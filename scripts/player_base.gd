extends CharacterBody3D
class_name PlayerBase

# --- Basisklasse für ALLE Charaktere (Ningning, Giselle, Karina, Winter, ...) ---
# Enthält die komplette gemeinsame Bewegungs-, Kamera-, Lock-On-, Status-
# Effekt- und Death-Logik. Charakter-spezifische Skripte (z.B. char_ningning.gd)
# erben von dieser Klasse. Charakter-spezifische FÄHIGKEITEN gehören NICHT
# hierher, sondern ins jeweilige Combat-Script (siehe combat_base.gd).

# --- Einstellbare Werte (im Godot-Inspector sichtbar, jedes Char-Scene kann eigene Werte setzen) ---
@export var speed: float = 15.0
@export var jump_velocity: float = 13.0
@export var mouse_sensitivity: float = 0.003
@export var gravity: float = 40.0

# --- Knockback (z.B. von Gegner-Hitboxen via apply_knockback()) ---
# Horizontaler Knockback wird NICHT direkt auf velocity addiert, weil
# _physics_process velocity.x/z jeden Frame aus dem Input neu berechnet
# und einen einmaligen Impuls sofort wieder ueberschreiben wuerde. Stattdessen
# landet er in _knockback_velocity und wird JEDEN Frame FRISCH (nicht
# kumulativ) mit der Eigenbewegung kombiniert — siehe _physics_process fuer
# die Herleitung, warum das insbesondere waehrend Stun wichtig ist.
@export var knockback_friction: float = 10.0
var _knockback_velocity: Vector3 = Vector3.ZERO

# Wird von Hitbox.gd aufgerufen (siehe primary_hitbox.gd). Vertikale
# Komponente (impulse.y) geht direkt in velocity.y, da diese von der
# Bewegungslogik nicht ueberschrieben wird — nur X/Z brauchen den Puffer.
func apply_knockback(impulse: Vector3) -> void:
	_knockback_velocity.x += impulse.x
	_knockback_velocity.z += impulse.z
	velocity.y += impulse.y

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

## --- Stun-Lock-Schutz (Death-Trap durch mehrere Stinger) ---------------
##
## PROBLEM: StatusEffectManager.apply_effect() frischt einen bestehenden
## Effekt per max(alte_restdauer, neue_dauer) AUF. Ein einzelner Stinger
## stunnt 0.7s bei 1.4s Angriffs-Cooldown — das allein waere fair. Bei
## bis zu 6 Stingern pro Raum (es_stinger.tres: max_per_room = 6) landet
## aber im Schnitt alle ~0.23s ein Treffer. Jeder davon setzt den Stun
## wieder auf volle 0.7s hoch, die Restdauer erreicht nie 0 und der
## Spieler steht bis zum Tod bewegungsunfaehig herum. Klassischer
## Stun-Lock: kein Konter moeglich, kein Skill-Ausdruck, nur Tod.
##
## LOESUNG (zweistufig, wie in den meisten Action-Spielen):
##  1. DIMINISHING RETURNS: Jeder Stun innerhalb des Ketten-Zeitfensters
##     ist nur noch stun_diminish_factor so lang wie der vorherige.
##  2. IMMUNITAET: Nach stun_max_chain Stuns in Folge — und generell
##     immer direkt NACH einem abgelaufenen Stun — ist der Spieler fuer
##     stun_immunity_after_stun Sekunden komplett stun-immun. Das ist das
##     eigentliche Sicherheitsnetz: es garantiert ein Handlungsfenster,
##     egal wie viele Gegner gleichzeitig treffen.
##
## SCHADEN bleibt davon voll erhalten — nur die Kontrollverlust-Zeit wird
## gedeckelt. Wer in 6 Stinger reinlaeuft, stirbt weiterhin. Er kann sich
## jetzt nur wehren dabei.
@export var stun_immunity_after_stun: float = 1.1
@export_range(0.0, 1.0) var stun_diminish_factor: float = 0.5
## Nach dieser Zeit ohne neuen Stun startet die Kette wieder bei voller Laenge.
@export var stun_diminish_reset_time: float = 4.0
## Kuerzester Stun, den die Abschwaechung uebrig laesst.
@export var stun_min_duration: float = 0.12
## So viele Stuns in Folge, danach greift zwingend die Immunitaet.
@export var stun_max_chain: int = 3
@export var stun_debug_logging: bool = false

