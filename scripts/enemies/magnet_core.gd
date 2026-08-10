extends CustomEnemyBase
class_name MagnetCore

# ============================================================================
# Magnet-Kern — stationaerer Gegner. Schiesst nicht, zieht stattdessen den
# Spieler und freiliegende Drops kontinuierlich zu sich heran. Kommt der
# Spieler zu nah, stoesst der Kern eine Schockwelle mit massivem Knockback
# aus - der Kern bestraft also sowohl "zu weit weg treiben lassen" (Sog)
# als auch "reinrennen und draufkloppen" (Schockwelle).
# ============================================================================
# BUGFIX "Sog spuerbar/sichtbar zu schwach": player_base.gd faengt jeden
# apply_knockback()-Impuls in einem Puffer ab, der pro Sekunde um
# knockback_friction (Standard 10.0) abgebaut wird (siehe dortiger
# Kopfkommentar zum behobenen "Magnet-Gefuehl"-Bug). Ein Dauer-Impuls von
# ~9 EINHEITEN * delta PRO FRAME lag praktisch im Rauschen der Reibung -
# netto blieb kaum spuerbare Geschwindigkeit uebrig. Jetzt wird stattdessen
# alle PULL_TICK_INTERVAL Sekunden EIN kraeftiger Einzelimpuls verpasst
# (PULL_IMPULSE_STRENGTH, deutlich ueber der Reibung) - UND exakt im selben
# Rhythmus eine nach innen laufende Ring-Welle gespawnt, damit sichtbarer
# Effekt und tatsaechlicher Zug immer im selben Moment passieren.

const DUST_RING_SCENE: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const PULL_WAVE_COLOR: Color = Color(0.6, 0.3, 1.0)
const PULL_TICK_INTERVAL: float = 0.35
const PULL_IMPULSE_STRENGTH: float = 16.0

## 5x die urspruengliche Modellgroesse (Bau-Basiswerte unten sind bereits
## mit VISUAL_SCALE multipliziert, statt an jeder einzelnen Mesh-Zahl von
## Hand herumzurechnen).
const VISUAL_SCALE: float = 5.0

var pull_radius: float = 20.0
var too_close_radius: float = 7.0
var shockwave_force: float = 30.0
var shockwave_cooldown_time: float = 1.6
var pickup_pull_speed: float = 7.0

var _shockwave_cooldown: float = 0.0
var _pull_tick_timer: float = 0.0
var _spin: float = 0.0
var _core_visual: MeshInstance3D = null


func _configure() -> void:
	display_name = "Magnet-Kern"
	max_health = 160.0


func _build() -> void:
	_build_visual()
	_add_box_collision(Vector3(1.8, 2.0, 1.8) * VISUAL_SCALE, Vector3(0.0, 1.0, 0.0) * VISUAL_SCALE)
	_pull_tick_timer = PULL_TICK_INTERVAL * randf()


func _build_visual() -> void:
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 1.0 * VISUAL_SCALE
	base_mesh.bottom_radius = 1.2 * VISUAL_SCALE
	base_mesh.height = 0.6 * VISUAL_SCALE
	var base_visual := MeshInstance3D.new()
	base_visual.mesh = base_mesh
	base_visual.material_override = _make_unshaded_material(Color(0.2, 0.18, 0.24))
	base_visual.position = Vector3(0.0, 0.3, 0.0) * VISUAL_SCALE
	visual_root.add_child(base_visual)

	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.85 * VISUAL_SCALE
	core_mesh.height = 1.7 * VISUAL_SCALE
	_core_visual = MeshInstance3D.new()
	_core_visual.mesh = core_mesh
	_core_visual.material_override = _make_unshaded_material(Color(0.6, 0.3, 1.0), 2.2)
	_core_visual.position = Vector3(0.0, 1.6, 0.0) * VISUAL_SCALE
	visual_root.add_child(_core_visual)

	var light := OmniLight3D.new()
	light.light_color = Color(0.6, 0.3, 1.0)
	light.light_energy = 2.2
	light.omni_range = pull_radius * 0.8
	light.shadow_enabled = false
	light.position = Vector3(0.0, 1.6, 0.0) * VISUAL_SCALE
	visual_root.add_child(light)


func _physics_process(delta: float) -> void:
	_spin += delta
	if _core_visual != null:
		_core_visual.rotation.y = _spin * 1.4
		_core_visual.scale = Vector3.ONE * (1.0 + sin(_spin * 3.0) * 0.06)

	_shockwave_cooldown = maxf(_shockwave_cooldown - delta, 0.0)

	_pull_tick_timer -= delta
	if _pull_tick_timer <= 0.0:
		_pull_tick_timer = PULL_TICK_INTERVAL
		_pull_tick()

	_pull_pickups(delta)


func _pull_tick() -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return

	var to_core: Vector3 = global_position - player.global_position
	to_core.y = 0.0
	var distance: float = to_core.length()
	if distance > pull_radius or distance < 0.01:
		return

	if distance <= too_close_radius:
		_trigger_shockwave(player)
		return

	# Sog waechst zur Mitte hin - am Rand des Radius kaum spuerbar, direkt
	# vor der Schockwellen-Zone am staerksten.
	var pull_factor: float = 1.0 - clampf((distance - too_close_radius) / maxf(pull_radius - too_close_radius, 0.01), 0.0, 1.0)

	if player.has_method("apply_knockback"):
		player.apply_knockback(to_core.normalized() * PULL_IMPULSE_STRENGTH * maxf(pull_factor, 0.25))

	# Ring startet am Spielerabstand und laeuft waehrend PULL_TICK_INTERVAL
	# bis zum Kern - visuell exakt derselbe Rhythmus wie der Impuls oben.
	_spawn_pull_wave(distance)


func _spawn_pull_wave(start_radius: float) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(start_radius - 0.3, 0.2)
	torus.outer_radius = start_radius
	ring.mesh = torus
	var mat := _make_unshaded_material(PULL_WAVE_COLOR, 1.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.7
	ring.material_override = mat

	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position + Vector3.UP * 0.1
	ring.scale = Vector3.ONE

	var tween: Tween = ring.create_tween()
	tween.set_parallel(true)
	# Von Aussenradius (Spielerabstand) auf ~0 - der Ring wandert sichtbar
	# ZUM Magneten hin, statt von ihm weg (Sog, kein Abstossen).
	tween.tween_property(ring, "scale", Vector3(0.05, 1.0, 0.05), PULL_TICK_INTERVAL) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(mat, "albedo_color:a", 0.0, PULL_TICK_INTERVAL)
	tween.chain().tween_callback(ring.queue_free)


func _trigger_shockwave(player: CharacterBody3D) -> void:
	if _shockwave_cooldown > 0.0:
		return
	_shockwave_cooldown = shockwave_cooldown_time

	VFX.spawn(DUST_RING_SCENE, global_position)
	Juice.shake(1.8)

	if not player.has_method("apply_knockback"):
		return
	var away: Vector3 = player.global_position - global_position
	away.y = 0.0
	if away.length_squared() < 0.01:
		away = Vector3.FORWARD
	player.apply_knockback(away.normalized() * shockwave_force + Vector3.UP * 6.0)


func _pull_pickups(delta: float) -> void:
	for node: Node in get_tree().get_nodes_in_group(Pickup.PICKUP_GROUP):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var pickup := node as Node3D
		var distance: float = pickup.global_position.distance_to(global_position)
		if distance > pull_radius or distance < 0.6:
			continue
		pickup.global_position = pickup.global_position.move_toward(global_position, pickup_pull_speed * delta)
