

extends Node

# ============================================================================
# RoomGuard — Autoload: schliesst die Luecke, durch die man Raeume umgehen
# kann, ohne den Kampf auszuloesen.
# Muss unter Project Settings -> Autoload als "RoomGuard" stehen.
# ============================================================================
#
# ############################################################################
# ZUERST: WARUM DAS FEATURE BISHER GAR NICHTS GETAN HAT
# ############################################################################
# Die vorherige Fassung dieser Datei war UNVOLLSTAENDIG. Sie endete mitten
# in _attach() direkt nach
#
#     area.collision_mask = 0b101
#
# Danach kam nichts mehr: kein CollisionShape3D, kein add_child(), kein
# Eintrag in _watched, kein _process(). GDScript parst das ohne Fehler —
# eine Funktion darf an jeder Stelle enden. Das Autoload lief also, hat pro
# Raum brav eine Area3D erzeugt, sie sofort wieder verworfen und
# ANSCHLIESSEND NIE WIEDER ETWAS GEMACHT.
#
# Das ist die unangenehmste Fehlerklasse ueberhaupt: keine Fehlermeldung,
# kein Warnhinweis, kein Absturz. Das Feature war schlicht nicht da. Der
# Wand-Hug-Trick ("an den Seiten am Raum vorbeilaufen") ist deshalb nie
# geschlossen worden — nicht weil die Idee falsch war, sondern weil sie nie
# fertig geschrieben wurde.
#
# ############################################################################
# DAS URSPRUENGLICHE PROBLEM
# ############################################################################
# room_instance.gd loest den Kampf ueber den EntryTrigger aus. Dessen Box
# wird von JEDER Seite um entry_trigger_depth eingerueckt:
#
#     size_x = room_footprint.x - entry_trigger_depth * 2.0
#
# In einem 48x48-Raum bleibt damit ringsum ein 9 m breiter Streifen, in dem
# nichts passiert. Die Tueren sitzen mittig in den Waenden — man kann also
# durch die Nordtuer hereinkommen, an der Wand entlang zur Osttuer laufen
# und den Raum verlassen, ohne den Kern je zu beruehren. Die Gegner spawnen
# nie, die Tueren verriegeln nie.
#
# WARUM DIE EINRUECKUNG TROTZDEM RECHT HAT
# ----------------------------------------
# Sie ist Absicht ("Anti-Baiting"): man soll in einen Raum hineinschauen
# duerfen, ohne sofort einen Kampf zu starten. Den EntryTrigger einfach auf
# Raumgroesse aufzublasen wuerde das zerstoeren — dann startet der Kampf
# schon, wenn man im Tuerrahmen steht und ueberlegt.
#
# ############################################################################
# DIE LOESUNG: ZWEITE STUFE MIT ZWEI UNABHAENGIGEN AUSLOESERN
# ############################################################################
# Dieses Script haengt jedem Raum eine ZUSAETZLICHE Area ueber den vollen
# Grundriss und startet den Kampf, sobald EINE der beiden Bedingungen
# erfuellt ist:
#
#   1. VERWEILDAUER (commit_dwell_time)
#      Der Spieler ist so lange am Stueck drin. Faengt den Fall
#      "stehenbleiben / kaempfen / umschauen" ab.
#
#   2. ZURUECKGELEGTE STRECKE (commit_travel_factor)
#      Der Spieler hat innerhalb des Grundrisses so viele Meter
#      zurueckgelegt. Genau DAS ist der Wand-Hug-Fall: von einer Tuer zur
#      naechsten sind es quer durch den Raum immer deutlich mehr Meter als
#      der Schwellwert — egal wie schnell man dabei ist.
#
# Warum zwei Bedingungen und nicht nur die Zeit:
# Eine reine Verweildauer ist ueber die Bewegungsgeschwindigkeit angreifbar.
# Ein Dash quer durch den Raum dauert deutlich weniger als eine Sekunde, und
# je hoeher die Bewegungs-Stats im Run werden, desto zuverlaessiger geht der
# Trick wieder auf. Die Strecke ist gegen Tempo immun: wer schneller ist,
# loest frueher aus statt spaeter.
#
# Umgekehrt bleibt "kurz reinschauen und zurueck" weiter erlaubt — dafuer
# laeuft man weder lange genug noch weit genug.
#
# WARUM ALS AUTOLOAD UND NICHT IN room_instance.gd:
# Dieselbe Begruendung wie bei Loot und Treasure — room_instance.gd hat
# 1800 Zeilen und sehr viel Zustand. Ein zusaetzliches Volumen mit eigenem
# Timer laesst sich vollstaendig von aussen anhaengen, und wenn sich das
# Feature nicht bewaehrt, entfernt man einen Autoload-Eintrag statt einen
# Merge-Konflikt aufzuloesen.

