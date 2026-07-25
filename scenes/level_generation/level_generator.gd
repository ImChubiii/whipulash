extends Node
class_name LevelGenerator

const NAV_SOURCE_GROUP := "navmesh_source"
const GENERATOR_GROUP := "level_generator"

const DIR_KEYS := ["north", "south", "east", "west"]
const DIR_OFFSETS := {
	"north": Vector2i(0, -1),
	"south": Vector2i(0, 1),
	"east": Vector2i(1, 0),
	"west": Vector2i(-1, 0),
}

@export var room_pool: Array[RoomData] = []
@export var current_stage: int = 1

@export var enemy_table: Array[EnemySpawnEntry] = []
@export var boss_table: Array[EnemySpawnEntry] = []

@export var cell_size: Vector3 = Vector3(48.0, 0.0, 48.0)

## Weltraum-Hoehe EINER Hoehenstufe aus dem RoomGridGenerator. Der Wert
## muss zur Rampenlaenge der Korridore passen: bei 48 Einheiten Ganglaenge
## sind 6.0 eine gut begehbare Steigung (ca. 7 Grad), 10.0 wird steil.
@export var elevation_step: float = 6.0

@export var grid_generator: RoomGridGenerator
@export var autostart: bool = true

@export var combat_threat_budget: int = 5
@export var corridor_threat_budget: int = 2
@export var boss_threat_budget: int = 12
@export var threat_per_stage: int = 2
@export var threat_hard_cap: int = 14

@export var navigation_region: NavigationRegion3D
@export var random_seed: int = 0

signal stage_generated(stage: int, room_count: int)
signal map_updated
signal stage_cleared(stage: int)

var _used_unique_rooms: Array[RoomData] = []
var _instances: Dictionary = {}
var _current_layout: Dictionary = {}
var _map_cells: Dictionary = {}
var _current_room: Vector2i = Vector2i.ZERO
var _stage_cleared: bool = false


func _ready() -> void:
	add_to_group(GENERATOR_GROUP)

	if random_seed != 0:
		seed(random_seed)
	else:
		randomize()

	if grid_generator == null:
		grid_generator = get_parent().get_node_or_null("RoomGridGenerator") as RoomGridGenerator

	if navigation_region == null:
		navigation_region = get_parent().get_node_or_null("NavigationRegion3D") as NavigationRegion3D
		if navigation_region == null:
			push_warning("[LevelGenerator] Keine NavigationRegion3D gefunden. Gegner fallen auf reines Direkt-Chasing zurueck.")

	print("[LevelGenerator] _ready() - autostart=%s, room_pool=%d, enemy_table=%d, boss_table=%d" % [autostart, room_pool.size(), enemy_table.size(), boss_table.size()])
	if autostart and grid_generator:
		call_deferred("generate_new_stage")
	elif autostart and grid_generator == null:
		push_error("[LevelGenerator] Kein RoomGridGenerator gefunden! Node muss 'RoomGridGenerator' heissen und Geschwister-Node sein, ODER im Inspector zugewiesen werden.")

# --- Oeffentliche API fuer die Minimap ------------------------------

func get_map_cells() -> Dictionary:
	return _map_cells

func get_current_room() -> Vector2i:
	return _current_room

func get_current_stage() -> int:
	return current_stage

func is_stage_cleared() -> bool:
	return _stage_cleared

func get_room_type_name(type: int) -> String:
	match type:
		RoomData.RoomType.START:
			return "START"
		RoomData.RoomType.COMBAT:
			return "COMBAT"
		RoomData.RoomType.CORRIDOR:
			return "CORRIDOR"
		RoomData.RoomType.TREASURE:
			return "TREASURE"
		RoomData.RoomType.BOSS:
			return "BOSS"
		RoomData.RoomType.SHOP:
			return "SHOP"
	return "UNKNOWN"

# --- Generierung ----------------------------------------------------

func generate_new_stage() -> void:
	_current_layout = grid_generator.generate_layout()
	print("[LevelGenerator] Layout generiert: %d Zellen" % _current_layout.size())
	_instantiate_layout(_current_layout)


