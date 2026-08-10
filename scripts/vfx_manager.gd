extends Node

## Zentraler One-Shot-VFX-Spawner.
##
## REGISTRIEREN: Project Settings -> Autoload
##   Pfad: res://scripts/vfx_manager.gd
##   Name: VFX
##
## WARUM ZENTRAL:
## Effekt-Nodes duerfen nicht am Ausloeser haengen — Hitboxen werden 0.15s
## nach dem Schlag deaktiviert, Gegner rufen bei Tod queue_free(). Ein
## Kind-Emitter waere dann mitten im Abspielen weg. Hier landen alle
## Effekte in current_scene und raeumen sich nach Ablauf selbst ab.

## Sicherheitszuschlag auf die berechnete Lebensdauer.
const CLEANUP_MARGIN: float = 0.5

## Notbremse, falls eine Szene gar keinen Partikel-Node enthaelt.
const FALLBACK_LIFETIME: float = 2.0


## global_pos = Weltposition des Effekts.
## direction  = Ausrichtung; -Z des Effekts zeigt darauf (Godot-Konvention
##              von look_at). Vector3.ZERO = keine Ausrichtung.
## parent     = optionaler Eltern-Node; Standard ist current_scene.
func spawn(scene: PackedScene, global_pos: Vector3, direction: Vector3 = Vector3.ZERO, parent: Node = null) -> Node3D:
	if scene == null:
		return null

	var target_parent: Node = parent if parent != null else get_tree().current_scene
	if target_parent == null or not is_instance_valid(target_parent):
		return null

	var instance: Node = scene.instantiate()
	if not (instance is Node3D):
		push_warning("[VFX] '%s' ist kein Node3D — verworfen." % scene.resource_path)
		instance.queue_free()
		return null

	var node: Node3D = instance as Node3D
	target_parent.add_child(node)
	# NACH add_child(): global_position ist vorher nicht gueltig.
	node.global_position = global_pos

	if direction.length_squared() > 0.0001:
		_aim(node, direction.normalized())

	var lifetime: float = _restart_emitters(node)
	_schedule_cleanup(node, lifetime)
	return node


## Wie spawn(), faerbt aber zusaetzlich JEDEN gefundenen Partikel-Emitter
## ZWEIFARBIG ein, BEVOR er emittiert (siehe primary_hitbox.gd, das damit den
## Treffer-Funken in attack_color/attack_color_secondary des aktiven
## Charakters einfaerbt, statt fuer jede Farbkombination eine eigene
## VFX-Szene zu brauchen).
##
## WIE DIE ZWEIFARBIGKEIT ENTSTEHT: draw_pass_1 bekommt color_a, draw_pass_2
## (sofern die Szene einen hat - siehe hit_spark_primary.tscn) color_b.
## GPUParticles3D wuerfelt bei mehreren Draw-Passes PRO EINZELPARTIKEL aus,
## welcher gezeichnet wird - das ist Godots eingebauter Mechanismus fuer
## Partikel-Vielfalt (z.B. unterschiedlich gefaerbte Glut in einem Feuer) und
## damit zuverlaessiger als der Versuch, Farbverlauf ueber
## ParticleProcessMaterial.color_ramp + Vertex-Color-Passthrough zu erzwingen,
## dessen genaues Verhalten mit einem unshaded StandardMaterial3D als
## Draw-Pass nicht in jedem Fall garantiert ist.
func spawn_dual_tinted(scene: PackedScene, global_pos: Vector3, color_a: Color, color_b: Color, direction: Vector3 = Vector3.ZERO, parent: Node = null) -> Node3D:
	if scene == null:
		return null

	var target_parent: Node = parent if parent != null else get_tree().current_scene
	if target_parent == null or not is_instance_valid(target_parent):
		return null

	var instance: Node = scene.instantiate()
	if not (instance is Node3D):
		push_warning("[VFX] '%s' ist kein Node3D — verworfen." % scene.resource_path)
		instance.queue_free()
		return null

	var node: Node3D = instance as Node3D
	target_parent.add_child(node)
	node.global_position = global_pos

	if direction.length_squared() > 0.0001:
		_aim(node, direction.normalized())

	# VOR dem Emittieren faerben: process_material/draw_pass-Material duerfen
	# erst NACH dem Einfaerben live gehen, sonst startet der erste
	# gerenderte Frame noch mit der alten Farbe.
	_apply_dual_tint(node, color_a, color_b)

	var lifetime: float = _restart_emitters(node)
	_schedule_cleanup(node, lifetime)
	return node


