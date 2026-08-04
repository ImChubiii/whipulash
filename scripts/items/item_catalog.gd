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
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.UNCOMMON
	)
	items.append(spoon)

	var cleaver := ItemData.create(
		ID_RUSTY_CLEAVER,
		"Rostiges Beil",
		"Schwere Hiebe",
		"30 % Chance, Bluten zuzufuegen: 4 s lang jede Sekunde Schaden.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.COMMON
	)
	cleaver.stat_modifiers = { PlayerStats.STAT_DAMAGE: {"mul": 1.05} }
	items.append(cleaver)

	var sock := ItemData.create(
		ID_STATIC_SOCK,
		"Statische Socke",
		"Ladung baut sich auf",
		"Jeder 6. Treffer entlaedt eine Schockwelle: doppelter Schaden im Umkreis, Gegner werden zurueckgestossen.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE
	)
	items.append(sock)

	var horns := ItemData.create(
		ID_BRIMSTONE_HORNS,
		"Hoellenfeuer-Hoerner",
		"Ramm sie!",
		"Wer mit hohem Tempo in einen Gegner laeuft, loest eine Ramm-Attacke aus: hoher Kontaktschaden und Rueckstoss.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.RARE
	)
	horns.stat_modifiers = { PlayerStats.STAT_MOVE_SPEED: {"add": 1.0} }
	items.append(horns)

	var oil := ItemData.create(
		ID_HOLY_OIL,
		"Heiliges Oel",
		"Hinterlasse eine Spur",
		"Hinterlaesst beim Laufen eine Pfuetze. Gegner darin erleiden Schaden und werden 25 % verlangsamt.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC
	)
	items.append(oil)

	var cables := ItemData.create(
		ID_JUMPER_CABLES,
		"Papas Starthilfekabel",
		"Zisch & Zap",
		"Sofortiger Dash nach vorne. Durchquerte Gegner nehmen hohen Schaden und werden 2 s betaeubt.",
		ItemData.Kind.ACTIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC
	)
	cables.charge_rooms = 2
	items.append(cables)

	var compass := ItemData.create(
		ID_MAGNETIC_COMPASS,
		"Magnetischer Kompass",
		"Alles kommt zu dir",
		"Zieht Muenzen, Herzen und abgelegte Bomben im Umkreis von 6 m automatisch an.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.UNCOMMON
	)
	# 6 m absolut: der Basiswert liegt bei 2.2, also +3.8 additiv.
	compass.stat_modifiers = { PlayerStats.STAT_PICKUP_RANGE: {"add": 3.8} }
	items.append(compass)

	var boots := ItemData.create(
		ID_ACID_BOOTS,
		"Saeurefeste Stiefel",
		"Die Limonade beisst nicht mehr",
		"75 % weniger Schaden durch saure Limonade und keine Verlangsamung mehr beim Durchwaten.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.LEGENDARY
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
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.UNCOMMON
	)
	shake.stat_modifiers = { PlayerStats.STAT_DAMAGE: {"mul": 1.25} }
	items.append(shake)

	# --- 2. Omas Enge Hosen ---------------------------------------------
	var pants := ItemData.create(
		ID_TIGHT_PANTS,
		"Omas Enge Hosen",
		"Sitzt wie angegossen. Zu gut.",
		"+20 % Tempo. Vorbeirennen oder ein abrupter Richtungswechsel loesen einen Tritt aus: halber Schaden und starker Rueckstoss (~4 m).",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.UNCOMMON
	)
	pants.stat_modifiers = { PlayerStats.STAT_MOVE_SPEED: {"mul": 1.20} }
	items.append(pants)

	# --- 3. Plastik-Heiligenschein --------------------------------------
	var halo := ItemData.create(
		ID_PLASTIC_HALO,
		"Plastik-Heiligenschein",
		"Aus dem Karnevalsbedarf",
		"+1 maximales Leben. Jeder Kill hat 10 % Chance, 0,5 Leben zu heilen.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.UNCOMMON
	)
	halo.stat_modifiers = { PlayerStats.STAT_MAX_HEALTH: {"add": 1.0} }
	items.append(halo)

	# --- 4. Das Blutpakt -------------------------------------------------
	var pact := ItemData.create(
		ID_BLOOD_PACT,
		"Das Blutpakt",
		"Unterschrieben, nicht gelesen",
		"+40 % Schaden. Jeder 5. Treffer kostet dich selbst 0,5 Leben.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE
	)
	pact.stat_modifiers = { PlayerStats.STAT_DAMAGE: {"mul": 1.40} }
	items.append(pact)

	# --- 5. Rostiger Dachnagel -------------------------------------------
	var nail := ItemData.create(
		ID_ROOF_NAIL,
		"Rostiger Dachnagel",
		"Festgenagelt",
		"25 % Chance, einen getroffenen Gegner 1,5 s lang festzunageln: er kann sich nicht mehr bewegen, sein Angriff wird sofort unterbrochen, und er ist gegen Rueckstoss immun.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE
	)
	items.append(nail)

	# --- 6. Kaugummi unter dem Schuh -------------------------------------
	var gum := ItemData.create(
		ID_CHEWING_GUM,
		"Kaugummi unter dem Schuh",
		"Da war doch was am Absatz",
		"Jeder Dash hinterlaesst eine klebrige Spur: Gegner darin werden 1,5 s verlangsamt. Steht ein Gegner in Saeure, haelt die Saeure 50 % laenger.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.RARE
	)
	items.append(gum)

	# --- 7. Kaputter Toaster ---------------------------------------------
	var toaster := ItemData.create(
		ID_BROKEN_TOASTER,
		"Kaputter Toaster",
		"Bitte nicht mit der Gabel",
		"Wenn du getroffen wirst, stossen Funken alle Nahkampf-Gegner zurueck. Brennende Gegner nehmen dabei sofort doppelten Feuerschaden.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.RARE
	)
	items.append(toaster)

	# --- 8. Mutters Haarspray --------------------------------------------
	var spray := ItemData.create(
		ID_HAIRSPRAY,
		"Mutters Haarspray",
		"FCKW-frei, angeblich",
		"Schlaege erzeugen eine Spruehwolke: Gegner darin brauchen 0,5 s laenger fuer ihre Angriffe. Trifft die Wolke Feuer, explodiert sie.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE
	)
	items.append(spray)

	# --- 9. Altes Modulations-Modem (56k) --------------------------------
	var modem := ItemData.create(
		ID_MODEM_56K,
		"Altes Modulations-Modem",
		"Kshhh-pshhh-diiing",
		"Jeder 10. Schlag sendet eine Einwahl-Welle: Gegner koennen 1 s lang keine Spezialangriffe starten. Betaeubte Gegner nehmen kritischen Zusatzschaden.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.EPIC
	)
	items.append(modem)

	# --- 10. Laser-Pointer aus dem Kiosk ---------------------------------
	var laser := ItemData.create(
		ID_LASER_POINTER,
		"Laser-Pointer aus dem Kiosk",
		"Die Katze ist woanders",
		"Markiert dauerhaft den Gegner mit den meisten Lebenspunkten: +15 % Schaden gegen ihn. Erleidet er Schaden ueber Zeit, springt die Haelfte davon auf umstehende Gegner ueber.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC
	)
	items.append(laser)

	# --- 11. Ueberkochter Milchreis --------------------------------------
	var rice := ItemData.create(
		ID_RICE_PUDDING,
		"Ueberkochter Milchreis",
		"Steht seit Dienstag auf dem Herd",
		"Stehen bleiben baut einen Schild auf (bis 15 % deiner Maximal-HP). Solange der Schild haelt, bist du komplett immun gegen Saeure und Boden-Hazards.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.EPIC
	)
	items.append(rice)

	# --- 12. Tennisball an der Schnur ------------------------------------
	var tennis := ItemData.create(
		ID_TENNIS_BALL,
		"Tennisball an der Schnur",
		"Kommt immer zurueck",
		"Jeder Dash feuert einen Tennisball nach vorn, der Gegner auf Distanz zurueckstoesst. Blutende Getroffene bluten wieder von vorn.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.RARE
	)
	items.append(tennis)

	# --- 13. Disco-Kugel-Anhaenger ---------------------------------------
	var disco := ItemData.create(
		ID_DISCO_BALL,
		"Disco-Kugel-Anhaenger",
		"Samstagnacht, jede Nacht",
		"Kills werfen Lichtreflexe durch den Raum. 10 % Chance, umstehende Gegner 2 s zu verwirren. Verwirrte Gegner nehmen 25 % mehr Schaden, wenn sie betaeubt sind.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE
	)
	items.append(disco)

	# --- 14. Gefrierbeutel voll Eis --------------------------------------
	var ice := ItemData.create(
		ID_ICE_BAG,
		"Gefrierbeutel voll Eis",
		"Fuer die Schwellung",
		"15 % Chance, einen Gegner 2 s lang um 40 % zu verlangsamen. Trifft es einen brennenden Gegner, entlaedt der Thermoschock den gesamten Restbrand auf einen Schlag.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE
	)
	items.append(ice)

	# --- 15. Omas Stricknadeln -------------------------------------------
	var needles := ItemData.create(
		ID_KNITTING_NEEDLES,
		"Omas Stricknadeln",
		"Zwei rechts, eine durch",
		"+10 % Angriffsgeschwindigkeit, kritische Treffer ignorieren Ruestung. Die Blutungs-Chance im Nahkampf steigt von 30 % auf 50 %.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE
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
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE
	)
	items.append(devil)

	# --- 17. Nonnen-Kutte ------------------------------------------------
	var nun := ItemData.create(
		ID_NUN_HABIT,
		"Nonnen-Kutte",
		"Leiden hat seinen Lohn",
		"Wenn du Schaden nimmst: 25 % Chance, dass ein aktives Item sofort wieder aufgeladen ist.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE
	)
	items.append(nun)

	# --- 18. Handball-Schulterpolster ------------------------------------
	var pads := ItemData.create(
		ID_HANDBALL_PADS,
		"Handball-Schulterpolster",
		"Kreislaeufer-Ausruestung",
		"Einmal pro Raum: toedlicher Schaden laesst dich stattdessen mit 1 Leben stehen.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.EPIC
	)
	items.append(pads)

	# --- 19. Goldene Kreditkarte -----------------------------------------
	var card := ItemData.create(
		ID_GOLDEN_CREDIT_CARD,
		"Goldene Kreditkarte",
		"Limit? Welches Limit?",
		"+2 % Schaden je 10 Muenzen im Beutel, bis maximal +50 %.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.UNCOMMON
	)
	items.append(card)

	# --- 20. Mamas Stoeckelschuhe ----------------------------------------
	var heels := ItemData.create(
		ID_STILETTO_HEELS,
		"Mamas Stoeckelschuhe",
		"Klack. Klack. Zisch.",
		"Beim Rennen bleiben 2 s lange Saeure-Lachen zurueck. Gegner darin nehmen Saeureschaden und werden langsamer. Jeder 3. Schritt loest eine Schockwelle aus, die nahe Gegner kurz straucheln laesst.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC
	)
	items.append(heels)

	# --- 21. Papp-Wahrsagerbrett ------------------------------------------
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
		ItemData.Kind.ACTIVE, ItemData.Category.MELEE, ItemData.Rarity.EPIC
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
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.LEGENDARY
	)
	book.charge_rooms = 0
	items.append(book)

	# --- A3. Verfluchter Glueckswuerfel (10 s) ---------------------------
	var cursed := ItemData.create(
		ID_CURSED_DIE,
		"Verfluchter Glueckswuerfel",
		"Neu wuerfeln kostet dich etwas",
		"Wandelt alle herumliegenden Drops im Raum in zufaellige andere Drops um.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.RARE
	)
	cursed.cooldown_seconds = 10.0
	items.append(cursed)

	# --- A4. Alter Handstaubsauger (6 s) ---------------------------------
	var vacuum := ItemData.create(
		ID_HAND_VACUUM,
		"Alter Handstaubsauger",
		"Beutel seit Jahren nicht gewechselt",
		"Saugt 2,5 s lang Gegner im Kegel zu dir heran. Saugt dabei Saeure vom Boden auf und feuert sie als Strahl zurueck.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC
	)
	vacuum.cooldown_seconds = 6.0
	items.append(vacuum)

	# --- A5. Omas Pfeffermuehle (8 s) ------------------------------------
	var pepper := ItemData.create(
		ID_PEPPER_MILL,
		"Omas Pfeffermuehle",
		"Immer zu viel",
		"Erzeugt eine Pfefferwolke: Gegner niesen und koennen 2 s nicht angreifen. Alle laufenden Schaden-ueber-Zeit-Effekte halten 3 s laenger.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC
	)
	pepper.cooldown_seconds = 8.0
	items.append(pepper)

	# --- A6. Walkman (kaputt) (12 s) -------------------------------------
	var walkman := ItemData.create(
		ID_WALKMAN,
		"Walkman (kaputt)",
		"Band verheddert, Bass intakt",
		"Eine Schockwelle zerstoert alle Projektile und stoesst Gegner zurueck. Getroffene sind 4 s lang voellig orientierungslos.",
		ItemData.Kind.ACTIVE, ItemData.Category.DEFENSE, ItemData.Rarity.LEGENDARY
	)
	walkman.cooldown_seconds = 12.0
	items.append(walkman)

	# --- A7. Megafon aus der Schule (5 s) --------------------------------
	var megaphone := ItemData.create(
		ID_MEGAPHONE,
		"Megafon aus der Schule",
		"RUHE JETZT",
		"Ein Schrei nach vorn unterbricht Gegner und verursacht Schaden. Gegen bereits betaeubte Gegner dreifacher Schaden.",
		ItemData.Kind.ACTIVE, ItemData.Category.MELEE, ItemData.Rarity.EPIC
	)
	megaphone.cooldown_seconds = 5.0
	items.append(megaphone)

	# --- A8. Spruehsahne-Dose (7 s) --------------------------------------
	var cream := ItemData.create(
		ID_WHIPPED_CREAM,
		"Spruehsahne-Dose",
		"Direkt aus der Dose",
		"Legt einen Sahneteppich aus: Gegner rutschen aus und liegen 1,5 s am Boden. Loescht brennende Gegner und richtet dabei massiven Schaden an.",
		ItemData.Kind.ACTIVE, ItemData.Category.UTILITY, ItemData.Rarity.EPIC
	)
	cream.cooldown_seconds = 7.0
	items.append(cream)

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
