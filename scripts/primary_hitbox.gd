extends Area3D
class_name Hitbox

signal hit_landed(target: Node)

@export var damage: float = 10.0
@export var knockback_force: float = 0.0
@export var stun_duration: float = 0.0
@export var status_effect_id: String = ""
@export var status_effect_duration: float = 0.0
@export var status_effect_magnitude: float = 1.0
@export var status_effect_tick_interval: float = 0.0
@export var damage_number_scene: PackedScene
@export var debug_logging: bool = false

# --- VFX ---
## Effekt beim Aktivieren der Hitbox (Schlag-Trail / Swoosh).
@export var swing_vfx: PackedScene
## Effekt beim BESTAETIGTEN Treffer (Impact-Funken).
@export var impact_vfx: PackedScene
## Hoehe ueber dem Ziel-Pivot, auf der der Impact erscheint.
@export var impact_height: float = 1.2

@onready var visual: MeshInstance3D = get_node_or_null("Visual")

var _already_hit: Array[Node] = []


func _debug(msg: String) -> void:
	if debug_logging:
		print("Hitbox DEBUG [%s]: %s" % [get_path(), msg])


func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)
	# Der Impact haengt bewusst am eigenen hit_landed-Signal statt in
	# _on_body_entered(): so bleibt die Treffer-Logik voellig unangetastet
	# und der Effekt feuert garantiert erst NACH allen Filtern
	# (Self-Damage, _already_hit, Health-Check).
	hit_landed.connect(_on_hit_landed_vfx)
	if visual:
		visual.visible = false


func activate() -> void:
	_already_hit.clear()
	monitoring = true
	_debug("activate() aufgerufen. monitoring=%s, global_position=%s, owner=%s" % [monitoring, global_position, owner])
	if visual:
		visual.visible = true

	if swing_vfx:
		# Das Projekt nutzt +Z als "vorne", deshalb basis.z (nicht -basis.z).
		VFX.spawn(swing_vfx, global_position, global_transform.basis.z)

	# ROBUSTHEITS-FIX: body_entered feuert nur beim EINTRETEN in die Area.
	# Steht der Spieler beim Aktivieren schon MITTEN in der Hitbox (genau
	# der Normalfall: der Gegner bleibt in Reichweite stehen, telegraphiert
	# und schlaegt dann zu, ohne dass sich jemand bewegt hat), kann das
	# Signal ausbleiben und der Schlag geht wirkungslos durch.
	# Deshalb wird direkt nach der Aktivierung EINMAL aktiv nachgesehen,
	# wer bereits ueberlappt.
	_sweep_initial_overlaps.call_deferred()


## Traegt Bodies nach, die beim Aktivieren bereits in der Hitbox standen.
## Ein Physik-Frame Wartezeit ist noetig, weil die Area ihre Ueberlappungen
## erst nach dem Umschalten von monitoring neu auswertet -
## get_overlapping_bodies() waere im selben Frame noch leer.
func _sweep_initial_overlaps() -> void:
	if not monitoring:
		return
	await get_tree().physics_frame
	if not is_instance_valid(self) or not monitoring:
		return

	for body in get_overlapping_bodies():
		if body is Node3D:
			_debug("Nachtrag-Sweep: '%s' stand beim Aktivieren bereits in der Hitbox." % body.name)
			_on_body_entered(body)


func deactivate() -> void:
	monitoring = false
	_debug("deactivate() aufgerufen.")
	if visual:
		visual.visible = false


