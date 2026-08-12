extends Node3D
class_name EnemyEspBox

# ============================================================================
# EnemyEspBox — "ESP-Hack"-Kastenumriss um ein anvisiertes Ziel.
# ============================================================================
# Macht sichtbar, WEN das jeweilige Waffensystem gerade automatisch anvisiert
# hat - dieselbe Grundidee wie die bereits existierenden Label3D-Diamant-
# Marker (siehe combat_giselle.gd::_build_esp_marker(), combat_winter.gd::
# _build_laser_esp_marker()), nur als Kastenumriss statt Text, und zusaetzlich
# mit einem kurzen Aufleucht-Puls (flash()) bei jedem tatsaechlichen Treffer.
#
# Haengt wie die Diamant-Marker unabhaengig unter current_scene, NICHT unter
# dem Ziel selbst - der aufrufende Combat-Node aktualisiert die Position
# jeden Frame per global_position, exakt das gleiche Muster wie
# _update_uzi_esp()/_update_laser_esp().
#
# Gebaut als zwoelf duenne, unshaded/emissive BoxMesh-Kanten statt eines
# echten Wireframe-Materials/Shaders - passt damit zum Rest des Projekts
# (siehe dive_bomber.gd::_build_visual(), custom_enemy_base.gd), das
# durchgehend einfache Primitiv-Meshes fuer Debug-/Hack-Optik nutzt statt
# eigener Shader.

const EDGE_THICKNESS: float = 0.045
const FLASH_DURATION: float = 0.18
## Rueckmeldung "Material/Shader deutlich sichtbarer/leuchtender machen":
## IDLE_ENERGY war 1.7, FLASH_ENERGY 5.0 - beide angehoben, PLUS Wechsel von
## alpha-gemischter Transparenz auf additive Blendung (siehe _add_edge()).
## Additiv heisst: die Kanten hellen den Hintergrund auf statt ihn nur zu
## ueberdecken - genau der "leuchtet durch alles hindurch"-Hack-Look, den
## z.B. auch treasure_pedestal.gd fuer seine Lichtsaeule nutzt
## (_make_glow_material()).
const FLASH_ENERGY: float = 9.0
const IDLE_ENERGY: float = 3.2
const IDLE_ALPHA: float = 0.95

## Rundherum-Zuschlag auf die aus der Kollisionsform berechnete Groesse
## (siehe compute_box_size()) - der Kasten soll den Gegner sichtbar
## UMGEBEN, nicht seine Huelle exakt nachzeichnen.
const SIZE_PADDING: float = 1.2
## Mindestgroesse pro Achse, falls ein Gegner keine (oder eine winzige)
## Kollisionsform hat - verhindert einen unsichtbar kleinen Punkt-Kasten.
const MIN_SIZE: Vector3 = Vector3(1.0, 1.0, 1.0)

## corner-index-Paare, die die zwoelf Kanten eines Quaders aus den acht
## Eckpunkten unten (_corners()) bilden - vier auf dem Boden, vier auf dem
## Deckel, vier vertikal dazwischen.
const EDGES: Array = [
	[0, 1], [1, 2], [2, 3], [3, 0],
	[4, 5], [5, 6], [6, 7], [7, 4],
	[0, 4], [1, 5], [2, 6], [3, 7],
]

var _color: Color = Color(1.0, 0.15, 0.15)
var _materials: Array[StandardMaterial3D] = []
var _flash_tween: Tween = null

## Groesse, mit der diese Box gebaut wurde - Aufrufer nutzen size.y * 0.5,
## um den vertikalen Versatz zum Ziel korrekt zu zentrieren (siehe
## combat_giselle.gd/combat_winter.gd), statt eines festen Werts, der bei
## einem Colossus zu tief und bei einem Fighter zu hoch saesse.
var size: Vector3 = Vector3.ONE


## Baut eine freistehende EnemyEspBox-Instanz, NICHT in den Baum gehaengt -
## der Aufrufer haengt sie selbst per add_child() unter current_scene
## (gleiches Muster wie _build_esp_marker()) und setzt global_position.
static func build(color: Color, box_size: Vector3 = Vector3(1.6, 2.2, 1.6)) -> EnemyEspBox:
	var box := EnemyEspBox.new()
	box._color = color
	box.size = box_size
	box._build_edges(box_size)
	return box


## Wie build(), bestimmt die Groesse aber selbst aus der Kollisionsform des
## Ziels statt einen festen Wert zu nehmen - Rueckmeldung "Kasten muss
## dynamisch mit der Groesse des jeweiligen Gegners skalieren (Colossus
## braucht groesseren Kasten als Fighter)".
static func build_for(enemy: Node3D, color: Color) -> EnemyEspBox:
	return build(color, compute_box_size(enemy))


