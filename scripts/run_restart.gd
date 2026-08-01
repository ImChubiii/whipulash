
extends Node

# ============================================================================
# RunRestart — Autoload: DER EINE Neustart-Pfad.
# Muss unter Project Settings -> Autoload als "RunRestart" stehen.
# ============================================================================
#
# WARUM DAS UEBERHAUPT EIN EIGENES AUTOLOAD IST
# ---------------------------------------------
# Ein Neustart wurde bisher an VIER Stellen unabhaengig voneinander
# ausgeloest:
#
#   reset_overlay.gd  [R] gehalten   -> Juice.cancel + Items/Loot reset + reload
#   pause_menu.gd     Restart-Button -> nur unpause + reload
#   death_screen.gd   Restart-Button -> nur unpause + reload
#   win_screen.gd     Restart-Button -> nur unpause + reload
#
# Drei dieser vier Wege haben also WENIGER aufgeraeumt als der vierte. Das
# ist die klassische Bauform fuer "der Restart-Button verhaelt sich anders
# als [R]" — und genau dieser Unterschied ist bei einem Bug im
# Neustart-Pfad das, was die Fehlersuche am laengsten aufhaelt.
#
# Ab jetzt rufen alle vier dieselbe Funktion auf. Wer einen Schritt
# ergaenzt, ergaenzt ihn zwangslaeufig fuer alle.
#
# ============================================================================
# WAS BEIM NEUSTART SCHIEFGING (Root Cause)
# ============================================================================
# reload_current_scene() baut die Szene ab und neu auf. Autoloads bleiben
# stehen — inklusive PartyManager, der einen Zeiger auf die Spieler-Instanz
# der ALTEN Szene haelt. Ein freigegebenes Object wird in GDScript nicht
# automatisch auf null gesetzt, "player == null" ist danach also FALSE
# obwohl die Instanz tot ist. PartyManager hielt sich damit fuer bereits
# bespielt und spawnte nie wieder einen Charakter: Level neu, Spieler weg.
#
# Der eigentliche Fix sitzt in party_manager.gd (has_player() /
# is_instance_valid). Hier wird zusaetzlich VOR dem Wechsel aufgeraeumt,
# damit die tote Instanz gar nicht erst einen Frame lang mitlaeuft.
#
# ============================================================================
# WARUM reload_current_scene() DEFERRED LAEUFT
# ============================================================================
# Ausgeloest wird der Neustart aus einem Button-Signal oder aus _process().
# Beides laeuft mitten im Frame, waehrend Nodes der noch lebenden Szene
# verarbeitet werden. Ein Szenenabbau in dem Moment ist genau die Situation,
# aus der "Cannot call method on a null value"-Kaskaden entstehen. Mit
# call_deferred() passiert der Wechsel am Frame-Ende, wenn niemand mehr in
# der alten Szene arbeitet.

signal restart_started

## Wird auf true gesetzt, sobald ein Neustart angefordert wurde, und beim
## Aufbau der neuen Szene wieder auf false. Verhindert, dass zwei Quellen
## im selben Frame zwei Szenenwechsel ausloesen (der zweite trifft dann auf
## eine bereits halb abgebaute Szene).
var _restart_pending: bool = false

@export var debug_logging: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _debug(msg: String) -> void:
	if debug_logging:
		print("[RunRestart] %s" % msg)


func is_restart_pending() -> bool:
	return _restart_pending


## Einziger oeffentlicher Einstieg. Von Reset-Overlay, Pause-, Death- und
## Win-Screen aufzurufen.
func restart() -> void:
	if _restart_pending:
		_debug("Neustart laeuft bereits — zweiter Aufruf ignoriert.")
		return
	_restart_pending = true
	restart_started.emit()

	_cleanup_run_state()
	_restore_engine_state()

	_debug("Szene wird neu geladen.")
	_do_reload.call_deferred()


func _do_reload() -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		_restart_pending = false
		return

	var result: int = tree.reload_current_scene()
	if result != OK:
		push_error("[RunRestart] reload_current_scene() ist fehlgeschlagen (Fehlercode %d)." % result)
		_restart_pending = false
		return

	# Eine Frame Luft, damit die neue Szene ihre _ready()-Kaskade fertig
	# hat, bevor ein weiterer Neustart zugelassen wird.
	await tree.process_frame
	await tree.process_frame
	_restart_pending = false
	_debug("Neue Szene steht.")


## Alles, was aus dem alten Lauf stammt und den Wechsel ueberleben wuerde.
## Jeder Aufruf ist einzeln abgesichert: fehlt ein Autoload (Testszene,
## abgespeckter Build), soll der Neustart trotzdem stattfinden.
func _cleanup_run_state() -> void:
	# WICHTIGSTER SCHRITT: siehe Root-Cause-Block oben.
	if PartyManager != null and PartyManager.has_method("notify_scene_reset"):
		PartyManager.notify_scene_reset()

	var items: Node = get_node_or_null("/root/Items")
	if items and items.has_method("reset_run"):
		items.reset_run()

	var loot: Node = get_node_or_null("/root/Loot")
	if loot and loot.has_method("reset_run"):
		loot.reset_run()

	var treasure: Node = get_node_or_null("/root/Treasure")
	if treasure and treasure.has_method("reset_run"):
		treasure.reset_run()

	var status: Node = get_node_or_null("/root/StatusEffectManager")
	if status and status.has_method("clear_all"):
		status.clear_all()


## Ein laufender Hit-Stop haelt Engine.time_scale bei ~0.05. Wird die Szene
## in genau diesem Moment gewechselt, startet der neue Run in Zeitlupe und
## der Timer, der time_scale zuruecksetzt, ist mit der alten Szene
## verschwunden. Beides wird hier hart zurueckgesetzt.
func _restore_engine_state() -> void:
	var juice: Node = get_node_or_null("/root/Juice")
	if juice and juice.has_method("cancel"):
		juice.cancel()
	Engine.time_scale = 1.0

	var tree: SceneTree = get_tree()
	if tree != null:
		tree.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
