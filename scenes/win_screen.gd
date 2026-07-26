extends Control
class_name WinScreen

@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

## Zeit-Label wird zur Laufzeit erzeugt, damit keine der (mehreren)
## Level-Szenen angefasst werden muss, in denen der WinScreen jeweils
## separat instanziiert ist.
var _time_label: Label = null

var _blur_overlay: ColorRect = null
var _pause_menu: PauseMenu = null


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

	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


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
