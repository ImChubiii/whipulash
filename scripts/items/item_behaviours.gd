# res://scripts/items/item_behaviours.gd
extends Node
class_name ItemBehaviours

# ============================================================================
# ItemBehaviours — hier steht, was die Items TATSAECHLICH tun.
# ============================================================================
# Wird von item_manager.gd als Kind erzeugt und haengt sich an dessen Signale.
# Jeder Effekt liegt in einem eigenen, klar benannten Block. Items, die NUR
# Stat-Boni geben (Magnetischer Kompass, Saeurefeste Stiefel, Proteinshake-
# Schadensteil), tauchen hier gar nicht auf — die erledigt
# ItemData.stat_modifiers.
#
# ALLE Zahlen liegen als Konstanten oben im jeweiligen Block, nicht mitten im
# Code. Balancing soll man an einer Stelle drehen koennen, ohne die Logik zu
# lesen.
#
# ############################################################################
# EVENT-HOOKS — WO WAS EINGEHAENGT IST
# ############################################################################
#   player_hit_enemy   -> _on_player_hit_enemy()      (Items.player_hit_enemy)
#   enemy_died         -> im selben Aufruf: Health.is_alive() ist dann false
#   take_damage        -> _on_player_damaged()        (Health.damage_taken)
#   room_cleared       -> _on_room_cleared()          (Items.room_cleared)
#   step_tick          -> _physics_process()          (Bewegungs-Spuren)
#   dash_started       -> _poll_dash()                (Flanke aus combat.is_dashing())
#
# WARUM dash_started GEPOLLT UND NICHT ALS SIGNAL:
# combat_base.gd hat kein Dash-Signal, nur is_dashing(). Ein Signal dort
# einzubauen haette alle vier Combat-Unterklassen angefasst. Eine
# Flankenerkennung im ohnehin laufenden _physics_process kostet nichts und
# laesst die Charakter-Skripte unberuehrt.
#
# ############################################################################
# WIE KILLS ERKANNT WERDEN — und wo die Grenze liegt
# ############################################################################
# Hitbox.take_damage laeuft VOR hit_landed. Wenn player_hit_enemy hier
# ankommt, ist der Gegner also schon tot, falls der Schlag toedlich war — ein
# Blick auf Health.is_alive() reicht als Kill-Erkennung.
#
# NICHT erfasst werden dadurch Kills durch Blutung, Brand oder
# Umgebungsschaden. Das ist bewusst so: die Alternative waere, sich an das
# died-Signal JEDES Gegners zu haengen und dabei den Verursacher zu
# rekonstruieren. Der Aufwand steht in keinem Verhaeltnis zu "der
# Heiligenschein heilt gelegentlich nicht".
#
# ############################################################################
# WARUM MANCHE EFFEKTE UEBER Health.damage_taken LAUFEN
# ############################################################################
# Health.take_damage kann von aussen nicht abgebrochen werden. Effekte, die
# einen Treffer "verhindern" sollen (Handball-Polster, Milchreis-Schild),
# haengen sich deshalb an das damage_taken-Signal und machen den Schaden
# NACHTRAEGLICH rueckgaengig. Das ist kein Trick, sondern die einzige
# Reihenfolge, die funktioniert:
#
#     current_health -= schaden
#     health_changed.emit()
#     damage_taken.emit()      <- wir sind hier
#     if current_health <= 0: died.emit()
#
# Der Todes-Check kommt NACH unserem Signal. Wer hier current_health wieder
# auf 1 setzt, verhindert died.emit() vollstaendig — genau das braucht das
# Handball-Polster.

# --- VFX-Szenen -------------------------------------------------------------
# preload statt load: fehlt eine Szene, faellt das beim Projektstart auf und
# nicht erst, wenn zufaellig das passende Item droppt.
const HIT_SPARK_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")
const DUST_RING_SCENE: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const SPARK_YELLOW_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const HOLOGRAM_BLUE_SCENE: PackedScene = preload("res://scenes/vfx/hologram_blue.tscn")
const FLASH_WHITE_SCENE: PackedScene = preload("res://scenes/vfx/flash_white.tscn")
const CORROSION_SCENE: PackedScene = preload("res://scenes/vfx/corrosion_vfx.tscn")
const OIL_BUBBLES_SCENE: PackedScene = preload("res://scenes/vfx/oil_bubbles.tscn")

## Die Saeure-Lache ist eine bestehende Hazard-Szene. Bewusst load() statt
## preload(): wer den Hazard-Ordner umbenennt, soll eine Warnung bekommen und
## keinen Parse-Fehler im ganzen Item-System.
const LEMONADE_SCENE_PATH: String = "res://scenes/hazards/lemonade.tscn"

const ENEMY_GROUP: String = "enemies"
const PICKUP_GROUP: String = "pickups"

# --- Shader-Flash auf dem Spielermodell -------------------------------------
const FLASH_DURATION: float = 0.22
const FLASH_STRENGTH: float = 0.85
const FLASH_RED: Color = Color(1.0, 0.15, 0.15)
const FLASH_WHITE: Color = Color(1.0, 1.0, 1.0)
const FLASH_GREEN: Color = Color(0.35, 1.0, 0.35)
const FLASH_BLUE: Color = Color(0.35, 0.70, 1.0)

# ============================================================================
# BESTANDSITEMS
# ============================================================================

# --- 1. Mamas Kochloeffel ---
const SPOON_DURATION: float = 0.75
const SPOON_SPEED_MULTIPLIER: float = 1.5

# --- 2. Rostiges Beil ---
const CLEAVER_CHANCE: float = 0.30
## Omas Stricknadeln heben die Chance auf diesen Wert an.
const CLEAVER_CHANCE_WITH_NEEDLES: float = 0.50
const BLEED_DURATION: float = 4.0
const BLEED_TICK_INTERVAL: float = 1.0
const BLEED_DAMAGE_PER_TICK: float = 5.0

# --- 3. Statische Socke ---
const SOCK_HITS_NEEDED: int = 6
const SOCK_RADIUS: float = 6.0
const SOCK_DAMAGE_MULTIPLIER: float = 2.0
const SOCK_KNOCKBACK: float = 14.0

# --- 4. Hoellenfeuer-Hoerner ---
const HORNS_MIN_SPEED: float = 18.0
const HORNS_CONTACT_RANGE: float = 2.0
const HORNS_DAMAGE: float = 35.0
const HORNS_KNOCKBACK: float = 18.0
const HORNS_COOLDOWN_PER_TARGET: float = 0.8

# --- 5. Heiliges Oel ---
const OIL_SPAWN_INTERVAL: float = 0.2
const OIL_LIFETIME: float = 3.0
const OIL_RADIUS: float = 1.1
const OIL_DAMAGE_PER_TICK: float = 3.0
const OIL_TICK_INTERVAL: float = 0.5
const OIL_SLOW_AMOUNT: float = 0.25
const OIL_MIN_SPEED: float = 3.0

# --- 6. Papas Starthilfekabel ---
const CABLES_DURATION: float = 0.28
const CABLES_DAMAGE: float = 45.0
const CABLES_STUN: float = 2.0
const CABLES_HIT_RADIUS: float = 2.6

# ============================================================================
# PHASE 4 — PASSIVE ITEMS
# ============================================================================

# --- P1. Proteinshake aus den 90ern ---
## Faktor auf die Skalierung der Angriffs-Hitboxen. 0.85 = 15 % kleiner.
const SHAKE_HITBOX_SCALE: float = 0.85

# --- P2. Omas Enge Hosen ---
const PANTS_MIN_SPEED: float = 8.0
const PANTS_RANGE: float = 2.4
const PANTS_DAMAGE_FACTOR: float = 0.5
const PANTS_COOLDOWN_PER_TARGET: float = 1.0
## ITEM-REWORK: Richtungswechsel als zweiter Ausloeser neben dem
## Vorbeirennen ("Body-Check"). Winkel zwischen letzter und aktueller
## Bewegungsrichtung, ab dem ein Wechsel als "abrupt" zaehlt.
const PANTS_TURN_ANGLE_DEG: float = 100.0
## Rueckstoss-Distanz "4 Meter" aus der Design-Vorgabe, umgerechnet ueber
## dieselbe Abbrems-Formel wie EnemyAI.apply_knockback()/knockback_friction
## (v0^2 = 2 * Reibung * Distanz). knockback_friction ist bei EnemyAI ein
## @export mit Standardwert 10.0 - der Wert hier trifft die 4 Meter fuer
## Gegner mit dieser Standardreibung.
const PANTS_KNOCKBACK: float = 9.0

# --- P3. Plastik-Heiligenschein ---
const HALO_HEAL_CHANCE: float = 0.10
const HALO_HEAL_AMOUNT: float = 0.5

# --- P4. Das Blutpakt ---
const PACT_HITS_PER_COST: int = 5
const PACT_SELF_DAMAGE: float = 0.5

# --- P5. Rostiger Dachnagel ---
const NAIL_CHANCE: float = 0.25

# --- P6. Kaugummi unter dem Schuh ---
const GUM_LIFETIME: float = 1.5
const GUM_RADIUS: float = 2.2
const GUM_SLOW_AMOUNT: float = 0.45
const GUM_SLOW_DURATION: float = 1.5
## Wie viele Klebeflecken ein Dash hinterlaesst.
const GUM_BLOB_COUNT: int = 3

# --- P7. Kaputter Toaster ---
const TOASTER_RADIUS: float = 5.5
const TOASTER_KNOCKBACK: float = 16.0
const TOASTER_DAMAGE: float = 6.0
## Mindestabstand zwischen zwei Funken-Bursts, damit ein Dauerbeschuss nicht
## zum Dauer-Pushback wird.
const TOASTER_COOLDOWN: float = 0.6

# --- P8. Mutters Haarspray ---
const SPRAY_RADIUS: float = 4.0
const SPRAY_DURATION: float = 2.5
## Wie viel laenger ein Gegner in der Wolke fuer seinen Angriff braucht.
const SPRAY_TELEGRAPH_DELAY: float = 0.5
const SPRAY_IGNITE_DAMAGE: float = 30.0
const SPRAY_IGNITE_RADIUS: float = 5.0
## Nur bei jedem n-ten Schlag, sonst haengt permanent eine Wolke im Raum.
const SPRAY_EVERY_N_HITS: int = 3

# --- P9. Altes Modulations-Modem (56k) ---
const MODEM_HITS_NEEDED: int = 10
const MODEM_RADIUS: float = 9.0
const MODEM_SILENCE_DURATION: float = 1.0

# --- P10. Laser-Pointer aus dem Kiosk ---
const LASER_RANGE: float = 40.0
const LASER_DAMAGE_BONUS: float = 0.15
## Anteil eines DoT-Ticks, der auf Nachbargegner ueberspringt.
const LASER_DOT_SPLIT: float = 0.50
const LASER_SPLIT_RADIUS: float = 6.0
const LASER_RETARGET_INTERVAL: float = 0.35
const LASER_BEAM_THICKNESS: float = 0.06
const LASER_COLOR: Color = Color(1.0, 0.12, 0.12)

# --- P11. Ueberkochter Milchreis ---
## Ab welcher Geschwindigkeit "Stillstehen" nicht mehr gilt.
const RICE_STAND_SPEED: float = 1.2
## Sekunden Stillstand, bis der Schild komplett aufgebaut ist.
const RICE_BUILD_TIME: float = 2.5
## Schild als Anteil der Maximal-HP.
const RICE_SHIELD_FRACTION: float = 0.15

# --- P12. Tennisball an der Schnur ---
const TENNIS_SPEED: float = 34.0
const TENNIS_RANGE: float = 18.0
const TENNIS_RADIUS: float = 1.4
const TENNIS_DAMAGE: float = 12.0
const TENNIS_KNOCKBACK: float = 20.0

# --- P13. Disco-Kugel-Anhaenger ---
const DISCO_CHANCE: float = 0.10
const DISCO_RADIUS: float = 7.0
const DISCO_CONFUSE_DURATION: float = 2.0

# --- P14. Gefrierbeutel voll Eis ---
const ICE_CHANCE: float = 0.15

# --- P15. Omas Stricknadeln ---
## Anteil der Ruestung, den ein kritischer Treffer ignoriert.
const NEEDLES_ARMOR_PIERCE: float = 1.0
const NEEDLES_CRIT_CHANCE: float = 0.20
const NEEDLES_CRIT_MULTIPLIER: float = 1.6

# --- P16. Teufelchen-Outfit ---
const DEVIL_HEALTH_THRESHOLD: float = 0.50
const DEVIL_DAMAGE_MULTIPLIER: float = 1.50

# --- P17. Nonnen-Kutte ---
const NUN_CHANCE: float = 0.25

# --- P19. Goldene Kreditkarte ---
const CARD_COINS_PER_STEP: int = 10
const CARD_BONUS_PER_STEP: float = 0.02
const CARD_MAX_BONUS: float = 0.50

# --- Papp-Wahrsagerbrett (Rachegeist) ---
const OUIJA_CHANCE: float = 0.20
## Umkreis, in dem nach einem gueltigen Rachegeist-Ziel gesucht wird.
const OUIJA_SEARCH_RADIUS: float = 20.0
## Ab welcher Entfernung ein Gegner als "ausserhalb der Nahkampf-Reichweite"
## zaehlt - grosszuegig ueber der tatsaechlichen Hitbox-Reichweite, damit
## wirklich nur Ziele zaehlen, die man im Nahkampf gerade NICHT bequem
## erreicht.
const OUIJA_MELEE_RANGE: float = 3.5

# --- P41. Mueckenspray der Tante ---
const MOSQUITO_HEAL_CHANCE: float = 0.15
const MOSQUITO_HEAL_AMOUNT: float = 0.5

# --- P42. Plastik-Vampirgebiss ---
const VAMPIRE_HEAL_AMOUNT: float = 0.5

# --- P43. Scharfrichter-Kapuze ---
const EXECUTIONER_HEAL_AMOUNT: float = 1.0
const EXECUTIONER_SHOCKWAVE_RADIUS: float = 5.0

# --- P44. Omas Scharfes Chili-Oel ---
const CHILI_RADIUS: float = 5.0
const CHILI_ACID_DURATION: float = 3.0
const CHILI_ACID_DAMAGE: float = 5.0

# --- P45. Ausgelaufene Flachbatterie ---
const BATTERY_RADIUS: float = 6.0
const BATTERY_STUN_DURATION: float = 1.5
const BATTERY_HAZARD_CHECK_RANGE: float = 4.0

# --- P46. Alarmanlage vom Parkplatz ---
const CAR_ALARM_SILENCE_DURATION: float = 3.0
const CAR_ALARM_RADIUS: float = 40.0

# --- P47. Ausgelaufener Sekundenkleber ---
const GLUE_ROOTED_DURATION: float = 2.0
const GLUE_RADIUS: float = 1.6
const GLUE_LIFETIME: float = 8.0

# --- P48. Alte Rollschuhe ---
const SKATES_RADIUS: float = 2.6
const SKATES_KNOCKBACK: float = 24.0
const SKATES_CONFUSE_DURATION: float = 3.0

# --- P49. Riesige Kaugummiblase ---
const BUBBLE_STAND_SPEED: float = 1.2
const BUBBLE_BUILD_TIME: float = 3.0
const BUBBLE_RADIUS: float = 5.0
const BUBBLE_SLOW_AMOUNT: float = 0.5
const BUBBLE_SLOW_DURATION: float = 4.0

# --- P50. Kupferdraht-Spule ---
const COPPER_RADIUS: float = 2.6

# --- A9. Alte Ghettoblaster-Box ---
const BOOMBOX_RADIUS: float = 12.0
const BOOMBOX_SILENCE_DURATION: float = 4.0
## Nahkampfschaden-Bonus gegen stummgeschaltete Gegner (Synergie).
const BOOMBOX_SILENCED_MELEE_BONUS: float = 0.30

# --- A10. Scharfe Instant-Nudeln ---
const RAMEN_RANGE: float = 7.0
const RAMEN_HALF_ANGLE_DEG: float = 40.0
const RAMEN_DAMAGE: float = 20.0

# --- A11. USB-Mini-Ventilator ---
const FAN_RANGE: float = 8.0
const FAN_HALF_ANGLE_DEG: float = 30.0
const FAN_SLOW_DURATION: float = 3.0
const FAN_SLOW_AMOUNT: float = 0.35
const FAN_SPREAD_RADIUS: float = 4.0

# --- A12. Spruehdose aus dem Tunnel ---
const GRAFFITI_RADIUS: float = 7.0
const GRAFFITI_CHARM_DURATION: float = 5.0

# --- Nr. 51-83: neue "Ultimate"-Items ---
const UPDRAFT_IMPULSE: float = 16.0
const HEALING_ORB_INSTANT_FRACTION: float = 0.25
const HEALING_ORB_OVER_TIME_FRACTION: float = 0.15
const HEALING_ORB_TICK_DURATION: float = 4.0
const SLOW_ORB_RADIUS: float = 4.0
const SLOW_ORB_SLOW_AMOUNT: float = 0.55
const SLOW_ORB_SLOW_DURATION: float = 4.0
const SLOW_ORB_LIFETIME: float = 6.0
const INCENDIARY_RADIUS: float = 3.5
const INCENDIARY_LIFETIME: float = 6.0
const INCENDIARY_TICK_INTERVAL: float = 0.5
const INCENDIARY_TICK_DAMAGE: float = 4.0
const BARRIER_ORB_LIFETIME: float = 5.0
const BARRIER_ORB_SIZE: Vector3 = Vector3(4.0, 3.0, 0.6)
const SHOCK_BOLT_RANGE: float = 16.0
const SHOCK_BOLT_DAMAGE: float = 12.0
const SHOCK_BOLT_STUN: float = 2.0
const ROLLING_THUNDER_RADIUS: float = 9.0
const ROLLING_THUNDER_STUN: float = 1.5
const ROLLING_THUNDER_KNOCKBACK: float = 14.0
const FAULT_LINE_RANGE: float = 12.0
const FAULT_LINE_WIDTH: float = 2.0
const FAULT_LINE_STUN: float = 1.5
const STIM_BEACON_RADIUS: float = 6.0
const STIM_BEACON_LIFETIME: float = 10.0
const STIM_BEACON_SPEED_MUL: float = 1.25
const STIM_BEACON_DAMAGE_MUL: float = 1.20
const SEIZE_RADIUS: float = 3.0
const SEIZE_LIFETIME: float = 7.0
const SEIZE_ROOTED_DURATION: float = 2.0
const SEIZE_ACID_DAMAGE: float = 3.0
const DEVOUR_HEAL_FRACTION: float = 0.04
const HUNTERS_FURY_RANGE: float = 18.0
const HUNTERS_FURY_WIDTH: float = 1.6
const HUNTERS_FURY_DAMAGE: float = 30.0
const HUNTERS_FURY_BEAM_COUNT: int = 3
const HUNTERS_FURY_BEAM_SPREAD_DEG: float = 8.0
const TURRET_ITEM_LIFETIME: float = 20.0
const TURRET_ITEM_RANGE: float = 10.0
const TURRET_ITEM_FIRE_INTERVAL: float = 1.2
const TURRET_ITEM_DAMAGE: float = 8.0
const ORBITAL_STRIKE_DELAY: float = 1.4
const ORBITAL_STRIKE_RADIUS: float = 5.0
const ORBITAL_STRIKE_DAMAGE: float = 55.0
const ORBITAL_STRIKE_RANGE_AHEAD: float = 9.0
const SNAKE_BITE_RADIUS: float = 3.0
const SNAKE_BITE_LIFETIME: float = 6.0
const SNAKE_BITE_VULNERABLE_DURATION: float = 3.0
const SNAKE_BITE_VULNERABLE_BONUS: float = 0.35
const SNAKE_BITE_ACID_DAMAGE: float = 3.0

