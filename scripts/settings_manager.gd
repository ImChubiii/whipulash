extends Node

# ============================================================================
# SettingsManager — Autoload-Singleton für alle persistenten Spieleinstellungen.
# Speichert/lädt in user://settings.cfg (ConfigFile). Muss unter Project Settings
# -> Autoload als "SettingsManager" eingetragen sein.
#
# ÄNDERUNGEN GEGENÜBER DER VORVERSION:
#  - ENTFERNT: minimap_grid_scale und minimap_big_map_zoom. Der Grosskarten-
#    Zoom laeuft jetzt ueber das Mausrad (siehe minimap.gd) — ein Regler
#    dafuer ist doppelte Bedienung fuer dieselbe Sache.
#  - NEU: minimap_show_player_arrow.
#  - ZUSAMMENGELEGT: es gibt nur noch EINE Minimap-Deckkraft
#    (minimap_opacity) fuer Flaeche und Rahmen.
#  - NEU: Reset pro Seite (reset_general/video/audio/controls) statt nur
#    "alles zuruecksetzen".
#  - FIX: Fenster sprang beim allerersten Start auf absolute Desktop-
#    Koordinate (0,0) statt auf dem Primary Screen zu bleiben. Grund:
#    _windowed_position wurde nie gespeichert/geladen und blieb dadurch
#    auf ihrem Klassen-Default Vector2i.ZERO stehen — bei Multi-Monitor-
#    Setups liegt (0,0) je nach Monitor-Anordnung oft NICHT auf dem
#    Hauptbildschirm. _has_valid_windowed_position sorgt jetzt dafuer,
#    dass window_set_position() nur laeuft, wenn wirklich eine echte,
#    gespeicherte Position existiert.
# ============================================================================

signal sensitivity_changed(value: float)
signal volume_changed(bus_name: String, value_linear: float)
signal fullscreen_changed(is_fullscreen: bool)
signal display_mode_changed(mode: int)
signal vsync_changed(enabled: bool)
signal fps_limit_changed(fps: int)
signal fov_changed(value: float)
signal keybind_changed(action: String)

# Accessibility
signal crt_filter_changed(enabled: bool)
signal screen_shake_changed(enabled: bool)
signal colorblind_mode_changed(mode: int)

# General
signal hud_visible_changed(visible: bool)
signal minimap_rotate_with_player_changed(enabled: bool)
signal hud_element_visible_changed(element: String, is_visible: bool)

## Sammelsignal fuer ALLE Minimap-Werte. minimap.gd reagiert darauf mit
## einem vollstaendigen _apply_minimap_settings() — kein Wert kann dadurch
## "vergessen" werden.
signal minimap_setting_changed()

const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_SENSITIVITY: float = 0.003
const DEFAULT_WINDOWED_SIZE: Vector2i = Vector2i(1280, 720)

# ============================================================================
# SICHTFELD (FOV)
# ============================================================================
# Godots Kamera-Default ist 75. Fuer eine Third-Person-Kamera am Federarm ist
# das zu eng: der Charakter frisst viel Bildflaeche und man verliert bei
# schnellen Kaempfen die Uebersicht ueber flankierende Gegner. 90 als Start
# gibt spuerbar mehr Peripherie, ohne PSX-typische Verzerrung an den Raendern.
#
# Die Grenzen leben hier und nicht im Einstellungsmenue, damit Slider-Range,
# der Clamp beim Laden und der Clamp im Spieler garantiert dieselbe Quelle
# haben.
const FOV_MIN: float = 60.0
const FOV_MAX: float = 120.0
const FOV_DEFAULT: float = 90.0

# Display Mode Enum
const DISPLAY_MODE_WINDOWED: int = 0
const DISPLAY_MODE_FULLSCREEN: int = 1
const DISPLAY_MODE_BORDERLESS: int = 2

