@tool
extends Node3D
class_name LavaHazard

# --- Größe & Optik — bei jeder Instanz individuell einstellbar ---
@export var size: Vector3 = Vector3(4.0, 1.0, 4.0):
	set(value):
		size = value
		_apply_size()

@export var lava_color: Color = Color(0.667, 0.843, 0.216):  # #AAD737
	set(value):
		lava_color = value
		_apply_color()

@export var glow_energy: float = 2.5:
	set(value):
		glow_energy = value
		_apply_color()

@export_range(0.0, 1.0) var alpha: float = 0.85:
	set(value):
		alpha = value
		_apply_color()

# --- Pulsieren: leichtes "Atmen" des Glows für den lebendigen, ätzenden Look ---
@export var pulse_enabled: bool = true
@export var pulse_speed: float = 2.0
@export_range(0.0, 1.0) var pulse_amount: float = 0.4

# --- Gameplay-Werte ---
@export var damage_per_tick: float = 15.0
@export var tick_interval: float = 1.0
@export var buoyancy_rise_speed: float = 2.5
@export_range(0.0, 1.0) var entry_dampening: float = 0.15

# Falls true, gibt's den ersten Tick-Schaden sofort beim Betreten. Falls
# false (Standard), wird der erste Schaden erst nach tick_interval fällig,
# wie jeder folgende Tick — fairer bei kurzem Kontakt.
@export var damage_on_entry: bool = false

# NEU: Toleranz nach OBEN in Metern — wie weit man über der berechneten
# Lava-Oberfläche noch als "gerade so drin" zählt (kleiner Puffer gegen
# Flackern an der exakten Kante). Größere Werte NICHT nutzen, um das
# eigentliche Problem (Trigger größer als sichtbare Lava) zu kaschieren —
# dafür gibt's die echte Höhenprüfung unten.
@export var submersion_tolerance: float = 0.3

@export var display_name: String = "Lava"

# Schaltet die "Lemonade DEBUG:"-Konsolen-Ausgaben an/aus.
@export var debug_logging: bool = false

func get_display_name() -> String:
	return display_name

@onready var visual: CSGBox3D = $LemonadeVisual
@onready var trigger: Area3D = $LemonadeTrigger
@onready var collision_shape: CollisionShape3D = $LemonadeTrigger/CollisionShape3D

# Jeder Body, der aktuell innerhalb der (rein horizontal/grob erfassenden)
# Area3D-Trigger-Zone ist, bekommt einen Eintrag. "submerged" wird JEDEN
# FRAME neu anhand der echten Weltraum-Höhe berechnet — nicht mehr allein
# anhand der Trigger-Box, die durch eine versehentliche Transform-Skalierung
# (siehe level_01's Lemonade-Instanz) viel größer sein kann als die
# sichtbare Lava-Oberfläche.
var _occupants: Dictionary = {}  # body -> {tick_timer: float, submerged: bool}
var _pulse_time: float = 0.0
var _material: StandardMaterial3D

func _debug(msg: String) -> void:
	if debug_logging:
		print("Lemonade DEBUG [%s]: %s" % [name, msg])

func _ready() -> void:
	_apply_size()
	_apply_color()

	if Engine.is_editor_hint():
		return

	add_to_group("lava_hazards")

	if trigger:
		trigger.body_entered.connect(_on_body_entered)
		trigger.body_exited.connect(_on_body_exited)

func _apply_size() -> void:
	if visual:
		visual.size = size
	if collision_shape and collision_shape.shape is BoxShape3D:
		(collision_shape.shape as BoxShape3D).size = size

func _apply_color() -> void:
	if not visual:
		return
	if _material == null:
		_material = visual.material as StandardMaterial3D
		if _material == null:
			_material = StandardMaterial3D.new()
			visual.material = _material

	_material.albedo_color = Color(lava_color.r, lava_color.g, lava_color.b, alpha)
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# WICHTIG: ohne das schreibt transparentes Material nicht in den
	# Tiefenpuffer -> Sortierungs-Chaos, Objekte "blitzen durch" andere
	# durch. Gleiches Problem hatten wir schon beim PSX-Shader.
	_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	_material.emission_enabled = true
	_material.emission = lava_color
	_material.emission_energy_multiplier = glow_energy

# Berechnet die TATSÄCHLICHE Weltraum-Y-Höhe der Lava-Oberfläche über
# global_transform — das rechnet JEDE Skalierung korrekt mit ein, egal ob
# sie sauber über das "size"-Feld kam oder (aus Versehen) über eine rohe
# Transform->Scale auf dem Node selbst (wie beim großen See in level_01).
# global_transform.basis.y.length() liefert den tatsächlichen effektiven
# Y-Skalierungsfaktor, unabhängig von der Ursache.
func _get_surface_top_world_y() -> float:
	var y_scale: float = global_transform.basis.y.length()
	return global_position.y + (size.y * 0.5 * y_scale)

func _is_body_submerged(body: Node3D) -> bool:
	return _get_body_feet_y(body) <= _get_surface_top_world_y() + submersion_tolerance

