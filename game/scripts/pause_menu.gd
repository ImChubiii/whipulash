
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

const MINIMAP_GROUP := "minimap"

## Action zum sofortigen Neustart des Levels. Ist in den Steuerungs-
## einstellungen rebindbar (SettingsManager.REBINDABLE_ACTIONS) und wird
## dort bei Bedarf automatisch angelegt (Fallback-Taste: R).
const RESET_ACTION := "reset"

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

@export var settings_menu_path: NodePath
var settings_menu: SettingsMenu

var _blur_overlay: ColorRect = null

## Ueberschrift ueber der Item-Liste.
const ITEM_LIST_TITLE: String = "GESAMMELTE ITEMS"
var _item_list: ItemSummaryList = null

## PHASE 5: Tausch-Widget fuer die beiden aktiven Item-Slots (Q/E).
var _active_swap_panel: ActiveItemSwapPanel = null

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

	# Gruppe statt fester Pfad: ResetOverlay haengt in einem ganz anderen
	# Teil des Baums (eigener Autoload-CanvasLayer, siehe hud_extra.gd) und
	# braucht einen Weg, DIESES PauseMenu zu finden, ohne einen Node-Pfad
	# zu raten. Gleiches Muster wie "level_generator" oder "minimap".
	add_to_group("pause_menu")

	_blur_overlay = _get_or_create_shared_blur()
	_fix_panel_background()

	if settings_menu_path != NodePath(""):
		settings_menu = get_node_or_null(settings_menu_path)

	if settings_menu:
		settings_menu.back_pressed.connect(_on_settings_back)
	else:
		push_warning("PauseMenu: settings_menu_path ist nicht gesetzt — Settings-Button bleibt ohne Funktion.")

	# Der Button heisst im Editor noch "Quit" (siehe .tscn) - er fuehrt jetzt
	# aber zum Hauptmenue statt die Anwendung zu beenden (siehe
	# _on_quit_pressed). Laufzeit-Override statt .tscn-Aenderung, gleiches
	# Prinzip wie bei den prozedural ergaenzten Controls in dieser Datei.
	quit_button.text = "Main Menu"

	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_build_active_swap_panel()
	_build_item_list()
	_build_admin_panel()


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


## Oeffentliche Sammel-Abfrage fuer reset_overlay.gd: darf ein Reset gerade
## VORGENOMMEN werden? Buendelt beide Sperren an EINER Stelle, damit sie
## nicht an zwei Orten im Code auseinanderlaufen koennen.
func is_reset_blocked() -> bool:
	return _locked_out or _is_endscreen_active()


func _is_endscreen_active() -> bool:
	var parent := get_parent()

	var death_screen := parent.get_node_or_null("DeathScreen") as Control
	if death_screen != null and is_instance_valid(death_screen) and death_screen.visible:
		return true

	var win_screen := parent.get_node_or_null("WinScreen") as Control
	if win_screen != null and is_instance_valid(win_screen) and win_screen.visible:
		return true

	return false


# Prueft, ob irgendeine Minimap gerade ihre Grosskarte offen hat. Mehrere
# Minimap-Instanzen sollten im Level nie gleichzeitig existieren, aber
# get_nodes_in_group() ist billig genug, um das nicht vorauszusetzen.
func _close_open_big_map() -> bool:
	var minimaps: Array[Node] = get_tree().get_nodes_in_group(MINIMAP_GROUP)
	for m in minimaps:
		if not is_instance_valid(m):
			continue
		if m.has_method("is_big_map_open") and m.is_big_map_open():
			m.close_big_map()
			return true
	return false


