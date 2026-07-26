extends Control
class_name SettingsMenu

signal back_pressed

@onready var tab_container: TabContainer = $Panel/VBoxContainer/TabContainer

# --- General ---
@onready var hud_visible_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/HUDVisibleRow/HUDVisibleCheck
@onready var minimap_rotate_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/MinimapRotateRow/MinimapRotateCheck
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

## --- Modulares HUD-Dropdown -------------------------------------------
## Wird KOMPLETT zur Laufzeit gebaut (kein .tscn-Eingriff noetig). Der
## Toggle-Button klappt die Einzelschalter auf/zu — neue Elemente aus
## SettingsManager.HUD_ELEMENTS erscheinen automatisch, ohne dass hier
## etwas nachgepflegt werden muss.
var _hud_dropdown_button: Button = null
var _hud_elements_box: VBoxContainer = null
var _hud_element_checks: Dictionary = {}  # element (String) -> CheckButton
var _hud_dropdown_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	# Muss ueber PauseMenu/DeathScreen/WinScreen (Z_INDEX_MENU) UND ueber dem
	# HUD liegen — SettingsMenu kann sowohl vom PauseMenu als auch (potenziell)
	# direkt geoeffnet werden, muss also in jedem Fall zuoberst liegen.
	z_index = PauseMenu.Z_INDEX_MENU + 10

	_fix_panel_background()
	_setup_slider_ranges()
	_populate_option_buttons()
	_hide_missing_audio_buses()

	conflict_label.visible = false

	_connect_signals()
	_build_hud_element_dropdown()
	_build_keybind_rows()
	_refresh_from_settings()
	_refresh_hud_element_checks()


# Panel hat opaken Standardhintergrund — fix auf halbtransparent damit der
# BackgroundBlur (flaches, dunkles ColorRect) dahinter sichtbar wird.
# HINWEIS: BackgroundBlur nutzt bewusst KEINEN Screen-Blur-Shader mehr —
# der 9-Tap-Blur (menu_blur.gdshader) erzeugte auf scharfen UI-/HUD-Texten
# (Minimap-Koordinaten, Ability-Icons etc.) sichtbare "Geisterbilder" statt
# einer sauberen Unschärfe, weil er nur 9 Samples nutzt. Bei Pause/Death/Win
# fällt das nicht auf, weil dort das Panel Full-Rect UND komplett opak ist
# und den Effekt komplett verdeckt. Settings hat aber bewusst ein KLEINES,
# zentriertes Panel (damit man sieht, dass man "über" dem Pause-Menü ist) —
# der Rest des Bildschirms braucht daher einen eigenen, aber schlichten
# dunklen Overlay statt des Blur-Shaders.
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
	minimap_rotate_check.toggled.connect(SettingsManager.set_minimap_rotate_with_player)
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
	_refresh_hud_element_checks()


func close() -> void:
	visible = false
	_rebinding_action = ""


func is_rebinding() -> bool:
	return _rebinding_action != ""


func _refresh_from_settings() -> void:
	hud_visible_check.button_pressed = SettingsManager.hud_visible
	minimap_rotate_check.button_pressed = SettingsManager.minimap_rotate_with_player
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


# BUGFIX: hier stand vorher SettingsManager.reset_to_defaults() — diese
# Methode existiert im SettingsManager gar nicht (sie heisst
# reset_all_to_defaults). Der Reset-Button hat also bei jedem Klick einen
# Laufzeitfehler geworfen statt zurueckzusetzen.
func _on_reset_pressed() -> void:
	SettingsManager.reset_all_to_defaults()
	_refresh_from_settings()
	_refresh_hud_element_checks()


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


# ============================================================================
# Modulares HUD-Dropdown (General-Tab)
# ============================================================================

