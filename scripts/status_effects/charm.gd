# res://scripts/status_effects/charm.gd
extends StatusEffectBase
class_name StatusCharm

# ============================================================================
# CHARM — betroffene Gegner greifen sich gegenseitig an statt den Spieler.
# ============================================================================
# WAS "VERZAUBERT" TECHNISCH HEISST:
# enemy_ai.gd fragt in _current_target() ab, ob "charm" aktiv ist, und
# verfolgt/schaut/greift dann einen anderen lebenden Gegner an statt den
# Spieler (siehe _pick_charm_target() dort). Der Effekt hat keine eigene
# Bewegungs- oder Angriffslogik - er schaltet nur um, WEN die bestehende
# State-Machine als Ziel benutzt.
#
# ABGRENZUNG ZU "confused": confused laesst den Gegner weiter auf den
# Spieler zielen, nur mit Fehlwinkel - er bleibt also gefaehrlich, trifft
# bloss oft daneben. charm entzieht dem Spieler den Gegner komplett: er
# kaempft fuer die Dauer des Effekts gegen sein eigenes Team.
#
# WARUM KEIN DoT/TICK: der Effekt wirkt rein ueber die Zielwahl, es gibt
# nichts, das "tickt". apply_raw() mit tick_interval = 0.0 reicht.

const ID: String = "charm"

const DEFAULT_DURATION: float = 4.0

## Rosa/Magenta - bewusst ein anderer Farbton als "confused" (dessen
## Regenbogen-Rotation um denselben Grundton kreist), damit die beiden
## Effekte auf einen Blick unterscheidbar bleiben.
const TINT_COLOR: Color = Color(1.0, 0.45, 0.75)
const TINT_STRENGTH: float = 0.32


static func apply(target: Node, duration: float = DEFAULT_DURATION, source: Node = null) -> bool:
	if not apply_raw(target, ID, duration, 1.0, source, 0.0):
		return false
	spawn_vfx(VFX_HOLOGRAM_BLUE, chest_position(target, 2.0))
	return true


static func active(target: Node) -> bool:
	return is_active(target, ID)


static func clear(target: Node) -> void:
	remove(target, ID)
