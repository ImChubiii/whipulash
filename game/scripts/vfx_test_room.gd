extends Node

# ============================================================================
# VfxTestRoom — Admin/Debug: ein Raum mit JEDEM VFX aus "res://test vfx/"
# nacheinander aufgereiht.
# ============================================================================

const ROOM_OFFSET: Vector3 = Vector3(1200.0, 800.0, 0.0)
## War 6.0 - Rueckmeldung "grosse Partikeleffekte ueberschneiden sich",
## deutlich vergroessert. floor_size/grid_origin/Waende sind unten komplett
## aus diesem einen Wert abgeleitet, es muss also nirgends sonst etwas
## nachgezogen werden.
const PEDESTAL_SPACING: float = 16.0
const ROOM_MARGIN: float = 8.0
const FRONT_CLEARANCE: float = 8.0
const FLOOR_THICKNESS: float = 1.0
const WALL_HEIGHT: float = 10.0
const RAYCAST_MASK: int = 1

const RETURN_PAD_COLOR: Color = Color(0.2, 0.6, 0.9, 0.6)
const INTERACT_ACTION: String = "interact"

var _root: Node3D = null
var _built: bool = false
var _spawn_position: Vector3 = Vector3.ZERO
var _return_position: Vector3 = Vector3.ZERO

var _pads: Array = []
var _vfx_scenes: Array[PackedScene] = []
var _vfx_names: Array[String] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func teleport_player_in() -> void:
	var player: CharacterBody3D = _get_player()
	if player == null:
		return

	_return_position = player.global_position
	
	_ensure_built()
	_root.process_mode = Node.PROCESS_MODE_INHERIT

	_place_player(player, _spawn_position)

func teleport_player_out() -> void:
	var player: CharacterBody3D = _get_player()
	if player == null:
		return

	_place_player(player, _return_position)

	if _root != null and is_instance_valid(_root):
		_root.process_mode = Node.PROCESS_MODE_DISABLED

func _place_player(player: CharacterBody3D, pos: Vector3) -> void:
	player.global_position = pos
	player.velocity = Vector3.ZERO
	if player.has_method("set_buoyancy"):
		player.set_buoyancy(false)

func _get_player() -> CharacterBody3D:
	return get_tree().get_first_node_in_group(PartyManager.PLAYER_GROUP) as CharacterBody3D

func _scan_for_vfx(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				if not file_name.begins_with("."):
					_scan_for_vfx(path + "/" + file_name)
			else:
				if file_name.to_lower().ends_with(".tscn"):
					var full_path = path + "/" + file_name
					var scene = load(full_path) as PackedScene
					if scene:
						_vfx_scenes.append(scene)
						_vfx_names.append(file_name.get_basename())
			file_name = dir.get_next()

func _strip_cameras(node: Node) -> void:
	if node is Camera3D:
		node.queue_free()
		return
	for child in node.get_children():
		_strip_cameras(child)

func _ensure_built() -> void:
	if _built:
		return
	_built = true

	_root = Node3D.new()
	_root.name = "VfxTestRoom"
	get_tree().current_scene.add_child(_root)
	_root.global_position = ROOM_OFFSET
	_root.process_mode = Node.PROCESS_MODE_DISABLED

	_vfx_scenes.clear()
	_vfx_names.clear()
	_scan_for_vfx("res://test vfx")

	var columns: int = maxi(int(ceil(sqrt(float(_vfx_scenes.size())))), 1)
	var rows: int = int(ceil(float(_vfx_scenes.size()) / float(columns)))

	var floor_size := Vector2(
		columns * PEDESTAL_SPACING + ROOM_MARGIN * 2.0,
		rows * PEDESTAL_SPACING + ROOM_MARGIN * 2.0 + FRONT_CLEARANCE
	)
	_build_floor(floor_size)
	_build_walls(floor_size)
	_build_light()

	var grid_origin := Vector3(
		-((columns - 1) * PEDESTAL_SPACING) * 0.5,
		0.0,
		-(floor_size.y * 0.5) + ROOM_MARGIN
	)
	for i: int in range(_vfx_scenes.size()):
		var col: int = i % columns
		var row: int = i / columns
		var pos = _root.global_position + grid_origin + Vector3(col * PEDESTAL_SPACING, 0.0, row * PEDESTAL_SPACING)
		
		# Instantiate VFX
		var vfx_instance = _vfx_scenes[i].instantiate()
		_strip_cameras(vfx_instance)
		
		if vfx_instance is Node3D:
			_root.add_child(vfx_instance)
			vfx_instance.global_position = pos + Vector3(0, 1.0, 0)
		else:
			var holder = Node3D.new()
			_root.add_child(holder)
			holder.global_position = pos + Vector3(0, 1.0, 0)
			holder.add_child(vfx_instance)
		
		# Add Label
		var label = Label3D.new()
		label.text = _vfx_names[i]
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 32
		label.outline_size = 8
		_root.add_child(label)
		label.global_position = pos + Vector3(0.0, 3.0, 0.0)

	_spawn_position = _root.global_position + Vector3(0.0, 1.0, floor_size.y * 0.5 - FRONT_CLEARANCE * 0.5)

	_build_interact_pad(
		_spawn_position + Vector3(0.0, -1.0, 3.0), RETURN_PAD_COLOR,
		"[ ZURUECK ]", "[F] ZURUECK ZUM RUN",
		teleport_player_out
	)

func _build_floor(size: Vector2) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, FLOOR_THICKNESS, size.y)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.16, 0.20)
	mesh.material_override = mat
	_root.add_child(mesh)
	mesh.position = Vector3(0.0, -FLOOR_THICKNESS * 0.5, 0.0)

	var body := StaticBody3D.new()
	body.collision_layer = RAYCAST_MASK
	_root.add_child(body)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box.size
	col.shape = shape
	body.add_child(col)
	body.position = mesh.position

