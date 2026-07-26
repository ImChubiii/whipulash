extends Node
class_name PlayerStats

# ============================================================================
# PlayerStats — die EINE Wahrheit ueber Schaden, Tempo, Glueck & Co.
# ============================================================================
#
# WARUM PUSH STATT PULL:
# Der naheliegende Weg waere, dass jeder Verbraucher (player_base.speed,
# Hitbox.damage, CombatBase.dash_damage, Health.max_health) beim Benutzen
# selbst hier nachfragt. Das haette bedeutet, in vier bestehende Skripte
# jeweils mitten in die heisse Schleife einzugreifen — jede kuenftige
# Aenderung an einem dieser Skripte haette das Stat-System wieder brechen
# koennen.
#
# Stattdessen merkt sich diese Komponente beim Anhaengen EINMAL die
# Basiswerte des Charakters und SCHREIBT bei jeder Aenderung die fertig
# gerechneten Werte zurueck in die bestehenden Felder. player_base.gd,
# combat_base.gd und primary_hitbox.gd bleiben dadurch voellig unangetastet
# und rechnen weiter mit "ihrem" speed / damage — nur steht da jetzt der
# modifizierte Wert drin.
#
# WICHTIG: Die Basiswerte werden pro SPIELER-INSTANZ gecached. Der
# PartyManager tauscht die Instanz bei jedem Charakterwechsel komplett aus,
# also bekommt jeder Charakter automatisch seine eigenen Basiswerte
# (Ningning schlaegt weiter anders zu als Winter) und die Item-Boni legen
# sich prozentual obendrauf.
#
# RECHENREGEL pro Stat:  ergebnis = (basis + summe_add) * produkt_mul
# Additive Boni zuerst, dann multiplikative — sonst wuerde die Reihenfolge,
# in der Items aufgesammelt werden, das Ergebnis veraendern.

signal stats_changed

const STAT_MAX_HEALTH: String = "max_health"
const STAT_DAMAGE: String = "damage"
const STAT_MOVE_SPEED: String = "move_speed"
## Multiplikator auf Cooldowns. Kleiner = schneller. Wird intern invertiert
## angeboten (get_attack_speed()), damit Items "+20 % Angriffstempo" sagen
## koennen statt "-16,7 % Cooldown".
const STAT_COOLDOWN: String = "cooldown"
const STAT_LUCK: String = "luck"
const STAT_PICKUP_RANGE: String = "pickup_range"
## Multiplikator auf ankommenden Schaden aus Umgebungs-Hazards (Lava).
const STAT_HAZARD_RESIST: String = "hazard_resist"
## Multiplikator auf ALLEN ankommenden Schaden.
const STAT_ARMOR: String = "armor"

const ALL_STATS: PackedStringArray = [
	STAT_MAX_HEALTH,
	STAT_DAMAGE,
	STAT_MOVE_SPEED,
	STAT_COOLDOWN,
	STAT_LUCK,
	STAT_PICKUP_RANGE,
	STAT_HAZARD_RESIST,
	STAT_ARMOR,
]

## Anzeigenamen fuers HUD. Steht hier und nicht im Panel, damit ein neues
## Stat nur an EINER Stelle nachgetragen werden muss.
const STAT_LABELS: Dictionary = {
	STAT_DAMAGE: "Schaden",
	STAT_MOVE_SPEED: "Tempo",
	STAT_COOLDOWN: "Angriffstempo",
	STAT_LUCK: "Glueck",
	STAT_PICKUP_RANGE: "Magnet",
	STAT_ARMOR: "Ruestung",
	STAT_HAZARD_RESIST: "Hitzeschutz",
}

@export var debug_logging: bool = false

# --- Basiswerte, beim Anhaengen aus der Charakter-Instanz gelesen ---
var _base_move_speed: float = 15.0
var _base_max_health: float = 100.0
var _base_primary_damage: float = 15.0
var _base_secondary_damage: float = 30.0
var _base_dash_damage: float = 12.0
var _base_primary_cooldown: float = 0.4
var _base_secondary_cooldown: float = 3.0
var _base_pickup_range: float = 2.2

# --- Modifikatoren: source_id -> { stat -> { "add": float, "mul": float } } ---
var _modifiers: Dictionary = {}

# --- Temporaere Buffs (laufen selbst ab), z.B. Mamas Kochloeffel ---
var _timed_sources: Dictionary = {}  # source_id -> Restlaufzeit in Sekunden

