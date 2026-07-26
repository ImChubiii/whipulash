extends Node
class_name CombatBase

# --- Basisklasse für ALLE Charakter-Combat-Skripte ---
# Enthält das komplette gemeinsame Cooldown-, Combo-, Hit-Lock- und Dash-
# System. Die eigentlichen FÄHIGKEITEN (was Primary/Secondary/Utility/Q/E
# tatsächlich TUN) sind virtuelle "_perform_*"-Methoden — jeder Charakter
# überschreibt sie in seinem eigenen Combat-Script (z.B. combat_ningning.gd)
# mit eigener Logik. Cooldown-Werte werden ebenfalls pro Charakter-Script
# überschrieben (siehe combat_ningning.gd) — es gibt KEIN globales
# Daten-Objekt mehr, das Cooldowns zur Laufzeit "einspielt".

# --- Cooldown-Werte, im Inspector einstellbar UND in Charakter-Subklassen überschreibbar ---
@export var primary_cooldown: float = 0.4
@export var secondary_cooldown: float = 3.0
@export var utility_cooldown: float = 0.8
@export var ability_q_cooldown: float = 6.0
@export var ability_e_cooldown: float = 10.0

@export var dash_speed: float = 35.0
@export var dash_duration: float = 0.4

# ============================================================================
# DASH-SCHADEN - nur beim DURCHdashen
# ============================================================================
# Ein normaler Area3D-Hitbox-Ansatz ("Schaden bei body_entered") waere hier
# falsch: der wuerde schon ausloesen, wenn man den Gegner nur ANTIPPT oder
# direkt vor ihm zum Stehen kommt. Gewollt ist ausdruecklich das DURCHqueren.
#
# Deshalb wird pro Gegner die VORZEICHEN-Umkehr entlang der Dash-Achse
# ausgewertet:
#
#   along = dash_richtung (flach) . (gegner_pos - spieler_pos)
#
#   along > 0  -> Gegner ist VOR mir     -> als Kandidat vormerken
#   along < 0  -> Gegner ist HINTER mir  -> ich bin durch ihn hindurch
#
# Erst dieser Wechsel loest den Schaden aus. Bleibt der Dash vorher stehen
# (Wand, Dauer abgelaufen, Gegner weicht aus), passiert nichts. Zusaetzlich
# muss der Gegner beim Durchqueren im Trefferfenster liegen (seitlich
# dash_hit_radius, vertikal dash_hit_height_up/-_down) - sonst zaehlte ein
# Vorbeirennen im Meterabstand als Treffer.
#
# Die Rechnung laeuft bewusst FLACH (X/Z): "durchdashen" ist eine
# horizontale Bewegung, und dash_direction traegt bei einem Vorwaerts-Dash
# die volle Blickneigung mit - die wuerde die Achse sonst verkippen.

@export var dash_damage_enabled: bool = true
@export var dash_damage: float = 12.0

# --- Trefferfenster ("Hitbox" des Dashs) ------------------------------
# Das Volumen ist ein Quader ENTLANG der Dash-Achse:
#
#            dash_hit_radius            Blick von oben
#                  |
#     +------------|------------+
#     |            |            |
#  ---o============>============|--->  Dash-Richtung
#     |            |            |
#     +------------|------------+
#          Spieler         Ende der Bahn
#
# Es gibt KEINE Obergrenze fuer die Anzahl getroffener Gegner - jeder wird
# einzeln verfolgt. Wer beim Dash mehr Gegner mitnehmen will, dreht
# dash_hit_radius hoch; das Limit war nie die Anzahl, sondern die Breite.
# dash_max_targets_per_dash existiert nur, falls man es bewusst DECKELN will.

## Seitliche Reichweite quer zur Dash-Achse (halbe Korridorbreite).
## 1.8 trifft praktisch nur, wen man frontal rammt. 2.5-3.5 nimmt eine
## ganze Reihe mit, ab ~4.0 fuehlen sich Treffer geschenkt an.
@export var dash_hit_radius: float = 2.6