signal room_committed(room: Node)

## Wie lange der Spieler ununterbrochen im Raum sein muss, bis der Kampf
## auch ohne Beruehrung des EntryTriggers startet.
##
## Von 0.6 auf 0.35 gesenkt. Die Verweildauer ist nach Einfuehrung der
## Strecken-Bedingung nur noch der Auffangfall fuer langsames Hineingehen;
## sie muss deshalb nicht mehr allein gegen schnelle Durchlaeufe halten.
##
## BUGFIX "Raum verriegelt schon im Tuerrahmen": Die Verweildauer laeuft
## jetzt NUR noch, solange der Spieler in der INNENZONE steht (siehe
## commit_inner_zone_factor). Vorher zaehlte sie ab dem ersten Frame im
## Grundriss — und der Grundriss beginnt exakt an der Wandinnenseite, also
## im Tuerrahmen. 0.35 s Stehenbleiben beim Hineinschauen haben damit
## verriegelt; wer danach rausgedasht ist, hat ueber _check_escape() den
## kompletten Raum zurueckgesetzt ("Gegner verschwinden").
@export var commit_dwell_time: float = 0.35

## Wie weit die Innenzone gegenueber dem Grundriss eingerueckt ist — als
## Anteil der halben Kantenlaenge. 0.28 bedeutet: die aeusseren 28 % der
## Raumhaelfte zaehlen NICHT als "drin".
##
## Das ist die eigentliche Anti-Bait-Grenze. Sie ersetzt NICHT edge_inset:
## die Area bleibt bewusst auf vollem Grundriss, weil die STRECKEN-
## Bedingung genau den Randstreifen mitmessen muss (Wand-Hug).
@export_range(0.0, 0.45) var commit_inner_zone_factor: float = 0.28

## Anteil der kuerzeren WELT-Kante des Raumes, den der Spieler innerhalb
## des Grundrisses zuruecklegen muss.
##
## BUGFIX "Commit feuert nach 7 Metern": commit_travel_distance war ein
## fester Meterwert, verglichen mit global_position-Deltas — also
## Weltmetern. Der LevelGenerator skaliert Raeume aber mit room_scale
## (2,2,2): aus 48 m Grundriss werden 96 m Weltkante. 7 m sind darin
## ~7 % der Raumbreite, faktisch die Tuerschwelle. Der Schwellwert wird
## deshalb jetzt aus der TATSAECHLICHEN Weltgroesse des Raumes abgeleitet.
@export_range(0.1, 1.5) var commit_travel_factor: float = 0.5

## Absolute Untergrenze in Weltmetern, damit sehr kleine Raeume nicht
## sofort ausloesen.
@export var commit_travel_min: float = 7.0

## Verkleinert die Commit-Area gegenueber dem Grundriss. 0 = exakt bis zur
## Wandinnenseite.
##
## BEWUSST 0: der Ausnutz-Weg fuehrt DIREKT an der Wand entlang. Jede
## Einrueckung, die groesser ist als der Radius der Spielerkapsel, laesst
## genau diesen Pfad wieder offen — die Luecke waere dann nur schmaler, aber
## nicht zu.
@export var edge_inset: float = 0.0

## Aus welcher Hoehe ueber dem Raumboden die Area beginnt. Etwas unter 0,
## damit auch abgesenkte Bodenstuecke und Rampen erfasst werden.
@export var floor_offset: float = -1.0

## Wie weit die Area ueber die Raumhoehe hinausragt. Ohne Zuschlag rutscht
## ein springender Spieler in Raeumen mit niedriger Decke kurzzeitig aus
## dem Volumen und der Fortschritt wuerde zurueckgesetzt.
@export var height_padding: float = 4.0

@export var debug_logging: bool = false

## room InstanceID -> {
##     "room": RoomInstance,
##     "area": Area3D,
##     "dwell": float,
##     "travel": float,
##     "last_pos": Vector3,
##     "had_player": bool,
##     "done": bool
## }
var _watched: Dictionary = {}


func _debug(msg: String) -> void:
	if debug_logging:
		print("[RoomGuard] %s" % msg)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_debug("Autoload aktiv.")
	get_tree().node_added.connect(_on_node_added)
	_scan_existing.call_deferred()


func _scan_existing() -> void:
	var root: Node = get_tree().root
	if root == null:
		return
	_scan_recursive(root)


