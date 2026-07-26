extends CharacterBody3D
class_name EnemyAI

enum State { IDLE, CHASE, ATTACK }

@export var move_speed: float = 7.0

# --- Individuelle Geschwindigkeits-Streuung -------------------------------
# Jede gespawnte Instanz wuerfelt EINMALIG in _ready() einen eigenen
# Multiplikator zwischen (1 - speed_variance) und (1 + speed_variance).
# Dadurch laufen mehrere Gegner desselben Typs nicht mehr wie auf einer
# Schnur hintereinander her, sondern ziehen sich beim Verfolgen leicht
# auseinander — der Unterschied ist bewusst klein genug, um nicht wie ein
# Balancing-Fehler zu wirken, aber gross genug um spuerbar zu sein.
# 0.0 = alle Instanzen exakt gleich schnell (altes Verhalten).
@export_range(0.0, 0.5) var speed_variance: float = 0.12

@export var detection_range: float = 20.0
@export var attack_range: float = 5.0
@export var attack_cooldown: float = 1.0

# --- Angriffs-Freigabe (Fix: "greift ins Leere") --------------------------
# Frueher wurde ein Angriff gestartet, sobald distance <= attack_range war,
# und die Hitbox danach BEDINGUNGSLOS aktiviert — auch wenn der Spieler
# waehrend pre_attack_delay + attack_windup_time laengst weggelaufen war
# oder von Anfang an ausserhalb der tatsaechlichen Hitbox-Reichweite stand
# (attack_range war groesser als die reale Reichweite der AttackHitbox).
# Ergebnis: Gegner schlagen sichtbar in die Luft.
#
# Jetzt wird die Distanz DIREKT VOR dem Aktivieren der Hitbox erneut
# geprueft. Liegt der Spieler weiter weg als attack_range * diesem Faktor,
# wird der Angriff sauber abgebrochen (Telegraph aus, kurzer Cooldown,
# zurueck in CHASE) statt ins Leere zu schlagen.
@export var attack_commit_range_multiplier: float = 1.15

# Cooldown nach einem abgebrochenen Angriff — kurz, damit der Gegner sofort
# wieder nachsetzen kann, aber lang genug um kein Telegraph-Flackern zu
# erzeugen.
@export var attack_abort_cooldown: float = 0.3

# Minimaler Blickrichtungs-Abgleich, damit ein Angriff ueberhaupt startet.
# Verhindert Schlaege, die seitlich am Spieler vorbeigehen, weil der Gegner
# sich noch dreht.
# 1.0 = exakt frontal, 0.0 = 90 Grad Toleranz, -1.0 = Check deaktiviert.
#
# ACHSEN-FALLE (hat in der ersten Fassung ALLE Angriffe blockiert):
# Godots Node3D-Konvention ist -Z = vorne. DIESES Projekt nutzt aber
# durchgehend +Z als Vorne — sichtbar an zwei Stellen:
#   1. _face_player() rechnet atan2(dir.x, dir.z) und richtet damit die
#      +Z-Achse auf den Spieler aus (fuer -Z waere es atan2(-x, -z)).
#   2. Die AttackHitbox sitzt bei z = +8.2 (dummy.tscn/tank_dummy.tscn),
#      also auf der POSITIVEN Z-Seite.
# Ein Check gegen -basis.z liefert deshalb dauerhaft ein Dot-Produkt von
# etwa -1 und der Gegner greift NIE an. Deshalb wird die Blickrichtung
# jetzt nicht mehr aus der Basis gelesen, sondern direkt gegen dieselbe
# Ziel-Yaw geprueft, die auch _face_player() ansteuert — damit koennen die
# beiden Stellen gar nicht mehr auseinanderlaufen.
@export_range(-1.0, 1.0) var attack_min_facing_dot: float = 0.35

# gravity hat einen Setter, damit jump_velocity automatisch neu berechnet
# wird, falls gravity zur Laufzeit (Inspector-Live-Edit, Debug-Tools etc.)
# veraendert wird — sonst bliebe die Sprungkraft auf Basis der ALTEN
# gravity "eingefroren".
@export var gravity: float = 20.0:
	set(value):
		gravity = value
		_recalculate_jump_velocity()

@export var attack_windup_time: float = 1.0
@export var pre_attack_delay: float = 0.8

