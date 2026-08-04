extends StaticBody3D
class_name Turret

# ============================================================================
# Turret — unzerstoerbarer, stationaerer Geschuetz-Hazard.
# ============================================================================
# Baut sich komplett per Code auf (gleiches Prinzip wie lemonade.gd/pickup.gd
# - kein Asset-Import noetig, ein neuer Turret ist ein Funktionsaufruf).
#
# ZWEI MONTAGEARTEN (Mount):
#   WALL    - sitzt in einer Wandoeffnung, feuert von dort weg. Die Muster
#             STRAIGHT/CROSS_2/CROSS_3/CROSS_4 sind fuer diese Montage
#             gedacht ("gerade" bzw. "2/3/4 Schuesse pro Wand" - parallele
#             Schusslinien quer zur Wand).
#   PILLAR  - freistehende Saeule, feuert in alle Richtungen. Die Muster
#             PLUS/X_DIAGONAL/ROTATING sind dafuer gedacht.
#
# DREI MUNITIONSARTEN (AmmoKind):
#   NORMAL  - geradliniges Geschoss (TurretProjectile, homing_strength = 0).
#   HOMING  - verfolgt den Spieler mit 30 % Staerke (siehe
#             turret_projectile.gd, HOMING_TURN_RATE_DEG * 0.3). Selten.
#   BOMB    - feuert eine echte Bomb-Instanz (scripts/bomb.gd) - dieselbe
#             Bombe, die auch der Spieler wirft/legt. Selten.
#
# QUADRATISCHE COLLISIONSHAPE: Design-Vorgabe. BoxShape3D mit gleicher
# X/Z-Kantenlaenge (body_size), unabhaengig von Montageart oder Muster.

enum Mount { WALL, PILLAR }
enum Pattern { STRAIGHT, CROSS_2, CROSS_3, CROSS_4, PLUS, X_DIAGONAL, ROTATING }
enum AmmoKind { NORMAL, HOMING, BOMB }

@export var mount: Mount = Mount.PILLAR
@export var pattern: Pattern = Pattern.PLUS
@export var ammo_kind: AmmoKind = AmmoKind.NORMAL

@export var fire_interval: float = 2.2
@export var projectile_speed: float = 15.0
@export var projectile_damage: float = 12.0
## 30 % Verfolgungsstaerke laut Vorgabe - siehe turret_projectile.gd.
@export var homing_strength: float = 0.3
@export var bomb_fuse_time: float = 1.6
@export var bomb_launch_speed: float = 9.0

## Kantenlaenge der quadratischen CollisionShape (X UND Z gleich).
@export var body_size: float = 2.2
@export var body_height: float = 2.6

## Nur bei Pattern.ROTATING: Grad pro Sekunde.
@export var rotation_speed_deg: float = 50.0
## Streuwinkel zwischen parallelen CROSS_*-Schusslinien in Grad.
@export var cross_spread_deg: float = 12.0

@export var muzzle_color: Color = Color(0.85, 0.20, 0.20)
@export var debug_logging: bool = false

var _timer: float = 0.0
var _rotation_offset_deg: float = 0.0
var _mesh: MeshInstance3D = null
var _light: OmniLight3D = null


func _debug(msg: String) -> void:
	if debug_logging:
		print("Turret DEBUG [%s]: %s" % [name, msg])


func _ready() -> void:
	add_to_group("turrets")
	# BEWUSST Godots Default-Layer (1) behalten, NICHT auf die Gegner-Ebene
	# (4) umstellen: Waende/Boden in diesem Projekt liegen ohne expliziten
	# Layer-Override ebenfalls auf 1 (siehe room_combat_*.tscn), und genau
	# das ist die Ebene, gegen die move_and_slide() von Spieler und Gegnern
	# kollidiert. Ein Turret auf Layer 4 waere unsichtbar durchlaufbar -
	# "unzerstoerbarer Hazard" heisst hier ausdruecklich auch "physisch im
	# Weg", nicht nur "nimmt keinen Schaden".

	_timer = fire_interval * randf_range(0.3, 1.0)  # entzerrt gleichzeitig gespawnte Turrets.
	_build_collision()
	_build_visual()


func _build_collision() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(body_size, body_height, body_size)
	shape.shape = box
	shape.position = Vector3(0.0, body_height * 0.5, 0.0)
	add_child(shape)


