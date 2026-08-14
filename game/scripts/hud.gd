extends Control

# Zentrales HUD:
#  - rechts: 4 Party-Slots (Portrait + HP, aktiver Char groesser + mit Name)
#  - rechts unten: 5 Ability-Icons (Primary, Secondary, Shift, Q, E)
#  - oben links: Minimap mit Zonenname darueber, X/Y-Koordinaten und
#    Tastenhinweis "MAP [M]" darunter
#  - oben links neben der Minimap: Speedrun-Timer
#  - Mitte: Combo-Anzeige mit Sway-Animation
#
# WICHTIG: player/player_health/player_combat werden NICHT nur einmal
# beim Start gesucht, sondern bei JEDEM Charakterwechsel ueber
# PartyManager.active_player_changed neu verbunden — da beim Wechsel die
# komplette Player-Instanz ausgetauscht wird.
#
# MODULARE HUD-ELEMENTE: Der Master-Schalter (SettingsManager.hud_visible)
# und die Einzelschalter (SettingsManager.hud_elements) sind UND-verknuepft.
# Deshalb wird die Sichtbarkeit NICHT direkt auf self gesetzt, sondern in
# _apply_hud_visibility() zentral aus beiden Quellen berechnet — sonst
# wuerde ein Master-Toggle die Einzelschalter ueberschreiben.

@onready var combo_display: Control = $ComboDisplay
@onready var combo_count_label: Label = $ComboDisplay/ComboCount
@onready var party_container: VBoxContainer = $RightPanel/PartyContainer
@onready var ability_container: HBoxContainer = $AbilityBar/AbilityContainer
@onready var minimap: Control = $Minimap
@onready var right_panel: Control = $RightPanel
@onready var ability_bar: Control = $AbilityBar
@onready var run_timer: Control = $RunTimer
@onready var sniper_crosshair: Control = $SniperCrosshair

const SLOT_COUNT: int = 5

## --- Combo-Sway ---------------------------------------------------------
## Ausschlag nach links/rechts bei jedem Treffer. Die Richtung alterniert
## mit dem Combo-Zaehler, damit es sich wie ein Pendel anfuehlt und nicht
## wie ein zufaelliges Zittern.
@export var combo_sway_distance: float = 26.0
@export var combo_sway_rotation_degrees: float = 11.0
@export var combo_sway_duration: float = 0.45
## Ab diesem Combo-Zaehler ist der Ausschlag maximal.
@export var combo_sway_max_at_count: int = 12
@export var combo_punch_scale: float = 1.45

var player_health: Health
var player_combat: CombatBase
var player: CharacterBody3D

var _party_slots: Array[PartySlot] = []
var _ability_slots: Array[AbilitySlot] = []
var _combo_display_home_position: Vector2
var _combo_tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	combo_display.visible = false
	combo_display.modulate.a = 1.0
	combo_display.rotation = 0.0
	_combo_display_home_position = combo_display.position
	# Pivot in die Mitte, damit die Sway-Rotation um den Text kippt und
	# nicht um die linke obere Ecke.
	combo_display.pivot_offset = combo_display.size * 0.5

	SettingsManager.hud_visible_changed.connect(_on_hud_visible_changed)
	SettingsManager.hud_element_visible_changed.connect(_on_hud_element_visible_changed)

	_cache_slots()
	_connect_party_manager()
	_refresh_party()
	_refresh_ability_icons()
	_apply_hud_visibility()

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

# ============================================================================
# Sichtbarkeit (Master-Schalter + modulare Einzelschalter)
# ============================================================================
func _on_hud_visible_changed(_is_visible: bool) -> void:
	_apply_hud_visibility()

func _on_hud_element_visible_changed(_element: String, _is_visible: bool) -> void:
	_apply_hud_visibility()

# Einzige Stelle, die ueber Sichtbarkeit entscheidet. Ein Element ist nur
# dann sichtbar, wenn BEIDE Schalter true sind.
func _apply_hud_visibility() -> void:
	var master: bool = SettingsManager.hud_visible
	visible = master

	if not master:
		return

	minimap.visible = SettingsManager.is_hud_element_visible(SettingsManager.HUD_ELEMENT_MINIMAP)
	right_panel.visible = SettingsManager.is_hud_element_visible(SettingsManager.HUD_ELEMENT_PARTY)
	ability_bar.visible = SettingsManager.is_hud_element_visible(SettingsManager.HUD_ELEMENT_ABILITIES)

	if run_timer:
		run_timer.visible = SettingsManager.is_hud_element_visible(SettingsManager.HUD_ELEMENT_TIMER)

	# Keybinds/Cooldowns sind KEIN eigener Node, sondern Kind-Labels der
	# Ability-Slots — deshalb ueber deren API statt ueber .visible.
	var show_keys: bool = SettingsManager.is_hud_element_visible(SettingsManager.HUD_ELEMENT_KEYBINDS)
	for slot: AbilitySlot in _ability_slots:
		slot.set_labels_visible(show_keys)

	if not SettingsManager.is_hud_element_visible(SettingsManager.HUD_ELEMENT_COMBO):
		combo_display.visible = false

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

	# Nach einem Icon-Refresh den Keybind-Schalter erneut anwenden — setup()
	# schreibt das KeyLabel neu und wuerde es sonst wieder sichtbar machen.
	var show_keys: bool = SettingsManager.is_hud_element_visible(SettingsManager.HUD_ELEMENT_KEYBINDS)
	for slot: AbilitySlot in _ability_slots:
		slot.set_labels_visible(show_keys)

