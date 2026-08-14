extends Node

# ============================================================================
# EnemySandboxRoom — Admin/Debug: ein Raum, in dem jeder Gegnertyp
# (Fighter/Stinger/Colossus) frei und beliebig oft ueber Bodenplatten
# gespawnt werden kann. Nur zum Gegner-Austesten gedacht, kein Teil des
# normalen Spiels - Zugang ausschliesslich ueber das vierte Teleport-Pad in
# debug_teleporter.gd.
#
# REGISTRIEREN: Project Settings -> Autoload
#   Pfad: res://scripts/enemy_sandbox_room.gd
#   Name: EnemySandboxRoom
#
# Baumuster (Lazy-Bau beim ersten Betreten, Stilllegung bei Abwesenheit,
# Rueckweg-Pad) identisch zu ItemTestRoom (siehe scripts/item_test_room.gd) -
# siehe dort fuer die ausfuehrliche Begruendung. Eigener ROOM_OFFSET, damit
# sich die beiden Debug-Raeume nicht ueberlappen.
#
# Gespawnte Gegner haengen (wie normale Level-Gegner in room_instance.gd)
# direkt unter der aktuellen Szene, nicht unter _root - dadurch laufen ihre
# eigenen _physics_process()-Ketten (Chasing etc.) nur, waehrend sie
# existieren. Beim Verlassen des Raums (teleport_player_out) und ueber die
# Loesch-Plattform werden alle noch lebenden Sandbox-Gegner entfernt, damit
# nichts dauerhaft im Hintergrund weiterlaeuft (siehe Framerate-Warnung im
# Kopfkommentar von item_test_room.gd).

const ROOM_OFFSET: Vector3 = Vector3(300.0, 800.0, 0.0)
const FLOOR_SIZE: Vector2 = Vector2(64.0, 60.0)
const FLOOR_THICKNESS: float = 1.0
const WALL_HEIGHT: float = 16.0
const RAYCAST_MASK: int = 1
const PAD_SPACING: float = 6.0

const SPAWN_PAD_COLOR: Color = Color(0.9, 0.45, 0.05, 0.6)
const CLEAR_PAD_COLOR: Color = Color(0.75, 0.05, 0.05, 0.7)
const RETURN_PAD_COLOR: Color = Color(0.2, 0.6, 0.9, 0.6)

const INTERACT_ACTION: String = "interact"

const DUMMY_SCENE: PackedScene = preload("res://scenes/enemies/dummy.tscn")
const SCOUT_DUMMY_SCENE: PackedScene = preload("res://scenes/scout_dummy.tscn")
const TANK_DUMMY_SCENE: PackedScene = preload("res://scenes/tank_dummy.tscn")

## Reihenfolge = Reihenfolge der Spawn-Pads im Raum (erste Reihe: normale
## Level-Gegner ueber ihre .tscn; zweite Reihe: die neuen, rein
## code-gebauten Typen aus scripts/enemies/ - siehe custom_enemy_base.gd).
## "spawn" statt "scene", weil die neuen Typen keine .tscn haben und per
## ClassName.new() statt scene.instantiate() entstehen.
var _enemy_factories: Array[Dictionary] = [
	{"label": "FIGHTER", "row": 0, "spawn": func() -> Node3D: return DUMMY_SCENE.instantiate()},
	{"label": "STINGER", "row": 0, "spawn": func() -> Node3D: return SCOUT_DUMMY_SCENE.instantiate()},
	{"label": "COLOSSUS", "row": 0, "spawn": func() -> Node3D: return TANK_DUMMY_SCENE.instantiate()},
	{"label": "MOERSER-BOT", "row": 1, "spawn": func() -> Node3D: return MortarBot.new()},
	{"label": "SAEURE-SPRINKLER", "row": 1, "spawn": func() -> Node3D: return AcidSprinkler.new()},
	{"label": "MAGNET-KERN", "row": 1, "spawn": func() -> Node3D: return MagnetCore.new()},
	{"label": "DIVEBOMBER", "row": 1, "spawn": func() -> Node3D: return DiveBomber.new()},
	{"label": "SCHILD-DROHNE", "row": 1, "spawn": func() -> Node3D: return ShieldDrone.new()},
	{"label": "PLASMASTRAHL-BOT", "row": 1, "spawn": func() -> Node3D: return PlasmaBeamBot.new()},
]

