extends Node

# ============================================================================
# Treasure — Autoload: setzt in JEDEN Schatzraum genau EINEN Item-Sockel.
# Muss unter Project Settings -> Autoload als "Treasure" stehen.
# ============================================================================
#
# WARUM ES DIESES SCRIPT UEBERHAUPT GIBT:
# Der Item-Katalog (item_catalog.gd), die Effekte (item_behaviours.gd), die
# Stat-Anbindung (player_stats.gd) und die Anzeige (item_description_hud.gd)
# waren bereits vollstaendig — aber Pickup.create_item() wurde im ganzen
# Projekt an KEINER Stelle aufgerufen. Es gab also acht fertige Items, die
# im Spiel nicht existierten. Dieses Script schliesst genau diese Luecke.
#
# DESIGN-VORGABE (Isaac): Items findet man ausschliesslich im Schatzraum,
# einzeln, mitten im Raum, auf einem Sockel. Deshalb NICHT ueber den
# LootManager: der wuerfelt nach dem Raum-Clear Verbrauchsgueter aus und
# waere fuer eine garantierte, einmalige Belohnung der falsche Ort.
#
# WIE ES SICH AN DIE RAEUME HAENGT: ueber SceneTree.node_added, exakt wie
# loot_manager.gd. Damit funktioniert es sowohl fuer generierte Level als
# auch fuer handgebaute Testszenen, in denen RoomInstances direkt in der
# .tscn stehen — und ohne eine einzige Zeile Aenderung an
# level_generator.gd oder room_instance.gd.
#
# ---------------------------------------------------------------------------
# WICHTIGE REIHENFOLGE-KORREKTUR GEGENUEBER DER ERSTEN FASSUNG
# ---------------------------------------------------------------------------
# level_generator.load_room() macht der Reihe nach:
#     instantiate() -> add_child()   <-- HIER feuert node_added
#     dann: instance.global_transform = ...
#     dann (im Aufrufer): room.grid_position = grid_pos
#
# Die Erkennung lief bisher direkt in _on_node_added und sah deshalb einen
# Raum, der noch bei (0,0,0) stand und dessen grid_position noch (0,0) war.
# Der Pfad-Check hat das ueberdeckt, der Generator-Fallback war aber tot und
# der RNG-Salt haette fuer alle Raeume gleich gelautet.
#
# Jetzt wird in _on_node_added NUR noch gemerkt, dass ein RoomInstance
# aufgetaucht ist. Geprueft und gespawnt wird eine Physik-Frame spaeter,
# wenn Transform, grid_position und die Kollisionsformen stehen.
#
# ---------------------------------------------------------------------------
# DIAGNOSE
# ---------------------------------------------------------------------------
# Dieses Script meldet sich beim Start und bei JEDEM gesehenen Raum zu Wort,
# solange debug_logging an ist. Wenn in der Konsole gar keine
# "[Treasure]"-Zeile auftaucht, laeuft _ready() nicht — dann ist der Autoload
# nicht eingetragen oder der Pfad stimmt nicht. Das ist die einzige
# Fehlerursache, die man sonst nicht von "Raum nicht erkannt" unterscheiden
# koennte, weil beides zu demselben Symptom fuehrt: kein Sockel.

signal pedestal_spawned(item: ItemData, room: Node)
signal treasure_item_taken(item: ItemData)

## Gruppe, mit der sich ein Raum manuell als Schatzraum markieren laesst.
const TREASURE_GROUP: String = "treasure_room"

## Teilstring im Szenenpfad, an dem Schatzraum-Prefabs erkannt werden.
const TREASURE_PATH_HINT: String = "/treasure/"

## Wie hoch ueber dem gefundenen Boden der Sockelfuss sitzt.
const GROUND_OFFSET: float = 0.02

## Wie tief NACH UNTEN gesucht wird. Nach oben wird bewusst NICHT gesucht,
## siehe _find_spawn_position().
const PROBE_DEPTH: float = 40.0

## Sicherheitsabstand, falls der Raycast ins Leere geht.
const FALLBACK_HEIGHT: float = 1.6

## Ein zweites Exemplar desselben Items ist bei nur acht Items im Katalog
## eine Enttaeuschung. Erst wenn wirklich alles vergeben ist, wird der Pool
## zurueckgesetzt.
@export var avoid_duplicates: bool = true

## Meldet jeden gesehenen Raum mitsamt Erkennungsergebnis. Nach der
## Verifikation auf false stellen.
@export var debug_logging: bool = true

## NOTNAGEL FUER DIE FEHLERSUCHE: setzt in JEDEN Raum einen Sockel, egal
## welcher Typ. Nur zum Testen — damit laesst sich in Sekunden klaeren, ob
## das Problem bei der Raum-ERKENNUNG oder beim SPAWNEN selbst liegt.
@export var debug_spawn_in_every_room: bool = false