func generate_next_stage_same_pattern() -> void:
	current_stage += 1
	_instantiate_layout(_current_layout)


func _instantiate_layout(layout: Dictionary) -> void:
	_clear_current_rooms()
	_used_unique_rooms.clear()
	_map_cells.clear()
	_stage_cleared = false
	_current_room = Vector2i.ZERO

	for grid_pos in layout.keys():
		var cell: RoomGridGenerator.RoomCell = layout[grid_pos]
		var data: RoomData = _pick_room(cell.room_type, cell.exit_flags)
		if data == null:
			continue

		# Hoehenstufe der Eingangsseite -> Welt-Y.
		var world_pos := Vector3(
			grid_pos.x * cell_size.x,
			cell.elevation * elevation_step,
			grid_pos.y * cell_size.z
		)
		var room := load_room(data, Transform3D(Basis.IDENTITY, world_pos))
		if room == null:
			continue

		room.grid_position = grid_pos
		room.apply_exit_flags(cell.exit_flags)

		# Korridor mit Hoehenunterschied -> Rampe im Inneren bauen und die
		# Tuer auf der hohen Seite entsprechend anheben.
		if cell.slope_delta != 0 and room.has_method("configure_slope"):
			room.configure_slope(cell.slope_low_dir, cell.slope_delta * elevation_step)

		var table: Array[EnemySpawnEntry] = _table_for_type(cell.room_type)
		var budget: int = _budget_for_type(cell.room_type)
		room.prepare_enemies(table, budget, current_stage)

		room.room_entered.connect(_on_room_entered)
		room.room_cleared.connect(_on_room_cleared)

		_instances[grid_pos] = room
		_map_cells[grid_pos] = {
			"type": cell.room_type,
			"exits": cell.exit_flags,
			"elevation": cell.elevation,
			"visited": grid_pos == Vector2i.ZERO,
			"cleared": not room.requires_clear(),
			"hostile": room.requires_clear(),
		}

	_apply_door_kinds(layout)

	print("[LevelGenerator] %d/%d Raeume instanziert." % [_instances.size(), layout.size()])
	_rebake_navigation()
	stage_generated.emit(current_stage, _instances.size())
	map_updated.emit()


## Faerbt Tueren nach dem Raum, in den sie fuehren: Boss = rot,
## Treasure = goldgelb. Beide Sonderformen muessen gehackt werden.
func _apply_door_kinds(layout: Dictionary) -> void:
	for grid_pos in _instances.keys():
		var room: RoomInstance = _instances[grid_pos]
		if not room.has_method("set_door_kind"):
			continue

		for dir in DIR_KEYS:
			var neighbor_pos: Vector2i = grid_pos + DIR_OFFSETS[dir]
			if not layout.has(neighbor_pos):
				continue
			var neighbor: RoomGridGenerator.RoomCell = layout[neighbor_pos]

			match neighbor.room_type:
				RoomData.RoomType.BOSS:
					room.set_door_kind(dir, Door.DoorKind.BOSS)
					# Boss-Tuer laesst sich erst hacken, wenn DIESER Raum
					# (der davor) leergeraeumt ist. Raeume ohne Gegner
					# geben sie sofort frei.
					room.set_door_hack_enabled(dir, room.is_cleared())
				RoomData.RoomType.TREASURE:
					room.set_door_kind(dir, Door.DoorKind.TREASURE)
					room.set_door_hack_enabled(dir, true)


func _on_room_entered(room: RoomInstance) -> void:
	_current_room = room.grid_position
	if _map_cells.has(room.grid_position):
		_map_cells[room.grid_position]["visited"] = true
	map_updated.emit()


