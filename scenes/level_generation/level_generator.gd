extends Node
class_name LevelGenerator

const NAV_SOURCE_GROUP := "navmesh_source"
const GENERATOR_GROUP := "level_generator"

const DIR_KEYS := ["north", "south", "east", "west"]

## Muss 1:1 zu RoomInstance._FLAG_BY_KEY passen.
const DIR_FLAGS := {
	"north": 1,
	"south": 2,
	"east": 4,
	"west": 8,
}

const OPPOSITE_DIR := {
	"north": "south",
	"south": "north",
	"east": "west",
	"west": "east",
}
const DIR_OFFSETS := {
	"north": Vector2i(0, -1),
	"south": Vector2i(0, 1),
	"east": Vector2i(1, 0),
	"west": Vector2i(-1, 0),
}

@export var room_pool: Array[RoomData] = []
@export var current_stage: int = 1

@export var enemy_table: Array[EnemySpawnEntry] = []
@export var boss_table: Array[EnemySpawnEntry] = []

@export var cell_size: Vector3 = Vector3(48.0, 0.0, 48.0)

## Weltraum-Hoehe EINER Hoehenstufe aus dem RoomGridGenerator. Der Wert
## muss zur Rampenlaenge der Korridore passen: bei 48 Einheiten Ganglaenge
## sind 6.0 eine gut begehbare Steigung (ca. 7 Grad), 10.0 wird steil.
@export var elevation_step: float = 6.0

@export var grid_generator: RoomGridGenerator
@export var autostart: bool = true

@export var combat_threat_budget: int = 5
@export var corridor_threat_budget: int = 2
@export var boss_threat_budget: int = 12
@export var threat_per_stage: int = 2
@export var threat_hard_cap: int = 14

@export var navigation_region: NavigationRegion3D
@export var random_seed: int = 0

## --- Sieg-Trophaee ----------------------------------------------------
## Faellt in die Mitte des Bossraums, sobald der Boss besiegt ist.
## Aufsammeln loest den WinScreen aus (siehe victory_trophy.gd).
##
## Als PFAD statt als PackedScene-Export, damit ein fehlendes/verschobenes
## Asset nur eine Warnung erzeugt statt die ganze Generator-Szene beim
## Laden zu zerreissen.
@export var victory_trophy_scene_path: String = "res://scenes/victory_trophy.tscn"
@export var spawn_victory_trophy: bool = true
## Hoehe ueber dem Raumboden, auf der die Trophaee liegen bleibt.
@export var victory_trophy_ground_offset: float = 0.3

## --- Tuer-Debug-Protokoll ---------------------------------------------
## Schreibt nach jeder Generierung und bei jedem Raum-Clear eine komplette
## Uebersicht aller Tueren ins Log: Zustand, ob Marker und Tuer-Node da
## sind, ob die Gegenseite passt, und was die Tuer eingefaerbt hat.
##
## Zusaetzlich lassen sich die einzelnen Raeume ueber
## RoomInstance.debug_doors gespraechig schalten (wird von hier
## automatisch mitgesetzt).
@export var debug_doors: bool = true
## Nach jedem Raum-Clear erneut protokollieren.
@export var debug_doors_on_clear: bool = true

signal stage_generated(stage: int, room_count: int)
signal map_updated
signal stage_cleared(stage: int)

var _used_unique_rooms: Array[RoomData] = []
var _instances: Dictionary = {}
var _current_layout: Dictionary = {}
var _map_cells: Dictionary = {}
var _current_room: Vector2i = Vector2i.ZERO
var _stage_cleared: bool = false


