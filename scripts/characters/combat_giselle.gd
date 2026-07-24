extends CombatBase
class_name CombatGiselle

# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
func _init() -> void:
	primary_cooldown = 0.4
	secondary_cooldown = 3.0
	utility_cooldown = 0.8
	ability_q_cooldown = 6.0
	ability_e_cooldown = 10.0

# TODO: Giselles einzigartige Q-Fähigkeit.
func _perform_ability_q() -> void:
	if player and player.has_method("shake_camera"):
		player.shake_camera(0.35)
	print("Giselle: Q-Ability!")

# TODO: Giselles einzigartige E-Fähigkeit.
func _perform_ability_e() -> void:
	if player and player.has_method("shake_camera"):
		player.shake_camera(0.5)
	print("Giselle: E-Ability!")
