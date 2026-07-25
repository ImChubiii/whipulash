extends Node3D
class_name RoomInstance

const EXIT_NORTH := 1
const EXIT_SOUTH := 2
const EXIT_EAST := 4
const EXIT_WEST := 8

const _FLAG_BY_KEY := {
	"north": EXIT_NORTH,
	"south": EXIT_SOUTH,
	"east": EXIT_EAST,
	"west": EXIT_WEST,
}

## Richtungsvektor in Raum-lokalen Koordinaten (-Z = Norden).
const _DIR_VECTOR := {
	"north": Vector3(0.0, 0.0, -1.0),
	"south": Vector3(0.0, 0.0, 1.0),
	"east": Vector3(1.0, 0.0, 0.0),
	"west": Vector3(-1.0, 0.0, 0.0),
}

const NAV_SOURCE_GROUP := "navmesh_source"

@export var room_footprint: Vector2 = Vector2(48.0, 48.0)
@export var room_height: float = 14.0

@export var entry_trigger_inset: float = 3.0

## --- Dunkle, aber TEXTURIERTE Decke -----------------------------------
## Erzeugt zur Laufzeit eine Deckenplatte. Verwendet dasselbe geteilte
## PSX-Material wie Waende/Boden (Vertex-Snapping-Shader + Textur), nur
## dunkel eingefaerbt - vorher war das eine reine Flatcolor-Flaeche ohne
## jede Textur, was im Vergleich zum Rest des Raumes "kaputt" aussah.
##
## CULL-BUG BEIM MATERIALWECHSEL: Der PSX-Shader hat "cull_back" FEST im
## Shadercode stehen (render_mode unshaded, cull_back, ...) - das laesst
## sich bei einem ShaderMaterial anders als bei StandardMaterial3D NICHT
## per Skript umschalten. Ein normaler BoxMesh mit nach oben zeigender
## Deckenflaeche waere von UNTEN betrachtet dadurch unsichtbar (man sieht
## die Rueckseite des Polygons, die weggecullt wird). Deshalb: PlaneMesh
## statt BoxMesh, um 180 Grad gekippt - dadurch zeigt exakt dieselbe
## Dreiecks-Vorderseite nach UNTEN in den Raum, ganz ohne den gemeinsamen
## Shader anzufassen. Die Kollision bleibt unabhaengig davon ein simpler
## Box-Collider (Kollision braucht keine Ausrichtung).
@export var build_ceiling: bool = true
@export var ceiling_color: Color = Color(0.035, 0.04, 0.035)
## Pfad zum geteilten PSX-Material. Fallback auf eine schlichte, dunkle
## StandardMaterial3D, falls die Resource fehlt/verschoben wurde.
@export var ceiling_material_path: String = "res://materials/psx_material.tres"
## Kollision fuer die Decke - verhindert, dass man mit hohen Spruengen
## oder Knockback aus dem Raum fliegt.
@export var ceiling_collision: bool = true
@export var ceiling_thickness: float = 1.0

## --- Wand-Kappe fuer die Minimap-Sichtbarkeit --------------------------
## Grund-Textur der Waende bleibt UNVERAENDERT identisch zum Boden (das
## bisherige Einfaerben der ganzen Wand wurde wieder entfernt - sah in
## der normalen Spielansicht falsch aus, weil Wand und Boden dort ja
## bewusst gleich aussehen sollen).
## PROBLEM bleibt aber bestehen: aus der reinen Top-Down-Perspektive der
## Minimap zeigt eine Wand nur ihre duenne Oberkante, texturell identisch
## zum Boden - man sieht sie praktisch nicht.
## FIX: jede Wand bekommt oben ein ZUSAETZLICHES, rein optisches Kappen-
## Mesh in dunkler Farbe (gleiche Groesse wie die Wand-Grundflaeche,
## aber nur wall_cap_height hoch), das ganz knapp ueber der eigentlichen
## Wand-Oberkante sitzt. Von der Seite/im normalen Spiel faellt dieser
## duenne dunkle Streifen kaum auf (er sitzt direkt an der duesteren
## Decke), aber die Top-Down-Kamera der Minimap trifft ihn zuerst und
## zeigt dadurch den Wandverlauf klar erkennbar dunkel gegen den
## helleren Boden.
@export var wall_cap_enabled: bool = true
@export var wall_cap_height: float = 1.0
@export var wall_cap_color: Color = Color(0.035, 0.04, 0.035)
## Minimaler Hochversatz ueber die tatsaechliche Wand-Oberkante, damit
## die Kappe im Tiefenvergleich zuverlaessig vor der (gleich hohen,
## gleich texturierten) eigentlichen Wandflaeche gewinnt - ohne das
## wuerde es zu Z-Fighting/Flackern zwischen beiden Flaechen kommen.
@export var wall_cap_epsilon: float = 0.03
@export var wall_cap_material_path: String = "res://materials/psx_material.tres"

