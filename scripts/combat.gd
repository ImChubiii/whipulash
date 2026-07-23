extends Node
class_name Combat

# --- Cooldown-Werte, im Inspector einstellbar ---
@export var primary_cooldown: float = 0.4
@export var secondary_cooldown: float = 3.0
@export var utility_cooldown: float = 0.8
@export var ability_q_cooldown: float = 6.0
@export var ability_e_cooldown: float = 10.0

@export var dash_speed: float = 30.0
@export var dash_duration: float = 0.4

# --- Signals, damit sich das UI-Cooldown-Icon dranhaengen kann ---
signal primary_used
signal secondary_used
signal utility_used
signal ability_q_used
signal ability_e_used
signal combo_changed(count: int)
# Generisches Signal fuers HUD: slot ist 0..4
signal cooldown_started(slot: int, duration: float)

enum Slot { PRIMARY, SECONDARY, UTILITY, ABILITY_Q, ABILITY_E }

# --- Interne Cooldown-Timer (0 = bereit, >0 = wartet noch) ---
var _primary_timer: float = 0.0
var _secondary_timer: float = 0.0
var _utility_timer: float = 0.0
var _ability_q_timer: float = 0.0
var _ability_e_timer: float = 0.0

var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_direction: Vector3 = Vector3.ZERO

# --- Hit Lock: nur aktiv, wenn ein Angriff TATSAECHLICH trifft ---
# --- (nicht bei jedem Schwung), und friert nicht komplett ein, ---
# --- sondern erlaubt noch etwas reduzierte Bewegung. ---
@export var hit_lock_duration: float = 0.2
@export_range(0.0, 1.0) var hit_lock_speed_multiplier: float = 0.1

# Wie viel "Trauma" ein TATSAECHLICHER Treffer zur Kamera hinzufuegt
# (summiert sich bei mehreren Treffern auf, gedeckelt bei 1.0 im Player).
@export var hit_shake_strength: float = 0.4

# --- Combo-Tilt: dramatische Kamera-Neigung, waechst mit der Combo ---
# --- "Bohrer"-Verhalten: bleibt in eine Richtung, solange derselbe ---
# --- Gegner getroffen wird, flippt nur bei Zielwechsel. ---
@export var combo_tilt_per_hit: float = 1.5
@export var combo_tilt_max: float = 8.0
# Eigener, KURZER Reset-Timer nur fuer den Tilt — unabhaengig vom
# combo_window (das laenger laeuft, fuer den Cooldown-Bonus).
@export var combo_tilt_reset_delay: float = 0.5
var _tilt_reset_timer: float = 0.0
var _tilt_direction: float = 1.0
var _last_hit_target: Node = null

# 0.0 = komplett schweben (keine Schwerkraft waehrend Hit Lock),
# 1.0 = normale Schwerkraft (kein Unterschied), 0.2-0.3 = langsames Sinken.
@export_range(0.0, 1.0) var hit_lock_gravity_multiplier: float = 0.0

# Ob man waehrend des Hit Locks ueberhaupt springen kann.
@export var hit_lock_allow_jump: bool = false

var _hit_lock_timer: float = 0.0

# --- Combo-System: jeder Treffer ueber den ersten hinaus reduziert den ---
# --- Primary-Cooldown linear, hart gedeckelt bei combo_max_reduction. ---
@export var combo_window: float = 3.0                        # Sekunden, bis Combo verfaellt
@export var combo_cooldown_reduction_per_hit: float = 0.1    # 10% Reduktion pro Combo-Stufe
@export_range(0.0, 1.0) var combo_max_reduction: float = 0.5 # Hard Cap: max. 50% Reduktion
var _combo_count: int = 0
var _combo_timer: float = 0.0

# --- Dash-Vertikalitaet: vorwaerts behaelt volle Blickrichtungs-Neigung, ---
# --- rueckwaerts bleibt bewusst flach/horizontal ("normaler" Dash). ---
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

# Uebernimmt die Cooldown-Werte eines AbilitySet beim Charakterwechsel.
# Laufende Cooldowns werden dabei zurueckgesetzt.
func apply_ability_set(set: AbilitySet) -> void:
	if set == null:
		return
	primary_cooldown = set.primary_cooldown
	secondary_cooldown = set.secondary_cooldown
	utility_cooldown = set.utility_cooldown
	ability_q_cooldown = set.ability_q_cooldown
	ability_e_cooldown = set.ability_e_cooldown

	_primary_timer = 0.0
	_secondary_timer = 0.0
	_utility_timer = 0.0
	_ability_q_timer = 0.0
	_ability_e_timer = 0.0

