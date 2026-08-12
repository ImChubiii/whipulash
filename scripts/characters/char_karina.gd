extends PlayerBase
class_name CharKarina

# Karina: TODO — char-spezifische Bewegungs-Overrides hier einbauen.

func _ready() -> void:
	super._ready()
	_grant_passive_lifesteal()


## Feste, unsichtbare Passive (siehe item_catalog.gd::
## build_karina_passive_lifesteal() / item_behaviours.gd::
## try_karina_lifesteal()) - wird bei JEDEM Spawnen erneut versucht (auch
## nach einem Charakterwechsel weg und wieder zurueck zu Karina im selben
## Run). add_item()s max_stacks=1-Pruefung verhindert doppelte Kopien.
## silent=true: kein "Item gefunden"-Popup, das Item ist absichtlich
## unsichtbar.
func _grant_passive_lifesteal() -> void:
	var items: Node = get_node_or_null("/root/Items")
	if items == null:
		return
	items.add_item(ItemCatalog.build_karina_passive_lifesteal(), true)
