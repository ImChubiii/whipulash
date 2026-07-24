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

func _ready() -> void:
	_collect_markers()
	_lock_exits(true)

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

## Wird vom LevelGenerator aufgerufen, um zufällig eine Teilmenge der
## verfügbaren Spawn-Punkte mit Gegnern zu befüllen (variiert Dichte).
func populate_enemies(enemy_scenes: Array[PackedScene], min_count: int, max_count: int) -> void:
	if enemy_scenes.is_empty() or enemy_spawn_points.is_empty():
		return

	var shuffled := enemy_spawn_points.duplicate()
	shuffled.shuffle()

	var count: int = clampi(randi_range(min_count, max_count), 0, shuffled.size())
	for i in range(count):
		var point: Marker3D = shuffled[i]
		var enemy_scene: PackedScene = enemy_scenes.pick_random()
		var enemy: Node3D = enemy_scene.instantiate()
		add_child(enemy)
		enemy.global_position = point.global_position
		enemy.global_rotation = point.global_rotation
		_active_enemies += 1

		# WICHTIG: Self-Damage-Schutz laut Projektregel - owner zeigt auf
		# Szenen-Root, damit Hitboxen den eigenen Raum/Spawner nicht als
		# Quelle für Friendly-Fire missverstehen.
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

	if count == 0:
		# Raum ohne Gegner (z.B. Corridor/Treasure) gilt sofort als "clear"
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
