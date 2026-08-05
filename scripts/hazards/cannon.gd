extends StaticBody3D
class_name Cannon

# ============================================================================
# Cannon — stationaerer, auf den Spieler ausgerichteter Geschuetz-Hazard.
# ============================================================================
# Anders als Turret (turret.gd, feste Schussmuster ohne Zielverfolgung)
# verfolgt der Cannon den Spieler aktiv: der Lauf dreht sich zu ihm, und
# erst wenn der Lauf naeherungsweise ausgerichtet ist UND (optional) freie
# Sichtlinie besteht, feuert er - ein schwereres, langsameres Geschoss als
# TurretProjectile normalerweise verschiesst, dafuer klar telegraphiert
# (Muendungsblitz kurz vor dem Schuss, gleiches Prinzip wie turret.gd).
#
# Baut sich komplett per Code auf, gleiches Prinzip wie turret.gd/lemonade.gd
# - kein Asset-Import noetig, ein neuer Cannon ist ein Funktionsaufruf bzw.
# eine per Hand in eine Raum-.tscn gesetzte Instanz.

@export var detect_range: float = 18.0
@export var fire_interval: float = 3.2
@export var aim_turn_speed_deg: float = 140.0
## Maximale Winkelabweichung (Grad) zwischen Lauf und Spieler, bei der noch
## gefeuert wird - verhindert einen Schuss "quer" waehrend der Lauf noch
## nachdreht.
@export var fire_angle_tolerance_deg: float = 20.0
@export var projectile_speed: float = 9.0
@export var projectile_damage: float = 18.0
## Leichtes Nachziehen des Geschosses, damit ein bereits abgefeuerter Schuss
## nicht durch einen scharfen Seitenschritt trivial zu umgehen ist - deutlich
## schwaecher als Turret.AmmoKind.HOMING (0.3), siehe turret_projectile.gd.
@export var projectile_homing_strength: float = 0.12
@export var require_line_of_sight: bool = true
@export var line_of_sight_mask: int = 1

@export var base_size: float = 2.0
@export var base_height: float = 1.4
@export var barrel_length: float = 2.4
@export var barrel_radius: float = 0.35

@export var muzzle_color: Color = Color(0.95, 0.35, 0.1)
@export var debug_logging: bool = false

var _timer: float = 0.0
var _barrel_pivot: Node3D = null
var _muzzle_light: OmniLight3D = null


func _debug(msg: String) -> void:
	if debug_logging:
		print("Cannon DEBUG [%s]: %s" % [name, msg])


func _ready() -> void:
	add_to_group("cannons")
	# Gleicher Grund wie in turret.gd: Godots Default-Layer (1) behalten,
	# NICHT auf die Gegner-Ebene umstellen - der Cannon soll ein physisches
	# Hindernis bleiben, kein unsichtbar durchlaufbares Deko-Objekt.
	_timer = fire_interval * randf_range(0.4, 1.0)
	_build_collision()
	_build_visual()


func _build_collision() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(base_size, base_height, base_size)
	shape.shape = box
	shape.position = Vector3(0.0, base_height * 0.5, 0.0)
	add_child(shape)


func _build_visual() -> void:
	var base_mesh := BoxMesh.new()
	base_mesh.size = Vector3(base_size, base_height, base_size)

	var base_mat := StandardMaterial3D.new()
	base_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	base_mat.albedo_color = Color(0.14, 0.13, 0.15)
	base_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var base_visual := MeshInstance3D.new()
	base_visual.name = "Base"
	base_visual.mesh = base_mesh
	base_visual.material_override = base_mat
	base_visual.position = Vector3(0.0, base_height * 0.5, 0.0)
	add_child(base_visual)

	_barrel_pivot = Node3D.new()
	_barrel_pivot.name = "BarrelPivot"
	_barrel_pivot.position = Vector3(0.0, base_height, 0.0)
	add_child(_barrel_pivot)

	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = barrel_radius
	barrel_mesh.bottom_radius = barrel_radius
	barrel_mesh.height = barrel_length

	var barrel_mat := StandardMaterial3D.new()
	barrel_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	barrel_mat.albedo_color = Color(0.2, 0.19, 0.21)
	barrel_mat.emission_enabled = true
	barrel_mat.emission = muzzle_color
	barrel_mat.emission_energy_multiplier = 0.35
	barrel_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var barrel := MeshInstance3D.new()
	barrel.name = "Barrel"
	barrel.mesh = barrel_mesh
	barrel.material_override = barrel_mat
	# CylinderMesh liegt per Default entlang der lokalen Y-Achse. Um 90 Grad
	# um X gekippt zeigt er stattdessen entlang -Z (Feuerrichtung des
	# Pivots), und um die halbe Laenge nach vorn verschoben sitzt seine
	# Basis am Pivot statt seine Mitte.
	barrel.rotation.x = deg_to_rad(90.0)
	barrel.position = Vector3(0.0, 0.0, -barrel_length * 0.5)
	_barrel_pivot.add_child(barrel)

	_muzzle_light = OmniLight3D.new()
	_muzzle_light.light_color = muzzle_color
	_muzzle_light.light_energy = 0.0
	_muzzle_light.omni_range = 5.0
	_muzzle_light.shadow_enabled = false
	_muzzle_light.position = Vector3(0.0, 0.0, -barrel_length)
	_barrel_pivot.add_child(_muzzle_light)