var _stun_immunity_timer: float = 0.0
var _stun_chain_count: int = 0
var _stun_chain_timer: float = 0.0

func _stun_debug(msg: String) -> void:
	if stun_debug_logging:
		print("[StunGuard] %s" % msg)

## Einziger Einstiegspunkt fuer Stuns — apply_status_effect("stun", ...)
## leitet bewusst hierher um, damit die Schutzlogik NICHT umgangen werden
## kann, egal ueber welchen Weg eine Hitbox den Stun ausloest.
func apply_stun(duration: float) -> void:
	if _stun_immunity_timer > 0.0:
		_stun_debug("Stun ignoriert — noch %.2fs immun." % _stun_immunity_timer)
		return

	# Kette ist ausgelaufen -> wieder bei voller Laenge anfangen.
	if _stun_chain_timer <= 0.0:
		_stun_chain_count = 0

	if _stun_chain_count >= stun_max_chain:
		_stun_debug("Ketten-Limit (%d) erreicht -> Immunitaet." % stun_max_chain)
		_begin_stun_immunity()
		return

	var scaled: float = duration * pow(stun_diminish_factor, float(_stun_chain_count))
	scaled = maxf(scaled, stun_min_duration)

	_stun_chain_count += 1
	_stun_chain_timer = stun_diminish_reset_time

	_stun_debug("Stun #%d: %.2fs angefordert -> %.2fs angewendet." % [_stun_chain_count, duration, scaled])

	status_effects.apply_effect("stun", scaled, 1.0)
	shake_camera(stun_camera_shake)

func _begin_stun_immunity() -> void:
	_stun_immunity_timer = stun_immunity_after_stun
	_stun_chain_count = 0
	_stun_chain_timer = 0.0
	status_effects.remove_effect("stun")
	_stun_debug("Immunitaet fuer %.2fs aktiv." % stun_immunity_after_stun)

## Sobald ein Stun regulaer auslaeuft, startet das garantierte
## Handlungsfenster. Ohne das koennte der naechste Treffer im selben Frame
## sofort wieder stunnen und die Kette liefe endlos weiter.
func _on_status_effect_expired(id: String) -> void:
	if id == "stun":
		_stun_immunity_timer = maxf(_stun_immunity_timer, stun_immunity_after_stun)
		_stun_debug("Stun abgelaufen -> %.2fs Immunitaet." % _stun_immunity_timer)

func is_stun_immune() -> bool:
	return _stun_immunity_timer > 0.0

## Laesst Immunitaets- und Ketten-Timer ablaufen. Wird aus
## _physics_process() gefuettert.
func _tick_stun_guard(delta: float) -> void:
	_stun_immunity_timer = maxf(_stun_immunity_timer - delta, 0.0)
	_stun_chain_timer = maxf(_stun_chain_timer - delta, 0.0)

func is_stunned() -> bool:
	return status_effects.has_effect("stun")

func apply_status_effect(id: String, duration: float, magnitude: float = 1.0, source: Node = null, tick_interval: float = 0.0) -> void:
	# Stun NIE direkt durchreichen — sonst umgeht dieser Pfad den kompletten
	# Stun-Lock-Schutz oben.
	if id == "stun":
		apply_stun(duration)
		return
	status_effects.apply_effect(id, duration, magnitude, source, tick_interval)

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
@onready var combat: CombatBase = $Combat
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
var _dash_roll_degrees: float = 0.0
var _dash_roll_tween: Tween
var _tilt_tween: Tween

