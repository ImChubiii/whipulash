
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

## Bit -> Richtungsname, wie ihn RoomInstance.get_door_state() erwartet.
const DIR_NAME_BY_BIT := {
	1: "north",
	2: "south",
	4: "east",
	8: "west",
}

const OPPOSITE_DIR := {
	"north": "south",
	"south": "north",
	"east": "west",
	"west": "east",
}

@export var cell_px: float = 18.0
@export var gap_px: float = 4.0
@export var view_radius: int = 2
@export var show_unexplored_neighbors: bool = true

## ############################################################################
## PHASE 5.1 — SCHMALE KORRIDORE
## ############################################################################
## Anteil der Zellbreite, mit dem ein KORRIDOR quer zu seiner Laufrichtung
## gezeichnet wird. 1.0 = so breit wie ein Raum (altes Verhalten).
##
## WARUM DAS NOETIG WAR: im Level sind Korridore nur 20 statt 48 Einheiten
## breit, auf der Karte sahen sie aber aus wie vollwertige Raeume. Damit war
## der Rhythmus "Arena - Gang - Arena", der das Layout ausmacht, auf der
## Minimap unsichtbar; alle Zellen wirkten gleichwertig.
##
## Die Laufrichtung wird aus den exit_flags abgeleitet: Nord|Sued = senkrecht,
## Ost|West = waagerecht. Ein Korridor hat per Konstruktion immer genau diese
## beiden Muster (siehe RoomGridGenerator._place_corridors), ein Sonderfall
## fuer Ecken oder T-Stuecke ist also nicht noetig.
@export_range(0.2, 1.0) var corridor_width_factor: float = 0.42

## ############################################################################
## PHASE 3.1 — MULTI-ZELLEN-RAEUME
## ############################################################################
## Ein Raum, der mehrere Rasterzellen belegt, wird als EIN zusammenhaengendes
## Rechteck ueber die gesamte Flaeche gezeichnet - nicht als mehrere Quadrate
## nebeneinander. Sonst waere auf der Karte nicht zu erkennen, ob dort ein
## grosser Raum steht oder zwei kleine.
##
## Die Fugen zwischen den Zellen werden dabei mitgefuellt (gap_px), damit das
## Rechteck geschlossen wirkt.
@export var merge_multi_cell_rooms: bool = true

## Dreht NUR die Positionierung der Zellen/Tueren zueinander, damit das
## Layout zur kalibrierten 3D-Minimap passt. Buchstaben und Symbole
## bleiben davon unberuehrt. Falls die Karte nach dem Einbau spiegelverkehrt
## zur 3D-Ansicht wirkt: Vorzeichen umdrehen (+90 statt -90).
@export var overlay_rotation_degrees: float = -90.0

