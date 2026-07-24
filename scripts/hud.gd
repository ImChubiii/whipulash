
extends Control

# Zentrales HUD:
#  - rechts: 4 Party-Slots (Portrait + HP, aktiver Char groesser + mit Name)
#  - rechts unten: 5 Ability-Icons (Primary, Secondary, Shift, Q, E)
#  - oben links: Minimap mit Zonenname darueber und X/Y-Koordinaten darunter
#  - Mitte: Combo-Anzeige (bestehende Logik, unveraendert)

@onready var combo_display: Control = $ComboDisplay
@onready var combo_count_label: Label = $ComboDisplay/ComboCount
@onready var party_container: VBoxContainer = $RightPanel/PartyContainer
@onready var ability_container: HBoxContainer = $AbilityBar/AbilityContainer
@onready var minimap: Control = $Minimap

const SLOT_COUNT: int = 5

var player_health: Health
var player_combat: Combat
var player: CharacterBody3D

var _party_slots: Array[PartySlot] = []
var _ability_slots: Array[AbilitySlot] = []
var _combo_display_home_position: Vector2

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	combo_display.visible = false
	combo_display.modulate.a = 1.0
	_combo_display_home_position = combo_display.position

	visible = SettingsManager.hud_visible
	SettingsManager.hud_visible_changed.connect(_on_hud_visible_changed)

	_cache_slots()

	await get_tree().process_frame

	_find_player()
	_find_and_connect_player_health()
	_find_and_connect_player_combat()
	_connect_party_manager()
	_refresh_party()
	_refresh_ability_icons()

	if minimap and player:
		minimap.set_player(player)

func _cache_slots() -> void:
	_party_slots.clear()
	for child: Node in party_container.get_children():
		if child is PartySlot:
			_party_slots.append(child)

	_ability_slots.clear()
	for child: Node in ability_container.get_children():
		if child is AbilitySlot:
			_ability_slots.append(child)

func _on_hud_visible_changed(is_visible: bool) -> void:
	visible = is_visible

func _find_player() -> void:
	var found := get_tree().get_root().find_child("Player", true, false)
	if found and found is CharacterBody3D:
		player = found
		PartyManager.register_player(player)
	else:
		push_warning("HUD: Konnte keinen Node namens 'Player' finden.")

func _find_and_connect_player_health() -> void:
	if player == null:
		return

	var health_node := player.find_child("Health", true, false)
	if health_node == null or not (health_node is Health):
		push_warning("HUD: Player hat keine Health-Komponente (Kind-Node 'Health').")
		return

	player_health = health_node
	player_health.health_changed.connect(_on_health_changed)
	_on_health_changed(player_health.current_health, player_health.max_health)

func _on_health_changed(current: float, max_hp: float) -> void:
	var idx: int = PartyManager.get_active_index()
	if idx >= 0 and idx < _party_slots.size():
		_party_slots[idx].update_health(current, max_hp)

func _find_and_connect_player_combat() -> void:
	if player == null:
		return

	var combat_node := player.find_child("Combat", true, false)
	if combat_node == null or not (combat_node is Combat):
		push_warning("HUD: Player hat keine Combat-Komponente (Kind-Node 'Combat').")
		return

	player_combat = combat_node
	player_combat.combo_changed.connect(_on_combo_changed)

func _connect_party_manager() -> void:
	if not PartyManager.active_character_changed.is_connected(_on_active_character_changed):
		PartyManager.active_character_changed.connect(_on_active_character_changed)
	if not PartyManager.member_health_changed.is_connected(_on_member_health_changed):
		PartyManager.member_health_changed.connect(_on_member_health_changed)
	if not PartyManager.party_changed.is_connected(_refresh_party):
		PartyManager.party_changed.connect(_refresh_party)

func _refresh_party() -> void:
	var active: int = PartyManager.get_active_index()

	for i: int in range(_party_slots.size()):
		var slot: PartySlot = _party_slots[i]
		var set: AbilitySet = PartyManager.get_set(i)
		slot.setup(i, set)

		if set == null:
			continue

		slot.update_health(
			PartyManager.get_member_health(i),
			PartyManager.get_member_max_health(i)
		)
		slot.set_active(i == active)

	_reorder_party_container(active)

func _on_member_health_changed(index: int, current: float, max_hp: float) -> void:
	if index >= 0 and index < _party_slots.size():
		_party_slots[index].update_health(current, max_hp)

func _on_active_character_changed(index: int) -> void:
	for i: int in range(_party_slots.size()):
		_party_slots[i].set_active(i == index)
	_reorder_party_container(index)
	_refresh_ability_icons()

# Der aktuell ausgewaehlte Charakter soll UNTEN in der Liste stehen statt
# oben. _party_slots bleibt dabei per PartyManager-Index fest zugeordnet
# (Health-Updates etc. adressieren weiterhin ueber den Index) — nur die
# VISUELLE Reihenfolge im VBoxContainer wird angepasst: der aktive Slot
# wandert an die letzte Position, alle anderen behalten ihre relative
# Reihenfolge zueinander.
func _reorder_party_container(active_index: int) -> void:
	if active_index < 0 or active_index >= _party_slots.size():
		return

	var active_slot: PartySlot = _party_slots[active_index]
	if not is_instance_valid(active_slot):
		return

	party_container.move_child(active_slot, party_container.get_child_count() - 1)

# Laedt die Icons des aktuell aktiven Charakters in die 5 Ability-Slots.
func _refresh_ability_icons() -> void:
	var set: AbilitySet = PartyManager.get_active_set()
	if set == null or _ability_slots.size() < SLOT_COUNT:
		return

	var keys: Array[String] = ["LMB", "RMB", "SHIFT", "Q", "E"]
	var icons: Array[Texture2D] = [
		set.icon_primary,
		set.icon_secondary,
		set.icon_utility,
		set.icon_ability_q,
		set.icon_ability_e
	]

	for i: int in range(SLOT_COUNT):
		_ability_slots[i].setup(icons[i], keys[i])

func _process(_delta: float) -> void:
	if player_combat == null:
		return

	for i: int in range(min(SLOT_COUNT, _ability_slots.size())):
		var percent: float = player_combat.get_cooldown_percent(i)
		var remaining: float = player_combat.get_cooldown_remaining(i)
		_ability_slots[i].update_cooldown(percent, remaining)

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
