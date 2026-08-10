# res://scripts/status_effects/shield.gd
extends StatusEffectBase
class_name StatusShield

# ============================================================================
# SHIELD — neuer Status-Effekt: Schild-Drohne verpasst bis zu drei Gegnern
# einen Schild (siehe scripts/enemies/shield_drone.gd).
# ============================================================================
# Reine Datenhaltung laeuft wie bei jedem anderen Effekt ueber
# StatusEffectManager. Die eigentliche Wirkung (+25 % Maximal-HP, groesseres
# Modell, blau schwankende Aura) ist NICHT hier, sondern in
# enemy_ai.gd::_on_status_effect_applied()/_on_status_effect_expired() bzw.
# custom_enemy_base.gd - genau wie "stun" seine Bewegungssperre nicht hier
# implementiert, sondern in den Bewegungs-Funktionen der Ziele selbst (siehe
# Kopfkommentar von status_effect_base.gd).
#
# KURZE STANDARDDAUER + REFRESH: die Schild-Drohne ruft apply() alle
# BEAM_TICK_INTERVAL Sekunden erneut auf, solange ihr Strahl auf das Ziel
# zeigt (identisches Prinzip wie der Stim-Beacon, siehe item_behaviours.gd).
# Bricht die Drohne die Verbindung ab (Reichweite verloren, Drohne selbst
# tot), laeuft der Schild von selbst binnen kurzer Zeit aus - kein manuelles
# "Schild entfernen" noetig.

const ID: String = "shield"

const DEFAULT_DURATION: float = 1.0

## Blau-Cyan, deutlich von allen Debuff-Farben (rot/gruen/gelb) unterschieden.
const TINT_COLOR: Color = Color(0.3, 0.65, 1.0)
const TINT_STRENGTH: float = 0.3

const MAX_HEALTH_BONUS_FACTOR: float = 0.25
const VISUAL_SCALE_BONUS: float = 0.15


static func apply(target: Node, duration: float = DEFAULT_DURATION, source: Node = null) -> bool:
	return apply_raw(target, ID, duration, 1.0, source, 0.0)


static func active(target: Node) -> bool:
	return is_active(target, ID)


static func clear(target: Node) -> void:
	remove(target, ID)
