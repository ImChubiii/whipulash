extends CharacterBody3D

# --- Einstellbare Werte (im Godot-Inspector sichtbar, wenn du @export nutzt) ---
@export var speed: float = 15.0
@export var jump_velocity: float = 13.0
@export var mouse_sensitivity: float = 0.003
@export var gravity: float = 40.0

# --- Kamera-Zoom per Mausrad ---
@export var zoom_min: float = 3
@export var zoom_max: float = 20.0
@export var zoom_step: float = 1

# --- Automatisches Zoom bei großen Gegnern ---
# Sobald das aktuell gelockte Ziel is_large_enemy = true hat, zieht die
# Kamera automatisch auf zoom_max raus (überschreibt dabei aktiv jeden
# Frame den Scroll-Wert — das ist so gewollt, "muss" laut Anforderung).
# Solange KEIN großer Gegner gelockt ist, fasst das Script den Zoom
# NICHT an — nur GENAU EINMAL, im Moment des Übergangs "Kampf vorbei",
# läuft eine kurze Tween-Animation zurück zur Zoomstufe von davor.
# Das verhindert das "Gummiband"-Gefühl, das ein Dauer-Lerp jeden Frame
# verursachen würde, wenn man währenddessen versucht manuell zu scrollen.
@export var large_enemy_zoom_hold_time: float = 1.5
@export var large_enemy_zoom_speed: float = 6.0
@export var large_enemy_return_duration: float = 0.6
var _large_enemy_timer: float = 0.0
var _was_fighting_large_enemy: bool = false
var _pre_large_enemy_zoom: float = 10.0
var _return_tween: Tween = null

# --- Status-Effekt-System (Stun, Poison, Slow, Fear, ...) ---
@export var stun_camera_shake: float = 0.3
var status_effects: StatusEffectManager

func apply_stun(duration: float) -> void:
	status_effects.apply_effect("stun", duration, 1.0)
	shake_camera(stun_camera_shake)

func is_stunned() -> bool:
	return status_effects.has_effect("stun")

func apply_status_effect(id: String, duration: float, magnitude: float = 1.0, source: Node = null, tick_interval: float = 0.0) -> void:
	status_effects.apply_effect(id, duration, magnitude, source, tick_interval)
	if id == "stun":
		shake_camera(stun_camera_shake)

func has_status_effect(id: String) -> bool:
	return status_effects.has_effect(id)

func _on_status_effect_ticked(id: String, magnitude: float, source: Node) -> void:
	if id == "poison" and health:
		health.take_damage(magnitude, source)

# --- Node-Referenzen ---
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var mesh: Node3D = $CharacterModel
@onready var combat: Combat = $Combat
@onready var health: Health = $Health
@onready var own_collision: CollisionShape3D = $CollisionShape3D

@export var own_damage_shake_strength: float = 0.6
var _last_known_health: float = -1.0

# --- Todes-Animation ---
@export var use_ragdoll: bool = true
@export var death_fall_rotation_degrees: float = 85.0
@export var death_fall_duration: float = 0.6
@export var ragdoll_mass: float = 6.0
@export var ragdoll_impulse_strength: float = 7.0
@export var ragdoll_upward_impulse: float = 1.2
@export var ragdoll_torque_strength: float = 6.0

var _is_dead: bool = false

# --- Target Lock ---
@export var camera_soft_lock_strength: float = 1.5
@export var model_lock_turn_speed: float = 10.0
@export var max_lock_range: float = 10.0
var _current_target: Node3D = null

signal target_changed(target: Node3D)

func set_target(target: Node3D) -> void:
	if target == _current_target:
		return
	_disconnect_target_death()
	_current_target = target
	if _current_target and is_instance_valid(_current_target):
		var target_health := _current_target.find_child("Health", true, false)
		if target_health:
			target_health.died.connect(_on_target_died)
	target_changed.emit(_current_target)

func clear_target() -> void:
	_disconnect_target_death()
	_current_target = null
	target_changed.emit(null)

func _on_target_died() -> void:
	clear_target()