# --- Nr. 52-83 (Rest): weitere neue "Ultimate"-Items ---
const BLADE_STORM_COUNT: int = 5
const BLADE_STORM_SPREAD_DEG: float = 45.0
const BLADE_STORM_RANGE: float = 10.0
const BLADE_STORM_DAMAGE: float = 14.0
const BLAZE_SEGMENTS: int = 4
const BLAZE_SEGMENT_SPACING: float = 2.2
const BLAZE_SEGMENT_RADIUS: float = 1.6
const BLAZE_LIFETIME: float = 5.0
const BLAZE_TICK_DAMAGE: float = 5.0
const HOT_HANDS_RANGE_AHEAD: float = 7.0
const HOT_HANDS_RADIUS: float = 3.0
const HOT_HANDS_DAMAGE: float = 22.0
const RUN_IT_BACK_HEAL_FRACTION: float = 0.5
const RUN_IT_BACK_LIFETIME: float = 20.0
const BOOM_BOT_SPEED: float = 9.0
const BOOM_BOT_LIFETIME: float = 5.0
const BOOM_BOT_RADIUS: float = 3.5
const BOOM_BOT_DAMAGE: float = 26.0
const PAINT_SHELLS_COUNT: int = 4
const PAINT_SHELLS_SPREAD: float = 3.0
const PAINT_SHELLS_RADIUS: float = 2.5
const PAINT_SHELLS_DAMAGE: float = 14.0
const PAINT_SHELLS_FUSE: float = 0.8
const SHOWSTOPPER_RANGE_AHEAD: float = 10.0
const SHOWSTOPPER_RADIUS: float = 5.5
const SHOWSTOPPER_DAMAGE: float = 60.0
const SHOWSTOPPER_KNOCKBACK: float = 18.0
const LEER_RADIUS: float = 7.0
const LEER_LIFETIME: float = 9.0
const LEER_TICK_INTERVAL: float = 2.0
const LEER_CONFUSE_DURATION: float = 2.5
## Nr. 61 Kaiserin: urspruenglich als PASSIVE mit Kill-Chance kodiert, bevor
## der Abgleich mit der echten Tabelle zeigte, dass es ein AKTIV-Item ist
## ("Erhoeht drastisch das Tempo. Kills erneuern die Abklingzeiten und machen
## kurz unsichtbar.") - siehe item_catalog.gd fuer die Korrektur.
## "Kurz unsichtbar": es gibt in diesem Projekt kein System, das die
## Gegner-Wahrnehmung (Sichtlinie/Aggro in enemy_ai.gd) beeinflusst - eine
## echte Unsichtbarkeit haette also tief in die KI eingreifen muessen, blind
## und ungetestet ein zu grosses Risiko. Stellvertretend: kurze
## Unverwundbarkeit (gleicher Mechanismus wie P1 Kochloeffel/P18 Schulter-
## polster) + sichtbarer Flash, statt echter KI-Blindheit.
const EMPRESS_BUFF_DURATION: float = 5.0
const EMPRESS_SPEED_MULTIPLIER: float = 1.6
const EMPRESS_INVULN_DURATION: float = 0.6
const FAKEOUT_LIFETIME: float = 3.0
const FAKEOUT_RADIUS: float = 5.0
const GATECRASH_LIFETIME: float = 10.0
const AFTERSHOCK_RANGE: float = 14.0
const AFTERSHOCK_RADIUS: float = 3.5
const AFTERSHOCK_DAMAGE: float = 24.0
const PROWLER_SPEED: float = 12.0
const PROWLER_LIFETIME: float = 8.0
const PROWLER_CONFUSE_DURATION: float = 2.0
const PROWLER_SILENCE_DURATION: float = 2.0
const NIGHTFALL_RADIUS: float = 11.0
const NIGHTFALL_SLOW_AMOUNT: float = 0.4
const NIGHTFALL_SLOW_DURATION: float = 4.0
const NIGHTFALL_SILENCE_DURATION: float = 3.0
const PARANOIA_RADIUS: float = 7.0
const PARANOIA_CONFUSE_DURATION: float = 2.0
const PARANOIA_SILENCE_DURATION: float = 2.0
const NANOSWARM_ARM_DELAY: float = 1.2
const NANOSWARM_TRIGGER_RADIUS: float = 3.0
const NANOSWARM_BLAST_RADIUS: float = 4.0
const NANOSWARM_DAMAGE: float = 30.0
const NANOSWARM_LIFETIME: float = 8.0
const ALARMBOT_SPEED: float = 15.0
const ALARMBOT_LIFETIME: float = 3.0
const ALARMBOT_VULNERABLE_DURATION: float = 4.0
const ALARMBOT_VULNERABLE_BONUS: float = 1.0
const LOCKDOWN_CHANNEL_TIME: float = 1.8
const LOCKDOWN_RADIUS: float = 12.0
const LOCKDOWN_STUN_DURATION: float = 2.5
const LOCKDOWN_SILENCE_DURATION: float = 3.5

# --- P20. Mamas Stoeckelschuhe ---
const HEELS_MIN_SPEED: float = 6.0
const HEELS_SPAWN_INTERVAL: float = 0.45
const HEELS_LIFETIME: float = 2.0
const HEELS_SIZE: Vector3 = Vector3(3.0, 0.5, 3.0)
const HEELS_DAMAGE_PER_TICK: float = 4.0
## ITEM-REWORK: jeder N-te "Schritt" (= Pfuetzen-Spawn-Takt, siehe
## _tick_stiletto_heels) loest zusaetzlich eine Bodenschockwelle aus, die
## nahe Gegner kurz straucheln laesst.
const HEELS_SHOCKWAVE_EVERY_N_STEPS: int = 3
const HEELS_SHOCKWAVE_RADIUS: float = 4.0
const HEELS_SHOCKWAVE_STUN: float = 0.4

# ============================================================================
# PHASE 4 — AKTIVE ITEMS
# ============================================================================

# --- A1. Sturmfeuerzeug ---
const LIGHTER_RANGE: float = 8.0
## Halber Oeffnungswinkel in Grad. 45 = 90-Grad-Bogen.
const LIGHTER_HALF_ANGLE_DEG: float = 45.0
const LIGHTER_DAMAGE_MULTIPLIER: float = 3.0
const LIGHTER_BASE_DAMAGE: float = 15.0

# --- A2. Schulbibliotheks-Buch ---
const BOOK_EXECUTE_THRESHOLD: float = 0.20

# --- A3. Verfluchter Glueckswuerfel ---
const CURSED_RADIUS: float = 30.0

# --- A4. Alter Handstaubsauger ---
const VACUUM_DURATION: float = 2.5
const VACUUM_RANGE: float = 12.0
const VACUUM_HALF_ANGLE_DEG: float = 35.0
const VACUUM_PULL_SPEED: float = 9.0
## Saeureschaden des Rueckstrahls pro getroffenem Gegner.
const VACUUM_ACID_DAMAGE: float = 6.0
const VACUUM_ACID_DURATION: float = 4.0

# --- A5. Omas Pfeffermuehle ---
const PEPPER_RADIUS: float = 9.0
const PEPPER_SILENCE_DURATION: float = 2.0
const PEPPER_DOT_EXTENSION: float = 3.0

# --- A6. Walkman (kaputt) ---
const WALKMAN_RADIUS: float = 12.0
const WALKMAN_KNOCKBACK: float = 26.0
const WALKMAN_CONFUSE_DURATION: float = 4.0
const WALKMAN_SHAKE: float = 2.0

# --- A7. Megafon aus der Schule ---
const MEGAPHONE_RANGE: float = 11.0
const MEGAPHONE_HALF_ANGLE_DEG: float = 30.0
const MEGAPHONE_DAMAGE: float = 26.0

# --- A8. Spruehsahne-Dose ---
const CREAM_RADIUS: float = 6.0
const CREAM_LIFETIME: float = 6.0
const CREAM_KNOCKDOWN_DURATION: float = 1.5
## Schaden, wenn die Sahne einen brennenden Gegner loescht.
const CREAM_EXTINGUISH_DAMAGE: float = 45.0

var _items: Node = null

# --- Laufzeit-Zustand -------------------------------------------------------
var _sock_hit_count: int = 0
var _pact_hit_count: int = 0
var _modem_hit_count: int = 0
var _spray_hit_count: int = 0
var _horns_cooldowns: Dictionary = {}
var _pants_cooldowns: Dictionary = {}
## Letzte horizontale Bewegungsrichtung, fuer die Richtungswechsel-Erkennung
## (siehe PANTS_TURN_ANGLE_DEG).
var _pants_prev_dir: Vector2 = Vector2.ZERO
var _oil_timer: float = 0.0
var _heels_timer: float = 0.0
## Zaehlt Pfuetzen-Spawns seit dem letzten Schockwellen-Ausloeser.
var _heels_step_count: int = 0
var _cables_timer: float = 0.0
var _cables_hit: Array[int] = []
var _toaster_cooldown: float = 0.0
var _pads_used_this_room: bool = false
var _book_used_in_stage: int = -1
var _devil_active: bool = false

## Dash-Flankenerkennung (siehe Kopfkommentar, "dash_started").
var _was_dashing: bool = false

## --- Ausgelaufene Flachbatterie: Flanken-Erkennung "steht jetzt im Hazard" ---
var _battery_was_in_hazard: bool = false

## --- Riesige Kaugummiblase ---
var _bubble_charge: float = 0.0

## --- Nr. 55. Run It Back: Todesschutz-Marke ---
var _run_it_back_anchor: Vector3 = Vector3.ZERO
var _run_it_back_active: bool = false

## --- Nr. 63. Portalanker ---
var _gatecrash_anchor: Vector3 = Vector3.ZERO
var _gatecrash_active: bool = false

## --- Nr. 61. Kaiserin: Restlaufzeit des Tempo-Buffs ---
var _empress_buff_timer: float = 0.0

## --- Milchreis-Schild ---
var _rice_charge: float = 0.0
var _rice_shield: float = 0.0
## Sichtbare Schild-Aura, solange _rice_shield > 0 - BUGFIX "Schild tut
## nichts sichtbares": vorher gab es ausser einem einzelnen Ring-Impuls beim
## erstmaligen Aufbau KEINE Dauer-Anzeige, der Effekt lief also unsichtbar
## im Hintergrund und wirkte dadurch wie "funktioniert nicht", obwohl die
## Absorption in _on_player_damaged() technisch bereits griff.
var _rice_aura: MeshInstance3D = null
var _rice_aura_material: StandardMaterial3D = null

## --- Laser-Pointer ---
var _laser_target: Node3D = null
var _laser_retarget_timer: float = 0.0
var _laser_beam: MeshInstance3D = null
var _laser_dot_relay: Dictionary = {}

## --- Handstaubsauger (laeuft ueber mehrere Sekunden) ---
var _vacuum_timer: float = 0.0
var _vacuum_direction: Vector3 = Vector3.ZERO
var _vacuum_absorbed_acid: bool = false

## Zuletzt gesehener Raum. Der ItemManager kennt kein "room_entered", nur
## "room_cleared" — fuer das Zuruecksetzen des Handball-Polsters brauchen wir
## aber den EINTRITT. Statt eine neue Signalkette durch RoomInstance und
## LevelGenerator zu ziehen, wird der aktuelle Raum hier abgefragt; der
## Generator veroeffentlicht ihn ohnehin schon fuer Minimap und Boss-Leiste.
var _last_room: Vector2i = Vector2i(2147483647, 2147483647)
var _room_poll_timer: float = 0.0
const ROOM_POLL_INTERVAL: float = 0.25

var _player_health: Health = null
## Hitboxen, deren Skalierung wir veraendert haben — zum Zuruecksetzen beim
## Charakterwechsel.
var _scaled_hitboxes: Array[Node3D] = []


func _ready() -> void:
	_items = get_parent()
	if _items == null:
		return

	_items.player_hit_enemy.connect(_on_player_hit_enemy)
	_items.active_item_used.connect(_on_active_item_used)
	_items.player_ready.connect(_on_player_ready)
	_items.item_added.connect(_on_item_added)
	_items.coins_changed.connect(_on_coins_changed)
	_items.room_cleared.connect(_on_room_cleared)


# ============================================================================
# Grundlagen
# ============================================================================
func _player() -> CharacterBody3D:
	if _items == null:
		return null
	var p = _items.player
	if p is CharacterBody3D and is_instance_valid(p):
		return p
	return null


func _has(item_id: String) -> bool:
	return _items != null and _items.has_item(item_id)


func _stats() -> PlayerStats:
	if _items == null:
		return null
	return _items.stats as PlayerStats


func _health_of(enemy: Node) -> Health:
	if enemy == null or not is_instance_valid(enemy):
		return null
	return enemy.find_child("Health", true, false) as Health


## Alle lebenden Gegner im Umkreis, aufsteigend nach Entfernung.
func _enemies_near(origin: Vector3, radius: float, exclude: Node = null) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy) or enemy == exclude:
			continue
		if enemy.global_position.distance_to(origin) > radius:
			continue
		var health: Health = _health_of(enemy)
		if health == null or not health.is_alive():
			continue
		result.append(enemy)

	result.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		return a.global_position.distance_to(origin) < b.global_position.distance_to(origin)
	)
	return result


## Gegner in einem Kegel vor dem Spieler. Basis fuer Sturmfeuerzeug,
## Handstaubsauger und Megafon — die drei unterscheiden sich nur in Reichweite,
## Winkel und Wirkung, nicht in der Suche.
func _enemies_in_cone(origin: Vector3, forward: Vector3, range_m: float, half_angle_deg: float) -> Array[Node3D]:
	var result: Array[Node3D] = []
	var cos_limit: float = cos(deg_to_rad(half_angle_deg))
	for enemy: Node3D in _enemies_near(origin, range_m):
		var to_enemy: Vector3 = enemy.global_position - origin
		to_enemy.y = 0.0
		if to_enemy.length_squared() < 0.0001:
			result.append(enemy)
			continue
		if forward.dot(to_enemy.normalized()) >= cos_limit:
			result.append(enemy)
	return result


## Flache Blickrichtung des Spielers.
##
## Gerechnet ueber -basis.z des CameraPivot, NICHT ueber +Z. Das Projekt nutzt
## zwar +Z als Vorne fuer die MODELL-Ausrichtung (siehe atan2(dir.x, dir.z) in
## enemy_ai.gd), der CameraPivot folgt aber der Godot-Konvention. Die
## Starthilfekabel rechnen seit jeher genauso — wer das hier umdreht, dreht
## auch den Feuerbogen des Sturmfeuerzeugs um 180 Grad.
func _player_forward(player: CharacterBody3D) -> Vector3:
	var pivot := player.get_node_or_null("CameraPivot") as Node3D
	var forward: Vector3
	if pivot != null:
		forward = -pivot.global_transform.basis.z
	else:
		forward = -player.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() < 0.0001:
		return Vector3.FORWARD
	return forward.normalized()


func _spawn_vfx(scene: PackedScene, world_pos: Vector3, direction: Vector3 = Vector3.ZERO) -> void:
	if scene == null:
		return
	VFX.spawn(scene, world_pos, direction)


## Faerbt das Spielermodell kurz ein (FLASH_RED / FLASH_WHITE / ...).
##
## Setzt flash_color/flash_strength im psx.gdshader. Modelle ohne
## ShaderMaterial werden stillschweigend uebersprungen — der Effekt ist
## Zuckerguss, kein Spielmechanismus, und darf nichts abbrechen.
##
## permanent = true haelt die Faerbung, bis _clear_player_flash() sie loest
## (Teufelchen-Outfit).
func _flash_player(color: Color, permanent: bool = false) -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	var materials: Array[ShaderMaterial] = []
	_collect_shader_materials(player, materials)
	if materials.is_empty():
		return

	for material: ShaderMaterial in materials:
		material.set_shader_parameter("flash_color", color)

	if permanent:
		for material: ShaderMaterial in materials:
			material.set_shader_parameter("flash_strength", 0.35)
		return

	var tween: Tween = create_tween()
	tween.tween_method(
		func(value: float) -> void:
			for material: ShaderMaterial in materials:
				if is_instance_valid(material):
					material.set_shader_parameter("flash_strength", value),
		FLASH_STRENGTH, 0.0, FLASH_DURATION
	)


func _clear_player_flash() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return
	var materials: Array[ShaderMaterial] = []
	_collect_shader_materials(player, materials)
	for material: ShaderMaterial in materials:
		material.set_shader_parameter("flash_strength", 0.0)


func _collect_shader_materials(node: Node, out: Array[ShaderMaterial]) -> void:
	var mesh := node as MeshInstance3D
	if mesh != null:
		# material_override hat Vorrang vor surface_material_override —
		# deshalb zuerst pruefen. Steht dort ein ShaderMaterial, sind die
		# Surface-Overrides ohnehin wirkungslos.
		if mesh.material_override is ShaderMaterial:
			out.append(mesh.material_override as ShaderMaterial)
		else:
			for i: int in range(mesh.get_surface_override_material_count()):
				var surface: Material = mesh.get_surface_override_material(i)
				if surface is ShaderMaterial:
					out.append(surface as ShaderMaterial)
	for child: Node in node.get_children():
		_collect_shader_materials(child, out)


const DAMAGE_NUMBER_SCENE_PATH: String = "res://scenes/ui/damage_number.tscn"
var _cached_damage_number_scene: PackedScene = null

## Spawnt eine Schadenszahl in der Item-Farbe (damage_number.gd, Kind.ITEM)
## ueber dem getroffenen Ziel. Fuer STANDALONE Item-/Passiv-Schaden gedacht
## (Ramm-Attacken, Tritte, Geister, Aktiv-Item-Treffer, ...) - ein normaler
## Hitbox-Treffer bekommt seine Zahl schon ueber primary_hitbox.gd, und
## DoT-Ticks (bleed/burn/acid/Pfuetzen) haben ihr eigenes Tick-System und
## werden hier bewusst NICHT zusaetzlich verdoppelt.
func _spawn_item_damage_number(target: Node3D, amount: float) -> void:
	if target == null or not is_instance_valid(target) or amount <= 0.0:
		return
	if _cached_damage_number_scene == null:
		if not ResourceLoader.exists(DAMAGE_NUMBER_SCENE_PATH):
			return
		_cached_damage_number_scene = load(DAMAGE_NUMBER_SCENE_PATH)
	if _cached_damage_number_scene == null:
		return

	var number: Node = _cached_damage_number_scene.instantiate()
	get_tree().current_scene.add_child(number)
	(number as Node3D).global_position = target.global_position + Vector3.UP * 1.8

	if number.has_method("show_item_damage"):
		number.show_item_damage(amount)
	elif number.has_method("show_damage"):
		number.show_damage(amount)


## Ein einfacher, ungeshadeter Farbwuerfel/-zylinder als Wegwerf-Mesh.
## Wird von Laser, Tennisball, Schallwellen und Sahneteppich benutzt.
func _make_glow_material(color: Color, alpha: float = 1.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, alpha)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.2
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if alpha < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# PSX-Optik: keine Filterung, harte Kanten.
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	return mat


## Haengt einen Node an die aktuelle Szene statt an den Ausloeser.
##
## WARUM NICHT AN DEN SPIELER: Hitboxen werden 0.15 s nach dem Schlag
## deaktiviert, Gegner rufen bei Tod queue_free(), und PartyManager tauscht
## beim Charakterwechsel die komplette Spieler-Instanz. Ein Kind-Node waere in
## allen drei Faellen mitten im Abspielen weg.
func _attach_to_world(node: Node3D, world_pos: Vector3) -> void:
	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(node)
	# NACH add_child(): global_position ist vorher nicht gueltig.
	node.global_position = world_pos


## Blendet einen Node aus und raeumt ihn danach ab.
func _fade_and_free(node: Node3D, lifetime: float, mesh: MeshInstance3D = null) -> void:
	var tween: Tween = create_tween()
	if mesh != null and mesh.get_surface_override_material(0) is StandardMaterial3D:
		var mat := mesh.get_surface_override_material(0) as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		tween.tween_property(mat, "albedo_color:a", 0.0, lifetime)
	else:
		tween.tween_interval(lifetime)
	tween.tween_callback(func() -> void:
		if is_instance_valid(node):
			node.queue_free()
	)


# ============================================================================
# Anbindung an den Spieler (laeuft bei jedem Charakterwechsel neu)
# ============================================================================
func _on_player_ready(player: CharacterBody3D) -> void:
	if player == null or not is_instance_valid(player):
		return

	# Die alte Health-Instanz stirbt mit der alten Spieler-Instanz; Godot
	# loest deren Verbindungen selbst. Nur die Referenz wird neu gesetzt.
	_player_health = player.get_node_or_null("Health") as Health
	if _player_health != null:
		if not _player_health.damage_taken.is_connected(_on_player_damaged):
			_player_health.damage_taken.connect(_on_player_damaged)
		if not _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.connect(_on_player_health_changed)

	_scaled_hitboxes.clear()
	# Der Laserstrahl haengt am alten Spieler und ist nach dem Wechsel
	# ungueltig — sonst zeigt er ins Leere.
	if is_instance_valid(_laser_beam):
		_laser_beam.queue_free()
	_laser_beam = null
	_laser_target = null

	# Milchreis-Schild NICHT mit ueber den Charakterwechsel retten: er ist
	# als Anteil der ALTEN max_health berechnet (RICE_SHIELD_FRACTION) und
	# waere auf dem neuen Charakter falsch dimensioniert. Die Aura-Instanz
	# haengt ausserdem an der alten Spieler-Instanz und wuerde sonst ins
	# Leere zeigen - derselbe Grund wie beim Laserstrahl oben.
	_rice_charge = 0.0
	_rice_shield = 0.0
	if is_instance_valid(_rice_aura):
		_rice_aura.queue_free()
	_rice_aura = null
	_rice_aura_material = null

	_apply_protein_shake_hitbox()
	_refresh_credit_card_bonus()
	_refresh_devil_outfit()


