

extends Node3D
class_name RoomInstance

const EXIT_NORTH := 1
const EXIT_SOUTH := 2
const EXIT_EAST := 4
const EXIT_WEST := 8

const _FLAG_BY_KEY := {
	"north": EXIT_NORTH,
	"south": EXIT_SOUTH,
	"east": EXIT_EAST,
	"west": EXIT_WEST,
}

## Richtungsvektor in Raum-lokalen Koordinaten (-Z = Norden).
const _DIR_VECTOR := {
	"north": Vector3(0.0, 0.0, -1.0),
	"south": Vector3(0.0, 0.0, 1.0),
	"east": Vector3(1.0, 0.0, 0.0),
	"west": Vector3(-1.0, 0.0, 0.0),
}

const NAV_SOURCE_GROUP := "navmesh_source"

## Visual-Layer, auf den ein vom Fog-of-War verdeckter Raum umgehaengt
## wird.
##
## WARUM UEBER LAYER UND NICHT UEBER visible:
## visible = false wuerde den Raum auch in der Hauptansicht ausblenden.
## Die Minimap ist aber nur eine zweite Kamera auf DIESELBE Welt. Also
## bekommt jede Geometrie eines verdeckten Raums einen Layer, den
## ausschliesslich die Minimap-Kamera aus ihrer cull_mask streicht - die
## Spielerkamera (Standard-cull_mask = alle 20 Layer) sieht ihn weiter.
const MINIMAP_HIDDEN_LAYER: int = 20

## Gegenstueck: Layer, den AUSSCHLIESSLICH die Minimap-Kamera rendert.
##
## Von oben betrachtet sieht ein Durchgang immer gleich aus - egal ob die
## Tuer offen oder verriegelt ist. Das Tuerblatt ist nur 10 hoch, die Wand
## 14; die Minimap-Kamera sieht also durch die Wandluecke hindurch auf den
## Tuersturz und liest das als Oeffnung. Deshalb bekommt jeder Durchgang
## eine flache, EINGEFAERBTE Platte knapp ueber der Wandoberkante, die nur
## auf diesem Layer liegt: die Minimap zeigt sie, die Spielerkamera nicht.
##
## player_base.gd streicht diesen Layer aus der cull_mask der
## Spielerkamera - ohne das saehe man die Platten im Spiel ueber sich
## schweben.
const MINIMAP_ONLY_LAYER: int = 19

## Zustand EINES Durchgangs - Grundlage fuer die Minimap-Synchronisation.
##
## BUGFIX (Minimap zeigte geschlossene Tueren als offen): Die Minimap hat
## bisher nur die exit_flags des LAYOUTS gezeichnet. Die sagen aber nur
## "hier ist im Grid ein Nachbar", nicht "hier gibt es tatsaechlich eine
## begehbare Tuer". Zwei Faelle liefen dadurch auseinander:
##   1. Die gewaehlte Raum-Szene hat fuer diese Richtung gar keinen
##      ExitPoint/Door-Node (dann warnt _collect_markers, die Minimap
##      malte den Durchgang aber trotzdem).
##   2. Die Tuer ist verriegelt (Kampfraum nicht gecleared) oder muss
##      erst gehackt werden (Boss/Treasure) - auf der Minimap sah sie
##      genauso offen aus wie jeder andere Gang.
## get_door_state() liefert jetzt den ECHTEN Zustand der jeweiligen Tuer.
enum DoorState {
	NONE,          ## Kein Durchgang / keine Tuer in dieser Richtung
	OPEN,          ## Offen und begehbar
	LOCKED,        ## Verriegelt (Raum noch nicht gecleared)
	HACK_LOCKED,   ## Boss/Treasure, Hacken noch nicht freigeschaltet
	HACK_READY,    ## Boss/Treasure, kann jetzt gehackt werden
}

@export var room_footprint: Vector2 = Vector2(48.0, 48.0)
@export var room_height: float = 14.0

## --- Kampfraum-Aktivierung / Anti-Baiting -----------------------------
## FRUEHER: Der EntryTrigger war fast so gross wie der ganze Raum
## (footprint - entry_trigger_inset mit inset = 3.0). Er feuerte damit
## schon im Tuerrahmen — man konnte kurz reinlaufen, den Spawn ausloesen
## und sofort wieder raus, bevor sich die Tueren schliessen.
##
## JETZT: Der Trigger ist ein deutlich kleinerer Quader in der RAUMMITTE.
## entry_trigger_depth gibt an, wie viele Meter der Spieler von JEDER Wand
## entfernt sein muss, damit der Raum scharf schaltet — der Spieler muss
## also wirklich einige Meter tief in den Raum hinein.
##
## Zusaetzlich muss der Spieler entry_trigger_dwell_time lang DRINNEN
## bleiben. Wer durch die Mitte durchsprintet und sofort wieder rausrennt,
## loest nichts aus.
@export var entry_trigger_depth: float = 9.0

## Mindestgroesse des Triggers, falls der Raum kleiner ist als
## 2 * entry_trigger_depth (schmale Korridore) — sonst waere der Quader
## rechnerisch negativ und der Raum liesse sich nie betreten.
@export var entry_trigger_min_size: float = 6.0

## Wie lange der Spieler ununterbrochen im Trigger stehen muss.
@export var entry_trigger_dwell_time: float = 0.25

## Vertikale Grosszuegigkeit: Der Trigger startet knapp ueber dem Boden und
## reicht bis zur Decke, damit auch springende/fallende Spieler erfasst
## werden.
@export var entry_trigger_floor_offset: float = 0.2

## --- Dunkle, aber TEXTURIERTE Decke -----------------------------------
## Erzeugt zur Laufzeit eine Deckenplatte. Verwendet dasselbe geteilte
## PSX-Material wie Waende/Boden (Vertex-Snapping-Shader + Textur), nur
## dunkel eingefaerbt - vorher war das eine reine Flatcolor-Flaeche ohne
## jede Textur, was im Vergleich zum Rest des Raumes "kaputt" aussah.
##
## CULL-BUG BEIM MATERIALWECHSEL: Der PSX-Shader hat "cull_back" FEST im
## Shadercode stehen (render_mode unshaded, cull_back, ...) - das laesst
## sich bei einem ShaderMaterial anders als bei StandardMaterial3D NICHT
## per Skript umschalten. Ein normaler BoxMesh mit nach oben zeigender
## Deckenflaeche waere von UNTEN betrachtet dadurch unsichtbar (man sieht
## die Rueckseite des Polygons, die weggecullt wird). Deshalb: PlaneMesh
## statt BoxMesh, um 180 Grad gekippt - dadurch zeigt exakt dieselbe
## Dreiecks-Vorderseite nach UNTEN in den Raum, ganz ohne den gemeinsamen
## Shader anzufassen. Die Kollision bleibt unabhaengig davon ein simpler
## Box-Collider (Kollision braucht keine Ausrichtung).
@export var build_ceiling: bool = true
@export var ceiling_color: Color = Color(0.035, 0.04, 0.035)

## --- Lokale Raumbeleuchtung ---------------------------------------------
## ERSATZ fuer das globale DirectionalLight3D, das vorher die gesamte Karte
## von oben beleuchtet hat (siehe level_generation_test.tscn). Mit einer
## "Sonne" ueber der ganzen Map waeren Abgruende (pit_floor.gd) NIE wirklich
## dunkel, egal wie tief die Grube ist - Licht faellt von oben direkt
## hinein. Jeder Raum beleuchtet sich deshalb jetzt selbst; ausserhalb der
## Lichtkegel (Gruben, Korridor-Enden) bleibt es dunkel.
@export var build_room_lights: bool = true
@export var room_light_color: Color = Color(1.0, 0.92, 0.78)
@export var room_light_energy: float = 2.4
## Anteil von room_height, auf dem die Lichter haengen (nahe der Decke).
@export_range(0.1, 1.0) var room_light_height_ratio: float = 0.85
## Ab dieser Kantenlaenge (lokale Einheiten) wird das Licht-Raster verdichtet
## statt EINES Lichts, das grosse/multi-Zellen-Raeume nicht mehr randvoll
## ausleuchtet.
@export var room_light_spacing: float = 42.0
@export_range(1.0, 2.0) var room_light_range_margin: float = 1.35
## Pfad zum geteilten PSX-Material. Fallback auf eine schlichte, dunkle
## StandardMaterial3D, falls die Resource fehlt/verschoben wurde.
@export var ceiling_material_path: String = "res://materials/psx_material.tres"
## Kollision fuer die Decke - verhindert, dass man mit hohen Spruengen
## oder Knockback aus dem Raum fliegt.
@export var ceiling_collision: bool = true
@export var ceiling_thickness: float = 1.0

## --- Wand-Kappe fuer die Minimap-Sichtbarkeit --------------------------
## Grund-Textur der Waende bleibt UNVERAENDERT identisch zum Boden (das
## bisherige Einfaerben der ganzen Wand wurde wieder entfernt - sah in
## der normalen Spielansicht falsch aus, weil Wand und Boden dort ja
## bewusst gleich aussehen sollen).
## PROBLEM bleibt aber bestehen: aus der reinen Top-Down-Perspektive der
## Minimap zeigt eine Wand nur ihre duenne Oberkante, texturell identisch
## zum Boden - man sieht sie praktisch nicht.
## FIX: jede Wand bekommt oben ein ZUSAETZLICHES, rein optisches Kappen-
## Mesh in dunkler Farbe (gleiche Groesse wie die Wand-Grundflaeche,
## aber nur wall_cap_height hoch), das ganz knapp ueber der eigentlichen
## Wand-Oberkante sitzt. Von der Seite/im normalen Spiel faellt dieser
## duenne dunkle Streifen kaum auf (er sitzt direkt an der duesteren
## Decke), aber die Top-Down-Kamera der Minimap trifft ihn zuerst und
## zeigt dadurch den Wandverlauf klar erkennbar dunkel gegen den
## helleren Boden.
@export var wall_cap_enabled: bool = true
@export var wall_cap_height: float = 1.0
@export var wall_cap_color: Color = Color(0.035, 0.04, 0.035)
## Minimaler Hochversatz ueber die tatsaechliche Wand-Oberkante, damit
## die Kappe im Tiefenvergleich zuverlaessig vor der (gleich hohen,
## gleich texturierten) eigentlichen Wandflaeche gewinnt - ohne das
## wuerde es zu Z-Fighting/Flackern zwischen beiden Flaechen kommen.
@export var wall_cap_epsilon: float = 0.03
@export var wall_cap_material_path: String = "res://materials/psx_material.tres"

## --- Tuersturz ---------------------------------------------------------
## Zwischen Tuer-Oberkante und Decke klafft in JEDER Raum-Szene ein Loch:
## die Wandsegmente sind room_height hoch (14, im Bossraum 24), das
## Tuerblatt aber nur 10. Bei 48er-Raeumen an einem 48er-Grid stossen zwei
## Aussenwaende deckungsgleich aneinander, die Loecher liegen uebereinander
## - man sieht in den Nachbarraum. Die Decke kaschiert nichts, die sitzt
## exakt an der OBERKANTE des Lochs.
##
## Der Sturz wird zur Laufzeit aus der Tuer-eigenen CollisionShape3D und
## room_height abgeleitet, NICHT aus festen Zahlen - er ueberlebt damit
## jede Raum-Skalierung und passt auch auf den 24 Meter hohen Bossraum.
##
## Er haengt unter "DoorLintels" statt direkt am Root, damit
## _build_wall_caps() ihn nicht als "Wall*" einsammelt: eine Minimap-Kappe
## quer ueber dem Durchgang wuerde die Oeffnung als Wand darstellen.
@export var build_door_lintels: bool = true
@export var door_lintel_thickness: float = 1.0
@export var door_lintel_collision: bool = true
@export var door_lintel_material_path: String = "res://materials/psx_material.tres"

