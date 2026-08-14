
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


const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")
const SLASH_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_slash_ningning.tscn")
const FIRE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_fire_ningning.tscn")

func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	
	if primary_hitbox:
		primary_hitbox.impact_vfx = HIT_VFX_SCENE
		primary_hitbox.swing_vfx = SLASH_VFX_SCENE
		var p_vis = primary_hitbox.get_node_or_null("Visual")
		if p_vis:
			p_vis.queue_free()
			
	if secondary_hitbox:
		secondary_hitbox.hit_landed.connect(_on_haymaker_hit)
		secondary_hitbox.impact_vfx = HIT_VFX_SCENE
		secondary_hitbox.swing_vfx = FIRE_VFX_SCENE
		var s_vis = secondary_hitbox.get_node_or_null("Visual")
		if s_vis:
			s_vis.queue_free()


func _on_haymaker_hit(_target: Node) -> void:
	# War 0.5 - Rueckmeldung "Screenshake bei Attacks generell zu stark", gesenkt.
	Juice.impact(0.3, Juice.DURATION_HEAVY)


## Windup VOR der Hitbox-Aktivierung (Telegraphing) - der einzige Unterschied
## zum Standardverhalten aus CombatBase._perform_secondary(), das die Hitbox
## sofort aktiviert. Der Ghost-Trail-Burst aus _do_secondary() startet
## trotzdem schon beim Tastendruck (combat_base.gd steuert das, nicht hier),
## damit man den Windup optisch schon "einleitet" statt tot dazustehen.
func _perform_secondary() -> void:
	if secondary_hitbox:
		secondary_hitbox.activate()
		await get_tree().create_timer(0.3).timeout
		secondary_hitbox.deactivate()
