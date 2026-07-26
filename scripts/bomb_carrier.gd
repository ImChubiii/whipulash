extends Node
class_name BombCarrier

# ============================================================================
# BombCarrier — haengt zur Laufzeit am aktiven Spieler (siehe item_manager.gd)
# und regelt Ausruesten, Ablegen und Werfen.
# ============================================================================
#
# BEDIENUNG (Design-Vorgabe):
#   X          -> Bombe ausruesten. Die Zuendschnur laeuft ab DIESEM Moment.
#   X nochmal  -> Bombe vor sich ablegen.
#   LMB        -> Bombe werfen.
#
# WARUM DIE ZUENDSCHNUR SCHON BEIM AUSRUESTEN LAEUFT:
# Das ist die eigentliche Spielmechanik. Wer die Bombe zu lange in der Hand
# haelt, sprengt sich selbst — genau dieser Druck macht die Entscheidung
# "jetzt werfen oder noch eine halbe Sekunde zielen" interessant. Eine
# Bombe, deren Timer erst beim Ablegen startet, ist nur eine Verzoegerung.
#
# LMB IST GLEICHZEITIG attack_primary. CombatBase POLLT diese Action mit
# Input.is_action_pressed() — set_input_as_handled() greift dagegen nicht.
# Deshalb wird das Combat-Node fuer die Dauer des Ausgeruestet-Zustands
# stillgelegt (set_process(false)). Das ist derselbe Ansatz, den Godot
# selbst fuer sich gegenseitig ausschliessende Zustaende empfiehlt, und er
# kommt ohne einen Eingriff in combat_base.gd aus.

signal bomb_equipped(fuse_remaining: float)
signal bomb_released
signal fuse_ticked(remaining: float)

## Muss mit item_manager.gd -> BOMB_ACTION uebereinstimmen. Die Action wird
## dort beim Start automatisch angelegt, falls sie im InputMap fehlt.
const BOMB_ACTION: String = "bomb"

## Wie weit vor dem Spieler eine abgelegte Bombe landet.
@export var place_distance: float = 1.2
## Wurfkraft nach vorne.
@export var throw_force: float = 14.0
## Zusaetzlicher Bogen nach oben, damit der Wurf nicht am Boden entlangschrammt.
@export var throw_arc: float = 5.0
## Zuendschnur — bewusst hier und nicht in bomb.gd, damit Items sie spaeter
## verlaengern koennen, ohne die Bombe selbst zu kennen.
@export var fuse_time: float = 2.0

var _player: CharacterBody3D = null
var _combat: CombatBase = null
var _pivot: Node3D = null

var _equipped: bool = false
var _fuse_remaining: float = 0.0
var _held_visual: Node3D = null


func _ready() -> void:
	_player = get_parent() as CharacterBody3D
	if _player == null:
		push_warning("BombCarrier: Elternknoten ist kein CharacterBody3D.")
		return
	_combat = _player.get_node_or_null("Combat") as CombatBase
	_pivot = _player.get_node_or_null("CameraPivot") as Node3D


func _exit_tree() -> void:
	# Beim Charakterwechsel darf das Combat-Node nicht stillgelegt
	# zurueckbleiben — sonst kann der neue Charakter nicht mehr angreifen.
	_set_combat_enabled(true)


func _process(delta: float) -> void:
	if not _equipped:
		return

	_fuse_remaining -= delta
	fuse_ticked.emit(_fuse_remaining)

	if _fuse_remaining <= 0.0:
		# In der Hand hochgegangen. Die Bombe wird trotzdem gespawnt, damit
		# die Explosion ueber denselben Code laeuft wie sonst auch — sie
		# zuendet nur sofort.
		var bomb: Bomb = _release_bomb(Vector3.ZERO)
		if bomb:
			bomb.trigger_now.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	if event.is_action_pressed(BOMB_ACTION):
		if _equipped:
			_place()
		else:
			_equip()
		get_viewport().set_input_as_handled()
		return

	if _equipped and event.is_action_pressed("attack_primary"):
		_throw()
		get_viewport().set_input_as_handled()


# ============================================================================
# Zustaende
# ============================================================================
func _equip() -> void:
	var items: Node = get_node_or_null("/root/Items")
	if items == null or not items.consume_bomb():
		return

	_equipped = true
	_fuse_remaining = fuse_time
	_set_combat_enabled(false)
	_build_held_visual()
	bomb_equipped.emit(_fuse_remaining)


func _place() -> void:
	_release_bomb(Vector3.ZERO)


func _throw() -> void:
	var forward: Vector3 = _get_forward()
	_release_bomb(forward * throw_force + Vector3.UP * throw_arc)


## Erzeugt die echte Bombe in der Welt und beendet den Ausgeruestet-Zustand.
func _release_bomb(impulse: Vector3) -> Bomb:
	if not _equipped:
		return null

	_equipped = false
	_set_combat_enabled(true)
	_clear_held_visual()
	bomb_released.emit()

	var parent: Node = get_tree().current_scene
	if parent == null:
		return null

	var bomb := Bomb.new()
	bomb.fuse_time = fuse_time
	bomb.thrower = _player
	parent.add_child(bomb)

	# Die Restlaufzeit aus der Hand wird uebernommen — sonst waere Halten
	# risikofrei.
	bomb.set("_fuse_remaining", maxf(_fuse_remaining, 0.05))

	var forward: Vector3 = _get_forward()
	bomb.global_position = _player.global_position + forward * place_distance + Vector3(0.0, 0.4, 0.0)

	if impulse.length() > 0.01:
		bomb.apply_central_impulse(impulse)

	return bomb


func _get_forward() -> Vector3:
	if _pivot == null:
		return -_player.global_transform.basis.z
	var forward: Vector3 = -_pivot.global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		return Vector3.FORWARD
	return forward.normalized()


func _set_combat_enabled(enabled: bool) -> void:
	if _combat == null or not is_instance_valid(_combat):
		return
	_combat.set_process(enabled)


# ============================================================================
# Bombe in der Hand
# ============================================================================
# Reine Sichtbarkeitshilfe: eine kleine Kugel ueber dem Kopf. Sobald es ein
# Modell mit Hand-Bone gibt, hier durch einen BoneAttachment3D ersetzen.
func _build_held_visual() -> void:
	_clear_held_visual()

	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.44
	sphere.radial_segments = 8
	sphere.rings = 5

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.16, 0.16, 0.20)
	material.emission_enabled = true
	material.emission = Color(0.95, 0.3, 0.15)
	material.emission_energy_multiplier = 1.5

	var instance := MeshInstance3D.new()
	instance.mesh = sphere
	instance.material_override = material

	_held_visual = Node3D.new()
	_held_visual.name = "HeldBomb"
	_held_visual.add_child(instance)
	_player.add_child(_held_visual)
	_held_visual.position = Vector3(0.0, 1.2, 0.0)


func _clear_held_visual() -> void:
	if _held_visual and is_instance_valid(_held_visual):
		_held_visual.queue_free()
	_held_visual = null


func is_equipped() -> bool:
	return _equipped


func get_fuse_remaining() -> float:
	return _fuse_remaining
