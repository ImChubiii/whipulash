extends Node
class_name RoomGridGenerator

## Isaac-artiger Grid-Layout-Generator: erzeugt NUR eine Datenstruktur,
## keine Szenen. Dadurch kann dasselbe Muster in einer spaeteren Etage
## mit anderen Raeumen/Gegnern wiederverwendet werden.
##
## NEU - VERSCHACHTELTE MAP:
##  1. Zwischen Kampfraeumen werden gezielt KORRIDOR-Zellen erzwungen
##     (min_connectors). Die Korridor-Templates sind nur 20 statt 48
##     Einheiten breit, aber volle 48 lang - dadurch entsteht der
##     "schmaler Gang zwischen zwei Arenen"-Rhythmus und ein Delay
##     zwischen zwei Kampfraeumen.
##  2. Jede Zelle bekommt eine HOEHENSTUFE (elevation). Geaendert wird
##     die Hoehe ausschliesslich INNERHALB eines Korridors: der Gang
##     bekommt eine Rampe (slope_delta = +1 Steigung / -1 Senkung / 0
##     gerade). Der LevelGenerator setzt die Raeume danach auf
##     unterschiedliche Y-Hoehen ab - die Map wirkt dadurch mehrstoeckig,
##     ohne dass Tueren aus der Flucht laufen.
##
## Das Layout ist ein BAUM (Zellen werden nur beim Erzeugen verbunden,
## es entstehen keine Ringe). Deshalb ist die Hoehenverteilung ueber eine
## einfache BFS ab dem Startraum immer widerspruchsfrei.

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
	## Nur bei Korridoren != 0: Hoehenunterschied, den die Rampe im
	## Inneren dieser Zelle ueberwindet.
	var slope_delta: int = 0
	## Richtung zur TIEFEREN/eingehenden Seite des Korridors.
	var slope_low_dir: String = ""

@export var target_room_count: int = 9

## Wahrscheinlichkeit, dass eine reine Durchgangszelle zum Korridor wird.
@export_range(0.0, 1.0) var corridor_chance: float = 0.7

## Mindestanzahl Korridore. Wird notfalls durch Umwandeln geeigneter
## Durchgangszellen erzwungen - "gut waere, wenn es schon paar mal ist".
@export var min_connectors: int = 3

## Wahrscheinlichkeit, dass ein Korridor eine Rampe statt eines geraden
## Ganges bekommt.
@export_range(0.0, 1.0) var slope_chance: float = 0.55

## Wie viele Hoehenstufen ueber/unter dem Startraum maximal erlaubt sind.
@export var max_elevation: int = 2
@export var min_elevation: int = -2

@export var boss_min_distance: int = 2


func generate_layout() -> Dictionary:
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

		var current: Vector2i = frontier[randi() % frontier.size()]
		var directions: Array = DIRECTION_OFFSETS.keys()
		directions.shuffle()

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
	return cells


func _link_neighbors(cells: Dictionary, from_pos: Vector2i, to_pos: Vector2i, dir: String) -> void:
	var from_cell: RoomCell = cells[from_pos]
	var to_cell: RoomCell = cells[to_pos]
	from_cell.exit_flags |= DIRECTION_FLAG[dir]
	to_cell.exit_flags |= DIRECTION_FLAG[OPPOSITE[dir]]


func _place_special_rooms(cells: Dictionary) -> void:
	var dead_ends: Array[Vector2i] = []
	for pos in cells.keys():
		if pos == Vector2i.ZERO:
			continue
		var cell: RoomCell = cells[pos]
		if _count_flags(cell.exit_flags) == 1:
			dead_ends.append(pos)

	dead_ends.sort_custom(func(a, b): return _manhattan(a) > _manhattan(b))

	var boss_pos: Vector2i = Vector2i.ZERO
	var boss_found: bool = false

	for pos in dead_ends:
		if _manhattan(pos) >= boss_min_distance:
			boss_pos = pos
			boss_found = true
			break

	if not boss_found:
		var farthest: int = -1
		for pos in cells.keys():
			if pos == Vector2i.ZERO:
				continue
			var d: int = _manhattan(pos)
			if d > farthest:
				farthest = d
				boss_pos = pos
				boss_found = true

	if boss_found:
		cells[boss_pos].room_type = RoomData.RoomType.BOSS
		dead_ends.erase(boss_pos)

	if not dead_ends.is_empty():
		var treasure_pos: Vector2i = dead_ends[randi() % dead_ends.size()]
		cells[treasure_pos].room_type = RoomData.RoomType.TREASURE


## Durchgangszellen (genau 2 gegenueberliegende Verbindungen) werden zu
## Korridoren. Die exit_flags sind dann garantiert NORTH|SOUTH (3) oder
## EAST|WEST (12) - passend zu den beiden gerichteten Korridor-Varianten
## im Pool. Falls der Zufall zu wenige liefert, wird nachgezogen, bis
## min_connectors erreicht ist.
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

	candidates.shuffle()

	var made: int = 0
	for pos in candidates:
		if randf() < corridor_chance:
			cells[pos].room_type = RoomData.RoomType.CORRIDOR
			made += 1

	# Nachziehen, falls der Wuerfel zu geizig war.
	for pos in candidates:
		if made >= min_connectors:
			break
		if cells[pos].room_type == RoomData.RoomType.COMBAT:
			cells[pos].room_type = RoomData.RoomType.CORRIDOR
			made += 1


## Verteilt Hoehenstufen per BFS ab dem Startraum. Nur Korridore duerfen
## die Hoehe aendern - dadurch liegen die Tueren zweier benachbarter
## Raeume immer auf derselben Hoehe, und der Hoehenunterschied wird
## komplett von der Rampe im Gang geschluckt.
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

		if cell.room_type == RoomData.RoomType.CORRIDOR and job["from"] != "" and randf() < slope_chance:
			var delta: int = 1 if randf() < 0.5 else -1
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