# ============================================================================
# WARUM ES HIER KEINEN "R"-HANDLER MEHR GIBT (behobener Bug)
# ============================================================================
# Bis vor Kurzem stand hier ein ZWEITER, unabhaengiger Reset-Pfad: ein
# einzelner Tastendruck auf R fuehrte SOFORT zu reload_current_scene() —
# parallel zu reset_overlay.gd, das dieselbe Taste per Input.is_action_pressed()
# ABFRAGT (Polling, nicht Event-basiert) und daraus die 1,5-Sekunden-
# Halten-Animation baut.
#
# get_viewport().set_input_as_handled() hier hat auf das Polling in
# reset_overlay.gd KEINERLEI Wirkung — "handled" gilt nur fuer die
# Input-Event-Pipeline (_unhandled_input), nicht fuer Input.is_action_pressed().
# Das Ergebnis bei jedem R-Druck:
#   1. DIESES Script startete den Neustart SOFORT, ohne jede Bestaetigung —
#      die ganze "gedrueckt halten" Absicherung war dadurch wirkungslos.
#   2. Falls R laenger als 1,5 s gehalten wurde, loeste ZUSAETZLICH
#      reset_overlay.gd einen ZWEITEN reload_current_scene() aus — auf
#      einer Szene, die durch den ersten Reload gerade schon abgebaut
#      wurde. Zwei Szenenwechsel im selben kurzen Zeitfenster sind genau
#      die Art von Zustand, die zu Abstuerzen (das Spiel schliesst sich
#      kommentarlos) und zu "Cannot call method ... on a null value"
#      fuehrt, wenn ein Node nach dem ersten Reload auf sich selbst
#      zugreift.
#
# reset_overlay.gd ist jetzt der EINZIGE Besitzer der "reset"-Action. Die
# Sperre waehrend Tod/Sieg (_locked_out / _is_endscreen_active()), die
# fruehen hier stand, ist NICHT verlorengegangen — sie wurde nach
# is_reset_blocked() verschoben, das reset_overlay.gd jetzt selbst abfragt
# (siehe dort). Der Restart-BUTTON unten (_on_restart_pressed) bleibt
# unveraendert; ein Klick ist kein Polling-Konflikt.

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

	# WICHTIG: erster ESC-Druck bei offener Grosskarte schliesst NUR die
	# Karte - die Pause darf sich dabei nicht gleichzeitig oeffnen. Erst
	# der NAECHSTE ESC-Druck (Karte bereits zu) macht Pause auf/zu.
	if _close_open_big_map():
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
	_restart_level()


## Gemeinsamer Pfad fuer Restart-Button UND Reset-Taste — so kann es keine
## zwei leicht unterschiedlichen Neustart-Wege geben.
##
## AENDERUNG: der eigentliche Neustart liegt jetzt in RunRestart (Autoload).
## Vorher stand hier ein direkter reload_current_scene() — und damit ein
## Neustart, der WENIGER aufgeraeumt hat als der ueber [R]:
##
##   * Juice.cancel() fehlte  -> ein laufender Hit-Stop nahm
##     Engine.time_scale ~0.05 in den neuen Run mit; der Timer, der ihn
##     zurueckgesetzt haette, verschwand mit der alten Szene.
##   * Items.reset_run() / Loot.reset_run() fehlten -> der neue Run
##     startete mit dem Inventar des alten.
##   * PartyManager.notify_scene_reset() fehlte — und DAS war der Grund,
##     warum der Button sich anfuehlte, als tue er nichts: PartyManager
##     hielt nach dem Reload einen Zeiger auf die tote Spieler-Instanz,
##     hielt sich fuer "schon bespielt" und spawnte keinen neuen
##     Charakter. Ausfuehrlich in party_manager.gd und run_restart.gd.
func _restart_level() -> void:
	if _blur_overlay:
		_blur_overlay.visible = false

	var restarter: Node = get_node_or_null("/root/RunRestart")
	if restarter and restarter.has_method("restart"):
		restarter.restart()
		return

	push_warning("PauseMenu: Autoload 'RunRestart' nicht gefunden - Notfall-Neustart ohne Aufraeumen.")
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()


