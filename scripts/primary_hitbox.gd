
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

@onready var visual: MeshInstance3D = get_node_or_null("Visual")

var _already_hit: Array[Node] = []


func _debug(msg: String) -> void:
	if debug_logging:
		print("Hitbox DEBUG [%s]: %s" % [get_path(), msg])


func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)
	if visual:
		visual.visible = false


func activate() -> void:
	_already_hit.clear()
	monitoring = true
	_debug("activate() aufgerufen. monitoring=%s, global_position=%s, owner=%s" % [monitoring, global_position, owner])
	if visual:
		visual.visible = true


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


func _spawn_damage_number(body: Node3D) -> void:
	if not damage_number_scene:
		push_warning("Hitbox: damage_number_scene ist NICHT gesetzt im Inspector!")
		return

	var number := damage_number_scene.instantiate()
	get_tree().current_scene.add_child(number)
	number.global_position = body.global_position + Vector3(0, 1.8, 0)
	number.show_damage(damage)
