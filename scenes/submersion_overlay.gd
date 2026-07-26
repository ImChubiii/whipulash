extends ColorRect
class_name SubmersionOverlay

@export var fade_duration: float = 0.3

var _tween: Tween

func _ready() -> void:
	color = Color(1.0, 1.0, 1.0, 0.0)  # startet unsichtbar
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # blockiert keine Klicks

## BUGFIX "Overlay taucht in den generierten Levels nie auf":
##
## show_submersion() hat bisher NUR die Farbe getweent. In level_01.tscn
## faellt das nicht auf, weil der Node dort sichtbar in der Szene liegt -
## in level_generation_test.tscn steht aber visible = false. Ein
## unsichtbarer ColorRect bleibt unsichtbar, egal wie oft man sein Alpha
## hochzieht.
##
## Die Sichtbarkeit wird deshalb hier mitgeschaltet statt sie der
## jeweiligen Szene zu ueberlassen: beim Einblenden sofort an, beim
## Ausblenden erst NACH dem Fade wieder aus (sonst waere der Node schon
## weg, bevor man das Ausblenden sieht).
func show_submersion(tint: Color, target_alpha: float = 0.35) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	# Alpha auf 0 ziehen, BEVOR der Node sichtbar wird - sonst blitzt beim
	# ersten Mal kurz die Editor-Farbe des ColorRect auf.
	if not visible:
		color = Color(tint.r, tint.g, tint.b, 0.0)
		visible = true
	var target_color: Color = Color(tint.r, tint.g, tint.b, target_alpha)
	_tween = create_tween()
	_tween.tween_property(self, "color", target_color, fade_duration)

func hide_submersion() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	if not visible:
		return
	var target_color: Color = color
	target_color.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "color", target_color, fade_duration)
	_tween.tween_callback(func() -> void:
		visible = false
	)
