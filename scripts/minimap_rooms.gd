extends Control
class_name MinimapRooms

## Schematische Raum-Uebersicht (Isaac-Style) als Overlay ueber/neben der
## 3D-Minimap.
##
## ROTATION: Die 3D-Minimap-Kamera hat eine -90-Grad-Bildkalibrierung
## (siehe minimap.gd: map_calibration_offset_degrees). Das Grid hier
## rotiert deshalb NUR die Positions-Berechnung der Zellen (nicht das
## ganze Control) um denselben Winkel - Text/Glyphen bleiben aufrecht.
##
## TUEREN ALS OFFENER DURCHGANG: Vorher wurde zwischen zwei Raeumen nur
## ein duenner 3px-Steg mitten im dunklen Spalt gezeichnet - das sah eher
## nach Gitter/Riegel aus als nach Durchgang. Jetzt wird der GESAMTE
## Spalt zwischen zwei betretenen Nachbarraeumen mit Flaeche gefuellt
## (_draw_passage). Der Trick, der das ohne Praezisions-Randberechnung
## sauber aussehen laesst: die Fuellung reicht von Zellmitte zu Zellmitte
## (bzw. bis zur Spaltmitte, wenn der Nachbar noch nicht betreten ist) -
## die spaeter obendrauf gezeichneten Raumquadrate schneiden den
## ueberschuessigen Teil in der Raummitte automatisch weg und uebrig
## bleibt genau der Spalt, sauber gefuellt.

const GENERATOR_GROUP := "level_generator"

## Bitmask-Richtungen -> Grid-Offset. Muss 1:1 mit RoomGridGenerator/
## RoomInstance uebereinstimmen: Norden=1, Sueden=2, Osten=4, Westen=8.
const DIR_OFFSET_BY_BIT := {
	1: Vector2i(0, -1),
	2: Vector2i(0, 1),
	4: Vector2i(1, 0),
	8: Vector2i(-1, 0),
}

@export var cell_px: float = 18.0
@export var gap_px: float = 4.0
@export var view_radius: int = 2
@export var show_unexplored_neighbors: bool = true

## Dreht NUR die Positionierung der Zellen/Tueren zueinander, damit das
## Layout zur kalibrierten 3D-Minimap passt. Buchstaben und Symbole
## bleiben davon unberuehrt. Falls die Karte nach dem Einbau spiegelverkehrt
## zur 3D-Ansicht wirkt: Vorzeichen umdrehen (+90 statt -90).
@export var overlay_rotation_degrees: float = -90.0

## --- Farbschema -------------------------------------------------------
@export var color_background: Color = Color(0.05, 0.06, 0.05, 0.72)
@export var color_unexplored: Color = Color(0.35, 0.38, 0.32, 0.45)
@export var color_combat: Color = Color(0.62, 0.64, 0.58, 0.95)
@export var color_corridor: Color = Color(0.45, 0.47, 0.42, 0.95)
@export var color_start: Color = Color(0.35, 0.68, 0.95, 0.95)
@export var color_boss: Color = Color(0.90, 0.24, 0.24, 0.95)
@export var color_treasure: Color = Color(0.98, 0.80, 0.25, 0.95)
@export var color_cleared_tint: Color = Color(0.44, 0.85, 0.36, 0.95)
@export var color_current: Color = Color(1.0, 1.0, 1.0, 1.0)
## Fuellfarbe des offenen Durchgangs zwischen zwei bereits betretenen
## Raeumen (voll deckend - liest sich als begehbarer Gang).
@export var color_door: Color = Color(0.85, 0.87, 0.80, 0.9)
## Durchgang zu einem noch NICHT betretenen Nachbarn: nur angedeutet
## (kuerzer + durchsichtiger), damit die Neugier/Fog-of-War erhalten
## bleibt, man aber trotzdem sieht "hier geht es weiter".
@export var color_door_unexplored_alpha: float = 0.5
@export var color_text: Color = Color(0.08, 0.08, 0.06, 1.0)

var _generator: Node = null
var _pulse: float = 0.0
var _rotation_rad: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_rotation_rad = deg_to_rad(overlay_rotation_degrees)
	set_process(true)
	_try_bind_generator()


func _process(delta: float) -> void:
	if _generator == null or not is_instance_valid(_generator):
		_try_bind_generator()
		return
	_pulse = fmod(_pulse + delta * 2.2, TAU)
	queue_redraw()


