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
		# door_kind wird vom LevelGenerator ERST NACH _ready() gesetzt
		# (siehe Bugfix-Kommentar oben) - das Hologramm muss deshalb hier
		# nachgezogen werden, nicht nur in _ready().
		if is_inside_tree():
			_refresh_hologram()

@export var open_height: float = 0.0
@export var open_clearance: float = 0.5
@export var move_speed: float = 0.0
@export var open_duration: float = 0.7

## --- Hacking --------------------------------------------------------
## BUGFIX "im Bossraum eingesperrt":
##
## Seit die Tuer auf BEIDEN Seiten eines Boss-/Tresor-Durchgangs
## eingefaerbt wird, war auch die Tuer INNERHALB des Sonderraums vom Typ
## BOSS/TREASURE — und requires_hack() leitete daraus ab, dass sie
## gehackt werden muss. Folge:
##   1. Spieler betritt den Bossraum, der Raum verriegelt hinter ihm.
##   2. Boss stirbt -> _lock_exits(false) ruft set_locked(false).
##   3. set_locked() steigt bei Hack-Tueren ohne abgeschlossenen Hack
##      SOFORT wieder aus und setzt _locked = true zurueck.
##   -> Die Tuer geht nie wieder auf. Der Spieler steht fest.
##
## Der Hack soll den EINTRITT in den Sonderraum gaten, nicht den Ausgang.
## Deshalb trennt hack_exempt jetzt die OPTIK (door_kind, bleibt rot bzw.
## golden) von der MECHANIK: Der LevelGenerator setzt das Flag auf der
## Innenseite und die Tuer verhaelt sich dort wie eine normale Tuer.
@export var hack_exempt: bool = false:
	set(value):
		hack_exempt = value
		# Der Hologramm-Zustand haengt an requires_hack() und muss deshalb
		# mitgezogen werden, wenn sich das Flag nachtraeglich aendert.
		if is_inside_tree():
			_refresh_hologram()

@export var force_hack: bool = false
@export var hack_duration: float = 4.0
@export var hack_decay_rate: float = 0.5
@export var hack_range: float = 4.0
@export var prompt_text: String = "HACKING"

## --- Farben ---------------------------------------------------------
@export var color_boss: Color = Color(0.85, 0.10, 0.10)
@export var color_treasure: Color = Color(1.0, 0.78, 0.15)
@export var kind_emission_energy: float = 1.6

## --- Hacking-Hologramm ------------------------------------------------
## Schwebendes Schild VOR der Tuer, das Boss-/Treasure-Tueren schon aus
## der Entfernung als Hack-Ziel kennzeichnet.
##
## AUSRICHTUNG: Die Richtung "in den Raum hinein" wird aus der Position
## der Tuer RELATIV ZUM RAUM-URSPRUNG abgeleitet (der Raum-Ursprung liegt
## in der Raummitte, die Tuer am Rand -> der Vektor von der Tuer zur
## Raummitte zeigt zwangslaeufig nach innen). Das funktioniert fuer alle
## vier Himmelsrichtungen ohne dass die Tuer ihre eigene Rotation kennen
## muss - die ist je nach Raum-Szene unterschiedlich gesetzt.
##
## VERSCHWINDEN: Sobald der Spieler zu hacken beginnt (oder der Hack
## fertig ist), wird das Hologramm ausgeblendet und kommt nicht zurueck -
## es hat seinen Zweck dann erfuellt und wuerde nur die Sicht auf den
## Fortschrittsbalken stoeren.
@export var hologram_enabled: bool = true
@export var hologram_distance: float = 3.2
@export var hologram_height: float = 3.0
@export var hologram_font_size: int = 64
@export var hologram_text_size: float = 0.5
@export var hologram_fade_duration: float = 0.35
@export var hologram_bob_height: float = 0.25
@export var hologram_bob_speed: float = 1.6

var _locked: bool = true
var _closed_y: float = 0.0
var _open_y: float = 0.0
## Erst true, nachdem _ready() _closed_y/_open_y einmal berechnet hat.
var _base_ready: bool = false
var _effective_open_height: float = 0.0
var _effective_speed: float = 1.0

var _hack_enabled: bool = false
var _hack_done: bool = false
var _hack_progress: float = 0.0
var _hack_area: Area3D = null
var _player_in_range: bool = false