## Faerbt draw_pass_1 mit color_a, draw_pass_2 (falls vorhanden) mit color_b.
## Fehlt draw_pass_2 in der Szene, faerbt sich der Emitter einfach komplett
## mit color_a - kein Fehler, nur weniger Abwechslung.
##
## WARUM ERST duplicate(): [sub_resource]-Materialien einer .tscn sind PRO
## PACKEDSCENE, nicht pro Instanz - Godot teilt sie standardmaessig zwischen
## allen scene.instantiate()-Aufrufen (derselbe Fallstrick, den
## lemonade.gd._make_resources_unique() im Projekt schon einmal beheben
## musste). Ohne die Duplikate wuerde das Einfaerben EINES Treffer-Funkens
## rueckwirkend auch jeden anderen, gerade noch aktiven Funken umfaerben.
func _apply_dual_tint(root: Node, color_a: Color, color_b: Color) -> void:
	for node in _collect_emitters(root):
		if node is GPUParticles3D:
			var gpu: GPUParticles3D = node
			# process_material.color bleibt neutral Weiss - die eigentliche
			# Faerbung kommt aus den beiden Draw-Pass-Materialien unten, sonst
			# wuerden beide Toene zusaetzlich gleichfoermig ueberfaerbt.
			if gpu.process_material != null:
				gpu.process_material = gpu.process_material.duplicate()
				if gpu.process_material is ParticleProcessMaterial:
					(gpu.process_material as ParticleProcessMaterial).color = Color(1.0, 1.0, 1.0, 1.0)
			if gpu.draw_pass_1 != null:
				gpu.draw_pass_1 = gpu.draw_pass_1.duplicate()
				_tint_primitive_mesh(gpu.draw_pass_1, color_a)
			if gpu.draw_pass_2 != null:
				gpu.draw_pass_2 = gpu.draw_pass_2.duplicate()
				_tint_primitive_mesh(gpu.draw_pass_2, color_b)
		elif node is CPUParticles3D:
			# CPUParticles3D kennt keine mehreren Draw-Passes - faerbt sich
			# einfarbig mit color_a statt einer erzwungenen Mischfarbe.
			(node as CPUParticles3D).color = color_a


func _tint_primitive_mesh(mesh: Mesh, tint: Color) -> void:
	if not (mesh is PrimitiveMesh):
		return
	var primitive: PrimitiveMesh = mesh as PrimitiveMesh
	if primitive.material == null:
		return
	var unique_material: Material = primitive.material.duplicate()
	if unique_material is StandardMaterial3D:
		var std: StandardMaterial3D = unique_material as StandardMaterial3D
		std.albedo_color = tint
		if std.emission_enabled:
			std.emission = tint
	primitive.material = unique_material


## look_at() wirft einen Fehler, wenn die Blickrichtung exakt parallel zum
## Up-Vektor liegt (Treffer senkrecht von oben/unten). Dann wird Up gekippt.
func _aim(node: Node3D, dir: Vector3) -> void:
	var up: Vector3 = Vector3.UP
	if absf(dir.dot(up)) > 0.99:
		up = Vector3.FORWARD
	node.look_at(node.global_position + dir, up)


## Startet alle Emitter der Szene neu und liefert die laengste Laufzeit.
func _restart_emitters(root: Node) -> float:
	var longest: float = 0.0
	for node in _collect_emitters(root):
		if node is GPUParticles3D:
			var gpu: GPUParticles3D = node
			gpu.restart()
			gpu.emitting = true
			longest = maxf(longest, gpu.lifetime / maxf(gpu.speed_scale, 0.01))
		elif node is CPUParticles3D:
			var cpu: CPUParticles3D = node
			cpu.restart()
			cpu.emitting = true
			longest = maxf(longest, cpu.lifetime / maxf(cpu.speed_scale, 0.01))
	return longest if longest > 0.0 else FALLBACK_LIFETIME


func _collect_emitters(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	if node is GPUParticles3D or node is CPUParticles3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_collect_emitters(child))
	return result


func _schedule_cleanup(node: Node3D, lifetime: float) -> void:
	await get_tree().create_timer(lifetime + CLEANUP_MARGIN).timeout
	if is_instance_valid(node):
		node.queue_free()
