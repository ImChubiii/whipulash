
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
#
# ---------------------------------------------------------------------------
# BUGFIX: "Bomben prallen nicht an Gegnern ab" + "fallen unter den Boden"
# ---------------------------------------------------------------------------
# ROOT CAUSE #1 (kein Abprall):
# Die Bombe hatte NIE ein physics_material_override. Godots Default dafuer
# ist bounce = 0.0. Trifft eine fliegende Bombe auf einen CharacterBody3D
# (physikalisch ein kinematischer Koerper mit quasi unendlicher Masse), gibt
# es rechnerisch keinen Rueckstoss — die Bombe bremst schlicht ab und bleibt
# kleben, statt abzuprallen. _apply_push_from_bodies() half hier nicht: die
# Funktion uebersetzt nur die Bewegung des CHARAKTERS in einen Impuls auf die
# Bombe (fuer's Wegschieben), nicht umgekehrt die Bewegung der Bombe beim
# Einschlag. Fix: physics_material_override mit echtem bounce-Wert UND eine
# explizite Deflektion in _apply_push_from_bodies(), die greift, sobald die
# Bombe selbst schnell unterwegs ist (Wurf/Flug) und in einen Koerper
# hineinfliegt.
#
# ROOT CAUSE #2 (faellt unter den Boden):
# lemonade.gd dokumentiert an anderer Stelle bereits "bei gravity = 40
# liegen zwischen zwei Frames schnell mehr Meter als die Toleranz breit
# ist" — dasselbe Problem trifft die Bombe. Nach voller max_flight_time
# (2.5 s) im freien Fall bei gravity = 40 erreicht linear_velocity.y
# Groessenordnungen von -80 bis -100. continuous_cd hilft gegen Tunneling
# bei KONVEXEN Formen, ist aber bei sehr hohen Geschwindigkeiten gegen
# duenne oder aus mehreren Boxen zusammengesetzte Boden-Collider nicht
# zuverlaessig. Fix: linear_velocity.y wird jeden Physik-Schritt auf
# max_fall_speed geclamped — nicht nur waehrend des Flugmodus, sondern
# permanent, da eine liegende Bombe genauso von einer Explosion in der
# Naehe hochgeschleudert und dann zu schnell wieder fallen kann.

signal exploded(position: Vector3)

@export var fuse_time: float = 2.0
@export var damage: float = 50.0

## Von 9,0 auf 14,0 angehoben (urspruenglich 4,5). Bei ca. 2,25 m pro
## Kachel entspricht 14,0 einem Areal von rund 6x6 Kacheln.
##
## WICHTIG: NICHT im Explosionscode nachziehen. Saemtliche VFX-Groessen
## (Feuerball, Kern, Schockwelle, Splitter, Licht, Brandfleck) leiten sich
## aus DIESEM Wert ab - wer die Reichweite hier aendert, aendert das
## sichtbare Bild automatisch mit. Genau das ist der Punkt: eine Explosion,
## deren Optik nicht zu ihrer echten Reichweite passt, fuehlt sich wie ein
## Zufallstreffer an.
@export var explosion_radius: float = 14.0

## Anteil des Explosionsradius, in dem der SPIELER Schaden nimmt. Siehe
## Begruendung im Kopf der Datei.
## Von 0.55 auf 0.40 gesenkt, weil der Gesamtradius gewachsen ist: 55 %
## von 14 m waeren fast acht Meter Eigengefahr gewesen. 40 % von 14 sind
## 5,6 m - grob dieselbe absolute Gefahrenzone wie vorher, nur eben in
## einer deutlich groesseren Explosion.
@export_range(0.1, 1.0) var self_damage_radius_factor: float = 0.40

## Wie stark Getroffene weggeschoben werden. Mit dem groesseren Radius
## angehoben, damit der Rand der Explosion noch spuerbar ist.
@export var knockback_force: float = 34.0

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

## --- Abprall / Kollisionsverhalten (NEU) -------------------------------
## physics_material_override.bounce. Ohne Wert hier bleibt es bei Godots
## Default 0.0 — die Bombe bremst an Gegnern/Waenden ab, statt abzuprallen.
@export_range(0.0, 1.0) var bounce: float = 0.35
@export_range(0.0, 1.0) var surface_friction: float = 0.6

## Ab welcher Eigengeschwindigkeit (m/s) ein Kontakt mit einem
## CharacterBody3D als "Einschlag" statt als sanftes Anschieben gilt.
@export var deflect_min_speed: float = 1.5
## Wie viel der Einschlagsgeschwindigkeit nach dem Abprall erhalten bleibt.
@export_range(0.0, 1.0) var deflect_retain: float = 0.55
## Kleiner Aufwaerts-Anteil beim Abprall, damit es nicht wie ein reines
## Abgleiten am Boden aussieht, sondern sichtbar "abspringt".
@export_range(0.0, 1.0) var deflect_up_ratio: float = 0.2

