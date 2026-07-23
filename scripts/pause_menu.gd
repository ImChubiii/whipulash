# scripts/pause_menu.gd
extends Control
class_name PauseMenu

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

@export var settings_menu_path: NodePath
var settings_menu: SettingsMenu

var _blur_overlay: ColorRect = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_blur_overlay = _get_or_create_shared_blur()
	_fix_panel_background()

	if settings_menu_path != NodePath(""):
		settings_menu = get_node_or_null(settings_menu_path)

	if settings_menu:
		settings_menu.back_pressed.connect(_on_settings_back)
	else:
		push_warning("PauseMenu: settings_menu_path ist nicht gesetzt — Settings-Button bleibt ohne Funktion.")

	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _fix_panel_background() -> void:
	var panel := get_node_or_null("Panel") as Panel
	if panel == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.82)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	panel.add_theme_stylebox_override("panel", style)


func _get_or_create_shared_blur() -> ColorRect:
	var parent := get_parent()

	var existing := parent.get_node_or_null("BlurOverlay")
	if existing is ColorRect:
		return existing

	var shader := load("res://shaders/menu_blur.gdshader") as Shader
	if shader == null:
		push_warning("PauseMenu: menu_blur.gdshader nicht gefunden — Blur-Effekt fehlt.")
		return null

	var mat := ShaderMaterial.new()
	mat.shader = shader

	var blur := ColorRect.new()
	blur.name = "BlurOverlay"
	blur.process_mode = Node.PROCESS_MODE_ALWAYS
	blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blur.material = mat
	blur.visible = false

	parent.add_child(blur)
	parent.move_child(blur, 0)
	blur.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	return blur


func _is_endscreen_active() -> bool:
	var parent := get_parent()

	var death_screen := parent.get_node_or_null("DeathScreen") as Control
	if death_screen != null and is_instance_valid(death_screen) and death_screen.visible:
		return true

	var win_screen := parent.get_node_or_null("WinScreen") as Control
	if win_screen != null and is_instance_valid(win_screen) and win_screen.visible:
		return true

	return false


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		return

	if _is_endscreen_active():
		get_viewport().set_input_as_handled()
		return

	if settings_menu != null and is_instance_valid(settings_menu) and settings_menu.visible:
		_on_settings_back()
	elif visible:
		_resume()
	else:
		_open_pause()

	get_viewport().set_input_as_handled()


func _open_pause() -> void:
	if _blur_overlay:
		_blur_overlay.visible = true
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _resume() -> void:
	if _blur_overlay:
		_blur_overlay.visible = false
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_resume_pressed() -> void:
	_resume()


func _on_settings_pressed() -> void:
	if _blur_overlay:
		_blur_overlay.visible = false
	visible = false
	if settings_menu != null and is_instance_valid(settings_menu):
		settings_menu.open()


func _on_settings_back() -> void:
	if settings_menu != null and is_instance_valid(settings_menu):
		settings_menu.close()
	if _blur_overlay:
		_blur_overlay.visible = true
	visible = true


func _on_restart_pressed() -> void:
	if _blur_overlay:
		_blur_overlay.visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