func _disconnect_target_death() -> void:
	if _current_target and is_instance_valid(_current_target):
		var target_health := _current_target.find_child("Health", true, false)
		if target_health and target_health.died.is_connected(_on_target_died):
			target_health.died.disconnect(_on_target_died)

@export var trauma_decay: float = 1.8
@export var max_shake_offset: float = 0.6
@export var max_shake_roll_degrees: float = 5.0
var _trauma: float = 0.0

# --- Combo-Tilt ---
var _combo_tilt_degrees: float = 0.0
var _tilt_tween: Tween

# --- Dash FOV-Boost ---
@export var dash_fov_boost: float = 25.0
@export var dash_fov_ramp_up_time: float = 0.08
@export var dash_fov_ramp_down_time: float = 0.35
var _base_fov: float = 75.0

# --- Buoyancy ---
@export var buoyancy_accel: float = 6.0
@export var buoyancy_swim_boost: float = 1.8
@export_range(0.0, 1.0) var submersion_body_ratio: float = 0.33
@export var fallback_body_height: float = 1.8
@export var bob_amplitude: float = 0.12
@export var bob_frequency: float = 0.55
@export var bob_response: float = 3.0

var _buoyancy_active: bool = false
var _buoyancy_rise_speed: float = 2.5
var _buoyancy_surface_y: float = 0.0
var _bob_time: float = 0.0

func set_buoyancy(active: bool, rise_speed: float = 2.5, surface_y: float = 0.0) -> void:
	if active and not _buoyancy_active:
		_bob_time = 0.0
	_buoyancy_active = active
	_buoyancy_rise_speed = rise_speed
	_buoyancy_surface_y = surface_y

func _get_body_height() -> float:
	if own_collision and own_collision.shape is CapsuleShape3D:
		return (own_collision.shape as CapsuleShape3D).height
	return fallback_body_height

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	combat.setup(self)
	_base_fov = camera.fov
	_pre_large_enemy_zoom = spring_arm.spring_length

	status_effects = StatusEffectManager.get_or_create(self)
	status_effects.effect_ticked.connect(_on_status_effect_ticked)

	if health:
		health.health_changed.connect(_on_own_health_changed)
		health.died.connect(_on_died)
		_last_known_health = health.current_health

func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	set_physics_process(false)

	if use_ragdoll:
		_spawn_ragdoll_corpse()
	else:
		_play_scripted_fall()

func _play_scripted_fall() -> void:
	if health and health.last_damage_source and is_instance_valid(health.last_damage_source) \
			and health.last_damage_source != self:
		var source: Node3D = health.last_damage_source
		var away_from_enemy: Vector3 = global_position - source.global_position
		away_from_enemy.y = 0
		if away_from_enemy.length() > 0.01:
			mesh.rotation.y = atan2(away_from_enemy.x, away_from_enemy.z)

	var tween := create_tween()
	tween.tween_property(mesh, "rotation:x", deg_to_rad(death_fall_rotation_degrees), death_fall_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _spawn_ragdoll_corpse() -> void:
	if own_collision:
		own_collision.disabled = true

	var corpse := RigidBody3D.new()
	corpse.name = "PlayerCorpse"
	corpse.mass = ragdoll_mass
	corpse.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(corpse)
	var spawn_transform: Transform3D = mesh.global_transform
	spawn_transform.origin.y += 0.15
	corpse.global_transform = spawn_transform

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	collision.shape = shape
	corpse.add_child(collision)

	mesh.get_parent().remove_child(mesh)
	corpse.add_child(mesh)
	mesh.transform = Transform3D.IDENTITY

	var impulse_dir: Vector3
	if health and health.last_damage_source and is_instance_valid(health.last_damage_source) \
			and health.last_damage_source != self:
		impulse_dir = corpse.global_position - health.last_damage_source.global_position
		impulse_dir.y = 0
		if impulse_dir.length() > 0.01:
			impulse_dir = impulse_dir.normalized()
		else:
			impulse_dir = -corpse.global_transform.basis.z
	else:
		impulse_dir = -corpse.global_transform.basis.z

	corpse.apply_central_impulse(impulse_dir * ragdoll_impulse_strength + Vector3.UP * ragdoll_upward_impulse)
	corpse.apply_torque_impulse(Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	) * ragdoll_torque_strength)