var _hologram: Node3D = null
var _hologram_label: Label3D = null
var _hologram_dismissed: bool = false
var _hologram_base_y: float = 0.0
var _hologram_time: float = 0.0

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
	_base_ready = true
	_collision.disabled = not _locked

	_apply_kind_visuals()

	# IMMER erzeugen, nicht nur "if requires_hack()" - siehe Bugfix-
	# Kommentar oben. door_kind kann sich NACH _ready() noch aendern
	# (LevelGenerator setzt es erst spaeter), die Area muss aber schon
	# jetzt existieren, damit der Spieler ueberhaupt erkannt wird.
	_setup_hack_area()
	_refresh_hologram()

	set_process(true)


func requires_hack() -> bool:
	# hack_exempt gewinnt IMMER — auch gegen force_hack. So laesst sich eine
	# einzelne Tuer gezielt freistellen, ohne die Kind-Logik anzufassen.
	if hack_exempt:
		return false
	return force_hack or door_kind == DoorKind.BOSS or door_kind == DoorKind.TREASURE


## Faerbt das Tuerblatt ein. material_override statt
## surface_material_override, weil ersteres im Template gesetzte
## Surface-Overrides ueberschreibt (bekannter Godot-Fallstrick).
## BUGFIX "Boss-Tuer ist manchmal nicht rot" (Teil 2):
##
## _mesh war ein @onready auf den FESTEN Kindnamen "MeshInstance3D".
## Weicht eine Raum-Szene davon ab (anderer Name, Mesh eine Ebene tiefer
## unter einem Zwischen-Node), ist _mesh null, _apply_kind_visuals()
## steigt still aus und die Tuer bleibt in ihrer Grundfarbe — abhaengig
## davon, WELCHE Raum-Szene der Generator gewuerfelt hat. Genau daher das
## "manchmal".
##
## Jetzt wird zusaetzlich rekursiv nach dem ersten MeshInstance3D gesucht
## und laut gewarnt, wenn wirklich keins da ist.
func _find_mesh() -> MeshInstance3D:
	if _mesh != null and is_instance_valid(_mesh):
		return _mesh

	var direct := get_node_or_null("MeshInstance3D")
	if direct is MeshInstance3D:
		_mesh = direct
		return _mesh

	for child in get_children():
		if child is MeshInstance3D:
			_mesh = child
			return _mesh

	for child in find_children("*", "MeshInstance3D", true, false):
		if child is MeshInstance3D:
			_mesh = child
			push_warning("Door (%s): Kein direktes 'MeshInstance3D' - nutze stattdessen '%s'. Einfaerbung nach door_kind funktioniert, aber die Raum-Szene sollte angeglichen werden." % [get_path(), child.get_path()])
			return _mesh

	return null


func _apply_kind_visuals() -> void:
	_mesh = _find_mesh()
	if _mesh == null:
		if is_inside_tree():
			push_warning("Door (%s): Kein MeshInstance3D gefunden - Tuer kann nicht nach door_kind eingefaerbt werden (bleibt normal-farbig)." % get_path())
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
	if _mesh == null or not is_instance_valid(_mesh):
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


## Kompakter Zustandsstring fuer das Tuer-Protokoll des LevelGenerators.
func get_debug_state() -> String:
	return "kind=%s locked=%s exempt=%s hack_needed=%s hack_enabled=%s hack_done=%s progress=%.2f mesh=%s" % [
		DoorKind.keys()[door_kind],
		_locked,
		hack_exempt,
		requires_hack(),
		_hack_enabled,
		_hack_done,
		_hack_progress,
		"OK" if (_mesh != null and is_instance_valid(_mesh)) else "FEHLT"
	]


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