## Wird bei JEDEM neu aufgesammelten Item gerufen — die passiven Dauereffekte
## muessen sich sofort einschalten und nicht erst beim naechsten
## Charakterwechsel.
func _on_item_added(item: ItemData) -> void:
	_apply_protein_shake_hitbox()
	_refresh_credit_card_bonus()
	_refresh_devil_outfit()

	# Proteinshake: FLASH_GREEN beim Aufheben (Design-Dokument).
	if item != null and item.id == ItemCatalog.ID_PROTEIN_SHAKE:
		_flash_player(FLASH_GREEN)
		_apply_protein_shake_mesh_scale()


func _on_room_cleared(_room: Node) -> void:
	# Neuer Raum in Sicht -> Rettung des Handball-Polsters wieder scharf.
	_pads_used_this_room = false


func _on_coins_changed(_amount: int) -> void:
	_refresh_credit_card_bonus()


func _on_player_health_changed(_current: float, _max: float) -> void:
	_refresh_devil_outfit()


# ----------------------------------------------------------------------------
# P1. Proteinshake aus den 90ern — kleinere Hitbox + kleineres Modell
# ----------------------------------------------------------------------------
# Der Schadensbonus steckt in stat_modifiers. Hier wird nur die Reichweite
# verkleinert.
#
# WARUM DIE HITBOX SKALIERT WIRD UND NICHT DIE COLLISIONSHAPE:
# Die Form ist eine SubResource der Charakter-Szene und wird von allen vier
# Charakteren geteilt. Sie zu veraendern wuerde in den anderen Charakteren
# nachwirken — derselbe geteilte-Resource-Fehler wie bei den BoxMeshes der
# Raeume. Die Area3D selbst zu skalieren ist instanzlokal und kostet nichts.
func _apply_protein_shake_hitbox() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	var wanted: float = SHAKE_HITBOX_SCALE if _has(ItemCatalog.ID_PROTEIN_SHAKE) else 1.0

	for path: String in ["CameraPivot/PrimaryHitbox", "CameraPivot/SecondaryHitbox"]:
		var hitbox := player.get_node_or_null(path) as Node3D
		if hitbox == null:
			continue
		hitbox.scale = Vector3.ONE * wanted


## Design-Dokument: "Dauerhaft: Mesh-Skalierung (mesh.scale * 0.85)".
##
## NUR das sichtbare Modell, NICHT der CharacterBody3D: dessen
## CollisionShape mitzuskalieren wuerde den Spieler durch Wandluecken
## rutschen lassen und die Kamerahoehe verschieben.
func _apply_protein_shake_mesh_scale() -> void:
	var player: CharacterBody3D = _player()
	if player == null or not _has(ItemCatalog.ID_PROTEIN_SHAKE):
		return
	for child: Node in player.get_children():
		var model := child as Node3D
		if model == null or model is Area3D or model is CollisionShape3D:
			continue
		if model.name == "CameraPivot" or model.name == "Health":
			continue
		model.scale = model.scale * SHAKE_HITBOX_SCALE


# ----------------------------------------------------------------------------
# P16. Teufelchen-Outfit — dauerhafter roter Glow unter 50 % HP
# ----------------------------------------------------------------------------
func _refresh_devil_outfit() -> void:
	if not _has(ItemCatalog.ID_DEVIL_OUTFIT) or _player_health == null:
		if _devil_active:
			_devil_active = false
			_clear_player_flash()
			var stats_off: PlayerStats = _stats()
			if stats_off != null:
				stats_off.remove_source("item:devil_outfit")
		return

	var low: bool = _player_health.get_health_percent() < DEVIL_HEALTH_THRESHOLD
	if low == _devil_active:
		return
	_devil_active = low

	var stats: PlayerStats = _stats()
	if stats == null:
		return

	if low:
		stats.add_modifier("item:devil_outfit", PlayerStats.STAT_DAMAGE, 0.0, DEVIL_DAMAGE_MULTIPLIER)
		_flash_player(FLASH_RED, true)
	else:
		stats.remove_source("item:devil_outfit")
		_clear_player_flash()
	stats.apply()


# ----------------------------------------------------------------------------
# P19. Goldene Kreditkarte — +2 % Schaden je 10 Muenzen
# ----------------------------------------------------------------------------
func _refresh_credit_card_bonus() -> void:
	var stats: PlayerStats = _stats()
	if stats == null:
		return

	if not _has(ItemCatalog.ID_GOLDEN_CREDIT_CARD):
		if stats.has_source("item:credit_card"):
			stats.remove_source("item:credit_card")
			stats.apply()
		return

	var coins: int = int(_items.coins)
	var steps: int = coins / CARD_COINS_PER_STEP
	var bonus: float = minf(float(steps) * CARD_BONUS_PER_STEP, CARD_MAX_BONUS)
	stats.add_modifier("item:credit_card", PlayerStats.STAT_DAMAGE, 0.0, 1.0 + bonus)
	stats.apply()


# ============================================================================
# Treffer-Events
# ============================================================================
func _on_player_hit_enemy(target: Node3D, hitbox: Hitbox) -> void:
	if target == null or not is_instance_valid(target):
		return

	var health: Health = _health_of(target)
	# Die Hitbox hat den Schaden bereits ausgeteilt, bevor dieses Signal
	# ankommt. Ein toter Gegner heisst also: dieser Schlag war der letzte.
	var was_kill: bool = health != null and not health.is_alive()
	var base_damage: float = hitbox.damage if hitbox != null else 15.0
	# FRUEH erfasst, VOR jeder Kill-Reaktion: Health.died() (in enemy_ai.gd
	# bereits gelaufen, siehe Signal-Reihenfolge in primary_hitbox.gd) koennte
	# Status-Effekte theoretisch aufraeumen - Mueckenspray/Vampirgebiss muessen
	# den Zustand VOM TREFFER SELBST sehen, nicht von danach.
	var target_had_dot: bool = target.has_method("has_status_effect") and (
		target.call("has_status_effect", "bleed")
		or target.call("has_status_effect", "burn")
		or target.call("has_status_effect", "acid")
	)
	var target_had_any_status: bool = target.has_method("has_status_effect") and (
		target_had_dot
		or target.call("has_status_effect", "stun")
		or target.call("has_status_effect", "rooted")
		or target.call("has_status_effect", "confused")
		or target.call("has_status_effect", "silenced")
		or target.call("has_status_effect", "slow")
		or target.call("has_status_effect", "charm")
	)
	var target_was_stunned_or_rooted: bool = target.has_method("has_status_effect") and (
		target.call("has_status_effect", "stun") or target.call("has_status_effect", "rooted")
	)

	# --- Bestandsitems ---
	if _has(ItemCatalog.ID_WOODEN_SPOON):
		_apply_wooden_spoon()
	if _has(ItemCatalog.ID_RUSTY_CLEAVER):
		_apply_rusty_cleaver(target)
	if _has(ItemCatalog.ID_STATIC_SOCK):
		_apply_static_sock(hitbox)

	# --- Phase 4 ---
	if _has(ItemCatalog.ID_ROOF_NAIL):
		_apply_roof_nail(target)
	if _has(ItemCatalog.ID_OUIJA_BOARD):
		_apply_ouija_board()
	if _has(ItemCatalog.ID_BLOOD_PACT):
		_apply_blood_pact()
	if _has(ItemCatalog.ID_ICE_BAG):
		_apply_ice_bag(target)
	if _has(ItemCatalog.ID_MODEM_56K):
		_apply_modem(target)
	if _has(ItemCatalog.ID_HAIRSPRAY):
		_apply_hairspray(target)
	if _has(ItemCatalog.ID_KNITTING_NEEDLES):
		_apply_knitting_needles(target, base_damage)
	if _has(ItemCatalog.ID_GOLDEN_CREDIT_CARD):
		_spawn_vfx(SPARK_YELLOW_SCENE, target.global_position + Vector3.UP * 1.2)
	if _has(ItemCatalog.ID_LASER_POINTER) and target == _laser_target:
		# Der Markierungs-Bonus laeuft NACHTRAEGLICH: die Hitbox hat ihren
		# Schaden schon ausgeteilt, ein Stat-Modifier haette also erst beim
		# NAECHSTEN Schlag gewirkt. Der Nachschlag hier trifft dagegen genau
		# den markierten Gegner, genau jetzt.
		if health != null and health.is_alive():
			var laser_bonus: float = base_damage * LASER_DAMAGE_BONUS
			health.take_damage(laser_bonus, _player())
			_spawn_item_damage_number(target, laser_bonus)
	if _has(ItemCatalog.ID_CHILI_OIL) and StatusBurn.active(target):
		_apply_chili_oil(target)
	if _has(ItemCatalog.ID_BOOMBOX) and StatusSilenced.active(target):
		_apply_boombox_silence_bonus(target, base_damage)
	# Nr. 76 Schlangenbiss: "vulnerable" ist ein generischer Status (kein
	# eigenes status_effects/*.gd noetig, siehe StatusEffectBase.apply_raw) -
	# jeder Treffer gegen einen so markierten Gegner bekommt denselben
	# Nachschlag-Bonus wie beim Laser-Pointer oben.
	if StatusEffectBase.is_active(target, "vulnerable") and health != null and health.is_alive():
		var vuln_bonus: float = base_damage * StatusEffectBase.magnitude_of(target, "vulnerable")
		health.take_damage(vuln_bonus, _player())
		_spawn_item_damage_number(target, vuln_bonus)

	if was_kill:
		if _has(ItemCatalog.ID_PLASTIC_HALO):
			_apply_plastic_halo(target)
		if _has(ItemCatalog.ID_DISCO_BALL):
			_apply_disco_ball(target)
		if _has(ItemCatalog.ID_MOSQUITO_SPRAY) and target_had_dot:
			_apply_mosquito_spray()
		if _has(ItemCatalog.ID_VAMPIRE_TEETH) and target_had_any_status:
			_apply_vampire_teeth()
		if _has(ItemCatalog.ID_EXECUTIONER_HOOD) and target_was_stunned_or_rooted:
			_apply_executioner_hood(target)
		if _has(ItemCatalog.ID_SUPER_GLUE):
			_spawn_glue_spot(target.global_position)
		if _has(ItemCatalog.ID_DEVOUR):
			_apply_devour(_player())
		if _has(ItemCatalog.ID_EMPRESS) and _empress_buff_timer > 0.0:
			_apply_empress()

	# --- Game Juice -----------------------------------------------------
	# Der Hit-Stop haengt an der Wucht des Angriffs, nicht am Item: die
	# SecondaryHitbox macht doppelten Schaden und bekommt deshalb den
	# laengeren Freeze.
	if hitbox != null and hitbox.name.begins_with("Secondary"):
		Juice.hit_stop(Juice.DURATION_HEAVY)
	else:
		Juice.hit_stop(Juice.DURATION_LIGHT)


# ----------------------------------------------------------------------------
# 1. Mamas Kochloeffel — kurzer Schub + Unverwundbarkeit
# ----------------------------------------------------------------------------
func _apply_wooden_spoon() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	if _player_health != null:
		_player_health.set_invulnerable(SPOON_DURATION)

	var stats: PlayerStats = _stats()
	if stats != null:
		stats.add_timed_modifier(
			"buff:wooden_spoon", PlayerStats.STAT_MOVE_SPEED,
			SPOON_DURATION, 0.0, SPOON_SPEED_MULTIPLIER
		)

	_spawn_vfx(DUST_RING_SCENE, player.global_position + Vector3.UP * 0.1)


# ----------------------------------------------------------------------------
# 2. Rostiges Beil — Blutung
# ----------------------------------------------------------------------------
# Nutzt den bestehenden StatusEffectManager statt einer eigenen Coroutine: der
# Effekt laeuft dann automatisch mit ab, wenn der Gegner stirbt oder der Raum
# zurueckgesetzt wird.
#
# SYNERGIE: Omas Stricknadeln heben die Chance von 30 % auf 50 %.
func _apply_rusty_cleaver(target: Node3D) -> void:
	var chance: float = CLEAVER_CHANCE_WITH_NEEDLES if _has(ItemCatalog.ID_KNITTING_NEEDLES) else CLEAVER_CHANCE
	if randf() > chance:
		return
	if not target.has_method("apply_status_effect"):
		return

	target.apply_status_effect("bleed", BLEED_DURATION, BLEED_DAMAGE_PER_TICK, _player(), BLEED_TICK_INTERVAL)
	_spawn_vfx(HIT_SPARK_SCENE, target.global_position + Vector3.UP * 1.0)


# ----------------------------------------------------------------------------
# 3. Statische Socke — Schockwelle bei jedem 6. Treffer
# ----------------------------------------------------------------------------
func _apply_static_sock(hitbox: Hitbox) -> void:
	_sock_hit_count += 1
	if _sock_hit_count < SOCK_HITS_NEEDED:
		return
	_sock_hit_count = 0

	var player: CharacterBody3D = _player()
	if player == null:
		return

	var base_damage: float = hitbox.damage if hitbox != null else 15.0
	var wave_damage: float = base_damage * SOCK_DAMAGE_MULTIPLIER
	var origin: Vector3 = player.global_position

	for enemy: Node3D in _enemies_near(origin, SOCK_RADIUS):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(wave_damage, player)
			_spawn_item_damage_number(enemy, wave_damage)
		if enemy.has_method("apply_knockback"):
			var push: Vector3 = (enemy.global_position - origin)
			push.y = 0.0
			if push.length_squared() > 0.0001:
				enemy.apply_knockback(push.normalized() * SOCK_KNOCKBACK)
		_spawn_vfx(HIT_SPARK_SCENE, enemy.global_position + Vector3.UP)

	_spawn_ring_wave(origin, SOCK_RADIUS, Color(0.55, 0.85, 1.0), 0.35)
	_spawn_vfx(SPARK_YELLOW_SCENE, origin + Vector3.UP)
	Juice.shake(1.2)


# ----------------------------------------------------------------------------
# 5. Rostiger Dachnagel — festnageln
# ----------------------------------------------------------------------------
func _apply_roof_nail(target: Node3D) -> void:
	if randf() > NAIL_CHANCE:
		return
	if StatusRooted.apply(target, StatusRooted.DEFAULT_DURATION, _player()):
		# ITEM-REWORK: bricht einen laufenden Angriffs-Telegraph SOFORT ab -
		# ohne das haette sich der schon angekuendigte Schlag trotz Festnageln
		# noch entladen. Knockback wird separat in EnemyAI.apply_knockback()
		# blockiert, solange "rooted" aktiv ist.
		if target.has_method("interrupt_attack"):
			target.interrupt_attack()
		_spawn_vfx(HIT_SPARK_SCENE, target.global_position + Vector3.UP * 1.0)


# ----------------------------------------------------------------------------
# Papp-Wahrsagerbrett — beschwoert einen Rachegeist gegen einen Gegner im
# blinden Fleck (hinter dem Spieler oder ausserhalb der Nahkampf-Reichweite)
# ----------------------------------------------------------------------------
func _apply_ouija_board() -> void:
	if randf() > OUIJA_CHANCE:
		return
	var player: CharacterBody3D = _player()
	if player == null:
		return
	var target: Node3D = _find_ouija_target(player)
	if target == null:
		return

	var stats: PlayerStats = _stats()
	var damage: float = RevengeGhost.DEFAULT_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)
	RevengeGhost.spawn(player, target, damage, player)


## Sucht den am besten geeigneten "blinden Fleck"-Gegner: hinter dem
## Spieler (Blickrichtung zeigt vom Ziel weg) ODER ausserhalb der
## Nahkampf-Reichweite. Bevorzugt wird, wer BEIDE Kriterien am staerksten
## erfuellt - ein Gegner weit hinter dem Ruecken vor einem, der nur knapp
## ausserhalb der Reichweite direkt vor einem steht.
func _find_ouija_target(player: CharacterBody3D) -> Node3D:
	var forward: Vector3 = _player_forward(player)
	var best: Node3D = null
	var best_score: float = -INF

	for enemy: Node3D in _enemies_near(player.global_position, OUIJA_SEARCH_RADIUS):
		var to_enemy: Vector3 = enemy.global_position - player.global_position
		to_enemy.y = 0.0
		var dist: float = to_enemy.length()
		if dist < 0.05:
			continue

		var dir: Vector3 = to_enemy / dist
		var facing_dot: float = forward.dot(dir)
		var is_behind: bool = facing_dot < 0.0
		var is_out_of_range: bool = dist > OUIJA_MELEE_RANGE
		if not (is_behind or is_out_of_range):
			continue

		var score: float = -facing_dot + maxf(dist - OUIJA_MELEE_RANGE, 0.0) * 0.1
		if score > best_score:
			best_score = score
			best = enemy

	return best


# ----------------------------------------------------------------------------
# 4. Das Blutpakt — jeder 5. Treffer kostet eigenes Leben
# ----------------------------------------------------------------------------
func _apply_blood_pact() -> void:
	_pact_hit_count += 1
	if _pact_hit_count < PACT_HITS_PER_COST:
		return
	_pact_hit_count = 0

	if _player_health == null:
		return
	# BEWUSST OHNE Unverwundbarkeits-Pruefung: der Pakt kostet immer. Ginge
	# der Schaden ueber take_damage(), wuerde ihn jede laufende i-Frame
	# schlucken — und der Kochloeffel machte das Blutpakt gratis.
	_player_health.current_health = maxf(_player_health.current_health - PACT_SELF_DAMAGE, 1.0)
	_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)
	_flash_player(FLASH_RED)


# ----------------------------------------------------------------------------
# P3. Plastik-Heiligenschein — Heilung bei Kill
# ----------------------------------------------------------------------------
func _apply_plastic_halo(target: Node3D) -> void:
	if randf() > HALO_HEAL_CHANCE:
		return
	if _player_health != null:
		_player_health.heal(HALO_HEAL_AMOUNT)
	var player: CharacterBody3D = _player()
	if player != null:
		_spawn_vfx(HOLOGRAM_BLUE_SCENE, player.global_position + Vector3.UP * 2.2)
	_spawn_vfx(HOLOGRAM_BLUE_SCENE, target.global_position + Vector3.UP * 1.5)


# ----------------------------------------------------------------------------
# P14. Gefrierbeutel voll Eis — starke Verlangsamung + Thermoschock
# ----------------------------------------------------------------------------
func _apply_ice_bag(target: Node3D) -> void:
	if randf() > ICE_CHANCE:
		return

	# REIHENFOLGE IST WICHTIG: der Thermoschock liest die RESTdauer des
	# Brands. Wuerde erst der Slow angewendet, waere das egal — aber wuerde
	# erst StatusBurn.clear() laufen, waere der Restschaden weg. Deshalb
	# zuerst der Schock, dann die Verlangsamung.
	if StatusBurn.active(target):
		StatusBurn.thermal_shock(target, _player())

	StatusSlow.apply_heavy(target, _player())
	_flash_player(FLASH_BLUE)
	_spawn_vfx(HIT_SPARK_SCENE, target.global_position + Vector3.UP * 1.0)


# ----------------------------------------------------------------------------
# P9. Altes Modulations-Modem — jeder 10. Schlag schaltet stumm
# ----------------------------------------------------------------------------
func _apply_modem(target: Node3D) -> void:
	# Kritischer Zusatzschaden gegen BETAEUBTE Gegner — greift bei JEDEM
	# Schlag, nicht nur beim zehnten.
	if StatusStun.active(target):
		var health: Health = _health_of(target)
		if health != null and health.is_alive():
			var modem_bonus: float = health.max_health * 0.05 * StatusStun.MODEM_CRIT_MULTIPLIER
			health.take_damage(modem_bonus, _player())
			_spawn_item_damage_number(target, modem_bonus)
			_spawn_vfx(HIT_SPARK_SCENE, target.global_position + Vector3.UP * 1.2)

	_modem_hit_count += 1
	if _modem_hit_count < MODEM_HITS_NEEDED:
		return
	_modem_hit_count = 0

	var player: CharacterBody3D = _player()
	if player == null:
		return

	for enemy: Node3D in _enemies_near(player.global_position, MODEM_RADIUS):
		StatusSilenced.apply(enemy, MODEM_SILENCE_DURATION, player)

	_spawn_ring_wave(player.global_position, MODEM_RADIUS, Color(0.30, 0.60, 1.0), 0.45)
	_flash_player(FLASH_WHITE)


# ----------------------------------------------------------------------------
# P8. Mutters Haarspray — Spruehwolke
# ----------------------------------------------------------------------------
func _apply_hairspray(target: Node3D) -> void:
	_spray_hit_count += 1
	if _spray_hit_count < SPRAY_EVERY_N_HITS:
		return
	_spray_hit_count = 0
	_spawn_hairspray_cloud(target.global_position)


