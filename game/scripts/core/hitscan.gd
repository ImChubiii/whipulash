extends RefCounted
class_name Hitscan

# ============================================================================
# Hitscan — gemeinsamer Raycast-Treffer fuer alle Feuerwaffen-Angriffe.
# ============================================================================
# Giselles Uzi/Sniper und Winters Laser-Tick teilen sich exakt dasselbe
# "Strahl von A nach B, erstes Health-tragende Ziel bekommt Schaden"-Muster -
# statt das dreimal zu kopieren, lebt es hier einmal. Health wird ueber
# find_child("Health", true, false) gesucht, exakt dieselbe Konvention wie
# primary_hitbox.gd::_on_body_entered() und custom_enemy_base.gd, damit
# Hitscan-Treffer und Melee-Treffer sich fuer jedes Ziel gleich verhalten.

## Layer 1 "World" (project.godot [layer_names]) + Layer 3 "Enemies" (Bitmask-
## wert 4, siehe custom_enemy_base.gd-Kopfkommentar) - Schuesse blocken an
## Waenden UND treffen Gegner, exakt wie Hitbox.collision_mask es fuer Nahkampf
## bereits tut.
const _RAYCAST_MASK: int = 1 | 4


## Feuert einen einzelnen Raycast von "from" in Richtung "dir" (normalisiert
## erwartet) bis "range" Meter weit. Bei Treffer eines Bodies mit einem
## "Health"-Kind-Node: Schaden anwenden + optional eine Schadenszahl
## spawnen. Rueckgabe: {"hit": bool, "position": Vector3, "target": Node}.
static func fire(
		context: Node, from: Vector3, dir: Vector3, range: float,
		damage: float, source: Node = null, damage_number_scene: PackedScene = null
) -> Dictionary:
	var result: Dictionary = {"hit": false, "position": from + dir * range, "target": null}
	if context == null or not is_instance_valid(context):
		return result

	# context.get_world_3d() wuerde hier abstuerzen: das ist eine Node3D-
	# Methode, aber "context" ist bei Giselle/Winter das Combat-Node selbst
	# (extends Node, siehe combat_base.gd) - kein Node3D. get_viewport() ist
	# dagegen auf JEDEM Node verfuegbar, egal ob 2D/3D.
	var viewport: Viewport = context.get_viewport()
	if viewport == null:
		return result
	var world: World3D = viewport.world_3d
	if world == null:
		return result

	var query := PhysicsRayQueryParameters3D.create(from, from + dir * range)
	query.collision_mask = _RAYCAST_MASK
	if source is CollisionObject3D:
		query.exclude = [(source as CollisionObject3D).get_rid()]

	var hit: Dictionary = world.direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return result

	result["position"] = hit["position"]

	var body: Node = hit["collider"]
	if body == source:
		return result

	var health := body.find_child("Health", true, false)
	if health == null or not (health is Health) or not (health as Health).is_alive():
		return result

	result["hit"] = true
	result["target"] = body
	var is_prop: bool = body is BreakableProp

	(health as Health).take_damage(damage, source as Node3D)

	if damage_number_scene != null and body is Node3D and not is_prop:
		var number: Node = damage_number_scene.instantiate()
		context.get_tree().current_scene.add_child(number)
		(number as Node3D).global_position = (body as Node3D).global_position + Vector3(0.0, 1.8, 0.0)
		if number.has_method("show_damage"):
			number.show_damage(damage)

	return result