var _root: Node3D = null
var _built: bool = false
var _spawn_position: Vector3 = Vector3.ZERO

## Position, von der aus zuletzt in den Sandbox-Raum teleportiert wurde -
## fuer den Rueckweg per Return-Pad.
var _return_position: Vector3 = Vector3.ZERO

var _spawned_enemies: Array[Node3D] = []

## Array[Dictionary{inside, label, idle, active, callback}] - siehe
## _build_interact_pad()/_unhandled_input() in item_test_room.gd (gleiches
## Prinzip).
var _pads: Array = []

## Fuer main_menu.gd::debug_boot_into_sandbox - siehe request_auto_teleport()
## weiter unten.
var _auto_teleport_pending: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


# ============================================================================
# Debug-Direktstart (main_menu.gd::debug_boot_into_sandbox)
# ============================================================================
## Von main_menu.gd aufgerufen, BEVOR es per change_scene_to_file() ins
## Gameplay-Level wechselt (main_menu.gd's eigener Szenenbaum - inkl. dieser
## Funktion aufrufend - wird dabei abgebaut, EnemySandboxRoom ueberlebt als
## Autoload). Sobald danach ein Level fertig generiert UND der Spieler
## gespawnt ist, wird automatisch teleport_player_in() aufgerufen - genau
## einmal. Die Flagge wird danach geloescht, damit ein spaeterer normaler
## Neustart (Restart-Button/erneutes "Nochmal spielen") nicht ungewollt
## wieder in die Sandbox springt.
##
## Gleiches "warte auf den naechsten LevelGenerator per SceneTree.node_added"-
## Muster wie debug_teleporter.gd::_connect_to_generator() - Autoloads werden
## in unbestimmter Reihenfolge initialisiert, der LevelGenerator existiert
## beim Aufruf hier also noch nicht zwingend.
func request_auto_teleport() -> void:
	_auto_teleport_pending = true
	if not get_tree().node_added.is_connected(_on_node_added_for_auto_teleport):
		get_tree().node_added.connect(_on_node_added_for_auto_teleport)
	call_deferred("_try_connect_to_generator_for_auto_teleport")


func _on_node_added_for_auto_teleport(node: Node) -> void:
	if node is LevelGenerator:
		_try_connect_to_generator_for_auto_teleport.call_deferred()


func _try_connect_to_generator_for_auto_teleport() -> void:
	var level_gen := get_tree().get_first_node_in_group("level_generator") as LevelGenerator
	if level_gen == null:
		return
	if not level_gen.stage_generated.is_connected(_on_stage_generated_for_auto_teleport):
		level_gen.stage_generated.connect(_on_stage_generated_for_auto_teleport)


func _on_stage_generated_for_auto_teleport(_stage: int, _room_count: int) -> void:
	if not _auto_teleport_pending:
		return
	_await_player_then_auto_teleport()


## Der Spieler-Spawn laeuft ueber PlayerSpawnPoint deferred und wartet dort
## selbst bis zu 10 Frames auf die Party (siehe dortiger Kopfkommentar) -
## direkt bei stage_generated existiert er deshalb noch nicht zuverlaessig.
## Gleiches Poll-Prinzip wie dort, nur hier auf den Spieler statt die Party.
func _await_player_then_auto_teleport() -> void:
	var guard: int = 0
	while _get_player() == null and guard < 60:
		await get_tree().process_frame
		guard += 1

	if not _auto_teleport_pending:
		return  # inzwischen ungueltig geworden, z.B. durch einen Neustart

	_auto_teleport_pending = false
	if get_tree().node_added.is_connected(_on_node_added_for_auto_teleport):
		get_tree().node_added.disconnect(_on_node_added_for_auto_teleport)

	if _get_player() == null:
		push_warning("EnemySandboxRoom: Auto-Teleport abgebrochen - nach %d Frames immer noch kein Spieler gefunden." % guard)
		return

	teleport_player_in()