# --- Dash FOV-Boost ---
## --- Drill-Effekt beim Dash (Phase 2.5) -------------------------------
##
## Der Kamera-Roll rollt beim seitlichen Dash in Bewegungsrichtung mit und
## faehrt danach zurueck — die "Bohrer"-Geste.
##
## NUR BEI A/D: bei einem Vorwaerts- oder Rueckwaerts-Dash gibt es keine
## Seitenrichtung, in die gerollt werden koennte. Ein Roll ohne seitliche
## Bewegung liest sich nicht als Schwung, sondern als Kamerafehler.
##
## WARUM DER ROLL NICHT PER TWEEN AUF camera.rotation.z LAEUFT:
## _process() schreibt camera.rotation.z jeden Frame komplett neu (Combo-
## Tilt + Screenshake). Ein Tween auf dieselbe Eigenschaft wuerde jeden
## Frame ueberschrieben — derselbe Konflikt, der bei dash_fov_boost schon
## dokumentiert ist. Der Roll laeuft deshalb als eigener Summand
## (_dash_roll_degrees) in genau diese Zeile hinein.
@export var dash_drill_enabled: bool = true
@export var dash_drill_degrees: float = 9.0
@export var dash_drill_ramp_up_time: float = 0.07
@export var dash_drill_ramp_down_time: float = 0.30

@export var dash_fov_boost: float = 25.0
@export var dash_fov_ramp_up_time: float = 0.08
@export var dash_fov_ramp_down_time: float = 0.35

# --- Kamera-Federarm --------------------------------------------------
# BUGFIX 1 "beim Dash zoomt die Kamera in den Spieler rein":
#
# SpringArm3D zieht seine Kinder heran, sobald der Cast auf Geometrie
# trifft, und setzt sie dabei OHNE JEDE DAEMPFUNG. Ohne zugewiesene shape
# castet er nur einen haarduennen Strahl - waehrend eines Dashs legt der
# Arm pro Frame mehrere Meter zurueck, und steht der Strahl auch nur einen
# einzigen Frame in Wand oder Boden, springt die Kamera auf Laenge 0.
#
# BUGFIX 2 "die Kamera geht beim Dashen durch Waende":
#
# Der erste Versuch war, die Kollision waehrend des Dashs komplett
# abzuschalten. Das beseitigt zwar das Reinzoomen, laesst die Kamera aber
# durch Waende fahren - schlechter Tausch. Die Kollision bleibt deshalb
# jetzt AN; stattdessen wird die Laengenaenderung gedaempft:
#
#   * Kugel statt Strahl als Cast-Form, plus Ausschluss des eigenen
#     Koerpers (Godot schliesst das Elternobjekt NICHT automatisch aus).
#   * Die Kamera wird nicht mehr vom Federarm gesetzt, sondern jeden
#     Frame selbst auf get_hit_length() zugefahren - REIN schnell, RAUS
#     langsam. Ein einzelner Fehltreffer verschiebt die Kamera dadurch
#     hoechstens um pull_speed/60 Einheiten statt sofort auf 0, und echte
#     Waende schieben sie trotzdem sauber heran.
#
# dash_camera_ignore_collision bleibt als Notschalter erhalten, ist aber
# bewusst AUS.
@export var dash_camera_ignore_collision: bool = false
@export var dash_camera_probe_radius: float = 0.35
@export var dash_camera_margin: float = 0.2

## Wie schnell die Kamera herangezogen wird, wenn etwas im Weg ist
## (Einheiten pro Sekunde). Hoch genug, dass eine echte Wand die Kamera
## rechtzeitig einholt - niedrig genug, dass ein Cast-Aussetzer von ein,
## zwei Frames praktisch unsichtbar bleibt.
@export var camera_spring_pull_speed: float = 22.0

