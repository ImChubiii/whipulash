# res://scenes/level_generation/room_grid_generator.gd
extends Node
class_name RoomGridGenerator

## Isaac-artiger Grid-Layout-Generator: erzeugt NUR eine Datenstruktur, keine
## Szenen. Dadurch kann dasselbe Muster in einer spaeteren Etage mit anderen
## Raeumen/Gegnern wiederverwendet werden.
##
## VERSCHACHTELTE MAP:
##  1. Zwischen Kampfraeumen werden gezielt KORRIDOR-Zellen erzwungen
##     (min_connectors). Die Korridor-Templates sind nur 20 statt 48 Einheiten
##     breit, aber volle 48 lang - dadurch entsteht der "schmaler Gang
##     zwischen zwei Arenen"-Rhythmus und ein Delay zwischen zwei Kaempfen.
##  2. Jede Zelle bekommt eine HOEHENSTUFE (elevation). Geaendert wird die
##     Hoehe ausschliesslich INNERHALB eines Korridors: der Gang bekommt eine
##     Rampe (slope_delta = +1 / -1 / 0). Der LevelGenerator setzt die Raeume
##     danach auf unterschiedliche Y-Hoehen ab.
##
## Das Layout ist ein BAUM (Zellen werden nur beim Erzeugen verbunden, es
## entstehen keine Ringe). Deshalb ist die Hoehenverteilung ueber eine
## einfache BFS ab dem Startraum immer widerspruchsfrei.
##
## ############################################################################
## PHASE 3.1 — MULTI-ZELLEN-RAEUME
## ############################################################################
## Ein Raum darf mehr als eine Rasterzelle belegen (1x2, 2x1, 2x2). Das laeuft
## als NACHGELAGERTER Schritt (_assign_footprints), nicht waehrend des
## Baumwachstums — und das ist der entscheidende Entwurfspunkt:
##
##   * Waehrend des Wachstums wuerde ein 2x2-Raum vier Frontier-Positionen auf
##     einmal verbrauchen und die Verzweigung des Baums kaputtmachen; das
##     Layout waere ein Schlauch.
##   * NACHTRAEGLICH ist jede Erweiterungszelle garantiert LEER (sonst
##     stuende dort schon ein Raum). Eine leere Zelle bringt keine eigenen
##     Ausgaenge mit.
##
## Daraus folgt die wichtigste Eigenschaft dieser Umsetzung: ein
## Multi-Zellen-Raum hat GENAU DIE AUSGAENGE SEINER ANKERZELLE, also hoechstens
## einen pro Himmelsrichtung. Damit funktioniert das bestehende Tuer-System
## (RoomInstance._doors_by_dir haelt eine Tuer je Richtung) unveraendert
## weiter; die Tuer muss nur ENTLANG der Wand verschoben werden, damit sie vor
## der Ankerzelle sitzt (RoomInstance.set_exit_offset).
##
## BEWUSST NICHT UMGESETZT: mehrere Tuer-Slots pro Aussenkante. Das verlangt
## einen Umbau von _doors_by_dir auf eine Liste und zieht sich durch
## get_door_state(), _seal_exit(), das Tuer-Protokoll und die Minimap.

const NORTH := "north"
const SOUTH := "south"
const EAST := "east"
const WEST := "west"

const DIRECTION_OFFSETS := {
	NORTH: Vector2i(0, -1),
	SOUTH: Vector2i(0, 1),
	EAST: Vector2i(1, 0),
	WEST: Vector2i(-1, 0),
}

const OPPOSITE := {
	NORTH: SOUTH,
	SOUTH: NORTH,
	EAST: WEST,
	WEST: EAST,
}

## Muss 1:1 mit RoomInstance.EXIT_* und RoomData.available_exits uebereinstimmen.
const DIRECTION_FLAG := {
	NORTH: 1,
	SOUTH: 2,
	EAST: 4,
	WEST: 8,
}

