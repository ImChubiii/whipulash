
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

## --- PHASE 3: Raumgroesse -----------------------------------------------
## Faktor, um den JEDE Raum-Szene beim Instanziieren skaliert wird — siehe
## load_room(). x/z = Grundriss (Breite/Tiefe), y = Hoehe. Alle Raum-Szenen
## sind fuer 48x48x14 gebaut; (2, 2, 2) macht daraus effektiv 96x96x28.
##
## War zuerst (3, 4, 3) - kam als "bisschen zu gross" zurueck. Jetzt
## einheitlich 2x auf allen drei Achsen, statt die Hoehe separat hoch zu
## halten: ohne erneute Erwaehnung eines eigenen Hoehenfaktors ist "gleich-
## maessig kleiner" die naheliegendere Lesart als "nur Grundriss kleiner,
## Decke bleibt bei 4x". Bei Bedarf einfach wieder unterschiedlich setzen,
## z.B. Vector3(2.0, 3.0, 2.0) fuer weiterhin hohe, aber weniger breite Raeume.
##
## WARUM SKALIEREN STATT JEDE RAUM-SZENE VON HAND NEU ZU BAUEN:
## Die Waende in room_combat_XX.tscn stehen als feste Transform3D/Size-Werte
## in der Szene - das von Hand auf "3x groesser" umzurechnen haette acht
## Szenendateien mit zusammen weit ueber hundert Einzelwerten bedeutet, jeder
## davon eine Fehlerquelle. RoomInstance baut EntryTrigger, PresenceArea,
## Decke und Tuerstuerze dagegen bereits PARAMETRISCH aus room_footprint/
## room_height (siehe room_instance.gd) - die skalieren also automatisch mit,
## wenn der ganze Raum-Node skaliert wird. Ein Node3D.scale auf dem
## instanziierten Raum-Root skaliert ALLES darunter (Waende, Boden, Lava,
## Spawn-Marker, NavigationObstacle3D) in einem Schritt konsistent mit.
##
## NEBENEFFEKT (bewusst in Kauf genommen): Wandstaerke skaliert mit derselben
## Achse wie die Wandlaenge (beide liegen in der Grundriss-Ebene), Waende
## werden also spuerbar dicker (1.0 -> 3.0 Einheiten). Bei der PSX-Optik
## dieses Spiels passt das eher zum Stil, als dass es stoert - falls nicht,
## ist das der erste Punkt, an dem man ansetzt.
## War Vector3(2.0, 2.0, 2.0) - Rueckmeldung "Raeume generell um ca. 15%
## verkleinern". cell_size/elevation_step werden unten in _apply_room_scale()
## direkt AUS diesem Wert abgeleitet (nicht separat gepflegt) - das
## Grid-System bleibt dadurch automatisch konsistent, es gibt keinen
## zweiten Ort, der von Hand synchron gehalten werden muesste.
@export var room_scale: Vector3 = Vector3(2.0, 2.0, 2.0) * 0.85

## Referenzgroesse EINER Raum-Szene bei room_scale = (1,1,1). Nicht aendern,
## ohne auch die Raum-Szenen selbst neu zu bauen - das hier ist die Basis,
## von der cell_size und elevation_step abgeleitet werden.
const BASE_CELL_SIZE: Vector3 = Vector3(48.0, 0.0, 48.0)
const BASE_ELEVATION_STEP: float = 6.0

## Wird in _ready() aus BASE_CELL_SIZE * room_scale berechnet - siehe
## _apply_room_scale(). Kein @export mehr: zwei unabhaengig editierbare
## Werte (Raumgroesse UND Zellenabstand), die von Hand synchron gehalten
## werden muessten, sind genau das Muster, das im HUD schon einmal zu einem
## "manchmal"-Bug gefuehrt hat (Minimap/Timer liefen auseinander, weil zwei
## Pixelwerte unabhaengig voneinander geaendert wurden). Hier ist derselbe
## Fehler strukturell ausgeschlossen.
var cell_size: Vector3 = BASE_CELL_SIZE

## Weltraum-Hoehe EINER Hoehenstufe aus dem RoomGridGenerator. Skaliert mit
## room_scale.y, damit die Rampen in Korridoren mit Hoehenunterschied bei
## der neuen, 4x hoeheren Raumdecke nicht unproportional flach wirken.
var elevation_step: float = BASE_ELEVATION_STEP

@export var grid_generator: RoomGridGenerator
@export var autostart: bool = true

