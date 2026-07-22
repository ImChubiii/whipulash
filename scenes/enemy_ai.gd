extends CharacterBody3D
class_name EnemyAI

enum State { IDLE, CHASE, ATTACK }

@export var move_speed: float = 7
@export var detection_range: float = 20
@export var attack_range: float = 5
@export var attack_cooldown: float = 0

# gravity hat einen Setter, damit jump_velocity automatisch neu berechnet
# wird, falls gravity zur Laufzeit (Inspector-Live-Edit, Debug-Tools etc.)
# verändert wird — sonst bliebe die Sprungkraft auf Basis der ALTEN
# gravity "eingefroren".
@export var gravity: float = 20.0:
	set(value):
		gravity = value
		_recalculate_jump_velocity()

@export var attack_windup_time: float = 1
@export var pre_attack_delay: float = 0.8

# Eigener Anzeigename für UI/Death-Screen — unabhängig vom technischen
# Godot-Node-Namen (der bei gespawnten Kopien hässlich werden kann, z.B.
# "@CharacterBody3D@3").
@export var display_name: String = "Gegner"

func get_display_name() -> String:
	return display_name

# Markiert diesen Gegner als "groß" — Kamera zoomt beim Lock-On automatisch
# raus auf zoom_max, statt bei der aktuellen manuellen Zoomstufe zu bleiben.
@export var is_large_enemy: bool = false

# Höhe, auf der der Lock-On-Ring über DIESEM Gegner erscheint.
@export var reticle_height_offset: float = 1.2

# Wie weit der Ring Richtung Kamera vor DIESEM Gegner schwebt.
@export var reticle_forward_offset: float = 1.0

# Skaliert die GRÖSSE des Lock-On-Rings passend zur Gegnergröße.
@export var reticle_scale: float = 1.0

# Multiplikator für die Stärke des Kamera-Soft-Locks, wenn dieser Gegner
# gerade als Ziel gelockt ist.
@export var camera_lock_multiplier: float = 1.0

# --- Sanfte Separation von anderen Gegnern ---
@export var separation_radius: float = 6
@export var separation_strength: float = 5

# --- Transparenz nach HP + Hit-Flash ---
@export_range(0.0, 1.0) var min_alpha_at_zero_hp: float = 0.15
@export_range(0.0, 1.0) var hit_flash_alpha: float = 0.2
@export var hit_flash_duration: float = 0.15

@export_range(0.0, 1.0) var hit_color_flash_strength: float = 0.25
@export var hit_color_flash_duration: float = 0.15

# --- Telegraph-Ring Boden-Snapping ---
@export var telegraph_ground_snap: bool = true
@export var telegraph_ground_clearance: float = 0.02
@export var telegraph_ground_raycast_mask: int = 1
@export var telegraph_ground_raycast_range: float = 20.0

# --- Sprung- & Kanten-Verhalten ---
@export var can_jump: bool = true

@export var jump_height: float = 2.0:
	set(value):
		jump_height = value
		_recalculate_jump_velocity()

@export var obstacle_jump_margin: float = 0.3
var jump_velocity: float = 0.0

@export var obstacle_check_distance: float = 1.2
@export var obstacle_check_low_height: float = 0.3
@export var ledge_check_forward_distance: float = 1.0
@export var ledge_check_drop_distance: float = 3.0
@export var ledge_wait_enabled: bool = true
@export var can_jump_across_ledges: bool = false
@export var jump_across_max_gap: float = 4.0
@export var ground_raycast_mask: int = 1

# Kanten-Check skaliert dynamisch mit der tatsächlichen Kapselgröße
# (Radius) dieses Gegners, damit große Gegner (Fighter, Colossus) nicht
# schon über den eigenen Körper fälschlich "Abgrund" erkennen.
@export var ledge_check_scale_with_radius: bool = true
@export var ledge_check_radius_margin: float = 0.5

# Zusätzlich zum mittleren Raycast werden zwei seitlich versetzte
# Raycasts geprüft — eine Kante wird nur erkannt, wenn ALLE drei
# Raycasts keinen Boden finden.
@export var ledge_check_lateral_samples: bool = true

@export var movement_acceleration: float = 40.0