class RoomCell:
	var grid_pos: Vector2i
	var room_type: int = RoomData.RoomType.COMBAT
	var exit_flags: int = 0
	## Absolute Hoehenstufe der EINGANGSSEITE dieser Zelle.
	var elevation: int = 0
	## Nur bei Korridoren != 0: Hoehenunterschied, den die Rampe im Inneren
	## dieser Zelle ueberwindet.
	var slope_delta: int = 0
	## Richtung zur TIEFEREN/eingehenden Seite des Korridors.
	var slope_low_dir: String = ""

	## PHASE 3.1: Groesse in Rasterzellen. (1,1) = klassischer Einzelraum.
	var footprint: Vector2i = Vector2i.ONE
	## Alle Rasterpositionen, die dieser Raum belegt — inklusive grid_pos.
	## Wird von Minimap und LevelGenerator gelesen.
	var covered_cells: Array[Vector2i] = []

	## Mittelpunkt der belegten Flaeche in RASTER-Koordinaten (kann auf
	## halben Zellen liegen, z.B. (0.5, 0) bei einem 2x1-Raum). Der
	## LevelGenerator setzt den Raum genau dorthin ab.
	func center_offset() -> Vector2:
		return Vector2(float(footprint.x - 1) * 0.5, float(footprint.y - 1) * 0.5)

	func is_multi_cell() -> bool:
		return footprint.x > 1 or footprint.y > 1


@export var target_room_count: int = 9

## Wahrscheinlichkeit, dass eine reine Durchgangszelle zum Korridor wird.
@export_range(0.0, 1.0) var corridor_chance: float = 0.7

## Mindestanzahl Korridore. Wird notfalls durch Umwandeln geeigneter
## Durchgangszellen erzwungen.
@export var min_connectors: int = 3

## Wahrscheinlichkeit, dass ein Korridor eine Rampe statt eines geraden
## Ganges bekommt.
@export_range(0.0, 1.0) var slope_chance: float = 0.55

## Wie viele Hoehenstufen ueber/unter dem Startraum maximal erlaubt sind.
@export var max_elevation: int = 2
@export var min_elevation: int = -2

@export var boss_min_distance: int = 2

## Chance, dass ein Tresorraum als Sackgasse DIREKT am Startraum (0,0)
## platziert wird, statt wie sonst am weitesten entfernten passenden Punkt.
@export_range(0.0, 1.0) var treasure_start_adjacent_chance: float = 0.2

## Wie viele Tresorraeume pro Etage reserviert werden.
@export var treasure_room_count: int = 2

## --- PHASE 3.1: Multi-Zellen-Raeume ------------------------------------
## Wahrscheinlichkeit, dass ein geeigneter Kampfraum auf mehrere Zellen
## aufgeblasen wird.
@export_range(0.0, 1.0) var multi_cell_chance: float = 0.45

## Obergrenze, damit eine Etage nicht nur noch aus Grossraeumen besteht.
@export var max_multi_cell_rooms: int = 3

## Welche Grundflaechen ueberhaupt vorkommen duerfen. Fuer JEDE Groesse in
## dieser Liste muss mindestens EINE Raum-Szene mit passendem
## RoomData.footprint_cells im Pool liegen, sonst bricht _pick_room() ab.
@export var allowed_footprints: Array[Vector2i] = [
	Vector2i(2, 1),
	Vector2i(1, 2),
	Vector2i(2, 2),
]

## Sentinel fuer "keine Zelle gefunden". Vector2i kann nicht null sein, und
## Vector2i.ZERO ist der Startraum - also ein Wert, der im Grid niemals
## vorkommen kann.
const INVALID_POS := Vector2i(2147483647, 2147483647)

## Eigener RNG statt der globalen randf()/randi()/shuffle(). Siehe det_rng.gd:
## der globale RNG wird von Screen-Shake, Schadenszahlen und Gegner-KI
## mitbenutzt und ist deshalb fuer reproduzierbare Layouts unbrauchbar.
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