## --- Ungenutzte Ausgaenge zumauern ------------------------------------
## Jede Raum-Szene bringt alle vier Tueren mit; das Layout benutzt aber
## meist nur ein bis drei davon. Bisher blieb das Tuerblatt der
## ungenutzten Richtungen einfach fuer immer verriegelt stehen - der
## Spieler sieht also drei Tueren, die sich nie oeffnen, und ein Bossraum
## mit einem einzigen Ausgang liest sich trotzdem nicht als Sackgasse.
##
## Mit diesem Schalter wird die Oeffnung stattdessen komplett zugemauert:
## Tuerblatt raus, volle Wand rein, vom Boden bis zur Decke. Der Raum
## sieht dann genauso aus, wie er sich verhaelt.
@export var seal_unused_exits: bool = true

## --- Rampen / Hoehenunterschiede --------------------------------------
## Dicke des Rampen-Keils UNTER seiner Lauf-Flaeche. Frueher fest 1.0 -
## darunter klaffte bis zu "rise" Meter Leere. Ein Gegner, der auf der Rampe
## gespawnt oder per Knockback hineingedrueckt wurde, ist durch die duenne
## Platte hindurchgerutscht und ins Nichts gefallen. Der Keil wird jetzt bis
## unter das tiefste Bodenniveau des Raums ausgefuellt.
@export var slope_ramp_extra_thickness: float = 2.0

## Waende eines Rampenraums nach OBEN um den Hoehengewinn und nach UNTEN um
## den Hoehenverlust verlaengern.
##
## Die Waende der Raum-Szenen stehen fest von y = 0 bis y = room_height. Auf
## einer Rampe stimmt das nicht mehr:
##   STEIGUNG (+6): man steht am hohen Ende auf y = 6, die Wandoberkante
##     liegt weiter bei 14 - es bleiben nur 8 Meter, und die Kamera schaut
##     ueber die Wand hinweg ins Nichts.
##   SENKUNG (-6): der Boden geht auf y = -6, die Wandunterkante bleibt bei
##     0 - darunter klafft ein 6 Meter hoher offener Spalt.
@export var slope_extend_walls: bool = true
## Sicherheitsabstand, den die Wand ueber/unter das Bodenniveau hinausragt.
@export var slope_wall_margin: float = 1.0

## Spawn-Marker nach dem Rampenbau per Raycast auf den ECHTEN Boden setzen.
## Siehe _snap_markers_to_ground() - das ist der Fix gegen "Gegner fallen bei
## Steigungen durch den Boden".
@export var snap_spawn_points_to_ground: bool = true
@export var spawn_ground_probe_height: float = 40.0

## --- Tuerzustand auf der 3D-Minimap -----------------------------------
## Farben absichtlich identisch zum schematischen Grid-Overlay
## (minimap_rooms.gd), damit beide Karten dasselbe sagen.
@export var door_marker_enabled: bool = true
@export var door_marker_height: float = 0.3
@export var door_marker_color_locked: Color = Color(0.70, 0.28, 0.24)
@export var door_marker_color_hack_locked: Color = Color(0.55, 0.45, 0.30)
@export var door_marker_color_hack_ready: Color = Color(0.98, 0.80, 0.25)

## --- Stage-Skalierung der Gegner --------------------------------------
## Vom LevelGenerator gesetzt (nicht @export - sonst gaebe es pro
## Raum-Szene einen konkurrierenden zweiten Wert). 1.0 = keine
## Skalierung. Wird beim Spawnen auf Health.max_health bzw. auf die
## damage jeder Hitbox des Gegners angewendet.
var enemy_health_multiplier: float = 1.0
var enemy_damage_multiplier: float = 1.0

var grid_position: Vector2i = Vector2i.ZERO

var enemy_spawn_points: Array[Marker3D] = []
var loot_spawn_points: Array[Marker3D] = []
var exit_points: Dictionary = {}

signal room_cleared(room: RoomInstance)
signal room_entered(room: RoomInstance)

## Schreibt bei jedem relevanten Ereignis eine Zeile ins Log. Zusammen mit
## LevelGenerator.debug_doors ergibt das ein vollstaendiges Tuer-Protokoll.
@export var debug_doors: bool = false

## Wie oft der Watchdog nach verwaisten Gegner-Zaehlern sucht (Sekunden).
@export var enemy_watchdog_interval: float = 1.0

## --- Anti-Einsperr-Reset ----------------------------------------------
## Ein Raum verriegelt seine Tueren, sobald der Spieler ihn scharf
## schaltet. Schafft es der Spieler trotzdem hinaus (Tuer noch in der
## Schliessanimation, Knockback, Rampen-Bug), bleibt der Raum fuer immer
## "nicht gecleared" - und beide Tueren bleiben zu. Weil ein Durchgang
## aus ZWEI Tueren besteht (eine pro Raum), sperrt so ein haengender Raum
## auch den NACHBARN ein. Genau das passiert im Log: der Spieler raeumt
## den Boss, will zurueck und steht vor Korridor (-2, 0), der noch
## 2 lebende Gegner und zwei geschlossene Tueren hat.
##
## Fix: Ist der Spieler laenger als escape_grace_time komplett ausserhalb
## des Raums, wird der Raum zurueckgesetzt - Gegner verschwinden, Tueren
## gehen auf, und beim naechsten Betreten startet der Kampf frisch.
@export var reset_when_player_escapes: bool = true
@export var escape_grace_time: float = 0.75
## Wie weit die Anwesenheits-Zone ueber den Raumrand hinausragt. Etwas
## Puffer verhindert, dass ein Spieler, der im Tuerrahmen steht, faelschlich
## als "draussen" gilt.
@export var presence_margin: float = 2.0

## --- BUGFIX "Gegner despawnen und spawnen in langen, engen Raeumen wieder" ---
##
## URSACHE (zwei Fehler, die sich gegenseitig verstaerkt haben):
##
##   1. ENTRY-TRIGGER ZU SCHMAL. _setup_entry_trigger() rueckt den Quader von
##      JEDER Seite um entry_trigger_depth (9.0) ein. Ein Korridor ist aber nur
##      room_footprint.x = 20 breit -> 20 - 18 = 2, gekappt auf
##      entry_trigger_min_size = 6. Der Trigger ist damit 6 von 20 Einheiten
##      breit. Wer an der Wand entlang kaempft (|x| > 3 lokal), steht NICHT
##      mehr drin - _find_player_inside() liefert null, _inside_entry_trigger
##      flackert, und room_entered feuert im Sekundentakt neu.
##
##   2. ANWESENHEIT NUR UEBER Area3D. _player_is_present() fragt
##      ausschliesslich _presence_area.get_overlapping_bodies() ab. Die Zone
##      ragt nur presence_margin = 2.0 ueber die Wand hinaus; zusammen mit dem
##      Flackern aus (1) und einem Knockback in Richtung Tuer reicht das aus,
##      damit der Raum den Spieler laenger als escape_grace_time (0.75 s) fuer
##      "draussen" haelt. Ergebnis: reset_room() -> alle Gegner queue_free(),
##      Tueren auf, und beim naechsten Frame startet der Kampf von vorn.
##      Genau das sieht man als "Gegner despawnen und spawnen wieder".
##
## FIX, ebenfalls zweiteilig:
##
##   1. Die Einrueckung ist jetzt ANTEILIG an der jeweiligen Kante gedeckelt
##      (entry_trigger_max_inset_factor). In einem 48er-Raum bleibt es bei den
##      gewohnten 9 Einheiten, in einem 20er-Korridor sind es nur noch 20*0.22
##      = 4.4 -> Trigger 11.2 statt 6 breit. Das Anti-Baiting bleibt erhalten
##      (man kann weiter in den Raum hineinschauen), der Trigger deckt aber
##      wieder den begehbaren Kern ab.
##
##   2. _player_is_present() hat einen GEOMETRISCHEN Rueckfallweg bekommen:
##      liegt der Spieler rechnerisch im Grundriss (plus Puffer), gilt er als
##      anwesend - unabhaengig davon, was die Area3D in diesem Frame meldet.
##      Area3D-Ueberlappungen werden nur einmal pro Physik-Schritt ausgewertet
##      und koennen nach Teleports, Charakterwechseln (PartyManager tauscht die
##      Instanz komplett aus!) und Knockback fuer einige Frames leer sein.
##
## presence_geometry_fallback lässt sich zum Gegentesten abschalten.
@export var presence_geometry_fallback: bool = true
## Zusaetzlicher Puffer fuer den geometrischen Test, in LOKALEN Einheiten.
## Grosszuegiger als presence_margin: hier geht es nicht um eine feine
## Zonengrenze, sondern nur um die Frage "ist der Spieler ueberhaupt noch in
## der Naehe dieses Raums".
@export var presence_geometry_margin: float = 6.0
## Obergrenze fuer die Einrueckung des Eintritts-Triggers, als Anteil der
## jeweiligen Kantenlaenge. 0.22 = maximal 22 % je Seite, es bleiben also immer
## mindestens 56 % der Kante als Trigger uebrig.
@export_range(0.05, 0.45) var entry_trigger_max_inset_factor: float = 0.22

var _is_cleared: bool = false
var _active_enemies: int = 0

## BUGFIX "Raum bleibt nach einem RESET fuer immer verriegelt":
##
## reset_room() ruft queue_free() auf alle Gegner und leert im selben
## Moment _counted_dead_enemies. Die tree_exited-Signale der gerade
## gefreeten Gegner feuern aber ERST IM NAECHSTEN FRAME - und laufen dann
## in ein leeres Dedup-Dict. _active_enemies rutscht dadurch ins Negative,
## die Bedingung "_active_enemies <= 0 and not _is_cleared" greift, und der
## Raum setzt sich selbst faelschlich auf CLEARED.
##
## Beim naechsten Betreten spawnen die Gegner zwar wieder und _lock_exits(true)
## verriegelt korrekt - aber _is_cleared steht bereits auf true, also wird
## beim letzten Kill NIE MEHR entriegelt. Der Raum ist dicht, obwohl leer.
##
## Fix: jede Spawn-Welle bekommt eine Generationsnummer mit. Rueckmeldungen
## aus einer aelteren Welle werden verworfen, statt in den Zaehler der
## neuen zu laufen.
var _spawn_generation: int = 0
## instance_id -> true. Verhindert Doppelzaehlung, siehe _register_enemy_gone().
var _counted_dead_enemies: Dictionary = {}
var _watchdog_timer: float = 0.0
var _requires_clear: bool = false

var _entry_trigger: Area3D = null
var _presence_area: Area3D = null
var _escape_timer: float = 0.0
var _has_entered: bool = false
## Laeuft, solange der Spieler im Trigger steht. Verlaesst er ihn vorher,
## wird der Timer verworfen und der Raum bleibt inaktiv.
var _dwell_timer: float = 0.0
var _dwell_body: Node3D = null
var _enemies_spawned: bool = false

## Eigener Spawn-RNG. Wird vom LevelGenerator aus Run-Seed + Grid-Position
## abgeleitet, BEVOR der Raum betreten wird. Dadurch ist die
## Gegner-Zusammensetzung dieses Raums unabhaengig davon, wann und in
## welcher Reihenfolge der Spieler ihn betritt - Voraussetzung dafuer,
## dass ein Seed auf dem Leaderboard einen Run wirklich reproduziert.
var _spawn_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _spawn_seed_set: bool = false

var _pending_entries: Array[EnemySpawnEntry] = []
var _pending_budget: int = 0
var _pending_stage: int = 1
## Boss-HP-Leisten (boss_health_bar.gd) suchen zuerst nach der Gruppe "boss" -
## gesetzt von prepare_enemies(), wenn dieser Raum ein Bossraum ist.
var _pending_is_boss_room: bool = false
var _spawned_enemies: Array[Node3D] = []