## PHASE 3: von 5/2/12 auf grob das 3-Fache angehoben, damit ein Kampfraum
## bei jetzt 4x groesserer Grundflaeche (2x Breite * 2x Tiefe) nicht wie
## leergefegt wirkt.
## PHASE 4: nochmal verdoppelt (16 -> 32 / 6 -> 12) - explizit angefordert,
## unabhaengig von der Raumflaeche. Fighter kostet 3 Threat, Stinger 1
## (siehe es_fighter.tres / es_stinger.tres) - 32 heisst grob "6 Fighter +
## 14 Stinger" oder jede Mischung dazwischen.
@export var combat_threat_budget: int = 64
@export var corridor_threat_budget: int = 12
@export var boss_threat_budget: int = 12
@export var threat_per_stage: int = 2

## --- Stage-Skalierung der Gegnerstaerke -------------------------------
## threat_per_stage erhoeht bisher NUR die Anzahl. Ein Stinger in Etage 5
## hatte damit exakt dieselben 25 HP und 6 Schaden wie in Etage 1 - es
## wurden eben nur mehr davon. Weil der Spieler bis dahin staerker ist,
## fuehlen sich spaetere Etagen dadurch leichter an statt schwerer.
##
## Die Werte sind Zuwachs PRO ETAGE ab Etage 2:
##   0.30 = Etage 1: 100 %, Etage 2: 130 %, Etage 3: 160 % ...
## Der Deckel verhindert, dass ein langer Run in absurde Zahlen laeuft.
@export var enemy_health_per_stage: float = 0.30
@export var enemy_damage_per_stage: float = 0.18
@export var enemy_scaling_cap: float = 4.0
@export var threat_hard_cap: int = 64

## Eigener Deckel fuer den Bossraum. Ohne den wuerde threat_hard_cap (14)
## drei Colossus a 10 Threat sofort abwuergen - der dritte passt schlicht
## nicht mehr ins Budget. Den globalen Cap dafuer hochzuziehen ist keine
## Option: er begrenzt auch normale Kampfraeume in spaeteren Stages.
@export var boss_threat_hard_cap: int = 40

@export var navigation_region: NavigationRegion3D

## --- Fog of War auf der Minimap ---------------------------------------
## Die schematische Grid-Karte blendet unbekannte Raeume schon aus. Die
## 3D-Minimap zeigte dagegen die KOMPLETTE Etage, weil sie einfach eine
## zweite Kamera auf dieselbe Welt ist. Mit diesem Schalter werden Raeume,
## die weder betreten noch direkt hinter einer Tuer eines betretenen
## Raums liegen, fuer die Minimap-Kamera ausgeblendet - siehe
## RoomInstance.MINIMAP_HIDDEN_LAYER.
@export var minimap_fog_enabled: bool = true

## Startwert fuer den ganzen Run. 0 = beim Start einmal wuerfeln.
## Der TATSAECHLICH benutzte Wert steht danach in get_run_seed() und wird
## mit auf das Steam-Leaderboard geschrieben - nur so laesst sich ein
## fremder Run nachspielen.
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

## --- Rueckweg-Garantie nach dem Bosskampf -----------------------------
## Ein Durchgang besteht aus ZWEI Tueren - eine in jedem Raum. Beide
## muessen offen sein. Haengt der Nachbarraum noch in einem verriegelten
## Kampfzustand (Spieler ist rausgekommen, ohne ihn zu clearen), bleibt
## der Spieler nach dem Bosskampf im Bossraum stehen, obwohl dessen eigene
## Tuer sauber aufgeht. Im Tuer-Protokoll steht das dann als
## "offen, aber Gegenseite ist HACK GESPERRT -> Durchgang trotzdem
## blockiert".
##
## RoomInstance.reset_when_player_escapes verhindert diesen Zustand
## normalerweise schon. Das hier ist die zweite Sicherung: nach dem
## Boss-Clear werden die Tueren des Bossraums UND die jeweilige Gegenseite
## beim Nachbarn bedingungslos geoeffnet.
@export var unlock_boss_exit_on_clear: bool = true
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
## Feuert einmal, sobald der Run-Seed feststeht (HUD/Seed-Anzeige).
signal run_seed_ready(run_seed: int, seed_code: String)

var _used_unique_rooms: Array[RoomData] = []
var _instances: Dictionary = {}
var _current_layout: Dictionary = {}
var _map_cells: Dictionary = {}
var _current_room: Vector2i = Vector2i.ZERO
var _stage_cleared: bool = false
## PHASE 3.2: Thema der laufenden Etage.
var _stage_theme: StageTheme = null
## PHASE 3.1: Rasterposition -> Ankerzelle. Enthaelt auch die Anker selbst.
var _occupancy: Dictionary = {}