## Wie schnell sie wieder herausfaehrt. Deutlich langsamer, sonst pumpt
## die Kamera an jeder Tuerkante.
@export var camera_spring_return_speed: float = 7.0

## -1 = kein Backup aktiv. Die echte Maske wird beim Dash-Start
## gesichert, damit ein spaeter geaenderter Layer nicht verlorengeht.
var _spring_arm_mask_backup: int = -1
var _camera_spring_current: float = -1.0
var _dash_fov_tween: Tween
var _base_fov: float = 90.0

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

	# Der FOV kommt AUSSCHLIESSLICH aus den Einstellungen, nicht mehr aus
	# camera.fov der Szene ("_base_fov = camera.fov"). Sonst haette jede
	# Charakter-Szene ihren eigenen konkurrierenden Wert und der Regler waere
	# nach dem naechsten Charakterwechsel wieder wirkungslos.
	#
	# Die Verbindung auf fov_changed wird beim Freigeben der Instanz von Godot
	# automatisch geloest - beim Charakterwechsel muss also nichts aufgeraeumt
	# werden.
	set_camera_fov(SettingsManager.fov)
	if not SettingsManager.fov_changed.is_connected(set_camera_fov):
		SettingsManager.fov_changed.connect(set_camera_fov)

	_pre_large_enemy_zoom = spring_arm.spring_length
	_setup_camera_probe()
	_camera_spring_current = spring_arm.spring_length

	# Die Tuerzustands-Platten der Raeume liegen auf einem Layer, den NUR
	# die Minimap-Kamera rendern soll. Ohne diese Zeile schweben sie im
	# Spiel sichtbar ueber den Durchgaengen.
	camera.set_cull_mask_value(RoomInstance.MINIMAP_ONLY_LAYER, false)

	status_effects = StatusEffectManager.get_or_create(self)
	status_effects.effect_ticked.connect(_on_status_effect_ticked)
	status_effects.effect_expired.connect(_on_status_effect_expired)

	if health:
		health.health_changed.connect(_on_own_health_changed)
		health.died.connect(_on_died)
		_last_known_health = health.current_health

## Einziger Einstiegspunkt fuer den Basis-FOV.
##
## Ein laufender Dash-Tween wird dabei gekillt: seine Rueckwaerts-Phase faehrt
## sonst auf den ALTEN _base_fov zurueck und ueberschreibt den gerade
## gesetzten Reglerwert wieder - der Slider haette dann scheinbar zufaellig
## keine Wirkung, wenn man ihn waehrend eines Dashs bewegt.
func set_camera_fov(value: float) -> void:
	_base_fov = clampf(value, SettingsManager.FOV_MIN, SettingsManager.FOV_MAX)
	if _dash_fov_tween and _dash_fov_tween.is_valid():
		_dash_fov_tween.kill()
	if camera:
		camera.fov = _base_fov


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

	camera.rotation.z = deg_to_rad(_combo_tilt_degrees + shake_roll_degrees + _dash_roll_degrees)

	# NACH dem Shake: der Federarm setzt seine Kinder im internen
	# Physics-Notification, also VOR diesem _process. Was hier geschrieben
	# wird, gewinnt fuer den gerenderten Frame.
	_update_camera_spring(delta)

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

# Bewusst als Node (nicht Node3D) typisiert: fehlt/fehlschlägt der Import,
# ersetzt Godot die Instanz durch einen MissingNode. Ein Cast auf Node3D
# würde das still verschlucken und mesh wäre null.

func _resolve_character_model() -> Node3D:
	var node: Node = get_node_or_null("CharacterModel")
	if node == null:
		push_error("PlayerBase: Kein Node namens 'CharacterModel' gefunden. Wurde er beim Model-Tausch umbenannt?")
		return null
	if node is Node3D:
		return node as Node3D
	push_error("PlayerBase: 'CharacterModel' ist ein %s statt Node3D. Model-Import fehlgeschlagen (fehlende .glb, OneDrive-Platzhalter oder noch nicht importiert)." % node.get_class())
	return null
	
