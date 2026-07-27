extends RigidBody3D
class_name Bomb

# ============================================================================
# Bomb — gezuendete Bombe: liegt herum, laesst sich schieben, explodiert.
# ============================================================================
# Baut sich wie Pickup komplett selbst auf, damit es keine bomb.tscn braucht.
#
# WARUM RIGIDBODY3D UND NICHT AREA3D/STATICBODY:
# Die Bombe soll sich schieben lassen — vom Spieler UND von Gegnern. Das
# geht nur mit echter Physik.
#
# ABER: CharacterBody3D schiebt RigidBody3D in Godot 4 NICHT automatisch.
# move_and_slide() gleitet an der Bombe ab, ohne Impuls zu uebertragen.
# Deshalb sitzt unten ein eigener Schiebe-Bereich (_push_area), der
# ueberlappende CharacterBody3D-Nodes einsammelt und ihnen anhand ihrer
# eigenen Geschwindigkeit einen passenden Impuls auf die Bombe uebersetzt.
# Ohne diesen Umweg fuehlt sich die Bombe an wie ein festgeschraubter Stein.
#
# ---------------------------------------------------------------------------
# AENDERUNG: GROESSERE EXPLOSION UND WEITERE WUERFE
# ---------------------------------------------------------------------------
# explosion_radius liegt jetzt bei 9.0 statt 4.5 — also 4x4 Kacheln statt
# 2x2. Damit sind zwei Folgeaenderungen zwingend, sonst fuehlt sich die
# groessere Bombe schlechter an als die kleine:
#
#   * SELBSTSCHADEN-RADIUS ist ENTKOPPELT (self_damage_radius_factor).
#     Bei 9 m Radius steht der Spieler nach einem Wurf fast immer noch in
#     der eigenen Explosion. Ohne eigenen, kleineren Radius fuer Eigen-
#     schaden waere die Bombe kein Werkzeug mehr, sondern eine Falle — und
#     zwar eine, die der Spieler nicht sehen kann. Der Schaden am eigenen
#     Koerper bleibt also auf den Kern beschraenkt (Standard 55 % des
#     Radius); wer nah dran steht, wird weiterhin bestraft.
#
#   * FLUGMODUS (launch()). Die eigentliche Ursache fuer kurze Wuerfe war
#     NICHT die Wurfkraft, sondern linear_damp = 3.0: eine geworfene Bombe
#     verlor ihre Geschwindigkeit schon in der Luft und fiel wie ein nasser
#     Sack. Waehrend des Flugs laeuft die Bombe deshalb mit sehr geringer
#     Daempfung; erst bei Bodenkontakt wird auf die hohe Roll-Daempfung
#     umgeschaltet, damit sie liegenbleibt statt wie eine Bowlingkugel
#     durch den Raum zu schiessen. Einfach nur den Impuls hochzudrehen
#     haette eine Bombe ergeben, die weit fliegt UND unkontrolliert
#     weiterrollt.

signal exploded(position: Vector3)

@export var fuse_time: float = 2.0
@export var damage: float = 50.0

## Deutlich groesser als die urspruenglichen 4,5. Bei ca. 2,25 m pro Kachel
## entspricht 9,0 einem Areal von rund 4x4 Kacheln um die Bombe herum.
## Notfalls hier nachziehen, nicht im Explosionscode.
@export var explosion_radius: float = 9.0

## Anteil des Explosionsradius, in dem der SPIELER Schaden nimmt. Siehe
## Begruendung im Kopf der Datei.
@export_range(0.1, 1.0) var self_damage_radius_factor: float = 0.55

## Wie stark Getroffene weggeschoben werden. Mit dem groesseren Radius
## angehoben, damit der Rand der Explosion noch spuerbar ist.
@export var knockback_force: float = 26.0

## Wie stark der Spieler die Bombe wegschieben kann.
@export var push_strength: float = 5.0
@export var push_radius: float = 0.9

## Ob die Explosion auch dem Spieler schadet. Klassisch: ja.
@export var damages_player: bool = true
## Anteil des Schadens, den der Spieler abbekommt.
@export_range(0.0, 1.0) var self_damage_ratio: float = 0.5

