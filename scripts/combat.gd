extends Node
class_name Combat

# --- Cooldown-Werte, im Inspector einstellbar ---
@export var primary_cooldown: float = 0.4
@export var secondary_cooldown: float = 3.0
@export var utility_cooldown: float = 1.5

@export var dash_speed: float = 30.0
@export var dash_duration: float = 0.4

# --- Signals, damit sich später ein UI-Cooldown-Icon dranhängen kann ---
signal primary_used
signal secondary_used
signal utility_used
signal combo_changed(count: int)

# --- Interne Cooldown-Timer (0 = bereit, >0 = wartet noch) ---
var _primary_timer: float = 0.0
var _secondary_timer: float = 0.0
var _utility_timer: float = 0.0

var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_direction: Vector3 = Vector3.ZERO

# --- Hit Lock: nur aktiv, wenn ein Angriff TATSÄCHLICH trifft ---
# --- (nicht bei jedem Schwung), und friert nicht komplett ein, ---
# --- sondern erlaubt noch etwas reduzierte Bewegung. ---
@export var hit_lock_duration: float = 0.2
@export_range(0.0, 1.0) var hit_lock_speed_multiplier: float = 0.1

# Wie viel "Trauma" ein TATSÄCHLICHER Treffer zur Kamera hinzufügt
# (summiert sich bei mehreren Treffern auf, gedeckelt bei 1.0 im Player).
@export var hit_shake_strength: float = 0.4

# --- Combo-Tilt: dramatische Kamera-Neigung, wächst mit der Combo ---
# --- "Bohrer"-Verhalten: bleibt in eine Richtung, solange derselbe ---
# --- Gegner getroffen wird, flippt nur bei Zielwechsel. ---
@export var combo_tilt_per_hit: float = 1.5
@export var combo_tilt_max: float = 8.0
# Eigener, KURZER Reset-Timer nur für den Tilt — unabhängig vom
# combo_window (das länger läuft, für den Cooldown-Bonus).
@export var combo_tilt_reset_delay: float = 0.5
var _tilt_reset_timer: float = 0.0
var _tilt_direction: float = 1.0
var _last_hit_target: Node = null

# 0.0 = komplett schweben (keine Schwerkraft während Hit Lock),
# 1.0 = normale Schwerkraft (kein Unterschied), 0.2-0.3 = langsames Sinken.
@export_range(0.0, 1.0) var hit_lock_gravity_multiplier: float = 0.0

# Ob man während des Hit Locks überhaupt springen kann.
@export var hit_lock_allow_jump: bool = false

var _hit_lock_timer: float = 0.0

# --- Combo-System: jeder Treffer über den ersten hinaus reduziert den ---
# --- Primary-Cooldown linear, hart gedeckelt bei combo_max_reduction. ---
@export var combo_window: float = 3.0                        # Sekunden, bis Combo verfällt
@export var combo_cooldown_reduction_per_hit: float = 0.1    # 10% Reduktion pro Combo-Stufe
@export_range(0.0, 1.0) var combo_max_reduction: float = 0.5 # Hard Cap: max. 50% Reduktion
var _combo_count: int = 0
var _combo_timer: float = 0.0

# --- Dash-Vertikalität: vorwärts behält volle Blickrichtungs-Neigung, ---
# --- rückwärts bleibt bewusst flach/horizontal ("normaler" Dash). ---
@export_range(0.0, 1.0) var backward_dash_vertical_influence: float = 0.0

# --- Node-Referenzen, die wir vom Player brauchen ---
var player: CharacterBody3D
@onready var primary_hitbox: Hitbox = get_node_or_null("../CameraPivot/PrimaryHitbox")
@onready var secondary_hitbox: Hitbox = get_node_or_null("../CameraPivot/SecondaryHitbox")

func setup(owner_player: CharacterBody3D) -> void:
	player = owner_player
	if primary_hitbox:
		primary_hitbox.hit_landed.connect(_on_hit_landed)
	if secondary_hitbox:
		secondary_hitbox.hit_landed.connect(_on_hit_landed)

