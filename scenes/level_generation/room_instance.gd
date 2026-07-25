extends Node3D
class_name RoomInstance

## Bitmask-Konstanten, identisch zu RoomData.available_exits und
## RoomGridGenerator.DIRECTION_FLAG, damit Raum und Grid-Generator sich
## ohne harte Klassenabhaengigkeit einig sind, welche Richtung was ist.
const EXIT_NORTH := 1
const EXIT_SOUTH := 2
const EXIT_EAST := 4
const EXIT_WEST := 8

const _FLAG_BY_KEY := {
	"north": EXIT_NORTH,
	"south": EXIT_SOUTH,
	"east": EXIT_EAST,
	"west": EXIT_WEST,
}

## Gruppe, aus der die NavigationRegion3D des Levels ihre Geometrie bakt.
## Muss identisch zu LevelGenerator.NAV_SOURCE_GROUP und zum
## geometry_source_group_name der NavigationMesh-Resource sein.
const NAV_SOURCE_GROUP := "navmesh_source"

## Grundflaeche/Hoehe DIESES Raum-Templates in echten Weltkoordinaten.
## Raeume werden NICHT mehr zur Laufzeit skaliert - dadurch koennen
## Korridore auch eine abweichende Grundflaeche haben (z.B. 20x48).
@export var room_footprint: Vector2 = Vector2(48.0, 48.0)
@export var room_height: float = 14.0

## Wie weit der Entry-Trigger gegenueber der Grundflaeche eingezogen wird,
## damit er erst feuert, wenn der Player wirklich IM Raum steht und nicht
## schon in der Tueroeffnung.
@export var entry_trigger_inset: float = 3.0

## Wird vom LevelGenerator gesetzt. Die Minimap braucht das, um Raeume
## im Grid wiederzufinden.
var grid_position: Vector2i = Vector2i.ZERO

## Marker3D-Kinder unter "EnemySpawnPoints" markieren moegliche
## Gegner-Spawnpunkte. Nicht jeder Marker muss belegt werden.
var enemy_spawn_points: Array[Marker3D] = []

## Marker fuer Loot/Items (Chests, Pickups)
var loot_spawn_points: Array[Marker3D] = []

## Gerichtete Tueren: "north"/"south"/"east"/"west" -> Marker3D.
var exit_points: Dictionary = {}

signal room_cleared(room: RoomInstance)
signal room_entered(room: RoomInstance)

var _is_cleared: bool = false
var _active_enemies: int = 0
var _requires_clear: bool = false

var _entry_trigger: Area3D = null
var _has_entered: bool = false
var _enemies_spawned: bool = false

var _pending_entries: Array[EnemySpawnEntry] = []
var _pending_budget: int = 0
var _pending_stage: int = 1
var _spawned_enemies: Array[Node3D] = []

func _ready() -> void:
	add_to_group(NAV_SOURCE_GROUP)
	_collect_markers()
	_setup_entry_trigger()
	# Hier NICHT _lock_exits(true) - Tueren starten offen. Ob und wann ein
	# Raum sich sperrt, entscheidet prepare_enemies() bzw. on_player_entered().

func _exit_tree() -> void:
	# Gegner haengen an current_scene, nicht an diesem Node - beim
	# Aufraeumen alter Raeume muessen sie deshalb explizit mit weg.
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_spawned_enemies.clear()

func _collect_markers() -> void:
	var spawn_group := get_node_or_null("EnemySpawnPoints")
	if spawn_group:
		for child in spawn_group.get_children():
			if child is Marker3D:
				enemy_spawn_points.append(child)

	var loot_group := get_node_or_null("LootSpawnPoints")
	if loot_group:
		for child in loot_group.get_children():
			if child is Marker3D:
				loot_spawn_points.append(child)

	var exit_group := get_node_or_null("ExitPoints")
	if exit_group:
		for child in exit_group.get_children():
			if child is Marker3D:
				var key: String = child.name.to_lower()
				if not _FLAG_BY_KEY.has(key):
					continue
				exit_points[key] = child
				# Tuer wird ueber Namenskonvention gefunden statt fest in der
				# .tscn verdrahtet: "Doors/Door" + Marker-Name.
				var door := get_node_or_null("Doors/Door%s" % child.name.capitalize())
				if door:
					child.set_meta("door_node", door)
				else:
					push_warning("RoomInstance (%s): ExitPoint '%s' hat keine Tuer unter 'Doors/Door%s'." % [name, child.name, child.name.capitalize()])

