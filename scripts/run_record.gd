extends RefCounted
class_name RunRecord

## Ein abgeschlossener Speedrun-Lauf in der Form, in der er auf das
## Steam-Leaderboard geht.
##
## STEAM-FORMAT:
## Ein Leaderboard-Eintrag besteht aus genau EINEM int32-Score plus einem
## optionalen PackedInt32Array ("details", max. 64 Werte). Alles, was den
## Run verifizierbar macht, muss also in int32 passen.
##
##   score       = Laufzeit in MILLISEKUNDEN (aufsteigend sortiert)
##   details[0]  = Format-Version dieses Records
##   details[1]  = Run-Seed
##   details[2]  = Build-Nummer des Spiels
##   details[3]  = Charakter-Index
##   details[4]  = erreichte Stage
##   details[5]  = geclearte Raeume
##   details[6]  = Pruefsumme
##
## WARUM MILLISEKUNDEN UND NICHT SEKUNDEN:
## Steam sortiert nach int32. Sekunden waeren fuer einen Run, der auf
## Hundertstel entschieden wird, viel zu grob; RunTimer rechnet ohnehin
## intern in Hundertsteln. int32 reicht fuer 24 Tage Laufzeit.
##
## WARUM DIE BUILD-NUMMER MITMUSS:
## Aendert sich Dash-Geschwindigkeit, Bossleben oder die Raumgroesse, sind
## alte Zeiten nicht mehr vergleichbar. Mit der Build-Nummer im Eintrag
## kann die Anzeige veraltete Runs markieren oder ausblenden, statt das
## ganze Leaderboard wegwerfen zu muessen.

const FORMAT_VERSION: int = 1

## Bei JEDER Aenderung hochzaehlen, die Laufzeiten beeinflusst
## (Movement, Schaden, Raumgroesse, Gegner-Budget).
const BUILD_NUMBER: int = 1

const DETAIL_COUNT: int = 7

var time_ms: int = 0
var run_seed: int = 0
var build_number: int = BUILD_NUMBER
var character_index: int = 0
var stage_reached: int = 1
var rooms_cleared: int = 0
var format_version: int = FORMAT_VERSION

## Nur bei heruntergeladenen Eintraegen gefuellt.
var steam_id: int = 0
var persona_name: String = ""
var global_rank: int = 0


static func create(p_time_ms: int, p_seed: int, p_character: int, p_stage: int, p_rooms: int) -> RunRecord:
	var rec := RunRecord.new()
	rec.time_ms = maxi(p_time_ms, 0)
	rec.run_seed = p_seed
	rec.character_index = p_character
	rec.stage_reached = p_stage
	rec.rooms_cleared = p_rooms
	return rec


## Packt die Zusatzdaten in das Steam-Detail-Array.
func to_details() -> PackedInt32Array:
	var details := PackedInt32Array()
	details.resize(DETAIL_COUNT)
	details[0] = format_version
	details[1] = run_seed
	details[2] = build_number
	details[3] = character_index
	details[4] = stage_reached
	details[5] = rooms_cleared
	details[6] = _checksum()
	return details


## Liest einen heruntergeladenen Eintrag zurueck. Faellt bei zu kurzen
## oder fremden Detail-Arrays auf Standardwerte zurueck, statt zu crashen -
## auf einem Live-Leaderboard liegen immer auch Eintraege aus aelteren
## Builds.
static func from_entry(entry: Dictionary) -> RunRecord:
	var rec := RunRecord.new()
	rec.time_ms = int(entry.get("score", 0))
	rec.steam_id = int(entry.get("steam_id", 0))
	rec.global_rank = int(entry.get("global_rank", 0))

	var details: Array = []
	var raw: Variant = entry.get("details", [])
	if raw is PackedInt32Array or raw is Array:
		details = Array(raw)

	if details.size() >= 7:
		rec.format_version = int(details[0])
		rec.run_seed = int(details[1])
		rec.build_number = int(details[2])
		rec.character_index = int(details[3])
		rec.stage_reached = int(details[4])
		rec.rooms_cleared = int(details[5])

	return rec


## Wurde der Eintrag mit dem aktuellen Spielstand aufgestellt?
func is_current_build() -> bool:
	return build_number == BUILD_NUMBER


## Plausibilitaetspruefung. Faengt KEINE gezielte Manipulation ab (der
## Client kennt die Formel), aber jeden kaputten oder aus einer anderen
## Version stammenden Eintrag - und genau darum geht es hier.
func is_plausible() -> bool:
	if time_ms <= 0:
		return false
	if run_seed <= 0 or run_seed > DetRng.MAX_SEED:
		return false
	if stage_reached < 1 or rooms_cleared < 0:
		return false
	return true


func get_seed_code() -> String:
	return DetRng.seed_to_code(run_seed)


func get_time_string() -> String:
	return RunTimer.format_time(float(time_ms) / 1000.0)


func _checksum() -> int:
	var raw: String = "%d|%d|%d|%d|%d|%d" % [
		time_ms, run_seed, build_number, character_index, stage_reached, rooms_cleared
	]
	return absi(hash(raw)) % 2147483647