## Hoehenfenster, getrennt nach oben und unten.
##
## WARUM GETRENNT: Der Spieler-Ursprung sitzt in der Mitte seiner Kapsel,
## der Gegner-Ursprung dagegen bei den FUESSEN. Ein Gegner auf demselben
## Boden liegt dadurch rechnerisch rund 0.9 Meter UNTER dem Spieler - ein
## symmetrisches Fenster verschenkt oben also Reichweite und braucht unten
## unnoetig viel. dash_hit_vertical_offset verschiebt das Fenster zusaetzlich
## als Ganzes, falls eure Kapselmasse abweichen.
@export var dash_hit_height_up: float = 2.0
@export var dash_hit_height_down: float = 3.0
@export var dash_hit_vertical_offset: float = -0.5

## 0 = unbegrenzt (Standard). Nur setzen, wenn ein Dash bewusst hoechstens
## N Gegner treffen soll.
@export var dash_max_targets_per_dash: int = 0
## Wie weit hinter mir der Gegner sein muss, damit es als "durch" zaehlt.
## Verhindert Treffer durch Zittern um den Nullpunkt.
@export var dash_pierce_exit_distance: float = 0.3
## Kulanz beim Dash-START: ein Gegner, der praktisch auf mir steht (along
## leicht negativ), zaehlt trotzdem noch als Kandidat.
@export var dash_entry_grace: float = 0.6

@export var dash_hit_shake_strength: float = 0.25
## Standardmaessig 0: ein Rueckstoss beim Durchqueren schiebt den Gegner
## unkontrolliert weg und macht das Nachsetzen unberechenbar.
@export var dash_knockback_force: float = 0.0
## Ob ein Dash-Treffer die Combo hochzaehlt. Der Hit-Lock aus
## _on_hit_landed() wird BEWUSST nicht ausgeloest - der wuerde den Dash
## mitten in der Bewegung abbremsen.
@export var dash_damage_counts_combo: bool = true
@export var dash_damage_sets_target: bool = true

## VFX, der bei einem Dash-TREFFER am Gegner aufblitzt. Getrennt von
## dash_vfx (Startpuff) und dash_trail (Dauer-Emitter) - das ist der
## Aufschlag, nicht die Bewegung. Leer lassen = kein Effekt.
@export var dash_hit_vfx: PackedScene

## Optionaler Override. Bleibt das Feld leer, wird die Szene von der
## PrimaryHitbox uebernommen (dort ist sie bereits im Inspector gesetzt),
## sonst der Pfad unten geladen.
@export var dash_damage_number_scene: PackedScene
@export var dash_debug_logging: bool = false

## Zeichnet bei jedem Dash das tatsaechliche Trefferfenster als
## halbtransparenten Quader in die Welt - der einzige praktikable Weg, die
## Werte oben einzustellen, ohne zu raten. Fuer den Release ausschalten.
@export var dash_debug_draw: bool = false
@export var dash_debug_draw_duration: float = 0.8
@export var dash_debug_color: Color = Color(1.0, 0.85, 0.1, 0.22)

const DAMAGE_NUMBER_FALLBACK_PATH: String = "res://scenes/damage_number.tscn"

## Gegner-InstanceID -> { "node": Node3D, "pending": bool, "done": bool }
var _dash_pierce_state: Dictionary = {}
var _dash_pierce_armed: bool = false
var _dash_flat_direction: Vector3 = Vector3.ZERO
var _dash_hit_count: int = 0
var _cached_damage_number_scene: PackedScene = null

# --- Signals, damit sich das UI-Cooldown-Icon dranhaengen kann ---
signal primary_used
signal secondary_used
signal utility_used
signal ability_q_used
signal ability_e_used
signal combo_changed(count: int)
## Feuert, wenn ein Gegner DURCHdasht wurde - fuer VFX/Sound/HUD.
signal dash_hit_landed(target: Node)
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
# --- rueckwaerts bleibt bewusst flach/horizontal (default-Dash). ---
@export_range(0.0, 1.0) var backward_dash_vertical_influence: float = 0.0

# --- VFX ---
## Startpuff beim Dash. Wird GEGEN die Dash-Richtung ausgerichtet, damit
## der Staub zurueckbleibt statt vorauszufliegen.
@export var dash_vfx: PackedScene