# --- Modulare HUD-Elemente ---------------------------------------------
const HUD_ELEMENT_MINIMAP: String = "minimap"
const HUD_ELEMENT_PARTY: String = "party"
const HUD_ELEMENT_ABILITIES: String = "abilities"
const HUD_ELEMENT_KEYBINDS: String = "keybinds"
const HUD_ELEMENT_TIMER: String = "timer"
const HUD_ELEMENT_COMBO: String = "combo"
## Diese beiden Schluessel muessen mit StatsPanel.HUD_ELEMENT bzw.
## ItemDescriptionHud.HUD_ELEMENT uebereinstimmen. Die Panels fragen
## is_hud_element_visible() mit genau diesen Strings ab; ein Tippfehler
## faellt nicht als Fehler auf, sondern nur dadurch, dass der Schalter
## im Menue nichts bewirkt.
const HUD_ELEMENT_STATS: String = "stats"
const HUD_ELEMENT_ITEMS: String = "items"

const HUD_ELEMENTS: Dictionary = {
	HUD_ELEMENT_MINIMAP: "Minimap",
	HUD_ELEMENT_PARTY: "Charakter-Status / Portraits",
	HUD_ELEMENT_ABILITIES: "Faehigkeiten",
	HUD_ELEMENT_KEYBINDS: "Keybinds / Cooldowns",
	HUD_ELEMENT_TIMER: "Speedrun-Timer",
	HUD_ELEMENT_COMBO: "Combo-Zaehler",
	HUD_ELEMENT_STATS: "Stats-Panel",
	HUD_ELEMENT_ITEMS: "Item-Anzeige",
}

# Colorblind Mode Enum
const COLORBLIND_OFF: int = 0
const COLORBLIND_PROTANOPIA: int = 1
const COLORBLIND_DEUTERANOPIA: int = 2
const COLORBLIND_TRITANOPIA: int = 3

# ============================================================================
# MINIMAP — Grenzwerte
# ============================================================================
# Die Grenzen leben hier und nicht im Einstellungsmenue, damit Slider-Range
# und der Clamp beim Laden aus der Config garantiert dieselbe Quelle haben.

const MINIMAP_ZOOM_MIN: float = 0.4
const MINIMAP_ZOOM_MAX: float = 3.0
const MINIMAP_ZOOM_DEFAULT: float = 1.0

const MINIMAP_UI_SCALE_MIN: float = 0.6
const MINIMAP_UI_SCALE_MAX: float = 1.8
const MINIMAP_UI_SCALE_DEFAULT: float = 1.0

## Deckkraft der Minimap-Flaeche UND ihres Rahmens. Es gibt bewusst nur
## noch diesen EINEN Wert: frueher hatten Frame, 3D-Ansicht und Raum-Grid
## je einen eigenen Alphawert, was drei unterschiedlich durchsichtige
## Flaechen uebereinander ergab (der "Kasten im Kasten"). Der Default 0.82
## entspricht dem Wert, der bisher fest in hud.tscn (StyleBoxFlat_mapframe)
## stand.
const MINIMAP_OPACITY_MIN: float = 0.0
const MINIMAP_OPACITY_MAX: float = 1.0
const MINIMAP_OPACITY_DEFAULT: float = 0.82

## Platzierung des schematischen Raum-Grids. Werte decken sich 1:1 mit
## minimap.gd -> OverlayPlacement.
const MINIMAP_GRID_BELOW: int = 0
const MINIMAP_GRID_INSIDE: int = 1
const MINIMAP_GRID_HIDDEN: int = 2

# --- Rebindbare Actions + Anzeigename fürs SettingsMenu-UI. ---
const REBINDABLE_ACTIONS: Dictionary = {
	"attack_primary": "Primärangriff",
	"attack_secondary": "Sekundärangriff",
	"utility": "Dash",
	"ability_primary": "Fähigkeit (Q)",
	"ability_secondary": "Fähigkeit (E)",
	"interact": "Interagieren",
	"reset": "Level neu starten",
	"ui_accept": "Springen",
	"ui_left": "Links",
	"ui_right": "Rechts",
	"ui_up": "Vorwärts",
	"ui_down": "Rückwärts",
}