## Macht den Federarm gegen schnelle Bewegung unempfindlich. Siehe den
## Kommentar bei dash_camera_ignore_collision.
func _setup_camera_probe() -> void:
	if spring_arm == null:
		return
	if spring_arm.shape == null:
		var probe := SphereShape3D.new()
		probe.radius = maxf(dash_camera_probe_radius, 0.05)
		spring_arm.shape = probe
	spring_arm.margin = maxf(spring_arm.margin, dash_camera_margin)
	# Der eigene Koerper darf den Arm niemals einziehen. Godot schliesst
	# das Elternobjekt NICHT automatisch aus.
	spring_arm.add_excluded_object(get_rid())


## Schaltet die Kollision des Federarms fuer die Dauer des Dashs ab und
## danach exakt auf den vorherigen Wert zurueck. Laeuft jeden Frame ganz
## oben in _physics_process, also auch dann, wenn der Dash durch Tod,
## Stun oder Szenenwechsel abbricht.
## Faehrt die Kamera gedaempft auf die vom Federarm ermittelte Laenge zu,
## statt sie ihn hart setzen zu lassen. Siehe Kommentarblock oben.
func _update_camera_spring(delta: float) -> void:
	if spring_arm == null or camera == null:
		return

	var target: float = spring_arm.get_hit_length()
	if _camera_spring_current < 0.0:
		_camera_spring_current = target

	var speed: float = camera_spring_pull_speed if target < _camera_spring_current else camera_spring_return_speed
	_camera_spring_current = move_toward(_camera_spring_current, target, speed * delta)
	camera.position = Vector3(0.0, 0.0, _camera_spring_current)


func _update_dash_camera_guard() -> void:
	if not dash_camera_ignore_collision or spring_arm == null:
		return

	var dashing: bool = combat != null and combat.is_dashing()
	if dashing:
		if _spring_arm_mask_backup < 0:
			_spring_arm_mask_backup = spring_arm.collision_mask
			spring_arm.collision_mask = 0
	elif _spring_arm_mask_backup >= 0:
		spring_arm.collision_mask = _spring_arm_mask_backup
		_spring_arm_mask_backup = -1


