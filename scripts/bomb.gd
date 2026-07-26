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

signal exploded(position: Vector3)

@export var fuse_time: float = 2.0
@export var damage: float = 50.0

## Standardmaessig 2 x 2 Kacheln. Die Kachelgroesse haengt am Level-Setup —
## bei 2,25 m pro Kachel entspricht ein Radius von 4,5 genau einem 2x2-Feld
## um die Bombe herum. Notfalls hier nachziehen, nicht im Explosionscode.
@export var explosion_radius: float = 4.5

## Wie stark Getroffene weggeschoben werden.
@export var knockback_force: float = 16.0

## Wie stark der Spieler die Bombe wegschieben kann.
@export var push_strength: float = 5.0
@export var push_radius: float = 0.9

## Ob die Explosion auch dem Spieler schadet. Klassisch: ja.
@export var damages_player: bool = true
## Anteil des Schadens, den der Spieler abbekommt.
@export_range(0.0, 1.0) var self_damage_ratio: float = 0.5

@export var debug_logging: bool = false

var _fuse_remaining: float = 0.0
var _exploded: bool = false
var _mesh: MeshInstance3D = null
var _push_area: Area3D = null
var _blink_accumulator: float = 0.0

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
	# Hohe lineare Daempfung: eine Bombe soll angeschoben ein Stueck rollen
	# und dann liegenbleiben, nicht wie eine Bowlingkugel durch den Raum
	# schiessen.
	linear_damp = 3.0
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
	_update_blink(delta)
	_apply_push_from_bodies()

	if _fuse_remaining <= 0.0:
		explode()


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
	Juice.shake(0.9)

	_spawn_flash(origin)
	queue_free()


func _damage_targets(origin: Vector3) -> void:
	# Gegner
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		_damage_one(node as Node3D, origin, damage)

	# Spieler
	if not damages_player:
		return
	for node: Node in get_tree().get_nodes_in_group("player"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		_damage_one(node as Node3D, origin, damage * self_damage_ratio)


## Schaden faellt linear mit der Entfernung ab. Am Rand des Radius bleiben
## noch 40 % uebrig: ein harter Cutoff fuehlt sich unfair an, weil man den
## Radius im Spiel nicht sieht.
func _damage_one(target: Node3D, origin: Vector3, full_damage: float) -> void:
	var distance: float = target.global_position.distance_to(origin)
	if distance > explosion_radius:
		return

	var health := target.find_child("Health", true, false) as Health
	if health == null or not health.is_alive():
		return

	var falloff: float = lerpf(1.0, 0.4, clampf(distance / maxf(explosion_radius, 0.01), 0.0, 1.0))
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


## Kurzer, heller Blitz als Platzhalter fuer ein richtiges VFX. Sobald es
## eine Partikelszene gibt, hier VFX.spawn() aufrufen und diese Funktion
## loeschen.
func _spawn_flash(origin: Vector3) -> void:
	var parent: Node = get_tree().current_scene
	if parent == null:
		return

	var sphere := SphereMesh.new()
	sphere.radius = explosion_radius * 0.5
	sphere.height = explosion_radius
	sphere.radial_segments = 12
	sphere.rings = 8

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.75, 0.30, 0.65)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED

	var flash := MeshInstance3D.new()
	flash.mesh = sphere
	flash.material_override = material
	flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(flash)
	flash.global_position = origin
	flash.scale = Vector3.ONE * 0.3

	var tween := flash.create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "scale", Vector3.ONE * 1.15, 0.22)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.28)
	tween.chain().tween_callback(flash.queue_free)


func get_fuse_remaining() -> float:
	return _fuse_remaining