## Der wirklich verwendete Run-Seed (nie 0, sobald _ready() durch ist).
var _run_seed: int = 0
## RNG fuer die Raumauswahl. Bewusst getrennt vom Layout-RNG des
## RoomGridGenerators und vom Spawn-RNG der Raeume, damit eine Aenderung
## an einem der drei die anderen beiden nicht verschiebt.
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	# PHASE 3: cell_size/elevation_step aus room_scale ableiten, BEVOR
	# irgendetwas anderes in _ready() sie lesen koennte. Siehe Kommentar
	# bei den var-Deklarationen oben, warum das keine @export-Werte mehr sind.
	_apply_room_scale()

	# PHASE 3.2: Thema der Startetage festlegen, BEVOR generiert wird —
	# sonst laeuft Etage 1 ungefaerbt und erst ab Etage 2 greift das System.
	_stage_theme = StageTheme.for_stage(current_stage)
	# Rueckmeldung "wall tiles sehen nicht gut aus, bitte wieder die andere
	# Textur": wall_texture bleibt bewusst UNGESETZT, damit Waende wieder auf
	# die alte, texturlose Theme-Faerbung zurueckfallen (siehe is_wall-Zweig
	# in room_instance.gd::_apply_theme_recursive - greift nur, wenn
	# wall_texture != null ist). floor_texture (Karo fuer Boden/Decke) bleibt
	# unveraendert, dazu kam keine Beschwerde.
	_stage_theme.floor_texture = StageTheme.floor_ceiling_texture()

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

	# Run-Seed festnageln. Frueher wurde hier seed()/randomize() auf den
	# GLOBALEN RNG angewandt - das reicht fuer verifizierbare Runs nicht,
	# weil derselbe globale RNG auch von Screen-Shake, Schadenszahlen und
	# Gegner-KI benutzt wird (siehe det_rng.gd). Stattdessen bekommen
	# Layout, Raumauswahl und Gegner-Rolls eigene, abgeleitete RNGs.
	_run_seed = random_seed if random_seed != 0 else DetRng.random_seed_value()
	_rng.seed = DetRng.derive(_run_seed, "roompick")
	# Der globale RNG bleibt fuer reine Optik zustaendig und wird bewusst
	# unabhaengig vom Run-Seed gewuerfelt.
	randomize()
	print("[LevelGenerator] Run-Seed: %d (Code: %s)" % [_run_seed, DetRng.seed_to_code(_run_seed)])
	run_seed_ready.emit(_run_seed, DetRng.seed_to_code(_run_seed))

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


## PHASE 3.1: Rasterposition -> Ankerzelle des belegenden Raums. Die Minimap
## fuellt damit die komplette Flaeche eines Multi-Zellen-Raums auf.
func get_occupancy() -> Dictionary:
	return _occupancy

func get_current_room() -> Vector2i:
	return _current_room

func get_current_stage() -> int:
	return current_stage


## Der tatsaechlich verwendete Run-Seed - Grundlage fuer den
## Leaderboard-Eintrag und die Seed-Anzeige im HUD.
func get_run_seed() -> int:
	return _run_seed


## Teilbarer Kurzcode desselben Seeds ("4F2K9").
func get_run_seed_code() -> String:
	return DetRng.seed_to_code(_run_seed)

func is_stage_cleared() -> bool:
	return _stage_cleared


## PHASE 3: leitet cell_size und elevation_step aus room_scale ab, statt sie
## unabhaengig voneinander im Inspector pflegen zu lassen. Wird von _ready()
## aufgerufen, bevor irgendetwas generiert wird.
func _apply_room_scale() -> void:
	cell_size = Vector3(
		BASE_CELL_SIZE.x * room_scale.x,
		BASE_CELL_SIZE.y,
		BASE_CELL_SIZE.z * room_scale.z
	)
	elevation_step = BASE_ELEVATION_STEP * room_scale.y

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
	_current_layout = grid_generator.generate_layout(_run_seed, current_stage)
	print("[LevelGenerator] Layout generiert: %d Zellen (Etage %d)" % [_current_layout.size(), current_stage])
	_instantiate_layout(_current_layout)


func generate_next_stage_same_pattern() -> void:
	current_stage += 1
	_instantiate_layout(_current_layout)


## ############################################################################
## PHASE 3.2 — ETAGENWECHSEL
## ############################################################################
## Baut eine KOMPLETT NEUE Etage: neues Layout, neues Thema, staerkere Gegner.
## Wird vom StageManager (stage_manager.gd) gerufen.
##
## Unterschied zu generate_next_stage_same_pattern(): dort wird dasselbe
## Grundriss-Muster mit anderen Raeumen neu bestueckt. Hier wird auch das
## Muster neu gewuerfelt — der Seed geht mit der Etagennummer in die
## Ableitung ein (siehe RoomGridGenerator.generate_layout), der Run bleibt
## also trotzdem vollstaendig reproduzierbar.
##
## Der Spielerzustand wird hier BEWUSST NICHT ANGEFASST. Items, PlayerStats
## und PartyManager sind Autoloads und ueberleben, weil kein Szenenwechsel
## stattfindet.
func generate_stage(stage: int) -> void:
	current_stage = maxi(stage, 1)
	_stage_theme = StageTheme.for_stage(current_stage)
	_stage_theme.floor_texture = StageTheme.floor_ceiling_texture()
	print("[LevelGenerator] Baue Etage %d (Thema: %s)" % [current_stage, _stage_theme.theme_name])
	_current_layout = grid_generator.generate_layout(_run_seed, current_stage)
	_instantiate_layout(_current_layout)