var grid_position: Vector2i = Vector2i.ZERO

var enemy_spawn_points: Array[Marker3D] = []
var loot_spawn_points: Array[Marker3D] = []
var exit_points: Dictionary = {}

signal room_cleared(room: RoomInstance)
signal room_entered(room: RoomInstance)

var _is_cleared: bool = false
var _active_enemies: int = 0
var _requires_clear: bool = false

var _entry_trigger: Area3D = null
var _has_entered: bool = false
var _enemies_spawned: bool = false

var _pending_entries: Array[EnemySpawnEntry] = []
var _pending_budget: int = 0
var _pending_stage: int = 1
var _spawned_enemies: Array[Node3D] = []

## Alle Tueren nach Richtung, AUCH die vom Layout wieder entfernten -
## exit_points wird von apply_exit_flags ausgeduennt, die Tuer-Referenz
## brauchen wir aber weiterhin zum Einfaerben.
var _doors_by_dir: Dictionary = {}


func _ready() -> void:
	add_to_group(NAV_SOURCE_GROUP)
	_collect_markers()
	_setup_entry_trigger()
	if build_ceiling:
		_build_ceiling()
	if wall_cap_enabled:
		_build_wall_caps()


func _exit_tree() -> void:
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_spawned_enemies.clear()


func _collect_markers() -> void:
	var spawn_group := get_node_or_null("EnemySpawnPoints")
	if spawn_group:
		for child in spawn_group.get_children():
			if child is Marker3D:
				enemy_spawn_points.append(child)

	var loot_group := get_node_or_null("LootSpawnPoints")
	if loot_group:
		for child in loot_group.get_children():
			if child is Marker3D:
				loot_spawn_points.append(child)

	var exit_group := get_node_or_null("ExitPoints")
	if exit_group:
		for child in exit_group.get_children():
			if child is Marker3D:
				var key: String = child.name.to_lower()
				if not _FLAG_BY_KEY.has(key):
					continue
				exit_points[key] = child
				var door := get_node_or_null("Doors/Door%s" % child.name.capitalize())
				if door:
					child.set_meta("door_node", door)
					_doors_by_dir[key] = door
				else:
					push_warning("RoomInstance (%s): ExitPoint '%s' hat keine Tuer unter 'Doors/Door%s'." % [name, child.name, child.name.capitalize()])


## Baut eine texturierte, dunkel eingefaerbte Decke. Kollision (Box) und
## Optik (gekipptes PlaneMesh mit PSX-Material) sind zwei unabhaengige
## Kinder desselben StaticBody3D.
func _build_ceiling() -> void:
	if get_node_or_null("Ceiling") != null:
		return

	var body := StaticBody3D.new()
	body.name = "Ceiling"
	body.position = Vector3(0.0, room_height + ceiling_thickness * 0.5, 0.0)
	add_child(body)

	var mat: Material = _make_ceiling_material()

	var plane := PlaneMesh.new()
	plane.size = Vector2(room_footprint.x, room_footprint.y)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = plane
	# PlaneMesh zeigt standardmaessig mit der Vorderseite nach OBEN (+Y).
	# Lokal auf die Unterkante der Kollisionsbox setzen und um 180 Grad
	# kippen, damit dieselbe Dreiecksseite stattdessen nach UNTEN in den
	# Raum zeigt - siehe Klassenkommentar zum cull_back-Problem oben.
	mesh_instance.position = Vector3(0.0, -ceiling_thickness * 0.5, 0.0)
	mesh_instance.rotation_degrees = Vector3(180.0, 0.0, 0.0)
	# material_override statt surface_material_override - Vorrangregel.
	mesh_instance.material_override = mat
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mesh_instance)

	if ceiling_collision:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(room_footprint.x, ceiling_thickness, room_footprint.y)
		shape.shape = box
		body.add_child(shape)
	else:
		body.collision_layer = 0


