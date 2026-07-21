extends Node
class_name StatusEffectManager

# --- Generisches Status-Effekt-System ---
# Verwaltet beliebig viele gleichzeitige Effekte auf EINEM Node (Player
# oder Gegner). Jeder Effekt hat eine ID (String, z.B. "stun", "poison",
# "slow", "fear"), eine Dauer, eine Stärke ("magnitude" — Bedeutung hängt
# vom Effekt ab, z.B. bei "slow" = Anteil der Verlangsamung 0.0-1.0, bei
# "poison" = Schaden pro Tick) und optional ein Tick-Intervall für
# Damage-over-Time-artige Effekte (Gift tickt alle X Sekunden, Stun/Slow/
# Fear haben meist kein Tick-Intervall, wirken nur über die reine Dauer).
#
# WICHTIG: Dieses Script kennt selbst KEINE Spielregeln (was "poison"
# genau tut, ob "fear" den Gegner fliehen lässt, etc.) — das entscheidet
# der Code, der es NUTZT (player.gd, enemy_ai.gd). Dieser Manager ist nur
# die reine Datenverwaltung: "welche Effekte sind aktiv, wie stark, wie
# lange noch, und wann tickt einer".

signal effect_applied(id: String, duration: float, magnitude: float, source: Node)
signal effect_expired(id: String)
# Wird bei jedem Tick eines Damage-over-Time-Effekts gefeuert (z.B. Gift).
# Der NUTZENDE Code (player.gd/enemy_ai.gd) hört darauf und entscheidet,
# was der Tick bedeutet (meistens: Health.take_damage aufrufen).
signal effect_ticked(id: String, magnitude: float, source: Node)

@export var debug_logging: bool = false

# NEU: Gemeinsamer Helper statt der duplizierten "get_node_or_null +
# new() + add_child"-Logik, die vorher fast identisch in player.gd UND
# enemy_ai.gd stand. Jeder Node, der Status-Effekte braucht, ruft einfach
# StatusEffectManager.get_or_create(self) auf — holt den Manager, falls
# er schon existiert, oder erstellt und hängt ihn automatisch an.
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

# Wendet einen Effekt an. Falls der Effekt schon aktiv ist, wird
# AUFGEFRISCHT statt addiert (Standardverhalten für die meisten Spiele:
# ein zweiter Gift-Tropfen verlängert/verstärkt den bestehenden Gift-
# Effekt, statt einen komplett zweiten parallelen Timer zu starten).
# Dauer und Stärke nehmen dabei jeweils den höheren der beiden Werte.
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

func remove_effect(id: String) -> void:
	if _effects.has(id):
		_effects.erase(id)
		effect_expired.emit(id)
		_debug("Effekt '%s' manuell entfernt" % id)

func clear_all() -> void:
	for id in _effects.keys():
		effect_expired.emit(id)
	_effects.clear()

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