## Weltposition, an der der Spieler in der neuen Etage abgesetzt wird.
##
## Bevorzugt den PlayerSpawnPoint der Startraum-Szene; ohne ihn die Raummitte.
## NIE Vector3.ZERO als Fallback: liegt der Startraum auf einer Hoehenstufe
## ungleich 0, faellt der Spieler sonst durch den Boden.
func get_start_room_spawn() -> Vector3:
	var start: RoomInstance = _instances.get(Vector2i.ZERO)
	if start == null or not is_instance_valid(start):
		return Vector3.ZERO

	var marker: Node3D = start.find_child("PlayerSpawnPoint", true, false) as Node3D
	if marker != null:
		return marker.global_position

	var center: Vector3 = start.get_room_center()
	center.y = start.global_position.y + 1.0
	return center


## Das aktuelle Thema der Etage. Die Minimap und der StageManager lesen hier.
func get_stage_theme() -> StageTheme:
	if _stage_theme == null:
		_stage_theme = StageTheme.for_stage(current_stage)
	return _stage_theme


func _instantiate_layout(layout: Dictionary) -> void:
	_clear_current_rooms()
	_used_unique_rooms.clear()
	_map_cells.clear()
	_stage_cleared = false
	_current_room = Vector2i.ZERO

	# PHASE 3.1: Belegungstabelle uebernehmen, damit Minimap und Fog-of-War
	# die volle Flaeche eines Multi-Zellen-Raums kennen.
	_occupancy.clear()
	if grid_generator.has_method("get_occupancy"):
		_occupancy = grid_generator.get_occupancy().duplicate()

	for grid_pos in layout.keys():
		var cell: RoomGridGenerator.RoomCell = layout[grid_pos]
		var data: RoomData = _pick_room(cell.room_type, cell.exit_flags, cell.footprint)
		if data == null:
			continue

		# BUGFIX "1x2-Raum zeigt sich als 1x1 auf Minimap/ingame":
		# _pick_room() faellt auf eine kleinere Vorlage zurueck, wenn der Pool
		# keine passende Groesse hat (siehe dortiger Kommentar). cell.footprint
		# blieb dabei bisher auf der urspruenglich reservierten, groesseren
		# Flaeche stehen - Minimap UND _map_cells haetten dann eine Flaeche
		# gemeldet, die der tatsaechlich instanzierte 1x1-Raum gar nicht
		# einnimmt. Deshalb hier korrigieren, BEVOR center_offset() und die
		# _map_cells-Eintraege weiter unten das Ergebnis benutzen.
		if data.footprint_cells != cell.footprint:
			cell.footprint = data.footprint_cells
			var fallback_covered: Array[Vector2i] = [grid_pos]
			cell.covered_cells = fallback_covered

		# PHASE 3.1: Ein Multi-Zellen-Raum sitzt in der MITTE seiner Flaeche,
		# nicht auf der Ankerzelle. center_offset() liefert die Verschiebung
		# in Rasterzellen — bei (2,1) also (0.5, 0), der Raum rueckt um eine
		# halbe Zelle nach Osten.
		var center_offset: Vector2 = cell.center_offset()
		var world_pos := Vector3(
			(float(grid_pos.x) + center_offset.x) * cell_size.x,
			cell.elevation * elevation_step,
			(float(grid_pos.y) + center_offset.y) * cell_size.z
		)
		var room := load_room(data, Transform3D(Basis.IDENTITY, world_pos))
		if room == null:
			continue

		room.grid_position = grid_pos
		if room.has_method("set_room_type"):
			room.set_room_type(cell.room_type)

		room.apply_exit_flags(cell.exit_flags)

		# PHASE 3.2: Thema der Etage auflegen.
		if _stage_theme != null and room.has_method("apply_theme"):
			room.apply_theme(_stage_theme)

		# Korridor mit Hoehenunterschied -> Rampe im Inneren bauen und die
		# Tuer auf der hohen Seite entsprechend anheben.
		#
		# BUGFIX "Stufe vor der Tuer / Rampe endet auf falscher Hoehe":
		#
		# load_room() setzt die Raum-Basis auf Basis.IDENTITY.scaled(room_scale).
		# ALLES, was configure_slope() im Raum baut (Rampe, Tuerhoehe,
		# ExitPoint, Waende), ist damit LOKAL und wird von Godot nochmal mit
		# room_scale.y multipliziert.
		#
		# elevation_step ist dagegen eine WELT-Groesse: world_pos.y oben nutzt
		# sie fuer den Raum-Ursprung, der NICHT mitskaliert wird.
		#
		# Wurde elevation_step ungefiltert weitergereicht, stieg die Rampe
		# elevation_step * room_scale.y Meter, der Nachbarraum lag aber nur
		# elevation_step hoeher. Bei room_scale.y = 2.0 und
		# BASE_ELEVATION_STEP = 6.0 sind das 24 statt 12 Weltmeter -> 12 Meter
		# Absatz exakt in der Tuer. Bei einem Gefaelle steht die Stufe direkt
		# am Tuerrahmen und ist gar nicht mehr begehbar.
		#
		# Deshalb wird der Hub hier in den LOKALEN Raum des Raumes
		# umgerechnet: local_rise * room_scale.y == elevation_step.
		if cell.slope_delta != 0 and room.has_method("configure_slope"):
			var local_rise: float = cell.slope_delta * elevation_step / maxf(room_scale.y, 0.001)
			room.configure_slope(cell.slope_low_dir, local_rise)

		# Jeder Raum bekommt seinen EIGENEN, aus Position und Stage
		# abgeleiteten Spawn-Seed. Wichtig: der Gegner-Roll passiert erst
		# beim BETRETEN des Raums. Haetten alle Raeume einen gemeinsamen
		# RNG, haenge das Ergebnis an der Reihenfolge, in der der Spieler
		# die Map ablaeuft - und der Seed waere wertlos.
		room.set_spawn_seed(DetRng.derive(_run_seed, "spawn:%d:%d:%d" % [grid_pos.x, grid_pos.y, current_stage]))

		var table: Array[EnemySpawnEntry] = _table_for_type(cell.room_type)
		var budget: int = _budget_for_type(cell.room_type, cell.footprint)
		room.prepare_enemies(table, budget, current_stage, cell.room_type == RoomData.RoomType.BOSS)

		room.debug_doors = debug_doors
		room.enemy_health_multiplier = get_enemy_health_multiplier()
		room.enemy_damage_multiplier = get_enemy_damage_multiplier()
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
			# PHASE 3.1: die Minimap zeichnet damit die volle Flaeche statt
			# eines Quadrats auf der Ankerzelle.
			"footprint": cell.footprint,
			"covered": cell.covered_cells.duplicate(),
		}

	_apply_door_kinds(layout)

	_refresh_minimap_fog()

	print("[LevelGenerator] %d/%d Raeume instanziert. Gegner-Skalierung: HP x%.2f, Schaden x%.2f" % [
		_instances.size(), layout.size(),
		get_enemy_health_multiplier(), get_enemy_damage_multiplier()
	])
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
					# BUGFIX "Hacking waehrend des Kampfs moeglich": galt bisher
					# bedingungslos, anders als der BOSS-Zweig direkt darueber.
					# Von aussen: erst hackbar, wenn DIESER Raum (der davor)
					# leergeraeumt ist - exakt dieselbe Bedingung wie bei BOSS.
					room.set_door_hack_enabled(dir, room.is_cleared() or is_inside_special)


