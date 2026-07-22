extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var combo_display: Control = $ComboDisplay
@onready var combo_count_label: Label = $ComboDisplay/ComboCount

var player_health: Health
var player_combat: Combat

var _combo_display_home_position: Vector2

func _ready() -> void:
	combo_display.visible = false
	combo_display.modulate.a = 1.0
	_combo_display_home_position = combo_display.position

	visible = SettingsManager.hud_visible
	SettingsManager.hud_visible_changed.connect(_on_hud_visible_changed)

	await get_tree().process_frame
	_find_and_connect_player_health()
	_find_and_connect_player_combat()

func _on_hud_visible_changed(is_visible: bool) -> void:
	visible = is_visible

func _find_and_connect_player_health() -> void:
	var player := get_tree().get_root().find_child("Player", true, false)
	if player == null:
		push_warning("HUD: Konnte keinen Node namens 'Player' finden.")
		return

	var health_node := player.find_child("Health", true, false)
	if health_node == null or not (health_node is Health):
		push_warning("HUD: Player hat keine Health-Komponente (Kind-Node 'Health').")
		return

	player_health = health_node
	player_health.health_changed.connect(_on_health_changed)
	_on_health_changed(player_health.current_health, player_health.max_health)

func _on_health_changed(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current
	health_label.text = "%d / %d" % [current, max_hp]

func _find_and_connect_player_combat() -> void:
	var player := get_tree().get_root().find_child("Player", true, false)
	if player == null:
		return

	var combat_node := player.find_child("Combat", true, false)
	if combat_node == null or not (combat_node is Combat):
		push_warning("HUD: Player hat keine Combat-Komponente (Kind-Node 'Combat').")
		return

	player_combat = combat_node
	player_combat.combo_changed.connect(_on_combo_changed)

func _on_combo_changed(count: int) -> void:
	if count <= 1:
		_play_combo_expire_animation()
		return

	combo_display.position = _combo_display_home_position
	combo_display.modulate.a = 1.0
	combo_display.visible = true
	combo_count_label.text = "x%d" % count

	combo_display.scale = Vector2(1.4, 1.4)
	var tween := create_tween()
	tween.tween_property(combo_display, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _play_combo_expire_animation() -> void:
	if not combo_display.visible:
		return

	var fall_tween := create_tween()
	fall_tween.set_parallel(true)
	fall_tween.tween_property(combo_display, "position:y", combo_display.position.y + 40, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_tween.tween_property(combo_display, "modulate:a", 0.0, 0.5)
	fall_tween.chain().tween_callback(func():
		combo_display.visible = false
		combo_display.position = _combo_display_home_position
		combo_display.modulate.a = 1.0
	)