var _player: CharacterBody3D = null
var _health: Health = null
var _combat: CombatBase = null
var _primary_hitbox: Hitbox = null
var _secondary_hitbox: Hitbox = null

var _cached: Dictionary = {}


func _debug(msg: String) -> void:
	if debug_logging:
		print("[PlayerStats] %s" % msg)


## Haengt die Komponente an einen Spieler und friert dessen Basiswerte ein.
## Wird von ItemManager beim Spawn/Charakterwechsel aufgerufen.
func bind_to_player(player: CharacterBody3D) -> void:
	_player = player
	if _player == null or not is_instance_valid(_player):
		return

	_health = _player.get_node_or_null("Health") as Health
	_combat = _player.get_node_or_null("Combat") as CombatBase
	_primary_hitbox = _player.get_node_or_null("CameraPivot/PrimaryHitbox") as Hitbox
	_secondary_hitbox = _player.get_node_or_null("CameraPivot/SecondaryHitbox") as Hitbox

	if "speed" in _player:
		_base_move_speed = float(_player.get("speed"))
	if _health:
		_base_max_health = _health.max_health
	if _primary_hitbox:
		_base_primary_damage = _primary_hitbox.damage
	if _secondary_hitbox:
		_base_secondary_damage = _secondary_hitbox.damage
	if _combat:
		_base_dash_damage = _combat.dash_damage
		_base_primary_cooldown = _combat.primary_cooldown
		_base_secondary_cooldown = _combat.secondary_cooldown

	_debug("An '%s' gebunden. Basis: speed=%.1f hp=%.0f dmg=%.0f/%.0f" % [
		_player.name, _base_move_speed, _base_max_health,
		_base_primary_damage, _base_secondary_damage
	])

	apply()


# ============================================================================
# Modifikatoren
# ============================================================================
# Jede Quelle (Item-ID, Buff-Name) haelt ihren eigenen Eintrag. Ein zweites
# Exemplar desselben Items ueberschreibt seinen alten Eintrag NICHT, sondern
# muss eine eigene Quellen-ID mitbringen ("rusty_cleaver#2") — sonst
# stapeln sich Duplikate nicht.

func add_modifier(source_id: String, stat: String, add_value: float = 0.0, mul_value: float = 1.0) -> void:
	if not _modifiers.has(source_id):
		_modifiers[source_id] = {}
	var entry: Dictionary = _modifiers[source_id]
	entry[stat] = {"add": add_value, "mul": mul_value}
	_modifiers[source_id] = entry
	apply()


## Zeitlich begrenzter Buff. Laeuft in _process ab und raeumt sich selbst weg.
func add_timed_modifier(source_id: String, stat: String, duration: float, add_value: float = 0.0, mul_value: float = 1.0) -> void:
	add_modifier(source_id, stat, add_value, mul_value)
	_timed_sources[source_id] = maxf(float(_timed_sources.get(source_id, 0.0)), duration)


func remove_source(source_id: String) -> void:
	var changed: bool = _modifiers.erase(source_id)
	_timed_sources.erase(source_id)
	if changed:
		apply()


func has_source(source_id: String) -> bool:
	return _modifiers.has(source_id)


func clear_all() -> void:
	_modifiers.clear()
	_timed_sources.clear()
	apply()


func _process(delta: float) -> void:
	if _timed_sources.is_empty():
		return

	var expired: Array[String] = []
	for source_id: String in _timed_sources.keys():
		var remaining: float = float(_timed_sources[source_id]) - delta
		if remaining <= 0.0:
			expired.append(source_id)
		else:
			_timed_sources[source_id] = remaining

	for source_id: String in expired:
		_timed_sources.erase(source_id)
		_modifiers.erase(source_id)
		_debug("Zeit-Buff '%s' abgelaufen." % source_id)

	if not expired.is_empty():
		apply()


# ============================================================================
# Berechnung
# ============================================================================
func _default_base(stat: String) -> float:
	match stat:
		STAT_MAX_HEALTH:
			return _base_max_health
		STAT_MOVE_SPEED:
			return _base_move_speed
		STAT_PICKUP_RANGE:
			return _base_pickup_range
		STAT_LUCK:
			return 0.0
	# Alles Uebrige sind reine Faktoren und starten bei 1.0.
	return 1.0


