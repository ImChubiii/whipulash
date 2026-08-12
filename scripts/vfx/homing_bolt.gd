extends Node3D
class_name HomingBolt

# ============================================================================
# HomingBolt — generischer fliegender Verfolger fuer Item-Minions.
# ============================================================================
# Verallgemeinert den Flug-/Zielverfolgungs-Code aus revenge_ghost.gd (gleiche
# Bewegungslogik: geradliniges Homing + leichtes seitliches Schweben), aber
# statt eines fest verdrahteten "Schaden + Knockback" bekommt der Aufrufer
# einen eigenen on_strike-Callback (target: Node3D) -> void. Damit teilen
# sich boom_bot (einmalige Explosion), alarmbot (einmaliger Vulnerable-Debuff)
# und prowler (wiederholtes Confused/Silenced auf mehrere Ziele nacheinander)
# denselben Flugcode, statt ihn dreimal zu duplizieren.
#
# RETARGET: wenn true, sucht der Bolt nach jedem Treffer automatisch den
# naechsten lebenden Gegner in der Gruppe "enemies" und fliegt weiter, bis
# die Lebensdauer ablaeuft (prowler). Wenn false, verschwindet er nach dem
# ersten Treffer (boom_bot, alarmbot).

const HIT_RANGE: float = 1.3
const WEAVE_AMPLITUDE: float = 0.5
const WEAVE_SPEED: float = 6.0

var _target: Node3D = null
var _source: Node = null
var _on_strike: Callable
var _retarget: bool = false
var _speed: float = 14.0
var _lifetime: float = 4.0
var _age: float = 0.0
var _weave_time: float = 0.0
var _struck_ids: Array[int] = []
var _color: Color = Color(0.7, 0.2, 0.9)

var _mesh: MeshInstance3D = null
var _light: OmniLight3D = null


## context liefert Zugriff auf den Szenenbaum (gleiches Prinzip wie
## RevengeGhost.spawn()/TurretProjectile.spawn()).
static func spawn(
		context: Node, origin: Vector3, initial_target: Node3D, color: Color,
		on_strike: Callable, speed: float = 14.0, lifetime: float = 4.0,
		retarget: bool = false, source: Node = null
) -> HomingBolt:
	if context == null or not is_instance_valid(context):
		return null
	if initial_target == null or not is_instance_valid(initial_target):
		return null

	var bolt := HomingBolt.new()
	bolt._target = initial_target
	bolt._on_strike = on_strike
	bolt._retarget = retarget
	bolt._speed = speed
	bolt._lifetime = lifetime
	bolt._source = source
	bolt._color = color

	var parent: Node = context.get_tree().current_scene
	if parent == null:
		parent = context.get_tree().get_root()
	parent.add_child(bolt)
	bolt.global_position = origin
	bolt._build_visual()
	return bolt


func _build_visual() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.7
	sphere.radial_segments = 10
	sphere.rings = 6

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = _color
	mat.emission_enabled = true
	mat.emission = _color
	mat.emission_energy_multiplier = 2.0
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	_mesh = MeshInstance3D.new()
	_mesh.mesh = sphere
	_mesh.material_override = mat
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh)

	_light = OmniLight3D.new()
	_light.light_color = _color
	_light.light_energy = 1.2
	_light.omni_range = 3.0
	_light.shadow_enabled = false
	add_child(_light)


func _process(delta: float) -> void:
	_age += delta
	if _age >= _lifetime:
		_dissipate()
		return

	if _target == null or not is_instance_valid(_target):
		_target = _find_next_target()
		if _target == null:
			_dissipate()
			return

	var to_target: Vector3 = (_target.global_position + Vector3.UP * 1.0) - global_position
	var dist: float = to_target.length()

	if dist <= HIT_RANGE:
		_strike()
		return

	var dir: Vector3 = to_target / maxf(dist, 0.001)
	global_position += dir * _speed * delta

	_weave_time += delta * WEAVE_SPEED
	var side: Vector3 = dir.cross(Vector3.UP)
	if side.length_squared() > 0.0001:
		global_position += side.normalized() * sin(_weave_time) * WEAVE_AMPLITUDE * delta
	if dir.length_squared() > 0.0001:
		look_at(global_position + dir, Vector3.UP)


func _strike() -> void:
	if _target != null and is_instance_valid(_target):
		_struck_ids.append(_target.get_instance_id())
		# BUGFIX "Crash beim Charakterwechsel waehrend Winters Plasma fliegt":
		# _on_strike ist eine Closure, die an den abfeuernden Combat-Node
		# gebunden ist (siehe combat_winter.gd::_perform_primary()). Der Bolt
		# selbst haengt unabhaengig unter current_scene und ueberlebt einen
		# Charakterwechsel - der gebundene Combat-Node aber nicht (party_manager.gd
		# switch_to() queue_free()'t ihn sofort). Ohne is_valid()-Check landete
		# der Aufruf auf einer bereits freigegebenen Instanz.
		if _on_strike.is_valid():
			_on_strike.call(_target)

	if not _retarget:
		_dissipate()
		return

	_target = _find_next_target()
	if _target == null:
		_dissipate()


func _find_next_target() -> Node3D:
	var best: Node3D = null
	var best_dist: float = INF
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		if _struck_ids.has(node.get_instance_id()):
			continue
		var health: Node = node.find_child("Health", true, false)
		if health != null and health.has_method("is_alive") and not health.is_alive():
			continue
		var d: float = global_position.distance_to((node as Node3D).global_position)
		if d < best_dist:
			best_dist = d
			best = node as Node3D
	return best


func _dissipate() -> void:
	set_process(false)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	if _mesh != null and is_instance_valid(_mesh):
		tween.tween_property(_mesh, "scale", Vector3.ZERO, 0.25)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if _light != null and is_instance_valid(_light):
		tween.tween_property(_light, "light_energy", 0.0, 0.25)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