# --- NEU: NavMesh-Pfadverfolgung ---
# Wie oft (in Sekunden) das Ziel des NavigationAgent3D neu gesetzt wird.
@export var nav_target_update_interval: float = 0.2

# --- NEU: Ledge-Drop-Verhalten (greift NUR, wenn KEIN gültiger NavMesh-
# Pfad zum Spieler existiert) ---
# Ob ein Gegner ohne NavMesh-Verbindung aktiv über eine sichere Kante
# läuft/fällt, statt an ihr zu warten — vorausgesetzt der Spieler
# befindet sich unterhalb UND die gemessene Falltiefe ist sicher.
@export var ledge_drop_enabled: bool = true
# Maximale Falltiefe in Metern, die OHNE NavMesh-Pfad als "sicher zum
# Runterlaufen" gilt.
@export var max_safe_drop_height: float = 4.0
# Wie weit der Downward-Raycast zur TATSÄCHLICHEN Tiefenmessung reicht.
# Muss größer als max_safe_drop_height sein.
@export var ledge_drop_probe_distance: float = 15.0
# Wie viele Meter der Spieler mindestens unter den eigenen Füßen stehen
# muss, damit "Spieler ist unten" als erfüllt gilt.
@export var ledge_drop_player_below_margin: float = 1.0

# --- Abrutsch-Logik, wenn der Gegner auf dem Player-Kopf steht ---
@export var player_head_slide_impulse: float = 6.0
@export_range(0.0, 1.0) var player_head_slide_normal_threshold: float = 0.9
@export var player_head_slide_min_height_above_player: float = 0.8

var _waiting_at_ledge: bool = false

# --- Status-Effekt-System (Poison, Slow, Fear, ...) ---
var status_effects: StatusEffectManager

func apply_status_effect(id: String, duration: float, magnitude: float = 1.0, source: Node = null, tick_interval: float = 0.0) -> void:
	status_effects.apply_effect(id, duration, magnitude, source, tick_interval)

func has_status_effect(id: String) -> bool:
	return status_effects.has_effect(id)

func get_status_effect_magnitude(id: String) -> float:
	return status_effects.get_effect_magnitude(id)

func _on_status_effect_ticked(id: String, magnitude: float, source: Node) -> void:
	if id == "poison" and health:
		health.take_damage(magnitude, source)

# --- Debug ---
@export var debug_logging: bool = false

@onready var attack_hitbox: Hitbox = get_node_or_null("AttackHitbox")
@onready var telegraph_inner: MeshInstance3D = get_node_or_null("AttackHitbox/TelegraphInner")
@onready var telegraph_outer: MeshInstance3D = get_node_or_null("AttackHitbox/TelegraphOuterRing")
@onready var health: Health = get_node_or_null("Health")
@onready var mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")
# NEU: optionaler NavigationAgent3D. get_node_or_null sorgt dafür, dass
# Gegner-Szenen OHNE diesen Node (z.B. alte Dummies) sauber auf null
# fallen und automatisch auf die Luftlinien-Logik zurückfallen.
@onready var nav_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D")

var _state: State = State.IDLE
var _player: Node3D
var _attack_timer: float = 0.0
var _is_attacking: bool = false
var _mesh_material: ShaderMaterial
var _base_alpha: float = 1.0
var _last_known_health: float = -1.0
var _alpha_tween: Tween
var _flash_tween: Tween

# Gecachte, robust gesuchte CollisionShape3D (siehe
# _get_collision_shape_node()) + Merker, damit die Warnung bei fehlender
# Shape nur EINMAL pro Gegner geloggt wird statt jeden Frame.
var _collision_shape_cache: CollisionShape3D
var _warned_missing_collision_shape: bool = false

# NEU: Timer für die periodische NavigationAgent3D-Zielaktualisierung.
var _nav_update_timer: float = 0.0

func _debug(msg: String) -> void:
	if debug_logging:
		print("EnemyAI DEBUG [%s]: %s" % [display_name, msg])

func _recalculate_jump_velocity() -> void:
	jump_velocity = sqrt(2.0 * gravity * jump_height)
	_debug("Sprungkraft neu berechnet: jump_height=%.2f, gravity=%.2f -> jump_velocity=%.2f" % [jump_height, gravity, jump_velocity])