## Dupliziert das geteilte PSX-Shader-Material (NIEMALS die Original-
## Resource direkt benutzen - sonst faerbt das erste instanziierte
## Zimmer ALLE anderen Decken im Spiel mit ein) und faerbt es dunkel via
## Shader-Parameter. Faellt auf eine schlichte StandardMaterial3D zurueck,
## falls die Resource fehlt.
func _make_ceiling_material() -> Material:
	var base := load(ceiling_material_path)
	if base is ShaderMaterial:
		var mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
		mat.set_shader_parameter("albedo_color", ceiling_color)
		return mat

	push_warning("RoomInstance: ceiling_material_path '%s' nicht gefunden oder kein ShaderMaterial - Decke faellt auf Flatcolor zurueck." % ceiling_material_path)
	var fallback := StandardMaterial3D.new()
	fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fallback.albedo_color = ceiling_color
	fallback.cull_mode = BaseMaterial3D.CULL_FRONT
	return fallback


## Setzt jeder Wand ("Wall*"-StaticBody3D, direktes Kind) eine duenne,
## dunkle Kappe knapp ueber ihre eigene Oberkante - siehe Klassenkommentar
## oben. Groesse/Position werden aus der WAND EIGENEN CollisionShape3D
## abgelesen (nicht aus room_height), damit das auch bei Waenden
## funktioniert, deren Hoehe (noch) nicht exakt der Raumhoehe entspricht.
func _build_wall_caps() -> void:
	var base := load(wall_cap_material_path)

	for child in get_children():
		if not (child is StaticBody3D):
			continue
		if not child.name.begins_with("Wall"):
			continue
		if child.get_node_or_null("MinimapCap") != null:
			continue

		var collision := child.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision == null or not (collision.shape is BoxShape3D):
			continue
		var box: BoxShape3D = collision.shape as BoxShape3D

		var cap_mesh := BoxMesh.new()
		cap_mesh.size = Vector3(box.size.x, wall_cap_height, box.size.z)

		var mat: Material
		if base is ShaderMaterial:
			var shader_mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
			shader_mat.set_shader_parameter("albedo_color", wall_cap_color)
			mat = shader_mat
		else:
			push_warning("RoomInstance: wall_cap_material_path '%s' nicht gefunden oder kein ShaderMaterial - Kappe faellt auf Flatcolor zurueck." % wall_cap_material_path)
			var fallback := StandardMaterial3D.new()
			fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			fallback.albedo_color = wall_cap_color
			mat = fallback

		var cap := MeshInstance3D.new()
		cap.name = "MinimapCap"
		cap.mesh = cap_mesh
		# material_override statt surface_material_override - Vorrangregel.
		cap.material_override = mat
		cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		# Lokal (relativ zur Wand-StaticBody3D, deren Ursprung mittig in
		# der Wand liegt): knapp ueber der eigenen Oberkante der Wand.
		var wall_top_local_y: float = box.size.y * 0.5
		cap.position = Vector3(0.0, wall_top_local_y - wall_cap_height * 0.5 + wall_cap_epsilon, 0.0)

		child.add_child(cap)


