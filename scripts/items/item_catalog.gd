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
# Wer spaeter lieber im Inspector arbeitet, legt .tres-Dateien mit dem
# Script item_data.gd an und laedt sie in load_external() dazu — der Rest
# des Systems merkt keinen Unterschied.
#
# ICONS: bleiben hier leer. Sobald es Texturen gibt, in
# ItemManager._build_catalog() nach dem Erzeugen zuweisen oder direkt
# unten im jeweiligen Block per load("res://textures/items/...").

const ID_WOODEN_SPOON: String = "wooden_spoon"
const ID_RUSTY_CLEAVER: String = "rusty_cleaver"
const ID_STATIC_SOCK: String = "static_sock"
const ID_BRIMSTONE_HORNS: String = "brimstone_horns"
const ID_HOLY_OIL: String = "holy_oil"
const ID_JUMPER_CABLES: String = "jumper_cables"
const ID_MAGNETIC_COMPASS: String = "magnetic_compass"
const ID_ACID_BOOTS: String = "acid_boots"


## Liefert alle Items als Array. Reihenfolge = Reihenfolge im Design-Dokument.
static func build_all() -> Array[ItemData]:
	var items: Array[ItemData] = []

	# ------------------------------------------------------------------
	# 1. Mamas Kochloeffel
	# ------------------------------------------------------------------
	var spoon := ItemData.create(
		ID_WOODEN_SPOON,
		"Mamas Kochloeffel",
		"Schlag die Hitze zurueck",
		"Ein Treffer auf einen Gegner gibt 0,75 s lang 1,5x Tempo und Unverwundbarkeit.",
		ItemData.Kind.PASSIVE,
		ItemData.Category.MELEE
	)
	spoon.pedestal_color = Color(0.85, 0.68, 0.42)
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
		ItemData.Category.MELEE
	)
	cleaver.pedestal_color = Color(0.72, 0.25, 0.20)
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
		ItemData.Category.MELEE
	)
	sock.pedestal_color = Color(0.55, 0.75, 0.98)
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
		ItemData.Category.MOVEMENT
	)
	horns.pedestal_color = Color(0.90, 0.35, 0.15)
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
		ItemData.Category.MOVEMENT
	)
	oil.pedestal_color = Color(0.95, 0.90, 0.55)
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
		ItemData.Category.MOVEMENT
	)
	cables.charge_rooms = 2
	cables.pedestal_color = Color(0.40, 0.85, 0.95)
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
		ItemData.Category.DEFENSE
	)
	compass.pedestal_color = Color(0.65, 0.70, 0.80)
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
		ItemData.Category.DEFENSE
	)
	boots.pedestal_color = Color(0.45, 0.90, 0.50)
	boots.stat_modifiers = {
		PlayerStats.STAT_HAZARD_RESIST: {"mul": 0.25},
	}
	items.append(boots)

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
