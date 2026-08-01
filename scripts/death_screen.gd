
extends Control
class_name DeathScreen

@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton
@onready var skill_issue_label: Label = $Panel/VBoxContainer/SkillIssueLabel
@onready var killed_by_label: Label = $Panel/VBoxContainer/KilledByLabel
@onready var items_box: Control = $Panel/VBoxContainer/ItemsBox
@onready var items_label: Label = $Panel/VBoxContainer/ItemsBox/ItemsLabel

@export var death_screen_delay: float = 1.2

## --- Layout-Korrektur -------------------------------------------------
## Die VBoxContainer-Geometrie kommt aus den Level-.tscn (in level_02.tscn
## z.B. offset_top = -211 / offset_bottom = 241 bei zwei 100px hohen
## Buttons) — der Inhalt lief dadurch unten aus dem Panel heraus und die
## Buttons standen viel zu tief.
##
## Statt die Geometrie in JEDER Level-Szene einzeln nachzuziehen (der
## DeathScreen ist in level_01/02/test/... jeweils separat instanziiert),
## wird das Layout hier EINMAL zentral im Code korrigiert. Damit ist es
## automatisch in allen Levels konsistent.
@export var fix_layout_in_code: bool = true
@export var content_top_offset: float = -260.0
@export var content_width: float = 640.0
@export var button_size: Vector2 = Vector2(240.0, 56.0)
@export var content_separation: int = 14

var _health_node: Health
var _blur_overlay: ColorRect = null

## Ueberschrift ueber der Item-Liste.
const ITEM_LIST_TITLE: String = "DIESER RUN"
var _item_list: ItemSummaryList = null
var _pause_menu: PauseMenu = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	# Muss ueber dem HUD liegen, unabhaengig davon wie die Level-Szene die
	# Nodes im Baum anordnet (siehe pause_menu.gd fuer die ausfuehrliche
	# Begruendung — gleiche Konstante wie PauseMenu/WinScreen).
	z_index = PauseMenu.Z_INDEX_MENU

	# BlurOverlay wurde von pause_menu.gd bereits im Parent erstellt
	_blur_overlay = get_parent().get_node_or_null("BlurOverlay") as ColorRect
	_pause_menu = get_parent().get_node_or_null("PauseMenu") as PauseMenu
	_fix_panel_background()
	if fix_layout_in_code:
		_fix_content_layout()

	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_build_item_list()

	if not PartyManager.active_player_changed.is_connected(_on_active_player_changed):
		PartyManager.active_player_changed.connect(_on_active_player_changed)

	if PartyManager.player and is_instance_valid(PartyManager.player):
		_on_active_player_changed(PartyManager.player)
	else:
		await get_tree().process_frame
		if PartyManager.player and is_instance_valid(PartyManager.player):
			_on_active_player_changed(PartyManager.player)


# Gleiches Fix wie im PauseMenu: Panel ist Full-Rect mit opakem Hintergrund
# und würde den Blur dahinter vollständig verdecken.
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


## Zieht den kompletten Inhalt nach oben und gibt den Buttons eine
## vernuenftige Groesse. Der VBoxContainer wird zentriert verankert und
## bekommt eine feste Hoehe, die zum Inhalt passt — vorher war er so
## dimensioniert, dass die 2x100px-Buttons unter den Bildschirmrand
## rutschten.
func _fix_content_layout() -> void:
	var box := get_node_or_null("Panel/VBoxContainer") as VBoxContainer
	if box == null:
		push_warning("DeathScreen: 'Panel/VBoxContainer' nicht gefunden - Layout-Korrektur uebersprungen.")
		return

	# Anker manuell setzen statt ueber set_anchors_preset() — der Preset
	# wuerde die Offsets mit umrechnen und das Ergebnis waere von der
	# vorherigen (kaputten) Geometrie aus der .tscn abhaengig.
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -content_width * 0.5
	box.offset_right = content_width * 0.5
	box.offset_top = content_top_offset
	# Hoehe wird vom Inhalt bestimmt (Buttons + Labels), deshalb bewusst
	# grosszuegig — der Container waechst nicht ueber seinen Inhalt hinaus.
	box.offset_bottom = content_top_offset + 420.0
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.alignment = BoxContainer.ALIGNMENT_BEGIN
	box.add_theme_constant_override("separation", content_separation)

	# Fuehrende Leerzeichen im Titel raus (waren im .tscn als manuelle
	# "Zentrierung" hart eingetippt) und stattdessen echte Zentrierung.
	if skill_issue_label:
		skill_issue_label.text = skill_issue_label.text.strip_edges()
		skill_issue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		skill_issue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if killed_by_label:
		killed_by_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		killed_by_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if items_label:
		items_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	for btn in [restart_button, quit_button]:
		if btn == null or not (btn is Button):
			continue
		btn.custom_minimum_size = button_size
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


