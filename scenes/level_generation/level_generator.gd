extends Node
class_name LevelGenerator

@export var room_pool: Array[RoomData] = []
@export var current_stage: int = 1
@export var enemy_pool: Array[PackedScene] = []
@export var cell_size: Vector3 = Vector3(16.0, 0.0, 16.0)
@export var grid_generator: RoomGridGenerator
@export var autostart: bool = true
## Multiplikator für die Raumgröße. cell_size bleibt die BASIS-Größe der
## Room-Templates (16x16) - der tatsächliche Weltabstand zwischen Raum-
## Zentren wird zur Laufzeit mit diesem Faktor multipliziert. Skaliert den
## kompletten RoomRoot-Node hoch (Wände, Boden, Türen, Marker wachsen alle
## proportional mit), ohne die 9 Room-Szenen einzeln anfassen zu müssen.
@export var room_scale: float = 2.5

var _used_unique_rooms: Array[RoomData] = []
var _instances: Dictionary = {}
var _current_layout: Dictionary = {}

func _ready() -> void:
	if grid_generator == null:
		# Fallback: In der .tscn per Hand gesetzte NodePath-Exports lösen
		# sich nicht automatisch zu einer Node-Referenz auf (das passiert
		# nur beim Drag&Drop im Editor-Inspector). Deshalb hier zur
		# Sicherheit selbst danach suchen.
		grid_generator = get_parent().get_node_or_null("RoomGridGenerator") as RoomGridGenerator
		if grid_generator:
			print("[LevelGenerator] grid_generator war leer, per Fallback gefunden: %s" % grid_generator)

	print("[LevelGenerator] _ready() - autostart=%s, grid_generator=%s, room_pool.size()=%d" % [autostart, grid_generator, room_pool.size()])
	if autostart and grid_generator:
		# WICHTIG: NICHT synchron aus _ready() heraus generieren!
		# Während der initialen Ready-Kaskade der Szene ist die Root-Node
		# (current_scene) noch "busy" (blocked > 0), weil sie selbst gerade
		# ihre Kinder durchläuft - add_child() darauf schlägt in diesem
		# Fenster lautlos fehl ("Parent node is busy setting up children").
		# call_deferred verschiebt den Aufruf auf den Moment, in dem die
		# Ready-Kaskade fertig ist und current_scene nicht mehr blockiert.
		call_deferred("generate_new_stage")
	elif autostart and grid_generator == null:
		push_error("[LevelGenerator] Kein RoomGridGenerator gefunden! Node muss 'RoomGridGenerator' heißen und Geschwister-Node von LevelGenerator sein, ODER im Inspector manuell zugewiesen werden.")

func generate_new_stage() -> void:
	_current_layout = grid_generator.generate_layout()
	print("[LevelGenerator] Layout generiert: %d Zellen -> %s" % [_current_layout.size(), _current_layout.keys()])
	_instantiate_layout(_current_layout)

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
			print("[LevelGenerator] KEIN Raum gefunden für Zelle %s (type=%s, exit_flags=%s)" % [grid_pos, cell.room_type, cell.exit_flags])
			continue

		# world_pos nutzt cell_size * room_scale, damit der Grid-Abstand
		# zwischen Raum-Zentren mit der tatsächlichen (skalierten) Raum-
		# größe übereinstimmt - sonst würden sich größer skalierte Räume
		# gegenseitig überlappen.
		var world_pos := Vector3(grid_pos.x * cell_size.x * room_scale, 0.0, grid_pos.y * cell_size.z * room_scale)
		var room := load_room(data, Transform3D(Basis.IDENTITY, world_pos))
		if room == null:
			print("[LevelGenerator] load_room() lieferte null für %s (scene=%s) - ist die Root-Node vom Typ RoomInstance, oder ist add_child() fehlgeschlagen?" % [grid_pos, data.scene])
			continue

		room.apply_exit_flags(cell.exit_flags)
		# Gegner werden NICHT mehr sofort gespawnt, sondern erst wenn der
		# Player den Raum betritt (siehe RoomInstance.prepare_enemies /
		# on_player_entered). Hier werden nur die möglichen Gegner-Typen
		# und die Anzahl-Range hinterlegt.
		room.prepare_enemies(enemy_pool, 2, 5)
		_instances[grid_pos] = room
		print("[LevelGenerator] Raum instanziert bei %s: %s (type=%s)" % [grid_pos, data.scene.resource_path, cell.room_type])

	print("[LevelGenerator] Fertig. %d/%d Räume erfolgreich instanziert." % [_instances.size(), layout.size()])

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
	if data.scene == null:
		print("[LevelGenerator] RoomData hat keine scene zugewiesen!")
		return null
	var instance: Node3D = data.scene.instantiate()
	instance.scale = Vector3.ONE * room_scale
	get_tree().current_scene.add_child(instance)
	instance.global_transform = Transform3D(instance.global_transform.basis, spawn_transform.origin)
	var room := instance as RoomInstance
	if room == null:
		print("[LevelGenerator] Instanzierte Szene '%s' hat Root-Typ %s statt RoomInstance-Script!" % [data.scene.resource_path, instance.get_class()])
	return room