## Alle Tueren nach Richtung, AUCH die vom Layout wieder entfernten -
## exit_points wird von apply_exit_flags ausgeduennt, die Tuer-Referenz
## brauchen wir aber weiterhin zum Einfaerben.
var _doors_by_dir: Dictionary = {}

## dir -> StaticBody3D des Tuersturzes. Wird von configure_slope() zum
## gezielten Neubau der angehobenen Seite gebraucht.
var _lintels_by_dir: Dictionary = {}

## Fog-of-War-Zustand. null-Zustand ueber _minimap_state_known, damit der
## erste Aufruf immer durchlaeuft (auch wenn er "true" setzt).
var _minimap_revealed: bool = true
var _minimap_state_known: bool = false

## Ob der Spieler GERADE im Eintritts-Trigger steht. Getrennt von
## _has_entered: das ist eine Einmal-Sperre fuer das Gegner-Spawnen, die
## Anwesenheit muss dagegen bei JEDEM Betreten neu gemeldet werden.
var _inside_entry_trigger: bool = false

## dir -> { "node": MeshInstance3D, "material": StandardMaterial3D }
var _door_markers: Dictionary = {}
## dir -> zuletzt gezeichneter DoorState. Verhindert, dass jeden Frame
## Material-Eigenschaften neu gesetzt werden.
var _door_marker_states: Dictionary = {}
var _door_marker_pulse: float = 0.0


func _ready() -> void:
	add_to_group(NAV_SOURCE_GROUP)
	_collect_markers()
	_setup_entry_trigger()
	_setup_presence_area()
	if build_ceiling:
		_build_ceiling()
	if build_door_lintels:
		_build_door_lintels()
	if wall_cap_enabled:
		_build_wall_caps()
	if build_room_lights:
		_build_room_lights()


func _exit_tree() -> void:
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_spawned_enemies.clear()


func _collect_markers() -> void:
	var spawn_group := get_node_or_null("EnemySpawnPoints")
	if spawn_group:
		for child in spawn_group.get_children():
			if child is Marker3D:
				enemy_spawn_points.append(child)

	var loot_group := get_node_or_null("LootSpawnPoints")
	if loot_group:
		for child in loot_group.get_children():
			if child is Marker3D:
				loot_spawn_points.append(child)

	var exit_group := get_node_or_null("ExitPoints")
	if exit_group:
		for child in exit_group.get_children():
			if child is Marker3D:
				var key: String = child.name.to_lower()
				if not _FLAG_BY_KEY.has(key):
					continue
				exit_points[key] = child
				var door := get_node_or_null("Doors/Door%s" % child.name.capitalize())
				if door:
					child.set_meta("door_node", door)
					_doors_by_dir[key] = door
				else:
					push_warning("RoomInstance (%s): ExitPoint '%s' hat keine Tuer unter 'Doors/Door%s'." % [name, child.name, child.name.capitalize()])


## Baut eine texturierte, dunkel eingefaerbte Decke. Kollision (Box) und
## Optik (gekipptes PlaneMesh mit PSX-Material) sind zwei unabhaengige
## Kinder desselben StaticBody3D.
func _build_ceiling() -> void:
	if get_node_or_null("Ceiling") != null:
		return

	var body := StaticBody3D.new()
	body.name = "Ceiling"
	body.position = Vector3(0.0, room_height + ceiling_thickness * 0.5, 0.0)
	add_child(body)

	var mat: Material = _make_ceiling_material()

	var plane := PlaneMesh.new()
	plane.size = Vector2(room_footprint.x, room_footprint.y)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = plane
	# PlaneMesh zeigt standardmaessig mit der Vorderseite nach OBEN (+Y).
	# Lokal auf die Unterkante der Kollisionsbox setzen und um 180 Grad
	# kippen, damit dieselbe Dreiecksseite stattdessen nach UNTEN in den
	# Raum zeigt - siehe Klassenkommentar zum cull_back-Problem oben.
	mesh_instance.position = Vector3(0.0, -ceiling_thickness * 0.5, 0.0)
	mesh_instance.rotation_degrees = Vector3(180.0, 0.0, 0.0)
	# material_override statt surface_material_override - Vorrangregel.
	mesh_instance.material_override = mat
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mesh_instance)

	if ceiling_collision:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(room_footprint.x, ceiling_thickness, room_footprint.y)
		shape.shape = box
		body.add_child(shape)
	else:
		body.collision_layer = 0


## Verteilt OmniLight3D-Quellen in einem Raster ueber die Raumflaeche, nahe
## der Decke haengend. Ein einzelnes Licht in der Mitte wuerde bei grossen
## oder Multi-Zellen-Raeumen (siehe room_footprint bei 2x2-Raeumen) die Ecken
## im Dunkeln lassen - das Raster verdichtet sich deshalb automatisch mit der
## Raumgroesse (room_light_spacing).
func _build_room_lights() -> void:
	if get_node_or_null("RoomLights") != null:
		return

	var container := Node3D.new()
	container.name = "RoomLights"
	add_child(container)

	var cols: int = maxi(1, int(ceil(room_footprint.x / maxf(room_light_spacing, 1.0))))
	var rows: int = maxi(1, int(ceil(room_footprint.y / maxf(room_light_spacing, 1.0))))
	var cell_x: float = room_footprint.x / float(cols)
	var cell_z: float = room_footprint.y / float(rows)
	var light_range: float = maxf(cell_x, cell_z) * 0.5 * room_light_range_margin + 4.0

	for cx: int in range(cols):
		for cz: int in range(rows):
			var light := OmniLight3D.new()
			light.name = "RoomLight_%d_%d" % [cx, cz]
			light.light_color = room_light_color
			light.light_energy = room_light_energy
			light.omni_range = light_range
			# AUS: mehrere schattenwerfende Punktlichter pro Raum, ueber
			# mehrere gleichzeitig geladene Raeume hinweg, kosten auf Forward
			# Mobile spuerbar Leistung (dieselbe Abwaegung wie beim
			# Pickup-Glow in pickup.gd) - fuer die reine Ausleuchtung eines
			# PSX-Dungeons unnoetig.
			light.shadow_enabled = false
			var px: float = (float(cx) + 0.5) * cell_x - room_footprint.x * 0.5
			var pz: float = (float(cz) + 0.5) * cell_z - room_footprint.y * 0.5
			light.position = Vector3(px, room_height * room_light_height_ratio, pz)
			container.add_child(light)


## Dupliziert das geteilte PSX-Shader-Material (NIEMALS die Original-
## Resource direkt benutzen - sonst faerbt das erste instanziierte
## Zimmer ALLE anderen Decken im Spiel mit ein) und faerbt es dunkel via
## Shader-Parameter. Faellt auf eine schlichte StandardMaterial3D zurueck,
## falls die Resource fehlt.
func _make_ceiling_material() -> Material:
	var base := load(ceiling_material_path)
	if base is ShaderMaterial:
		var mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
		mat.set_shader_parameter("albedo_color", ceiling_color)
		return mat

	push_warning("RoomInstance: ceiling_material_path '%s' nicht gefunden oder kein ShaderMaterial - Decke faellt auf Flatcolor zurueck." % ceiling_material_path)
	var fallback := StandardMaterial3D.new()
	fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fallback.albedo_color = ceiling_color
	fallback.cull_mode = BaseMaterial3D.CULL_FRONT
	return fallback


## Setzt jeder Wand ("Wall*"-StaticBody3D, direktes Kind) eine duenne,
## dunkle Kappe knapp ueber ihre eigene Oberkante - siehe Klassenkommentar
## oben. Groesse/Position werden aus der WAND EIGENEN CollisionShape3D
## abgelesen (nicht aus room_height), damit das auch bei Waenden
## funktioniert, deren Hoehe (noch) nicht exakt der Raumhoehe entspricht.
func _build_wall_caps() -> void:
	var base := load(wall_cap_material_path)

	for child in get_children():
		if not (child is StaticBody3D):
			continue
		if not child.name.begins_with("Wall"):
			continue
		if child.get_node_or_null("MinimapCap") != null:
			continue

		var collision := child.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision == null or not (collision.shape is BoxShape3D):
			continue
		var box: BoxShape3D = collision.shape as BoxShape3D

		var cap_mesh := BoxMesh.new()
		cap_mesh.size = Vector3(box.size.x, wall_cap_height, box.size.z)

		var mat: Material
		if base is ShaderMaterial:
			var shader_mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
			shader_mat.set_shader_parameter("albedo_color", wall_cap_color)
			mat = shader_mat
		else:
			push_warning("RoomInstance: wall_cap_material_path '%s' nicht gefunden oder kein ShaderMaterial - Kappe faellt auf Flatcolor zurueck." % wall_cap_material_path)
			var fallback := StandardMaterial3D.new()
			fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			fallback.albedo_color = wall_cap_color
			mat = fallback

		var cap := MeshInstance3D.new()
		cap.name = "MinimapCap"
		cap.mesh = cap_mesh
		# material_override statt surface_material_override - Vorrangregel.
		cap.material_override = mat
		cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		# Lokal (relativ zur Wand-StaticBody3D, deren Ursprung mittig in
		# der Wand liegt): knapp ueber der eigenen Oberkante der Wand.
		var wall_top_local_y: float = box.size.y * 0.5
		cap.position = Vector3(0.0, wall_top_local_y - wall_cap_height * 0.5 + wall_cap_epsilon, 0.0)

		child.add_child(cap)


## Blendet den kompletten Raum auf der Minimap ein oder aus.
##
## Wird vom LevelGenerator getrieben (siehe _refresh_minimap_fog dort).
## Der urspruengliche Layer jeder Geometrie wird einmalig als Meta
## gesichert, damit das Einblenden ihn exakt wiederherstellt statt
## pauschal Layer 1 zu erzwingen.
func set_minimap_revealed(revealed: bool) -> void:
	if _minimap_state_known and revealed == _minimap_revealed:
		return
	_minimap_revealed = revealed
	_minimap_state_known = true
	_apply_minimap_layer(self, revealed)


func _apply_minimap_layer(node: Node, revealed: bool) -> void:
	for child in node.get_children():
		if child is VisualInstance3D:
			var visual: VisualInstance3D = child as VisualInstance3D
			if not visual.has_meta("minimap_base_layers"):
				visual.set_meta("minimap_base_layers", visual.layers)
			if revealed:
				visual.layers = int(visual.get_meta("minimap_base_layers"))
			else:
				visual.layers = 1 << (MINIMAP_HIDDEN_LAYER - 1)
		_apply_minimap_layer(child, revealed)


## Baut ueber JEDEN in der Szene vorhandenen Durchgang einen Sturz - auch
## ueber Richtungen, die das Layout gar nicht benutzt. Deren Tuer bleibt
## zwar dauerhaft verriegelt (apply_exit_flags duennt nur exit_points aus,
## _lock_exits iteriert danach ueber genau dieses Dict), der Spalt darueber
## waere aber trotzdem offen.
func _build_door_lintels() -> void:
	for dir in _doors_by_dir.keys():
		_build_door_lintel(dir)