func _ready() -> void:
	# --- Schutz gegen doppelte Generatoren --------------------------------
	# Zwei aktive LevelGenerator erzeugen ZWEI komplette Raumsaetze an
	# denselben Weltpositionen. Sichtbare Folgen: Tueren, die sich nicht
	# oeffnen lassen (die Tuer des zweiten Satzes blockiert die Oeffnung
	# des ersten, weil jeder Generator nur seinen EIGENEN Raumsatz
	# entriegelt), doppelte Gegner und Boss-Tueren, die je nach Satz mal
	# rot und mal normal eingefaerbt sind.
	#
	# Zu erkennen ist das im Log daran, dass "[LevelGenerator] _ready()"
	# ZWEIMAL erscheint. Statt das stillschweigend zu erzeugen, steigt der
	# zweite Generator hier hart aus und meldet sich deutlich.
	var existing: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if not existing.is_empty():
		push_error("[LevelGenerator] ABBRUCH: Es existiert bereits ein LevelGenerator ('%s') in der Szene. Dieser hier ('%s') generiert NICHT, sonst hingen zwei komplette Raumsaetze uebereinander. Bitte einen der beiden aus der Szene entfernen." % [existing[0].get_path(), get_path()])
		autostart = false
		set_process(false)
		return

	add_to_group(GENERATOR_GROUP)

	if random_seed != 0:
		seed(random_seed)
	else:
		randomize()

	if grid_generator == null:
		grid_generator = get_parent().get_node_or_null("RoomGridGenerator") as RoomGridGenerator

	if navigation_region == null:
		navigation_region = get_parent().get_node_or_null("NavigationRegion3D") as NavigationRegion3D
		if navigation_region == null:
			push_warning("[LevelGenerator] Keine NavigationRegion3D gefunden. Gegner fallen auf reines Direkt-Chasing zurueck.")

	print("[LevelGenerator] _ready() - autostart=%s, room_pool=%d, enemy_table=%d, boss_table=%d" % [autostart, room_pool.size(), enemy_table.size(), boss_table.size()])
	if autostart and grid_generator:
		call_deferred("generate_new_stage")
	elif autostart and grid_generator == null:
		push_error("[LevelGenerator] Kein RoomGridGenerator gefunden! Node muss 'RoomGridGenerator' heissen und Geschwister-Node sein, ODER im Inspector zugewiesen werden.")

# --- Oeffentliche API fuer die Minimap ------------------------------

func get_map_cells() -> Dictionary:
	return _map_cells

func get_current_room() -> Vector2i:
	return _current_room

func get_current_stage() -> int:
	return current_stage

func is_stage_cleared() -> bool:
	return _stage_cleared

## Echter Tuerzustand einer Zelle in einer Richtung - wird von der
## Minimap (minimap_rooms.gd) abgefragt, damit dort nur tatsaechlich
## vorhandene und tatsaechlich begehbare Durchgaenge als offen erscheinen.
func get_door_state(grid: Vector2i, dir: String) -> int:
	if not _instances.has(grid):
		return RoomInstance.DoorState.NONE
	var room: RoomInstance = _instances[grid]
	if not is_instance_valid(room):
		return RoomInstance.DoorState.NONE
	return room.get_door_state(dir)


func get_room_type_name(type: int) -> String:
	match type:
		RoomData.RoomType.START:
			return "START"
		RoomData.RoomType.COMBAT:
			return "COMBAT"
		RoomData.RoomType.CORRIDOR:
			return "CORRIDOR"
		RoomData.RoomType.TREASURE:
			return "TREASURE"
		RoomData.RoomType.BOSS:
			return "BOSS"
		RoomData.RoomType.SHOP:
			return "SHOP"
	return "UNKNOWN"

# --- Generierung ----------------------------------------------------

func generate_new_stage() -> void:
	_current_layout = grid_generator.generate_layout()
	print("[LevelGenerator] Layout generiert: %d Zellen" % _current_layout.size())
	_instantiate_layout(_current_layout)


func generate_next_stage_same_pattern() -> void:
	current_stage += 1
	_instantiate_layout(_current_layout)


