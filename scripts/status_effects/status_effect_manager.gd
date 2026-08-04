# res://scripts/status_effects/status_effect_manager.gd
extends Node
class_name StatusEffectManager

# ============================================================================
# Generisches Status-Effekt-System
# ============================================================================
# Verwaltet beliebig viele gleichzeitige Effekte auf EINEM Node (Spieler oder
# Gegner). Jeder Effekt hat eine ID (String, z.B. "stun", "acid", "slow"),
# eine Dauer, eine Staerke ("magnitude" — Bedeutung haengt vom Effekt ab, z.B.
# bei "slow" = Anteil der Verlangsamung 0.0-1.0, bei "acid" = Schaden pro
# Tick) und optional ein Tick-Intervall fuer Damage-over-Time-Effekte.
#
# WICHTIG: Dieses Script kennt selbst KEINE Spielregeln (was "acid" genau
# tut, ob "confused" den Gegner danebenschlagen laesst). Das entscheidet der
# Code, der es NUTZT (player_base.gd, enemy_ai.gd) bzw. die Effekt-Dateien
# daneben. Dieser Manager ist reine Datenverwaltung.
#
# ############################################################################
# PHASE 4 — WAS NEU IST
# ############################################################################
#  * get_effect_tick_interval()  — StatusBurn.thermal_shock() muss ausrechnen,
#    wie viele Ticks noch ausstehen. Ohne Zugriff auf das Intervall ging das
#    nur ueber eine im Item hartkodierte Kopie des Werts — und damit ueber
#    eine zweite Wahrheit, die beim naechsten Balancing auseinanderlaeuft.
#  * extend_effect() / extend_all()  — Omas Pfeffermuehle verlaengert ALLE
#    laufenden DoTs um +3 s, das Kaugummi die Saeure um +50 %. apply_effect()
#    taugt dafuer nicht: es nimmt das MAXIMUM aus alt und neu, verlaengert
#    also gar nichts, wenn der laufende Effekt noch lange genug haelt.
#  * clear_all_on_death / Raumwechsel-Cleanup — ein Gegner, der mit
#    laufendem Brand stirbt, hat bisher seine Effekte mit ins Grab genommen;
#    das war unproblematisch. Der SPIELER dagegen behielt Debuffs ueber den
#    Raumwechsel hinweg. clear_all() ist jetzt von aussen erreichbar und
#    wird von RunRestart/RoomInstance benutzt.
#  * DOT_IDS — eine Stelle, an der steht, welche Effekte als
#    "Damage over Time" gelten. Vorher stand diese Liste in enemy_ai.gd und
#    war der Grund, warum "acid" ohne Patch dort ins Leere getickt haette.

signal effect_applied(id: String, duration: float, magnitude: float, source: Node)
signal effect_expired(id: String)
## Wird bei jedem Tick eines Damage-over-Time-Effekts gefeuert. Der NUTZENDE
## Code entscheidet, was der Tick bedeutet (meistens: Health.take_damage).
signal effect_ticked(id: String, magnitude: float, source: Node)

## Alle Effekte, die als Damage over Time gelten. EINE Wahrheit — enemy_ai.gd
## und die Pfeffermuehle lesen beide hier.
const DOT_IDS: PackedStringArray = ["poison", "bleed", "burn", "acid"]

@export var debug_logging: bool = false


## Gemeinsamer Helper statt der duplizierten "get_node_or_null + new() +
## add_child"-Logik, die vorher fast identisch in player_base.gd UND
## enemy_ai.gd stand.
static func get_or_create(owner: Node) -> StatusEffectManager:
	var existing := owner.get_node_or_null("StatusEffectManager")
	if existing:
		return existing
	var manager := StatusEffectManager.new()
	manager.name = "StatusEffectManager"
	owner.add_child(manager)
	return manager


class ActiveEffect:
	var duration_remaining: float = 0.0
	var magnitude: float = 1.0
	var tick_interval: float = 0.0
	var tick_timer: float = 0.0
	var source: Node = null

var _effects: Dictionary = {}  # id (String) -> ActiveEffect


func _debug(msg: String) -> void:
	if debug_logging:
		print("StatusEffectManager DEBUG [%s]: %s" % [get_parent().name if get_parent() else "?", msg])