## Baut den Sturz einer einzelnen Richtung neu. Ein bereits vorhandener
## wird vorher entfernt, damit configure_slope() die angehobene Seite
## einfach nochmal anstossen kann.
func _build_door_lintel(dir: String) -> void:
	if not _doors_by_dir.has(dir):
		return
	var door: Node3D = _doors_by_dir[dir] as Node3D
	if not is_instance_valid(door):
		return

	var holder: Node3D = get_node_or_null("DoorLintels") as Node3D
	if holder == null:
		holder = Node3D.new()
		holder.name = "DoorLintels"
		add_child(holder)

	var lintel_name: String = "Lintel%s" % dir.capitalize()
	if _lintels_by_dir.has(dir):
		var old: Node = _lintels_by_dir[dir]
		if is_instance_valid(old):
			old.queue_free()
		_lintels_by_dir.erase(dir)

	var collision := door.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision == null or not (collision.shape is BoxShape3D):
		push_warning("RoomInstance (%s): Tuer '%s' hat keine BoxShape3D - Sturz uebersprungen." % [name, dir])
		return

	var leaf: Vector3 = (collision.shape as BoxShape3D).size

	# Geschlossene Ruhehoehe, nicht die aktuelle - siehe
	# Door.get_base_height(). Eine offene Tuer steht Blatthoehe +
	# open_clearance hoeher, der Sturz waere dann viel zu kurz.
	var closed_y: float = door.position.y
	if door is Door:
		closed_y = (door as Door).get_base_height()

	var leaf_top: float = closed_y + leaf.y * 0.5
	var gap: float = room_height - leaf_top
	if gap <= 0.01:
		return

	# Duenne Achse = Wandachse. Die breite Achse uebernimmt exakt die
	# Blattbreite, die per Konstruktion der Wandluecke entspricht
	# (Wandsegmente 19 bei +/-14.5 -> Luecke 10, Blatt 10).
	var box_size: Vector3
	if leaf.x >= leaf.z:
		box_size = Vector3(leaf.x, gap, door_lintel_thickness)
	else:
		box_size = Vector3(door_lintel_thickness, gap, leaf.z)

	var body := StaticBody3D.new()
	body.name = lintel_name
	body.position = Vector3(door.position.x, leaf_top + gap * 0.5, door.position.z)
	holder.add_child(body)

	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = box_mesh
	# material_override statt surface_material_override - Vorrangregel.
	mesh_instance.material_override = _load_lintel_material()
	body.add_child(mesh_instance)

	if door_lintel_collision:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = box_size
		shape.shape = box
		body.add_child(shape)
	else:
		body.collision_layer = 0

	_lintels_by_dir[dir] = body


## Der Sturz wird NICHT umgefaerbt, deshalb reicht die geteilte Resource
## direkt - kein duplicate() noetig (anders als bei Decke und Wandkappe,
## die den albedo_color-Shaderparameter veraendern und ohne Kopie jedes
## andere Zimmer mit einfaerben wuerden).
func _load_lintel_material() -> Material:
	var base := load(door_lintel_material_path)
	if base is Material:
		return base as Material
	push_warning("RoomInstance: door_lintel_material_path '%s' nicht gefunden - Sturz faellt auf Flatcolor zurueck." % door_lintel_material_path)
	var fallback := StandardMaterial3D.new()
	fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fallback.albedo_color = Color(0.12, 0.13, 0.12)
	return fallback


## Schaltet die flache Bodenplatte des Raumes ab und liefert deren
## Material zurueck, damit die Rampe genauso aussieht.
##
## Es werden ALLE Mesh- und Collider-Kinder des "Floor"-Nodes erfasst,
## nicht nur "MeshInstance3D"/"CollisionShape3D": haengt dort pit_floor.gd,
## besteht der Boden zur Laufzeit aus mehreren generierten Gen_*-Segmenten.
func _disable_flat_floor() -> Material:
	var material: Material = null
	var floor_body := get_node_or_null("Floor") as StaticBody3D
	if floor_body == null:
		return material

	for child in floor_body.get_children():
		if child is MeshInstance3D:
			var mesh_child: MeshInstance3D = child as MeshInstance3D
			if material == null:
				if mesh_child.material_override != null:
					material = mesh_child.material_override
				elif mesh_child.get_surface_override_material_count() > 0:
					material = mesh_child.get_surface_override_material(0)
			mesh_child.visible = false
		elif child is CollisionShape3D:
			(child as CollisionShape3D).disabled = true

	return material


## Baut im Inneren eines Korridors eine Rampe, die rise Meter ueberwindet.
## low_dir zeigt zur tiefer liegenden Eingangsseite; die Tuer und der
## ExitPoint auf der Gegenseite werden um rise angehoben.
##
## Wird vom LevelGenerator aufgerufen, BEVOR der Raum betreten wird.
func configure_slope(low_dir: String, rise: float) -> void:
	if not _DIR_VECTOR.has(low_dir) or is_zero_approx(rise):
		return

	var high_dir: String = _opposite(low_dir)
	var axis: Vector3 = _DIR_VECTOR[high_dir]

	# Laenge der Rampe entlang der Steigungsachse.
	var length: float = room_footprint.y if absf(axis.z) > 0.5 else room_footprint.x
	var width: float = room_footprint.x if absf(axis.z) > 0.5 else room_footprint.y

	# BUGFIX "Korridore haben keinen absteigenden Boden":
	#
	# Die Rampe wurde frueher ZUSAETZLICH zur flachen Bodenplatte gebaut. Bei
	# einer STEIGUNG faellt das nicht auf - die Rampe liegt dann ueber der
	# Platte und gewinnt. Bei einem GEFAELLE laeuft sie von 0 auf -rise nach
	# unten, liegt also UNTER der Platte: der Spieler laeuft die ganze
	# Ganglaenge auf der Platte weiter und faellt am Ende einen ungefederten
	# Absatz von rise Metern in den naechsten Raum.
	#
	# Sobald eine Rampe existiert, IST sie der Boden - die Platte wird
	# abgeschaltet und gibt ihr Material an die Rampe weiter (sonst rendert
	# die Rampe im Godot-Standardgrau statt im PSX-Material).
	var floor_material: Material = _disable_flat_floor()

	var ramp := StaticBody3D.new()
	ramp.name = "SlopeRamp"
	add_child(ramp)
	ramp.add_to_group(NAV_SOURCE_GROUP)

	var hypotenuse: float = sqrt(length * length + rise * rise)
	var angle: float = atan2(rise, length)

	# Massiver Keil statt duenner Platte: die Dicke reicht garantiert unter
	# das tiefste Bodenniveau des Raums. Siehe slope_ramp_extra_thickness.
	var thickness: float = absf(rise) + maxf(slope_ramp_extra_thickness, 0.5)

	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(width, thickness, hypotenuse)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = box_mesh
	if floor_material != null:
		# material_override statt surface_material_override - Vorrangregel.
		mesh_instance.material_override = floor_material
	ramp.add_child(mesh_instance)

	var shape := CollisionShape3D.new()
	shape.name = "CollisionShape3D"
	var box := BoxShape3D.new()
	box.size = box_mesh.size
	shape.shape = box
	ramp.add_child(shape)

	# Die LAUF-FLAECHE (Oberseite des Keils) soll ihren Mittelpunkt exakt bei
	# rise * 0.5 haben, damit die Enden sauber auf 0 und rise liegen. Die
	# halbe Dicke muss dabei MIT dem Neigungswinkel gerechnet werden: der
	# alte feste Term "- 0.5" stimmte nur zufaellig fuer eine 1.0 dicke
	# Platte und liefe bei dickeren Keilen weg.
	ramp.position = Vector3(0.0, rise * 0.5 - thickness * 0.5 * cos(angle), 0.0)

	# BUGFIX "Ost/West-Rampen sind flach -> 6 Meter hohe Wand statt
	# Durchgang":
	#
	# Frueher stand hier fuer die X-Achse rotation = Vector3(0, PI/2, angle).
	# Godot interpretiert Node3D.rotation in der Euler-Reihenfolge YXZ, die
	# Gesamtdrehung ist also Ry * Rx * Rz. Die Laengsachse der Rampen-Box ist
	# lokal +Z - und eine Drehung UM Z laesst genau diese Achse unveraendert.
	# Der Winkel landete damit komplett im Leeren.
	#
	# Korrekt ist Pitch um X (kippt +Z nach oben) und danach Yaw um Y (dreht
	# die gekippte Achse auf Ost/West). In YXZ-Reihenfolge ist das
	# Vector3(pitch, yaw, 0) - der dritte Wert MUSS 0 bleiben.
	var pitch: float = 0.0
	var yaw: float = 0.0
	if absf(axis.z) > 0.5:
		yaw = 0.0
		pitch = -angle * signf(axis.z)
	else:
		yaw = PI * 0.5
		pitch = -angle * signf(axis.x)
	ramp.rotation = Vector3(pitch, yaw, 0.0)

	# Tuer + ExitPoint auf der hohen Seite mit anheben, sonst steht die Tuer
	# im Boden bzw. der naechste Raum haengt in der Luft.
	if exit_points.has(high_dir):
		var marker: Marker3D = exit_points[high_dir]
		marker.position.y += rise
	if _doors_by_dir.has(high_dir):
		var door: Node3D = _doors_by_dir[high_dir]
		if is_instance_valid(door):
			# NICHT nur position.y verschieben: die Tuer merkt sich in
			# _ready() ihre Ruhehoehe und faehrt sonst im naechsten Frame
			# wieder nach unten. Siehe Door.shift_base_height().
			if door is Door:
				(door as Door).shift_base_height(rise)
			else:
				door.position.y += rise

	# Waende, Decke, Tuerstuerze, Minimap-Platten und die Trigger-Volumen auf
	# das neue Hoehenband ziehen. Baut die Stuerze BEIDER Richtungen neu -
	# der Aufruf fuer high_dir, der frueher hier stand, ist darin enthalten.
	_apply_slope_bounds(rise)

	# Erst JETZT die Spawn-Marker snappen: der Raycast braucht die fertige
	# Rampe als Trefferflaeche.
	if snap_spawn_points_to_ground:
		_snap_markers_to_ground(enemy_spawn_points)
		_snap_markers_to_ground(loot_spawn_points)


## Zieht Waende, Decke, Tuerstuerze, Minimap-Platten und die Trigger-Volumen
## auf das Hoehenband, das durch die Rampe entstanden ist.
##
## floor_min / floor_max sind das tiefste und hoechste Bodenniveau des Raums
## (0 und rise, je nach Vorzeichen von rise).
func _apply_slope_bounds(rise: float) -> void:
	var floor_min: float = minf(0.0, rise)
	var floor_max: float = maxf(0.0, rise)
	var margin: float = maxf(slope_wall_margin, 0.0)

	var new_bottom: float = floor_min - margin
	var new_top: float = room_height + floor_max

	if slope_extend_walls:
		for child in get_children():
			if child is StaticBody3D and child.name.begins_with("Wall"):
				_stretch_wall(child as StaticBody3D, new_bottom, new_top)

	# Die Decke MUSS mit angehoben werden. Sonst steckt die um rise
	# angehobene Tuer der hohen Seite in der Deckenplatte, und
	# _build_door_lintel() rechnet fuer sie gap = room_height - leaf_top <= 0
	# und baut gar keinen Sturz - genau dort klafft dann das Loch in den
	# Nachbarraum.
	_raise_ceiling(floor_max)

	# Ab hier IST room_height die neue Oberkante des Raums. Alles, was danach
	# gebaut oder verschoben wird (Kappen, Stuerze, Minimap-Platten), rechnet
	# damit.
	room_height = new_top

	# Die Kappen sitzen auf der ALTEN Wandoberkante -> komplett neu bauen.
	if wall_cap_enabled:
		_rebuild_wall_caps()

	# Stuerze BEIDER Richtungen neu: die hohe Tuer ist gewandert, die
	# Raumhoehe ebenfalls.
	if build_door_lintels:
		for dir in _doors_by_dir.keys():
			_build_door_lintel(dir)

	for dir in _door_markers.keys():
		var marker: MeshInstance3D = _door_markers[dir]["node"]
		if is_instance_valid(marker):
			marker.position.y = room_height + door_marker_height

	_extend_trigger_volumes(new_bottom)