func _scan_recursive(node: Node) -> void:
	_on_node_added(node)
	for child: Node in node.get_children():
		_scan_recursive(child)


func _on_node_added(node: Node) -> void:
	if not (node is RoomInstance):
		return
	var room: RoomInstance = node as RoomInstance
	if _watched.has(room.get_instance_id()):
		return
	_attach_deferred.call_deferred(room)


## Eine Physik-Frame warten, damit room_footprint, room_height und die
## Welt-Transform stehen (der LevelGenerator setzt global_transform erst
## NACH add_child).
func _attach_deferred(room: RoomInstance) -> void:
	if not is_instance_valid(room):
		return
	await get_tree().physics_frame
	if not is_instance_valid(room) or not room.is_inside_tree():
		return
	_attach(room)


func _attach(room: RoomInstance) -> void:
	var id: int = room.get_instance_id()
	if _watched.has(id):
		return

	var area := Area3D.new()
	area.name = "CommitTrigger"
	# Layer 0 / Maske 0b101: exakt dieselbe Konfiguration wie EntryTrigger
	# und PresenceArea in room_instance.gd. Weicht sie ab, findet die Area
	# den Spieler nicht — und das aeussert sich nicht als Fehler, sondern
	# nur dadurch, dass das Feature stillschweigend nichts tut.
	area.collision_layer = 0
	area.collision_mask = 0b101
	area.monitoring = true
	area.monitorable = false

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()

	var size_x: float = maxf(room.room_footprint.x - edge_inset * 2.0, 1.0)
	var size_z: float = maxf(room.room_footprint.y - edge_inset * 2.0, 1.0)
	var size_y: float = maxf(room.room_height - floor_offset + height_padding, 1.0)

	box.size = Vector3(size_x, size_y, size_z)
	shape.shape = box
	shape.position = Vector3(0.0, floor_offset + size_y * 0.5, 0.0)

	area.add_child(shape)
	room.add_child(area)

	# --- Weltmasse des Raumes ------------------------------------------
	#
	# room_footprint ist ein LOKALER Wert der Raum-Szene. load_room() im
	# LevelGenerator setzt die Raum-Basis auf
	# Basis.IDENTITY.scaled(room_scale) — die echte Kantenlaenge in der
	# Welt ist also footprint * scale. Alles, was gegen global_position
	# gerechnet wird (die Strecke), MUSS diese Groesse benutzen.
	var room_scale: Vector3 = room.global_transform.basis.get_scale()
	var world_x: float = room.room_footprint.x * absf(room_scale.x)
	var world_z: float = room.room_footprint.y * absf(room_scale.z)
	var travel_threshold: float = maxf(
		minf(world_x, world_z) * maxf(commit_travel_factor, 0.05),
		maxf(commit_travel_min, 0.1)
	)

	# Innenzone in LOKALEN Koordinaten — der Test laeuft ueber
	# room.to_local(), und lokale Koordinaten sind von room_scale
	# unabhaengig. Deshalb hier bewusst KEINE Skalierung einrechnen.
	var inner_half := Vector2(
		room.room_footprint.x * 0.5 * (1.0 - clampf(commit_inner_zone_factor, 0.0, 0.45)),
		room.room_footprint.y * 0.5 * (1.0 - clampf(commit_inner_zone_factor, 0.0, 0.45))
	)

	_watched[id] = {
		"room": room,
		"area": area,
		"dwell": 0.0,
		"travel": 0.0,
		"last_pos": Vector3.ZERO,
		"had_player": false,
		"done": false,
		"inner_half": inner_half,
		"travel_threshold": travel_threshold,
	}

	# Ohne diese Aufraeumung waechst _watched ueber die Laufzeit eines Runs
	# mit jedem Stage-Wechsel weiter an und haelt Zeiger auf abgeraeumte
	# Raeume.
	room.tree_exited.connect(_on_room_gone.bind(id))

	_debug("Raum %s ueberwacht (lokal %.0f x %.0f, Welt %.0f x %.0f, Strecke >= %.1f m)." % [
		room.grid_position, size_x, size_z, world_x, world_z, travel_threshold
	])


func _on_room_gone(id: int) -> void:
	_watched.erase(id)