## --- Farbschema -------------------------------------------------------
## KEIN color_background mehr: das Grid hatte fruerher eine eigene,
## unabhaengige Hintergrundflaeche - das war die dritte Deckkraft neben
## Frame und 3D-Ansicht und erzeugte den sichtbaren "Kasten im Kasten".
## Das Overlay zeichnet jetzt nur noch Zellen/Durchgaenge/Text; der
## EINE Frame-Hintergrund (minimap.gd, Einstellung "Deckkraft") scheint
## darunter durch.
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
## Farbe eines OFFENEN Durchgangs.
##
## Deutlich gedaempfter als frueher (war 0.85/0.87/0.80 bei Alpha 0.9). Der
## alte Wert war heller als JEDE Raumfarbe — ein offener Gang leuchtete
## dadurch staerker als der Raum, zu dem er gehoert, und zog den Blick auf
## die unwichtigste Information der ganzen Karte. Ein offener Durchgang soll
## als LUECKE gelesen werden, nicht als Signal.
@export var color_door: Color = Color(0.42, 0.45, 0.40, 0.85)
## Durchgang zu einem noch NICHT betretenen Nachbarn: nur angedeutet
## (kuerzer + durchsichtiger), damit die Neugier/Fog-of-War erhalten
## bleibt, man aber trotzdem sieht "hier geht es weiter".
@export var color_door_unexplored_alpha: float = 0.5
## Verriegelte Tuer (Kampfraum noch nicht gecleared): schmaler Riegel in
## gedaempftem Rot statt offener Gang.
@export var color_door_locked: Color = Color(0.70, 0.28, 0.24, 0.95)
## Boss-/Treasure-Tuer, die noch NICHT gehackt werden darf.
@export var color_door_hack_locked: Color = Color(0.55, 0.45, 0.30, 0.9)
## Boss-/Treasure-Tuer, die JETZT gehackt werden kann - pulsiert.
@export var color_door_hack_ready: Color = Color(0.98, 0.80, 0.25, 1.0)
## Wie breit ein verriegelter Durchgang im Verhaeltnis zur Zelle
## gezeichnet wird (1.0 = so breit wie ein offener Gang).
@export_range(0.1, 1.0) var locked_door_width_factor: float = 0.42
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

	# Jeder Durchgang liegt zwischen ZWEI Zellen und wurde deshalb bisher
	# zweimal gezeichnet: einmal aus Sicht jeder Seite, an dieselbe Stelle,
	# mit derselben halbtransparenten Farbe.
	#
	# Zwei Fuellungen mit Alpha 0.9 uebereinander ergeben zusammen rund 0.99 —
	# offene Durchgaenge zwischen zwei besuchten Raeumen wurden dadurch fast
	# deckend und damit heller als alles andere auf der Karte. Genau das ist
	# das "Leuchten". Zusaetzlich flackerte es beim Betreten eines Raums,
	# weil in dem Moment aus einem einfach gezeichneten Durchgang (Nachbar
	# noch unbesucht, Alpha 0.45) ein doppelt gezeichneter wurde.
	#
	# Der Schluessel ist die SORTIERTE Zellenpaarung — so landen beide
	# Blickrichtungen auf demselben Eintrag.
	var drawn_passages: Dictionary = {}

	# PHASE 3.1: Zusatzzellen eines Multi-Zellen-Raums stehen NICHT in
	# get_map_cells() - dort liegt nur die Ankerzelle mit ihrem footprint.
	# Es gibt hier also nichts zu ueberspringen; das Rechteck der Ankerzelle
	# deckt die Flaeche bereits ab.

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

			var dir_name: String = DIR_NAME_BY_BIT[bit]
			var state: int = _door_state(grid, dir_name, exits, bit)
			if state == RoomInstance.DoorState.NONE:
				continue

			# BEIDSEITIGE Pruefung: ein Durchgang existiert nur, wenn AUCH
			# der Nachbarraum auf seiner Gegenseite eine Tuer hat. Ohne das
			# malte die Minimap Gaenge, die im Level an einer Wand enden.
			var neighbor_exits: int = int(cells[neighbor_grid].get("exits", 0))
			var opposite_bit: int = _bit_for_dir(OPPOSITE_DIR[dir_name])
			var neighbor_state: int = _door_state(
				neighbor_grid, OPPOSITE_DIR[dir_name], neighbor_exits, opposite_bit
			)
			if neighbor_state == RoomInstance.DoorState.NONE:
				continue

			var neighbor_data: Dictionary = cells[neighbor_grid]
			var neighbor_visited: bool = bool(neighbor_data.get("visited", false))
			# PHASE 3.1: Der Durchgang endet an der ZELLE, nicht am
			# Raum-Mittelpunkt. Das ist genau die Stelle, an der die Tuer im
			# Level sitzt (siehe LevelGenerator._apply_multi_cell_exit_offsets),
			# und deshalb auch die, die auf der Karte stimmen muss.
			var neighbor_center := _cell_center(neighbor_grid, current, center, pitch)

			# Sortiertes Schluesselpaar: (A,B) und (B,A) ergeben denselben
			# Eintrag, der Durchgang wird also genau einmal gefuellt.
			var key: String = _passage_key(grid, neighbor_grid)
			if drawn_passages.has(key):
				continue
			drawn_passages[key] = true

			# Der restriktivere der beiden Zustaende gewinnt - eine Seite
			# offen und die andere verriegelt heisst: man kommt nicht durch.
			_draw_passage(here_center, neighbor_center, cell_px, neighbor_visited,
				_stricter_state(state, neighbor_state))

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
		var rect := _rect_for_cell(data, grid, current, center, pitch, exits_of(data))

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


## Exit-Bitmaske einer Zelle. Kleiner Helfer, damit _rect_for_cell() nicht
## noch einen Parameter mehr braucht.
func exits_of(data: Dictionary) -> int:
	return int(data.get("exits", 0))


