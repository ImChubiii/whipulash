extends Control
class_name WinScreen

@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

## Zeit-Label wird zur Laufzeit erzeugt, damit keine der (mehreren)
## Level-Szenen angefasst werden muss, in denen der WinScreen jeweils
## separat instanziiert ist.
var _time_label: Label = null

var _blur_overlay: ColorRect = null

## Ueberschrift ueber der Item-Liste.
const ITEM_LIST_TITLE: String = "DIESER RUN"
var _item_list: ItemSummaryList = null
var _pause_menu: PauseMenu = null

## Leaderboard-Block wird - wie das Zeit-Label - zur Laufzeit gebaut,
## damit keine der Level-Szenen angefasst werden muss.
var _seed_label: Label = null
var _board_title: Label = null
var _board_list: VBoxContainer = null
var _own_record: RunRecord = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	# Muss ueber dem HUD liegen, unabhaengig davon wie die Level-Szene die
	# Nodes im Baum anordnet (siehe pause_menu.gd fuer die ausfuehrliche
	# Begruendung — gleiche Konstante wie PauseMenu/DeathScreen).
	z_index = PauseMenu.Z_INDEX_MENU

	# BlurOverlay wurde von pause_menu.gd bereits im Parent erstellt
	_blur_overlay = get_parent().get_node_or_null("BlurOverlay") as ColorRect
	_pause_menu = get_parent().get_node_or_null("PauseMenu") as PauseMenu
	_fix_panel_background()

	_build_time_label()	
	_build_leaderboard_block()

	LeaderboardManager.submit_finished.connect(_on_submit_finished)
	LeaderboardManager.entries_ready.connect(_on_entries_ready)
	LeaderboardManager.unavailable.connect(_on_leaderboard_unavailable)

	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_build_item_list()


## Setzt das Zeit-Label direkt unter die Ueberschrift (Index 1), damit es
## ueber den Buttons steht.
func _build_time_label() -> void:
	var box := get_node_or_null("Panel/VBoxContainer") as VBoxContainer
	if box == null:
		return
	_time_label = Label.new()
	_time_label.name = "RunTimeLabel"
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_label.add_theme_font_size_override("font_size", 32)
	_time_label.text = ""
	box.add_child(_time_label)
	box.move_child(_time_label, 1)


## Seed-Zeile + Ueberschrift + Liste. Die Liste bleibt leer, bis Steam
## antwortet - ein Platzhalter verhindert, dass der Block beim Aufpoppen
## in der Hoehe springt.
func _build_leaderboard_block() -> void:
	var box := get_node_or_null("Panel/VBoxContainer") as VBoxContainer
	if box == null:
		return

	_seed_label = Label.new()
	_seed_label.name = "SeedLabel"
	_seed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_seed_label.add_theme_font_size_override("font_size", 18)
	_seed_label.modulate = Color(0.72, 0.72, 0.78)
	_seed_label.text = ""
	box.add_child(_seed_label)
	box.move_child(_seed_label, 2)

	_board_title = Label.new()
	_board_title.name = "BoardTitle"
	_board_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_board_title.add_theme_font_size_override("font_size", 20)
	_board_title.text = ""
	box.add_child(_board_title)
	box.move_child(_board_title, 3)

	_board_list = VBoxContainer.new()
	_board_list.name = "BoardList"
	_board_list.add_theme_constant_override("separation", 2)
	box.add_child(_board_list)
	box.move_child(_board_list, 4)


## Sammelt alles, was den Run beschreibt. Der LevelGenerator wird ueber
## seine Gruppe gesucht, nicht ueber einen festen Pfad - der WinScreen
## kennt den Aufbau der Level-Szene nicht.
func _build_own_record() -> RunRecord:
	var time_ms: int = 0
	for node in get_tree().get_nodes_in_group(RunTimer.RUN_TIMER_GROUP):
		if node is RunTimer:
			time_ms = (node as RunTimer).get_elapsed_ms()
			break

	var run_seed: int = 0
	var stage: int = 1
	var rooms_cleared: int = 0

	var generators: Array[Node] = get_tree().get_nodes_in_group(LevelGenerator.GENERATOR_GROUP)
	if not generators.is_empty() and generators[0] is LevelGenerator:
		var gen: LevelGenerator = generators[0] as LevelGenerator
		run_seed = gen.get_run_seed()
		stage = gen.get_current_stage()
		for cell in gen.get_map_cells().values():
			if bool(cell.get("cleared", false)):
				rooms_cleared += 1

	var character: int = PartyManager.get_active_index()

	return RunRecord.create(time_ms, run_seed, character, stage, rooms_cleared)