func _physics_process(delta: float) -> void:
	if _watched.is_empty():
		return

	for id: int in _watched.keys():
		var entry: Dictionary = _watched[id]
		if entry["done"]:
			continue

		var room: Node = entry["room"]
		if not is_instance_valid(room):
			_watched.erase(id)
			continue

		var area: Area3D = entry["area"]
		if not is_instance_valid(area):
			_watched.erase(id)
			continue

		# Raum bereits ausgeloest oder gar kein Kampfraum -> nichts zu tun.
		# Ueber has_method/get abgefragt statt ueber direkte Feldzugriffe,
		# damit dieses Script auch mit aelteren RoomInstance-Versionen laeuft.
		if _room_is_settled(room):
			entry["done"] = true
			_watched[id] = entry
			continue

		var player: Node3D = _find_player(area)

		if player == null:
			# Verlassen -> Fortschritt faellt zurueck. Sonst koennte man
			# sich das Commit in mehreren kurzen Besuchen zusammensparen,
			# und "kurz reinschauen" waere ab dem dritten Mal ein Kampf.
			entry["dwell"] = 0.0
			entry["travel"] = 0.0
			entry["had_player"] = false
			_watched[id] = entry
			continue

		if not entry["had_player"]:
			entry["had_player"] = true
			entry["last_pos"] = player.global_position
			entry["dwell"] = 0.0
			entry["travel"] = 0.0

		# --- Bedingung 1: Verweildauer IN DER INNENZONE ---
		#
		# Der Randstreifen zaehlt bewusst nicht mit. Wer im Tuerrahmen
		# steht und in den Raum schaut, baut keine Verweildauer auf —
		# genau das war der "zu frueh verriegelt"-Fall. Verlaesst der
		# Spieler die Innenzone wieder, faellt NUR die Verweildauer
		# zurueck; die Strecke bleibt stehen, sonst waere der Wand-Hug
		# ueber den Randstreifen wieder offen.
		var current: Vector3 = player.global_position
		var local: Vector3 = room.to_local(current)
		var inner_half: Vector2 = entry["inner_half"]
		var in_inner: bool = absf(local.x) <= inner_half.x and absf(local.z) <= inner_half.y

		if in_inner:
			entry["dwell"] = float(entry["dwell"]) + delta
		else:
			entry["dwell"] = 0.0

		# --- Bedingung 2: zurueckgelegte Strecke ---
		# Nur horizontal: Springen und Fallen sollen keine Strecke
		# aufbauen, sonst loest ein Sprung im Tuerrahmen aus.
		var last: Vector3 = entry["last_pos"]
		var step: Vector3 = current - last
		step.y = 0.0
		entry["travel"] = float(entry["travel"]) + step.length()
		entry["last_pos"] = current

		var by_time: bool = float(entry["dwell"]) >= maxf(commit_dwell_time, 0.0)
		var by_travel: bool = float(entry["travel"]) >= float(entry["travel_threshold"])

		if by_time or by_travel:
			entry["done"] = true
			_watched[id] = entry
			_commit(room, "Verweildauer" if by_time else "Strecke")
			continue

		_watched[id] = entry


## true, wenn der Raum aus Sicht des Guards nicht mehr interessant ist:
## gecleared, bereits betreten, oder gar kein Kampfraum.
func _room_is_settled(room: Node) -> bool:
	if room.has_method("is_cleared") and room.is_cleared():
		return true
	# _has_entered / _enemies_spawned sind private Felder von
	# room_instance.gd. get() liest sie ohne Fehler aus und liefert null,
	# falls es sie in einer anderen Version nicht gibt.
	if room.get("_enemies_spawned") == true:
		return true
	if room.get("_requires_clear") == false:
		return true
	return false


func _find_player(area: Area3D) -> Node3D:
	for body: Node3D in area.get_overlapping_bodies():
		if body is Node3D and body.is_in_group(PartyManager.PLAYER_GROUP):
			return body
	return null


## Loest den Kampf aus.
##
## _has_entered wird ueber set() mitgesetzt, NICHT nur on_player_entered()
## aufgerufen. Grund: room_instance._physics_process() schaltet erst bei
## _has_entered == true auf die Ausbruch-Ueberwachung (_check_escape) um.
## Ohne das Flag wuerde ein per Guard gestarteter Kampf nie zuruecksetzen,
## wenn der Spieler den verriegelten Raum doch noch verlaesst — der Raum
## bliebe dauerhaft in einem halb toten Zustand haengen.
##
## Der fuehrende Unterstrich ist in GDScript reine Namenskonvention, kein
## Zugriffsschutz; set() ist hier also kein Trick, sondern der normale Weg.
func _commit(room: Node, reason: String) -> void:
	if room.has_method("on_player_entered"):
		room.set("_has_entered", true)
		room.on_player_entered()
		room_committed.emit(room)
		_debug("Raum %s festgesetzt (Ausloeser: %s)." % [room.get("grid_position"), reason])
	else:
		push_warning("RoomGuard: Raum ohne on_player_entered() — Commit nicht moeglich.")