# --- Node-Referenzen, die wir vom Player brauchen ---
var player: CharacterBody3D
@onready var primary_hitbox: Hitbox = get_node_or_null("../CameraPivot/PrimaryHitbox")
@onready var secondary_hitbox: Hitbox = get_node_or_null("../CameraPivot/SecondaryHitbox")
## Dauer-Emitter fuer den Dash-Trail: GPUParticles3D-Kind am Player-Root
## namens "DashTrail" (emitting = false, one_shot = false,
## local_coords = false — sonst zieht der Trail mit statt stehenzubleiben).
@onready var dash_trail: GPUParticles3D = get_node_or_null("../DashTrail")

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

	# --- Grosskarte offen: keine Angriffe ------------------------------
	# Auf der Grosskarte wird mit gedrueckter linker Maustaste gezogen.
	# LMB ist gleichzeitig attack_primary, und Angriffe werden hier per
	# Input.is_action_pressed() GEPOLLT — set_input_as_handled() in
	# minimap.gd kann Polling nicht abfangen. Ohne diesen Block wuerde
	# jedes Verschieben der Karte den Charakter zuschlagen lassen.
	#
	# Bewusst NACH den Cooldown-Timern: die sollen weiterlaufen, damit
	# ein Blick auf die Karte keine Cooldowns einfriert. Und bewusst ein
	# static-Zugriff statt einer Baumsuche — diese Zeile laeuft in jedem
	# Frame.
	if Minimap.big_map_open:
		return

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
	_perform_primary()

# Von Charakter-Subklassen überschreibbar. Standardverhalten: PrimaryHitbox
# fuer ein kurzes Angriffs-Fenster aktivieren.
# Der Schlag-VFX (swing_vfx) haengt bewusst an der Hitbox selbst, nicht
# hier — so bekommt jede Waffe/jeder Charakter ihren eigenen Swoosh ueber
# den Inspector, ohne dass diese Methode ueberschrieben werden muss.
func _perform_primary() -> void:
	if primary_hitbox:
		primary_hitbox.activate()
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
	_perform_secondary()

# Von Charakter-Subklassen überschreibbar. Standardverhalten: SecondaryHitbox
# fuer ein laengeres Angriffs-Fenster aktivieren.
func _perform_secondary() -> void:
	if secondary_hitbox:
		secondary_hitbox.activate()
		await get_tree().create_timer(0.25).timeout
		secondary_hitbox.deactivate()

func _do_utility() -> void:
	_utility_timer = utility_cooldown
	utility_used.emit()
	cooldown_started.emit(Slot.UTILITY, utility_cooldown)
	_perform_utility()

# Von Charakter-Subklassen überschreibbar. Standardverhalten: Dash in
# Bewegungs-/Blickrichtung.
func _perform_utility() -> void:
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

	# --- VFX ---
	# Startpuff zeigt GEGEN die Dash-Richtung — der Staub bleibt zurueck,
	# das verkauft die Beschleunigung deutlich besser als ein Puff nach vorn.
	if dash_vfx and player:
		VFX.spawn(dash_vfx, player.global_position, -_dash_direction)
	if dash_trail:
		dash_trail.emitting = true

# --- Q-Ability: von jedem Charakter individuell zu überschreiben ---
func _do_ability_q() -> void:
	_ability_q_timer = ability_q_cooldown
	ability_q_used.emit()
	cooldown_started.emit(Slot.ABILITY_Q, ability_q_cooldown)
	_perform_ability_q()

# Fallback, falls ein Charakter-Script das nicht überschreibt.
func _perform_ability_q() -> void:
	if player and player.has_method("shake_camera"):
		player.shake_camera(0.35)

# --- E-Ability: von jedem Charakter individuell zu überschreiben ---
func _do_ability_e() -> void:
	_ability_e_timer = ability_e_cooldown
	ability_e_used.emit()
	cooldown_started.emit(Slot.ABILITY_E, ability_e_cooldown)
	_perform_ability_e()

# Fallback, falls ein Charakter-Script das nicht überschreibt.
func _perform_ability_e() -> void:
	if player and player.has_method("shake_camera"):
		player.shake_camera(0.5)

# Wird vom Player-Script in _physics_process aufgerufen, damit der Dash
# die normale Bewegung waehrend seiner Dauer ueberschreiben kann.
func get_dash_velocity(delta: float) -> Vector3:
	if not _is_dashing:
		return Vector3.ZERO

	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_is_dashing = false
		# Trail hier abschalten und NICHT per create_timer: der Dash kann
		# durch Frame-Drops laenger dauern als dash_duration in Echtzeit,
		# ein paralleler Timer waere dann zu frueh fertig.
		if dash_trail:
			dash_trail.emitting = false
		return Vector3.ZERO

	return _dash_direction * dash_speed