# ----------------------------------------------------------------------------
# P15. Omas Stricknadeln — kritische Treffer durchdringen Ruestung
# ----------------------------------------------------------------------------
# Die +10 % Angriffsgeschwindigkeit stecken in stat_modifiers. Hier nur der
# Krit: Health.incoming_damage_multiplier wird fuer genau EINEN Schlag
# hochgesetzt und sofort wieder zurueckgestellt.
#
# WARUM NACHTRAEGLICH UND NICHT VORHER: der Schaden ist beim Eintreffen dieses
# Signals bereits ausgeteilt. Ein Multiplikator haette also erst beim naechsten
# Schlag gewirkt und der Krit waere immer einen Treffer zu spaet gekommen.
func _apply_knitting_needles(target: Node3D, base_damage: float) -> void:
	if randf() > NEEDLES_CRIT_CHANCE:
		return
	var health: Health = _health_of(target)
	if health == null or not health.is_alive():
		return

	# Ruestung ignorieren = der Zusatzschaden umgeht incoming_damage_multiplier
	# des Ziels, indem er direkt in voller Hoehe nachgereicht wird.
	var bonus: float = base_damage * (NEEDLES_CRIT_MULTIPLIER - 1.0)
	var saved: float = health.incoming_damage_multiplier
	health.incoming_damage_multiplier = 1.0
	health.take_damage(bonus, _player())
	health.incoming_damage_multiplier = saved
	_spawn_item_damage_number(target, bonus)

	_flash_player(FLASH_WHITE)
	_spawn_vfx(HIT_SPARK_SCENE, target.global_position + Vector3.UP * 1.3)


# ----------------------------------------------------------------------------
# P13. Disco-Kugel-Anhaenger — Lichtreflexe bei Kill
# ----------------------------------------------------------------------------
func _apply_disco_ball(target: Node3D) -> void:
	_spawn_vfx(SPARK_YELLOW_SCENE, target.global_position + Vector3.UP * 1.4)
	if randf() > DISCO_CHANCE:
		return
	for enemy: Node3D in _enemies_near(target.global_position, DISCO_RADIUS, target):
		StatusConfused.apply(enemy, DISCO_CONFUSE_DURATION, StatusConfused.DEFAULT_MAX_ANGLE_DEG, _player())


# ----------------------------------------------------------------------------
# P44. Omas Scharfes Chili-Oel — Saeure-Spritzer auf brennende Treffer
# ----------------------------------------------------------------------------
func _apply_chili_oil(target: Node3D) -> void:
	for enemy: Node3D in _enemies_near(target.global_position, CHILI_RADIUS, target):
		StatusAcid.apply(enemy, CHILI_ACID_DURATION, CHILI_ACID_DAMAGE, _player())
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
	_spawn_vfx(OIL_BUBBLES_SCENE, target.global_position + Vector3.UP)


# ----------------------------------------------------------------------------
# P41. Mueckenspray der Tante — Kill-Heal bei DoT-Opfern
# ----------------------------------------------------------------------------
func _apply_mosquito_spray() -> void:
	if randf() > MOSQUITO_HEAL_CHANCE or _player_health == null:
		return
	_player_health.heal(MOSQUITO_HEAL_AMOUNT)
	_flash_player(FLASH_GREEN)


# ----------------------------------------------------------------------------
# P42. Plastik-Vampirgebiss — garantierter Kill-Heal bei Status-Opfern
# ----------------------------------------------------------------------------
func _apply_vampire_teeth() -> void:
	if _player_health == null:
		return
	_player_health.heal(VAMPIRE_HEAL_AMOUNT)
	_flash_player(FLASH_RED)


# ----------------------------------------------------------------------------
# P43. Scharfrichter-Kapuze — Kill-Heal + Schockwelle bei stun/rooted
# ----------------------------------------------------------------------------
func _apply_executioner_hood(target: Node3D) -> void:
	if _player_health != null:
		_player_health.heal(EXECUTIONER_HEAL_AMOUNT)
	_spawn_ring_wave(target.global_position, EXECUTIONER_SHOCKWAVE_RADIUS, Color(0.35, 0.60, 1.0), 0.4)
	_flash_player(FLASH_WHITE)


# ----------------------------------------------------------------------------
# P47. Ausgelaufener Sekundenkleber — klebrige Stelle bei Kills
# ----------------------------------------------------------------------------
func _spawn_glue_spot(world_pos: Vector3) -> void:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0xFFFFFFFF

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = GLUE_RADIUS
	cyl.height = 1.2
	shape.shape = cyl
	area.add_child(shape)

	var mesh_node := MeshInstance3D.new()
	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = GLUE_RADIUS
	cyl_mesh.bottom_radius = GLUE_RADIUS
	cyl_mesh.height = 0.06
	mesh_node.mesh = cyl_mesh
	mesh_node.set_surface_override_material(0, _make_glow_material(Color(0.92, 0.90, 0.80), 0.65))
	area.add_child(mesh_node)

	_attach_to_world(area, world_pos + Vector3(0.0, 0.05, 0.0))

	var already_rooted: Array[int] = []
	var timer := Timer.new()
	timer.wait_time = 0.25
	timer.autostart = true
	area.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(area):
			return
		for body: Node3D in area.get_overlapping_bodies():
			if not body.is_in_group(ENEMY_GROUP):
				continue
			var id: int = body.get_instance_id()
			if already_rooted.has(id):
				continue
			already_rooted.append(id)
			StatusRooted.apply(body, GLUE_ROOTED_DURATION, _player())
	)

	_fade_and_free(area, GLUE_LIFETIME, mesh_node)


# ============================================================================
# Schaden am Spieler
# ============================================================================
func _on_player_damaged(amount: float, source: Node3D) -> void:
	# --- P11. Ueberkochter Milchreis: Schild faengt zuerst ab ------------
	# Guard auf _has(ID_RICE_PUDDING): _rice_shield ist ein rohes
	# Laufzeit-Feld und darf keinen Schaden mehr abfangen, wenn das Item
	# nicht (mehr) im Inventar steckt.
	if _rice_shield > 0.0 and _player_health != null and _has(ItemCatalog.ID_RICE_PUDDING):
		var absorbed: float = minf(_rice_shield, amount)
		_rice_shield -= absorbed
		_player_health.current_health = minf(_player_health.current_health + absorbed, _player_health.max_health)
		_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)
		_flash_player(FLASH_WHITE)
		_update_rice_aura()
		if _rice_shield <= 0.0:
			_rice_charge = 0.0

	# --- P18. Handball-Schulterpolster: Todesschutz ----------------------
	# MUSS VOR allem anderen laufen, was den Frame beenden koennte: der
	# died-Check in Health.take_damage kommt direkt nach diesem Signal.
	# --- Nr. 55. Run It Back: Todesschutz an die Anker-Marke -------------
	# MUSS ebenfalls vor dem died()-Check in Health.take_damage laufen
	# (gleiche Begruendung wie beim Handball-Polster direkt darunter).
	if _has(ItemCatalog.ID_RUN_IT_BACK) and _run_it_back_active and _player_health != null:
		if _player_health.current_health <= 0.0:
			_run_it_back_active = false
			var player: CharacterBody3D = _player()
			if player != null:
				player.global_position = _run_it_back_anchor
			_player_health.current_health = _player_health.max_health * RUN_IT_BACK_HEAL_FRACTION
			_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)
			_player_health.set_invulnerable(1.5)
			_flash_player(FLASH_WHITE)
			_spawn_ring_wave(_run_it_back_anchor, 3.0, Color(0.4, 1.0, 0.9), 0.5)

	if _has(ItemCatalog.ID_HANDBALL_PADS) and not _pads_used_this_room and _player_health != null:
		if _player_health.current_health <= 0.0:
			_pads_used_this_room = true
			_player_health.current_health = 1.0
			_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)
			_player_health.set_invulnerable(1.0)
			_flash_player(FLASH_WHITE)
			_spawn_shield_pulse()

	# --- P17. Nonnen-Kutte: Aktiv-Item aufladen -------------------------
	if _has(ItemCatalog.ID_NUN_HABIT) and randf() <= NUN_CHANCE:
		if _items.has_method("force_recharge_active") and _items.force_recharge_active():
			_flash_player(FLASH_WHITE)

	# --- P7. Kaputter Toaster: Funken stossen Nahkaempfer zurueck -------
	if _has(ItemCatalog.ID_BROKEN_TOASTER) and _toaster_cooldown <= 0.0:
		_toaster_cooldown = TOASTER_COOLDOWN
		_apply_broken_toaster()

	# --- P46. Alarmanlage vom Parkplatz: raumweite Stummschaltung -------
	if _has(ItemCatalog.ID_CAR_ALARM):
		_apply_car_alarm()

	# --- P49. Riesige Kaugummiblase: Blase platzt und verlangsamt -------
	if _has(ItemCatalog.ID_BUBBLE_GUM) and _bubble_charge > 0.0:
		_pop_bubble_gum()

	_refresh_devil_outfit()


# ----------------------------------------------------------------------------
# P7. Kaputter Toaster
# ----------------------------------------------------------------------------
# Funken stossen alle Nahkampf-Gegner im Umkreis zurueck. Brennende Gegner
# bekommen zusaetzlich einen sofortigen doppelten Feuer-Tick — die
# Feuersturm-Synergie aus dem Design-Dokument. Die Regel dafuer steht in
# burn.gd (StatusBurn.detonate), nicht hier: sie beschreibt, wie sich Feuer
# verhaelt, nicht was der Toaster tut.
func _apply_broken_toaster() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return
	var origin: Vector3 = player.global_position

	for enemy: Node3D in _enemies_near(origin, TOASTER_RADIUS):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(TOASTER_DAMAGE, player)
			_spawn_item_damage_number(enemy, TOASTER_DAMAGE)
		if enemy.has_method("apply_knockback"):
			var push: Vector3 = enemy.global_position - origin
			push.y = 0.0
			if push.length_squared() > 0.0001:
				enemy.apply_knockback(push.normalized() * TOASTER_KNOCKBACK)
		# Feuersturm.
		StatusBurn.detonate(enemy, player)
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)

	_spawn_vfx(SPARK_YELLOW_SCENE, origin + Vector3.UP)
	_flash_player(Color(1.0, 0.55, 0.15))


# ----------------------------------------------------------------------------
# P46. Alarmanlage vom Parkplatz — raumweite Stummschaltung bei Schaden
# ----------------------------------------------------------------------------
func _apply_car_alarm() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return
	for enemy: Node3D in _enemies_near(player.global_position, CAR_ALARM_RADIUS):
		StatusSilenced.apply(enemy, CAR_ALARM_SILENCE_DURATION, player)
	_spawn_ring_wave(player.global_position, 6.0, Color(0.90, 0.20, 0.20), 0.4)


# ----------------------------------------------------------------------------
# P49. Riesige Kaugummiblase — platzt bei Schaden, verlangsamt massiv
# ----------------------------------------------------------------------------
func _pop_bubble_gum() -> void:
	var player: CharacterBody3D = _player()
	_bubble_charge = 0.0
	if player == null:
		return
	for enemy: Node3D in _enemies_near(player.global_position, BUBBLE_RADIUS):
		StatusSlow.apply(enemy, BUBBLE_SLOW_DURATION, BUBBLE_SLOW_AMOUNT, player)
	_spawn_ring_wave(player.global_position, BUBBLE_RADIUS, Color(1.0, 0.55, 0.85), 0.4)
	_spawn_vfx(DUST_RING_SCENE, player.global_position + Vector3.UP)


# ----------------------------------------------------------------------------
# P18. Handball-Schulterpolster — sichtbarer Schild-Impuls
# ----------------------------------------------------------------------------
func _spawn_shield_pulse() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return
	_spawn_ring_wave(player.global_position, 3.5, Color(1.0, 1.0, 1.0), 0.4)


# ----------------------------------------------------------------------------
# Wiederverwendbare Schallwelle / Ring
# ----------------------------------------------------------------------------
# Wird von Socke, Modem, Walkman, Handball-Polster und Milchreis benutzt.
# TorusMesh statt GPUParticles3D: ein Ring, der von 0 auf radius waechst, ist
# als Mesh billiger UND liest sich klarer als Reichweiten-Anzeige.
func _spawn_ring_wave(world_pos: Vector3, radius: float, color: Color, duration: float) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.75
	torus.outer_radius = 1.0
	ring.mesh = torus

	var mat: StandardMaterial3D = _make_glow_material(color, 0.75)
	ring.set_surface_override_material(0, mat)
	ring.scale = Vector3(0.15, 0.15, 0.15)

	_attach_to_world(ring, world_pos + Vector3.UP * 0.35)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector3(radius, radius * 0.35, radius), duration)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration)
	tween.set_parallel(false)
	tween.tween_callback(func() -> void:
		if is_instance_valid(ring):
			ring.queue_free()
	)


# ============================================================================
# Laufende Effekte (pro Physik-Frame)
# ============================================================================
func _physics_process(delta: float) -> void:
	if _items == null:
		return

	if _toaster_cooldown > 0.0:
		_toaster_cooldown -= delta

	var player: CharacterBody3D = _player()
	if player == null:
		return

	var speed: float = Vector2(player.velocity.x, player.velocity.z).length()

	_poll_dash(player)
	_poll_room_change()

	# --- Bewegungs-Spuren ("step_tick") ---------------------------------
	if _has(ItemCatalog.ID_HOLY_OIL):
		_tick_holy_oil(delta, player, speed)
	if _has(ItemCatalog.ID_STILETTO_HEELS):
		_tick_stiletto_heels(delta, player, speed)

	# --- Kontakt-Effekte -------------------------------------------------
	if _has(ItemCatalog.ID_BRIMSTONE_HORNS):
		_tick_brimstone_horns(delta, player, speed)
	if _has(ItemCatalog.ID_TIGHT_PANTS):
		_tick_tight_pants(delta, player, speed)

	# --- Dauerzustaende ---------------------------------------------------
	if _has(ItemCatalog.ID_RICE_PUDDING):
		_tick_rice_pudding(delta, player, speed)
	if _has(ItemCatalog.ID_BUBBLE_GUM):
		_tick_bubble_gum(delta, player, speed)
	if _has(ItemCatalog.ID_BATTERY_PACK):
		_tick_battery_pack(player)
	if _empress_buff_timer > 0.0:
		_tick_empress(delta)
	if _has(ItemCatalog.ID_LASER_POINTER):
		_tick_laser_pointer(delta, player)
	elif is_instance_valid(_laser_beam):
		_laser_beam.visible = false

	# --- Aktiv-Items mit Laufzeit -----------------------------------------
	if _cables_timer > 0.0:
		_tick_jumper_cables(delta, player)
	if _vacuum_timer > 0.0:
		_tick_hand_vacuum(delta, player)


## Flankenerkennung fuer den Dash (siehe Kopfkommentar "dash_started").
func _poll_dash(player: CharacterBody3D) -> void:
	var combat: Node = player.get("combat")
	var dashing: bool = false
	if combat != null and is_instance_valid(combat) and combat.has_method("is_dashing"):
		dashing = bool(combat.is_dashing())

	if dashing and not _was_dashing:
		_on_dash_started(player)
	_was_dashing = dashing


func _on_dash_started(player: CharacterBody3D) -> void:
	if _has(ItemCatalog.ID_CHEWING_GUM):
		_spawn_gum_trail(player)
	if _has(ItemCatalog.ID_TENNIS_BALL):
		_fire_tennis_ball(player)
	if _has(ItemCatalog.ID_ROLLER_SKATES):
		_apply_roller_skates(player)
	if _has(ItemCatalog.ID_COPPER_WIRE):
		_apply_copper_wire(player)


## Raumwechsel erkennen — setzt das Handball-Polster zurueck.
func _poll_room_change() -> void:
	_room_poll_timer -= get_physics_process_delta_time()
	if _room_poll_timer > 0.0:
		return
	_room_poll_timer = ROOM_POLL_INTERVAL

	var generators: Array[Node] = get_tree().get_nodes_in_group("level_generator")
	if generators.is_empty():
		return
	var gen: Node = generators[0]
	if not gen.has_method("get_current_room"):
		return

	var room: Vector2i = gen.get_current_room()
	if room == _last_room:
		return
	_last_room = room
	_pads_used_this_room = false


# ----------------------------------------------------------------------------
# 5. Heiliges Oel — Pfuetzenspur
# ----------------------------------------------------------------------------
func _tick_holy_oil(delta: float, player: CharacterBody3D, speed: float) -> void:
	if speed < OIL_MIN_SPEED:
		return
	_oil_timer -= delta
	if _oil_timer > 0.0:
		return
	_oil_timer = OIL_SPAWN_INTERVAL
	_spawn_hazard_puddle(
		player.global_position,
		Vector3(OIL_RADIUS * 2.0, 0.4, OIL_RADIUS * 2.0),
		OIL_LIFETIME, OIL_DAMAGE_PER_TICK, OIL_TICK_INTERVAL,
		OIL_SLOW_AMOUNT, false
	)
	_spawn_vfx(OIL_BUBBLES_SCENE, player.global_position + Vector3.UP * 0.1)


# ----------------------------------------------------------------------------
# P20. Mamas Stoeckelschuhe — Saeure-Lachen
# ----------------------------------------------------------------------------
func _tick_stiletto_heels(delta: float, player: CharacterBody3D, speed: float) -> void:
	if speed < HEELS_MIN_SPEED:
		return
	_heels_timer -= delta
	if _heels_timer > 0.0:
		return
	_heels_timer = HEELS_SPAWN_INTERVAL
	_spawn_hazard_puddle(
		player.global_position, HEELS_SIZE, HEELS_LIFETIME,
		HEELS_DAMAGE_PER_TICK, StatusAcid.DEFAULT_TICK_INTERVAL,
		StatusSlow.DEFAULT_AMOUNT, true
	)
	_spawn_vfx(DUST_RING_SCENE, player.global_position + Vector3.UP * 0.05)

	# ITEM-REWORK: jeder dritte "Schritt" loest zusaetzlich eine haptische
	# Bodenschockwelle aus.
	_heels_step_count += 1
	if _heels_step_count >= HEELS_SHOCKWAVE_EVERY_N_STEPS:
		_heels_step_count = 0
		_trigger_heels_shockwave(player)


## Micro-Stun/Interrupt fuer nahe Gegner - StatusStun.apply() interrupt't
## einen laufenden Telegraph bereits automatisch (siehe EnemyAI.
## _on_status_effect_applied), zusaetzlicher Code dafuer ist hier nicht
## noetig.
func _trigger_heels_shockwave(player: CharacterBody3D) -> void:
	for enemy: Node3D in _enemies_near(player.global_position, HEELS_SHOCKWAVE_RADIUS):
		StatusStun.apply(enemy, HEELS_SHOCKWAVE_STUN, player)
	_spawn_ring_wave(player.global_position, HEELS_SHOCKWAVE_RADIUS, Color(0.85, 0.55, 1.0), 0.3)
	Juice.shake(0.6)


## Gemeinsamer Bauplan fuer Oel-, Saeure- und Klebe-Pfuetzen.
##
## WARUM NICHT lemonade.tscn INSTANZIIEREN:
## Die Hazard-Szene bringt ihre eigene Groesse, ihr eigenes Material und ihre
## eigenen Tick-Werte mit. Sie fuer drei verschiedene Items umzukonfigurieren
## haette bedeutet, jede dieser Eigenschaften nach dem Instanziieren zu
## ueberschreiben — inklusive der SubResource-Falle (BoxMesh/BoxShape3D sind
## in .tscn geteilt und muessen VOR jeder Aenderung dupliziert werden, sonst
## waechst mit der ersten Pfuetze auch jede Lava-Flaeche im Level mit).
## Ein im Code gebauter Area3D ist kuerzer und hat das Problem gar nicht.
func _spawn_hazard_puddle(
		world_pos: Vector3,
		puddle_size: Vector3,
		lifetime: float,
		damage_per_tick: float,
		tick_interval: float,
		slow_amount: float,
		is_acid: bool
) -> void:
	var area := Area3D.new()
	area.monitoring = true
	# Layer 0 / Maske auf "alles": die Pfuetze soll Gegner finden, nicht selbst
	# gefunden werden.
	area.collision_layer = 0
	area.collision_mask = 0xFFFFFFFF

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = puddle_size
	shape.shape = box
	area.add_child(shape)

	var mesh_node := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(puddle_size.x, 0.08, puddle_size.z)
	mesh_node.mesh = box_mesh
	var color: Color = Color(0.62, 0.92, 0.28) if is_acid else Color(0.85, 0.78, 0.35)
	mesh_node.set_surface_override_material(0, _make_glow_material(color, 0.55))
	area.add_child(mesh_node)

	_attach_to_world(area, world_pos + Vector3(0.0, 0.05, 0.0))

	# Der Tick laeuft ueber einen eigenen Timer im Node, damit die Pfuetze
	# unabhaengig von diesem Script weiterlebt (Charakterwechsel!).
	var timer := Timer.new()
	timer.wait_time = tick_interval
	timer.autostart = true
	area.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(area):
			return
		for body: Node3D in area.get_overlapping_bodies():
			if not body.is_in_group(ENEMY_GROUP):
				continue
			var health: Health = _health_of(body)
			if health == null or not health.is_alive():
				continue
			if is_acid:
				StatusAcid.apply(body, StatusAcid.DEFAULT_DURATION, damage_per_tick, _player(), tick_interval)
			else:
				health.take_damage(damage_per_tick, _player())
			if slow_amount > 0.0:
				StatusSlow.apply(body, maxf(tick_interval * 2.0, 0.6), slow_amount, _player())
	)

	_fade_and_free(area, lifetime, mesh_node)


