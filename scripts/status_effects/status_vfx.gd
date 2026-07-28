extends GPUParticles3D
class_name StatusVFX

## Schaltet einen Partikel-Emitter anhand eines aktiven Status-Effekts.
##
## VERWENDUNG: GPUParticles3D als Kind des Spielers/Gegners anlegen,
## dieses Script per "Load" zuweisen, effect_id im Inspector setzen.
## Fuer Stun z.B. kreisende Sterne ueber dem Kopf (position.y ~ 2.0).
##
## Funktioniert generisch fuer "stun", "poison", "slow", ... — pro Effekt
## einfach einen weiteren Partikel-Node mit anderer effect_id anlegen.

@export var effect_id: String = "stun"
## Node mit dem StatusEffectManager. Leer = direkter Elternknoten.
@export var source_path: NodePath


func _ready() -> void:
	emitting = false

	var source: Node = get_parent()
	if not source_path.is_empty():
		source = get_node_or_null(source_path)
	if source == null:
		push_warning("[StatusVFX] Keine Quelle gefunden (%s)." % get_path())
		return

	# WICHTIG: Kinder werden in Godot VOR dem Elternknoten ready — der
	# StatusEffectManager wird aber erst in dessen _ready() erzeugt.
	# Ohne dieses await waere status_effects hier garantiert null.
	if not source.is_node_ready():
		await source.ready
	if not is_instance_valid(source):
		return

	var manager: StatusEffectManager = source.get("status_effects") as StatusEffectManager
	if manager == null:
		push_warning("[StatusVFX] '%s' hat keinen StatusEffectManager." % source.name)
		return

	manager.effect_applied.connect(_on_effect_applied)
	manager.effect_expired.connect(_on_effect_expired)


func _on_effect_applied(id: String, _duration: float, _magnitude: float, _source: Node) -> void:
	if id == effect_id:
		emitting = true


func _on_effect_expired(id: String) -> void:
	if id == effect_id:
		emitting = false
