extends Marker3D
class_name PlayerSpawnPoint

# In jedem Level EINMAL platzieren, dort wo frueher die feste Player-Node
# direkt in der Szene lag. Ersetzt diese - PartyManager entscheidet zur
# Laufzeit, WELCHER Charakter hier spawnt (abhaengig von der per
# PartySetup/Home-Screen gewaehlten Party).
#
# WICHTIG 1: PartySetup.setup_party() sollte VOR diesem Marker laufen, damit
# beim Spawnen schon eine Party existiert. Falls die Reihenfolge im
# Level-Baum das nicht garantiert, wartet dieses Script notfalls Frames,
# bevor es sich registriert.
#
# WICHTIG 2: Als Parent wird current_scene uebergeben, NICHT get_parent().
# Bei dynamisch generierten Leveln liegt dieser Marker als Kind eines
# RoomInstance-Node, der beim Regenerieren eines neuen Stage-Layouts
# komplett freigegeben wird - das wuerde den Player mit in den Abgrund
# reissen.
#
# WICHTIG 3 (BUGFIX): Es wird NIE die rohe global_transform weitergereicht.
#   a) Der LevelGenerator setzt die Weltposition des Raums ERST NACH
#      add_child(). Waehrend unserer _ready()-Kaskade steht der Raum also
#      noch auf (0,0,0) - ein sofortiges Registrieren wuerde den Spieler
#      im falschen Raum spawnen. Deshalb warten wir bis zum Ende des
#      Frames (process_frame).
#   b) Frueher wurde room_scale auf den RoomRoot angewendet. Dessen
#      Skalierung steckte dann in global_transform.basis und wurde vom
#      PartyManager 1:1 auf den Spieler uebertragen -> der Spieler war
#      2.5x zu gross, wodurch alle Gegner "zu klein" wirkten. Wir geben
#      deshalb grundsaetzlich nur Position + Yaw weiter, nie eine Skalierung.

## Zusaetzlicher Hoehenversatz beim Spawnen, damit der Charakter nicht im
## Boden klemmt und sauber runterfaellt.
@export var spawn_height_offset: float = 0.2

func _ready() -> void:
	# Ein Frame warten, damit der LevelGenerator die Weltposition des
	# Raums gesetzt hat (siehe WICHTIG 3a).
	await get_tree().process_frame

	if not is_inside_tree():
		return

	var guard: int = 0
	while PartyManager.get_party_size() == 0 and guard < 10:
		await get_tree().process_frame
		if not is_inside_tree():
			return
		guard += 1

	if PartyManager.get_party_size() == 0:
		push_error("[PlayerSpawnPoint] Nach 10 Frames existiert immer noch keine Party. Liegt ein PartySetup-Node mit gefuellten party_members im Level?")
		return

	var spawn_transform := _build_clean_transform()
	PartyManager.register_spawn_point(get_tree().current_scene, spawn_transform)
	print("[PlayerSpawnPoint] registriert bei %s (Yaw %.1f Grad)" % [spawn_transform.origin, rad_to_deg(global_rotation.y)])

## Baut eine garantiert skalierungsfreie Transform: nur Position + Yaw.
## Roll/Pitch werden bewusst verworfen - ein CharacterBody3D soll immer
## aufrecht stehen.
func _build_clean_transform() -> Transform3D:
	var basis := Basis.IDENTITY.rotated(Vector3.UP, global_rotation.y)
	var origin: Vector3 = global_position
	origin.y += spawn_height_offset
	return Transform3D(basis, origin)