## --- Flug- und Rollverhalten -----------------------------------------
## Daempfung, solange die Bombe fliegt. Nahe 0 = echte Wurfparabel.
@export var flight_damp: float = 0.12
## Daempfung am Boden. Hoch, damit die Bombe nach kurzem Rollen liegt.
@export var ground_damp: float = 3.0
## Notbremse: nach so vielen Sekunden endet der Flugmodus auf jeden Fall.
## Ohne diese Grenze bliebe eine Bombe, die in einer Ecke haengt und den
## Boden-Raycast nie ausloest, dauerhaft ungedaempft.
@export var max_flight_time: float = 2.5
## Wie weit unter dem Bombenmittelpunkt nach Boden gesucht wird.
@export var ground_probe_length: float = 0.45

@export var debug_logging: bool = false

var _fuse_remaining: float = 0.0
var _exploded: bool = false
var _mesh: MeshInstance3D = null
var _push_area: Area3D = null
var _blink_accumulator: float = 0.0
var _in_flight: bool = false
var _flight_time: float = 0.0

## Wer die Bombe gelegt hat. Wird als Schadensquelle durchgereicht, damit
## Health.last_damage_source (Richtung der Todesanimation) stimmt.
var thrower: Node3D = null


func _debug(msg: String) -> void:
	if debug_logging:
		print("[Bomb] %s" % msg)


func _ready() -> void:
	# Gruppe fuer Kettenreaktionen und den Magneten des Kompass-Items.
	add_to_group("bombs")
	_fuse_remaining = fuse_time

	mass = 2.5
	linear_damp = ground_damp
	angular_damp = 4.0
	continuous_cd = true
	contact_monitor = false

	_build_collision()
	_build_visual()
	_build_push_area()


func _build_collision() -> void:
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.32
	shape.shape = sphere
	add_child(shape)


func _build_visual() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.32
	sphere.height = 0.64
	sphere.radial_segments = 10
	sphere.rings = 6

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.16, 0.16, 0.20)
	material.emission_enabled = true
	material.emission = Color(0.9, 0.25, 0.15)
	material.emission_energy_multiplier = 0.0

	_mesh = MeshInstance3D.new()
	_mesh.mesh = sphere
	# material_override statt surface_material_override — Vorrangregel.
	_mesh.material_override = material
	add_child(_mesh)


func _build_push_area() -> void:
	_push_area = Area3D.new()
	_push_area.name = "PushArea"
	# Alle Layer abhorchen: Spieler und Gegner liegen je nach Szene auf
	# unterschiedlichen Ebenen, und eine zu enge Maske aeussert sich nicht
	# als Fehler, sondern nur als "die Bombe laesst sich nicht schieben".
	_push_area.collision_mask = 0xFFFFF
	_push_area.monitoring = true
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = push_radius
	shape.shape = sphere
	_push_area.add_child(shape)
	add_child(_push_area)


func _physics_process(delta: float) -> void:
	if _exploded:
		return

	_fuse_remaining -= delta
	_update_flight(delta)
	_update_blink(delta)
	_apply_push_from_bodies()

	if _fuse_remaining <= 0.0:
		explode()


# ============================================================================
# Wurf und Flug
# ============================================================================
## Vom BombCarrier statt apply_central_impulse() aufzurufen. Setzt zusaetzlich
## die Daempfung fuer die Flugphase herunter — genau das entscheidet ueber die
## Wurfweite.
func launch(impulse: Vector3) -> void:
	if impulse.length() <= 0.01:
		return
	_in_flight = true
	_flight_time = 0.0
	linear_damp = flight_damp
	apply_central_impulse(impulse)
	_debug("Geworfen mit Impuls %.1f." % impulse.length())


## Beendet den Flugmodus, sobald die Bombe Boden beruehrt oder die Notbremse
## greift. Der Raycast fragt die echte Welt ab statt sich auf
## linear_velocity.y zu verlassen: am Scheitelpunkt der Wurfparabel ist die
## Vertikalgeschwindigkeit ebenfalls 0, und die Bombe wuerde mitten in der
## Luft abgebremst.
func _update_flight(delta: float) -> void:
	if not _in_flight:
		return

	_flight_time += delta
	if _flight_time >= max_flight_time or _is_grounded():
		_in_flight = false
		linear_damp = ground_damp
		_debug("Landung nach %.2f s." % _flight_time)


func _is_grounded() -> bool:
	var world: World3D = get_world_3d()
	if world == null:
		return true

	var query := PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3(0.0, -ground_probe_length, 0.0)
	)
	query.collide_with_areas = false
	query.exclude = [get_rid()]
	return not world.direct_space_state.intersect_ray(query).is_empty()


