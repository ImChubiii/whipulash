

extends RefCounted
class_name ItemCatalog

# ============================================================================
# ItemCatalog — alle Items als Code statt als .tres-Dateien.
# ============================================================================
# BEWUSSTE ENTSCHEIDUNG: Items im Code zu definieren statt als Resource-
# Dateien im Editor hat hier drei praktische Vorteile:
#   * Ein neues Item ist ein Funktionsaufruf, kein Datei-Anlege-Ritual.
#   * Balancing-Aenderungen sind im Git-Diff lesbar (eine .tres-Aenderung
#     ist es nicht).
#   * Es gibt keine kaputten Resource-Pfade, wenn Ordner umbenannt werden.
#
# RARITY: jedes Item bekommt eine Seltenheitsstufe statt einer handgesetzten
# Sockelfarbe. Die Farbe leitet ItemData daraus ab - grau / gruen / blau /
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
# PHASE 4: 20 NEUE ITEMS
# ############################################################################
# Die Reihenfolge unten folgt dem Design-Dokument (Nummern 1-20 des neuen
# Satzes), NICHT der Rarity. Wer ein Item sucht, findet es damit an der
# Stelle, an der es auch im Dokument steht.
#
# WAS HIER STEHT UND WAS NICHT:
# Items, die AUSSCHLIESSLICH Stat-Boni geben, brauchen keinen Eintrag in
# item_behaviours.gd - stat_modifiers unten reicht. Alles mit Bedingung,
# Timer, Zufall oder VFX steht dort. Die Kommentare "-> Verhalten" verweisen
# auf den jeweiligen Block.
#
# ICONS: bleiben leer. Sobald es Texturen gibt, hier per
# load("res://textures/items/...") zuweisen.

# --- Bestandsitems (Phase 1-3) ---
const ID_WOODEN_SPOON: String = "wooden_spoon"
const ID_RUSTY_CLEAVER: String = "rusty_cleaver"
const ID_STATIC_SOCK: String = "static_sock"
const ID_BRIMSTONE_HORNS: String = "brimstone_horns"
const ID_HOLY_OIL: String = "holy_oil"
const ID_JUMPER_CABLES: String = "jumper_cables"
const ID_MAGNETIC_COMPASS: String = "magnetic_compass"
const ID_ACID_BOOTS: String = "acid_boots"

# --- Phase 4: 16 passive Items ---
const ID_PROTEIN_SHAKE: String = "protein_shake"
const ID_TIGHT_PANTS: String = "tight_pants"
const ID_PLASTIC_HALO: String = "plastic_halo"
const ID_BLOOD_PACT: String = "blood_pact"
const ID_ROOF_NAIL: String = "roof_nail"
const ID_JELLY_RING: String = "jelly_ring"
const ID_DEVIL_OUTFIT: String = "devil_outfit"
const ID_NUN_HABIT: String = "nun_habit"
const ID_HANDBALL_PADS: String = "handball_pads"
const ID_GOLDEN_CREDIT_CARD: String = "golden_credit_card"
const ID_HOLY_BLOOD_VIAL: String = "holy_blood_vial"
const ID_OUIJA_BOARD: String = "ouija_board"
const ID_CROOKED_DIE: String = "crooked_die"
const ID_DEVIL_HORNS_PLASTIC: String = "devil_horns_plastic"
const ID_BROKEN_GAMEBOY: String = "broken_gameboy"
const ID_CARDBOARD_WINGS: String = "cardboard_wings"
const ID_STILETTO_HEELS: String = "stiletto_heels"

# --- Phase 4: 3 aktive Items ---
const ID_STORM_LIGHTER: String = "storm_lighter"
const ID_LIBRARY_BOOK: String = "library_book"
const ID_CURSED_DIE: String = "cursed_die"