func _on_room_entered(room: RoomInstance) -> void:
	_current_room = room.grid_position
	if _map_cells.has(room.grid_position):
		_map_cells[room.grid_position]["visited"] = true
	_refresh_minimap_fog()
	map_updated.emit()


func _on_room_cleared(room: RoomInstance) -> void:
	if _map_cells.has(room.grid_position):
		_map_cells[room.grid_position]["cleared"] = true
		if _map_cells[room.grid_position]["type"] == RoomData.RoomType.BOSS:
			_stage_cleared = true
			stage_cleared.emit(current_stage)
			print("[LevelGenerator] Stage %d gecleared (Bossraum bei %s)." % [current_stage, room.grid_position])
			if unlock_boss_exit_on_clear:
				_force_open_boss_exits(room)
			if spawn_victory_trophy:
				_spawn_victory_trophy(room)

	# Angrenzende Boss-/Tresor-Tuer freischalten - ab jetzt darf gehackt
	# werden. TREASURE muss hier GENAUSO behandelt werden wie BOSS: seit die
	# Tuer beim Anlegen nur noch bei room.is_cleared() freigeschaltet wird
	# (siehe _apply_door_kinds), bleibt sie sonst dauerhaft gesperrt, weil
	# der Raum zu dem Zeitpunkt noch nicht gecleared war.
	for dir in DIR_KEYS:
		var neighbor_pos: Vector2i = room.grid_position + DIR_OFFSETS[dir]
		if not _current_layout.has(neighbor_pos):
			continue
		var neighbor_type: int = _current_layout[neighbor_pos].room_type
		if neighbor_type == RoomData.RoomType.BOSS or neighbor_type == RoomData.RoomType.TREASURE:
			room.set_door_hack_enabled(dir, true)

	_refresh_minimap_fog()
	map_updated.emit()

	if debug_doors and debug_doors_on_clear:
		print_door_report("nach Clear von %s" % room.grid_position)

