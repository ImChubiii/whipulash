extends Node
class_name LevelGenerator

@export var room_pool: Array[RoomData] = []
@export var current_stage: int = 1
@export var enemy_pool: Array[PackedScene] = []

## Weltgröße einer Grid-Zelle. MUSS zur physischen Größe eurer Raum-Vorlagen
## passen (die generierten Blockout-Räume sind 16x16), sonst driften Türen
## benachbarter Räume auseinander.
@export var cell_size: Vector3 = Vector3(16.0, 0.0, 16.0)

## Node im Baum, das RoomGridGenerator als Skript trägt - im Inspector zuweisen.
@export var grid_generator: RoomGridGenerator

var _used_unique_rooms: Array[RoomData] = []
var _instances: Dictionary = {}  # Vector2i -> RoomInstance
var _current_layout: Dictionary = {}

## Baut eine komplett neue Ebene: neues Zufalls-Grid-Layout + neue
## Raum-Bestückung/Gegner.
func generate_new_stage() -> void:
	_current_layout = grid_generator.generate_layout()
	_instantiate_layout(_current_layout)

## Baut die NÄCHSTE Ebene mit dem GLEICHEN Grid-Muster wie zuvor
## (Isaac-Stil: "gleiches Muster, neue Ebene"). Würfelt dabei neu,
## welche konkreten Raum-Szenen und Gegner reinkommen.
func generate_next_stage_same_pattern() -> void:
	current_stage += 1
	_instantiate_layout(_current_layout)

func _instantiate_layout(layout: Dictionary) -> void:
	_clear_current_rooms()
	_used_unique_rooms.clear()

	for grid_pos in layout.keys():
		var cell: RoomGridGenerator.RoomCell = layout[grid_pos]
		var data: RoomData = _pick_room(cell.room_type, cell.exit_flags)
		if data == null:
			continue

		var world_pos := Vector3(grid_pos.x * cell_size.x, 0.0, grid_pos.y * cell_size.z)
		var room := load_room(data, Transform3D(Basis.IDENTITY, world_pos))
		if room:
			room.apply_exit_flags(cell.exit_flags)
			_instances[grid_pos] = room

func _clear_current_rooms() -> void:
	for room in _instances.values():
		if is_instance_valid(room):
			room.queue_free()
	_instances.clear()

func _pick_room(type: int, required_exit_flags: int) -> RoomData:
	var candidates: Array[RoomData] = []
	for data in room_pool:
		if data.room_type != type:
			continue
		if data.min_stage > current_stage:
			continue
		if data.unique_per_run and data in _used_unique_rooms:
			continue
		# Vorlage muss MINDESTENS die geforderten Ausgänge besitzen -
		# überschüssige Türen werden in RoomInstance.apply_exit_flags
		# dauerhaft zugesperrt.
		if (data.available_exits & required_exit_flags) != required_exit_flags:
			continue
		candidates.append(data)

	if candidates.is_empty():
		push_error("LevelGenerator: Kein passender Raum für Typ %s (Exits %d) gefunden!" % [type, required_exit_flags])
		return null

	var chosen: RoomData = _weighted_pick(candidates)
	if chosen.unique_per_run:
		_used_unique_rooms.append(chosen)
	return chosen

func _weighted_pick(candidates: Array[RoomData]) -> RoomData:
	var total_weight: float = 0.0
	for c in candidates:
		total_weight += c.spawn_weight

	var roll: float = randf() * total_weight
	var accumulated: float = 0.0
	for c in candidates:
		accumulated += c.spawn_weight
		if roll <= accumulated:
			return c

	return candidates.back()

func load_room(data: RoomData, spawn_transform: Transform3D) -> RoomInstance:
	var instance: Node3D = data.scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_transform = spawn_transform

	var room: RoomInstance = instance as RoomInstance
	if room:
		room.populate_enemies(enemy_pool, 2, 5)
	return room