# ----------------------------------------------------------------------------
# P6. Kaugummi unter dem Schuh — Klebespur beim Dash
# ----------------------------------------------------------------------------
func _spawn_gum_trail(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	for i: int in range(GUM_BLOB_COUNT):
		var pos: Vector3 = player.global_position - forward * (float(i) * 1.6)
		_spawn_gum_blob(pos)


## Ein Klebefleck. Verlangsamt und verlaengert laufende Saeure um 50 %
## (Synergie aus dem Design-Dokument, Regel steht in acid.gd).
func _spawn_gum_blob(world_pos: Vector3) -> void:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0xFFFFFFFF

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = GUM_RADIUS
	cyl.height = 1.2
	shape.shape = cyl
	area.add_child(shape)

	var mesh_node := MeshInstance3D.new()
	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = GUM_RADIUS
	cyl_mesh.bottom_radius = GUM_RADIUS
	cyl_mesh.height = 0.08
	mesh_node.mesh = cyl_mesh
	mesh_node.set_surface_override_material(0, _make_glow_material(Color(0.55, 0.90, 0.45), 0.6))
	area.add_child(mesh_node)

	_attach_to_world(area, world_pos + Vector3(0.0, 0.06, 0.0))

	var timer := Timer.new()
	timer.wait_time = 0.3
	timer.autostart = true
	area.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(area):
			return
		for body: Node3D in area.get_overlapping_bodies():
			if not body.is_in_group(ENEMY_GROUP):
				continue
			StatusSlow.apply(body, GUM_SLOW_DURATION, GUM_SLOW_AMOUNT, _player())
			# Synergie: Saeure haelt 50 % laenger.
			StatusAcid.extend_for_gum(body)
	)

	_fade_and_free(area, GUM_LIFETIME, mesh_node)


# ----------------------------------------------------------------------------
# P12. Tennisball an der Schnur — Projektil beim Dash
# ----------------------------------------------------------------------------
func _fire_tennis_ball(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var start: Vector3 = player.global_position + Vector3.UP * 1.0 + forward * 1.0

	var ball := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.7
	ball.mesh = sphere
	ball.set_surface_override_material(0, _make_glow_material(Color(0.90, 0.95, 0.20)))
	_attach_to_world(ball, start)

	# Die Schnur: ein duenner Zylinder zwischen Spieler und Ball. Wird jeden
	# Frame nachgezogen (siehe unten).
	var travel_time: float = TENNIS_RANGE / TENNIS_SPEED
	var target: Vector3 = start + forward * TENNIS_RANGE
	var already_hit: Array[int] = []

	var tween: Tween = create_tween()
	tween.tween_method(
		func(t: float) -> void:
			if not is_instance_valid(ball):
				return
			ball.global_position = start.lerp(target, t)
			for enemy: Node3D in _enemies_near(ball.global_position, TENNIS_RADIUS):
				var id: int = enemy.get_instance_id()
				if already_hit.has(id):
					continue
				already_hit.append(id)
				var health: Health = _health_of(enemy)
				if health != null:
					health.take_damage(TENNIS_DAMAGE, player)
					_spawn_item_damage_number(enemy, TENNIS_DAMAGE)
				if enemy.has_method("apply_knockback"):
					enemy.apply_knockback(forward * TENNIS_KNOCKBACK)
				# Frischt eine laufende Blutung komplett auf.
				if StatusEffectBase.is_active(enemy, "bleed"):
					enemy.apply_status_effect("bleed", BLEED_DURATION, BLEED_DAMAGE_PER_TICK, player, BLEED_TICK_INTERVAL)
				_spawn_vfx(HIT_SPARK_SCENE, enemy.global_position + Vector3.UP)
				_spawn_vfx(DUST_RING_SCENE, ball.global_position),
		0.0, 1.0, travel_time
	)
	tween.tween_callback(func() -> void:
		if is_instance_valid(ball):
			ball.queue_free()
	)


# ----------------------------------------------------------------------------
# P48. Alte Rollschuhe — Dash-Treffer stossen extrem weit zurueck + verwirren
# ----------------------------------------------------------------------------
# Kein echter Hitbox-Hook fuer "traf per Dash": derselbe Ansatz wie
# Hoellenfeuer-Hoerner/Enge Hosen - ein Umkreis-Sweep im Moment des Dash-
# Starts, mit derselben Begruendung (siehe Kopfkommentar "dash_started").
func _apply_roller_skates(player: CharacterBody3D) -> void:
	for enemy: Node3D in _enemies_near(player.global_position, SKATES_RADIUS):
		if enemy.has_method("apply_knockback"):
			var push: Vector3 = enemy.global_position - player.global_position
			push.y = 0.0
			if push.length_squared() > 0.0001:
				enemy.apply_knockback(push.normalized() * SKATES_KNOCKBACK)
		StatusConfused.apply(enemy, SKATES_CONFUSE_DURATION, StatusConfused.DEFAULT_MAX_ANGLE_DEG, player)
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position + Vector3.UP * 0.1)


# ----------------------------------------------------------------------------
# P50. Kupferdraht-Spule — Dash durch slow/rooted setzt in Brand
# ----------------------------------------------------------------------------
func _apply_copper_wire(player: CharacterBody3D) -> void:
	for enemy: Node3D in _enemies_near(player.global_position, COPPER_RADIUS):
		if not StatusSlow.active(enemy) and not StatusRooted.active(enemy):
			continue
		StatusBurn.apply(enemy, StatusBurn.DEFAULT_DURATION, StatusBurn.DEFAULT_DAMAGE_PER_TICK, player)
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
		_flash_player(Color(1.0, 0.35, 0.15))


# ----------------------------------------------------------------------------
# 4. Hoellenfeuer-Hoerner — Ramm-Attacke bei hohem Tempo
# ----------------------------------------------------------------------------
func _tick_brimstone_horns(delta: float, player: CharacterBody3D, speed: float) -> void:
	_tick_cooldown_map(_horns_cooldowns, delta)
	if speed < HORNS_MIN_SPEED:
		return

	for enemy: Node3D in _enemies_near(player.global_position, HORNS_CONTACT_RANGE):
		var id: int = enemy.get_instance_id()
		if _horns_cooldowns.has(id):
			continue
		_horns_cooldowns[id] = HORNS_COOLDOWN_PER_TARGET

		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(HORNS_DAMAGE, player)
			_spawn_item_damage_number(enemy, HORNS_DAMAGE)
		if enemy.has_method("apply_knockback"):
			var push: Vector3 = enemy.global_position - player.global_position
			push.y = 0.0
			if push.length_squared() > 0.0001:
				enemy.apply_knockback(push.normalized() * HORNS_KNOCKBACK)
		_spawn_vfx(HIT_SPARK_SCENE, enemy.global_position + Vector3.UP)
		Juice.hit_stop(Juice.DURATION_HEAVY)


# ----------------------------------------------------------------------------
# P2. Omas Enge Hosen — Tritt im Vorbeirennen
# ----------------------------------------------------------------------------
func _tick_tight_pants(delta: float, player: CharacterBody3D, speed: float) -> void:
	_tick_cooldown_map(_pants_cooldowns, delta)

	# ITEM-REWORK: zweiter Ausloeser neben "schnell an einem Gegner vorbei"
	# (Body-Check) - ein abrupter Richtungswechsel (Juke) zaehlt jetzt
	# genauso. Erkannt ueber den Winkel zwischen letzter und aktueller
	# horizontaler Bewegungsrichtung.
	var current_dir: Vector2 = Vector2(player.velocity.x, player.velocity.z)
	var abrupt_turn: bool = false
	if current_dir.length() > 0.5 and _pants_prev_dir.length() > 0.5:
		abrupt_turn = _pants_prev_dir.normalized().angle_to(current_dir.normalized()) > deg_to_rad(PANTS_TURN_ANGLE_DEG)
	if current_dir.length() > 0.5:
		_pants_prev_dir = current_dir

	if speed < PANTS_MIN_SPEED and not abrupt_turn:
		return

	var stats: PlayerStats = _stats()
	var base: float = 15.0 * (stats.get_damage_multiplier() if stats != null else 1.0)

	for enemy: Node3D in _enemies_near(player.global_position, PANTS_RANGE):
		var id: int = enemy.get_instance_id()
		if _pants_cooldowns.has(id):
			continue
		_pants_cooldowns[id] = PANTS_COOLDOWN_PER_TARGET

		var health: Health = _health_of(enemy)
		var pants_damage: float = base * PANTS_DAMAGE_FACTOR
		if health != null:
			health.take_damage(pants_damage, player)
			# Item-Damage-Number in Spezialfarbe - siehe damage_number.gd,
			# Kind.ITEM.
			_spawn_item_damage_number(enemy, pants_damage)
		# ITEM-REWORK: starker Rueckstoss (~4 Meter) statt nur eines
		# kosmetischen Staubrings.
		if enemy.has_method("apply_knockback"):
			var push: Vector3 = enemy.global_position - player.global_position
			push.y = 0.0
			if push.length_squared() > 0.0001:
				enemy.apply_knockback(push.normalized() * PANTS_KNOCKBACK)
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position + Vector3.UP * 0.1)
	# Windlinien an den Fuessen des Spielers.
	if not _pants_cooldowns.is_empty():
		_spawn_vfx(DUST_RING_SCENE, player.global_position + Vector3.UP * 0.05)


## Laesst alle Eintraege einer Cooldown-Tabelle ablaufen und raeumt sie ab.
func _tick_cooldown_map(map: Dictionary, delta: float) -> void:
	if map.is_empty():
		return
	var done: Array = []
	for id in map.keys():
		var left: float = float(map[id]) - delta
		if left <= 0.0:
			done.append(id)
		else:
			map[id] = left
	for id in done:
		map.erase(id)


# ----------------------------------------------------------------------------
# P11. Ueberkochter Milchreis — Schild beim Stillstehen
# ----------------------------------------------------------------------------
func _tick_rice_pudding(delta: float, player: CharacterBody3D, speed: float) -> void:
	if _player_health == null:
		return

	var max_shield: float = _player_health.max_health * RICE_SHIELD_FRACTION

	if speed > RICE_STAND_SPEED:
		# In Bewegung: der Schild BLEIBT, er waechst nur nicht weiter. Ein
		# Schild, der beim ersten Schritt verpufft, waere im Kampf nutzlos.
		return

	_rice_charge = minf(_rice_charge + delta, RICE_BUILD_TIME)
	var wanted: float = max_shield * (_rice_charge / RICE_BUILD_TIME)
	if wanted > _rice_shield:
		if _rice_shield <= 0.0 and wanted > 0.0:
			_spawn_ring_wave(player.global_position, 2.5, Color(1.0, 1.0, 1.0), 0.5)
		_rice_shield = wanted
		_update_rice_aura()

	# Saeure-Immunitaet, solange der Schild steht.
	var stats: PlayerStats = _stats()
	if stats == null:
		return
	if _rice_shield > 0.0:
		if not stats.has_source("item:rice_shield"):
			stats.add_modifier("item:rice_shield", PlayerStats.STAT_HAZARD_RESIST, 0.0, 0.0)
			stats.apply()
	elif stats.has_source("item:rice_shield"):
		stats.remove_source("item:rice_shield")
		stats.apply()


# ----------------------------------------------------------------------------
# P49. Riesige Kaugummiblase — baut sich beim Stillstehen auf
# ----------------------------------------------------------------------------
func _tick_bubble_gum(delta: float, player: CharacterBody3D, speed: float) -> void:
	if speed > BUBBLE_STAND_SPEED:
		return  # Blase BLEIBT beim Laufen stehen, waechst nur nicht weiter.
	_bubble_charge = minf(_bubble_charge + delta, BUBBLE_BUILD_TIME)


# ----------------------------------------------------------------------------
# P45. Ausgelaufene Flachbatterie — Stromschlag beim Betreten von Saeure
# ----------------------------------------------------------------------------
## Flankenerkennung "gerade erst reingetreten" ueber _player_stands_in_hazard()
## (dieselbe Distanz-Abfrage, die auch der Handstaubsauger benutzt) - nur beim
## UEBERGANG entlaedt sich der Stromschlag, nicht jeden Frame im Hazard.
func _tick_battery_pack(player: CharacterBody3D) -> void:
	var now_in_hazard: bool = _player_stands_in_hazard(player, BATTERY_HAZARD_CHECK_RANGE)
	if now_in_hazard and not _battery_was_in_hazard:
		for enemy: Node3D in _enemies_near(player.global_position, BATTERY_RADIUS):
			StatusStun.apply(enemy, BATTERY_STUN_DURATION, player)
		_spawn_ring_wave(player.global_position, BATTERY_RADIUS, Color(0.35, 0.70, 1.0), 0.35)
		_flash_player(FLASH_BLUE)
	_battery_was_in_hazard = now_in_hazard


## Persistente Schild-Aura: ein halbtransparenter weisser Ball um den
## Spieler, der sich mit _rice_shield relativ zu max_shield skaliert und
## verschwindet, sobald der Schild aufgebraucht ist. Ohne diese Dauer-Anzeige
## gab es ausser dem einmaligen Ring-Impuls beim ersten Aufbau KEIN
## sichtbares Zeichen, dass der Schild ueberhaupt aktiv ist.
func _update_rice_aura() -> void:
	var player: CharacterBody3D = _player()
	if player == null or _player_health == null:
		_clear_rice_aura()
		return

	if _rice_shield <= 0.0:
		_clear_rice_aura()
		return

	if _rice_aura == null or not is_instance_valid(_rice_aura):
		var sphere := SphereMesh.new()
		sphere.radius = 1.0
		sphere.height = 2.0
		sphere.radial_segments = 16
		sphere.rings = 8

		_rice_aura_material = _make_glow_material(Color(1.0, 1.0, 1.0), 0.28)
		_rice_aura_material.cull_mode = BaseMaterial3D.CULL_DISABLED

		_rice_aura = MeshInstance3D.new()
		_rice_aura.name = "RiceShieldAura"
		_rice_aura.mesh = sphere
		_rice_aura.set_surface_override_material(0, _rice_aura_material)
		_rice_aura.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		player.add_child(_rice_aura)
		_rice_aura.position = Vector3(0.0, 0.9, 0.0)

	var max_shield: float = _player_health.max_health * RICE_SHIELD_FRACTION
	var fraction: float = clampf(_rice_shield / maxf(max_shield, 0.001), 0.0, 1.0)
	# Nie ganz auf 0 skalieren (sonst "verschwindet" die Kugel invertiert
	# statt zu schrumpfen) - 0.55 bis 1.0 als sichtbarer Bereich.
	var scale_amount: float = lerpf(0.55, 1.0, fraction)
	_rice_aura.scale = Vector3.ONE * scale_amount
	if _rice_aura_material != null:
		_rice_aura_material.albedo_color.a = lerpf(0.12, 0.32, fraction)


func _clear_rice_aura() -> void:
	if is_instance_valid(_rice_aura):
		_rice_aura.queue_free()
	_rice_aura = null
	_rice_aura_material = null


# ----------------------------------------------------------------------------
# P10. Laser-Pointer aus dem Kiosk
# ----------------------------------------------------------------------------
# Markiert dauerhaft den Gegner mit den MEISTEN Lebenspunkten und zieht einen
# Strahl dorthin. Der Schadensbonus haengt in _on_player_hit_enemy(); hier
# laeuft nur Zielsuche, Strahl-Darstellung und die DoT-Verteilung.
func _tick_laser_pointer(delta: float, player: CharacterBody3D) -> void:
	_laser_retarget_timer -= delta
	if _laser_retarget_timer <= 0.0:
		_laser_retarget_timer = LASER_RETARGET_INTERVAL
		_laser_target = _find_strongest_enemy(player.global_position)
		_rebind_laser_dot_relay()

	if _laser_target == null or not is_instance_valid(_laser_target):
		if is_instance_valid(_laser_beam):
			_laser_beam.visible = false
		return

	_update_laser_beam(player.global_position + Vector3.UP * 1.5,
		_laser_target.global_position + Vector3.UP * 1.2)


## Gegner mit den HOECHSTEN absoluten Lebenspunkten in Reichweite.
func _find_strongest_enemy(origin: Vector3) -> Node3D:
	var best: Node3D = null
	var best_hp: float = -1.0
	for enemy: Node3D in _enemies_near(origin, LASER_RANGE):
		var health: Health = _health_of(enemy)
		if health == null:
			continue
		if health.current_health > best_hp:
			best_hp = health.current_health
			best = enemy
	return best


## Baut den Strahl beim ersten Aufruf und richtet ihn danach nur noch aus.
##
## SKALIERUNG STATT NEUBAU: ein Zylinder mit Hoehe 1.0, der auf die Distanz
## gestreckt wird, kostet pro Frame eine Zuweisung. Ein neues Mesh pro Frame
## waere Speichermuell im Sekundentakt.
func _update_laser_beam(from: Vector3, to: Vector3) -> void:
	if not is_instance_valid(_laser_beam):
		_laser_beam = MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = LASER_BEAM_THICKNESS
		cyl.bottom_radius = LASER_BEAM_THICKNESS
		cyl.height = 1.0
		_laser_beam.mesh = cyl
		_laser_beam.set_surface_override_material(0, _make_glow_material(LASER_COLOR, 0.85))
		_attach_to_world(_laser_beam, from)

	_laser_beam.visible = true
	var distance: float = from.distance_to(to)
	if distance < 0.05:
		_laser_beam.visible = false
		return

	_laser_beam.global_position = (from + to) * 0.5
	# CylinderMesh steht entlang +Y. look_at richtet -Z aus, deshalb die
	# zusaetzliche Drehung um 90 Grad auf der X-Achse.
	var up: Vector3 = Vector3.UP
	if absf((to - from).normalized().dot(up)) > 0.99:
		up = Vector3.FORWARD
	_laser_beam.look_at(to, up)
	_laser_beam.rotate_object_local(Vector3.RIGHT, PI * 0.5)
	_laser_beam.scale = Vector3(1.0, distance, 1.0)


## Haengt sich an das Tick-Signal des markierten Gegners, um 50 % jedes
## DoT-Ticks auf Nachbargegner zu verteilen.
##
## WARUM UEBER DAS SIGNAL UND NICHT PER POLLING:
## Ein Poll haette den DoT-Schaden nachbauen muessen (Tick-Intervall,
## Magnitude, Restdauer) — also eine zweite Wahrheit neben dem
## StatusEffectManager. Am Signal haengt automatisch genau der Wert, der
## gerade wirklich ausgeteilt wurde.
func _rebind_laser_dot_relay() -> void:
	# Alte Verbindung loesen.
	for id in _laser_dot_relay.keys():
		var entry: Dictionary = _laser_dot_relay[id]
		var manager: StatusEffectManager = entry.get("manager")
		var callable: Callable = entry.get("callable")
		if is_instance_valid(manager) and manager.effect_ticked.is_connected(callable):
			manager.effect_ticked.disconnect(callable)
	_laser_dot_relay.clear()

	if _laser_target == null or not is_instance_valid(_laser_target):
		return

	var manager: StatusEffectManager = StatusEffectBase.manager_of(_laser_target)
	if manager == null:
		return

	var target: Node3D = _laser_target
	var relay: Callable = func(id: String, magnitude: float, source: Node) -> void:
		if not StatusEffectManager.DOT_IDS.has(id):
			return
		if not is_instance_valid(target):
			return
		var split: float = magnitude * LASER_DOT_SPLIT
		for neighbor: Node3D in _enemies_near(target.global_position, LASER_SPLIT_RADIUS, target):
			var health: Health = _health_of(neighbor)
			if health != null and health.is_alive():
				health.take_damage(split, source)
				_spawn_vfx(HIT_SPARK_SCENE, neighbor.global_position + Vector3.UP)

	manager.effect_ticked.connect(relay)
	_laser_dot_relay[target.get_instance_id()] = {"manager": manager, "callable": relay}


# ----------------------------------------------------------------------------
# P8. Mutters Haarspray — die Wolke
# ----------------------------------------------------------------------------
# Verlaengert die Telegraphs von Gegnern in der Wolke. Faengt die Wolke Feuer
# (brennender Gegner darin), explodiert sie und setzt alles in Brand.
func _spawn_hairspray_cloud(world_pos: Vector3) -> void:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0xFFFFFFFF

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = SPRAY_RADIUS
	shape.shape = sphere
	area.add_child(shape)

	var mesh_node := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = SPRAY_RADIUS
	sphere_mesh.height = SPRAY_RADIUS * 2.0
	mesh_node.mesh = sphere_mesh
	mesh_node.set_surface_override_material(0, _make_glow_material(Color(0.85, 0.92, 0.35), 0.22))
	area.add_child(mesh_node)

	_attach_to_world(area, world_pos + Vector3.UP * 1.2)

	var ignited: Array[bool] = [false]
	var timer := Timer.new()
	timer.wait_time = 0.25
	timer.autostart = true
	area.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(area) or ignited[0]:
			return
		for body: Node3D in area.get_overlapping_bodies():
			if not body.is_in_group(ENEMY_GROUP):
				continue
			# Brennt jemand in der Wolke -> Feuerwelle.
			if StatusBurn.active(body):
				ignited[0] = true
				_ignite_hairspray_cloud(area.global_position)
				return
			# Sonst: Telegraphs werden traeger.
			if body.has_method("apply_status_effect"):
				body.apply_status_effect("spray_slow_telegraph", 0.4, SPRAY_TELEGRAPH_DELAY, _player(), 0.0)
			StatusSlow.apply(body, 0.4, 0.15, _player())
	)

	_fade_and_free(area, SPRAY_DURATION, mesh_node)


