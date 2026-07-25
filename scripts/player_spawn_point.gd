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
#
# WICHTIG 2: Als Parent wird current_scene übergeben, NICHT get_parent().
# Bei dynamisch generierten Leveln (Grid-System) liegt dieser Marker als
# Kind eines RoomInstance-Node, der (a) durch LevelGenerator.room_scale
# skaliert sein kann - ein Kind davon würde die Skalierung erben - und
# (b) beim Regenerieren eines neuen Stage-Layouts komplett queue_free()'t
# wird, was den Player mit in den Abgrund reißen würde.

func _ready() -> void:
	print("[PlayerSpawnPoint] _ready() bei %s, parent=%s, party_size=%d" % [global_transform.origin, get_parent(), PartyManager.get_party_size()])
	if PartyManager.get_party_size() == 0:
		print("[PlayerSpawnPoint] Party noch leer, warte einen Frame...")
		await get_tree().process_frame
		print("[PlayerSpawnPoint] nach 1 Frame: party_size=%d" % PartyManager.get_party_size())
	PartyManager.register_spawn_point(get_tree().current_scene, global_transform)
	print("[PlayerSpawnPoint] register_spawn_point() aufgerufen. PartyManager.player=%s" % PartyManager.player)