func _on_hit_landed(target: Node) -> void:
	_hit_lock_timer = hit_lock_duration

	if player and player.has_method("shake_camera"):
		player.shake_camera(hit_shake_strength)

	# Target Lock: der getroffene Gegner wird zum anvisierten Ziel —
	# Modell schaut zu ihm, Kamera wird sanft in seine Richtung gezogen,
	# bis er stirbt oder ein anderer Gegner getroffen wird.
	if player and player.has_method("set_target") and target is Node3D:
		player.set_target(target)

	# Bestehendes AUFWÄRTS-Momentum sofort kappen (z.B. aus einem Sprung),
	# damit man während des Hit Locks nicht einfach weiter nach oben
	# treibt. Abwärts-Momentum (Fallen) bleibt unangetastet, das wird
	# separat über hit_lock_gravity_multiplier gesteuert.
	if player and player.velocity.y > 0.0:
		player.velocity.y = 0.0

	# Combo hochzählen und Verfalls-Timer zurücksetzen
	_combo_count += 1
	_combo_timer = combo_window
	combo_changed.emit(_combo_count)

	# "Bohrer"-Tilt: Richtung bleibt gleich, solange derselbe Gegner
	# getroffen wird (dreht sich immer weiter rein) — wechselt das Ziel
	# auf einen ANDEREN Gegner, flippt die Richtung einmal um.
	if target != _last_hit_target:
		_tilt_direction *= -1.0
		_last_hit_target = target

	if _combo_count >= 2 and player and player.has_method("play_combo_tilt"):
		var tilt: float = min(_combo_count * combo_tilt_per_hit, combo_tilt_max) * _tilt_direction
		player.play_combo_tilt(tilt)

	_tilt_reset_timer = combo_tilt_reset_delay

func _process(delta: float) -> void:
	# NEU: Solange der Player gestunnt ist (z.B. von einem schnellen,
	# nervigen Gegner getroffen), werden weder Angriffe noch Dash
	# ausgelöst — kompletter Input-Block für Combat, bis der Stun
	# abgelaufen ist. Cooldown-Countdown pausiert dabei mit, das ist
	# gewollt (kein "Cooldown-Farming" während man eh nichts tun kann).
	if player and player.has_method("is_stunned") and player.is_stunned():
		return

	# Cooldowns runterzählen
	_primary_timer = max(_primary_timer - delta, 0.0)
	_secondary_timer = max(_secondary_timer - delta, 0.0)
	_utility_timer = max(_utility_timer - delta, 0.0)
	_hit_lock_timer = max(_hit_lock_timer - delta, 0.0)

	# Combo-Verfall: läuft der Timer ab, ohne dass neu getroffen wurde,
	# wird die Combo komplett zurückgesetzt.
	if _combo_count > 0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_count = 0
			combo_changed.emit(0)
			_last_hit_target = null
			if player and player.has_method("reset_combo_tilt"):
				player.reset_combo_tilt()

	# Eigener, kurzer Tilt-Reset: läuft schneller ab als das ganze
	# combo_window, damit sich die Kamera-Neigung zügig zurücksetzt,
	# sobald kurz nicht mehr getroffen wird.
	if _tilt_reset_timer > 0.0:
		_tilt_reset_timer -= delta
		if _tilt_reset_timer <= 0.0:
			_last_hit_target = null
			if player and player.has_method("reset_combo_tilt"):
				player.reset_combo_tilt()

	if Input.is_action_pressed("attack_primary") and _primary_timer <= 0.0:
		_do_primary()

	if Input.is_action_pressed("attack_secondary") and _secondary_timer <= 0.0:
		_do_secondary()

	if Input.is_action_just_pressed("utility") and _utility_timer <= 0.0:
		_do_utility()

func _do_primary() -> void:
	_primary_timer = _get_effective_primary_cooldown()
	primary_used.emit()
	if primary_hitbox:
		primary_hitbox.activate()
		# Hitbox nach kurzer Zeit wieder ausschalten (Angriffs-"Fenster")
		await get_tree().create_timer(0.15).timeout
		primary_hitbox.deactivate()

