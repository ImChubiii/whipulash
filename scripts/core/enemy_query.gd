extends RefCounted
class_name EnemyQuery

# ============================================================================
# EnemyQuery — gemeinsame "welche Gegner sind in der Naehe"-Abfragen.
# ============================================================================
# Verallgemeinert zwei Muster, die im Projekt schon einzeln existieren, aber
# nirgends geteilt werden: die naechste-Ziel-Suche aus homing_bolt.gd
# (dort ohne Reichweiten-Deckel, weil sie ausschliesslich beim Retargeting
# eines bereits fliegenden Bolts laeuft) und die Radius-Sammlung, wie sie
# combat_base.gd::_collect_dash_targets() fuer den Dash-Schaden macht. Winters
# Primary (naechstes Ziel in Reichweite fuer den Homing-Bolt) und Karinas
# Acid-Rush/Phantom-Execute (alle Gegner im Umkreis) brauchen beide Varianten.


## Naechster lebender Gegner zu "from_pos", hoechstens "max_range" entfernt
## (INF = ungedeckelt). null, wenn keiner in Reichweite lebt.
static func nearest_enemy(from_pos: Vector3, max_range: float = INF) -> Node3D:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	var best: Node3D = null
	var best_dist: float = max_range

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var health: Node = node.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		var dist: float = from_pos.distance_to((node as Node3D).global_position)
		if dist <= best_dist:
			best_dist = dist
			best = node as Node3D

	return best


## Alle lebenden Gegner innerhalb "radius" um "from_pos" (Kugel-Radius, nicht
## nur horizontal - anders als der flache Dash-Check in combat_base.gd, da
## Karinas Aura/Beruehrungs-Check keine Bewegungsachse hat, an der er sich
## orientieren koennte).
static func enemies_within(from_pos: Vector3, radius: float) -> Array[Node3D]:
	var result: Array[Node3D] = []

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return result

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		if enemy.global_position.distance_to(from_pos) > radius:
			continue

		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		result.append(enemy)

	return result
