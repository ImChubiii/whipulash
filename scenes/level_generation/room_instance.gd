extends Node3D
class_name RoomInstance

## Bitmask-Konstanten, identisch zu RoomData.available_exits und
## RoomGridGenerator.DIRECTION_FLAG, damit Raum und Grid-Generator sich
## ohne harte Klassenabhängigkeit einig sind, welche Richtung was ist.
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

## Basis-Grundfläche/Höhe der 9 aktuellen Room-Templates (VOR Skalierung
## durch LevelGenerator.room_scale - der Entry-Trigger unten ist Kind von
## RoomRoot und wird dadurch automatisch mitskaliert). Falls künftig Räume
## mit abweichenden Maßen dazukommen, muss das hier pro Raum konfigurierbar
## werden (z.B. @export) statt hart codiert zu sein.
const ROOM_FOOTPRINT: Vector2 = Vector2(16.0, 16.0)
const ROOM_HEIGHT: float = 4.5

## Marker3D-Kinder unter "EnemySpawnPoints" markieren mögliche
## Gegner-Spawnpunkte. Nicht jeder Marker muss belegt werden -> variiert
## die Dichte pro Durchlauf.
var enemy_spawn_points: Array[Marker3D] = []

## Marker für Loot/Items (Chests, Pickups)
var loot_spawn_points: Array[Marker3D] = []

## Gerichtete Türen: "north"/"south"/"east"/"west" -> Marker3D.
## Nur Richtungen, die im aktuellen Grid-Layout tatsächlich gebraucht
## werden, bleiben nach apply_exit_flags() in diesem Dictionary.
var exit_points: Dictionary = {}

signal room_cleared
signal room_entered

var _is_cleared: bool = false
var _active_enemies: int = 0

## Ob dieser Raum überhaupt Gegner hat und sich daher beim Betreten
## versiegeln muss. Räume ohne EnemySpawnPoints (Start/Corridor/Treasure)
## bleiben immer offen.
var _requires_clear: bool = false

var _entry_trigger: Area3D = null
var _has_entered: bool = false
var _enemies_spawned: bool = false
var _pending_enemy_scenes: Array[PackedScene] = []
var _pending_min_count: int = 0
var _pending_max_count: int = 0
var _spawned_enemies: Array[Node3D] = []

func _ready() -> void:
	_collect_markers()
	_setup_entry_trigger()
	# WICHTIG: hier NICHT mehr _lock_exits(true) - Türen starten offen.
	# Ob und wann ein Raum sich sperrt, entscheidet prepare_enemies() bzw.
	# on_player_entered(). Würden wir hier schon sperren, könnte der
	# Player einen Combat-Raum nie betreten (Deadlock: Tür bleibt zu, bis
	# Gegner tot sind, die aber nur spawnen, wenn der Player den Raum
	# betritt).

func _exit_tree() -> void:
	# Gegner hängen (siehe _spawn_prepared_enemies) nicht mehr an diesem
	# Node, sondern an current_scene, damit sie NICHT die room_scale-
	# Skalierung von RoomRoot erben. Dadurch werden sie beim Aufräumen
	# alter Räume (LevelGenerator._clear_current_rooms -> queue_free) auch
	# nicht mehr automatisch mit entfernt - das holen wir hier nach.
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()

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
				# Tür wird über Namenskonvention gefunden statt fest in der
				# .tscn verdrahtet: "Doors/Door" + Marker-Name (z.B. "North"
				# -> "Doors/DoorNorth"). Spart fehleranfällige NodePath-
				# Zuweisungen im Editor pro Raum-Variante.
				var door := get_node_or_null("Doors/Door%s" % child.name.capitalize())
				if door:
					child.set_meta("door_node", door)

## Erzeugt eine Area3D, die die Bodenfläche des Raums abdeckt. Löst beim
## ersten Betreten durch den Player on_player_entered() aus. Programmatisch
## statt in den 9 .tscn-Dateien angelegt, damit alle Räume automatisch die
## gleiche Logik bekommen, ohne jede Szene einzeln pflegen zu müssen.
func _setup_entry_trigger() -> void:
	_entry_trigger = Area3D.new()
	_entry_trigger.name = "EntryTrigger"
	_entry_trigger.collision_layer = 0
	_entry_trigger.collision_mask = 0xFFFFFFFF
	_entry_trigger.monitoring = true
	_entry_trigger.monitorable = false
	add_child(_entry_trigger)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	# Etwas kleiner als die volle Grundfläche, damit der Trigger erst
	# feuert wenn man wirklich im Raum ist (nicht schon in der Türöffnung).
	box.size = Vector3(ROOM_FOOTPRINT.x - 1.0, ROOM_HEIGHT, ROOM_FOOTPRINT.y - 1.0)
	shape.shape = box
	shape.position = Vector3(0.0, ROOM_HEIGHT * 0.5, 0.0)
	_entry_trigger.add_child(shape)

	_entry_trigger.body_entered.connect(_on_entry_trigger_body_entered)

