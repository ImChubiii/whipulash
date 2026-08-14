extends CustomEnemyBase
class_name AcidSprinkler

# ============================================================================
# Saeure-Sprinkler — stationaerer Gegner, fest im Boden verankert.
# ============================================================================
# Spuckt in festen Abstaenden ein Saeure-Geschoss auf die aktuelle Position
# des Spielers. Am Einschlagsort bleibt eine Pfuetze liegen (Area3D, exakt
# das gleiche Prinzip wie die Saeure-/Limonaden-Pfuetzen aus
# item_behaviours.gd::_spawn_puddle), die Steht-drin-Spieler per Tick den
# "acid"-Statuseffekt verpasst - NICHT das Geschoss selbst beim Vorbeiflug.
# Mehrere Pfuetzen ueberlappen sich mit der Zeit zu einem Bereich, den der
# Spieler aktiv meiden muss.

const ACID_TICK_INTERVAL: float = 0.5
const ACID_DAMAGE_PER_TICK: float = 5.0
const ACID_DURATION: float = 3.0

## Rueckmeldung "jeder Gegner ausser Magnet soll 3x groesser sein". Anders
## als mortar_bot.gd/etc. hatte dieser Gegner bisher gar keinen eigenen
## Skalierungsfaktor (Meshe direkt in Rohgroesse gebaut) - jetzt nachgeruestet,
## gleiches Muster wie die anderen CustomEnemyBase-Gegner.
## Rueckmeldung "Saeure-Sprinkler ist zu gross" (2026-08-13): um 15%
## verkleinert, gleiche Groessenordnung wie mortar_bot.gd's Korrektur.
const VISUAL_SCALE: float = 3.0 * 0.85

## Rueckmeldung "alle Gegner sollen global 10% schneller angreifen"
## (2026-08-13): kuerzerer Cooldown = hoehere Angriffsfrequenz.
var fire_interval: float = 2.6 / 1.1
var flight_time: float = 0.7
var puddle_radius: float = 2.6
var puddle_lifetime: float = 6.0
## War 40.0 - Rueckmeldung "Detection-Range extrem stark erhoehen, damit er
## den Spieler fast ueberall im Raum bemerkt" (siehe mortar_bot.gd fuer
## dieselbe Aenderung/Begruendung).
var detect_range: float = 500.0

## Wie schnell sich der Saeure-Sprinkler zum Spieler dreht (rad/s) - langsam
## genug, dass die Drehung als sichtbares "Zielen" wirkt statt als Snap.
const TURN_SPEED: float = 1.2

var _cooldown: float = 0.0


func _configure() -> void:
	display_name = "Saeure-Sprinkler"
	max_health = 70.0


func _build() -> void:
	_build_visual()
	visual_root.scale = Vector3.ONE * VISUAL_SCALE
	_add_box_collision(Vector3(1.6, 1.8, 1.6) * VISUAL_SCALE, Vector3(0.0, 0.9, 0.0) * VISUAL_SCALE)
	_cooldown = fire_interval * randf_range(0.3, 1.0)


func _build_visual() -> void:
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = 0.7
	body_mesh.bottom_radius = 0.95
	body_mesh.height = 1.6
	var body_visual := MeshInstance3D.new()
	body_visual.mesh = body_mesh
	body_visual.material_override = _make_unshaded_material(Color(0.25, 0.35, 0.15))
	body_visual.position = Vector3(0.0, 0.8, 0.0)
	visual_root.add_child(body_visual)

	var nozzle_mesh := CylinderMesh.new()
	nozzle_mesh.top_radius = 0.18
	nozzle_mesh.bottom_radius = 0.3
	nozzle_mesh.height = 0.9
	var nozzle := MeshInstance3D.new()
	nozzle.mesh = nozzle_mesh
	nozzle.material_override = _make_unshaded_material(Color(0.55, 0.95, 0.25), 1.4)
	nozzle.rotation.x = deg_to_rad(-45.0)
	nozzle.position = Vector3(0.0, 1.7, 0.35)
	visual_root.add_child(nozzle)

	var light := OmniLight3D.new()
	light.light_color = Color(0.55, 0.95, 0.25)
	light.light_energy = 0.8
	light.omni_range = 5.0
	light.shadow_enabled = false
	light.position = Vector3(0.0, 1.9, 0.0)
	visual_root.add_child(light)