## Sicherheitsclamp gegen Boden-Tunneling bei gravity = 40 (siehe
## Root-Cause-Kommentar oben). -28 m/s entspricht bei dieser Gravitation
## grob 0,7 s freiem Fall — mehr braucht kein Bomben-Wurf in diesem Spiel.
@export var max_fall_speed: float = 28.0

## --- Explosions-VFX -----------------------------------------------------
## Anzahl der Splitter, die radial nach aussen fliegen. Sie sind der
## Grund, warum eine Explosion "aufreisst" statt nur aufzuleuchten: eine
## Kugel, die groesser wird, liest das Auge als Ballon. Erst Teile, die
## sich UNTERSCHIEDLICH schnell in UNTERSCHIEDLICHE Richtungen bewegen,
## lesen sich als Detonation.
@export var debris_count: int = 14
@export var debris_size: float = 0.45

## Dunkler Brandfleck, der nach dem Feuer kurz stehenbleibt. Ohne ihn ist
## eine halbe Sekunde nach der Explosion nicht mehr zu sehen, dass an der
## Stelle ueberhaupt etwas passiert ist.
@export var scorch_enabled: bool = true
@export var scorch_lifetime: float = 1.6

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

	# Explizit statt Default: Bombe kollidiert mit derselben Welt-Ebene wie
	# Spieler/Gegner (Layer 1). Vorher lief das stillschweigend ueber den
	# Godot-Default — funktional identisch, aber nicht mehr "zufaellig
	# richtig", falls sich Layer-Konventionen im Projekt mal aendern.
	collision_layer = 1
	collision_mask = 1

	_build_physics_material()
	_build_collision()
	_build_visual()
	_build_push_area()


## NEU: ohne physics_material_override liegt bounce bei 0.0 — die Bombe
## bremst beim Kontakt mit einem Gegner (kinematischer Koerper, quasi
## unendliche Masse) einfach ab, statt abzuprallen. Das war Root Cause #1.
func _build_physics_material() -> void:
	var material := PhysicsMaterial.new()
	material.bounce = bounce
	material.friction = surface_friction
	physics_material_override = material


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

	# NEU: permanenter Sicherheitsclamp gegen Boden-Tunneling, nicht nur
	# waehrend des Flugmodus — siehe Root-Cause-Kommentar #2 im Dateikopf.
	if linear_velocity.y < -max_fall_speed:
		linear_velocity.y = -max_fall_speed

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


## Uebersetzt die Eigenbewegung ueberlappender Charaktere in einen Impuls
## ODER laesst die Bombe an ihnen abprallen — je nachdem, wer sich hier
## eigentlich bewegt:
##   - Charakter laeuft in die stehende/liegende Bombe -> sanftes Anschieben
##     (bestehendes Verhalten, siehe Klassenkommentar oben).
##   - Die Bombe SELBST ist schnell unterwegs (Wurf/Flug) und trifft einen
##     Koerper -> Abprall/Deflektion (NEU, Root Cause #1 im Dateikopf).
func _apply_push_from_bodies() -> void:
	if _push_area == null:
		return

	for body: Node3D in _push_area.get_overlapping_bodies():
		if not (body is CharacterBody3D):
			continue

		var character: CharacterBody3D = body as CharacterBody3D

		if linear_velocity.length() > deflect_min_speed:
			var away: Vector3 = global_position - character.global_position
			away.y = 0.0
			if away.length() > 0.01:
				away = away.normalized()
				var incoming_speed: float = linear_velocity.length()
				var bounced: Vector3 = away * incoming_speed * deflect_retain
				bounced.y = maxf(linear_velocity.y, incoming_speed * deflect_up_ratio)
				linear_velocity = bounced
				_debug("Abprall an '%s' mit %.1f m/s." % [character.name, bounced.length()])
				continue  # kein zusaetzlicher Push-Impuls in derselben Iteration

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
	# Mit dem noch groesseren Radius auch mehr Wucht auf der Kamera.
	Juice.shake(2.0)

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

	_spawn_scorch(parent, origin)
	_spawn_fireball(parent, origin)
	_spawn_core(parent, origin)
	_spawn_shockwave(parent, origin)
	_spawn_outer_ring(parent, origin)
	_spawn_debris(parent, origin)
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
	# TRANS_EXPO statt QUINT: das Aufreissen passiert damit noch staerker
	# in den ersten Frames. Eine Explosion, die gleichmaessig waechst,
	# sieht aus wie ein aufgehender Ballon.
	tween.tween_property(flash, "scale", Vector3.ONE * 1.10, 0.26) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(flash, "rotation:y", TAU * 0.15, 0.50)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.50)
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


