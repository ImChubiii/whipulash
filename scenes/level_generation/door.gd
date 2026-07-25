extends StaticBody3D
class_name Door

## Tuer faehrt beim Entriegeln senkrecht nach oben aus dem Rahmen.
##
## door_kind faerbt das Tuerblatt ein (BOSS = rot, TREASURE = goldgelb).
## BOSS/TREASURE-Tueren muessen "gehackt" werden: Interaktionstaste
## (Action "interact") hack_duration Sekunden GEDRUECKT HALTEN.
## Freigeschaltet wird das Hacken erst, wenn der davorliegende Raum
## gecleared ist -> LevelGenerator ruft set_hack_enabled(true).
##
## BUGFIX (Boss-/Treasure-Tuer liess sich nicht bedienen):
## _setup_hack_area() (die Area3D, die den Spieler ueberhaupt erst
## erkennt) wurde bisher NUR aufgerufen, wenn requires_hack() beim
## Ausfuehren von _ready() bereits true war. Das Problem: der
## LevelGenerator ruft set_door_kind(BOSS/TREASURE) immer ERST NACH dem
## add_child() aller Raeume auf (_apply_door_kinds() laeuft ganz am Ende
## von _instantiate_layout) - add_child() loest _ready() der Tuer aber
## SOFORT rekursiv aus, also lange BEVOR der Kind ueberhaupt gesetzt
## wird. requires_hack() war zu dem Zeitpunkt also immer false, die
## Hack-Area wurde nie erzeugt, und die Taste tat buntlich nichts.
## Fix: die Hack-Area wird jetzt IMMER in _ready() erzeugt (minimaler
## Overhead - eine leere Area3D pro Tuer), unabhaengig vom aktuellen
## door_kind. Fuer normale Tueren bricht _process_hack() trotzdem sofort
## über requires_hack() ab, es wird also nichts zusaetzlich verarbeitet.
##
## MATERIAL-OVERRIDE-BUG beachtet: material_override HAT VORRANG vor
## surface_material_override - die Einfaerbung nach door_kind wird
## deshalb bewusst ueber material_override gesetzt.

enum DoorKind { NORMAL, BOSS, TREASURE }

signal hack_started
signal hack_progress_changed(progress: float)
signal hack_completed

## Achtung: die InputMap-Action heisst "interact" (ohne Leerzeichen) -
## der urspruengliche Tippfehler mit Leerzeichen wurde im Input Map
## bereinigt (Action umbenannt), dieser Verweis hier entsprechend
## nachgezogen.
const INTERACT_ACTION := "interact"

@export var door_kind: DoorKind = DoorKind.NORMAL:
	set(value):
		door_kind = value
		_apply_kind_visuals()

@export var open_height: float = 0.0
@export var open_clearance: float = 0.5
@export var move_speed: float = 0.0
@export var open_duration: float = 0.7

## --- Hacking --------------------------------------------------------
@export var force_hack: bool = false
@export var hack_duration: float = 4.0
@export var hack_decay_rate: float = 0.5
@export var hack_range: float = 4.0
@export var prompt_text: String = "HACKING"

## --- Farben ---------------------------------------------------------
@export var color_boss: Color = Color(0.85, 0.10, 0.10)
@export var color_treasure: Color = Color(1.0, 0.78, 0.15)
@export var kind_emission_energy: float = 1.6

var _locked: bool = true
var _closed_y: float = 0.0
var _open_y: float = 0.0
var _effective_open_height: float = 0.0
var _effective_speed: float = 1.0

var _hack_enabled: bool = false
var _hack_done: bool = false
var _hack_progress: float = 0.0
var _hack_area: Area3D = null
var _player_in_range: bool = false

@onready var _collision: CollisionShape3D = get_node_or_null("CollisionShape3D")
@onready var _mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")


func _ready() -> void:
	if _collision == null:
		push_error("Door (%s): Kein Kind namens 'CollisionShape3D' gefunden - Tuer kann nicht blockieren." % get_path())
		set_process(false)
		return

	_effective_open_height = open_height
	if _effective_open_height <= 0.0:
		_effective_open_height = _measure_door_height() + open_clearance

	_effective_speed = move_speed
	if _effective_speed <= 0.0:
		_effective_speed = _effective_open_height / max(open_duration, 0.05)

	_closed_y = position.y
	_open_y = _closed_y + _effective_open_height
	_collision.disabled = not _locked

	_apply_kind_visuals()

	# IMMER erzeugen, nicht nur "if requires_hack()" - siehe Bugfix-
	# Kommentar oben. door_kind kann sich NACH _ready() noch aendern
	# (LevelGenerator setzt es erst spaeter), die Area muss aber schon
	# jetzt existieren, damit der Spieler ueberhaupt erkannt wird.
	_setup_hack_area()

	set_process(true)


func requires_hack() -> bool:
	return force_hack or door_kind == DoorKind.BOSS or door_kind == DoorKind.TREASURE