## Verlaengert EINE Wand auf das Hoehenband [bottom, top].
##
## KRITISCH: BoxMesh und BoxShape3D der Raum-Szenen sind SubResources.
## WallEast und WallWest teilen sich in room_corridor_01.tscn dieselbe
## Instanz - und alle Raeume derselben Szene ebenfalls. Ohne duplicate()
## wuerde das Strecken einer einzigen Wand jede andere Wand im ganzen Level
## mitverformen. Exakt derselbe Bug wie bei den geteilten Lemonade-Shapes.
##
## Vorausgesetzt wird, dass CollisionShape3D und MeshInstance3D mittig im
## StaticBody3D sitzen (so sind alle Raum-Szenen gebaut).
func _stretch_wall(body: StaticBody3D, bottom: float, top: float) -> void:
	var collision := body.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision == null or not (collision.shape is BoxShape3D):
		return

	var height: float = top - bottom
	if height <= 0.01:
		return

	var shape: BoxShape3D = (collision.shape as BoxShape3D).duplicate()
	var new_size: Vector3 = shape.size
	new_size.y = height
	shape.size = new_size
	collision.shape = shape

	for child in body.get_children():
		if not (child is MeshInstance3D):
			continue
		var mesh_child: MeshInstance3D = child as MeshInstance3D
		# Die Minimap-Kappe wird gleich komplett neu gebaut - hier nicht
		# mitskalieren, sonst waere sie so hoch wie die ganze Wand und die
		# Minimap zeigte eine schwarze Flaeche statt eines Wandstrichs.
		if mesh_child.name == "MinimapCap":
			continue
		if mesh_child.mesh is BoxMesh:
			var wall_mesh: BoxMesh = (mesh_child.mesh as BoxMesh).duplicate()
			wall_mesh.size = new_size
			mesh_child.mesh = wall_mesh

	body.position.y = (top + bottom) * 0.5


func _raise_ceiling(amount: float) -> void:
	if amount <= 0.0:
		return
	var ceiling := get_node_or_null("Ceiling") as StaticBody3D
	if ceiling == null:
		return
	ceiling.position.y += amount


## remove_child() VOR queue_free(): queue_free raeumt erst am Frame-Ende auf,
## _build_wall_caps() wuerde die alte Kappe sonst noch finden und die Wand
## per "continue" ueberspringen.
func _rebuild_wall_caps() -> void:
	for child in get_children():
		if not (child is StaticBody3D):
			continue
		var old_cap: Node = child.get_node_or_null("MinimapCap")
		if old_cap:
			child.remove_child(old_cap)
			old_cap.queue_free()
	_build_wall_caps()


## EntryTrigger und PresenceArea wurden in _ready() mit der alten Raumhoehe
## gebaut und reichen von knapp ueber y = 0 bis room_height.
##
## Bei einer SENKUNG steht der Spieler am Ende des Gangs bei y = -6, also
## UNTER beiden Volumen: der Raum wuerde nie scharf schalten und den Spieler
## gleichzeitig dauerhaft als "entkommen" werten -> Endlos-Reset.
func _extend_trigger_volumes(bottom: float) -> void:
	_resize_area_box(_entry_trigger, bottom + entry_trigger_floor_offset, room_height)
	_resize_area_box(_presence_area, bottom - presence_margin, room_height + presence_margin)


## Die BoxShape3D beider Areas werden in _setup_*() per new() erzeugt, sind
## also NICHT geteilt - sie duerfen hier direkt veraendert werden.
func _resize_area_box(area: Area3D, bottom: float, top: float) -> void:
	if area == null:
		return
	var shape := area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if shape == null or not (shape.shape is BoxShape3D):
		return
	var box: BoxShape3D = shape.shape as BoxShape3D
	var new_size: Vector3 = box.size
	new_size.y = maxf(top - bottom, 1.0)
	box.size = new_size
	shape.position.y = bottom + new_size.y * 0.5


## Setzt Spawn-Marker per Raycast auf den tatsaechlichen Boden.
##
## In den Raum-Szenen liegen ALLE Marker fest auf y = 0.5. Auf einer Rampe
## ist der Boden dort aber bis zu "rise" Meter hoeher oder tiefer.
## _spawn_one() setzt den Gegner auf marker.global_position.y + 0.1 - bei
## einer Steigung steckt er damit meterhoch IM Rampen-Collider. Godots
## Depenetration schiebt ihn im ersten Physikschritt heraus, bevorzugt nach
## unten, also durch den Keil hindurch ins Nichts. Genau das ist der
## "Gegner fallen bei Steigungen durch den Boden"-Bug.
##
## Die Decke wird explizit ausgeschlossen: der Strahl startet oberhalb des
## Markers und wuerde sonst zuerst die Deckenplatte treffen.
func _snap_markers_to_ground(markers: Array[Marker3D]) -> void:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	if space == null:
		return

	var exclude: Array[RID] = []
	var ceiling := get_node_or_null("Ceiling") as StaticBody3D
	if ceiling:
		exclude.append(ceiling.get_rid())

	var probe: float = maxf(spawn_ground_probe_height, 1.0)

	for marker in markers:
		if not is_instance_valid(marker):
			continue

		var origin: Vector3 = marker.global_position
		var query := PhysicsRayQueryParameters3D.create(
			origin + Vector3.UP * probe,
			origin - Vector3.UP * probe
		)
		query.collision_mask = 1
		query.collide_with_areas = false
		query.exclude = exclude

		var hit: Dictionary = space.intersect_ray(query)
		if hit.is_empty():
			push_warning("RoomInstance (%s): Kein Boden unter Spawn-Marker '%s' - Marker bleibt unveraendert." % [grid_position, marker.name])
			continue

		# 0.5 statt 0.1 Abstand: _spawn_one() legt nochmal 0.1 drauf, und ein
		# Gegner, der minimal ueber dem Boden startet, faellt sauber drauf -
		# einer, der minimal DRIN startet, wird herausgedrueckt.
		marker.global_position = (hit["position"] as Vector3) + Vector3.UP * 0.5


func _opposite(dir: String) -> String:
	match dir:
		"north": return "south"
		"south": return "north"
		"east": return "west"
		"west": return "east"
	return ""


# --- Tuer-API fuer den LevelGenerator --------------------------------

func set_door_kind(dir: String, kind: int) -> void:
	if not _doors_by_dir.has(dir):
		return
	var door: Node = _doors_by_dir[dir]
	if is_instance_valid(door) and door is Door:
		(door as Door).door_kind = kind


## Stellt eine Tuer vom Hack-Zwang frei, OHNE ihre Einfaerbung zu
## aendern - siehe hack_exempt in door.gd. Wird vom LevelGenerator fuer
## die Innenseite von Boss-/Tresorraeumen gesetzt, damit man dort nicht
## eingesperrt wird.
func set_door_hack_exempt(dir: String, exempt: bool) -> void:
	if not _doors_by_dir.has(dir):
		return
	var door: Node = _doors_by_dir[dir]
	if is_instance_valid(door) and door is Door:
		(door as Door).hack_exempt = exempt


func set_door_hack_enabled(dir: String, enabled: bool) -> void:
	if not _doors_by_dir.has(dir):
		return
	var door: Node = _doors_by_dir[dir]
	if is_instance_valid(door) and door.has_method("set_hack_enabled"):
		door.set_hack_enabled(enabled)


func _setup_entry_trigger() -> void:
	_entry_trigger = Area3D.new()
	_entry_trigger.name = "EntryTrigger"
	_entry_trigger.collision_layer = 0
	_entry_trigger.collision_mask = 0b101
	_entry_trigger.monitoring = true
	_entry_trigger.monitorable = false
	add_child(_entry_trigger)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()

	# Von JEDER Seite um entry_trigger_depth einruecken -> der Trigger sitzt
	# als kompakter Quader in der Raummitte.
	# Einrueckung pro Achse: der feste entry_trigger_depth, aber nie mehr als
	# entry_trigger_max_inset_factor der jeweiligen Kante. Siehe den
	# ausfuehrlichen Bugfix-Block bei presence_geometry_fallback.
	var factor: float = clampf(entry_trigger_max_inset_factor, 0.05, 0.45)
	var inset_x: float = minf(entry_trigger_depth, room_footprint.x * factor)
	var inset_z: float = minf(entry_trigger_depth, room_footprint.y * factor)

	var size_x: float = maxf(room_footprint.x - inset_x * 2.0, entry_trigger_min_size)
	var size_z: float = maxf(room_footprint.y - inset_z * 2.0, entry_trigger_min_size)
	var size_y: float = maxf(room_height - entry_trigger_floor_offset, 1.0)

	box.size = Vector3(size_x, size_y, size_z)
	shape.shape = box
	shape.position = Vector3(0.0, entry_trigger_floor_offset + size_y * 0.5, 0.0)
	_entry_trigger.add_child(shape)

	_entry_trigger.body_exited.connect(_on_entry_trigger_body_exited)


## Zweite, RAUMGROSSE Zone. Der EntryTrigger sitzt bewusst tief in der
## Raummitte (Anti-Baiting) und taugt deshalb NICHT, um zu erkennen, ob der
## Spieler den Raum verlassen hat - wer an der Wand kaempft, steht auch
## nicht im EntryTrigger. Die Presence-Area deckt den ganzen Raum plus
## presence_margin ab und beantwortet nur eine Frage: ist der Spieler noch
## irgendwo hier drin?
func _setup_presence_area() -> void:
	if not reset_when_player_escapes:
		return

	_presence_area = Area3D.new()
	_presence_area.name = "PresenceArea"
	_presence_area.collision_layer = 0
	_presence_area.collision_mask = 0b101
	_presence_area.monitoring = true
	_presence_area.monitorable = false
	add_child(_presence_area)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(
		room_footprint.x + presence_margin * 2.0,
		maxf(room_height, 1.0) + presence_margin * 2.0,
		room_footprint.y + presence_margin * 2.0
	)
	shape.shape = box
	shape.position = Vector3(0.0, box.size.y * 0.5 - presence_margin, 0.0)
	_presence_area.add_child(shape)


func _player_is_present() -> bool:
	if _presence_area != null:
		for body in _presence_area.get_overlapping_bodies():
			if body is Node3D and body.is_in_group(PartyManager.PLAYER_GROUP):
				return true

	# Geometrischer Rueckfallweg. Bewusst NACH der Area-Abfrage: die Area ist
	# die genauere Quelle (sie kennt die tatsaechliche Kapselform), dieser Test
	# faengt nur die Frames ab, in denen sie nichts meldet.
	if presence_geometry_fallback and _player_is_inside_footprint():
		return true

	# Gar keine Zone vorhanden -> lieber "anwesend" annehmen als den Raum
	# grundlos zuruecksetzen.
	return _presence_area == null


## Rein rechnerischer Anwesenheitstest im LOKALEN Raumsystem. Lokale
## Koordinaten sind von room_scale unabhaengig, room_footprint ist genau so
## definiert - deshalb muss hier NICHTS mit dem Skalierungsfaktor verrechnet
## werden (derselbe Grund wie bei der Innenzone in room_commit_guard.gd).
func _player_is_inside_footprint() -> bool:
	var margin: float = maxf(presence_geometry_margin, 0.0)
	var half_x: float = room_footprint.x * 0.5 + margin
	var half_z: float = room_footprint.y * 0.5 + margin

	for node: Node in get_tree().get_nodes_in_group(PartyManager.PLAYER_GROUP):
		var body := node as Node3D
		if body == null or not is_instance_valid(body):
			continue
		var local: Vector3 = to_local(body.global_position)
		if absf(local.x) > half_x or absf(local.z) > half_z:
			continue
		# Y grosszuegig: Rampen, Sprung und abgesenkte Bodenstuecke duerfen
		# nicht als "Raum verlassen" gelten.
		if local.y < -(room_height + margin) or local.y > room_height + margin:
			continue
		return true
	return false


