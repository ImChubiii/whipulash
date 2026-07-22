extends Node

# ============================================================================
# SettingsManager — Autoload-Singleton für alle persistenten Spieleinstellungen.
# Speichert/lädt in user://settings.cfg (ConfigFile). Muss unter Project Settings
# -> Autoload als "SettingsManager" eingetragen sein.
#
# ARCHITEKTUR: Werte werden hier zentral gehalten. Andere Systeme (HUD, Player,
# CRT-Overlay, combat.gd) verbinden sich mit den passenden `*_changed`-Signalen
# und reagieren live, ohne dass hier von SettingsManager aus in fremde Nodes
# reingegriffen wird (Ausnahme: _apply_sensitivity_to_player als Legacy-Pfad).
# ============================================================================

signal sensitivity_changed(value: float)
signal volume_changed(bus_name: String, value_linear: float)
signal fullscreen_changed(is_fullscreen: bool)
signal display_mode_changed(mode: int)
signal vsync_changed(enabled: bool)
signal fps_limit_changed(fps: int)
signal fov_changed(fov: float)
signal keybind_changed(action: String)

# Accessibility
signal crt_filter_changed(enabled: bool)
signal screen_shake_changed(enabled: bool)
signal aim_toggle_changed(is_toggle: bool)
signal colorblind_mode_changed(mode: int)

# General / HUD
signal hud_visible_changed(visible: bool)
signal damage_numbers_changed(enabled: bool)
signal minimap_opacity_changed(opacity: float)

const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_SENSITIVITY: float = 0.003
const DEFAULT_FOV: float = 75.0

# Display Mode Enum
const DISPLAY_MODE_WINDOWED: int = 0
const DISPLAY_MODE_FULLSCREEN: int = 1
const DISPLAY_MODE_BORDERLESS: int = 2

# Colorblind Mode Enum (Filter-Implementierung folgt in Phase 4)
const COLORBLIND_OFF: int = 0
const COLORBLIND_PROTANOPIA: int = 1
const COLORBLIND_DEUTERANOPIA: int = 2
const COLORBLIND_TRITANOPIA: int = 3

# --- Rebindbare Actions + Anzeigename fürs SettingsMenu-UI. Diese Liste ist
# die EINZIGE Quelle der Wahrheit dafür, welche Actions im Menü auftauchen —
# neue rebindbare Actions einfach hier ergänzen. ---
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
var is_fullscreen: bool = false  # DEPRECATED, nur für Migration von alten Configs
var display_mode: int = DISPLAY_MODE_WINDOWED
var vsync_enabled: bool = true
var fps_limit: int = 144  # 0 = unlimited
var fov: float = DEFAULT_FOV

# --- General / HUD ---
var hud_visible: bool = true
var damage_numbers_enabled: bool = true
var minimap_opacity: float = 0.8

# --- Accessibility ---
var crt_filter_enabled: bool = true
var screen_shake_enabled: bool = true
var aim_is_toggle: bool = false  # false = Hold, true = Toggle
var colorblind_mode: int = COLORBLIND_OFF

# Merkt sich die InputMap-Belegung vom allerersten Start (noch ohne
# user://settings.cfg-Overrides) — Grundlage für reset_action_to_default().
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
# Legacy-API — bleibt für alte Aufrufer erhalten, delegiert intern auf
# das neue Display-Mode-System.
func set_fullscreen(enabled: bool) -> void:
	set_display_mode(DISPLAY_MODE_FULLSCREEN if enabled else DISPLAY_MODE_WINDOWED)

func set_display_mode(mode: int) -> void:
	display_mode = mode
	is_fullscreen = (mode == DISPLAY_MODE_FULLSCREEN or mode == DISPLAY_MODE_BORDERLESS)
	_apply_display_mode(mode)
	display_mode_changed.emit(mode)
	fullscreen_changed.emit(is_fullscreen)  # Legacy-Signal weiter feuern
	save_settings()

func _apply_display_mode(mode: int) -> void:
	match mode:
		DISPLAY_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
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

func set_fov(value: float) -> void:
	fov = value
	fov_changed.emit(value)
	save_settings()

# ============================================================================
# General / HUD
# ============================================================================
func set_hud_visible(is_visible: bool) -> void:
	hud_visible = is_visible
	hud_visible_changed.emit(is_visible)
	save_settings()

func set_damage_numbers_enabled(enabled: bool) -> void:
	damage_numbers_enabled = enabled
	damage_numbers_changed.emit(enabled)
	save_settings()

func set_minimap_opacity(opacity: float) -> void:
	minimap_opacity = opacity
	minimap_opacity_changed.emit(opacity)
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
	# Toggelt alle Nodes in der Gruppe "crt_overlay" (siehe TODO Phase 2 —
	# CRTOverlay-ColorRect muss dieser Gruppe hinzugefügt werden).
	for node in get_tree().get_nodes_in_group("crt_overlay"):
		if node is CanvasItem:
			node.visible = enabled

