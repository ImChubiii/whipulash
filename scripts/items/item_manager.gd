

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
#
# ---------------------------------------------------------------------------
# PHASE 5: ZWEI UNABHAENGIGE AKTIVE-ITEM-SLOTS (Q UND E)
# ---------------------------------------------------------------------------
# Vorher gab es genau EIN aktives Item, ausgeloest ueber Taste C. Q und E
# waren leere Charakter-Faehigkeits-Platzhalter (siehe combat_base.gd).
# Jetzt sind Q und E selbst die beiden Slots:
#   * Slot 0 (Q) wird vom ERSTEN aktiven Item belegt, das man aufsammelt.
#   * Slot 1 (E) vom ZWEITEN.
#   * Ein drittes aktives Item landet zwar im normalen inventory (zaehlt
#     fuer die Item-Liste, Stats etc.), wird aber NICHT automatisch
#     ausgeruestet — es gibt aktuell keinen dritten Slot. Siehe
#     active_item_swap_panel.gd fuer die bewusste Entscheidung, den
#     Pause-Screen NUR "Q und E tauschen" anbieten zu lassen statt eines
#     vollen Item-Pickers.
#
# WARUM EIN DICTIONARY FUER DIE LADUNG STATT EINES ARRAYS PARALLEL ZU
# active_items:
# Ladung haengt am ITEM (verschiedene Items brauchen unterschiedlich viele
# Raeume), nicht am SLOT. Wuerde die Ladung stattdessen pro Slot-Index
# gespeichert, wuerde ein Tausch zwischen Q und E (swap_active_slots())
# entweder die Ladung mittauschen MUESSEN (Extra-Code, Fehlerquelle) oder
# still verloren gehen. Mit einem Dictionary, das per item.id schluesselt,
# ist ein Tausch nur noch "welcher Slot-Index zeigt auf welche ID" — die
# Ladung selbst wird nie angefasst.

signal item_added(item: ItemData)
signal inventory_changed
signal coins_changed(amount: int)
signal bombs_changed(amount: int)
## PHASE 5: slot ist jetzt Teil der Signatur (0 = Q, 1 = E) - vorher gab es
## nur einen Slot, das HUD (item_description_hud.gd) muss jetzt wissen,
## WELCHE der beiden Anzeigen aktualisiert werden soll.
signal active_item_charge_changed(slot: int, current: int, needed: int)
## Feuert, wenn sich belegt/leer ODER die Zuordnung Item->Slot aendert
## (Aufsammeln eines aktiven Items, Tausch im Pause-Screen). Getrennt von
## active_item_charge_changed, weil sich hier die IDENTITAET aendert, nicht
## nur ein Fortschrittswert - Listener wie der Swap-Panel-Button muessen
## z.B. komplett neu aufbauen, nicht nur einen Balken aktualisieren.
signal active_slots_changed

## Der aktive Spieler hat einen Gegner getroffen (Primary/Secondary-Hitbox).
signal player_hit_enemy(target: Node3D, hitbox: Hitbox)
## Ein Raum wurde geleert.
signal room_cleared(room: Node)
## Der Spieler ist in eine neue Instanz gewechselt (oder frisch gespawnt).
signal player_ready(player: CharacterBody3D)
## Aktives Item wurde benutzt. slot: 0 = Q, 1 = E.
signal active_item_used(item: ItemData, slot: int)

const BOMB_ACTION: String = "bomb"

## Wie viele aktive Item-Slots es gibt. Siehe Kopfkommentar - Slot 0 = Q,
## Slot 1 = E. Kein drittes Element hinzufuegen, ohne auch
## active_item_swap_panel.gd und item_description_hud.gd anzupassen, die
## beide fest von genau zwei Slots ausgehen.
const ACTIVE_SLOT_COUNT: int = 2

## Startwerte eines Runs.
const START_COINS: int = 0
const START_BOMBS: int = 1

var coins: int = START_COINS
var bombs: int = START_BOMBS

var inventory: Array[ItemData] = []
var catalog: Array[ItemData] = []

## Index 0 = Q, Index 1 = E. null = Slot frei.
var active_items: Array[ItemData] = [null, null]

## Ladung PRO ITEM (Schluessel: item.id), nicht pro Slot - siehe
## Kopfkommentar. Ein Item, das gerade in keinem Slot steckt, behaelt seinen
## Eintrag hier trotzdem (falls es spaeter wieder eingewechselt wird).
var _active_charges: Dictionary = {}

