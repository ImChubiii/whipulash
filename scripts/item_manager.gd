extends Node

# ============================================================================
# Items — Autoload: Inventar, Waehrungen und der Event-Verteiler fuer alle
# Item-Effekte. Muss unter Project Settings -> Autoload als "Items" stehen.
# ============================================================================
#
# WARUM EIN AUTOLOAD UND KEINE KOMPONENTE AM SPIELER:
# Der PartyManager tauscht die Spieler-Instanz bei JEDEM Charakterwechsel
# komplett aus. Ein Inventar, das am Spieler haengt, waere nach dem ersten
# Wechsel weg. Items gehoeren dem RUN, nicht der Figur.
#
# WAS DIESES SCRIPT SONST NOCH TUT — und warum:
# Es haengt bei jedem Charakterwechsel automatisch die Laufzeit-Komponenten
# an die neue Spieler-Instanz (PlayerStats, BombCarrier) und verbindet sich
# mit deren Hitboxen. Dadurch muss KEINE der vier Charakter-Szenen
# angefasst werden — kein neuer Node im Inspector, kein vergessener Slot in
# char_winter.tscn, der drei Wochen spaeter als Bug zurueckkommt.
#
# EVENT-VERTEILUNG: item_behaviours.gd haengt sich an die Signale unten.
# Dieses Script kennt selbst KEINE Item-Regeln — genau wie
# StatusEffectManager keine Spielregeln kennt.

signal item_added(item: ItemData)
signal inventory_changed
signal coins_changed(amount: int)
signal bombs_changed(amount: int)
signal active_item_charge_changed(current: int, needed: int)

## Der aktive Spieler hat einen Gegner getroffen (Primary/Secondary-Hitbox).
signal player_hit_enemy(target: Node3D, hitbox: Hitbox)
## Ein Raum wurde geleert.
signal room_cleared(room: Node)
## Der Spieler ist in eine neue Instanz gewechselt (oder frisch gespawnt).
signal player_ready(player: CharacterBody3D)
## Aktives Item wurde benutzt.
signal active_item_used(item: ItemData)

const USE_ITEM_ACTION: String = "use_item"
const BOMB_ACTION: String = "bomb"

## Startwerte eines Runs.
const START_COINS: int = 0
const START_BOMBS: int = 1

var coins: int = START_COINS
var bombs: int = START_BOMBS

var inventory: Array[ItemData] = []
var catalog: Array[ItemData] = []

var active_item: ItemData = null
var active_item_charge: int = 0

var player: CharacterBody3D = null
var stats: PlayerStats = null
var bomb_carrier: Node = null

var _behaviours: Node = null
var _connected_hitboxes: Array[Hitbox] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_ensure_actions()
	_build_catalog()
	_spawn_behaviours()

	# PartyManager ist selbst ein Autoload. Die Reihenfolge, in der Godot
	# Autoloads initialisiert, ist nicht garantiert — deshalb wird die
	# Verbindung deferred aufgebaut statt direkt hier.
	_connect_party_manager.call_deferred()


# ============================================================================
# Eingabe-Actions selbst registrieren
# ============================================================================
# Bewusst hier statt in settings_manager.gd: dieses Feature soll sich
# installieren lassen, ohne eine bestehende Datei anzufassen. Wer die Tasten
# spaeter im Menue umlegbar machen will, traegt die beiden Actions
# zusaetzlich in SettingsManager.REBINDABLE_ACTIONS und DEFAULT_KEYBINDS ein.
func _ensure_actions() -> void:
	if not InputMap.has_action(BOMB_ACTION):
		InputMap.add_action(BOMB_ACTION)
		var bomb_event := InputEventKey.new()
		bomb_event.physical_keycode = KEY_X
		InputMap.action_add_event(BOMB_ACTION, bomb_event)

	if not InputMap.has_action(USE_ITEM_ACTION):
		InputMap.add_action(USE_ITEM_ACTION)
		var use_event := InputEventKey.new()
		use_event.physical_keycode = KEY_C
		InputMap.action_add_event(USE_ITEM_ACTION, use_event)


func _build_catalog() -> void:
	catalog = ItemCatalog.build_all()
	for external: ItemData in ItemCatalog.load_external():
		catalog.append(external)


func _spawn_behaviours() -> void:
	_behaviours = ItemBehaviours.new()
	_behaviours.name = "ItemBehaviours"
	add_child(_behaviours)


# ============================================================================
# Anbindung an den jeweils aktiven Spieler
# ============================================================================
func _connect_party_manager() -> void:
	var party: Node = get_node_or_null("/root/PartyManager")
	if party == null:
		push_warning("Items: PartyManager nicht gefunden — Item-Effekte bleiben inaktiv.")
		return

	if party.has_signal("active_player_changed") \
			and not party.active_player_changed.is_connected(bind_player):
		party.active_player_changed.connect(bind_player)

	# Falls der Spieler schon vor diesem Autoload gespawnt ist.
	var existing = party.get("player")
	if existing is CharacterBody3D and is_instance_valid(existing):
		bind_player(existing)


## Haengt alle Laufzeit-Komponenten an die neue Spieler-Instanz.
func bind_player(new_player: CharacterBody3D) -> void:
	_disconnect_hitboxes()

	player = new_player
	stats = null
	bomb_carrier = null

	if player == null or not is_instance_valid(player):
		return

	# --- PlayerStats -------------------------------------------------
	stats = player.get_node_or_null("PlayerStats") as PlayerStats
	if stats == null:
		stats = PlayerStats.new()
		stats.name = "PlayerStats"
		player.add_child(stats)
	stats.bind_to_player(player)

	# --- BombCarrier -------------------------------------------------
	bomb_carrier = player.get_node_or_null("BombCarrier")
	if bomb_carrier == null:
		bomb_carrier = BombCarrier.new()
		bomb_carrier.name = "BombCarrier"
		player.add_child(bomb_carrier)

	_connect_hitboxes()
	_reapply_all_item_stats()

	player_ready.emit(player)


