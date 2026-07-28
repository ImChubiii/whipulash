
extends CombatBase
class_name CombatNingning

# Ningning: schnelle Combo-Klingen, kurze Cooldowns.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: die "Zest Burst"/"Sour Storm"-Platzhalter (ability_q_cooldown/
# ability_e_cooldown + _perform_ability_q()/_perform_ability_e()) sind weg -
# Q/E loesen jetzt immer das aktive Item im jeweiligen Slot aus, siehe
# combat_base.gd. Primary/Secondary/Utility nutzen weiterhin das
# Standardverhalten aus CombatBase (Hitbox-Angriff / Dash) — hier kannst du
# das bei Bedarf ueberschreiben (_perform_primary, _perform_secondary,
# _perform_utility).
func _init() -> void:
	primary_cooldown = 0.4
	secondary_cooldown = 3.0
	utility_cooldown = 0.8
