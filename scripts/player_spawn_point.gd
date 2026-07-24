extends Marker3D
class_name PlayerSpawnPoint

# In jedem Level EINMAL platzieren, dort wo frueher die feste Player-Node
# direkt in der Szene lag. Ersetzt diese — PartyManager entscheidet zur
# Laufzeit, WELCHER Charakter hier spawnt (abhaengig von der per
# PartySetup/Home-Screen gewaehlten Party).
#
# WICHTIG: PartySetup.setup_party() sollte VOR diesem Marker laufen, damit
# beim Spawnen schon eine Party existiert. Falls die Reihenfolge im
# Level-Baum das nicht garantiert, wartet dieses Script notfalls einen
# Frame, bevor es sich registriert.

func _ready() -> void:
	if PartyManager.get_party_size() == 0:
		await get_tree().process_frame
	PartyManager.register_spawn_point(get_parent(), global_transform)