func set_screen_shake_enabled(enabled: bool) -> void:
	screen_shake_enabled = enabled
	screen_shake_changed.emit(enabled)
	save_settings()

func set_aim_toggle(is_toggle: bool) -> void:
	aim_is_toggle = is_toggle
	aim_toggle_changed.emit(is_toggle)
	save_settings()

func set_colorblind_mode(mode: int) -> void:
	colorblind_mode = mode
	colorblind_mode_changed.emit(mode)
	save_settings()

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

func reset_action_to_default(action: String) -> void:
	if not _default_keybinds.has(action):
		return
	InputMap.action_erase_events(action)
	for event: InputEvent in _default_keybinds[action]:
		InputMap.action_add_event(action, event)
	keybind_changed.emit(action)
	save_settings()

func get_action_event(action: String) -> InputEvent:
	var events: Array = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey or event is InputEventMouseButton:
			return event
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
	is_fullscreen = false
	vsync_enabled = true
	fps_limit = 144
	fov = DEFAULT_FOV
	hud_visible = true
	damage_numbers_enabled = true
	minimap_opacity = 0.8
	crt_filter_enabled = true
	screen_shake_enabled = true
	aim_is_toggle = false
	colorblind_mode = COLORBLIND_OFF

	for action in REBINDABLE_ACTIONS.keys():
		reset_action_to_default(action)

	_apply_all()
	# Alle Change-Signals feuern, damit UI + gebundene Systeme sich neu syncen
	sensitivity_changed.emit(mouse_sensitivity)
	volume_changed.emit("Master", master_volume)
	volume_changed.emit("Music", music_volume)
	volume_changed.emit("SFX", sfx_volume)
	display_mode_changed.emit(display_mode)
	vsync_changed.emit(vsync_enabled)
	fps_limit_changed.emit(fps_limit)
	fov_changed.emit(fov)
	hud_visible_changed.emit(hud_visible)
	damage_numbers_changed.emit(damage_numbers_enabled)
	minimap_opacity_changed.emit(minimap_opacity)
	crt_filter_changed.emit(crt_filter_enabled)
	screen_shake_changed.emit(screen_shake_enabled)
	aim_toggle_changed.emit(aim_is_toggle)
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
	config.set_value("display", "fov", fov)

	config.set_value("general", "hud_visible", hud_visible)
	config.set_value("general", "damage_numbers", damage_numbers_enabled)
	config.set_value("general", "minimap_opacity", minimap_opacity)

	config.set_value("accessibility", "crt_filter", crt_filter_enabled)
	config.set_value("accessibility", "screen_shake", screen_shake_enabled)
	config.set_value("accessibility", "aim_toggle", aim_is_toggle)
	config.set_value("accessibility", "colorblind_mode", colorblind_mode)

	for action in REBINDABLE_ACTIONS.keys():
		var event: InputEvent = get_action_event(action)
		if event:
			config.set_value("keybinds", action, var_to_str(event))

	var err: Error = config.save(SETTINGS_PATH)
	if err != OK:
		push_warning("SettingsManager: Speichern nach '%s' fehlgeschlagen (Fehlercode %d)." % [SETTINGS_PATH, err])

func load_settings() -> void:
	# Defaults aus InputMap sichern, BEVOR irgendwas überschrieben wird
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

	# Migration: alte Configs hatten nur "fullscreen: bool", neue haben display_mode.
	# Wenn display_mode fehlt, aus fullscreen ableiten.
	if config.has_section_key("display", "display_mode"):
		display_mode = config.get_value("display", "display_mode", DISPLAY_MODE_WINDOWED)
	else:
		var legacy_fs: bool = config.get_value("display", "fullscreen", false)
		display_mode = DISPLAY_MODE_FULLSCREEN if legacy_fs else DISPLAY_MODE_WINDOWED
	is_fullscreen = (display_mode == DISPLAY_MODE_FULLSCREEN or display_mode == DISPLAY_MODE_BORDERLESS)
	vsync_enabled = config.get_value("display", "vsync", true)
	fps_limit = config.get_value("display", "fps_limit", 144)
	fov = config.get_value("display", "fov", DEFAULT_FOV)

	hud_visible = config.get_value("general", "hud_visible", true)
	damage_numbers_enabled = config.get_value("general", "damage_numbers", true)
	minimap_opacity = config.get_value("general", "minimap_opacity", 0.8)

	crt_filter_enabled = config.get_value("accessibility", "crt_filter", true)
	screen_shake_enabled = config.get_value("accessibility", "screen_shake", true)
	aim_is_toggle = config.get_value("accessibility", "aim_toggle", false)
	colorblind_mode = config.get_value("accessibility", "colorblind_mode", COLORBLIND_OFF)

	for action in REBINDABLE_ACTIONS.keys():
		var raw: String = config.get_value("keybinds", action, "")
		if raw == "":
			continue
		var event = str_to_var(raw)
		if event is InputEvent:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
