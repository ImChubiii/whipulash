extends Control
class_name SettingsMenu

# ============================================================================
# SettingsMenu — Tab-basiertes UI für alle Settings.
# Public API bleibt kompatibel zu pause_menu.gd: open(), close(),
# is_rebinding(), back_pressed-Signal.
#
# Erwartete Node-Struktur (siehe settings_menu.tscn):
# SettingsMenu (Control, dieses Script)
# └── Panel
#     └── VBoxContainer
#         ├── TitleLabel
#         ├── TabContainer
#         │   ├── General (VBoxContainer)
#         │   │   ├── HUDVisibleRow / HUDVisibleCheck (CheckButton)
#         │   │   ├── DamageNumbersRow / DamageNumbersCheck (CheckButton)
#         │   │   └── MinimapOpacityRow / MinimapOpacitySlider / MinimapOpacityValueLabel
#         │   ├── Video (VBoxContainer)
#         │   │   ├── DisplayModeRow / DisplayModeOption (OptionButton)
#         │   │   ├── VSyncRow / VSyncCheck (CheckButton)
#         │   │   ├── FPSLimitRow / FPSLimitOption (OptionButton)
#         │   │   └── FOVRow / FOVSlider / FOVValueLabel
#         │   ├── Audio (VBoxContainer)
#         │   │   ├── MasterVolumeRow / MasterVolumeSlider
#         │   │   ├── MusicVolumeRow / MusicVolumeSlider
#         │   │   └── SFXVolumeRow / SFXVolumeSlider
#         │   ├── Controls (VBoxContainer)
#         │   │   ├── SensitivityRow / SensitivitySlider / SensitivityValueLabel
#         │   │   └── KeybindsContainer (VBoxContainer, wird zur Laufzeit gefüllt)
#         │   └── Accessibility (VBoxContainer)
#         │       ├── CRTFilterRow / CRTFilterCheck (CheckButton)
#         │       ├── ScreenShakeRow / ScreenShakeCheck (CheckButton)
#         │       ├── AimToggleRow / AimToggleCheck (CheckButton)
#         │       └── ColorblindRow / ColorblindOption (OptionButton)
#         ├── ConflictLabel (Label, initial unsichtbar)
#         └── BottomRow (HBoxContainer)
#             ├── ResetButton
#             └── BackButton
# ============================================================================

signal back_pressed

# --- Tabs ---
@onready var tab_container: TabContainer = $Panel/VBoxContainer/TabContainer

# --- General ---
@onready var hud_visible_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/HUDVisibleRow/HUDVisibleCheck
@onready var damage_numbers_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/DamageNumbersRow/DamageNumbersCheck
@onready var minimap_opacity_slider: HSlider = $Panel/VBoxContainer/TabContainer/General/MinimapOpacityRow/MinimapOpacitySlider
@onready var minimap_opacity_value_label: Label = $Panel/VBoxContainer/TabContainer/General/MinimapOpacityRow/MinimapOpacityValueLabel

# --- Video ---
@onready var display_mode_option: OptionButton = $Panel/VBoxContainer/TabContainer/Video/DisplayModeRow/DisplayModeOption
@onready var vsync_check: CheckButton = $Panel/VBoxContainer/TabContainer/Video/VSyncRow/VSyncCheck
@onready var fps_limit_option: OptionButton = $Panel/VBoxContainer/TabContainer/Video/FPSLimitRow/FPSLimitOption
@onready var fov_slider: HSlider = $Panel/VBoxContainer/TabContainer/Video/FOVRow/FOVSlider
@onready var fov_value_label: Label = $Panel/VBoxContainer/TabContainer/Video/FOVRow/FOVValueLabel

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

# --- Accessibility ---
@onready var crt_filter_check: CheckButton = $Panel/VBoxContainer/TabContainer/Accessibility/CRTFilterRow/CRTFilterCheck
@onready var screen_shake_check: CheckButton = $Panel/VBoxContainer/TabContainer/Accessibility/ScreenShakeRow/ScreenShakeCheck
@onready var aim_toggle_check: CheckButton = $Panel/VBoxContainer/TabContainer/Accessibility/AimToggleRow/AimToggleCheck
@onready var colorblind_option: OptionButton = $Panel/VBoxContainer/TabContainer/Accessibility/ColorblindRow/ColorblindOption

# --- Footer ---
@onready var conflict_label: Label = $Panel/VBoxContainer/ConflictLabel
@onready var reset_button: Button = $Panel/VBoxContainer/BottomRow/ResetButton
@onready var back_button: Button = $Panel/VBoxContainer/BottomRow/BackButton

