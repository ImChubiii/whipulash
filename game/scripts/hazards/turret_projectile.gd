extends Node3D
class_name TurretProjectile

# ============================================================================
# TurretProjectile — Geschoss eines Turret (turret.gd).
# ============================================================================
# Bewegt sich per Raycast-Vorausschau (nicht ueber Area3D-Kollision): so
# lassen sich Wandabpraller und "faellt in den Abgrund" mit derselben
# einfachen Technik loesen, die auch enemy_ai.gd fuer Kanten-/Hindernis-
# Checks benutzt (_measure_drop_depth, _is_ledge_ahead).
#
# HOMING (30 % Staerke): begrenzte Drehrate statt perfektem Tracking - das
# Geschoss dreht sich hoechstens HOMING_TURN_RATE_DEG * homing_strength Grad
# pro Sekunde in Richtung Spieler. Bei homing_strength = 0.3 lässt sich ein
# Homing-Schuss also durch einen scharfen Richtungswechsel noch abschuetteln.
#
# LEBENSDAUER: bricht nach MAX_BOUNCES Wandabprallern oder LIFETIME Sekunden
# ab, faellt zusaetzlich in einen erkannten Abgrund (kein Boden mehr unter
# dem naechsten Schritt) - "existieren also nicht unendlich".

const LIFETIME: float = 6.0
const MAX_BOUNCES: int = 3
const RAYCAST_MASK: int = 1
const HOMING_TURN_RATE_DEG: float = 140.0
const HIT_RANGE: float = 1.2
const FLOOR_PROBE_DEPTH: float = 3.0
const FALL_DESPAWN_Y: float = -80.0

var velocity: Vector3 = Vector3.ZERO
var speed: float = 14.0
var damage: float = 10.0
## 0.0 = normales Geschoss, > 0.0 = Homing-Staerke (0.3 = "30 % Staerke").
var homing_strength: float = 0.0
var source: Node = null

var _age: float = 0.0
var _bounces: int = 0
var _falling: bool = false
var _fall_speed: float = 2.0


## Bequemer Einzeiler fuer turret.gd - context liefert Zugriff auf den
## Szenenbaum (dasselbe Prinzip wie RevengeGhost.spawn()/Pickup.create()).
static func spawn(context: Node, origin: Vector3, direction: Vector3, p_speed: float, p_damage: float, p_homing_strength: float = 0.0, p_source: Node = null) -> TurretProjectile:
	if context == null or not is_instance_valid(context):
		return null
	var dir: Vector3 = direction
	dir.y = 0.0
	if dir.length_squared() < 0.0001:
		return null
	dir = dir.normalized()

	var proj := TurretProjectile.new()
	proj.velocity = dir * p_speed
	proj.speed = p_speed
	proj.damage = p_damage
	proj.homing_strength = p_homing_strength
	proj.source = p_source

	var parent: Node = context.get_tree().current_scene
	if parent == null:
		parent = context.get_tree().get_root()
	parent.add_child(proj)
	proj.global_position = origin
	proj._build_visual()
	proj.add_to_group("projectiles")
	return proj


func _build_visual() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.44
	sphere.radial_segments = 8
	sphere.rings = 4

	var color: Color = Color(0.78, 0.35, 0.95) if homing_strength > 0.0 else Color(1.0, 0.35, 0.15)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.5
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var mesh := MeshInstance3D.new()
	mesh.name = "Visual"
	mesh.mesh = sphere
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh)

	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 1.1
	light.omni_range = 3.5
	light.shadow_enabled = false
	add_child(light)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return

	if _falling:
		_fall_speed += 30.0 * delta
		global_position.y -= _fall_speed * delta
		if global_position.y < FALL_DESPAWN_Y:
			queue_free()
		return

	if homing_strength > 0.0:
		_apply_homing(delta)

	_move_and_bounce(delta)
	if not is_instance_valid(self) or _falling:
		return

	_check_floor_ahead()
	if not is_instance_valid(self) or _falling:
		return

	_check_player_hit()


func _apply_homing(delta: float) -> void:
	var player: Node3D = _find_player()
	if player == null:
		return
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() < 0.1:
		return

	var current_dir: Vector3 = velocity.normalized()
	var wanted_dir: Vector3 = to_player.normalized()
	var angle: float = current_dir.signed_angle_to(wanted_dir, Vector3.UP)
	var max_turn: float = deg_to_rad(HOMING_TURN_RATE_DEG * homing_strength) * delta
	var turn: float = clampf(angle, -max_turn, max_turn)
	velocity = current_dir.rotated(Vector3.UP, turn) * speed


## Kurze Raycast-Vorausschau statt Area3D-Kollision: liefert eine echte
## Aufprall-Normale, die fuer einen glaubwuerdigen Abprall (Vector3.bounce)
## noetig ist.
func _move_and_bounce(delta: float) -> void:
	var step: Vector3 = velocity * delta
	if step.length_squared() < 0.0001:
		return

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, global_position + step * 1.4)
	query.collision_mask = RAYCAST_MASK
	query.exclude = [self]
	var result := space_state.intersect_ray(query)

	if not result.is_empty():
		_bounces += 1
		if _bounces > MAX_BOUNCES:
			_start_falling()
			return
		velocity = velocity.bounce(result.normal)
		global_position = result.position + result.normal * 0.25
	else:
		global_position += step


## Kein Boden mehr unter dem naechsten Schritt -> das Geschoss ist gerade
## ueber einen Abgrund geflogen und faellt hinein.
func _check_floor_ahead() -> void:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		global_position, global_position - Vector3(0.0, FLOOR_PROBE_DEPTH, 0.0)
	)
	query.collision_mask = RAYCAST_MASK
	query.exclude = [self]
	if space_state.intersect_ray(query).is_empty():
		_start_falling()


func _start_falling() -> void:
	_falling = true
	_fall_speed = 2.0


func _check_player_hit() -> void:
	var player: Node3D = _find_player()
	if player == null:
		return
	if global_position.distance_to(player.global_position) > HIT_RANGE:
		return
	var health: Node = player.find_child("Health", true, false)
	if health != null and health.has_method("take_damage"):
		health.call("take_damage", damage, source)
	queue_free()


func _find_player() -> Node3D:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null