## Setzt einen verriegelten, nicht gecleart en Raum komplett zurueck.
## Gegner verschwinden, der Zaehler wird geleert, die Tueren gehen auf und
## _enemies_spawned faellt zurueck auf false - beim naechsten Betreten
## startet der Kampf also frisch statt in einem halb toten Zustand.
func reset_room() -> void:
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_spawned_enemies.clear()
	_counted_dead_enemies.clear()
	_active_enemies = 0

	# Neue Welle: alles, was von der alten noch nachfeuert, ist ab jetzt
	# ungueltig.
	_spawn_generation += 1

	# Der Raum ist NICHT gecleared, er wurde nur verlassen. Ohne das
	# Zuruecksetzen bliebe ein faelschlich gesetztes _is_cleared stehen und
	# der Raum wuerde beim naechsten Durchgang nie wieder entriegeln.
	_is_cleared = false

	_enemies_spawned = false
	_has_entered = false
	# Nicht _inside_entry_trigger zuruecksetzen: der Spieler ist beim Reset
	# per Definition DRAUSSEN, die naechste steigende Flanke kommt also
	# ohnehin von selbst. Ein erzwungenes false wuerde nur eine doppelte
	# Meldung erzeugen.
	_dwell_timer = 0.0
	_dwell_body = null
	_escape_timer = 0.0

	_lock_exits(false)

	if debug_doors:
		print("[Room %s] RESET - Spieler hat den verriegelten Raum verlassen, Tueren wieder offen." % grid_position)


## Entriegelt eine Tuer bedingungslos - auch eine noch nicht gehackte
## Hack-Tuer. Notausgang fuer den LevelGenerator, wenn eine Sperre den
## Rueckweg blockieren wuerde.
func force_unlock_door(dir: String) -> void:
	if not _doors_by_dir.has(dir):
		return
	var door: Node = _doors_by_dir[dir]
	if not is_instance_valid(door):
		return
	if door.has_method("force_unlock"):
		door.force_unlock()
	elif door.has_method("set_locked"):
		door.set_locked(false)
	if debug_doors:
		print("[Room %s] Tuer '%s' -> ZWANGS-ENTRIEGELT (danach: %s)" % [grid_position, dir, door_state_name(get_door_state(dir))])


## Der Dwell-Check laeuft bewusst in _physics_process statt ueber
## body_entered: So wird auch der Fall abgedeckt, dass der Spieler beim
## Laden des Raumes BEREITS im Trigger steht (body_entered feuert dann nie).
func _physics_process(delta: float) -> void:
	# NICHT mehr komplett abschalten, sobald der Raum betreten wurde — der
	# Gegner-Watchdog unten muss weiterlaufen. Nur der Eintritts-Check wird
	# uebersprungen.
	if _entry_trigger == null:
		set_physics_process(false)
		return

	# Watchdog laeuft IMMER - auch nachdem der Raum betreten wurde, denn
	# genau dann koennen Gegner verschwinden ohne sauber zu sterben.
	_watchdog_timer -= delta
	if _watchdog_timer <= 0.0:
		_watchdog_timer = maxf(enemy_watchdog_interval, 0.1)
		_watchdog_check()

	# BUGFIX "Blinken auf der Grid-Karte bleibt am zuletzt geclearten Raum
	# haengen":
	#
	# room_entered wurde frueher NUR aus on_player_entered() gefeuert, und
	# das laeuft wegen der _has_entered-Sperre genau EINMAL pro Raum. Wer
	# in einen bereits geclearten Raum zurueckgeht, meldet sich damit nie
	# wieder an - _current_room im LevelGenerator zeigt weiter auf den
	# zuletzt NEU betretenen Raum, und das Overlay markiert den falschen.
	#
	# Die Anwesenheit wird deshalb jetzt jeden Frame geprueft und bei jeder
	# steigenden Flanke gemeldet. _has_entered bleibt reine Spawn-Sperre.
	var player: Node3D = _find_player_inside()
	_update_entry_presence(player != null)

	if _has_entered:
		_check_escape(delta)
		return

	if player == null:
		_dwell_timer = 0.0
		_dwell_body = null
		return

	if player != _dwell_body:
		_dwell_body = player
		_dwell_timer = 0.0

	_dwell_timer += delta
	if _dwell_timer >= maxf(entry_trigger_dwell_time, 0.0):
		_has_entered = true
		on_player_entered()


## Meldet die steigende Flanke "Spieler ist im Eintritts-Trigger". Der
## Eintritts-Trigger ist dafuer das richtige Volumen: er sitzt mittig im
## Raum und ueberlappt - anders als die PresenceArea, die den Grundriss um
## presence_margin aufblaeht - NICHT mit dem Nachbarraum. Sonst wuerde die
## Markierung im Tuerrahmen zwischen zwei Raeumen hin und her springen.
func _update_entry_presence(inside: bool) -> void:
	if inside == _inside_entry_trigger:
		return
	_inside_entry_trigger = inside
	if inside:
		room_entered.emit(self)


## Zaehlt hoch, solange der Spieler ausserhalb der Presence-Area ist, und
## setzt den Raum zurueck, sobald escape_grace_time ueberschritten ist.
## Laeuft nur fuer Raeume, die gerade wirklich verriegelt sind.
func _check_escape(delta: float) -> void:
	if not reset_when_player_escapes:
		return
	if _is_cleared or not _requires_clear or not _enemies_spawned:
		_escape_timer = 0.0
		return

	if _player_is_present():
		_escape_timer = 0.0
		return

	_escape_timer += delta
	if _escape_timer >= maxf(escape_grace_time, 0.05):
		_escape_timer = 0.0
		reset_room()


func _find_player_inside() -> Node3D:
	for body in _entry_trigger.get_overlapping_bodies():
		if body is Node3D and body.is_in_group(PartyManager.PLAYER_GROUP):
			return body
	return null


func _on_entry_trigger_body_exited(body: Node) -> void:
	if body == _dwell_body:
		_dwell_timer = 0.0
		_dwell_body = null


## Vom LevelGenerator vor prepare_enemies() aufzurufen.
func set_spawn_seed(seed_value: int) -> void:
	_spawn_rng.seed = seed_value
	_spawn_seed_set = true


func prepare_enemies(entries: Array[EnemySpawnEntry], threat_budget: int, stage: int, is_boss_room: bool = false) -> void:
	_pending_is_boss_room = is_boss_room
	if not _spawn_seed_set:
		# Ohne gesetzten Seed (z.B. Raum von Hand in ein Testlevel
		# gesetzt) faellt der Raum auf echten Zufall zurueck - nur dann
		# ist der Run eben nicht reproduzierbar.
		_spawn_rng.randomize()
		_spawn_seed_set = true

	_pending_stage = stage
	var usable: Array[EnemySpawnEntry] = []
	for e in entries:
		if e != null and e.is_allowed(stage, room_height):
			usable.append(e)

	if usable.is_empty() or enemy_spawn_points.is_empty() or threat_budget <= 0:
		_is_cleared = true
		_lock_exits(false)
		return

	_requires_clear = true
	_pending_entries = usable
	_pending_budget = threat_budget
	_lock_exits(false)


func _roll_enemy_mix() -> Array[EnemySpawnEntry]:
	var result: Array[EnemySpawnEntry] = []
	var budget: int = _pending_budget
	var used_count: Dictionary = {}
	var guard: int = 0

	for e in _pending_entries:
		for i in range(e.guaranteed_count):
			if result.size() >= enemy_spawn_points.size():
				break
			result.append(e)
			used_count[e] = used_count.get(e, 0) + 1
			budget -= e.threat_cost

	while budget > 0 and result.size() < enemy_spawn_points.size() and guard < 64:
		guard += 1

		var affordable: Array[EnemySpawnEntry] = []
		for e in _pending_entries:
			if e.threat_cost > budget:
				continue
			if used_count.get(e, 0) >= e.max_per_room:
				continue
			affordable.append(e)

		if affordable.is_empty():
			break

		var chosen: EnemySpawnEntry = _weighted_pick_entry(affordable)
		result.append(chosen)
		used_count[chosen] = used_count.get(chosen, 0) + 1
		budget -= chosen.threat_cost

	if result.is_empty() and not _pending_entries.is_empty():
		result.append(_pending_entries[0])

	return result


func _weighted_pick_entry(candidates: Array[EnemySpawnEntry]) -> EnemySpawnEntry:
	var total: float = 0.0
	for c in candidates:
		total += maxf(c.weight, 0.0)
	if total <= 0.0:
		return DetRng.pick(candidates, _spawn_rng) as EnemySpawnEntry
	var roll: float = _spawn_rng.randf() * total
	var acc: float = 0.0
	for c in candidates:
		acc += maxf(c.weight, 0.0)
		if roll <= acc:
			return c
	return candidates.back()


func _spawn_prepared_enemies() -> void:
	if _pending_entries.is_empty() or enemy_spawn_points.is_empty():
		_is_cleared = true
		_lock_exits(false)
		return

	var mix: Array[EnemySpawnEntry] = _roll_enemy_mix()
	mix.sort_custom(func(a, b): return a.threat_cost > b.threat_cost)

	var free_points: Array[Marker3D] = enemy_spawn_points.duplicate()
	DetRng.shuffle(free_points, _spawn_rng)
	var taken_positions: Array[Vector3] = []

	for entry in mix:
		var point: Marker3D = _take_spawn_point(free_points, taken_positions, entry.min_spawn_spacing)
		if point == null:
			break
		taken_positions.append(point.global_position)
		_spawn_one(entry, point)

	if _spawned_enemies.is_empty():
		_is_cleared = true
		_lock_exits(false)


func _take_spawn_point(free_points: Array[Marker3D], taken: Array[Vector3], spacing: float) -> Marker3D:
	if free_points.is_empty():
		return null
	if spacing <= 0.0 or taken.is_empty():
		return free_points.pop_front()

	for i in range(free_points.size()):
		var candidate: Marker3D = free_points[i]
		var ok: bool = true
		for t in taken:
			if candidate.global_position.distance_to(t) < spacing:
				ok = false
				break
		if ok:
			free_points.remove_at(i)
			return candidate

	return free_points.pop_front()


func _spawn_one(entry: EnemySpawnEntry, point: Marker3D) -> void:
	var enemy: Node3D = entry.scene.instantiate()

	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(enemy)

	# BUGFIX "Boss-HP-Leiste bleibt leer": boss_health_bar.gd sucht zuerst die
	# Gruppe "boss" - ohne diese Markierung faellt sie auf eine unzuverlaessige
	# Staerkste-im-Raum-Heuristik zurueck. Hier markieren wir jeden Gegner, der
	# ueber boss_table (statt enemy_table) in einen Bossraum gespawnt wurde.
	if _pending_is_boss_room:
		enemy.add_to_group("boss")

	var spawn_pos: Vector3 = point.global_position
	spawn_pos.y += 0.1
	enemy.global_transform = Transform3D(Basis.IDENTITY, spawn_pos)
	enemy.rotation = Vector3(0.0, point.global_rotation.y, 0.0)
	enemy.scale = Vector3.ONE

	_apply_stage_scaling(enemy)

	_spawned_enemies.append(enemy)
	_active_enemies += 1

	# BUGFIX "Tueren gehen manchmal nicht auf":
	# Frueher wurde NUR EINE der drei Quellen verbunden (died am Gegner,
	# sonst died an Health, sonst tree_exited). Verschwindet ein Gegner
	# aber auf einem Weg, der das gewaehlte Signal NICHT feuert - er faellt
	# in eine Lava-/Abgrund-Zone und wird per queue_free() entfernt, oder
	# er wird beim Raum-Cleanup abgeraeumt - dann zaehlt _active_enemies
	# nie herunter, der Raum gilt ewig als "nicht gecleared" und die
	# Tueren bleiben fuer immer zu.
	#
	# Jetzt werden ALLE verfuegbaren Quellen verbunden und ueber die
	# Instanz-ID dedupliziert: was zuerst feuert zaehlt, alles danach wird
	# ignoriert. tree_exited ist dabei das Sicherheitsnetz, das JEDEN
	# Verschwinde-Weg abdeckt.
	var enemy_id: int = enemy.get_instance_id()
	var generation: int = _spawn_generation

	if enemy.has_signal("died"):
		enemy.connect("died", _register_enemy_gone.bind(enemy_id, generation))

	var health_node := enemy.find_child("Health", true, false)
	if health_node and health_node.has_signal("died"):
		health_node.died.connect(_register_enemy_gone.bind(enemy_id, generation))

	enemy.tree_exited.connect(_register_enemy_gone.bind(enemy_id, generation))