## Baut im Inneren eines Korridors eine Rampe, die rise Meter ueberwindet.
## low_dir zeigt zur tiefer liegenden Eingangsseite; die Tuer und der
## ExitPoint auf der Gegenseite werden um rise angehoben.
##
## Wird vom LevelGenerator aufgerufen, BEVOR der Raum betreten wird.
func configure_slope(low_dir: String, rise: float) -> void:
	if not _DIR_VECTOR.has(low_dir) or is_zero_approx(rise):
		return

	var high_dir: String = _opposite(low_dir)
	var axis: Vector3 = _DIR_VECTOR[high_dir]

	# Laenge der Rampe entlang der Steigungsachse.
	var length: float = room_footprint.y if absf(axis.z) > 0.5 else room_footprint.x
	var width: float = room_footprint.x if absf(axis.z) > 0.5 else room_footprint.y

	var ramp := StaticBody3D.new()
	ramp.name = "SlopeRamp"
	add_child(ramp)
	ramp.add_to_group(NAV_SOURCE_GROUP)

	var hypotenuse: float = sqrt(length * length + rise * rise)
	var angle: float = atan2(rise, length)

	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(width, 1.0, hypotenuse)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = box_mesh
	ramp.add_child(mesh_instance)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = box_mesh.size
	shape.shape = box
	ramp.add_child(shape)

	# Rampe mittig platzieren, Oberkante bei 0 am tiefen und bei rise am
	# hohen Ende. -0.5 auf Y, weil die Box 1.0 dick ist.
	ramp.position = Vector3(0.0, rise * 0.5 - 0.5, 0.0)

	if absf(axis.z) > 0.5:
		ramp.rotation = Vector3(-angle * signf(axis.z), 0.0, 0.0)
	else:
		ramp.rotation = Vector3(0.0, PI * 0.5, angle * signf(axis.x))

	# Tuer + ExitPoint auf der hohen Seite mit anheben, sonst steht die
	# Tuer im Boden bzw. der naechste Raum haengt in der Luft.
	if exit_points.has(high_dir):
		var marker: Marker3D = exit_points[high_dir]
		marker.position.y += rise
	if _doors_by_dir.has(high_dir):
		var door: Node3D = _doors_by_dir[high_dir]
		if is_instance_valid(door):
			door.position.y += rise


func _opposite(dir: String) -> String:
	match dir:
		"north": return "south"
		"south": return "north"
		"east": return "west"
		"west": return "east"
	return ""


# --- Tuer-API fuer den LevelGenerator --------------------------------

func set_door_kind(dir: String, kind: int) -> void:
	if not _doors_by_dir.has(dir):
		return
	var door: Node = _doors_by_dir[dir]
	if is_instance_valid(door) and door is Door:
		(door as Door).door_kind = kind


func set_door_hack_enabled(dir: String, enabled: bool) -> void:
	if not _doors_by_dir.has(dir):
		return
	var door: Node = _doors_by_dir[dir]
	if is_instance_valid(door) and door.has_method("set_hack_enabled"):
		door.set_hack_enabled(enabled)


func _setup_entry_trigger() -> void:
	_entry_trigger = Area3D.new()
	_entry_trigger.name = "EntryTrigger"
	_entry_trigger.collision_layer = 0
	_entry_trigger.collision_mask = 0b101
	_entry_trigger.monitoring = true
	_entry_trigger.monitorable = false
	add_child(_entry_trigger)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(
		max(room_footprint.x - entry_trigger_inset, 1.0),
		room_height,
		max(room_footprint.y - entry_trigger_inset, 1.0)
	)
	shape.shape = box
	shape.position = Vector3(0.0, room_height * 0.5, 0.0)
	_entry_trigger.add_child(shape)

	_entry_trigger.body_entered.connect(_on_entry_trigger_body_entered)


func _on_entry_trigger_body_entered(body: Node) -> void:
	if _has_entered:
		return
	if not body.is_in_group(PartyManager.PLAYER_GROUP):
		return
	_has_entered = true
	on_player_entered()


func prepare_enemies(entries: Array[EnemySpawnEntry], threat_budget: int, stage: int) -> void:
	_pending_stage = stage
	var usable: Array[EnemySpawnEntry] = []
	for e in entries:
		if e != null and e.is_allowed(stage, room_height):
			usable.append(e)

	if usable.is_empty() or enemy_spawn_points.is_empty() or threat_budget <= 0:
		_is_cleared = true
		_lock_exits(false)
		return

	_requires_clear = true
	_pending_entries = usable
	_pending_budget = threat_budget
	_lock_exits(false)


func _roll_enemy_mix() -> Array[EnemySpawnEntry]:
	var result: Array[EnemySpawnEntry] = []
	var budget: int = _pending_budget
	var used_count: Dictionary = {}
	var guard: int = 0

	for e in _pending_entries:
		for i in range(e.guaranteed_count):
			if result.size() >= enemy_spawn_points.size():
				break
			result.append(e)
			used_count[e] = used_count.get(e, 0) + 1
			budget -= e.threat_cost

	while budget > 0 and result.size() < enemy_spawn_points.size() and guard < 64:
		guard += 1

		var affordable: Array[EnemySpawnEntry] = []
		for e in _pending_entries:
			if e.threat_cost > budget:
				continue
			if used_count.get(e, 0) >= e.max_per_room:
				continue
			affordable.append(e)

		if affordable.is_empty():
			break

		var chosen: EnemySpawnEntry = _weighted_pick_entry(affordable)
		result.append(chosen)
		used_count[chosen] = used_count.get(chosen, 0) + 1
		budget -= chosen.threat_cost

	if result.is_empty() and not _pending_entries.is_empty():
		result.append(_pending_entries[0])

	return result


