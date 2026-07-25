extends Node
class_name RoomGridGenerator

## Isaac-artiger Grid-Layout-Generator: erzeugt zunaechst NUR eine reine
## Datenstruktur (welche Grid-Zelle hat welchen Raumtyp und welche
## Tuer-Richtungen zu Nachbarn), ohne irgendeine Szene zu instanzieren.
## Das erlaubt es, das exakt gleiche Muster in einer spaeteren Ebene
## wiederzuverwenden (siehe LevelGenerator.generate_next_stage_same_pattern):
## nur WELCHE konkrete Raum-Szene + Gegner reinkommen wird neu gewuerfelt.

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
	var exit_flags: int = 0  # Bitmask aus DIRECTION_FLAG - welche Nachbarn existieren

## Wie viele Zellen (zusaetzlich zum Startraum) erzeugt werden sollen.
@export var target_room_count: int = 9

## Wahrscheinlichkeit, dass eine reine Durchgangszelle (genau 2
## gegenueberliegende Verbindungen) zum Korridor statt zum Kampfraum wird.
@export_range(0.0, 1.0) var corridor_chance: float = 0.5

## Der Bossraum wird mindestens so viele Grid-Schritte vom Start entfernt
## platziert. Verhindert "Boss direkt neben der Tuer".
@export var boss_min_distance: int = 2

func generate_layout() -> Dictionary:
	var cells: Dictionary = {}  # Vector2i -> RoomCell

	var start_cell := RoomCell.new()
	start_cell.grid_pos = Vector2i.ZERO
	start_cell.room_type = RoomData.RoomType.START
	cells[Vector2i.ZERO] = start_cell

	var frontier: Array[Vector2i] = [Vector2i.ZERO]
	var placed: int = 0
	# Sicherheitsnetz gegen Endlosschleifen, falls frontier nie leer wird
	# (kann bei kuenftigen Aenderungen an der Expansionslogik passieren).
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
	return cells

func _link_neighbors(cells: Dictionary, from_pos: Vector2i, to_pos: Vector2i, dir: String) -> void:
	var from_cell: RoomCell = cells[from_pos]
	var to_cell: RoomCell = cells[to_pos]
	from_cell.exit_flags |= DIRECTION_FLAG[dir]
	to_cell.exit_flags |= DIRECTION_FLAG[OPPOSITE[dir]]

func _place_special_rooms(cells: Dictionary) -> void:
	# Boss- und Treasure-Raeume kommen an "Dead Ends" (genau 1 Verbindung).
	# Boss bevorzugt den vom Start am weitesten entfernten Dead End.
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
		# Fallback: kein passender Dead End (z.B. ringfoermiges Layout).
		# Dann nimmt der Boss einfach die am weitesten entfernte Zelle -
		# ein Level ohne Bossraum waere schlimmer als einer mit 2 Tueren.
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

func _place_corridors(cells: Dictionary) -> void:
	# Zellen mit genau 2 gegenueberliegenden Verbindungen (reiner
	# Durchgang) werden mit corridor_chance als CORRIDOR statt COMBAT
	# markiert. Die exit_flags sind dann garantiert entweder
	# NORTH|SOUTH (3) oder EAST|WEST (12) - passend zu den beiden
	# gerichteten Korridor-Varianten im Pool.
	for pos in cells.keys():
		var cell: RoomCell = cells[pos]
		if cell.room_type != RoomData.RoomType.COMBAT:
			continue
		var flags: int = cell.exit_flags
		var is_straight_through: bool = (flags == (DIRECTION_FLAG[NORTH] | DIRECTION_FLAG[SOUTH])) \
			or (flags == (DIRECTION_FLAG[EAST] | DIRECTION_FLAG[WEST]))
		if is_straight_through and randf() < corridor_chance:
			cell.room_type = RoomData.RoomType.CORRIDOR

func _manhattan(pos: Vector2i) -> int:
	return absi(pos.x) + absi(pos.y)

func _count_flags(flags: int) -> int:
	var count: int = 0
	for i in range(4):
		if flags & (1 << i) != 0:
			count += 1
	return count