func _ignite_hairspray_cloud(world_pos: Vector3) -> void:
	for enemy: Node3D in _enemies_near(world_pos, SPRAY_IGNITE_RADIUS):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(SPRAY_IGNITE_DAMAGE, _player())
			_spawn_item_damage_number(enemy, SPRAY_IGNITE_DAMAGE)
		StatusBurn.apply(enemy, StatusBurn.DEFAULT_DURATION, StatusBurn.DEFAULT_DAMAGE_PER_TICK, _player())
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
	_spawn_ring_wave(world_pos, SPRAY_IGNITE_RADIUS, Color(1.0, 0.55, 0.10), 0.35)
	Juice.shake(1.5)


# ============================================================================
# AKTIVE ITEMS
# ============================================================================
func _on_active_item_used(item: ItemData, _slot: int) -> void:
	if item == null:
		return
	var player: CharacterBody3D = _player()
	if player == null:
		return

	match item.id:
		ItemCatalog.ID_JUMPER_CABLES:
			_use_jumper_cables(player)
		ItemCatalog.ID_STORM_LIGHTER:
			_use_storm_lighter(player)
		ItemCatalog.ID_LIBRARY_BOOK:
			_use_library_book(player)
		ItemCatalog.ID_CURSED_DIE:
			_use_cursed_die(player)
		ItemCatalog.ID_HAND_VACUUM:
			_use_hand_vacuum(player)
		ItemCatalog.ID_PEPPER_MILL:
			_use_pepper_mill(player)
		ItemCatalog.ID_WALKMAN:
			_use_walkman(player)
		ItemCatalog.ID_MEGAPHONE:
			_use_megaphone(player)
		ItemCatalog.ID_WHIPPED_CREAM:
			_use_whipped_cream(player)
		ItemCatalog.ID_BOOMBOX:
			_use_boombox(player)
		ItemCatalog.ID_SPICY_RAMEN:
			_use_spicy_ramen(player)
		ItemCatalog.ID_POCKET_FAN:
			_use_pocket_fan(player)
		ItemCatalog.ID_GRAFFITI_CAN:
			_use_graffiti_can(player)
		ItemCatalog.ID_UPDRAFT:
			_use_updraft(player)
		ItemCatalog.ID_HEALING_ORB:
			_use_healing_orb(player)
		ItemCatalog.ID_SLOW_ORB:
			_use_slow_orb(player)
		ItemCatalog.ID_INCENDIARY:
			_use_incendiary(player)
		ItemCatalog.ID_BARRIER_ORB:
			_use_barrier_orb(player)
		ItemCatalog.ID_SHOCK_BOLT:
			_use_shock_bolt(player)
		ItemCatalog.ID_ROLLING_THUNDER:
			_use_rolling_thunder(player)
		ItemCatalog.ID_FAULT_LINE:
			_use_fault_line(player)
		ItemCatalog.ID_STIM_BEACON:
			_use_stim_beacon(player)
		ItemCatalog.ID_SEIZE:
			_use_seize(player)
		ItemCatalog.ID_HUNTERS_FURY:
			_use_hunters_fury(player)
		ItemCatalog.ID_TURRET:
			_use_turret_item(player)
		ItemCatalog.ID_ORBITAL_STRIKE:
			_use_orbital_strike(player)
		ItemCatalog.ID_SNAKE_BITE:
			_use_snake_bite(player)
		ItemCatalog.ID_BLADE_STORM:
			_use_blade_storm(player)
		ItemCatalog.ID_BLAZE:
			_use_blaze(player)
		ItemCatalog.ID_HOT_HANDS:
			_use_hot_hands(player)
		ItemCatalog.ID_RUN_IT_BACK:
			_use_run_it_back(player)
		ItemCatalog.ID_BOOM_BOT:
			_use_boom_bot(player)
		ItemCatalog.ID_PAINT_SHELLS:
			_use_paint_shells(player)
		ItemCatalog.ID_SHOWSTOPPER:
			_use_showstopper(player)
		ItemCatalog.ID_LEER:
			_use_leer(player)
		ItemCatalog.ID_FAKEOUT:
			_use_fakeout(player)
		ItemCatalog.ID_GATECRASH:
			_use_gatecrash(player)
		ItemCatalog.ID_AFTERSHOCK:
			_use_aftershock(player)
		ItemCatalog.ID_PROWLER:
			_use_prowler(player)
		ItemCatalog.ID_NIGHTFALL:
			_use_nightfall(player)
		ItemCatalog.ID_PARANOIA:
			_use_paranoia(player)
		ItemCatalog.ID_NANOSWARM:
			_use_nanoswarm(player)
		ItemCatalog.ID_ALARMBOT:
			_use_alarmbot(player)
		ItemCatalog.ID_LOCKDOWN:
			_use_lockdown(player)
		ItemCatalog.ID_EMPRESS:
			_use_empress(player)


# --- 6. Papas Starthilfekabel ------------------------------------------------
func _use_jumper_cables(player: CharacterBody3D) -> void:
	_cables_timer = CABLES_DURATION
	_cables_hit.clear()
	_spawn_vfx(SPARK_YELLOW_SCENE, player.global_position + Vector3.UP)
	_flash_player(FLASH_BLUE)


func _tick_jumper_cables(delta: float, player: CharacterBody3D) -> void:
	_cables_timer -= delta
	var forward: Vector3 = _player_forward(player)
	# Der Spieler wird aktiv geschoben — dash_speed des Charakters ist hier
	# bewusst NICHT die Referenz: das Kabel soll immer gleich weit tragen,
	# unabhaengig davon, wer gerade gespielt wird.
	player.velocity.x = forward.x * 30.0
	player.velocity.z = forward.z * 30.0

	for enemy: Node3D in _enemies_near(player.global_position, CABLES_HIT_RADIUS):
		var id: int = enemy.get_instance_id()
		if _cables_hit.has(id):
			continue
		_cables_hit.append(id)
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(CABLES_DAMAGE, player)
			_spawn_item_damage_number(enemy, CABLES_DAMAGE)
		StatusStun.apply(enemy, CABLES_STUN, player)
		_spawn_vfx(HIT_SPARK_SCENE, enemy.global_position + Vector3.UP)


# --- A1. Sturmfeuerzeug ------------------------------------------------------
func _use_storm_lighter(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var stats: PlayerStats = _stats()
	var damage: float = LIGHTER_BASE_DAMAGE * LIGHTER_DAMAGE_MULTIPLIER
	if stats != null:
		damage *= stats.get_damage_multiplier()

	for enemy: Node3D in _enemies_in_cone(player.global_position, forward, LIGHTER_RANGE, LIGHTER_HALF_ANGLE_DEG):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(damage, player)
			_spawn_item_damage_number(enemy, damage)
		StatusBurn.apply(enemy, StatusBurn.DEFAULT_DURATION, StatusBurn.DEFAULT_DAMAGE_PER_TICK, player)
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)

	_spawn_cone_flash(player, forward, LIGHTER_RANGE, LIGHTER_HALF_ANGLE_DEG, Color(1.0, 0.55, 0.12))
	Juice.shake(1.0)


# --- A2. Schulbibliotheks-Buch ----------------------------------------------
# "1x pro Etage": weder Zeit- noch Raum-Cooldown, deshalb eine eigene Sperre.
# Die Etage kommt vom LevelGenerator — der ist die einzige Stelle, die weiss,
# wann eine neue anfaengt.
func _use_library_book(player: CharacterBody3D) -> void:
	var stage: int = _current_stage()
	if _book_used_in_stage == stage:
		return
	_book_used_in_stage = stage

	for enemy: Node3D in _enemies_near(player.global_position, 60.0):
		var health: Health = _health_of(enemy)
		if health == null or not health.is_alive():
			continue
		if health.get_health_percent() > BOOK_EXECUTE_THRESHOLD:
			continue
		var execute_amount: float = health.current_health + 1.0
		health.take_damage(execute_amount, player)
		_spawn_item_damage_number(enemy, execute_amount)
		_spawn_vfx(FLASH_WHITE_SCENE, enemy.global_position + Vector3.UP)

	_spawn_vfx(FLASH_WHITE_SCENE, player.global_position + Vector3.UP)
	_flash_player(FLASH_WHITE)
	Juice.shake(1.6)


func _current_stage() -> int:
	var generators: Array[Node] = get_tree().get_nodes_in_group("level_generator")
	if generators.is_empty():
		return 1
	var gen: Node = generators[0]
	if gen.has_method("get_current_stage"):
		return int(gen.get_current_stage())
	return 1


# --- A3. Verfluchter Glueckswuerfel -----------------------------------------
func _use_cursed_die(player: CharacterBody3D) -> void:
	var rerolled: int = 0
	for node: Node in get_tree().get_nodes_in_group(PICKUP_GROUP):
		var pickup := node as Node3D
		if pickup == null or not is_instance_valid(pickup):
			continue
		if pickup.global_position.distance_to(player.global_position) > CURSED_RADIUS:
			continue
		_spawn_vfx(SPARK_YELLOW_SCENE, pickup.global_position + Vector3.UP * 0.5)
		if pickup.has_method("reroll"):
			pickup.reroll()
			rerolled += 1
		elif Loot != null and Loot.has_method("spawn_random_drop"):
			# Fallback: altes Pickup weg, neues an derselben Stelle.
			var pos: Vector3 = pickup.global_position
			pickup.queue_free()
			Loot.spawn_random_drop(pos)
			rerolled += 1

	if rerolled > 0:
		Juice.shake(0.8)


# --- A4. Alter Handstaubsauger ----------------------------------------------
func _use_hand_vacuum(player: CharacterBody3D) -> void:
	_vacuum_timer = VACUUM_DURATION
	_vacuum_direction = _player_forward(player)
	_vacuum_absorbed_acid = false
	_spawn_cone_flash(player, _vacuum_direction, VACUUM_RANGE, VACUUM_HALF_ANGLE_DEG, Color(0.45, 0.95, 0.35))


func _tick_hand_vacuum(delta: float, player: CharacterBody3D) -> void:
	_vacuum_timer -= delta
	# Richtung mitdrehen: der Sauger folgt dem Blick, sonst muesste man
	# 2,5 Sekunden lang still stehen.
	_vacuum_direction = _player_forward(player)

	for enemy: Node3D in _enemies_in_cone(player.global_position, _vacuum_direction, VACUUM_RANGE, VACUUM_HALF_ANGLE_DEG):
		var pull: Vector3 = player.global_position - enemy.global_position
		pull.y = 0.0
		if pull.length() < 2.0:
			continue
		if enemy is CharacterBody3D:
			var body := enemy as CharacterBody3D
			body.velocity.x += pull.normalized().x * VACUUM_PULL_SPEED * delta * 10.0
			body.velocity.z += pull.normalized().z * VACUUM_PULL_SPEED * delta * 10.0

	# Saeure aufsaugen: einmal pro Einsatz, sobald der Spieler in einer
	# Hazard-Flaeche steht.
	if not _vacuum_absorbed_acid and _player_stands_in_hazard(player):
		_vacuum_absorbed_acid = true

	if _vacuum_timer <= 0.0 and _vacuum_absorbed_acid:
		_fire_acid_beam(player)


## BUGFIX: pruefte bisher die Gruppe "hazard" - LavaHazard (lemonade.gd)
## registriert sich aber unter "lava_hazards". Da nirgends im Projekt etwas
## der Gruppe "hazard" beitritt, lieferte diese Funktion IMMER false - die
## Saeure-Absorption des Handstaubsaugers lief seit jeher ins Leere.
func _player_stands_in_hazard(player: CharacterBody3D, range_m: float = 4.0) -> bool:
	for node: Node in get_tree().get_nodes_in_group("lava_hazards"):
		var hazard := node as Node3D
		if hazard != null and is_instance_valid(hazard):
			if hazard.global_position.distance_to(player.global_position) < range_m:
				return true
	return false


## Der zurueckgefeuerte Saeurestrahl. Dicker Zylinder nach vorn plus
## Saeure-DoT auf alles im Weg.
func _fire_acid_beam(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var start: Vector3 = player.global_position + Vector3.UP * 1.2

	var beam := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.5
	cyl.bottom_radius = 0.5
	cyl.height = VACUUM_RANGE
	beam.mesh = cyl
	beam.set_surface_override_material(0, _make_glow_material(Color(0.55, 0.95, 0.25), 0.7))
	_attach_to_world(beam, start + forward * VACUUM_RANGE * 0.5)
	beam.look_at(start + forward * VACUUM_RANGE, Vector3.UP)
	beam.rotate_object_local(Vector3.RIGHT, PI * 0.5)

	for enemy: Node3D in _enemies_in_cone(player.global_position, forward, VACUUM_RANGE, 12.0):
		StatusAcid.apply(enemy, VACUUM_ACID_DURATION, VACUUM_ACID_DAMAGE, player)
		_spawn_vfx(CORROSION_SCENE, enemy.global_position + Vector3.UP * 0.4)

	_fade_and_free(beam, 0.4, beam)


# --- A5. Omas Pfeffermuehle -------------------------------------------------
func _use_pepper_mill(player: CharacterBody3D) -> void:
	for enemy: Node3D in _enemies_near(player.global_position, PEPPER_RADIUS):
		# Niesen = kein Angriff moeglich. silenced statt stun: der Gegner
		# soll sich weiter bewegen duerfen, nur eben nicht zuschlagen.
		StatusSilenced.apply(enemy, PEPPER_SILENCE_DURATION, player)
		# Alle laufenden DoTs halten 3 s laenger.
		var manager: StatusEffectManager = StatusEffectBase.manager_of(enemy)
		if manager != null:
			manager.extend_all(PEPPER_DOT_EXTENSION)
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position + Vector3.UP * 1.8)

	_spawn_ring_wave(player.global_position, PEPPER_RADIUS, Color(0.55, 0.52, 0.48), 0.5)


# --- A6. Walkman (kaputt) ---------------------------------------------------
func _use_walkman(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position

	# Projektile zerstoeren.
	for node: Node in get_tree().get_nodes_in_group("projectiles"):
		var proj := node as Node3D
		if proj != null and is_instance_valid(proj):
			if proj.global_position.distance_to(origin) <= WALKMAN_RADIUS:
				_spawn_vfx(HIT_SPARK_SCENE, proj.global_position)
				proj.queue_free()

	for enemy: Node3D in _enemies_near(origin, WALKMAN_RADIUS):
		if enemy.has_method("apply_knockback"):
			var push: Vector3 = enemy.global_position - origin
			push.y = 0.0
			if push.length_squared() > 0.0001:
				enemy.apply_knockback(push.normalized() * WALKMAN_KNOCKBACK)
		StatusConfused.apply(enemy, WALKMAN_CONFUSE_DURATION, StatusConfused.HEAVY_MAX_ANGLE_DEG, player)

	_spawn_ring_wave(origin, WALKMAN_RADIUS, Color(0.35, 0.60, 1.0), 0.45)
	_flash_player(FLASH_WHITE)
	Juice.shake(WALKMAN_SHAKE)


# --- A7. Megafon aus der Schule ---------------------------------------------
func _use_megaphone(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var stats: PlayerStats = _stats()
	var base: float = MEGAPHONE_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)

	for enemy: Node3D in _enemies_in_cone(player.global_position, forward, MEGAPHONE_RANGE, MEGAPHONE_HALF_ANGLE_DEG):
		# Dreifacher Schaden gegen betaeubte Gegner (Design-Dokument).
		# Die confused-Synergie steckt in StatusStun.damage_multiplier_against.
		var factor: float = StatusStun.damage_multiplier_against(enemy, StatusStun.MEGAPHONE_DAMAGE_MULTIPLIER)
		var health: Health = _health_of(enemy)
		var megaphone_damage: float = base * factor
		if health != null:
			health.take_damage(megaphone_damage, player)
			_spawn_item_damage_number(enemy, megaphone_damage)
		# Interrupt: laufende Telegraphs abbrechen.
		if enemy.has_method("interrupt_attack"):
			enemy.interrupt_attack()
		StatusSilenced.apply(enemy, 0.8, player)
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)

	_spawn_cone_flash(player, forward, MEGAPHONE_RANGE, MEGAPHONE_HALF_ANGLE_DEG, Color(1.0, 0.60, 0.15))
	Juice.shake(1.2)


# --- A8. Spruehsahne-Dose ---------------------------------------------------
func _use_whipped_cream(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 3.0

	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0xFFFFFFFF

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = CREAM_RADIUS
	cyl.height = 1.5
	shape.shape = cyl
	area.add_child(shape)

	var mesh_node := MeshInstance3D.new()
	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = CREAM_RADIUS
	cyl_mesh.bottom_radius = CREAM_RADIUS
	cyl_mesh.height = 0.12
	mesh_node.mesh = cyl_mesh
	mesh_node.set_surface_override_material(0, _make_glow_material(Color(1.0, 0.98, 0.94), 0.85))
	area.add_child(mesh_node)

	_attach_to_world(area, origin + Vector3(0.0, 0.08, 0.0))

	var timer := Timer.new()
	timer.wait_time = 0.35
	timer.autostart = true
	area.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(area):
			return
		for body: Node3D in area.get_overlapping_bodies():
			if not body.is_in_group(ENEMY_GROUP):
				continue
			# Knockdown = rooted. Ein Gegner, der am Boden liegt, soll sich
			# nicht bewegen, aber sichtbar noch "leben" — deshalb rooted und
			# nicht stun.
			StatusRooted.apply(body, CREAM_KNOCKDOWN_DURATION, _player())
			_spawn_vfx(DUST_RING_SCENE, body.global_position + Vector3.UP * 0.1)

			# Synergie: loescht Brand und richtet dabei massiven Schaden an.
			if StatusBurn.active(body):
				StatusBurn.clear(body)
				var health: Health = _health_of(body)
				if health != null and health.is_alive():
					health.take_damage(CREAM_EXTINGUISH_DAMAGE, _player())
					_spawn_item_damage_number(body, CREAM_EXTINGUISH_DAMAGE)
				_spawn_vfx(HIT_SPARK_SCENE, body.global_position + Vector3.UP)
	)

	_fade_and_free(area, CREAM_LIFETIME, mesh_node)


# --- A9. Alte Ghettoblaster-Box ----------------------------------------------
func _use_boombox(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position

	for node: Node in get_tree().get_nodes_in_group("projectiles"):
		var proj := node as Node3D
		if proj != null and is_instance_valid(proj) and proj.global_position.distance_to(origin) <= BOOMBOX_RADIUS:
			_spawn_vfx(HIT_SPARK_SCENE, proj.global_position)
			proj.queue_free()

	for enemy: Node3D in _enemies_near(origin, BOOMBOX_RADIUS):
		StatusSilenced.apply(enemy, BOOMBOX_SILENCE_DURATION, player)

	_spawn_ring_wave(origin, BOOMBOX_RADIUS, Color(0.55, 0.30, 0.85), 0.5)
	_flash_player(FLASH_BLUE)
	Juice.shake(1.4)


## Synergie zu A9: +30 % Nahkampfschaden gegen stummgeschaltete Gegner.
## Nachtraeglicher Zusatzschlag - gleiches Muster wie der Laser-Pointer-Bonus.
func _apply_boombox_silence_bonus(target: Node3D, base_damage: float) -> void:
	var health: Health = _health_of(target)
	if health == null or not health.is_alive():
		return
	var bonus: float = base_damage * BOOMBOX_SILENCED_MELEE_BONUS
	health.take_damage(bonus, _player())
	_spawn_item_damage_number(target, bonus)


# --- A10. Scharfe Instant-Nudeln ---------------------------------------------
func _use_spicy_ramen(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var stats: PlayerStats = _stats()
	var damage: float = RAMEN_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)

	for enemy: Node3D in _enemies_in_cone(player.global_position, forward, RAMEN_RANGE, RAMEN_HALF_ANGLE_DEG):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(damage, player)
			_spawn_item_damage_number(enemy, damage)
		StatusBurn.apply(enemy, StatusBurn.DEFAULT_DURATION, StatusBurn.DEFAULT_DAMAGE_PER_TICK, player)
		# Interrupt: bricht einen laufenden Telegraph sofort ab.
		if enemy.has_method("interrupt_attack"):
			enemy.interrupt_attack()
		# Synergie: trifft die Flamme einen Gegner, der bereits in Saeure
		# steht (StatusAcid aktiv), explodiert sie zusaetzlich.
		if StatusAcid.active(enemy):
			health = _health_of(enemy)
			if health != null and health.is_alive():
				health.take_damage(damage, player)
				_spawn_item_damage_number(enemy, damage)
			_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)

	_spawn_cone_flash(player, forward, RAMEN_RANGE, RAMEN_HALF_ANGLE_DEG, Color(1.0, 0.45, 0.10))
	Juice.shake(0.9)