func _build_walls(size: Vector2) -> void:
	_build_one_wall(Vector3(size.x, WALL_HEIGHT, 1.0), Vector3(0.0, WALL_HEIGHT * 0.5, -size.y * 0.5))
	_build_one_wall(Vector3(size.x, WALL_HEIGHT, 1.0), Vector3(0.0, WALL_HEIGHT * 0.5, size.y * 0.5))
	_build_one_wall(Vector3(1.0, WALL_HEIGHT, size.y), Vector3(-size.x * 0.5, WALL_HEIGHT * 0.5, 0.0))
	_build_one_wall(Vector3(1.0, WALL_HEIGHT, size.y), Vector3(size.x * 0.5, WALL_HEIGHT * 0.5, 0.0))

func _build_one_wall(size: Vector3, pos: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.10, 0.10, 0.13)
	mesh.material_override = mat
	_root.add_child(mesh)
	mesh.position = pos

	var body := StaticBody3D.new()
	body.collision_layer = RAYCAST_MASK
	_root.add_child(body)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	body.position = pos

func _build_light() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60.0, -30.0, 0.0)
	light.light_energy = 1.0
	light.shadow_enabled = false
	_root.add_child(light)

func _build_interact_pad(pos: Vector3, color: Color, label_idle: String, label_active: String, callback: Callable) -> void:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = RAYCAST_MASK

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3.0, 2.0, 3.0)
	col.shape = box
	area.add_child(col)

	var csg := CSGBox3D.new()
	csg.size = Vector3(2.8, 0.2, 2.8)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	csg.material = mat
	area.add_child(csg)

	var label := Label3D.new()
	label.text = label_idle
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0.0, 2.0, 0.0)
	label.font_size = 48
	label.outline_size = 12
	area.add_child(label)

	_root.add_child(area)
	area.global_position = pos

	var entry: Dictionary = {
		"inside": false, "label": label,
		"idle": label_idle, "active": label_active,
		"callback": callback,
	}
	_pads.append(entry)

	area.body_entered.connect(func(b: Node) -> void:
		if b.is_in_group(PartyManager.PLAYER_GROUP):
			entry["inside"] = true
			label.text = label_active
	)
	area.body_exited.connect(func(b: Node) -> void:
		if b.is_in_group(PartyManager.PLAYER_GROUP):
			entry["inside"] = false
			label.text = label_idle
	)

func _unhandled_input(event: InputEvent) -> void:
	if _pads.is_empty():
		return

	var is_interact: bool = event.is_action_pressed(INTERACT_ACTION) \
		or (event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).physical_keycode == KEY_F)
	if not is_interact:
		return

	for entry: Dictionary in _pads:
		if entry["inside"]:
			(entry["callback"] as Callable).call()
			return
