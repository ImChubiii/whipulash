extends Control

# Zentrales HUD:
#  - rechts: 4 Party-Slots (Portrait + HP, aktiver Char groesser + mit Name)
#  - rechts unten: 5 Ability-Icons (Primary, Secondary, Shift, Q, E)
#  - oben links: Minimap mit Zonenname darueber und X/Y-Koordinaten darunter
#  - Mitte: Combo-Anzeige (bestehende Logik, unveraendert)
#
# WICHTIG: player/player_health/player_combat werden NICHT mehr nur einmal
# beim Start gesucht, sondern bei JEDEM Charakterwechsel ueber
# PartyManager.active_player_changed neu verbunden — da beim Wechsel die
# komplette Player-Instanz ausgetauscht wird.

@onready var combo_display: Control = $ComboDisplay
@onready var combo_count_label: Label = $ComboDisplay/ComboCount
@onready var party_container: VBoxContainer = $RightPanel/PartyContainer
@onready var ability_container: HBoxContainer = $AbilityBar/AbilityContainer
@onready var minimap: Control = $Minimap

const SLOT_COUNT: int = 5

var player_health: Health
var player_combat: CombatBase
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
	_connect_party_manager()
	_refresh_party()
	_refresh_ability_icons()

	# Falls PartyManager schon vor dem HUD gespawnt hat, sofort verbinden.
	if PartyManager.player and is_instance_valid(PartyManager.player):
		_on_active_player_changed(PartyManager.player)

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

func _connect_party_manager() -> void:
	if not PartyManager.active_character_changed.is_connected(_on_active_character_changed):
		PartyManager.active_character_changed.connect(_on_active_character_changed)
	if not PartyManager.member_health_changed.is_connected(_on_member_health_changed):
		PartyManager.member_health_changed.connect(_on_member_health_changed)
	if not PartyManager.party_changed.is_connected(_refresh_party):
		PartyManager.party_changed.connect(_refresh_party)
	if not PartyManager.active_player_changed.is_connected(_on_active_player_changed):
		PartyManager.active_player_changed.connect(_on_active_player_changed)

# Wird bei JEDEM Spawn/Wechsel aufgerufen — haelt player/player_health/
# player_combat und die Minimap-Referenz immer aktuell.
func _on_active_player_changed(new_player: CharacterBody3D) -> void:
	if player_health and player_health.health_changed.is_connected(_on_health_changed):
		player_health.health_changed.disconnect(_on_health_changed)

	player = new_player
	player_health = null
	player_combat = null

	if player == null or not is_instance_valid(player):
		return

	var health_node := player.find_child("Health", true, false)
	if health_node and health_node is Health:
		player_health = health_node
		player_health.health_changed.connect(_on_health_changed)
		_on_health_changed(player_health.current_health, player_health.max_health)
	else:
		push_warning("HUD: Player hat keine Health-Komponente (Kind-Node 'Health').")

	var combat_node := player.find_child("Combat", true, false)
	if combat_node and combat_node is CombatBase:
		player_combat = combat_node
		if not player_combat.combo_changed.is_connected(_on_combo_changed):
			player_combat.combo_changed.connect(_on_combo_changed)
	else:
		push_warning("HUD: Player hat keine Combat-Komponente (Kind-Node 'Combat').")

	if minimap:
		minimap.set_player(player)

func _on_health_changed(current: float, max_hp: float) -> void:
	var idx: int = PartyManager.get_active_index()
	if idx >= 0 and idx < _party_slots.size():
		_party_slots[idx].update_health(current, max_hp)

func _refresh_party() -> void:
	var active: int = PartyManager.get_active_index()

	for i: int in range(_party_slots.size()):
		var slot: PartySlot = _party_slots[i]
		var data: CharacterData = PartyManager.get_data(i)
		slot.setup(i, data)

		if data == null:
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
	var data: CharacterData = PartyManager.get_active_data()
	if data == null or _ability_slots.size() < SLOT_COUNT:
		return

	var keys: Array[String] = ["LMB", "RMB", "SHIFT", "Q", "E"]
	var icons: Array[Texture2D] = [
		data.icon_primary,
		data.icon_secondary,
		data.icon_utility,
		data.icon_ability_q,
		data.icon_ability_e
	]

	for i: int in range(SLOT_COUNT):
		_ability_slots[i].setup(icons[i], keys[i])

func _process(_delta: float) -> void:
	# Switch-Cooldown der Party-Slots (unabhaengig davon, ob player_combat
	# gerade gueltig ist — betrifft auch inaktive Party-Mitglieder).
	for i: int in range(_party_slots.size()):
		var switch_percent: float = PartyManager.get_switch_cooldown_percent(i)
		var switch_remaining: float = PartyManager.get_switch_cooldown_remaining(i)
		_party_slots[i].update_switch_cooldown(switch_percent, switch_remaining)

	if player_combat == null or not is_instance_valid(player_combat):
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