## Das Blinken beschleunigt sich, je kuerzer die Zuendschnur wird — das ist
## die einzige Information, die der Spieler ueber die Restzeit bekommt, und
## sie muss aus dem Augenwinkel lesbar sein.
func _update_blink(delta: float) -> void:
	if _mesh == null or not (_mesh.material_override is StandardMaterial3D):
		return

	var progress: float = 1.0 - clampf(_fuse_remaining / maxf(fuse_time, 0.01), 0.0, 1.0)
	var frequency: float = lerpf(3.0, 18.0, progress)
	_blink_accumulator += delta * frequency

	var pulse: float = (sin(_blink_accumulator * TAU) * 0.5 + 0.5)
	var material: StandardMaterial3D = _mesh.material_override
	material.emission_energy_multiplier = pulse * lerpf(1.0, 3.5, progress)


## Uebersetzt die Eigenbewegung ueberlappender Charaktere in einen Impuls.
## Nur wer sich AUF die Bombe zubewegt, schiebt sie — sonst wuerde ein
## Gegner, der daneben herlaeuft, die Bombe seitlich wegsaugen.
func _apply_push_from_bodies() -> void:
	if _push_area == null:
		return

	for body: Node3D in _push_area.get_overlapping_bodies():
		if not (body is CharacterBody3D):
			continue

		var character: CharacterBody3D = body as CharacterBody3D
		var to_bomb: Vector3 = global_position - character.global_position
		to_bomb.y = 0.0
		if to_bomb.length() < 0.01:
			continue
		to_bomb = to_bomb.normalized()

		var flat_velocity := Vector3(character.velocity.x, 0.0, character.velocity.z)
		var closing_speed: float = flat_velocity.dot(to_bomb)
		if closing_speed <= 0.1:
			continue

		apply_central_impulse(to_bomb * closing_speed * push_strength * get_physics_process_delta_time())


# ============================================================================
# Explosion
# ============================================================================
func explode() -> void:
	if _exploded:
		return
	_exploded = true

	var origin: Vector3 = global_position
	_debug("Explosion bei %s (Radius %.1f)." % [origin, explosion_radius])

	_damage_targets(origin)
	_chain_other_bombs(origin)

	exploded.emit(origin)

	Juice.hit_stop(Juice.DURATION_EXPLOSION)
	# Mit dem groesseren Radius auch mehr Wucht auf der Kamera.
	Juice.shake(1.4)

	_spawn_flash(origin)
	queue_free()


func _damage_targets(origin: Vector3) -> void:
	# Gegner — voller Radius.
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		_damage_one(node as Node3D, origin, damage, explosion_radius)

	# Spieler — nur der Kern der Explosion.
	if not damages_player:
		return
	var self_radius: float = explosion_radius * self_damage_radius_factor
	for node: Node in get_tree().get_nodes_in_group("player"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		_damage_one(node as Node3D, origin, damage * self_damage_ratio, self_radius)


## Schaden faellt linear mit der Entfernung ab. Am Rand des Radius bleiben
## noch 40 % uebrig: ein harter Cutoff fuehlt sich unfair an, weil man den
## Radius im Spiel nicht sieht.
func _damage_one(target: Node3D, origin: Vector3, full_damage: float, radius: float) -> void:
	var distance: float = target.global_position.distance_to(origin)
	if distance > radius:
		return

	var health := target.find_child("Health", true, false) as Health
	if health == null or not health.is_alive():
		return

	var falloff: float = lerpf(1.0, 0.4, clampf(distance / maxf(radius, 0.01), 0.0, 1.0))
	health.take_damage(full_damage * falloff, thrower if thrower else self)

	if target.get("is_heavy") == true:
		return

	var push: Vector3 = target.global_position - origin
	push.y = 0.0
	if push.length() < 0.01:
		push = Vector3.FORWARD
	push = push.normalized() * knockback_force * falloff

	if target.has_method("apply_knockback"):
		target.apply_knockback(push + Vector3.UP * 3.0)


## Kettenreaktion: eine Explosion zuendet benachbarte Bomben sofort.
## deferred, damit nicht mitten in der eigenen queue_free()-Runde eine
## zweite Bombe dieselbe Liste veraendert.
func _chain_other_bombs(origin: Vector3) -> void:
	for node: Node in get_tree().get_nodes_in_group("bombs"):
		if node == self or not is_instance_valid(node) or not (node is Bomb):
			continue
		var other: Bomb = node as Bomb
		if other.global_position.distance_to(origin) > explosion_radius:
			continue
		other.trigger_now.call_deferred()


## Zuendet sofort — fuer Kettenreaktionen und Skript-Ausloeser.
func trigger_now() -> void:
	if _exploded:
		return
	_fuse_remaining = 0.0
	explode()


# ============================================================================
# Explosions-VFX
# ============================================================================
## Drei Ebenen statt einer einzelnen Kugel: greller Kern, aufreissende
## Feuerkugel auf VOLLEM Radius und eine flache Schockwelle am Boden.
##
## Die Schockwelle ist der wichtigste Teil: sie ist das einzige Element, das
## dem Spieler zeigt, WIE WEIT die Explosion tatsaechlich reicht. Bei 9 m
## Radius ist das kein Detail mehr — ohne diese Rueckmeldung wirkt jeder
## Treffer am Rand wie ein Zufallstreffer.
func _spawn_flash(origin: Vector3) -> void:
	var parent: Node = get_tree().current_scene
	if parent == null:
		return

	_spawn_fireball(parent, origin)
	_spawn_core(parent, origin)
	_spawn_shockwave(parent, origin)
	_spawn_light(parent, origin)


func _spawn_fireball(parent: Node, origin: Vector3) -> void:
	var sphere := SphereMesh.new()
	sphere.radius = explosion_radius * 0.5
	sphere.height = explosion_radius
	sphere.radial_segments = 12
	sphere.rings = 8

	var material := _make_flash_material(Color(1.0, 0.62, 0.22, 0.62))

	var flash := MeshInstance3D.new()
	flash.mesh = sphere
	flash.material_override = material
	flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(flash)
	flash.global_position = origin
	flash.scale = Vector3.ONE * 0.25

	var tween := flash.create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "scale", Vector3.ONE * 1.05, 0.30) \
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.42)
	tween.chain().tween_callback(flash.queue_free)


