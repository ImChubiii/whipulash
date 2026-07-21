extends CharacterBody3D
class_name EnemyAI

enum State { IDLE, CHASE, ATTACK }

@export var move_speed: float = 8
@export var detection_range: float = 20
@export var attack_range: float = 5
@export var attack_cooldown: float = 0
@export var gravity: float = 20.0
@export var attack_windup_time: float = 1
@export var pre_attack_delay: float = 0.8

# Eigener Anzeigename für UI/Death-Screen — unabhängig vom technischen
# Godot-Node-Namen (der bei gespawnten Kopien hässlich werden kann,
# z.B. "@CharacterBody3D@3").
@export var display_name: String = "Gegner"

func get_display_name() -> String:
	return display_name

# Markiert diesen Gegner als "groß" — Kamera zoomt beim Lock-On automatisch
# raus auf zoom_max, statt bei der aktuellen manuellen Zoomstufe zu bleiben.
@export var is_large_enemy: bool = false

# Höhe, auf der der Lock-On-Ring über DIESEM Gegner erscheint — beim
# normalen Dummy passt der Standard vom TargetReticle, bei größeren
# Varianten (Tank etc.) hier einfach hochstellen.
@export var reticle_height_offset: float = 1.2

# Wie weit der Ring Richtung Kamera vor DIESEM Gegner schwebt — bei
# größeren Modellen (Tank etc.) höher stellen, sonst steckt der Ring
# im Modell fest und wird von der Geometrie verdeckt.
@export var reticle_forward_offset: float = 1.0

# NEU: Skaliert die GRÖSSE des Lock-On-Rings selbst passend zur
# Gegnergröße — 1.0 = TargetReticle-Standardgröße, größer bei großen
# Gegnern (Tank/Koloss), kleiner bei winzigen/schnellen Gegnern (Scout).
@export var reticle_scale: float = 1.0

# Multiplikator für die Stärke des Kamera-Soft-Locks, WENN dieser Gegner
# gerade als Ziel gelockt ist. 1.0 = normale Stärke. Kleinere Werte
# (z.B. 0.3) für kleine, schnelle Gegner, die viel um den Spieler
# herumlaufen — sonst reißt die Kamera bei jedem Positionswechsel
# ruckartig hinterher.
@export var camera_lock_multiplier: float = 1.0

# --- Sanfte Separation von anderen Gegnern (statt harter Physik-Kollision, ---
# --- die zu Katapult-artigem Wegschubsen führen kann). ---
@export var separation_radius: float = 6
@export var separation_strength: float = 5

# --- Transparenz nach HP + Hit-Flash ---
# Bei voller HP komplett sichtbar, bei 0 HP auf diesen Wert runter.
@export_range(0.0, 1.0) var min_alpha_at_zero_hp: float = 0.15
# Wie stark/kurz die Transparenz beim TREFFER zusätzlich kurz einbricht.
@export_range(0.0, 1.0) var hit_flash_alpha: float = 0.2
@export var hit_flash_duration: float = 0.15

# NEU: Roter Farb-Blitz beim Treffer, dezent (niedrige Stärke = wenig
# Rot-Anteil, kein komplett rot eingefärbter Gegner).
@export_range(0.0, 1.0) var hit_color_flash_strength: float = 0.25
@export var hit_color_flash_duration: float = 0.15

# --- Telegraph-Ring Boden-Snapping ---
# Die Telegraph-Ringe (TelegraphOuterRing/TelegraphInner) werden jeden
# Physik-Frame per Downward-Raycast auf den echten Boden gepinnt (X/Z
# folgen weiterhin normal dem Gegner) — funktioniert automatisch für
# jeden Gegnertyp, ohne dass man pro Modell manuell Offsets tunen muss.
@export var telegraph_ground_snap: bool = true
@export var telegraph_ground_clearance: float = 0.02
@export var telegraph_ground_raycast_mask: int = 1
@export var telegraph_ground_raycast_range: float = 20.0

# --- Sprung- & Kanten-Verhalten ---
# Gegner können jetzt über kleine Hindernisse/Stufen springen (Raycast
# unten = blockiert, Raycast oben = frei -> Hindernis ist niedrig genug,
# springen). An echten Abgründen (kein Boden mehr in Bewegungsrichtung
# erkennbar) bleiben sie STEHEN und warten, statt blind runterzulaufen —
# außer can_jump_across_ledges ist an UND die Lücke ist klein genug
# (jump_across_max_gap), dann wird stattdessen rübergesprungen.
@export var can_jump: bool = true

