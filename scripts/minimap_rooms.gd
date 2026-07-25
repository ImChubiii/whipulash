extends Control
class_name MinimapRooms

## Schematische Raum-Uebersicht (Isaac-Style) als Overlay ueber der 3D-Minimap.
##
## Wird von minimap.gd zur Laufzeit erzeugt und ueber den LevelGenerator
## (Gruppe "level_generator") gefuettert. In handgebauten Leveln ohne
## Generator bleibt das Overlay unsichtbar - dort gibt es kein Raum-Grid.

const GENERATOR_GROUP := "level_generator"

## Kantenlaenge einer Raumzelle in Pixeln.
@export var cell_px: float = 18.0
## Abstand zwischen zwei Zellen (hier werden die Tuer-Stummel gezeichnet).
@export var gap_px: float = 4.0
## Wie viele Zellen in jede Richtung um den aktuellen Raum gezeigt werden.
@export var view_radius: int = 2
## Raeume, die noch nie betreten wurden, aber an einen betretenen grenzen,
## werden als "bekannt aber unerforscht" angedeutet.
@export var show_unexplored_neighbors: bool = true

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
@export var color_door: Color = Color(0.85, 0.87, 0.80, 0.9)
@export var color_text: Color = Color(0.08, 0.08, 0.06, 1.0)

var _generator: Node = null
var _pulse: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_process(true)
	_try_bind_generator()

func _process(delta: float) -> void:
	if _generator == null or not is_instance_valid(_generator):
		_try_bind_generator()
		return
	# Nur der Rahmen des aktuellen Raums pulsiert - billig genug fuer
	# jeden Frame, und ohne das wirkt die Karte statisch/tot.
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

	# --- Tuer-Verbindungen zuerst, damit sie unter den Raeumen liegen ---
	for pos in cells.keys():
		var grid: Vector2i = pos
		if not _is_visible_cell(cells, grid, current):
			continue
		var data: Dictionary = cells[grid]
		if not bool(data.get("visited", false)):
			continue
		var origin := _cell_center(grid, current, center, pitch)
		var exits: int = int(data.get("exits", 0))
		# Bitmask: Norden=1, Sueden=2, Osten=4, Westen=8
		if exits & 1:
			draw_line(origin, origin + Vector2(0.0, -pitch * 0.5), color_door, 3.0)
		if exits & 2:
			draw_line(origin, origin + Vector2(0.0, pitch * 0.5), color_door, 3.0)
		if exits & 4:
			draw_line(origin, origin + Vector2(pitch * 0.5, 0.0), color_door, 3.0)
		if exits & 8:
			draw_line(origin, origin + Vector2(-pitch * 0.5, 0.0), color_door, 3.0)

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
		var rect := Rect2(c - Vector2(cell_px, cell_px) * 0.5, Vector2(cell_px, cell_px))

		if not visited:
			# Unerforscht: nur angedeutet, keine Typ-Information verraten.
			draw_rect(rect, color_unexplored, true)
			draw_rect(rect, Color(0, 0, 0, 0.5), false, 1.0)
			continue

		var base := _color_for_type(type)
		# Gecleared = Raum faerbt sich gruenlich ein. Nur Raeume, die
		# ueberhaupt Gegner hatten, koennen "gecleared" aussehen - sonst
		# waere jeder Korridor sofort gruen und die Info wertlos.
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

	# --- "STAGE CLEAR"-Banner -------------------------------------------
	if _generator.has_method("is_stage_cleared") and _generator.is_stage_cleared():
		var font := ThemeDB.fallback_font
		var txt := "STAGE CLEAR"
		draw_string(font, Vector2(0.0, size.y - 4.0), txt,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, color_cleared_tint)

## Fog of War: sichtbar sind betretene Raeume und (optional) deren direkte
## Nachbarn - damit man sieht, WO die naechste Tuer hinfuehrt, ohne die
## ganze Karte zu verraten.
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

func _cell_center(grid: Vector2i, current: Vector2i, center: Vector2, pitch: float) -> Vector2:
	var d := grid - current
	return center + Vector2(float(d.x) * pitch, float(d.y) * pitch)

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

## Zeichnet das Typ-Symbol bzw. den Clear-Haken in die Zelle.
func _draw_room_glyph(rect: Rect2, type: int, cleared: bool) -> void:
	if cleared:
		# Haken aus zwei Linien - unabhaengig davon, ob der Fallback-Font
		# ein Haken-Glyph besitzt.
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
