

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
const ENEMY_GROUP := "enemies"

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

## --- Dynamischer Auto-Zoom -------------------------------------------
## Die Kamera zoomt automatisch heraus, sobald die aufgedeckte Flaeche
## nicht mehr in den Ausschnitt passt. Grundlage ist die Spannweite der
## belegten Grid-Zellen (get_map_cells()), NICHT die Raumzahl: ein Layout
## mit 12 Raeumen in einer Reihe braucht mehr Ausschnitt als 12 Raeume im
## Block.
##
## SettingsManager.minimap_zoom bleibt uneingeschraenkt wirksam — es wird
## weiterhin als Teiler auf den (jetzt dynamischen) Basisausschnitt
## angewandt. Der Regler ist damit relativ statt absolut.
@export var auto_zoom_enabled: bool = true
## Zuschlag um die belegte Flaeche herum, in Weltmetern.
@export var auto_zoom_padding: float = 40.0
## Obergrenze fuer die KLEINE Karte. Ohne Deckel waere sie im spaeten Run
## so weit draussen, dass man den eigenen Raum nicht mehr erkennt.
@export var auto_zoom_small_max: float = 300.0
## Obergrenze fuer die Grosskarte. Deutlich hoeher — dort ist der
## Gesamtueberblick genau der Zweck.
@export var auto_zoom_big_max: float = 900.0

## --- Gegner-Icons (Phase 2.3) -----------------------------------------
##
## Gezeichnet wird als 2D-Overlay UEBER dem SubViewport, nicht als
## 3D-Objekt in der Welt.
##
## WARUM NICHT 3D: Ein Marker-Mesh ueber jedem Gegner muesste auf einem
## eigenen Visibility-Layer liegen, den NUR die Minimap-Kamera sieht. Das
## hiesse: cull_mask der Spielerkamera in allen vier Charakter-Szenen
## anpassen, plus ein Mesh pro Gegner. Das Overlay braucht dagegen null
## Szenenaenderungen und kostet einen _draw()-Aufruf pro Frame.
##
## Die Umrechnung Welt -> Pixel macht map_camera.unproject_position() -
## dieselbe Funktion, die schon den Spielerpfeil setzt. Zoom, Pan und
## (falls aktiv) die Kameradrehung sind darin bereits enthalten.
@export var show_enemy_icons: bool = true
@export var enemy_icon_radius: float = 3.0
@export var enemy_icon_color: Color = Color(0.92, 0.26, 0.24, 0.95)
@export var enemy_icon_outline: Color = Color(0.05, 0.03, 0.04, 0.85)
## Gegner ausserhalb dieser Weltdistanz zum Spieler werden gar nicht erst
## umgerechnet. Culling-Schritt 1: spart die unproject-Rechnung fuer alles,
## was ohnehin nicht in den Ausschnitt faellt.
@export var enemy_icon_cull_distance: float = 260.0
## Obergrenze pro Frame. Notbremse gegen Layouts, in denen sehr viele
## Gegner gleichzeitig leben.
@export var enemy_icon_max: int = 64

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

## Weltbreite, die die aufgedeckten Zellen aktuell einnehmen. Wird bei
## jedem map_updated neu bestimmt. 0 = noch keine Daten -> Auto-Zoom
## verhaelt sich neutral und map_size gilt unveraendert.
var _revealed_world_span: float = 0.0

var _enemy_overlay: Control = null

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

	# Fog of War: Raeume, die noch nicht aufgedeckt sind, haengt der
	# LevelGenerator auf RoomInstance.MINIMAP_HIDDEN_LAYER um. NUR diese
	# Kamera streicht den Layer aus ihrer cull_mask - die Spielerkamera
	# bleibt unangetastet und zeigt die Welt vollstaendig.
	map_camera.set_cull_mask_value(RoomInstance.MINIMAP_HIDDEN_LAYER, false)

	sub_viewport.own_world_3d = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_viewport.transparent_bg = minimap_transparent_background

	_cache_frame_style()
	_set_zone_text(default_zone_name)

	if minimap_disable_fog:
		_apply_minimap_environment()

	map_container.pivot_offset = map_container.size * 0.5
	map_container.rotation_degrees = map_calibration_offset_degrees

	# Das schematische Raum-Grid-Overlay (MinimapRooms) ist komplett entfernt
	# (Rueckmeldung: "sollte kein Layoutgrid sein, sondern direkt in der
	# Minimap"). Raum-Zustand (gecleart/nicht) und Spezialraum-Icons
	# (Schatz/Boss) werden jetzt direkt in der echten 3D-Top-Down-Ansicht
	# angezeigt - siehe room_instance.gd::_build_room_state_overlay()/
	# set_room_type(), beide auf MINIMAP_ONLY_LAYER wie die schon
	# bestehenden Tuerzustands-Platten. _create_room_overlay() bleibt als
	# totes Legacy-Codepfad stehen (siehe dortiger Kommentar), wird aber
	# absichtlich nie mehr aufgerufen.
	overlay_placement = OverlayPlacement.HIDDEN

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

	_bind_generator()
	_build_enemy_overlay()
	_apply_minimap_settings()