## Baut unter der Zeile "HUD anzeigen" einen aufklappbaren Block mit einem
## CheckButton pro HUD-Element.
##
## Warum zur Laufzeit statt im .tscn: die Elementliste lebt im
## SettingsManager (HUD_ELEMENTS). Waeren die Checkboxen fest in der Szene
## verdrahtet, muesste man bei jedem neuen HUD-Element ZWEI Stellen
## nachpflegen und die beiden koennten auseinanderlaufen.
func _build_hud_element_dropdown() -> void:
	var general: Node = tab_container.get_node_or_null("General")
	if general == null:
		push_warning("SettingsMenu: Tab 'General' nicht gefunden — HUD-Dropdown wird uebersprungen.")
		return

	_hud_dropdown_button = Button.new()
	_hud_dropdown_button.name = "HUDElementsDropdown"
	_hud_dropdown_button.toggle_mode = true
	_hud_dropdown_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	general.add_child(_hud_dropdown_button)

	_hud_elements_box = VBoxContainer.new()
	_hud_elements_box.name = "HUDElementsBox"
	_hud_elements_box.visible = false
	_hud_elements_box.add_theme_constant_override("separation", 2)
	general.add_child(_hud_elements_box)

	# Direkt unter die HUD-Sichtbarkeits-Zeile einsortieren, damit der
	# Zusammenhang optisch klar ist.
	var hud_row: Node = general.get_node_or_null("HUDVisibleRow")
	if hud_row:
		var target_index: int = hud_row.get_index() + 1
		general.move_child(_hud_dropdown_button, target_index)
		general.move_child(_hud_elements_box, target_index + 1)

	for element in SettingsManager.HUD_ELEMENTS.keys():
		var row := HBoxContainer.new()
		_hud_elements_box.add_child(row)

		# Einrueckung, damit die Unterpunkte als "Kinder" der HUD-Zeile
		# lesbar sind.
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(24, 0)
		row.add_child(spacer)

		var label := Label.new()
		label.text = SettingsManager.HUD_ELEMENTS[element]
		label.custom_minimum_size = Vector2(220, 0)
		row.add_child(label)

		var check := CheckButton.new()
		row.add_child(check)
		_hud_element_checks[element] = check

		# bind() haengt die Element-ID an — sonst wuesste der Callback
		# nicht, WELCHE Checkbox geschaltet wurde.
		check.toggled.connect(_on_hud_element_toggled.bind(element))

	_hud_dropdown_button.toggled.connect(_on_hud_dropdown_toggled)
	_update_hud_dropdown_label()


func _on_hud_dropdown_toggled(pressed: bool) -> void:
	_hud_dropdown_open = pressed
	if _hud_elements_box:
		_hud_elements_box.visible = pressed
	_update_hud_dropdown_label()


func _update_hud_dropdown_label() -> void:
	if _hud_dropdown_button == null:
		return
	var arrow: String = "v" if _hud_dropdown_open else ">"
	var active: int = 0
	for element in SettingsManager.HUD_ELEMENTS.keys():
		if SettingsManager.is_hud_element_visible(element):
			active += 1
	_hud_dropdown_button.text = "%s  HUD-Elemente  (%d/%d aktiv)" % [
		arrow, active, SettingsManager.HUD_ELEMENTS.size()
	]


func _on_hud_element_toggled(is_on: bool, element: String) -> void:
	SettingsManager.set_hud_element_visible(element, is_on)
	_update_hud_dropdown_label()


## Liest die Checkbox-Zustaende aus dem SettingsManager zurueck. Wichtig:
## set_pressed_no_signal() statt button_pressed, sonst wuerde das Setzen
## selbst wieder toggled() feuern und eine Endlosschleife ausloesen.
func _refresh_hud_element_checks() -> void:
	for element in _hud_element_checks.keys():
		var check: CheckButton = _hud_element_checks[element]
		if is_instance_valid(check):
			check.set_pressed_no_signal(SettingsManager.is_hud_element_visible(element))
	_update_hud_dropdown_label()
