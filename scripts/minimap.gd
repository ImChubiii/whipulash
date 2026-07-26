extends Control
class_name Minimap

## Minimap oben links.
##
## - Das schematische Raum-Grid (RoomOverlay, minimap_rooms.gd) rotiert
##   seine Zellen-POSITIONEN intern um -90 Grad, damit es zur kalibrierten
##   3D-Minimap passt - Text/Glyphen bleiben dabei aufrecht.
## - "toggle_map"-Action (Taste M im Input Map einzutragen) blendet eine
##   grosse Ansicht ein: 3D-Karte und Raum-Grid NEBENEINANDER.
## - ESCAPE: liegt in der Gruppe "minimap", damit pause_menu.gd die
##   Grosskarte per is_big_map_open()/close_big_map() zuerst schliessen
##   kann, BEVOR ein zweiter ESC-Druck die Pause oeffnet.
##
## GROSSKARTE — BEDIENUNG:
##   Solange die Grosskarte offen ist, wird die Maus freigegeben. Das
##   stoppt die Spielerkamera automatisch, weil player_base.gd sein
##   Mouse-Look an Input.mouse_mode == MOUSE_MODE_CAPTURED knuepft - es
##   braucht dafuer also KEINEN zusaetzlichen Schalter im Spieler.
##   Mausrad zoomt auf den Cursor, Ziehen verschiebt den Ausschnitt.
##
## DECKKRAFT:
##   Es gibt bewusst nur EINEN Regler. Frueher hatten Rahmen (StyleBox),
##   3D-Ansicht (Environment.BG_COLOR) und Raum-Grid (eigenes
##   color_background) je einen eigenen, unabhaengigen Alphawert - drei
##   Flaechen mit drei verschiedenen Deckkraeften uebereinander, was die
##   sichtbaren Kanten und den "Kasten im Kasten" erzeugt hat. Jetzt malt
##   nur noch der Frame eine Flaeche; 3D-Ansicht und Grid rendern
##   transparent darueber. Der Regler faerbt Hintergrund UND Rahmen, damit
##   bei niedriger Deckkraft nicht ein knallgelber Rand ueber einer fast
##   unsichtbaren Karte stehen bleibt.

const ROOM_OVERLAY_SCRIPT := preload("res://scripts/minimap_rooms.gd")
const GENERATOR_GROUP := "level_generator"
const TOGGLE_ACTION := "toggle_map"
const MINIMAP_GROUP := "minimap"

enum OverlayPlacement { BELOW_MAP, INSIDE_MAP, HIDDEN }

## Mausrad-Zoom der Grosskarte. Laufzeitwert, KEINE gespeicherte
## Einstellung: das ist eine Geste waehrend des Schauens, kein Setup-Wert.
const BIG_MAP_ZOOM_MIN: float = 0.35
const BIG_MAP_ZOOM_MAX: float = 4.0
const BIG_MAP_ZOOM_STEP: float = 1.15

## Statischer Schalter, damit combat_base.gd in seinem _process() mit
## EINEM Zugriff pruefen kann, ob die Grosskarte offen ist. Ueber
## get_nodes_in_group() waere das eine Baumsuche pro Frame; Angriffe
## werden per Input.is_action_pressed() gepollt und muessen deshalb
## wirklich jeden Frame fragen.
##
## WICHTIG: static var ueberlebt einen Szenenwechsel. Deshalb wird der
## Wert in _ready() UND _exit_tree() hart zurueckgesetzt - sonst bliebe
## das Flag nach einem Level-Neustart mit offener Karte auf true haengen
## und der Spieler koennte nie wieder angreifen.
static var big_map_open: bool = false

@onready var frame: Panel = $Frame
@onready var zone_label: Label = $Frame/ZoneLabel
@onready var map_container: Control = $Frame/MapContainer
@onready var sub_viewport_container: SubViewportContainer = $Frame/MapContainer/SubViewportContainer
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

## Falls die Transparenz auf einem Grafiktreiber Probleme macht: hier auf
## false stellen, dann rendert die Karte wieder mit fester Hintergrund-
## farbe (minimap_background_color) wie frueher.
@export var minimap_transparent_background: bool = true
@export var minimap_background_color: Color = Color(0.05, 0.05, 0.06)

var player: Node3D = null
var _current_zone: String = ""
var _zone_timer: float = 0.0
var _room_overlay: Control = null
var _generator: Node = null

