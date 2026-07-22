extends Node

# ============================================================================
# SettingsManager — Autoload-Singleton für alle persistenten Spieleinstellungen.
# Speichert/lädt Sensitivity, Lautstärke, Fullscreen und Tastenbelegung in
# user://settings.cfg (ConfigFile) und wendet sie beim Spielstart automatisch
# an (siehe _ready()). Muss unter Project Settings -> Autoload als
# "SettingsManager" eingetragen werden.
# ============================================================================

signal sensitivity_changed(value: float)
signal volume_changed(bus_name: String, value_linear: float)
signal fullscreen_changed(is_fullscreen: bool)
signal keybind_changed(action: String)

const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_SENSITIVITY: float = 0.003

# --- Rebindbare Actions + Anzeigename fürs SettingsMenu-UI. Diese Liste ist
# die EINZIGE Quelle der Wahrheit dafür, welche Actions im Menü auftauchen —
# neue rebindbare Actions einfach hier ergänzen. ---
# ACHTUNG: "interact " (mit Leerzeichen am Ende) ist ein bestehender Tippfehler
# im InputMap-Namen selbst (project.godot), hier absichtlich 1:1 übernommen,
# damit InputMap.action_erase_events()/action_add_event() die richtige Action
# treffen. Empfehlung: die Action einmal sauber in "interact" umbenennen und
# diese Zeile danach anpassen.
const REBINDABLE_ACTIONS: Dictionary = {
	"attack_primary": "Primärangriff",
	"attack_secondary": "Sekundärangriff",
	"utility": "Dash",
	"interact ": "Interagieren",
	"ui_accept": "Springen",
	"ui_left": "Links",
	"ui_right": "Rechts",
	"ui_up": "Vorwärts",
	"ui_down": "Rückwärts",
}

var mouse_sensitivity: float = DEFAULT_SENSITIVITY
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var is_fullscreen: bool = false

# Merkt sich die InputMap-Belegung, wie sie beim allerersten Start (also
# noch OHNE geladene user://settings.cfg-Overrides) tatsächlich aus
# project.godot kam — Grundlage für reset_action_to_default().
var _default_keybinds: Dictionary = {}  # action -> Array[InputEvent]

func _ready() -> void:
	load_settings()
	_apply_all()

func _apply_all() -> void:
	_apply_volume("Master", master_volume)
	_apply_volume("Music", music_volume)
	_apply_volume("SFX", sfx_volume)
	_apply_fullscreen(is_fullscreen)
	_apply_sensitivity_to_player()

# --- Sensitivity ---
func set_sensitivity(value: float) -> void:
	mouse_sensitivity = value
	_apply_sensitivity_to_player()
	sensitivity_changed.emit(mouse_sensitivity)
	save_settings()

func _apply_sensitivity_to_player() -> void:
	# Sucht den Player robust über die Gruppe/den Namen — funktioniert auch,
	# wenn das Settings-Menü VOR dem eigentlichen Level geöffnet wird (z.B.
	# Hauptmenü), dann greift die Zuweisung einfach beim nächsten Level-Start
	# über den geladenen mouse_sensitivity-Wert nicht — deshalb liest
	# player.gd den Wert idealerweise selbst aus SettingsManager in _ready().
	var player := get_tree().get_root().find_child("Player", true, false)
	if player and "mouse_sensitivity" in player:
		player.set("mouse_sensitivity", mouse_sensitivity)

# --- Lautstärke ---
func set_volume(bus_name: String, value_linear: float) -> void:
	match bus_name:
		"Master":
			master_volume = value_linear
		"Music":
			music_volume = value_linear
		"SFX":
			sfx_volume = value_linear
		_:
			push_warning("SettingsManager: Unbekannter Audio-Bus '%s'." % bus_name)
			return
	_apply_volume(bus_name, value_linear)
	volume_changed.emit(bus_name, value_linear)
	save_settings()

func _apply_volume(bus_name: String, value_linear: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		# Bus existiert nicht im Audio-Bus-Layout des Projekts (z.B. wenn
		# "Music"/"SFX" noch nicht als eigene Busse angelegt wurden) —
		# kein Fehler, einfach überspringen.
		return
	var muted: bool = value_linear <= 0.0001
	AudioServer.set_bus_mute(bus_index, muted)
	if not muted:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamp(value_linear, 0.0001, 1.0)))