## PHASE 3.1: Rasterposition -> Ankerposition des Raums, der sie belegt.
## Enthaelt AUCH die Ankerzellen selbst (pos -> pos), damit eine einzige
## Abfrage reicht.
var _occupancy: Dictionary = {}


## run_seed = 0 bedeutet "egal" - dann wird einmalig gewuerfelt. Der
## LevelGenerator reicht hier immer den echten Run-Seed durch.
##
## PHASE 3.2: stage geht mit in die Seed-Ableitung ein. Ohne das haette jede
## Etage EXAKT dasselbe Layout — nur mit anderen Farben, was den Sinn der
## Themen-Ebenen zerstoert. Mit stage im Ableitungsschluessel bleibt der Run
## trotzdem vollstaendig reproduzierbar: derselbe Seed erzeugt dieselbe
## Abfolge von Etagen.
func generate_layout(run_seed: int = 0, stage: int = 1) -> Dictionary:
	if run_seed == 0:
		_rng.randomize()
	else:
		_rng.seed = DetRng.derive(run_seed, "layout:%d" % stage)

	_occupancy.clear()

	var cells: Dictionary = {}

	var start_cell := RoomCell.new()
	start_cell.grid_pos = Vector2i.ZERO
	start_cell.room_type = RoomData.RoomType.START
	cells[Vector2i.ZERO] = start_cell

	var frontier: Array[Vector2i] = [Vector2i.ZERO]
	var placed: int = 0
	var guard: int = 0
	var guard_limit: int = target_room_count * 50 + 100

	while placed < target_room_count and not frontier.is_empty():
		guard += 1
		if guard > guard_limit:
			push_warning("RoomGridGenerator: Abbruch nach %d Iterationen - Layout evtl. kleiner als target_room_count." % guard)
			break

		var current: Vector2i = frontier[_rng.randi_range(0, frontier.size() - 1)]
		var directions: Array = DIRECTION_OFFSETS.keys()
		DetRng.shuffle(directions, _rng)

		var expanded: bool = false
		for dir in directions:
			var next_pos: Vector2i = current + DIRECTION_OFFSETS[dir]
			if cells.has(next_pos):
				continue

			var new_cell := RoomCell.new()
			new_cell.grid_pos = next_pos
			new_cell.room_type = RoomData.RoomType.COMBAT
			cells[next_pos] = new_cell
			frontier.append(next_pos)

			_link_neighbors(cells, current, next_pos, dir)

			placed += 1
			expanded = true
			break

		if not expanded:
			frontier.erase(current)

	_place_special_rooms(cells)
	_place_corridors(cells)
	_plan_elevations(cells)
	_assign_footprints(cells)
	return cells


## PHASE 3.1: Rasterposition -> Ankerzelle des belegenden Raums.
## Liefert INVALID_POS, wenn die Position frei ist.
func get_occupant(pos: Vector2i) -> Vector2i:
	return _occupancy.get(pos, INVALID_POS)


## Die komplette Belegungstabelle. Der LevelGenerator reicht sie an die
## Minimap durch, damit dort die volle Flaeche eines Multi-Zellen-Raums
## aufgedeckt wird.
func get_occupancy() -> Dictionary:
	return _occupancy


func _link_neighbors(cells: Dictionary, from_pos: Vector2i, to_pos: Vector2i, dir: String) -> void:
	var from_cell: RoomCell = cells[from_pos]
	var to_cell: RoomCell = cells[to_pos]
	from_cell.exit_flags |= DIRECTION_FLAG[dir]
	to_cell.exit_flags |= DIRECTION_FLAG[OPPOSITE[dir]]