# Sekunden, die eine Konflikt-Warnung sichtbar bleibt.
@export var conflict_warning_duration: float = 2.5

# FPS-Limit-Presets für die OptionButton-Reihenfolge
const FPS_OPTIONS: Array[int] = [30, 60, 120, 144, 240, 0]  # 0 = Unlimited

var _rebinding_action: String = ""
var _keybind_buttons: Dictionary = {}  # action -> Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_setup_slider_ranges()
	_populate_option_buttons()
	_hide_missing_audio_buses()

	conflict_label.visible = false

	_connect_signals()
	_build_keybind_rows()
	_refresh_from_settings()

func _setup_slider_ranges() -> void:
	sensitivity_slider.min_value = 0.0005
	sensitivity_slider.max_value = 0.01
	sensitivity_slider.step = 0.0001

	for slider in [master_slider, music_slider, sfx_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01

	minimap_opacity_slider.min_value = 0.0
	minimap_opacity_slider.max_value = 1.0
	minimap_opacity_slider.step = 0.05

	fov_slider.min_value = 60.0
	fov_slider.max_value = 110.0
	fov_slider.step = 1.0

func _populate_option_buttons() -> void:
	# Display Mode
	display_mode_option.clear()
	display_mode_option.add_item("Windowed", SettingsManager.DISPLAY_MODE_WINDOWED)
	display_mode_option.add_item("Fullscreen", SettingsManager.DISPLAY_MODE_FULLSCREEN)
	display_mode_option.add_item("Borderless Windowed", SettingsManager.DISPLAY_MODE_BORDERLESS)

	# FPS Limit
	fps_limit_option.clear()
	for fps in FPS_OPTIONS:
		var label: String = "Unlimited" if fps == 0 else "%d FPS" % fps
		fps_limit_option.add_item(label, fps)

	# Colorblind Mode
	colorblind_option.clear()
	colorblind_option.add_item("Off", SettingsManager.COLORBLIND_OFF)
	colorblind_option.add_item("Protanopia", SettingsManager.COLORBLIND_PROTANOPIA)
	colorblind_option.add_item("Deuteranopia", SettingsManager.COLORBLIND_DEUTERANOPIA)
	colorblind_option.add_item("Tritanopia", SettingsManager.COLORBLIND_TRITANOPIA)

func _hide_missing_audio_buses() -> void:
	music_row.visible = SettingsManager.has_audio_bus("Music")
	sfx_row.visible = SettingsManager.has_audio_bus("SFX")

func _connect_signals() -> void:
	# General
	hud_visible_check.toggled.connect(SettingsManager.set_hud_visible)
	damage_numbers_check.toggled.connect(SettingsManager.set_damage_numbers_enabled)
	minimap_opacity_slider.value_changed.connect(_on_minimap_opacity_changed)

	# Video
	display_mode_option.item_selected.connect(_on_display_mode_selected)
	vsync_check.toggled.connect(SettingsManager.set_vsync)
	fps_limit_option.item_selected.connect(_on_fps_limit_selected)
	fov_slider.value_changed.connect(_on_fov_changed)

	# Audio
	master_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("Master", v))
	music_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("Music", v))
	sfx_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("SFX", v))

	# Controls
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

	# Accessibility
	crt_filter_check.toggled.connect(SettingsManager.set_crt_filter_enabled)
	screen_shake_check.toggled.connect(SettingsManager.set_screen_shake_enabled)
	aim_toggle_check.toggled.connect(SettingsManager.set_aim_toggle)
	colorblind_option.item_selected.connect(_on_colorblind_selected)

	# Footer
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

	# Manager-Signale (falls Werte extern geändert werden, UI syncen)
	SettingsManager.keybind_changed.connect(_on_keybind_changed)

# ============================================================================
# Public API — bleibt kompatibel zu pause_menu.gd
# ============================================================================
func open() -> void:
	visible = true
	_refresh_from_settings()

func close() -> void:
	visible = false
	_rebinding_action = ""

func is_rebinding() -> bool:
	return _rebinding_action != ""