# ============================================================================
# VERBINDLICHE Standard-Tastenbelegung
# ============================================================================
# Diese Tabelle IST der Standard — hart definiert, unabhaengig von
# project.godot.
const DEFAULT_KEYBINDS: Dictionary = {
	"attack_primary":    {"mouse": MOUSE_BUTTON_LEFT},
	"attack_secondary":  {"mouse": MOUSE_BUTTON_RIGHT},
	"utility":           {"key": KEY_SHIFT},
	"ability_primary":   {"key": KEY_Q},
	"ability_secondary": {"key": KEY_E},
	"interact":          {"key": KEY_F},
	"ui_accept":         {"key": KEY_SPACE},
	"ui_left":           {"key": KEY_A},
	"ui_right":          {"key": KEY_D},
	"ui_up":             {"key": KEY_W},
	"ui_down":           {"key": KEY_S},
	"reset":             {"key": KEY_R},
}


static func build_default_event(action: String) -> InputEvent:
	if not DEFAULT_KEYBINDS.has(action):
		return null
	var spec: Dictionary = DEFAULT_KEYBINDS[action]

	if spec.has("mouse"):
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = spec["mouse"]
		return mouse_event

	if spec.has("key"):
		var key_event := InputEventKey.new()
		# physical_keycode statt keycode: bleibt auf AZERTY/QWERTZ an der
		# gleichen PHYSISCHEN Stelle, was fuer WASD entscheidend ist.
		key_event.physical_keycode = spec["key"]
		return key_event

	return null

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
## Vertikales Sichtfeld der Spielerkamera in Grad.
var fov: float = FOV_DEFAULT

# --- General / HUD ---
var hud_visible: bool = true
var hud_elements: Dictionary = {}

# --- Minimap ---
## false = Minimap bleibt IMMER nordorientiert (Standard).
var minimap_rotate_with_player: bool = false
## Multiplikator auf den Weltausschnitt der 3D-Draufsicht.
## Groesser = naeher dran (weniger Welt sichtbar).
var minimap_zoom: float = MINIMAP_ZOOM_DEFAULT
## Skaliert das komplette Minimap-Control im HUD.
var minimap_ui_scale: float = MINIMAP_UI_SCALE_DEFAULT
## Deckkraft von Flaeche und Rahmen.
var minimap_opacity: float = MINIMAP_OPACITY_DEFAULT
## Wo das Raum-Grid sitzt: unter der Karte / in der Karte / aus.
var minimap_grid_placement: int = MINIMAP_GRID_BELOW
## Spielerpfeil in der Kartenmitte.
var minimap_show_player_arrow: bool = true
## X/Y-Koordinatenanzeige unter der Karte.
var minimap_show_coords: bool = true
## Zonen-/Etagenname ueber der Karte.
var minimap_show_zone_label: bool = true

# --- Accessibility ---
var crt_filter_enabled: bool = true
var screen_shake_enabled: bool = true
var colorblind_mode: int = COLORBLIND_OFF

# Merkt sich die letzte bekannte Fenstergröße/-position im Windowed-Modus.
var _windowed_size: Vector2i = DEFAULT_WINDOWED_SIZE
var _windowed_position: Vector2i = Vector2i.ZERO
## true, sobald eine ECHTE Fensterposition bekannt ist (aus der Config
## geladen ODER durch set_display_mode() beim Wechsel WEG von Windowed
## gesichert). Verhindert, dass der Klassen-Default Vector2i.ZERO beim
## allerersten Start das Fenster auf absolute Desktop-Koordinate (0,0)
## zieht — die bei Multi-Monitor-Setups oft NICHT auf dem Hauptbildschirm
## liegt. Siehe _apply_display_mode().
var _has_valid_windowed_position: bool = false

# Merkt sich die InputMap-Belegung vom allerersten Start.
var _default_keybinds: Dictionary = {}  # action -> Array[InputEvent]

func _ready() -> void:
	_init_hud_elements()
	_ensure_actions_exist()
	load_settings()
	_apply_all()

func _ensure_actions_exist() -> void:
	for action in REBINDABLE_ACTIONS.keys():
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var event: InputEvent = build_default_event(action)
		if event:
			InputMap.action_add_event(action, event)
			print("[SettingsManager] Action '%s' fehlte im InputMap - mit Standardbelegung angelegt." % action)
		else:
			push_warning("SettingsManager: Action '%s' fehlt im InputMap und steht nicht in DEFAULT_KEYBINDS." % action)

func _init_hud_elements() -> void:
	for key in HUD_ELEMENTS.keys():
		if not hud_elements.has(key):
			hud_elements[key] = true

