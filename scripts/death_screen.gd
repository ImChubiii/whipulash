extends Control
class_name DeathScreen

@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton
@onready var skill_issue_label: Label = $Panel/VBoxContainer/SkillIssueLabel
@onready var killed_by_label: Label = $Panel/VBoxContainer/KilledByLabel
@onready var items_box: Control = $Panel/VBoxContainer/ItemsBox
@onready var items_label: Label = $Panel/VBoxContainer/ItemsBox/ItemsLabel

# Wartezeit nach dem Tod, BEVOR das Spiel pausiert und der Screen erscheint —
# gibt der Ragdoll-Animation Zeit, in Echtzeit abzulaufen. Da die Physik
# danach dank process_mode ALWAYS trotzdem weiterläuft, muss das nicht die
# GESAMTE Animation abdecken — nur der Anfang sollte ungepausred sichtbar sein.
@export var death_screen_delay: float = 1.2

var _health_node: Health

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	await get_tree().process_frame
	_connect_to_player_health()

func _connect_to_player_health() -> void:
	# Gleicher Such-Trick wie beim HUD: findet den Player und seine
	# Health-Komponente automatisch im Szenenbaum.
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
	killed_by_label.text = "Getötet von: %s" % _get_killer_name()
	_update_items_display()

	await get_tree().create_timer(death_screen_delay).timeout
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _get_killer_name() -> String:
	if _health_node == null:
		return "Unbekannt"
	var source := _health_node.last_damage_source
	if source == null or not is_instance_valid(source):
		return "Unbekannt"
	# Falls die Quelle einen "display_name" hat (später mal einbaubar für
	# schönere Gegner-/Hazard-Namen statt technischer Node-Namen):
	if source.has_method("get_display_name"):
		return source.call("get_display_name")
	return source.name

func _update_items_display() -> void:
	# PLATZHALTER: Sobald dein Item-System existiert, hier die tatsächlich
	# gesammelten Items reinschreiben, z.B.:
	#   items_label.text = "\n".join(item_names)
	# Für jetzt: einfacher Platzhalter-Text.
	items_label.text = "Keine Items gesammelt"

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
