# res://scripts/status_effects/burn.gd
extends StatusEffectBase
class_name StatusBurn

# ============================================================================
# BURN — Feuer-DoT. Der Gegner leuchtet rot/orange, solange er brennt.
# ============================================================================
# ANBINDUNG: enemy_ai.DOT_EFFECT_IDS enthaelt "burn" bereits, der Schaden
# kommt also an. Neu ist hier die dauerhafte Einfaerbung ueber
# StatusEffectVisuals sowie zwei Sonderregeln, die im Design-Dokument als
# Synergien stehen:
#
#   * detonate()  — Kaputter Toaster: ein brennender Gegner nimmt beim
#                   Funken-Burst SOFORT einen doppelten Tick zusaetzlich.
#   * thermal_shock() — Gefrierbeutel voll Eis: Brand wird abgebrochen und
#                   der GESAMTE Restschaden auf einmal ausgeteilt.
#
# Beide sind bewusst hier und nicht in item_behaviours.gd: sie beschreiben,
# wie sich FEUER verhaelt, nicht was ein bestimmtes Item tut. Kaeme ein
# zweites Item mit "loescht Feuer", muesste es dieselbe Regel benutzen.

const ID: String = "burn"

const DEFAULT_DURATION: float = 3.0
const DEFAULT_TICK_INTERVAL: float = 0.75
const DEFAULT_DAMAGE_PER_TICK: float = 6.0

## FLASH_RED / Orange-Glut.
const TINT_COLOR: Color = Color(1.0, 0.38, 0.10)
const TINT_STRENGTH: float = 0.45

## Faktor auf den Tick-Schaden beim Funken-Burst des Kaputten Toasters.
const DETONATE_MULTIPLIER: float = 2.0


static func apply(
		target: Node,
		duration: float = DEFAULT_DURATION,
		damage_per_tick: float = DEFAULT_DAMAGE_PER_TICK,
		source: Node = null,
		tick_interval: float = DEFAULT_TICK_INTERVAL
) -> bool:
	if not apply_raw(target, ID, duration, damage_per_tick, source, tick_interval):
		return false
	spawn_vfx(VFX_SPARK_YELLOW, chest_position(target, 0.9))
	return true


static func active(target: Node) -> bool:
	return is_active(target, ID)


static func clear(target: Node) -> void:
	remove(target, ID)


## Kaputter Toaster: Funken zuenden einen brennenden Gegner kurz durch.
## Kein neuer Effekt, sondern ein sofortiger Zusatz-Tick — der laufende Brand
## bleibt unveraendert weiter ticken.
static func detonate(target: Node, source: Node = null) -> bool:
	if not active(target):
		return false
	var health: Health = health_of(target)
	if health == null or not health.is_alive():
		return false

	var tick_damage: float = magnitude_of(target, ID)
	health.take_damage(tick_damage * DETONATE_MULTIPLIER, source)
	spawn_vfx(VFX_SPARK_YELLOW, chest_position(target, 1.0))
	spawn_vfx(VFX_HIT_SPARK, chest_position(target, 1.0))
	return true


## Gefrierbeutel voll Eis: Thermoschock.
##
## Der komplette VERBLEIBENDE Brandschaden wird auf einen Schlag ausgeteilt
## und der Brand geloescht. Wie viel das ist, ergibt sich aus Restdauer und
## Tick-Intervall — deshalb steht die Rechnung hier und nicht im Item.
static func thermal_shock(target: Node, source: Node = null) -> float:
	if not active(target):
		return 0.0

	var manager: StatusEffectManager = manager_of(target)
	if manager == null:
		return 0.0

	var tick_damage: float = manager.get_effect_magnitude(ID)
	var time_left: float = manager.get_effect_remaining(ID)
	var interval: float = maxf(manager.get_effect_tick_interval(ID), 0.01)
	# ceil statt floor: der Tick, der gerade laeuft, zaehlt mit. Sonst
	# verschenkt ein Thermoschock kurz vor Ablauf den letzten Treffer.
	var remaining_ticks: float = ceilf(time_left / interval)
	var burst: float = tick_damage * remaining_ticks

	clear(target)

	var health: Health = health_of(target)
	if health != null and health.is_alive() and burst > 0.0:
		health.take_damage(burst, source)

	spawn_vfx(VFX_HIT_SPARK, chest_position(target, 1.0))
	return burst