func _on_own_health_changed(current: float, _max_hp: float) -> void:
	if _last_known_health >= 0.0 and current < _last_known_health:
		shake_camera(own_damage_shake_strength)
	_last_known_health = current

func _process(delta: float) -> void:
	var shake_roll_degrees: float = 0.0
	if _trauma > 0.0:
		var shake_amount: float = _trauma * _trauma
		camera.h_offset = randf_range(-1.0, 1.0) * max_shake_offset * shake_amount
		camera.v_offset = randf_range(-1.0, 1.0) * max_shake_offset * shake_amount
		shake_roll_degrees = randf_range(-1.0, 1.0) * max_shake_roll_degrees * shake_amount
		_trauma = max(_trauma - trauma_decay * delta, 0.0)
		if _trauma <= 0.0:
			camera.h_offset = 0.0
			camera.v_offset = 0.0

	camera.rotation.z = deg_to_rad(_combo_tilt_degrees + shake_roll_degrees)

func shake_camera(amount: float) -> void:
	if not SettingsManager.screen_shake_enabled:
		return
	_trauma = clamp(_trauma + amount, 0.0, 1.0)

func play_combo_tilt(target_degrees: float) -> void:
	if _tilt_tween and _tilt_tween.is_valid():
		_tilt_tween.kill()
	_tilt_tween = create_tween()
	_tilt_tween.tween_property(self, "_combo_tilt_degrees", target_degrees, 0.15)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func reset_combo_tilt() -> void:
	if _tilt_tween and _tilt_tween.is_valid():
		_tilt_tween.kill()
	_tilt_tween = create_tween()
	_tilt_tween.tween_property(self, "_combo_tilt_degrees", 0.0, 0.6)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func play_dash_fov_effect() -> void:
	var tween := create_tween()
	tween.tween_property(camera, "fov", _base_fov + dash_fov_boost, dash_fov_ramp_up_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", _base_fov, dash_fov_ramp_down_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _unhandled_input(event: InputEvent) -> void:
	if _is_dead:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-60), deg_to_rad(60))

	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length = clamp(spring_arm.spring_length - zoom_step, zoom_min, zoom_max)
			_on_manual_zoom_input()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length = clamp(spring_arm.spring_length + zoom_step, zoom_min, zoom_max)
			_on_manual_zoom_input()

func _on_manual_zoom_input() -> void:
	if _return_tween and _return_tween.is_valid():
		_return_tween.kill()

