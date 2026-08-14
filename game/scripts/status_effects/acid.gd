# res://scripts/status_effects/acid.gd
extends StatusEffectBase
class_name StatusAcid

# ============================================================================
# ACID — Saeure-DoT aus Limonade, Pfuetzen und dem Handstaubsauger.
# ============================================================================
# EIGENER EFFEKT STATT "poison": Saeure und Gift ticken zwar beide Schaden,
# haben aber unterschiedliche Synergien. Der Ueberkochte Milchreis macht
# ausdruecklich gegen SAEURE immun, nicht gegen Gift; das Kaugummi verlaengert
# nur die Saeuredauer. Mit einer gemeinsamen ID waeren beide Regeln nicht
# formulierbar.
#
# ANBINDUNG: "acid" muss in enemy_ai.DOT_EFFECT_IDS stehen, sonst tickt der
# Effekt ins Leere (genau der Fehler, den "bleed" und "burn" frueher hatten).
# Die gepatchte enemy_ai.gd in dieser Lieferung enthaelt die ID.

const ID: String = "acid"

const DEFAULT_DURATION: float = 3.0
const DEFAULT_TICK_INTERVAL: float = 0.5
const DEFAULT_DAMAGE_PER_TICK: float = 4.0

## Saeure-Gruen.
const TINT_COLOR: Color = Color(0.55, 0.95, 0.25)
const TINT_STRENGTH: float = 0.35

## Kaugummi unter dem Schuh: verlaengert eine laufende Saeure um diesen
## Anteil ihrer RESTdauer.
const GUM_EXTENSION_FACTOR: float = 0.50

## Saeure legt die Ruestung bloss statt viel eigenen Schaden zu machen:
## waehrend sie aktiv ist, nimmt das Ziel von JEDER Quelle 20% mehr Schaden.
## Wird in Health.take_damage() gelesen (siehe dort) statt hier selbst
## angewendet, weil Health die einzige Stelle ist, durch die wirklich JEDER
## Treffer laeuft.
const VULNERABILITY_MULTIPLIER: float = 1.2


static func apply(
		target: Node,
		duration: float = DEFAULT_DURATION,
		damage_per_tick: float = DEFAULT_DAMAGE_PER_TICK,
		source: Node = null,
		tick_interval: float = DEFAULT_TICK_INTERVAL
) -> bool:
	if not apply_raw(target, ID, duration, damage_per_tick, source, tick_interval):
		return false
	spawn_vfx(VFX_CORROSION, foot_position(target))
	return true


static func active(target: Node) -> bool:
	return is_active(target, ID)


static func clear(target: Node) -> void:
	remove(target, ID)


## Kaugummi-Synergie: +50 % auf die Restdauer einer laufenden Saeure.
##
## Bewusst auf die RESTdauer und nicht auf die Ausgangsdauer: sonst waere ein
## fast abgelaufener Effekt genauso viel wert wie ein frischer, und das Item
## haette am staerksten gewirkt, wenn es am wenigsten noetig war.
static func extend_for_gum(target: Node) -> bool:
	var manager: StatusEffectManager = manager_of(target)
	if manager == null or not manager.has_effect(ID):
		return false
	var left: float = manager.get_effect_remaining(ID)
	manager.extend_effect(ID, left * GUM_EXTENSION_FACTOR)
	spawn_vfx(VFX_OIL_BUBBLES, foot_position(target))
	return true