func _apply_all() -> void:
	_apply_volume("Master", master_volume)
	_apply_volume("Music", music_volume)
	_apply_volume("SFX", sfx_volume)
	_apply_display_mode(display_mode)
	_apply_vsync(vsync_enabled)
	_apply_fps_limit(fps_limit)
	_apply_sensitivity_to_player()
	_apply_fov_to_player()
	_apply_crt_filter(crt_filter_enabled)
	_apply_colorblind_mode(colorblind_mode)
	minimap_setting_changed.emit()

# ============================================================================
# Controls
# ============================================================================
func set_sensitivity(value: float) -> void:
	mouse_sensitivity = value
	_apply_sensitivity_to_player()
	sensitivity_changed.emit(mouse_sensitivity)
	save_settings()

## Ueber die Gruppe "player" statt find_child("Player"): der PartyManager
## tauscht die Spieler-Instanz bei JEDEM Charakterwechsel komplett aus (alte
## Instanz raus, neue rein). Ein per Namen gefundener Node ist danach
## ungueltig, und find_child laeuft ausserdem bei jedem Aufruf den halben
## Szenenbaum ab.
##
## Die Gruppe steht hier bewusst als String und nicht als
## PartyManager.PLAYER_GROUP: die Reihenfolge, in der Autoloads initialisiert
## werden, ist nicht garantiert - ein Zugriff auf ein anderes Autoload
## waehrend _ready() kann ins Leere laufen.
func _apply_sensitivity_to_player() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		if "mouse_sensitivity" in node:
			node.set("mouse_sensitivity", mouse_sensitivity)

# ============================================================================
# Sichtfeld (FOV)
# ============================================================================
func set_fov(value: float) -> void:
	fov = clampf(value, FOV_MIN, FOV_MAX)
	_apply_fov_to_player()
	fov_changed.emit(fov)
	save_settings()

## Der Spieler hoert zusaetzlich selbst auf fov_changed (siehe
## player_base.gd). Dieser Push hier ist fuer den Fall, dass eine
## Spieler-Instanz erst NACH dem Setzen des Werts entsteht bzw. beim
## Spielstart aus _apply_all() heraus.
func _apply_fov_to_player() -> void:
	for node in get_tree().get_nodes_in_group("player"):
		if node.has_method("set_camera_fov"):
			node.set_camera_fov(fov)

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
	if display_mode == DISPLAY_MODE_WINDOWED:
		_windowed_size = DisplayServer.window_get_size()
		_windowed_position = DisplayServer.window_get_position()
		_has_valid_windowed_position = true

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
			DisplayServer.window_set_size(_windowed_size)
			# Nur eine ECHTE gespeicherte Position anwenden. Beim
			# allerersten Start (kein gespeicherter Wert, _windowed_position
			# steht noch auf dem Klassen-Default Vector2i.ZERO) bleibt das
			# Fenster dort stehen, wo Godot es ueber die Projekteinstellung
			# "Initial Position Type = Center Primary Screen" bereits
			# korrekt platziert hat. Ohne diese Sperre wuerde JEDER Start
			# das Fenster auf absolute Desktop-Koordinate (0,0) ziehen, was
			# bei Multi-Monitor-Setups haeufig auf dem falschen Bildschirm
			# und nur teilweise sichtbar landet.
			if _has_valid_windowed_position:
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
# General / HUD
# ============================================================================
func set_hud_visible(is_visible: bool) -> void:
	hud_visible = is_visible
	hud_visible_changed.emit(is_visible)
	save_settings()

func set_hud_element_visible(element: String, is_visible: bool) -> void:
	if not HUD_ELEMENTS.has(element):
		push_warning("SettingsManager: Unbekanntes HUD-Element '%s'." % element)
		return
	hud_elements[element] = is_visible
	hud_element_visible_changed.emit(element, is_visible)
	save_settings()

## Reiner Element-Schalter OHNE den Master-Schalter. Das HUD verknuepft
## beides — siehe hud.gd.
func is_hud_element_visible(element: String) -> bool:
	return bool(hud_elements.get(element, true))

