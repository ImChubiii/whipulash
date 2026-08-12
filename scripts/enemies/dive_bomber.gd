extends CustomEnemyBase
class_name DiveBomber

# ============================================================================
# Divebomber — fliegender Gegner.
# ============================================================================
# Wartet ausserhalb der Nahkampf-Reichweite in der Luft (leichtes Schweben/
# Wippen, KEIN staendiges Kreisen mehr um den Spieler) und stuerzt im festen
# Rhythmus (DASH_INTERVAL) auf ihn herab: LOCK-Phase mit sichtbarem
# Lean/Telegraph-Ring, dann senkrechter Sturz auf die zu diesem Zeitpunkt
# FESTGELEGTE Position.
#
# Der Einschlag passiert IMMER (Treffer oder nicht) und hinterlaesst
# liegenbleibende Gesteinstruemmer auf dem Boden - anders als normale VFX
# blenden diese nicht automatisch aus, sie werden nur beim Force-Clear ueber
# _cleanup_effects() entfernt (siehe dort). Der Bomber selbst ist danach
# IMMER fuer GROUNDED_STUN_TIME (5 s) bewegungsunfaehig, bevor er wieder
# aufsteigt und den naechsten Rhythmus startet - unabhaengig davon, ob der
# Sturz getroffen hat. Nur der SCHADEN haengt weiter davon ab, ob der
# Spieler beim Einschlag noch im Ziel-Radius stand.

enum State { HOVER, LOCK, DIVE, GROUNDED, RECOVER }

const DUST_RING_SCENE: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const SPARK_YELLOW_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const ROCK_COLOR: Color = Color(0.32, 0.28, 0.26)

## War 11.0 - Rueckmeldung "zu tief, nicht weit oben in der Luft" (2026-08-12).
var hover_height: float = 16.0
var hover_recenter_speed: float = 2.5
var dash_interval: float = 3.4
var lock_time: float = 0.9
var dive_speed: float = 34.0
var hit_radius: float = 2.4
var damage: float = 20.0
var grounded_stun_time: float = 5.0
var recover_speed: float = 10.0
var detect_range: float = 40.0

## Optisch (und, ueber die Kollisionsbox, auch spielerisch) groesser - reine
## Groessenanpassung, siehe visual_root.scale unten.
## War 1.5, dann 4.5 ("jeder Gegner ausser Magnet soll 3x groesser sein").
## Rueckmeldung "zu gross" (2026-08-12): auf 3.0 zurueckgenommen.
const VISUAL_SCALE: float = 3.0

var _state: State = State.HOVER
var _bob_phase: float = 0.0
var _timer: float = 0.0
var _dive_target: Vector3 = Vector3.ZERO
var _lock_marker: MeshInstance3D = null
var _visual_body: MeshInstance3D = null
var _rubble: Array[Node3D] = []

## Feste Ziel-Hoehe fuer den RECOVER-Zustand, EINMALIG beim Verlassen von
## GROUNDED gesetzt statt bei jedem _do_recover()-Aufruf neu berechnet.
##
## BUGFIX "Divebomber stuerzt in den Boden, steigt dann auf und kommt nie
## wieder runter": target_y wurde vorher JEDEN Frame frisch aus der
## AKTUELLEN global_position.y berechnet (target_y = aktuelle Hoehe +
## hover_height * 0.5). Damit war target_y immer um denselben Betrag ueber
## der aktuellen Position - move_toward kam der Zielhoehe also nie naeher
## (der "Abstand" wurde ja jeden Frame neu auf denselben Wert zurueckgesetzt),
## der Bomber stieg dadurch unbegrenzt weiter, statt jemals in den HOVER-
## Zustand zurueckzuwechseln.
var _recover_target_y: float = 0.0


func _configure() -> void:
	display_name = "Divebomber"
	max_health = 55.0


func _build() -> void:
	_build_visual()
	visual_root.scale = Vector3.ONE * VISUAL_SCALE
	_add_box_collision(Vector3(1.6, 1.0, 1.6) * VISUAL_SCALE)
	_bob_phase = randf() * TAU
	_timer = dash_interval * randf_range(0.4, 1.0)