func _instantiate_layout(layout: Dictionary) -> void:
	_clear_current_rooms()
	_used_unique_rooms.clear()
	_map_cells.clear()
	_stage_cleared = false
	_current_room = Vector2i.ZERO

	for grid_pos in layout.keys():
		var cell: RoomGridGenerator.RoomCell = layout[grid_pos]
		var data: RoomData = _pick_room(cell.room_type, cell.exit_flags)
		if data == null:
			continue

		# Hoehenstufe der Eingangsseite -> Welt-Y.
		var world_pos := Vector3(
			grid_pos.x * cell_size.x,
			cell.elevation * elevation_step,
			grid_pos.y * cell_size.z
		)
		var room := load_room(data, Transform3D(Basis.IDENTITY, world_pos))
		if room == null:
			continue

		room.grid_position = grid_pos
		room.apply_exit_flags(cell.exit_flags)

		# Korridor mit Hoehenunterschied -> Rampe im Inneren bauen und die
		# Tuer auf der hohen Seite entsprechend anheben.
		if cell.slope_delta != 0 and room.has_method("configure_slope"):
			room.configure_slope(cell.slope_low_dir, cell.slope_delta * elevation_step)

		var table: Array[EnemySpawnEntry] = _table_for_type(cell.room_type)
		var budget: int = _budget_for_type(cell.room_type)
		room.prepare_enemies(table, budget, current_stage)

		room.debug_doors = debug_doors
		room.room_entered.connect(_on_room_entered)
		room.room_cleared.connect(_on_room_cleared)

		_instances[grid_pos] = room
		_map_cells[grid_pos] = {
			"type": cell.room_type,
			"exits": cell.exit_flags,
			"elevation": cell.elevation,
			"visited": grid_pos == Vector2i.ZERO,
			"cleared": not room.requires_clear(),
			"hostile": room.requires_clear(),
		}

	_apply_door_kinds(layout)

	print("[LevelGenerator] %d/%d Raeume instanziert." % [_instances.size(), layout.size()])
	_rebake_navigation()
	stage_generated.emit(current_stage, _instances.size())
	map_updated.emit()

	if debug_doors:
		print_door_report("nach Generierung")


## Faerbt Tueren nach dem Raum, in den sie fuehren: Boss = rot,
## Treasure = goldgelb. Beide Sonderformen muessen gehackt werden.
## BUGFIX "Boss-Tuer ist manchmal nicht rot":
##
## Frueher wurde nur geprueft, ob im GRID ein Boss-Raum nebenan liegt
## (layout.has(neighbor_pos)) — NICHT, ob dorthin ueberhaupt ein Durchgang
## fuehrt. Zwei Fehler auf einmal:
##
##  1. ZU VIEL: Ein Raum, der im Grid neben dem Bossraum liegt aber gar
##     nicht mit ihm verbunden ist, bekam trotzdem eine rote Tuer — die
##     fuehrt dann ins Nichts.
##  2. ZU WENIG: Der Bossraum selbst wurde nie eingefaerbt. Wer von innen
##     oder ueber die andere Seite kam, sah eine normale Tuer. Genau das
##     "manchmal" aus dem Bugreport — es haengt davon ab, aus welcher
##     Richtung man ankommt.
##
## Jetzt wird die Verbindung ueber die exit_flags BEIDER Zellen verifiziert
## und die Tuer auf BEIDEN Seiten eingefaerbt.
func _apply_door_kinds(layout: Dictionary) -> void:
	for grid_pos in _instances.keys():
		var room: RoomInstance = _instances[grid_pos]
		if not room.has_method("set_door_kind"):
			continue

		var own_cell: RoomGridGenerator.RoomCell = layout.get(grid_pos)
		if own_cell == null:
			continue

		for dir in DIR_KEYS:
			var neighbor_pos: Vector2i = grid_pos + DIR_OFFSETS[dir]
			if not layout.has(neighbor_pos):
				continue

			# Es muss auf BEIDEN Seiten ein Ausgang gesetzt sein, sonst
			# gibt es hier keinen begehbaren Durchgang.
			var flag: int = DIR_FLAGS[dir]
			var opposite_flag: int = DIR_FLAGS[OPPOSITE_DIR[dir]]
			var neighbor: RoomGridGenerator.RoomCell = layout[neighbor_pos]

			if (own_cell.exit_flags & flag) == 0:
				continue
			if (neighbor.exit_flags & opposite_flag) == 0:
				continue

			# Sonderfarbe richtet sich danach, WOHIN die Tuer fuehrt —
			# ausser man steht selbst im Sonderraum, dann faerbt sich die
			# Tuer nach dem EIGENEN Raumtyp (Rueckweg bleibt erkennbar).
			var target_type: int = neighbor.room_type
			var is_inside_special: bool = (
				own_cell.room_type == RoomData.RoomType.BOSS
				or own_cell.room_type == RoomData.RoomType.TREASURE
			)
			if is_inside_special:
				target_type = own_cell.room_type

			# BUGFIX "im Bossraum eingesperrt":
			# Der Hack gatet den EINTRITT, nicht den Ausgang. Die Tuer auf
			# der INNENSEITE eines Sonderraums bleibt zwar rot/golden
			# eingefaerbt, wird aber vom Hack-Zwang freigestellt. Sonst
			# lehnt set_locked(false) beim Raum-Clear die Entriegelung ab
			# (Hack-Tueren gehen nur ueber einen abgeschlossenen Hack auf)
			# und der Spieler kommt nach dem Bosskampf nicht mehr raus.
			room.set_door_hack_exempt(dir, is_inside_special)

			match target_type:
				RoomData.RoomType.BOSS:
					room.set_door_kind(dir, Door.DoorKind.BOSS)
					# Von aussen: erst hackbar, wenn DIESER Raum (der davor)
					# leergeraeumt ist. Von innen ist der Hack ohnehin
					# freigestellt, das Flag ist dort nur noch Kosmetik.
					room.set_door_hack_enabled(dir, room.is_cleared() or is_inside_special)
				RoomData.RoomType.TREASURE:
					room.set_door_kind(dir, Door.DoorKind.TREASURE)
					room.set_door_hack_enabled(dir, true)