# ============================================================================
# Minimap
# ============================================================================
# Alle Setter clampen selbst und feuern dasselbe Sammelsignal. Der Clamp
# hier (statt nur im Slider) ist der eigentliche Schutz — ein Aufruf aus
# Code oder eine manipulierte Config geht sonst am Slider vorbei.

func set_minimap_rotate_with_player(enabled: bool) -> void:
	minimap_rotate_with_player = enabled
	minimap_rotate_with_player_changed.emit(enabled)
	minimap_setting_changed.emit()
	save_settings()

func set_minimap_zoom(value: float) -> void:
	minimap_zoom = clampf(value, MINIMAP_ZOOM_MIN, MINIMAP_ZOOM_MAX)
	minimap_setting_changed.emit()
	save_settings()

func set_minimap_ui_scale(value: float) -> void:
	minimap_ui_scale = clampf(value, MINIMAP_UI_SCALE_MIN, MINIMAP_UI_SCALE_MAX)
	minimap_setting_changed.emit()
	save_settings()

func set_minimap_opacity(value: float) -> void:
	minimap_opacity = clampf(value, MINIMAP_OPACITY_MIN, MINIMAP_OPACITY_MAX)
	minimap_setting_changed.emit()
	save_settings()

func set_minimap_grid_placement(placement: int) -> void:
	minimap_grid_placement = clampi(placement, MINIMAP_GRID_BELOW, MINIMAP_GRID_HIDDEN)
	minimap_setting_changed.emit()
	save_settings()

func set_minimap_show_player_arrow(enabled: bool) -> void:
	minimap_show_player_arrow = enabled
	minimap_setting_changed.emit()
	save_settings()

func set_minimap_show_coords(enabled: bool) -> void:
	minimap_show_coords = enabled
	minimap_setting_changed.emit()
	save_settings()

func set_minimap_show_zone_label(enabled: bool) -> void:
	minimap_show_zone_label = enabled
	minimap_setting_changed.emit()
	save_settings()

## Setzt NUR den Minimap-Block zurueck. Feuert das Sammelsignal genau
## einmal statt achtmal.
func reset_minimap_settings() -> void:
	_reset_minimap_values()
	minimap_rotate_with_player_changed.emit(minimap_rotate_with_player)
	minimap_setting_changed.emit()
	save_settings()

## Reine Wertzuweisung ohne Signale — damit die Seiten-Resets weiter unten
## erst ALLE Werte setzen und dann EINMAL sammelfeuern koennen.
func _reset_minimap_values() -> void:
	minimap_rotate_with_player = false
	minimap_zoom = MINIMAP_ZOOM_DEFAULT
	minimap_ui_scale = MINIMAP_UI_SCALE_DEFAULT
	minimap_opacity = MINIMAP_OPACITY_DEFAULT
	minimap_grid_placement = MINIMAP_GRID_BELOW
	minimap_show_player_arrow = true
	minimap_show_coords = true
	minimap_show_zone_label = true

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

func reset_action_to_default(action: String) -> void:
	var event: InputEvent = build_default_event(action)

	if event == null:
		push_warning("SettingsManager: '%s' fehlt in DEFAULT_KEYBINDS - nutze die beim Start gesicherte Belegung." % action)
		if not _default_keybinds.has(action):
			return
		InputMap.action_erase_events(action)
		for fallback_event: InputEvent in _default_keybinds[action]:
			InputMap.action_add_event(action, fallback_event)
		keybind_changed.emit(action)
		save_settings()
		return

	if not InputMap.has_action(action):
		InputMap.add_action(action)

	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)

	keybind_changed.emit(action)
	save_settings()


## Setzt ALLE Actions auf die Standardbelegung zurueck.
func reset_all_keybinds() -> void:
	for action in REBINDABLE_ACTIONS.keys():
		reset_action_to_default(action)


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
# Reset — pro Seite
# ============================================================================
# Ein globaler "Reset to Default" ist im Alltag gefaehrlich: wer in den
# Keybinds sitzt und zuruecksetzen will, verliert sonst nebenbei seine
# Lautstaerke, Aufloesung und Minimap-Einstellungen. Deshalb setzt der
# Button im Menue nur noch die AKTUELLE Seite zurueck; reset_all_to_defaults()
# bleibt als API bestehen (z.B. fuer einen spaeteren "Alles zuruecksetzen"
# im Hauptmenue), wird vom Button aber nicht mehr aufgerufen.

