
extends Control
class_name RunTimer

## Speedrun-Timer neben der Minimap.
##
## START-LOGIK: Der Timer startet automatisch, sobald zum ersten Mal eine
## gueltige Spieler-Instanz existiert (PartyManager.player) — also genau in
## dem Moment, in dem der Spieler die Map betritt. Ein manueller start()
## ist dadurch NICHT noetig, kann aber (z.B. von einem Cutscene-Ende aus)
## trotzdem aufgerufen werden.
##
## PAUSE: process_mode bleibt bewusst auf PROCESS_MODE_INHERIT. Dadurch
## friert der Timer ein, sobald get_tree().paused == true (Pausemenue,
## Grosskarte mit Pause, Death-Screen). Ein Speedrun-Timer, der im
## Pausemenue weiterlaeuft, waere fuer Runs unbrauchbar.
##
## STOPPEN: win_screen.gd / death_screen.gd koennen ueber die Gruppe
## RUN_TIMER_GROUP an diesen Node kommen und stop() aufrufen — die
## Endzeit bleibt dann stehen und ist ueber get_time_string() auslesbar.

const RUN_TIMER_GROUP: String = "run_timer"
const MINIMAP_GROUP: String = "minimap"

@onready var time_label: Label = $TimeLabel

## --- Andocken an die Minimap -------------------------------------------
##
## PROBLEM: Die Position des Timers stand fest in hud.tscn (offset_left =
## 280). Die Minimap wird dagegen ueber Control.scale mit
## SettingsManager.minimap_ui_scale vergroessert. Ab etwa 1.2 schiebt sich
## ihr Rahmen unter den Timer — bei dem neuen Standardwert 1.35 also
## sofort.
##
## LOESUNG: Der Timer liest das TATSAECHLICH belegte Rechteck der Minimap
## (Minimap.get_docking_rect(), scale-korrigiert) und setzt seine eigene
## Position rechts daneben. Bewusst hier und nicht in hud.tscn: eine feste
## Zahl in der Szene kann nicht auf einen Laufzeit-Regler reagieren.
@export var dock_to_minimap: bool = true
## Abstand zwischen Minimap-Rahmen und Timer in Pixeln.
@export var dock_gap: float = 16.0

## Position aus hud.tscn. Faellt zurueck, wenn keine Minimap existiert
## (Testlevel) oder das Andocken abgeschaltet ist.
var _fallback_position: Vector2 = Vector2.ZERO
var _minimap: Control = null

## Wenn false, muss start() explizit aufgerufen werden.
@export var auto_start_on_player_spawn: bool = true

## Text, der vor dem Start angezeigt wird.
@export var idle_text: String = "0.00"

var _elapsed: float = 0.0
var _running: bool = false
var _started: bool = false


func _ready() -> void:
	add_to_group(RUN_TIMER_GROUP)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_elapsed = 0.0
	_running = false
	_started = false
	if time_label:
		time_label.text = idle_text

	_fallback_position = position

	# Auf das Sammelsignal hoeren: minimap_ui_scale aendert sich zur
	# Laufzeit im Einstellungsmenue, und der Timer muss dann sofort
	# mitwandern statt erst beim naechsten Szenenwechsel.
	if SettingsManager != null and SettingsManager.has_signal("minimap_setting_changed"):
		if not SettingsManager.minimap_setting_changed.is_connected(_update_dock):
			SettingsManager.minimap_setting_changed.connect(_update_dock)

	get_viewport().size_changed.connect(_update_dock)

	# Ein Frame warten: die Minimap baut ihr Raum-Overlay in _ready() und
	# veraendert dabei die Rahmenhoehe. Wer vorher misst, dockt an die
	# noch unfertige Groesse an.
	_update_dock.call_deferred()


## Setzt die X-Position rechts neben die Minimap. Idempotent — ein
## doppelter Aufruf macht nichts kaputt.
func _update_dock() -> void:
	if not dock_to_minimap:
		position = _fallback_position
		return

	if _minimap == null or not is_instance_valid(_minimap):
		var found: Array[Node] = get_tree().get_nodes_in_group(MINIMAP_GROUP)
		if found.is_empty():
			position = _fallback_position
			return
		_minimap = found[0] as Control

	if _minimap == null or not _minimap.has_method("get_docking_rect"):
		position = _fallback_position
		return

	# Ausgeblendete Minimap (HUD-Element abgeschaltet) darf den Timer
	# nicht an eine Geisterposition heften.
	if not _minimap.visible:
		position = _fallback_position
		return

	var rect: Rect2 = _minimap.get_docking_rect()
	position = Vector2(rect.position.x + rect.size.x + dock_gap, rect.position.y)

	# Die Sichtbarkeit steuert zentral hud.gd (Master-Schalter UND
	# Element-Schalter) — hier bewusst NICHT nochmal gesetzt, sonst gaebe
	# es zwei konkurrierende Quellen fuer denselben Zustand.


func _process(delta: float) -> void:
	# Guenstiger Abgleich: nur nachziehen, wenn sich wirklich etwas
	# verschoben hat. get_docking_rect() ist eine reine Rechnung ohne
	# Baumsuche, solange _minimap gebunden ist.
	if dock_to_minimap and _minimap != null and is_instance_valid(_minimap):
		var rect: Rect2 = _minimap.get_docking_rect()
		var wanted := Vector2(rect.position.x + rect.size.x + dock_gap, rect.position.y)
		if _minimap.visible and not position.is_equal_approx(wanted):
			position = wanted

	if not _started and auto_start_on_player_spawn:
		if PartyManager.player and is_instance_valid(PartyManager.player):
			start()

	if not _running:
		return

	_elapsed += delta
	if time_label:
		time_label.text = format_time(_elapsed)


# --- Oeffentliche API ---------------------------------------------------

func start() -> void:
	_started = true
	_running = true


func stop() -> void:
	_running = false


func reset() -> void:
	_elapsed = 0.0
	_running = false
	_started = false
	if time_label:
		time_label.text = idle_text


func restart() -> void:
	_elapsed = 0.0
	_started = true
	_running = true


func is_running() -> bool:
	return _running


func get_elapsed() -> float:
	return _elapsed


func get_time_string() -> String:
	return format_time(_elapsed)


## Laufzeit in ganzen Millisekunden - das Format, das das Steam-Leaderboard
## als int32-Score erwartet. Bewusst abgerundet statt gerundet: eine Zeit
## darf durch das Hochladen nicht besser werden, als sie gelaufen wurde.
func get_elapsed_ms() -> int:
	return int(floor(maxf(_elapsed, 0.0) * 1000.0))


## Format: Sekunden mit zwei Nachkommastellen ("42.17"). Minuten werden
## NUR vorangestellt, sobald es welche gibt ("1.42.17").
##
## Bewusst ueber Hundertstel als int gerechnet statt ueber fmod(): float-
## Rundung wuerde bei 59.999 sonst "59.100" statt "1.00.00" erzeugen.
static func format_time(seconds: float) -> String:
	var total_cs: int = int(floor(maxf(seconds, 0.0) * 100.0))
	var minutes: int = total_cs / 6000
	var secs: int = (total_cs / 100) % 60
	var cs: int = total_cs % 100

	if minutes > 0:
		return "%d.%02d.%02d" % [minutes, secs, cs]
	return "%d.%02d" % [secs, cs]