func _try_bind_generator() -> void:
	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		visible = false
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)
	visible = true
	queue_redraw()


func _on_map_updated() -> void:
	queue_redraw()


## Rotiert einen reinen Richtungs-/Offset-Vektor um overlay_rotation_degrees.
## Wird NIE auf Text angewendet - nur auf Positionen.
func _rotate(v: Vector2) -> Vector2:
	return v.rotated(_rotation_rad)


func _draw() -> void:
	if _generator == null or not is_instance_valid(_generator):
		return
	if not _generator.has_method("get_map_cells"):
		return

	var cells: Dictionary = _generator.get_map_cells()
	if cells.is_empty():
		return

	var current: Vector2i = _generator.get_current_room()
	var pitch: float = cell_px + gap_px
	var center := size * 0.5

	draw_rect(Rect2(Vector2.ZERO, size), color_background, true)

	# --- Durchgaenge zuerst, damit die Raumquadrate spaeter sauber
	# darueber gezeichnet werden und den ueberschuessigen Teil der
	# Fuellung in der Raummitte automatisch abschneiden -----------------
	for pos in cells.keys():
		var grid: Vector2i = pos
		if not _is_visible_cell(cells, grid, current):
			continue
		var data: Dictionary = cells[grid]
		if not bool(data.get("visited", false)):
			continue

		var exits: int = int(data.get("exits", 0))
		var here_center := _cell_center(grid, current, center, pitch)

		for bit in DIR_OFFSET_BY_BIT.keys():
			if exits & bit == 0:
				continue
			var neighbor_grid: Vector2i = grid + DIR_OFFSET_BY_BIT[bit]
			if not cells.has(neighbor_grid):
				continue
			var neighbor_data: Dictionary = cells[neighbor_grid]
			var neighbor_visited: bool = bool(neighbor_data.get("visited", false))
			var neighbor_center := _cell_center(neighbor_grid, current, center, pitch)

			_draw_passage(here_center, neighbor_center, cell_px, neighbor_visited)

	# --- Raumzellen ------------------------------------------------------
	for pos in cells.keys():
		var grid: Vector2i = pos
		if not _is_visible_cell(cells, grid, current):
			continue

		var data: Dictionary = cells[grid]
		var visited: bool = bool(data.get("visited", false))
		var cleared: bool = bool(data.get("cleared", false))
		var hostile: bool = bool(data.get("hostile", false))
		var type: int = int(data.get("type", 0))

		var c := _cell_center(grid, current, center, pitch)
		# Zelle bleibt ein achsenparalleles Rect2 - NUR ihre Position
		# wandert entlang der rotierten Achsen, die Box selbst dreht sich
		# nicht. Dadurch bleiben Glyphen/Text darin aufrecht.
		var rect := Rect2(c - Vector2(cell_px, cell_px) * 0.5, Vector2(cell_px, cell_px))

		if not visited:
			draw_rect(rect, color_unexplored, true)
			draw_rect(rect, Color(0, 0, 0, 0.5), false, 1.0)
			continue

		var base := _color_for_type(type)
		if hostile and cleared:
			base = base.lerp(color_cleared_tint, 0.65)

		draw_rect(rect, base, true)
		draw_rect(rect, Color(0, 0, 0, 0.65), false, 1.0)

		_draw_room_glyph(rect, type, hostile and cleared)

		if grid == current:
			var a: float = 0.55 + 0.45 * sin(_pulse)
			var hl := color_current
			hl.a = a
			draw_rect(rect.grow(2.0), hl, false, 2.0)

	# --- "STAGE CLEAR"-Banner --------------------------------------------
	if _generator.has_method("is_stage_cleared") and _generator.is_stage_cleared():
		var font := ThemeDB.fallback_font
		var txt := "STAGE CLEAR"
		draw_string(font, Vector2(0.0, size.y - 4.0), txt,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, color_cleared_tint)