var _is_big_map: bool = false
var _tween: Tween = null
var _big_map_zoom: float = 1.0
## Verschiebung des Kartenausschnitts gegenueber der Spielerposition
## (nur X/Z genutzt). Nur in der Grosskarte relevant.
var _big_map_pan: Vector3 = Vector3.ZERO
var _dragging: bool = false
## Weltpunkt, den der Cursor beim Drag-Start "gegriffen" hat. Beim Ziehen
## wird der Pan so nachgefuehrt, dass genau dieser Punkt unter dem Cursor
## bleibt - dadurch klebt die Karte am Mauszeiger, statt mit einem
## willkuerlichen Pixel-pro-Welt-Faktor zu driften.
var _drag_anchor_world: Vector3 = Vector3.ZERO
var _prev_mouse_mode: int = Input.MOUSE_MODE_CAPTURED

## Ausgangsfarben der Frame-StyleBox. Ohne diese Merker wuerde jedes
## Anwenden der Deckkraft auf dem bereits veraenderten Wert aufsetzen und
## die Farben waeren nach mehreren Aenderungen verschoben.
var _frame_base_bg_color: Color = Color(0.06, 0.06, 0.09, 0.82)
var _frame_base_border_color: Color = Color(0.5, 0.48, 0.18, 1.0)
var _frame_style: StyleBoxFlat = null

var _small_frame_size: Vector2
var _small_frame_position: Vector2
var _small_map_container_size: Vector2
var _small_map_container_position: Vector2
var _small_map_camera_size: float
var _small_overlay_size: Vector2
var _small_overlay_position: Vector2


func _ready() -> void:
	add_to_group(MINIMAP_GROUP)
	big_map_open = false

	map_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	map_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	map_camera.near = 0.1
	map_camera.far = map_height * 2.0

	sub_viewport.own_world_3d = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_viewport.transparent_bg = minimap_transparent_background

	_cache_frame_style()
	_set_zone_text(default_zone_name)

	if minimap_disable_fog:
		_apply_minimap_environment()

	map_container.pivot_offset = map_container.size * 0.5
	map_container.rotation_degrees = map_calibration_offset_degrees

	# Overlay-Platzierung kommt aus den Einstellungen. Der @export-Wert
	# bleibt als Editor-Vorgabe erhalten, wird hier aber ueberschrieben -
	# sonst gaebe es zwei konkurrierende Quellen fuer dieselbe Entscheidung.
	overlay_placement = SettingsManager.minimap_grid_placement as OverlayPlacement
	if overlay_placement != OverlayPlacement.HIDDEN:
		_create_room_overlay()

	# WICHTIG: Erst NACH _create_room_overlay() die Kleinansicht-Masse
	# sichern. Das Overlay veraendert dort ggf. die Frame-Hoehe - wuerde
	# man vorher sichern, springt die Minimap beim ersten Schliessen der
	# Grosskarte auf die falsche Groesse zurueck.
	_small_frame_size = frame.size
	_small_frame_position = frame.position
	_small_map_container_size = map_container.size
	_small_map_container_position = map_container.position
	_small_map_camera_size = map_size
	if _room_overlay:
		_small_overlay_size = _room_overlay.size
		_small_overlay_position = _room_overlay.position

	if not SettingsManager.minimap_setting_changed.is_connected(_apply_minimap_settings):
		SettingsManager.minimap_setting_changed.connect(_apply_minimap_settings)

	_apply_minimap_settings()


## static var ueberlebt Szenenwechsel - beim Verlassen zwingend loeschen,
## sonst bleibt das Combat-Gate nach einem Neustart mit offener Karte
## dauerhaft aktiv.
func _exit_tree() -> void:
	big_map_open = false


## Holt die StyleBox des Frames einmalig als eigene Kopie. duplicate() ist
## entscheidend: die StyleBoxFlat aus hud.tscn ist eine geteilte
## SubResource - ohne Kopie wuerde die Deckkraft auch den Speedrun-Timer-
## Rahmen mitveraendern, der dieselbe Ressource nutzt.
func _cache_frame_style() -> void:
	var existing := frame.get_theme_stylebox("panel")
	if existing is StyleBoxFlat:
		_frame_style = (existing as StyleBoxFlat).duplicate()
	else:
		_frame_style = StyleBoxFlat.new()
		_frame_style.border_width_left = 2
		_frame_style.border_width_top = 2
		_frame_style.border_width_right = 2
		_frame_style.border_width_bottom = 2
		_frame_style.border_color = Color(0.5, 0.48, 0.18, 1.0)
	_frame_base_bg_color = _frame_style.bg_color
	_frame_base_border_color = _frame_style.border_color
	frame.add_theme_stylebox_override("panel", _frame_style)