## Streicht alle Richtungen, die das Layout nicht benutzt.
##
## Es wird ueber ALLE vier Himmelsrichtungen gelaufen, nicht nur ueber
## exit_points: eine Raum-Szene kann eine Tuer ohne zugehoerigen
## ExitPoint-Marker haben, und genau die blieb frueher als unbenutzbares
## Tuerblatt stehen.
## Zieht Lebenspunkte und Schaden eines frisch gespawnten Gegners auf das
## Niveau der aktuellen Etage hoch.
##
## Bis hierher skalierte NUR die Anzahl (threat_per_stage). Ein Stinger in
## Etage 5 hatte damit exakt dieselben 25 HP wie in Etage 1 - es wurden
## eben nur mehr davon. Das laesst spaetere Etagen leichter wirken, weil
## der Spieler inzwischen mehr Schaden macht.
##
## Health._ready() hat zu diesem Zeitpunkt bereits current_health auf
## max_health gesetzt (der Gegner haengt schon im Baum), deshalb wird
## current_health danach neu gesetzt und health_changed gefeuert - sonst
## zeigte die Lebensleiste ueber dem Kopf den alten Maximalwert.
func _apply_stage_scaling(enemy: Node3D) -> void:
	if is_equal_approx(enemy_health_multiplier, 1.0) and is_equal_approx(enemy_damage_multiplier, 1.0):
		return

	if not is_equal_approx(enemy_health_multiplier, 1.0):
		var health_node: Node = enemy.find_child("Health", true, false)
		if health_node != null and health_node is Health:
			var hp: Health = health_node as Health
			hp.max_health *= enemy_health_multiplier
			hp.current_health = hp.max_health
			hp.health_changed.emit(hp.current_health, hp.max_health)

	if not is_equal_approx(enemy_damage_multiplier, 1.0):
		_scale_hitbox_damage(enemy)


## Alle Hitboxen des Gegners hochziehen - ein Gegner kann mehrere haben
## (Nahkampf, Sprungangriff, Aura).
func _scale_hitbox_damage(node: Node) -> void:
	for child in node.get_children():
		if child is Hitbox:
			(child as Hitbox).damage *= enemy_damage_multiplier
		_scale_hitbox_damage(child)


func apply_exit_flags(required_flags: int) -> void:
	var sealed_any: bool = false

	for key in _FLAG_BY_KEY.keys():
		var flag: int = int(_FLAG_BY_KEY[key])
		if flag & required_flags != 0:
			continue

		# DIAGNOSE "Raum wirkt an einer Seite als wuerde er fehlen": hatte
		# dieser Raum ueberhaupt einen ExitPoint fuer 'key' (das Template
		# unterstuetzt die Richtung also physisch), _seal_exit() aber NICHTS
		# zugemauert, bleibt eine echte Wandoeffnung offen - obwohl die Zelle
		# daneben laut Layout GAR KEINEN Nachbarn hat. Man sieht dann durch
		# die Wand ins Leere, was von aussen wie ein fehlender Raum aussieht.
		# Nur warnen, wenn hier WIRKLICH etwas zu versiegeln war - sonst waere
		# jeder normale 1-2-Exit-Raum ein Fehlalarm (dessen unbenutzte
		# Richtungen hatten nie eine Tuer).
		var had_exit_point: bool = exit_points.has(key)
		exit_points.erase(key)

		if not seal_unused_exits:
			continue

		if _seal_exit(key):
			sealed_any = true
		elif had_exit_point:
			push_warning("RoomInstance (%s): Richtung '%s' hatte einen ExitPoint, konnte aber nicht zugemauert werden (Tuer nicht in _doors_by_dir registriert) - die Oeffnung bleibt offen und fuehrt ins Leere." % [grid_position, key])

	# Die frisch gemauerten Waende brauchen ihre Minimap-Kappe. Der zweite
	# Durchlauf ist billig: _build_wall_caps ueberspringt jede Wand, die
	# schon eine hat.
	if sealed_any and wall_cap_enabled:
		_build_wall_caps()

	# Erst JETZT die Zustandsplatten bauen - vorher stehen noch die
	# Tueren der Richtungen im Weg, die gerade zugemauert wurden.
	if door_marker_enabled:
		_build_door_markers()


## Legt ueber jeden verbliebenen Durchgang eine flache Platte auf
## MINIMAP_ONLY_LAYER. Farbe und Sichtbarkeit richten sich nach dem
## Tuerzustand, aktualisiert wird in _process().
func _build_door_markers() -> void:
	for dir in _doors_by_dir.keys():
		if _door_markers.has(dir):
			continue

		var door: Node3D = _doors_by_dir[dir] as Node3D
		if not is_instance_valid(door):
			continue

		var leaf := Vector3(10.0, 10.0, 0.8)
		var collision := door.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision != null and collision.shape is BoxShape3D:
			leaf = (collision.shape as BoxShape3D).size

		var box := BoxMesh.new()
		if leaf.x >= leaf.z:
			box.size = Vector3(leaf.x, door_marker_height, door_lintel_thickness)
		else:
			box.size = Vector3(door_lintel_thickness, door_marker_height, leaf.z)

		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = door_marker_color_locked

		var marker := MeshInstance3D.new()
		marker.name = "DoorMarker%s" % dir.capitalize()
		marker.mesh = box
		marker.material_override = material
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# Knapp UEBER der Wandoberkante, sonst kaempft die Platte im
		# Tiefenvergleich mit den Wandkappen (die sitzen exakt dort).
		marker.position = Vector3(door.position.x, room_height + door_marker_height, door.position.z)
		# Nur die Minimap-Kamera sieht diesen Layer.
		marker.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
		add_child(marker)

		_door_markers[dir] = {"node": marker, "material": material}
		_door_marker_states[dir] = -1


func _process(delta: float) -> void:
	if _door_markers.is_empty():
		return
	_door_marker_pulse = fmod(_door_marker_pulse + delta * 2.2, TAU)
	_refresh_door_markers()


## Faerbt die Platten nach dem ECHTEN Tuerzustand. Eine offene Tuer
## bekommt keine Platte - der Durchgang soll auf der Karte dann ja als
## Oeffnung zu lesen sein.
func _refresh_door_markers() -> void:
	for dir in _door_markers.keys():
		var entry: Dictionary = _door_markers[dir]
		var marker: MeshInstance3D = entry["node"]
		if not is_instance_valid(marker):
			continue

		var state: int = get_door_state(dir)

		# Der Puls muss jeden Frame durch, alles andere nur bei Wechsel.
		if state == DoorState.HACK_READY:
			var material: StandardMaterial3D = entry["material"]
			var pulsing: Color = door_marker_color_hack_ready
			pulsing.a = 0.55 + 0.45 * sin(_door_marker_pulse)
			material.albedo_color = pulsing
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

		if int(_door_marker_states.get(dir, -1)) == state:
			continue
		_door_marker_states[dir] = state

		match state:
			DoorState.OPEN, DoorState.NONE:
				marker.visible = false
			DoorState.LOCKED:
				marker.visible = true
				_set_marker_color(entry, door_marker_color_locked)
			DoorState.HACK_LOCKED:
				marker.visible = true
				_set_marker_color(entry, door_marker_color_hack_locked)
			DoorState.HACK_READY:
				marker.visible = true


func _set_marker_color(entry: Dictionary, color: Color) -> void:
	var material: StandardMaterial3D = entry["material"]
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	material.albedo_color = color


## Mauert EINE Richtung zu: Tuerblatt und Sturz raus, volle Wand rein.
## Liefert true, wenn tatsaechlich etwas gemauert wurde.
func _seal_exit(dir: String) -> bool:
	if not _doors_by_dir.has(dir):
		return false

	var door: Node3D = _doors_by_dir[dir] as Node3D
	_doors_by_dir.erase(dir)
	if not is_instance_valid(door):
		return false

	# Masse der Oeffnung aus dem Tuerblatt ableiten - dieselbe Quelle wie
	# beim Sturz, damit beides zusammenpasst und die Skalierung des Raums
	# automatisch mitgeht.
	var leaf := Vector3(10.0, 10.0, 0.8)
	var collision := door.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision != null and collision.shape is BoxShape3D:
		leaf = (collision.shape as BoxShape3D).size

	var door_x: float = door.position.x
	var door_z: float = door.position.z

	door.queue_free()

	# Der Sturz dieser Richtung ist jetzt ueberfluessig - er saesse mitten
	# in der neuen Wand.
	if _lintels_by_dir.has(dir):
		var lintel: Node = _lintels_by_dir[dir]
		if is_instance_valid(lintel):
			lintel.queue_free()
		_lintels_by_dir.erase(dir)

	var box_size: Vector3
	if leaf.x >= leaf.z:
		box_size = Vector3(leaf.x, room_height, door_lintel_thickness)
	else:
		box_size = Vector3(door_lintel_thickness, room_height, leaf.z)

	# Als DIREKTES Kind und mit "Wall"-Praefix, damit _build_wall_caps()
	# die Wand findet und ihr eine Minimap-Kappe verpasst.
	var body := StaticBody3D.new()
	body.name = "WallSeal%s" % dir.capitalize()
	add_child(body)
	body.position = Vector3(door_x, room_height * 0.5, door_z)

	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = box_mesh
	# material_override statt surface_material_override - Vorrangregel.
	mesh_instance.material_override = _load_lintel_material()
	body.add_child(mesh_instance)

	var shape := CollisionShape3D.new()
	shape.name = "CollisionShape3D"
	var box := BoxShape3D.new()
	box.size = box_size
	shape.shape = box
	body.add_child(shape)

	if debug_doors:
		print("[Room %s] Ausgang '%s' zugemauert (%.1f x %.1f)." % [grid_position, dir, box_size.x if box_size.x > box_size.z else box_size.z, box_size.y])

	return true


## Zaehlt EINEN Gegner genau EINMAL herunter, egal wie viele Signale fuer
## ihn feuern. Ohne die Deduplizierung wuerde ein Gegner, der sowohl
## died ALS AUCH tree_exited ausloest, doppelt zaehlen und der Raum
## koennte sich verfrueht als leer melden.
func _register_enemy_gone(enemy_id: int, generation: int = -1) -> void:
	# Nachzuegler aus einer abgeraeumten Welle ignorieren - siehe
	# _spawn_generation. -1 heisst "ohne Generation verbunden" und wird
	# aus Kompatibilitaet weiterhin akzeptiert.
	if generation != -1 and generation != _spawn_generation:
		return
	if _counted_dead_enemies.has(enemy_id):
		return
	_counted_dead_enemies[enemy_id] = true

	# Nie unter 0 - ein negativer Zaehler wuerde den Raum beim naechsten
	# Kill sofort als leer melden.
	_active_enemies = maxi(_active_enemies - 1, 0)
	if debug_doors:
		print("[Room %s] Gegner entfernt - noch %d aktiv." % [grid_position, _active_enemies])

	if _active_enemies <= 0 and not _is_cleared:
		_is_cleared = true
		_lock_exits(false)
		if debug_doors:
			print("[Room %s] CLEARED -> Tueren entriegelt." % grid_position)
		room_cleared.emit(self)