func _on_submit_finished(success: bool, is_new_best: bool) -> void:
	if _board_title == null:
		return
	if not success:
		_board_title.text = "BESTENLISTE - UPLOAD FEHLGESCHLAGEN"
		return
	_board_title.text = "NEUE BESTZEIT - BESTENLISTE" if is_new_best else "BESTENLISTE"


func _on_leaderboard_unavailable(reason: String) -> void:
	if _board_title:
		_board_title.text = "BESTENLISTE OFFLINE"
	if _board_list:
		_clear_board_list()
		var info := Label.new()
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		info.add_theme_font_size_override("font_size", 14)
		info.modulate = Color(0.6, 0.6, 0.65)
		info.text = reason
		_board_list.add_child(info)


func _on_entries_ready(records: Array, _scope: String) -> void:
	if _board_list == null:
		return
	_clear_board_list()

	var own_id: int = SteamManager.get_steam_id()
	for record in records:
		var rec: RunRecord = record as RunRecord
		if rec == null:
			continue

		var row := Label.new()
		row.add_theme_font_size_override("font_size", 16)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		# Eintraege aus aelteren Builds werden markiert statt versteckt -
		# sonst wirkt das Brett nach jedem Patch kaputt.
		var suffix: String = "" if rec.is_current_build() else "  (alter Build)"
		row.text = "%2d.  %-10s  Seed %s%s" % [
			rec.global_rank, rec.get_time_string(), rec.get_seed_code(), suffix
		]

		if rec.steam_id == own_id and own_id != 0:
			row.modulate = Color(1.0, 0.82, 0.22)
		elif not rec.is_current_build():
			row.modulate = Color(0.55, 0.55, 0.6)

		_board_list.add_child(row)


func _clear_board_list() -> void:
	if _board_list == null:
		return
	for child in _board_list.get_children():
		child.queue_free()


## Stoppt den Speedrun-Timer und liefert die Endzeit. Ueber die Gruppe
## statt ueber einen festen Pfad — der WinScreen kennt den HUD-Aufbau nicht.
func _stop_and_read_run_timer() -> String:
	for node in get_tree().get_nodes_in_group(RunTimer.RUN_TIMER_GROUP):
		if node is RunTimer:
			var timer: RunTimer = node
			timer.stop()
			return timer.get_time_string()
	return ""


# Gleiches Fix wie PauseMenu / DeathScreen: Panel Full-Rect opak → Blur unsichtbar
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


func show_win() -> void:
	if visible:
		return  # Nicht doppelt auslösen

	# SOFORT sperren, bevor die Buttons ueberhaupt sichtbar sind — ab jetzt
	# ist das Level gewonnen, ESC/Pause soll nicht mehr moeglich sein.
	if _pause_menu:
		_pause_menu.lock_out()

	var run_time: String = _stop_and_read_run_timer()
	if _time_label:
		_time_label.text = ("ZEIT: %s" % run_time) if run_time != "" else ""

	# Reihenfolge ist wichtig: erst den Timer stoppen, DANN den Record
	# bauen - sonst laeuft die Zeit waehrend des Uploads weiter.
	_own_record = _build_own_record()
	if _seed_label:
		_seed_label.text = "SEED: %s" % _own_record.get_seed_code()

	if _board_title:
		_board_title.text = "BESTENLISTE"
	LeaderboardManager.submit_run(_own_record)
	LeaderboardManager.request_top()

	if _blur_overlay:
		_blur_overlay.visible = true
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_restart_pressed() -> void:
	if _blur_overlay:
		_blur_overlay.visible = false
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
