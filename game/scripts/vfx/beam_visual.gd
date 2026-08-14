extends RefCounted
class_name BeamVisual

# ============================================================================
# BeamVisual — statischer Port von custom_enemy_base.gd's Strahl-Helfern
# (_create_beam_visual()/_update_beam_visual()/_free_beam_visual()/
# _orient_beam_segment()) fuer Spieler-Faehigkeiten.
# ============================================================================
# custom_enemy_base.gd's Original ist an Instanzmethoden von CustomEnemyBase
# gebunden - fuer Winters Heavy-Laser-Stream (ein Spieler-Combat-Script, keine
# CustomEnemyBase) direkt unbrauchbar. Bewusst KOPIERT statt custom_enemy_base
# umgebaut, um dessen Original (Basis fuer sechs funktionierende Gegnertypen)
# nicht anzutasten - siehe dortiger Kopfkommentar fuer die volle Begruendung
# von Kern+Glow+Puls statt eines einzelnen duennen Zylinders.


## Baut einen Energiestrahl: duenner heller Kern + breiterer weicher
## Glow-Mantel + eine Puls-Kugel, die den Strahl entlanglaeuft. Rueckgabe:
## Dictionary{root, core, glow, pulse, t} - "root" haengt unter
## context.get_tree().current_scene, muss also explizit ueber free() wieder
## aufgeraeumt werden, NICHT automatisch beim Tod des Aufrufers.
static func create(context: Node, color: Color, radius_scale: float = 1.0) -> Dictionary:
	if context == null or not is_instance_valid(context):
		return {}

	var root := Node3D.new()
	context.get_tree().current_scene.add_child(root)

	var glow := MeshInstance3D.new()
	var glow_cyl := CylinderMesh.new()
	glow_cyl.top_radius = 0.3 * radius_scale
	glow_cyl.bottom_radius = 0.3 * radius_scale
	glow_cyl.height = 1.0
	glow.mesh = glow_cyl
	var glow_mat := _make_unshaded_material(color, 0.8)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color.a = 0.3
	glow.material_override = glow_mat
	root.add_child(glow)

	var core := MeshInstance3D.new()
	var core_cyl := CylinderMesh.new()
	core_cyl.top_radius = 0.09 * radius_scale
	core_cyl.bottom_radius = 0.09 * radius_scale
	core_cyl.height = 1.0
	core.mesh = core_cyl
	core.material_override = _make_unshaded_material(color, 2.8)
	root.add_child(core)

	var pulse := MeshInstance3D.new()
	var pulse_mesh := SphereMesh.new()
	pulse_mesh.radius = 0.24 * radius_scale
	pulse_mesh.height = 0.48 * radius_scale
	pulse.mesh = pulse_mesh
	pulse.material_override = _make_unshaded_material(color, 3.2)
	root.add_child(pulse)

	return {"root": root, "core": core, "glow": glow, "pulse": pulse, "t": 0.0}


## Aktualisiert Position/Ausrichtung/Puls eines mit create() erzeugten
## Strahls. delta wird nur fuer die Pulsgeschwindigkeit gebraucht.
static func update(beam: Dictionary, from: Vector3, to: Vector3, delta: float) -> void:
	if beam.is_empty() or not is_instance_valid(beam["root"]):
		return
	_orient_segment(beam["core"], from, to)
	_orient_segment(beam["glow"], from, to)

	beam["t"] = fmod(float(beam["t"]) + delta * 1.6, 1.0)
	var pulse: MeshInstance3D = beam["pulse"]
	if is_instance_valid(pulse):
		pulse.global_position = from.lerp(to, float(beam["t"]))


static func free_beam(beam: Dictionary) -> void:
	if not beam.is_empty() and is_instance_valid(beam["root"]):
		(beam["root"] as Node3D).queue_free()


## Positioniert/skaliert/dreht einen duennen Cylinder-Mesh so, dass er als
## Verbindungsbeam zwischen zwei Punkten erscheint (Y-Achse = Laenge).
## NICHT einfach node.look_at(to, Vector3.UP): wirft eine Godot-Warnung bei
## einer fast senkrechten Blickrichtung - siehe custom_enemy_base.gd::
## _orient_beam_segment() fuer die volle Herleitung, hier identisch kopiert.
static func _orient_segment(node: Node3D, from: Vector3, to: Vector3) -> void:
	var dist: float = from.distance_to(to)
	node.global_position = from.lerp(to, 0.5)

	node.scale = Vector3.ONE
	if dist <= 0.01:
		node.scale = Vector3(1.0, 0.01, 1.0)
		return
	var dir: Vector3 = (to - from) / dist
	var up_hint: Vector3 = Vector3.FORWARD if absf(dir.dot(Vector3.UP)) > 0.95 else Vector3.UP
	node.look_at(to, up_hint)
	node.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))
	node.scale = Vector3(1.0, dist, 1.0)


static func _make_unshaded_material(color: Color, emission_mul: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	if emission_mul > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission_mul
	return mat