# Feste maximale Sprunghöhe in Metern für DIESEN Gegner — direkt hier
# einstellen, z.B. 2.0. Das ist eine OBERGRENZE — der tatsächliche Sprung
# misst die reale Hindernishöhe per Raycast ab und springt nur so hoch wie
# nötig (plus kleine Marge), nie automatisch bis zur vollen jump_height.
# Nur bei einem Hindernis, das GENAU jump_height hoch ist, wird die volle
# Höhe genutzt.
@export var jump_height: float = 2.0
# Kleiner Sicherheitsaufschlag über der gemessenen Hindernishöhe, damit
# der Sprung nicht exakt an der Kante kratzt.
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

# NEU: Statt die Geschwindigkeit jeden Frame SOFORT auf den Zielwert zu
# springen (fühlt sich besonders bei schnellen Gegnern wie dem Stinger
# ruckartig/roboterhaft an, "0 Delay"), rampt sich velocity.x/z jetzt
# über movement_acceleration hoch bzw. runter — move_toward statt
# direkter Zuweisung. Kleinere Werte = trägere, "schwerere" Beschleunigung
# (natürlicher wirkendes Anlaufen/Abbremsen), größere Werte = fast wie
# vorher (fast instant). Für den Stinger z.B. 30-40 statt eines riesigen
# Werts probieren.
@export var movement_acceleration: float = 40.0

var _waiting_at_ledge: bool = false

# --- Status-Effekt-System (Poison, Slow, Fear, ...) ---
# Läuft über einen generischen StatusEffectManager-Kind-Node, der sich
# selbst erstellt, falls er nicht schon in der Szene liegt — kein
# manuelles Scene-Editing nötig. "slow" reduziert move_speed anteilig,
# "poison" tickt Schaden über Health. Weitere Effekte (z.B. "fear") sind
# über has_status_effect()/get_status_effect_magnitude() abfragbar, auch
# wenn hier noch keine konkrete Fear-Verhaltenslogik verdrahtet ist.
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
# Schaltet die "EnemyAI DEBUG:"-Konsolen-Ausgaben für DIESEN Gegner an/aus.
# Praktisch um gezielt nur den Gegnertyp zu debuggen, den man gerade testet,
# ohne dass die Konsole von allen anderen gleichzeitig aktiven Gegnern
# zugespammt wird.
@export var debug_logging: bool = false

@onready var attack_hitbox: Hitbox = get_node_or_null("AttackHitbox")
@onready var telegraph_inner: MeshInstance3D = get_node_or_null("AttackHitbox/TelegraphInner")
@onready var telegraph_outer: MeshInstance3D = get_node_or_null("AttackHitbox/TelegraphOuterRing")
@onready var health: Health = get_node_or_null("Health")
@onready var mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")

var _state: State = State.IDLE
var _player: Node3D
var _attack_timer: float = 0.0
var _is_attacking: bool = false
var _mesh_material: ShaderMaterial
var _base_alpha: float = 1.0
var _last_known_health: float = -1.0
var _alpha_tween: Tween
var _flash_tween: Tween

func _debug(msg: String) -> void:
	if debug_logging:
		print("EnemyAI DEBUG [%s]: %s" % [display_name, msg])

func _ready() -> void:
	add_to_group("enemies")
	_player = get_tree().get_root().find_child("Player", true, false)
	if _player == null:
		push_warning("EnemyAI: Konnte keinen Node namens 'Player' finden.")

	_debug("_ready() aufgerufen. attack_hitbox gefunden: %s | telegraph_inner: %s | telegraph_outer: %s" % [attack_hitbox, telegraph_inner, telegraph_outer])

	# StatusEffectManager holen oder automatisch erstellen (gemeinsamer
	# Helper statt dupliziertem Code — siehe status_effect_manager.gd).
	status_effects = StatusEffectManager.get_or_create(self)
	status_effects.effect_ticked.connect(_on_status_effect_ticked)

	# Sprungkraft aus der festen jump_height berechnen (Sprungphysik:
	# v = sqrt(2 * g * h)), damit der Sprung physikalisch auch wirklich
	# so hoch kommt wie im Inspector eingestellt.
	jump_velocity = sqrt(2.0 * gravity * jump_height)
	_debug("Sprungkraft berechnet: jump_height=%.1f -> jump_velocity=%.2f" % [jump_height, jump_velocity])

	if telegraph_inner:
		telegraph_inner.visible = false
		telegraph_inner.scale = Vector3(0.01, 1.0, 0.01)
	if telegraph_outer:
		telegraph_outer.visible = false

	# Das ShaderMaterial des Meshes holen und DUPLIZIEREN — sonst würden
	# sich mehrere gleichzeitig existierende Gegner (Spawner!) alle
	# dasselbe Material teilen, und die Transparenz eines Gegners würde
	# versehentlich auch alle anderen mitverändern.
	if mesh:
		var mat := mesh.get_surface_override_material(0)
		if mat is ShaderMaterial:
			_mesh_material = mat.duplicate()
			mesh.set_surface_override_material(0, _mesh_material)
			# Sicherheitshalber explizit zurücksetzen, falls im Basis-Material
			# irgendwann mal ein Flash-Wert manuell im Inspector getestet und
			# gespeichert wurde — sonst könnte der als "eingefroren" bestehen
			# bleiben, unabhängig vom Script.
			_mesh_material.set_shader_parameter("flash_strength", 0.0)
		else:
			push_warning("EnemyAI: Mesh hat kein ShaderMaterial mit alpha_multiplier — Transparenz-Effekt wird nicht funktionieren.")

	if health:
		health.died.connect(_on_died)
		health.health_changed.connect(_on_health_changed)
		# Direkt beim Start einmal die korrekte Basis-Transparenz setzen
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
	# dass sie sich stapeln/überlappen, OHNE die harten Physik-Pops zu
	# verursachen, die bei echter CharacterBody3D-vs-CharacterBody3D-
	# Kollision zwischen vielen Gegnern gleichzeitig auftreten können.
	velocity += _get_separation_velocity()

	move_and_slide()

	# Telegraph-Ringe NACH move_and_slide() auf den echten Boden pinnen —
	# so hängen sie nie im Boden fest und schweben nicht mit, falls der
	# Gegner selbst gerade in der Luft ist (Sprung, Fall, Knockback etc.).
	_update_telegraph_ground_position()

