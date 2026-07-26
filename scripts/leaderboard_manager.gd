extends Node

## Autoload "LeaderboardManager" - Steam-Leaderboards fuer Lemonade.
##
## WARUM EINE WARTESCHLANGE:
## Die Steam-API erlaubt pro Leaderboard immer nur EINE laufende
## Operation. Wer Upload und Download gleichzeitig anstoesst, bekommt
## still verworfene Callbacks - typisch dafuer ist ein Leaderboard, das
## "manchmal" leer bleibt. Deshalb laeuft hier alles strikt seriell:
## Handle suchen -> hochladen -> herunterladen -> anzeigen.
##
## ZWEI BRETTER:
##   ALLTIME  - jeder Run, Seed steht in den Details (nachspielbar)
##   DAILY    - alle Spieler bekommen denselben Seed des Tages; erst hier
##              werden Zeiten wirklich direkt vergleichbar, weil das
##              Layout identisch ist
##
## Ohne Steam (Addon fehlt, Client aus, Offline) meldet sich der Manager
## einmal ueber unavailable() und tut danach schlicht nichts. Das Spiel
## laeuft normal weiter.

signal submit_finished(success: bool, is_new_best: bool)
signal entries_ready(records: Array, scope: String)
signal unavailable(reason: String)

## Steam-Konstanten. Bewusst als Rohwerte, weil auf Steam.XY nicht
## zugegriffen werden kann, ohne das Projekt ohne Addon unlesbar zu
## machen - siehe steam_manager.gd.
const SORT_ASCENDING: int = 1              ## kleinere Zeit = besser
const DISPLAY_TIME_MILLISECONDS: int = 3
const REQUEST_GLOBAL: int = 0
const REQUEST_GLOBAL_AROUND_USER: int = 1
const REQUEST_FRIENDS: int = 2

const SCOPE_ALLTIME: String = "alltime"
const SCOPE_DAILY: String = "daily"

## Namen der Bretter. Werden bei Bedarf angelegt (findOrCreateLeaderboard),
## damit du sie nicht fuer jeden Tag von Hand im Partnerportal pflegen
## musst.
@export var alltime_board_name: String = "LEMONADE_ANY_PERCENT"
@export var daily_board_prefix: String = "LEMONADE_DAILY_"

## Muss vor dem Download gesetzt werden, sonst liefert Steam die Details
## (und damit den Seed) gar nicht erst mit.
@export var details_max: int = RunRecord.DETAIL_COUNT

@export var default_entry_count: int = 10

enum _Op { NONE, FIND, UPLOAD, DOWNLOAD }

var _steam: Object = null
var _handles: Dictionary = {}          ## scope -> leaderboard handle
var _queue: Array[Dictionary] = []
var _current: Dictionary = {}
var _op: int = _Op.NONE
var _signals_connected: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ensure_ready() -> bool:
	if not SteamManager.is_available():
		unavailable.emit("Steam nicht verfuegbar - Leaderboard uebersprungen.")
		return false

	if _signals_connected:
		return true

	_steam = SteamManager.get_steam()
	_connect("leaderboard_find_result", _on_find_result)
	_connect("leaderboard_score_uploaded", _on_score_uploaded)
	_connect("leaderboard_scores_downloaded", _on_scores_downloaded)

	if _steam.has_method("setLeaderboardDetailsMax"):
		_steam.call("setLeaderboardDetailsMax", details_max)

	_signals_connected = true
	return true


## Defensiv verbinden: GodotSteam hat Signalnamen ueber die Versionen
## mehrfach angepasst. Ein fehlendes Signal soll eine Warnung geben, nicht
## das Spiel beim Start abschiessen.
func _connect(signal_name: String, callable: Callable) -> void:
	if not _steam.has_signal(signal_name):
		push_warning("[LeaderboardManager] GodotSteam kennt kein Signal '%s' - Leaderboard bleibt unvollstaendig. GodotSteam-Version pruefen." % signal_name)
		return
	if _steam.is_connected(signal_name, callable):
		return
	_steam.connect(signal_name, callable)


# --- Oeffentliche API ---------------------------------------------------

## Seed des Tages. Aus dem UTC-Datum abgeleitet, damit weltweit alle
## denselben Lauf bekommen - lokale Zeitzonen wuerden sonst zwei
## verschiedene "Heute" erzeugen.
static func get_daily_seed() -> int:
	var utc: Dictionary = Time.get_datetime_dict_from_system(true)
	var key: String = "%04d-%02d-%02d" % [utc["year"], utc["month"], utc["day"]]
	return absi(DetRng.derive(20260101, key)) % DetRng.MAX_SEED + 1


static func get_daily_key() -> String:
	var utc: Dictionary = Time.get_datetime_dict_from_system(true)
	return "%04d%02d%02d" % [utc["year"], utc["month"], utc["day"]]


func get_daily_board_name() -> String:
	return daily_board_prefix + get_daily_key()


func board_name_for(scope: String) -> String:
	return get_daily_board_name() if scope == SCOPE_DAILY else alltime_board_name