## BUGFIX "Tuer versinkt im Rampenboden / Durchgang offen trotz VERRIEGELT":
##
## _closed_y wird in _ready() aus position.y gelesen. _ready() laeuft
## waehrend add_child() im LevelGenerator - also BEVOR
## RoomInstance.configure_slope() die Tuer auf der hohen Seite eines
## Rampen-Korridors um rise Meter anhebt. Die Tuer wird zwar korrekt
## versetzt, aber _process() faehrt sie im selben Frame wieder auf das
## alte (tiefe) _closed_y zurueck - sie verschwindet in der Rampe und der
## Durchgang steht offen, obwohl das Tuer-Protokoll "VERRIEGELT" meldet.
##
## Genau das erzeugt im Log das Muster: Korridor (-2, 0) verriegelt beide
## Tueren und hat 2 aktive Gegner, der Spieler steht trotzdem schon im
## Bossraum (-3, 0).
##
## shift_base_height() zieht die Ruhe- UND die Offen-Hoehe mit und muss
## IMMER aufgerufen werden, wenn die Tuer nach _ready() vertikal versetzt
## wird.
func shift_base_height(delta: float) -> void:
	if is_zero_approx(delta):
		return
	if not _base_ready:
		# _ready() liest position.y sowieso erst noch - dort landet der
		# Versatz dann automatisch mit drin.
		position.y += delta
		return

	_closed_y += delta
	_open_y += delta
	position.y = _closed_y if _locked else _open_y


## Absolute Ruhehoehe setzen (Alternative zu shift_base_height, falls die
## Zielhoehe bekannt ist statt der Differenz).
func set_base_height(new_closed_y: float) -> void:
	shift_base_height(new_closed_y - _closed_y)


## Ruhehoehe (geschlossen) der Tuer in Raum-lokalen Koordinaten.
##
## Wird von RoomInstance._build_door_lintel() gebraucht: der Tuersturz muss
## von der Oberkante des GESCHLOSSENEN Blatts bis zur Decke reichen.
## position.y taugt dafuer nicht - eine offene Tuer steht
## _effective_open_height (Blatthoehe + open_clearance) hoeher, der Sturz
## waere dann viel zu kurz und der Spalt bliebe offen.
##
## Vor _ready() ist _closed_y noch nicht gefuellt; dann ist position.y die
## korrekte Antwort, weil die Tuer bis dahin unbewegt auf ihrer
## Szenen-Position steht.
func get_base_height() -> float:
	return _closed_y if _base_ready else position.y


func set_locked(locked: bool) -> void:
	# Hack-Tueren ignorieren ein automatisches Entriegeln - die gehen NUR
	# ueber den abgeschlossenen Hack auf. Zusperren darf man sie trotzdem.
	#
	# Frueher passierte das lautlos. Im Tuer-Protokoll sah man dann nur
	# "ENTRIEGELN (danach: HACK BEREIT)" und musste selbst darauf kommen,
	# dass die Entriegelung abgelehnt wurde. Jetzt sagt die Tuer es selbst.
	if requires_hack() and not locked and not _hack_done:
		_locked = true
		if _collision:
			_collision.disabled = false
		push_warning("Door (%s): Entriegeln ABGELEHNT - Tuer ist eine Hack-Tuer (kind=%s) und wurde noch nicht gehackt. Falls das ein Ausgang aus einem Sonderraum ist, muss hack_exempt gesetzt sein." % [get_path(), DoorKind.keys()[door_kind]])
		return

	_locked = locked
	if _collision:
		_collision.disabled = not _locked


## Entriegelt bedingungslos, auch eine noch nicht gehackte Hack-Tuer.
## Notausgang fuer Sonderfaelle (Cheats, Debug, Rettung aus einem Raum,
## der sich sonst nicht mehr verlassen laesst).
func force_unlock() -> void:
	_hack_done = true
	_locked = false
	if _collision:
		_collision.disabled = true
	_hide_prompt()
	_dismiss_hologram()


func is_locked() -> bool:
	return _locked


func _process(delta: float) -> void:
	_process_hack(delta)
	_animate_hologram(delta)

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
		# Erster echter Interaktions-Frame: Hologramm hat seinen Zweck
		# erfuellt und wuerde ab jetzt nur den Fortschrittsbalken stoeren.
		_dismiss_hologram()
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
	_dismiss_hologram()
	_locked = false
	if _collision:
		_collision.disabled = true
	_set_emission_pulse(1.0)
	_hide_prompt()
	hack_completed.emit()


# ============================================================================
# Hacking-Hologramm
# ============================================================================

## Erzeugt das Hologramm, sobald die Tuer eine Hack-Tuer ist, und entfernt
## es wieder, falls door_kind zurueck auf NORMAL faellt.
func _refresh_hologram() -> void:
	if not hologram_enabled or _hologram_dismissed:
		return

	if not requires_hack():
		if _hologram and is_instance_valid(_hologram):
			_hologram.queue_free()
			_hologram = null
			_hologram_label = null
		return

	if _hologram and is_instance_valid(_hologram):
		_update_hologram_text()
		return

	_build_hologram()