func _update_telegraph_ground_position() -> void:
	if not telegraph_ground_snap:
		return
	if telegraph_outer == null and telegraph_inner == null:
		return

	# Nur raycasten, wenn mindestens ein Ring gerade sichtbar ist —
	# spart Performance bei vielen gleichzeitig aktiven Gegnern, die
	# gerade nicht im Angriffszustand sind.
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
	# Abgrund): einfach die aktuelle Gegner-Y-Position nehmen, damit die
	# Ringe nicht komplett verschwinden oder ins Leere schießen.
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
			# Je näher, desto stärker die Abstoßung (linear abfallend mit Distanz)
			var strength: float = (1.0 - dist / separation_radius) * separation_strength
			push += offset.normalized() * strength
	return push

func _move_towards_player(delta: float) -> void:
	var dir: Vector3 = (_player.global_position - global_position)
	dir.y = 0
	dir = dir.normalized()

	# --- Kanten-Check: droht hier ein Abgrund? ---
	if dir.length() > 0.01 and _is_ledge_ahead(dir):
		var jumped_across: bool = can_jump_across_ledges and is_on_floor() and _try_jump_across_ledge(dir)
		if not jumped_across:
			if ledge_wait_enabled:
				# An der Kante stehen bleiben und warten statt blind
				# runterzulaufen — nur zum Spieler drehen, nicht bewegen.
				_waiting_at_ledge = true
				velocity.x = 0
				velocity.z = 0
				_face_player(delta)
				return
			# ledge_wait_enabled = false -> altes Verhalten: einfach weiterlaufen
	_waiting_at_ledge = false

	# --- Hindernis-Check: kleine Stufe/Kante springen statt stehenbleiben,
	# und zwar nur SO HOCH wie das Hindernis tatsächlich ist, nicht immer
	# volle jump_height. ---
	if can_jump and is_on_floor() and dir.length() > 0.01:
		var required_height: float = _get_required_jump_height(dir)
		if required_height > 0.0:
			velocity.y = sqrt(2.0 * gravity * required_height)
			_debug("Springe auf Zielhöhe %.2f (Obergrenze %.2f) über Hindernis." % [required_height, jump_height])

	# "slow"-Status-Effekt reduziert die Bewegungsgeschwindigkeit anteilig
	# (magnitude 0.5 = 50% langsamer). Kommt z.B. von einer Slow-Waffe
	# oder einem Hazard, per apply_status_effect("slow", dauer, staerke).
	var slow_factor: float = 1.0 - clamp(status_effects.get_effect_magnitude("slow"), 0.0, 1.0)
	var effective_speed: float = move_speed * slow_factor

	# Sanft auf die Zielgeschwindigkeit hin beschleunigen statt sofort
	# draufzuspringen — macht die Bewegung spürbar natürlicher, besonders
	# bei schnellen Gegnern wie dem Stinger, die sonst bei jedem
	# Richtungswechsel wie teleportiert wirken.
	var target_velocity_x: float = dir.x * effective_speed
	var target_velocity_z: float = dir.z * effective_speed
	velocity.x = move_toward(velocity.x, target_velocity_x, movement_acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity_z, movement_acceleration * delta)
	_face_player(delta)