func _physics_process(delta: float) -> void:
	if _barrel_pivot == null:
		return

	var player: Node3D = _find_player()
	if player == null:
		return

	var to_player: Vector3 = player.global_position - _barrel_pivot.global_position
	to_player.y = 0.0
	var distance: float = to_player.length()
	if distance > detect_range or distance < 0.01:
		return
	var wanted_dir: Vector3 = to_player.normalized()

	var current_dir: Vector3 = -_barrel_pivot.global_transform.basis.z
	current_dir.y = 0.0
	if current_dir.length_squared() < 0.0001:
		current_dir = Vector3.FORWARD
	current_dir = current_dir.normalized()

	var angle: float = current_dir.signed_angle_to(wanted_dir, Vector3.UP)
	var max_turn: float = deg_to_rad(aim_turn_speed_deg) * delta
	_barrel_pivot.rotate_y(clampf(angle, -max_turn, max_turn))

	_timer -= delta
	if _timer > 0.0:
		return

	# BUGFIX "Kanone schiesst nie": vorher wurde _timer HIER SCHON auf den
	# vollen fire_interval zurueckgesetzt, bevor ueberhaupt geprueft wurde,
	# ob Winkel/Sichtlinie passen. Kreist der Spieler nah genug um die
	# Kanone, dass ihre Winkelgeschwindigkeit die Nachdreh-Geschwindigkeit
	# des Laufs (aim_turn_speed_deg) uebersteigt, war der Lauf beim naechsten
	# Tick NIE ausgerichtet - jeder Tick verstrich ergebnislos, und die
	# Kanone wartete danach erneut die vollen fire_interval Sekunden, ohne
	# es zwischendurch nochmal zu versuchen. Fix: der Cooldown wird nur nach
	# einem TATSAECHLICHEN Schuss zurueckgesetzt; bis dahin wird JEDEN Frame
	# neu geprueft.
	if absf(angle) > deg_to_rad(fire_angle_tolerance_deg):
		return
	if require_line_of_sight and not _has_line_of_sight(player):
		_debug("Kein freies Schussfeld - Schuss ausgelassen.")
		return

	_timer = maxf(fire_interval, 0.5)
	_fire(wanted_dir)


func _fire(direction: Vector3) -> void:
	_flash_muzzle()
	var origin: Vector3 = _barrel_pivot.global_position + (-_barrel_pivot.global_transform.basis.z) * barrel_length
	TurretProjectile.spawn(self, origin, direction, projectile_speed, projectile_damage, projectile_homing_strength, self)


func _flash_muzzle() -> void:
	if _muzzle_light == null:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_muzzle_light, "light_energy", 3.0, 0.05)
	tween.tween_property(_muzzle_light, "light_energy", 0.0, 0.3)


func _has_line_of_sight(player: Node3D) -> bool:
	var space_state := get_world_3d().direct_space_state
	var from: Vector3 = _barrel_pivot.global_position
	var to: Vector3 = player.global_position + Vector3.UP * 1.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = line_of_sight_mask
	query.exclude = [self]
	return space_state.intersect_ray(query).is_empty()


func _find_player() -> Node3D:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null
