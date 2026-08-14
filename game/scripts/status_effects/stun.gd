# res://scripts/status_effects/stun.gd
extends StatusEffectBase
class_name StatusStun

# ============================================================================
# STUN — vollstaendige Handlungsunfaehigkeit.
# ============================================================================
# Sperrt Bewegung UND Angriff. Der harte Fall; alles Schwaechere gehoert in
# rooted (nur Bewegung) oder silenced (nur Spezialangriffe).
#
# ANBINDUNG: enemy_ai.is_movement_locked() kennt "stun" bereits. Neu ist die
# Angriffssperre in _can_start_attack() — vorher durfte ein betaeubter Gegner
# aus dem Stand heraus weiter zuschlagen, was den Effekt praktisch wertlos
# machte.

const ID: String = "stun"

const DEFAULT_DURATION: float = 2.0

## FLASH_WHITE — ausgeknockt.
const TINT_COLOR: Color = Color(1.0, 1.0, 0.85)
const TINT_STRENGTH: float = 0.40

## Design-Dokument, Megafon: dreifacher Schaden gegen bereits betaeubte
## Gegner. Modem: kritischer Zusatzschaden gegen stunned.
const MEGAPHONE_DAMAGE_MULTIPLIER: float = 3.0
const MODEM_CRIT_MULTIPLIER: float = 1.75


static func apply(target: Node, duration: float = DEFAULT_DURATION, source: Node = null) -> bool:
	# apply_stun() existiert auf enemy_ai UND player_base und macht dort noch
	# eigene Dinge (laufenden Angriff abbrechen). Deshalb bevorzugt.
	if target != null and is_instance_valid(target) and target.has_method("apply_stun"):
		target.call("apply_stun", duration)
		spawn_vfx(VFX_FLASH_WHITE, chest_position(target, 1.6))
		return true

	if not apply_raw(target, ID, duration, 1.0, source, 0.0):
		return false
	spawn_vfx(VFX_FLASH_WHITE, chest_position(target, 1.6))
	return true


static func active(target: Node) -> bool:
	return is_active(target, ID)


static func clear(target: Node) -> void:
	remove(target, ID)


## Schadensfaktor gegen ein Ziel, das gerade betaeubt ist.
## Beruecksichtigt die confused-Synergie (+25 % laut Design-Dokument).
static func damage_multiplier_against(target: Node, base_multiplier: float) -> float:
	if not active(target):
		return 1.0
	var result: float = base_multiplier
	if StatusConfused.active(target):
		result *= (1.0 + StatusConfused.STUN_DAMAGE_BONUS)
	return result
