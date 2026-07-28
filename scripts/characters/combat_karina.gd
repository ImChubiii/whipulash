
extends CombatBase
class_name CombatKarina

# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind weg - Q/E loesen jetzt immer das
# aktive Item im jeweiligen Slot aus, siehe combat_base.gd.
func _init() -> void:
	primary_cooldown = 0.4
	secondary_cooldown = 3.0
	utility_cooldown = 0.8