func _spawn_core(parent: Node, origin: Vector3) -> void:
	var sphere := SphereMesh.new()
	sphere.radius = explosion_radius * 0.22
	sphere.height = explosion_radius * 0.44
	sphere.radial_segments = 10
	sphere.rings = 6

	var material := _make_flash_material(Color(1.0, 0.97, 0.85, 0.95))

	var core := MeshInstance3D.new()
	core.mesh = sphere
	core.material_override = material
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(core)
	core.global_position = origin
	core.scale = Vector3.ONE * 0.4

	var tween := core.create_tween()
	tween.set_parallel(true)
	tween.tween_property(core, "scale", Vector3.ONE * 1.3, 0.14) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.18)
	tween.chain().tween_callback(core.queue_free)


## Flacher, sich aufweitender Zylinder direkt ueber dem Boden. Startet bei
## Radius 0 und endet exakt auf explosion_radius — die Kante der Welle IST
## die Reichweitenanzeige.
func _spawn_shockwave(parent: Node, origin: Vector3) -> void:
	var ring := CylinderMesh.new()
	ring.top_radius = 1.0
	ring.bottom_radius = 1.0
	ring.height = 0.35
	ring.radial_segments = 24
	ring.rings = 1

	var material := _make_flash_material(Color(1.0, 0.85, 0.55, 0.45))

	var wave := MeshInstance3D.new()
	wave.mesh = ring
	wave.material_override = material
	wave.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(wave)
	wave.global_position = origin + Vector3(0.0, 0.2, 0.0)
	wave.scale = Vector3(0.2, 1.0, 0.2)

	var tween := wave.create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave, "scale", Vector3(explosion_radius, 0.35, explosion_radius), 0.34) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.38)
	tween.chain().tween_callback(wave.queue_free)


## Kurzer Lichtblitz. Ohne ihn bleibt die Umgebung waehrend der Explosion
## unveraendert dunkel, und die Wucht endet an der Kante der Meshes.
func _spawn_light(parent: Node, origin: Vector3) -> void:
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.72, 0.35)
	light.light_energy = 6.0
	light.omni_range = explosion_radius * 1.4
	light.shadow_enabled = false
	parent.add_child(light)
	light.global_position = origin + Vector3(0.0, 0.8, 0.0)

	var tween := light.create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.32) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(light.queue_free)


func _make_flash_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.disable_receive_shadows = true
	return material


func get_fuse_remaining() -> float:
	return _fuse_remaining


func is_in_flight() -> bool:
	return _in_flight
