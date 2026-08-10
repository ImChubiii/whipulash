extends CustomEnemyBase
class_name PlasmaBeamBot

# ============================================================================
# Plasmastrahl-Bot — fliegender Gegner.
# ============================================================================
# Fliegt langsam ueber dem Schlachtfeld (ueber Bodenhindernissen hinweg),
# laedt sichtbar auf und zieht danach einen durchgehenden Laser ueber den
# Boden: eine gerade Linie, die waehrend BEAM_DURATION von einem Start- zu
# einem Endpunkt "wandert" und dabei genau die Stelle kreuzt, an der der
# Spieler beim Feuern stand - wer nicht seitlich ausweicht, steht laenger
# im Feuer und sammelt burn-Ticks.

const BURN_TICK_INTERVAL: float = 0.4
const BURN_DAMAGE_PER_TICK: float = 5.0
const BURN_DURATION: float = 2.5
const CLEAR_CHECK_INTERVAL: float = 1.0
const BEAM_COLOR: Color = Color(0.9, 0.2, 1.0)

var hover_height: float = 8.0
var drift_speed: float = 2.0
var charge_time: float = 1.1
var beam_duration: float = 1.4
var beam_width: float = 2.0
var sweep_length: float = 14.0
var cooldown_time: float = 3.2
var detect_range: float = 40.0

enum State { DRIFT, CHARGE, FIRE, COOLDOWN }

var _state: State = State.DRIFT
var _timer: float = 0.0
var _clear_check_timer: float = 0.0
var _charge_light: OmniLight3D = null
var _beam_mesh: MeshInstance3D = null
var _vertical_beam: Dictionary = {}
var _beam_start: Vector3 = Vector3.ZERO
var _beam_end: Vector3 = Vector3.ZERO
var _beam_elapsed: float = 0.0
var _beam_tick_timer: float = 0.0


func _configure() -> void:
	display_name = "Plasmastrahl-Bot"
	max_health = 65.0


func _build() -> void:
	_build_visual()
	_add_box_collision(Vector3(1.4, 1.2, 1.4))
	_timer = cooldown_time * randf_range(0.3, 0.8)


func _build_visual() -> void:
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.3, 0.5, 1.3)
	var body := MeshInstance3D.new()
	body.mesh = body_mesh
	body.material_override = _make_unshaded_material(Color(0.75, 0.15, 0.9), 1.0)
	visual_root.add_child(body)

	_charge_light = OmniLight3D.new()
	_charge_light.light_color = Color(0.9, 0.2, 1.0)
	_charge_light.light_energy = 0.0
	_charge_light.omni_range = 5.0
	_charge_light.shadow_enabled = false
	visual_root.add_child(_charge_light)


func _physics_process(delta: float) -> void:
	match _state:
		State.DRIFT:
			_do_drift(delta)
		State.CHARGE:
			_do_charge(delta)
		State.FIRE:
			_do_fire(delta)
		State.COOLDOWN:
			_do_cooldown(delta)

	_clear_check_timer -= delta
	if _clear_check_timer <= 0.0:
		_clear_check_timer = CLEAR_CHECK_INTERVAL
		_despawn_if_room_clear()


## Fliegender Support-Typ - muss fuer den Raum-Clear nicht sterben (siehe
## Klassenkommentar oben und shield_drone.gd::_despawn_if_room_clear(),
## identisches Prinzip).
func _despawn_if_room_clear() -> void:
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if node == self or not (node is Node3D):
			continue
		if node is ShieldDrone or node is PlasmaBeamBot:
			continue
		return
	despawn()


func _do_drift(delta: float) -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return

	var wanted: Vector3 = player.global_position + Vector3.UP * hover_height
	global_position = global_position.move_toward(wanted, drift_speed * delta)

	if global_position.distance_to(player.global_position) > detect_range:
		return

	_timer -= delta
	if _timer <= 0.0:
		_state = State.CHARGE
		_timer = charge_time


