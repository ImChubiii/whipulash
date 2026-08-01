
extends Node

# ============================================================================
# EnemyDensity — Autoload: vervielfacht die Gegner-Spawnpunkte JEDES Raums.
# Muss unter Project Settings -> Autoload als "EnemyDensity" stehen.
# ============================================================================
#
# ############################################################################
# WARUM "MEHR GEGNER" NICHT UEBER DAS THREAT-BUDGET ALLEIN GEHT
# ############################################################################
# Es gab ZWEI Deckel gleichzeitig, und nur einer davon war das Budget:
#
#   1. BUDGET — level_generation_test.tscn ueberschreibt
#      combat_threat_budget = 16 und threat_hard_cap = 28. Die 64 im
#      Script von level_generator.gd sind dadurch komplett wirkungslos;
#      wer nur den Script-Default hochdreht, aendert gar nichts.
#
#   2. SPAWNPUNKTE — room_instance._roll_enemy_mix() kappt hart:
#
#          while budget > 0 and result.size() < enemy_spawn_points.size()
#
#      Die Anzahl der Marker3D unter "EnemySpawnPoints" in der Raum-Szene
#      IST damit die echte Obergrenze. Ein Raum mit 12 Markern spawnt nie
#      mehr als 12 Gegner — egal wie gross das Budget ist. Genau das war im
#      Log zu sehen: "Gegner entfernt - noch 11 aktiv" abwaerts, bei einem
#      Budget, das rechnerisch ein Vielfaches hergegeben haette.
#
# Deckel 1 wird in der Szene angehoben. Deckel 2 loest dieses Autoload.
#
# ############################################################################
# WARUM ALS AUTOLOAD STATT ALS AENDERUNG AN room_instance.gd
# ############################################################################
# Die Alternative waere, in 12 Raum-Szenen jeweils zwei Dutzend Marker von
# Hand zu setzen — und danach bei jedem neuen Raum wieder. Oder
# room_instance.gd (1800 Zeilen) umzubauen.
#
# Stattdessen wird hier von aussen die Liste ergaenzt, auf der die
# vorhandene Logik ohnehin schon arbeitet: fuer jeden bestehenden Marker
# entstehen extra_points_per_marker weitere, ringfoermig darum herum. Der
# Spawn-Code merkt keinen Unterschied — er sieht nur eine laengere Liste.
# Dasselbe Muster wie Loot, Treasure und RoomGuard.
#
# ############################################################################
# TIMING — WARUM DAS RECHTZEITIG PASSIERT
# ############################################################################
# LevelGenerator ruft prepare_enemies() direkt nach dem Instanziieren auf.
# Dort wird die Liste aber nur auf "ist sie leer?" geprueft; die eigentliche
# Auswahl (_roll_enemy_mix) und das Spawnen laufen erst, wenn der Spieler
# den Raum BETRITT. Unsere Marker muessen also lediglich vor dem Betreten
# des Raums stehen — ein deferred Aufruf plus eine Physik-Frame reicht mit
# grossem Abstand.
#
# ############################################################################
# DETERMINISMUS
# ############################################################################
# Kein RandomNumberGenerator: die Zusatzpunkte werden rein geometrisch aus
# Index und Winkel berechnet. Zwei Runs mit demselben Seed bekommen damit
# exakt dieselben Marker in exakt derselben Reihenfolge — sonst waeren die
# verifizierbaren Speedrun-Seeds (siehe det_rng.gd / run_record.gd) beim
# ersten Gegner hinfaellig.

## Wie viele ZUSAETZLICHE Punkte pro vorhandenem Marker entstehen.
## 2 = dreifache Gesamtzahl (Original + 2). Das ist die angeforderte
## "mindestens 3x mehr Gegner"-Vorgabe.
@export var extra_points_per_marker: int = 2

## Radius des ersten Rings um den Original-Marker. Jeder weitere Ring liegt
## um ring_step weiter aussen.
##
## 4.5 ist bewusst groesser als min_spawn_spacing des Stingers (3.0) und
## kleiner als das des Fighters (6.0): Stinger duerfen sich dicht draengen,
## Fighter verteilen sich ueber _take_spawn_point() dann automatisch auf
## weiter auseinanderliegende Punkte.
@export var ring_radius: float = 4.5
@export var ring_step: float = 3.0

## Wie weit ein Zusatzpunkt maximal vom Raumrand entfernt bleiben muss.
## Verhindert Marker in oder hinter der Wand.
@export var wall_margin: float = 3.0

## Aus dieser Hoehe UEBER dem Marker wird nach Boden gesucht.
##
## Nicht von der Raumdecke aus: dann trifft der Strahl zuerst die Decke.
## Das ist derselbe Fehler, der beim Sockel-Raycast in treasure_manager.gd
## schon einmal aufgetreten ist.
@export var ground_probe_up: float = 3.0
@export var ground_probe_down: float = 40.0

## Zusatzpunkte, die in einer Limonaden-Lache landen wuerden, werden
## verworfen. Ein Gegner, der beim Spawn sofort Schaden nimmt und
## wegrutscht, sieht nach Fehler aus, nicht nach Absicht.
@export var avoid_hazards: bool = true
@export var hazard_margin: float = 1.5

@export var debug_logging: bool = false

var _processed: Dictionary = {}


func _debug(msg: String) -> void:
	if debug_logging:
		print("[EnemyDensity] %s" % msg)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_debug("Autoload aktiv.")
	get_tree().node_added.connect(_on_node_added)
	_scan_existing.call_deferred()


func _scan_existing() -> void:
	var root: Node = get_tree().root
	if root == null:
		return
	_scan_recursive(root)