func _physics_process(delta: float) -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return
	if global_position.distance_to(player.global_position) > detect_range:
		return

	_turn_toward(player.global_position, delta, TURN_SPEED)

	_cooldown -= delta
	if _cooldown <= 0.0:
		_cooldown = fire_interval
		# Ground-projiziert, damit Glob-Landung und Pfuetze sichtbar auf dem
		# Boden liegen statt auf roher Spieler-Y-Hoehe (Sprung etc.) - siehe
		# gleiche Begruendung in mortar_bot.gd::_physics_process().
		_spit_at(_project_to_ground(player.global_position))


func _spit_at(target_pos: Vector3) -> void:
	var launch_pos: Vector3 = global_position + Vector3.UP * 1.7 + \
		(global_position.direction_to(target_pos) * 0.6)

	var glob := MeshInstance3D.new()
	var glob_mesh := SphereMesh.new()
	glob_mesh.radius = 0.32
	glob_mesh.height = 0.64
	glob.mesh = glob_mesh
	glob.material_override = _make_unshaded_material(Color(0.55, 0.95, 0.25), 1.8)
	get_tree().current_scene.add_child(glob)
	glob.global_position = launch_pos

	var peak: Vector3 = launch_pos.lerp(target_pos, 0.5) + Vector3.UP * 3.0
	var tween: Tween = create_tween()
	tween.tween_property(glob, "global_position", peak, flight_time * 0.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(glob, "global_position", target_pos, flight_time * 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		glob.queue_free()
		_spawn_puddle(target_pos)
	)


func _spawn_puddle(pos: Vector3) -> void:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0xFFFFFFFF

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = puddle_radius
	cyl.height = 1.0
	shape.shape = cyl
	area.add_child(shape)

	var mesh_node := MeshInstance3D.new()
	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = puddle_radius
	cyl_mesh.bottom_radius = puddle_radius
	cyl_mesh.height = 0.06
	mesh_node.mesh = cyl_mesh
	var mat := _make_unshaded_material(Color(0.55, 0.95, 0.25), 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.55
	mesh_node.material_override = mat
	area.add_child(mesh_node)

	get_tree().current_scene.add_child(area)
	area.global_position = pos + Vector3.UP * 0.05

	var timer := Timer.new()
	timer.wait_time = ACID_TICK_INTERVAL
	timer.autostart = true
	area.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(area):
			return
		for body: Node in area.get_overlapping_bodies():
			if not body.is_in_group(PartyManager.PLAYER_GROUP):
				continue
			if body.has_method("apply_status_effect"):
				body.call("apply_status_effect", "acid", ACID_DURATION, ACID_DAMAGE_PER_TICK, self, ACID_TICK_INTERVAL)
	)

	var fade: Tween = area.create_tween()
	fade.tween_interval(maxf(puddle_lifetime - 0.6, 0.0))
	fade.tween_property(mat, "albedo_color:a", 0.0, 0.6)
	fade.tween_callback(func() -> void:
		if is_instance_valid(area):
			area.queue_free()
	)


## Maschinen-Tod statt des generischen Wegschrumpfens aus custom_enemy_base.gd
## - der Saeure-Sprinkler ist ein Geraet, keine organische Einheit, und
## zerspringt deshalb sichtbar in seine Bauteile (gleiches Prinzip wie
## Moerser-Bot, siehe dortiger _teardown()).
func _teardown(with_hit_vfx: bool) -> void:
	if with_hit_vfx:
		_spawn_ground_fragments([Color(0.25, 0.35, 0.15), Color(0.55, 0.95, 0.25)])
	await super._teardown(with_hit_vfx)
