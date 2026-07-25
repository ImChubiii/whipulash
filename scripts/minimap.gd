extends Control

## Minimap oben links.
##
## - Das schematische Raum-Grid (RoomOverlay, minimap_rooms.gd) rotiert
##   seine Zellen-POSITIONEN intern um -90 Grad, damit es zur kalibrierten
##   3D-Minimap passt - Text/Glyphen bleiben dabei aufrecht. Hier wird das
##   Overlay nur noch positioniert/skaliert, NICHT mehr zusaetzlich als
##   Control gedreht.
## - "toggle_map"-Action (Taste M im Input Map einzutragen) blendet eine
##   grosse Ansicht ein: 3D-Karte und Raum-Grid NEBENEINANDER, beide auf
##   dieselbe Kantenlaenge gebracht.
## - ESCAPE: liegt in der Gruppe "minimap", damit pause_menu.gd die
##   Grosskarte per is_big_map_open()/close_big_map() zuerst schliessen
##   kann, BEVOR ein zweiter ESC-Druck die Pause oeffnet.
## - Der Spieler-Pfeil orientiert sich an der Kamera-Blickrichtung, nicht
##   am Charaktermodell.
## - Die 3D-Minimap-Kamera bekommt ein EIGENES Environment ohne Nebel und
##   mit vollem Umgebungslicht: sub_viewport.own_world_3d = false teilt
##   sich das World3D (und damit die WorldEnvironment) mit der Hauptszene.
##   Der duestere Dungel-Fog (dungeon_atmosphere.gd) wuerde die Draufsicht
##   sonst mitverdunkeln - eine Minimap soll aber immer gut lesbar bleiben.

const ROOM_OVERLAY_SCRIPT := preload("res://scripts/minimap_rooms.gd")
const GENERATOR_GROUP := "level_generator"
const TOGGLE_ACTION := "toggle_map"
const MINIMAP_GROUP := "minimap"

enum OverlayPlacement { BELOW_MAP, INSIDE_MAP, HIDDEN }

@onready var frame: Panel = $Frame
@onready var zone_label: Label = $Frame/ZoneLabel
@onready var map_container: Control = $Frame/MapContainer
@onready var sub_viewport: SubViewport = $Frame/MapContainer/SubViewportContainer/SubViewport
@onready var map_camera: Camera3D = $Frame/MapContainer/SubViewportContainer/SubViewport/MapCamera
@onready var coord_label: Label = $Frame/CoordLabel
@onready var player_arrow: TextureRect = $Frame/MapContainer/PlayerArrow

@export var map_height: float = 60.0
@export var map_size: float = 90.0
@export var map_calibration_offset_degrees: float = -90.0
@export var rotate_with_player: bool = false
@export var default_zone_name: String = "UNKNOWN AREA"
@export var zone_check_interval: float = 0.25

## --- Raum-Overlay ---------------------------------------------------
@export var overlay_placement: OverlayPlacement = OverlayPlacement.BELOW_MAP
@export var room_overlay_size: float = 118.0
@export var room_overlay_margin: float = 8.0
@export var coord_label_reserve: float = 30.0

## --- Grosse Karte (Nebeneinander-Layout) ------------------------------
@export var big_map_world_size: float = 220.0
@export var big_map_box_size: float = 320.0
@export var big_map_gap: float = 28.0
@export var big_map_padding: float = 20.0
@export var big_map_header_reserve: float = 34.0
@export var big_map_tween_duration: float = 0.18

## --- Minimap-Beleuchtung ----------------------------------------------
## Verhindert, dass Fog/Ambient-Abdunklung der Hauptszene (siehe
## dungeon_atmosphere.gd) auch die Draufsicht mit verdunkelt.
@export var minimap_disable_fog: bool = true
@export var minimap_ambient_color: Color = Color(1.0, 1.0, 1.0)
@export var minimap_ambient_energy: float = 1.3
@export var minimap_background_color: Color = Color(0.05, 0.05, 0.06)

var player: Node3D = null
var _current_zone: String = ""
var _zone_timer: float = 0.0
var _room_overlay: Control = null
var _generator: Node = null

