extends Node
class_name PartySetup

# An einen leeren Node im Level haengen. Zieht bis zu 4 CharacterData-.tres
# im Inspector in party_members. Bestimmt, welche Charaktere in diesem
# Level als Party zur Verfuegung stehen — Platzhalter, bis der Home-Screen
# mit echter Roster-Auswahl steht (der wird dieselbe PartyManager-API
# nutzen: PartyManager.setup_party(...)).

@export var party_members: Array[CharacterData] = []

func _ready() -> void:
	if party_members.is_empty():
		push_warning("PartySetup: party_members ist leer — HUD zeigt keine Charaktere.")
		return
	PartyManager.setup_party(party_members)