## Camera3D.environment ueberschreibt fuer DIESE eine Kamera die
## WorldEnvironment der geteilten Welt - der Rest der Szene (inkl. der
## Haupt-Spielkamera) bleibt vom Dungeon-Nebel unberuehrt.
##
## BG_CLEAR_COLOR statt BG_COLOR bei aktiver Transparenz: BG_COLOR malt
## IMMER eine deckende Flaeche und haette transparent_bg wirkungslos
## gemacht.
func _apply_minimap_environment() -> void:
	var env := Environment.new()
	if minimap_transparent_background:
		env.background_mode = Environment.BG_CLEAR_COLOR
	else:
		env.background_mode = Environment.BG_COLOR
		env.background_color = minimap_background_color
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = minimap_ambient_color
	env.ambient_light_energy = minimap_ambient_energy
	env.fog_enabled = false
	env.glow_enabled = false
	map_camera.environment = env


## Uebertraegt ALLE Minimap-Einstellungen auf die Nodes. Bewusst
## idempotent, damit ein doppelter Aufruf nichts kaputt macht.
func _apply_minimap_settings() -> void:
	rotate_with_player = SettingsManager.minimap_rotate_with_player

	# Skalierung am Wurzel-Control, Pivot oben links: die Minimap sitzt in
	# der linken oberen Ecke und soll beim Vergroessern nach innen wachsen,
	# nicht aus dem Bildschirm herauslaufen.
	pivot_offset = Vector2.ZERO
	scale = Vector2.ONE * SettingsManager.minimap_ui_scale

	# EIN Regler faerbt Flaeche UND Rahmen. Der Rahmen wird relativ zu
	# seiner Ausgangsdeckkraft skaliert, nicht hart gleichgesetzt - so
	# bleibt ein evtl. absichtlich halbtransparenter Rand im Verhaeltnis
	# erhalten.
	if _frame_style:
		var opacity: float = SettingsManager.minimap_opacity
		var bg: Color = _frame_base_bg_color
		bg.a = opacity
		_frame_style.bg_color = bg

		var border: Color = _frame_base_border_color
		border.a = _frame_base_border_color.a * opacity
		_frame_style.border_color = border

	# Kameragroesse haengt davon ab, in welchem Modus wir gerade sind -
	# sonst wuerde der Zoom-Regler bei offener Grosskarte die Kleinansicht
	# einstellen und der Effekt waere erst nach dem Schliessen sichtbar.
	map_camera.size = _effective_big_map_size() if _is_big_map else _effective_map_size()
	_small_map_camera_size = _effective_map_size()

	if player_arrow:
		player_arrow.visible = SettingsManager.minimap_show_player_arrow
	if coord_label:
		coord_label.visible = SettingsManager.minimap_show_coords
	if zone_label:
		zone_label.visible = SettingsManager.minimap_show_zone_label

	var placement: int = SettingsManager.minimap_grid_placement
	if _room_overlay and is_instance_valid(_room_overlay):
		_room_overlay.visible = placement != SettingsManager.MINIMAP_GRID_HIDDEN
	elif placement != SettingsManager.MINIMAP_GRID_HIDDEN:
		# Grid war beim Start ausgeschaltet und wurde jetzt eingeschaltet:
		# Overlay nachtraeglich erzeugen statt einen Neustart zu verlangen.
		overlay_placement = placement as OverlayPlacement
		_create_room_overlay()
		if _room_overlay:
			_small_overlay_size = _room_overlay.size
			_small_overlay_position = _room_overlay.position


## Zoom > 1 = naeher dran. Der Kamera-Ausschnitt ist der KEHRWERT des
## Zooms. maxf() verhindert eine Division, die bei einem manipulierten
## Zoom von 0 eine size von inf erzeugen wuerde.
func _effective_map_size() -> float:
	return map_size / maxf(SettingsManager.minimap_zoom, 0.01)


func _effective_big_map_size() -> float:
	return big_map_world_size / maxf(_big_map_zoom, 0.01)


func _create_room_overlay() -> void:
	if _room_overlay and is_instance_valid(_room_overlay):
		return

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


