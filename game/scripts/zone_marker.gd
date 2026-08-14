extends Area3D
class_name ZoneMarker

# Markiert einen benannten Spielbereich fuer die Minimap-Anzeige.
# Node wird automatisch der Gruppe "zone" hinzugefuegt.

@export var zone_name: String = "Lemonade Fields"

func _ready() -> void:
	if not is_in_group("zone"):
		add_to_group("zone")
	monitoring = true
	monitorable = false
