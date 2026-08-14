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
#
# ---------------------------------------------------------------------------
# AENDERUNG: DEUTLICH WEITERE WUERFE
# ---------------------------------------------------------------------------
# throw_force liegt jetzt bei 26 statt 14, throw_arc bei 9 statt 5. Der
# entscheidende Teil steckt aber NICHT in diesen Zahlen, sondern in
# Bomb.launch(): die Bombe lief bisher schon in der Luft mit
# linear_damp = 3.0 und verlor ihren Schwung, bevor sie ueberhaupt
# irgendwo ankam. Ein hoeherer Impuls allein haette daran wenig geaendert —
# er waere einfach schneller weggedaempft worden. launch() senkt die
# Daempfung fuer die Flugphase und stellt sie bei Bodenkontakt wieder her.
#
# BLICKRICHTUNG: das Projekt nutzt +Z als Vorne. _get_forward() gibt
# deshalb bewusst -basis.z des CameraPivot zurueck (Godots eigene
# Vorwaertsachse), weil hier die KAMERA-Blickrichtung gemeint ist und nicht
# die Charakter-Ausrichtung. Wer das auf die Figur umstellt, muss auf +Z
# wechseln — sonst wirft der Spieler nach hinten.

signal bomb_equipped(fuse_remaining: float)
signal bomb_released
signal fuse_ticked(remaining: float)

## Muss mit item_manager.gd -> BOMB_ACTION uebereinstimmen. Die Action wird
## dort beim Start automatisch angelegt, falls sie im InputMap fehlt.
const BOMB_ACTION: String = "bomb"

## Wie weit vor dem Spieler eine abgelegte Bombe landet.
@export var place_distance: float = 1.2
## Wurfkraft nach vorne.
@export var throw_force: float = 85.0
## Zusaetzlicher Bogen nach oben, damit der Wurf nicht am Boden entlangschrammt.
@export var throw_arc: float = 10.0
## Zuendschnur — bewusst hier und nicht in bomb.gd, damit Items sie spaeter
## verlaengern koennen, ohne die Bombe selbst zu kennen.
@export var fuse_time: float = 2.0

## Vorschau-Bogen, waehrend die Bombe in der Hand liegt. Bei der neuen
## Wurfweite kann man das Ziel sonst nicht mehr abschaetzen: die Bombe
## fliegt weiter, als der Bildausschnitt bei enger Kamera hergibt.
@export var show_aim_preview: bool = true
@export var aim_preview_points: int = 14
@export var aim_preview_step: float = 0.075

var _player: CharacterBody3D = null
var _combat: CombatBase = null
var _pivot: Node3D = null

var _equipped: bool = false
var _fuse_remaining: float = 0.0
var _held_visual: Node3D = null
var _aim_preview: Node3D = null
var _aim_dots: Array[MeshInstance3D] = []
var _blink_accumulator: float = 0.0


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
	_update_aim_preview()
	_update_blink(delta)

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
		return
		
	if _equipped and event.is_action_pressed("attack_secondary"):
		_place()
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
	_blink_accumulator = 0.0
	_set_combat_enabled(false)
	_build_held_visual()
	_build_aim_preview()
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
	_clear_aim_preview()
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
	bomb.set("_blink_accumulator", _blink_accumulator)

	var forward: Vector3 = _get_forward()
	# Etwas hoeher als frueher (0.9 statt 0.4): der Wurf startet damit auf
	# Brusthoehe statt an den Fuessen. Bei der groesseren Wurfweite ist das
	# der Unterschied zwischen einer Parabel und einem Aufprall auf der
	# naechsten Stufe.
	bomb.global_position = _player.global_position + forward * place_distance + Vector3(0.0, 0.9, 0.0)

	# launch() statt apply_central_impulse(): nur so faellt die Daempfung
	# fuer die Flugphase weg. Siehe Kopf der Datei.
	if impulse.length() > 0.01:
		bomb.launch(impulse)

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
	sphere.radius = 0.55
	sphere.height = 1.10
	sphere.radial_segments = 10
	sphere.rings = 6

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.16, 0.16, 0.20)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.35, 0.15)
	material.emission_energy_multiplier = 1.0

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


