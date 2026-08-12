extends GutTest

# ============================================================================
# Basisklasse fuer Tests, die PartyManager und/oder Items (Autoload-
# Singletons) brauchen.
# ============================================================================
# PartyManager und Items sind ECHTE Godot-Autoloads: sie existieren bereits,
# bevor der erste Test laeuft, und ueberleben die gesamte Testsitzung (eine
# GUT-Session laeuft in EINEM Engine-Prozess, der alle Test-Skripte nach-
# einander ausfuehrt). Isolation zwischen Tests heisst hier deshalb NICHT
# "neu instanziieren" - project.godot-Autoloads lassen sich zur Laufzeit
# ohnehin nicht sauber neu erzeugen -, sondern: vor jedem Test in einen
# leeren, definierten Zustand zuruecksetzen und danach wieder aufraeumen.
# Ohne das wuerde z.B. eine in Test A gespawnte Spieler-Instanz oder ein in
# Test A eingesammeltes Item in Test B weiterleben.
#
# Jeder konkrete Test extended DIESE Datei statt direkt GutTest:
#   extends "res://test/base/party_manager_test_base.gd"

const WINTER_DATA: String = "res://resources/char_4.tres"
const KARINA_DATA: String = "res://resources/char_3.tres"
const NINGNING_DATA: String = "res://resources/char_1.tres"
const GISELLE_DATA: String = "res://resources/char_2.tres"

## Container-Node fuer die gespawnte Spieler-Instanz - steht fuer den
## PlayerSpawnPoint-Marker3D, den PartyManager im echten Spiel von einem
## RoomInstance-Level bekommt (siehe scripts/player_spawn_point.gd). Wird
## pro Test frisch angelegt und von GUT automatisch wieder entfernt.
var _spawn_parent: Node3D = null


func before_each() -> void:
	_reset_party_manager()
	_reset_items()
	_spawn_parent = Node3D.new()
	_spawn_parent.name = "TestSpawnParent"
	add_child_autofree(_spawn_parent)


func after_each() -> void:
	# Eine evtl. noch lebende Spieler-Instanz VOR dem naechsten
	# notify_scene_reset() explizit einsammeln - sonst haengt sie bis zum
	# Ende der gesamten Suite als Orphan im Baum statt sofort nach diesem
	# Test aufzuraeumen.
	if PartyManager.has_player():
		PartyManager.player.queue_free()

	_reset_party_manager()
	_reset_items()

	# Globaler Input-State (Input.action_press/-release) ueberlebt Tests
	# genauso wie die Autoloads. Jeder Test, der eine Taste "haelt", sollte
	# sie selbst wieder loslassen (siehe test_character_switch.gd) - das
	# hier ist zusaetzlich ein Netz, falls ein Test vorher an einer
	# fehlgeschlagenen Assertion abbricht, ohne selbst aufzuraeumen.
	for action: StringName in [
		&"attack_primary", &"attack_secondary", &"utility",
		&"ability_primary", &"ability_secondary",
	]:
		if InputMap.has_action(action):
			Input.action_release(action)

	# player_base.gd::_ready() faengt bei jedem Spawn die Maus ein
	# (MOUSE_MODE_CAPTURED) - fuer eine Testsitzung im Editor unangenehm
	# genug, um es hier zurueckzusetzen.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _reset_party_manager() -> void:
	PartyManager.notify_scene_reset()
	PartyManager.setup_party([])


func _reset_items() -> void:
	Items.reset_run()


## Registriert den Test-Spawn-Punkt und baut die Party auf - inhaltlich
## derselbe Ablauf wie PlayerSpawnPoint.register_spawn_point() +
## PartySetup._ready() im echten Level, nur ohne ein echtes Level drumherum.
## members[0] wird der aktive Charakter (siehe PartyManager.setup_party()).
##
## Wartet danach einen Frame: PartyManager._spawn_active_character() laeuft
## bewusst per call_deferred(), siehe party_manager.gd-Kommentar zu
## setup_party() - ohne den Wait waere PartyManager.player hier noch null.
func spawn_party(members: Array[CharacterData]) -> void:
	PartyManager.register_spawn_point(_spawn_parent, Transform3D.IDENTITY)
	PartyManager.setup_party(members)
	await wait_frames(1)


## Minimaler Gegner-Dummy: Gruppe "enemies" + ein Kind-Node namens "Health" -
## exakt die zwei Dinge, die EnemyQuery/Hitbox/Items wirklich brauchen, um
## einen Node als gueltigen Gegner zu behandeln (siehe CLAUDE.md-
## Architekturnotiz zu den zwei parallelen Gegner-Systemen). Keine echte
## Gegner-Szene noetig.
func spawn_dummy_enemy(at_position: Vector3, max_health: float = 999.0) -> Node3D:
	var enemy := Node3D.new()
	enemy.name = "DummyEnemy"
	add_child_autofree(enemy)
	enemy.add_to_group("enemies")
	enemy.global_position = at_position

	var health := Health.new()
	health.name = "Health"
	health.max_health = max_health
	enemy.add_child(health)

	return enemy