func _process(_delta: float) -> void:
	# Switch-Cooldown der Party-Slots (unabhaengig davon, ob player_combat
	# gerade gueltig ist — betrifft auch inaktive Party-Mitglieder).
	for i: int in range(_party_slots.size()):
		var switch_percent: float = PartyManager.get_switch_cooldown_percent(i)
		var switch_remaining: float = PartyManager.get_switch_cooldown_remaining(i)
		_party_slots[i].update_switch_cooldown(switch_percent, switch_remaining)

	if player_combat == null or not is_instance_valid(player_combat):
		if sniper_crosshair:
			sniper_crosshair.visible = false
		return

	for i: int in range(min(SLOT_COUNT, _ability_slots.size())):
		var percent: float = player_combat.get_cooldown_percent(i)
		var remaining: float = player_combat.get_cooldown_remaining(i)
		_ability_slots[i].update_cooldown(percent, remaining)

	_update_resource_widgets()


## Kleine, charakterspezifische Zusatzanzeigen (Giselles Munition, Winters
## Laser-Energie, Giselles Sniper-Fadenkreuz) - ueber has_method()-Checks auf
## player_combat statt Charakter-ID-Verzweigung, gleiches Prinzip wie
## InputMap.has_action(...)-Checks in combat_base.gd. hud.gd muss dadurch nie
## wissen, welcher Charakter gerade aktiv ist.
func _update_resource_widgets() -> void:
	if _ability_slots.size() > 0:
		if player_combat.has_method("get_uzi_ammo_remaining"):
			_ability_slots[0].set_resource_text("%d/%d" % [
				player_combat.get_uzi_ammo_remaining(), player_combat.get_uzi_magazine_size()
			])
		else:
			_ability_slots[0].set_resource_text("")

	if _ability_slots.size() > 1:
		if player_combat.has_method("get_laser_energy_percent"):
			_ability_slots[1].set_resource_bar(player_combat.get_laser_energy_percent())
		else:
			_ability_slots[1].set_resource_bar(-1.0)

	if sniper_crosshair:
		sniper_crosshair.visible = player_combat.has_method("is_sniper_charging") and player_combat.is_sniper_charging()

# ============================================================================
# Combo-Anzeige
# ============================================================================
func _on_combo_changed(count: int) -> void:
	if not SettingsManager.is_hud_element_visible(SettingsManager.HUD_ELEMENT_COMBO):
		combo_display.visible = false
		return

	if count <= 1:
		_play_combo_expire_animation()
		return

	# Laufende Animation hart beenden, sonst ueberlagern sich bei schnellen
	# Combos mehrere Tweens und das Element "driftet" aus seiner Position.
	if _combo_tween and _combo_tween.is_valid():
		_combo_tween.kill()

	combo_display.pivot_offset = combo_display.size * 0.5
	combo_display.modulate.a = 1.0
	combo_display.visible = true
	combo_count_label.text = "x%d" % count

	# Richtung alterniert -> Pendel-Gefuehl statt Zufallsgezappel.
	var direction: float = 1.0 if count % 2 == 0 else -1.0
	# Intensitaet waechst mit dem Combo-Zaehler und saettigt bei
	# combo_sway_max_at_count.
	var intensity: float = clampf(
		float(count) / float(max(combo_sway_max_at_count, 2)),
		0.35,
		1.0
	)

	# Startzustand des Ausschlags SOFORT setzen (kein Tween hin, nur zurueck)
	# — dadurch fuehlt sich der Treffer wie ein Schlag an und nicht wie eine
	# weiche Bewegung.
	combo_display.position = Vector2(
		_combo_display_home_position.x + combo_sway_distance * intensity * direction,
		_combo_display_home_position.y
	)
	combo_display.rotation_degrees = combo_sway_rotation_degrees * intensity * direction
	combo_display.scale = Vector2(combo_punch_scale, combo_punch_scale)

	_combo_tween = create_tween()
	_combo_tween.set_parallel(true)

	_combo_tween.tween_property(combo_display, "position", _combo_display_home_position, combo_sway_duration)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_combo_tween.tween_property(combo_display, "rotation_degrees", 0.0, combo_sway_duration)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_combo_tween.tween_property(combo_display, "scale", Vector2.ONE, 0.22)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _play_combo_expire_animation() -> void:
	if not combo_display.visible:
		return

	if _combo_tween and _combo_tween.is_valid():
		_combo_tween.kill()

	_combo_tween = create_tween()
	_combo_tween.set_parallel(true)
	_combo_tween.tween_property(combo_display, "position:y", combo_display.position.y + 40.0, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_combo_tween.tween_property(combo_display, "rotation_degrees", 0.0, 0.3)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_combo_tween.tween_property(combo_display, "modulate:a", 0.0, 0.5)
	_combo_tween.chain().tween_callback(func() -> void:
		combo_display.visible = false
		combo_display.position = _combo_display_home_position
		combo_display.rotation_degrees = 0.0
		combo_display.scale = Vector2.ONE
		combo_display.modulate.a = 1.0
	)
