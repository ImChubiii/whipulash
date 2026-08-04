# res://scripts/items/item_catalog.gd
extends RefCounted
class_name ItemCatalog

# ============================================================================
# ItemCatalog — alle Items als Code statt als .tres-Dateien.
# ============================================================================
# BEWUSSTE ENTSCHEIDUNG: Items im Code zu definieren hat hier drei Vorteile:
#   * Ein neues Item ist ein Funktionsaufruf, kein Datei-Anlege-Ritual.
#   * Balancing-Aenderungen sind im Git-Diff lesbar (eine .tres-Aenderung
#     ist es nicht).
#   * Es gibt keine kaputten Resource-Pfade, wenn Ordner umbenannt werden.
#
# RARITY: jedes Item bekommt eine Seltenheitsstufe statt einer handgesetzten
# Sockelfarbe. Die Farbe leitet ItemData daraus ab — grau / gruen / blau /
# lila / rot, aufsteigend. NIEMALS zusaetzlich pedestal_color setzen: dessen
# Setter markiert das Item als "Farbe von Hand gesetzt" und die Rarity-Farbe
# wird still ueberschrieben.
#
# Die Einstufung folgt der Wirkung, nicht dem Geschmack:
#   COMMON     - kleiner, dauerhafter Bonus ohne Spielaenderung
#   UNCOMMON   - spuerbarer Bonus oder ein Effekt mit Bedingung
#   RARE       - aendert, wie man einen Kampf angeht
#   EPIC       - aktive Faehigkeit oder starker Dauereffekt
#   LEGENDARY  - haelt fuer den ganzen Run her
#
# ############################################################################
# PHASE 4 — 20 PASSIVE + 8 AKTIVE ITEMS
# ############################################################################
# Die Reihenfolge folgt dem Design-Dokument, NICHT der Rarity. Wer ein Item
# sucht, findet es an derselben Stelle wie im Dokument.
#
# WAS HIER STEHT UND WAS NICHT:
# Items, die AUSSCHLIESSLICH Stat-Boni geben, brauchen keinen Eintrag in
# item_behaviours.gd — stat_modifiers unten reicht. Alles mit Bedingung,
# Timer, Zufall, Statuseffekt oder VFX steht dort.
#
# ############################################################################
# AKTIV-ITEMS: SEKUNDEN STATT RAEUME
# ############################################################################
# Das Design-Dokument nennt fuer sieben der acht Aktiv-Items einen Cooldown
# in SEKUNDEN. Das alte System lud ueber geclearte Raeume auf. ItemData hat
# dafuer jetzt cooldown_seconds; charge_rooms bleibt fuer die Bestandsitems.
#
# EINZIGE AUSNAHME: das Schulbibliotheks-Buch ("1x pro Etage"). Das ist weder
# Zeit noch Raumzahl — es laeuft ueber eine eigene Sperre in
# item_behaviours.gd (_book_used_in_stage) und bekommt deshalb weder
# cooldown_seconds noch charge_rooms.
#
# ICONS: bleiben leer. Sobald es Texturen gibt, hier per
# load("res://textures/items/...") zuweisen.

# --- Bestandsitems (Phase 1-3) ----------------------------------------------
const ID_WOODEN_SPOON: String = "wooden_spoon"
const ID_RUSTY_CLEAVER: String = "rusty_cleaver"
const ID_STATIC_SOCK: String = "static_sock"
const ID_BRIMSTONE_HORNS: String = "brimstone_horns"
const ID_HOLY_OIL: String = "holy_oil"
const ID_JUMPER_CABLES: String = "jumper_cables"
const ID_MAGNETIC_COMPASS: String = "magnetic_compass"
const ID_ACID_BOOTS: String = "acid_boots"

# --- Phase 4: 20 passive Items ----------------------------------------------
const ID_PROTEIN_SHAKE: String = "protein_shake"
const ID_TIGHT_PANTS: String = "tight_pants"
const ID_PLASTIC_HALO: String = "plastic_halo"
const ID_BLOOD_PACT: String = "blood_pact"
const ID_ROOF_NAIL: String = "roof_nail"
const ID_CHEWING_GUM: String = "chewing_gum"
const ID_BROKEN_TOASTER: String = "broken_toaster"
const ID_HAIRSPRAY: String = "hairspray"
const ID_MODEM_56K: String = "modem_56k"
const ID_LASER_POINTER: String = "laser_pointer"
const ID_RICE_PUDDING: String = "rice_pudding"
const ID_TENNIS_BALL: String = "tennis_ball"
const ID_DISCO_BALL: String = "disco_ball"
const ID_ICE_BAG: String = "ice_bag"
const ID_KNITTING_NEEDLES: String = "knitting_needles"
const ID_DEVIL_OUTFIT: String = "devil_outfit"
const ID_NUN_HABIT: String = "nun_habit"
const ID_HANDBALL_PADS: String = "handball_pads"
const ID_GOLDEN_CREDIT_CARD: String = "golden_credit_card"
const ID_STILETTO_HEELS: String = "stiletto_heels"

# --- Tabellen-Nr. 41-50 (2.28-2.37): urspruenglich fehlende Passiv-Items ----
const ID_MOSQUITO_SPRAY: String = "mosquito_spray"
const ID_VAMPIRE_TEETH: String = "vampire_teeth"
const ID_EXECUTIONER_HOOD: String = "executioner_hood"
const ID_CHILI_OIL: String = "chili_oil"
const ID_BATTERY_PACK: String = "battery_pack"
const ID_CAR_ALARM: String = "car_alarm"
const ID_SUPER_GLUE: String = "super_glue"
const ID_ROLLER_SKATES: String = "roller_skates"
const ID_BUBBLE_GUM: String = "bubble_gum"
const ID_COPPER_WIRE: String = "copper_wire"

# --- Neuzugang: Papp-Wahrsagerbrett ------------------------------------------
const ID_OUIJA_BOARD: String = "ouija_board"

