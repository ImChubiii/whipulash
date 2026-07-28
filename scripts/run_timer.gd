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

@onready var time_label: Label = $TimeLabel

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

	# Die Sichtbarkeit steuert zentral hud.gd (Master-Schalter UND
	# Element-Schalter) — hier bewusst NICHT nochmal gesetzt, sonst gaebe
	# es zwei konkurrierende Quellen fuer denselben Zustand.


func _process(delta: float) -> void:
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
