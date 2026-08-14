extends RoomInstance
class_name RoomSwitchArena

# ============================================================================
# RoomSwitchArena — Blueprint Nr. 2 "Der Schalter-Puzzle-Kampf" (Switch
# Arena). Die Tuer geht NICHT automatisch auf, wenn alle Gegner tot sind.
# Erst wenn alle REQUIRED_SWITCHES Bodenschalter (SwitchPad-Kinder unter dem
# Geschwister-Node "Switches") aktiviert wurden, entriegelt der Raum -
# waehrend dessen respawnen in Abstaenden billige Gegner nach, damit
# Stillstand keine Option ist.
# ============================================================================
# Ueberschreibt bewusst NUR den Freigabe-Moment der Basisklasse
# (_register_enemy_gone) - Spawnen/Zaehlen/Watchdog bleiben unveraendert
# (siehe room_instance.gd). super._register_enemy_gone() laeuft normal
# durch; ist der Raum dadurch "cleared", aber die Schalter noch nicht fertig,
# wird sofort wieder zugesperrt statt der Basis-Entriegelung zu vertrauen.

const REQUIRED_SWITCHES: int = 3
const RESPAWN_INTERVAL: float = 4.0
## Kleines Fix-Kontingent pro Nachschub-Welle, UNABHAENGIG vom eigentlichen
## Raum-Budget - der Puzzle-Druck soll konstant bleiben, nicht eskalieren.
const RESPAWN_COUNT: int = 2

var _switches_activated: int = 0
var _switches_done: bool = false
var _respawn_timer: Timer


func _ready() -> void:
	super._ready()

	_respawn_timer = Timer.new()
	_respawn_timer.wait_time = RESPAWN_INTERVAL
	_respawn_timer.one_shot = false
	_respawn_timer.timeout.connect(_on_respawn_timeout)
	add_child(_respawn_timer)

	var switches: Node = get_node_or_null("Switches")
	if switches != null:
		for child in switches.get_children():
			if child.has_signal("activated"):
				child.activated.connect(_on_switch_activated)


func _register_enemy_gone(enemy_id: int, generation: int = -1) -> void:
	var was_cleared_before: bool = _is_cleared
	super._register_enemy_gone(enemy_id, generation)

	if _is_cleared and not was_cleared_before and not _switches_done:
		_lock_exits(true)
		if _respawn_timer.is_stopped():
			_respawn_timer.start()


func _on_switch_activated() -> void:
	if _switches_done:
		return
	_switches_activated += 1
	if _switches_activated < REQUIRED_SWITCHES:
		return

	_switches_done = true
	_respawn_timer.stop()
	_is_cleared = true
	_lock_exits(false)
	room_cleared.emit(self)


func _on_respawn_timeout() -> void:
	if _switches_done or _pending_entries.is_empty() or enemy_spawn_points.is_empty():
		return

	var cheapest: EnemySpawnEntry = _pending_entries[0]
	for e: EnemySpawnEntry in _pending_entries:
		if e.threat_cost < cheapest.threat_cost:
			cheapest = e

	var points: Array[Marker3D] = enemy_spawn_points.duplicate()
	DetRng.shuffle(points, _spawn_rng)
	for i in range(mini(RESPAWN_COUNT, points.size())):
		_spawn_one(cheapest, points[i])
