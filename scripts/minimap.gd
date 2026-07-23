extends Control

# Minimap oben links: orthogonale Kamera in einem SubViewport, die
# dem Player von oben folgt. Zonenname wird ueber Area3D-Nodes in der
# Gruppe "zone" ermittelt (siehe zone_marker.gd).

@onready var zone_label: Label = $Frame/ZoneLabel
@onready var sub_viewport: SubViewport = $Frame/MapContainer/SubViewportContainer/SubViewport
@onready var map_camera: Camera3D = $Frame/MapContainer/SubViewportContainer/SubViewport/MapCamera
@onready var coord_label: Label = $Frame/CoordLabel
@onready var player_arrow: TextureRect = $Frame/MapContainer/PlayerArrow

@export var map_height: float = 40.0
@export var map_size: float = 30.0
@export var rotate_with_player: bool = false
@export var default_zone_name: String = "UNKNOWN AREA"
@export var zone_check_interval: float = 0.25

var player: Node3D = null
var _current_zone: String = ""
var _zone_timer: float = 0.0

func _ready() -> void:
	map_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	map_camera.size = map_size
	map_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	# SubViewport muss die Welt des Hauptlevels rendern, sonst bleibt
	# die Karte schwarz.
	sub_viewport.own_world_3d = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_set_zone_text(default_zone_name)

func set_player(p: Node3D) -> void:
	player = p

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var pos: Vector3 = player.global_position
	map_camera.global_position = Vector3(pos.x, pos.y + map_height, pos.z)

	var model: Node3D = player.get_node_or_null("CharacterModel")

	if rotate_with_player:
		if model:
			map_camera.rotation.y = model.rotation.y
		player_arrow.rotation = 0.0
	else:
		map_camera.rotation.y = 0.0
		if model:
			# Karte bleibt nordorientiert, der Pfeil dreht sich
			player_arrow.rotation = -model.rotation.y

	coord_label.text = "X: %d   Y: %d" % [int(pos.x), int(pos.z)]

	# Zonen-Check gedrosselt, nicht jeden Frame
	_zone_timer -= delta
	if _zone_timer <= 0.0:
		_zone_timer = zone_check_interval
		_update_zone()

# Sucht die Area3D-Zonen, in denen der Player gerade steht.
func _update_zone() -> void:
	var zones: Array[Node] = get_tree().get_nodes_in_group("zone")
	var found: String = ""

	for z: Node in zones:
		if not (z is Area3D):
			continue
		var area: Area3D = z
		if area.overlaps_body(player):
			var zone_name: Variant = area.get("zone_name")
			if zone_name != null and str(zone_name) != "":
				found = str(zone_name)
				break

	if found == "":
		found = default_zone_name

	if found != _current_zone:
		_set_zone_text(found)

func _set_zone_text(text: String) -> void:
	_current_zone = text
	zone_label.text = text.to_upper()

	zone_label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(zone_label, "modulate:a", 1.0, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
