@tool
extends StaticBody3D
class_name PitFloor

## Ersetzt den durchgehenden Boden-Slab eines Raumes durch einen Boden MIT
## LOECHERN plus echte Gruben-Wannen darunter. Damit faellt man wirklich in
## die Limonade, statt obendrauf zu laufen.
##
## WARUM NICHT CSG-SUBTRACTION:
## Die NavigationMesh der generierten Level hat
## geometry_parsed_geometry_type = STATIC_COLLIDERS - gebacken wird also
## ausschliesslich aus StaticBody3D/CollisionShape3D-Paaren im Szenenbaum.
## CSGShape3D mit use_collision registriert seinen Collider direkt im
## PhysicsServer und taucht als Node gar nicht auf; der Baker wuerde den
## Raum als leer sehen und die Gegner haetten keine Navmesh. Ausserdem
## wird die CSG-Operation bei jedem Instanziieren neu evaluiert.
##
## VERWENDUNG:
## Dieses Script per "Load" auf den bestehenden "Floor"-StaticBody3D eines
## Room-Templates legen. Die vorhandene MeshInstance3D/CollisionShape3D
## bleiben als Vorlage liegen (Material wird uebernommen) und werden zur
## Laufzeit durch die generierten Segmente ersetzt.
##
## Die Gruben werden standardmaessig AUTOMATISCH aus den bereits im Raum
## platzierten Lemonade-Instanzen abgeleitet - du musst also nichts doppelt
## pflegen. Die Lava wird dabei gleich mit nach unten gesetzt und auf
## hazard_mode = POOL umgestellt.

## Grundflaeche des Bodens (X/Z) in Weltunits.
@export var floor_size: Vector2 = Vector2(48.0, 48.0):
	set(value):
		floor_size = value
		_request_rebuild()

## Dicke des Boden-Slabs. Muss zur BoxShape3D des Templates passen.
@export var floor_thickness: float = 1.0:
	set(value):
		floor_thickness = value
		_request_rebuild()

## Tiefe der Gruben, gemessen von der Bodenoberkante nach unten.
@export var pit_depth: float = 6.0:
	set(value):
		pit_depth = value
		_request_rebuild()

## Gruben automatisch unter jeder LavaHazard-Instanz des Raumes anlegen.
@export var auto_pits_from_lava: bool = true:
	set(value):
		auto_pits_from_lava = value
		_request_rebuild()

## Wie weit die Grube ueber die Lava-Grundflaeche hinausragt. Ein kleiner
## Wert verhindert Z-Fighting zwischen Lava-Rand und Grubenwand.
@export var pit_margin: float = 0.15:
	set(value):
		pit_margin = value
		_request_rebuild()

## Zusaetzliche Gruben ohne Lava (z.B. reine Absturzloecher fuer Parkour).
## Pro Eintrag: (center_x, center_z, size_x, size_z) - lokal zum Raum.
@export var extra_pits: Array[Vector4] = []:
	set(value):
		extra_pits = value
		_request_rebuild()

## Bodenlose Abgruende MIT Instant-Kill, UNABHAENGIG von build_basin. Anders
## als extra_pits (die build_basin fuer den ganzen Raum mitbenutzen, also
## KEINE Wanne bekommen koennen, solange irgendwo im selben Raum eine
## Lava-Wanne noetig ist) sind das hier immer echte Abgruende: keine Wanne,
## dafuer eine Instant-Kill-Zone tief unten plus eine dunkle Rueckwand
## darunter, damit man die Falltiefe nicht abschaetzen kann. Gleiches
## Eintragsformat wie extra_pits: (center_x, center_z, size_x, size_z).
@export var extra_void_pits: Array[Vector4] = []:
	set(value):
		extra_void_pits = value
		_request_rebuild()

## Wie tief unter der Bodenoberkante die Instant-Kill-Zone eines
## extra_void_pits-Eintrags sitzt. Tief genug, dass der Sturz sichtbar Zeit
## braucht, bevor er endet.
@export var void_kill_depth: float = 24.0

## Zusaetzliche Tiefe der schwarzen Rueckwand UNTER der Kill-Zone - rein
## optisch, verhindert, dass beim Reinfallen kurz der Boden der Kill-Zone
## aufblitzt, bevor der Treffer ausgewertet wird.
@export var void_backdrop_extra_depth: float = 10.0

## Wie hoch die Grube mit Limonade gefuellt wird (Anteil von pit_depth).
@export_range(0.1, 1.0) var lava_fill_ratio: float = 0.8