func _on_room_cleared(room: RoomInstance) -> void:
	if _map_cells.has(room.grid_position):
		_map_cells[room.grid_position]["cleared"] = true
		if _map_cells[room.grid_position]["type"] == RoomData.RoomType.BOSS:
			_stage_cleared = true
			stage_cleared.emit(current_stage)
			print("[LevelGenerator] Stage %d gecleared (Bossraum bei %s)." % [current_stage, room.grid_position])

	# Angrenzende Boss-Tuer freischalten - ab jetzt darf gehackt werden.
	for dir in DIR_KEYS:
		var neighbor_pos: Vector2i = room.grid_position + DIR_OFFSETS[dir]
		if not _current_layout.has(neighbor_pos):
			continue
		if _current_layout[neighbor_pos].room_type == RoomData.RoomType.BOSS:
			room.set_door_hack_enabled(dir, true)

	map_updated.emit()

# --- Gegner-Tabellen & Budget ---------------------------------------

func _table_for_type(type: int) -> Array[EnemySpawnEntry]:
	if type == RoomData.RoomType.BOSS:
		if not boss_table.is_empty():
			return boss_table
		return enemy_table
	if type == RoomData.RoomType.COMBAT or type == RoomData.RoomType.CORRIDOR:
		return enemy_table
	var empty: Array[EnemySpawnEntry] = []
	return empty


func _budget_for_type(type: int) -> int:
	var base: int = 0
	match type:
		RoomData.RoomType.COMBAT:
			base = combat_threat_budget
		RoomData.RoomType.CORRIDOR:
			base = corridor_threat_budget
		RoomData.RoomType.BOSS:
			base = boss_threat_budget
		_:
			return 0
	return clampi(base + (current_stage - 1) * threat_per_stage, 0, threat_hard_cap)

# --- Navigation ------------------------------------------------------

func _rebake_navigation() -> void:
	if navigation_region == null:
		return
	if navigation_region.navigation_mesh == null:
		push_error("[LevelGenerator] NavigationRegion3D hat keine NavigationMesh-Resource - Baking uebersprungen.")
		return
	await get_tree().process_frame
	await get_tree().physics_frame
	navigation_region.bake_navigation_mesh(false)
	print("[LevelGenerator] NavMesh gebakt (%d Quell-Nodes in '%s')." % [get_tree().get_nodes_in_group(NAV_SOURCE_GROUP).size(), NAV_SOURCE_GROUP])

# --- Raum-Auswahl ----------------------------------------------------

func _clear_current_rooms() -> void:
	for room in _instances.values():
		if is_instance_valid(room):
			var parent: Node = room.get_parent()
			if parent:
				parent.remove_child(room)
			room.queue_free()
	_instances.clear()


func _pick_room(type: int, required_exit_flags: int) -> RoomData:
	var candidates: Array[RoomData] = []
	for data in room_pool:
		if data == null or data.scene == null:
			continue
		if data.room_type != type:
			continue
		if data.min_stage > current_stage:
			continue
		if data.unique_per_run and data in _used_unique_rooms:
			continue
		if (data.available_exits & required_exit_flags) != required_exit_flags:
			continue
		candidates.append(data)

	if candidates.is_empty():
		push_error("LevelGenerator: Kein passender Raum fuer Typ %s (Exits %d) gefunden!" % [type, required_exit_flags])
		return null

	var chosen: RoomData = _weighted_pick(candidates)
	if chosen.unique_per_run:
		_used_unique_rooms.append(chosen)
	return chosen


func _weighted_pick(candidates: Array[RoomData]) -> RoomData:
	var total_weight: float = 0.0
	for c in candidates:
		total_weight += c.spawn_weight
	if total_weight <= 0.0:
		return candidates.pick_random()

	var roll: float = randf() * total_weight
	var accumulated: float = 0.0
	for c in candidates:
		accumulated += c.spawn_weight
		if roll <= accumulated:
			return c
	return candidates.back()


func load_room(data: RoomData, spawn_transform: Transform3D) -> RoomInstance:
	if data.scene == null:
		return null
	var instance: Node3D = data.scene.instantiate()

	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(instance)
	instance.global_transform = Transform3D(Basis.IDENTITY, spawn_transform.origin)

	var room := instance as RoomInstance
	if room == null:
		push_error("[LevelGenerator] Szene '%s' hat Root-Typ %s statt RoomInstance-Script!" % [data.scene.resource_path, instance.get_class()])
	return room