## Sicherheitsnetz gegen haengende Zaehler. Laeuft nur, solange der Raum
## noch nicht gecleared ist, und prueft im Sekundentakt, ob ueberhaupt noch
## gueltige Gegner-Instanzen existieren. Falls nicht, aber der Zaehler
## haengt noch ueber 0: Raum zwangsweise freigeben.
##
## Das faengt selbst den Fall ab, in dem ein Gegner ohne JEDES Signal
## verschwindet (z.B. wenn ein anderer Node ihn direkt aus dem Baum
## nimmt und free() statt queue_free() aufruft).
func _watchdog_check() -> void:
	if _is_cleared or not _requires_clear or not _enemies_spawned:
		return

	var alive: int = 0
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy) and enemy.is_inside_tree():
			alive += 1

	if alive > 0:
		return

	push_warning("RoomInstance (%s): Watchdog - kein lebender Gegner mehr, aber _active_enemies = %d. Raum wird zwangsweise freigegeben." % [grid_position, _active_enemies])
	_active_enemies = 0
	_is_cleared = true
	_lock_exits(false)
	room_cleared.emit(self)


## Echter Zustand des Durchgangs in dieser Richtung - siehe DoorState.
func get_door_state(dir: String) -> int:
	# exit_points wurde von apply_exit_flags() auf die vom Layout wirklich
	# geforderten Richtungen eingedampft. Steht dir nicht (mehr) drin,
	# existiert hier auch kein Durchgang.
	if not exit_points.has(dir):
		return DoorState.NONE
	if not _doors_by_dir.has(dir):
		return DoorState.NONE

	var door: Node = _doors_by_dir[dir]
	if not is_instance_valid(door):
		return DoorState.NONE

	if not (door is Door):
		return DoorState.OPEN

	var d: Door = door as Door
	if not d.is_locked():
		return DoorState.OPEN
	if d.requires_hack():
		return DoorState.HACK_READY if d.is_hack_enabled() else DoorState.HACK_LOCKED
	return DoorState.LOCKED


## Menschenlesbarer Name eines DoorState-Werts - fuer das Debug-Protokoll.
static func door_state_name(state: int) -> String:
	match state:
		DoorState.NONE: return "KEINE TUER"
		DoorState.OPEN: return "OFFEN"
		DoorState.LOCKED: return "VERRIEGELT"
		DoorState.HACK_LOCKED: return "HACK GESPERRT"
		DoorState.HACK_READY: return "HACK BEREIT"
	return "?"


## Vollstaendiger Zustandsbericht dieses Raums fuer das Tuer-Protokoll.
## Liefert eine Liste von Dictionaries, eine pro Himmelsrichtung, in der
## das Layout ueberhaupt einen Ausgang vorsieht.
func get_door_report() -> Array:
	var report: Array = []
	for dir in _FLAG_BY_KEY.keys():
		var has_marker: bool = exit_points.has(dir)
		var has_door: bool = _doors_by_dir.has(dir)

		# Richtungen ohne Marker UND ohne Tuer sind schlicht Wand - die
		# muessen nicht im Protokoll auftauchen.
		if not has_marker and not has_door:
			continue

		var door: Node = _doors_by_dir.get(dir)
		var kind: int = -1
		var hack_enabled: bool = false
		var hack_needed: bool = false
		var hack_exempt: bool = false
		if is_instance_valid(door) and door is Door:
			var d: Door = door as Door
			kind = d.door_kind
			hack_enabled = d.is_hack_enabled()
			hack_needed = d.requires_hack()
			hack_exempt = d.hack_exempt

		report.append({
			"dir": dir,
			"state": get_door_state(dir),
			"has_exit_marker": has_marker,
			"has_door_node": has_door,
			"door_kind": kind,
			"hack_enabled": hack_enabled,
			"hack_needed": hack_needed,
			"hack_exempt": hack_exempt,
		})
	return report


## Weltposition der Raummitte auf Bodenhoehe - z.B. fuer den Spawn der
## Sieg-Trophaee im Bossraum.
##
## Bevorzugt den ersten LootSpawnPoint-Marker: der ist von Hand gesetzt und
## liegt garantiert auf begehbarem Boden. Der reine Raum-Ursprung kann in
## Raeumen mit zentralem Lava-Pool, Loch oder Podest daneben liegen.
## ############################################################################
## PHASE 3.1 — MULTI-ZELLEN-RAEUME
## ############################################################################
## Verschiebt einen Durchgang ENTLANG seiner Wand.
##
## WOZU: ein Raum mit 2x1-Grundflaeche ist 96 Einheiten breit, die Nachbar-
## zelle daneben aber nur 48. Der Nordausgang muss deshalb nicht in der Mitte
## der langen Wand liegen, sondern genau vor der Zelle, an die er anschliesst.
## Ohne diese Verschiebung endet jede Tuer eines Multi-Zellen-Raums an der
## falschen Stelle und der Durchgang fuehrt gegen eine Wand.
##
## offset ist LOKAL und wird vom LevelGenerator aus der Differenz zwischen
## Raum-Mittelpunkt und Anker-Zelle berechnet (siehe _exit_offset_for_cell()).
##
## MUSS VOR apply_exit_flags() aufgerufen werden: die Zustandsplatten
## (_build_door_markers) leiten ihre Position von der Tuer ab und wuerden
## sonst an der alten Stelle stehen bleiben.
##
## BEKANNTE GRENZE: es bleibt bei EINER Tuer pro Himmelsrichtung. Mehrere
## Tuer-Slots pro Aussenkante brauchen einen Umbau von _doors_by_dir auf eine
## Liste und sind bewusst NICHT Teil dieser Aenderung.
func set_exit_offset(dir: String, offset: Vector3) -> void:
	if offset.length_squared() < 0.0001:
		return

	var marker := exit_points.get(dir) as Node3D
	if marker != null and is_instance_valid(marker):
		marker.position += offset

	var door := _doors_by_dir.get(dir) as Node3D
	if door != null and is_instance_valid(door):
		door.position += offset

	# Der Tuersturz wird bereits in _ready() gebaut und muss mitwandern.
	if _lintels_by_dir.has(dir):
		var lintel := _lintels_by_dir[dir] as Node3D
		if lintel != null and is_instance_valid(lintel):
			lintel.position += offset


## PHASE 3.2 — THEMEN-EBENEN
## Faerbt alle PSX-Materialien dieses Raums nach dem Theme der Etage ein.
##
## WARUM DUPLIZIERT WIRD:
## psx_material.tres ist EINE Resource, die sich alle Raeume teilen. Wuerde
## sie direkt eingefaerbt, haetten Etage 1 und Etage 2 dieselbe Farbe — bzw.
## die letzte gewinnt. Das ist derselbe geteilte-SubResource-Fehler wie bei
## den BoxMeshes. Deshalb bekommt jede MeshInstance3D beim ersten
## Theme-Wechsel ihre EIGENE Kopie.
func apply_theme(theme: StageTheme) -> void:
	if theme == null:
		return
	_apply_theme_recursive(self, theme)
	# Decke und Wandkappen werden im Code gebaut und haben eigene Materialien.
	ceiling_color = theme.ceiling_color
	wall_cap_color = theme.ceiling_color


func _apply_theme_recursive(node: Node, theme: StageTheme) -> void:
	var mesh := node as MeshInstance3D
	# BUGFIX "Abyss-Loch ist weiss/untexturiert": pit_floor.gd erzeugt fuer
	# extra_void_pits einen absichtlich unbeleuchteten NAHE-SCHWARZ-Schacht
	# (_emit_dark_box, Name enthaelt "VoidShaft") - er soll die Falltiefe
	# verschleiern (siehe Kommentar dort), egal welches Etagen-Theme aktiv
	# ist. Diese generierten Kinder haengen direkt unter dem "Floor"-Node,
	# tint_for_node_name() liest aber den PARENT-Namen und haette sie sonst
	# wie normale Bodenflaechen mit floor_color eingefaerbt - je nach Theme
	# (z.B. Tiefkuehlhaus: Color(0.72, 0.84, 0.95), fast weiss) sieht der
	# Abgrund dann aus wie eine flache, unbelichtete Flaeche statt wie ein
	# dunkles Loch.
	if mesh != null and not mesh.name.to_lower().contains("voidshaft"):
		var tint: Color = theme.tint_for_node_name(mesh.get_parent().name if mesh.get_parent() else mesh.name)
		# material_override hat Vorrang vor surface_material_override.
		if mesh.material_override != null:
			var copy: Material = mesh.material_override.duplicate()
			_tint_material(copy, tint)
			mesh.material_override = copy
		else:
			for i: int in range(mesh.get_surface_override_material_count()):
				var surface: Material = mesh.get_surface_override_material(i)
				if surface == null:
					continue
				var dup: Material = surface.duplicate()
				_tint_material(dup, tint)
				mesh.set_surface_override_material(i, dup)
	for child: Node in node.get_children():
		_apply_theme_recursive(child, theme)


func _tint_material(material: Material, tint: Color) -> void:
	if material is ShaderMaterial:
		(material as ShaderMaterial).set_shader_parameter("albedo_color", tint)
	elif material is BaseMaterial3D:
		(material as BaseMaterial3D).albedo_color = tint


func get_room_center() -> Vector3:
	for marker in loot_spawn_points:
		if is_instance_valid(marker):
			return marker.global_position
	return global_position


func is_cleared() -> bool:
	return _is_cleared


func requires_clear() -> bool:
	return _requires_clear


## Aktiver Kampf laeuft: Gegner wurden gespawnt, der Raum ist aber noch nicht
## geleert. Von door.gd benutzt, um Hacking waehrend des Kampfs direkt am
## Raumzustand zu verweigern - unabhaengig davon, ob set_door_hack_enabled()
## fuer diese Tuer (noch) korrekt gesetzt wurde.
func is_in_combat() -> bool:
	return _requires_clear and _enemies_spawned and not _is_cleared


func get_active_enemy_count() -> int:
	return _active_enemies


func _lock_exits(locked: bool) -> void:
	for dir in exit_points.keys():
		var marker: Marker3D = exit_points[dir]
		if not marker.has_meta("door_node"):
			push_warning("RoomInstance (%s): ExitPoint '%s' hat keine door_node-Meta - Tuer kann weder ver- noch entriegelt werden." % [grid_position, dir])
			continue
		var door: Node = marker.get_meta("door_node")
		if not is_instance_valid(door) or not door.has_method("set_locked"):
			push_warning("RoomInstance (%s): Tuer '%s' ist ungueltig oder hat kein set_locked()." % [grid_position, dir])
			continue
		door.set_locked(locked)
		if debug_doors:
			print("[Room %s] Tuer '%s' -> %s (danach: %s)" % [
				grid_position, dir,
				"VERRIEGELN" if locked else "ENTRIEGELN",
				door_state_name(get_door_state(dir))
			])


## Wird EINMALIG nach Ablauf der Verweilzeit gerufen und startet den
## Kampf. Das room_entered-Signal kommt NICHT mehr von hier, sondern aus
## _update_entry_presence() - sonst wuerde es beim Rueckkehren in einen
## geclearten Raum fehlen.
func on_player_entered() -> void:
	if _is_cleared or _enemies_spawned or not _requires_clear:
		return
	_enemies_spawned = true
	_lock_exits(true)
	_spawn_prepared_enemies()