# ============================================================================
# UI-Sync
# ============================================================================
func _refresh_from_settings() -> void:
	# General
	hud_visible_check.button_pressed = SettingsManager.hud_visible
	damage_numbers_check.button_pressed = SettingsManager.damage_numbers_enabled
	minimap_opacity_slider.value = SettingsManager.minimap_opacity
	minimap_opacity_value_label.text = "%d%%" % int(round(SettingsManager.minimap_opacity * 100.0))

	# Video
	_select_option_by_id(display_mode_option, SettingsManager.display_mode)
	vsync_check.button_pressed = SettingsManager.vsync_enabled
	_select_option_by_id(fps_limit_option, SettingsManager.fps_limit)
	fov_slider.value = SettingsManager.fov
	fov_value_label.text = "%d°" % int(round(SettingsManager.fov))

	# Audio
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume

	# Controls
	sensitivity_slider.value = SettingsManager.mouse_sensitivity
	sensitivity_value_label.text = "%.4f" % SettingsManager.mouse_sensitivity
	_refresh_all_keybind_labels()

	# Accessibility
	crt_filter_check.button_pressed = SettingsManager.crt_filter_enabled
	screen_shake_check.button_pressed = SettingsManager.screen_shake_enabled
	aim_toggle_check.button_pressed = SettingsManager.aim_is_toggle
	_select_option_by_id(colorblind_option, SettingsManager.colorblind_mode)

func _select_option_by_id(option: OptionButton, id: int) -> void:
	for i in range(option.item_count):
		if option.get_item_id(i) == id:
			option.select(i)
			return

# ============================================================================
# Handler
# ============================================================================
func _on_sensitivity_changed(value: float) -> void:
	sensitivity_value_label.text = "%.4f" % value
	SettingsManager.set_sensitivity(value)

func _on_minimap_opacity_changed(value: float) -> void:
	minimap_opacity_value_label.text = "%d%%" % int(round(value * 100.0))
	SettingsManager.set_minimap_opacity(value)

func _on_fov_changed(value: float) -> void:
	fov_value_label.text = "%d°" % int(round(value))
	SettingsManager.set_fov(value)

func _on_display_mode_selected(idx: int) -> void:
	SettingsManager.set_display_mode(display_mode_option.get_item_id(idx))

func _on_fps_limit_selected(idx: int) -> void:
	SettingsManager.set_fps_limit(fps_limit_option.get_item_id(idx))

func _on_colorblind_selected(idx: int) -> void:
	SettingsManager.set_colorblind_mode(colorblind_option.get_item_id(idx))

func _on_back_pressed() -> void:
	close()
	back_pressed.emit()

func _on_reset_pressed() -> void:
	SettingsManager.reset_all_to_defaults()
	_refresh_from_settings()

# ============================================================================
# Keybinds
# ============================================================================
func _build_keybind_rows() -> void:
	for child in keybinds_container.get_children():
		child.queue_free()
	_keybind_buttons.clear()

	for action in SettingsManager.REBINDABLE_ACTIONS.keys():
		var row := HBoxContainer.new()

		var label := Label.new()
		label.text = SettingsManager.REBINDABLE_ACTIONS[action]
		label.custom_minimum_size = Vector2(160, 0)
		row.add_child(label)

		var bind_button := Button.new()
		bind_button.custom_minimum_size = Vector2(140, 0)
		bind_button.pressed.connect(_on_bind_button_pressed.bind(action, bind_button))
		row.add_child(bind_button)

		var reset_key_button := Button.new()
		reset_key_button.text = "Reset"
		reset_key_button.pressed.connect(_on_reset_key_button_pressed.bind(action))
		row.add_child(reset_key_button)

		keybinds_container.add_child(row)
		_keybind_buttons[action] = bind_button

func _refresh_all_keybind_labels() -> void:
	for action in _keybind_buttons.keys():
		_refresh_keybind_label(action)

func _refresh_keybind_label(action: String) -> void:
	var button: Button = _keybind_buttons.get(action)
	if button == null:
		return
	button.text = _event_to_display_string(SettingsManager.get_action_event(action))

func _event_to_display_string(event: InputEvent) -> String:
	if event == null:
		return "—"
	if event is InputEventKey:
		return OS.get_keycode_string(event.physical_keycode)
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				return "Maus Links"
			MOUSE_BUTTON_RIGHT:
				return "Maus Rechts"
			MOUSE_BUTTON_MIDDLE:
				return "Maus Mitte"
			_:
				return "Maustaste %d" % event.button_index
	return "?"

func _on_bind_button_pressed(action: String, button: Button) -> void:
	if _rebinding_action != "":
		_refresh_keybind_label(_rebinding_action)
	_rebinding_action = action
	button.text = "Drücke eine Taste..."

func _on_reset_key_button_pressed(action: String) -> void:
	SettingsManager.reset_action_to_default(action)

func _on_keybind_changed(action: String) -> void:
	_refresh_keybind_label(action)

# WICHTIG: _input() statt _unhandled_input(), damit Rebinding IMMER
# zuerst greift — auch vor PauseMenu.gd's Escape-Handler.
func _input(event: InputEvent) -> void:
	if not visible or _rebinding_action == "":
		return

	# ESC bricht Rebinding ab
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