## Item-IDs, die in diesem Run bereits auf einem Sockel lagen.
var _reserved_ids: Dictionary = {}   # String -> true
## Raeume, die schon behandelt wurden (erkannt oder abgelehnt).
var _handled_rooms: Dictionary = {}  # InstanceID -> true
## Run-Seed beim letzten Spawn. Aendert er sich, beginnt ein neuer Lauf.
var _last_seen_seed: int = -1
## Nur fuers Log: wie viele Raeume ueberhaupt gesehen wurden.
var _rooms_seen: int = 0


func _debug(msg: String) -> void:
	if debug_logging:
		print("[Treasure] %s" % msg)


func _ready() -> void:
	# ALWAYS statt PAUSABLE: die Generierung laeuft zwar nie pausiert, aber
	# ein Autoload, das sich beim Pausieren abschaltet, verliert im Zweifel
	# genau das node_added, auf das es wartet.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Diese Zeile ist der Lebensbeweis. Fehlt sie in der Konsole, ist der
	# Autoload nicht eingetragen — alles andere ist dann Zeitverschwendung.
	_debug("Autoload aktiv. Warte auf RoomInstances.")

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


## Hier wird NICHTS mehr geprueft ausser dem Typ. Begruendung siehe Kopf der
## Datei: zu diesem Zeitpunkt sind Transform und grid_position des Raums
## noch nicht gesetzt.
func _on_node_added(node: Node) -> void:
	if not (node is RoomInstance):
		return
	var room: RoomInstance = node as RoomInstance
	var id: int = room.get_instance_id()
	if _handled_rooms.has(id):
		return
	# Sofort sperren, nicht erst nach dem await: sonst kann derselbe Raum
	# ueber node_added UND ueber _scan_existing zweimal durchlaufen.
	_handled_rooms[id] = true
	_rooms_seen += 1

	# Die laufende Nummer wird HIER festgehalten und mitgereicht. Wuerde sie
	# erst im deferred Teil gelesen, stuende in jeder Log-Zeile dieselbe
	# Endsumme — alle Raeume werden im selben Frame hinzugefuegt, die
	# Auswertung laeuft aber erst danach.
	_process_room_deferred.call_deferred(room, _rooms_seen)


## Eine Physik-Frame spaeter: jetzt stehen Welt-Transform, grid_position und
## die Kollisionsformen des Raums.
func _process_room_deferred(room: RoomInstance, index: int) -> void:
	if not is_instance_valid(room):
		return
	await get_tree().physics_frame
	if not is_instance_valid(room) or not room.is_inside_tree():
		return

	var verdict: String = _detection_reason(room)
	var is_treasure: bool = verdict != ""

	_debug("Raum #%d gesehen: grid=%s szene='%s' -> %s" % [
		index,
		room.grid_position,
		room.scene_file_path,
		verdict if is_treasure else "kein Schatzraum"
	])

	if not is_treasure and not debug_spawn_in_every_room:
		return

	_spawn_pedestal(room)


# ============================================================================
# Erkennung
# ============================================================================
## Liefert den GRUND, warum der Raum als Schatzraum gilt — oder "" wenn
## nicht. Ein String statt bool, damit im Log steht, WELCHER der drei Wege
## gegriffen hat. Bei "kein Sockel gespawnt" ist genau das die Information,
## die man braucht.
func _detection_reason(room: RoomInstance) -> String:
	if room.is_in_group(TREASURE_GROUP):
		return "TREFFER (Gruppe '%s')" % TREASURE_GROUP

	if room.scene_file_path.to_lower().contains(TREASURE_PATH_HINT):
		return "TREFFER (Szenenpfad enthaelt '%s')" % TREASURE_PATH_HINT

	if _generator_says_treasure(room):
		return "TREFFER (LevelGenerator meldet RoomType.TREASURE)"

	return ""


## Dritter Weg: den LevelGenerator nach dem Typ der Rasterzelle fragen.
func _generator_says_treasure(room: RoomInstance) -> bool:
	var generator: Node = _find_generator()
	if generator == null:
		return false

	var cells = generator.get("_map_cells")
	if not (cells is Dictionary):
		return false
	if not cells.has(room.grid_position):
		return false

	var cell = cells[room.grid_position]
	if not (cell is Dictionary):
		return false
	return int(cell.get("type", -1)) == RoomData.RoomType.TREASURE


# ============================================================================
# Spawnen
# ============================================================================
func _spawn_pedestal(room: RoomInstance) -> void:
	_maybe_reset_for_new_run()

	var item: ItemData = _pick_item(room)
	if item == null:
		push_warning("[Treasure] Raum %s: kein Item verfuegbar — Sockel uebersprungen." % room.grid_position)
		return

	var pedestal := TreasurePedestal.create(item)
	room.add_child(pedestal)
	pedestal.global_position = _find_spawn_position(room)
	pedestal.item_taken.connect(_on_item_taken)

	_reserved_ids[item.id] = true
	pedestal_spawned.emit(item, room)

	_debug("  -> Sockel gesetzt: '%s' bei %s." % [item.display_name, pedestal.global_position])