# Berechnet die TATSÄCHLICHE Weltraum-Y-Höhe der FÜSSE eines Bodies über
# dessen eigene CollisionShape3D — nicht einfach body.global_position.y
# (die Root!). Beim Spieler sitzt die Kapsel-Mitte um die Root (Root =
# Körpermitte), bei manchen Gegnern ist Root = Fußhöhe. Ohne diesen Fix
# musste ein Body fast bis zur Hüfte einsinken, bevor eine nur 1 Einheit
# tiefe Lachpfütze überhaupt als "wirklich drin" erkannt wurde — man lief
# einfach obenauf, statt einzusinken.
func _get_body_feet_y(body: Node3D) -> float:
	var collision_shape: CollisionShape3D = body.get_node_or_null("CollisionShape3D")
	if collision_shape and collision_shape.shape:
		var shape := collision_shape.shape
		# WICHTIG: falls die CollisionShape3D-Node selbst noch eine
		# Transform-Skalierung trägt (z.B. beim Colossus, dessen Body-
		# Kollision nie auf Identity-Scale umgestellt wurde), muss das
		# hier mit eingerechnet werden — sonst stimmt die Fußhöhe bei
		# großen, noch skalierten Gegnern nicht.
		var y_scale: float = collision_shape.global_transform.basis.y.length()
		var half_height: float = 0.0
		if shape is CapsuleShape3D:
			half_height = (shape.radius + shape.height * 0.5) * y_scale
		elif shape is BoxShape3D:
			half_height = shape.size.y * 0.5 * y_scale
		elif shape is SphereShape3D:
			half_height = shape.radius * y_scale
		return collision_shape.global_position.y - half_height
	return body.global_position.y

func _process(delta: float) -> void:
	# Pulsieren darf auch im Editor laufen (rein optisch, keine Gameplay-Logik)
	if pulse_enabled and _material:
		_pulse_time += delta * pulse_speed
		var pulse: float = 1.0 + sin(_pulse_time) * pulse_amount
		_material.emission_energy_multiplier = glow_energy * pulse

	if Engine.is_editor_hint():
		return
	if _occupants.is_empty():
		return

	for body in _occupants.keys():
		if not is_instance_valid(body):
			continue

		var entry: Dictionary = _occupants[body]
		var now_submerged: bool = _is_body_submerged(body)
		var was_submerged: bool = entry["submerged"]

		if now_submerged and not was_submerged:
			_debug("'%s' ist jetzt WIRKLICH untergetaucht (war nur in der groben Trigger-Zone)." % body.name)
			_start_submersion_effects(body)
		elif was_submerged and not now_submerged:
			_debug("'%s' ist über die Oberfläche gestiegen, obwohl noch in der Trigger-Zone -> Effekte pausiert." % body.name)
			_stop_submersion_effects(body)

		entry["submerged"] = now_submerged

		if now_submerged:
			entry["tick_timer"] += delta
			if entry["tick_timer"] >= tick_interval:
				entry["tick_timer"] = 0.0
				var health: Node = body.find_child("Health", true, false)
				if health:
					_debug("Tick-Schaden an '%s' (%.1f Schaden)" % [body.name, damage_per_tick])
					_apply_tick_damage(health)

		_occupants[body] = entry

func _is_player(body: Node3D) -> bool:
	# Gleiche Erkennungs-Konvention wie im Rest des Projekts (KillGate,
	# GoalZone): der Spieler hat set_target() vom Lock-On-System, Gegner
	# (EnemyAI) haben das NICHT.
	return body.has_method("set_target")

func _start_submersion_effects(body: Node3D) -> void:
	if body is CharacterBody3D and body.velocity.y < 0.0:
		body.velocity.y *= entry_dampening

	if body.has_method("set_buoyancy"):
		body.set_buoyancy(true, buoyancy_rise_speed)

	if _is_player(body):
		var overlay := get_tree().get_root().find_child("SubmersionOverlay", true, false)
		if overlay and overlay.has_method("show_submersion"):
			overlay.show_submersion(lava_color)

func _stop_submersion_effects(body: Node3D) -> void:
	if body.has_method("set_buoyancy"):
		body.set_buoyancy(false)

	if _is_player(body):
		if not _player_still_in_any_other_lemonade(body):
			var overlay := get_tree().get_root().find_child("SubmersionOverlay", true, false)
			if overlay and overlay.has_method("hide_submersion"):
				overlay.hide_submersion()

func _on_body_entered(body: Node3D) -> void:
	_debug("body_entered (grobe Trigger-Zone): '%s'" % body.name)

	var health := body.find_child("Health", true, false)
	if health == null or not (health is Health):
		_debug("  -> ignoriert: kein Health-Node an '%s'" % body.name)
		return

	var starts_submerged: bool = _is_body_submerged(body)
	_occupants[body] = {"tick_timer": 0.0, "submerged": starts_submerged}
	_debug("  -> als Occupant registriert. Sofort wirklich untergetaucht: %s" % starts_submerged)

	if starts_submerged:
		if damage_on_entry:
			_apply_tick_damage(health)
		_start_submersion_effects(body)

func _on_body_exited(body: Node3D) -> void:
	_debug("body_exited (grobe Trigger-Zone): '%s'" % body.name)

	if _occupants.has(body):
		var was_submerged: bool = _occupants[body]["submerged"]
		_occupants.erase(body)
		if was_submerged:
			_stop_submersion_effects(body)

func _player_still_in_any_other_lemonade(player_body: Node3D) -> bool:
	for hazard in get_tree().get_nodes_in_group("lava_hazards"):
		if hazard == self:
			continue
		if hazard is LavaHazard and hazard._occupants.has(player_body):
			if hazard._occupants[player_body]["submerged"]:
				return true
	return false

func _apply_tick_damage(health: Node) -> void:
	health.take_damage(damage_per_tick)
