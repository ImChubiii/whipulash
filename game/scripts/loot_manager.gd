extends Node

# ============================================================================
# Loot — Autoload: wuerfelt Drops aus, sobald ein Raum geleert ist.
# Muss unter Project Settings -> Autoload als "Loot" stehen.
# ============================================================================
#
# WIE ES SICH AN DIE RAEUME HAENGT:
# Nicht ueber den LevelGenerator, sondern ueber SceneTree.node_added. Der
# Grund ist Robustheit: der Generator baut Raeume, aber Testlevel und
# handgebaute Szenen (level_01.tscn, nav_test_level.tscn) enthalten
# RoomInstances direkt in der Szenendatei. Wer sich nur beim Generator
# anmeldet, bekommt in genau diesen Szenen nie einen Drop — und merkt es
# beim Testen nicht, weil dort ohnehin selten aufgeraeumt wird.
# node_added deckt beide Faelle ab und braucht keine Aenderung an
# level_generator.gd.
#
# DETERMINISTISCHER ZUFALL:
# Die Drops haengen NICHT am globalen RNG. Der laeuft laut det_rng.gd auch
# fuer Screen-Shake und Schadenszahlen, ist also nach ein paar Minuten
# Spielzeit voellig unvorhersehbar weit gelaufen. Ein Seed auf dem
# Leaderboard waere damit wertlos: zwei Laeufe mit identischem Seed
# haetten unterschiedliches Loot. Stattdessen bekommt jeder Raum einen
# eigenen, aus Run-Seed + Rasterposition abgeleiteten RNG.

signal loot_dropped(kind: int, position: Vector3)

## Grundchance auf ueberhaupt einen Drop, bevor Glueck und Combo dazukommen.
## War 0.78 - Rueckmeldung "Drop-Raten spuerbar erhoehen".
const BASE_DROP_CHANCE: float = 0.9

## Gewichte der Verbrauchsgueter. Werden intern normalisiert — die Zahlen
## entsprechen 1:1 der Design-Vorgabe (40 / 30 / 15).
const WEIGHT_COIN: float = 40.0
const WEIGHT_HEAL: float = 30.0
const WEIGHT_BOMB: float = 15.0

## Glueck-Bonus pro Combo-Stufe zum Zeitpunkt des Raum-Clears.
const LUCK_PER_COMBO_STEP: float = 0.002

## Obergrenze der Gesamt-Dropchance. 100 % wuerde den Zufall komplett
## entwerten und Loot zur Selbstverstaendlichkeit machen.
const MAX_DROP_CHANCE: float = 0.95

## Wie viele Drops ein Raum maximal ausspuckt. War 1 - Rueckmeldung
## "Drop-Raten spuerbar erhoehen", zusammen mit BASE_DROP_CHANCE angehoben:
## nicht nur wahrscheinlicher, dass ueberhaupt etwas droppt, sondern auch
## mehr auf einmal.
@export var max_drops_per_room: int = 2

## Standardmaessig AN, bis das System verifiziert ist. Danach auf false.
@export var debug_logging: bool = true

var _handled_rooms: Dictionary = {}  # InstanceID -> true


func _debug(msg: String) -> void:
	if debug_logging:
		print("[Loot] %s" % msg)


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	# Raeume, die es beim Start dieses Autoloads schon gab, nachtragen.
	_scan_existing.call_deferred()


func _scan_existing() -> void:
	var root: Node = get_tree().root
	if root == null:
		return
	_scan_recursive(root)


func _scan_recursive(node: Node) -> void:
	_on_node_added(node)
	for child: Node in node.get_children():
		_scan_recursive(child)


func _on_node_added(node: Node) -> void:
	if not (node is RoomInstance):
		return
	var room: RoomInstance = node as RoomInstance
	if room.room_cleared.is_connected(_on_room_cleared):
		return
	room.room_cleared.connect(_on_room_cleared)


func _on_room_cleared(room: RoomInstance) -> void:
	# room_cleared kann laut room_instance.gd aus zwei Stellen feuern
	# (regulaeres Herunterzaehlen und Watchdog). Ohne diese Sperre koennte
	# ein Raum doppelt droppen.
	var id: int = room.get_instance_id()
	if _handled_rooms.has(id):
		return
	_handled_rooms[id] = true

	var items: Node = get_node_or_null("/root/Items")
	if items:
		items.notify_room_cleared(room)

	_roll_drops(room)


# ============================================================================
# Wuerfeln
# ============================================================================
func _roll_drops(room: RoomInstance) -> void:
	var rng: RandomNumberGenerator = _make_rng(room)
	var chance: float = _get_drop_chance()

	_debug("Raum %s gecleared. Dropchance %.1f%%." % [room.grid_position, chance * 100.0])

	for i: int in range(max_drops_per_room):
		if rng.randf() > chance:
			_debug("  -> kein Drop.")
			continue

		var kind: int = _pick_kind(rng)
		var spawn_position: Vector3 = _pick_position(room, rng, i)
		_spawn_pickup(kind, spawn_position)
		_debug("  -> Drop %s bei %s." % [Pickup.Kind.keys()[kind], spawn_position])