func _build_visual() -> void:
	var body_mesh := SphereMesh.new()
	body_mesh.radius = 0.75
	body_mesh.height = 1.1
	_visual_body = MeshInstance3D.new()
	_visual_body.mesh = body_mesh
	_visual_body.material_override = _make_unshaded_material(Color(0.9, 0.55, 0.1), 1.2)
	visual_root.add_child(_visual_body)

	var wing_mesh := BoxMesh.new()
	wing_mesh.size = Vector3(2.6, 0.12, 0.6)
	var wings := MeshInstance3D.new()
	wings.mesh = wing_mesh
	wings.material_override = _make_unshaded_material(Color(0.3, 0.28, 0.32))
	_visual_body.add_child(wings)

	var light := OmniLight3D.new()
	light.light_color = Color(0.9, 0.55, 0.1)
	light.light_energy = 0.9
	light.omni_range = 4.0
	light.shadow_enabled = false
	_visual_body.add_child(light)


func _physics_process(delta: float) -> void:
	match _state:
		State.HOVER:
			_do_hover(delta)
		State.LOCK:
			_do_lock(delta)
		State.DIVE:
			_do_dive(delta)
		State.GROUNDED:
			_do_grounded(delta)
		State.RECOVER:
			_do_recover(delta)


## Bleibt weitgehend an Ort und Stelle (nur ein sanftes Auf/Ab), statt
## staendig um den Spieler zu kreisen - die vorherige schnelle Orbit-Bewegung
## machte den Rhythmus des Sturzangriffs schwer lesbar. Zentriert sich nur
## LANGSAM horizontal ueber die aktuelle Spielerposition nach, damit er nicht
## komplett aus dem Kampf herauslaeuft.
func _do_hover(delta: float) -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return

	_bob_phase += delta * 1.2
	var wanted: Vector3 = player.global_position + Vector3.UP * hover_height
	wanted.y += sin(_bob_phase) * 0.4
	global_position = global_position.move_toward(wanted, hover_recenter_speed * delta)
	if _visual_body:
		_visual_body.rotation.y += delta * 0.4

	if global_position.distance_to(player.global_position) > detect_range:
		return

	_timer -= delta
	if _timer <= 0.0:
		_timer = dash_interval
		_start_lock(player)


func _start_lock(player: CharacterBody3D) -> void:
	_state = State.LOCK
	_timer = lock_time
	_dive_target = player.global_position

	_lock_marker = MeshInstance3D.new()
	var ring := CylinderMesh.new()
	ring.top_radius = hit_radius
	ring.bottom_radius = hit_radius
	ring.height = 0.05
	_lock_marker.mesh = ring
	var mat := _make_unshaded_material(DANGER_TELEGRAPH_COLOR)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.15
	_lock_marker.material_override = mat
	get_tree().current_scene.add_child(_lock_marker)
	_lock_marker.global_position = _dive_target + Vector3.UP * 0.05

	var tween: Tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.8, lock_time)


func _do_lock(delta: float) -> void:
	# Lean-Telegraph: kippt sichtbar in Richtung des Sturzflugs, statt
	# regungslos in der Luft zu haengen.
	if _visual_body:
		_visual_body.rotation.x = lerpf(_visual_body.rotation.x, deg_to_rad(70.0), delta * 4.0)

	_timer -= delta
	if _timer <= 0.0:
		_state = State.DIVE


func _do_dive(delta: float) -> void:
	global_position.x = move_toward(global_position.x, _dive_target.x, dive_speed * delta)
	global_position.z = move_toward(global_position.z, _dive_target.z, dive_speed * delta)
	global_position.y -= dive_speed * delta

	if _is_at_ground_level():
		_land()


func _is_at_ground_level() -> bool:
	var world: World3D = get_world_3d()
	if world == null:
		return true
	var query := PhysicsRayQueryParameters3D.create(
		global_position, global_position - Vector3(0.0, 1.0, 0.0)
	)
	query.collision_mask = 1
	query.exclude = [get_rid()]
	return not world.direct_space_state.intersect_ray(query).is_empty()