func has_audio_bus(bus_name: String) -> bool:
	return AudioServer.get_bus_index(bus_name) != -1

# --- Fullscreen ---
func set_fullscreen(enabled: bool) -> void:
	is_fullscreen = enabled
	_apply_fullscreen(enabled)
	fullscreen_changed.emit(enabled)
	save_settings()

func _apply_fullscreen(enabled: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	)

# --- Tastenbelegung ---
# Ersetzt nur bestehende Tastatur-/Maus-Bindings einer Action, Controller-
# Bindings (Joypad Button/Motion) bleiben unangetastet — sonst würde jedes
# Rebinding per Tastatur/Maus gleichzeitig die Gamepad-Belegung zerstören.
func rebind_action(action: String, event: InputEvent) -> void:
	if not REBINDABLE_ACTIONS.has(action):
		push_warning("SettingsManager: '%s' ist nicht als rebindbar registriert." % action)
		return

	for existing in InputMap.action_get_events(action):
		if existing is InputEventKey or existing is InputEventMouseButton:
			InputMap.action_erase_event(action, existing)

	InputMap.action_add_event(action, event)
	keybind_changed.emit(action)
	save_settings()

func reset_action_to_default(action: String) -> void:
	if not _default_keybinds.has(action):
		return
	InputMap.action_erase_events(action)
	for event: InputEvent in _default_keybinds[action]:
		InputMap.action_add_event(action, event)
	keybind_changed.emit(action)
	save_settings()

# Liefert das erste Tastatur- oder Maus-Event einer Action fürs UI (Joypad-
# Events werden hier bewusst übersprungen, da das Menü nur Keyboard/Maus
# anzeigt/rebindet).
func get_action_event(action: String) -> InputEvent:
	var events: Array = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey or event is InputEventMouseButton:
			return event
	return events[0] if not events.is_empty() else null

# Prüft, ob das gegebene Event bereits einer ANDEREN rebindbaren Action
# zugewiesen ist — fürs Warn-Feedback im SettingsMenu, kein automatisches
# Vertauschen (das wäre überraschendes Verhalten für den Spieler).
func find_conflicting_action(event: InputEvent, exclude_action: String) -> String:
	for action in REBINDABLE_ACTIONS.keys():
		if action == exclude_action:
			continue
		for existing in InputMap.action_get_events(action):
			if _events_match(existing, event):
				return action
	return ""

func _events_match(a: InputEvent, b: InputEvent) -> bool:
	if a is InputEventKey and b is InputEventKey:
		return a.physical_keycode == b.physical_keycode
	if a is InputEventMouseButton and b is InputEventMouseButton:
		return a.button_index == b.button_index
	return false

# --- Persistenz ---
func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("display", "fullscreen", is_fullscreen)

	for action in REBINDABLE_ACTIONS.keys():
		var event: InputEvent = get_action_event(action)
		if event:
			config.set_value("keybinds", action, var_to_str(event))

	var err: Error = config.save(SETTINGS_PATH)
	if err != OK:
		push_warning("SettingsManager: Speichern nach '%s' fehlgeschlagen (Fehlercode %d)." % [SETTINGS_PATH, err])

func load_settings() -> void:
	# Defaults aus dem InputMap sichern, BEVOR irgendwas überschrieben wird —
	# Grundlage für reset_action_to_default().
	_default_keybinds.clear()
	for action in REBINDABLE_ACTIONS.keys():
		var dup: Array[InputEvent] = []
		for event in InputMap.action_get_events(action):
			dup.append(event.duplicate())
		_default_keybinds[action] = dup

	var config := ConfigFile.new()
	var err: Error = config.load(SETTINGS_PATH)
	if err != OK:
		# Keine gespeicherten Settings vorhanden (erster Start) — kein
		# Fehler, einfach bei den Defaults aus project.godot bleiben.
		return

	mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", DEFAULT_SENSITIVITY)
	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 1.0)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
	is_fullscreen = config.get_value("display", "fullscreen", false)

	for action in REBINDABLE_ACTIONS.keys():
		var raw: String = config.get_value("keybinds", action, "")
		if raw == "":
			continue
		var event = str_to_var(raw)
		if event is InputEvent:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