func _build_hologram() -> void:
	_hologram = Node3D.new()
	_hologram.name = "HackHologram"
	add_child(_hologram)

	var tint: Color = color_boss if door_kind == DoorKind.BOSS else color_treasure

	_hologram_label = Label3D.new()
	_hologram_label.name = "HologramLabel"
	# BILLBOARD_ENABLED: dreht sich immer zur Kamera, damit das Schild aus
	# jeder Anlaufrichtung lesbar ist.
	_hologram_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_hologram_label.no_depth_test = false
	_hologram_label.shaded = false
	_hologram_label.double_sided = true
	_hologram_label.font_size = hologram_font_size
	_hologram_label.pixel_size = hologram_text_size / float(max(hologram_font_size, 1))
	_hologram_label.modulate = tint
	_hologram_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_hologram_label.outline_size = 12
	_hologram_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hologram.add_child(_hologram_label)

	_update_hologram_text()
	_position_hologram()


func _update_hologram_text() -> void:
	if _hologram_label == null:
		return
	var kind_text: String = "BOSS" if door_kind == DoorKind.BOSS else "TRESOR"
	_hologram_label.text = "%s\n[ HACK ]" % kind_text
	var tint: Color = color_boss if door_kind == DoorKind.BOSS else color_treasure
	_hologram_label.modulate = tint


## Setzt das Hologramm hologram_distance Meter VOR die Tuer, Richtung
## Raummitte - siehe Klassenkommentar zur Herleitung der Innenrichtung.
func _position_hologram() -> void:
	if _hologram == null:
		return

	var inward: Vector3 = _inward_direction()
	_hologram.position = inward * hologram_distance + Vector3(0.0, hologram_height, 0.0)
	_hologram_base_y = _hologram.position.y


## Richtung "in den Raum hinein", ausgedrueckt im LOKALEN Raum der Tuer.
## Fallback auf -Z (Godot-Vorwaerts), falls kein RoomInstance-Vorfahre
## existiert (z.B. Tuer manuell in ein Testlevel gesetzt).
func _inward_direction() -> Vector3:
	var room: Node = get_parent()
	while room != null and not (room is RoomInstance):
		room = room.get_parent()

	if room == null:
		return Vector3(0.0, 0.0, -1.0)

	var room_3d: Node3D = room as Node3D
	var to_center: Vector3 = room_3d.global_position - global_position
	to_center.y = 0.0
	if to_center.length() < 0.01:
		return Vector3(0.0, 0.0, -1.0)

	# In den lokalen Raum der Tuer umrechnen, weil _hologram.position
	# lokal interpretiert wird.
	return global_transform.basis.inverse() * to_center.normalized()


## Blendet das Hologramm dauerhaft aus - wird beim ersten Hack-Fortschritt
## und beim abgeschlossenen Hack aufgerufen.
func _dismiss_hologram() -> void:
	if _hologram_dismissed:
		return
	_hologram_dismissed = true

	if _hologram == null or not is_instance_valid(_hologram):
		return

	if _hologram_label:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(_hologram_label, "modulate:a", 0.0, hologram_fade_duration)
		tween.tween_property(_hologram, "scale", Vector3(1.4, 0.05, 1.4), hologram_fade_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(func() -> void:
			if is_instance_valid(_hologram):
				_hologram.queue_free()
			_hologram = null
			_hologram_label = null
		)
	else:
		_hologram.queue_free()
		_hologram = null


func _animate_hologram(delta: float) -> void:
	if _hologram == null or not is_instance_valid(_hologram):
		return
	_hologram_time += delta * hologram_bob_speed
	_hologram.position.y = _hologram_base_y + sin(_hologram_time) * hologram_bob_height


func _show_prompt(text: String, progress: float) -> void:
	var prompt: Node = HackPrompt.get_or_create(self)
	if prompt:
		prompt.show_prompt(text, progress, InputMap.action_get_events(INTERACT_ACTION))


func _hide_prompt() -> void:
	var prompt: Node = HackPrompt.find_existing(self)
	if prompt:
		prompt.hide_prompt()