## Holt die Endzeit vom Speedrun-Timer und stoppt ihn. Nutzt die Gruppe
## statt eines festen Pfades, damit der DeathScreen nichts ueber den
## HUD-Aufbau wissen muss.
func _stop_and_read_run_timer() -> String:
	for node in get_tree().get_nodes_in_group(RunTimer.RUN_TIMER_GROUP):
		if node is RunTimer:
			var timer: RunTimer = node
			timer.stop()
			return timer.get_time_string()
	return ""


# Wird bei JEDEM Charakterwechsel gefeuert (siehe PartyManager) — der alte
# Player-Node samt seiner Health-Komponente wird komplett entfernt, also
# muss auch died-Verbindung jedes Mal neu aufgebaut werden. Ohne das würde
# der DeathScreen nach dem ersten Charakterwechsel nie wieder auslösen.
func _on_active_player_changed(new_player: CharacterBody3D) -> void:
	if _health_node and is_instance_valid(_health_node) and _health_node.died.is_connected(_on_player_died):
		_health_node.died.disconnect(_on_player_died)
	_health_node = null

	if new_player == null or not is_instance_valid(new_player):
		push_warning("DeathScreen: Kein gueltiger Player vorhanden.")
		return

	var health_node := new_player.find_child("Health", true, false)
	if health_node == null or not (health_node is Health):
		push_warning("DeathScreen: Player hat keine Health-Komponente.")
		return

	_health_node = health_node
	_health_node.died.connect(_on_player_died)


func _on_player_died() -> void:
	# SOFORT sperren — der Spieler ist ab genau JETZT tot, nicht erst wenn
	# der Screen nach death_screen_delay sichtbar wird. Ohne das könnte man
	# waehrend der Verzoegerung noch ESC druecken und die Pause oeffnen.
	if _pause_menu:
		_pause_menu.lock_out()

	var run_time: String = _stop_and_read_run_timer()
	killed_by_label.text = "Getötet von: %s" % _get_killer_name()
	if run_time != "":
		killed_by_label.text += "     |     Zeit: %s" % run_time
	_update_items_display()

	await get_tree().create_timer(death_screen_delay).timeout

	if _blur_overlay:
		_blur_overlay.visible = true
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _get_killer_name() -> String:
	if _health_node == null:
		return "Unbekannt"
	var source := _health_node.last_damage_source
	if source == null or not is_instance_valid(source):
		return "Unbekannt"
	if source.has_method("get_display_name"):
		return source.call("get_display_name")
	return source.name


## Die alte Fassung schrieb hier fest "Keine Items gesammelt" hinein — ein
## Platzhalter aus der Zeit vor dem Item-System, der nie ersetzt wurde. Genau
## deshalb sah die Auflistung nach jedem Run gleich aus, egal was man
## eingesammelt hatte.
##
## Die eigentliche Liste baut jetzt ItemSummaryList. Das alte Label wird nur
## noch versteckt statt geloescht, damit die Szenendatei unveraendert bleibt.
func _update_items_display() -> void:
	if items_label:
		items_label.visible = false
	if items_box:
		items_box.visible = false
	if _item_list and is_instance_valid(_item_list):
		_item_list.refresh()


## Laeuft ueber RunRestart (Autoload) statt direkt ueber
## reload_current_scene(). Begruendung ausfuehrlich in run_restart.gd und
## party_manager.gd: der direkte Weg liess PartyManager mit einem Zeiger
## auf die tote Spieler-Instanz zurueck, wodurch im neuen Level nie wieder
## ein Charakter gespawnt wurde. Der Button hat also durchaus etwas getan -
## nur eben ein Level ohne Spieler erzeugt.
func _on_restart_pressed() -> void:
	if _blur_overlay:
		_blur_overlay.visible = false

	var restarter: Node = get_node_or_null("/root/RunRestart")
	if restarter and restarter.has_method("restart"):
		restarter.restart()
		return

	push_warning("DeathScreen: Autoload 'RunRestart' nicht gefunden - Notfall-Neustart ohne Aufraeumen.")
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()


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


## Index des ersten Buttons in der Spalte. Ueber den Typ gesucht statt ueber
## einen festen Index, weil die drei Screens unterschiedlich viele Labels
## ueber den Buttons haben.
func _first_button_index(column: VBoxContainer) -> int:
	for i: int in range(column.get_child_count()):
		if column.get_child(i) is Button:
			return i
	return column.get_child_count()