var _is_big_map: bool = false
var _tween: Tween = null

var _small_frame_size: Vector2
var _small_frame_position: Vector2
var _small_map_container_size: Vector2
var _small_map_container_position: Vector2
var _small_map_camera_size: float
var _small_overlay_size: Vector2
var _small_overlay_position: Vector2


func _ready() -> void:
	add_to_group(MINIMAP_GROUP)

	map_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	map_camera.size = map_size
	map_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	map_camera.near = 0.1
	map_camera.far = map_height * 2.0

	sub_viewport.own_world_3d = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_set_zone_text(default_zone_name)

	if minimap_disable_fog:
		_apply_minimap_environment()

	map_container.pivot_offset = map_container.size * 0.5
	map_container.rotation_degrees = map_calibration_offset_degrees

	if overlay_placement != OverlayPlacement.HIDDEN:
		_create_room_overlay()

	rotate_with_player = SettingsManager.minimap_rotate_with_player
	if not SettingsManager.minimap_rotate_with_player_changed.is_connected(_on_rotate_setting_changed):
		SettingsManager.minimap_rotate_with_player_changed.connect(_on_rotate_setting_changed)

	_small_frame_size = frame.size
	_small_frame_position = frame.position
	_small_map_container_size = map_container.size
	_small_map_container_position = map_container.position
	_small_map_camera_size = map_size
	if _room_overlay:
		_small_overlay_size = _room_overlay.size
		_small_overlay_position = _room_overlay.position


## Camera3D.environment ueberschreibt fuer DIESE eine Kamera die
## WorldEnvironment der geteilten Welt - der Rest der Szene (inkl. der
## Haupt-Spielkamera) bleibt vom Dungeon-Nebel unberuehrt.
func _apply_minimap_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = minimap_background_color
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = minimap_ambient_color
	env.ambient_light_energy = minimap_ambient_energy
	env.fog_enabled = false
	env.glow_enabled = false
	map_camera.environment = env


func _create_room_overlay() -> void:
	_room_overlay = Control.new()
	_room_overlay.name = "RoomOverlay"
	_room_overlay.set_script(ROOM_OVERLAY_SCRIPT)
	_room_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(_room_overlay)

	var s: float = room_overlay_size
	_room_overlay.size = Vector2(s, s)

	if overlay_placement == OverlayPlacement.INSIDE_MAP:
		_room_overlay.position = Vector2(
			map_container.position.x + map_container.size.x - s - room_overlay_margin,
			map_container.position.y + map_container.size.y - s - room_overlay_margin
		)
		return

	var overlay_top: float = map_container.position.y + map_container.size.y + room_overlay_margin
	var overlay_x: float = map_container.position.x + (map_container.size.x - s) * 0.5
	_room_overlay.position = Vector2(overlay_x, overlay_top)

	var needed_height: float = overlay_top + s + coord_label_reserve
	if frame.size.y < needed_height:
		frame.size.y = needed_height

	var needed_outer: float = frame.position.y + frame.size.y + frame.position.y
	if size.y < needed_outer:
		size.y = needed_outer
		offset_bottom = needed_outer


func _on_rotate_setting_changed(enabled: bool) -> void:
	rotate_with_player = enabled


func set_player(p: Node3D) -> void:
	player = p


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(TOGGLE_ACTION):
		_set_big_map(not _is_big_map)
		get_viewport().set_input_as_handled()


## --- Oeffentliche API fuer pause_menu.gd ------------------------------
## ESC soll ZUERST nur die Grosskarte schliessen und erst beim NAECHSTEN
## Druck die Pause oeffnen. pause_menu.gd fragt das hier ab, statt dass
## Minimap sich selbst um ESC kuemmert - so gibt es nur EINE Stelle, die
## ueber Pause entscheidet, keine Wettlaufsituation zwischen zwei
## _unhandled_input()-Listenern auf dieselbe Taste.
func is_big_map_open() -> bool:
	return _is_big_map


func close_big_map() -> void:
	if _is_big_map:
		_set_big_map(false)


func _set_big_map(active: bool) -> void:
	if active == _is_big_map:
		return
	_is_big_map = active

	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if _is_big_map:
		_enter_big_map()
	else:
		_exit_big_map()