## Legacy-Handler: minimap_rotate_with_player_changed feuert weiterhin
## (andere Systeme koennen daran haengen). Die eigentliche Arbeit macht
## _apply_minimap_settings() ueber das Sammelsignal.
func _on_rotate_setting_changed(enabled: bool) -> void:
	rotate_with_player = enabled


func set_player(p: Node3D) -> void:
	player = p


# ============================================================================
# Eingabe
# ============================================================================

## _input() statt _unhandled_input() fuer die Kartenbedienung: _input()
## laeuft GARANTIERT vor jedem _unhandled_input() im Baum. Nur dadurch
## kann die Karte den Mausklick verschlucken, bevor player_base.gd ihn
## sieht und die Maus wieder einfaengt (dort:
## "if event is InputEventMouseButton and mouse_mode == VISIBLE ->
## MOUSE_MODE_CAPTURED"). Ueber die Baumreihenfolge waere das nur
## zufaellig richtig.
func _input(event: InputEvent) -> void:
	if not _is_big_map:
		return
	if not (event is InputEventMouseButton or event is InputEventMouseMotion):
		return

	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		match mb.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if mb.pressed:
					_zoom_big_map(BIG_MAP_ZOOM_STEP)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_zoom_big_map(1.0 / BIG_MAP_ZOOM_STEP)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE:
				if mb.pressed:
					_dragging = true
					_drag_anchor_world = _world_point_under_mouse()
				else:
					_dragging = false
				get_viewport().set_input_as_handled()
		return

	if _dragging:
		# Pan so nachfuehren, dass der beim Klick gegriffene Weltpunkt
		# wieder genau unter dem Cursor landet.
		var current: Vector3 = _world_point_under_mouse()
		_big_map_pan += Vector3(
			_drag_anchor_world.x - current.x,
			0.0,
			_drag_anchor_world.z - current.z
		)
		_update_camera_position()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(TOGGLE_ACTION):
		_set_big_map(not _is_big_map)
		get_viewport().set_input_as_handled()


## Rechnet die Bildschirm-Mausposition in einen Weltpunkt auf Bodenhoehe um.
##
## get_global_transform_with_canvas().affine_inverse() erledigt dabei in
## einem Rutsch die UI-Skalierung, die Verschiebung UND die
## -90-Grad-Drehung des map_container - von Hand nachgerechnet waere
## genau diese Drehung die Fehlerquelle.
##
## project_ray_origin() funktioniert bei einer ORTHOGONALEN Kamera anders
## als bei einer perspektivischen: der Ursprung wandert mit dem
## Bildschirmpunkt, die Richtung bleibt konstant. Genau deshalb liefert
## schon der Ursprung allein den gesuchten XZ-Punkt, ohne Strahl-Ebenen-
## Schnitt.
func _world_point_under_mouse() -> Vector3:
	var xform: Transform2D = sub_viewport_container.get_global_transform_with_canvas()
	var local: Vector2 = xform.affine_inverse() * get_viewport().get_mouse_position()
	return map_camera.project_ray_origin(local)


## Multiplikativer Zoomschritt statt additiv: so fuehlt sich das Scrollen
## bei starker Vergroesserung genauso fein an wie bei starker
## Verkleinerung (ein additiver Schritt waere bei Zoom 4.0 kaum spuerbar
## und bei 0.4 ein Sprung).
##
## Zoom ZUM CURSOR: Weltpunkt unter der Maus vor und nach der
## Groessenaenderung messen, die Differenz auf den Pan addieren. Dadurch
## bleibt der Punkt unter dem Zeiger stehen, statt dass die Karte immer
## zur Mitte zieht.
func _zoom_big_map(factor: float) -> void:
	var before: Vector3 = _world_point_under_mouse()

	_big_map_zoom = clampf(_big_map_zoom * factor, BIG_MAP_ZOOM_MIN, BIG_MAP_ZOOM_MAX)
	map_camera.size = _effective_big_map_size()

	var after: Vector3 = _world_point_under_mouse()
	_big_map_pan += Vector3(before.x - after.x, 0.0, before.z - after.z)
	_update_camera_position()


## Einzige Stelle, die die Kameraposition setzt. Wird aus _process() UND
## aus den Maus-Handlern gerufen - Letzteres, damit Zoom/Drag sofort
## sichtbar sind und nicht erst einen Frame spaeter nachziehen.
func _update_camera_position() -> void:
	if player == null or not is_instance_valid(player):
		return
	var pos: Vector3 = player.global_position
	map_camera.global_position = Vector3(
		pos.x + _big_map_pan.x,
		pos.y + map_height,
		pos.z + _big_map_pan.z
	)