func _compute(stat: String) -> float:
	var total_add: float = 0.0
	var total_mul: float = 1.0

	for source_id: String in _modifiers.keys():
		var entry: Dictionary = _modifiers[source_id]
		if not entry.has(stat):
			continue
		var mod: Dictionary = entry[stat]
		total_add += float(mod.get("add", 0.0))
		total_mul *= float(mod.get("mul", 1.0))

	return (_default_base(stat) + total_add) * total_mul


## Fertig gerechneter Wert eines Stats.
func get_stat(stat: String) -> float:
	if _cached.has(stat):
		return float(_cached[stat])
	return _compute(stat)


## Angriffstempo als "je hoeher desto schneller" — der Kehrwert des
## Cooldown-Multiplikators. Nur fuer die Anzeige gedacht.
func get_attack_speed() -> float:
	var cd: float = maxf(get_stat(STAT_COOLDOWN), 0.05)
	return 1.0 / cd


## Neu rechnen UND in die bestehenden Komponenten zurueckschreiben.
func apply() -> void:
	_cached.clear()
	for stat: String in ALL_STATS:
		_cached[stat] = _compute(stat)

	if _player == null or not is_instance_valid(_player):
		stats_changed.emit()
		return

	# STAT_MOVE_SPEED traegt den Basiswert bereits in sich (siehe
	# _default_base) — hier wird also der fertige Absolutwert geschrieben,
	# NICHT noch einmal mit _base_move_speed multipliziert.
	if "speed" in _player:
		_player.set("speed", float(_cached[STAT_MOVE_SPEED]))

	if _health:
		_health.set_max_health(float(_cached[STAT_MAX_HEALTH]), false)
		_health.incoming_damage_multiplier = float(_cached[STAT_ARMOR])

	var damage_mul: float = float(_cached[STAT_DAMAGE])
	if _primary_hitbox:
		_primary_hitbox.damage = _base_primary_damage * damage_mul
	if _secondary_hitbox:
		_secondary_hitbox.damage = _base_secondary_damage * damage_mul

	if _combat:
		_combat.dash_damage = _base_dash_damage * damage_mul
		var cd_mul: float = float(_cached[STAT_COOLDOWN])
		_combat.primary_cooldown = _base_primary_cooldown * cd_mul
		_combat.secondary_cooldown = _base_secondary_cooldown * cd_mul

	stats_changed.emit()


# ============================================================================
# Bequeme Getter fuer HUD und Gameplay
# ============================================================================
func get_move_speed() -> float:
	return get_stat(STAT_MOVE_SPEED)


func get_damage_multiplier() -> float:
	return get_stat(STAT_DAMAGE)


func get_luck() -> float:
	return get_stat(STAT_LUCK)


func get_pickup_range() -> float:
	return get_stat(STAT_PICKUP_RANGE)


func get_hazard_resist() -> float:
	return get_stat(STAT_HAZARD_RESIST)


func get_player() -> CharacterBody3D:
	return _player


## Formatierter Anzeigewert fuers Stats-Panel. Faktoren werden als Prozent
## gezeigt, absolute Werte als Zahl — sonst stuende im HUD "Tempo 1.15"
## neben "Schaden 1.15" und niemand wuesste, was gemeint ist.
func format_stat(stat: String) -> String:
	var value: float = get_stat(stat)
	match stat:
		STAT_MOVE_SPEED:
			return "%.1f" % value
		STAT_MAX_HEALTH:
			return "%.0f" % value
		STAT_PICKUP_RANGE:
			return "%.1f m" % value
		STAT_LUCK:
			return "%+.0f%%" % (value * 100.0)
		STAT_COOLDOWN:
			return "%.0f%%" % (get_attack_speed() * 100.0)
		STAT_ARMOR, STAT_HAZARD_RESIST:
			return "%.0f%%" % ((1.0 - value) * 100.0)
	return "%.0f%%" % (value * 100.0)


## Findet die Komponente am aktuell aktiven Spieler. Bequemer Einstieg fuer
## Code, der nicht selbst mitverfolgt, welche Instanz gerade lebt.
static func find_for(node: Node) -> PlayerStats:
	if node == null:
		return null
	for player: Node in node.get_tree().get_nodes_in_group("player"):
		var stats := player.get_node_or_null("PlayerStats")
		if stats is PlayerStats:
			return stats
	return null