## Baut den Raum (falls noch nicht geschehen) und teleportiert den Spieler
## hinein. Merkt sich die aktuelle Position, damit teleport_player_out() den
## Rueckweg kennt.
func teleport_player_in() -> void:
	var player: CharacterBody3D = _get_player()
	if player == null:
		return

	_return_position = player.global_position

	_ensure_built()
	_root.process_mode = Node.PROCESS_MODE_INHERIT

	_place_player(player, _spawn_position)


func teleport_player_out() -> void:
	var player: CharacterBody3D = _get_player()
	if player == null:
		return

	_place_player(player, _return_position)
	_clear_enemies()

	if _root != null and is_instance_valid(_root):
		_root.process_mode = Node.PROCESS_MODE_DISABLED


func _place_player(player: CharacterBody3D, pos: Vector3) -> void:
	player.global_position = pos
	player.velocity = Vector3.ZERO
	if player.has_method("set_buoyancy"):
		player.set_buoyancy(false)


func _get_player() -> CharacterBody3D:
	return get_tree().get_first_node_in_group(PartyManager.PLAYER_GROUP) as CharacterBody3D


# ============================================================================
# Aufbau
# ============================================================================
func _ensure_built() -> void:
	if _built:
		return
	_built = true

	_root = Node3D.new()
	_root.name = "EnemySandboxRoom"
	get_tree().current_scene.add_child(_root)
	_root.global_position = ROOM_OFFSET
	# Bis zum ersten Betreten stillgelegt - siehe Kopfkommentar.
	_root.process_mode = Node.PROCESS_MODE_DISABLED

	_build_floor(FLOOR_SIZE)
	_build_walls(FLOOR_SIZE)
	_build_light()

	_spawn_position = _root.global_position + Vector3(0.0, 1.0, FLOOR_SIZE.y * 0.30)

	var rows: Array[Array] = [[], []]
	for entry: Dictionary in _enemy_factories:
		rows[int(entry["row"])].append(entry)

	for row_index: int in range(rows.size()):
		var row_entries: Array = rows[row_index]
		var count: int = row_entries.size()
		var start_x: float = -((count - 1) * PAD_SPACING) * 0.5
		# Reihe 0 (normale Level-Gegner) am naechsten zum Spawn, Reihe 1 (die
		# neuen Typen) eine Reihe weiter hinten - genug Abstand, damit ein
		# Divebomber/Plasmastrahl-Bot beim Kreisen nicht sofort ueber der
		# vorderen Reihe haengt.
		var row_z: float = -8.0 - float(row_index) * 10.0
		for i: int in range(count):
			var entry: Dictionary = row_entries[i]
			var pad_pos: Vector3 = _spawn_position + Vector3(start_x + i * PAD_SPACING, -1.0, row_z)
			_build_interact_pad(
				pad_pos, SPAWN_PAD_COLOR,
				"[ %s SPAWNEN ]" % entry["label"], "[F] %s SPAWNEN" % entry["label"],
				_spawn_enemy.bind(entry["spawn"])
			)

	_build_interact_pad(
		_spawn_position + Vector3(-3.0, -1.0, 4.0), CLEAR_PAD_COLOR,
		"[ GEGNER LOESCHEN ]", "[F] ALLE GEGNER LOESCHEN",
		_clear_enemies
	)

	_build_interact_pad(
		_spawn_position + Vector3(3.0, -1.0, 4.0), RETURN_PAD_COLOR,
		"[ ZURUECK ]", "[F] ZURUECK ZUM RUN",
		teleport_player_out
	)


func _spawn_enemy(factory: Callable) -> void:
	var enemy: Node3D = factory.call()
	if enemy == null:
		return

	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(enemy)

	var jitter := Vector3(randf_range(-4.0, 4.0), 0.1, randf_range(-3.0, 3.0))
	enemy.global_transform = Transform3D(Basis.IDENTITY, _spawn_position + jitter)

	_spawned_enemies.append(enemy)
	enemy.tree_exited.connect(_on_enemy_gone.bind(enemy), CONNECT_ONE_SHOT)


func _on_enemy_gone(enemy: Node3D) -> void:
	_spawned_enemies.erase(enemy)