## Sammelt alle CollisionShape3D-Nachfahren des Ziels und liefert eine
## gepolsterte Bounding-Box in Weltmasseinheiten. Deckt beide Gegnersysteme
## des Projekts ab (siehe CLAUDE.md-Architekturnotiz "zwei parallele
## Gegner-Systeme"): EnemyAI (Fighter/Stinger/Colossus) nutzt eine
## CapsuleShape3D, CustomEnemyBase-Gegner (Moerser-Bot etc., siehe
## custom_enemy_base.gd::_add_box_collision()) eine BoxShape3D. Die
## Shape-GROESSE selbst ist dort schon in Weltunits (inkl. VISUAL_SCALE)
## angegeben - hier wird nur noch die lokale Position/Rotation der jeweiligen
## CollisionShape3D-Node mit einbezogen, damit ein versetzt sitzender
## Collider die Bounding-Box nicht verfaelscht.
static func compute_box_size(enemy: Node3D) -> Vector3:
	if enemy == null or not is_instance_valid(enemy):
		return MIN_SIZE

	var min_corner := Vector3.INF
	var max_corner := -Vector3.INF
	var found: bool = false

	for shape_node: CollisionShape3D in _collect_collision_shapes(enemy):
		var extents: Vector3 = _shape_half_extents(shape_node.shape)
		if extents == Vector3.ZERO:
			continue
		found = true
		# Acht Eckpunkte der lokalen Shape-AABB, durch die Node-eigene
		# Transform (Position/Rotation innerhalb des Gegners) geschickt -
		# einfacher und robust genug fuer die hier ausschliesslich
		# achsenausgerichteten Formen, statt eine echte OBB zu rechnen.
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				for sz in [-1.0, 1.0]:
					var corner: Vector3 = shape_node.transform * Vector3(
						extents.x * sx, extents.y * sy, extents.z * sz
					)
					min_corner = min_corner.min(corner)
					max_corner = max_corner.max(corner)

	if not found:
		return MIN_SIZE

	var size: Vector3 = (max_corner - min_corner) * SIZE_PADDING
	return Vector3(maxf(size.x, MIN_SIZE.x), maxf(size.y, MIN_SIZE.y), maxf(size.z, MIN_SIZE.z))


static func _collect_collision_shapes(node: Node) -> Array[CollisionShape3D]:
	var result: Array[CollisionShape3D] = []
	if node is CollisionShape3D:
		result.append(node as CollisionShape3D)
	for child: Node in node.get_children():
		result.append_array(_collect_collision_shapes(child))
	return result


## Halbe Ausdehnung (lokale AABB-Extents, NICHT Weltmasse) fuer die in
## diesem Projekt vorkommenden Formtypen. Vector3.ZERO fuer alles andere
## (z.B. noch kein Shape zugewiesen) - vom Aufrufer als "ueberspringen"
## behandelt.
static func _shape_half_extents(shape: Shape3D) -> Vector3:
	if shape is BoxShape3D:
		return (shape as BoxShape3D).size * 0.5
	if shape is CapsuleShape3D:
		var capsule := shape as CapsuleShape3D
		return Vector3(capsule.radius, capsule.height * 0.5, capsule.radius)
	if shape is SphereShape3D:
		var r: float = (shape as SphereShape3D).radius
		return Vector3(r, r, r)
	if shape is CylinderShape3D:
		var cyl := shape as CylinderShape3D
		return Vector3(cyl.radius, cyl.height * 0.5, cyl.radius)
	return Vector3.ZERO


func _corners(size: Vector3) -> Array[Vector3]:
	var half: Vector3 = size * 0.5
	return [
		Vector3(-half.x, -half.y, -half.z), Vector3(half.x, -half.y, -half.z),
		Vector3(half.x, -half.y, half.z), Vector3(-half.x, -half.y, half.z),
		Vector3(-half.x, half.y, -half.z), Vector3(half.x, half.y, -half.z),
		Vector3(half.x, half.y, half.z), Vector3(-half.x, half.y, half.z),
	]


func _build_edges(size: Vector3) -> void:
	var corners: Array[Vector3] = _corners(size)
	for edge: Array in EDGES:
		_add_edge(corners[edge[0]], corners[edge[1]])


## Ein einzelner Kantenbalken: ein duenner BoxMesh, dessen lange Achse
## (lokal Z) per Basis.looking_at() auf die Kante ausgerichtet wird.
## Basis.looking_at() arbeitet rein in lokalen Vektoren (keine Baum-
## Zugehoerigkeit noetig) - anders als Node3D.look_at(), das schon
## global_position braucht und deshalb erst NACH add_child() funktionieren
## wuerde.
func _add_edge(from: Vector3, to: Vector3) -> void:
	var delta: Vector3 = to - from
	var length: float = delta.length()
	if length < 0.001:
		return
	var dir: Vector3 = delta / length
	var up: Vector3 = Vector3.FORWARD if absf(dir.dot(Vector3.UP)) > 0.99 else Vector3.UP

	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(EDGE_THICKNESS, EDGE_THICKNESS, length)
	mesh_instance.mesh = box

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(_color.r, _color.g, _color.b, IDLE_ALPHA)
	mat.emission_enabled = true
	mat.emission = _color
	mat.emission_energy_multiplier = IDLE_ENERGY
	# Additiv statt alpha-gemischt: hellt den Hintergrund auf statt ihn nur
	# zu ueberdecken - der eigentliche "leuchtet/glueht"-Unterschied (siehe
	# Konstanten-Kommentar oben).
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mesh_instance.material_override = mat
	_materials.append(mat)

	add_child(mesh_instance)
	mesh_instance.transform = Transform3D(Basis.looking_at(dir, up), from + delta * 0.5)


## Kurzer heller Puls bei einem tatsaechlichen Treffer - macht den Effekt
## reaktiv statt eines dauerhaft gleich hellen Umrisses ("laeuchtet auf, wenn
## der Angriff trifft" laut Rueckmeldung), statt nur staendig sichtbar zu
## sein, solange ein Ziel gelockt ist.
func flash() -> void:
	if _materials.is_empty():
		return
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()

	for mat: StandardMaterial3D in _materials:
		mat.emission_energy_multiplier = FLASH_ENERGY

	_flash_tween = create_tween()
	_flash_tween.set_parallel(true)
	for mat: StandardMaterial3D in _materials:
		_flash_tween.tween_property(mat, "emission_energy_multiplier", IDLE_ENERGY, FLASH_DURATION)