func _weighted_pick_entry(candidates: Array[EnemySpawnEntry]) -> EnemySpawnEntry:
	var total: float = 0.0
	for c in candidates:
		total += maxf(c.weight, 0.0)
	if total <= 0.0:
		return candidates.pick_random()
	var roll: float = randf() * total
	var acc: float = 0.0
	for c in candidates:
		acc += maxf(c.weight, 0.0)
		if roll <= acc:
			return c
	return candidates.back()


func _spawn_prepared_enemies() -> void:
	if _pending_entries.is_empty() or enemy_spawn_points.is_empty():
		_is_cleared = true
		_lock_exits(false)
		return

	var mix: Array[EnemySpawnEntry] = _roll_enemy_mix()
	mix.sort_custom(func(a, b): return a.threat_cost > b.threat_cost)

	var free_points: Array[Marker3D] = enemy_spawn_points.duplicate()
	free_points.shuffle()
	var taken_positions: Array[Vector3] = []

	for entry in mix:
		var point: Marker3D = _take_spawn_point(free_points, taken_positions, entry.min_spawn_spacing)
		if point == null:
			break
		taken_positions.append(point.global_position)
		_spawn_one(entry, point)

	if _spawned_enemies.is_empty():
		_is_cleared = true
		_lock_exits(false)


func _take_spawn_point(free_points: Array[Marker3D], taken: Array[Vector3], spacing: float) -> Marker3D:
	if free_points.is_empty():
		return null
	if spacing <= 0.0 or taken.is_empty():
		return free_points.pop_front()

	for i in range(free_points.size()):
		var candidate: Marker3D = free_points[i]
		var ok: bool = true
		for t in taken:
			if candidate.global_position.distance_to(t) < spacing:
				ok = false
				break
		if ok:
			free_points.remove_at(i)
			return candidate

	return free_points.pop_front()


func _spawn_one(entry: EnemySpawnEntry, point: Marker3D) -> void:
	var enemy: Node3D = entry.scene.instantiate()

	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(enemy)

	var spawn_pos: Vector3 = point.global_position
	spawn_pos.y += 0.1
	enemy.global_transform = Transform3D(Basis.IDENTITY, spawn_pos)
	enemy.rotation = Vector3(0.0, point.global_rotation.y, 0.0)
	enemy.scale = Vector3.ONE

	_spawned_enemies.append(enemy)
	_active_enemies += 1

	if enemy.has_signal("died"):
		enemy.connect("died", _on_enemy_died)
	else:
		var health_node := enemy.find_child("Health", true, false)
		if health_node and health_node.has_signal("died"):
			health_node.died.connect(_on_enemy_died)
		else:
			enemy.tree_exited.connect(_on_enemy_died)


func apply_exit_flags(required_flags: int) -> void:
	for key in exit_points.keys().duplicate():
		var flag: int = _FLAG_BY_KEY.get(key, 0)
		if flag & required_flags == 0:
			exit_points.erase(key)


func _on_enemy_died() -> void:
	_active_enemies -= 1
	if _active_enemies <= 0 and not _is_cleared:
		_is_cleared = true
		_lock_exits(false)
		room_cleared.emit(self)


func is_cleared() -> bool:
	return _is_cleared


func requires_clear() -> bool:
	return _requires_clear


func get_active_enemy_count() -> int:
	return _active_enemies


func _lock_exits(locked: bool) -> void:
	for marker in exit_points.values():
		if marker.has_meta("door_node"):
			var door: Node = marker.get_meta("door_node")
			if is_instance_valid(door) and door.has_method("set_locked"):
				door.set_locked(locked)


func on_player_entered() -> void:
	room_entered.emit(self)
	if _is_cleared or _enemies_spawned or not _requires_clear:
		return
	_enemies_spawned = true
	_lock_exits(true)
	_spawn_prepared_enemies()