# --- A11. USB-Mini-Ventilator -------------------------------------------------
func _use_pocket_fan(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var hit_enemies: Array[Node3D] = _enemies_in_cone(player.global_position, forward, FAN_RANGE, FAN_HALF_ANGLE_DEG)

	for enemy: Node3D in hit_enemies:
		StatusSlow.apply(enemy, FAN_SLOW_DURATION, FAN_SLOW_AMOUNT, player)
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position + Vector3.UP * 0.5)

		# Synergie: ueberträgt aktive DoTs auf Nachbargegner.
		for dot_id: String in ["bleed", "burn", "acid"]:
			if not StatusEffectBase.is_active(enemy, dot_id):
				continue
			var magnitude: float = StatusEffectBase.magnitude_of(enemy, dot_id)
			for neighbor: Node3D in _enemies_near(enemy.global_position, FAN_SPREAD_RADIUS, enemy):
				neighbor.apply_status_effect(dot_id, 3.0, magnitude, player, 1.0)

	_spawn_cone_flash(player, forward, FAN_RANGE, FAN_HALF_ANGLE_DEG, Color(0.90, 0.95, 1.0))


# --- A12. Spruehdose aus dem Tunnel -------------------------------------------
## Verwendet "charm" (nicht "confused"): das Design-Dokument beschreibt
## "verliert die Orientierung" - Gegner, die sich gegenseitig angreifen, ist
## die woertlichere und wirkungsvollere Lesart davon als nur ein Fehlwinkel.
func _use_graffiti_can(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position
	for enemy: Node3D in _enemies_near(origin, GRAFFITI_RADIUS):
		StatusCharm.apply(enemy, GRAFFITI_CHARM_DURATION, player)

	_spawn_ring_wave(origin, GRAFFITI_RADIUS, Color(1.0, 0.35, 0.85), 0.6)
	_spawn_vfx(DUST_RING_SCENE, origin + Vector3.UP)
	Juice.shake(0.7)


## Kegelfoermiger Aufblitzer fuer Feuerzeug, Sauger und Megafon.
##
## Ein ConeMesh mit Spitze am Spieler, das kurz aufgeht und ausblendet.
## CylinderMesh mit top_radius = 0 statt ConeMesh: ConeMesh gibt es in
## Godot 4 nicht als eigene Klasse.
func _spawn_cone_flash(player: CharacterBody3D, forward: Vector3, range_m: float, half_angle_deg: float, color: Color) -> void:
	var cone := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = range_m * tan(deg_to_rad(half_angle_deg))
	mesh.bottom_radius = 0.15
	mesh.height = range_m
	cone.mesh = mesh
	var mat: StandardMaterial3D = _make_glow_material(color, 0.45)
	cone.set_surface_override_material(0, mat)

	var center: Vector3 = player.global_position + Vector3.UP * 1.0 + forward * (range_m * 0.5)
	_attach_to_world(cone, center)
	cone.look_at(player.global_position + Vector3.UP * 1.0 + forward * range_m, Vector3.UP)
	cone.rotate_object_local(Vector3.RIGHT, PI * 0.5)

	var tween: Tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.28)
	tween.tween_callback(func() -> void:
		if is_instance_valid(cone):
			cone.queue_free()
	)


# ============================================================================
# Nr. 51-83 — neue "Ultimate"-Items
# ============================================================================
# Alle bauen prozedural auf (kein Asset-Import), wiederverwenden bestehende
# Helfer (_enemies_near/_enemies_in_cone/_spawn_ring_wave/_spawn_vfx/
# _make_glow_material/_attach_to_world/_fade_and_free) und den
# TurretProjectile/Turret-Baustein aus scripts/hazards/, wo es passt.

# --- Nr. 51. Aufwind -----------------------------------------------------
func _use_updraft(player: CharacterBody3D) -> void:
	player.velocity.y = UPDRAFT_IMPULSE
	_spawn_ring_wave(player.global_position, 2.5, Color(0.75, 0.95, 1.0), 0.4)
	Juice.shake(0.5)


# --- Nr. 79. Heil-Orb ------------------------------------------------------
func _use_healing_orb(player: CharacterBody3D) -> void:
	if _player_health == null:
		return
	var max_hp: float = _player_health.max_health
	var instant: float = max_hp * HEALING_ORB_INSTANT_FRACTION
	_player_health.current_health = minf(_player_health.current_health + instant, max_hp)
	_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)
	_flash_player(FLASH_WHITE)
	_spawn_ring_wave(player.global_position, 2.0, Color(0.4, 1.0, 0.55), 0.5)

	var total_over_time: float = max_hp * HEALING_ORB_OVER_TIME_FRACTION
	var elapsed: float = 0.0
	var timer := Timer.new()
	timer.wait_time = 0.4
	timer.autostart = true
	add_child(timer)
	var ticks_total: int = int(HEALING_ORB_TICK_DURATION / 0.4)
	var per_tick: float = total_over_time / maxf(float(ticks_total), 1.0)
	timer.timeout.connect(func() -> void:
		elapsed += 0.4
		if _player_health != null and _player_health.is_alive():
			_player_health.current_health = minf(_player_health.current_health + per_tick, _player_health.max_health)
			_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)
		if elapsed >= HEALING_ORB_TICK_DURATION:
			timer.queue_free()
	)


# --- Nr. 78. Frost-Orb -----------------------------------------------------
func _use_slow_orb(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 3.0
	_spawn_hazard_area(origin, SLOW_ORB_RADIUS, SLOW_ORB_LIFETIME, Color(0.55, 0.85, 1.0), 0.4, func(enemy: Node3D) -> void:
		StatusSlow.apply(enemy, SLOW_ORB_SLOW_DURATION, SLOW_ORB_SLOW_AMOUNT, player)
	)


# --- Nr. 73. Brandsatz ------------------------------------------------------
func _use_incendiary(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 3.0
	_spawn_hazard_area(origin, INCENDIARY_RADIUS, INCENDIARY_LIFETIME, Color(1.0, 0.4, 0.1), INCENDIARY_TICK_INTERVAL, func(enemy: Node3D) -> void:
		StatusBurn.apply(enemy, 2.0, INCENDIARY_TICK_DAMAGE, player)
	)


# --- Nr. 70. Ergreifen -------------------------------------------------------
func _use_seize(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 2.5
	_spawn_hazard_area(origin, SEIZE_RADIUS, SEIZE_LIFETIME, Color(0.75, 0.95, 0.25), 0.4, func(enemy: Node3D) -> void:
		StatusRooted.apply(enemy, SEIZE_ROOTED_DURATION, player)
		StatusAcid.apply(enemy, 2.0, SEIZE_ACID_DAMAGE, player)
	)


# --- Nr. 76. Schlangenbiss ---------------------------------------------------
func _use_snake_bite(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 2.5
	_spawn_hazard_area(origin, SNAKE_BITE_RADIUS, SNAKE_BITE_LIFETIME, Color(0.55, 0.9, 0.35), 0.4, func(enemy: Node3D) -> void:
		StatusAcid.apply(enemy, 2.0, SNAKE_BITE_ACID_DAMAGE, player)
		StatusEffectBase.apply_raw(enemy, "vulnerable", SNAKE_BITE_VULNERABLE_DURATION, SNAKE_BITE_VULNERABLE_BONUS, player)
	)


## Gemeinsamer Baustein fuer alle "Pfuetzen"-Items (Frost-Orb, Brandsatz,
## Ergreifen, Schlangenbiss): eine Area3D, die im festen Takt (tick_interval)
## jeden ueberlappenden Gegner an on_tick uebergibt. Gleiches Grundprinzip
## wie _spawn_glue_spot, aber mit austauschbarem Effekt statt fest verdrahtetem
## StatusRooted, damit die vier Items sich nicht duplizieren.
## on_tick steht ABSICHTLICH als letzter Parameter (nicht vor tick_interval):
## ein mehrzeiliges Lambda mitten in einer Argumentliste, gefolgt von noch
## mehr Argumenten danach, ist in GDScript unnoetig fehleranfaellig - als
## letztes Argument schliesst die Klammer direkt nach dem Lambda-Block.
func _spawn_hazard_area(world_pos: Vector3, radius: float, lifetime: float, color: Color, tick_interval: float, on_tick: Callable) -> void:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0xFFFFFFFF

	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = radius
	cyl.height = 1.2
	shape.shape = cyl
	area.add_child(shape)

	var mesh_node := MeshInstance3D.new()
	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = radius
	cyl_mesh.bottom_radius = radius
	cyl_mesh.height = 0.06
	mesh_node.mesh = cyl_mesh
	mesh_node.set_surface_override_material(0, _make_glow_material(color, 0.5))
	area.add_child(mesh_node)

	_attach_to_world(area, world_pos + Vector3(0.0, 0.05, 0.0))

	var timer := Timer.new()
	timer.wait_time = tick_interval
	timer.autostart = true
	area.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(area):
			return
		for body: Node3D in area.get_overlapping_bodies():
			if body.is_in_group(ENEMY_GROUP):
				on_tick.call(body)
	)

	_fade_and_free(area, lifetime, mesh_node)


# --- Nr. 77. Barriere-Orb ----------------------------------------------------
func _use_barrier_orb(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var origin: Vector3 = player.global_position + forward * 2.5

	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = BARRIER_ORB_SIZE
	shape.shape = box
	body.add_child(shape)

	var mesh_node := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = BARRIER_ORB_SIZE
	mesh_node.mesh = box_mesh
	var mat: StandardMaterial3D = _make_glow_material(Color(0.6, 0.9, 1.0), 0.55)
	mesh_node.material_override = mat
	body.add_child(mesh_node)

	_attach_to_world(body, origin + Vector3.UP * (BARRIER_ORB_SIZE.y * 0.5))
	body.look_at(body.global_position + forward, Vector3.UP)
	body.rotate_object_local(Vector3.UP, PI * 0.5)

	_spawn_ring_wave(origin, 2.0, Color(0.6, 0.9, 1.0), 0.4)
	_fade_and_free(body, BARRIER_ORB_LIFETIME, mesh_node)


# --- Nr. 64. Schockbolzen -----------------------------------------------------
func _use_shock_bolt(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	# forward * 2.0 haelt den Spawnpunkt bewusst ausserhalb von
	# TurretProjectile.HIT_RANGE (1.2 m) - sonst wuerde der rein
	# dekorative Bolzen (der eigentliche Treffer laeuft oben schon per
	# Distanz-/Winkel-Check) sich selbst am Spieler "treffen" und sofort
	# wieder verschwinden, statt sichtbar loszufliegen.
	var origin: Vector3 = player.global_position + Vector3.UP * 1.2 + forward * 2.0
	var stats: PlayerStats = _stats()
	var damage: float = SHOCK_BOLT_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)

	var closest: Node3D = null
	var closest_dist: float = SHOCK_BOLT_RANGE
	for enemy: Node3D in _enemies_in_cone(player.global_position, forward, SHOCK_BOLT_RANGE, 8.0):
		var dist: float = player.global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = enemy

	if closest != null:
		var health: Health = _health_of(closest)
		if health != null:
			health.take_damage(damage, player)
			_spawn_item_damage_number(closest, damage)
		StatusStun.apply(closest, SHOCK_BOLT_STUN, player)
		_spawn_vfx(SPARK_YELLOW_SCENE, closest.global_position + Vector3.UP)

	TurretProjectile.spawn(self, origin, forward, 30.0, 0.0, 0.0, player)


# --- Nr. 68. Donnergrollen ---------------------------------------------------
func _use_rolling_thunder(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position
	for enemy: Node3D in _enemies_near(origin, ROLLING_THUNDER_RADIUS):
		StatusStun.apply(enemy, ROLLING_THUNDER_STUN, player)
		if enemy.has_method("apply_knockback"):
			var away: Vector3 = (enemy.global_position - origin)
			away.y = 0.0
			if away.length_squared() > 0.0001:
				enemy.call("apply_knockback", away.normalized() * ROLLING_THUNDER_KNOCKBACK)
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position + Vector3.UP * 0.5)

	_spawn_ring_wave(origin, ROLLING_THUNDER_RADIUS, Color(1.0, 0.85, 0.3), 0.7)
	Juice.shake(1.4)


# --- Nr. 67. Verwerfungslinie ------------------------------------------------
func _use_fault_line(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var origin: Vector3 = player.global_position
	var stats: PlayerStats = _stats()
	var damage: float = 18.0 * (stats.get_damage_multiplier() if stats != null else 1.0)

	for enemy: Node3D in _enemies_in_cone(origin, forward, FAULT_LINE_RANGE, 6.0):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(damage, player)
			_spawn_item_damage_number(enemy, damage)
		StatusStun.apply(enemy, FAULT_LINE_STUN, player)
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP * 0.2)

	_spawn_cone_flash(player, forward, FAULT_LINE_RANGE, 6.0, Color(0.85, 0.55, 0.2))
	Juice.shake(0.8)


# --- Nr. 72. Stim-Beacon ------------------------------------------------------
## Kein neuer Dauerzustand in _physics_process noetig: der Beacon selbst
## erneuert per Timer alle 0.4 s einen add_timed_modifier() mit 0.5 s
## Laufzeit, solange der Spieler in Reichweite ist - verlaesst er den
## Radius, laeuft der Modifier von selbst aus (PlayerStats._process()).
func _use_stim_beacon(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 2.0
	var stats: PlayerStats = _stats()

	var mesh_node := MeshInstance3D.new()
	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = 0.35
	cyl_mesh.bottom_radius = 0.5
	cyl_mesh.height = 1.4
	mesh_node.mesh = cyl_mesh
	var mat: StandardMaterial3D = _make_glow_material(Color(1.0, 0.55, 0.15), 0.85)
	mesh_node.material_override = mat
	_attach_to_world(mesh_node, origin + Vector3.UP * 0.7)

	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.55, 0.15)
	light.light_energy = 1.4
	light.omni_range = STIM_BEACON_RADIUS
	light.shadow_enabled = false
	mesh_node.add_child(light)

	var timer := Timer.new()
	timer.wait_time = 0.4
	timer.autostart = true
	mesh_node.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(mesh_node):
			return
		var cur_player: CharacterBody3D = _player()
		if cur_player == null or stats == null:
			return
		if mesh_node.global_position.distance_to(cur_player.global_position) <= STIM_BEACON_RADIUS:
			stats.add_timed_modifier("stim_beacon", PlayerStats.STAT_MOVE_SPEED, 0.5, 0.0, STIM_BEACON_SPEED_MUL)
			stats.add_timed_modifier("stim_beacon_dmg", PlayerStats.STAT_DAMAGE, 0.5, 0.0, STIM_BEACON_DAMAGE_MUL)
	)

	_spawn_ring_wave(origin, STIM_BEACON_RADIUS, Color(1.0, 0.55, 0.15), 0.5)
	_fade_and_free(mesh_node, STIM_BEACON_LIFETIME, mesh_node)


# --- Nr. 65. Jaegerzorn -------------------------------------------------------
## "Durchdringt Waende": bewusst KEIN Raycast-Blockcheck wie bei normalen
## Geschossen - stattdessen ein reiner Distanz-/Winkel-Check
## (_enemies_in_cone), der Geometrie schlicht ignoriert. Drei schmale Strahlen
## im Faecher statt einem, damit "drei Energiestrahlen" auch optisch stimmt.
func _use_hunters_fury(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var stats: PlayerStats = _stats()
	var damage: float = HUNTERS_FURY_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)
	var hit_ids: Array[int] = []

	var half: float = float(HUNTERS_FURY_BEAM_COUNT - 1) * 0.5
	for i: int in range(HUNTERS_FURY_BEAM_COUNT):
		var offset_deg: float = (float(i) - half) * HUNTERS_FURY_BEAM_SPREAD_DEG
		var beam_dir: Vector3 = forward.rotated(Vector3.UP, deg_to_rad(offset_deg))
		for enemy: Node3D in _enemies_in_cone(player.global_position, beam_dir, HUNTERS_FURY_RANGE, 4.0):
			var id: int = enemy.get_instance_id()
			if hit_ids.has(id):
				continue
			hit_ids.append(id)
			var health: Health = _health_of(enemy)
			if health != null:
				health.take_damage(damage, player)
				_spawn_item_damage_number(enemy, damage)
			_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
		_spawn_cone_flash(player, beam_dir, HUNTERS_FURY_RANGE, 4.0, Color(0.6, 0.85, 1.0))

	Juice.shake(1.1)


# --- Nr. 82. Geschuetzturm (Item) ---------------------------------------------
## Wiederverwendet die Turret-Klasse aus scripts/hazards/turret.gd, aber im
## "friendly"-Modus: statt den Spieler zu beschiessen, sucht dieser Turret
## per Timer den naechsten Gegner in Reichweite und schaedigt ihn direkt
## (gleiches Direktschaden-Prinzip wie EnemyAI._strike_charm_target - ein
## echtes homing/zielsuchendes Projektil braucht hier keinen Mehrwert).
func _use_turret_item(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 2.0

	var body := StaticBody3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(1.2, 1.6, 1.2)
	var mesh_node := MeshInstance3D.new()
	mesh_node.mesh = box_mesh
	mesh_node.position = Vector3.UP * 0.8
	var mat: StandardMaterial3D = _make_glow_material(Color(0.3, 0.85, 1.0), 1.0)
	mesh_node.material_override = mat
	body.add_child(mesh_node)

	var light := OmniLight3D.new()
	light.light_color = Color(0.3, 0.85, 1.0)
	light.light_energy = 1.0
	light.omni_range = 4.0
	light.shadow_enabled = false
	light.position = Vector3.UP * 1.8
	body.add_child(light)

	_attach_to_world(body, origin)

	var timer := Timer.new()
	timer.wait_time = TURRET_ITEM_FIRE_INTERVAL
	timer.autostart = true
	body.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(body):
			return
		var target: Node3D = null
		var closest: float = TURRET_ITEM_RANGE
		for enemy: Node3D in _enemies_near(body.global_position, TURRET_ITEM_RANGE):
			var dist: float = body.global_position.distance_to(enemy.global_position)
			if dist < closest:
				closest = dist
				target = enemy
		if target == null:
			return
		var health: Health = _health_of(target)
		if health != null:
			health.take_damage(TURRET_ITEM_DAMAGE, player)
			_spawn_item_damage_number(target, TURRET_ITEM_DAMAGE)
		TurretProjectile.spawn(self, body.global_position + Vector3.UP, (target.global_position - body.global_position).normalized(), 22.0, 0.0, 0.0, player)
	)

	_fade_and_free(body, TURRET_ITEM_LIFETIME, mesh_node)


# --- Nr. 74. Orbitalschlag ----------------------------------------------------
func _use_orbital_strike(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * ORBITAL_STRIKE_RANGE_AHEAD

	var telegraph := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = ORBITAL_STRIKE_RADIUS
	ring_mesh.bottom_radius = ORBITAL_STRIKE_RADIUS
	ring_mesh.height = 0.05
	telegraph.mesh = ring_mesh
	var mat: StandardMaterial3D = _make_glow_material(Color(1.0, 0.2, 0.2), 0.5)
	telegraph.material_override = mat
	_attach_to_world(telegraph, origin + Vector3.UP * 0.05)

	var tween: Tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.9, ORBITAL_STRIKE_DELAY)

	var timer := Timer.new()
	timer.wait_time = ORBITAL_STRIKE_DELAY
	timer.one_shot = true
	timer.autostart = true
	telegraph.add_child(timer)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(telegraph):
			var strike_pos: Vector3 = telegraph.global_position
			var stats: PlayerStats = _stats()
			var damage: float = ORBITAL_STRIKE_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)
			for enemy: Node3D in _enemies_near(strike_pos, ORBITAL_STRIKE_RADIUS):
				var health: Health = _health_of(enemy)
				if health != null:
					health.take_damage(damage, player)
					_spawn_item_damage_number(enemy, damage)
				if enemy.has_method("interrupt_attack"):
					enemy.interrupt_attack()
				_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
			_spawn_ring_wave(strike_pos, ORBITAL_STRIKE_RADIUS, Color(1.0, 0.3, 0.1), 0.8)
			Juice.shake(2.0)
			Juice.hit_stop(Juice.DURATION_HEAVY)
			telegraph.queue_free()
	)


# --- Nr. 60. Verschlingen (passiv) --------------------------------------------
## Wird direkt aus _on_player_hit_enemy() im was_kill-Zweig aufgerufen
## (siehe dort) - hier nur der Heil-Effekt selbst.
func _apply_devour(player: CharacterBody3D) -> void:
	if _player_health == null or not _player_health.is_alive():
		return
	var heal: float = _player_health.max_health * DEVOUR_HEAL_FRACTION
	_player_health.current_health = minf(_player_health.current_health + heal, _player_health.max_health)
	_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)
	_flash_player(FLASH_WHITE)