func _scan_recursive(node: Node) -> void:
	_on_node_added(node)
	for child: Node in node.get_children():
		_scan_recursive(child)


func _on_node_added(node: Node) -> void:
	if not (node is RoomInstance):
		return
	if _processed.has(node.get_instance_id()):
		return
	_densify_deferred.call_deferred(node as RoomInstance)


## Eine Physik-Frame warten: room_footprint, die Welt-Transform und die
## bereits am Boden ausgerichteten Original-Marker stehen erst danach.
func _densify_deferred(room: RoomInstance) -> void:
	if not is_instance_valid(room):
		return
	await get_tree().physics_frame
	if not is_instance_valid(room) or not room.is_inside_tree():
		return
	_densify(room)


func _densify(room: RoomInstance) -> void:
	var id: int = room.get_instance_id()
	if _processed.has(id):
		return
	_processed[id] = true
	room.tree_exited.connect(func() -> void: _processed.erase(id))

	if extra_points_per_marker <= 0:
		return

	var originals: Array[Marker3D] = room.enemy_spawn_points.duplicate()
	if originals.is_empty():
		_debug("Raum %s hat keine Spawnpunkte - uebersprungen." % room.grid_position)
		return

	var parent: Node = room.get_node_or_null("EnemySpawnPoints")
	if parent == null:
		parent = room

	var added: int = 0

	for marker_index: int in range(originals.size()):
		var source: Marker3D = originals[marker_index]
		if not is_instance_valid(source):
			continue

		for extra_index: int in range(extra_points_per_marker):
			var candidate: Vector3 = _ring_position(source.global_position, marker_index, extra_index)

			if not _is_inside_room(room, candidate):
				continue

			var grounded: Vector3 = _snap_to_ground(room, candidate)
			if grounded == Vector3.INF:
				continue

			if avoid_hazards and _is_in_hazard(grounded):
				continue

			var extra := Marker3D.new()
			extra.name = "EnemySpawnExtra_%d_%d" % [marker_index, extra_index]
			parent.add_child(extra)
			extra.global_position = grounded
			extra.global_rotation = Vector3(0.0, source.global_rotation.y, 0.0)

			room.enemy_spawn_points.append(extra)
			added += 1

	_debug("Raum %s: %d Original-Punkte + %d Zusatzpunkte = %d." % [
		room.grid_position, originals.size(), added, room.enemy_spawn_points.size()
	])


## Rein geometrisch, ohne Zufall — siehe Determinismus-Block im Dateikopf.
## Der Versatz aus marker_index sorgt dafuer, dass benachbarte Original-
## Marker ihre Ringe nicht deckungsgleich uebereinanderlegen.
func _ring_position(origin: Vector3, marker_index: int, extra_index: int) -> Vector3:
	var ring: int = extra_index / 3
	var slot: int = extra_index % 3
	var radius: float = ring_radius + float(ring) * ring_step
	var angle: float = TAU * (float(slot) / 3.0) + float(marker_index) * 0.7
	return origin + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)


## Liegt der Punkt noch mit Sicherheitsabstand innerhalb des Grundrisses?
## Gerechnet wird im LOKALEN Raumkoordinatensystem, weil room_footprint
## genau so definiert ist — global waere die Rechnung bei gedrehten oder
## skalierten Raeumen falsch.
func _is_inside_room(room: RoomInstance, world_pos: Vector3) -> bool:
	var local: Vector3 = room.to_local(world_pos)
	var half_x: float = room.room_footprint.x * 0.5 - wall_margin
	var half_z: float = room.room_footprint.y * 0.5 - wall_margin
	if half_x <= 0.0 or half_z <= 0.0:
		return false
	return absf(local.x) <= half_x and absf(local.z) <= half_z


## Setzt den Punkt auf den tatsaechlichen Boden. Ohne das haengen Marker in
## Raeumen mit Rampe oder abgesenktem Bodenstueck in der Luft, und die
## Gegner fallen beim Spawn durch die Geometrie — derselbe Fehler, den
## room_instance._snap_markers_to_ground() fuer die Original-Marker loest.
##
## Rueckgabe Vector3.INF = kein Boden gefunden, Punkt verwerfen.
func _snap_to_ground(room: RoomInstance, world_pos: Vector3) -> Vector3:
	var world: World3D = room.get_world_3d()
	if world == null:
		return world_pos

	var from: Vector3 = world_pos + Vector3(0.0, ground_probe_up, 0.0)
	var to: Vector3 = world_pos + Vector3(0.0, -ground_probe_down, 0.0)

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 1

	var hit: Dictionary = world.direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return Vector3.INF

	var point: Vector3 = hit["position"]
	point.y += 0.1
	return point


## Ueber die Gruppe "lava_hazards", in die sich jede LavaHazard-Instanz in
## ihrem _ready() eintraegt. Geprueft wird die XZ-Ausdehnung im lokalen
## System der Lache, damit gedrehte Pfuetzen korrekt behandelt werden.
func _is_in_hazard(world_pos: Vector3) -> bool:
	for node: Node in get_tree().get_nodes_in_group("lava_hazards"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var hazard: Node3D = node as Node3D
		var size: Variant = hazard.get("size")
		if not (size is Vector3):
			continue

		var local: Vector3 = hazard.to_local(world_pos)
		var half_x: float = (size as Vector3).x * 0.5 + hazard_margin
		var half_z: float = (size as Vector3).z * 0.5 + hazard_margin
		if absf(local.x) <= half_x and absf(local.z) <= half_z:
			return true
	return false
