# res://scripts/vfx/blood_decal.gd
extends RefCounted
class_name BloodDecal

# ============================================================================
# BloodDecal — Blutspuren beim Tod eines Gegners.
# ============================================================================
# MEHRERE Flecken auf dem Boden (statt einem), bis zu zwei Wand-Spritzer
# (statt hoechstens einem), plus ein kurzer Partikel-Schwall fliegender
# Tropfen im Moment des Todes - "splasht" jetzt sichtbar statt nur einen
# einzelnen Fleck zu hinterlassen. Alles prozedural gebaut, kein Textur-
# Asset noetig - gleiches Prinzip wie der Brandfleck in bomb.gd
# (_spawn_scorch): unshaded, ungefiltertes Mesh mit Alpha, das nach einer
# Weile ausblendet.
#
# WARUM RAYCAST STATT EINFACH AN DER TODESPOSITION: ein Gegner stirbt oft in
# der Luft (Knockback, Sprung) oder leicht ueber dem Boden. Ohne den
# Boden-Raycast wuerde der Fleck freischwebend haengen statt auf dem Boden zu
# liegen.
#
# PERFORMANCE: das hier laeuft NUR EINMAL pro Gegnertod (kein Dauer-Effekt
# wie ein Trail) - selbst mehrere gleichzeitige Kills bleiben ein einmaliger,
# kurzer Spawn-Schwung statt fortlaufender Kosten pro Frame.

const FLOOR_COLOR: Color = Color(0.42, 0.03, 0.05, 0.85)
const WALL_COLOR: Color = Color(0.38, 0.03, 0.05, 0.75)

## Mehrere kleinere Flecken statt einem grossen - liest sich als Spritzmuster.
const FLOOR_SPLAT_COUNT_MIN: int = 3
const FLOOR_SPLAT_COUNT_MAX: int = 5
const FLOOR_SPLAT_SCATTER_RADIUS: float = 1.5
const FLOOR_RADIUS_MIN: float = 0.35
const FLOOR_RADIUS_MAX: float = 0.9

## Bis zu zwei Wandtreffer statt hoechstens einem.
const WALL_SPLAT_MAX_COUNT: int = 2
const WALL_SIZE_MIN: float = 0.5
const WALL_SIZE_MAX: float = 1.0
const WALL_CHECK_RADIUS: float = 2.5

const FLOOR_PROBE_UP: float = 1.0
const FLOOR_PROBE_DOWN: float = 4.0
const LIFETIME: float = 45.0
const FADE_TIME: float = 3.0
const RAYCAST_MASK: int = 1

## Fliegende Tropfen im Todesmoment - das eigentliche "Splashen", die Decals
## darunter sind nur, was danach liegen bleibt.
const DROPLET_COUNT: int = 20
const DROPLET_LIFETIME: float = 0.7
const DROPLET_SPREAD_DEG: float = 100.0
const DROPLET_VELOCITY_MIN: float = 3.0
const DROPLET_VELOCITY_MAX: float = 7.0
const DROPLET_GRAVITY: float = 14.0
const DROPLET_SIZE: float = 0.07
const DROPLET_COLOR: Color = Color(0.55, 0.03, 0.05, 1.0)


## context liefert Zugriff auf Szenenbaum und World3D (gleiches Prinzip wie
## RevengeGhost.spawn()/TurretProjectile.spawn()).
static func spawn(context: Node3D, origin: Vector3) -> void:
	if context == null or not is_instance_valid(context):
		return
	var parent: Node = context.get_tree().current_scene
	if parent == null:
		parent = context.get_tree().get_root()

	_spawn_droplet_burst(parent, origin)
	_spawn_floor_splats(parent, origin, context)
	_spawn_wall_splats(parent, origin, context)


## Kurzer, unbeleuchteter Partikel-Schwall - dieselbe Bauweise wie
## hit_spark_primary.tscn (one_shot, hohe Explosiveness), aber mit Schwerkraft
## und geringerer Geschwindigkeit, damit die Tropfen sichtbar einem Bogen
## folgen und zu Boden fallen statt geradlinig wegzuschiessen.
static func _spawn_droplet_burst(parent: Node, origin: Vector3) -> void:
	var process_mat := ParticleProcessMaterial.new()
	process_mat.direction = Vector3(0.0, 1.0, 0.0)
	process_mat.spread = DROPLET_SPREAD_DEG
	process_mat.initial_velocity_min = DROPLET_VELOCITY_MIN
	process_mat.initial_velocity_max = DROPLET_VELOCITY_MAX
	process_mat.gravity = Vector3(0.0, -DROPLET_GRAVITY, 0.0)
	process_mat.scale_min = 0.7
	process_mat.scale_max = 1.3
	process_mat.color = DROPLET_COLOR

	var quad_mat := StandardMaterial3D.new()
	quad_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	quad_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad_mat.albedo_color = DROPLET_COLOR
	quad_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	var quad := QuadMesh.new()
	quad.size = Vector2(DROPLET_SIZE, DROPLET_SIZE)
	quad.material = quad_mat

	var particles := GPUParticles3D.new()
	particles.name = "BloodDroplets"
	particles.emitting = false
	particles.amount = DROPLET_COUNT
	particles.lifetime = DROPLET_LIFETIME
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.randomness = 0.4
	particles.fixed_fps = 30
	particles.process_material = process_mat
	particles.draw_pass_1 = quad

	parent.add_child(particles)
	particles.global_position = origin
	particles.restart()
	particles.emitting = true

	# Selbstaendige Aufraeum-Zeit statt eines Dauer-Nodes - dieselbe
	# Begruendung wie vfx_manager.gd._schedule_cleanup().
	var cleanup: SceneTreeTimer = particles.get_tree().create_timer(DROPLET_LIFETIME + 0.5)
	cleanup.timeout.connect(func() -> void:
		if is_instance_valid(particles):
			particles.queue_free()
	)


## Mehrere kleinere Flecken statt einem grossen, verstreut um origin herum -
## jeder mit eigenem Boden-Raycast, damit auf unebenem/gestuftem Untergrund
## keiner freischwebt.
static func _spawn_floor_splats(parent: Node, origin: Vector3, context: Node3D) -> void:
	var count: int = randi_range(FLOOR_SPLAT_COUNT_MIN, FLOOR_SPLAT_COUNT_MAX)
	for i: int in range(count):
		var offset: Vector3 = Vector3.ZERO
		if i > 0:
			# Erster Fleck bleibt genau am Todesort - die uebrigen streuen
			# darum herum, wie echte Spritzer.
			var angle: float = randf() * TAU
			var dist: float = randf() * FLOOR_SPLAT_SCATTER_RADIUS
			offset = Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		_spawn_one_floor_splat(parent, origin + offset, context)


static func _spawn_one_floor_splat(parent: Node, origin: Vector3, context: Node3D) -> void:
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


## Prueft ALLE vier Himmelsrichtungen (statt nur bis zum ersten Treffer) und
## setzt an bis zu WALL_SPLAT_MAX_COUNT Stellen einen Spritzer.
static func _spawn_wall_splats(parent: Node, origin: Vector3, context: Node3D) -> void:
	var space_state := context.get_world_3d().direct_space_state
	var directions: Array = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	directions.shuffle()

	var placed: int = 0
	for dir: Vector3 in directions:
		if placed >= WALL_SPLAT_MAX_COUNT:
			break

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
		placed += 1


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