func _on_room_entered(room: RoomInstance) -> void:
	_current_room = room.grid_position
	if _map_cells.has(room.grid_position):
		_map_cells[room.grid_position]["visited"] = true
	map_updated.emit()


func _on_room_cleared(room: RoomInstance) -> void:
	if _map_cells.has(room.grid_position):
		_map_cells[room.grid_position]["cleared"] = true
		if _map_cells[room.grid_position]["type"] == RoomData.RoomType.BOSS:
			_stage_cleared = true
			stage_cleared.emit(current_stage)
			print("[LevelGenerator] Stage %d gecleared (Bossraum bei %s)." % [current_stage, room.grid_position])
			if spawn_victory_trophy:
				_spawn_victory_trophy(room)

	# Angrenzende Boss-Tuer freischalten - ab jetzt darf gehackt werden.
	for dir in DIR_KEYS:
		var neighbor_pos: Vector2i = room.grid_position + DIR_OFFSETS[dir]
		if not _current_layout.has(neighbor_pos):
			continue
		if _current_layout[neighbor_pos].room_type == RoomData.RoomType.BOSS:
			room.set_door_hack_enabled(dir, true)

	map_updated.emit()

	if debug_doors and debug_doors_on_clear:
		print_door_report("nach Clear von %s" % room.grid_position)

## Laesst die goldene Sieg-Trophaee in die Mitte des Bossraums fallen.
## Wird als Kind der aktuellen Szene (nicht des Raums) eingehaengt, damit
## sie einen Raumwechsel/Cleanup ueberlebt - der Raum selbst koennte beim
## Stage-Wechsel abgeraeumt werden.
func _spawn_victory_trophy(room: RoomInstance) -> void:
	var packed: PackedScene = load(victory_trophy_scene_path) as PackedScene
	if packed == null:
		push_warning("[LevelGenerator] Sieg-Trophaee nicht gefunden unter '%s' - Bossraum bleibt ohne Belohnung." % victory_trophy_scene_path)
		return

	var trophy: Node3D = packed.instantiate() as Node3D
	if trophy == null:
		push_warning("[LevelGenerator] '%s' hat keinen Node3D-Root." % victory_trophy_scene_path)
		return

	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(trophy)

	var center: Vector3 = room.get_room_center()
	center.y += victory_trophy_ground_offset
	trophy.global_position = center

	print("[LevelGenerator] Sieg-Trophaee gespawnt bei %s." % center)


# ============================================================================
# Tuer-Debug-Protokoll
# ============================================================================

