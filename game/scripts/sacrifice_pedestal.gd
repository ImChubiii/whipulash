extends TreasurePedestal
class_name SacrificePedestal

# ============================================================================
# SacrificePedestal — Blueprint Nr. 5 "Blutzoll" (Sacrifice Room). Dieselbe
# Sockel-Optik/Interaktion wie TreasurePedestal, nur dass take() zusaetzlich
# 25% der Max-HP des Spielers kostet - ERST nachdem das Item sicher im
# Inventar gelandet ist (super.take() == true), damit ein fehlgeschlagenes
# take() (z.B. Stapelgrenze erreicht) niemals HP ohne Gegenwert kostet.
# ============================================================================

const SACRIFICE_HP_FRACTION: float = 0.25
## Mindest-HP-Anteil, der nach dem Opfer uebrig bleiben muss - ein Sockel, an
## dem man sich nicht bedienen KANN, waere ein schlechter Trick, kein
## Risk/Reward. Der Blutzoll wird verweigert, wenn er toedlich waere.
const MIN_SURVIVING_FRACTION: float = 0.05


## EIGENE create(): GDScript-Static-Methoden sind NICHT virtuell - ein Aufruf
## von SacrificePedestal.create() wuerde sonst die geerbte Implementierung
## von TreasurePedestal.create() ausfuehren, die textuell TreasurePedestal.
## new() aufruft, also trotzdem einen normalen Sockel erzeugen wuerde.
static func create(data: ItemData) -> SacrificePedestal:
	var pedestal := SacrificePedestal.new()
	pedestal.item_data = data
	pedestal.name = "SacrificePedestal_%s" % (data.id if data else "empty")
	return pedestal


func take() -> bool:
	if is_taken() or item_data == null:
		return false

	var player: Node3D = _find_player()
	if player == null:
		return false
	var health: Health = player.get_node_or_null("Health") as Health
	if health == null:
		return false

	var cost: float = health.max_health * SACRIFICE_HP_FRACTION
	if health.current_health - cost < health.max_health * MIN_SURVIVING_FRACTION:
		return false

	if not super.take():
		return false

	health.take_damage(cost, self)
	return true
