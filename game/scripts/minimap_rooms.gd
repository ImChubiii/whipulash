
extends Control
class_name MinimapRooms

## Raum-Uebersicht als Overlay ueber/neben der 3D-Minimap.
##
## ROTATION: Die 3D-Minimap-Kamera hat eine -90-Grad-Bildkalibrierung
## (siehe minimap.gd: map_calibration_offset_degrees). Die Punkte hier
## rotieren deshalb NUR ihre POSITIONS-Berechnung (nicht das ganze Control)
## um denselben Winkel - Icons bleiben dabei aufrecht.
##
## ============================================================================
## REDESIGN (Rueckmeldung "Grid wirkt bei groesseren Raeumen verzerrt, bitte
## komplett entfernen"): das fruehere Overlay zeichnete ein Rechteck pro
## Raum (bei Mehrzellen-Raeumen zu einem groesseren Rechteck verschmolzen)
## plus gefuellte Durchgangs-Flaechen zwischen benachbarten Raeumen - optisch
## ein Raster/Grundriss. Das ist jetzt komplett ersetzt durch:
##   - EIN Punkt pro Raum-Mittelpunkt statt eines Rechtecks/Grundrisses.
##   - Farbe statt Form zeigt den Zustand: gedaempft/grau = noch nicht
##     gecleart (hostile Raum), volle Typ-Farbe = gecleart bzw. kein
##     Kampf-Gate (Korridor/Start/Schatz/...). Siehe _display_color_for().
##   - Kronen-/Totenkopf-Icon fuer Schatz-/Bossraum statt Text-Glyphen.
## Keine Durchgangs-/Wand-Darstellung mehr - das war der Teil, der bei
## Mehrzellen-Raeumen am ehesten "verzerrt" wirkte.

const GENERATOR_GROUP := "level_generator"

@export var cell_px: float = 18.0
@export var gap_px: float = 4.0
@export var view_radius: int = 2
@export var show_unexplored_neighbors: bool = true

## Radius des gezeichneten Raum-Punkts, relativ zu cell_px (1.0 = so breit
## wie frueher eine ganze Raumzelle).
@export_range(0.1, 1.0) var room_dot_radius_factor: float = 0.4

## Dreht NUR die Positionierung der Punkte zueinander, damit das Layout zur
## kalibrierten 3D-Minimap passt.
@export var overlay_rotation_degrees: float = -90.0

## --- Farbschema -------------------------------------------------------
@export var color_unexplored: Color = Color(0.35, 0.38, 0.32, 0.45)
@export var color_combat: Color = Color(0.62, 0.64, 0.58, 0.95)
@export var color_corridor: Color = Color(0.45, 0.47, 0.42, 0.95)
@export var color_start: Color = Color(0.35, 0.68, 0.95, 0.95)
@export var color_boss: Color = Color(0.90, 0.24, 0.24, 0.95)
@export var color_treasure: Color = Color(0.98, 0.80, 0.25, 0.95)
@export var color_current: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var color_text: Color = Color(0.08, 0.08, 0.06, 1.0)

## Zielfarbe, gegen die ein noch nicht gecleareter Kampf-/Bossraum
## eingefaerbt wird (siehe _display_color_for()) - graeulich statt der
## vollen, hellen Typ-Farbe. "Voll hell" ist jetzt das Signal fuer
## "sicher/gecleart", nicht mehr ein Haekchen-Symbol.
@export var color_uncleared_tint: Color = Color(0.32, 0.32, 0.34)
## Wie stark Richtung color_uncleared_tint gemischt wird. 1.0 = komplett
## grau (Typ nicht mehr erkennbar), 0.0 = kein Unterschied zu gecleart.
@export_range(0.0, 1.0) var uncleared_dim_strength: float = 0.7

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
## Wird NIE auf Icons angewendet - nur auf Positionen.
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
	var radius: float = cell_px * room_dot_radius_factor

	for pos in cells.keys():
		var grid: Vector2i = pos
		if not _is_visible_cell(cells, grid, current):
			continue

		var data: Dictionary = cells[grid]
		var visited: bool = bool(data.get("visited", false))
		var c := _cell_center(grid, current, center, pitch)

		if not visited:
			draw_circle(c, radius, color_unexplored)
			draw_arc(c, radius, 0.0, TAU, 16, Color(0, 0, 0, 0.5), 1.0)
			continue

		var cleared: bool = bool(data.get("cleared", false))
		var hostile: bool = bool(data.get("hostile", false))
		var type: int = int(data.get("type", 0))

		var fill: Color = _display_color_for(_color_for_type(type), hostile, cleared)
		draw_circle(c, radius, fill)
		draw_arc(c, radius, 0.0, TAU, 16, Color(0, 0, 0, 0.65), 1.0)

		_draw_room_icon(c, radius, type)

		if grid == current:
			var a: float = 0.55 + 0.45 * sin(_pulse)
			var hl := color_current
			hl.a = a
			draw_arc(c, radius + 3.0, 0.0, TAU, 20, hl, 2.0)

	if _generator.has_method("is_stage_cleared") and _generator.is_stage_cleared():
		var font := ThemeDB.fallback_font
		var txt := "STAGE CLEAR"
		draw_string(font, Vector2(0.0, size.y - 4.0), txt,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, color_treasure)