## ############################################################################
## Das Rechteck, mit dem eine Zelle gezeichnet wird.
## ############################################################################
## Deckt drei Faelle ab:
##   1. Normaler Raum      -> Quadrat von cell_px.
##   2. Korridor           -> quer zur Laufrichtung auf corridor_width_factor
##                            geschrumpft (Phase 5.1).
##   3. Multi-Zellen-Raum  -> ein Rechteck ueber die gesamte belegte Flaeche,
##                            inklusive der Fugen dazwischen (Phase 3.1).
##
## Fall 2 und 3 schliessen sich gegenseitig aus: Korridore bleiben laut
## RoomGridGenerator._assign_footprints() immer einzellig.
##
## ROTATION: das Rechteck selbst bleibt achsenparallel, damit Glyphen aufrecht
## stehen. Bei overlay_rotation_degrees = -90 vertauschen sich aber Breite und
## Hoehe auf dem Bildschirm — deshalb wird die Ausdehnung ueber die rotierten
## Eckpunkte bestimmt statt ueber die Rasterachsen direkt.
func _rect_for_cell(
		data: Dictionary,
		grid: Vector2i,
		current: Vector2i,
		center: Vector2,
		pitch: float,
		exits: int
) -> Rect2:
	var c: Vector2 = _cell_center(grid, current, center, pitch)
	var type: int = int(data.get("type", 0))

	# --- Fall 3: Multi-Zellen-Raum ---------------------------------------
	var footprint: Vector2i = data.get("footprint", Vector2i.ONE)
	if merge_multi_cell_rooms and (footprint.x > 1 or footprint.y > 1):
		# Mittelpunkt der Flaeche statt der Ankerzelle.
		var half: Vector2 = Vector2(float(footprint.x - 1) * 0.5, float(footprint.y - 1) * 0.5)
		var shifted: Vector2 = c + _rotate(Vector2(half.x * pitch, half.y * pitch))
		# Volle Ausdehnung inkl. Fugen: n Zellen + (n-1) Luecken.
		var span := Vector2(
			float(footprint.x) * cell_px + float(footprint.x - 1) * gap_px,
			float(footprint.y) * cell_px + float(footprint.y - 1) * gap_px
		)
		var rotated_span: Vector2 = _rotate(span).abs()
		return Rect2(shifted - rotated_span * 0.5, rotated_span)

	# --- Fall 2: Korridor -------------------------------------------------
	if type == RoomData.RoomType.CORRIDOR:
		var narrow: float = cell_px * corridor_width_factor
		# Nord|Sued (1|2) = der Gang laeuft senkrecht durchs Raster, ist also
		# in RASTER-X schmal. Alles andere behandeln wir als waagerecht.
		var vertical: bool = (exits & 1) != 0 and (exits & 2) != 0
		var raw := Vector2(narrow, cell_px) if vertical else Vector2(cell_px, narrow)
		var span_c: Vector2 = _rotate(raw).abs()
		return Rect2(c - span_c * 0.5, span_c)

	# --- Fall 1: normaler Raum -------------------------------------------
	return Rect2(c - Vector2(cell_px, cell_px) * 0.5, Vector2(cell_px, cell_px))


