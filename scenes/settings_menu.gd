extends Control
class_name SettingsMenu

# ============================================================================
# SettingsMenu — UI-Panel für Sensitivity, Lautstärke, Fullscreen und
# Tastenbelegung. Wird vom PauseMenu geöffnet/geschlossen (siehe pause_menu.gd).
#
# Erwartete Node-Struktur (im Editor anzulegen):
# SettingsMenu (Control, dieses Script)
# └── Panel
#     └── VBoxContainer
#         ├── SensitivityRow (HBoxContainer)
#         │   ├── Label ("Maus-Sensitivity")
#         │   ├── SensitivitySlider (HSlider)
#         │   └── SensitivityValueLabel (Label)
#         ├── MasterVolumeRow (HBoxContainer): Label, MasterVolumeSlider (HSlider)
#         ├── MusicVolumeRow (HBoxContainer): Label, MusicVolumeSlider (HSlider)
#         ├── SFXVolumeRow (HBoxContainer): Label, SFXVolumeSlider (HSlider)
#         ├── FullscreenRow (HBoxContainer): Label, FullscreenCheckButton (CheckButton)
#         ├── ConflictLabel (Label, initial unsichtbar)
#         ├── KeybindsContainer (VBoxContainer, wird zur Laufzeit gefüllt)
#         └── BackButton (Button)
# ============================================================================

signal back_pressed

@onready var sensitivity_slider: HSlider = $Panel/VBoxContainer/SensitivityRow/SensitivitySlider
@onready var sensitivity_value_label: Label = $Panel/VBoxContainer/SensitivityRow/SensitivityValueLabel

@onready var master_row: HBoxContainer = $Panel/VBoxContainer/MasterVolumeRow
@onready var master_slider: HSlider = $Panel/VBoxContainer/MasterVolumeRow/MasterVolumeSlider

@onready var music_row: HBoxContainer = $Panel/VBoxContainer/MusicVolumeRow
@onready var music_slider: HSlider = $Panel/VBoxContainer/MusicVolumeRow/MusicVolumeSlider

@onready var sfx_row: HBoxContainer = $Panel/VBoxContainer/SFXVolumeRow
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/SFXVolumeRow/SFXVolumeSlider

@onready var fullscreen_check: CheckButton = $Panel/VBoxContainer/FullscreenRow/FullscreenCheckButton
@onready var conflict_label: Label = $Panel/VBoxContainer/ConflictLabel
@onready var keybinds_container: VBoxContainer = $Panel/VBoxContainer/KeybindsContainer
@onready var back_button: Button = $Panel/VBoxContainer/BackButton

# Sekunden, die eine Konflikt-Warnung ("Taste war bereits belegt") sichtbar
# bleibt, bevor sie automatisch wieder ausgeblendet wird.
@export var conflict_warning_duration: float = 2.5

# Leer = kein Rebind aktiv. Solange gesetzt, fängt _input() JEDEN
# Tastatur-/Maus-Input ab, bevor er als Spiel-Input durchgeht.
var _rebinding_action: String = ""
var _keybind_buttons: Dictionary = {}  # action -> Button

func _ready() -> void:
	# Process Mode Always: das Menü muss auch bei get_tree().paused = true
	# reagieren (wird ja aus dem pausierten PauseMenu heraus geöffnet).
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	sensitivity_slider.min_value = 0.0005
	sensitivity_slider.max_value = 0.01
	sensitivity_slider.step = 0.0001

	for slider in [master_slider, music_slider, sfx_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01

	# Volume-Zeilen ausblenden, wenn der zugehörige Audio-Bus im Projekt
	# gar nicht existiert — verhindert nutzlose Regler ohne Wirkung.
	music_row.visible = SettingsManager.has_audio_bus("Music")
	sfx_row.visible = SettingsManager.has_audio_bus("SFX")

	conflict_label.visible = false

	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	master_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("Master", v))
	music_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("Music", v))
	sfx_slider.value_changed.connect(func(v: float) -> void: SettingsManager.set_volume("SFX", v))
	fullscreen_check.toggled.connect(SettingsManager.set_fullscreen)
	back_button.pressed.connect(_on_back_pressed)
	SettingsManager.keybind_changed.connect(_on_keybind_changed)

	_build_keybind_rows()
	_refresh_from_settings()

func open() -> void:
	visible = true
	_refresh_from_settings()

func close() -> void:
	visible = false
	_rebinding_action = ""

func is_rebinding() -> bool:
	return _rebinding_action != ""

func _refresh_from_settings() -> void:
	sensitivity_slider.value = SettingsManager.mouse_sensitivity
	sensitivity_value_label.text = "%.4f" % SettingsManager.mouse_sensitivity
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	fullscreen_check.button_pressed = SettingsManager.is_fullscreen
	_refresh_all_keybind_labels()

func _on_sensitivity_changed(value: float) -> void:
	sensitivity_value_label.text = "%.4f" % value
	SettingsManager.set_sensitivity(value)

func _on_back_pressed() -> void:
	close()
	back_pressed.emit()

# --- Tastenbelegung: Zeilen dynamisch aus SettingsManager.REBINDABLE_ACTIONS
# aufbauen, damit hier nichts manuell im Editor gepflegt werden muss. ---
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

		var reset_button := Button.new()
		reset_button.text = "Reset"
		reset_button.pressed.connect(_on_reset_button_pressed.bind(action))
		row.add_child(reset_button)

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
		# Bereits im Rebind-Modus für eine andere Action — deren Button-Text
		# sauber zurücksetzen, bevor der neue Rebind-Modus startet.
		_refresh_keybind_label(_rebinding_action)

	_rebinding_action = action
	button.text = "Drücke eine Taste..."

func _on_reset_button_pressed(action: String) -> void:
	SettingsManager.reset_action_to_default(action)

func _on_keybind_changed(action: String) -> void:
	_refresh_keybind_label(action)

# WICHTIG: _input() statt _unhandled_input(), damit das Rebinding IMMER
# zuerst greift — auch vor PauseMenu.gd's eigenem Escape-Handler, unabhängig
# von der Reihenfolge im Szenenbaum. _input() läuft für alle Nodes, bevor
# die _unhandled_input()-Phase überhaupt beginnt.
func _input(event: InputEvent) -> void:
	if not visible or _rebinding_action == "":
		return

	# ESC bricht NUR das Rebinding ab, ohne das Menü zu schließen.
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