## Schreibt eine vollstaendige Uebersicht aller Tueren ins Log.
##
## Geprueft wird pro Durchgang:
##   - Was sagt das LAYOUT (exit_flags beider Zellen)?
##   - Existiert im Raum ein ExitPoint-Marker und ein Door-Node?
##   - Welchen Zustand hat die Tuer wirklich?
##   - Passt die Gegenseite dazu?
##
## Jede Unstimmigkeit bekommt ein Praefix, damit man im Log danach filtern
## kann. Am Ende steht eine Zusammenfassung mit allen Problemfaellen.
func print_door_report(reason: String = "") -> void:
	var header: String = "===== TUER-PROTOKOLL"
	if reason != "":
		header += " (%s)" % reason
	print("%s =====" % header)
	print("Stage %d | %d Raeume | aktueller Raum: %s" % [current_stage, _instances.size(), _current_room])

	var problems: Array[String] = []
	var closed: Array[String] = []

	var sorted_keys: Array = _instances.keys()
	sorted_keys.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y != b.y:
			return a.y < b.y
		return a.x < b.x
	)

	for grid_pos in sorted_keys:
		var room: RoomInstance = _instances[grid_pos]
		if not is_instance_valid(room):
			problems.append("Raum %s: Instanz ungueltig!" % grid_pos)
			continue

		var cell: RoomGridGenerator.RoomCell = _current_layout.get(grid_pos)
		var type_name: String = get_room_type_name(cell.room_type) if cell != null else "?"
		var cleared_text: String = "gecleared" if room.is_cleared() else "%d Gegner aktiv" % room.get_active_enemy_count()

		print("  Raum %s [%s] - %s" % [grid_pos, type_name, cleared_text])

		for entry in room.get_door_report():
			var dir: String = entry["dir"]
			var state: int = entry["state"]
			var state_text: String = RoomInstance.door_state_name(state)
			var kind_text: String = _door_kind_name(entry["door_kind"])

			# Was sagt das Layout?
			var layout_says_exit: bool = false
			if cell != null:
				layout_says_exit = (cell.exit_flags & DIR_FLAGS[dir]) != 0

			# Was sagt die Gegenseite?
			var neighbor_pos: Vector2i = grid_pos + DIR_OFFSETS[dir]
			var neighbor_state: int = RoomInstance.DoorState.NONE
			var neighbor_exists: bool = _instances.has(neighbor_pos)
			if neighbor_exists:
				neighbor_state = get_door_state(neighbor_pos, OPPOSITE_DIR[dir])

			var hack_text: String = "-"
			if bool(entry.get("hack_needed", false)):
				hack_text = "noetig/frei" if entry["hack_enabled"] else "noetig/gesperrt"
			elif bool(entry.get("hack_exempt", false)):
				hack_text = "freigestellt"

			var line: String = "      %-6s %-14s Kind=%-8s Layout=%s Marker=%s Node=%s Hack=%-15s Nachbar=%s" % [
				dir.to_upper(),
				state_text,
				kind_text,
				"JA" if layout_says_exit else "nein",
				"JA" if entry["has_exit_marker"] else "NEIN",
				"JA" if entry["has_door_node"] else "NEIN",
				hack_text,
				RoomInstance.door_state_name(neighbor_state) if neighbor_exists else "kein Raum"
			]
			print(line)

			# --- Auffaelligkeiten sammeln ---
			if layout_says_exit and not entry["has_door_node"]:
				problems.append("Raum %s %s: Layout will Ausgang, aber KEIN Door-Node (Doors/Door%s fehlt in der Raum-Szene)." % [grid_pos, dir.to_upper(), dir.capitalize()])
			if layout_says_exit and not entry["has_exit_marker"]:
				problems.append("Raum %s %s: Layout will Ausgang, aber ExitPoint-Marker fehlt." % [grid_pos, dir.to_upper()])
			if layout_says_exit and neighbor_exists and neighbor_state == RoomInstance.DoorState.NONE:
				problems.append("Raum %s %s: Durchgang einseitig - Gegenseite in %s hat keine Tuer." % [grid_pos, dir.to_upper(), neighbor_pos])
			if state != RoomInstance.DoorState.NONE and state != RoomInstance.DoorState.OPEN:
				closed.append("Raum %s [%s] %s -> %s%s" % [
					grid_pos, type_name, dir.to_upper(), state_text,
					"" if room.is_cleared() else "  (Raum noch nicht gecleared: %d Gegner)" % room.get_active_enemy_count()
				])
			if neighbor_exists and state == RoomInstance.DoorState.OPEN and neighbor_state != RoomInstance.DoorState.OPEN and neighbor_state != RoomInstance.DoorState.NONE:
				problems.append("Raum %s %s: offen, aber Gegenseite in %s ist %s -> Durchgang trotzdem blockiert." % [grid_pos, dir.to_upper(), neighbor_pos, RoomInstance.door_state_name(neighbor_state)])
			# EINSPERR-FALLE: Sonderraum, dessen einziger Ausgang gehackt
			# werden muesste. set_locked(false) wuerde dort beim Clear
			# abgelehnt -> Spieler sitzt fest.
			if cell != null and bool(entry.get("hack_needed", false)):
				if cell.room_type == RoomData.RoomType.BOSS or cell.room_type == RoomData.RoomType.TREASURE:
					problems.append("Raum %s %s: EINSPERR-FALLE - Ausgang aus einem Sonderraum verlangt einen Hack. hack_exempt fehlt." % [grid_pos, dir.to_upper()])

	print("  --- GESCHLOSSENE TUEREN (%d) ---" % closed.size())
	if closed.is_empty():
		print("      keine")
	for c in closed:
		print("      %s" % c)

	print("  --- AUFFAELLIGKEITEN (%d) ---" % problems.size())
	if problems.is_empty():
		print("      keine")
	for pr in problems:
		print("      !! %s" % pr)

	print("===== ENDE TUER-PROTOKOLL =====")