## PHASE 4: sekundenbasierte Cooldowns. item_id -> Restsekunden.
##
## BEWUSST GETRENNT von _active_charges: die beiden Mechaniken haben
## unterschiedliche Einheiten (Raeume vs. Sekunden) und unterschiedliche
## Nullpunkte. In EINEM Dictionary gemischt haette jede Abfrage erst den
## Item-Typ nachschlagen muessen, um zu wissen, was der Wert bedeutet.
var _active_cooldowns: Dictionary = {}

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
# installieren lassen, ohne eine bestehende Datei anzufassen.
#
# PHASE 5: die fruehere eigene "use_item"-Action (Taste C) ist weg. Aktive
# Items werden jetzt ueber Q/E ausgeloest ("ability_primary"/
# "ability_secondary"), die bereits in settings_manager.gd registriert und
# rebindbar sind (siehe DEFAULT_KEYBINDS dort) - dieses Script fasst Input
# ueberhaupt nicht mehr direkt an, siehe combat_base.gd._do_ability_q()/
# _do_ability_e().
func _ensure_actions() -> void:
	if not InputMap.has_action(BOMB_ACTION):
		InputMap.add_action(BOMB_ACTION)
		var bomb_event := InputEventKey.new()
		bomb_event.physical_keycode = KEY_X
		InputMap.action_add_event(BOMB_ACTION, bomb_event)


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
		_equip_active_item(item)

	_apply_item_stats(item, inventory.size() - 1)

	item_added.emit(item)
	inventory_changed.emit()
	return true


## Weist ein neu aufgesammeltes aktives Item dem ersten freien Slot zu
## (Q vor E). Ist keiner frei, bleibt das Item unausgeruestet im normalen
## inventory liegen - siehe Kopfkommentar zum Drei-Item-Fall.
func _equip_active_item(item: ItemData) -> void:
	if not _active_charges.has(item.id):
		_active_charges[item.id] = item.charge_rooms

	for slot: int in range(ACTIVE_SLOT_COUNT):
		if active_items[slot] == null:
			active_items[slot] = item
			active_slots_changed.emit()
			active_item_charge_changed.emit(slot, _active_charges[item.id], item.charge_rooms)
			return


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
	active_items = [null, null]
	_active_charges.clear()
	# PHASE 4: sonst startet der neue Run mit dem Cooldown des alten.
	_active_cooldowns.clear()
	coins = START_COINS
	bombs = START_BOMBS
	if stats:
		stats.clear_all()
		stats.apply()
	inventory_changed.emit()
	active_slots_changed.emit()
	coins_changed.emit(coins)
	bombs_changed.emit(bombs)


## Admin/Debug: entfernt ALLE Items aus dem Inventar (inkl. Stat-Boni und
## aktiver Slots), OHNE Muenzen/Bomben anzufassen - anders als reset_run(),
## das fuer einen kompletten Rundenneustart gedacht ist. Gedacht fuer die
## Loesch-Plattform im Item-Testraum (siehe scripts/item_test_room.gd):
## Items durchtesten, dann per Knopfdruck wieder bei null anfangen, ohne
## gleich den ganzen Run neu zu starten.
func clear_inventory() -> void:
	inventory.clear()
	active_items = [null, null]
	_active_charges.clear()
	_active_cooldowns.clear()
	if stats:
		stats.clear_all()
		stats.apply()
	inventory_changed.emit()
	active_slots_changed.emit()


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
## Wird von LootManager aufgerufen, sobald ein Raum geleert ist. Laedt
## BEIDE Slots gleichzeitig auf, unabhaengig voneinander (siehe Kopfkommentar
## - Ladung haengt am Item, nicht am Slot).
func notify_room_cleared(room: Node) -> void:
	for slot: int in range(ACTIVE_SLOT_COUNT):
		var item: ItemData = active_items[slot]
		if item == null:
			continue
		var remaining: int = int(_active_charges.get(item.id, 0))
		if remaining > 0:
			remaining -= 1
			_active_charges[item.id] = remaining
			active_item_charge_changed.emit(slot, remaining, item.charge_rooms)
	room_cleared.emit(room)


func is_active_slot_ready(slot: int) -> bool:
	if slot < 0 or slot >= ACTIVE_SLOT_COUNT:
		return false
	var item: ItemData = active_items[slot]
	if item == null:
		return false
	if item.uses_time_cooldown():
		return float(_active_cooldowns.get(item.id, 0.0)) <= 0.0
	return int(_active_charges.get(item.id, 0)) <= 0


