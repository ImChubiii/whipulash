extends Node

## Debug-Teleporter System
## Spawnt automatisch zwei Interaktions-Pads im Startraum
## für direkten Transfer zum Tresor- oder Bossraum.
@export var pad_offset_left: Vector3 = Vector3(-5.0, -2.2, 0.0)
@export var pad_offset_right: Vector3 = Vector3(5.0, -2.2, 0.0)
## Drittes Pad, Admin-only: teleportiert in den Item-Testraum (siehe
## scripts/item_test_room.gd) - dort liegt JEDES Item aus dem Katalog
## nacheinander auf einem eigenen Sockel, plus eine Loesch-Plattform fuers
## Inventar. Bewusst auf der +Z-Achse statt links/rechts, damit es sich
## nicht mit den Tresor-/Boss-Pads ueberlappt.
@export var pad_offset_item_test: Vector3 = Vector3(0.0, -2.2, 6.0)
## Viertes Pad, Admin-only: teleportiert in den Gegner-Sandbox-Raum (siehe
## scripts/enemy_sandbox_room.gd) - dort lassen sich Fighter/Stinger/Colossus
## frei und beliebig oft spawnen, ohne einen echten Run zu starten. Auf der
## -Z-Achse, damit es sich nicht mit den anderen drei Pads ueberlappt.
@export var pad_offset_sandbox: Vector3 = Vector3(0.0, -2.2, -6.0)
@export var interact_action: StringName = &"interact"
@export var only_in_debug_build: bool = false # Auf false, damit es garantiert im Editor & Build erscheint

var _boss_pad: Area3D
var _treasure_pad: Area3D
var _item_test_pad: Area3D
var _sandbox_pad: Area3D
var _boss_label: Label3D
var _treasure_label: Label3D
var _item_test_label: Label3D
var _sandbox_label: Label3D

var _player_in_boss: bool = false
var _player_in_treasure: bool = false
var _player_in_item_test: bool = false
var _player_in_sandbox: bool = false
var _boss_grid: Vector2i = Vector2i(-999, -999)
var _treasure_grid: Vector2i = Vector2i(-999, -999)

func _ready() -> void:
	if only_in_debug_build and not OS.is_debug_build():
		queue_free()
		return

	# BUGFIX "Teleporter weg nach Neustart (2. Run)":
	# "Teleporter" ist ein AUTOLOAD (siehe project.godot) - _ready() hier
	# laeuft deshalb GENAU EINMAL fuer die gesamte Spielsitzung. Ein Neustart
	# (ResetOverlay -> RunRestart.restart() -> reload_current_scene()) ersetzt
	# aber die komplette Szene INKLUSIVE der alten LevelGenerator-Instanz
	# durch eine neue. Die bisherige einmalige Verbindung zu
	# level_gen.stage_generated haengt danach an einem laengst freigegebenen
	# Objekt, feuert nie wieder, und die Pads (die ausserdem unter dem
	# ebenfalls freigegebenen alten Startraum haengen) werden nie neu gebaut.
	#
	# Fix nach demselben Muster wie loot_manager.gd (dort dasselbe Problem mit
	# RoomInstance statt LevelGenerator, siehe Kopfkommentar dort): ueber
	# SceneTree.node_added auf JEDEN neu hinzugefuegten LevelGenerator
	# reagieren, nicht nur auf den allerersten.
	get_tree().node_added.connect(_on_node_added)

	# Verbinde mit dem LevelGenerator, sobald dieser geladen ist
	call_deferred("_connect_to_generator")


func _on_node_added(node: Node) -> void:
	if node is LevelGenerator:
		# Deferred: der Node haengt in diesem Frame evtl. noch nicht
		# vollstaendig im Baum (Gruppenzugehoerigkeit, Kinder), und
		# _connect_to_generator() sucht ueber die Gruppe.
		_connect_to_generator.call_deferred()

func _connect_to_generator() -> void:
	var level_gen := get_tree().get_first_node_in_group("level_generator") as LevelGenerator
	if level_gen:
		if not level_gen.stage_generated.is_connected(_on_stage_generated):
			level_gen.stage_generated.connect(_on_stage_generated)
		# Falls das Level beim Laden schon generiert wurde:
		if level_gen._instances.size() > 0:
			_setup_pads()

func _on_stage_generated(_stage: int, _room_count: int) -> void:
	call_deferred("_setup_pads")

