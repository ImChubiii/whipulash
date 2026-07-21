extends Area3D
class_name Hitbox

signal hit_landed(target: Node)

@export var damage: float = 10.0
@export var knockback_force: float = 5.0

# Wie lange der GETROFFENE (falls er "apply_stun" unterstützt, z.B. der
# Player) durch diesen Treffer gestunnt wird. 0.0 = kein Stun-Effekt.
@export var stun_duration: float = 0.0

# NEU: Generischer Status-Effekt, den dieser Angriff zusätzlich anwendet
# — funktioniert für BEIDE Seiten (Gegner-Angriffe auf den Player UND
# Spieler-Waffen auf Gegner), solange das getroffene Objekt eine
# apply_status_effect()-Methode hat (Player UND EnemyAI haben das).
#
# Beispiel Gift-Handschuh: status_effect_id = "poison",
# status_effect_duration = 5.0, status_effect_magnitude = 3.0,
# status_effect_tick_interval = 1.0 -> vergiftet für 5s, alle 1s 3 Schaden.
#
# Beispiel Slow-Waffe: status_effect_id = "slow",
# status_effect_duration = 2.0, status_effect_magnitude = 0.5,
# status_effect_tick_interval = 0.0 -> 2s lang 50% langsamer, kein Tick.
#
# Leer lassen (status_effect_id = "") = kein zusätzlicher Effekt, nur
# normaler Schaden (+ optional Stun, siehe oben).
@export var status_effect_id: String = ""
@export var status_effect_duration: float = 0.0
@export var status_effect_magnitude: float = 1.0
@export var status_effect_tick_interval: float = 0.0

# Ziehe hier im Inspector die damage_number.tscn rein, um bei jedem
# Treffer eine fliegende Schadenszahl zu spawnen.
@export var damage_number_scene: PackedScene

# --- Debug ---
# Schaltet die "Hitbox DEBUG:"-Konsolen-Ausgaben für DIESE Hitbox an/aus.
@export var debug_logging: bool = false

# Optional: ein Mesh-Kind-Node (z.B. "Visual"), das nur während activate()
# sichtbar ist — reines Debug-/Feedback-Feature, kein Gameplay-Effekt.
@onready var visual: MeshInstance3D = get_node_or_null("Visual")

# Verhindert, dass derselbe Gegner mehrfach in derselben Aktivierung
# getroffen wird (z.B. wenn er 3 Frames lang in der Hitbox steht).
var _already_hit: Array[Node] = []

func _debug(msg: String) -> void:
	if debug_logging:
		print("Hitbox DEBUG [%s]: %s" % [get_path(), msg])

func _ready() -> void:
	# monitoring = false heißt: die Hitbox erkennt erstmal NICHTS,
	# bis wir sie über activate() bewusst einschalten.
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

	# Verhindert Friendly Fire / Self-Damage: "owner" zeigt automatisch auf
	# den Root-Node der Szene, in der diese Hitbox liegt (also den Player,
	# der die Hitbox als Kind besitzt).
	if body == owner:
		_debug("  -> ignoriert: body ist der owner selbst (Self-Damage-Schutz)")
		return

	if body in _already_hit:
		_debug("  -> ignoriert: body wurde in dieser Aktivierung bereits getroffen")
		return

	# Sucht eine Health-Komponente als Kind-Node des getroffenen Objekts
	var health := body.find_child("Health", true, false)
	if health == null or not (health is Health):
		_debug("  -> ignoriert: kein Health-Node am getroffenen Objekt gefunden (health=%s)" % health)
		return  # getroffenes Objekt hat keine Health-Komponente (z.B. Wand)

	_debug("  -> TREFFER BESTÄTIGT. Schaden=%.1f, stun_duration=%.2f, status_effect_id='%s'" % [damage, stun_duration, status_effect_id])

	_already_hit.append(body)
	health.take_damage(damage, owner)
	hit_landed.emit(body)
	_spawn_damage_number(body)

	# Stun anwenden, falls dieser Angriff einen hat.
	if stun_duration > 0.0 and body.has_method("apply_stun"):
		body.apply_stun(stun_duration)
		_debug("  -> apply_stun(%.2f) auf '%s' aufgerufen" % [stun_duration, body.name])

	# NEU: Generischen Status-Effekt anwenden, falls gesetzt — funktioniert
	# für jeden Effekt-Typ (poison, slow, fear, ...), solange das Ziel
	# apply_status_effect() unterstützt (Player und EnemyAI beide ja).
	if status_effect_id != "" and body.has_method("apply_status_effect"):
		body.apply_status_effect(status_effect_id, status_effect_duration, status_effect_magnitude, owner, status_effect_tick_interval)
		_debug("  -> apply_status_effect('%s', duration=%.2f, magnitude=%.2f, tick=%.2f) auf '%s' aufgerufen" % [status_effect_id, status_effect_duration, status_effect_magnitude, status_effect_tick_interval, body.name])

	# Einfacher Knockback: Richtung von der Hitbox weg zum getroffenen Objekt
	if body is CharacterBody3D:
		var push_dir := (body.global_position - global_position).normalized()
		body.velocity += push_dir * knockback_force

func _spawn_damage_number(body: Node3D) -> void:
	if not damage_number_scene:
		push_warning("Hitbox: damage_number_scene ist NICHT gesetzt im Inspector!")
		return

	var number := damage_number_scene.instantiate()
	# WICHTIG: der Zahl-Node kommt in die Hauptszene, NICHT als Kind
	# der Hitbox — sonst würde sie sich mit dem Spieler mitbewegen
	# statt an Ort und Stelle über dem Gegner stehen zu bleiben.
	get_tree().current_scene.add_child(number)
	number.global_position = body.global_position + Vector3(0, 1.8, 0)
	number.show_damage(damage)