## Eindeutiger Schluessel fuer ein Zellenpaar, unabhaengig von der
## Reihenfolge. Ohne die Sortierung waeren "(0,0)->(0,1)" und "(0,1)->(0,0)"
## zwei verschiedene Eintraege und die Deduplizierung liefe ins Leere.
func _passage_key(a: Vector2i, b: Vector2i) -> String:
	var first: Vector2i = a
	var second: Vector2i = b
	if b.x < a.x or (b.x == a.x and b.y < a.y):
		first = b
		second = a
	return "%d,%d|%d,%d" % [first.x, first.y, second.x, second.y]


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
func _draw_passage(here: Vector2, neighbor: Vector2, cell_size: float, neighbor_visited: bool, state: int) -> void:
	var delta: Vector2 = neighbor - here
	var horizontal: bool = absf(delta.x) >= absf(delta.y)
	var mid: Vector2 = (here + neighbor) * 0.5
	var far_point: Vector2 = neighbor if neighbor_visited else mid

	# SPOILER-SPERRE: Zu einem noch NICHT betretenen Nachbarn wird immer die
	# neutrale Tuerfarbe gezeichnet, nie die von Zustand oder Raumtyp.
	#
	# Vorher verriet die Karte den halben Grundriss, bevor man ihn gesehen
	# hatte: eine Tuer zum Schatzraum kam als goldener, pulsierender Riegel
	# heraus, eine Bossturm als brauner. Man musste also gar nicht erkunden —
	# ein Blick auf die Minimap sagte, in welcher Richtung das Item liegt und
	# wo der Boss wartet. Fog-of-War, der die Raeume verdeckt, aber ihre
	# Tueren durchscheinen laesst, ist kein Fog-of-War.
	#
	# Sobald der Nachbarraum betreten wurde, greift wieder die volle
	# Zustandsfarbe — dann ist die Information ja verdient.
	var fill: Color = _color_for_door_state(state) if neighbor_visited else color_door
	if not neighbor_visited:
		fill.a = fill.a * color_door_unexplored_alpha

	# Nur ein OFFENER Durchgang wird in voller Zellbreite gefuellt. Alles
	# Verriegelte wird bewusst SCHMALER gezeichnet, damit es sich optisch
	# klar als Riegel und nicht als Gang liest.
	#
	# Auch die BREITE bleibt bei unbesuchten Nachbarn neutral: ein schmal
	# gezeichneter Riegel haette denselben Hinweis gegeben wie die Farbe.
	var width: float = cell_size
	if neighbor_visited and state != RoomInstance.DoorState.OPEN:
		width = cell_size * locked_door_width_factor

	if horizontal:
		var min_x: float = minf(here.x, far_point.x)
		var max_x: float = maxf(here.x, far_point.x)
		var rect := Rect2(Vector2(min_x, here.y - width * 0.5), Vector2(max_x - min_x, width))
		draw_rect(rect, fill, true)
	else:
		var min_y: float = minf(here.y, far_point.y)
		var max_y: float = maxf(here.y, far_point.y)
		var rect := Rect2(Vector2(here.x - width * 0.5, min_y), Vector2(width, max_y - min_y))
		draw_rect(rect, fill, true)


## Fragt den ECHTEN Tuerzustand beim Generator ab.
##
## Faellt auf die alte Bitmaske zurueck, falls der Generator die Methode
## (noch) nicht kennt - so bleibt das Overlay auch mit einem aelteren
## LevelGenerator funktionsfaehig, statt gar nichts mehr zu zeichnen.
func _door_state(grid: Vector2i, dir: String, exits: int, bit: int) -> int:
	if _generator != null and is_instance_valid(_generator) and _generator.has_method("get_door_state"):
		return int(_generator.get_door_state(grid, dir))
	return RoomInstance.DoorState.OPEN if (exits & bit) != 0 else RoomInstance.DoorState.NONE


func _bit_for_dir(dir: String) -> int:
	for bit in DIR_NAME_BY_BIT.keys():
		if DIR_NAME_BY_BIT[bit] == dir:
			return bit
	return 0


## Reihenfolge von "am wenigsten begehbar" nach "offen". Der niedrigere
## Rang gewinnt, damit eine einseitig verriegelte Verbindung auch als
## verriegelt dargestellt wird.
func _stricter_state(a: int, b: int) -> int:
	var rank := {
		RoomInstance.DoorState.NONE: 0,
		RoomInstance.DoorState.LOCKED: 1,
		RoomInstance.DoorState.HACK_LOCKED: 2,
		RoomInstance.DoorState.HACK_READY: 3,
		RoomInstance.DoorState.OPEN: 4,
	}
	return a if int(rank.get(a, 4)) <= int(rank.get(b, 4)) else b


func _color_for_door_state(state: int) -> Color:
	match state:
		RoomInstance.DoorState.LOCKED:
			return color_door_locked
		RoomInstance.DoorState.HACK_LOCKED:
			return color_door_hack_locked
		RoomInstance.DoorState.HACK_READY:
			# Pulsiert im selben Takt wie die Markierung des aktuellen
			# Raums - signalisiert "hier kannst du JETZT etwas tun".
			var pulsing := color_door_hack_ready
			pulsing.a = color_door_hack_ready.a * (0.55 + 0.45 * sin(_pulse))
			return pulsing
	return color_door


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
