
extends Control
class_name DeathScreen

@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton
@onready var skill_issue_label: Label = $Panel/VBoxContainer/SkillIssueLabel
@onready var killed_by_label: Label = $Panel/VBoxContainer/KilledByLabel
@onready var items_box: Control = $Panel/VBoxContainer/ItemsBox
@onready var items_label: Label = $Panel/VBoxContainer/ItemsBox/ItemsLabel

@export var death_screen_delay: float = 1.2

var _health_node: Health
var _blur_overlay: ColorRect = null
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

	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	await get_tree().process_frame
	_connect_to_player_health()


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


func _connect_to_player_health() -> void:
	var player := get_tree().get_root().find_child("Player", true, false)
	if player == null:
		push_warning("DeathScreen: Konnte keinen Node namens 'Player' finden.")
		return

	var health_node := player.find_child("Health", true, false)
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

	killed_by_label.text = "Getötet von: %s" % _get_killer_name()
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


func _update_items_display() -> void:
	# PLATZHALTER: Sobald dein Item-System existiert, hier die tatsächlich
	# gesammelten Items reinschreiben, z.B.:
	#   items_label.text = "\n".join(item_names)
	items_label.text = "Keine Items gesammelt"


func _on_restart_pressed() -> void:
	if _blur_overlay:
		_blur_overlay.visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
