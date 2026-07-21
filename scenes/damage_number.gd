extends Label3D
class_name DamageNumber

@export var rise_distance: float = 2.5
@export var horizontal_drift: float = 0.9  # max. seitliche Abweichung
@export var duration: float = 1.5
@export var normal_color: Color = Color(0.0, 0.918, 0.882, 1.0)
@export var crit_color: Color = Color(1.0, 0.349, 0.102, 0.855)
@export var outline_color: Color = Color(0.0, 0.773, 0.933, 1.0)
@export var horizontal_stretch: float = 3  # >1.0 = breiter, <1.0 = schmaler

func _ready() -> void:
	# Sinnvolle Defaults direkt im Code, damit man im Editor nichts
	# vergessen kann — Billboard sorgt dafür, dass die Zahl immer zur
	# Kamera zeigt. no_depth_test verhindert, dass die Zahl hinter/in
	# Gegnern verschwindet (die dank depth_draw_always im PSX-Shader
	# immer noch "solide" im Tiefenpuffer sind, auch wenn sie optisch
	# transparent aussehen).
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	outline_size = 0
	font_size = 128
	scale.x = horizontal_stretch
	outline_modulate = outline_color

func show_damage(amount: float, is_crit: bool = false) -> void:
	text = str(int(round(amount)))
	modulate = crit_color if is_crit else normal_color
	outline_modulate = outline_color

	# Jede Zahl bekommt ihre EIGENE zufällige Richtung — sowohl seitlich
	# (X/Z) als auch wie stark sie nach oben steigt. randf_range() liefert
	# bei jedem Aufruf einen neuen Zufallswert, daher ist jede Instanz anders.
	var random_offset := Vector3(
		randf_range(-horizontal_drift, horizontal_drift),
		rise_distance * randf_range(0.8, 1.3),
		randf_range(-horizontal_drift, horizontal_drift)
	)
	var target_position: Vector3 = position + random_offset

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", target_position, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# WICHTIG: modulate UND outline_modulate müssen beide gefadet werden —
	# sind zwei komplett separate Color-Properties in Label3D. Ohne diese
	# zweite Zeile bleibt die Outline stehen, während der Rest verblasst.
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_property(self, "outline_modulate:a", 0.0, duration)
	tween.chain().tween_callback(queue_free)