func _on_entry_trigger_body_entered(body: Node) -> void:
	if _has_entered:
		return
	if not body.is_in_group(PartyManager.PLAYER_GROUP):
		return
	_has_entered = true
	on_player_entered()

## Wird vom LevelGenerator direkt nach dem Instanziieren aufgerufen.
## Legt fest, WELCHE Gegner-Typen/Anzahl beim Betreten gespawnt werden
## sollen - spawnt aber noch NICHTS. Räume ohne EnemySpawnPoints (Start,
## Corridor, Treasure) haben nichts zu klären und bleiben dauerhaft offen.
func prepare_enemies(enemy_scenes: Array[PackedScene], min_count: int, max_count: int) -> void:
	if enemy_scenes.is_empty() or enemy_spawn_points.is_empty():
		_is_cleared = true
		_lock_exits(false)
		return
	_requires_clear = true
	_pending_enemy_scenes = enemy_scenes
	_pending_min_count = min_count
	_pending_max_count = max_count
	# Tür bleibt bewusst OFFEN, bis der Player den Raum tatsächlich betritt
	# (siehe on_player_entered) - sonst könnte der Player nie rein.
	_lock_exits(false)

func _spawn_prepared_enemies() -> void:
	if _pending_enemy_scenes.is_empty() or enemy_spawn_points.is_empty():
		_is_cleared = true
		_lock_exits(false)
		return

	var shuffled := enemy_spawn_points.duplicate()
	shuffled.shuffle()

	var count: int = clampi(randi_range(_pending_min_count, _pending_max_count), 0, shuffled.size())
	for i in range(count):
		var point: Marker3D = shuffled[i]
		var enemy_scene: PackedScene = _pending_enemy_scenes.pick_random()
		var enemy: Node3D = enemy_scene.instantiate()
		# WICHTIG: current_scene statt self (RoomRoot) als Parent, damit
		# der Gegner NICHT die room_scale-Skalierung von RoomRoot erbt
		# (sonst wäre er proportional genauso vergrößert wie der Raum).
		# global_position berücksichtigt die Skalierung des Markers durch
		# seinen (skalierten) Parent trotzdem korrekt.
		get_tree().current_scene.add_child(enemy)
		enemy.global_position = point.global_position
		enemy.global_rotation = point.global_rotation
		_spawned_enemies.append(enemy)
		_active_enemies += 1

		# WICHTIG: Self-Damage-Schutz laut Projektregel - owner zeigt auf
		# Szenen-Root, damit Hitboxen den eigenen Raum/Spawner nicht als
		# Quelle für Friendly-Fire missverstehen.

		# Gegner wie ScoutDummy/TankDummy (enemy_ai.gd) tragen "died" NICHT
		# auf ihrem Root, sondern auf ihrer Health-Kindkomponente. Root-
		# Signal hat Vorrang, falls doch vorhanden; sonst wird die
		# Health-Komponente per find_child gesucht.
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)
		else:
			var health_node := enemy.find_child("Health", true, false)
			if health_node and health_node.has_signal("died"):
				health_node.died.connect(_on_enemy_died)
			else:
				# Fallback: kein Health-Node gefunden -> zählt als "weg",
				# sobald der Gegner die Szene verlässt.
				enemy.tree_exited.connect(_on_enemy_died)

	if count == 0:
		_is_cleared = true
		_lock_exits(false)

## Wird vom LevelGenerator direkt nach dem Instanziieren aufgerufen.
## Entfernt alle Türen, die im aktuellen Grid-Layout NICHT gebraucht
## werden, aus exit_points. Diese Türen bleiben dadurch für immer
## verriegelt (sie werden nie wieder von _lock_exits erreicht) und
## wirken effektiv wie eine massive Wand - kosmetisch bleibt es eine
## geschlossene Tür-Mesh, funktional ist sie unpassierbar.
func apply_exit_flags(required_flags: int) -> void:
	for key in exit_points.keys().duplicate():
		var flag: int = _FLAG_BY_KEY.get(key, 0)
		if flag & required_flags == 0:
			exit_points.erase(key)

func _on_enemy_died() -> void:
	_active_enemies -= 1
	if _active_enemies <= 0 and not _is_cleared:
		_is_cleared = true
		_lock_exits(false)
		room_cleared.emit()

func _lock_exits(locked: bool) -> void:
	for marker in exit_points.values():
		if marker.has_meta("door_node"):
			var door: Node = marker.get_meta("door_node")
			if door.has_method("set_locked"):
				door.set_locked(locked)

func on_player_entered() -> void:
	room_entered.emit()
	if _is_cleared or _enemies_spawned or not _requires_clear:
		return
	_enemies_spawned = true
	# Jetzt erst - beim tatsächlichen Betreten - sperrt sich der Raum und
	# spawnt seine Gegner. Vorher war die Tür absichtlich offen.
	_lock_exits(true)
	_spawn_prepared_enemies()
