extends Node
class_name PartySetup

# An einen leeren Node im Level haengen. Zieht die 4 AbilitySet-.tres
# im Inspector in party_sets. Muss VOR dem HUD-Refresh laufen —
# das HUD wartet einen Frame, daher passt die Reihenfolge.

@export var party_sets: Array[AbilitySet] = []

func _ready() -> void:
	if party_sets.is_empty():
		push_warning("PartySetup: party_sets ist leer — HUD zeigt keine Charaktere.")
		return
	PartyManager.setup_party(party_sets)
