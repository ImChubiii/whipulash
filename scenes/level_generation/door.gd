extends StaticBody3D
class_name Door

## Tür fährt beim Entriegeln senkrecht nach oben aus dem Türrahmen weg
## (klassischer Action-Spiel-Look, kein Dreh-Clipping mit der Wand).
@export var open_height: float = 3.5
@export var move_speed: float = 6.0

var _locked: bool = true
var _closed_y: float = 0.0
var _open_y: float = 0.0

@onready var _collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	_closed_y = position.y
	_open_y = _closed_y + open_height
	_collision.disabled = not _locked
	set_process(true)

func set_locked(locked: bool) -> void:
	_locked = locked

func _process(delta: float) -> void:
	var target_y: float = _closed_y if _locked else _open_y
	if is_equal_approx(position.y, target_y):
		_collision.disabled = not _locked
		return
	position.y = move_toward(position.y, target_y, move_speed * delta)
	_collision.disabled = not _locked
