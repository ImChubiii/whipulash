extends Control
class_name MainMenu

# ============================================================================
# MainMenu — Hauptmenue (Play/Continue/Character/Stats/Settings/Quit).
# ============================================================================
# Komplett prozedural gebaut (gleiches Prinzip wie die Turrets/Hazards/VFX
# dieser Session) — die zugehoerige .tscn enthaelt nur einen leeren
# CanvasLayer + Control-Root mit diesem Script, kein Hand-Layout im Editor.
# Grund: dieses Script muss in zwei UNTERSCHIEDLICHEN Kontexten funktionieren
# (siehe unten), und ein rein codebasierter Aufbau macht beide Kontexte zum
# selben Pfad, statt zwei leicht unterschiedliche Szenen pflegen zu muessen.
#
# ZWEI VERWENDUNGSKONTEXTE:
#   1. TITEL-BILDSCHIRM: res://scenes/main_menu.tscn ist run/main_scene
#      (project.godot) — die Anwendung startet direkt hier, es existiert noch
#      keine lebende Spieler-Instanz. "Fortsetzen" ist hier IMMER deaktiviert.
#   2. PAUSE-OVERLAY: pause_menu.gd instanziert dieses Script zusaetzlich als
#      Kind-Node UEBER der weiterhin lebenden, pausierten Spielszene (neuer
#      "Hauptmenue"-Button, siehe pause_menu.gd). "Fortsetzen" schliesst hier
#      nur das Overlay wieder und pausiert die Welt nicht neu.
#
# "FORTSETZEN" IST BEWUSST NICHT DASSELBE WIE "SPIELSTAND LADEN": es gibt in
# diesem Projekt keine Serialisierung des prozeduralen Dungeons (Raum-Layout,
# Gegner-Zustaende, Position). Ein echtes Fortsetzen nach einem kompletten
# Neustart der Anwendung ist damit ausserhalb dessen, was hier sicher blind
# (ohne lokale Godot-Instanz zum Testen) gebaut werden kann. "Fortsetzen"
# funktioniert deshalb ausschliesslich innerhalb DERSELBEN Laufzeit-Sitzung,
# ueber den Pause-Overlay-Weg oben — dort wird nie irgendetwas abgebaut, es
# muss also auch nichts wiederhergestellt werden. Siehe GameStats.has_live_run.

signal continue_requested()

const GAMEPLAY_SCENE_PATH: String = "res://scenes/level_generation_test.tscn"
## Deckt sich mit StageManager.final_stage's Skript-Default (stage_manager.gd)
## - wird hier NICHT von dort gelesen, weil Stages.final_stage zur Laufzeit
## durch eine vorherige Speedrun-Runde bereits auf 1 stehen KOENNTE (Autoloads
## ueberleben Szenenwechsel innerhalb derselben Anwendungssitzung).
const NORMAL_FINAL_STAGE: int = 5
const SPEEDRUN_FINAL_STAGE: int = 1

const PANEL_COLOR: Color = Color(0.05, 0.05, 0.08, 0.86)
const BG_COLOR: Color = Color(0.03, 0.03, 0.05, 1.0)
const TITLE_COLOR: Color = Color(0.92, 0.92, 0.98)
const ACCENT_COLOR: Color = Color(0.55, 0.75, 1.0)

const CHARACTER_RESOURCE_PATHS: Array[String] = [
	"res://resources/char_1.tres",
	"res://resources/char_2.tres",
	"res://resources/char_3.tres",
	"res://resources/char_4.tres",
]

var _roster: Array[CharacterData] = []
var _character_index: int = 0

var _screens: Dictionary = {}  # String -> Control
var _continue_button: Button = null
var _settings_instance: SettingsMenu = null

var _character_portrait: TextureRect = null
var _character_name_label: Label = null
var _character_desc_label: Label = null
var _character_abilities_label: Label = null

var _stats_label: Label = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_load_roster()
	_build_background()
	_build_root_screen()
	_build_play_screen()
	_build_character_screen()
	_build_stats_screen()

	_show_screen("root")


func _load_roster() -> void:
	for path: String in CHARACTER_RESOURCE_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var data: CharacterData = load(path) as CharacterData
		if data != null:
			_roster.append(data)


func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = BG_COLOR
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	move_child(bg, 0)


