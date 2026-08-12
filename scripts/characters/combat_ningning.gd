
extends CombatBase
class_name CombatNingning

# Ningning: Brawler/Nahkampf mit starkem Burst-Potenzial.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: die "Zest Burst"/"Sour Storm"-Platzhalter (ability_q_cooldown/
# ability_e_cooldown + _perform_ability_q()/_perform_ability_e()) sind weg -
# Q/E loesen jetzt immer das aktive Item im jeweiligen Slot aus, siehe
# combat_base.gd.
#
# Primary "Quick Jab": sehr schneller, schwacher Schlag mit minimalem
# Cooldown, um Gegner im Stunlock zu halten - das Standardverhalten aus
# CombatBase._perform_primary() (kurzer Hitbox-Puls) passt dafuer schon
# unveraendert, nur der Cooldown und PrimaryHitbox.damage (siehe
# char_ningning.tscn) werden angepasst.
#
# Secondary "Heavy Haymaker": wuchtiger, aufgeladener Schlag mit Windup-
# Telegraphing und Knockback - dafuer _perform_secondary() unten
# ueberschrieben. SecondaryHitbox.damage/knockback_force sitzen weiterhin im
# Inspector (char_ningning.tscn), nicht hier - gleiche Konvention wie beim
# Primary.
func _init() -> void:
	primary_cooldown = 0.18
	secondary_cooldown = 3.0
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	# Zusaetzlich zum automatischen Kamera-Shake aus combat_base.gd::
	# _on_hit_landed() (der fuer JEDEN Treffer gleich stark ausfaellt) - ein
	# kurzer Hit-Stop + kraeftigerer Shake NUR fuer den Haymaker, damit sich
	# der wuchtige Finisher spuerbar staerker anfuehlt als der schnelle Jab
	# (Rueckmeldung "sieht schwach aus").
	if secondary_hitbox:
		secondary_hitbox.hit_landed.connect(_on_haymaker_hit)


func _on_haymaker_hit(_target: Node) -> void:
	Juice.impact(0.5, Juice.DURATION_HEAVY)


## Windup VOR der Hitbox-Aktivierung (Telegraphing) - der einzige Unterschied
## zum Standardverhalten aus CombatBase._perform_secondary(), das die Hitbox
## sofort aktiviert. Der Ghost-Trail-Burst aus _do_secondary() startet
## trotzdem schon beim Tastendruck (combat_base.gd steuert das, nicht hier),
## damit man den Windup optisch schon "einleitet" statt tot dazustehen.
func _perform_secondary() -> void:
	await get_tree().create_timer(0.35).timeout
	if secondary_hitbox:
		secondary_hitbox.activate()
		await get_tree().create_timer(0.3).timeout
		secondary_hitbox.deactivate()