func _do_charge(delta: float) -> void:
	_timer -= delta
	if _charge_light:
		_charge_light.light_energy = lerpf(0.0, 3.0, 1.0 - clampf(_timer / maxf(charge_time, 0.01), 0.0, 1.0))
	if _timer > 0.0:
		return

	var player: CharacterBody3D = _find_player()
	if player == null:
		_state = State.COOLDOWN
		_timer = cooldown_time
		return

	var ground: Vector3 = _project_to_ground(player.global_position)
	var dir: Vector3 = _find_facing_toward(player.global_position)
	_beam_start = ground - dir * sweep_length * 0.5
	_beam_end = ground + dir * sweep_length * 0.5
	_beam_elapsed = 0.0
	_beam_tick_timer = 0.0

	_beam_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(beam_width, 0.08, 0.6)
	_beam_mesh.mesh = box
	_beam_mesh.material_override = _make_unshaded_material(BEAM_COLOR, 2.0)
	get_tree().current_scene.add_child(_beam_mesh)

	# Verbindet den Bot sichtbar mit dem Bodenfleck - ohne diesen Strahl
	# wirkt der wandernde Fleck wie eine eigenstaendige Falle statt wie ein
	# Laser, den DIESER Gegner gerade abfeuert. _create_beam_visual() statt
	# eines einzelnen duennen Zylinders: Kern+Glow+Puls sind aus
	# Kampfdistanz tatsaechlich als Strahl erkennbar.
	_vertical_beam = _create_beam_visual(BEAM_COLOR)

	_state = State.FIRE


func _do_fire(delta: float) -> void:
	if _charge_light:
		_charge_light.light_energy = 3.0

	_beam_elapsed += delta
	var t: float = clampf(_beam_elapsed / maxf(beam_duration, 0.01), 0.0, 1.0)
	var point: Vector3 = _beam_start.lerp(_beam_end, t)

	if _beam_mesh != null and is_instance_valid(_beam_mesh):
		_beam_mesh.global_position = point + Vector3.UP * 0.1
		_beam_mesh.look_at(point + (_beam_end - _beam_start), Vector3.UP)

	_update_beam_visual(_vertical_beam, global_position, point, delta)

	_beam_tick_timer -= delta
	if _beam_tick_timer <= 0.0:
		_beam_tick_timer = BURN_TICK_INTERVAL
		_tick_damage(point)

	if t >= 1.0:
		_end_beam()


func _tick_damage(point: Vector3) -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return
	var flat_player: Vector3 = player.global_position
	flat_player.y = point.y
	if flat_player.distance_to(point) > beam_width * 0.5 + 0.6:
		return

	var target_health := player.find_child("Health", true, false) as Health
	if target_health != null and target_health.is_alive():
		target_health.take_damage(BURN_DAMAGE_PER_TICK, self)
	if player.has_method("apply_status_effect"):
		player.call("apply_status_effect", "burn", BURN_DURATION, BURN_DAMAGE_PER_TICK, self, BURN_TICK_INTERVAL)


func _end_beam() -> void:
	if _beam_mesh != null and is_instance_valid(_beam_mesh):
		_beam_mesh.queue_free()
	_beam_mesh = null
	_free_beam_visual(_vertical_beam)
	_vertical_beam = {}
	_state = State.COOLDOWN
	_timer = cooldown_time


func _do_cooldown(delta: float) -> void:
	if _charge_light:
		_charge_light.light_energy = maxf(_charge_light.light_energy - delta * 4.0, 0.0)
	_timer -= delta
	if _timer <= 0.0:
		_state = State.DRIFT
		_timer = randf_range(0.5, 1.5)


func _find_facing_toward(target_pos: Vector3) -> Vector3:
	var dir: Vector3 = target_pos - global_position
	dir.y = 0.0
	if dir.length_squared() < 0.01:
		return Vector3.FORWARD
	return dir.normalized()


func _cleanup_effects() -> void:
	if _beam_mesh != null and is_instance_valid(_beam_mesh):
		_beam_mesh.queue_free()
	_beam_mesh = null
	_free_beam_visual(_vertical_beam)
	_vertical_beam = {}
