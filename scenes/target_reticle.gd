extends Sprite3D
class_name TargetReticle

@export var height_offset: float = 3
@export var forward_offset: float = 3
@export var spin_speed: float = 2.0
@export var pulse_speed: float = 4.0
@export var pulse_amount: float = 0.1

var _target: Node3D = null
var _player: Node3D
var _base_scale: Vector3

func _ready() -> void:
	visible = false
	_base_scale = scale
	# Sprite3D übernimmt die Kamera-Ausrichtung selbst — keine manuelle
	# look_at()-Rechnung nötig, nur diese eine Property setzen.
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	# WICHTIG: ohne das wird der Ring vom Tiefenpuffer der (teils riesigen)
	# Gegner-Meshes verdeckt, besonders beim skalierten Tank — der Ring
	# soll IMMER oben drauf gerendert werden, egal was davor/dahinter steht.
	no_depth_test = true
	_player = get_tree().get_root().find_child("Player", true, false)
	if _player == null:
		push_warning("TargetReticle: Konnte keinen Node namens 'Player' finden.")
		return
	if _player.has_signal("target_changed"):
		_player.target_changed.connect(_on_target_changed)

func _on_target_changed(new_target: Node3D) -> void:
	_target = new_target
	visible = _target != null and is_instance_valid(_target)

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		if visible:
			visible = false
		return

	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	# Falls der Gegner eigene Offsets hat (z.B. größere Varianten wie
	# der Tank), die nehmen — sonst die Standardwerte vom Reticle selbst.
	var effective_height_offset: float = height_offset
	var custom_offset_h = _target.get("reticle_height_offset")
	if custom_offset_h != null:
		effective_height_offset = custom_offset_h

	var effective_forward_offset: float = forward_offset
	var custom_offset_f = _target.get("reticle_forward_offset")
	if custom_offset_f != null:
		effective_forward_offset = custom_offset_f

	# NEU: Größenskalierung des Rings selbst, passend zur Gegnergröße.
	# 1.0 = normale Reticle-Größe (Standard, falls der Gegner kein
	# reticle_scale-Feld hat oder es fehlt/null ist). Größere Gegner
	# (z.B. Tank) bekommen einen größeren Ring, kleine/schnelle Gegner
	# (z.B. Scout) einen kleineren.
	var effective_scale_multiplier: float = 1.0
	var custom_scale = _target.get("reticle_scale")
	if custom_scale != null:
		effective_scale_multiplier = custom_scale

	var to_camera: Vector3 = camera.global_position - _target.global_position
	to_camera.y = 0
	if to_camera.length() > 0.01:
		to_camera = to_camera.normalized()
	else:
		to_camera = Vector3.FORWARD

	global_position = _target.global_position + Vector3(0, effective_height_offset, 0) + to_camera * effective_forward_offset
	rotation.z += spin_speed * delta
	var pulse: float = 1.0 + sin(Time.get_ticks_msec() / 1000.0 * pulse_speed) * pulse_amount
	scale = _base_scale * pulse * effective_scale_multiplier