# ============================================================================
# Dash-Schaden: Durchquerungs-Erkennung
# ============================================================================
# Laeuft in _physics_process und NICHT in _process:
#   1. Positionen werden im Physik-Schritt aktualisiert - ein Check im
#      Render-Frame arbeitet je nach Framerate mit veralteten Daten und
#      verpasst bei 30 Metern pro Sekunde ganze Gegner.
#   2. Godot ruft _physics_process in Baumreihenfolge auf: der Player
#      (Elternknoten) zuerst, dieses Combat-Node danach. Wir sehen hier also
#      bereits die Positionen NACH move_and_slide() dieses Frames.
#
# Der armed-Zustand wird aus _is_dashing abgeleitet statt in _perform_utility
# gesetzt: so funktioniert die Erkennung auch, wenn ein Charakter-Script
# _perform_utility ueberschreibt und _is_dashing selbst setzt - und sie
# ueberlebt jede spaetere Aenderung an der Dash-VFX-Logik darueber.
func _physics_process(_delta: float) -> void:
	if not dash_damage_enabled or player == null:
		return

	if _is_dashing:
		if not _dash_pierce_armed:
			_arm_dash_pierce()
		_update_dash_pierce()
	elif _dash_pierce_armed:
		_dash_pierce_armed = false
		_dash_pierce_state.clear()


func _dash_debug(msg: String) -> void:
	if dash_debug_logging:
		print("[DashDamage] %s" % msg)


## Nimmt beim Dash-Start eine Momentaufnahme auf: wer steht schon hinter mir?
## Diese Gegner werden NICHT zu Kandidaten - man ist ja nicht durch sie
## hindurch, man dasht von ihnen weg.
func _arm_dash_pierce() -> void:
	_dash_pierce_armed = true
	_dash_pierce_state.clear()
	_dash_hit_count = 0

	_dash_flat_direction = Vector3(_dash_direction.x, 0.0, _dash_direction.z)
	if _dash_flat_direction.length() < 0.01:
		# Rein vertikaler Dash (Blick senkrecht nach oben/unten): es gibt
		# keine sinnvolle horizontale Achse, also kein Dash-Schaden.
		_dash_flat_direction = Vector3.ZERO
		_dash_debug("Dash ohne horizontale Komponente - Schadenspruefung aus.")
		return

	_dash_flat_direction = _dash_flat_direction.normalized()

	for enemy in _collect_dash_targets():
		var along: float = _dash_along(enemy)
		var id: int = enemy.get_instance_id()
		# Kulanz: wer praktisch auf mir steht, zaehlt noch als "vor mir".
		var pending: bool = along > -dash_entry_grace
		_dash_pierce_state[id] = {"node": enemy, "pending": pending, "done": false}

	_spawn_dash_debug_volume()

	var pending_count: int = 0
	for entry in _dash_pierce_state.values():
		if entry["pending"]:
			pending_count += 1
	_dash_debug("Dash gestartet. %d Gegner im Fenster, davon %d vor mir (Radius %.1f, Hoehe +%.1f/-%.1f)." % [
		_dash_pierce_state.size(), pending_count,
		dash_hit_radius, dash_hit_height_up, dash_hit_height_down
	])


func _update_dash_pierce() -> void:
	if _dash_flat_direction == Vector3.ZERO:
		return
	if dash_max_targets_per_dash > 0 and _dash_hit_count >= dash_max_targets_per_dash:
		return

	for enemy in _collect_dash_targets():
		var id: int = enemy.get_instance_id()
		var along: float = _dash_along(enemy)

		if not _dash_pierce_state.has(id):
			# Erst waehrend des Dashs in Reichweite gekommen. Nur vormerken,
			# wenn er tatsaechlich noch VOR mir ist - taucht er direkt hinter
			# mir auf, bin ich nicht durch ihn durchgelaufen.
			_dash_pierce_state[id] = {
				"node": enemy,
				"pending": along > 0.0,
				"done": false,
			}
			continue

		var entry: Dictionary = _dash_pierce_state[id]
		if entry["done"] or not entry["pending"]:
			continue

		# Vorzeichenwechsel entlang der Dash-Achse = durchquert.
		if along < -dash_pierce_exit_distance:
			entry["done"] = true
			_dash_pierce_state[id] = entry
			_dash_hit_count += 1
			_apply_dash_damage(enemy)
			if dash_max_targets_per_dash > 0 and _dash_hit_count >= dash_max_targets_per_dash:
				_dash_debug("Trefferlimit %d erreicht - Rest dieses Dashs wird ignoriert." % dash_max_targets_per_dash)
				return


