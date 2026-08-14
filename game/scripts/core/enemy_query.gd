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


## Wie enemies_within(), aber mit GETRENNTER horizontaler/vertikaler
## Reichweite statt eines reinen Kugel-Radius - fuer bodennahe Aura-/
## Beruehrungs-Faehigkeiten, die auch treffen sollen, waehrend der Spieler in
## der Luft ist (z.B. nach einem Sprung).
##
## WARUM enemies_within() DAFUER NICHT REICHT: es misst die volle 3D-Distanz
## von from_pos (Spieler-URSPRUNG, mittig in der Kapsel). Ein Gegner-Ursprung
## liegt aber bei den FUESSEN (rund 0.9 Einheiten unter einem gleich hoch
## stehenden Spieler, siehe combat_base.gd::dash_hit_height_up-Kommentar fuer
## dieselbe Herleitung). Springt der Spieler (player_base.gd: jump_velocity=
## 13.0, gravity=40.0 -> ~2.1 Einheiten Sprunghoehe), addiert sich das zum
## Fuesse-Versatz auf ~3.0 Einheiten - bei einem Radius von z.B. 3.0
## (Karinas acid_aura_radius) fallen dadurch WAEHREND DES SPRUNGS bereits
## horizontal direkt neben dem Spieler stehende Gegner aus der reinen
## Kugel-Distanz heraus, obwohl der Angriff im Flachen problemlos treffen
## wuerde. Getrennte horizontale/vertikale Fenster (wie beim Dash-Schaden)
## umgehen das.
static func enemies_within_flat(
		from_pos: Vector3, horizontal_radius: float,
		height_up: float = 3.0, height_down: float = 5.0
) -> Array[Node3D]:
	var result: Array[Node3D] = []

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return result

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		var to_enemy: Vector3 = enemy.global_position - from_pos

		if to_enemy.y > height_up or to_enemy.y < -height_down:
			continue
		var flat_dist: float = Vector2(to_enemy.x, to_enemy.z).length()
		if flat_dist > horizontal_radius:
			continue

		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		result.append(enemy)

	return result


## Aim-Assist: liegt ein lebender Gegner innerhalb "max_angle_deg" um die
## reine Blickrichtung UND in Reichweite, wird "dir" sanft (per Slerp,
## Staerke "strength") auf ihn gebogen statt hart eingerastet - verzeiht
## knapp daneben gezielte Schuesse, ohne komplett automatisch zu treffen.
## Ohne Kandidat wird "dir" unveraendert zurueckgegeben.
static func aim_assisted_direction(
		origin: Vector3, dir: Vector3, max_range: float,
		max_angle_deg: float = 6.0, strength: float = 0.5
) -> Vector3:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or dir.length_squared() < 0.0001:
		return dir

	var flat_dir: Vector3 = dir.normalized()
	var best: Node3D = null
	var best_angle: float = deg_to_rad(max_angle_deg)

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		var to_enemy: Vector3 = (enemy.global_position + Vector3.UP) - origin
		if to_enemy.length_squared() < 0.0001 or to_enemy.length() > max_range:
			continue
		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		var angle: float = flat_dir.angle_to(to_enemy.normalized())
		if angle < best_angle:
			best_angle = angle
			best = enemy

	if best == null:
		return dir

	var to_best: Vector3 = ((best.global_position + Vector3.UP) - origin).normalized()
	return flat_dir.slerp(to_best, strength).normalized()


## Bester Gegner in einem Blickkegel: kleinste Winkelabweichung zur reinen
## Blickrichtung gewinnt, nicht die Distanz - "wer am meisten mittig im
## Fadenkreuz steht" statt "wer am naechsten dran ist". Gleiche Kandidaten-
## Suche wie aim_assisted_direction(), gibt aber das Ziel selbst zurueck statt
## nur eine korrigierte Richtung - fuer echtes Auto-Target (Giselles Uzi-
## Rework: "nur grob hinschauen, die Waffe erledigt den Rest").
static func best_target_in_cone(
		origin: Vector3, dir: Vector3, max_range: float, max_angle_deg: float = 35.0
) -> Node3D:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or dir.length_squared() < 0.0001:
		return null

	var flat_dir: Vector3 = dir.normalized()
	var best: Node3D = null
	var best_angle: float = deg_to_rad(max_angle_deg)

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		var to_enemy: Vector3 = (enemy.global_position + Vector3.UP) - origin
		if to_enemy.length_squared() < 0.0001 or to_enemy.length() > max_range:
			continue
		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		var angle: float = flat_dir.angle_to(to_enemy.normalized())
		if angle < best_angle:
			best_angle = angle
			best = enemy

	return best
