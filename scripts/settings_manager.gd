extends Node

# ============================================================================
# SettingsManager — Autoload-Singleton für alle persistenten Spieleinstellungen.
# Speichert/lädt in user://settings.cfg (ConfigFile). Muss unter Project Settings
# -> Autoload als "SettingsManager" eingetragen sein.
# ============================================================================

signal sensitivity_changed(value: float)
signal volume_changed(bus_name: String, value_linear: float)
signal fullscreen_changed(is_fullscreen: bool)
signal display_mode_changed(mode: int)
signal vsync_changed(enabled: bool)
signal fps_limit_changed(fps: int)
signal keybind_changed(action: String)

# Accessibility
signal crt_filter_changed(enabled: bool)
signal screen_shake_changed(enabled: bool)
signal colorblind_mode_changed(mode: int)

# General
signal hud_visible_changed(visible: bool)

const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_SENSITIVITY: float = 0.003
const DEFAULT_WINDOWED_SIZE: Vector2i = Vector2i(1280, 720)

# Display Mode Enum
const DISPLAY_MODE_WINDOWED: int = 0
const DISPLAY_MODE_FULLSCREEN: int = 1
const DISPLAY_MODE_BORDERLESS: int = 2

# Colorblind Mode Enum
const COLORBLIND_OFF: int = 0
const COLORBLIND_PROTANOPIA: int = 1
const COLORBLIND_DEUTERANOPIA: int = 2
const COLORBLIND_TRITANOPIA: int = 3

# --- Rebindbare Actions + Anzeigename fürs SettingsMenu-UI. ---
# ACHTUNG: "interact " (mit Leerzeichen am Ende) ist ein bestehender Tippfehler
# im InputMap-Namen selbst (project.godot), hier absichtlich 1:1 übernommen.
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

# --- Controls ---
var mouse_sensitivity: float = DEFAULT_SENSITIVITY

# --- Audio ---
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

# --- Video ---
var display_mode: int = DISPLAY_MODE_WINDOWED
var vsync_enabled: bool = true
var fps_limit: int = 144  # 0 = unlimited

# --- General ---
var hud_visible: bool = true

# --- Accessibility ---
var crt_filter_enabled: bool = true
var screen_shake_enabled: bool = true
var colorblind_mode: int = COLORBLIND_OFF

# Merkt sich die letzte bekannte Fenstergröße/-position im Windowed-Modus,
# damit beim Zurückwechseln von Borderless/Fullscreen die Größe wiederhergestellt
# wird — ohne das würde "Windowed" nach einem Borderless-Trip bildschirmgroß bleiben.
var _windowed_size: Vector2i = DEFAULT_WINDOWED_SIZE
var _windowed_position: Vector2i = Vector2i.ZERO

# Merkt sich die InputMap-Belegung vom allerersten Start — Grundlage für
# reset_action_to_default().
var _default_keybinds: Dictionary = {}  # action -> Array[InputEvent]

func _ready() -> void:
	load_settings()
	_apply_all()

func _apply_all() -> void:
	_apply_volume("Master", master_volume)
	_apply_volume("Music", music_volume)
	_apply_volume("SFX", sfx_volume)
	_apply_display_mode(display_mode)
	_apply_vsync(vsync_enabled)
	_apply_fps_limit(fps_limit)
	_apply_sensitivity_to_player()
	_apply_crt_filter(crt_filter_enabled)
	_apply_colorblind_mode(colorblind_mode)

# ============================================================================
# Controls
# ============================================================================
func set_sensitivity(value: float) -> void:
	mouse_sensitivity = value
	_apply_sensitivity_to_player()
	sensitivity_changed.emit(mouse_sensitivity)
	save_settings()

func _apply_sensitivity_to_player() -> void:
	var player := get_tree().get_root().find_child("Player", true, false)
	if player and "mouse_sensitivity" in player:
		player.set("mouse_sensitivity", mouse_sensitivity)

# ============================================================================
# Audio
# ============================================================================
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
		return
	var muted: bool = value_linear <= 0.0001
	AudioServer.set_bus_mute(bus_index, muted)
	if not muted:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamp(value_linear, 0.0001, 1.0)))

func has_audio_bus(bus_name: String) -> bool:
	return AudioServer.get_bus_index(bus_name) != -1

# ============================================================================
# Video
# ============================================================================
func set_display_mode(mode: int) -> void:
	# Aktuelle Fenstergröße/-position sichern, SOLANGE wir noch im Windowed-
	# Modus sind — das ist die einzige zuverlässige Quelle für "wie groß war
	# das Fenster, bevor wir in Fullscreen/Borderless gewechselt sind".
	if display_mode == DISPLAY_MODE_WINDOWED:
		_windowed_size = DisplayServer.window_get_size()
		_windowed_position = DisplayServer.window_get_position()

	display_mode = mode
	_apply_display_mode(mode)
	display_mode_changed.emit(mode)
	fullscreen_changed.emit(mode != DISPLAY_MODE_WINDOWED)  # Legacy-Signal
	save_settings()