## Wendet einen Effekt an. Falls der Effekt schon aktiv ist, wird
## AUFGEFRISCHT statt addiert: Dauer und Staerke nehmen jeweils den hoeheren
## der beiden Werte. Ein zweiter Saeuretropfen verlaengert also den
## bestehenden Effekt, statt einen zweiten parallelen Timer zu starten.
func apply_effect(id: String, duration: float, magnitude: float = 1.0, source: Node = null, tick_interval: float = 0.0) -> void:
	if _effects.has(id):
		var existing: ActiveEffect = _effects[id]
		existing.duration_remaining = max(existing.duration_remaining, duration)
		existing.magnitude = max(existing.magnitude, magnitude)
		if tick_interval > 0.0:
			existing.tick_interval = tick_interval
		existing.source = source
		_debug("Effekt '%s' aufgefrischt: duration=%.2f magnitude=%.2f" % [id, existing.duration_remaining, existing.magnitude])
	else:
		var effect := ActiveEffect.new()
		effect.duration_remaining = duration
		effect.magnitude = magnitude
		effect.tick_interval = tick_interval
		effect.tick_timer = tick_interval
		effect.source = source
		_effects[id] = effect
		_debug("Effekt '%s' NEU angewendet: duration=%.2f magnitude=%.2f tick_interval=%.2f" % [id, duration, magnitude, tick_interval])

	effect_applied.emit(id, duration, magnitude, source)


func has_effect(id: String) -> bool:
	return _effects.has(id)


func get_effect_magnitude(id: String) -> float:
	if _effects.has(id):
		return (_effects[id] as ActiveEffect).magnitude
	return 0.0


func get_effect_remaining(id: String) -> float:
	if _effects.has(id):
		return (_effects[id] as ActiveEffect).duration_remaining
	return 0.0


## NEU in Phase 4. Wird von StatusBurn.thermal_shock() gebraucht, um den
## Restschaden auszurechnen.
func get_effect_tick_interval(id: String) -> float:
	if _effects.has(id):
		return (_effects[id] as ActiveEffect).tick_interval
	return 0.0


## Alle aktiven IDs — fuer HUD-Anzeigen und die Pfeffermuehle.
func get_active_ids() -> PackedStringArray:
	var result: PackedStringArray = []
	for id: String in _effects.keys():
		result.append(id)
	return result


## NEU in Phase 4: verlaengert einen LAUFENDEN Effekt additiv.
##
## Unterschied zu apply_effect(): dort gewinnt das Maximum aus alt und neu,
## eine Verlaengerung um 3 s waere bei einem noch 4 s laufenden Effekt also
## wirkungslos. Hier wird echt addiert.
##
## Wirkt bewusst NUR auf bereits aktive Effekte — die Pfeffermuehle soll
## bestehende DoTs strecken, nicht neue anzuenden.
func extend_effect(id: String, extra_seconds: float) -> bool:
	if extra_seconds <= 0.0 or not _effects.has(id):
		return false
	var effect: ActiveEffect = _effects[id]
	effect.duration_remaining += extra_seconds
	_debug("Effekt '%s' verlaengert um %.2f s (jetzt %.2f s)" % [id, extra_seconds, effect.duration_remaining])
	return true


## Verlaengert alle Effekte aus der uebergebenen Liste. Leere Liste = alle
## DoTs (Omas Pfeffermuehle).
## Rueckgabe: Anzahl der tatsaechlich verlaengerten Effekte.
func extend_all(extra_seconds: float, ids: PackedStringArray = []) -> int:
	var targets: PackedStringArray = ids if not ids.is_empty() else DOT_IDS
	var count: int = 0
	for id: String in targets:
		if extend_effect(id, extra_seconds):
			count += 1
	return count


func remove_effect(id: String) -> void:
	if _effects.has(id):
		_effects.erase(id)
		effect_expired.emit(id)
		_debug("Effekt '%s' manuell entfernt" % id)


func clear_all() -> void:
	for id in _effects.keys():
		effect_expired.emit(id)
	_effects.clear()


## true, sobald irgendein DoT laeuft — der Laser-Pointer verteilt nur dann.
func has_any_dot() -> bool:
	for id: String in DOT_IDS:
		if _effects.has(id):
			return true
	return false


## Alle laufenden DoTs als { id: { "magnitude": float, "remaining": float,
## "tick_interval": float } }. Der Laser-Pointer kopiert damit 50 % eines DoTs
## auf Nachbargegner, ohne die interne Klasse nach aussen zu geben.
func snapshot_dots() -> Dictionary:
	var result: Dictionary = {}
	for id: String in DOT_IDS:
		if not _effects.has(id):
			continue
		var effect: ActiveEffect = _effects[id]
		result[id] = {
			"magnitude": effect.magnitude,
			"remaining": effect.duration_remaining,
			"tick_interval": effect.tick_interval,
			"source": effect.source,
		}
	return result


func _process(delta: float) -> void:
	if _effects.is_empty():
		return

	var expired_ids: Array = []
	for id in _effects.keys():
		var effect: ActiveEffect = _effects[id]
		effect.duration_remaining -= delta

		if effect.tick_interval > 0.0:
			effect.tick_timer -= delta
			if effect.tick_timer <= 0.0:
				effect.tick_timer += effect.tick_interval
				effect_ticked.emit(id, effect.magnitude, effect.source)

		if effect.duration_remaining <= 0.0:
			expired_ids.append(id)

	for id in expired_ids:
		_effects.erase(id)
		effect_expired.emit(id)
		_debug("Effekt '%s' abgelaufen" % id)