## Zeichenflaeche fuer die Gegner-Punkte.
##
## Haengt IM map_container und damit unter derselben -90-Grad-Drehung wie
## die Karte. Das ist Absicht: unproject_position() liefert Pixel im
## ungedrehten SubViewport, und der Container dreht sie anschliessend
## genauso mit wie das gerenderte Bild. Haenge man das Overlay eine Ebene
## hoeher, muesste die Drehung von Hand nachgerechnet werden - exakt die
## Fehlerquelle, die im Kommentar zu _world_point_under_mouse() steht.
func _build_enemy_overlay() -> void:
	if _enemy_overlay != null and is_instance_valid(_enemy_overlay):
		return
	_enemy_overlay = Control.new()
	_enemy_overlay.name = "EnemyOverlay"
	_enemy_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_enemy_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_enemy_overlay.draw.connect(_draw_enemy_icons)
	map_container.add_child(_enemy_overlay)
	# Unter den Spielerpfeil sortieren: der eigene Standort muss auch dann
	# lesbar bleiben, wenn ein Gegner direkt darauf steht.
	if player_arrow != null and is_instance_valid(player_arrow):
		map_container.move_child(_enemy_overlay, player_arrow.get_index())


## Wandelt Weltpositionen in Pixel IM map_container um.
##
## Gleiche Rechnung wie _update_player_arrow_position(): erst
## unproject_position() (Pixel im SubViewport), dann auf die gestreckte
## Containergroesse skalieren. Liefert false, wenn der Punkt hinter der
## Kamera oder ausserhalb des Rahmens liegt.
func _world_to_map_pixel(world: Vector3, out: Array) -> bool:
	var viewport_size: Vector2 = Vector2(sub_viewport.size)
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return false

	var box_size: Vector2 = sub_viewport_container.size
	var in_viewport: Vector2 = map_camera.unproject_position(world)
	var in_box: Vector2 = sub_viewport_container.position + in_viewport * (box_size / viewport_size)

	# Culling-Schritt 2: alles ausserhalb des sichtbaren Rahmens faellt
	# raus. Ohne diese Pruefung malt Godot die Punkte zwar weg, rechnet
	# sie aber trotzdem - und bei offener Grosskarte waeren das die
	# Gegner der halben Etage.
	var rect := Rect2(sub_viewport_container.position, box_size)
	if not rect.has_point(in_box):
		return false

	out.append(in_box)
	return true


func _draw_enemy_icons() -> void:
	if not show_enemy_icons or _enemy_overlay == null:
		return
	if player == null or not is_instance_valid(player):
		return

	var origin: Vector3 = player.global_position
	var cull_sq: float = enemy_icon_cull_distance * enemy_icon_cull_distance
	var drawn: int = 0

	for node: Node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		if drawn >= enemy_icon_max:
			break
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue
		# Sterbende Gegner haengen noch einen Frame im Baum. Ohne diese
		# Pruefung blinkt nach jedem Kill kurz ein Geisterpunkt auf.
		if not enemy.is_inside_tree() or not enemy.visible:
			continue

		var health: Node = enemy.get_node_or_null("Health")
		if health != null and health.has_method("is_alive") and not health.is_alive():
			continue

		# Culling-Schritt 1: grobe Weltdistanz, bevor irgendetwas
		# projiziert wird.
		if origin.distance_squared_to(enemy.global_position) > cull_sq:
			continue

		var result: Array = []
		if not _world_to_map_pixel(enemy.global_position, result):
			continue

		var point: Vector2 = result[0]
		# Dunkler Ring unter dem Punkt: ohne ihn verschwindet ein roter
		# Punkt auf einer roten Bossraum-Flaeche.
		_enemy_overlay.draw_circle(point, enemy_icon_radius + 1.0, enemy_icon_outline)
		_enemy_overlay.draw_circle(point, enemy_icon_radius, enemy_icon_color)
		drawn += 1


# --- Dynamischer Auto-Zoom ---------------------------------------------

## Haengt sich an das map_updated-Signal des LevelGenerators. Genau dieses
## Signal feuert beim Instanziieren eines Stages, beim Betreten eines Raums
## und beim Aufdecken — also exakt bei jeder Aenderung der bekannten
## Flaeche. Ein Polling pro Frame waere dafuer Verschwendung.
func _bind_generator() -> void:
	if _generator != null and is_instance_valid(_generator):
		return
	var found: Array = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)
	_on_map_updated()