# Eigener Anzeigename fuer UI/Death-Screen — unabhaengig vom technischen
# Godot-Node-Namen (der bei gespawnten Kopien haesslich werden kann, z.B.
# "@CharacterBody3D@3").
@export var display_name: String = "Gegner"

func get_display_name() -> String:
	return display_name

# Markiert diesen Gegner als "gross" — Kamera zoomt beim Lock-On automatisch
# raus auf zoom_max, statt bei der aktuellen manuellen Zoomstufe zu bleiben.
@export var is_large_enemy: bool = false

# Schwere Gegner koennen vom Player nicht weggestossen werden (Knockback
# vom Player's Hitbox wird ignoriert). Im Inspector aktivieren fuer Fighter, Colossus etc.
@export var is_heavy: bool = false

# Hoehe, auf der der Lock-On-Ring ueber DIESEM Gegner erscheint.
@export var reticle_height_offset: float = 1.2

# Wie weit der Ring Richtung Kamera vor DIESEM Gegner schwebt.
@export var reticle_forward_offset: float = 1.0

# Skaliert die GROESSE des Lock-On-Rings passend zur Gegnergroesse.
@export var reticle_scale: float = 1.0

# Multiplikator fuer die Staerke des Kamera-Soft-Locks, wenn dieser Gegner
# gerade als Ziel gelockt ist.
@export var camera_lock_multiplier: float = 1.0

# --- Sanfte Separation von anderen Gegnern ---
@export var separation_radius: float = 6.0
@export var separation_strength: float = 5.0

# Sauberer Ausstieg aus einem angefangenen Angriff: Telegraph aus, kurzer
# Cooldown, zurueck ins Verfolgen. Wird NICHT aufgerufen, wenn der Gegner
# stirbt — dafuer ist _on_died() zustaendig.
func _abort_attack() -> void:
	_is_attacking = false
	_attack_timer = maxf(attack_abort_cooldown, 0.0)

	if telegraph_inner:
		telegraph_inner.visible = false
	if telegraph_outer:
		telegraph_outer.visible = false

	if _state == State.ATTACK:
		_state = State.CHASE

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

# Kanten-Check skaliert dynamisch mit der tatsaechlichen Kapselgroesse
# (Radius) dieses Gegners, damit grosse Gegner (Fighter, Colossus) nicht
# schon ueber den eigenen Koerper faelschlich "Abgrund" erkennen.
@export var ledge_check_scale_with_radius: bool = true
@export var ledge_check_radius_margin: float = 0.5

# Zusaetzlich zum mittleren Raycast werden zwei seitlich versetzte
# Raycasts geprueft — eine Kante wird nur erkannt, wenn ALLE drei
# Raycasts keinen Boden finden.
@export var ledge_check_lateral_samples: bool = true

@export var movement_acceleration: float = 40.0

# --- NavMesh-Pfadverfolgung ---
# Wie oft (in Sekunden) das Ziel des NavigationAgent3D neu gesetzt wird.
@export var nav_target_update_interval: float = 0.2

# --- Ledge-Drop-Verhalten (greift NUR, wenn KEIN gueltiger NavMesh-
# Pfad zum Spieler existiert) ---
@export var ledge_drop_enabled: bool = true
@export var max_safe_drop_height: float = 4.0
@export var ledge_drop_probe_distance: float = 15.0
@export var ledge_drop_player_below_margin: float = 1.0

# --- Abrutsch-Logik, wenn der Gegner auf dem Player-Kopf steht ---
@export var player_head_slide_impulse: float = 6.0
@export_range(0.0, 1.0) var player_head_slide_normal_threshold: float = 0.4
@export var player_head_slide_min_height_above_player: float = 0.3

var _waiting_at_ledge: bool = false

# Cooldown damit der Slide-Impuls nicht jeden Frame ueberschrieben wird
# und move_and_slide() ihn sofort wieder killt.
var _slide_cooldown: float = 0.0

# --- Knockback (z.B. von Hitboxen mit knockback_force, is_heavy schuetzt) ---
# Gleiches Prinzip wie in player_base.gd: _state-abhaengige Bewegung
# (IDLE/ATTACK setzen velocity.x/z direkt auf 0, CHASE regelt per
# move_toward) wuerde einen direkten velocity-Impuls sofort wieder
# ueberschreiben. Der Puffer wird stattdessen additiv angewendet und
# klingt eigenstaendig ab.
@export var knockback_friction: float = 10.0
var _knockback_velocity: Vector3 = Vector3.ZERO

