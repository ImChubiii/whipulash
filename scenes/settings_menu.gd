extends Control
class_name SettingsMenu

signal back_pressed

@onready var tab_container: TabContainer = $Panel/VBoxContainer/TabContainer

# --- General ---
@onready var hud_visible_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/HUDVisibleRow/HUDVisibleCheck
@onready var crt_filter_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/CRTFilterRow/CRTFilterCheck
@onready var screen_shake_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/ScreenShakeRow/ScreenShakeCheck
@onready var colorblind_option: OptionButton = $Panel/VBoxContainer/TabContainer/General/ColorblindRow/ColorblindOption

# --- Video ---
@onready var display_mode_option: OptionButton = $Panel/VBoxContainer/TabContainer/Video/DisplayModeRow/DisplayModeOption
@onready var vsync_check: CheckButton = $Panel/VBoxContainer/TabContainer/Video/VSyncRow/VSyncCheck
@onready var fps_limit_option: OptionButton = $Panel/VBoxContainer/TabContainer/Video/FPSLimitRow/FPSLimitOption

# --- Audio ---
@onready var master_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/Audio/MasterVolumeRow
@onready var master_slider: HSlider = $Panel/VBoxContainer/TabContainer/Audio/MasterVolumeRow/MasterVolumeSlider
@onready var music_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/Audio/MusicVolumeRow
@onready var music_slider: HSlider = $Panel/VBoxContainer/TabContainer/Audio/MusicVolumeRow/MusicVolumeSlider
@onready var sfx_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/Audio/SFXVolumeRow
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/TabContainer/Audio/SFXVolumeRow/SFXVolumeSlider

# --- Controls ---
@onready var sensitivity_slider: HSlider = $Panel/VBoxContainer/TabContainer/Controls/SensitivityRow/SensitivitySlider
@onready var sensitivity_value_label: Label = $Panel/VBoxContainer/TabContainer/Controls/SensitivityRow/SensitivityValueLabel
@onready var keybinds_container: VBoxContainer = $Panel/VBoxContainer/TabContainer/Controls/KeybindsContainer

# --- Footer ---
@onready var conflict_label: Label = $Panel/VBoxContainer/ConflictLabel
@onready var reset_button: Button = $Panel/VBoxContainer/BottomRow/ResetButton
@onready var back_button: Button = $Panel/VBoxContainer/BottomRow/BackButton

@export var conflict_warning_duration: float = 2.5

const FPS_OPTIONS: Array[int] = [30, 60, 120, 144, 240, 0]

var _rebinding_action: String = ""
var _keybind_buttons: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_fix_panel_background()
	_setup_slider_ranges()
	_populate_option_buttons()
	_hide_missing_audio_buses()

	conflict_label.visible = false

	_connect_signals()
	_build_keybind_rows()
	_refresh_from_settings()


# Panel hat opaken Standardhintergrund — fix auf halbtransparent damit der
# BackgroundBlur (hint_screen_texture ColorRect) dahinter sichtbar wird.
func _fix_panel_background() -> void:
	var panel := get_node_or_null("Panel") as Panel
	if panel == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.82)  # Dunkel + leicht transparent
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	panel.add_theme_stylebox_override("panel", style)


func _setup_slider_ranges() -> void:
	sensitivity_slider.min_value = 0.0005
	sensitivity_slider.max_value = 0.01
	sensitivity_slider.step = 0.0001

	for slider in [master_slider, music_slider, sfx_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01


func _populate_option_buttons() -> void:
	display_mode_option.clear()
	display_mode_option.add_item("Windowed", SettingsManager.DISPLAY_MODE_WINDOWED)
	display_mode_option.add_item("Fullscreen", SettingsManager.DISPLAY_MODE_FULLSCREEN)
	display_mode_option.add_item("Borderless Windowed", SettingsManager.DISPLAY_MODE_BORDERLESS)

	fps_limit_option.clear()
	for fps in FPS_OPTIONS:
		var label: String = "Unlimited" if fps == 0 else "%d FPS" % fps
		fps_limit_option.add_item(label, fps)

	colorblind_option.clear()
	colorblind_option.add_item("Off", SettingsManager.COLORBLIND_OFF)
	colorblind_option.add_item("Protanopia", SettingsManager.COLORBLIND_PROTANOPIA)
	colorblind_option.add_item("Deuteranopia", SettingsManager.COLORBLIND_DEUTERANOPIA)
	colorblind_option.add_item("Tritanopia", SettingsManager.COLORBLIND_TRITANOPIA)


func _hide_missing_audio_buses() -> void:
	music_row.visible = SettingsManager.has_audio_bus("Music")
	sfx_row.visible = SettingsManager.has_audio_bus("SFX")


func _connect_signals() -> void:
	hud_visible_check.toggled.connect(SettingsManager.set_hud_visible)
	crt_filter_check.toggled.connect(SettingsManager.set_crt_filter_enabled)
	screen_shake_check.toggled.connect(SettingsManager.set_screen_shake_enabled)
	colorblind_option.item_selected.connect(_on_colorblind_selected)

	display_mode_option.item_selected.connect(_on_display_mode_selected)
	vsync_check.toggled.connect(SettingsManager.set_vsync)
	fps_limit_option.item_selected.connect(_on_fps_limit_selected)

	master_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("Master", v))
	music_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("Music", v))
	sfx_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("SFX", v))

	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

	SettingsManager.keybind_changed.connect(_on_keybind_changed)