## Wie weit die Limonaden-Oberflaeche unter der Bodenoberkante liegt.
##
## BUGFIX "Lava-Flaechen stehen ueber den Rand / sind zu niedrig": vorher
## 1.2 - je nach pit_depth/lava_fill_ratio-Kombination eines Raumes wirkte
## dieser feste Absatz mal wie ein zu tief abgesackter, mal (durch die neu
## berechnete Fuellhoehe) wie ein ueber den Rand ragender Pool. Knapp ueber
## 0 haelt die Oberflaeche stattdessen IMMER auf Bodenhoehe - "ground
## level", wie gefordert - unabhaengig von pit_depth/lava_fill_ratio.
@export var lava_surface_drop: float = 0.08

## Erzeugt die Wanne (Seitenwaende + Grubenboden). Ausschalten, wenn du
## ein echtes bodenloses Loch willst (Sturz aus dem Level).
@export var build_basin: bool = true

## Prefix aller generierten Kinder - dient dem Aufraeumen beim Rebuild.
const GEN_PREFIX := "Gen_"
const EPSILON := 0.001

var _floor_material: Material = null
var _rebuild_queued: bool = false


func _ready() -> void:
	_build()


func _request_rebuild() -> void:
	# Setter feuern auch waehrend des Ladens, bevor Kinder existieren.
	if not is_inside_tree():
		return
	if _rebuild_queued:
		return
	_rebuild_queued = true
	call_deferred("_build")


func _build() -> void:
	_rebuild_queued = false
	_capture_template_material()
	_clear_generated()

	var pits: Array[Rect2] = _collect_pits()
	var void_pits: Array[Rect2] = _collect_void_pits()

	# Der Boden-Sweep muss BEIDE Gruben-Arten kennen, sonst liesse er ueber
	# einem extra_void_pits-Eintrag den alten durchgehenden Slab stehen.
	var all_pits: Array[Rect2] = pits.duplicate()
	all_pits.append_array(void_pits)
	_build_floor_segments(all_pits)

	if build_basin:
		for pit in pits:
			_build_basin(pit)

	for i in range(void_pits.size()):
		_build_void_pit(void_pits[i], i)

	_disable_template_nodes()

	if not Engine.is_editor_hint():
		_reposition_lava()


## Material und Vorlage aus der urspruenglichen MeshInstance3D uebernehmen,
## damit die Segmente exakt wie der alte Boden aussehen.
func _capture_template_material() -> void:
	var template: MeshInstance3D = get_node_or_null("MeshInstance3D")
	if template == null:
		return
	# material_override hat Vorrang vor surface_material_override - hier
	# also in der richtigen Reihenfolge auslesen.
	if template.material_override:
		_floor_material = template.material_override
	elif template.get_surface_override_material_count() > 0:
		_floor_material = template.get_surface_override_material(0)


func _clear_generated() -> void:
	for child in get_children():
		if child.name.begins_with(GEN_PREFIX):
			remove_child(child)
			child.queue_free()


## Der originale Slab darf nicht stehenbleiben, sonst laeuft man weiter
## ueber das Loch. Im Editor nur ausblenden, zur Laufzeit entfernen.
func _disable_template_nodes() -> void:
	var mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")
	var shape: CollisionShape3D = get_node_or_null("CollisionShape3D")

	if Engine.is_editor_hint():
		if mesh:
			mesh.visible = false
		if shape:
			shape.disabled = true
		return

	if mesh:
		mesh.queue_free()
	if shape:
		shape.queue_free()


## Sammelt alle Gruben als Rect2 (position = linke obere Ecke in X/Z,
## size = Ausdehnung), im LOKALEN Koordinatensystem dieses Floor-Nodes.
func _collect_pits() -> Array[Rect2]:
	var pits: Array[Rect2] = []

	if auto_pits_from_lava:
		for hazard in _find_lava_hazards():
			var local_center: Vector3 = _to_floor_local(hazard)
			var lava_size: Vector3 = hazard.get("size")
			var sx: float = lava_size.x + pit_margin * 2.0
			var sz: float = lava_size.z + pit_margin * 2.0
			pits.append(Rect2(
				local_center.x - sx * 0.5,
				local_center.z - sz * 0.5,
				sx, sz
			))

	for entry in extra_pits:
		pits.append(Rect2(
			entry.x - entry.z * 0.5,
			entry.y - entry.w * 0.5,
			entry.z, entry.w
		))

	return pits


