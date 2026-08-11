extends CustomEnemyBase
class_name MortarBot

# ============================================================================
# Moerser-Bot — stationaerer Artillerie-Gegner.
# ============================================================================
# Bewegt sich nie. Feuert in festen Abstaenden eine Wurfparabel auf die
# AKTUELLE Position des Spielers zum Schusszeitpunkt. Der rote Bodenkreis
# markiert diesen Einschlagspunkt SOFORT (schwach), wird aber erst kurz vor
# dem Einschlag richtig kraeftig - deshalb bleibt er waehrend der ganzen
# Flugzeit exakt an derselben Stelle liegen, unabhaengig davon, wohin sich
# der Spieler danach bewegt. Wer beim Einschlag noch drinsteht, wird
# getroffen; wer rausdasht, nicht.
#
# Nutzt bewusst dieselbe "Telegraph bleibt am Ort, Schaden liest die
# Telegraph-Position und NICHT die aktuelle Spielerposition"-Regel wie
# Orbitalschlag/Lockdown in item_behaviours.gd (siehe dortiger Bugfix im
# Lockdown-Item - exakt derselbe Fehler waere hier genauso moeglich
# gewesen).

const DUST_RING_SCENE: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const SPARK_YELLOW_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")

var fire_interval: float = 3.6
var flight_time: float = 1.3
var arc_height: float = 8.0
var blast_radius: float = 4.2
var damage: float = 22.0
var detect_range: float = 45.0

var _cooldown: float = 0.0
var _base_radius: float = 1.1


func _configure() -> void:
	display_name = "Moerser-Bot"
	max_health = 90.0


func _build() -> void:
	_build_visual()
	_add_box_collision(Vector3(2.0, 2.2, 2.0), Vector3(0.0, 1.1, 0.0))
	_cooldown = fire_interval * randf_range(0.3, 1.0)


func _build_visual() -> void:
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = _base_radius
	base_mesh.bottom_radius = _base_radius * 1.3
	base_mesh.height = 1.4
	var base_visual := MeshInstance3D.new()
	base_visual.mesh = base_mesh
	base_visual.material_override = _make_unshaded_material(Color(0.16, 0.15, 0.18))
	base_visual.position = Vector3(0.0, 0.7, 0.0)
	visual_root.add_child(base_visual)

	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.4
	barrel_mesh.bottom_radius = 0.55
	barrel_mesh.height = 2.0
	var barrel := MeshInstance3D.new()
	barrel.mesh = barrel_mesh
	var mat := _make_unshaded_material(Color(0.85, 0.25, 0.15), 0.6)
	barrel.material_override = mat
	barrel.rotation.x = deg_to_rad(-55.0)
	barrel.position = Vector3(0.0, 1.7, 0.4)
	visual_root.add_child(barrel)

	var light := OmniLight3D.new()
	light.light_color = Color(0.9, 0.3, 0.15)
	light.light_energy = 0.9
	light.omni_range = 6.0
	light.shadow_enabled = false
	light.position = Vector3(0.0, 1.9, 0.0)
	visual_root.add_child(light)


func _physics_process(delta: float) -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return
	if global_position.distance_to(player.global_position) > detect_range:
		return

	_cooldown -= delta
	if _cooldown <= 0.0:
		_cooldown = fire_interval
		# Auf den Boden projiziert, statt roh player.global_position zu
		# nehmen: der Spieler-Root sitzt zwar normalerweise auf Fusshoehe,
		# aber im Sprung oder auf leicht geneigtem Boden waere das nicht
		# mehr exakt Bodenhoehe - Ring und Einschlag sollen sichtbar AUF
		# dem Boden liegen, nicht in der Luft schweben.
		_fire_at(_project_to_ground(player.global_position))


func _fire_at(target_pos: Vector3) -> void:
	var launch_pos: Vector3 = global_position + Vector3.UP * 1.9

	# --- Bodentelegraph: bleibt fix an target_pos stehen ---------------------
	var telegraph := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = blast_radius
	ring_mesh.bottom_radius = blast_radius
	ring_mesh.height = 0.05
	telegraph.mesh = ring_mesh
	var ring_mat := _make_unshaded_material(DANGER_TELEGRAPH_COLOR)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.albedo_color.a = 0.12
	telegraph.material_override = ring_mat
	get_tree().current_scene.add_child(telegraph)
	telegraph.global_position = target_pos + Vector3.UP * 0.05

	var ring_tween: Tween = create_tween()
	ring_tween.tween_property(ring_mat, "albedo_color:a", 0.85, flight_time)

	# --- Geschoss: zweiphasige Wurfparabel (Aufstieg, dann Fall) -------------
	var shell := MeshInstance3D.new()
	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = 0.4
	shell_mesh.height = 0.8
	shell.mesh = shell_mesh
	shell.material_override = _make_unshaded_material(Color(1.0, 0.4, 0.1), 2.0)
	get_tree().current_scene.add_child(shell)
	shell.global_position = launch_pos

	var peak: Vector3 = launch_pos.lerp(target_pos, 0.5) + Vector3.UP * arc_height
	var shell_tween: Tween = create_tween()
	shell_tween.tween_property(shell, "global_position", peak, flight_time * 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	shell_tween.tween_property(shell, "global_position", target_pos, flight_time * 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	shell_tween.tween_callback(func() -> void:
		shell.queue_free()
		if is_instance_valid(telegraph):
			telegraph.queue_free()
		_impact(target_pos)
	)


func _impact(impact_pos: Vector3) -> void:
	VFX.spawn(DUST_RING_SCENE, impact_pos)
	VFX.spawn(SPARK_YELLOW_SCENE, impact_pos + Vector3.UP)
	Juice.shake(1.4)

	var player: CharacterBody3D = _find_player()
	if player == null:
		return
	# Fixe Einschlagsposition, NICHT die aktuelle Spielerposition - siehe
	# Kopfkommentar. Nur horizontal gemessen: der Telegraph-Ring ist eine
	# flache Bodenflaeche, kein Kugelvolumen - ob man 3 m in der Luft ueber
	# dem Ring haengt, sollte am Treffer nichts aendern.
	var flat_player: Vector3 = player.global_position
	flat_player.y = impact_pos.y
	if flat_player.distance_to(impact_pos) > blast_radius:
		return

	var target_health := player.find_child("Health", true, false) as Health
	if target_health != null and target_health.is_alive():
		target_health.take_damage(damage, self)
	if player.has_method("apply_knockback"):
		var away: Vector3 = player.global_position - impact_pos
		away.y = 0.0
		if away.length_squared() < 0.01:
			away = Vector3.FORWARD
		player.apply_knockback(away.normalized() * 10.0 + Vector3.UP * 4.0)