func apply_knockback(impulse: Vector3) -> void:
	_knockback_velocity.x += impulse.x
	_knockback_velocity.z += impulse.z
	velocity.y += impulse.y

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

# BUGFIX: _do_attack() enthaelt mehrere awaits. Stirbt der Gegner mittendrin,
# lief die Coroutine danach auf einem bereits freigegebenen Objekt weiter und
# warf "Attempt to call function on a previously freed instance" in die
# Konsole. Ueber dieses Flag steigt die Coroutine sauber aus.
var _is_dead: bool = false

var _collision_shape_cache: CollisionShape3D
var _warned_missing_collision_shape: bool = false

# Einmalig in _ready() gewuerfelter, instanzspezifischer Tempo-Multiplikator.
var _speed_multiplier: float = 1.0

var _nav_update_timer: float = 0.0
# Wird beim ersten Nutzungsversuch geprueft: existiert ueberhaupt eine
# NavigationRegion3D auf der Map? Ohne die spammt is_target_reachable()
# nur Warnungen und liefert immer false.
var _nav_map_checked: bool = false
var _nav_map_usable: bool = false

func _debug(msg: String) -> void:
	if debug_logging:
		print("EnemyAI DEBUG [%s]: %s" % [display_name, msg])

func _recalculate_jump_velocity() -> void:
	jump_velocity = sqrt(2.0 * max(gravity, 0.0) * max(jump_height, 0.0))

# Wuerfelt den instanzspezifischen Tempo-Multiplikator. Bewusst nur EINMAL
# beim Spawn — ein pro Frame neu gewuerfelter Wert wuerde als Zittern statt
# als Charakter wahrgenommen.
func _roll_speed_multiplier() -> void:
	var v: float = clampf(speed_variance, 0.0, 0.5)
	_speed_multiplier = randf_range(1.0 - v, 1.0 + v)
	_debug("Tempo-Multiplikator gewuerfelt: %.3f (effektiv %.2f m/s)" % [_speed_multiplier, move_speed * _speed_multiplier])

# Effektives Tempo inkl. Slow-Status und individueller Streuung.
func get_effective_move_speed() -> float:
	var slow_factor: float = 1.0 - clamp(status_effects.get_effect_magnitude("slow"), 0.0, 1.0)
	return move_speed * _speed_multiplier * slow_factor

# Aktuelle XZ-Distanz zum Spieler. Die Y-Achse wird bewusst ignoriert:
# Ein Gegner, der 3 Meter unter dem Spieler auf einer Treppe steht, soll
# nicht faelschlich als "ausser Reichweite" gelten.
func _distance_to_player_xz() -> float:
	if _player == null or not is_instance_valid(_player):
		return INF
	var offset: Vector3 = _player.global_position - global_position
	offset.y = 0.0
	return offset.length()

# Prueft, ob der Gegner den Spieler grob anschaut. Ohne diesen Check
# starten Gegner Angriffe waehrend sie sich noch drehen und schlagen
# seitlich vorbei.
#
# Verglichen wird die AKTUELLE rotation.y gegen genau die Ziel-Yaw, die
# _face_player() ansteuert (atan2(dir.x, dir.z)). Dadurch ist der Check
# unabhaengig davon, welche Achse das Projekt als "vorne" definiert —
# siehe die ausfuehrliche Begruendung bei attack_min_facing_dot.
func _is_facing_player() -> bool:
	if attack_min_facing_dot <= -1.0:
		return true
	if _player == null or not is_instance_valid(_player):
		return false

	var to_player: Vector3 = _player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() < 0.01:
		return true
	to_player = to_player.normalized()

	# Exakt dieselbe Formel wie in _face_player().
	var target_yaw: float = atan2(to_player.x, to_player.z)
	var yaw_error: float = absf(angle_difference(rotation.y, target_yaw))

	# Dot-Schwelle in einen maximal erlaubten Winkel umrechnen, damit der
	# Inspector-Wert dieselbe Bedeutung behaelt wie vorher.
	var max_angle: float = acos(clampf(attack_min_facing_dot, -1.0, 1.0))

	if yaw_error > max_angle:
		_debug("Angriff wartet — Blickwinkel %.1f Grad > erlaubte %.1f Grad." % [rad_to_deg(yaw_error), rad_to_deg(max_angle)])
		return false
	return true