func _setup_entry_trigger() -> void:
	_entry_trigger = Area3D.new()
	_entry_trigger.name = "EntryTrigger"
	_entry_trigger.collision_layer = 0
	# Nur Layer 1 (Player) und 3 (Gegner) scannen.
	_entry_trigger.collision_mask = 0b101
	_entry_trigger.monitoring = true
	_entry_trigger.monitorable = false
	add_child(_entry_trigger)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(
		max(room_footprint.x - entry_trigger_inset, 1.0),
		room_height,
		max(room_footprint.y - entry_trigger_inset, 1.0)
	)
	shape.shape = box
	shape.position = Vector3(0.0, room_height * 0.5, 0.0)
	_entry_trigger.add_child(shape)

	_entry_trigger.body_entered.connect(_on_entry_trigger_body_entered)

func _on_entry_trigger_body_entered(body: Node) -> void:
	if _has_entered:
		return
	if not body.is_in_group(PartyManager.PLAYER_GROUP):
		return
	_has_entered = true
	on_player_entered()

## Wird vom LevelGenerator direkt nach dem Instanziieren aufgerufen.
## Legt fest, MIT WELCHEM BUDGET beim Betreten gespawnt wird - spawnt aber
## noch nichts. Raeume ohne EnemySpawnPoints (Start, Treasure) bleiben offen.
func prepare_enemies(entries: Array[EnemySpawnEntry], threat_budget: int, stage: int) -> void:
	_pending_stage = stage
	var usable: Array[EnemySpawnEntry] = []
	for e in entries:
		if e != null and e.is_allowed(stage, room_height):
			usable.append(e)

	if usable.is_empty() or enemy_spawn_points.is_empty() or threat_budget <= 0:
		_is_cleared = true
		_lock_exits(false)
		return

	_requires_clear = true
	_pending_entries = usable
	_pending_budget = threat_budget
	# Tuer bleibt bewusst OFFEN, bis der Player den Raum betritt.
	_lock_exits(false)

## Waehlt anhand des Budgets eine Gegner-Mischung. Teure Gegner (Fighter,
## Colossus) verdraengen automatisch billige (Stinger), statt zusaetzlich
## dazuzukommen - dadurch wird ein Raum abwechslungsreicher, ohne haerter
## zu werden.
func _roll_enemy_mix() -> Array[EnemySpawnEntry]:
	var result: Array[EnemySpawnEntry] = []
	var budget: int = _pending_budget
	var used_count: Dictionary = {}
	var guard: int = 0

	# Garantierte Gegner zuerst (z.B. der Colossus im Bossraum). Ohne das
	# koennte die Gewichtung theoretisch nur billige Gegner ziehen und der
	# Boss waere gar nicht da.
	for e in _pending_entries:
		for i in range(e.guaranteed_count):
			if result.size() >= enemy_spawn_points.size():
				break
			result.append(e)
			used_count[e] = used_count.get(e, 0) + 1
			budget -= e.threat_cost

	while budget > 0 and result.size() < enemy_spawn_points.size() and guard < 64:
		guard += 1

		var affordable: Array[EnemySpawnEntry] = []
		for e in _pending_entries:
			if e.threat_cost > budget:
				continue
			if used_count.get(e, 0) >= e.max_per_room:
				continue
			affordable.append(e)

		if affordable.is_empty():
			break

		var chosen: EnemySpawnEntry = _weighted_pick_entry(affordable)
		result.append(chosen)
		used_count[chosen] = used_count.get(chosen, 0) + 1
		budget -= chosen.threat_cost

	# Sicherheitsnetz: leerer Kampfraum waere ein Softlock, weil sich die
	# Tueren nie wieder oeffnen wuerden.
	if result.is_empty() and not _pending_entries.is_empty():
		result.append(_pending_entries[0])

	return result

func _weighted_pick_entry(candidates: Array[EnemySpawnEntry]) -> EnemySpawnEntry:
	var total: float = 0.0
	for c in candidates:
		total += maxf(c.weight, 0.0)
	if total <= 0.0:
		return candidates.pick_random()
	var roll: float = randf() * total
	var acc: float = 0.0
	for c in candidates:
		acc += maxf(c.weight, 0.0)
		if roll <= acc:
			return c
	return candidates.back()