## Faerbt das Tuerblatt ein. material_override statt
## surface_material_override, weil ersteres im Template gesetzte
## Surface-Overrides ueberschreibt (bekannter Godot-Fallstrick).
func _apply_kind_visuals() -> void:
	if _mesh == null:
		_mesh = get_node_or_null("MeshInstance3D")
	if _mesh == null:
		return

	if door_kind == DoorKind.NORMAL:
		_mesh.material_override = null
		return

	var tint: Color = color_boss if door_kind == DoorKind.BOSS else color_treasure
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.emission_enabled = true
	mat.emission = tint
	mat.emission_energy_multiplier = kind_emission_energy
	_mesh.material_override = mat


func _set_emission_pulse(factor: float) -> void:
	if _mesh == null:
		return
	var mat := _mesh.material_override as StandardMaterial3D
	if mat:
		mat.emission_energy_multiplier = kind_emission_energy * factor


func _setup_hack_area() -> void:
	if _hack_area != null:
		return

	_hack_area = Area3D.new()
	_hack_area.name = "HackRange"
	_hack_area.collision_layer = 0
	_hack_area.collision_mask = 1  # nur Player-Layer
	_hack_area.monitorable = false
	add_child(_hack_area)

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = hack_range
	shape.shape = sphere
	_hack_area.add_child(shape)

	_hack_area.body_entered.connect(_on_hack_body_entered)
	_hack_area.body_exited.connect(_on_hack_body_exited)


func _on_hack_body_entered(body: Node3D) -> void:
	if body.is_in_group(PartyManager.PLAYER_GROUP):
		_player_in_range = true


func _on_hack_body_exited(body: Node3D) -> void:
	if body.is_in_group(PartyManager.PLAYER_GROUP):
		_player_in_range = false
		_hide_prompt()


## Wird vom LevelGenerator aufgerufen, sobald der Raum davor gecleared ist.
func set_hack_enabled(enabled: bool) -> void:
	_hack_enabled = enabled


func is_hack_enabled() -> bool:
	return _hack_enabled


func _measure_door_height() -> float:
	if _collision == null or _collision.shape == null:
		return 4.0
	var shape: Shape3D = _collision.shape
	var y_scale: float = _collision.global_transform.basis.y.length()
	if shape is BoxShape3D:
		return (shape as BoxShape3D).size.y * y_scale
	if shape is CapsuleShape3D:
		return (shape as CapsuleShape3D).height * y_scale
	if shape is CylinderShape3D:
		return (shape as CylinderShape3D).height * y_scale
	if shape is SphereShape3D:
		return (shape as SphereShape3D).radius * 2.0 * y_scale
	return 4.0


func set_locked(locked: bool) -> void:
	# Hack-Tueren ignorieren ein automatisches Entriegeln - die gehen NUR
	# ueber den abgeschlossenen Hack auf. Zusperren darf man sie trotzdem.
	if requires_hack() and not locked and not _hack_done:
		_locked = true
		if _collision:
			_collision.disabled = false
		return

	_locked = locked
	if _collision:
		_collision.disabled = not _locked


func is_locked() -> bool:
	return _locked


func _process(delta: float) -> void:
	_process_hack(delta)

	var target_y: float = _closed_y if _locked else _open_y
	if not is_equal_approx(position.y, target_y):
		position.y = move_toward(position.y, target_y, _effective_speed * delta)


func _process_hack(delta: float) -> void:
	if not requires_hack() or _hack_done:
		return

	if not _player_in_range:
		_decay(delta)
		return

	if not _hack_enabled:
		_show_prompt("GESPERRT", 0.0)
		_decay(delta)
		return

	if Input.is_action_pressed(INTERACT_ACTION):
		if _hack_progress <= 0.0:
			hack_started.emit()
		_hack_progress = minf(_hack_progress + delta / max(hack_duration, 0.05), 1.0)
		hack_progress_changed.emit(_hack_progress)
		_show_prompt(prompt_text, _hack_progress)
		_set_emission_pulse(1.0 + sin(Time.get_ticks_msec() * 0.02) * 0.6)

		if _hack_progress >= 1.0:
			_complete_hack()
	else:
		_show_prompt(prompt_text, _hack_progress)
		_decay(delta)


func _decay(delta: float) -> void:
	if _hack_progress <= 0.0:
		return
	_hack_progress = maxf(_hack_progress - delta * hack_decay_rate, 0.0)
	hack_progress_changed.emit(_hack_progress)
	_set_emission_pulse(1.0)
	if _hack_progress <= 0.0:
		_hide_prompt()


func _complete_hack() -> void:
	_hack_done = true
	_locked = false
	if _collision:
		_collision.disabled = true
	_set_emission_pulse(1.0)
	_hide_prompt()
	hack_completed.emit()


func _show_prompt(text: String, progress: float) -> void:
	var prompt: Node = HackPrompt.get_or_create(self)
	if prompt:
		prompt.show_prompt(text, progress, InputMap.action_get_events(INTERACT_ACTION))


func _hide_prompt() -> void:
	var prompt: Node = HackPrompt.find_existing(self)
	if prompt:
		prompt.hide_prompt()