## Quit fuehrt NICHT mehr direkt aus der Anwendung — stattdessen zurueck zum
## Hauptmenue (main_menu.gd), von dort aus quittet ein eigener Quit-Button
## die Anwendung wirklich. Der laufende Run gilt damit als verlassen
## (GameStats.has_live_run = false): es gibt in diesem Projekt keine
## Serialisierung des prozeduralen Dungeons, "Fortsetzen" im Hauptmenue ist
## also folgerichtig deaktiviert, nachdem man ihn hier verlassen hat — siehe
## main_menu.gd Kopfkommentar.
func _on_quit_pressed() -> void:
	if _blur_overlay:
		_blur_overlay.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameStats.has_live_run = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# ============================================================================
# Item-Uebersicht
# ============================================================================
# Wird zur Laufzeit gebaut, damit keine der Szenen angefasst werden muss, in
# denen dieser Screen instanziiert ist — dieselbe Begruendung wie beim
# Zeit-Label und beim Leaderboard-Block.
func _build_item_list() -> void:
	if _item_list != null and is_instance_valid(_item_list):
		return
	var column: VBoxContainer = get_node_or_null("Panel/VBoxContainer")
	if column == null:
		push_warning("%s: 'Panel/VBoxContainer' nicht gefunden — Item-Liste faellt aus." % name)
		return

	_item_list = ItemSummaryList.create(ITEM_LIST_TITLE)
	column.add_child(_item_list)
	# Vor den ersten Button schieben: die Liste ist Information, die Buttons
	# sind die Handlung. Umgekehrt muesste man an den Buttons vorbeilesen.
	column.move_child(_item_list, _first_button_index(column))


## PHASE 5: baut das Q/E-Tausch-Widget und haengt es VOR die Item-Liste
## (also noch ueber ihr) - welche zwei Items gerade auf welcher Taste
## liegen, ist waehrend eines Kampf-Runs wichtiger als die komplette
## Sammel-Uebersicht darunter.
func _build_active_swap_panel() -> void:
	if _active_swap_panel != null and is_instance_valid(_active_swap_panel):
		return
	var column: VBoxContainer = get_node_or_null("Panel/VBoxContainer")
	if column == null:
		push_warning("%s: 'Panel/VBoxContainer' nicht gefunden — Aktive-Item-Tausch faellt aus." % name)
		return

	_active_swap_panel = ActiveItemSwapPanel.create()
	column.add_child(_active_swap_panel)
	column.move_child(_active_swap_panel, _first_button_index(column))


## Index des ersten Buttons in der Spalte. Ueber den Typ gesucht statt ueber
## einen festen Index, weil die drei Screens unterschiedlich viele Labels
## ueber den Buttons haben.
func _first_button_index(column: VBoxContainer) -> int:
	for i: int in range(column.get_child_count()):
		if column.get_child(i) is Button:
			return i
	return column.get_child_count()


# ============================================================================
# ADMIN-Panel — Teleportation zu Debug-Räumen (ersetzt die physischen Pads)
# ============================================================================
func _build_admin_panel() -> void:
	var column: VBoxContainer = get_node_or_null("Panel/VBoxContainer")
	if column == null:
		return

	# Trennlinie
	var sep := HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 8)
	column.add_child(sep)

	# Überschrift
	var title := Label.new()
	title.text = "— ADMIN —"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 13)
	title.modulate = Color(0.6, 0.85, 1.0, 0.8)
	column.add_child(title)

	var row1 := HBoxContainer.new()
	row1.alignment = BoxContainer.ALIGNMENT_CENTER
	row1.add_theme_constant_override("separation", 6)
	column.add_child(row1)

	# Zurück zum Start
	var back_btn := _make_admin_btn("← Start")
	back_btn.pressed.connect(_admin_teleport_to_start)
	row1.add_child(back_btn)

	# Tresorraum
	var treasure_btn := _make_admin_btn("Tresor")
	treasure_btn.pressed.connect(func() -> void: _admin_teleport_to_room_type(RoomData.RoomType.TREASURE))
	row1.add_child(treasure_btn)

	# Bossraum
	var boss_btn := _make_admin_btn("Boss")
	boss_btn.pressed.connect(func() -> void: _admin_teleport_to_room_type(RoomData.RoomType.BOSS))
	row1.add_child(boss_btn)

	var row2 := HBoxContainer.new()
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	row2.add_theme_constant_override("separation", 6)
	column.add_child(row2)

	# Item-Testraum
	var item_btn := _make_admin_btn("Items")
	item_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: ItemTestRoom.teleport_player_in()))
	row2.add_child(item_btn)

	# Sandbox
	var sandbox_btn := _make_admin_btn("Sandbox")
	sandbox_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: EnemySandboxRoom.teleport_player_in()))
	row2.add_child(sandbox_btn)

	# Hub
	var hub_btn := _make_admin_btn("Hub")
	hub_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: HubRoom.teleport_player_in()))
	row2.add_child(hub_btn)

	# VFX-Test
	var vfx_btn := _make_admin_btn("VFX")
	vfx_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: VfxTestRoom.teleport_player_in()))
	row2.add_child(vfx_btn)


