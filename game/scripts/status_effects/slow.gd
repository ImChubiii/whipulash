# res://scripts/status_effects/slow.gd
extends StatusEffectBase
class_name StatusSlow

# ============================================================================
# SLOW — prozentuale Verlangsamung.
# ============================================================================
# MAGNITUDE-BEDEUTUNG: Anteil, um den das Tempo SINKT. 0.4 = 40 % langsamer.
# enemy_ai.get_effective_move_speed() rechnet bereits
#     move_speed * (1.0 - magnitude)
# — die Bedeutung ist also durch bestehenden Code festgelegt und darf hier
# nicht umgedeutet werden.
#
# STAPELN: StatusEffectManager frischt einen bestehenden Effekt auf und nimmt
# dabei jeweils den HOEHEREN Wert von Dauer und Staerke. Zwei Slow-Quellen
# addieren sich also NICHT auf 80 % — die staerkere gewinnt. Das ist gewollt:
# additives Stapeln haette Gegner bei drei Quellen komplett eingefroren und
# damit stun ueberfluessig gemacht.

const ID: String = "slow"

const DEFAULT_DURATION: float = 1.5
## Standard-Verlangsamung (Kaugummi unter dem Schuh, Saeure-Pfuetzen).
const DEFAULT_AMOUNT: float = 0.25
## Starke Verlangsamung (Gefrierbeutel voll Eis).
const HEAVY_AMOUNT: float = 0.40
const HEAVY_DURATION: float = 2.0

## Kaeltestich-Blau.
const TINT_COLOR: Color = Color(0.42, 0.72, 1.0)
const TINT_STRENGTH: float = 0.28


## amount wird hart auf 0.0-0.95 geklemmt. Ein Wert von 1.0 waere ein
## verkappter Stun ohne dessen Sichtbarkeit — wer das will, nimmt stun.gd.
static func apply(
		target: Node,
		duration: float = DEFAULT_DURATION,
		amount: float = DEFAULT_AMOUNT,
		source: Node = null
) -> bool:
	var clamped: float = clampf(amount, 0.0, 0.95)
	if not apply_raw(target, ID, duration, clamped, source, 0.0):
		return false
	spawn_vfx(VFX_DUST_RING, foot_position(target))
	return true


## Gefrierbeutel voll Eis — starke Variante mit eigenem Blitz.
static func apply_heavy(target: Node, source: Node = null) -> bool:
	if not apply(target, HEAVY_DURATION, HEAVY_AMOUNT, source):
		return false
	spawn_vfx(VFX_HIT_SPARK, chest_position(target, 1.0))
	return true


static func active(target: Node) -> bool:
	return is_active(target, ID)


static func amount_on(target: Node) -> float:
	return magnitude_of(target, ID)


static func clear(target: Node) -> void:
	remove(target, ID)