## Oeffnet nach dem Bosskampf jeden Durchgang des Bossraums auf BEIDEN
## Seiten. Der Nachbarraum darf danach weiterhin seine eigenen Gegner
## haben - der Spieler kann dann eben zurueck in einen laufenden Kampf,
## was deutlich besser ist als festzustecken.
func _force_open_boss_exits(room: RoomInstance) -> void:
	for dir in DIR_KEYS:
		if room.get_door_state(dir) == RoomInstance.DoorState.NONE:
			continue

		room.force_unlock_door(dir)

		var neighbor_pos: Vector2i = room.grid_position + DIR_OFFSETS[dir]
		if not _instances.has(neighbor_pos):
			continue
		var neighbor: RoomInstance = _instances[neighbor_pos]
		if not is_instance_valid(neighbor):
			continue
		neighbor.force_unlock_door(OPPOSITE_DIR[dir])


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

	# Farbe je Modus: GOLD nur auf der Etage, die den Run tatsaechlich beendet
	# (Speedrun hat final_stage = 1, ist also immer "die letzte"; im Normal-
	# Modus ist das erst Etage final_stage). Alle anderen Etagen bekommen eine
	# SCHWARZE Trophaee, die per Stages.advance_stage() in die naechste Etage
	# fuehrt statt den Run zu beenden (siehe victory_trophy.gd:_collect()).
	# Vor _ready() gesetzt (instantiate() ruft _ready() noch NICHT auf -
	# das passiert erst bei add_child() weiter unten), also baut
	# _build_visuals() das Mesh gleich mit der richtigen Farbe.
	var stages: Node = get_node_or_null("/root/Stages")
	var is_final_stage: bool = true
	if stages != null:
		var final_stage: int = int(stages.get("final_stage"))
		is_final_stage = final_stage > 0 and current_stage >= final_stage
	trophy.set("trophy_color", Color(1.0, 0.82, 0.22) if is_final_stage else Color(0.08, 0.08, 0.09))

	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(trophy)

	var center: Vector3 = room.get_room_center()
	center.y += victory_trophy_ground_offset

	# BUGFIX "Trophaee liegt unter dem Boden":
	# Frueher stand hier nur trophy.global_position = center. Das kam zu
	# SPAET - add_child() hat _ready() der Trophaee bereits ausgeloest, die
	# hat sich (0, 0, 0) als Landepunkt gemerkt und ihren Fall-Tween auf
	# "global_position:y -> 0.0" gestartet. Der Tween ueberschreibt die
	# Zuweisung hier im naechsten Frame wieder. Liegt der Bossraum auf einer
	# Hoehenstufe > 0 (hier Welt-Y 6.0), landet die Trophaee entsprechend
	# 6 Meter unter dem Bossraumboden.
	#
	# start_drop_at() setzt Position UND Landehoehe in einem Rutsch und
	# startet den Fall erst danach.
	if trophy.has_method("start_drop_at"):
		trophy.start_drop_at(center)
	else:
		trophy.global_position = center

	print("[LevelGenerator] Sieg-Trophaee gespawnt bei %s (Raum %s, Bodenhoehe %.1f)." % [center, room.grid_position, room.global_position.y])


## Faktor auf Health.max_health jedes gespawnten Gegners dieser Etage.
func get_enemy_health_multiplier() -> float:
	return clampf(1.0 + enemy_health_per_stage * float(current_stage - 1), 1.0, enemy_scaling_cap)


## Faktor auf die damage jeder Hitbox eines gespawnten Gegners.
func get_enemy_damage_multiplier() -> float:
	return clampf(1.0 + enemy_damage_per_stage * float(current_stage - 1), 1.0, enemy_scaling_cap)


# ============================================================================
# Fog of War (3D-Minimap)
# ============================================================================