## Raum-Ursprung ist bei allen Prefabs die Raum-MITTE (Waende liegen
## symmetrisch bei +-24). Deshalb wird von dort aus nach unten gemessen.
##
## WARUM NICHT room.get_room_center():
## Die Funktion liefert den ERSTEN LootSpawnPoint-Marker zurueck, und die
## liegen im Schatzraum-Prefab bei (-4, 2.1, -4) — also in einer Ecke der
## Plattform, nicht in der Mitte. Der Sockel stuende sichtbar schief.
##
## ---------------------------------------------------------------------------
## WARUM DER STRAHL NICHT VON GANZ OBEN KOMMT (behobener Fehler)
## ---------------------------------------------------------------------------
## room_instance.gd baut sich in _build_ceiling() selbst eine DECKE als
## StaticBody3D mit Kollision:
##     position.y = room_height + ceiling_thickness * 0.5   (= 14.5)
##     box.size.y = ceiling_thickness                        (= 1.0)
## Deren Oberkante liegt damit bei exakt 15.0.
##
## Ein Strahl, der 40 m ueber dem Raum startet, trifft folglich zuerst das
## DACH und nicht den Boden — der Sockel landete bei y = 15.02, also
## ausserhalb des begehbaren Raums und fuer den Spieler unsichtbar. Und
## zwar ohne jede Fehlermeldung, weil der Raycast ja erfolgreich war.
##
## Zwei Absicherungen dagegen:
##   1. Der Strahl startet auf halber Raumhoehe, also UNTERHALB der Decke.
##   2. Die Decke wird zusaetzlich explizit ausgeschlossen — falls jemand
##      room_height spaeter kleiner setzt als die Deckenhoehe.
func _find_spawn_position(room: RoomInstance) -> Vector3:
	var center: Vector3 = room.global_position
	var world: World3D = room.get_world_3d()
	if world == null:
		return center + Vector3(0.0, FALLBACK_HEIGHT, 0.0)

	# Halbe Raumhoehe: sicher unter der Decke und sicher ueber jeder
	# Plattform (im Schatzraum liegt die hoechste bei 1.6).
	var start_height: float = clampf(room.room_height * 0.5, 2.0, maxf(room.room_height - 1.5, 2.0))

	var space: PhysicsDirectSpaceState3D = world.direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		center + Vector3(0.0, start_height, 0.0),
		center + Vector3(0.0, -PROBE_DEPTH, 0.0)
	)
	# Nur echte Geometrie: Areas sind hier Trigger-Volumen (Raum-Eintritt,
	# Praesenz) und wuerden den Sockel in die Luft haengen.
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = _collect_ceiling_rids(room)

	var hit: Dictionary = space.intersect_ray(query)
	if hit.is_empty():
		_debug("  Boden-Raycast ins Leere (Start %.1f) — Ersatzhoehe %.1f benutzt." % [
			start_height, FALLBACK_HEIGHT
		])
		return center + Vector3(0.0, FALLBACK_HEIGHT, 0.0)

	var point: Vector3 = hit["position"]
	return Vector3(center.x, point.y + GROUND_OFFSET, center.z)


## Decke und Tuersturz-Koerper, die room_instance.gd zur Laufzeit anlegt.
## Beide haengen direkt unter dem Raum-Root und heissen fest "Ceiling" bzw.
## beginnen mit "DoorLintel".
func _collect_ceiling_rids(room: RoomInstance) -> Array[RID]:
	var rids: Array[RID] = []
	for child: Node in room.get_children():
		if not (child is CollisionObject3D):
			continue
		if child.name == "Ceiling" or String(child.name).begins_with("DoorLintel"):
			rids.append((child as CollisionObject3D).get_rid())
	return rids