func _physics_process(delta: float) -> void:
	if combat.is_dashing():
		velocity = combat.get_dash_velocity(delta)
		move_and_slide()
		return

	if _buoyancy_active:
		var exiting: bool = Input.is_action_pressed("ui_accept")

		if exiting:
			var target_rise: float = _buoyancy_rise_speed * buoyancy_swim_boost
			velocity.y = move_toward(velocity.y, target_rise, buoyancy_accel * delta)
		else:
			var body_height: float = _get_body_height()
			var float_target_y: float = _buoyancy_surface_y - body_height * (0.5 - submersion_body_ratio)

			if global_position.y < float_target_y - bob_amplitude:
				velocity.y = move_toward(velocity.y, _buoyancy_rise_speed, buoyancy_accel * delta)
			else:
				_bob_time += delta
				var bob_offset: float = sin(_bob_time * bob_frequency * TAU) * bob_amplitude
				var bob_target_y: float = float_target_y + bob_offset
				var to_target: float = (bob_target_y - global_position.y) * bob_response
				velocity.y = move_toward(velocity.y, to_target, buoyancy_accel * delta)
	else:
		if not is_on_floor():
			velocity.y -= gravity * combat.get_gravity_multiplier() * delta

		if Input.is_action_pressed("ui_accept") and is_on_floor() and combat.can_jump() and not is_stunned():
			velocity.y = jump_velocity

	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var effective_speed: float = speed * combat.get_movement_multiplier()
	if is_stunned():
		effective_speed = 0.0
	else:
		var slow_factor: float = 1.0 - clamp(status_effects.get_effect_magnitude("slow"), 0.0, 1.0)
		effective_speed *= slow_factor

	var forward: Vector3 = camera_pivot.global_transform.basis.z
	var right: Vector3 = camera_pivot.global_transform.basis.x
	var direction: Vector3 = (right * input_dir.x + forward * input_dir.y)
	direction.y = 0
	direction = direction.normalized()

	if direction.length() > 0.1:
		velocity.x = direction.x * effective_speed
		velocity.z = direction.z * effective_speed
	else:
		velocity.x = move_toward(velocity.x, 0, effective_speed)
		velocity.z = move_toward(velocity.z, 0, effective_speed)

	if _current_target and is_instance_valid(_current_target):
		if global_position.distance_to(_current_target.global_position) > max_lock_range:
			clear_target()

	if _current_target and is_instance_valid(_current_target):
		var to_target: Vector3 = _current_target.global_position - global_position
		to_target.y = 0
		if to_target.length() > 0.01:
			var target_facing: float = atan2(to_target.x, to_target.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_facing, delta * model_lock_turn_speed)
	elif direction.length() > 0.1:
		var target_rotation: float = atan2(direction.x, direction.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, delta * 10.0)

	if _current_target and is_instance_valid(_current_target):
		var to_target_cam: Vector3 = _current_target.global_position - camera_pivot.global_position
		to_target_cam.y = 0
		if to_target_cam.length() > 0.01:
			var desired_yaw: float = atan2(-to_target_cam.x, -to_target_cam.z)
			var lock_multiplier: float = 1.0
			var custom_lock_multiplier = _current_target.get("camera_lock_multiplier")
			if custom_lock_multiplier != null:
				lock_multiplier = custom_lock_multiplier
			var effective_lock_strength: float = camera_soft_lock_strength * lock_multiplier
			camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, desired_yaw, effective_lock_strength * delta)

	# --- Automatisches Kamera-Zoom bei großen Gegnern ---
	var target_is_large: bool = false
	if _current_target and is_instance_valid(_current_target):
		var large_flag = _current_target.get("is_large_enemy")
		if large_flag == true:
			target_is_large = true

	if target_is_large:
		_large_enemy_timer = large_enemy_zoom_hold_time
	else:
		_large_enemy_timer = max(_large_enemy_timer - delta, 0.0)

	var is_fighting_large_now: bool = _large_enemy_timer > 0.0

	if is_fighting_large_now:
		if not _was_fighting_large_enemy:
			_pre_large_enemy_zoom = spring_arm.spring_length
			if _return_tween and _return_tween.is_valid():
				_return_tween.kill()
		spring_arm.spring_length = move_toward(spring_arm.spring_length, zoom_max, large_enemy_zoom_speed * delta)

	elif _was_fighting_large_enemy:
		if _return_tween and _return_tween.is_valid():
			_return_tween.kill()
		_return_tween = create_tween()
		_return_tween.tween_property(spring_arm, "spring_length", _pre_large_enemy_zoom, large_enemy_return_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_was_fighting_large_enemy = is_fighting_large_now

	move_and_slide()

	# Heavy-Enemy Wall: Kollisions-Rückstoß gegen schwere Gegner unterdrücken.
	# move_and_slide() gibt bei Kollisionen automatisch Slide-Velocity zurück —
	# gegen is_heavy-Gegner soll der Player wie gegen eine Wand laufen,
	# also kein horizontaler Rückprall. Y (Schwerkraft/Sprung) bleibt unangetastet.
	for i: int in get_slide_collision_count():
		var col: KinematicCollision3D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider and collider.get("is_heavy") == true:
			velocity.x = 0.0
			velocity.z = 0.0
			break
