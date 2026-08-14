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


const _GROUND_RAYCAST_MASK: int = 1

## Bruchstuecke, die von origin aus auf den Boden fallen und dort liegen
## bleiben (statt wie eine reine Partikelwolke in der Luft zu verblassen).
## Extrahiert aus custom_enemy_base.gd::_spawn_ground_fragments() (Moerser-
## Bot-Zerstoerung), damit auch Nicht-CustomEnemyBase-Nodes (z.B. breakable_
## prop.gd) exakt denselben Look/dieselbe Tween-Arc-Physik bekommen, ohne den
## Code zu duplizieren - CustomEnemyBase._spawn_ground_fragments() ruft jetzt
## nur noch diese Methode auf.
##
## colors zyklisch pro Bruchstueck verwendet - so faerben sich die Kloetze
## dynamisch in beliebigen Farben (z.B. der Hauptfarbe eines zerstoerten
## Requisits), ohne pro Farbe eine eigene Szene zu brauchen.
## exclude_body: optionaler CollisionObject3D, dessen eigene Kollision beim
## Boden-Raycast ignoriert werden soll (z.B. der gerade sterbende Gegner
## selbst, damit der Strahl nicht an dessen eigener Huelle haengen bleibt).
func spawn_ground_fragments(colors: Array[Color], origin: Vector3, count: int = 6, exclude_body: CollisionObject3D = null) -> void:
	var tree: SceneTree = get_tree()
	var parent: Node = tree.current_scene
	if parent == null or not is_instance_valid(parent) or colors.is_empty():
		return

	for i: int in range(count):
		var frag := MeshInstance3D.new()
		var box := BoxMesh.new()
		var size: float = randf_range(0.25, 0.5)
		box.size = Vector3(size, size * randf_range(0.6, 1.0), size)
		frag.mesh = box
		frag.material_override = _make_unshaded_material(colors[i % colors.size()], 0.4)
		# Gruppe statt freihaengendem Node: stage_manager.gd raeumt
		# "floor_debris" beim Etagenwechsel mit auf (wie pickups/hazard/
		# projectiles) - ohne das wuerden sich Bruchstuecke ueber eine ganze
		# Run-Dauer unbegrenzt unter current_scene ansammeln, weil sie
		# absichtlich nie von selbst queue_free()en.
		frag.add_to_group("floor_debris")
		parent.add_child(frag)
		frag.global_position = origin
		frag.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)

		var angle: float = randf() * TAU
		var horiz: float = randf_range(1.0, 2.8)
		var landing_xz: Vector3 = origin + Vector3(cos(angle) * horiz, 0.0, sin(angle) * horiz)
		# _project_ground_point() statt eines geratenen Y-Werts, damit die
		# Bruchstuecke auch auf leicht geneigtem/unebenem Boden sauber
		# aufliegen statt in der Luft zu haengen oder im Boden zu versinken.
		var target: Vector3 = _project_ground_point(landing_xz, exclude_body) + Vector3.UP * (size * 0.5)
		var spin: Vector3 = frag.rotation + Vector3(
			randf_range(2.0, 6.0), randf_range(2.0, 6.0), randf_range(2.0, 6.0)
		)

		var tween: Tween = frag.create_tween()
		tween.set_parallel(true)
		tween.tween_property(frag, "global_position", target, 0.6) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(frag, "rotation", spin, 0.6)


func _make_unshaded_material(color: Color, emission_mul: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	if emission_mul > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission_mul
	return mat


func _project_ground_point(pos: Vector3, exclude_body: CollisionObject3D = null) -> Vector3:
	var world: World3D = get_tree().root.world_3d
	if world == null:
		return pos
	var query := PhysicsRayQueryParameters3D.create(
		pos + Vector3.UP * 2.0, pos - Vector3.UP * 20.0
	)
	query.collision_mask = _GROUND_RAYCAST_MASK
	if exclude_body != null and is_instance_valid(exclude_body):
		query.exclude = [exclude_body.get_rid()]
	var result := world.direct_space_state.intersect_ray(query)
	if result.is_empty():
		return pos
	return result.position


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