## --- Oeffentliche API fuer pause_menu.gd ------------------------------
## ESC soll ZUERST nur die Grosskarte schliessen und erst beim NAECHSTEN
## Druck die Pause oeffnen.
func is_big_map_open() -> bool:
	return _is_big_map


func close_big_map() -> void:
	if _is_big_map:
		_set_big_map(false)


func _set_big_map(active: bool) -> void:
	if active == _is_big_map:
		return
	_is_big_map = active
	big_map_open = active

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
	# Maus freigeben. player_base.gd dreht die Kamera nur bei
	# MOUSE_MODE_CAPTURED - damit steht die Spielerkamera automatisch
	# still, ohne dass der Spieler einen eigenen Sperrschalter braucht.
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_big_map_pan = Vector3.ZERO
	_dragging = false

	var viewport_size: Vector2 = get_viewport_rect().size

	var box: float = big_map_box_size
	var content_width: float = box + big_map_gap + box

	var target_frame_size := Vector2(
		content_width + big_map_padding * 2.0,
		big_map_header_reserve + box + big_map_padding + coord_label_reserve
	)

	# Die Grosskarte soll IMMER bildschirmzentriert und in Originalgroesse
	# erscheinen - die UI-Skalierung gilt nur fuer die kleine HUD-Ansicht.
	# Deshalb wird hier gegen die Skalierung gerechnet, sonst saesse die
	# Grosskarte bei ui_scale 1.5 sichtbar aus der Mitte verschoben und
	# waere 50 % zu gross.
	var s: float = maxf(SettingsManager.minimap_ui_scale, 0.01)
	var target_frame_position: Vector2 = ((viewport_size / s) - target_frame_size) * 0.5 - (position / s)

	_tween.tween_property(frame, "size", target_frame_size, big_map_tween_duration)
	_tween.tween_property(frame, "position", target_frame_position, big_map_tween_duration)

	var map_target_pos := Vector2(big_map_padding, big_map_header_reserve)
	var overlay_target_pos := Vector2(big_map_padding + box + big_map_gap, big_map_header_reserve)

	_tween.tween_property(map_container, "size", Vector2(box, box), big_map_tween_duration)
	_tween.tween_property(map_container, "position", map_target_pos, big_map_tween_duration)
	_tween.tween_method(_update_map_container_pivot, 0.0, 1.0, big_map_tween_duration)

	map_camera.size = _effective_big_map_size()

	if _room_overlay:
		_room_overlay.visible = SettingsManager.minimap_grid_placement != SettingsManager.MINIMAP_GRID_HIDDEN
		_tween.tween_property(_room_overlay, "size", Vector2(box, box), big_map_tween_duration)
		_tween.tween_property(_room_overlay, "position", overlay_target_pos, big_map_tween_duration)


func _exit_big_map() -> void:
	_dragging = false
	_big_map_pan = Vector3.ZERO

	# Nur zurueckfangen, wenn das Spiel wirklich weiterlaeuft. Wird die
	# Karte durch ESC geschlossen und gleichzeitig das Pausemenue
	# geoeffnet, muss die Maus sichtbar bleiben.
	if not get_tree().paused:
		Input.mouse_mode = _prev_mouse_mode

	_tween.tween_property(frame, "size", _small_frame_size, big_map_tween_duration)
	_tween.tween_property(frame, "position", _small_frame_position, big_map_tween_duration)

	_tween.tween_property(map_container, "size", _small_map_container_size, big_map_tween_duration)
	_tween.tween_property(map_container, "position", _small_map_container_position, big_map_tween_duration)
	_tween.tween_method(_update_map_container_pivot, 0.0, 1.0, big_map_tween_duration)

	map_camera.size = _effective_map_size()

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

	_update_camera_position()

	var camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
	var camera_yaw: float = camera_pivot.rotation.y if camera_pivot else 0.0

	if rotate_with_player:
		map_camera.rotation.y = camera_yaw
		player_arrow.rotation = 0.0
	else:
		map_camera.rotation.y = 0.0
		player_arrow.rotation = -camera_yaw

	if coord_label.visible:
		var pos: Vector3 = player.global_position
		coord_label.text = "X: %d   Y: %d" % [int(pos.x), int(pos.z)]

	# Zonen-Ermittlung laeuft weiter, auch wenn das Label aus ist: andere
	# Systeme (z.B. Musik-Trigger) koennen an _current_zone haengen.
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