func _spawn_prepared_enemies() -> void:
	if _pending_entries.is_empty() or enemy_spawn_points.is_empty():
		_is_cleared = true
		_lock_exits(false)
		return

	var mix: Array[EnemySpawnEntry] = _roll_enemy_mix()

	# Teure/grosse Gegner zuerst platzieren, damit sie sich die Marker mit
	# dem meisten Platz sichern koennen.
	mix.sort_custom(func(a, b): return a.threat_cost > b.threat_cost)

	var free_points: Array[Marker3D] = enemy_spawn_points.duplicate()
	free_points.shuffle()
	var taken_positions: Array[Vector3] = []

	for entry in mix:
		var point: Marker3D = _take_spawn_point(free_points, taken_positions, entry.min_spawn_spacing)
		if point == null:
			break
		taken_positions.append(point.global_position)
		_spawn_one(entry, point)

	if _spawned_enemies.is_empty():
		_is_cleared = true
		_lock_exits(false)

## Sucht einen Marker, der weit genug von den bereits belegten entfernt ist.
## Fallback: erster freier Marker (besser ein enger Spawn als gar keiner).
func _take_spawn_point(free_points: Array[Marker3D], taken: Array[Vector3], spacing: float) -> Marker3D:
	if free_points.is_empty():
		return null
	if spacing <= 0.0 or taken.is_empty():
		return free_points.pop_front()

	for i in range(free_points.size()):
		var candidate: Marker3D = free_points[i]
		var ok: bool = true
		for t in taken:
			if candidate.global_position.distance_to(t) < spacing:
				ok = false
				break
		if ok:
			free_points.remove_at(i)
			return candidate

	return free_points.pop_front()

func _spawn_one(entry: EnemySpawnEntry, point: Marker3D) -> void:
	var enemy: Node3D = entry.scene.instantiate()

	# current_scene statt self (RoomRoot) als Parent: so erbt der Gegner
	# garantiert keine Transform-Kette des Raums und ueberlebt keine
	# Raum-Neugenerierung unbemerkt.
	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(enemy)

	# Transform explizit SAUBER setzen: nur Position + Yaw, nie die Basis
	# des Markers uebernehmen (sonst schlaegt eine geerbte Skalierung durch).
	var spawn_pos: Vector3 = point.global_position
	spawn_pos.y += 0.1
	enemy.global_transform = Transform3D(Basis.IDENTITY, spawn_pos)
	enemy.rotation = Vector3(0.0, point.global_rotation.y, 0.0)
	enemy.scale = Vector3.ONE

	_spawned_enemies.append(enemy)
	_active_enemies += 1

	# Gegner tragen "died" nicht auf ihrem Root, sondern auf ihrer
	# Health-Kindkomponente. Root-Signal hat Vorrang, falls doch vorhanden.
	if enemy.has_signal("died"):
		enemy.connect("died", _on_enemy_died)
	else:
		var health_node := enemy.find_child("Health", true, false)
		if health_node and health_node.has_signal("died"):
			health_node.died.connect(_on_enemy_died)
		else:
			enemy.tree_exited.connect(_on_enemy_died)

## Entfernt alle Tueren, die im aktuellen Grid-Layout NICHT gebraucht
## werden, aus exit_points. Diese Tueren bleiben dadurch fuer immer
## verriegelt und wirken effektiv wie eine massive Wand.
func apply_exit_flags(required_flags: int) -> void:
	for key in exit_points.keys().duplicate():
		var flag: int = _FLAG_BY_KEY.get(key, 0)
		if flag & required_flags == 0:
			exit_points.erase(key)

func _on_enemy_died() -> void:
	_active_enemies -= 1
	if _active_enemies <= 0 and not _is_cleared:
		_is_cleared = true
		_lock_exits(false)
		room_cleared.emit(self)

func is_cleared() -> bool:
	return _is_cleared

func requires_clear() -> bool:
	return _requires_clear

func get_active_enemy_count() -> int:
	return _active_enemies

func _lock_exits(locked: bool) -> void:
	for marker in exit_points.values():
		if marker.has_meta("door_node"):
			var door: Node = marker.get_meta("door_node")
			if is_instance_valid(door) and door.has_method("set_locked"):
				door.set_locked(locked)

func on_player_entered() -> void:
	room_entered.emit(self)
	if _is_cleared or _enemies_spawned or not _requires_clear:
		return
	_enemies_spawned = true
	# Jetzt erst - beim tatsaechlichen Betreten - sperrt sich der Raum und
	# spawnt seine Gegner. Vorher war die Tuer absichtlich offen.
	_lock_exits(true)
	_spawn_prepared_enemies()