## Gleiches Eintragsformat wie _collect_pits(), aber fuer extra_void_pits -
## bewusst getrennt gehalten, weil diese Gruben IMMER die
## Instant-Kill-Behandlung bekommen, unabhaengig von build_basin (siehe
## Kopfkommentar bei extra_void_pits).
func _collect_void_pits() -> Array[Rect2]:
	var pits: Array[Rect2] = []
	for entry in extra_void_pits:
		pits.append(Rect2(
			entry.x - entry.z * 0.5,
			entry.y - entry.w * 0.5,
			entry.z, entry.w
		))
	return pits


## Sucht LavaHazard-Instanzen im selben Raum. Die Gruppe "lava_hazards"
## wird erst in deren _ready() gesetzt und ist im Editor gar nicht
## vorhanden - deshalb wird hier per Typ durch den Raum gelaufen.
func _find_lava_hazards() -> Array[Node3D]:
	var result: Array[Node3D] = []
	var room: Node = get_parent()
	if room == null:
		return result
	_collect_hazards_recursive(room, result)
	return result


func _collect_hazards_recursive(node: Node, out: Array[Node3D]) -> void:
	for child in node.get_children():
		if child is LavaHazard:
			out.append(child)
		_collect_hazards_recursive(child, out)


func _to_floor_local(node: Node3D) -> Vector3:
	# Relativ zueinander, damit die Weltposition des Raumes egal ist.
	return global_transform.affine_inverse() * node.global_transform.origin


## Zerlegt den Boden per Sweep entlang X in Streifen und fuellt in jedem
## Streifen die Z-Bereiche auf, die von keiner Grube belegt sind. Ergibt
## bei zwei Gruben typischerweise 5-7 Boxen statt eines Slabs - guenstig
## genug, und alles bleibt sauberer StaticBody3D-Collider.
func _build_floor_segments(pits: Array[Rect2]) -> void:
	var half_x: float = floor_size.x * 0.5
	var half_z: float = floor_size.y * 0.5

	if pits.is_empty():
		_emit_floor_box(Rect2(-half_x, -half_z, floor_size.x, floor_size.y))
		return

	# 1. Alle X-Schnittkanten einsammeln.
	var x_cuts: Array[float] = [-half_x, half_x]
	for pit in pits:
		x_cuts.append(clampf(pit.position.x, -half_x, half_x))
		x_cuts.append(clampf(pit.end.x, -half_x, half_x))
	x_cuts.sort()

	# 2. Pro X-Streifen die belegten Z-Intervalle bestimmen.
	for i in range(x_cuts.size() - 1):
		var x0: float = x_cuts[i]
		var x1: float = x_cuts[i + 1]
		if x1 - x0 <= EPSILON:
			continue
		var x_mid: float = (x0 + x1) * 0.5

		var blocked: Array = []
		for pit in pits:
			if x_mid > pit.position.x and x_mid < pit.end.x:
				blocked.append(Vector2(
					maxf(pit.position.y, -half_z),
					minf(pit.end.y, half_z)
				))

		blocked.sort_custom(func(a, b): return a.x < b.x)

		var cursor: float = -half_z
		for interval in blocked:
			if interval.x > cursor + EPSILON:
				_emit_floor_box(Rect2(x0, cursor, x1 - x0, interval.x - cursor))
			cursor = maxf(cursor, interval.y)

		if cursor < half_z - EPSILON:
			_emit_floor_box(Rect2(x0, cursor, x1 - x0, half_z - cursor))


func _emit_floor_box(rect: Rect2) -> void:
	if rect.size.x <= EPSILON or rect.size.y <= EPSILON:
		return
	var center := Vector3(
		rect.position.x + rect.size.x * 0.5,
		0.0,
		rect.position.y + rect.size.y * 0.5
	)
	_emit_box("Floor", center, Vector3(rect.size.x, floor_thickness, rect.size.y))