func _on_hit_landed(target: Node) -> void:
	_hit_lock_timer = hit_lock_duration

	if player and player.has_method("shake_camera"):
		player.shake_camera(hit_shake_strength)

	# Target Lock: der getroffene Gegner wird zum anvisierten Ziel —
	# Modell schaut zu ihm, Kamera wird sanft in seine Richtung gezogen,
	# bis er stirbt oder ein anderer Gegner getroffen wird.
	if player and player.has_method("set_target") and target is Node3D:
		player.set_target(target)

	# Bestehendes AUFWAERTS-Momentum sofort kappen (z.B. aus einem Sprung),
	# damit man waehrend des Hit Locks nicht einfach weiter nach oben
	# treibt. Abwaerts-Momentum (Fallen) bleibt unangetastet, das wird
	# separat ueber hit_lock_gravity_multiplier gesteuert.
	if player and player.velocity.y > 0.0:
		player.velocity.y = 0.0

	# Combo hochzaehlen und Verfalls-Timer zuruecksetzen
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
	# Solange der Player gestunnt ist (z.B. von einem schnellen,
	# nervigen Gegner getroffen), werden weder Angriffe noch Dash
	# ausgeloest — kompletter Input-Block fuer Combat, bis der Stun
	# abgelaufen ist. Cooldown-Countdown pausiert dabei mit, das ist
	# gewollt (kein "Cooldown-Farming" waehrend man eh nichts tun kann).
	if player and player.has_method("is_stunned") and player.is_stunned():
		return

	# Cooldowns runterzaehlen
	_primary_timer = max(_primary_timer - delta, 0.0)
	_secondary_timer = max(_secondary_timer - delta, 0.0)
	_utility_timer = max(_utility_timer - delta, 0.0)
	_ability_q_timer = max(_ability_q_timer - delta, 0.0)
	_ability_e_timer = max(_ability_e_timer - delta, 0.0)
	_hit_lock_timer = max(_hit_lock_timer - delta, 0.0)

	# Combo-Verfall: laeuft der Timer ab, ohne dass neu getroffen wurde,
	# wird die Combo komplett zurueckgesetzt.
	if _combo_count > 0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_count = 0
			combo_changed.emit(0)
			_last_hit_target = null
			if player and player.has_method("reset_combo_tilt"):
				player.reset_combo_tilt()

	# Eigener, kurzer Tilt-Reset: laeuft schneller ab als das ganze
	# combo_window, damit sich die Kamera-Neigung zuegig zuruecksetzt,
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

	if InputMap.has_action("ability_primary") \
			and Input.is_action_just_pressed("ability_primary") and _ability_q_timer <= 0.0:
		_do_ability_q()

	if InputMap.has_action("ability_secondary") \
			and Input.is_action_just_pressed("ability_secondary") and _ability_e_timer <= 0.0:
		_do_ability_e()

func _do_primary() -> void:
	var cd: float = _get_effective_primary_cooldown()
	_primary_timer = cd
	primary_used.emit()
	cooldown_started.emit(Slot.PRIMARY, cd)
	if primary_hitbox:
		primary_hitbox.activate()
		# Hitbox nach kurzer Zeit wieder ausschalten (Angriffs-"Fenster")
		await get_tree().create_timer(0.15).timeout
		primary_hitbox.deactivate()

# Erst ab dem ZWEITEN Treffer (combo_count >= 2) wird der Cooldown reduziert.
# Jeder weitere Treffer reduziert LINEAR weiter, bis zum harten Cap bei
# combo_max_reduction (Standard: 50% — der Cooldown kann also nie mehr
# als auf die Haelfte fallen, egal wie lang die Combo laeuft).
func _get_effective_primary_cooldown() -> float:
	var stacks: int = max(_combo_count - 1, 0)
	var reduction: float = min(stacks * combo_cooldown_reduction_per_hit, combo_max_reduction)
	return primary_cooldown * (1.0 - reduction)

func _do_secondary() -> void:
	_secondary_timer = secondary_cooldown
	secondary_used.emit()
	cooldown_started.emit(Slot.SECONDARY, secondary_cooldown)
	if secondary_hitbox:
		secondary_hitbox.activate()
		await get_tree().create_timer(0.25).timeout
		secondary_hitbox.deactivate()

# --- Q-Ability: Platzhalter-Logik, hier deine Charakterfaehigkeit einbauen ---
func _do_ability_q() -> void:
	_ability_q_timer = ability_q_cooldown
	ability_q_used.emit()
	cooldown_started.emit(Slot.ABILITY_Q, ability_q_cooldown)

	if player and player.has_method("shake_camera"):
		player.shake_camera(0.35)

# --- E-Ability: Platzhalter-Logik, hier deine Charakterfaehigkeit einbauen ---
func _do_ability_e() -> void:
	_ability_e_timer = ability_e_cooldown
	ability_e_used.emit()
	cooldown_started.emit(Slot.ABILITY_E, ability_e_cooldown)

	if player and player.has_method("shake_camera"):
		player.shake_camera(0.5)