func _build_visual() -> void:
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(body_size, body_height, body_size)

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.16, 0.16, 0.19)
	mat.emission_enabled = true
	mat.emission = muzzle_color
	mat.emission_energy_multiplier = 0.6
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	_mesh = MeshInstance3D.new()
	_mesh.name = "Visual"
	_mesh.mesh = box_mesh
	_mesh.material_override = mat
	_mesh.position = Vector3(0.0, body_height * 0.5, 0.0)
	add_child(_mesh)

	# Kleine Muendungsleuchte oben drauf - macht auf einen Blick klar, dass
	# das hier kein Deko-Wuerfel, sondern eine aktive Gefahrenquelle ist.
	_light = OmniLight3D.new()
	_light.light_color = muzzle_color
	_light.light_energy = 1.2
	_light.omni_range = 4.0
	_light.shadow_enabled = false
	_light.position = Vector3(0.0, body_height + 0.3, 0.0)
	add_child(_light)


func _physics_process(delta: float) -> void:
	if pattern == Pattern.ROTATING:
		_rotation_offset_deg = fmod(_rotation_offset_deg + rotation_speed_deg * delta, 360.0)

	_timer -= delta
	if _timer <= 0.0:
		_timer = maxf(fire_interval, 0.1)
		_fire()


func _fire() -> void:
	var directions: Array[Vector3] = _pattern_directions()
	if directions.is_empty():
		return

	_flash_muzzle()

	for dir: Vector3 in directions:
		var origin: Vector3 = global_position + Vector3.UP * (body_height * 0.6) + dir * (body_size * 0.6)
		match ammo_kind:
			AmmoKind.BOMB:
				_fire_bomb(dir, origin)
			AmmoKind.HOMING:
				TurretProjectile.spawn(self, origin, dir, projectile_speed, projectile_damage, homing_strength, self)
			_:
				TurretProjectile.spawn(self, origin, dir, projectile_speed, projectile_damage, 0.0, self)


func _fire_bomb(dir: Vector3, origin: Vector3) -> void:
	var bomb := Bomb.new()
	bomb.fuse_time = bomb_fuse_time
	bomb.thrower = self

	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(bomb)
	bomb.global_position = origin
	bomb.launch(dir * bomb_launch_speed + Vector3.UP * (bomb_launch_speed * 0.35))


func _flash_muzzle() -> void:
	if _light == null:
		return
	var base_energy: float = _light.light_energy
	var tween: Tween = create_tween()
	tween.tween_property(_light, "light_energy", base_energy * 3.0, 0.05)
	tween.tween_property(_light, "light_energy", base_energy, 0.25)


## Liefert die Feuerrichtungen fuer das aktuelle Muster, in Weltkoordinaten.
## PLUS/X_DIAGONAL sind WELTACHSEN-ausgerichtet (kardinal) statt an die
## eigene Rotation des Turrets gebunden - eine freistehende Saeule hat keine
## bevorzugte "Vorderseite", ihr Muster soll unabhaengig davon sein, wie sie
## im Editor gedreht im Raum steht.
func _pattern_directions() -> Array[Vector3]:
	var dirs: Array[Vector3] = []
	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() < 0.0001:
		forward = Vector3.FORWARD
	forward = forward.normalized()
	var right: Vector3 = forward.cross(Vector3.UP).normalized()

	match pattern:
		Pattern.STRAIGHT:
			dirs.append(forward)

		Pattern.CROSS_2, Pattern.CROSS_3, Pattern.CROSS_4:
			var count: int = 2 if pattern == Pattern.CROSS_2 else (3 if pattern == Pattern.CROSS_3 else 4)
			var half: float = float(count - 1) * 0.5
			for i: int in range(count):
				var offset_deg: float = (float(i) - half) * cross_spread_deg
				dirs.append(forward.rotated(Vector3.UP, deg_to_rad(offset_deg)))

		Pattern.PLUS:
			dirs.append(Vector3.FORWARD)
			dirs.append(Vector3.BACK)
			dirs.append(Vector3.LEFT)
			dirs.append(Vector3.RIGHT)

		Pattern.X_DIAGONAL:
			for deg: int in [45, 135, 225, 315]:
				var rad: float = deg_to_rad(float(deg))
				dirs.append(Vector3(sin(rad), 0.0, cos(rad)))

		Pattern.ROTATING:
			var rad: float = deg_to_rad(_rotation_offset_deg)
			dirs.append(Vector3(sin(rad), 0.0, cos(rad)))

	return dirs
