# res://scripts/status_effects/silenced.gd
extends StatusEffectBase
class_name StatusSilenced

# ============================================================================
# SILENCED — keine Spezialangriffe, keine Telegraphs.
# ============================================================================
# ABGRENZUNG ZU STUN: ein stummgeschalteter Gegner bewegt sich normal und darf
# auch weiterhin einfach zuschlagen — er kann nur keinen TELEGRAPHIERTEN
# Angriff mehr starten (die grossen, angekuendigten Schlaege). Das macht
# "Altes Modulations-Modem" zu einem Werkzeug gegen Elite-Gegner statt zu
# einem zweiten Stun.
#
# ANBINDUNG: enemy_ai._can_start_attack() prueft in dieser Lieferung
# zusaetzlich auf "silenced". Laeuft bereits ein Telegraph, wird er
# ABGEBROCHEN — sonst waere die Stummschaltung wirkungslos gegen genau den
# Angriff, den man abfangen wollte.

const ID: String = "silenced"

const DEFAULT_DURATION: float = 1.0

## Gedaempftes Blaugrau — "Signal weg".
const TINT_COLOR: Color = Color(0.35, 0.45, 0.62)
const TINT_STRENGTH: float = 0.30


static func apply(target: Node, duration: float = DEFAULT_DURATION, source: Node = null) -> bool:
	if not apply_raw(target, ID, duration, 1.0, source, 0.0):
		return false
	# Stumm-Icon ueber dem Kopf.
	spawn_vfx(VFX_HOLOGRAM_BLUE, chest_position(target, 2.1))
	return true


static func active(target: Node) -> bool:
	return is_active(target, ID)


static func clear(target: Node) -> void:
	remove(target, ID)
