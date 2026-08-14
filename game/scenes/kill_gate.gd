extends Node3D
class_name KillGate

@export var required_kills: int = 1
@export var interact_range_hint: String = "[E] Öffnen"
@export var open_angle_degrees: float = 100.0
@export var open_duration: float = 1.2

# Optional: manuell den passenden Spawner reinziehen, falls du NUR einen
# bestimmten Spawner zählen willst.
@export var spawner_override: NodePath

# Alternative zu spawner_override — statt eines einzelnen Spawners kannst
# du hier den Namen einer Gruppe angeben (siehe enemy_spawner.gd's
# extra_group-Feld). Alle Spawner in dieser Gruppe werden zusammengezählt.
# Praktisch für Stages mit MEHREREN gleichzeitigen Spawnern (z.B. die
# finale Stage mit Koloss+Fighter+Stinger-Spawnern, die alle derselben
# Gruppe "stage4_spawners" angehören — das Gate zählt dann automatisch
# die Summe aus allen dreien).
# Priorität: spawner_override > spawner_group_override > Fallback (ALLE
# Spawner in der globalen Gruppe "enemy_spawners", bisheriges Verhalten).
@export var spawner_group_override: String = ""

# WORKAROUND: is_action_pressed("interact") hat im Input-Map-System aus
# unbekanntem Grund nicht zuverlässig funktioniert — daher wird direkt
# auf einen physischen Keycode geprüft. Das umgeht damit bewusst das
# Rebinding-System; falls du später Tasten-Neubelegung im Menü anbieten
# willst, müsste diese eine Taste separat behandelt werden. Zumindest ist
# die Taste selbst jetzt hier im Inspector änderbar, statt hart im Code
# zu stehen.
@export var interact_keycode: Key = KEY_E

# Schaltet die "KillGate DEBUG:"-Konsolen-Ausgaben an/aus — gleiches
# Muster wie bei enemy_ai.gd/primary_hitbox.gd. Standardmäßig AUS, da die
# Root-Causes der ursprünglichen Debugging-Session bereits gefunden sind.
@export var debug_logging: bool = false

@onready var gate_visual: Node3D = $GateVisual
@onready var status_label: Label3D = $StatusLabel
@onready var interact_zone: Area3D = $InteractZone

var _current_kills: int = 0
# WICHTIG: merkt sich pro Spawner den letzten bekannten Kill-Stand.
# Bei mehreren Spawnern muss addiert werden, statt nur den letzten
# empfangenen Wert zu nehmen — sonst überschreiben sich die Spawner
# gegenseitig und der Gesamtstand ist falsch.
var _spawner_kill_counts: Dictionary = {}
var _player_in_range: bool = false
var _is_open: bool = false

func _debug(msg: String) -> void:
	if debug_logging:
		print("KillGate DEBUG [%s]: %s" % [name, msg])

func _ready() -> void:
	_update_label()

	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

	var spawners: Array = []

	if not spawner_override.is_empty():
		var single := get_node_or_null(spawner_override)
		if single:
			spawners.append(single)

	if spawners.is_empty() and not spawner_group_override.is_empty():
		spawners = get_tree().get_nodes_in_group(spawner_group_override)

	if spawners.is_empty():
		spawners = get_tree().get_nodes_in_group("enemy_spawners")

	if spawners.is_empty():
		push_warning("KillGate: Konnte keinen EnemySpawner finden.")
	else:
		for spawner in spawners:
			_debug("Spawner gefunden -> %s" % spawner.name)
			_spawner_kill_counts[spawner] = 0
			if spawner.has_signal("enemy_killed"):
				spawner.enemy_killed.connect(_on_enemy_killed.bind(spawner))
				_debug("mit enemy_killed Signal verbunden -> %s" % spawner.name)
			else:
				_debug("WARNUNG: Spawner %s hat KEIN enemy_killed Signal!" % spawner.name)

func _on_enemy_killed(total_killed: int, spawner: Node) -> void:
	_spawner_kill_counts[spawner] = total_killed

	# Gesamtsumme über ALLE verbundenen Spawner neu berechnen
	_current_kills = 0
	for count in _spawner_kill_counts.values():
		_current_kills += count

	_debug("enemy_killed von %s empfangen, spawner_total=%d, gesamt=%d" % [spawner.name, total_killed, _current_kills])
	_update_label()

func _update_label() -> void:
	if _is_open:
		status_label.text = "Geöffnet"
		return
	if _current_kills >= required_kills:
		status_label.text = interact_range_hint if _player_in_range else "Bereit (E)"
	else:
		status_label.text = "Enemies Killed %d/%d" % [_current_kills, required_kills]

func _on_body_entered(body: Node3D) -> void:
	_debug("body_entered -> %s | has set_target: %s | in group player: %s" % [body.name, body.has_method("set_target"), body.is_in_group("player")])
	if body.name != "Player" and not body.is_in_group("player"):
		if not body.has_method("set_target"):
			_debug("body wurde NICHT als Player erkannt, ignoriert")
			return
	_player_in_range = true
	_debug("_player_in_range = true")
	_update_label()

func _on_body_exited(body: Node3D) -> void:
	if body.has_method("set_target") or body.is_in_group("player"):
		_player_in_range = false
		_debug("_player_in_range = false")
		_update_label()

func _unhandled_input(event: InputEvent) -> void:
	var interact_pressed: bool = event is InputEventKey and event.pressed \
		and not event.echo and event.physical_keycode == interact_keycode

	if interact_pressed:
		_debug("Interact-Taste gedrückt. _is_open=%s _player_in_range=%s kills=%d/%d" % [_is_open, _player_in_range, _current_kills, required_kills])

	if _is_open or not _player_in_range:
		return
	if _current_kills < required_kills:
		return
	if interact_pressed:
		_debug("Tor wird jetzt geöffnet!")
		_open_gate()

func _open_gate() -> void:
	_is_open = true
	_update_label()

	var tween := create_tween()
	tween.tween_property(gate_visual, "rotation:y", deg_to_rad(open_angle_degrees), open_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var gate_collision := gate_visual.find_child("CollisionShape3D", true, false)
	if gate_collision:
		await tween.finished
		gate_collision.disabled = true
