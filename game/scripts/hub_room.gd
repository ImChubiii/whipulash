extends Node

# ============================================================================
# HubRoom (Autoload "HubRoom") — Blueprint "Meta-Progression: Was passiert
# nach dem Tod?". Ein kleiner, immer verfuegbarer Lobby-Raum mit einem
# Drops-Shop, der die persistente Meta-Waehrung aus SaveGame (siehe
# scripts/save_game_manager.gd) gegen ein dauerhaftes Item-Drop-Gewicht-
# Upgrade eintauscht.
#
# Erreichbar ueber das fuenfte Teleport-Pad in debug_teleporter.gd - GENAU
# dasselbe Muster wie ItemTestRoom/EnemySandboxRoom (siehe dort fuer die
# ausfuehrliche Begruendung: fester Offset weit ausserhalb des generierten
# Layouts, lazy gebaut, ausserhalb der Besuchszeit process-stillgelegt).
#
# BEWUSST NICHT automatisch nach einem Tod aufgerufen: der bestehende Death-
# Screen-Flow (death_screen.gd/RunRestart) ist an einem frueheren Bug schon
# einmal zerbrochen (siehe run_restart.gd-Kopfkommentar) und wird hier nicht
# angefasst. Die Hub-Belohnung (Drops) wird trotzdem automatisch bei jedem
# Tod gutgeschrieben (SaveGame._on_party_wiped) - nur das Betreten des Hubs
# selbst ist manuell ueber das Teleport-Pad.

const ROOM_OFFSET: Vector3 = Vector3(600.0, 800.0, 0.0)
const FLOOR_SIZE: Vector2 = Vector2(24.0, 24.0)
const FLOOR_THICKNESS: float = 1.0
const WALL_HEIGHT: float = 8.0
const RAYCAST_MASK: int = 1
const INTERACT_ACTION: String = "interact"

const SHOP_COLOR: Color = Color(0.85, 0.65, 0.15, 0.7)
const RETURN_PAD_COLOR: Color = Color(0.2, 0.6, 0.9, 0.6)

var _root: Node3D = null
var _built: bool = false
var _spawn_position: Vector3 = Vector3.ZERO
var _return_position: Vector3 = Vector3.ZERO
var _shop_label: Label3D = null
var _drops_label: Label3D = null

## Array[Dictionary{inside, label, idle, active, callback}].
var _pads: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not SaveGame.drops_changed.is_connected(_on_drops_changed):
		SaveGame.drops_changed.connect(_on_drops_changed)
	if not SaveGame.item_weight_bonus_changed.is_connected(_on_bonus_changed):
		SaveGame.item_weight_bonus_changed.connect(_on_bonus_changed)


func teleport_player_in() -> void:
	var player: CharacterBody3D = _get_player()
	if player == null:
		return

	_return_position = player.global_position

	_ensure_built()
	_root.process_mode = Node.PROCESS_MODE_INHERIT
	_refresh_labels()

	_place_player(player, _spawn_position)


func teleport_player_out() -> void:
	var player: CharacterBody3D = _get_player()
	if player == null:
		return

	_place_player(player, _return_position)

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
	_root.name = "HubRoom"
	get_tree().current_scene.add_child(_root)
	_root.global_position = ROOM_OFFSET
	_root.process_mode = Node.PROCESS_MODE_DISABLED

	_build_floor()
	_build_walls()
	_build_light()

	_spawn_position = _root.global_position + Vector3(0.0, 1.0, FLOOR_SIZE.y * 0.5 - 4.0)

	_drops_label = Label3D.new()
	_drops_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_drops_label.font_size = 40
	_drops_label.outline_size = 10
	_drops_label.position = _spawn_position - _root.global_position + Vector3(0.0, 3.0, -2.0)
	_root.add_child(_drops_label)

	_shop_label = _build_interact_pad(
		_spawn_position + Vector3(-3.0, -1.0, -2.0), SHOP_COLOR,
		"[ DROPS-SHOP ]", "[F] UPGRADE KAUFEN",
		_on_shop_interact
	)

	_build_interact_pad(
		_spawn_position + Vector3(3.0, -1.0, 2.0), RETURN_PAD_COLOR,
		"[ ZURUECK ]", "[F] ZURUECK ZUM RUN",
		teleport_player_out
	)


func _on_shop_interact() -> void:
	SaveGame.buy_item_weight_upgrade()


func _on_drops_changed(_amount: int) -> void:
	_refresh_labels()


func _on_bonus_changed(_bonus: float) -> void:
	_refresh_labels()


func _refresh_labels() -> void:
	if _drops_label != null and is_instance_valid(_drops_label):
		_drops_label.text = "Drops: %d\nItem-Gewicht-Bonus: +%d%%" % [
			SaveGame.drops, int(round(SaveGame.get_item_weight_bonus() * 100.0))
		]

	if _shop_label == null or not is_instance_valid(_shop_label):
		return
	if SaveGame.is_upgrade_maxed():
		_shop_label.text = "[ SHOP: MAXIMUM ERREICHT ]"
	else:
		_shop_label.text = "[ DROPS-SHOP ] Kosten: %d" % SaveGame.get_upgrade_cost()


func _build_floor() -> void:
	var mesh := MeshInstance3D.new()
	mesh.name = "Floor"
	var box := BoxMesh.new()
	box.size = Vector3(FLOOR_SIZE.x, FLOOR_THICKNESS, FLOOR_SIZE.y)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.14, 0.13, 0.18)
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


func _build_walls() -> void:
	_build_one_wall(Vector3(FLOOR_SIZE.x, WALL_HEIGHT, 1.0), Vector3(0.0, WALL_HEIGHT * 0.5, -FLOOR_SIZE.y * 0.5))
	_build_one_wall(Vector3(FLOOR_SIZE.x, WALL_HEIGHT, 1.0), Vector3(0.0, WALL_HEIGHT * 0.5, FLOOR_SIZE.y * 0.5))
	_build_one_wall(Vector3(1.0, WALL_HEIGHT, FLOOR_SIZE.y), Vector3(-FLOOR_SIZE.x * 0.5, WALL_HEIGHT * 0.5, 0.0))
	_build_one_wall(Vector3(1.0, WALL_HEIGHT, FLOOR_SIZE.y), Vector3(FLOOR_SIZE.x * 0.5, WALL_HEIGHT * 0.5, 0.0))


func _build_one_wall(size: Vector3, pos: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.09, 0.09, 0.12)
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


## Generischer interaktiver Trigger (Bodenplatte) - identisches Muster zu
## item_test_room.gd::_build_interact_pad() und den Pads in
## debug_teleporter.gd. Gibt das Label zurueck, damit der Aufrufer den Text
## spaeter dynamisch aktualisieren kann (Drops-Anzeige/Kosten).
func _build_interact_pad(pos: Vector3, color: Color, label_idle: String, label_active: String, callback: Callable) -> Label3D:
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
			label.text = entry["active"]
	)
	area.body_exited.connect(func(b: Node) -> void:
		if b.is_in_group(PartyManager.PLAYER_GROUP):
			entry["inside"] = false
			label.text = entry["idle"]
	)

	return label


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