func _on_map_updated() -> void:
	_recalculate_revealed_span()
	# Beide Modi sofort nachziehen, damit der neue Ausschnitt nicht erst
	# beim naechsten Oeffnen/Schliessen der Grosskarte greift.
	map_camera.size = _effective_big_map_size() if _is_big_map else _effective_map_size()
	_small_map_camera_size = _effective_map_size()


## Spannweite der SICHTBAREN Zellen in Weltmetern.
##
## Sichtbar = besucht. Unbesuchte Nachbarn zaehlen bewusst mit einer
## halben Zelle, weil minimap_rooms.gd sie als Umriss zeichnet — sonst
## rutschte der angrenzende Raum am Rand aus dem Bild.
##
## Die Zellgroesse wird vom Generator geholt, nicht hier gepflegt: sie
## haengt an dessen room_scale und waere als zweite Konstante sofort
## veraltet.
func _recalculate_revealed_span() -> void:
	_revealed_world_span = 0.0
	if _generator == null or not is_instance_valid(_generator):
		return
	if not _generator.has_method("get_map_cells"):
		return

	var cells: Dictionary = _generator.get_map_cells()
	if cells.is_empty():
		return

	# get() liefert null, falls das Feld in einer aelteren Generator-
	# Version nicht existiert. Erst pruefen, DANN typisiert zuweisen —
	# eine direkte Zuweisung von null an ein Vector3 waere ein
	# Laufzeitfehler.
	var raw_cell_size: Variant = _generator.get("cell_size")
	if not (raw_cell_size is Vector3):
		return
	var cell_size: Vector3 = raw_cell_size
	if is_zero_approx(cell_size.x) or is_zero_approx(cell_size.z):
		return

	var min_cell := Vector2i(2147483647, 2147483647)
	var max_cell := Vector2i(-2147483648, -2147483648)
	var any: bool = false

	for pos in cells.keys():
		var grid: Vector2i = pos
		if not bool(cells[grid].get("visited", false)):
			continue
		any = true
		min_cell.x = mini(min_cell.x, grid.x)
		min_cell.y = mini(min_cell.y, grid.y)
		max_cell.x = maxi(max_cell.x, grid.x)
		max_cell.y = maxi(max_cell.y, grid.y)

	if not any:
		return

	# +1, weil eine einzelne Zelle bereits eine volle Raumbreite belegt;
	# +1 zusaetzlich fuer die angrenzenden, nur umrissenen Nachbarn.
	var span_x: float = (float(max_cell.x - min_cell.x) + 2.0) * cell_size.x
	var span_z: float = (float(max_cell.y - min_cell.y) + 2.0) * cell_size.z
	_revealed_world_span = maxf(span_x, span_z) + auto_zoom_padding


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

	# Grid-Overlay entfernt (siehe _ready()) - die minimap_grid_placement-
	# Einstellung bleibt bestehen (Menue nicht angefasst), wird hier aber
	# bewusst ignoriert statt ein Overlay nachzuziehen.


## Zoom > 1 = naeher dran. Der Kamera-Ausschnitt ist der KEHRWERT des
## Zooms. maxf() verhindert eine Division, die bei einem manipulierten
## Zoom von 0 eine size von inf erzeugen wuerde.
func _effective_map_size() -> float:
	return _auto_base_size(map_size, auto_zoom_small_max) / maxf(SettingsManager.minimap_zoom, 0.01)


func _effective_big_map_size() -> float:
	return _auto_base_size(big_map_world_size, auto_zoom_big_max) / maxf(_big_map_zoom, 0.01)


## Basisausschnitt VOR dem Anwenden des Zoom-Reglers.
##
## Der Auto-Zoom vergroessert nur — er zieht nie enger als der
## eingestellte Grundwert. Sonst wuerde die Karte am Anfang eines Runs
## (eine einzige aufgedeckte Zelle) auf einen winzigen Ausschnitt
## zusammenfallen.
func _auto_base_size(base: float, limit: float) -> float:
	if not auto_zoom_enabled or _revealed_world_span <= 0.0:
		return base
	return clampf(_revealed_world_span, base, maxf(limit, base))


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