func _apply_display_mode(mode: int) -> void:
	match mode:
		DISPLAY_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			# WICHTIG: Ohne diese zwei Zeilen bleibt das Fenster nach einem
			# Borderless-Trip bildschirmgroß — DisplayServer merkt sich die
			# Größe nicht selbst zurück.
			DisplayServer.window_set_size(_windowed_size)
			DisplayServer.window_set_position(_windowed_position)
		DISPLAY_MODE_FULLSCREEN:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DISPLAY_MODE_BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
			DisplayServer.window_set_position(Vector2i.ZERO)

func set_vsync(enabled: bool) -> void:
	vsync_enabled = enabled
	_apply_vsync(enabled)
	vsync_changed.emit(enabled)
	save_settings()

func _apply_vsync(enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	)

func set_fps_limit(fps: int) -> void:
	fps_limit = fps
	_apply_fps_limit(fps)
	fps_limit_changed.emit(fps)
	save_settings()

func _apply_fps_limit(fps: int) -> void:
	Engine.max_fps = maxi(0, fps)

# ============================================================================
# General
# ============================================================================
func set_hud_visible(is_visible: bool) -> void:
	hud_visible = is_visible
	hud_visible_changed.emit(is_visible)
	save_settings()

# ============================================================================
# Accessibility
# ============================================================================
func set_crt_filter_enabled(enabled: bool) -> void:
	crt_filter_enabled = enabled
	_apply_crt_filter(enabled)
	crt_filter_changed.emit(enabled)
	save_settings()

func _apply_crt_filter(enabled: bool) -> void:
	for node in _find_nodes_by_name(get_tree().root, "CRTOverlay"):
		if node is CanvasItem:
			node.visible = enabled

func set_screen_shake_enabled(enabled: bool) -> void:
	screen_shake_enabled = enabled
	screen_shake_changed.emit(enabled)
	save_settings()

func set_colorblind_mode(mode: int) -> void:
	colorblind_mode = mode
	_apply_colorblind_mode(mode)
	colorblind_mode_changed.emit(mode)
	save_settings()

func _apply_colorblind_mode(mode: int) -> void:
	for node in _find_nodes_by_name(get_tree().root, "ColorblindOverlay"):
		if node is CanvasItem and node.material is ShaderMaterial:
			node.material.set_shader_parameter("colorblind_mode", mode)

# Rekursive Namenssuche im ganzen Szenenbaum — bewusst NICHT über Gruppen
# gelöst, damit du im Editor an den bestehenden CRTOverlay-Nodes NICHTS
# manuell nachpflegen musst (funktioniert einfach über den exakten Node-Namen).
func _find_nodes_by_name(root: Node, target_name: String) -> Array:
	var results: Array = []
	_find_nodes_by_name_recursive(root, target_name, results)
	return results

func _find_nodes_by_name_recursive(node: Node, target_name: String, results: Array) -> void:
	if node.name == target_name:
		results.append(node)
	for child in node.get_children():
		_find_nodes_by_name_recursive(child, target_name, results)

# ============================================================================
# Tastenbelegung
# ============================================================================
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

# Setzt eine Action auf ihren Ausgangszustand zurück.
#
# SONDERFALL ui_accept: Die project.godot-Defaults sind hier historisch
# uneinheitlich (mal nur Enter, mal Enter+Space in wechselnder Reihenfolge)
# — für "Springen" wollen wir aber IMMER verlässlich Space als Ergebnis,
# unabhängig davon was ursprünglich in project.godot stand. Deshalb wird
# hier nicht aus _default_keybinds wiederhergestellt, sondern die
# Tastatur-Belegung hart auf Space gesetzt (Joypad-Bindings bleiben wie
# gehabt unangetastet).
func reset_action_to_default(action: String) -> void:
	if action == "ui_accept":
		for existing in InputMap.action_get_events(action):
			if existing is InputEventKey or existing is InputEventMouseButton:
				InputMap.action_erase_event(action, existing)
		var space_event := InputEventKey.new()
		space_event.physical_keycode = KEY_SPACE
		InputMap.action_add_event(action, space_event)
		keybind_changed.emit(action)
		save_settings()
		return

	if not _default_keybinds.has(action):
		return
	InputMap.action_erase_events(action)
	for event: InputEvent in _default_keybinds[action]:
		InputMap.action_add_event(action, event)
	keybind_changed.emit(action)
	save_settings()