func reset_general_settings() -> void:
	hud_visible = true
	for key in HUD_ELEMENTS.keys():
		hud_elements[key] = true
	_reset_minimap_values()
	crt_filter_enabled = true
	screen_shake_enabled = true
	colorblind_mode = COLORBLIND_OFF

	_apply_crt_filter(crt_filter_enabled)
	_apply_colorblind_mode(colorblind_mode)

	hud_visible_changed.emit(hud_visible)
	for key in HUD_ELEMENTS.keys():
		hud_element_visible_changed.emit(key, bool(hud_elements[key]))
	minimap_rotate_with_player_changed.emit(minimap_rotate_with_player)
	minimap_setting_changed.emit()
	crt_filter_changed.emit(crt_filter_enabled)
	screen_shake_changed.emit(screen_shake_enabled)
	colorblind_mode_changed.emit(colorblind_mode)
	save_settings()


func reset_video_settings() -> void:
	display_mode = DISPLAY_MODE_WINDOWED
	vsync_enabled = true
	fps_limit = 144
	fov = FOV_DEFAULT

	_apply_display_mode(display_mode)
	_apply_vsync(vsync_enabled)
	_apply_fps_limit(fps_limit)
	_apply_fov_to_player()

	display_mode_changed.emit(display_mode)
	fullscreen_changed.emit(false)
	vsync_changed.emit(vsync_enabled)
	fps_limit_changed.emit(fps_limit)
	fov_changed.emit(fov)
	save_settings()


func reset_audio_settings() -> void:
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 1.0

	_apply_volume("Master", master_volume)
	_apply_volume("Music", music_volume)
	_apply_volume("SFX", sfx_volume)

	volume_changed.emit("Master", master_volume)
	volume_changed.emit("Music", music_volume)
	volume_changed.emit("SFX", sfx_volume)
	save_settings()


## Sensitivity + komplette Tastenbelegung. reset_action_to_default()
## speichert selbst — das abschliessende save_settings() ist trotzdem
## noetig, weil die Sensitivity sonst nur im Speicher stuende, falls
## REBINDABLE_ACTIONS jemals leer waere.
func reset_controls_settings() -> void:
	mouse_sensitivity = DEFAULT_SENSITIVITY
	_apply_sensitivity_to_player()
	sensitivity_changed.emit(mouse_sensitivity)

	for action in REBINDABLE_ACTIONS.keys():
		reset_action_to_default(action)

	save_settings()