## ############################################################################
## PHASE 3.1 — Grundflaechen vergeben
## ############################################################################
## Laeuft NACH allem anderen. Fuer jeden Kampfraum wird gewuerfelt, ob er auf
## eine groessere Flaeche aufgeblasen wird; die Zusatzzellen muessen dabei
##
##   a) im Raster frei sein (kein anderer Raum steht dort),
##   b) noch nicht von einem anderen Multi-Zellen-Raum belegt sein.
##
## Beides zusammen garantiert die Ueberlappungsfreiheit, um die es in der
## Anforderung geht. Die Belegung wird in _occupancy festgehalten und
## gleichzeitig in cell.covered_cells gespiegelt — _occupancy fuer die
## schnelle Kollisionspruefung hier, covered_cells fuer alle Leser draussen.
##
## START, BOSS, TRESOR und KORRIDORE bleiben absichtlich einzellig:
##   * START und Sonderraeume sind Sackgassen mit genau einem Ausgang; ein
##     grosser Vorplatz davor braeuchte eine eigene Szene ohne Mehrwert.
##   * KORRIDORE sind per Definition schmal — ein 2x2-Korridor waere ein
##     Widerspruch in sich und wuerde auf der Minimap als Raum gelesen.
func _assign_footprints(cells: Dictionary) -> void:
	# Erst alle Einzelzellen eintragen, damit die Kollisionspruefung unten
	# von Anfang an vollstaendig ist.
	for pos in cells.keys():
		var cell: RoomCell = cells[pos]
		cell.footprint = Vector2i.ONE
		cell.covered_cells = [pos]
		_occupancy[pos] = pos

	if allowed_footprints.is_empty() or max_multi_cell_rooms <= 0:
		return

	var candidates: Array[Vector2i] = []
	for pos in cells.keys():
		if cells[pos].room_type == RoomData.RoomType.COMBAT:
			candidates.append(pos)
	DetRng.shuffle(candidates, _rng)

	var made: int = 0
	for anchor in candidates:
		if made >= max_multi_cell_rooms:
			break
		if _rng.randf() > multi_cell_chance:
			continue

		var sizes: Array = allowed_footprints.duplicate()
		DetRng.shuffle(sizes, _rng)

		for size in sizes:
			var footprint: Vector2i = size
			if footprint.x <= 0 or footprint.y <= 0:
				continue
			var area: Array[Vector2i] = _footprint_cells(anchor, footprint)
			if not _area_is_free(area, anchor):
				continue

			var cell: RoomCell = cells[anchor]
			cell.footprint = footprint
			cell.covered_cells = area
			for p in area:
				_occupancy[p] = anchor
			made += 1
			break