## Gesamt-Dropchance aus Grundwert, Glueck-Stat und aktueller Combo.
func _get_drop_chance() -> float:
	var items: Node = get_node_or_null("/root/Items")
	if items == null:
		return BASE_DROP_CHANCE

	var luck: float = items.get_luck()
	var combo_bonus: float = float(items.get_combo_count()) * LUCK_PER_COMBO_STEP

	return clampf(BASE_DROP_CHANCE + luck + combo_bonus, 0.0, MAX_DROP_CHANCE)


func _pick_kind(rng: RandomNumberGenerator) -> int:
	var total: float = WEIGHT_COIN + WEIGHT_HEAL + WEIGHT_BOMB
	var roll: float = rng.randf() * total

	if roll < WEIGHT_COIN:
		return Pickup.Kind.COIN
	if roll < WEIGHT_COIN + WEIGHT_HEAL:
		return Pickup.Kind.HEAL
	return Pickup.Kind.BOMB


## Bevorzugt einen LootSpawnPoint-Marker: der ist von Hand gesetzt und liegt
## garantiert auf begehbarem Boden.
##
## WARUM DER FALLBACK NICHT get_room_center() IST:
## Aktuell haben nur room_treasure_01 und room_boss_01 ueberhaupt Marker —
## saemtliche Combat- und Korridor-Raeume nicht. get_room_center() liefert
## bei leerer Markerliste aber den Raum-URSPRUNG zurueck, nicht die Mitte
## (siehe room_instance.gd). Der liegt je nach Prefab in einer Ecke oder
## unter dem Boden, und der Drop waere unsichtbar — ohne Fehlermeldung,
## also praktisch nicht auffindbar.
##
## Deshalb wird ersatzweise beim SPIELER abgelegt: er hat den Raum gerade
## geleert, steht also zwangslaeufig auf begehbarem Boden und sieht den
## Drop sofort. Der kleine Zufallsversatz verhindert, dass mehrere Drops
## exakt uebereinander landen.
func _pick_position(room: RoomInstance, rng: RandomNumberGenerator, index: int) -> Vector3:
	var points: Array[Marker3D] = room.loot_spawn_points
	if not points.is_empty():
		var marker: Marker3D = points[(rng.randi_range(0, points.size() - 1) + index) % points.size()]
		return marker.global_position + Vector3(0.0, 0.6, 0.0)

	var player: Node3D = _find_player()
	if player:
		var offset := Vector3(
			rng.randf_range(-1.6, 1.6),
			0.0,
			rng.randf_range(-1.6, 1.6)
		)
		return player.global_position + offset + Vector3(0.0, 0.4, 0.0)

	return room.get_room_center() + Vector3(0.0, 0.6, 0.0)


func _find_player() -> Node3D:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


func _spawn_pickup(kind: int, spawn_position: Vector3) -> void:
	var parent: Node = get_tree().current_scene
	if parent == null:
		return

	var pickup: Pickup = Pickup.create(kind)
	parent.add_child(pickup)
	pickup.global_position = spawn_position

	loot_dropped.emit(kind, spawn_position)


## Fallback fuer den Verfluchten Glueckswuerfel (item_behaviours.gd,
## _use_cursed_die): wird nur aufgerufen, wenn ein am Boden liegendes Pickup
## KEINE eigene reroll()-Methode hat. Wuerfelt eine ganz normale
## Verbrauchsgut-Sorte ueber dieselbe Gewichtung wie ein regulaerer Drop und
## spawnt sie an derselben Stelle.
func spawn_random_drop(spawn_position: Vector3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_spawn_pickup(_pick_kind(rng), spawn_position)


# ============================================================================
# Deterministischer RNG pro Raum
# ============================================================================
func _make_rng(room: RoomInstance) -> RandomNumberGenerator:
	var base_seed: int = _get_run_seed()
	var salt: String = "loot:%d:%d:%d" % [
		room.grid_position.x,
		room.grid_position.y,
		_get_current_stage()
	]
	return DetRng.make(DetRng.derive(base_seed, salt))


func _get_run_seed() -> int:
	var generator: Node = _find_generator()
	if generator and generator.has_method("get_run_seed"):
		return generator.get_run_seed()
	return 0


func _get_current_stage() -> int:
	var generator: Node = _find_generator()
	if generator and generator.has_method("get_current_stage"):
		return generator.get_current_stage()
	return 1


func _find_generator() -> Node:
	var found: Array = get_tree().get_nodes_in_group("level_generator")
	if not found.is_empty():
		return found[0]
	return null


## Beim Start eines neuen Runs aufrufen, sonst haelt der Manager Raeume aus
## dem alten Lauf fuer bereits abgehandelt.
func reset_run() -> void:
	_handled_rooms.clear()