func _land() -> void:
	if is_instance_valid(_lock_marker):
		_lock_marker.queue_free()
	_lock_marker = null

	var impact_pos: Vector3 = _project_to_ground(global_position)
	VFX.spawn(DUST_RING_SCENE, impact_pos)
	Juice.shake(1.2)
	_spawn_rubble(impact_pos)

	var player: CharacterBody3D = _find_player()
	var flat_player: Vector3 = Vector3.ZERO
	var hit_player: bool = false
	if player != null:
		flat_player = player.global_position
		flat_player.y = _dive_target.y
		hit_player = flat_player.distance_to(_dive_target) <= hit_radius

	if hit_player:
		var target_health := player.find_child("Health", true, false) as Health
		if target_health != null and target_health.is_alive():
			target_health.take_damage(damage, self)
		VFX.spawn(SPARK_YELLOW_SCENE, player.global_position + Vector3.UP)

	# IMMER gestunnt, egal ob getroffen wurde - siehe Klassenkommentar.
	_state = State.GROUNDED
	_timer = grounded_stun_time
	if _visual_body:
		_visual_body.rotation.x = deg_to_rad(90.0)


## Wie viele Gesteinsbrocken GLEICHZEITIG pro Bomber liegen bleiben duerfen -
## etwa 2 Einschlaege wert. BUGFIX "Spiel friert nach ~30s ein": Truemmer
## waren komplett unbegrenzt (nur Force-Clear raeumte sie auf). Bei
## dash_interval=3.4s und bis zu 8 Divebombern/Raum (siehe
## resources/enemies/es_divebomber.tres) haetten sich in 30s bereits
## hunderte permanente Meshes + je eine eigene StandardMaterial3D
## angesammelt - genau das hat den Frame-Einbruch verursacht. Vorher fiel
## das nie auf, weil im Sandbox-Testraum nie mehr als 1-2 gleichzeitig
## liefen.
const MAX_RUBBLE_ROCKS: int = 12

## Truemmer, die eine Weile liegen BLEIBEN (kein Fade-Timer wie bei
## normalem VFX) - sichtbarer Beleg dafuer, dass hier gerade etwas
## eingeschlagen ist. Werden beim Force-Clear ueber _cleanup_effects()
## entfernt, ODER sobald MAX_RUBBLE_ROCKS ueberschritten ist (dann zuerst
## der aelteste Brocken).
func _spawn_rubble(pos: Vector3) -> void:
	var rock_count: int = randi_range(4, 6)
	for i: int in range(rock_count):
		var rock := MeshInstance3D.new()
		var box := BoxMesh.new()
		var size: float = randf_range(0.35, 0.75)
		box.size = Vector3(size, size * randf_range(0.5, 0.9), size)
		rock.mesh = box
		rock.material_override = _make_unshaded_material(ROCK_COLOR)

		get_tree().current_scene.add_child(rock)
		var angle: float = randf() * TAU
		var dist: float = randf_range(0.2, hit_radius * 0.8)
		rock.global_position = pos + Vector3(cos(angle) * dist, size * 0.3, sin(angle) * dist)
		rock.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)

		_rubble.append(rock)

	while _rubble.size() > MAX_RUBBLE_ROCKS:
		var oldest: Node3D = _rubble.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()


func _do_grounded(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_state = State.RECOVER
		_recover_target_y = global_position.y + hover_height * 0.5
		if _visual_body:
			_visual_body.rotation.x = 0.0


func _do_recover(delta: float) -> void:
	global_position.y = move_toward(global_position.y, _recover_target_y, recover_speed * delta)
	if global_position.y >= _recover_target_y - 0.1:
		_state = State.HOVER
		_timer = dash_interval


func _cleanup_effects() -> void:
	if is_instance_valid(_lock_marker):
		_lock_marker.queue_free()
	_lock_marker = null
	for rock: Node3D in _rubble:
		if is_instance_valid(rock):
			rock.queue_free()
	_rubble.clear()
