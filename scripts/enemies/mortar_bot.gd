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

const VISUAL_SCALE: float = 1.5
const FRAGMENT_LIFETIME: float = 1.1

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
	visual_root.scale = Vector3.ONE * VISUAL_SCALE
	_add_box_collision(Vector3(2.0, 2.2, 2.0) * VISUAL_SCALE, Vector3(0.0, 1.1, 0.0) * VISUAL_SCALE)
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
	var tree: SceneTree = get_tree()

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
	tree.current_scene.add_child(telegraph)
	telegraph.global_position = target_pos + Vector3.UP * 0.05

	# create_tween() an "telegraph"/"shell" statt an "self" (dem Moerser-Bot)
	# gebunden - siehe Kommentar am shell_tween unten fuer den Grund.
	var ring_tween: Tween = telegraph.create_tween()
	ring_tween.tween_property(ring_mat, "albedo_color:a", 0.85, flight_time)

	# --- Geschoss: zweiphasige Wurfparabel (Aufstieg, dann Fall) -------------
	var shell := MeshInstance3D.new()
	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = 0.4
	shell_mesh.height = 0.8
	shell.mesh = shell_mesh
	shell.material_override = _make_unshaded_material(Color(1.0, 0.4, 0.1), 2.0)
	tree.current_scene.add_child(shell)
	shell.global_position = launch_pos

	var peak: Vector3 = launch_pos.lerp(target_pos, 0.5) + Vector3.UP * arc_height
	# Werte VOR dem Tween-Callback in lokale Variablen kopieren, damit der
	# Callback unten (siehe _impact_at()) komplett ohne "self" auskommt.
	var dmg: float = damage
	var radius: float = blast_radius

	# BUGFIX "Geschosse frieren ein, wenn der Moerser-Bot waehrend des Flugs
	# stirbt": create_tween(), aufgerufen AUF DEM Moerser-Bot (self), wird
	# automatisch an dessen Lebensdauer gebunden - Godot killt so gebundene
	# Tweens automatisch, sobald der Node den Baum verlaesst (queue_free()
	# in custom_enemy_base.gd::_teardown()). "shell" haengt aber laengst
	# unter current_scene und sollte den Tod des Schuetzen ueberleben - der
	# Tween muss also an "shell" selbst gebunden sein, nicht an "self".
	var shell_tween: Tween = shell.create_tween()
	shell_tween.tween_property(shell, "global_position", peak, flight_time * 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	shell_tween.tween_property(shell, "global_position", target_pos, flight_time * 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	shell_tween.tween_callback(func() -> void:
		shell.queue_free()
		if is_instance_valid(telegraph):
			telegraph.queue_free()
		# _impact_at() ist "static" und ruft NICHTS auf "self" auf - der
		# Moerser-Bot selbst kann zu diesem Zeitpunkt laengst tot und
		# freigegeben sein (siehe Kommentar am shell_tween oben), ein
		# gewoehnlicher Methodenaufruf wie "_impact(target_pos)" wuerde
		# implizit ueber "self" aufgeloest und dann mit einem Fehler
		# fehlschlagen.
		_impact_at(tree, target_pos, dmg, radius)
	)


static func _impact_at(tree: SceneTree, impact_pos: Vector3, dmg: float, radius: float) -> void:
	VFX.spawn(DUST_RING_SCENE, impact_pos)
	VFX.spawn(SPARK_YELLOW_SCENE, impact_pos + Vector3.UP)
	Juice.shake(1.4)

	var player: CharacterBody3D = tree.get_first_node_in_group(PartyManager.PLAYER_GROUP) as CharacterBody3D
	if player == null:
		return
	# Fixe Einschlagsposition, NICHT die aktuelle Spielerposition - siehe
	# Kopfkommentar. Nur horizontal gemessen: der Telegraph-Ring ist eine
	# flache Bodenflaeche, kein Kugelvolumen - ob man 3 m in der Luft ueber
	# dem Ring haengt, sollte am Treffer nichts aendern.
	var flat_player: Vector3 = player.global_position
	flat_player.y = impact_pos.y
	if flat_player.distance_to(impact_pos) > radius:
		return

	var target_health := player.find_child("Health", true, false) as Health
	if target_health != null and target_health.is_alive():
		# source = null statt "self": "self" ist hier eine statische Funktion
		# ohne Instanz, der Moerser-Bot, der das eigentlich abgefeuert hat,
		# kann zu diesem Zeitpunkt schon tot sein (siehe Kopfkommentar am
		# Aufrufer). take_damage() behandelt source ohnehin nur als
		# optionale Info fuer last_damage_source.
		target_health.take_damage(dmg, null)
	if player.has_method("apply_knockback"):
		var away: Vector3 = player.global_position - impact_pos
		away.y = 0.0
		if away.length_squared() < 0.01:
			away = Vector3.FORWARD
		player.apply_knockback(away.normalized() * 10.0 + Vector3.UP * 4.0)


## Maschinen-Tod statt des generischen Wegschrumpfens aus custom_enemy_base.gd
## - der Moerser-Bot ist ein Geraet, keine organische Einheit, und zerspringt
## deshalb sichtbar in seine Bauteile.
func _teardown(with_hit_vfx: bool) -> void:
	if with_hit_vfx:
		_spawn_death_fragments()
	await super._teardown(with_hit_vfx)


## Fragmente haengen unter current_scene und ihre Tweens sind an SICH SELBST
## gebunden, nicht an den Moerser-Bot - sonst wuerden sie beim queue_free()
## des Bots (siehe custom_enemy_base.gd::_teardown()) sofort eingefroren,
## exakt derselbe Fehler wie vorher bei den Geschossen in _fire_at().
func _spawn_death_fragments() -> void:
	var tree: SceneTree = get_tree()
	var origin: Vector3 = global_position + Vector3.UP * VISUAL_SCALE
	var colors: Array[Color] = [Color(0.16, 0.15, 0.18), Color(0.85, 0.25, 0.15)]

	for i: int in range(6):
		var frag := MeshInstance3D.new()
		var box := BoxMesh.new()
		var size: float = randf_range(0.3, 0.6) * VISUAL_SCALE
		box.size = Vector3(size, size * randf_range(0.6, 1.0), size)
		frag.mesh = box
		var mat := _make_unshaded_material(colors[i % colors.size()], 0.4)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		frag.material_override = mat
		tree.current_scene.add_child(frag)
		frag.global_position = origin
		frag.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)

		var angle: float = randf() * TAU
		var horiz: float = randf_range(1.5, 3.5) * VISUAL_SCALE
		var target: Vector3 = origin + Vector3(cos(angle) * horiz, randf_range(0.5, 2.0), sin(angle) * horiz)
		var spin: Vector3 = frag.rotation + Vector3(
			randf_range(2.0, 6.0), randf_range(2.0, 6.0), randf_range(2.0, 6.0)
		)

		var tween: Tween = frag.create_tween()
		tween.set_parallel(true)
		tween.tween_property(frag, "global_position", target, FRAGMENT_LIFETIME) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(frag, "rotation", spin, FRAGMENT_LIFETIME)
		tween.tween_property(mat, "albedo_color:a", 0.0, FRAGMENT_LIFETIME * 0.5) \
			.set_delay(FRAGMENT_LIFETIME * 0.5)
		tween.tween_callback(frag.queue_free).set_delay(FRAGMENT_LIFETIME)