func _door_kind_name(kind: int) -> String:
	match kind:
		Door.DoorKind.NORMAL: return "NORMAL"
		Door.DoorKind.BOSS: return "BOSS"
		Door.DoorKind.TREASURE: return "TRESOR"
	return "-"


# --- Gegner-Tabellen & Budget ---------------------------------------

func _table_for_type(type: int) -> Array[EnemySpawnEntry]:
	if type == RoomData.RoomType.BOSS:
		if not boss_table.is_empty():
			return boss_table
		return enemy_table
	if type == RoomData.RoomType.COMBAT or type == RoomData.RoomType.CORRIDOR:
		return enemy_table
	var empty: Array[EnemySpawnEntry] = []
	return empty


func _budget_for_type(type: int) -> int:
	var base: int = 0
	match type:
		RoomData.RoomType.COMBAT:
			base = combat_threat_budget
		RoomData.RoomType.CORRIDOR:
			base = corridor_threat_budget
		RoomData.RoomType.BOSS:
			base = boss_threat_budget
		_:
			return 0
	return clampi(base + (current_stage - 1) * threat_per_stage, 0, threat_hard_cap)

# --- Navigation ------------------------------------------------------

func _rebake_navigation() -> void:
	if navigation_region == null:
		return
	if navigation_region.navigation_mesh == null:
		push_error("[LevelGenerator] NavigationRegion3D hat keine NavigationMesh-Resource - Baking uebersprungen.")
		return
	await get_tree().process_frame
	await get_tree().physics_frame
	navigation_region.bake_navigation_mesh(false)
	print("[LevelGenerator] NavMesh gebakt (%d Quell-Nodes in '%s')." % [get_tree().get_nodes_in_group(NAV_SOURCE_GROUP).size(), NAV_SOURCE_GROUP])

# --- Raum-Auswahl ----------------------------------------------------

func _clear_current_rooms() -> void:
	for room in _instances.values():
		if is_instance_valid(room):
			var parent: Node = room.get_parent()
			if parent:
				parent.remove_child(room)
			room.queue_free()
	_instances.clear()


func _pick_room(type: int, required_exit_flags: int) -> RoomData:
	var candidates: Array[RoomData] = []
	for data in room_pool:
		if data == null or data.scene == null:
			continue
		if data.room_type != type:
			continue
		if data.min_stage > current_stage:
			continue
		if data.unique_per_run and data in _used_unique_rooms:
			continue
		if (data.available_exits & required_exit_flags) != required_exit_flags:
			continue
		candidates.append(data)

	if candidates.is_empty():
		push_error("LevelGenerator: Kein passender Raum fuer Typ %s (Exits %d) gefunden!" % [type, required_exit_flags])
		return null

	var chosen: RoomData = _weighted_pick(candidates)
	if chosen.unique_per_run:
		_used_unique_rooms.append(chosen)
	return chosen


func _weighted_pick(candidates: Array[RoomData]) -> RoomData:
	var total_weight: float = 0.0
	for c in candidates:
		total_weight += c.spawn_weight
	if total_weight <= 0.0:
		return candidates.pick_random()

	var roll: float = randf() * total_weight
	var accumulated: float = 0.0
	for c in candidates:
		accumulated += c.spawn_weight
		if roll <= accumulated:
			return c
	return candidates.back()


func load_room(data: RoomData, spawn_transform: Transform3D) -> RoomInstance:
	if data.scene == null:
		return null
	var instance: Node3D = data.scene.instantiate()

	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(instance)
	instance.global_transform = Transform3D(Basis.IDENTITY, spawn_transform.origin)

	var room := instance as RoomInstance
	if room == null:
		push_error("[LevelGenerator] Szene '%s' hat Root-Typ %s statt RoomInstance-Script!" % [data.scene.resource_path, instance.get_class()])
	return room