## Alle lebenden Gegner, die seitlich und vertikal im Trefferfenster liegen.
## Der Seitenabstand wird zur ACHSE gemessen, nicht zum Spieler - sonst
## wuerde ein Gegner weit vorne auf der Bahn schon rausfallen.
func _collect_dash_targets() -> Array[Node3D]:
	var result: Array[Node3D] = []
	if _dash_flat_direction == Vector3.ZERO:
		return result

	for node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		if enemy == player:
			continue

		var to_enemy: Vector3 = enemy.global_position - player.global_position

		# Hoehenfenster asymmetrisch, siehe Kommentar bei dash_hit_height_up.
		var vertical: float = to_enemy.y - dash_hit_vertical_offset
		if vertical > dash_hit_height_up or vertical < -dash_hit_height_down:
			continue

		var flat := Vector3(to_enemy.x, 0.0, to_enemy.z)
		var along: float = _dash_flat_direction.dot(flat)
		var lateral: float = (flat - _dash_flat_direction * along).length()
		if lateral > dash_hit_radius:
			continue

		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health):
			continue
		if not (health as Health).is_alive():
			continue

		result.append(enemy)

	return result


func _dash_along(enemy: Node3D) -> float:
	var to_enemy: Vector3 = enemy.global_position - player.global_position
	return _dash_flat_direction.dot(Vector3(to_enemy.x, 0.0, to_enemy.z))


func _apply_dash_damage(enemy: Node3D) -> void:
	var health: Node = enemy.find_child("Health", true, false)
	if health == null or not (health is Health):
		return

	# Quelle ist der SPIELER, nicht dieses Combat-Node: Health.last_damage_source
	# steuert die Richtung der Todes-Animation, und die soll vom Spieler
	# wegzeigen.
	(health as Health).take_damage(dash_damage, player)
	_dash_debug("%.0f Schaden an '%s' (durchgedasht)." % [dash_damage, enemy.name])

	_spawn_dash_damage_number(enemy)
	dash_hit_landed.emit(enemy)

	# Treffer-VFX zeigt in Dash-Richtung: der Effekt soll mit der Bewegung
	# wegspritzen, nicht dem Gegner entgegen.
	if dash_hit_vfx:
		VFX.spawn(dash_hit_vfx, enemy.global_position + Vector3(0.0, 1.0, 0.0), _dash_flat_direction)

	if player.has_method("shake_camera"):
		player.shake_camera(dash_hit_shake_strength)

	if dash_damage_sets_target and player.has_method("set_target"):
		player.set_target(enemy)

	# BEWUSST NICHT _on_hit_landed(): das setzt den Hit-Lock, kappt das
	# Aufwaerts-Momentum und wuerde den laufenden Dash mitten in der Bewegung
	# ausbremsen. Nur der Combo-Zaehler wird uebernommen.
	if dash_damage_counts_combo:
		_combo_count += 1
		_combo_timer = combo_window
		combo_changed.emit(_combo_count)
		if enemy != _last_hit_target:
			_tilt_direction *= -1.0
			_last_hit_target = enemy
		if _combo_count >= 2 and player.has_method("play_combo_tilt"):
			var tilt: float = min(_combo_count * combo_tilt_per_hit, combo_tilt_max) * _tilt_direction
			player.play_combo_tilt(tilt)
		_tilt_reset_timer = combo_tilt_reset_delay

	if dash_knockback_force > 0.0 and enemy is CharacterBody3D:
		if enemy.get("is_heavy") == true:
			_dash_debug("Knockback ignoriert: '%s' ist ein schwerer Gegner." % enemy.name)
		else:
			var push_dir: Vector3 = _dash_flat_direction
			if enemy.has_method("apply_knockback"):
				enemy.apply_knockback(push_dir * dash_knockback_force)
			else:
				enemy.velocity += push_dir * dash_knockback_force