func _connect_hitboxes() -> void:
	for path: String in ["CameraPivot/PrimaryHitbox", "CameraPivot/SecondaryHitbox"]:
		var hitbox := player.get_node_or_null(path) as Hitbox
		if hitbox == null:
			continue
		# Eine gebundene Callable pro Hitbox: nur so weiss der Empfaenger
		# spaeter, WELCHE Hitbox getroffen hat (Primary vs. Secondary
		# entscheidet ueber die Wucht des Hit-Stops).
		var callable := _on_hitbox_hit.bind(hitbox)
		if not hitbox.hit_landed.is_connected(callable):
			hitbox.hit_landed.connect(callable)
		_connected_hitboxes.append(hitbox)


func _disconnect_hitboxes() -> void:
	# Die alte Instanz wird vom PartyManager freigegeben; Godot loest die
	# Verbindungen dabei selbst. Der Array wird trotzdem geleert, damit
	# keine ungueltigen Referenzen liegenbleiben.
	_connected_hitboxes.clear()


func _on_hitbox_hit(target: Node, hitbox: Hitbox) -> void:
	if not (target is Node3D):
		return
	player_hit_enemy.emit(target as Node3D, hitbox)


# ============================================================================
# Inventar
# ============================================================================
func get_item_by_id(item_id: String) -> ItemData:
	for item: ItemData in catalog:
		if item.id == item_id:
			return item
	return null


func has_item(item_id: String) -> bool:
	for item: ItemData in inventory:
		if item.id == item_id:
			return true
	return false


func count_item(item_id: String) -> int:
	var total: int = 0
	for item: ItemData in inventory:
		if item.id == item_id:
			total += 1
	return total


func add_item(item: ItemData) -> bool:
	if item == null:
		return false
	if item.max_stacks > 0 and count_item(item.id) >= item.max_stacks:
		return false

	inventory.append(item)

	if item.is_active_item():
		active_item = item
		active_item_charge = item.charge_rooms
		active_item_charge_changed.emit(active_item_charge, item.charge_rooms)

	_apply_item_stats(item, inventory.size() - 1)

	item_added.emit(item)
	inventory_changed.emit()
	return true


func add_item_by_id(item_id: String) -> bool:
	return add_item(get_item_by_id(item_id))


## Stat-Boni eines Items an PlayerStats melden. Der Index wandert in die
## Quellen-ID, damit ein zweites Exemplar desselben Items den Eintrag des
## ersten nicht ueberschreibt.
func _apply_item_stats(item: ItemData, index: int) -> void:
	if stats == null or item.stat_modifiers.is_empty():
		return

	var source_id: String = "item:%s#%d" % [item.id, index]
	for stat_name: String in item.stat_modifiers.keys():
		var mod: Dictionary = item.stat_modifiers[stat_name]
		stats.add_modifier(
			source_id,
			stat_name,
			float(mod.get("add", 0.0)),
			float(mod.get("mul", 1.0))
		)


## Nach einem Charakterwechsel haengen die Boni an der ALTEN PlayerStats-
## Instanz. Deshalb wird beim Binden alles frisch aufgetragen.
func _reapply_all_item_stats() -> void:
	if stats == null:
		return
	for i: int in range(inventory.size()):
		_apply_item_stats(inventory[i], i)


## Alles zuruecksetzen — beim Start eines neuen Runs aufrufen.
func reset_run() -> void:
	inventory.clear()
	active_item = null
	active_item_charge = 0
	coins = START_COINS
	bombs = START_BOMBS
	if stats:
		stats.clear_all()
		stats.apply()
	inventory_changed.emit()
	coins_changed.emit(coins)
	bombs_changed.emit(bombs)


# ============================================================================
# Waehrungen
# ============================================================================
func add_coins(amount: int) -> void:
	coins = maxi(coins + amount, 0)
	coins_changed.emit(coins)


func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true


func add_bombs(amount: int) -> void:
	bombs = maxi(bombs + amount, 0)
	bombs_changed.emit(bombs)


func consume_bomb() -> bool:
	if bombs <= 0:
		return false
	bombs -= 1
	bombs_changed.emit(bombs)
	return true


# ============================================================================
# Raum-Events
# ============================================================================
## Wird von LootManager aufgerufen, sobald ein Raum geleert ist.
func notify_room_cleared(room: Node) -> void:
	if active_item != null and active_item_charge > 0:
		active_item_charge -= 1
		active_item_charge_changed.emit(active_item_charge, active_item.charge_rooms)
	room_cleared.emit(room)


func is_active_item_ready() -> bool:
	return active_item != null and active_item_charge <= 0


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(USE_ITEM_ACTION):
		return
	use_active_item()


func use_active_item() -> void:
	if not is_active_item_ready():
		return
	if player == null or not is_instance_valid(player):
		return

	active_item_charge = active_item.charge_rooms
	active_item_charge_changed.emit(active_item_charge, active_item.charge_rooms)
	active_item_used.emit(active_item)


## Aktuelle Combo des Spielers. LootManager nutzt sie fuer den Glueck-Bonus;
## das HUD zeigt sie an. Liefert 0, wenn gerade kein Spieler existiert.
func get_combo_count() -> int:
	if player == null or not is_instance_valid(player):
		return 0
	var combat := player.get_node_or_null("Combat") as CombatBase
	if combat == null:
		return 0
	return combat.get_combo_count()


func get_luck() -> float:
	if stats == null:
		return 0.0
	return stats.get_luck()