func _setup_pads() -> void:
	_cleanup()
	
	var level_gen := get_tree().get_first_node_in_group("level_generator") as LevelGenerator
	if not level_gen:
		return
		
	var layout := level_gen._current_layout
	_boss_grid = Vector2i(-999, -999)
	_treasure_grid = Vector2i(-999, -999)
	
	var start_room: RoomInstance = null
	
	for grid_pos in layout.keys():
		var cell: RoomGridGenerator.RoomCell = layout[grid_pos]
		if cell.room_type == RoomData.RoomType.BOSS:
			_boss_grid = grid_pos
		elif cell.room_type == RoomData.RoomType.TREASURE:
			_treasure_grid = grid_pos
		elif cell.room_type == RoomData.RoomType.START:
			start_room = level_gen._instances.get(grid_pos)

	if not start_room or not is_instance_valid(start_room):
		return

	# Verwende TutorialHologram als Anker, sonst Fallback auf Raum-Mitte
	var holo := start_room.find_child("TutorialHologram", true, false) as Node3D
	var base_pos := holo.global_position if holo else start_room.global_position

	_treasure_pad = _create_pad("TreasureTeleportPad", Color(1, 0.8, 0.2, 0.6), base_pos + pad_offset_left)
	_treasure_label = _create_label(_treasure_pad, "[ TRESOR ]" if _treasure_grid != Vector2i(-999, -999) else "[ kein Tresor ]")
	_treasure_pad.body_entered.connect(func(b): if _is_player(b): _player_in_treasure = true; _update_labels())
	_treasure_pad.body_exited.connect(func(b): if _is_player(b): _player_in_treasure = false; _update_labels())
	start_room.add_child(_treasure_pad)

	_boss_pad = _create_pad("BossTeleportPad", Color(0.9, 0.2, 0.2, 0.6), base_pos + pad_offset_right)
	_boss_label = _create_label(_boss_pad, "[ BOSS ]" if _boss_grid != Vector2i(-999, -999) else "[ kein Boss ]")
	_boss_pad.body_entered.connect(func(b): if _is_player(b): _player_in_boss = true; _update_labels())
	_boss_pad.body_exited.connect(func(b): if _is_player(b): _player_in_boss = false; _update_labels())
	start_room.add_child(_boss_pad)

	_item_test_pad = _create_pad("ItemTestTeleportPad", Color(0.55, 0.25, 0.95, 0.6), base_pos + pad_offset_item_test)
	_item_test_label = _create_label(_item_test_pad, "[ ITEM-TESTRAUM ]")
	_item_test_pad.body_entered.connect(func(b): if _is_player(b): _player_in_item_test = true; _update_labels())
	_item_test_pad.body_exited.connect(func(b): if _is_player(b): _player_in_item_test = false; _update_labels())
	start_room.add_child(_item_test_pad)

	_sandbox_pad = _create_pad("SandboxTeleportPad", Color(0.9, 0.45, 0.05, 0.6), base_pos + pad_offset_sandbox)
	_sandbox_label = _create_label(_sandbox_pad, "[ GEGNER-SANDBOX ]")
	_sandbox_pad.body_entered.connect(func(b): if _is_player(b): _player_in_sandbox = true; _update_labels())
	_sandbox_pad.body_exited.connect(func(b): if _is_player(b): _player_in_sandbox = false; _update_labels())
	start_room.add_child(_sandbox_pad)

	print("[Teleporter] Pads erfolgreich im Startraum platziert!")

func _unhandled_input(event: InputEvent) -> void:
	# Typ explizit als bool deklarieren (: bool = ...), statt Godot raten zu lassen
	var is_interact: bool = event.is_action_pressed(interact_action) or (event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).physical_keycode == KEY_F)
	
	if not is_interact:
		return
		
	if _player_in_treasure and _treasure_grid != Vector2i(-999, -999):
		_teleport_player_to_grid(_treasure_grid)
	elif _player_in_boss and _boss_grid != Vector2i(-999, -999):
		_teleport_player_to_grid(_boss_grid)
	elif _player_in_item_test:
		ItemTestRoom.teleport_player_in()
	elif _player_in_sandbox:
		EnemySandboxRoom.teleport_player_in()

func _teleport_player_to_grid(target_grid: Vector2i) -> void:
	var level_gen := get_tree().get_first_node_in_group("level_generator") as LevelGenerator
	if not level_gen or not level_gen._instances.has(target_grid):
		return
		
	var player := get_tree().get_first_node_in_group(PartyManager.PLAYER_GROUP) as CharacterBody3D
	if not player:
		return
		
	var target_room: RoomInstance = level_gen._instances[target_grid]
	# Teleportiere den Spieler etwas abseits der Raummitte auf den Boden
	var dest_pos := target_room.global_position + Vector3(0, 4.0, 6.0)
	
	player.global_position = dest_pos
	player.velocity = Vector3.ZERO
	if player.has_method("set_buoyancy"):
		player.set_buoyancy(false)
	print("[Teleporter] Spieler nach ", target_grid, " teleportiert!")

func _create_pad(p_name: String, color: Color, pos: Vector3) -> Area3D:
	var area := Area3D.new()
	area.name = p_name
	area.collision_layer = 0
	area.collision_mask = 1
	
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
	
	area.global_position = pos
	return area

func _create_label(parent: Node, text: String) -> Label3D:
	var lbl := Label3D.new()
	lbl.text = text
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.position = Vector3(0, 2.0, 0)
	lbl.font_size = 48
	lbl.outline_size = 12
	parent.add_child(lbl)
	return lbl

func _update_labels() -> void:
	if _treasure_label:
		if _player_in_treasure:
			_treasure_label.text = "[F / E] TRESOR TELEPORT" if _treasure_grid != Vector2i(-999, -999) else "[ Nicht im Layout ]"
		else:
			_treasure_label.text = "[ TRESOR ]" if _treasure_grid != Vector2i(-999, -999) else "[ kein Tresor ]"
			
	if _boss_label:
		if _player_in_boss:
			_boss_label.text = "[F / E] BOSS TELEPORT" if _boss_grid != Vector2i(-999, -999) else "[ Nicht im Layout ]"
		else:
			_boss_label.text = "[ BOSS ]" if _boss_grid != Vector2i(-999, -999) else "[ kein Boss ]"

	if _item_test_label:
		_item_test_label.text = "[F / E] ITEM-TESTRAUM" if _player_in_item_test else "[ ITEM-TESTRAUM ]"

	if _sandbox_label:
		_sandbox_label.text = "[F / E] GEGNER-SANDBOX" if _player_in_sandbox else "[ GEGNER-SANDBOX ]"

func _is_player(body: Node) -> bool:
	return body.is_in_group(PartyManager.PLAYER_GROUP)

func _cleanup() -> void:
	if is_instance_valid(_boss_pad): _boss_pad.queue_free()
	if is_instance_valid(_treasure_pad): _treasure_pad.queue_free()
	if is_instance_valid(_item_test_pad): _item_test_pad.queue_free()
	if is_instance_valid(_sandbox_pad): _sandbox_pad.queue_free()