## PHASE 4: laesst die Sekunden-Cooldowns ablaufen.
##
## _process statt eines Timers pro Item: es gibt hoechstens zwei aktive
## Slots, die Schleife kostet nichts, und ein Timer-Node pro Item haette bei
## jedem Slot-Tausch neu verdrahtet werden muessen.
func _process(delta: float) -> void:
	if _active_cooldowns.is_empty():
		return
	var finished: Array = []
	for id: String in _active_cooldowns.keys():
		var left: float = float(_active_cooldowns[id]) - delta
		if left <= 0.0:
			finished.append(id)
		else:
			_active_cooldowns[id] = left

	for id: String in finished:
		_active_cooldowns.erase(id)
		for slot: int in range(ACTIVE_SLOT_COUNT):
			var item: ItemData = active_items[slot]
			if item != null and item.id == id:
				active_item_charge_changed.emit(slot, 0, 0)


## PHASE 4: von der Nonnen-Kutte benutzt — laedt ein Aktiv-Item sofort auf,
## egal welche der beiden Mechaniken es benutzt.
## Rueckgabe: true, wenn wirklich etwas aufgeladen wurde.
func force_recharge_active(slot: int = -1) -> bool:
	var slots: Array[int] = []
	if slot >= 0:
		slots.append(slot)
	else:
		for i: int in range(ACTIVE_SLOT_COUNT):
			slots.append(i)

	var did: bool = false
	for s: int in slots:
		var item: ItemData = active_items[s]
		if item == null:
			continue
		if item.uses_time_cooldown():
			if float(_active_cooldowns.get(item.id, 0.0)) <= 0.0:
				continue
			_active_cooldowns.erase(item.id)
		else:
			if int(_active_charges.get(item.id, 0)) <= 0:
				continue
			_active_charges[item.id] = 0
		active_item_charge_changed.emit(s, 0, item.charge_rooms)
		did = true
	return did


## Fuer combat_base.gd's Cooldown-Anzeige im HUD: 1.0 = nicht bereit (Overlay
## voll), 0.0 = bereit (Overlay leer). Leerer Slot zeigt IMMER 0.0 - ein
## leerer Slot ist nicht "auf Cooldown", er hat einfach nichts zu zeigen.
func get_active_charge_percent(slot: int) -> float:
	if slot < 0 or slot >= ACTIVE_SLOT_COUNT:
		return 0.0
	var item: ItemData = active_items[slot]
	if item == null:
		return 0.0
	if item.uses_time_cooldown():
		var left: float = float(_active_cooldowns.get(item.id, 0.0))
		return clampf(left / maxf(item.cooldown_seconds, 0.001), 0.0, 1.0)
	if item.charge_rooms <= 0:
		return 0.0
	var remaining: int = int(_active_charges.get(item.id, 0))
	return clampf(float(remaining) / float(item.charge_rooms), 0.0, 1.0)


## Fuer die Zahl im HUD-Cooldown-Overlay: "noch so viele Raeume".
func get_active_charge_remaining(slot: int) -> float:
	if slot < 0 or slot >= ACTIVE_SLOT_COUNT:
		return 0.0
	var item: ItemData = active_items[slot]
	if item == null:
		return 0.0
	if item.uses_time_cooldown():
		# Aufgerundet: "noch 1 s" ist ehrlicher als "noch 0 s", solange der
		# Knopf noch nicht geht.
		return ceilf(float(_active_cooldowns.get(item.id, 0.0)))
	return float(_active_charges.get(item.id, 0))


func use_active_item(slot: int) -> void:
	if not is_active_slot_ready(slot):
		return
	if player == null or not is_instance_valid(player):
		return

	var item: ItemData = active_items[slot]
	if item.uses_time_cooldown():
		_active_cooldowns[item.id] = item.cooldown_seconds
		active_item_charge_changed.emit(slot, int(ceilf(item.cooldown_seconds)), int(ceilf(item.cooldown_seconds)))
	else:
		_active_charges[item.id] = item.charge_rooms
		active_item_charge_changed.emit(slot, item.charge_rooms, item.charge_rooms)
	active_item_used.emit(item, slot)


## Vom Pause-Screen (active_item_swap_panel.gd) aufgerufen: tauscht, was in
## Q und was in E steckt. Absichtlich NUR das - kein Item-Picker fuer ein
## drittes, unausgeruestetes aktives Item (siehe Kopfkommentar). Die Ladung
## selbst wird nicht angefasst, sie haengt am Item, nicht am Slot.
func swap_active_slots() -> void:
	var tmp: ItemData = active_items[0]
	active_items[0] = active_items[1]
	active_items[1] = tmp
	active_slots_changed.emit()

	for slot: int in range(ACTIVE_SLOT_COUNT):
		var item: ItemData = active_items[slot]
		if item != null:
			active_item_charge_changed.emit(slot, int(_active_charges.get(item.id, 0)), item.charge_rooms)


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