func _on_body_entered(body: Node3D) -> void:
	_debug("body_entered ausgelöst: '%s' (Typ: %s)" % [body.name, body.get_class()])

	if body == owner:
		_debug("  -> ignoriert: body ist der owner selbst (Self-Damage-Schutz)")
		return

	if body in _already_hit:
		_debug("  -> ignoriert: body wurde in dieser Aktivierung bereits getroffen")
		return

	var health := body.find_child("Health", true, false)
	if health == null or not (health is Health):
		_debug("  -> ignoriert: kein Health-Node am getroffenen Objekt gefunden (health=%s)" % health)
		return

	_debug("  -> TREFFER BESTÄTIGT. Schaden=%.1f, stun_duration=%.2f, status_effect_id='%s'" % [damage, stun_duration, status_effect_id])

	_already_hit.append(body)
	health.take_damage(damage, owner)
	hit_landed.emit(body)

	if stun_duration > 0.0 and body.has_method("apply_stun"):
		body.apply_stun(stun_duration)
		_debug("  -> apply_stun(%.2f) auf '%s' aufgerufen" % [stun_duration, body.name])

	if status_effect_id != "" and body.has_method("apply_status_effect"):
		body.apply_status_effect(status_effect_id, status_effect_duration, status_effect_magnitude, owner, status_effect_tick_interval)
		_debug("  -> apply_status_effect('%s', duration=%.2f, magnitude=%.2f, tick=%.2f) auf '%s' aufgerufen" % [status_effect_id, status_effect_duration, status_effect_magnitude, status_effect_tick_interval, body.name])

	# Knockback: nur wenn knockback_force > 0.0 und Ziel kein schwerer Gegner.
	#
	# WICHTIG: Player und EnemyAI setzen velocity.x/z JEDEN Physik-Frame direkt
	# aus ihrer eigenen Bewegungslogik (Input bzw. State-Machine) — ein simples
	# "body.velocity += push_dir * knockback_force" wird dadurch im naechsten
	# Frame sofort wieder ueberschrieben und ist praktisch unsichtbar. Deshalb
	# wird bevorzugt apply_knockback() aufgerufen: dort landet der Impuls in
	# einem separaten, ueber Zeit abklingenden Puffer, der von der Bewegung
	# NICHT ueberschrieben wird. Bodies ohne diese Methode fallen weiterhin
	# auf die direkte velocity-Modifikation zurueck.
	if knockback_force > 0.0 and body is CharacterBody3D:
		var is_heavy_target: bool = body.get("is_heavy") == true
		if is_heavy_target:
			_debug("  -> Knockback IGNORIERT: '%s' ist ein schwerer Gegner (is_heavy=true)" % body.name)
		else:
			var push_dir := (body.global_position - global_position).normalized()
			var impulse: Vector3 = push_dir * knockback_force
			if body.has_method("apply_knockback"):
				body.apply_knockback(impulse)
				_debug("  -> Knockback %.1f ueber apply_knockback() auf '%s' angewendet" % [knockback_force, body.name])
			else:
				body.velocity += impulse
				_debug("  -> Knockback %.1f (Fallback: direkt auf velocity) auf '%s' angewendet" % [knockback_force, body.name])

	_spawn_damage_number(body)


func _on_hit_landed_vfx(target: Node) -> void:
	if impact_vfx == null or not (target is Node3D):
		return

	var target_3d: Node3D = target as Node3D
	var dir: Vector3 = target_3d.global_position - global_position
	dir.y = 0.0
	if dir.length_squared() < 0.0001:
		dir = global_transform.basis.z

	# Auf halbem Weg zwischen Hitbox-Mitte und Ziel-Pivot: sieht bei
	# grossen Gegnern (Colossus) deutlich besser aus als exakt im Pivot,
	# der dort tief in der Koerpermitte liegt.
	var spawn_pos: Vector3 = global_position.lerp(target_3d.global_position, 0.5)
	spawn_pos.y = target_3d.global_position.y + impact_height

	VFX.spawn(impact_vfx, spawn_pos, dir.normalized())


func _spawn_damage_number(body: Node3D) -> void:
	if not damage_number_scene:
		push_warning("Hitbox: damage_number_scene ist NICHT gesetzt im Inspector!")
		return

	var number := damage_number_scene.instantiate()
	get_tree().current_scene.add_child(number)
	number.global_position = body.global_position + Vector3(0, 1.8, 0)
	number.show_damage(damage)