## "voll hell" (die reine Typ-Farbe) heisst jetzt "sicher/gecleart". Ein
## Kampf- oder Bossraum, dessen Kampf noch laeuft (hostile UND NICHT
## cleared), wird stattdessen Richtung color_uncleared_tint gedaempft - die
## Rueckmeldung wollte genau diese Unterscheidung statt eines separaten
## Haekchen-Symbols. Nicht-hostile Raeume (Korridor, Start, Schatz, ...)
## haben kein Kampf-Gate und zeigen deshalb immer ihre volle Farbe.
func _display_color_for(base: Color, hostile: bool, cleared: bool) -> Color:
	if hostile and not cleared:
		return base.lerp(color_uncleared_tint, uncleared_dim_strength)
	return base


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
## rotiert, NICHT die Zelle selbst. Bei Mehrzellen-Raeumen (footprint > 1x1)
## bleibt das die ANKERZELLE, nicht die geometrische Mitte der Gesamtflaeche
## - fuer einen einzelnen Punkt (statt frueher eines flaechendeckenden
## Rechtecks) ist der Unterschied vernachlaessigbar, macht die Rechnung aber
## deutlich einfacher.
func _cell_center(grid: Vector2i, current: Vector2i, center: Vector2, pitch: float) -> Vector2:
	var d := grid - current
	var offset := Vector2(float(d.x) * pitch, float(d.y) * pitch)
	return center + _rotate(offset)


## Zeichnet das Typ-Icon fuer Spezialraeume in die Mitte des Punkts.
## Bewusst als Vektor-Form (draw_circle/draw_colored_polygon) statt als
## Text-Glyph: ThemeDB.fallback_font deckt Symbol-Unicode-Bloecke (Krone/
## Totenkopf) nicht zuverlaessig ab, ein Vektor-Icon rendert dagegen
## garantiert unabhaengig von Font-Glyphabdeckung - passt ausserdem zum Rest
## des Projekts, das durchgehend auf Primitiv-Formen statt importierter
## Texturen setzt.
func _draw_room_icon(center: Vector2, radius: float, type: int) -> void:
	match type:
		RoomData.RoomType.TREASURE:
			_draw_crown_icon(center, radius)
		RoomData.RoomType.BOSS:
			_draw_skull_icon(center, radius)
		RoomData.RoomType.START:
			_draw_glyph(center, radius, "S")
		RoomData.RoomType.SHOP:
			_draw_glyph(center, radius, "?")


func _draw_glyph(center: Vector2, radius: float, glyph: String) -> void:
	var font := ThemeDB.fallback_font
	var fs: int = int(radius * 1.5)
	var text_size: Vector2 = font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	draw_string(font, center + Vector2(-text_size.x * 0.5, text_size.y * 0.35), glyph,
		HORIZONTAL_ALIGNMENT_CENTER, text_size.x, fs, color_text)


## Einfache Kronen-Silhouette: Basis-Balken + drei Zacken mit "Edelstein"-
## Punkten an den Spitzen.
func _draw_crown_icon(center: Vector2, r: float) -> void:
	var base_top: float = r * 0.15
	var base_bottom: float = r * 0.55
	var base: PackedVector2Array = [
		center + Vector2(-r * 0.85, base_bottom), center + Vector2(r * 0.85, base_bottom),
		center + Vector2(r * 0.85, base_top), center + Vector2(-r * 0.85, base_top),
	]
	draw_colored_polygon(base, color_text)

	var spikes: PackedVector2Array = [
		center + Vector2(-r * 0.85, base_top),
		center + Vector2(-r * 0.6, -r * 0.7),
		center + Vector2(-r * 0.3, -r * 0.05),
		center + Vector2(0.0, -r * 0.9),
		center + Vector2(r * 0.3, -r * 0.05),
		center + Vector2(r * 0.6, -r * 0.7),
		center + Vector2(r * 0.85, base_top),
	]
	draw_colored_polygon(spikes, color_text)

	for entry in [[-r * 0.6, -r * 0.7], [0.0, -r * 0.9], [r * 0.6, -r * 0.7]]:
		draw_circle(center + Vector2(entry[0], entry[1]), r * 0.13, color_treasure)


## Einfacher Totenkopf: Schaedel-Kreis + zwei dunkle Augenhoehlen + Kiefer.
func _draw_skull_icon(center: Vector2, r: float) -> void:
	draw_circle(center + Vector2(0.0, -r * 0.1), r * 0.78, color_text)
	draw_circle(center + Vector2(-r * 0.3, -r * 0.15), r * 0.16, color_boss)
	draw_circle(center + Vector2(r * 0.3, -r * 0.15), r * 0.16, color_boss)

	var jaw: PackedVector2Array = [
		center + Vector2(-r * 0.32, r * 0.35), center + Vector2(r * 0.32, r * 0.35),
		center + Vector2(r * 0.22, r * 0.68), center + Vector2(-r * 0.22, r * 0.68),
	]
	draw_colored_polygon(jaw, color_text)