## Fuellt den Durchgang zwischen zwei Zellen als FLAECHE statt als
## duenne Linie - das ist der eigentliche Unterschied zwischen "sieht
## nach Gitter/Riegel aus" und "sieht nach offenem Gang aus".
##
## Reicht bei einem bereits betretenen Nachbarn bis zu dessen Mitte,
## bei einem noch unbetretenen Nachbarn nur bis zur Spaltmitte (Fog-of-
## War bleibt erhalten, man sieht aber "hier geht's weiter"). Die
## spaeter obendrauf gezeichneten Raumquadrate schneiden den Teil, der
## in die jeweilige Raummitte hineinreicht, automatisch weg.
##
## Funktioniert nur exakt fuer Rotationen, die ein Vielfaches von 90 Grad
## sind (Standard: -90) - dann ist die Verbindung zwischen zwei
## Zellmitten garantiert rein horizontal oder rein vertikal auf dem
## Bildschirm, und ein simples Rect2 reicht aus.
func _draw_passage(here: Vector2, neighbor: Vector2, cell_size: float, neighbor_visited: bool) -> void:
	var delta: Vector2 = neighbor - here
	var horizontal: bool = absf(delta.x) >= absf(delta.y)
	var mid: Vector2 = (here + neighbor) * 0.5
	var far_point: Vector2 = neighbor if neighbor_visited else mid

	var fill: Color = color_door
	if not neighbor_visited:
		fill.a = color_door.a * color_door_unexplored_alpha

	if horizontal:
		var min_x: float = minf(here.x, far_point.x)
		var max_x: float = maxf(here.x, far_point.x)
		var rect := Rect2(Vector2(min_x, here.y - cell_size * 0.5), Vector2(max_x - min_x, cell_size))
		draw_rect(rect, fill, true)
	else:
		var min_y: float = minf(here.y, far_point.y)
		var max_y: float = maxf(here.y, far_point.y)
		var rect := Rect2(Vector2(here.x - cell_size * 0.5, min_y), Vector2(cell_size, max_y - min_y))
		draw_rect(rect, fill, true)


## Fog of War: sichtbar sind betretene Raeume und (optional) deren direkte
## Nachbarn.
func _is_visible_cell(cells: Dictionary, grid: Vector2i, current: Vector2i) -> bool:
	if absi(grid.x - current.x) > view_radius or absi(grid.y - current.y) > view_radius:
		return false
	var data: Dictionary = cells[grid]
	if bool(data.get("visited", false)):
		return true
	if not show_unexplored_neighbors:
		return false
	for offset in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]:
		var n: Vector2i = grid + offset
		if cells.has(n) and bool(cells[n].get("visited", false)):
			return true
	return false


## Position der Zelle relativ zur aktuellen: der reine Offset-Vektor wird
## rotiert, NICHT die Zelle selbst.
func _cell_center(grid: Vector2i, current: Vector2i, center: Vector2, pitch: float) -> Vector2:
	var d := grid - current
	var offset := Vector2(float(d.x) * pitch, float(d.y) * pitch)
	return center + _rotate(offset)


func _color_for_type(type: int) -> Color:
	match type:
		RoomData.RoomType.START:
			return color_start
		RoomData.RoomType.BOSS:
			return color_boss
		RoomData.RoomType.TREASURE:
			return color_treasure
		RoomData.RoomType.CORRIDOR:
			return color_corridor
	return color_combat


## Zeichnet das Typ-Symbol bzw. den Clear-Haken in die Zelle. Bewusst
## UNROTIERT: rect ist achsenparallel, also bleibt der Text aufrecht,
## egal wie overlay_rotation_degrees eingestellt ist.
func _draw_room_glyph(rect: Rect2, type: int, cleared: bool) -> void:
	if cleared:
		var p := rect.position
		var s := rect.size
		draw_line(p + Vector2(s.x * 0.24, s.y * 0.52), p + Vector2(s.x * 0.44, s.y * 0.74), color_text, 2.0)
		draw_line(p + Vector2(s.x * 0.44, s.y * 0.74), p + Vector2(s.x * 0.78, s.y * 0.26), color_text, 2.0)
		return

	var glyph: String = ""
	match type:
		RoomData.RoomType.BOSS:
			glyph = "B"
		RoomData.RoomType.TREASURE:
			glyph = "$"
		RoomData.RoomType.START:
			glyph = "S"
		RoomData.RoomType.SHOP:
			glyph = "?"
	if glyph == "":
		return

	var font := ThemeDB.fallback_font
	var fs: int = int(cell_px * 0.72)
	draw_string(font, rect.position + Vector2(0.0, rect.size.y * 0.78), glyph,
		HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, fs, color_text)
