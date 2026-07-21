extends ColorRect
class_name SubmersionOverlay

@export var fade_duration: float = 0.3

var _tween: Tween

func _ready() -> void:
	color = Color(1.0, 1.0, 1.0, 0.0)  # startet unsichtbar
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # blockiert keine Klicks

func show_submersion(tint: Color, target_alpha: float = 0.35) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	var target_color: Color = Color(tint.r, tint.g, tint.b, target_alpha)
	_tween = create_tween()
	_tween.tween_property(self, "color", target_color, fade_duration)

func hide_submersion() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	var target_color: Color = color
	target_color.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "color", target_color, fade_duration)