func _ready() -> void:
	add_to_group("enemies")
	_player = get_tree().get_root().find_child("Player", true, false)
	if _player == null:
		push_warning("EnemyAI: Konnte keinen Node namens 'Player' finden.")

	_debug("_ready() aufgerufen. attack_hitbox gefunden: %s | telegraph_inner: %s | telegraph_outer: %s | nav_agent: %s" % [attack_hitbox, telegraph_inner, telegraph_outer, nav_agent])

	var shape_node := _get_collision_shape_node()
	if shape_node:
		_debug("CollisionShape3D gefunden: %s (Pfad: %s)" % [shape_node.shape, shape_node.get_path()])
		_debug("-> berechneter Körperradius: %.2f | Fuß-Y: %.2f (eigene global_position.y: %.2f)" % [_get_body_radius(), _get_feet_y(), global_position.y])
	else:
		push_warning("EnemyAI (%s): Keine CollisionShape3D gefunden! Kanten-/Hindernis-Checks laufen mit Fallback-Werten und sind unzuverlässig." % display_name)

	status_effects = StatusEffectManager.get_or_create(self)
	status_effects.effect_ticked.connect(_on_status_effect_ticked)

	_recalculate_jump_velocity()

	if telegraph_inner:
		telegraph_inner.visible = false
		telegraph_inner.scale = Vector3(0.01, 1.0, 0.01)
	if telegraph_outer:
		telegraph_outer.visible = false

	if mesh:
		var mat := mesh.get_surface_override_material(0)
		if mat is ShaderMaterial:
			_mesh_material = mat.duplicate()
			mesh.set_surface_override_material(0, _mesh_material)
			_mesh_material.set_shader_parameter("flash_strength", 0.0)
		else:
			push_warning("EnemyAI: Mesh hat kein ShaderMaterial mit alpha_multiplier — Transparenz-Effekt wird nicht funktionieren.")

	if health:
		health.died.connect(_on_died)
		health.health_changed.connect(_on_health_changed)
		_on_health_changed(health.current_health, health.max_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	_attack_timer = max(_attack_timer - delta, 0.0)

	if _player == null or not is_instance_valid(_player):
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		_update_telegraph_ground_position()
		return

	var distance: float = global_position.distance_to(_player.global_position)
	var previous_state: State = _state

	match _state:
		State.IDLE:
			velocity.x = 0
			velocity.z = 0
			if distance <= detection_range:
				_state = State.CHASE

		State.CHASE:
			if distance <= attack_range:
				_state = State.ATTACK
			elif distance > detection_range * 1.5:
				_state = State.IDLE
			else:
				_move_towards_player(delta)

		State.ATTACK:
			velocity.x = 0
			velocity.z = 0
			_face_player(delta)
			if distance > attack_range * 1.3 and not _is_attacking:
				_state = State.CHASE
			elif _attack_timer <= 0.0 and not _is_attacking:
				_debug("Bedingungen erfüllt (attack_timer=%.2f, is_attacking=%s) -> _do_attack() wird aufgerufen. Distanz zum Player: %.2f" % [_attack_timer, _is_attacking, distance])
				_do_attack()

	if _state != previous_state:
		_debug("State-Wechsel: %s -> %s (Distanz zum Player: %.2f, attack_range: %.2f)" % [State.keys()[previous_state], State.keys()[_state], distance, attack_range])
		if _state == State.ATTACK and telegraph_outer:
			telegraph_outer.visible = true
		elif _state != State.ATTACK and telegraph_outer and not _is_attacking:
			telegraph_outer.visible = false

	# Sanfte Separation von anderen Gegnern draufaddieren — verhindert,
	# dass sie sich stapeln/überlappen, ohne harte Physik-Pops.
	velocity += _get_separation_velocity()

	move_and_slide()

	_handle_standing_on_player()

	# Telegraph-Ringe NACH move_and_slide() auf den echten Boden pinnen.
	_update_telegraph_ground_position()

# Erkennt, ob der Gegner WIRKLICH auf dem Player steht (nicht nur seitlich
# an ihm anliegt), und verpasst ihm in diesem Fall einen horizontalen
# Impuls weg vom Player-Zentrum.
func _handle_standing_on_player() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider == null:
			continue

		var is_player_collision: bool = collider == _player
		if not is_player_collision and collider is Node:
			is_player_collision = (collider as Node).is_in_group("player")
		if not is_player_collision:
			continue

		var normal: Vector3 = collision.get_normal()
		if normal.dot(Vector3.UP) < player_head_slide_normal_threshold:
			continue

		var feet_y: float = _get_feet_y()
		var player_y: float = _player.global_position.y
		if feet_y < player_y + player_head_slide_min_height_above_player:
			continue

		_debug("Steht WIRKLICH auf dem Player (feet_y=%.2f > player_y=%.2f + %.2f, normal.y=%.2f) -> rutscht seitlich ab." % [feet_y, player_y, player_head_slide_min_height_above_player, normal.y])

		var away: Vector3 = global_position - _player.global_position
		away.y = 0
		if away.length() < 0.01:
			away = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
		away = away.normalized()

		velocity.x = away.x * player_head_slide_impulse
		velocity.z = away.z * player_head_slide_impulse
		velocity.y = min(velocity.y, 0.0)
		break

func _update_telegraph_ground_position() -> void:
	if not telegraph_ground_snap:
		return
	if telegraph_outer == null and telegraph_inner == null:
		return

	var outer_visible: bool = telegraph_outer != null and telegraph_outer.visible
	var inner_visible: bool = telegraph_inner != null and telegraph_inner.visible
	if not outer_visible and not inner_visible:
		return

	var space_state := get_world_3d().direct_space_state
	var ray_origin: Vector3 = global_position + Vector3.UP * 2.0
	var ray_end: Vector3 = global_position - Vector3.UP * telegraph_ground_raycast_range

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [self]
	query.collision_mask = telegraph_ground_raycast_mask

	var result := space_state.intersect_ray(query)

	# Fallback, falls kein Boden gefunden wird (z.B. Gegner über einem
	# Abgrund): einfach die aktuelle Gegner-Y-Position nehmen.
	var ground_y: float = global_position.y
	if result:
		ground_y = result.position.y

	var target_y: float = ground_y + telegraph_ground_clearance

	if telegraph_outer:
		var p: Vector3 = telegraph_outer.global_position
		p.y = target_y
		telegraph_outer.global_position = p

	if telegraph_inner:
		var p2: Vector3 = telegraph_inner.global_position
		p2.y = target_y
		telegraph_inner.global_position = p2

func _get_separation_velocity() -> Vector3:
	var push: Vector3 = Vector3.ZERO
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self or not is_instance_valid(other):
			continue
		var offset: Vector3 = global_position - other.global_position
		offset.y = 0
		var dist: float = offset.length()
		if dist > 0.001 and dist < separation_radius:
			var strength: float = (1.0 - dist / separation_radius) * separation_strength
			push += offset.normalized() * strength
	return push

# ÜBERARBEITET: unterscheidet jetzt sauber zwischen "gültiger NavMesh-Pfad
# vorhanden -> strikt folgen" und "kein Pfad, aber Ziel liegt unten -> über
# die Kante droppen" statt bei jeder Kante blind einzufrieren.
func _move_towards_player(delta: float) -> void:
	var dir: Vector3 = Vector3.ZERO
	var following_nav_path: bool = false

	# --- NavMesh-Pfadverfolgung, FALLS ein gültiger Pfad existiert ---
	if nav_agent != null:
		_nav_update_timer -= delta
		if _nav_update_timer <= 0.0:
			_nav_update_timer = nav_target_update_interval
			nav_agent.target_position = _player.global_position

		if _has_valid_nav_path_to_player():
			var next_point: Vector3 = nav_agent.get_next_path_position()
			var to_next: Vector3 = next_point - global_position
			to_next.y = 0.0
			# WICHTIG: nur WIRKLICH als "folge dem Pfad" zählen, wenn die
			# berechnete Richtung auch spürbar von der eigenen Position
			# wegzeigt. Bei fehlendem/leerem NavMesh (kein
			# NavigationRegion3D im Level, z.B. level_02test.tscn) kann
			# get_next_path_position() praktisch die eigene Position
			# zurückgeben -> dir bliebe Vector3.ZERO und der Gegner würde
			# komplett einfrieren, OHNE dass die Ledge-Logik unten je
			# zum Zug kommt. Dieses Sicherheitsnetz verhindert genau das.
			if to_next.length() > 0.01:
				following_nav_path = true
				dir = to_next.normalized()

	if not following_nav_path:
		dir = (_player.global_position - global_position)
		dir.y = 0
		dir = dir.normalized()

	_waiting_at_ledge = false

	# --- Ledge-Logik: NUR relevant, wenn wir die Richtung selbst wählen
	# (kein gültiger NavMesh-Pfad vorhanden) ---
	if not following_nav_path and dir.length() > 0.01 and _is_ledge_ahead(dir):
		var jumped_across: bool = can_jump_across_ledges and is_on_floor() and _try_jump_across_ledge(dir)

		if not jumped_across:
			var effective_forward_distance: float = ledge_check_forward_distance
			if ledge_check_scale_with_radius:
				effective_forward_distance = max(ledge_check_forward_distance, _get_body_radius() + ledge_check_radius_margin)

			var drop_depth: float = _measure_drop_depth(dir, effective_forward_distance)
			var feet_y: float = _get_feet_y()
			var player_is_below: bool = _player.global_position.y <= feet_y - ledge_drop_player_below_margin

			var may_drop: bool = ledge_drop_enabled and player_is_below and drop_depth <= max_safe_drop_height

			if may_drop:
				# Sicherer Drop: kein NavMesh-Pfad, Spieler ist unten UND
				# die Falltiefe liegt im erlaubten Rahmen -> über die
				# Kante weiterlaufen statt einzufrieren. Die Schwerkraft
				# übernimmt den Rest, sobald is_on_floor() false wird.
				_debug("Sicherer Drop erkannt (Tiefe %.2f <= max_safe_drop_height %.2f, player_is_below=%s) -> laufe über die Kante." % [drop_depth, max_safe_drop_height, player_is_below])
			else:
				if ledge_wait_enabled:
					_debug("WARTE AN KANTE — kein NavMesh-Pfad, Drop nicht sicher/erlaubt (Tiefe %.2f, player_is_below=%s, ledge_drop_enabled=%s)." % [drop_depth, player_is_below, ledge_drop_enabled])
					_waiting_at_ledge = true
					velocity.x = 0
					velocity.z = 0
					_face_player(delta)
					return
				# ledge_wait_enabled = false -> altes Verhalten: einfach weiterlaufen

	# --- Hindernis-Check: kleine Stufe/Kante hochspringen statt stehenbleiben ---
	if can_jump and is_on_floor() and dir.length() > 0.01:
		var required_height: float = _get_required_jump_height(dir)
		if required_height > 0.0:
			velocity.y = sqrt(2.0 * gravity * required_height)
			_debug("Springe auf Zielhöhe %.2f (Obergrenze %.2f) über Hindernis." % [required_height, jump_height])

	var slow_factor: float = 1.0 - clamp(status_effects.get_effect_magnitude("slow"), 0.0, 1.0)
	var effective_speed: float = move_speed * slow_factor

	var target_velocity_x: float = dir.x * effective_speed
	var target_velocity_z: float = dir.z * effective_speed
	velocity.x = move_toward(velocity.x, target_velocity_x, movement_acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity_z, movement_acceleration * delta)
	_face_player(delta)

# NEU: Misst die TATSÄCHLICHE Falltiefe in Metern an einer erkannten Kante,
# über eine GRÖSSERE Downward-Raycast-Distanz (ledge_drop_probe_distance)
# als der reine Ja/Nein-Check in _is_ledge_ahead(). Trifft der Ray
# innerhalb dieser Distanz keinen Boden, gilt der Abgrund als "zu tief zum
# sicheren Messen" (INF) -> wird automatisch als unsicher behandelt.
func _measure_drop_depth(dir: Vector3, effective_forward_distance: float) -> float:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()
	var check_pos: Vector3 = Vector3(global_position.x, feet_y, global_position.z) + dir * effective_forward_distance + Vector3(0, 0.5, 0)
	var ray_end: Vector3 = check_pos - Vector3(0, ledge_drop_probe_distance, 0)

	var query := PhysicsRayQueryParameters3D.create(check_pos, ray_end)
	query.exclude = [self]
	query.collision_mask = ground_raycast_mask

	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return INF

	var drop_y: float = result.position.y
	return feet_y - drop_y

# Nutzt Godots eingebaute is_target_reachable(), um zuverlässig zwischen
# "NavMesh hat eine durchgehende Verbindung zum Spieler" und "kein
# gültiger Pfad" zu unterscheiden — deckt sowohl den Fall aus deiner
# Ursachen-Analyse ab (Start/Ziel auf getrennten NavMesh-Inseln) als auch
# den Fall "gar kein NavigationRegion3D im Level vorhanden" (z.B.
# level_02test.tscn). Eine eigene Distanz-Heuristik über
# get_final_position() war hier unzuverlässig: bei fehlendem NavMesh
# gibt get_final_position() praktisch die Zielposition selbst zurück,
# wodurch die Prüfung fälschlich "gültiger Pfad" meldete und Gegner
# komplett einfroren (dir blieb Vector3.ZERO, siehe _move_towards_player).
func _has_valid_nav_path_to_player() -> bool:
	if nav_agent == null or _player == null:
		return false

	return nav_agent.is_target_reachable()

func _get_collision_shape_node() -> CollisionShape3D:
	if _collision_shape_cache and is_instance_valid(_collision_shape_cache):
		return _collision_shape_cache

	var direct := get_node_or_null("CollisionShape3D")
	if direct and direct is CollisionShape3D:
		_collision_shape_cache = direct
		return _collision_shape_cache

	for child in get_children():
		if child is CollisionShape3D:
			if not _warned_missing_collision_shape:
				_debug("WARNUNG: Kein Kind namens 'CollisionShape3D' — nutze stattdessen direktes Kind '%s'." % child.get_path())
				_warned_missing_collision_shape = true
			_collision_shape_cache = child
			return _collision_shape_cache

	if not _warned_missing_collision_shape:
		push_warning("EnemyAI (%s): Konnte KEINE CollisionShape3D unter den direkten Kindern finden. Kanten-/Hindernis-Checks laufen mit unzuverlässigen Fallback-Werten." % display_name)
		_warned_missing_collision_shape = true
	return null

# Berechnet die TATSÄCHLICHE Weltraum-Y-Höhe der FÜSSE dieses Gegners über
# die eigene CollisionShape3D — nicht einfach global_position.y (die
# Root!), die je nach Gegnertyp Fußhöhe ODER Körpermitte sein kann.
# WICHTIG: shape.height bei CapsuleShape3D ist in Godot 4 bereits die
# GESAMTE Kapselhöhe inklusive beider halbrunder Kappen — der halbe
# Abstand von der Mitte zur Spitze ist daher schlicht height * 0.5, NICHT
# radius + height * 0.5.
func _get_feet_y() -> float:
	var collision_shape := _get_collision_shape_node()
	if collision_shape and collision_shape.shape:
		var shape := collision_shape.shape
		var y_scale: float = collision_shape.global_transform.basis.y.length()
		var half_height: float = 0.0
		if shape is CapsuleShape3D:
			half_height = shape.height * 0.5 * y_scale
		elif shape is BoxShape3D:
			half_height = shape.size.y * 0.5 * y_scale
		elif shape is SphereShape3D:
			half_height = shape.radius * y_scale
		return collision_shape.global_position.y - half_height
	return global_position.y

func _get_body_radius() -> float:
	var collision_shape := _get_collision_shape_node()
	if collision_shape and collision_shape.shape:
		var shape := collision_shape.shape
		var xz_scale: float = collision_shape.global_transform.basis.x.length()
		if shape is CapsuleShape3D:
			return shape.radius * xz_scale
		elif shape is BoxShape3D:
			return max(shape.size.x, shape.size.z) * 0.5 * xz_scale
		elif shape is SphereShape3D:
			return shape.radius * xz_scale
	return 0.5

# Gibt -1.0 zurück, wenn kein Sprung nötig ist ODER das Hindernis selbst
# bei voller jump_height noch blockiert. Sonst: die Zielhöhe, auf die
# gesprungen werden soll (gemessene Hindernishöhe + kleine Marge,
# gedeckelt bei jump_height als Obergrenze).
func _get_required_jump_height(dir: Vector3) -> float:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()

	var origin_low: Vector3 = Vector3(global_position.x, feet_y + obstacle_check_low_height, global_position.z)
	var end_low: Vector3 = origin_low + dir * obstacle_check_distance
	var query_low := PhysicsRayQueryParameters3D.create(origin_low, end_low)
	query_low.exclude = [self]
	query_low.collision_mask = ground_raycast_mask
	var result_low := space_state.intersect_ray(query_low)
	if result_low.is_empty():
		return -1.0

	var obstacle_clear_height: float = jump_height
	var found_clear_height: bool = false
	var steps: int = 8
	for i in range(1, steps + 1):
		var h: float = obstacle_check_low_height + (jump_height - obstacle_check_low_height) * float(i) / float(steps)
		var origin: Vector3 = Vector3(global_position.x, feet_y + h, global_position.z)
		var end: Vector3 = origin + dir * obstacle_check_distance
		var query := PhysicsRayQueryParameters3D.create(origin, end)
		query.exclude = [self]
		query.collision_mask = ground_raycast_mask
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			obstacle_clear_height = h
			found_clear_height = true
			break

	if not found_clear_height:
		return -1.0

	return min(obstacle_clear_height + obstacle_jump_margin, jump_height)

# Prüft per Downward-Raycast, ob in Bewegungsrichtung noch Boden vorhanden
# ist. Zusätzlich zum mittleren Raycast werden zwei seitlich versetzte
# geprüft — eine Kante wird nur erkannt, wenn ALLE Raycasts keinen Boden
# finden (verhindert False-Positives durch Unebenheiten im Collision-Mesh).
func _is_ledge_ahead(dir: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()

	var effective_forward_distance: float = ledge_check_forward_distance
	if ledge_check_scale_with_radius:
		var body_radius: float = _get_body_radius()
		effective_forward_distance = max(ledge_check_forward_distance, body_radius + ledge_check_radius_margin)

	var offsets: Array[Vector3] = [Vector3.ZERO]
	if ledge_check_lateral_samples:
		var lateral_dir: Vector3 = Vector3(-dir.z, 0.0, dir.x)
		var lateral_offset: float = max(_get_body_radius() * 0.5, 0.3)
		offsets.append(lateral_dir * lateral_offset)
		offsets.append(-lateral_dir * lateral_offset)

	for offset in offsets:
		var check_pos: Vector3 = Vector3(global_position.x, feet_y, global_position.z) + dir * effective_forward_distance + offset + Vector3(0, 0.5, 0)
		var ray_end: Vector3 = check_pos - Vector3(0, ledge_check_drop_distance, 0)

		var query := PhysicsRayQueryParameters3D.create(check_pos, ray_end)
		query.exclude = [self]
		query.collision_mask = ground_raycast_mask

		var result := space_state.intersect_ray(query)
		if not result.is_empty():
			return false

	_debug("Kante erkannt: feet_y=%.2f, effective_forward_distance=%.2f (Basis ledge_check_forward_distance=%.2f, Körperradius=%.2f)" % [feet_y, effective_forward_distance, ledge_check_forward_distance, _get_body_radius()])
	return true

# Tastet sich in mehreren Schritten über die Lücke vor; findet sich
# innerhalb von jump_across_max_gap wieder Boden, wird gesprungen.
func _try_jump_across_ledge(dir: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()
	var steps: int = 6
	for i in range(1, steps + 1):
		var t: float = jump_across_max_gap * float(i) / float(steps)
		var probe: Vector3 = Vector3(global_position.x, feet_y, global_position.z) + dir * t + Vector3(0, 0.5, 0)
		var probe_end: Vector3 = probe - Vector3(0, ledge_check_drop_distance, 0)
		var query := PhysicsRayQueryParameters3D.create(probe, probe_end)
		query.exclude = [self]
		query.collision_mask = ground_raycast_mask
		var result := space_state.intersect_ray(query)
		if not result.is_empty():
			velocity.y = jump_velocity
			_debug("Springe über Lücke Richtung Spieler (Distanz ~%.1f)." % t)
			return true
	return false

func _face_player(delta: float) -> void:
	var dir: Vector3 = (_player.global_position - global_position)
	dir.y = 0
	if dir.length() < 0.01:
		return
	dir = dir.normalized()
	var target_rotation: float = atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * 6.0)

func _do_attack() -> void:
	_is_attacking = true
	_attack_timer = attack_cooldown
	_debug("_do_attack() gestartet. Warte pre_attack_delay=%.2fs..." % pre_attack_delay)

	await get_tree().create_timer(pre_attack_delay).timeout

	if telegraph_inner:
		telegraph_inner.visible = true
		telegraph_inner.scale = Vector3(0.01, 1.0, 0.01)
		var grow_tween := create_tween()
		grow_tween.tween_property(telegraph_inner, "scale", Vector3(1.0, 1.0, 1.0), attack_windup_time)\
			.set_trans(Tween.TRANS_LINEAR)
		_debug("Telegraph Inner sichtbar, wächst über attack_windup_time=%.2fs" % attack_windup_time)
	else:
		_debug("WARNUNG: telegraph_inner ist null, kein visueller Windup!")

	await get_tree().create_timer(attack_windup_time).timeout

	if telegraph_inner:
		telegraph_inner.visible = false

	if attack_hitbox:
		_debug("attack_hitbox.activate() wird jetzt aufgerufen. Hitbox global_position: %s" % attack_hitbox.global_position)
		attack_hitbox.activate()
		await get_tree().create_timer(0.2).timeout
		attack_hitbox.deactivate()
		_debug("attack_hitbox.deactivate() aufgerufen — Angriffsfenster vorbei.")
	else:
		_debug("FEHLER: attack_hitbox ist null! Kein Angriff kann ausgelöst werden — Node-Pfad 'AttackHitbox' existiert nicht oder heißt anders.")

	_is_attacking = false

	if _state != State.ATTACK and telegraph_outer:
		telegraph_outer.visible = false

# --- Transparenz nach HP + Hit-Flash ---

func _on_health_changed(current: float, max_hp: float) -> void:
	var percent: float = clamp(current / max_hp, 0.0, 1.0)
	_base_alpha = lerp(min_alpha_at_zero_hp, 1.0, percent)
	_set_mesh_alpha(_base_alpha)

	if _last_known_health >= 0.0 and current < _last_known_health:
		_play_hit_flash()
	_last_known_health = current

func _set_mesh_alpha(value: float) -> void:
	if _mesh_material:
		_mesh_material.set_shader_parameter("alpha_multiplier", value)

func _play_hit_flash() -> void:
	if not _mesh_material:
		return

	if _alpha_tween and _alpha_tween.is_valid():
		_alpha_tween.kill()
	_alpha_tween = create_tween()
	_alpha_tween.tween_method(_set_mesh_alpha, _base_alpha, hit_flash_alpha, hit_flash_duration * 0.5)
	_alpha_tween.tween_method(_set_mesh_alpha, hit_flash_alpha, _base_alpha, hit_flash_duration * 0.5)

	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_method(_set_flash_strength, 0.0, hit_color_flash_strength, hit_color_flash_duration * 0.4)
	_flash_tween.tween_method(_set_flash_strength, hit_color_flash_strength, 0.0, hit_color_flash_duration * 0.6)

func _set_flash_strength(value: float) -> void:
	if _mesh_material:
		_mesh_material.set_shader_parameter("flash_strength", value)

# --- Tod ---

func _on_died() -> void:
	set_physics_process(false)
	if attack_hitbox:
		attack_hitbox.deactivate()
	if telegraph_inner:
		telegraph_inner.visible = false
	if telegraph_outer:
		telegraph_outer.visible = false

	if mesh:
		var tween := create_tween()
		tween.tween_property(mesh, "scale", Vector3.ZERO, 0.4)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await tween.finished

	queue_free()
