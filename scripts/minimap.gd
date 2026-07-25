extends Control

# Minimap oben links: orthogonale Kamera in einem SubViewport, die
# dem Player von oben folgt. Zonenname wird ueber Area3D-Nodes in der
# Gruppe "zone" ermittelt (siehe zone_marker.gd) - in prozedural
# generierten Leveln stattdessen ueber den LevelGenerator.
#
# NEU: Zusaetzlich zur 3D-Ansicht wird ein schematisches Raum-Grid
# (minimap_rooms.gd) eingeblendet, das Boss-/Treasure-Raeume und
# gecleartes Terrain markiert. Das Overlay wird hier zur Laufzeit erzeugt,
# damit hud.tscn nicht angefasst werden muss.

const ROOM_OVERLAY_SCRIPT := preload("res://scripts/minimap_rooms.gd")
const GENERATOR_GROUP := "level_generator"

@onready var zone_label: Label = $Frame/ZoneLabel
@onready var map_container: Control = $Frame/MapContainer
@onready var sub_viewport: SubViewport = $Frame/MapContainer/SubViewportContainer/SubViewport
@onready var map_camera: Camera3D = $Frame/MapContainer/SubViewportContainer/SubViewport/MapCamera
@onready var coord_label: Label = $Frame/CoordLabel
@onready var player_arrow: TextureRect = $Frame/MapContainer/PlayerArrow

@export var map_height: float = 60.0
## Sichtfeld der Minimap-Kamera in Weltunits. Bei 48x48-Raeumen zeigt 90.0
## den aktuellen Raum PLUS die angrenzenden Tueroeffnungen - man sieht
## also, wo es weitergeht, ohne die halbe Etage zu spoilern.
@export var map_size: float = 90.0
# Kalibrierungs-Korrektur: die gerenderte Karte war um 90 Grad verdreht.
# Godot-2D-Rotation ist positiv = im Uhrzeigersinn, daher -90 fuer
# "90 Grad gegen den Uhrzeigersinn". Wird als reine Bildschirmraum-Drehung
# auf MapContainer angewendet.
@export var map_calibration_offset_degrees: float = -90.0
# Editor-Fallback, falls SettingsManager (Autoload) mal nicht verfuegbar ist.
@export var rotate_with_player: bool = false
@export var default_zone_name: String = "UNKNOWN AREA"
@export var zone_check_interval: float = 0.25

## --- Raum-Overlay ---------------------------------------------------
@export var show_room_overlay: bool = true
## Groesse des schematischen Grids in Pixeln (quadratisch).
@export var room_overlay_size: float = 118.0
## Abstand zur unteren rechten Ecke des Kartenbereichs.
@export var room_overlay_margin: float = 6.0

var player: Node3D = null
var _current_zone: String = ""
var _zone_timer: float = 0.0
var _room_overlay: Control = null
var _generator: Node = null

func _ready() -> void:
	map_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	map_camera.size = map_size
	map_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	# Damit bei den hohen Boss-Arenen (24 Units) nichts weggeclippt wird.
	map_camera.near = 0.1
	map_camera.far = map_height * 2.0

	# SubViewport muss die Welt des Hauptlevels rendern, sonst bleibt
	# die Karte schwarz.
	sub_viewport.own_world_3d = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_set_zone_text(default_zone_name)

	# Kalibrierungs-Drehung: um die Mitte drehen statt um die obere linke
	# Ecke (Control-Standard-Pivot), sonst verschiebt sich das Bild.
	map_container.pivot_offset = map_container.size * 0.5
	map_container.rotation_degrees = map_calibration_offset_degrees

	if show_room_overlay:
		_create_room_overlay()

	# Setting "Karte dreht sich mit Spieler" (General-Tab): Standard ist
	# AUS -> Karte bleibt nordorientiert, nur der Spieler-Pfeil dreht sich.
	rotate_with_player = SettingsManager.minimap_rotate_with_player
	if not SettingsManager.minimap_rotate_with_player_changed.is_connected(_on_rotate_setting_changed):
		SettingsManager.minimap_rotate_with_player_changed.connect(_on_rotate_setting_changed)

## Das Overlay haengt bewusst unter "Frame" und NICHT unter "MapContainer":
## MapContainer traegt die Kalibrierungs-Drehung von -90 Grad, die ein Kind
## erben wuerde - das Grid stuende dann schief.
func _create_room_overlay() -> void:
	var frame: Control = $Frame
	_room_overlay = Control.new()
	_room_overlay.name = "RoomOverlay"
	_room_overlay.set_script(ROOM_OVERLAY_SCRIPT)
	_room_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(_room_overlay)

	var s := room_overlay_size
	_room_overlay.size = Vector2(s, s)
	_room_overlay.position = Vector2(
		map_container.position.x + map_container.size.x - s - room_overlay_margin,
		map_container.position.y + map_container.size.y - s - room_overlay_margin
	)

func _on_rotate_setting_changed(enabled: bool) -> void:
	rotate_with_player = enabled

func set_player(p: Node3D) -> void:
	player = p

func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var pos: Vector3 = player.global_position
	map_camera.global_position = Vector3(pos.x, pos.y + map_height, pos.z)

	var model: Node3D = player.get_node_or_null("CharacterModel")

	if rotate_with_player:
		# WICHTIG: hier muss die KAMERA-Blickrichtung rein, nicht die
		# Blickrichtung des Charakter-Modells - die beiden koennen
		# auseinanderlaufen (z.B. waehrend Target-Lock dreht sich das Modell
		# zum anvisierten Gegner, waehrend die Kamera woanders hinschaut).
		var camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
		if camera_pivot:
			map_camera.rotation.y = camera_pivot.rotation.y
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

## Zonenname: in generierten Leveln aus dem aktuellen Raumtyp, sonst wie
## bisher ueber die Area3D-Zonen in der Gruppe "zone".
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
	var tween := create_tween()
	tween.tween_property(zone_label, "modulate:a", 1.0, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
