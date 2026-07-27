extends Node3D
class_name HealthBar3D

@onready var fill: MeshInstance3D = $Fill
@onready var background: MeshInstance3D = $Background

var _fill_width: float = 1.0
var _health_node: Health

func _ready() -> void:
	# Breite des Fill-Quads merken, bevor wir sie skalieren
	if fill.mesh is QuadMesh:
		_fill_width = (fill.mesh as QuadMesh).size.x

	await get_tree().process_frame
	_connect_to_parent_health()

func _connect_to_parent_health() -> void:
	# Sucht die Health-Komponente im direkten Parent (dem Dummy/Gegner selbst)
	var parent := get_parent()
	var health_node := parent.find_child("Health", true, false)
	if health_node == null or not (health_node is Health):
		push_warning("HealthBar3D: Kein Health-Node im Parent gefunden.")
		return

	_health_node = health_node
	_health_node.health_changed.connect(_on_health_changed)
	_on_health_changed(_health_node.current_health, _health_node.max_health)

func _process(_delta: float) -> void:
	# Billboard-Effekt: Bar dreht sich immer zur aktiven Kamera
	var camera := get_viewport().get_camera_3d()
	if camera:
		look_at(camera.global_position, Vector3.UP)
		rotate_object_local(Vector3.UP, PI)  # Quad zeigt sonst mit der Rückseite zur Kamera

func _on_health_changed(current: float, max_hp: float) -> void:
	var percent: float = clamp(current / max_hp, 0.0, 1.0)
	fill.scale.x = percent
	# Fill von links her verankern statt mittig zu schrumpfen
	fill.position.x = -(1.0 - percent) * _fill_width * 0.5
