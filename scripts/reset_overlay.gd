
extends Control
class_name ResetOverlay

# ============================================================================
# ResetOverlay — "R" gedrueckt halten blendet ab und startet das Level neu.
# ============================================================================
#
# WARUM HALTEN STATT DRUECKEN:
# Ein Neustart auf Tastendruck ist in einem Spiel mit Speedrun-Timer eine
# Falle: R liegt direkt neben den Bewegungstasten. Das Halten macht den
# Abbruch zu einer bewussten Entscheidung, und die 1,5 Sekunden Abblende
# sind gleichzeitig das Zeitfenster, in dem man es sich anders ueberlegen
# kann.
#
# DAS VORSCHAU-FENSTER:
# Waehrend gehalten wird, steht der Seed des naechsten Runs auf dem Bild.
# Wer ihn kennt, kann entscheiden, ob sich der Neustart lohnt — loslassen
# bricht ab, weiter halten startet neu. Der Seed wird EINMAL beim Beginn
# des Haltens gezogen und dann festgehalten: ein pro Frame neu gewuerfelter
# Wert waere als Vorschau wertlos.
#
# Der Input wird ueber Input.is_action_pressed() GEPOLLT statt ueber
# _unhandled_input, weil es hier um einen Haltezustand geht und nicht um ein
# Ereignis. Ein losgelassenes R soll sofort abbrechen, auch wenn in dem
# Frame gar kein Input-Event ankommt.

## Sekunden, die R gehalten werden muss.
## Von 1.5 auf 0.9 gesenkt: 1,5 s fuehlen sich bei einem Run, den man in
## der ersten Sekunde als verloren erkennt, wie eine Strafe an. 0,9 s ist
## immer noch deutlich mehr als ein versehentlicher Tastendruck.
@export var hold_duration: float = 0.9
## Ab wann die Vorschau eingeblendet wird (Anteil der Haltedauer).
@export_range(0.0, 1.0) var preview_threshold: float = 0.25

const RESET_ACTION: String = "reset"

## Notnagel, falls die Action "reset" im InputMap fehlt (Projekt ohne den
## SettingsManager-Autoload, kaputte Settings-Datei, frisch geklonter
## Branch). Ohne diesen Fallback stieg _process() frueher kommentarlos aus
## und [R] tat GAR NICHTS — ohne jede Meldung, warum.
const RESET_FALLBACK_KEY: Key = KEY_R

## Gruppe, unter der sich PauseMenu selbst eintraegt. Siehe die ausfuehrliche
## Begruendung in pause_menu.gd, wo frueher ein zweiter, konkurrierender
## Reset-Pfad lag: dieser Guard ist der Ersatz dafuer, jetzt an der einzigen
## Stelle, die die Taste tatsaechlich verarbeitet.
const PAUSE_MENU_GROUP: String = "pause_menu"

var _hold_time: float = 0.0
var _preview_seed_code: String = ""
var _is_restarting: bool = false

## Lazy gebunden und bei Ungueltigkeit neu gesucht — PauseMenu wird bei
## jedem reload_current_scene() neu instanziiert, eine einmal gecachte
## Referenz waere nach dem ersten Neustart bereits eine Leiche.
var _pause_menu: PauseMenu = null

## Millisekunden-Zeitstempel des Haltebeginns.
##
## WARUM NICHT delta AUFADDIEREN:
## _process(delta) bekommt SKALIERTE Zeit. Waehrend eines Hit-Stops steht
## Engine.time_scale bei 0.05 — eine gehaltene Taste haette dort das
## 20-Fache an Echtzeit gebraucht. Time.get_ticks_msec() laeuft in echter
## Wanduhrzeit und ist damit unabhaengig von Zeitlupe und Pause.
var _hold_started_ms: int = 0

var _warned_missing_action: bool = false

var _fade: ColorRect = null
var _preview_box: PanelContainer = null
var _preview_label: Label = null
var _hint_label: Label = null


func _ready() -> void:
	# Der Neustart soll auch aus dem Pausenmenue heraus funktionieren, und
	# die Abblende darf beim Wechsel nicht einfrieren.
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	_fade = ColorRect.new()
	_fade.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fade)

	_preview_box = PanelContainer.new()
	_preview_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_box.visible = false
	_preview_box.set_anchors_preset(Control.PRESET_CENTER)
	_preview_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_preview_box.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.06, 0.80)
	style.border_color = Color(0.98, 0.80, 0.22, 0.75)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	_preview_box.add_theme_stylebox_override("panel", style)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 4)
	_preview_box.add_child(column)

	var title := Label.new()
	title.text = "NAECHSTER RUN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.60, 0.63, 0.68))
	column.add_child(title)

	_preview_label = Label.new()
	_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_label.add_theme_font_size_override("font_size", 30)
	_preview_label.add_theme_color_override("font_color", Color(0.98, 0.85, 0.35))
	column.add_child(_preview_label)

	_hint_label = Label.new()
	_hint_label.text = "loslassen zum Abbrechen"
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 11)
	_hint_label.add_theme_color_override("font_color", Color(0.55, 0.58, 0.62))
	column.add_child(_hint_label)

	add_child(_preview_box)