## Baut die Wanne: vier Seitenwaende plus Grubenboden. Ohne die Waende
## saehe man beim Reinfallen durch den Boden-Slab hindurch ins Nichts.
func _build_basin(pit: Rect2) -> void:
	var top: float = floor_thickness * 0.5           # Bodenoberkante, lokal
	var bottom: float = top - pit_depth
	var center_x: float = pit.position.x + pit.size.x * 0.5
	var center_z: float = pit.position.y + pit.size.y * 0.5
	var wall: float = 0.5

	# Grubenboden
	_emit_box(
		"PitFloor",
		Vector3(center_x, bottom - wall * 0.5, center_z),
		Vector3(pit.size.x + wall * 2.0, wall, pit.size.y + wall * 2.0)
	)

	var wall_height: float = pit_depth
	var wall_center_y: float = top - pit_depth * 0.5

	# Nord / Sued (entlang X)
	_emit_box("PitWallN",
		Vector3(center_x, wall_center_y, pit.position.y - wall * 0.5),
		Vector3(pit.size.x + wall * 2.0, wall_height, wall))
	_emit_box("PitWallS",
		Vector3(center_x, wall_center_y, pit.end.y + wall * 0.5),
		Vector3(pit.size.x + wall * 2.0, wall_height, wall))
	# West / Ost (entlang Z)
	_emit_box("PitWallW",
		Vector3(pit.position.x - wall * 0.5, wall_center_y, center_z),
		Vector3(wall, wall_height, pit.size.y))
	_emit_box("PitWallE",
		Vector3(pit.end.x + wall * 0.5, wall_center_y, center_z),
		Vector3(wall, wall_height, pit.size.y))


## Erzeugt EIN Mesh+Collider-Paar. Beides landet als Kind dieses
## StaticBody3D, damit der NavMesh-Baker die Collider findet.
func _emit_box(tag: String, center: Vector3, box_size: Vector3) -> void:
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "%s%s_Mesh" % [GEN_PREFIX, tag]
	mesh_instance.mesh = box_mesh
	mesh_instance.position = center
	if _floor_material:
		mesh_instance.material_override = _floor_material
	add_child(mesh_instance)

	var box_shape := BoxShape3D.new()
	box_shape.size = box_size

	var collision := CollisionShape3D.new()
	collision.name = "%s%s_Shape" % [GEN_PREFIX, tag]
	collision.shape = box_shape
	collision.position = center
	add_child(collision)

	if Engine.is_editor_hint():
		mesh_instance.owner = get_tree().edited_scene_root
		collision.owner = get_tree().edited_scene_root


## Bodenloser Abgrund: KEINE Wanne (siehe extra_void_pits-Kommentar) - dafuer
## ein tiefer, rein schwarzer SCHACHT (vier Waende + Boden, alle unbeleuchtet
## nahe Schwarz) statt eines offenen Lochs. Ohne Waende sieht man beim
## Reinschauen aus einem flachen Winkel an der duennen Kill-Zone/Rueckwand
## vorbei ins Nichts (Skybox, Nachbarraum) - der Schacht garantiert, dass in
## JEDE Blickrichtung nur Dunkelheit zu sehen ist. Die Instant-Kill-Zone
## sitzt weit genug oben im Schacht, dass man sie nie erreicht.
func _build_void_pit(pit: Rect2, index: int) -> void:
	var top: float = floor_thickness * 0.5
	var center_x: float = pit.position.x + pit.size.x * 0.5
	var center_z: float = pit.position.y + pit.size.y * 0.5
	var shaft_depth: float = void_kill_depth + void_backdrop_extra_depth

	_build_void_shaft("%sVoidShaft%d" % [GEN_PREFIX, index], pit, top, shaft_depth)

	var kill_y: float = top - void_kill_depth
	_build_void_kill_zone(
		"%sVoidKill%d" % [GEN_PREFIX, index],
		Vector3(center_x, kill_y, center_z),
		Vector3(pit.size.x, 2.0, pit.size.y)
	)


## Vier Waende (dicker als bei _build_basin, damit man selbst aus flachem
## Blickwinkel keine Luecke am Uebergang zum Boden-Slab sieht) plus ein
## Boden-Cap ganz unten - alles in derselben nahe-schwarzen Unlit-Farbe wie
## vorher die reine Rueckwand.
func _build_void_shaft(prefix: String, pit: Rect2, top: float, shaft_depth: float) -> void:
	var center_x: float = pit.position.x + pit.size.x * 0.5
	var center_z: float = pit.position.y + pit.size.y * 0.5
	var bottom: float = top - shaft_depth
	var wall: float = 1.0
	var wall_center_y: float = top - shaft_depth * 0.5

	_emit_dark_box("%sWallN" % prefix,
		Vector3(center_x, wall_center_y, pit.position.y - wall * 0.5),
		Vector3(pit.size.x + wall * 2.0, shaft_depth, wall))
	_emit_dark_box("%sWallS" % prefix,
		Vector3(center_x, wall_center_y, pit.end.y + wall * 0.5),
		Vector3(pit.size.x + wall * 2.0, shaft_depth, wall))
	_emit_dark_box("%sWallW" % prefix,
		Vector3(pit.position.x - wall * 0.5, wall_center_y, center_z),
		Vector3(wall, shaft_depth, pit.size.y))
	_emit_dark_box("%sWallE" % prefix,
		Vector3(pit.end.x + wall * 0.5, wall_center_y, center_z),
		Vector3(wall, shaft_depth, pit.size.y))
	_emit_dark_box("%sBottom" % prefix,
		Vector3(center_x, bottom - wall * 0.5, center_z),
		Vector3(pit.size.x + wall * 2.0, wall, pit.size.y + wall * 2.0))


