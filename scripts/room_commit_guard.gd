extends Node

# ============================================================================
# RoomGuard — Autoload: schliesst die Luecke, durch die man Raeume umgehen
# kann, ohne den Kampf auszuloesen.
# Muss unter Project Settings -> Autoload als "RoomGuard" stehen.
# ============================================================================
#
# DAS PROBLEM
# -----------
# room_instance.gd loest den Kampf ueber den EntryTrigger aus. Dessen Box
# wird von JEDER Seite um entry_trigger_depth eingerueckt:
#
#     size_x = room_footprint.x - entry_trigger_depth * 2.0
#            = 48 - 18 = 30
#
# In einem 48x48-Raum bleibt damit ringsum ein 9 m breiter Streifen, in dem
# nichts passiert. Die Tueren sitzen mittig in den Waenden — man kann also
# durch die Nordtuer hereinkommen, an der Wand entlang zur Osttuer laufen
# und den Raum verlassen, ohne den 30x30-Kern je zu beruehren. Die Gegner
# spawnen nie, die Tueren verriegeln nie.
#
# WARUM DER EINRUECKUNG TROTZDEM RECHT HAT
# ----------------------------------------
# Sie ist Absicht und heisst im Original-Kommentar "Anti-Baiting": man soll
# in einen Raum hineinschauen duerfen, ohne sofort einen Kampf zu starten.
# Diese Eigenschaft will man behalten. Den EntryTrigger einfach auf
# Raumgroesse aufzublasen wuerde sie zerstoeren — dann startet der Kampf
# schon, wenn man im Tuerrahmen steht und ueberlegt.
#
# DIE LOESUNG: ZWEITE, LANGSAMERE STUFE
# -------------------------------------
# Dieses Script haengt jedem Raum eine ZUSAETZLICHE Area ueber den vollen
# Grundriss und startet den Kampf erst, wenn der Spieler dort
# commit_dwell_time Sekunden am Stueck drin ist.
#
# Damit gilt:
#   * Kurz reinschauen und zurueck  -> nichts passiert (wie bisher).
#   * In die Raummitte laufen       -> sofort Kampf (EntryTrigger, wie bisher).
#   * An der Wand entlangschleichen -> nach gut einer Sekunde Kampf (NEU).
#
# Der Trick ist damit nicht "verboten", sondern nur nicht mehr schneller als
# der ehrliche Weg — und genau das ist bei einer Abkuerzung die richtige
# Antwort. Wer wirklich in unter einer Sekunde quer durch einen 48 m breiten
# Raum kommt, hat sich das Durchhuschen verdient.
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
@export var commit_dwell_time: float = 1.1

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

@export var debug_logging: bool = false

## room InstanceID -> { "room": RoomInstance, "area": Area3D, "timer": float }
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
	room.add_child(area)

	var size_x: float = maxf(room.room_footprint.x - edge_inset * 2.0, 1.0)
	var size_z: float = maxf(room.room_footprint.y - edge_inset * 2.0, 1.0)
	var size_y: float = maxf(room.room_height, 1.0)

	var box := BoxShape3D.new()
	box.size = Vector3(size_x, size_y, size_z)

	var shape := CollisionShape3D.new()
	shape.shape = box
	shape.position = Vector3(0.0, floor_offset + size_y * 0.5, 0.0)
	area.add_child(shape)

	_watched[id] = {"room": room, "area": area, "timer": 0.0}
	_debug("Raum %s ueberwacht (%.0f x %.0f)." % [room.grid_position, size_x, size_z])


# ============================================================================
# Auswertung
# ============================================================================
func _physics_process(delta: float) -> void:
	var stale: Array = []

	for id in _watched.keys():
		var entry: Dictionary = _watched[id]
		var room = entry["room"]
		var area = entry["area"]

		if not is_instance_valid(room) or not is_instance_valid(area):
			stale.append(id)
			continue

		if not _needs_commit(room):
			entry["timer"] = 0.0
			continue

		if not _player_inside(area):
			# Zuruecksetzen statt weiterlaufen zu lassen: gemessen wird
			# ununterbrochene Anwesenheit. Sonst wuerde sich mehrfaches
			# kurzes Reinschauen aufaddieren und irgendwann den Kampf
			# ausloesen, obwohl der Spieler nie im Raum war.
			entry["timer"] = 0.0
			continue

		entry["timer"] = float(entry["timer"]) + delta
		if float(entry["timer"]) < maxf(commit_dwell_time, 0.0):
			continue

		entry["timer"] = 0.0
		_commit(room)

	for id in stale:
		_watched.erase(id)


## Nur Raeume, die ueberhaupt noch einen Kampf vor sich haben. Geclearte
## Raeume, Korridore ohne Gegner und bereits ausgeloeste Raeume werden
## uebersprungen.
func _needs_commit(room: RoomInstance) -> bool:
	if room.is_cleared() or not room.requires_clear():
		return false
	# _enemies_spawned ist die verlaessliche Sperre: on_player_entered()
	# prueft sie selbst, aber ohne diesen Test wuerde der Timer nach dem
	# Spawn sinnlos weiterlaufen.
	return room.get("_enemies_spawned") != true


func _player_inside(area: Area3D) -> bool:
	for body in area.get_overlapping_bodies():
		if body is Node3D and body.is_in_group(PartyManager.PLAYER_GROUP):
			return true
	return false


## Startet den Kampf ueber denselben Einstiegspunkt, den auch der
## EntryTrigger benutzt. on_player_entered() sichert sich selbst gegen
## Doppelausloesung ab.
##
## _has_entered wird zusaetzlich gesetzt, weil room_instance.gd daran seinen
## Flucht-Check (_check_escape) haengt. Ohne das Flag wuerde ein Raum, den
## dieser Guard ausgeloest hat, nie zuruecksetzen, wenn der Spieler
## anschliessend doch verschwindet — und das waere ein zweiter, schlimmerer
## Exploit als der, den wir gerade schliessen.
func _commit(room: RoomInstance) -> void:
	room.set("_has_entered", true)
	room.on_player_entered()
	room_committed.emit(room)
	_debug("Raum %s ausgeloest (Aufenthalt statt Kern-Trigger)." % room.grid_position)


## Beim Start eines neuen Runs aufrufen.
func reset_run() -> void:
	_watched.clear()