# Berechnet die TATSÄCHLICHE Weltraum-Y-Höhe der FÜSSE dieses Gegners,
# über die eigene CollisionShape3D — nicht einfach global_position.y (die
# Root!), die je nach Gegnertyp Fußhöhe ODER Körpermitte sein kann (Fighter
# z.B. sitzt die Kapsel-Mitte ~4.5 Einheiten über dem Boden). OHNE diesen
# Fix reichten die Abwärts-Raycasts bei großen Gegnern nie bis zum echten
# Boden -> die dachten JEDEN Frame "Abgrund voraus" und blieben komplett
# stehen, obwohl gar keine Kante da war.
func _get_feet_y() -> float:
	var collision_shape: CollisionShape3D = get_node_or_null("CollisionShape3D")
	if collision_shape and collision_shape.shape:
		var shape := collision_shape.shape
		# WICHTIG: die Shape-Ressource kennt nur ihre EIGENEN Rohwerte
		# (radius/height). Falls die CollisionShape3D-Node selbst noch
		# eine Transform-Skalierung trägt (wie beim Colossus, dessen
		# Body-Kollision nie auf Identity-Scale umgestellt wurde), muss
		# das hier mit eingerechnet werden — sonst landen wir bei großen,
		# noch skalierten Gegnern bei einer viel zu hohen "Fußposition"
		# und der Kanten-Check denkt fälschlich, es sei ein Abgrund da.
		var y_scale: float = collision_shape.global_transform.basis.y.length()
		var half_height: float = 0.0
		if shape is CapsuleShape3D:
			half_height = (shape.radius + shape.height * 0.5) * y_scale
		elif shape is BoxShape3D:
			half_height = shape.size.y * 0.5 * y_scale
		elif shape is SphereShape3D:
			half_height = shape.radius * y_scale
		return collision_shape.global_position.y - half_height
	return global_position.y

# Misst per gestuften Raycasts die TATSÄCHLICHE Höhe des Hindernisses vor
# dem Gegner, statt einfach binär "springbar ja/nein" zu prüfen. Gibt -1.0
# zurück, wenn kein Sprung nötig ist ODER das Hindernis selbst bei voller
# jump_height noch blockiert (dann lieber gar nicht erst springen, statt
# mit dem Kopf dagegen zu laufen). Sonst: die Zielhöhe, auf die gesprungen
# werden soll (gemessene Hindernishöhe + kleine Marge, gedeckelt bei
# jump_height als Obergrenze) — DAS behebt das "springt immer 4 Meter über
# eine 1-Meter-Kiste"-Problem.
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
		return -1.0  # unten nichts im Weg, kein Sprung nötig

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
		# Selbst auf voller jump_height noch blockiert -> zu hoch, gar
		# nicht erst versuchen zu springen.
		return -1.0

	return min(obstacle_clear_height + obstacle_jump_margin, jump_height)

# Prüft per Downward-Raycast, ob in Bewegungsrichtung (etwas vor dem
# Gegner) noch Boden vorhanden ist. Kein Treffer = Abgrund/Lücke.
func _is_ledge_ahead(dir: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var feet_y: float = _get_feet_y()
	var check_pos: Vector3 = Vector3(global_position.x, feet_y, global_position.z) + dir * ledge_check_forward_distance + Vector3(0, 0.5, 0)
	var ray_end: Vector3 = check_pos - Vector3(0, ledge_check_drop_distance, 0)

	var query := PhysicsRayQueryParameters3D.create(check_pos, ray_end)
	query.exclude = [self]
	query.collision_mask = ground_raycast_mask

	var result := space_state.intersect_ray(query)
	return result.is_empty()

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

	# NUR bei echtem Treffer flashen (HP gesunken), nicht bei Regeneration/
	# Heilung — sonst feuert der Flash bei jedem Regen-Tick jeden Frame
	# neu und wirkt wie ein Dauer-Leuchten.
	if _last_known_health >= 0.0 and current < _last_known_health:
		_play_hit_flash()
	_last_known_health = current

func _set_mesh_alpha(value: float) -> void:
	if _mesh_material:
		_mesh_material.set_shader_parameter("alpha_multiplier", value)

func _play_hit_flash() -> void:
	if not _mesh_material:
		return

	# WICHTIG: alten Tween killen, bevor ein neuer startet — sonst
	# stapeln sich bei schnellem Dauerfeuer viele gleichzeitig laufende
	# Tweens übereinander, die sich gegenseitig überschreiben und zu
	# chaotischem Geflacker statt einem sauberen Effekt führen.
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
