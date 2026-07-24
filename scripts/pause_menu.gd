
# scripts/pause_menu.gd
extends Control
class_name PauseMenu

# HUD liegt in JEDEM Level immer im selben CanvasLayer wie die Overlay-
# Screens (Pause/Death/Win/Settings), aber die tatsächliche Sibling-
# Reihenfolge im Szenenbaum variiert von Level zu Level (in level_01.tscn
# z.B. wird HUD als LETZTES Kind hinzugefügt -> würde ohne z_index über
# allem anderen liegen). z_index macht die Zeichenreihenfolge unabhängig
# davon, wie die Level-Autoren die Nodes im Baum anordnen.
const Z_INDEX_BLUR: int = 10
const Z_INDEX_MENU: int = 20

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

@export var settings_menu_path: NodePath
var settings_menu: SettingsMenu

var _blur_overlay: ColorRect = null

# Wird von death_screen.gd / win_screen.gd SOFORT beim Tod/Sieg gesetzt
# (nicht erst wenn der jeweilige Screen sichtbar wird — bei DeathScreen
# liegt dazwischen noch eine Verzögerung, siehe death_screen_delay). Damit
# ist ESC/Pause exakt ab dem Moment gesperrt, in dem das Spiel logisch
# vorbei ist, nicht erst ab dem sichtbaren Screen.
var _locked_out: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	z_index = Z_INDEX_MENU

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
		existing.z_index = Z_INDEX_BLUR
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
	# Liegt ueber dem HUD, aber UNTER den Menu-Panels (Z_INDEX_MENU) —
	# unabhaengig von der Sibling-Reihenfolge im Baum.
	blur.z_index = Z_INDEX_BLUR

	parent.add_child(blur)
	parent.move_child(blur, 0)
	blur.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	return blur


# Wird von death_screen.gd bzw. win_screen.gd aufgerufen, SOBALD das Spiel
# logisch endet (nicht erst wenn der jeweilige Screen sichtbar wird).
# Ab dann kann Pause fuer den Rest des Levels nicht mehr geoeffnet werden —
# ein bereits offenes PauseMenu wird dabei defensiv geschlossen.
func lock_out() -> void:
	_locked_out = true
	if visible:
		visible = false
		if _blur_overlay:
			_blur_overlay.visible = false


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

	# _locked_out deckt die Zeit ZWISCHEN Tod/Sieg und dem sichtbaren
	# Death-/Win-Screen ab (death_screen_delay!). _is_endscreen_active()
	# bleibt zusaetzlich als Absicherung, falls lock_out() aus irgendeinem
	# Grund nicht aufgerufen wurde.
	if _locked_out or _is_endscreen_active():
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
	if _locked_out:
		return
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
