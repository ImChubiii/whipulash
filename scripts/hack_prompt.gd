extends CanvasLayer
class_name HackPrompt

## Bildschirm-Prompt fuer das Tuer-Hacking ("HACKING" + Fortschrittsbalken).
##
## Wird zur Laufzeit erzeugt, damit keine Szene angefasst werden muss.
## Jede Tuer ruft nur HackPrompt.get_or_create(self) auf - es existiert
## immer genau eine Instanz pro Szenenbaum (Gruppe "hack_prompt").

const GROUP_NAME := "hack_prompt"

@export var bar_size: Vector2 = Vector2(320.0, 14.0)
@export var color_bar_bg: Color = Color(0.05, 0.06, 0.05, 0.75)
@export var color_bar_fill: Color = Color(0.85, 0.12, 0.12, 1.0)
@export var color_text: Color = Color(0.92, 0.94, 0.88, 1.0)

var _root: Control = null
var _label: Label = null
var _hint: Label = null
var _bar_bg: ColorRect = null
var _bar_fill: ColorRect = null
var _progress: float = 0.0


static func find_existing(context: Node) -> Node:
	var found: Array[Node] = context.get_tree().get_nodes_in_group(GROUP_NAME)
	if found.is_empty():
		return null
	return found[0]


static func get_or_create(context: Node) -> Node:
	var existing: Node = find_existing(context)
	if existing:
		return existing

	var prompt := HackPrompt.new()
	prompt.name = "HackPrompt"
	var parent: Node = context.get_tree().current_scene
	if parent == null:
		parent = context.get_tree().get_root()
	parent.add_child(prompt)
	return prompt


func _ready() -> void:
	add_to_group(GROUP_NAME)
	layer = 5
	_build_ui()
	hide_prompt()


func _build_ui() -> void:
	_root = Control.new()
	_root.name = "PromptRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var box := VBoxContainer.new()
	box.name = "Box"
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Etwas unterhalb der Bildmitte, damit das Fadenkreuz frei bleibt.
	box.position = Vector2(-bar_size.x * 0.5, 120.0)
	box.custom_minimum_size = Vector2(bar_size.x, 0.0)
	_root.add_child(box)

	_label = Label.new()
	_label.text = "HACKING"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_color_override("font_color", color_text)
	_label.add_theme_font_size_override("font_size", 26)
	box.add_child(_label)

	_bar_bg = ColorRect.new()
	_bar_bg.color = color_bar_bg
	_bar_bg.custom_minimum_size = bar_size
	_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_bar_bg)

	_bar_fill = ColorRect.new()
	_bar_fill.color = color_bar_fill
	_bar_fill.size = Vector2(0.0, bar_size.y)
	_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(_bar_fill)

	_hint = Label.new()
	_hint.text = "[F] GEDRUECKT HALTEN"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_color_override("font_color", color_text)
	_hint.add_theme_font_size_override("font_size", 14)
	box.add_child(_hint)


## progress: 0.0 - 1.0. events dient nur dazu, die tatsaechlich belegte
## Taste anzuzeigen (der Spieler kann sie in den Einstellungen umbinden).
func show_prompt(text: String, progress: float, events: Array = []) -> void:
	if _root == null:
		return
	_progress = clampf(progress, 0.0, 1.0)
	_root.visible = true
	_label.text = text
	_bar_fill.size = Vector2(bar_size.x * _progress, bar_size.y)
	_hint.text = "[%s] GEDRUECKT HALTEN" % _key_name(events)


func hide_prompt() -> void:
	if _root:
		_root.visible = false
	_progress = 0.0


func _key_name(events: Array) -> String:
	for e in events:
		if e is InputEventKey:
			var key: InputEventKey = e
			var code: Key = key.physical_keycode if key.physical_keycode != 0 else key.keycode
			return OS.get_keycode_string(code).to_upper()
		if e is InputEventMouseButton:
			return "MAUS %d" % (e as InputEventMouseButton).button_index
	return "F"
