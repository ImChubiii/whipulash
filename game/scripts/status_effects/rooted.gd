# res://scripts/status_effects/rooted.gd
extends StatusEffectBase
class_name StatusRooted

# ============================================================================
# ROOTED — festgenagelt. Bewegung gesperrt, Angriffe weiterhin erlaubt.
# ============================================================================
# ABGRENZUNG ZU STUN: rooted sperrt NUR die Fortbewegung. Ein festgenagelter
# Gegner darf sich weiter drehen, telegraphen und zuschlagen — er kommt bloss
# nicht von der Stelle. Das ist der Unterschied, der "Rostiger Dachnagel"
# taktisch macht statt einfach nur zu einem schwaecheren Stun.
#
# ANBINDUNG: enemy_ai.is_movement_locked() fragt "rooted" bereits ab; ueber
# get_effective_move_speed() faellt das Tempo damit auf 0. Es ist also KEINE
# Aenderung an der Bewegungslogik noetig, nur an der Wirkungsdauer hier.

const ID: String = "rooted"

const DEFAULT_DURATION: float = 1.5

## Farbton, in dem StatusEffectVisuals das Modell einfaerbt (LEMONADE_GREEN).
const TINT_COLOR: Color = Color(0.62, 0.92, 0.28)
const TINT_STRENGTH: float = 0.30

## Wie viele Staubringe beim Auftragen am Fuss erscheinen.
const DUST_RING_COUNT: int = 2
const DUST_RING_SPREAD: float = 0.45


## Nagelt ein Ziel fest.
##
## Rueckgabe: true, wenn der Effekt angekommen ist — Aufrufer haengen daran
## ihre eigenen VFX (z.B. HIT_SPARK beim Dachnagel).
static func apply(target: Node, duration: float = DEFAULT_DURATION, source: Node = null) -> bool:
	if not apply_raw(target, ID, duration, 1.0, source, 0.0):
		return false
	_play_vfx(target)
	return true


static func active(target: Node) -> bool:
	return is_active(target, ID)


static func clear(target: Node) -> void:
	remove(target, ID)


## DUST_RING am Fuss — mehrfach leicht versetzt, damit der Ring nicht wie ein
## sauberer Kreis, sondern wie aufgewirbelter Dreck wirkt.
static func _play_vfx(target: Node) -> void:
	var base: Vector3 = foot_position(target)
	for i: int in range(DUST_RING_COUNT):
		var offset := Vector3(
			randf_range(-DUST_RING_SPREAD, DUST_RING_SPREAD),
			float(i) * 0.12,
			randf_range(-DUST_RING_SPREAD, DUST_RING_SPREAD)
		)
		spawn_vfx(VFX_DUST_RING, base + offset)