func open() -> void:
	visible = true
	_refresh_from_settings()


func close() -> void:
	visible = false
	_rebinding_action = ""


func is_rebinding() -> bool:
	return _rebinding_action != ""


func _refresh_from_settings() -> void:
	hud_visible_check.button_pressed = SettingsManager.hud_visible
	crt_filter_check.button_pressed = SettingsManager.crt_filter_enabled
	screen_shake_check.button_pressed = SettingsManager.screen_shake_enabled
	_select_option_by_id(colorblind_option, SettingsManager.colorblind_mode)

	_select_option_by_id(display_mode_option, SettingsManager.display_mode)
	vsync_check.button_pressed = SettingsManager.vsync_enabled
	_select_option_by_id(fps_limit_option, SettingsManager.fps_limit)

	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume

	sensitivity_slider.value = SettingsManager.mouse_sensitivity


func _select_option_by_id(option: OptionButton, id: int) -> void:
	for i in option.item_count:
		if option.get_item_id(i) == id:
			option.selected = i
			return


func _on_colorblind_selected(index: int) -> void:
	SettingsManager.set_colorblind_mode(colorblind_option.get_item_id(index))


func _on_display_mode_selected(index: int) -> void:
	SettingsManager.set_display_mode(display_mode_option.get_item_id(index))


func _on_fps_limit_selected(index: int) -> void:
	SettingsManager.set_fps_limit(fps_limit_option.get_item_id(index))


func _on_sensitivity_changed(value: float) -> void:
	SettingsManager.set_sensitivity(value)
	sensitivity_value_label.text = str(int(round(value * 10000.0)))


func _on_reset_pressed() -> void:
	SettingsManager.reset_to_defaults()
	_refresh_from_settings()


func _on_back_pressed() -> void:
	back_pressed.emit()


func _build_keybind_rows() -> void:
	for child in keybinds_container.get_children():
		child.queue_free()

	for action in SettingsManager.REBINDABLE_ACTIONS.keys():
		var display_name: String = SettingsManager.REBINDABLE_ACTIONS[action]

		var row := HBoxContainer.new()
		keybinds_container.add_child(row)

		var label := Label.new()
		label.text = display_name
		label.custom_minimum_size = Vector2(200, 0)
		row.add_child(label)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(160, 0)
		row.add_child(btn)
		_keybind_buttons[action] = btn

		_refresh_keybind_label(action)
		btn.pressed.connect(_on_keybind_button_pressed.bind(action))


func _refresh_keybind_label(action: String) -> void:
	var btn: Button = _keybind_buttons.get(action)
	if btn == null:
		return
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		btn.text = "---"
		return
	var ev := events[0]
	if ev is InputEventKey:
		btn.text = OS.get_keycode_string(ev.physical_keycode)
	elif ev is InputEventMouseButton:
		btn.text = "Mouse %d" % ev.button_index
	else:
		btn.text = ev.as_text()

	if _rebinding_action == action:
		btn.text = "[ ... ]"


func _on_keybind_button_pressed(action: String) -> void:
	if _rebinding_action != "":
		return
	_rebinding_action = action
	_refresh_keybind_label(action)


func _on_keybind_changed(action: String) -> void:
	_refresh_keybind_label(action)


func _input(event: InputEvent) -> void:
	if not visible or _rebinding_action == "":
		return

	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		_refresh_keybind_label(_rebinding_action)
		_rebinding_action = ""
		get_viewport().set_input_as_handled()
		return

	var capture_event: InputEvent = null
	if event is InputEventKey and event.pressed and not event.echo:
		capture_event = InputEventKey.new()
		capture_event.physical_keycode = event.physical_keycode
	elif event is InputEventMouseButton and event.pressed:
		capture_event = InputEventMouseButton.new()
		capture_event.button_index = event.button_index

	if capture_event == null:
		return

	var action: String = _rebinding_action
	var conflict: String = SettingsManager.find_conflicting_action(capture_event, action)

	SettingsManager.rebind_action(action, capture_event)
	_rebinding_action = ""
	_refresh_keybind_label(action)

	if conflict != "":
		var conflict_name: String = SettingsManager.REBINDABLE_ACTIONS.get(conflict, conflict)
		conflict_label.text = "Hinweis: Taste war bereits '%s' zugewiesen." % conflict_name
		conflict_label.visible = true
		var timer := get_tree().create_timer(conflict_warning_duration)
		timer.timeout.connect(func() -> void: conflict_label.visible = false)

	get_viewport().set_input_as_handled()