## Zeichnet das Trefferfenster als halbtransparenten Quader in die Welt.
##
## Der Quader entspricht 1:1 dem, was _collect_dash_targets() prueft: Laenge
## = dash_speed * dash_duration (die theoretische Bahn ohne Wandkollision),
## Breite = 2 * dash_hit_radius, Hoehe = up + down, vertikal um
## dash_hit_vertical_offset verschoben.
##
## BoxMesh liegt lokal mit seiner Laengsachse auf +Z, deshalb reicht ein
## reiner Yaw um Y.
func _spawn_dash_debug_volume() -> void:
	if not dash_debug_draw or _dash_flat_direction == Vector3.ZERO or player == null:
		return

	var length: float = maxf(dash_speed * dash_duration, 0.1)
	var height: float = maxf(dash_hit_height_up + dash_hit_height_down, 0.1)

	var box := BoxMesh.new()
	box.size = Vector3(dash_hit_radius * 2.0, height, length)

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = dash_debug_color

	var gizmo := MeshInstance3D.new()
	gizmo.name = "DashHitboxDebug"
	gizmo.mesh = box
	# material_override statt surface_material_override - Vorrangregel.
	gizmo.material_override = mat
	gizmo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var parent: Node = get_tree().current_scene
	if parent == null:
		return
	parent.add_child(gizmo)

	var center: Vector3 = player.global_position \
		+ _dash_flat_direction * (length * 0.5) \
		+ Vector3.UP * (dash_hit_vertical_offset + (dash_hit_height_up - dash_hit_height_down) * 0.5)

	var yaw: float = atan2(_dash_flat_direction.x, _dash_flat_direction.z)
	gizmo.global_transform = Transform3D(Basis.IDENTITY.rotated(Vector3.UP, yaw), center)

	# queue_free direkt als Callable verbinden statt ueber eine mehrzeilige
	# Lambda: kuerzer, und der Timer haelt keine Referenz auf einen Closure,
	# der einen bereits gefreeten Node einfaengt.
	var timer := get_tree().create_timer(maxf(dash_debug_draw_duration, 0.05))
	timer.timeout.connect(gizmo.queue_free)


func _spawn_dash_damage_number(enemy: Node3D) -> void:
	var scene: PackedScene = _resolve_damage_number_scene()
	if scene == null:
		push_warning("CombatBase: Keine damage_number_scene gefunden - Dash-Schadenszahl wird nicht angezeigt.")
		return

	var number: Node = scene.instantiate()
	get_tree().current_scene.add_child(number)
	(number as Node3D).global_position = enemy.global_position + Vector3(0.0, 1.8, 0.0)

	if number.has_method("show_dash_damage"):
		number.show_dash_damage(dash_damage)
	elif number.has_method("show_damage"):
		# Fallback fuer eine aeltere damage_number.gd ohne Dash-Variante:
		# dann eben in Crit-Farbe statt gelb, aber nicht unsichtbar.
		number.show_damage(dash_damage, true)


## Die Szene ist an der PrimaryHitbox bereits im Inspector gesetzt - von dort
## wird sie uebernommen, damit man sie nicht an einer zweiten Stelle pflegen
## muss. Ergebnis wird gecached, der Pfad-Fallback laeuft also hoechstens
## einmal pro Charakter-Instanz.
func _resolve_damage_number_scene() -> PackedScene:
	if dash_damage_number_scene != null:
		return dash_damage_number_scene
	if _cached_damage_number_scene != null:
		return _cached_damage_number_scene

	if primary_hitbox and primary_hitbox.damage_number_scene:
		_cached_damage_number_scene = primary_hitbox.damage_number_scene
	elif secondary_hitbox and secondary_hitbox.damage_number_scene:
		_cached_damage_number_scene = secondary_hitbox.damage_number_scene
	elif ResourceLoader.exists(DAMAGE_NUMBER_FALLBACK_PATH):
		_cached_damage_number_scene = load(DAMAGE_NUMBER_FALLBACK_PATH)

	return _cached_damage_number_scene

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