# Wird bei JEDEM Charakterwechsel gefeuert (siehe PartyManager) — haelt
# _player aktuell, da der Player-Node beim Wechseln komplett ausgetauscht
# wird (alte Instanz wird entfernt, neue gespawnt).
func _on_active_player_changed(new_player: CharacterBody3D) -> void:
	_player = new_player

# Holt die aktuelle Spieler-Instanz bevorzugt ueber PartyManager (immer
# aktuell), find_child("Player") nur als Fallback, falls PartyManager aus
# irgendeinem Grund noch keine Instanz kennt.
func _refresh_player_reference() -> void:
	if PartyManager.player and is_instance_valid(PartyManager.player):
		_player = PartyManager.player
	else:
		_player = get_tree().get_root().find_child("Player", true, false)
	if _player == null:
		push_warning("EnemyAI: Konnte keinen Node namens 'Player' finden.")

func _ready() -> void:
	add_to_group("enemies")
	_roll_speed_multiplier()
	_refresh_player_reference()
	if not PartyManager.active_player_changed.is_connected(_on_active_player_changed):
		PartyManager.active_player_changed.connect(_on_active_player_changed)

	_debug("_ready(). attack_hitbox=%s | telegraph_inner=%s | telegraph_outer=%s | nav_agent=%s" % [attack_hitbox, telegraph_inner, telegraph_outer, nav_agent])

	var shape_node := _get_collision_shape_node()
	if shape_node == null:
		push_warning("EnemyAI (%s): Keine CollisionShape3D gefunden! Kanten-/Hindernis-Checks laufen mit Fallback-Werten und sind unzuverlaessig." % display_name)

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
			push_warning("EnemyAI (%s): Mesh hat kein ShaderMaterial mit alpha_multiplier — Transparenz-Effekt wird nicht funktionieren." % display_name)

	if health:
		health.died.connect(_on_died)
		health.health_changed.connect(_on_health_changed)
		_on_health_changed(health.current_health, health.max_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y <= 0.0:
		# BUGFIX: Frueher wurde velocity.y auf dem Boden bedingungslos
		# genullt. Damit hat _handle_standing_on_player() seinen
		# Aufwaerts-Kick nie ueberlebt (der Gegner "steht" ja auf dem
		# Spielerkopf = is_on_floor()). Jetzt bleibt ein positiver
		# Y-Impuls erhalten und nur Restfallgeschwindigkeit wird gekappt.
		velocity.y = 0.0

	_attack_timer = max(_attack_timer - delta, 0.0)
	_slide_cooldown = max(_slide_cooldown - delta, 0.0)

	if _player == null or not is_instance_valid(_player):
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		_update_telegraph_ground_position()
		return

	var distance: float = global_position.distance_to(_player.global_position)
	var previous_state: State = _state

	match _state:
		State.IDLE:
			velocity.x = 0.0
			velocity.z = 0.0
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
			velocity.x = 0.0
			velocity.z = 0.0
			_face_player(delta)
			if distance > attack_range * 1.3 and not _is_attacking:
				_state = State.CHASE
			elif _attack_timer <= 0.0 and not _is_attacking and _is_facing_player():
				_do_attack()

	if _state != previous_state:
		_debug("State-Wechsel: %s -> %s (Distanz %.2f, attack_range %.2f)" % [State.keys()[previous_state], State.keys()[_state], distance, attack_range])
		if _state == State.ATTACK and telegraph_outer:
			telegraph_outer.visible = true
		elif _state != State.ATTACK and telegraph_outer and not _is_attacking:
			telegraph_outer.visible = false

	# Sanfte Separation von anderen Gegnern draufaddieren — verhindert,
	# dass sie sich stapeln/ueberlappen, ohne harte Physik-Pops.
	velocity += _get_separation_velocity()

	# Knockback-Puffer additiv drauf, NACH der State-Machine-Logik, damit er
	# nicht von velocity.x/z = 0 (IDLE/ATTACK) oder move_toward (CHASE)
	# ueberschrieben wird. Klingt selbststaendig ueber knockback_friction ab.
	velocity.x += _knockback_velocity.x
	velocity.z += _knockback_velocity.z
	_knockback_velocity.x = move_toward(_knockback_velocity.x, 0.0, knockback_friction * delta)
	_knockback_velocity.z = move_toward(_knockback_velocity.z, 0.0, knockback_friction * delta)

	move_and_slide()

	_handle_standing_on_player()

	# Telegraph-Ringe NACH move_and_slide() auf den echten Boden pinnen.
	_update_telegraph_ground_position()

# Erkennt, ob der Gegner auf dem Player-Kopf steht, und verpasst ihm
# einen einmaligen Impuls weg — mit Cooldown, damit move_and_slide()
# den Impuls nicht sofort im naechsten Frame wieder killt.
func _handle_standing_on_player() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	# Cooldown aktiv: Impuls wurde bereits gesetzt, abwarten.
	if _slide_cooldown > 0.0:
		return

	var to_player_xz: Vector3 = global_position - _player.global_position
	to_player_xz.y = 0.0
	var dist_xz: float = to_player_xz.length()

	# Hoehen-Check: stehen wir signifikant UEBER dem Player?
	var feet_y: float = _get_feet_y()
	var player_y: float = _player.global_position.y
	if feet_y < player_y + player_head_slide_min_height_above_player:
		return

	# Nur wenn wir wirklich direkt drueber sind.
	if dist_xz > 4.0:
		return

	var away: Vector3 = to_player_xz
	if away.length() < 0.01:
		away = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
	away = away.normalized()

	_debug("Auf Player-Kopf erkannt (feet_y=%.2f, dist_xz=%.2f) -> Slide-Impuls." % [feet_y, dist_xz])

	# Impuls direkt ueberschreiben — kein move_toward, kein max().
	velocity.x = away.x * player_head_slide_impulse
	velocity.z = away.z * player_head_slide_impulse
	# Aufwaerts-Kick damit Gravity den Impuls nicht sofort neutralisiert.
	velocity.y = player_head_slide_impulse * 0.8

	# Fuer 0.4s nicht nochmal feuern — laesst den Impuls voll wirken.
	_slide_cooldown = 0.4

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
	if separation_radius <= 0.0 or separation_strength <= 0.0:
		return push
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self or not is_instance_valid(other):
			continue
		var other_3d := other as Node3D
		if other_3d == null:
			continue
		var offset: Vector3 = global_position - other_3d.global_position
		offset.y = 0.0
		var dist: float = offset.length()
		if dist > 0.001 and dist < separation_radius:
			var strength: float = (1.0 - dist / separation_radius) * separation_strength
			push += offset.normalized() * strength
	return push

# Prueft EINMALIG, ob die Navigation-Map ueberhaupt Regionen enthaelt.
# Im Level-Generator-Test fehlte die NavigationRegion3D komplett - dann
# liefert is_target_reachable() dauerhaft false und Godot spammt
# "NavigationAgent3D is not on a navigation map" in die Konsole.
func _is_nav_usable() -> bool:
	if nav_agent == null:
		return false
	if _nav_map_checked:
		return _nav_map_usable
	_nav_map_checked = true
	var map: RID = nav_agent.get_navigation_map()
	_nav_map_usable = map.is_valid() and NavigationServer3D.map_get_regions(map).size() > 0
	if not _nav_map_usable:
		push_warning("EnemyAI (%s): Keine NavigationRegion3D auf der Map - Pathfinding deaktiviert, es greift nur Direkt-Chasing." % display_name)
	return _nav_map_usable

func _move_towards_player(delta: float) -> void:
	var dir: Vector3 = Vector3.ZERO
	var following_nav_path: bool = false

	# --- NavMesh-Pfadverfolgung, FALLS ein gueltiger Pfad existiert ---
	if _is_nav_usable():
		_nav_update_timer -= delta
		if _nav_update_timer <= 0.0:
			_nav_update_timer = max(nav_target_update_interval, 0.05)
			nav_agent.target_position = _player.global_position

		if nav_agent.is_target_reachable():
			var next_point: Vector3 = nav_agent.get_next_path_position()
			var to_next: Vector3 = next_point - global_position
			to_next.y = 0.0
			if to_next.length() > 0.01:
				following_nav_path = true
				dir = to_next.normalized()

	if not following_nav_path:
		dir = (_player.global_position - global_position)
		dir.y = 0.0
		dir = dir.normalized()

	_waiting_at_ledge = false

	# --- Ledge-Logik: NUR relevant ohne gueltigen NavMesh-Pfad ---
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

			if not may_drop and ledge_wait_enabled:
				_debug("WARTE AN KANTE (Tiefe %.2f, player_is_below=%s)." % [drop_depth, player_is_below])
				_waiting_at_ledge = true
				velocity.x = 0.0
				velocity.z = 0.0
				_face_player(delta)
				return

	# --- Hindernis-Check: kleine Stufe hochspringen ---
	if can_jump and is_on_floor() and dir.length() > 0.01:
		var required_height: float = _get_required_jump_height(dir)
		if required_height > 0.0:
			velocity.y = sqrt(2.0 * gravity * required_height)

	var effective_speed: float = get_effective_move_speed()

	var target_velocity_x: float = dir.x * effective_speed
	var target_velocity_z: float = dir.z * effective_speed
	# Residual (velocity OHNE den zuletzt aufaddierten Knockback-Anteil) als
	# Basis nehmen, sonst wuerde ein aktiver Knockback hier langsam in die
	# normale Verfolgungsgeschwindigkeit "eingerechnet" statt sauber
	# eigenstaendig abzuklingen.
	var residual_x: float = velocity.x - _knockback_velocity.x
	var residual_z: float = velocity.z - _knockback_velocity.z
	velocity.x = move_toward(residual_x, target_velocity_x, movement_acceleration * delta)
	velocity.z = move_toward(residual_z, target_velocity_z, movement_acceleration * delta)
	_face_player(delta)

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
				_debug("Kein Kind namens 'CollisionShape3D' — nutze stattdessen '%s'." % child.get_path())
				_warned_missing_collision_shape = true
			_collision_shape_cache = child
			return _collision_shape_cache

	if not _warned_missing_collision_shape:
		push_warning("EnemyAI (%s): Konnte KEINE CollisionShape3D unter den direkten Kindern finden." % display_name)
		_warned_missing_collision_shape = true
	return null

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

	return true

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
			return true
	return false

func _face_player(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var dir: Vector3 = (_player.global_position - global_position)
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	dir = dir.normalized()
	var target_rotation: float = atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, delta * 6.0)

func _do_attack() -> void:
	_is_attacking = true
	_attack_timer = attack_cooldown
	_debug("_do_attack() gestartet. pre_attack_delay=%.2fs" % pre_attack_delay)

	if pre_attack_delay > 0.0:
		await get_tree().create_timer(pre_attack_delay).timeout
	if _is_dead or not is_instance_valid(self):
		return

	if telegraph_inner:
		telegraph_inner.visible = true
		telegraph_inner.scale = Vector3(0.01, 1.0, 0.01)
		var grow_tween := create_tween()
		grow_tween.tween_property(telegraph_inner, "scale", Vector3.ONE, attack_windup_time)\
			.set_trans(Tween.TRANS_LINEAR)

	if attack_windup_time > 0.0:
		await get_tree().create_timer(attack_windup_time).timeout
	if _is_dead or not is_instance_valid(self):
		return

	if telegraph_inner:
		telegraph_inner.visible = false

	# --- Freigabe-Check: steht der Spieler UEBERHAUPT noch in Reichweite? ---
	# Ohne diesen Check wird die Hitbox auch dann aktiviert, wenn der Spieler
	# waehrend pre_attack_delay + attack_windup_time laengst weggelaufen ist.
	var commit_range: float = attack_range * maxf(attack_commit_range_multiplier, 0.1)
	if _distance_to_player_xz() > commit_range:
		_debug("Angriff ABGEBROCHEN — Spieler ausser Reichweite (%.2f > %.2f)." % [_distance_to_player_xz(), commit_range])
		_abort_attack()
		return

	if attack_hitbox:
		attack_hitbox.activate()
		await get_tree().create_timer(0.2).timeout
		if _is_dead or not is_instance_valid(self):
			return
		attack_hitbox.deactivate()
	else:
		push_warning("EnemyAI (%s): attack_hitbox ist null — Node 'AttackHitbox' fehlt." % display_name)

	_is_attacking = false

	if _state != State.ATTACK and telegraph_outer:
		telegraph_outer.visible = false

# --- Transparenz nach HP + Hit-Flash ---

func _on_health_changed(current: float, max_hp: float) -> void:
	var percent: float = clamp(current / max(max_hp, 0.001), 0.0, 1.0)
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
	if _is_dead:
		return
	_is_dead = true
	set_physics_process(false)
	# Kollision sofort abschalten, damit die sterbende Instanz waehrend der
	# Death-Animation weder den Spieler blockiert noch von Hitboxen
	# nochmal getroffen wird.
	collision_layer = 0
	collision_mask = 0
	remove_from_group("enemies")

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