# ============================================================================
# Bau-Helfer — gemeinsamer Look fuer alle Screens.
# ============================================================================
func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	return style


## Legt einen neuen Screen als zentrierten Panel/VBox-Aufbau an, haengt ihn
## direkt unter self und traegt ihn in _screens ein. Der Aufrufer fuellt
## anschliessend das zurueckgegebene VBoxContainer mit eigenem Inhalt.
func _create_screen(id: String) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.visible = false
	add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	panel.custom_minimum_size = Vector2(420, 0)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	_screens[id] = center
	return box


func _show_screen(id: String) -> void:
	for key: String in _screens.keys():
		(_screens[key] as Control).visible = (key == id)
	if id == "stats":
		_refresh_stats_screen()
	elif id == "character":
		_refresh_character_screen()
	elif id == "root":
		_refresh_continue_button()


func _make_title(text: String, size: int = 28) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TITLE_COLOR)
	return label


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 44)
	button.focus_mode = Control.FOCUS_ALL
	return button


# ============================================================================
# Root-Screen
# ============================================================================
func _build_root_screen() -> void:
	var box: VBoxContainer = _create_screen("root")
	box.add_child(_make_title("WHIPLASH"))

	var play_button: Button = _make_button("Play")
	play_button.pressed.connect(func() -> void: _show_screen("play"))
	box.add_child(play_button)

	_continue_button = _make_button("Continue")
	_continue_button.pressed.connect(_on_continue_pressed)
	box.add_child(_continue_button)

	var character_button: Button = _make_button("Character")
	character_button.pressed.connect(func() -> void: _show_screen("character"))
	box.add_child(character_button)

	var stats_button: Button = _make_button("Stats")
	stats_button.pressed.connect(func() -> void: _show_screen("stats"))
	box.add_child(stats_button)

	var settings_button: Button = _make_button("Settings")
	settings_button.pressed.connect(_on_settings_pressed)
	box.add_child(settings_button)

	var quit_button: Button = _make_button("Quit")
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	box.add_child(quit_button)


func _refresh_continue_button() -> void:
	if _continue_button == null:
		return
	_continue_button.disabled = not GameStats.has_live_run


func _on_continue_pressed() -> void:
	if not GameStats.has_live_run:
		return
	continue_requested.emit()


# ============================================================================
# Play-Submenu — Normal / Speedrun
# ============================================================================
func _build_play_screen() -> void:
	var box: VBoxContainer = _create_screen("play")
	box.add_child(_make_title("Play", 22))

	var normal_button: Button = _make_button("Normal")
	normal_button.pressed.connect(func() -> void: _start_run(false))
	box.add_child(normal_button)

	var speedrun_button: Button = _make_button("Speedrun")
	speedrun_button.pressed.connect(func() -> void: _start_run(true))
	box.add_child(speedrun_button)

	var speedrun_hint := Label.new()
	speedrun_hint.text = "Speedrun: eine Etage, Bestenliste nach Zeit."
	speedrun_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speedrun_hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	speedrun_hint.add_theme_font_size_override("font_size", 13)
	box.add_child(speedrun_hint)

	var back_button: Button = _make_button("Back")
	back_button.pressed.connect(func() -> void: _show_screen("root"))
	box.add_child(back_button)


## Startet einen neuen Run. In der PAUSE-OVERLAY-Nutzung (GameStats.has_live_run
## == true) wird der bereits laufende ueber RunRestart verworfen und neu
## aufgebaut — derselbe Weg, den auch der Restart-Button in pause_menu.gd
## nimmt (siehe dortiger Kopfkommentar zu _restart_level: Juice/Items/Loot/
## PartyManager muessen ALLE zurueckgesetzt werden, ein blosses
## change_scene_to_file() wuerde das nicht leisten).
func _start_run(speedrun: bool) -> void:
	Stages.final_stage = SPEEDRUN_FINAL_STAGE if speedrun else NORMAL_FINAL_STAGE

	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if GameStats.has_live_run and RunRestart != null and RunRestart.has_method("restart"):
		RunRestart.restart()
		continue_requested.emit()
		return

	get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH)


