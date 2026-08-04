# res://scripts/status_effects/confused.gd
extends StatusEffectBase
class_name StatusConfused

# ============================================================================
# CONFUSED — der Gegner schlaegt in die falsche Richtung.
# ============================================================================
# WAS "VERWIRRT" TECHNISCH HEISST:
# enemy_ai.gd bekommt in dieser Lieferung eine zusaetzliche Abfrage in
# _face_player(): ist "confused" aktiv, wird die Ziel-Yaw um einen zufaelligen
# Winkel verdreht. Der Gegner laeuft und schlaegt damit weiterhin voll —
# nur eben daneben. Das ist deutlich lesbarer als ein Gegner, der einfach
# stehen bleibt, und unterscheidet sich klar von stun.
#
# WARUM DER WINKEL IM EFFEKT UND NICHT IN DER KI STEHT:
# Damit "wie stark verwirrt" ein Balancing-Wert bleibt. Der Walkman
# desorientiert deutlich heftiger als der Disco-Kugel-Anhaenger.

const ID: String = "confused"

const DEFAULT_DURATION: float = 2.0
## Walkman (kaputt): 4 s statt 2 s.
const HEAVY_DURATION: float = 4.0

## Maximale Winkelabweichung in Grad. magnitude traegt diesen Wert, damit
## enemy_ai ihn direkt auslesen kann.
const DEFAULT_MAX_ANGLE_DEG: float = 75.0
const HEAVY_MAX_ANGLE_DEG: float = 140.0

## HOLOGRAM_RAINBOW-Ersatz: kraeftiges Magenta, das StatusEffectVisuals
## ueber die Zeit durch den Farbkreis dreht (siehe RAINBOW_SPEED).
const TINT_COLOR: Color = Color(0.95, 0.35, 0.95)
const TINT_STRENGTH: float = 0.35
## Umdrehungen pro Sekunde im HSV-Farbkreis.
const RAINBOW_SPEED: float = 0.9

## Design-Dokument: verwirrte Gegner nehmen +25 % Schaden durch stun.
const STUN_DAMAGE_BONUS: float = 0.25


static func apply(
		target: Node,
		duration: float = DEFAULT_DURATION,
		max_angle_deg: float = DEFAULT_MAX_ANGLE_DEG,
		source: Node = null
) -> bool:
	if not apply_raw(target, ID, duration, max_angle_deg, source, 0.0):
		return false
	spawn_vfx(VFX_HOLOGRAM_BLUE, chest_position(target, 2.0))
	return true


## Walkman (kaputt) — komplette Orientierungslosigkeit.
static func apply_heavy(target: Node, source: Node = null) -> bool:
	return apply(target, HEAVY_DURATION, HEAVY_MAX_ANGLE_DEG, source)


static func active(target: Node) -> bool:
	return is_active(target, ID)


## Maximale Fehlausrichtung in RADIANT — so, wie enemy_ai sie braucht.
static func max_angle_rad(target: Node) -> float:
	return deg_to_rad(magnitude_of(target, ID))


static func clear(target: Node) -> void:
	remove(target, ID)