## Alle Rasterpositionen, die ein Raum mit dieser Grundflaeche ab der
## Ankerzelle belegt. Die Ankerzelle ist immer die Ecke mit den KLEINSTEN
## Koordinaten — das haelt die Umrechnung in Weltkoordinaten einfach und
## macht sie im LevelGenerator nachvollziehbar.
func _footprint_cells(anchor: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dx: int in range(footprint.x):
		for dy: int in range(footprint.y):
			result.append(anchor + Vector2i(dx, dy))
	return result


## true, wenn ALLE Zellen der Flaeche frei sind. Die Ankerzelle selbst ist
## natuerlich belegt (von sich) und wird deshalb ausgenommen.
func _area_is_free(area: Array[Vector2i], anchor: Vector2i) -> bool:
	for pos in area:
		if pos == anchor:
			continue
		if _occupancy.has(pos):
			return false
	return true


## Boss und Tresor duerfen NUR in echten Sackgassen liegen.
##
## WARUM: Ein Sonderraum wird von aussen ueber eine Hack-Tuer betreten. Die
## Innenseite ist per hack_exempt freigestellt, damit man wieder rauskommt.
## Hat der Raum aber ZWEI Ausgaenge, dann steht am zweiten von aussen eine
## Hack-Tuer, die nur freischaltet, wenn der Raum DAHINTER gecleared wird -
## aus Spielersicht: eine Tuer, die sich nicht oeffnen laesst.
##
## Die alte Fassung hat das nur BEVORZUGT und ist im Zweifel auf den
## entferntesten Raum ausgewichen. Jetzt wird eine Sackgasse notfalls
## ANGEBAUT. Das Layout bekommt dadurch ein bis zwei Zellen mehr als
## target_room_count; das ist gewollt.
func _place_special_rooms(cells: Dictionary) -> void:
	var boss_pos: Vector2i = _reserve_dead_end(cells, boss_min_distance, [])
	if boss_pos == INVALID_POS:
		# Zweiter Versuch ohne Mindestabstand - lieber ein naher Boss als ein
		# Boss mitten im Durchgangsverkehr.
		boss_pos = _reserve_dead_end(cells, 1, [])

	if boss_pos != INVALID_POS:
		cells[boss_pos].room_type = RoomData.RoomType.BOSS
	else:
		push_warning("RoomGridGenerator: Keine Sackgasse fuer den Bossraum gefunden und keine anbaubar - Layout ohne Boss!")

	# Boss und Tresor duerfen nicht am SELBEN Raum haengen. Beide sind zwar
	# korrekt je eine Sackgasse, aber wenn ihr einziger Nachbar derselbe Raum
	# ist, steht der Spieler in einer Vorkammer mit zwei Sondertueren
	# nebeneinander.
	var forbidden_anchors: Array[Vector2i] = []
	if boss_pos != INVALID_POS:
		var boss_anchor: Vector2i = _connected_neighbor(cells, boss_pos)
		if boss_anchor != INVALID_POS:
			forbidden_anchors.append(boss_anchor)

	# 35 %-Regel: bevorzugt eine Sackgasse DIREKT am Start, bevor auf die
	# alte "immer am weitesten entfernten Punkt"-Suche zurueckgefallen wird.
	#
	# MEHRERE TRESORRAEUME: jede bereits vergebene Position UND deren
	# Vorraum werden fuer die naechste Runde ausgeschlossen (exclude bzw.
	# forbidden_anchors), damit zwei Tresorraeume nicht dieselbe Zelle oder
	# denselben Vorraum wie der Boss oder ein bereits platzierter Tresor
	# teilen - gleicher Grund wie bei forbidden_anchors oben.
	var treasure_exclude: Array = [boss_pos]
	var placed_treasures: int = 0
	for i in range(treasure_room_count):
		var treasure_pos: Vector2i = INVALID_POS
		if _rng.randf() < treasure_start_adjacent_chance:
			treasure_pos = _reserve_dead_end_near_start(cells, treasure_exclude, forbidden_anchors)

		if treasure_pos == INVALID_POS:
			treasure_pos = _reserve_dead_end(cells, 1, treasure_exclude, forbidden_anchors)
		if treasure_pos == INVALID_POS and not forbidden_anchors.is_empty():
			# Lieber ein Tresor am Bossvorraum als gar keiner.
			treasure_pos = _reserve_dead_end(cells, 1, treasure_exclude, [])
		if treasure_pos == INVALID_POS:
			break  # Keine weitere passende Sackgasse mehr uebrig.

		cells[treasure_pos].room_type = RoomData.RoomType.TREASURE
		placed_treasures += 1
		treasure_exclude.append(treasure_pos)

		var treasure_anchor: Vector2i = _connected_neighbor(cells, treasure_pos)
		if treasure_anchor != INVALID_POS:
			forbidden_anchors.append(treasure_anchor)

	if placed_treasures < treasure_room_count:
		push_warning("RoomGridGenerator: Nur %d von %d Tresorraeumen platziert - keine weitere passende Sackgasse gefunden." % [placed_treasures, treasure_room_count])


## Der EINZIGE Nachbar einer Sackgasse.
func _connected_neighbor(cells: Dictionary, pos: Vector2i) -> Vector2i:
	if not cells.has(pos):
		return INVALID_POS
	var cell: RoomCell = cells[pos]
	for dir in DIRECTION_OFFSETS.keys():
		if cell.exit_flags & DIRECTION_FLAG[dir] == 0:
			continue
		var neighbor: Vector2i = pos + DIRECTION_OFFSETS[dir]
		if cells.has(neighbor):
			return neighbor
	return INVALID_POS


## Liefert eine Zelle mit GENAU EINEM Ausgang, die mindestens min_distance
## Schritte vom Start entfernt ist. Existiert keine, wird eine neue Zelle an
## die entfernteste passende Zelle angebaut.
func _reserve_dead_end(cells: Dictionary, min_distance: int, exclude: Array, forbidden_anchors: Array = []) -> Vector2i:
	# 1) Vorhandene Sackgassen, die weiteste zuerst.
	var candidates: Array[Vector2i] = []
	for pos in cells.keys():
		if pos == Vector2i.ZERO or exclude.has(pos):
			continue
		var cell: RoomCell = cells[pos]
		if cell.room_type != RoomData.RoomType.COMBAT:
			continue
		if _count_flags(cell.exit_flags) != 1:
			continue
		if _manhattan(pos) < min_distance:
			continue
		if not forbidden_anchors.is_empty() and forbidden_anchors.has(_connected_neighbor(cells, pos)):
			continue
		candidates.append(pos)

	if not candidates.is_empty():
		candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
			return _manhattan(a) > _manhattan(b)
		)
		return candidates[0]

	# 2) Nichts Passendes da -> eine Sackgasse anbauen.
	var anchors: Array = cells.keys()
	anchors.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return _manhattan(a) > _manhattan(b)
	)

	for anchor in anchors:
		var anchor_cell: RoomCell = cells[anchor]
		if anchor_cell.room_type == RoomData.RoomType.BOSS or anchor_cell.room_type == RoomData.RoomType.TREASURE:
			continue
		if forbidden_anchors.has(anchor):
			continue

		var directions: Array = DIRECTION_OFFSETS.keys()
		DetRng.shuffle(directions, _rng)

		for dir in directions:
			var new_pos: Vector2i = anchor + DIRECTION_OFFSETS[dir]
			if cells.has(new_pos) or exclude.has(new_pos):
				continue
			if _manhattan(new_pos) < min_distance:
				continue

			var new_cell := RoomCell.new()
			new_cell.grid_pos = new_pos
			new_cell.room_type = RoomData.RoomType.COMBAT
			cells[new_pos] = new_cell
			_link_neighbors(cells, anchor, new_pos, dir)
			return new_pos

	return INVALID_POS