func _clear_enemies() -> void:
	for enemy: Node3D in _spawned_enemies:
		if not is_instance_valid(enemy):
			continue
		# Zwangsentfernung, NICHT ueber Health.died - die eigenen
		# Effekt-Nodes (Beams etc. der neuen custom_enemy_base.gd-Typen)
		# haengen ausserhalb der Instanz und muessten sonst ihr eigenes
		# Timeout abwarten. Siehe custom_enemy_base.gd::_cleanup_effects().
		if enemy.has_method("_cleanup_effects"):
			enemy.call("_cleanup_effects")
		enemy.queue_free()
	_spawned_enemies.clear()


func _build_floor(size: Vector2) -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "Floor"
	var box := BoxMesh.new()
	box.size = Vector3(size.x, FLOOR_THICKNESS, size.y)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.16, 0.20)
	mesh.material_override = mat
	_root.add_child(mesh)
	mesh.position = Vector3(0.0, -FLOOR_THICKNESS * 0.5, 0.0)

	var body := StaticBody3D.new()
	body.name = "FloorCollision"
	body.collision_layer = RAYCAST_MASK
	_root.add_child(body)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box.size
	col.shape = shape
	body.add_child(col)
	body.position = mesh.position


func _build_walls(size: Vector2) -> void:
	_build_one_wall(Vector3(size.x, WALL_HEIGHT, 1.0), Vector3(0.0, WALL_HEIGHT * 0.5, -size.y * 0.5))
	_build_one_wall(Vector3(size.x, WALL_HEIGHT, 1.0), Vector3(0.0, WALL_HEIGHT * 0.5, size.y * 0.5))
	_build_one_wall(Vector3(1.0, WALL_HEIGHT, size.y), Vector3(-size.x * 0.5, WALL_HEIGHT * 0.5, 0.0))
	_build_one_wall(Vector3(1.0, WALL_HEIGHT, size.y), Vector3(size.x * 0.5, WALL_HEIGHT * 0.5, 0.0))


func _build_one_wall(size: Vector3, pos: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.10, 0.10, 0.13)
	mesh.material_override = mat
	_root.add_child(mesh)
	mesh.position = pos

	var body := StaticBody3D.new()
	body.collision_layer = RAYCAST_MASK
	_root.add_child(body)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	body.position = pos


func _build_light() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60.0, -30.0, 0.0)
	light.light_energy = 1.0
	light.shadow_enabled = false
	_root.add_child(light)


## Generischer interaktiver Trigger (Bodenplatte), gleiches Prinzip wie die
## Teleport-Pads in debug_teleporter.gd und die Pads in item_test_room.gd.
func _build_interact_pad(pos: Vector3, color: Color, label_idle: String, label_active: String, callback: Callable) -> void:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = RAYCAST_MASK

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3.0, 2.0, 3.0)
	col.shape = box
	area.add_child(col)

	var csg := CSGBox3D.new()
	csg.size = Vector3(2.8, 0.2, 2.8)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.0
	csg.material = mat
	area.add_child(csg)

	var label := Label3D.new()
	label.text = label_idle
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0.0, 2.0, 0.0)
	label.font_size = 48
	label.outline_size = 12
	area.add_child(label)

	_root.add_child(area)
	area.global_position = pos

	var entry: Dictionary = {
		"inside": false, "label": label,
		"idle": label_idle, "active": label_active,
		"callback": callback,
	}
	_pads.append(entry)

	area.body_entered.connect(func(b: Node) -> void:
		if b.is_in_group(PartyManager.PLAYER_GROUP):
			entry["inside"] = true
			label.text = label_active
	)
	area.body_exited.connect(func(b: Node) -> void:
		if b.is_in_group(PartyManager.PLAYER_GROUP):
			entry["inside"] = false
			label.text = label_idle
	)


func _unhandled_input(event: InputEvent) -> void:
	if _pads.is_empty():
		return

	var is_interact: bool = event.is_action_pressed(INTERACT_ACTION) \
		or (event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).physical_keycode == KEY_F)
	if not is_interact:
		return

	for entry: Dictionary in _pads:
		if entry["inside"]:
			(entry["callback"] as Callable).call()
			return