## Gleiche Bauweise wie _emit_box(), aber mit fester, unbeleuchteter
## Nahe-Schwarz-Farbe statt des Boden-Materials - fuer alles, was als reine
## Dunkelheit wirken soll, nicht als sichtbare Grubenwand.
func _emit_dark_box(tag: String, center: Vector3, box_size: Vector3) -> void:
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.01, 0.01, 0.012)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "%s%s_Mesh" % [GEN_PREFIX, tag]
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = mat
	mesh_instance.position = center
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)

	var box_shape := BoxShape3D.new()
	box_shape.size = box_size
	var collision := CollisionShape3D.new()
	collision.name = "%s%s_Shape" % [GEN_PREFIX, tag]
	collision.shape = box_shape
	collision.position = center
	add_child(collision)

	if Engine.is_editor_hint():
		mesh_instance.owner = get_tree().edited_scene_root
		collision.owner = get_tree().edited_scene_root


## monitoring-only Area3D (collision_layer = 0, blockiert selbst nichts) -
## collision_mask = 5 (Layer 1 Spieler + Layer 4 Gegner, siehe lemonade.gd/
## LemonadeTrigger fuer denselben, bereits bewaehrten Maskenwert) - damit
## sterben auch Gegner sofort, die in den Abgrund fallen, nicht nur der
## Spieler.
func _build_void_kill_zone(node_name: String, center: Vector3, size: Vector3) -> void:
	var area := Area3D.new()
	area.name = node_name
	area.collision_layer = 0
	area.collision_mask = 5
	area.monitorable = false
	area.position = center
	add_child(area)

	var box := BoxShape3D.new()
	box.size = size
	var shape := CollisionShape3D.new()
	shape.shape = box
	area.add_child(shape)

	area.body_entered.connect(_on_void_kill_body_entered)

	if Engine.is_editor_hint():
		area.owner = get_tree().edited_scene_root
		shape.owner = get_tree().edited_scene_root


## Toetet JEDEN Body mit einer Health-Komponente - Spieler UND Gegner sollen
## beim Reinfallen sofort sterben, keine Sonderbehandlung noetig.
func _on_void_kill_body_entered(body: Node3D) -> void:
	var health: Node = body.get_node_or_null("Health")
	if health == null or not health.has_method("take_damage"):
		return
	if health.has_method("is_alive") and not health.is_alive():
		return
	var max_hp: float = float(health.get("max_health"))
	if max_hp <= 0.0:
		max_hp = 9999.0
	health.take_damage(max_hp * 999.0, self)


## Setzt die vorhandenen Lemonade-Instanzen in die frisch gebaute Grube:
## tiefer, dicker und im POOL-Modus, damit Auftrieb und Schwimmen greifen.
func _reposition_lava() -> void:
	for hazard in _find_lava_hazards():
		var local_pos: Vector3 = _to_floor_local(hazard)
		var lava_size: Vector3 = hazard.get("size")

		var new_depth: float = maxf(pit_depth * lava_fill_ratio, 0.5)
		var floor_top_local: float = floor_thickness * 0.5
		var target_surface_local: float = floor_top_local - lava_surface_drop
		var current_surface_local: float = local_pos.y + lava_size.y * 0.5

		# Neue Hoehe zuerst setzen, sonst rechnet der Offset mit der alten
		# Dicke und die Oberflaeche landet zu hoch.
		hazard.set("size", Vector3(lava_size.x, new_depth, lava_size.z))
		var new_surface_local: float = local_pos.y + new_depth * 0.5

		hazard.position.y += target_surface_local - new_surface_local

		hazard.set("hazard_mode", LavaHazard.HazardMode.POOL)
		# Im POOL-Modus zaehlt wieder die praezise Eintauchtiefe.
		hazard.set("submersion_tolerance", 0.3)

		# Ergebnis-Check nur zur Kontrolle in der Konsole.
		if hazard.get("debug_logging"):
			print("[PitFloor] '%s' -> Oberflaeche lokal %.2f, Tiefe %.2f" % [
				hazard.name, target_surface_local, new_depth
			])
