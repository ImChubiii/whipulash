extends Node
class_name Health

# --- Signals: andere Nodes (UI, Sound, VFX) koennen darauf reagieren, ---
# --- ohne dass diese Komponente wissen muss, WER zuhoert. ---
signal health_changed(current: float, max: float)
signal died

## NEU: feuert NUR bei tatsaechlich angekommenem Schaden (nach Invuln- und
## Multiplikator-Filter). Items wie "Mamas Kochloeffel" oder ein
## Trefferfeedback-System haengen sich hier dran, statt health_changed
## abzuhoeren — das feuert auch beim Heilen und bei jedem Regen-Tick.
signal damage_taken(amount: float, source: Node3D)

## NEU: Start/Ende der Unverwundbarkeit, z.B. fuer ein Blink-VFX am Modell.
signal invulnerability_changed(active: bool)

@export var max_health: float = 100.0

# --- Regeneration ---
@export var regen_enabled: bool = true
@export var regen_rate: float = 5.0       # HP pro Sekunde, sobald Regen aktiv ist
@export var regen_delay: float = 3.0      # Sekunden Wartezeit nach dem letzten Treffer

# ============================================================================
# UNVERWUNDBARKEIT
# ============================================================================
# Wird ueber set_invulnerable(dauer) gesetzt und laeuft hier selbst ab. Das
# gehoert bewusst in die Health-Komponente und nicht in den Aufrufer: sonst
# muesste JEDE Schadensquelle (Hitbox, Lava, Bombe, Dash) den Zustand
# einzeln pruefen, und die erste vergessene Stelle macht den Effekt wertlos.
#
# _invuln_timer < 0.0 bedeutet "unbegrenzt" (z.B. waehrend einer Cutscene) —
# in dem Fall raeumt nur clear_invulnerable() wieder auf.
var _invuln_timer: float = 0.0
var _invuln_permanent: bool = false

## Globaler Multiplikator auf ANKOMMENDEN Schaden. 1.0 = normal,
## 0.25 = 75 % Reduktion (siehe Item "Saeurefeste Stiefel"). Wird von
## PlayerStats gesetzt, nicht von Hand.
var incoming_damage_multiplier: float = 1.0

var current_health: float
var _time_since_damage: float = 0.0

# Merkt sich, WER/WAS zuletzt Schaden verursacht hat — z.B. fuer
# richtungsabhaengige Todes-Animationen (faellt weg vom Angreifer).
var last_damage_source: Node3D = null


func _ready() -> void:
	current_health = max_health


func _process(delta: float) -> void:
	if _invuln_timer > 0.0:
		_invuln_timer -= delta
		if _invuln_timer <= 0.0:
			_invuln_timer = 0.0
			if not _invuln_permanent:
				invulnerability_changed.emit(false)

	if not regen_enabled or not is_alive():
		return

	_time_since_damage += delta

	if _time_since_damage >= regen_delay and current_health < max_health:
		heal(regen_rate * delta)


## Verlaengert eine laufende Unverwundbarkeit, statt sie zu ueberschreiben:
## zwei Effekte kurz hintereinander sollen sich nicht gegenseitig kuerzen.
func set_invulnerable(duration: float) -> void:
	var was_active: bool = is_invulnerable()
	_invuln_timer = maxf(_invuln_timer, duration)
	if not was_active:
		invulnerability_changed.emit(true)


func set_invulnerable_permanent(enabled: bool) -> void:
	var was_active: bool = is_invulnerable()
	_invuln_permanent = enabled
	if is_invulnerable() != was_active:
		invulnerability_changed.emit(is_invulnerable())


func clear_invulnerable() -> void:
	var was_active: bool = is_invulnerable()
	_invuln_timer = 0.0
	_invuln_permanent = false
	if was_active:
		invulnerability_changed.emit(false)


func is_invulnerable() -> bool:
	return _invuln_permanent or _invuln_timer > 0.0


func take_damage(amount: float, source: Node3D = null) -> void:
	if current_health <= 0.0:
		return  # bereits tot, ignoriere weitere Treffer

	if is_invulnerable():
		return

	var effective: float = amount * maxf(incoming_damage_multiplier, 0.0)
	if effective <= 0.0:
		return

	current_health = max(current_health - effective, 0.0)
	_time_since_damage = 0.0  # Regen-Timer zuruecksetzen bei jedem Treffer
	last_damage_source = source
	health_changed.emit(current_health, max_health)
	damage_taken.emit(effective, source)

	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


## Hebt die Obergrenze an und nimmt den Zuwachs optional gleich als Heilung
## mit. Ohne das zweite Argument steigt nur das Maximum — der Balken wird
## also laenger, aber nicht voller.
func set_max_health(value: float, heal_difference: bool = true) -> void:
	var new_max: float = maxf(value, 1.0)
	var difference: float = new_max - max_health
	max_health = new_max

	if heal_difference and difference > 0.0:
		current_health += difference

	current_health = clampf(current_health, 0.0, max_health)
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return current_health > 0.0


func get_health_percent() -> float:
	if max_health <= 0.0:
		return 0.0
	return clampf(current_health / max_health, 0.0, 1.0)