## Vollreset ueber ALLE Seiten. Vom Menue-Button NICHT mehr aufgerufen.
func reset_all_to_defaults() -> void:
	reset_general_settings()
	reset_video_settings()
	reset_audio_settings()
	reset_controls_settings()

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

	# Fensterposition/-groesse im Windowed-Modus. has_valid_windowed_position
	# ist der eigentliche Schutz: ohne ihn wuerde ein Erststart mit dem
	# Klassen-Default Vector2i.ZERO gespeichert und beim naechsten Start
	# faelschlich als "echte" Position behandelt.
	config.set_value("display", "has_valid_windowed_position", _has_valid_windowed_position)
	config.set_value("display", "windowed_position_x", _windowed_position.x)
	config.set_value("display", "windowed_position_y", _windowed_position.y)
	config.set_value("display", "windowed_size_x", _windowed_size.x)
	config.set_value("display", "windowed_size_y", _windowed_size.y)

	config.set_value("general", "hud_visible", hud_visible)
	for key in HUD_ELEMENTS.keys():
		config.set_value("general", "hud_%s" % key, bool(hud_elements.get(key, true)))

	# Eigene Section statt "general": haelt die Config lesbar und macht
	# spaetere Migrationen unabhaengig vom Rest.
	config.set_value("minimap", "rotate_with_player", minimap_rotate_with_player)
	config.set_value("minimap", "zoom", minimap_zoom)
	config.set_value("minimap", "ui_scale", minimap_ui_scale)
	config.set_value("minimap", "opacity", minimap_opacity)
	config.set_value("minimap", "grid_placement", minimap_grid_placement)
	config.set_value("minimap", "show_player_arrow", minimap_show_player_arrow)
	config.set_value("minimap", "show_coords", minimap_show_coords)
	config.set_value("minimap", "show_zone_label", minimap_show_zone_label)

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

	# clampf schon beim LADEN, nicht erst im Setter: eine von Hand editierte
	# settings.cfg mit fov = 5 wuerde die Kamera sonst unbrauchbar machen,
	# ohne dass irgendwo ein Fehler im Log steht.
	fov = clampf(float(config.get_value("display", "fov", FOV_DEFAULT)), FOV_MIN, FOV_MAX)

	# Fensterposition/-groesse: NUR uebernehmen, wenn die Config sagt, dass
	# schon einmal eine echte Position gesichert wurde. Fehlt der Key
	# komplett (alte settings.cfg vor diesem Fix, oder Erststart), bleibt
	# _has_valid_windowed_position auf false und _apply_display_mode()
	# laesst das Fenster dort stehen, wo es die Projekteinstellung schon
	# richtig platziert hat.
	_has_valid_windowed_position = bool(config.get_value("display", "has_valid_windowed_position", false))
	if _has_valid_windowed_position:
		_windowed_position = Vector2i(
			int(config.get_value("display", "windowed_position_x", 0)),
			int(config.get_value("display", "windowed_position_y", 0))
		)
		_windowed_size = Vector2i(
			int(config.get_value("display", "windowed_size_x", DEFAULT_WINDOWED_SIZE.x)),
			int(config.get_value("display", "windowed_size_y", DEFAULT_WINDOWED_SIZE.y))
		)

	hud_visible = config.get_value("general", "hud_visible", true)
	for key in HUD_ELEMENTS.keys():
		hud_elements[key] = bool(config.get_value("general", "hud_%s" % key, true))

	# Migration: rotate_with_player lag frueher unter [general].
	# Die entfallenen Schluessel "grid_scale" und "big_map_zoom" werden
	# einfach nicht mehr gelesen — beim naechsten save_settings() fallen
	# sie automatisch aus der Datei, weil ConfigFile neu geschrieben wird.
	var legacy_rotate: bool = bool(config.get_value("general", "minimap_rotate_with_player", false))
	minimap_rotate_with_player = bool(config.get_value("minimap", "rotate_with_player", legacy_rotate))

	# clampf beim Laden, nicht nur beim Setzen: eine von Hand editierte
	# settings.cfg mit zoom = 0 wuerde die Minimap-Kamera sonst auf size 0
	# stellen (komplett schwarze Karte, kein Fehler im Log).
	minimap_zoom = clampf(
		float(config.get_value("minimap", "zoom", MINIMAP_ZOOM_DEFAULT)),
		MINIMAP_ZOOM_MIN, MINIMAP_ZOOM_MAX)
	minimap_ui_scale = clampf(
		float(config.get_value("minimap", "ui_scale", MINIMAP_UI_SCALE_DEFAULT)),
		MINIMAP_UI_SCALE_MIN, MINIMAP_UI_SCALE_MAX)
	# Migration: wer die Vorversion mit zwei Reglern hatte, bekommt den
	# frueheren HINTERGRUND-Wert als neuen Gesamtwert - der Gesamt-Regler
	# stand dort meist auf 1.0 und waere als Startwert nutzlos.
	var legacy_bg: float = float(config.get_value("minimap", "bg_opacity", MINIMAP_OPACITY_DEFAULT))
	minimap_opacity = clampf(
		float(config.get_value("minimap", "opacity", legacy_bg)) if not config.has_section_key("minimap", "bg_opacity") else legacy_bg,
		MINIMAP_OPACITY_MIN, MINIMAP_OPACITY_MAX)
	minimap_grid_placement = clampi(
		int(config.get_value("minimap", "grid_placement", MINIMAP_GRID_BELOW)),
		MINIMAP_GRID_BELOW, MINIMAP_GRID_HIDDEN)
	minimap_show_player_arrow = bool(config.get_value("minimap", "show_player_arrow", true))
	minimap_show_coords = bool(config.get_value("minimap", "show_coords", true))
	minimap_show_zone_label = bool(config.get_value("minimap", "show_zone_label", true))

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
