# res://scripts/vfx/blood_decal.gd
extends RefCounted
class_name BloodDecal

# ============================================================================
# BloodDecal — Blutspuren beim Tod eines Gegners.
# ============================================================================
# Ein Fleck auf dem Boden, plus (falls der Gegner nah genug an einer Wand
# stand) ein Spritzer dort. Prozedural gebaut, kein Textur-Asset noetig -
# gleiches Prinzip wie der Brandfleck in bomb.gd (_spawn_scorch): ein
# unshaded, ungefiltertes Mesh mit Alpha, das nach einer Weile ausblendet.
#
# WARUM RAYCAST STATT EINFACH AN DER TODESPOSITION: ein Gegner stirbt oft in
# der Luft (Knockback, Sprung) oder leicht ueber dem Boden. Ohne den
# Boden-Raycast wuerde der Fleck freischwebend haengen statt auf dem Boden zu
# liegen.

const FLOOR_COLOR: Color = Color(0.42, 0.03, 0.05, 0.85)
const WALL_COLOR: Color = Color(0.38, 0.03, 0.05, 0.75)
const FLOOR_RADIUS_MIN: float = 0.7
const FLOOR_RADIUS_MAX: float = 1.4
const WALL_SIZE_MIN: float = 0.6
const WALL_SIZE_MAX: float = 1.1
const WALL_CHECK_RADIUS: float = 2.5
const FLOOR_PROBE_UP: float = 1.0
const FLOOR_PROBE_DOWN: float = 4.0
const LIFETIME: float = 45.0
const FADE_TIME: float = 3.0
const RAYCAST_MASK: int = 1


## context liefert Zugriff auf Szenenbaum und World3D (gleiches Prinzip wie
## RevengeGhost.spawn()/TurretProjectile.spawn()).
static func spawn(context: Node3D, origin: Vector3) -> void:
	if context == null or not is_instance_valid(context):
		return
	var parent: Node = context.get_tree().current_scene
	if parent == null:
		parent = context.get_tree().get_root()

	_spawn_floor_splat(parent, origin, context)
	_spawn_wall_splat(parent, origin, context)


static func _spawn_floor_splat(parent: Node, origin: Vector3, context: Node3D) -> void:
	var space_state := context.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		origin + Vector3.UP * FLOOR_PROBE_UP, origin - Vector3.UP * FLOOR_PROBE_DOWN
	)
	query.collision_mask = RAYCAST_MASK
	var result := space_state.intersect_ray(query)
	var floor_pos: Vector3 = result.position if not result.is_empty() else origin

	var radius: float = randf_range(FLOOR_RADIUS_MIN, FLOOR_RADIUS_MAX)
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.03
	disc.radial_segments = 10

	var mat := _make_material(FLOOR_COLOR)
	var mesh := MeshInstance3D.new()
	mesh.name = "BloodFloor"
	mesh.mesh = disc
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mesh)
	mesh.global_position = floor_pos + Vector3.UP * 0.02
	mesh.rotation.y = randf() * TAU
	# Leicht unregelmaessig statt einem perfekten Kreis - liest sich mehr
	# nach Spritzer, weniger nach gestempeltem Aufkleber.
	mesh.scale = Vector3(1.0, 1.0, randf_range(0.65, 1.35))

	_fade_and_free(mesh, mat)


static func _spawn_wall_splat(parent: Node, origin: Vector3, context: Node3D) -> void:
	var space_state := context.get_world_3d().direct_space_state
	var directions: Array = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	directions.shuffle()

	for dir: Vector3 in directions:
		var from: Vector3 = origin + Vector3.UP * 1.0
		var query := PhysicsRayQueryParameters3D.create(from, from + dir * WALL_CHECK_RADIUS)
		query.collision_mask = RAYCAST_MASK
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			continue
		# Nahezu waagerechte Normale (Boden/Decke aus einem Streifschuss)
		# ueberspringen - look_at() unten braucht eine Normale, die klar von
		# Vector3.UP abweicht.
		if absf(result.normal.dot(Vector3.UP)) > 0.9:
			continue

		var size: float = randf_range(WALL_SIZE_MIN, WALL_SIZE_MAX)
		var quad := QuadMesh.new()
		quad.size = Vector2(size, size)

		var mat := _make_material(WALL_COLOR)
		var mesh := MeshInstance3D.new()
		mesh.name = "BloodWall"
		mesh.mesh = quad
		mesh.material_override = mat
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(mesh)
		mesh.global_position = result.position + result.normal * 0.03
		mesh.look_at(mesh.global_position + result.normal, Vector3.UP)

		_fade_and_free(mesh, mat)
		return  # nur EIN Wandspritzer pro Tod.


static func _make_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_receive_shadows = true
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	return mat


static func _fade_and_free(mesh: MeshInstance3D, mat: StandardMaterial3D) -> void:
	var tween: Tween = mesh.create_tween()
	tween.tween_interval(maxf(LIFETIME - FADE_TIME, 0.0))
	tween.tween_property(mat, "albedo_color:a", 0.0, FADE_TIME)
	tween.tween_callback(func() -> void:
		if is_instance_valid(mesh):
			mesh.queue_free()
	)