## Sichtbar ist ein Raum, wenn er betreten wurde ODER wenn von einem
## betretenen Nachbarraum ein ECHTER Durchgang zu ihm fuehrt. "Echt"
## heisst beidseitig: beide Raeume muessen auf der gemeinsamen Seite eine
## Tuer haben. Ohne diese Pruefung wuerde ein Raum aufgedeckt, der im
## Grid zwar nebenan liegt, aber gar nicht verbunden ist.
##
## Bewusst dieselbe Regel wie im Grid-Overlay (minimap_rooms.gd), damit
## schematische Karte und 3D-Ansicht nicht unterschiedlich viel verraten.
func is_room_revealed(grid: Vector2i) -> bool:
	if not _map_cells.has(grid):
		# PHASE 3.1: Zusatzzelle eines Multi-Zellen-Raums -> der Anker
		# entscheidet. Ohne diese Umleitung waere die halbe Flaeche eines
		# grossen Raums dauerhaft im Nebel.
		var anchor: Vector2i = _occupancy.get(grid, grid)
		if anchor != grid and _map_cells.has(anchor):
			return is_room_revealed(anchor)
		return false
	if bool(_map_cells[grid].get("visited", false)):
		return true

	for dir in DIR_KEYS:
		var neighbor: Vector2i = grid + DIR_OFFSETS[dir]
		if not _map_cells.has(neighbor):
			continue
		if not bool(_map_cells[neighbor].get("visited", false)):
			continue
		if get_door_state(grid, dir) == RoomInstance.DoorState.NONE:
			continue
		if get_door_state(neighbor, OPPOSITE_DIR[dir]) == RoomInstance.DoorState.NONE:
			continue
		return true

	return false


## Schiebt jeden Raum auf den passenden Visual-Layer. RoomInstance
## verwirft Aufrufe ohne Zustandswechsel selbst, der Durchlauf ist also
## billig genug fuer jedes Betreten/Clearen.
func _refresh_minimap_fog() -> void:
	for grid_pos in _instances.keys():
		var room: RoomInstance = _instances[grid_pos]
		if not is_instance_valid(room):
			continue
		room.set_minimap_revealed(not minimap_fog_enabled or is_room_revealed(grid_pos))


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
	var hack_gates: Array[String] = []

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
				var neighbor_is_hack: bool = (
					neighbor_state == RoomInstance.DoorState.HACK_READY
					or neighbor_state == RoomInstance.DoorState.HACK_LOCKED
				)
				if neighbor_is_hack:
					# KEIN Fehler, sondern das gewollte Verhalten eines
					# Sonderraums: die Innenseite ist per hack_exempt offen,
					# die Aussenseite verlangt den Hack. Frueher landete
					# genau dieses Paar in den AUFFAELLIGKEITEN und hat das
					# Protokoll bei jedem Boss-/Tresorraum rot gefaerbt.
					hack_gates.append("Raum %s [%s] %s -> Gegenseite in %s: %s" % [
						grid_pos, type_name, dir.to_upper(), neighbor_pos,
						RoomInstance.door_state_name(neighbor_state)
					])
				else:
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

	print("  --- HACK-SPERREN (%d) ---" % hack_gates.size())
	if hack_gates.is_empty():
		print("      keine")
	for h in hack_gates:
		print("      %s" % h)

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


## footprint: Zellen-Grundflaeche des Raums (Vector2i.ONE = normaler 1x1-
## Raum). Rueckmeldung "grosse Raeume (2x1/2x2) wirken leer, wenn sie
## dasselbe Budget wie ein 1x1-Raum haben, obwohl sie deutlich mehr
## Grundflaeche haben" - skaliert Budget linear mit der Zellenanzahl, damit
## die Gegnerdichte pro Flaeche konstant bleibt.
func _budget_for_type(type: int, footprint: Vector2i = Vector2i.ONE) -> int:
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

	# WICHTIG: threat_hard_cap (64) ist standardmaessig GENAU gleich
	# combat_threat_budget (64) - ein normaler 1x1-Kampfraum sitzt in Stage 1
	# also schon exakt am Deckel. Wuerde NUR "base" mit der Zellenzahl
	# multipliziert, wuerde der unveraenderte Cap die Skalierung sofort
	# wieder auf den 1x1-Wert zurueckschneiden. Der Cap muss deshalb
	# GENAUSO skalieren wie das Budget selbst.
	var cell_count: int = maxi(footprint.x * footprint.y, 1)
	base *= cell_count
	var cap: int = (boss_threat_hard_cap if type == RoomData.RoomType.BOSS else threat_hard_cap) * cell_count

	# Die Stage-Steigerung bleibt bewusst UNSKALIERT (flacher Bonus,
	# unabhaengig von der Raumgroesse) - sie ist eine globale
	# Schwierigkeitskurve, keine flaechenabhaengige Groesse.
	return clampi(base + (current_stage - 1) * threat_per_stage, 0, cap)

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


