extends Node3D
class_name Torch

# ============================================================================
# Torch — flackernde Wandfackel/Brazier fuer Raum-Atmosphaere.
# ============================================================================
# Baut sich komplett per Code auf (gleiches Prinzip wie turret.gd/lemonade.gd):
# ein OmniLight3D mit Flacker-Animation - zwei ueberlagerte Sinuskurven mit
# unpassenden Frequenzen, dieselbe Technik wie
# spawn_tutorial_hologram.gd:_apply_alpha() und aus demselben Grund: eine
# einzelne Welle liest sich als gleichmaessiges Pulsieren, nicht als
# instabile Flamme - plus eine kleine Dauerflamme aus GPUParticles3D.
#
# Additiv zum globalen Nebel/Ambient aus dungeon_atmosphere.gd - ersetzt es
# nicht, es gibt sonst keine einzelne platzierte Lichtquelle im Projekt.

@export var light_color: Color = Color(1.0, 0.55, 0.15)
@export var light_energy: float = 1.4
@export var light_range: float = 9.0
@export_range(0.0, 1.0) var flicker_amount: float = 0.35
@export var flicker_speed: float = 11.0
@export var flame_height: float = 0.9

var _light: OmniLight3D = null
var _flame: GPUParticles3D = null
var _time: float = 0.0


func _ready() -> void:
	# Zufaelliger Phasenversatz, damit mehrere Fackeln im selben Raum nicht
	# synchron flackern.
	_time = randf() * 100.0
	_build_light()
	_build_flame()


func _build_light() -> void:
	_light = OmniLight3D.new()
	_light.name = "Light"
	_light.light_color = light_color
	_light.light_energy = light_energy
	_light.omni_range = light_range
	_light.shadow_enabled = false
	_light.position = Vector3(0.0, flame_height, 0.0)
	add_child(_light)


func _build_flame() -> void:
	var process_mat := ParticleProcessMaterial.new()
	process_mat.direction = Vector3(0.0, 1.0, 0.0)
	process_mat.spread = 12.0
	process_mat.initial_velocity_min = 0.4
	process_mat.initial_velocity_max = 0.9
	process_mat.gravity = Vector3(0.0, 1.2, 0.0)
	process_mat.scale_min = 0.35
	process_mat.scale_max = 0.7
	process_mat.color = light_color

	var quad_mat := StandardMaterial3D.new()
	quad_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# BILLBOARD_ENABLED statt _PARTICLES: eine Flamme soll immer zur Kamera
	# zeigen, nicht sich an ihrer eigenen Flugrichtung ausrichten - gleicher
	# Grund/Fix wie bei bleed_vfx.tscn.
	quad_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad_mat.albedo_color = light_color
	quad_mat.emission_enabled = true
	quad_mat.emission = light_color
	quad_mat.emission_energy_multiplier = 2.0

	var quad := QuadMesh.new()
	quad.size = Vector2(0.28, 0.28)
	quad.material = quad_mat

	_flame = GPUParticles3D.new()
	_flame.name = "Flame"
	_flame.emitting = true
	_flame.amount = 8
	_flame.lifetime = 0.5
	_flame.randomness = 0.4
	_flame.fixed_fps = 30
	_flame.process_material = process_mat
	_flame.draw_pass_1 = quad
	_flame.position = Vector3(0.0, flame_height * 0.4, 0.0)
	add_child(_flame)


func _process(delta: float) -> void:
	_time += delta
	if _light == null:
		return
	var noise: float = sin(_time * flicker_speed) * 0.6 + sin(_time * flicker_speed * 2.7) * 0.4
	var factor: float = 1.0 - flicker_amount * (noise * 0.5 + 0.5)
	_light.light_energy = light_energy * factor