# Erst ab dem ZWEITEN Treffer (combo_count >= 2) wird der Cooldown reduziert.
# Jeder weitere Treffer reduziert LINEAR weiter, bis zum harten Cap bei
# combo_max_reduction (Standard: 50% — der Cooldown kann also nie mehr
# als auf die Hälfte fallen, egal wie lang die Combo läuft).
func _get_effective_primary_cooldown() -> float:
	var stacks: int = max(_combo_count - 1, 0)
	var reduction: float = min(stacks * combo_cooldown_reduction_per_hit, combo_max_reduction)
	return primary_cooldown * (1.0 - reduction)

func _do_secondary() -> void:
	_secondary_timer = secondary_cooldown
	secondary_used.emit()
	if secondary_hitbox:
		secondary_hitbox.activate()
		await get_tree().create_timer(0.25).timeout
		secondary_hitbox.deactivate()

func _do_utility() -> void:
	_utility_timer = utility_cooldown
	utility_used.emit()

	if player and player.has_method("play_dash_fov_effect"):
		player.play_dash_fov_effect()

	var camera_pivot: Node3D = player.get_node("CameraPivot")
	var spring_arm: SpringArm3D = player.get_node("CameraPivot/SpringArm3D")

	# forward_full: mit voller vertikaler Neigung (Pitch) — für Vorwärts-Dash.
	# forward_flat: rein horizontal, keine Neigung — für Rückwärts-Dash.
	var forward_full: Vector3 = spring_arm.global_transform.basis.z
	var forward_flat: Vector3 = camera_pivot.global_transform.basis.z
	var right: Vector3 = camera_pivot.global_transform.basis.x

	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# input_dir.y < 0 heißt "vorwärts" (W), > 0 heißt "rückwärts" (S).
	# Rückwärts wird die Vertikal-Komponente gedämpft (Standard: komplett
	# geflacht), vorwärts bleibt exakt wie zuvor mit voller Neigung.
	var effective_forward: Vector3
	if input_dir.y > 0.0:
		effective_forward = forward_full.lerp(forward_flat, 1.0 - backward_dash_vertical_influence)
	else:
		effective_forward = forward_full

	var move_direction: Vector3 = (right * input_dir.x + effective_forward * input_dir.y)

	if move_direction.length() > 0.1:
		_dash_direction = move_direction.normalized()
	else:
		# Keine Taste gedrückt → Fallback: exakte Blickrichtung, mit voller Neigung
		_dash_direction = -forward_full.normalized()

	_is_dashing = true
	_dash_timer = dash_duration

# Wird vom Player-Script in _physics_process aufgerufen, damit der Dash
# die normale Bewegung während seiner Dauer überschreiben kann.
func get_dash_velocity(delta: float) -> Vector3:
	if not _is_dashing:
		return Vector3.ZERO

	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_is_dashing = false
		return Vector3.ZERO

	return _dash_direction * dash_speed

func is_dashing() -> bool:
	return _is_dashing

# 1.0 = normale Bewegung, kleinerer Wert = verlangsamt (während Hit Lock)
func get_movement_multiplier() -> float:
	if _hit_lock_timer > 0.0:
		return hit_lock_speed_multiplier
	return 1.0

func is_hit_locked() -> bool:
	return _hit_lock_timer > 0.0

# 1.0 = normale Schwerkraft, 0.0 = komplett ausgesetzt (schweben),
# dazwischen = anteiliges langsames Fallen. Nur während Hit Lock relevant.
func get_gravity_multiplier() -> float:
	if _hit_lock_timer > 0.0:
		return hit_lock_gravity_multiplier
	return 1.0

func can_jump() -> bool:
	if _hit_lock_timer > 0.0:
		return hit_lock_allow_jump
	return true

# --- Praktisch für ein späteres Cooldown-UI (0.0 bis 1.0) ---
func get_primary_cooldown_percent() -> float:
	var cd := _get_effective_primary_cooldown()
	return _primary_timer / cd if cd > 0.0 else 0.0

func get_secondary_cooldown_percent() -> float:
	return _secondary_timer / secondary_cooldown if secondary_cooldown > 0.0 else 0.0

func get_utility_cooldown_percent() -> float:
	return _utility_timer / utility_cooldown if utility_cooldown > 0.0 else 0.0

func get_combo_count() -> int:
	return _combo_count