## PHASE 3.1: footprint kam dazu. Eine Vorlage passt nur, wenn ihre
## footprint_cells EXAKT der geforderten Grundflaeche entsprechen — ein
## 1x1-Raum in eine 2x1-Luecke zu setzen wuerde die halbe Flaeche als Loch
## im Level stehen lassen.
##
## FALLBACK: findet sich nichts, wird auf (1,1) zurueckgefallen und die
## Zusatzzellen bleiben ungenutzt. Besser ein etwas leereres Layout als ein
## Abbruch mitten in der Generierung.
func _pick_room(type: int, required_exit_flags: int, footprint: Vector2i = Vector2i.ONE) -> RoomData:
	var candidates: Array[RoomData] = _collect_candidates(type, required_exit_flags, footprint)

	if candidates.is_empty() and (footprint.x > 1 or footprint.y > 1):
		push_warning("LevelGenerator: Keine %dx%d-Vorlage fuer Typ %s im Pool - falle auf 1x1 zurueck. Die Zusatzzellen bleiben leer." % [footprint.x, footprint.y, type])
		candidates = _collect_candidates(type, required_exit_flags, Vector2i.ONE)

	if candidates.is_empty():
		push_error("LevelGenerator: Kein passender Raum fuer Typ %s (Exits %d, Flaeche %dx%d) gefunden!" % [type, required_exit_flags, footprint.x, footprint.y])
		return null

	var chosen: RoomData = _weighted_pick(candidates)
	if chosen.unique_per_run:
		_used_unique_rooms.append(chosen)
	return chosen


func _collect_candidates(type: int, required_exit_flags: int, footprint: Vector2i) -> Array[RoomData]:
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
		if data.footprint_cells != footprint:
			continue
		candidates.append(data)
	return candidates


## ############################################################################
## PHASE 3.1 — WO DIE TUEREN EINES MULTI-ZELLEN-RAUMS SITZEN
## ############################################################################
## Der Raum steht in der MITTE seiner Flaeche, die Nachbarn haengen aber an der
## ANKERZELLE (die Ecke mit den kleinsten Koordinaten). Eine Tuer in der Mitte
## der langen Wand wuerde also gegen die Wand des Nachbarn laufen.
##
## GELOEST WIRD DAS IN DER RAUM-SZENE, NICHT HIER — und das ist der
## entscheidende Punkt:
##
##   Der Generator kann eine Tuer verschieben. Er kann die WANDLUECKE nicht
##   verschieben. Die Waende stehen als feste Transform3D-Werte in der .tscn.
##   Eine nachtraeglich versetzte Tuer stuende also vor einer geschlossenen
##   Wand, und an ihrer alten Stelle klaffte ein offenes Loch.
##
## Deshalb gilt fuer jede Szene mit footprint_cells != (1,1) die Konvention:
##
##   Tuer, ExitPoint UND Wandluecke liegen auf der Achse der Ankerzelle, also
##   bei -(cells-1) * 24 in lokalen Koordinaten.
##
## Die mitgelieferten Szenen (room_combat_wide_01, _tall_01, _arena_01) sind
## genau so gebaut. Wer eine eigene anlegt: die Zahl ist -24 bei zwei Zellen,
## -48 bei drei.
##
## RoomInstance.set_exit_offset() existiert weiterhin und verschiebt Tuer,
## ExitPoint und Tuersturz gemeinsam — als Werkzeug fuer den Fall, dass jemand
## eine Szene mit mittigen Tueren einpassen will UND die Wandluecke dort selbst
## anpasst. Automatisch aufgerufen wird sie bewusst nicht.


func _weighted_pick(candidates: Array[RoomData]) -> RoomData:
	var total_weight: float = 0.0
	for c in candidates:
		total_weight += c.spawn_weight
	if total_weight <= 0.0:
		return DetRng.pick(candidates, _rng) as RoomData

	var roll: float = _rng.randf() * total_weight
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
	# PHASE 3: room_scale mit in die Basis packen statt Basis.IDENTITY.
	# _ready() der Raum-Szene ist zu diesem Zeitpunkt zwar schon gelaufen
	# (add_child loest ihn synchron aus) und hat EntryTrigger/PresenceArea/
	# Decke bereits als Kinder gebaut - das ist unproblematisch, weil scale
	# eine Eigenschaft des Transforms ist und sich auf ALLE Kinder auswirkt,
	# unabhaengig davon, wann sie erzeugt wurden. Exakt dasselbe Muster nutzt
	# schon room_commit_guard.gd (siehe dessen Kommentar zu _attach_deferred).
	instance.global_transform = Transform3D(Basis.IDENTITY.scaled(room_scale), spawn_transform.origin)

	var room := instance as RoomInstance
	if room == null:
		push_error("[LevelGenerator] Szene '%s' hat Root-Typ %s statt RoomInstance-Script!" % [data.scene.resource_path, instance.get_class()])
	return room 