## Bildschirm-Rechteck, das die KLEINE Minimap tatsaechlich belegt —
## inklusive der UI-Skalierung (SettingsManager.minimap_ui_scale).
##
## WARUM NICHT get_global_rect(): Control.get_global_rect() liefert
## Position und size, aber OHNE scale. Die Minimap wird ueber
## Control.scale vergroessert (siehe _apply_minimap_settings), das
## Rechteck waere damit bei jedem Wert != 1.0 zu klein — genau der
## Grund, warum der Speedrun-Timer bei groesserer Karte darunter
## verschwunden ist.
##
## Wird von run_timer.gd genutzt, um sich rechts anzudocken.
func get_docking_rect() -> Rect2:
	if frame == null:
		return Rect2(global_position, size * scale)

	# Bei offener Grosskarte waechst der Frame auf Bildschirmbreite. Der
	# Timer soll trotzdem an der KLEINANSICHT kleben, sonst springt er
	# beim Oeffnen der Karte quer ueber den Bildschirm und wieder zurueck.
	var f_pos: Vector2 = _small_frame_position if _is_big_map else frame.position
	var f_size: Vector2 = _small_frame_size if _is_big_map else frame.size

	return Rect2(global_position + f_pos * scale, f_size * scale)


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


## Setzt den Spielerpfeil auf die Bildschirmposition des Spielers.
##
## BUGFIX "Pfeil bleibt beim Verschieben der Grosskarte in der Mitte":
## Der Pfeil haengt als eigenes Control mittig im MapContainer. Auf der
## KLEINEN Karte stimmt das, weil _update_camera_position() die Kamera
## exakt ueber den Spieler setzt - die Mitte IST der Spieler. Auf der
## grossen Karte kommt _big_map_pan dazu: die Kamera schaut woanders hin,
## der Pfeil klebte aber weiter in der Mitte und zeigte damit dauerhaft
## die falsche Position an.
##
## unproject_position() rechnet die Weltposition in Pixel IM SubViewport
## um. Das beruecksichtigt Zoom (map_camera.size), Pan und - falls
## rotate_with_player an ist - auch die Kameradrehung, ohne dass hier
## irgendetwas davon nachgerechnet werden muss. Anschliessend wird nur
## noch auf die (gestreckte) Containergroesse skaliert.
func _update_player_arrow_position() -> void:
	if player_arrow == null or not player_arrow.visible:
		return
	if player == null or not is_instance_valid(player):
		return

	var viewport_size: Vector2 = Vector2(sub_viewport.size)
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var box_size: Vector2 = sub_viewport_container.size
	var in_viewport: Vector2 = map_camera.unproject_position(player.global_position)
	var in_box: Vector2 = sub_viewport_container.position + in_viewport * (box_size / viewport_size)

	# Ausserhalb des Rahmens an den Rand klemmen und abdunkeln, statt den
	# Pfeil verschwinden zu lassen - so bleibt erkennbar, in welche
	# Richtung der eigene Standort liegt.
	var half: Vector2 = player_arrow.size * 0.5
	var min_point: Vector2 = sub_viewport_container.position + half
	var max_point: Vector2 = sub_viewport_container.position + box_size - half
	var clamped := Vector2(
		clampf(in_box.x, min_point.x, max_point.x),
		clampf(in_box.y, min_point.y, max_point.y)
	)
	player_arrow.modulate.a = 1.0 if clamped.is_equal_approx(in_box) else 0.45

	# Der Pfeil sitzt an den Mittelankern (anchors_preset 8). Deshalb wird
	# der VERSATZ ZUR MITTE ueber die Offsets gesetzt und nicht position -
	# sonst rechnen Anker und position gegeneinander und der Pfeil zittert.
	var delta: Vector2 = clamped - map_container.size * 0.5
	player_arrow.offset_left = delta.x - half.x
	player_arrow.offset_top = delta.y - half.y
	player_arrow.offset_right = delta.x + half.x
	player_arrow.offset_bottom = delta.y + half.y


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

	_update_player_arrow_position()

	# Gegner bewegen sich jeden Frame - das Overlay muss deshalb jeden
	# Frame neu gezeichnet werden. queue_redraw() ist billig, solange
	# _draw_enemy_icons() frueh aussteigt; die eigentliche Arbeit
	# verhindern die beiden Culling-Stufen.
	if show_enemy_icons and _enemy_overlay != null and is_instance_valid(_enemy_overlay):
		_enemy_overlay.queue_redraw()

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
	# Ueber _bind_generator() statt einer eigenen Suche: die frueher hier
	# stehende Lazy-Bindung hat _generator zwar gesetzt, aber NICHT
	# map_updated verbunden. Steht der LevelGenerator beim _ready() der
	# Minimap noch nicht in seiner Gruppe (Reihenfolge im Szenenbaum),
	# waere der Auto-Zoom danach dauerhaft tot gewesen — ohne Fehler,
	# einfach nur ohne Wirkung.
	_bind_generator()
	if _generator == null or not is_instance_valid(_generator):
		return ""

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