## Liefert alle Items als Array. Reihenfolge = Reihenfolge im Design-Dokument.
static func build_all() -> Array[ItemData]:
	var items: Array[ItemData] = []

	# ======================================================================
	# BESTANDSITEMS
	# ======================================================================

	# ------------------------------------------------------------------
	# 1. Mamas Kochloeffel
	# ------------------------------------------------------------------
	var spoon := ItemData.create(
		ID_WOODEN_SPOON,
		"Mamas Kochloeffel",
		"Schlag die Hitze zurueck",
		"Ein Treffer auf einen Gegner gibt 0,75 s lang 1,5x Tempo und Unverwundbarkeit.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.UNCOMMON
	)
	items.append(spoon)

	# ------------------------------------------------------------------
	# 2. Rostiges Beil
	# ------------------------------------------------------------------
	var cleaver := ItemData.create(
		ID_RUSTY_CLEAVER,
		"Rostiges Beil",
		"Schwere Hiebe",
		"30 % Chance, Bluten zuzufuegen: 4 s lang jede Sekunde Schaden.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.COMMON
	)
	# Kleiner Grundschadensbonus, damit sich das Item auch ohne Prozzen lohnt.
	cleaver.stat_modifiers = {
		PlayerStats.STAT_DAMAGE: {"mul": 1.05},
	}
	items.append(cleaver)

	# ------------------------------------------------------------------
	# 3. Statische Socke
	# ------------------------------------------------------------------
	var sock := ItemData.create(
		ID_STATIC_SOCK,
		"Statische Socke",
		"Ladung baut sich auf",
		"Jeder 6. Treffer entlaedt eine Schockwelle: doppelter Schaden im Umkreis, Gegner werden zurueckgestossen.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.RARE
	)
	items.append(sock)

	# ------------------------------------------------------------------
	# 4. Hoellenfeuer-Hoerner
	# ------------------------------------------------------------------
	var horns := ItemData.create(
		ID_BRIMSTONE_HORNS,
		"Hoellenfeuer-Hoerner",
		"Ramm sie!",
		"Wer mit hohem Tempo in einen Gegner laeuft, loest eine Ramm-Attacke aus: hoher Kontaktschaden und Rueckstoss.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MOVEMENT,
		ItemData.Rarity.RARE
	)
	horns.stat_modifiers = {
		PlayerStats.STAT_MOVE_SPEED: {"add": 1.0},
	}
	items.append(horns)

	# ------------------------------------------------------------------
	# 5. Heiliges Oel
	# ------------------------------------------------------------------
	var oil := ItemData.create(
		ID_HOLY_OIL,
		"Heiliges Oel",
		"Hinterlasse eine Spur",
		"Hinterlaesst beim Laufen eine Pfuetze. Gegner darin erleiden Schaden und werden 25 % verlangsamt.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MOVEMENT,
		ItemData.Rarity.EPIC
	)
	items.append(oil)

	# ------------------------------------------------------------------
	# 6. Papas Starthilfekabel (AKTIV)
	# ------------------------------------------------------------------
	var cables := ItemData.create(
		ID_JUMPER_CABLES,
		"Papas Starthilfekabel",
		"Zisch & Zap",
		"Sofortiger Dash nach vorne. Durchquerte Gegner nehmen hohen Schaden und werden 2 s betaeubt.",
		ItemData.Kind.ACTIVE,
		ItemData.Category.MOVEMENT,
		ItemData.Rarity.EPIC
	)
	cables.charge_rooms = 2
	items.append(cables)

	# ------------------------------------------------------------------
	# 7. Magnetischer Kompass
	# ------------------------------------------------------------------
	var compass := ItemData.create(
		ID_MAGNETIC_COMPASS,
		"Magnetischer Kompass",
		"Alles kommt zu dir",
		"Zieht Muenzen, Herzen und abgelegte Bomben im Umkreis von 6 m automatisch an.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.DEFENSE,
		ItemData.Rarity.UNCOMMON
	)
	compass.stat_modifiers = {
		# 6 m absolut: der Basiswert liegt bei 2.2, also +3.8 additiv.
		PlayerStats.STAT_PICKUP_RANGE: {"add": 3.8},
	}
	items.append(compass)

	# ------------------------------------------------------------------
	# 8. Saeurefeste Stiefel
	# ------------------------------------------------------------------
	var boots := ItemData.create(
		ID_ACID_BOOTS,
		"Saeurefeste Stiefel",
		"Die Limonade beisst nicht mehr",
		"75 % weniger Schaden durch saure Limonade und keine Verlangsamung mehr beim Durchwaten.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.DEFENSE,
		ItemData.Rarity.LEGENDARY
	)
	boots.stat_modifiers = {
		PlayerStats.STAT_HAZARD_RESIST: {"mul": 0.25},
	}
	items.append(boots)

	# ======================================================================
	# PHASE 4 — 20 NEUE ITEMS
	# ======================================================================

	# ------------------------------------------------------------------
	# 1. Proteinshake aus den 90ern
	# ------------------------------------------------------------------
	# Reiner Stat-Tausch: mehr Schaden, dafuer kleinere Reichweite. Die
	# Verkleinerung der Hitbox laeuft ueber item_behaviours.gd, weil
	# PlayerStats keinen Reichweiten-Stat kennt (und einer nur fuer dieses
	# Item die PUSH-Kette in vier Skripten erweitert haette).
	var shake := ItemData.create(
		ID_PROTEIN_SHAKE,
		"Proteinshake aus den 90ern",
		"Abgelaufen, aber wirksam",
		"+25 % Schaden. Deine Angriffs-Reichweite schrumpft dafuer um 15 %.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.UNCOMMON
	)
	shake.stat_modifiers = {
		PlayerStats.STAT_DAMAGE: {"mul": 1.25},
	}
	items.append(shake)

	# ------------------------------------------------------------------
	# 2. Omas Enge Hosen
	# ------------------------------------------------------------------
	var pants := ItemData.create(
		ID_TIGHT_PANTS,
		"Omas Enge Hosen",
		"Sitzt wie angegossen. Zu gut.",
		"+20 % Tempo. Wer im Vorbeirennen einen Gegner streift, tritt automatisch zu (halber Schaden).",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MOVEMENT,
		ItemData.Rarity.UNCOMMON
	)
	pants.stat_modifiers = {
		PlayerStats.STAT_MOVE_SPEED: {"mul": 1.20},
	}
	items.append(pants)

	# ------------------------------------------------------------------
	# 3. Plastik-Heiligenschein
	# ------------------------------------------------------------------
	var halo := ItemData.create(
		ID_PLASTIC_HALO,
		"Plastik-Heiligenschein",
		"Aus dem Karnevalsbedarf",
		"+1 maximales Leben. Jeder Kill hat 10 % Chance, 0,5 Leben zu heilen.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.DEFENSE,
		ItemData.Rarity.UNCOMMON
	)
	halo.stat_modifiers = {
		PlayerStats.STAT_MAX_HEALTH: {"add": 1.0},
	}
	items.append(halo)

	# ------------------------------------------------------------------
	# 4. Das Blutpakt
	# ------------------------------------------------------------------
	var pact := ItemData.create(
		ID_BLOOD_PACT,
		"Das Blutpakt",
		"Unterschrieben, nicht gelesen",
		"+40 % Schaden. Jeder 5. Treffer kostet dich selbst 0,5 Leben.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.RARE
	)
	pact.stat_modifiers = {
		PlayerStats.STAT_DAMAGE: {"mul": 1.40},
	}
	items.append(pact)

	# ------------------------------------------------------------------
	# 5. Rostiger Dachnagel
	# ------------------------------------------------------------------
	var nail := ItemData.create(
		ID_ROOF_NAIL,
		"Rostiger Dachnagel",
		"Festgenagelt",
		"25 % Chance, einen getroffenen Gegner 1,5 s lang festzunageln. Er kann sich nicht mehr bewegen.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.RARE
	)
	items.append(nail)

	# ------------------------------------------------------------------
	# 6. Sturmfeuerzeug (AKTIV)
	# ------------------------------------------------------------------
	# HINWEIS ZUM COOLDOWN: das Design-Dokument nennt 2 Sekunden. Das
	# Aktiv-Item-System dieses Projekts laedt aber ueber GECLEARTE RAEUME
	# auf (siehe item_manager.notify_room_cleared), nicht ueber eine Zeit.
	# charge_rooms = 1 ist die naechstliegende Entsprechung: nach jedem
	# Raum wieder bereit. Ein sekundenbasierter Cooldown haette einen
	# zweiten, parallelen Lademechanismus im ItemManager gebraucht.
	var lighter := ItemData.create(
		ID_STORM_LIGHTER,
		"Sturmfeuerzeug",
		"Haelt jedem Wind stand",
		"Spuckt einen 90-Grad-Feuerbogen nach vorn: dreifacher Schaden, Gegner brennen 3 s lang nach.",
		ItemData.Kind.ACTIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.EPIC
	)
	lighter.charge_rooms = 1
	items.append(lighter)

	# ------------------------------------------------------------------
	# 7. Schulbibliotheks-Buch (AKTIV)
	# ------------------------------------------------------------------
	var book := ItemData.create(
		ID_LIBRARY_BOOK,
		"Schulbibliotheks-Buch",
		"Ueberfaellig seit 1997",
		"Toetet sofort alle Gegner im Raum unter 20 % Leben. Nur einmal pro Etage.",
		ItemData.Kind.ACTIVE,
		ItemData.Category.UTILITY,
		ItemData.Rarity.LEGENDARY
	)
	book.charge_rooms = 4
	items.append(book)

	# ------------------------------------------------------------------
	# 8. Wackelpudding-Ring
	# ------------------------------------------------------------------
	var jelly := ItemData.create(
		ID_JELLY_RING,
		"Wackelpudding-Ring",
		"Wabbelt schuetzend",
		"Ein Ring kreist um dich und blockt alle 4 s einen Nahkampftreffer komplett.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.DEFENSE,
		ItemData.Rarity.RARE
	)
	items.append(jelly)

	# ------------------------------------------------------------------
	# 9. Teufelchen-Outfit
	# ------------------------------------------------------------------
	var devil := ItemData.create(
		ID_DEVIL_OUTFIT,
		"Teufelchen-Outfit",
		"Rote Augen, schlechte Laune",
		"Unter 50 % Leben: +50 % Schaden. Deine Augen leuchten rot.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.RARE
	)
	items.append(devil)

	# ------------------------------------------------------------------
	# 10. Nonnen-Kutte
	# ------------------------------------------------------------------
	var habit := ItemData.create(
		ID_NUN_HABIT,
		"Nonnen-Kutte",
		"Leiden hat seinen Lohn",
		"Wenn du Schaden nimmst: 25 % Chance, dass ein aktives Item sofort wieder aufgeladen ist.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.UTILITY,
		ItemData.Rarity.RARE
	)
	items.append(habit)

	# ------------------------------------------------------------------
	# 11. Handball-Schulterpolster
	# ------------------------------------------------------------------
	var pads := ItemData.create(
		ID_HANDBALL_PADS,
		"Handball-Schulterpolster",
		"Kreisläufer-Ausruestung",
		"Einmal pro Raum: toedlicher Schaden laesst dich stattdessen mit 1 Leben stehen.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.DEFENSE,
		ItemData.Rarity.EPIC
	)
	items.append(pads)

	# ------------------------------------------------------------------
	# 12. Goldene Kreditkarte
	# ------------------------------------------------------------------
	var card := ItemData.create(
		ID_GOLDEN_CREDIT_CARD,
		"Goldene Kreditkarte",
		"Limit? Welches Limit?",
		"+2 % Schaden je 10 Muenzen im Beutel, bis maximal +50 %.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.UTILITY,
		ItemData.Rarity.UNCOMMON
	)
	items.append(card)

	# ------------------------------------------------------------------
	# 13. Phiole Heiligenblut
	# ------------------------------------------------------------------
	var vial := ItemData.create(
		ID_HOLY_BLOOD_VIAL,
		"Phiole Heiligenblut",
		"Von zweifelhafter Herkunft",
		"+15 % Schaden. Getoetete Gegner explodieren und reissen Umstehende mit.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.EPIC
	)
	vial.stat_modifiers = {
		PlayerStats.STAT_DAMAGE: {"mul": 1.15},
	}
	items.append(vial)

	# ------------------------------------------------------------------
	# 14. Papp-Wahrsagerbrett
	# ------------------------------------------------------------------
	var ouija := ItemData.create(
		ID_OUIJA_BOARD,
		"Papp-Wahrsagerbrett",
		"J - A - !",
		"20 % Chance, dass ein Schlag durch den Gegner hindurchgeht und den dahinter gleich mittrifft.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.RARE
	)
	items.append(ouija)

	# ------------------------------------------------------------------
	# 15. Ungerader Wuerfel
	# ------------------------------------------------------------------
	var die := ItemData.create(
		ID_CROOKED_DIE,
		"Ungerader Wuerfel",
		"Sieben Seiten. Sieben.",
		"Bei jedem Raumbeitritt bekommst du einen zufaelligen Buff auf Tempo, Schaden oder Ruestung.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.UTILITY,
		ItemData.Rarity.UNCOMMON
	)
	items.append(die)

	# ------------------------------------------------------------------
	# 16. Plastik-Teufelshoerner
	# ------------------------------------------------------------------
	var plastic_horns := ItemData.create(
		ID_DEVIL_HORNS_PLASTIC,
		"Plastik-Teufelshoerner",
		"Kostuemladen-Boesewicht",
		"+15 % Tempo. Du laeufst durch Gegner hindurch und fuegst ihnen dabei leichten Schaden zu.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MOVEMENT,
		ItemData.Rarity.EPIC
	)
	plastic_horns.stat_modifiers = {
		PlayerStats.STAT_MOVE_SPEED: {"mul": 1.15},
	}
	items.append(plastic_horns)

	# ------------------------------------------------------------------
	# 17. Defekter Gameboy
	# ------------------------------------------------------------------
	var gameboy := ItemData.create(
		ID_BROKEN_GAMEBOY,
		"Defekter Gameboy",
		"Batteriefach korrodiert",
		"Jeder Treffer springt als Mini-Blitz auf einen weiteren Gegner in der Naehe ueber.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE,
		ItemData.Rarity.RARE
	)
	items.append(gameboy)

	# ------------------------------------------------------------------
	# 18. Rote Pappfluegel
	# ------------------------------------------------------------------
	var wings := ItemData.create(
		ID_CARDBOARD_WINGS,
		"Rote Pappfluegel",
		"Fliegen ist Ansichtssache",
		"Nach einem erlittenen Treffer wirst du 0,3 s rueckwaerts gerissen - unverwundbar waehrenddessen.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.DEFENSE,
		ItemData.Rarity.UNCOMMON
	)
	items.append(wings)

	# ------------------------------------------------------------------
	# 19. Mamas Stoeckelschuhe
	# ------------------------------------------------------------------
	var heels := ItemData.create(
		ID_STILETTO_HEELS,
		"Mamas Stoeckelschuhe",
		"Klack. Klack. Zisch.",
		"Beim Rennen bleiben 2 s lange Saeure-Lachen zurueck. Gegner darin nehmen Schaden und werden langsamer.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MOVEMENT,
		ItemData.Rarity.EPIC
	)
	items.append(heels)

	# ------------------------------------------------------------------
	# 20. Verfluchter Glueckswuerfel (AKTIV)
	# ------------------------------------------------------------------
	var cursed := ItemData.create(
		ID_CURSED_DIE,
		"Verfluchter Glueckswuerfel",
		"Neu wuerfeln kostet dich etwas",
		"Wandelt alle herumliegenden Drops im Raum in zufaellige andere Drops um.",
		ItemData.Kind.ACTIVE,
		ItemData.Category.UTILITY,
		ItemData.Rarity.RARE
	)
	cursed.charge_rooms = 1
	items.append(cursed)

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
