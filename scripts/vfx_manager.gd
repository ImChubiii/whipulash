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