func _make_admin_btn(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(60, 28)
	btn.add_theme_font_size_override("font_size", 12)
	return btn


## Teleportiert den Spieler zum Startraum zurück (erster START-Raum im Layout).
func _admin_teleport_to_start() -> void:
	_admin_teleport_to_room_type(RoomData.RoomType.START)


## Sucht den ersten Raum des gegebenen Typs im aktuellen Layout und
## teleportiert den aktiven Spieler dorthin. Schliesst danach das Pause-Menue.
func _admin_teleport_to_room_type(room_type: int) -> void:
	_teardown_tutorial_ui_if_present()
	var gen: LevelGenerator = _find_level_generator()
	if gen == null:
		return
	var target_room: RoomInstance = null
	for grid_pos in gen._instances.keys():
		var room: RoomInstance = gen._instances[grid_pos]
		if room == null or not is_instance_valid(room):
			continue
		var cell = gen._current_layout.get(grid_pos)
		if cell != null and int(cell.get("room_type", -1)) == room_type:
			target_room = room
			break
	if target_room == null:
		push_warning("ADMIN: Kein Raum vom Typ %d gefunden." % room_type)
		return
	_admin_move_player_to_room(target_room)


## Ruft einen Pocket-Dimension-Teleport-Callable auf und schliesst das Pause-Menue.
func _admin_pocket(tp: Callable) -> void:
	_teardown_tutorial_ui_if_present()
	_resume()
	await get_tree().process_frame
	tp.call()


## Rueckmeldung "Dash/Bomben+Charakter-Beschreibung soll NUR im Tutorial
## vorkommen, auch beim Admin-Teleport aus dem Tutorial raus (VFX/Sandbox/
## Hub/Items/Boss/Tresor/Start)" (2026-08-13): level_generator.gd raeumt die
## Tutorial-UI zwar schon bei jedem regulaeren Etagenwechsel weg (siehe
## dortiges _teardown_tutorial_ui()), aber die Admin-Teleports hier springen
## NIE ueber generate_stage()/generate_new_stage() - sie verschieben den
## Spieler nur innerhalb desselben Layouts (Raum-Typ-Teleport) oder haengen
## eine Pocket-Dimension zusaetzlich in dieselbe Szene (siehe
## vfx_test_room.gd::teleport_player_in() - kein change_scene_to_file()).
## Ohne diesen Aufruf ueberlebt die Tutorial-UI also jeden Admin-Teleport.
func _teardown_tutorial_ui_if_present() -> void:
	var gen: LevelGenerator = _find_level_generator()
	if gen != null and gen.has_method("_teardown_tutorial_ui"):
		gen._teardown_tutorial_ui()


func _admin_move_player_to_room(room: RoomInstance) -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return
	player.global_position = room.global_position + Vector3(0, 2.0, 0)
	player.velocity = Vector3.ZERO
	_resume()


func _find_level_generator() -> LevelGenerator:
	var nodes: Array[Node] = get_tree().get_nodes_in_group("level_generator")
	if nodes.is_empty():
		return null
	return nodes[0] as LevelGenerator


func _find_player() -> CharacterBody3D:
	if PartyManager.has_player():
		return PartyManager.player
	return null