## Fuer die 35 %-Regel: eine Sackgasse, die DIREKT am Startraum (0,0) haengt.
##
## Jede Zelle mit Manhattan-Distanz 1 von (0,0) kann waehrend des
## Baumwachstums NUR von (0,0) selbst erzeugt worden sein (alle anderen
## potenziellen Nachbarn liegen auf Distanz 2 und koennen zu dem Zeitpunkt
## noch nicht existieren) - eine dort gefundene Sackgasse haengt also
## garantiert direkt am Start, keine zusaetzliche Verbindungspruefung noetig.
func _reserve_dead_end_near_start(cells: Dictionary, exclude: Array, forbidden_anchors: Array = []) -> Vector2i:
	if forbidden_anchors.has(Vector2i.ZERO):
		return INVALID_POS

	# 1) Vorhandene Sackgasse direkt am Start.
	var candidates: Array[Vector2i] = []
	for dir in DIRECTION_OFFSETS.keys():
		var pos: Vector2i = Vector2i.ZERO + DIRECTION_OFFSETS[dir]
		if not cells.has(pos) or exclude.has(pos):
			continue
		var cell: RoomCell = cells[pos]
		if cell.room_type != RoomData.RoomType.COMBAT:
			continue
		if _count_flags(cell.exit_flags) != 1:
			continue
		candidates.append(pos)

	if not candidates.is_empty():
		return candidates[_rng.randi_range(0, candidates.size() - 1)]

	# 2) Nichts Passendes da -> direkt am Start anbauen, falls eine Richtung
	# frei ist.
	var directions: Array = DIRECTION_OFFSETS.keys()
	DetRng.shuffle(directions, _rng)

	for dir in directions:
		var new_pos: Vector2i = Vector2i.ZERO + DIRECTION_OFFSETS[dir]
		if cells.has(new_pos) or exclude.has(new_pos):
			continue

		var new_cell := RoomCell.new()
		new_cell.grid_pos = new_pos
		new_cell.room_type = RoomData.RoomType.COMBAT
		cells[new_pos] = new_cell
		_link_neighbors(cells, Vector2i.ZERO, new_pos, dir)
		return new_pos

	return INVALID_POS


