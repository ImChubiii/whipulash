extends Node3D
class_name EnemySpawner

@export var dummy_scene: PackedScene
@export var spawn_points: Array[Node3D] = []
@export var max_concurrent: int = 3
@export var spawn_interval: float = 4.0

# NEU: Zusätzliche Gruppe, der dieser Spawner beitritt (neben dem globalen
# "enemy_spawners"). Damit können mehrere Spawner gezielt EINER Stage
# zugeordnet werden (z.B. "stage1_spawners"), und ein KillGate kann per
# spawner_group_override NUR diese Gruppe zählen statt ALLER Spawner im
# Level. Leer lassen = keine zusätzliche Gruppe (Standardverhalten
# unverändert).
@export var extra_group: String = ""

# Feuert bei JEDEM Tod eines von diesem Spawner erzeugten Gegners —
# das hört sich z.B. ein Gate/Tor an, um Fortschritt zu zeigen.
signal enemy_killed(total_killed: int)

var _active_enemies: Array[Node] = []
var _spawn_timer: float = 0.0
var _total_killed: int = 0

func _ready() -> void:
	randomize()
	add_to_group("enemy_spawners")
	if not extra_group.is_empty():
		add_to_group(extra_group)

func get_total_killed() -> int:
	return _total_killed

func _process(delta: float) -> void:
	_cleanup_dead_references()

	if spawn_points.is_empty() or dummy_scene == null:
		return

	if _active_enemies.size() >= max_concurrent:
		return

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_one()
		_spawn_timer = spawn_interval

func _cleanup_dead_references() -> void:
	# Enemies, die queue_free() aufgerufen haben (gestorben sind), aus
	# der Liste entfernen — sonst denkt der Spawner, es sind noch welche da.
	_active_enemies = _active_enemies.filter(func(e): return is_instance_valid(e))

func _spawn_one() -> void:
	var point: Node3D = spawn_points[randi() % spawn_points.size()]
	var enemy := dummy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = point.global_position
	_active_enemies.append(enemy)

	# Auf den Tod DIESES konkreten Gegners hören, um enemy_killed korrekt
	# auszulösen — funktioniert automatisch auch für Gegner, die der
	# Spawner erst in der Zukunft erzeugt.
	var health := enemy.find_child("Health", true, false)
	if health:
		health.died.connect(_on_spawned_enemy_died)

func _on_spawned_enemy_died() -> void:
	_total_killed += 1
	enemy_killed.emit(_total_killed)