## Der Tween wird gemerkt und beim naechsten Dash abgeraeumt. Ohne das
## laufen bei zwei schnell aufeinanderfolgenden Dashs zwei Tweens
## gleichzeitig auf camera.fov und ueberschreiben sich gegenseitig - das
## Sichtfeld bleibt dann auf einem Zwischenwert haengen.
func play_dash_fov_effect() -> void:
	if _dash_fov_tween and _dash_fov_tween.is_valid():
		_dash_fov_tween.kill()
	_dash_fov_tween = create_tween()
	_dash_fov_tween.tween_property(camera, "fov", _base_fov + dash_fov_boost, dash_fov_ramp_up_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_dash_fov_tween.tween_property(camera, "fov", _base_fov, dash_fov_ramp_down_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	play_dash_drill_effect()


## Seitlicher Kamera-Roll waehrend des Dashs.
##
## Die Seitenrichtung wird DIREKT aus dem Input gelesen, nicht aus
## _dash_direction in combat_base.gd. Grund: _dash_direction ist ein
## Weltvektor. Ob er "seitlich" ist, haengt an der Blickrichtung, und die
## Umrechnung waere eine zweite Stelle, die den +Z-Vorne-Sonderfall dieses
## Projekts kennen muesste. Der Input weiss es ohne Umrechnung.
##
## Vorzeichen: Dash nach RECHTS rollt die Kamera nach links (negatives z),
## wie beim Einlenken in eine Kurve. Umgekehrt fuehlt es sich an, als
## wuerde die Kamera weggeschoben.
func play_dash_drill_effect() -> void:
	if not dash_drill_enabled:
		return

	var strafe: float = Input.get_axis("ui_left", "ui_right")
	if is_zero_approx(strafe):
		# Reiner Vorwaerts-/Rueckwaerts-Dash: kein Roll. Ein evtl. noch
		# laufender Roll aus einem vorherigen Dash wird sauber
		# zurueckgefahren statt haengen gelassen.
		_reset_dash_roll()
		return

	if _dash_roll_tween and _dash_roll_tween.is_valid():
		_dash_roll_tween.kill()

	var target: float = -signf(strafe) * dash_drill_degrees

	_dash_roll_tween = create_tween()
	_dash_roll_tween.tween_property(self, "_dash_roll_degrees", target, dash_drill_ramp_up_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_dash_roll_tween.tween_property(self, "_dash_roll_degrees", 0.0, dash_drill_ramp_down_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func _reset_dash_roll() -> void:
	if is_zero_approx(_dash_roll_degrees):
		return
	if _dash_roll_tween and _dash_roll_tween.is_valid():
		_dash_roll_tween.kill()
	_dash_roll_tween = create_tween()
	_dash_roll_tween.tween_property(self, "_dash_roll_degrees", 0.0, dash_drill_ramp_down_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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
	# GANZ oben, VOR dem Dash-Return: die Stun-Timer muessen auch waehrend
	# eines Dashs weiterlaufen, sonst friert die Immunitaet mitten im
	# Ausweichmanoever ein und der naechste Treffer stunnt wieder voll.
	_tick_stun_guard(delta)
	_update_dash_camera_guard()

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

	# --- Bewegung + Knockback sauber getrennt kombinieren ---
	# BUG (behoben): vorher wurde _knockback_velocity per "+=" auf velocity.x/z
	# addiert. Das funktioniert NUR, wenn direkt danach velocity.x/z wieder
	# komplett neu aus dem Input berechnet wird (normalfall). Waehrend Stun
	# ist effective_speed = 0 -> move_toward(velocity.x, 0, 0) aendert NICHTS,
	# d.h. der bereits letzten Frame aufaddierte Knockback blieb in velocity.x
	# STECKEN, und wir haben JEDEN weiteren Frame den (noch nicht ganz
	# abgeklungenen) Puffer NOCHMAL draufaddiert -> unkontrolliertes Aufschaukeln
	# ("Magnet"-Gefuehl), das sich beim naechsten Nicht-Stun-Frame wieder
	# schlagartig auf 0 totbremste. Deshalb rechnen wir "move_x"/"move_z" jetzt
	# aus dem RESIDUAL (aktuelle velocity MINUS dem zuletzt aufaddierten
	# Knockback-Anteil) — die reine Eigenbewegung bleibt so unabhaengig vom
	# Knockback-Puffer, egal ob gestunnt, in der Luft oder am Stehen.
	var move_x: float
	var move_z: float
	if direction.length() > 0.1:
		move_x = direction.x * effective_speed
		move_z = direction.z * effective_speed
	else:
		var residual_x: float = velocity.x - _knockback_velocity.x
		var residual_z: float = velocity.z - _knockback_velocity.z
		move_x = move_toward(residual_x, 0.0, effective_speed)
		move_z = move_toward(residual_z, 0.0, effective_speed)

	# Knockback-Puffer klingt UNABHAENGIG von Input/Stun ab und wird jeden
	# Frame frisch (nicht kumulativ) mit der Eigenbewegung kombiniert.
	_knockback_velocity.x = move_toward(_knockback_velocity.x, 0.0, knockback_friction * delta)
	_knockback_velocity.z = move_toward(_knockback_velocity.z, 0.0, knockback_friction * delta)

	velocity.x = move_x + _knockback_velocity.x
	velocity.z = move_z + _knockback_velocity.z

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