# ============================================================================
# Character-Screen
# ============================================================================
func _build_character_screen() -> void:
	var box: VBoxContainer = _create_screen("character")
	box.add_child(_make_title("Character", 22))

	_character_portrait = TextureRect.new()
	_character_portrait.custom_minimum_size = Vector2(160, 160)
	_character_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_character_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_character_portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(_character_portrait)

	var nav_row := HBoxContainer.new()
	nav_row.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_row.add_theme_constant_override("separation", 24)
	box.add_child(nav_row)

	var prev_button: Button = _make_button("<")
	prev_button.custom_minimum_size = Vector2(44, 44)
	prev_button.pressed.connect(func() -> void: _step_character(-1))
	nav_row.add_child(prev_button)

	_character_name_label = _make_title("", 20)
	_character_name_label.custom_minimum_size = Vector2(200, 0)
	nav_row.add_child(_character_name_label)

	var next_button: Button = _make_button(">")
	next_button.custom_minimum_size = Vector2(44, 44)
	next_button.pressed.connect(func() -> void: _step_character(1))
	nav_row.add_child(next_button)

	_character_desc_label = Label.new()
	_character_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_character_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_character_desc_label.custom_minimum_size = Vector2(360, 0)
	box.add_child(_character_desc_label)

	_character_abilities_label = Label.new()
	_character_abilities_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_character_abilities_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_character_abilities_label.add_theme_font_size_override("font_size", 13)
	_character_abilities_label.add_theme_color_override("font_color", ACCENT_COLOR)
	box.add_child(_character_abilities_label)

	var back_button: Button = _make_button("Back")
	back_button.pressed.connect(func() -> void: _show_screen("root"))
	box.add_child(back_button)


func _step_character(delta: int) -> void:
	if _roster.is_empty():
		return
	_character_index = wrapi(_character_index + delta, 0, _roster.size())
	_refresh_character_screen()


func _refresh_character_screen() -> void:
	if _roster.is_empty():
		if _character_name_label != null:
			_character_name_label.text = "Kein Charakter gefunden"
		return

	var data: CharacterData = _roster[_character_index]
	_character_portrait.texture = data.portrait
	_character_name_label.text = data.character_name
	_character_desc_label.text = data.description if data.description != "" else ""
	_character_abilities_label.text = "%s | %s | %s | %s | %s" % [
		data.name_primary, data.name_secondary, data.name_utility,
		data.name_ability_q, data.name_ability_e,
	]


# ============================================================================
# Stats-Screen
# ============================================================================
func _build_stats_screen() -> void:
	var box: VBoxContainer = _create_screen("stats")
	box.add_child(_make_title("Stats", 22))

	_stats_label = Label.new()
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_stats_label.add_theme_constant_override("line_spacing", 6)
	box.add_child(_stats_label)

	var back_button: Button = _make_button("Back")
	back_button.pressed.connect(func() -> void: _show_screen("root"))
	box.add_child(back_button)


func _refresh_stats_screen() -> void:
	if _stats_label == null:
		return
	var discovered: int = GameStats.get_items_discovered_count()
	var total: int = GameStats.get_items_total_count()
	_stats_label.text = (
		"Bosses Killed: %d\n" +
		"Kills: %d\n" +
		"Deaths: %d\n" +
		"Items Discovered: %d / %d\n" +
		"Best Combo: %d\n" +
		"Winstreak: %d\n" +
		"Playtime: %s"
	) % [
		GameStats.bosses_killed, GameStats.kills, GameStats.deaths,
		discovered, total, GameStats.best_combo, GameStats.winstreak,
		GameStats.get_playtime_string(),
	]


# ============================================================================
# Settings — instanziert die bestehende settings_menu.tscn statt eine
# eigene Version zu bauen. Gleiches open()/close()/back_pressed-API wie in
# pause_menu.gd bereits verwendet.
# ============================================================================
func _on_settings_pressed() -> void:
	if _settings_instance == null:
		var scene: PackedScene = load("res://scenes/settings_menu.tscn")
		if scene == null:
			push_warning("MainMenu: settings_menu.tscn nicht gefunden.")
			return
		_settings_instance = scene.instantiate()
		add_child(_settings_instance)
		_settings_instance.back_pressed.connect(_on_settings_back)

	for key: String in _screens.keys():
		(_screens[key] as Control).visible = false
	_settings_instance.open()


func _on_settings_back() -> void:
	if _settings_instance != null:
		_settings_instance.close()
	_show_screen("root")