# Liefert das "beste" Tastatur-/Maus-Event einer Action fürs UI. Manche
# Actions (ui_up/down/left/right) haben in project.godot ZWEI Keyboard-
# Events: Pfeiltasten (nur "keycode" gesetzt, physical_keycode = 0) UND
# WASD (physical_keycode gesetzt) — davon wird die physical_keycode-Variante
# bevorzugt gezeigt.
#
# SONDERFALL ui_accept: Godots Default-Belegung enthält hier standardmäßig
# SOWOHL Enter ALS AUCH Leertaste (beides mit physical_keycode gesetzt).
# Ohne Sonderbehandlung würde einfach das erste gefundene Event gewinnen,
# was zufällig Enter statt Space sein kann. Deshalb wird für ui_accept
# explizit KEY_SPACE gesucht und bevorzugt, falls vorhanden.
func get_action_event(action: String) -> InputEvent:
	var events: Array = InputMap.action_get_events(action)

	if action == "ui_accept":
		for event in events:
			if event is InputEventKey and event.physical_keycode == KEY_SPACE:
				return event

	var fallback: InputEvent = null
	for event in events:
		if event is InputEventKey:
			if event.physical_keycode != 0:
				return event
			elif fallback == null:
				fallback = event
		elif event is InputEventMouseButton and fallback == null:
			fallback = event

	if fallback != null:
		return fallback
	return events[0] if not events.is_empty() else null

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

# ============================================================================
# Reset to Defaults (alle Werte)
# ============================================================================
func reset_all_to_defaults() -> void:
	mouse_sensitivity = DEFAULT_SENSITIVITY
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 1.0
	display_mode = DISPLAY_MODE_WINDOWED
	vsync_enabled = true
	fps_limit = 144
	hud_visible = true
	crt_filter_enabled = true
	screen_shake_enabled = true
	colorblind_mode = COLORBLIND_OFF

	for action in REBINDABLE_ACTIONS.keys():
		reset_action_to_default(action)

	_apply_all()
	sensitivity_changed.emit(mouse_sensitivity)
	volume_changed.emit("Master", master_volume)
	volume_changed.emit("Music", music_volume)
	volume_changed.emit("SFX", sfx_volume)
	display_mode_changed.emit(display_mode)
	vsync_changed.emit(vsync_enabled)
	fps_limit_changed.emit(fps_limit)
	hud_visible_changed.emit(hud_visible)
	crt_filter_changed.emit(crt_filter_enabled)
	screen_shake_changed.emit(screen_shake_enabled)
	colorblind_mode_changed.emit(colorblind_mode)
	save_settings()

# ============================================================================
# Persistenz
# ============================================================================
func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)

	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)

	config.set_value("display", "display_mode", display_mode)
	config.set_value("display", "vsync", vsync_enabled)
	config.set_value("display", "fps_limit", fps_limit)

	config.set_value("general", "hud_visible", hud_visible)

	config.set_value("accessibility", "crt_filter", crt_filter_enabled)
	config.set_value("accessibility", "screen_shake", screen_shake_enabled)
	config.set_value("accessibility", "colorblind_mode", colorblind_mode)

	for action in REBINDABLE_ACTIONS.keys():
		var event: InputEvent = get_action_event(action)
		if event:
			config.set_value("keybinds", action, var_to_str(event))

	var err: Error = config.save(SETTINGS_PATH)
	if err != OK:
		push_warning("SettingsManager: Speichern nach '%s' fehlgeschlagen (Fehlercode %d)." % [SETTINGS_PATH, err])

func load_settings() -> void:
	_default_keybinds.clear()
	for action in REBINDABLE_ACTIONS.keys():
		var dup: Array[InputEvent] = []
		for event in InputMap.action_get_events(action):
			dup.append(event.duplicate())
		_default_keybinds[action] = dup

	var config := ConfigFile.new()
	var err: Error = config.load(SETTINGS_PATH)
	if err != OK:
		return  # Erster Start — Defaults behalten

	mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", DEFAULT_SENSITIVITY)

	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 1.0)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)

	# Migration: alte Configs hatten nur "fullscreen: bool".
	if config.has_section_key("display", "display_mode"):
		display_mode = config.get_value("display", "display_mode", DISPLAY_MODE_WINDOWED)
	else:
		var legacy_fs: bool = config.get_value("display", "fullscreen", false)
		display_mode = DISPLAY_MODE_FULLSCREEN if legacy_fs else DISPLAY_MODE_WINDOWED
	vsync_enabled = config.get_value("display", "vsync", true)
	fps_limit = config.get_value("display", "fps_limit", 144)

	hud_visible = config.get_value("general", "hud_visible", true)

	crt_filter_enabled = config.get_value("accessibility", "crt_filter", true)
	screen_shake_enabled = config.get_value("accessibility", "screen_shake", true)
	colorblind_mode = config.get_value("accessibility", "colorblind_mode", COLORBLIND_OFF)

	for action in REBINDABLE_ACTIONS.keys():
		var raw: String = config.get_value("keybinds", action, "")
		if raw == "":
			continue
		var event = str_to_var(raw)
		if event is InputEvent:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