## Durchgangszellen (genau 2 gegenueberliegende Verbindungen) werden zu
## Korridoren. Die exit_flags sind dann garantiert NORTH|SOUTH (3) oder
## EAST|WEST (12) - passend zu den beiden gerichteten Korridor-Varianten.
func _place_corridors(cells: Dictionary) -> void:
	var candidates: Array[Vector2i] = []

	for pos in cells.keys():
		var cell: RoomCell = cells[pos]
		if cell.room_type != RoomData.RoomType.COMBAT:
			continue
		var flags: int = cell.exit_flags
		var is_straight_through: bool = (flags == (DIRECTION_FLAG[NORTH] | DIRECTION_FLAG[SOUTH])) \
			or (flags == (DIRECTION_FLAG[EAST] | DIRECTION_FLAG[WEST]))
		if is_straight_through:
			candidates.append(pos)

	DetRng.shuffle(candidates, _rng)

	var made: int = 0
	for pos in candidates:
		if _rng.randf() < corridor_chance:
			cells[pos].room_type = RoomData.RoomType.CORRIDOR
			made += 1

	# Nachziehen, falls der Wuerfel zu geizig war.
	for pos in candidates:
		if made >= min_connectors:
			break
		if cells[pos].room_type == RoomData.RoomType.COMBAT:
			cells[pos].room_type = RoomData.RoomType.CORRIDOR
			made += 1


## Verteilt Hoehenstufen per BFS ab dem Startraum. Nur Korridore duerfen die
## Hoehe aendern - dadurch liegen die Tueren zweier benachbarter Raeume immer
## auf derselben Hoehe, und der Hoehenunterschied wird komplett von der Rampe
## im Gang geschluckt.
func _plan_elevations(cells: Dictionary) -> void:
	var visited: Dictionary = {}
	var queue: Array = [{"pos": Vector2i.ZERO, "elev": 0, "from": ""}]
	visited[Vector2i.ZERO] = true

	while not queue.is_empty():
		var job: Dictionary = queue.pop_front()
		var pos: Vector2i = job["pos"]
		var cell: RoomCell = cells[pos]
		cell.elevation = job["elev"]
		cell.slope_delta = 0
		cell.slope_low_dir = ""

		var outgoing_elev: int = cell.elevation

		if cell.room_type == RoomData.RoomType.CORRIDOR and job["from"] != "" and _rng.randf() < slope_chance:
			var delta: int = 1 if _rng.randf() < 0.5 else -1
			var target: int = cell.elevation + delta
			if target <= max_elevation and target >= min_elevation:
				cell.slope_delta = delta
				cell.slope_low_dir = job["from"]
				outgoing_elev = target

		for dir in DIRECTION_OFFSETS.keys():
			if cell.exit_flags & DIRECTION_FLAG[dir] == 0:
				continue
			var next_pos: Vector2i = pos + DIRECTION_OFFSETS[dir]
			if not cells.has(next_pos) or visited.has(next_pos):
				continue
			visited[next_pos] = true
			queue.append({"pos": next_pos, "elev": outgoing_elev, "from": OPPOSITE[dir]})


func _manhattan(pos: Vector2i) -> int:
	return absi(pos.x) + absi(pos.y)


func _count_flags(flags: int) -> int:
	var count: int = 0
	for i in range(4):
		if flags & (1 << i) != 0:
			count += 1
	return count