# --- Phase 4: 8 aktive Items ------------------------------------------------
const ID_STORM_LIGHTER: String = "storm_lighter"
const ID_LIBRARY_BOOK: String = "library_book"
const ID_CURSED_DIE: String = "cursed_die"
const ID_HAND_VACUUM: String = "hand_vacuum"
const ID_PEPPER_MILL: String = "pepper_mill"
const ID_WALKMAN: String = "walkman"
const ID_MEGAPHONE: String = "megaphone"
const ID_WHIPPED_CREAM: String = "whipped_cream"

# --- Tabellen-Nr. 10-13 (1.10-1.13): urspruenglich fehlende Aktiv-Items ----
const ID_BOOMBOX: String = "boombox"
const ID_SPICY_RAMEN: String = "spicy_ramen"
const ID_POCKET_FAN: String = "pocket_fan"
const ID_GRAFFITI_CAN: String = "graffiti_can"

# --- Tabellen-Nr. 51-83: neue Items (Auszug - siehe item_behaviours.gd) -----
const ID_UPDRAFT: String = "updraft"
const ID_HEALING_ORB: String = "healing_orb"
const ID_SLOW_ORB: String = "slow_orb"
const ID_INCENDIARY: String = "incendiary"
const ID_BARRIER_ORB: String = "barrier_orb"
const ID_SHOCK_BOLT: String = "shock_bolt"
const ID_ROLLING_THUNDER: String = "rolling_thunder"
const ID_FAULT_LINE: String = "fault_line"
const ID_STIM_BEACON: String = "stim_beacon"
const ID_SEIZE: String = "seize"
const ID_DEVOUR: String = "devour"
const ID_HUNTERS_FURY: String = "hunters_fury"
const ID_TURRET: String = "turret"
const ID_ORBITAL_STRIKE: String = "orbital_strike"
const ID_SNAKE_BITE: String = "snake_bite"
const ID_BLADE_STORM: String = "blade_storm"
const ID_BLAZE: String = "blaze"
const ID_HOT_HANDS: String = "hot_hands"
const ID_RUN_IT_BACK: String = "run_it_back"
const ID_BOOM_BOT: String = "boom_bot"
const ID_PAINT_SHELLS: String = "paint_shells"
const ID_SHOWSTOPPER: String = "showstopper"
const ID_LEER: String = "leer"
const ID_EMPRESS: String = "empress"
const ID_FAKEOUT: String = "fakeout"
const ID_GATECRASH: String = "gatecrash"
const ID_AFTERSHOCK: String = "aftershock"
const ID_PROWLER: String = "prowler"
const ID_NIGHTFALL: String = "nightfall"
const ID_PARANOIA: String = "paranoia"
const ID_NANOSWARM: String = "nanoswarm"
const ID_ALARMBOT: String = "alarmbot"
const ID_LOCKDOWN: String = "lockdown"


