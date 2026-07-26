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
@export var hold_duration: float = 1.5
## Ab wann die Vorschau eingeblendet wird (Anteil der Haltedauer).
@export_range(0.0, 1.0) var preview_threshold: float = 0.25

const RESET_ACTION: String = "reset"

var _hold_time: float = 0.0
var _preview_seed_code: String = ""
var _is_restarting: bool = false

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


func _process(delta: float) -> void:
	if _is_restarting:
		return
	if not InputMap.has_action(RESET_ACTION):
		return

	if not Input.is_action_pressed(RESET_ACTION):
		_cancel()
		return

	if _hold_time <= 0.0:
		_begin_hold()

	_hold_time += delta
	var progress: float = clampf(_hold_time / maxf(hold_duration, 0.01), 0.0, 1.0)

	# Quadratisch statt linear: die Abblende soll spaet richtig zupacken,
	# damit das Bild waehrend der Entscheidungsphase noch lesbar bleibt.
	_fade.color.a = progress * progress
	_preview_box.visible = progress >= preview_threshold

	if progress >= 1.0:
		_restart()


func _begin_hold() -> void:
	_preview_seed_code = _peek_next_seed_code()
	_preview_label.text = _preview_seed_code


func _cancel() -> void:
	if _hold_time <= 0.0:
		return
	_hold_time = 0.0
	_preview_box.visible = false

	# Sanft aufblenden statt hart auf 0: ein abrupter Sprung sieht aus wie
	# ein Darstellungsfehler.
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 0.0, 0.18)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _restart() -> void:
	_is_restarting = true
	_fade.color.a = 1.0

	# Aufraeumen, bevor die Szene neu geladen wird: ein laufender Hit-Stop
	# wuerde sonst mit eingefrorenem Engine.time_scale in den neuen Run
	# uebernommen, und Loot/Items wuerden Zustaende aus dem alten Lauf
	# behalten.
	Juice.cancel()

	var items: Node = get_node_or_null("/root/Items")
	if items and items.has_method("reset_run"):
		items.reset_run()

	var loot: Node = get_node_or_null("/root/Loot")
	if loot and loot.has_method("reset_run"):
		loot.reset_run()

	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()

	# Nach dem Reload existiert dieses Overlay weiter (es haengt in einem
	# Autoload-CanvasLayer), also selbst zuruecksetzen.
	_hold_time = 0.0
	_is_restarting = false
	_preview_box.visible = false
	_fade.color.a = 0.0


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