func _process(_delta: float) -> void:
	if _is_restarting:
		return

	# Ein bereits laufender Neustart (z.B. ueber den Pause-Button) darf
	# nicht noch einmal angestossen werden.
	var restarter: Node = get_node_or_null("/root/RunRestart")
	if restarter and restarter.has_method("is_restart_pending") and restarter.is_restart_pending():
		return

	# Waehrend Tod/Sieg gesperrt: dort gibt es eigene Restart-Buttons, und
	# ein Reset waehrend des laufenden Death-Delays wuerde die Screens
	# durcheinanderbringen. Diese Sperre stand FRUEHER in pause_menu.gd, das
	# parallel dazu die Taste selbst auswertete — mit den in _restart_level()
	# beschriebenen Folgen. Jetzt fragt der einzige verbliebene Reset-Pfad
	# sie direkt bei PauseMenu ab.
	if _is_reset_blocked():
		_cancel()
		return

	if not _is_reset_held():
		_cancel()
		return

	if _hold_time <= 0.0:
		_begin_hold()

	# Echtzeit statt skalierter delta-Summe — Begruendung an _hold_started_ms.
	_hold_time = float(Time.get_ticks_msec() - _hold_started_ms) / 1000.0
	var progress: float = clampf(_hold_time / maxf(hold_duration, 0.01), 0.0, 1.0)

	# Quadratisch statt linear: die Abblende soll spaet richtig zupacken,
	# damit das Bild waehrend der Entscheidungsphase noch lesbar bleibt.
	_fade.color.a = progress * progress
	_preview_box.visible = progress >= preview_threshold

	if progress >= 1.0:
		_restart()


## true, wenn PauseMenu gerade sagt, dass kein Reset stattfinden soll (Tod/
## Sieg-Uebergang oder ein Endscreen ist sichtbar). Liefert false, solange
## kein PauseMenu gefunden wird — Testszenen ohne Pausemenue sollen weiter
## normal neustarten koennen.
func _is_reset_blocked() -> bool:
	if _pause_menu == null or not is_instance_valid(_pause_menu):
		var found: Array[Node] = get_tree().get_nodes_in_group(PAUSE_MENU_GROUP)
		_pause_menu = found[0] as PauseMenu if not found.is_empty() else null
	if _pause_menu == null or not is_instance_valid(_pause_menu):
		return false
	return _pause_menu.is_reset_blocked()


## Fragt die Reset-Taste ab und faellt auf die physische [R] zurueck, wenn
## die Action gar nicht existiert. Die Warnung kommt bewusst nur EINMAL —
## als Meldung pro Frame waere sie in der Konsole nicht zu gebrauchen.
func _is_reset_held() -> bool:
	if InputMap.has_action(RESET_ACTION):
		return Input.is_action_pressed(RESET_ACTION)

	if not _warned_missing_action:
		_warned_missing_action = true
		push_warning("ResetOverlay: Action '%s' fehlt im InputMap - Fallback auf die physische Taste [R]. Autoload 'SettingsManager' pruefen." % RESET_ACTION)
	return Input.is_physical_key_pressed(RESET_FALLBACK_KEY)


func _begin_hold() -> void:
	_hold_started_ms = Time.get_ticks_msec()
	_preview_seed_code = _peek_next_seed_code()
	_preview_label.text = _preview_seed_code


func _cancel() -> void:
	if _hold_time <= 0.0:
		return
	_hold_time = 0.0
	_hold_started_ms = 0
	_preview_box.visible = false

	# Sanft aufblenden statt hart auf 0: ein abrupter Sprung sieht aus wie
	# ein Darstellungsfehler.
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 0.0, 0.18)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _restart() -> void:
	_is_restarting = true
	_fade.color.a = 1.0
	_preview_box.visible = false

	# Der komplette Aufraeum- und Reload-Ablauf liegt jetzt in RunRestart
	# (Autoload). Vorher stand er HIER — und nur hier: die Restart-Buttons
	# in Pause-, Death- und Win-Screen sprangen direkt auf
	# reload_current_scene() und haben Juice, Items und Loot NICHT
	# zurueckgesetzt. Ein Neustart per Taste und ein Neustart per Button
	# fuehrten damit in unterschiedliche Zustaende.
	var restarter: Node = get_node_or_null("/root/RunRestart")
	if restarter and restarter.has_method("restart"):
		restarter.restart()
	else:
		# Fallback, falls das Autoload nicht eingetragen ist: wenigstens
		# nicht in einem eingefrorenen Zustand haengenbleiben.
		push_warning("ResetOverlay: Autoload 'RunRestart' nicht gefunden - Notfall-Neustart ohne Aufraeumen.")
		Engine.time_scale = 1.0
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().reload_current_scene()

	# Dieses Overlay haengt in einem Autoload-CanvasLayer und ueberlebt den
	# Szenenwechsel — also selbst zuruecksetzen. Ein Frame Verzoegerung,
	# damit die Abblende waehrend des Wechsels stehen bleibt und nicht
	# mitten im Ladevorgang aufreisst.
	await get_tree().process_frame
	await get_tree().process_frame

	_hold_time = 0.0
	_hold_started_ms = 0
	_is_restarting = false
	_preview_box.visible = false

	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 0.0, 0.25)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Zieht den Seed-Code, den der naechste Run bekommen wuerde. Faellt auf
## einen frisch gewuerfelten Wert zurueck, wenn kein Generator da ist.
func _peek_next_seed_code() -> String:
	var generators: Array = get_tree().get_nodes_in_group("level_generator")
	if not generators.is_empty():
		var generator: Node = generators[0]
		if generator.has_method("get_run_seed"):
			# Derselbe Ableitungsweg wie im Generator: aus dem aktuellen
			# Seed plus einem festen Salt wird der Folge-Seed bestimmt.
			var next_seed: int = DetRng.derive(generator.get_run_seed(), "restart")
			return DetRng.seed_to_code(absi(next_seed) % DetRng.MAX_SEED)

	return DetRng.seed_to_code(DetRng.random_seed_value())