## Liefert alle Items als Array. Reihenfolge = Reihenfolge im Design-Dokument.
static func build_all() -> Array[ItemData]:
	var items: Array[ItemData] = []

	# ======================================================================
	# BESTANDSITEMS
	# ======================================================================

	var spoon := ItemData.create(
		ID_WOODEN_SPOON,
		"Mamas Kochloeffel",
		"Schlag die Hitze zurueck",
		"Ein Treffer auf einen Gegner gibt 0,75 s lang 1,5x Tempo und Unverwundbarkeit.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.UNCOMMON,
		14, "2.1"
	)
	items.append(spoon)

	var cleaver := ItemData.create(
		ID_RUSTY_CLEAVER,
		"Rostiges Beil",
		"Schwere Hiebe",
		"30 % Chance, Bluten zuzufuegen: 4 s lang jede Sekunde Schaden.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.COMMON,
		15, "2.2"
	)
	cleaver.stat_modifiers = { PlayerStats.STAT_DAMAGE: {"mul": 1.05} }
	items.append(cleaver)

	var sock := ItemData.create(
		ID_STATIC_SOCK,
		"Statische Socke",
		"Ladung baut sich auf",
		"Jeder 6. Treffer entlaedt eine Schockwelle: doppelter Schaden im Umkreis, Gegner werden zurueckgestossen.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE,
		16, "2.3"
	)
	items.append(sock)

	var horns := ItemData.create(
		ID_BRIMSTONE_HORNS,
		"Hoellenfeuer-Hoerner",
		"Ramm sie!",
		"Wer mit hohem Tempo in einen Gegner laeuft, loest eine Ramm-Attacke aus: hoher Kontaktschaden und Rueckstoss.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.RARE,
		17, "2.4"
	)
	horns.stat_modifiers = { PlayerStats.STAT_MOVE_SPEED: {"add": 1.0} }
	items.append(horns)

	var oil := ItemData.create(
		ID_HOLY_OIL,
		"Heiliges Oel",
		"Hinterlasse eine Spur",
		"Hinterlaesst beim Laufen eine Pfuetze. Gegner darin erleiden Schaden und werden 25 % verlangsamt.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC,
		18, "2.5"
	)
	items.append(oil)

	var cables := ItemData.create(
		ID_JUMPER_CABLES,
		"Papas Starthilfekabel",
		"Zisch & Zap",
		"Sofortiger Dash nach vorne. Durchquerte Gegner nehmen hohen Schaden und werden 2 s betaeubt.",
		ItemData.Kind.ACTIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC,
		1, "1.1"
	)
	cables.charge_rooms = 2
	items.append(cables)

	var compass := ItemData.create(
		ID_MAGNETIC_COMPASS,
		"Magnetischer Kompass",
		"Alles kommt zu dir",
		"Zieht Muenzen, Herzen und abgelegte Bomben im Umkreis von 6 m automatisch an.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.UNCOMMON,
		19, "2.6"
	)
	# 6 m absolut: der Basiswert liegt bei 2.2, also +3.8 additiv.
	compass.stat_modifiers = { PlayerStats.STAT_PICKUP_RANGE: {"add": 3.8} }
	items.append(compass)

	var boots := ItemData.create(
		ID_ACID_BOOTS,
		"Saeurefeste Stiefel",
		"Die Limonade beisst nicht mehr",
		"75 % weniger Schaden durch saure Limonade und keine Verlangsamung mehr beim Durchwaten.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.LEGENDARY,
		20, "2.7"
	)
	boots.stat_modifiers = { PlayerStats.STAT_HAZARD_RESIST: {"mul": 0.25} }
	items.append(boots)

	# ======================================================================
	# PHASE 4 — 20 PASSIVE ITEMS
	# ======================================================================

	# --- 1. Proteinshake aus den 90ern ---------------------------------
	# Reiner Stat-Tausch. Die Hitbox-Verkleinerung laeuft ueber
	# item_behaviours.gd, weil PlayerStats keinen Reichweiten-Stat kennt.
	var shake := ItemData.create(
		ID_PROTEIN_SHAKE,
		"Proteinshake aus den 90ern",
		"Abgelaufen, aber wirksam",
		"+25 % Schaden. Deine Angriffs-Reichweite schrumpft dafuer um 15 %.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.UNCOMMON,
		21, "2.8"
	)
	shake.stat_modifiers = { PlayerStats.STAT_DAMAGE: {"mul": 1.25} }
	items.append(shake)

	# --- 2. Omas Enge Hosen ---------------------------------------------
	var pants := ItemData.create(
		ID_TIGHT_PANTS,
		"Omas Enge Hosen",
		"Sitzt wie angegossen. Zu gut.",
		"+20 % Tempo. Vorbeirennen oder ein abrupter Richtungswechsel loesen einen Tritt aus: halber Schaden und starker Rueckstoss (~4 m).",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.UNCOMMON,
		22, "2.9"
	)
	pants.stat_modifiers = { PlayerStats.STAT_MOVE_SPEED: {"mul": 1.20} }
	items.append(pants)

	# --- 3. Plastik-Heiligenschein --------------------------------------
	var halo := ItemData.create(
		ID_PLASTIC_HALO,
		"Plastik-Heiligenschein",
		"Aus dem Karnevalsbedarf",
		"+1 maximales Leben. Jeder Kill hat 10 % Chance, 0,5 Leben zu heilen.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.UNCOMMON,
		23, "2.10"
	)
	halo.stat_modifiers = { PlayerStats.STAT_MAX_HEALTH: {"add": 1.0} }
	items.append(halo)

	# --- 4. Das Blutpakt -------------------------------------------------
	var pact := ItemData.create(
		ID_BLOOD_PACT,
		"Das Blutpakt",
		"Unterschrieben, nicht gelesen",
		"+40 % Schaden. Jeder 5. Treffer kostet dich selbst 0,5 Leben.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE,
		24, "2.11"
	)
	pact.stat_modifiers = { PlayerStats.STAT_DAMAGE: {"mul": 1.40} }
	items.append(pact)

	# --- 5. Rostiger Dachnagel -------------------------------------------
	var nail := ItemData.create(
		ID_ROOF_NAIL,
		"Rostiger Dachnagel",
		"Festgenagelt",
		"25 % Chance, einen getroffenen Gegner 1,5 s lang festzunageln: er kann sich nicht mehr bewegen, sein Angriff wird sofort unterbrochen, und er ist gegen Rueckstoss immun.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE,
		25, "2.12"
	)
	items.append(nail)

	# --- 6. Kaugummi unter dem Schuh -------------------------------------
	var gum := ItemData.create(
		ID_CHEWING_GUM,
		"Kaugummi unter dem Schuh",
		"Da war doch was am Absatz",
		"Jeder Dash hinterlaesst eine klebrige Spur: Gegner darin werden 1,5 s verlangsamt. Steht ein Gegner in Saeure, haelt die Saeure 50 % laenger.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.RARE,
		26, "2.13"
	)
	items.append(gum)

	# --- 7. Kaputter Toaster ---------------------------------------------
	var toaster := ItemData.create(
		ID_BROKEN_TOASTER,
		"Kaputter Toaster",
		"Bitte nicht mit der Gabel",
		"Wenn du getroffen wirst, stossen Funken alle Nahkampf-Gegner zurueck. Brennende Gegner nehmen dabei sofort doppelten Feuerschaden.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.RARE,
		27, "2.14"
	)
	items.append(toaster)

	# --- 8. Mutters Haarspray --------------------------------------------
	var spray := ItemData.create(
		ID_HAIRSPRAY,
		"Mutters Haarspray",
		"FCKW-frei, angeblich",
		"Schlaege erzeugen eine Spruehwolke: Gegner darin brauchen 0,5 s laenger fuer ihre Angriffe. Trifft die Wolke Feuer, explodiert sie.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		28, "2.15"
	)
	items.append(spray)

	# --- 9. Altes Modulations-Modem (56k) --------------------------------
	var modem := ItemData.create(
		ID_MODEM_56K,
		"Altes Modulations-Modem",
		"Kshhh-pshhh-diiing",
		"Jeder 10. Schlag sendet eine Einwahl-Welle: Gegner koennen 1 s lang keine Spezialangriffe starten. Betaeubte Gegner nehmen kritischen Zusatzschaden.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.EPIC,
		29, "2.16"
	)
	items.append(modem)

	# --- 10. Laser-Pointer aus dem Kiosk ---------------------------------
	var laser := ItemData.create(
		ID_LASER_POINTER,
		"Laser-Pointer aus dem Kiosk",
		"Die Katze ist woanders",
		"Markiert dauerhaft den Gegner mit den meisten Lebenspunkten: +15 % Schaden gegen ihn. Erleidet er Schaden ueber Zeit, springt die Haelfte davon auf umstehende Gegner ueber.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		30, "2.17"
	)
	items.append(laser)

	# --- 11. Ueberkochter Milchreis --------------------------------------
	var rice := ItemData.create(
		ID_RICE_PUDDING,
		"Ueberkochter Milchreis",
		"Steht seit Dienstag auf dem Herd",
		"Stehen bleiben baut einen Schild auf (bis 15 % deiner Maximal-HP). Solange der Schild haelt, bist du komplett immun gegen Saeure und Boden-Hazards.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.EPIC,
		31, "2.18"
	)
	items.append(rice)

	# --- 12. Tennisball an der Schnur ------------------------------------
	var tennis := ItemData.create(
		ID_TENNIS_BALL,
		"Tennisball an der Schnur",
		"Kommt immer zurueck",
		"Jeder Dash feuert einen Tennisball nach vorn, der Gegner auf Distanz zurueckstoesst. Blutende Getroffene bluten wieder von vorn.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.RARE,
		32, "2.19"
	)
	items.append(tennis)

	# --- 13. Disco-Kugel-Anhaenger ---------------------------------------
	var disco := ItemData.create(
		ID_DISCO_BALL,
		"Disco-Kugel-Anhaenger",
		"Samstagnacht, jede Nacht",
		"Kills werfen Lichtreflexe durch den Raum. 10 % Chance, umstehende Gegner 2 s zu verwirren. Verwirrte Gegner nehmen 25 % mehr Schaden, wenn sie betaeubt sind.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		33, "2.20"
	)
	items.append(disco)

	# --- 14. Gefrierbeutel voll Eis --------------------------------------
	var ice := ItemData.create(
		ID_ICE_BAG,
		"Gefrierbeutel voll Eis",
		"Fuer die Schwellung",
		"15 % Chance, einen Gegner 2 s lang um 40 % zu verlangsamen. Trifft es einen brennenden Gegner, entlaedt der Thermoschock den gesamten Restbrand auf einen Schlag.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE,
		34, "2.21"
	)
	items.append(ice)

	# --- 15. Omas Stricknadeln -------------------------------------------
	var needles := ItemData.create(
		ID_KNITTING_NEEDLES,
		"Omas Stricknadeln",
		"Zwei rechts, eine durch",
		"+10 % Angriffsgeschwindigkeit, kritische Treffer ignorieren Ruestung. Die Blutungs-Chance im Nahkampf steigt von 30 % auf 50 %.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE,
		35, "2.22"
	)
	# STAT_COOLDOWN wirkt als Teiler auf die Angriffszeit (siehe
	# PlayerStats.get_attack_speed) — 0.909 entspricht +10 % Tempo.
	needles.stat_modifiers = { PlayerStats.STAT_COOLDOWN: {"mul": 0.909} }
	items.append(needles)

	# --- 16. Teufelchen-Outfit -------------------------------------------
	var devil := ItemData.create(
		ID_DEVIL_OUTFIT,
		"Teufelchen-Outfit",
		"Rote Augen, schlechte Laune",
		"Unter 50 % Leben: +50 % Schaden. Dein Modell gluent dabei dauerhaft rot.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE,
		36, "2.23"
	)
	items.append(devil)

	# --- 17. Nonnen-Kutte ------------------------------------------------
	var nun := ItemData.create(
		ID_NUN_HABIT,
		"Nonnen-Kutte",
		"Leiden hat seinen Lohn",
		"Wenn du Schaden nimmst: 25 % Chance, dass ein aktives Item sofort wieder aufgeladen ist.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		37, "2.24"
	)
	items.append(nun)

	# --- 18. Handball-Schulterpolster ------------------------------------
	var pads := ItemData.create(
		ID_HANDBALL_PADS,
		"Handball-Schulterpolster",
		"Kreislaeufer-Ausruestung",
		"Einmal pro Raum: toedlicher Schaden laesst dich stattdessen mit 1 Leben stehen.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.EPIC,
		38, "2.25"
	)
	items.append(pads)

	# --- 19. Goldene Kreditkarte -----------------------------------------
	var card := ItemData.create(
		ID_GOLDEN_CREDIT_CARD,
		"Goldene Kreditkarte",
		"Limit? Welches Limit?",
		"+2 % Schaden je 10 Muenzen im Beutel, bis maximal +50 %.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.UNCOMMON,
		39, "2.26"
	)
	items.append(card)

	# --- 20. Mamas Stoeckelschuhe ----------------------------------------
	var heels := ItemData.create(
		ID_STILETTO_HEELS,
		"Mamas Stoeckelschuhe",
		"Klack. Klack. Zisch.",
		"Beim Rennen bleiben 2 s lange Saeure-Lachen zurueck. Gegner darin nehmen Saeureschaden und werden langsamer. Jeder 3. Schritt loest eine Schockwelle aus, die nahe Gegner kurz straucheln laesst.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC,
		40, "2.27"
	)
	items.append(heels)

	# --- 41. Mueckenspray der Tante ---------------------------------------
	var mosquito := ItemData.create(
		ID_MOSQUITO_SPRAY,
		"Mueckenspray der Tante",
		"Riecht nach 1994",
		"Kill-Heal: Toetest du einen Gegner, der unter Blutung, Brand oder Saeure leidet, hast du 15 % Chance auf +0,5 Leben.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		41, "2.28"
	)
	items.append(mosquito)

	# --- 42. Plastik-Vampirgebiss ------------------------------------------
	var vampire := ItemData.create(
		ID_VAMPIRE_TEETH,
		"Plastik-Vampirgebiss",
		"Aus dem Faschingsladen",
		"Kill-Heal: Kills an Gegnern mit einem aktiven Statuseffekt heilen garantiert +0,5 Leben.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY,
		42, "2.29"
	)
	items.append(vampire)

	# --- 43. Scharfrichter-Kapuze -------------------------------------------
	var executioner := ItemData.create(
		ID_EXECUTIONER_HOOD,
		"Scharfrichter-Kapuze",
		"Der letzte Weg ist kurz",
		"Kill-Heal: Kills an betaeubten oder festgenagelten Gegnern heilen +1 Leben und loesen eine Schockwelle aus.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		43, "2.30"
	)
	items.append(executioner)

	# --- 44. Omas Scharfes Chili-Oel ----------------------------------------
	var chili := ItemData.create(
		ID_CHILI_OIL,
		"Omas Scharfes Chili-Oel",
		"Ein Tropfen reicht",
		"Treffer auf brennende Gegner loesen Saeure-Spritzer auf alle umliegenden Gegner aus.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.EPIC,
		44, "2.31"
	)
	items.append(chili)

	# --- 45. Ausgelaufene Flachbatterie -------------------------------------
	var battery := ItemData.create(
		ID_BATTERY_PACK,
		"Ausgelaufene Flachbatterie",
		"Klebt an den Fingern",
		"Betreten von Saeure/Limonade entlaedt einen Stromschlag: nahe Gegner werden betaeubt.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.RARE,
		45, "2.32"
	)
	items.append(battery)

	# --- 46. Alarmanlage vom Parkplatz --------------------------------------
	var alarm := ItemData.create(
		ID_CAR_ALARM,
		"Alarmanlage vom Parkplatz",
		"WIIIU WIIIU WIIIU",
		"Nimmst du Schaden, werden alle Gegner im Raum stummgeschaltet.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.UNCOMMON,
		46, "2.33"
	)
	items.append(alarm)

	# --- 47. Ausgelaufener Sekundenkleber -----------------------------------
	var glue := ItemData.create(
		ID_SUPER_GLUE,
		"Ausgelaufener Sekundenkleber",
		"Finger weg. Zu spaet.",
		"Kills hinterlassen eine klebrige Stelle am Boden, die nachfolgende Gegner festnagelt.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		47, "2.34"
	)
	items.append(glue)

	# --- 48. Alte Rollschuhe -------------------------------------------------
	var skates := ItemData.create(
		ID_ROLLER_SKATES,
		"Alte Rollschuhe",
		"Bremsen? Kannte man nicht.",
		"Dash-Treffer stossen Gegner extrem weit zurueck und verwirren sie kurz.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC,
		48, "2.35"
	)
	items.append(skates)

	# --- 49. Riesige Kaugummiblase -------------------------------------------
	var bubble := ItemData.create(
		ID_BUBBLE_GUM,
		"Riesige Kaugummiblase",
		"Groesser als der Kopf",
		"Beim Stillstehen baut sich eine Blase auf. Nimmst du Schaden, platzt sie und verlangsamt Gegner ringsum massiv.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.RARE,
		49, "2.36"
	)
	items.append(bubble)

	# --- 50. Kupferdraht-Spule -----------------------------------------------
	var copper := ItemData.create(
		ID_COPPER_WIRE,
		"Kupferdraht-Spule",
		"Isolierung? War mal.",
		"Ein Dash durch verlangsamte oder festgenagelte Gegner setzt sie sofort in Brand.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.RARE,
		50, "2.37"
	)
	items.append(copper)

	# --- 21. Papp-Wahrsagerbrett ------------------------------------------
	# ABSICHTLICH OHNE nr/entity_id: dieses Item steht nicht in der 83-Zeilen-
	# Mastertabelle - ein spaeterer Zusatz ausserhalb der offiziellen Liste.
	var ouija := ItemData.create(
		ID_OUIJA_BOARD,
		"Papp-Wahrsagerbrett",
		"Etwas antwortet",
		"Nahkampftreffer haben 20 % Chance, einen Rachegeist zu beschwoeren. Er visiert gezielt Gegner an, die hinter dir oder ausserhalb deiner Nahkampf-Reichweite stehen.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE
	)
	items.append(ouija)

	# ======================================================================
	# PHASE 4 — 8 AKTIVE ITEMS
	# ======================================================================

	# --- A1. Sturmfeuerzeug (3 s) ----------------------------------------
	var lighter := ItemData.create(
		ID_STORM_LIGHTER,
		"Sturmfeuerzeug",
		"Haelt jedem Wind stand",
		"Spuckt einen 90-Grad-Feuerbogen nach vorn: dreifacher Schaden, Gegner brennen 3 s lang nach.",
		ItemData.Kind.ACTIVE, ItemData.Category.MELEE, ItemData.Rarity.EPIC,
		2, "1.2"
	)
	lighter.cooldown_seconds = 3.0
	items.append(lighter)

	# --- A2. Schulbibliotheks-Buch (1x pro Etage) ------------------------
	# Weder Zeit noch Raumzahl: die Sperre sitzt in item_behaviours.gd.
	# charge_rooms bleibt bewusst 0, damit das HUD keinen Cooldown anzeigt,
	# den es gar nicht gibt.
	var book := ItemData.create(
		ID_LIBRARY_BOOK,
		"Schulbibliotheks-Buch",
		"Ueberfaellig seit 1997",
		"Toetet sofort alle Gegner im Raum unter 20 % Leben. Nur einmal pro Etage.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY,
		3, "1.3"
	)
	book.charge_rooms = 0
	items.append(book)

	# --- A3. Verfluchter Glueckswuerfel (10 s) ---------------------------
	var cursed := ItemData.create(
		ID_CURSED_DIE,
		"Verfluchter Glueckswuerfel",
		"Neu wuerfeln kostet dich etwas",
		"Wandelt alle herumliegenden Drops im Raum in zufaellige andere Drops um.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		4, "1.4"
	)
	cursed.cooldown_seconds = 10.0
	items.append(cursed)

	# --- A4. Alter Handstaubsauger (6 s) ---------------------------------
	var vacuum := ItemData.create(
		ID_HAND_VACUUM,
		"Alter Handstaubsauger",
		"Beutel seit Jahren nicht gewechselt",
		"Saugt 2,5 s lang Gegner im Kegel zu dir heran. Saugt dabei Saeure vom Boden auf und feuert sie als Strahl zurueck.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		5, "1.5"
	)
	vacuum.cooldown_seconds = 6.0
	items.append(vacuum)

	# --- A5. Omas Pfeffermuehle (8 s) ------------------------------------
	var pepper := ItemData.create(
		ID_PEPPER_MILL,
		"Omas Pfeffermuehle",
		"Immer zu viel",
		"Erzeugt eine Pfefferwolke: Gegner niesen und koennen 2 s nicht angreifen. Alle laufenden Schaden-ueber-Zeit-Effekte halten 3 s laenger.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		6, "1.6"
	)
	pepper.cooldown_seconds = 8.0
	items.append(pepper)

	# --- A6. Walkman (kaputt) (12 s) -------------------------------------
	var walkman := ItemData.create(
		ID_WALKMAN,
		"Walkman (kaputt)",
		"Band verheddert, Bass intakt",
		"Eine Schockwelle zerstoert alle Projektile und stoesst Gegner zurueck. Getroffene sind 4 s lang voellig orientierungslos.",
		ItemData.Kind.ACTIVE, ItemData.Category.DEFENSE, ItemData.Rarity.LEGENDARY,
		7, "1.7"
	)
	walkman.cooldown_seconds = 12.0
	items.append(walkman)

	# --- A7. Megafon aus der Schule (5 s) --------------------------------
	var megaphone := ItemData.create(
		ID_MEGAPHONE,
		"Megafon aus der Schule",
		"RUHE JETZT",
		"Ein Schrei nach vorn unterbricht Gegner und verursacht Schaden. Gegen bereits betaeubte Gegner dreifacher Schaden.",
		ItemData.Kind.ACTIVE, ItemData.Category.MELEE, ItemData.Rarity.EPIC,
		8, "1.8"
	)
	megaphone.cooldown_seconds = 5.0
	items.append(megaphone)

	# --- A8. Spruehsahne-Dose (7 s) --------------------------------------
	var cream := ItemData.create(
		ID_WHIPPED_CREAM,
		"Spruehsahne-Dose",
		"Direkt aus der Dose",
		"Legt einen Sahneteppich aus: Gegner rutschen aus und liegen 1,5 s am Boden. Loescht brennende Gegner und richtet dabei massiven Schaden an.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		9, "1.9"
	)
	cream.cooldown_seconds = 7.0
	items.append(cream)

	# --- A9. Alte Ghettoblaster-Box (9 s) ---------------------------------
	var boombox := ItemData.create(
		ID_BOOMBOX,
		"Alte Ghettoblaster-Box",
		"Bass, der Waende einreisst",
		"Sendet eine 4 s lange Basswelle: zerstoert Projektile und schaltet Gegner in Reichweite stumm. Stumme Gegner erleiden +30 % Nahkampfschaden.",
		ItemData.Kind.ACTIVE, ItemData.Category.DEFENSE, ItemData.Rarity.EPIC,
		10, "1.10"
	)
	boombox.cooldown_seconds = 9.0
	items.append(boombox)

	# --- A10. Scharfe Instant-Nudeln (9 s) --------------------------------
	var ramen := ItemData.create(
		ID_SPICY_RAMEN,
		"Scharfe Instant-Nudeln",
		"Achtung: wirklich scharf",
		"Speit einen breiten Flammenkegel, der Telegraphs sofort abbricht und Gegner 4 s lang brennen laesst.",
		ItemData.Kind.ACTIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE,
		11, "1.11"
	)
	ramen.cooldown_seconds = 9.0
	items.append(ramen)

	# --- A11. USB-Mini-Ventilator (7 s) ------------------------------------
	var fan := ItemData.create(
		ID_POCKET_FAN,
		"USB-Mini-Ventilator",
		"5V, aber mit Haltung",
		"Ein Windstoss nach vorn verlangsamt Gegner 3 s lang und ueberträgt ihre laufenden Schaden-ueber-Zeit-Effekte auf Nachbarn.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.UNCOMMON,
		12, "1.12"
	)
	fan.cooldown_seconds = 7.0
	items.append(fan)

	# --- A12. Spruehdose aus dem Tunnel (11 s) -----------------------------
	var graffiti := ItemData.create(
		ID_GRAFFITI_CAN,
		"Spruehdose aus dem Tunnel",
		"Kunst ist, was Kunst macht",
		"Huellt die Umgebung in eine Farbwolke: Gegner darin sind 5 s verwirrt und treffen sich gegenseitig.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		13, "1.13"
	)
	graffiti.cooldown_seconds = 11.0
	items.append(graffiti)

	# --- Tabellen-Nr. 51-83: Auswahl der neuen "Ultimate"-Items -----------
	# Ausfuehrliche Mechanik in item_behaviours.gd (_use_<id>).

	var updraft := ItemData.create(
		ID_UPDRAFT, "Aufwind", "Nach oben, immer nach oben",
		"Schleudert dich mit einem starken Aufwind senkrecht nach oben - perfekt, um Abgruende oder Angriffe zu ueberspringen.",
		ItemData.Kind.ACTIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.UNCOMMON,
		51, "1.14"
	)
	updraft.cooldown_seconds = 8.0
	items.append(updraft)

	var healing_orb := ItemData.create(
		ID_HEALING_ORB, "Heil-Orb", "Warmes Licht",
		"Heilt dich sofort um einen Teil deines Maximal-Lebens und dann ueber 4 s weiter.",
		ItemData.Kind.ACTIVE, ItemData.Category.DEFENSE, ItemData.Rarity.EPIC,
		79, "1.41"
	)
	healing_orb.cooldown_seconds = 16.0
	items.append(healing_orb)

	var slow_orb := ItemData.create(
		ID_SLOW_ORB, "Frost-Orb", "Kuehler Kopf",
		"Legt eine Eisflaeche vor dir ab, die Gegner darin stark verlangsamt.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		78, "1.40"
	)
	slow_orb.cooldown_seconds = 9.0
	items.append(slow_orb)

	var incendiary := ItemData.create(
		ID_INCENDIARY, "Brandsatz", "Alles brennt lichterloh",
		"Legt ein Napalm-Feld vor dir ab, das Gegner darin kontinuierlich verbrennt.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		73, "1.35"
	)
	incendiary.cooldown_seconds = 10.0
	items.append(incendiary)

	var barrier_orb := ItemData.create(
		ID_BARRIER_ORB, "Barriere-Orb", "Kommst du hier nicht vorbei",
		"Errichtet eine kurzlebige, undurchdringliche Eiswand vor dir - blockiert Gegner und Geschosse.",
		ItemData.Kind.ACTIVE, ItemData.Category.DEFENSE, ItemData.Rarity.EPIC,
		77, "1.39"
	)
	barrier_orb.cooldown_seconds = 14.0
	items.append(barrier_orb)

	var shock_bolt := ItemData.create(
		ID_SHOCK_BOLT, "Schockbolzen", "Kurzschluss garantiert",
		"Feuert einen Energiebolzen ab, der den ersten getroffenen Gegner betaeubt.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.UNCOMMON,
		64, "1.26"
	)
	shock_bolt.cooldown_seconds = 7.0
	items.append(shock_bolt)

	var rolling_thunder := ItemData.create(
		ID_ROLLING_THUNDER, "Donnergrollen", "Der Boden bebt",
		"Eine gewaltige Schockwelle betaeubt und stoesst alle nahen Gegner zurueck.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY,
		68, "1.30"
	)
	rolling_thunder.cooldown_seconds = 18.0
	items.append(rolling_thunder)

	var fault_line := ItemData.create(
		ID_FAULT_LINE, "Verwerfungslinie", "Riss im Boden",
		"Ein seismischer Riss laeuft geradeaus vor dir und betaeubt jeden Gegner, den er durchquert.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		67, "1.29"
	)
	fault_line.cooldown_seconds = 12.0
	items.append(fault_line)

	var stim_beacon := ItemData.create(
		ID_STIM_BEACON, "Stim-Beacon", "Pumpt dich auf",
		"Wirft ein Beacon, das dir Tempo und Angriffskraft verleiht, solange du in seiner Naehe bleibst.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		72, "1.34"
	)
	stim_beacon.cooldown_seconds = 15.0
	items.append(stim_beacon)

	var seize := ItemData.create(
		ID_SEIZE, "Ergreifen", "Kein Entkommen",
		"Legt eine Falle ab, die Gegner darin festwurzelt und mit Saeure uebergiesst.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		70, "1.32"
	)
	seize.cooldown_seconds = 11.0
	items.append(seize)

	var devour := ItemData.create(
		ID_DEVOUR, "Verschlingen", "Nimmt, was uebrig bleibt",
		"Passiv: Toetest du einen Gegner, heilst du sofort um einen kleinen Teil deines Maximal-Lebens.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		60, "2.38"
	)
	items.append(devour)

	var hunters_fury := ItemData.create(
		ID_HUNTERS_FURY, "Jaegerzorn", "Durch alles hindurch",
		"Feuert drei Energiestrahlen geradeaus ab, die Waende durchdringen und alle getroffenen Gegner schwer verletzen.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY,
		65, "1.27"
	)
	hunters_fury.cooldown_seconds = 16.0
	items.append(hunters_fury)

	var turret_item := ItemData.create(
		ID_TURRET, "Geschuetzturm", "Automatische Unterstuetzung",
		"Stellt einen freundlichen Geschuetzturm auf, der automatisch auf nahe Gegner feuert.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		82, "1.44"
	)
	turret_item.cooldown_seconds = 20.0
	items.append(turret_item)

	var orbital_strike := ItemData.create(
		ID_ORBITAL_STRIKE, "Orbitalschlag", "Einschlag in 3... 2... 1...",
		"Markiert die Stelle vor dir - nach kurzer Verzoegerung schlaegt ein gewaltiger Strahl ein und verwuestet den Bereich.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY,
		74, "1.36"
	)
	orbital_strike.cooldown_seconds = 22.0
	items.append(orbital_strike)

	var snake_bite := ItemData.create(
		ID_SNAKE_BITE, "Schlangenbiss", "Gift wirkt langsam, aber sicher",
		"Legt eine Saeurepfuetze ab. Gegner darin sind verwundbar und nehmen erhoehten Schaden.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		76, "1.38"
	)
	snake_bite.cooldown_seconds = 10.0
	items.append(snake_bite)

	var blade_storm := ItemData.create(
		ID_BLADE_STORM, "Klingensturm", "Fuenffacher Schnitt",
		"Wirft fuenf Klingen im Faecher; ein Kill mit diesem Wurf laedt das Item sofort komplett neu auf.",
		ItemData.Kind.ACTIVE, ItemData.Category.MELEE, ItemData.Rarity.LEGENDARY,
		52, "1.15"
	)
	blade_storm.cooldown_seconds = 14.0
	items.append(blade_storm)

	var blaze := ItemData.create(
		ID_BLAZE, "Feuerwand", "Nichts kommt durch",
		"Legt eine Reihe brennender Flaechen vor dir ab, die Gegner darin fortlaufend verbrennen.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		53, "1.16"
	)
	blaze.cooldown_seconds = 12.0
	items.append(blaze)

	var hot_hands := ItemData.create(
		ID_HOT_HANDS, "Heisse Haende", "Direkt aus dem Ofen",
		"Schleudert einen Feuerball, der bei Einschlag sofort Schaden macht und Gegner in Brand setzt.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		54, "1.17"
	)
	hot_hands.cooldown_seconds = 6.0
	items.append(hot_hands)

	var run_it_back := ItemData.create(
		ID_RUN_IT_BACK, "Run It Back", "Zweite Chance",
		"Setzt eine Marke an deiner Position. Wuerdest du sterben, wirst du stattdessen dorthin zurueckgeholt und teilweise geheilt.",
		ItemData.Kind.ACTIVE, ItemData.Category.DEFENSE, ItemData.Rarity.LEGENDARY,
		55, "1.18"
	)
	run_it_back.cooldown_seconds = 25.0
	items.append(run_it_back)

	var boom_bot := ItemData.create(
		ID_BOOM_BOT, "Boom-Bot", "Rollt, dann kracht's",
		"Entsendet einen kleinen Bot, der zum naechsten Gegner rollt und explodiert.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		56, "1.19"
	)
	boom_bot.cooldown_seconds = 9.0
	items.append(boom_bot)

	var paint_shells := ItemData.create(
		ID_PAINT_SHELLS, "Streugranaten", "Bunter Regen",
		"Wirft mehrere kleine Granaten in einem Streumuster vor dir, die kurz danach explodieren.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		57, "1.20"
	)
	paint_shells.cooldown_seconds = 11.0
	items.append(paint_shells)

	var showstopper := ItemData.create(
		ID_SHOWSTOPPER, "Showstopper", "Grosses Finale",
		"Feuert eine gewaltige Rakete geradeaus ab, die bei Einschlag massiven Flaechenschaden und starken Rueckstoss verursacht.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY,
		58, "1.21"
	)
	showstopper.cooldown_seconds = 20.0
	items.append(showstopper)

	var leer := ItemData.create(
		ID_LEER, "Schwebendes Auge", "Es beobachtet dich alle",
		"Beschwoert ein schwebendes Auge, das nahe Gegner regelmaessig verwirrt.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		59, "1.22"
	)
	leer.cooldown_seconds = 16.0
	items.append(leer)

	# KORREKTUR: urspruenglich faelschlich als PASSIVE eingetragen (dieser
	# Session-Fehler wurde vor Abgleich mit der echten Tabelle gemacht - siehe
	# item_behaviours.gd _use_empress). Die Tabelle listet Empress klar als
	# "1 (Aktiv)": erhoeht drastisch das Tempo, Kills waehrenddessen setzen
	# Abklingzeiten zurueck und machen kurz unsichtbar.
	var empress := ItemData.create(
		ID_EMPRESS, "Kaiserin", "Regiert das Schlachtfeld",
		"Erhoeht dein Tempo drastisch. Waehrend der Wirkung setzen Kills die Abklingzeit deines Aktiv-Items zurueck und machen dich kurz unsichtbar.",
		ItemData.Kind.ACTIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.LEGENDARY,
		61, "1.23"
	)
	empress.cooldown_seconds = 20.0
	items.append(empress)

	var fakeout := ItemData.create(
		ID_FAKEOUT, "Koeder", "Nicht die echte",
		"Stellt einen Koeder auf, der nach kurzer Zeit explodiert und nahe Gegner verwirrt.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		62, "1.24"
	)
	fakeout.cooldown_seconds = 10.0
	items.append(fakeout)

	var gatecrash := ItemData.create(
		ID_GATECRASH, "Portalanker", "Hier lang, dann zurueck",
		"Erste Nutzung wirft einen Anker. Zweite Nutzung teleportiert dich sofort dorthin zurueck.",
		ItemData.Kind.ACTIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC,
		63, "1.25"
	)
	gatecrash.cooldown_seconds = 12.0
	items.append(gatecrash)

	var aftershock := ItemData.create(
		ID_AFTERSHOCK, "Nachbeben", "Verzoegerte Wucht",
		"Feuert eine Energieladung geradeaus, die am ersten Treffer oder maximaler Reichweite explodiert.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		66, "1.28"
	)
	aftershock.cooldown_seconds = 10.0
	items.append(aftershock)

	var prowler := ItemData.create(
		ID_PROWLER, "Schatten-Pirscher", "Laeuft unter dem Radar",
		"Entsendet einen Schattenwolf, der von Gegner zu Gegner hetzt und sie kurz verwirrt und stumm schaltet.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		69, "1.31"
	)
	prowler.cooldown_seconds = 15.0
	items.append(prowler)

	var nightfall := ItemData.create(
		ID_NIGHTFALL, "Anbruch der Nacht", "Durch Mauern hindurch",
		"Eine Welle, die durch Waende dringt und alle Gegner im Raum verlangsamt und stumm schaltet.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY,
		71, "1.33"
	)
	nightfall.cooldown_seconds = 18.0
	items.append(nightfall)

	var paranoia := ItemData.create(
		ID_PARANOIA, "Paranoia", "Sie sind ueberall",
		"Eine schwaechere Welle durch Waende hindurch, die Gegner kurz verwirrt und stumm schaltet.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		75, "1.37"
	)
	paranoia.cooldown_seconds = 9.0
	items.append(paranoia)

	var nanoswarm := ItemData.create(
		ID_NANOSWARM, "Nano-Schwarm", "Unsichtbar, bis es zu spaet ist",
		"Legt eine unsichtbare Mine ab, die sich nach kurzer Zeit scharf macht und beim naechsten Gegner in der Naehe explodiert.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC,
		80, "1.42"
	)
	nanoswarm.cooldown_seconds = 10.0
	items.append(nanoswarm)

	var alarmbot := ItemData.create(
		ID_ALARMBOT, "Alarm-Bot", "Markiert das Ziel",
		"Rast auf den naechsten Gegner zu und markiert ihn - er nimmt danach kurzzeitig doppelten Schaden.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE,
		81, "1.43"
	)
	alarmbot.cooldown_seconds = 9.0
	items.append(alarmbot)

	var lockdown := ItemData.create(
		ID_LOCKDOWN, "Lockdown", "Alles steht still",
		"Nach kurzem Aufladen betaeubt und schaltet eine gewaltige Druckwelle alle Gegner im Raum stumm.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY,
		83, "1.45"
	)
	lockdown.cooldown_seconds = 26.0
	items.append(lockdown)

	return items


## Optionaler Zusatz-Ladepfad fuer spaetere .tres-Items. Fehlt der Ordner,
## passiert nichts — das ist kein Fehlerfall, sondern der Normalzustand,
## solange alle Items aus dem Code kommen.
static func load_external(directory: String = "res://resources/items") -> Array[ItemData]:
	var result: Array[ItemData] = []
	if not DirAccess.dir_exists_absolute(directory):
		return result

	var dir := DirAccess.open(directory)
	if dir == null:
		return result

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res: Resource = load(directory.path_join(file_name))
			if res is ItemData and (res as ItemData).id != "":
				result.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()

	return result