func _enter_big_map() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	var box: float = big_map_box_size
	var content_width: float = box + big_map_gap + box

	var target_frame_size := Vector2(
		content_width + big_map_padding * 2.0,
		big_map_header_reserve + box + big_map_padding + coord_label_reserve
	)
	var target_frame_position: Vector2 = (viewport_size - target_frame_size) * 0.5

	_tween.tween_property(frame, "size", target_frame_size, big_map_tween_duration)
	_tween.tween_property(frame, "position", target_frame_position, big_map_tween_duration)

	var map_target_pos := Vector2(big_map_padding, big_map_header_reserve)
	var overlay_target_pos := Vector2(big_map_padding + box + big_map_gap, big_map_header_reserve)

	_tween.tween_property(map_container, "size", Vector2(box, box), big_map_tween_duration)
	_tween.tween_property(map_container, "position", map_target_pos, big_map_tween_duration)
	_tween.tween_method(_update_map_container_pivot, 0.0, 1.0, big_map_tween_duration)

	map_camera.size = big_map_world_size

	if _room_overlay:
		_tween.tween_property(_room_overlay, "size", Vector2(box, box), big_map_tween_duration)
		_tween.tween_property(_room_overlay, "position", overlay_target_pos, big_map_tween_duration)


func _exit_big_map() -> void:
	_tween.tween_property(frame, "size", _small_frame_size, big_map_tween_duration)
	_tween.tween_property(frame, "position", _small_frame_position, big_map_tween_duration)

	_tween.tween_property(map_container, "size", _small_map_container_size, big_map_tween_duration)
	_tween.tween_property(map_container, "position", _small_map_container_position, big_map_tween_duration)
	_tween.tween_method(_update_map_container_pivot, 0.0, 1.0, big_map_tween_duration)

	map_camera.size = _small_map_camera_size

	if _room_overlay:
		_tween.tween_property(_room_overlay, "size", _small_overlay_size, big_map_tween_duration)
		_tween.tween_property(_room_overlay, "position", _small_overlay_position, big_map_tween_duration)


## map_container ist um map_calibration_offset_degrees um seine EIGENE
## Mitte gedreht - beim Groessenwechsel muss der Pivot mitwandern, sonst
## verschiebt sich die 3D-Ansicht seitlich aus ihrer Box waehrend des Tweens.
func _update_map_container_pivot(_t: float) -> void:
	map_container.pivot_offset = map_container.size * 0.5


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var pos: Vector3 = player.global_position
	map_camera.global_position = Vector3(pos.x, pos.y + map_height, pos.z)

	var camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
	var camera_yaw: float = camera_pivot.rotation.y if camera_pivot else 0.0

	if rotate_with_player:
		map_camera.rotation.y = camera_yaw
		player_arrow.rotation = 0.0
	else:
		map_camera.rotation.y = 0.0
		player_arrow.rotation = -camera_yaw

	coord_label.text = "X: %d   Y: %d" % [int(pos.x), int(pos.z)]

	_zone_timer -= delta
	if _zone_timer <= 0.0:
		_zone_timer = zone_check_interval
		_update_zone()


func _update_zone() -> void:
	var from_generator: String = _zone_from_generator()
	if from_generator != "":
		if from_generator != _current_zone:
			_set_zone_text(from_generator)
		return

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


func _zone_from_generator() -> String:
	if _generator == null or not is_instance_valid(_generator):
		var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
		if found.is_empty():
			return ""
		_generator = found[0]

	if not _generator.has_method("get_map_cells"):
		return ""

	var cells: Dictionary = _generator.get_map_cells()
	var current: Vector2i = _generator.get_current_room()
	if not cells.has(current):
		return ""

	var type: int = int(cells[current].get("type", 0))
	var label: String = _generator.get_room_type_name(type)
	var stage: int = _generator.get_current_stage()
	return "ETAGE %d - %s" % [stage, label]


func _set_zone_text(text: String) -> void:
	_current_zone = text
	zone_label.text = text.to_upper()

	zone_label.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(zone_label, "modulate:a", 1.0, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