func _update_blink(delta: float) -> void:
	if _held_visual == null:
		return
	var mesh_node: MeshInstance3D = _held_visual.get_child(0) as MeshInstance3D
	if mesh_node == null or not (mesh_node.material_override is StandardMaterial3D):
		return

	var progress: float = 1.0 - clampf(_fuse_remaining / maxf(fuse_time, 0.01), 0.0, 1.0)
	var frequency: float = lerpf(3.0, 18.0, progress)
	_blink_accumulator += delta * frequency

	var pulse: float = (sin(_blink_accumulator * TAU) * 0.5 + 0.5)
	var material: StandardMaterial3D = mesh_node.material_override
	material.emission_energy_multiplier = pulse * lerpf(2.0, 6.0, progress)


# ============================================================================
# Ziel-Vorschau
# ============================================================================
# Punktreihe entlang der Wurfparabel. Sie wird NICHT physikalisch simuliert,
# sondern analytisch berechnet (p = p0 + v*t + 0.5*g*t^2). Eine echte
# Simulation muesste die Bombe probeweise durch die Welt schicken, und das
# jeden Frame — fuer eine reine Zielhilfe waere das voellig unverhaeltnis-
# maessig. Die Punkte ignorieren deshalb Hindernisse; sie zeigen die
# Flugbahn, nicht den Einschlag.
func _build_aim_preview() -> void:
	_clear_aim_preview()
	if not show_aim_preview:
		return

	_aim_preview = Node3D.new()
	_aim_preview.name = "BombAimPreview"
	# Direkt an die Szene, nicht an den Spieler: sonst wandern die Punkte
	# mit, sobald sich der Spieler beim Zielen dreht.
	var parent: Node = get_tree().current_scene
	if parent == null:
		return
	parent.add_child(_aim_preview)

	var sphere := SphereMesh.new()
	sphere.radius = 0.09
	sphere.height = 0.18
	sphere.radial_segments = 6
	sphere.rings = 3

	for i: int in range(aim_preview_points):
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		# Nach hinten ausblenden: die Bahn soll gerichtet wirken.
		var fade: float = 1.0 - float(i) / float(maxi(aim_preview_points, 1))
		material.albedo_color = Color(1.0, 0.55, 0.25, 0.25 + fade * 0.55)
		material.cull_mode = BaseMaterial3D.CULL_DISABLED

		var dot := MeshInstance3D.new()
		dot.mesh = sphere
		dot.material_override = material
		dot.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		dot.scale = Vector3.ONE * (0.5 + fade * 0.8)
		_aim_preview.add_child(dot)
		_aim_dots.append(dot)


func _update_aim_preview() -> void:
	if _aim_preview == null or not is_instance_valid(_aim_preview):
		return
	if _player == null or not is_instance_valid(_player):
		return

	var forward: Vector3 = _get_forward()
	var start: Vector3 = _player.global_position + forward * place_distance + Vector3(0.0, 0.9, 0.0)

	# Impuls / Masse = Startgeschwindigkeit. Die Masse steht in bomb.gd auf
	# 2.5 — wer sie dort aendert, muss sie hier mitziehen, sonst zeigt die
	# Vorschau eine andere Bahn als der tatsaechliche Wurf.
	var velocity: Vector3 = (forward * throw_force + Vector3.UP * throw_arc) / 2.5
	var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))

	for i: int in range(_aim_dots.size()):
		var t: float = float(i + 1) * aim_preview_step
		var point: Vector3 = start + velocity * t + Vector3.DOWN * (0.5 * gravity * t * t)
		_aim_dots[i].global_position = point


func _clear_aim_preview() -> void:
	_aim_dots.clear()
	if _aim_preview and is_instance_valid(_aim_preview):
		_aim_preview.queue_free()
	_aim_preview = null


func is_equipped() -> bool:
	return _equipped


func get_fuse_remaining() -> float:
	return _fuse_remaining