func _do_utility() -> void:
	_utility_timer = utility_cooldown
	utility_used.emit()
	cooldown_started.emit(Slot.UTILITY, utility_cooldown)

	if player and player.has_method("play_dash_fov_effect"):
		player.play_dash_fov_effect()

	var camera_pivot: Node3D = player.get_node("CameraPivot")
	var spring_arm: SpringArm3D = player.get_node("CameraPivot/SpringArm3D")

	# forward_full: mit voller vertikaler Neigung (Pitch) — fuer Vorwaerts-Dash.
	# forward_flat: rein horizontal, keine Neigung — fuer Rueckwaerts-Dash.
	var forward_full: Vector3 = spring_arm.global_transform.basis.z
	var forward_flat: Vector3 = camera_pivot.global_transform.basis.z
	var right: Vector3 = camera_pivot.global_transform.basis.x

	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# input_dir.y < 0 heisst "vorwaerts" (W), > 0 heisst "rueckwaerts" (S).
	# Rueckwaerts wird die Vertikal-Komponente gedaempft (Standard: komplett
	# geflacht), vorwaerts bleibt exakt wie zuvor mit voller Neigung.
	var effective_forward: Vector3
	if input_dir.y > 0.0:
		effective_forward = forward_full.lerp(forward_flat, 1.0 - backward_dash_vertical_influence)
	else:
		effective_forward = forward_full

	var move_direction: Vector3 = (right * input_dir.x + effective_forward * input_dir.y)

	if move_direction.length() > 0.1:
		_dash_direction = move_direction.normalized()
	else:
		# Keine Taste gedrueckt -> Fallback: exakte Blickrichtung, mit voller Neigung
		_dash_direction = -forward_full.normalized()

	_is_dashing = true
	_dash_timer = dash_duration

# Wird vom Player-Script in _physics_process aufgerufen, damit der Dash
# die normale Bewegung waehrend seiner Dauer ueberschreiben kann.
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

# 1.0 = normale Bewegung, kleinerer Wert = verlangsamt (waehrend Hit Lock)
func get_movement_multiplier() -> float:
	if _hit_lock_timer > 0.0:
		return hit_lock_speed_multiplier
	return 1.0

func is_hit_locked() -> bool:
	return _hit_lock_timer > 0.0

# 1.0 = normale Schwerkraft, 0.0 = komplett ausgesetzt (schweben),
# dazwischen = anteiliges langsames Fallen. Nur waehrend Hit Lock relevant.
func get_gravity_multiplier() -> float:
	if _hit_lock_timer > 0.0:
		return hit_lock_gravity_multiplier
	return 1.0

func can_jump() -> bool:
	if _hit_lock_timer > 0.0:
		return hit_lock_allow_jump
	return true

# --- Cooldown-Prozente fuers UI (0.0 = bereit, 1.0 = gerade gestartet) ---
func get_primary_cooldown_percent() -> float:
	var cd := _get_effective_primary_cooldown()
	return _primary_timer / cd if cd > 0.0 else 0.0

func get_secondary_cooldown_percent() -> float:
	return _secondary_timer / secondary_cooldown if secondary_cooldown > 0.0 else 0.0

func get_utility_cooldown_percent() -> float:
	return _utility_timer / utility_cooldown if utility_cooldown > 0.0 else 0.0

func get_ability_q_cooldown_percent() -> float:
	return _ability_q_timer / ability_q_cooldown if ability_q_cooldown > 0.0 else 0.0

func get_ability_e_cooldown_percent() -> float:
	return _ability_e_timer / ability_e_cooldown if ability_e_cooldown > 0.0 else 0.0

# Sammel-Getter fuers HUD: gibt fuer Slot 0..4 den Prozentwert zurueck.
func get_cooldown_percent(slot: int) -> float:
	match slot:
		Slot.PRIMARY:
			return get_primary_cooldown_percent()
		Slot.SECONDARY:
			return get_secondary_cooldown_percent()
		Slot.UTILITY:
			return get_utility_cooldown_percent()
		Slot.ABILITY_Q:
			return get_ability_q_cooldown_percent()
		Slot.ABILITY_E:
			return get_ability_e_cooldown_percent()
	return 0.0

# Verbleibende Sekunden fuer den Cooldown-Text im HUD.
func get_cooldown_remaining(slot: int) -> float:
	match slot:
		Slot.PRIMARY:
			return _primary_timer
		Slot.SECONDARY:
			return _secondary_timer
		Slot.UTILITY:
			return _utility_timer
		Slot.ABILITY_Q:
			return _ability_q_timer
		Slot.ABILITY_E:
			return _ability_e_timer
	return 0.0

func get_combo_count() -> int:
	return _combo_count