# ============================================================================
# Item-Auswahl
# ============================================================================
## Deterministisch aus Run-Seed und Rasterposition. Bereits vergebene Items
## fliegen aus dem Pool, damit man in einem Lauf nicht zweimal denselben
## Kochloeffel findet.
func _pick_item(room: RoomInstance) -> ItemData:
	var items: Node = get_node_or_null("/root/Items")
	if items == null:
		push_warning("[Treasure] Autoload 'Items' nicht gefunden — kein Sockel moeglich. Autoload-Reihenfolge pruefen: 'Items' muss VOR 'Treasure' stehen.")
		return null

	var catalog: Array = items.catalog
	if catalog.is_empty():
		push_warning("[Treasure] Item-Katalog ist leer.")
		return null

	var pool: Array[ItemData] = []
	for entry in catalog:
		if not (entry is ItemData):
			continue
		var data: ItemData = entry as ItemData
		if avoid_duplicates and _reserved_ids.has(data.id):
			continue
		# Ein Item, dessen Stapelgrenze bereits erreicht ist, waere auf dem
		# Sockel nicht aufnehmbar — der Spieler stuende vor einem [F], das
		# nichts tut.
		if data.max_stacks > 0 and items.count_item(data.id) >= data.max_stacks:
			continue
		pool.append(data)

	# Alles vergeben: lieber ein Duplikat als ein leerer Schatzraum.
	if pool.is_empty():
		_debug("Item-Pool erschoepft — Duplikate werden wieder zugelassen.")
		_reserved_ids.clear()
		for entry in catalog:
			if entry is ItemData:
				pool.append(entry as ItemData)

	if pool.is_empty():
		return null

	var rng: RandomNumberGenerator = _make_rng(room)
	return pool[rng.randi_range(0, pool.size() - 1)]


func _make_rng(room: RoomInstance) -> RandomNumberGenerator:
	var salt: String = "treasure:%d:%d:%d" % [
		room.grid_position.x,
		room.grid_position.y,
		_get_current_stage()
	]
	return DetRng.make(DetRng.derive(_get_run_seed(), salt))


func _get_run_seed() -> int:
	var generator: Node = _find_generator()
	if generator and generator.has_method("get_run_seed"):
		return generator.get_run_seed()
	return 0


func _get_current_stage() -> int:
	var generator: Node = _find_generator()
	if generator and generator.has_method("get_current_stage"):
		return generator.get_current_stage()
	return 1


func _find_generator() -> Node:
	var found: Array = get_tree().get_nodes_in_group("level_generator")
	if not found.is_empty():
		return found[0]
	return null


# ============================================================================
# Run-Verwaltung
# ============================================================================
func _on_item_taken(item: ItemData, _pedestal: TreasurePedestal) -> void:
	treasure_item_taken.emit(item)
	_debug("'%s' vom Sockel genommen." % item.display_name)


## Erkennt einen neuen Lauf am geaenderten Run-Seed. Ohne das haelt der
## Manager nach reload_current_scene() alle Raeume fuer bereits abgehandelt
## und der Schatzraum bliebe leer — ein Fehler ohne Fehlermeldung.
func _maybe_reset_for_new_run() -> void:
	var current_seed: int = _get_run_seed()
	if current_seed == _last_seen_seed:
		return
	if _last_seen_seed != -1:
		_debug("Neuer Run erkannt (Seed %d -> %d). Item-Pool zurueckgesetzt." % [
			_last_seen_seed, current_seed
		])
		_reserved_ids.clear()
	_last_seen_seed = current_seed


## Beim Start eines neuen Runs aufrufen — parallel zu Loot.reset_run() und
## Items.reset_run().
func reset_run() -> void:
	_reserved_ids.clear()
	_handled_rooms.clear()
	_last_seen_seed = -1
	_rooms_seen = 0


## Welche Items in diesem Lauf bereits auf einem Sockel lagen.
func get_reserved_ids() -> Array:
	return _reserved_ids.keys()


# ============================================================================
# Test-Hilfen
# ============================================================================
## Setzt sofort einen Sockel vor den Spieler. Gedacht fuer einen temporaeren
## Tastendruck, um Sockel-Optik und Aufnehmen zu testen, ohne erst einen
## Schatzraum freihacken zu muessen.
func debug_spawn_at_player(item_id: String = "") -> void:
	var player: Node3D = null
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			player = node as Node3D
			break
	if player == null:
		push_warning("[Treasure] Kein Spieler gefunden.")
		return

	var items: Node = get_node_or_null("/root/Items")
	if items == null:
		push_warning("[Treasure] Autoload 'Items' fehlt.")
		return

	var data: ItemData = null
	if item_id != "":
		data = items.get_item_by_id(item_id)
	elif not items.catalog.is_empty():
		data = items.catalog[0]
	if data == null:
		push_warning("[Treasure] Item '%s' nicht im Katalog." % item_id)
		return

	var pedestal := TreasurePedestal.create(data)
	get_tree().current_scene.add_child(pedestal)
	pedestal.global_position = player.global_position + Vector3(0.0, 0.0, 3.0)
	pedestal.item_taken.connect(_on_item_taken)
	_debug("Test-Sockel '%s' vor dem Spieler gesetzt." % data.display_name)


## Kurzbericht fuer die Konsole.
func debug_report() -> void:
	print("[Treasure] Raeume gesehen: %d | reservierte Items: %s | Seed: %d" % [
		_rooms_seen, str(_reserved_ids.keys()), _last_seen_seed
	])