## Laedt einen abgeschlossenen Run hoch. keep_best sorgt dafuer, dass eine
## schlechtere Zeit den eigenen Rekord nicht ueberschreibt.
func submit_run(record: RunRecord, scope: String = SCOPE_ALLTIME) -> void:
	if record == null or not record.is_plausible():
		submit_finished.emit(false, false)
		return
	if not _ensure_ready():
		submit_finished.emit(false, false)
		return

	_enqueue({"op": _Op.UPLOAD, "scope": scope, "record": record})


## Holt die weltweite Top-Liste.
func request_top(count: int = 0, scope: String = SCOPE_ALLTIME) -> void:
	if not _ensure_ready():
		return
	var n: int = count if count > 0 else default_entry_count
	_enqueue({"op": _Op.DOWNLOAD, "scope": scope, "type": REQUEST_GLOBAL, "start": 1, "end": n})


## Holt die Eintraege rund um den eigenen Rang - der interessantere Blick,
## sobald man nicht mehr in den Top 10 steht.
func request_around_user(spread: int = 4, scope: String = SCOPE_ALLTIME) -> void:
	if not _ensure_ready():
		return
	_enqueue({"op": _Op.DOWNLOAD, "scope": scope, "type": REQUEST_GLOBAL_AROUND_USER, "start": -spread, "end": spread})


func request_friends(count: int = 0, scope: String = SCOPE_ALLTIME) -> void:
	if not _ensure_ready():
		return
	var n: int = count if count > 0 else default_entry_count
	_enqueue({"op": _Op.DOWNLOAD, "scope": scope, "type": REQUEST_FRIENDS, "start": 1, "end": n})


# --- Warteschlange ------------------------------------------------------

func _enqueue(job: Dictionary) -> void:
	_queue.append(job)
	_pump()


func _pump() -> void:
	if _op != _Op.NONE:
		return
	if _queue.is_empty():
		return

	_current = _queue.pop_front()
	var scope: String = _current.get("scope", SCOPE_ALLTIME)

	# Handle fehlt noch -> erst suchen, Job wieder vorne einreihen.
	if not _handles.has(scope):
		_queue.push_front(_current)
		_op = _Op.FIND
		_current = {"op": _Op.FIND, "scope": scope}
		_steam.call("findOrCreateLeaderboard", board_name_for(scope), SORT_ASCENDING, DISPLAY_TIME_MILLISECONDS)
		return

	var handle: int = _handles[scope]
	match int(_current["op"]):
		_Op.UPLOAD:
			_op = _Op.UPLOAD
			var record: RunRecord = _current["record"]
			_steam.call("uploadLeaderboardScore", record.time_ms, true, record.to_details(), handle)
		_Op.DOWNLOAD:
			_op = _Op.DOWNLOAD
			_steam.call("downloadLeaderboardEntries", int(_current["start"]), int(_current["end"]), int(_current["type"]), handle)
		_:
			_finish_op()


func _finish_op() -> void:
	_op = _Op.NONE
	_current = {}
	_pump()


# --- Steam-Callbacks ----------------------------------------------------

func _on_find_result(leaderboard_handle: int, found: int) -> void:
	if _op != _Op.FIND:
		return

	var scope: String = _current.get("scope", SCOPE_ALLTIME)
	if found == 0 or leaderboard_handle == 0:
		push_warning("[LeaderboardManager] Leaderboard '%s' konnte nicht gefunden/angelegt werden." % board_name_for(scope))
		# Passende Jobs verwerfen, sonst sucht der Manager endlos weiter.
		_queue = _queue.filter(func(j: Dictionary) -> bool: return j.get("scope", "") != scope)
		unavailable.emit("Leaderboard '%s' nicht verfuegbar." % board_name_for(scope))
		_finish_op()
		return

	_handles[scope] = leaderboard_handle
	print("[LeaderboardManager] Leaderboard '%s' bereit (Handle %d)." % [board_name_for(scope), leaderboard_handle])
	_finish_op()


func _on_score_uploaded(success: int, _leaderboard_handle: int, this_score: Dictionary) -> void:
	if _op != _Op.UPLOAD:
		return

	var ok: bool = success == 1
	var improved: bool = bool(this_score.get("score_changed", false))
	if ok:
		print("[LeaderboardManager] Zeit hochgeladen: %d ms, neuer Rang %s (vorher %s)." % [
			int(this_score.get("score", 0)),
			str(this_score.get("global_rank_new", "?")),
			str(this_score.get("global_rank_previous", "?"))
		])
	else:
		push_warning("[LeaderboardManager] Upload fehlgeschlagen.")

	submit_finished.emit(ok, improved)
	_finish_op()


func _on_scores_downloaded(_message: String, _leaderboard_handle: int, result: Array) -> void:
	if _op != _Op.DOWNLOAD:
		return

	var scope: String = _current.get("scope", SCOPE_ALLTIME)
	var records: Array = []
	for entry in result:
		if entry is Dictionary:
			var rec: RunRecord = RunRecord.from_entry(entry)
			records.append(rec)

	records.sort_custom(func(a: RunRecord, b: RunRecord) -> bool:
		return a.time_ms < b.time_ms
	)

	entries_ready.emit(records, scope)
	_finish_op()