# --- Nr. 61. Kaiserin (passiv) ------------------------------------------------
## Wird aus _on_player_hit_enemy() im was_kill-Zweig aufgerufen. Fuer das
## "laedt dein Aktiv-Item ein Stueck auf" gibt es keine Teil-Aufladung in
## item_manager.gd (nur force_recharge_active() = volle Aufladung) - deshalb
## dieselbe Loesung wie bei der Nonnen-Kutte (P17): eine Chance auf volle
## statt einer garantierten Teil-Aufladung.
## Nur waehrend _empress_buff_timer > 0.0 aufgerufen (siehe was_kill-Zweig
## in _on_player_hit_enemy) - "Kills waehrend der Wirkung", nicht "Kills,
## solange man das Item besitzt".
func _apply_empress() -> void:
	if _player_health != null:
		_player_health.set_invulnerable(EMPRESS_INVULN_DURATION)
	_flash_player(FLASH_WHITE)
	if _items.has_method("force_recharge_active"):
		_items.force_recharge_active()


# --- Nr. 61. Kaiserin (aktiv) -------------------------------------------------
func _use_empress(player: CharacterBody3D) -> void:
	_empress_buff_timer = EMPRESS_BUFF_DURATION
	var stats: PlayerStats = _stats()
	if stats != null:
		stats.add_timed_modifier(
			"buff:empress", PlayerStats.STAT_MOVE_SPEED,
			EMPRESS_BUFF_DURATION, 0.0, EMPRESS_SPEED_MULTIPLIER
		)
	_flash_player(FLASH_WHITE)
	_spawn_ring_wave(player.global_position, 2.5, Color(0.85, 0.2, 0.35), 0.5)


func _tick_empress(delta: float) -> void:
	if _empress_buff_timer > 0.0:
		_empress_buff_timer = maxf(_empress_buff_timer - delta, 0.0)


# --- Nr. 52. Klingensturm -----------------------------------------------------
func _use_blade_storm(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var stats: PlayerStats = _stats()
	var damage: float = BLADE_STORM_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)
	var got_kill: bool = false

	var half: float = float(BLADE_STORM_COUNT - 1) * 0.5
	for i: int in range(BLADE_STORM_COUNT):
		var offset_deg: float = (float(i) - half) * (BLADE_STORM_SPREAD_DEG / float(BLADE_STORM_COUNT))
		var beam_dir: Vector3 = forward.rotated(Vector3.UP, deg_to_rad(offset_deg))
		var closest: Node3D = null
		var closest_dist: float = BLADE_STORM_RANGE
		for enemy: Node3D in _enemies_in_cone(player.global_position, beam_dir, BLADE_STORM_RANGE, 10.0):
			var dist: float = player.global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = enemy
		if closest != null:
			var health: Health = _health_of(closest)
			if health != null:
				var was_alive: bool = health.is_alive()
				health.take_damage(damage, player)
				_spawn_item_damage_number(closest, damage)
				if was_alive and not health.is_alive():
					got_kill = true
			_spawn_vfx(SPARK_YELLOW_SCENE, closest.global_position + Vector3.UP)
		TurretProjectile.spawn(self, player.global_position + Vector3.UP * 1.2 + beam_dir * 1.5, beam_dir, 26.0, 0.0, 0.0, player)

	if got_kill and _items.has_method("force_recharge_active"):
		_items.force_recharge_active()

	Juice.shake(1.0)


# --- Nr. 53. Feuerwand --------------------------------------------------------
func _use_blaze(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var origin: Vector3 = player.global_position
	for i: int in range(BLAZE_SEGMENTS):
		var seg_pos: Vector3 = origin + forward * (BLAZE_SEGMENT_SPACING * float(i + 1))
		_spawn_hazard_area(seg_pos, BLAZE_SEGMENT_RADIUS, BLAZE_LIFETIME, Color(1.0, 0.35, 0.05), 0.5, func(enemy: Node3D) -> void:
			StatusBurn.apply(enemy, 1.5, BLAZE_TICK_DAMAGE, player)
		)
	Juice.shake(0.6)


# --- Nr. 54. Heisse Haende ----------------------------------------------------
func _use_hot_hands(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * HOT_HANDS_RANGE_AHEAD
	var stats: PlayerStats = _stats()
	var damage: float = HOT_HANDS_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)

	for enemy: Node3D in _enemies_near(origin, HOT_HANDS_RADIUS):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(damage, player)
			_spawn_item_damage_number(enemy, damage)
		StatusBurn.apply(enemy, StatusBurn.DEFAULT_DURATION, StatusBurn.DEFAULT_DAMAGE_PER_TICK, player)
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)

	_spawn_ring_wave(origin, HOT_HANDS_RADIUS, Color(1.0, 0.5, 0.1), 0.5)
	Juice.shake(1.0)


# --- Nr. 55. Run It Back ------------------------------------------------------
## Setzt nur die Marke - der eigentliche Rettungs-Effekt sitzt in
## _on_player_damaged() (siehe dort), weil nur dort bekannt ist, WANN der
## Spieler stirbt.
func _use_run_it_back(player: CharacterBody3D) -> void:
	_run_it_back_anchor = player.global_position
	_run_it_back_active = true
	_spawn_ring_wave(_run_it_back_anchor, 2.0, Color(0.4, 1.0, 0.9), 0.5)
	_flash_player(FLASH_WHITE)

	var timer := get_tree().create_timer(RUN_IT_BACK_LIFETIME)
	timer.timeout.connect(func() -> void:
		_run_it_back_active = false
	)


# --- Nr. 56. Boom-Bot ---------------------------------------------------------
func _use_boom_bot(player: CharacterBody3D) -> void:
	var target: Node3D = null
	var closest: float = INF
	for enemy: Node3D in _enemies_near(player.global_position, 30.0):
		var dist: float = player.global_position.distance_to(enemy.global_position)
		if dist < closest:
			closest = dist
			target = enemy
	if target == null:
		return

	var on_strike: Callable = func(hit_target: Node3D) -> void:
		_explode_boom_bot(hit_target.global_position, player)
	HomingBolt.spawn(
		self, player.global_position + Vector3.UP * 0.6, target, Color(0.9, 0.3, 0.2),
		on_strike, BOOM_BOT_SPEED, BOOM_BOT_LIFETIME, false, player
	)


func _explode_boom_bot(pos: Vector3, player: CharacterBody3D) -> void:
	var stats: PlayerStats = _stats()
	var damage: float = BOOM_BOT_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)
	for enemy: Node3D in _enemies_near(pos, BOOM_BOT_RADIUS):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(damage, player)
			_spawn_item_damage_number(enemy, damage)
	_spawn_ring_wave(pos, BOOM_BOT_RADIUS, Color(1.0, 0.5, 0.1), 0.6)
	Juice.shake(1.2)
	Juice.hit_stop(Juice.DURATION_HEAVY)


# --- Nr. 57. Streugranaten ----------------------------------------------------
func _use_paint_shells(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var right: Vector3 = forward.cross(Vector3.UP).normalized()
	var stats: PlayerStats = _stats()
	var damage: float = PAINT_SHELLS_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)

	for i: int in range(PAINT_SHELLS_COUNT):
		var t: float = float(i) / maxf(float(PAINT_SHELLS_COUNT - 1), 1.0)
		var lateral: float = lerpf(-PAINT_SHELLS_SPREAD, PAINT_SHELLS_SPREAD, t)
		var landing: Vector3 = player.global_position + forward * (4.0 + randf_range(-0.5, 1.5)) + right * lateral

		var timer := get_tree().create_timer(PAINT_SHELLS_FUSE + randf_range(0.0, 0.15))
		timer.timeout.connect(func() -> void:
			for enemy: Node3D in _enemies_near(landing, PAINT_SHELLS_RADIUS):
				var health: Health = _health_of(enemy)
				if health != null:
					health.take_damage(damage, player)
					_spawn_item_damage_number(enemy, damage)
			_spawn_ring_wave(landing, PAINT_SHELLS_RADIUS, Color(1.0, 0.6, 0.15), 0.4)
		)
		_spawn_vfx(DUST_RING_SCENE, landing)

	Juice.shake(0.8)


# --- Nr. 58. Showstopper ------------------------------------------------------
func _use_showstopper(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * SHOWSTOPPER_RANGE_AHEAD
	var stats: PlayerStats = _stats()
	var damage: float = SHOWSTOPPER_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)

	for enemy: Node3D in _enemies_near(origin, SHOWSTOPPER_RADIUS):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(damage, player)
			_spawn_item_damage_number(enemy, damage)
		if enemy.has_method("apply_knockback"):
			var away: Vector3 = enemy.global_position - origin
			away.y = 0.0
			if away.length_squared() > 0.0001:
				enemy.call("apply_knockback", away.normalized() * SHOWSTOPPER_KNOCKBACK)
		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)

	_spawn_ring_wave(origin, SHOWSTOPPER_RADIUS, Color(1.0, 0.4, 0.05), 0.9)
	Juice.shake(2.2)
	Juice.hit_stop(Juice.DURATION_HEAVY)


# --- Nr. 59. Schwebendes Auge --------------------------------------------------
func _use_leer(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 2.5 + Vector3.UP * 1.6

	var eye := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.4
	sphere.height = 0.8
	eye.mesh = sphere
	var mat: StandardMaterial3D = _make_glow_material(Color(0.85, 0.2, 0.9), 1.0)
	eye.material_override = mat

	var light := OmniLight3D.new()
	light.light_color = Color(0.85, 0.2, 0.9)
	light.light_energy = 1.3
	light.omni_range = LEER_RADIUS
	light.shadow_enabled = false
	eye.add_child(light)

	_attach_to_world(eye, origin)

	var timer := Timer.new()
	timer.wait_time = LEER_TICK_INTERVAL
	timer.autostart = true
	eye.add_child(timer)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(eye):
			return
		for enemy: Node3D in _enemies_near(eye.global_position, LEER_RADIUS):
			StatusConfused.apply(enemy, LEER_CONFUSE_DURATION, StatusConfused.DEFAULT_MAX_ANGLE_DEG, player)
		_spawn_ring_wave(eye.global_position, LEER_RADIUS, Color(0.85, 0.2, 0.9), 0.4)
	)

	_fade_and_free(eye, LEER_LIFETIME, eye)


# --- Nr. 62. Koeder ------------------------------------------------------------
func _use_fakeout(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 3.0

	var decoy := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	decoy.mesh = capsule
	var mat: StandardMaterial3D = _make_glow_material(Color(0.3, 0.9, 1.0), 0.9)
	decoy.material_override = mat
	_attach_to_world(decoy, origin + Vector3.UP * 0.8)

	var timer := get_tree().create_timer(FAKEOUT_LIFETIME)
	timer.timeout.connect(func() -> void:
		if not is_instance_valid(decoy):
			return
		for enemy: Node3D in _enemies_near(decoy.global_position, FAKEOUT_RADIUS):
			StatusConfused.apply(enemy, LEER_CONFUSE_DURATION, StatusConfused.DEFAULT_MAX_ANGLE_DEG, player)
		_spawn_ring_wave(decoy.global_position, FAKEOUT_RADIUS, Color(0.3, 0.9, 1.0), 0.6)
		Juice.shake(0.7)
		decoy.queue_free()
	)


# --- Nr. 63. Portalanker -------------------------------------------------------
func _use_gatecrash(player: CharacterBody3D) -> void:
	if _gatecrash_active:
		_gatecrash_active = false
		player.global_position = _gatecrash_anchor
		_spawn_ring_wave(_gatecrash_anchor, 2.0, Color(0.6, 0.4, 1.0), 0.4)
		_flash_player(FLASH_BLUE)
		return

	_gatecrash_anchor = player.global_position
	_gatecrash_active = true
	_spawn_ring_wave(_gatecrash_anchor, 2.0, Color(0.6, 0.4, 1.0), 0.4)

	var timer := get_tree().create_timer(GATECRASH_LIFETIME)
	timer.timeout.connect(func() -> void:
		_gatecrash_active = false
	)


# --- Nr. 66. Nachbeben ---------------------------------------------------------
func _use_aftershock(player: CharacterBody3D) -> void:
	var forward: Vector3 = _player_forward(player)
	var stats: PlayerStats = _stats()
	var damage: float = AFTERSHOCK_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)

	var impact_pos: Vector3 = player.global_position + forward * AFTERSHOCK_RANGE
	for enemy: Node3D in _enemies_in_cone(player.global_position, forward, AFTERSHOCK_RANGE, 6.0):
		impact_pos = enemy.global_position
		break

	var timer := get_tree().create_timer(0.35)
	timer.timeout.connect(func() -> void:
		for enemy: Node3D in _enemies_near(impact_pos, AFTERSHOCK_RADIUS):
			var health: Health = _health_of(enemy)
			if health != null:
				health.take_damage(damage, player)
				_spawn_item_damage_number(enemy, damage)
			_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
		_spawn_ring_wave(impact_pos, AFTERSHOCK_RADIUS, Color(0.8, 0.3, 1.0), 0.6)
		Juice.shake(1.3)
	)
	_spawn_cone_flash(player, forward, AFTERSHOCK_RANGE, 6.0, Color(0.8, 0.3, 1.0))


# --- Nr. 69. Schatten-Pirscher --------------------------------------------------
func _use_prowler(player: CharacterBody3D) -> void:
	var target: Node3D = null
	var closest: float = INF
	for enemy: Node3D in _enemies_near(player.global_position, 30.0):
		var dist: float = player.global_position.distance_to(enemy.global_position)
		if dist < closest:
			closest = dist
			target = enemy
	if target == null:
		return

	var on_strike: Callable = func(hit_target: Node3D) -> void:
		StatusConfused.apply(hit_target, PROWLER_CONFUSE_DURATION, StatusConfused.DEFAULT_MAX_ANGLE_DEG, player)
		StatusSilenced.apply(hit_target, PROWLER_SILENCE_DURATION, player)
		_spawn_vfx(DUST_RING_SCENE, hit_target.global_position + Vector3.UP * 0.5)
	HomingBolt.spawn(
		self, player.global_position + Vector3.UP * 0.6, target, Color(0.25, 0.1, 0.4),
		on_strike, PROWLER_SPEED, PROWLER_LIFETIME, true, player
	)


# --- Nr. 71. Anbruch der Nacht --------------------------------------------------
## "Durch Waende hindurch": bewusst kein Raycast-/Sichtlinien-Check, siehe
## Jaegerzorn (Nr. 65) weiter oben - reiner Umkreis-Check ignoriert Geometrie.
func _use_nightfall(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position
	for enemy: Node3D in _enemies_near(origin, NIGHTFALL_RADIUS):
		StatusSlow.apply(enemy, NIGHTFALL_SLOW_DURATION, NIGHTFALL_SLOW_AMOUNT, player)
		StatusSilenced.apply(enemy, NIGHTFALL_SILENCE_DURATION, player)
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position + Vector3.UP * 0.5)

	_spawn_ring_wave(origin, NIGHTFALL_RADIUS, Color(0.15, 0.1, 0.35), 0.8)
	Juice.shake(0.9)


# --- Nr. 75. Paranoia -----------------------------------------------------------
func _use_paranoia(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position
	for enemy: Node3D in _enemies_near(origin, PARANOIA_RADIUS):
		StatusConfused.apply(enemy, PARANOIA_CONFUSE_DURATION, StatusConfused.DEFAULT_MAX_ANGLE_DEG, player)
		StatusSilenced.apply(enemy, PARANOIA_SILENCE_DURATION, player)
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position + Vector3.UP * 0.5)

	_spawn_ring_wave(origin, PARANOIA_RADIUS, Color(0.5, 0.2, 0.6), 0.5)


# --- Nr. 80. Nano-Schwarm ---------------------------------------------------------
func _use_nanoswarm(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position + _player_forward(player) * 3.0
	var armed: bool = false
	var stats: PlayerStats = _stats()
	var damage: float = NANOSWARM_DAMAGE * (stats.get_damage_multiplier() if stats != null else 1.0)

	var mesh_node := MeshInstance3D.new()
	var cyl_mesh := CylinderMesh.new()
	cyl_mesh.top_radius = 0.3
	cyl_mesh.bottom_radius = 0.3
	cyl_mesh.height = 0.08
	mesh_node.mesh = cyl_mesh
	var mat: StandardMaterial3D = _make_glow_material(Color(0.5, 1.0, 0.4), 0.0)
	mesh_node.material_override = mat
	_attach_to_world(mesh_node, origin + Vector3.UP * 0.05)

	var arm_timer := get_tree().create_timer(NANOSWARM_ARM_DELAY)
	arm_timer.timeout.connect(func() -> void:
		armed = true
		if is_instance_valid(mesh_node):
			mat.albedo_color.a = 0.7
			mat.emission_energy_multiplier = 2.0
	)

	var check_timer := Timer.new()
	check_timer.wait_time = 0.25
	check_timer.autostart = true
	mesh_node.add_child(check_timer)
	check_timer.timeout.connect(func() -> void:
		if not armed or not is_instance_valid(mesh_node):
			return
		for enemy: Node3D in _enemies_near(mesh_node.global_position, NANOSWARM_TRIGGER_RADIUS):
			for blast_enemy: Node3D in _enemies_near(mesh_node.global_position, NANOSWARM_BLAST_RADIUS):
				var health: Health = _health_of(blast_enemy)
				if health != null:
					health.take_damage(damage, player)
					_spawn_item_damage_number(blast_enemy, damage)
			_spawn_ring_wave(mesh_node.global_position, NANOSWARM_BLAST_RADIUS, Color(0.5, 1.0, 0.4), 0.6)
			Juice.shake(1.4)
			Juice.hit_stop(Juice.DURATION_HEAVY)
			mesh_node.queue_free()
			return
	)

	_fade_and_free(mesh_node, NANOSWARM_LIFETIME, mesh_node)


# --- Nr. 81. Alarm-Bot -----------------------------------------------------------
func _use_alarmbot(player: CharacterBody3D) -> void:
	var target: Node3D = null
	var closest: float = INF
	for enemy: Node3D in _enemies_near(player.global_position, 30.0):
		var dist: float = player.global_position.distance_to(enemy.global_position)
		if dist < closest:
			closest = dist
			target = enemy
	if target == null:
		return

	var on_strike: Callable = func(hit_target: Node3D) -> void:
		StatusEffectBase.apply_raw(hit_target, "vulnerable", ALARMBOT_VULNERABLE_DURATION, ALARMBOT_VULNERABLE_BONUS, player)
		_spawn_vfx(SPARK_YELLOW_SCENE, hit_target.global_position + Vector3.UP)
		_spawn_ring_wave(hit_target.global_position, 2.0, Color(1.0, 0.85, 0.1), 0.35)
	HomingBolt.spawn(
		self, player.global_position + Vector3.UP * 0.6, target, Color(1.0, 0.85, 0.1),
		on_strike, ALARMBOT_SPEED, ALARMBOT_LIFETIME, false, player
	)


# --- Nr. 83. Lockdown -------------------------------------------------------------
func _use_lockdown(player: CharacterBody3D) -> void:
	var origin: Vector3 = player.global_position

	var telegraph := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = LOCKDOWN_RADIUS
	ring_mesh.bottom_radius = LOCKDOWN_RADIUS
	ring_mesh.height = 0.05
	telegraph.mesh = ring_mesh
	var mat: StandardMaterial3D = _make_glow_material(Color(1.0, 0.1, 0.1), 0.35)
	telegraph.material_override = mat
	_attach_to_world(telegraph, origin + Vector3.UP * 0.05)

	var tween: Tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.85, LOCKDOWN_CHANNEL_TIME)

	var timer := get_tree().create_timer(LOCKDOWN_CHANNEL_TIME)
	timer.timeout.connect(func() -> void:
		var cur_player: CharacterBody3D = _player()
		var strike_pos: Vector3 = cur_player.global_position if cur_player != null else origin
		for enemy: Node3D in _enemies_near(strike_pos, LOCKDOWN_RADIUS):
			StatusStun.apply(enemy, LOCKDOWN_STUN_DURATION, player)
			StatusSilenced.apply(enemy, LOCKDOWN_SILENCE_DURATION, player)
			if enemy.has_method("interrupt_attack"):
				enemy.interrupt_attack()
			_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
		_spawn_ring_wave(strike_pos, LOCKDOWN_RADIUS, Color(1.0, 0.1, 0.1), 0.9)
		Juice.shake(2.0)
		Juice.hit_stop(Juice.DURATION_HEAVY)
		if is_instance_valid(telegraph):
			telegraph.queue_free()
	)