## Zweiter, duennerer Ring, der SCHNELLER nach aussen laeuft als die
## Hauptschockwelle und ueber deren Rand hinausschiesst. Zwei Ringe mit
## unterschiedlichem Tempo geben der Explosion Tiefe; einer allein wirkt
## wie eine aufgemalte Kreisanimation.
func _spawn_outer_ring(parent: Node, origin: Vector3) -> void:
	var ring := TorusMesh.new()
	ring.inner_radius = 0.85
	ring.outer_radius = 1.0
	ring.rings = 4
	ring.ring_segments = 28

	var material := _make_flash_material(Color(1.0, 0.95, 0.75, 0.55))

	var wave := MeshInstance3D.new()
	wave.mesh = ring
	wave.material_override = material
	wave.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(wave)
	wave.global_position = origin + Vector3(0.0, 0.35, 0.0)
	wave.scale = Vector3(0.4, 0.4, 0.4)

	var tween := wave.create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave, "scale", Vector3(explosion_radius * 1.15, 0.6, explosion_radius * 1.15), 0.26) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.30)
	tween.chain().tween_callback(wave.queue_free)


## Splitter: kleine Wuerfel, die radial nach aussen und leicht nach oben
## fliegen und dabei schrumpfen.
##
## Bewusst KEIN GPUParticles3D: die Bombe baut sich komplett im Code auf
## (keine bomb.tscn, siehe Klassenkommentar), und ein Partikelsystem
## braeuchte ein ProcessMaterial als Ressource. Ein Dutzend getweente
## Meshes kostet fuer einen Effekt, der eine halbe Sekunde dauert,
## praktisch nichts - und bleibt im PSX-Look sogar naeher am Rest des
## Spiels als weiche Partikel.
func _spawn_debris(parent: Node, origin: Vector3) -> void:
	if debris_count <= 0:
		return

	var box := BoxMesh.new()
	box.size = Vector3.ONE * debris_size

	for i: int in range(debris_count):
		# Gleichmaessig verteilte Winkel plus ein fester Versatz pro
		# Splitter statt reinem Zufall: das Ergebnis sieht ausgewogener
		# aus und ist zwischen zwei Explosionen nicht wiedererkennbar
		# gleich.
		var angle: float = TAU * (float(i) / float(debris_count)) + randf() * 0.35
		var direction := Vector3(cos(angle), 0.0, sin(angle))
		var distance: float = explosion_radius * randf_range(0.45, 0.95)
		var height: float = explosion_radius * randf_range(0.10, 0.30)

		var material := _make_flash_material(Color(1.0, 0.70, 0.30, 0.9))

		var shard := MeshInstance3D.new()
		shard.mesh = box
		shard.material_override = material
		shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(shard)
		shard.global_position = origin + Vector3(0.0, 0.4, 0.0)

		var peak: Vector3 = origin + direction * distance * 0.6 + Vector3(0.0, height, 0.0)
		var landing: Vector3 = origin + direction * distance + Vector3(0.0, 0.15, 0.0)

		var tween := shard.create_tween()
		# Erst Aufstieg, dann Fall - eine gerade Linie nach aussen sieht
		# aus wie ein Sternchen-Sprite, keine Wurfparabel.
		tween.tween_property(shard, "global_position", peak, 0.16) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(shard, "global_position", landing, 0.26) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		var fade := shard.create_tween()
		fade.set_parallel(true)
		fade.tween_property(shard, "rotation", Vector3(randf() * TAU, randf() * TAU, randf() * TAU), 0.42)
		fade.tween_property(shard, "scale", Vector3.ONE * 0.2, 0.42) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		fade.tween_property(material, "albedo_color:a", 0.0, 0.42)
		fade.chain().tween_callback(shard.queue_free)


## Flacher, dunkler Kreis auf Bodenhoehe, der NACH dem Feuer noch kurz
## stehenbleibt und dann ausblendet.
##
## Wird als ERSTES gespawnt, damit er unter allen anderen Ebenen liegt.
## Er benutzt bewusst KEIN additives Blending (im Gegensatz zu allen
## anderen Effekten hier) - additiv gemischtes Schwarz ist unsichtbar.
func _spawn_scorch(parent: Node, origin: Vector3) -> void:
	if not scorch_enabled:
		return

	var disc := CylinderMesh.new()
	disc.top_radius = explosion_radius * 0.75
	disc.bottom_radius = explosion_radius * 0.75
	disc.height = 0.06
	disc.radial_segments = 20
	disc.rings = 1

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.05, 0.04, 0.03, 0.55)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.disable_receive_shadows = true

	var mark := MeshInstance3D.new()
	mark.mesh = disc
	mark.material_override = material
	mark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mark)
	mark.global_position = origin + Vector3(0.0, 0.05, 0.0)
	mark.scale = Vector3(0.3, 1.0, 0.3)

	var tween := mark.create_tween()
	tween.tween_property(mark, "scale", Vector3(1.0, 1.0, 1.0), 0.20) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(maxf(scorch_lifetime - 0.6, 0.0))
	tween.tween_property(material, "albedo_color:a", 0.0, 0.40)
	tween.tween_callback(mark.queue_free)


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
