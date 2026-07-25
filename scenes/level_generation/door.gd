extends StaticBody3D
class_name Door

## Tür fährt beim Entriegeln senkrecht nach oben aus dem Türrahmen weg
## (klassischer Action-Spiel-Look, kein Dreh-Clipping mit der Wand).
##
## FIX: open_height wird jetzt AUTOMATISCH aus der tatsächlichen Höhe des
## Türblatts abgeleitet (0.0 = auto). Vorher stand hier ein fixer Wert von
## 3.5, der bei den alten 4.0 Units hohen Türen bereits zu klein war und
## bei den neuen 10.0 Units hohen Türen die Öffnung zu 65% blockiert hätte.

## 0.0 = automatisch (Türblatt-Höhe + open_clearance). Nur überschreiben,
## wenn eine Tür bewusst nur teilweise aufgehen soll.
@export var open_height: float = 0.0
## Zusätzlicher Sicherheitsabstand, damit die Unterkante wirklich über der
## Türöffnung verschwindet.
@export var open_clearance: float = 0.5
## Units pro Sekunde. Wird bei auto-open_height so skaliert, dass die Tür
## unabhängig von ihrer Größe immer ca. open_duration Sekunden braucht.
@export var move_speed: float = 0.0
@export var open_duration: float = 0.7

var _locked: bool = true
var _closed_y: float = 0.0
var _open_y: float = 0.0
var _effective_open_height: float = 0.0
var _effective_speed: float = 1.0

@onready var _collision: CollisionShape3D = get_node_or_null("CollisionShape3D")

func _ready() -> void:
	if _collision == null:
		push_error("Door (%s): Kein Kind namens 'CollisionShape3D' gefunden - Tür kann nicht blockieren." % get_path())
		set_process(false)
		return

	_effective_open_height = open_height
	if _effective_open_height <= 0.0:
		_effective_open_height = _measure_door_height() + open_clearance

	_effective_speed = move_speed
	if _effective_speed <= 0.0:
		_effective_speed = _effective_open_height / max(open_duration, 0.05)

	_closed_y = position.y
	_open_y = _closed_y + _effective_open_height
	_collision.disabled = not _locked
	set_process(true)

## Liest die Y-Ausdehnung aus der CollisionShape3D, damit die Tür sich
## garantiert komplett aus der Öffnung schiebt - egal wie groß das
## Room-Template ist.
func _measure_door_height() -> float:
	if _collision == null or _collision.shape == null:
		return 4.0
	var shape: Shape3D = _collision.shape
	var y_scale: float = _collision.global_transform.basis.y.length()
	if shape is BoxShape3D:
		return (shape as BoxShape3D).size.y * y_scale
	if shape is CapsuleShape3D:
		return (shape as CapsuleShape3D).height * y_scale
	if shape is CylinderShape3D:
		return (shape as CylinderShape3D).height * y_scale
	if shape is SphereShape3D:
		return (shape as SphereShape3D).radius * 2.0 * y_scale
	return 4.0

func set_locked(locked: bool) -> void:
	_locked = locked
	# Kollision SOFORT umschalten, nicht erst wenn die Bewegung fertig ist.
	# Beim Öffnen soll man direkt durchlaufen können, beim Schließen sofort
	# blockiert werden (sonst kann man sich durch die zufallende Tür mogeln).
	if _collision:
		_collision.disabled = not _locked

func is_locked() -> bool:
	return _locked

func _process(delta: float) -> void:
	var target_y: float = _closed_y if _locked else _open_y
	if is_equal_approx(position.y, target_y):
		return
	position.y = move_toward(position.y, target_y, _effective_speed * delta)
