extends Resource
class_name ItemData

# ============================================================================
# ItemData — reine Beschreibung EINES Items. Enthaelt bewusst KEINE Logik.
# ============================================================================
# Was ein Item TUT, steht in item_behaviours.gd. Diese Trennung ist wichtig,
# weil Items aus zwei sehr unterschiedlichen Quellen kommen koennen:
# aus dem Code-Katalog (item_catalog.gd) oder spaeter aus .tres-Dateien, die
# im Editor angelegt werden. Beide Wege liefern dasselbe ItemData-Objekt.

enum Kind {
	PASSIVE,   ## Wirkt dauerhaft, sobald es im Inventar liegt.
	ACTIVE,    ## Muss aktiv ausgeloest werden, laedt ueber Raeume auf.
}

enum Category {
	MELEE,      ## Nahkampf & Treffer-Effekte
	MOVEMENT,   ## Bewegung & Ramm-Attacken
	DEFENSE,    ## Defensive / Taktik
	UTILITY,    ## Alles Uebrige
}

## Eindeutige ID. Wird von item_behaviours.gd zur Zuordnung benutzt und
## darf sich nach dem Release NICHT mehr aendern (Speicherstaende, Runs).
@export var id: String = ""
@export var display_name: String = "Unbenanntes Item"

## Der kursive Einzeiler unter dem Namen ("Schlag die Hitze zurueck").
@export_multiline var flavor_text: String = ""

## Die mechanische Erklaerung fuers HUD unten links.
@export_multiline var description: String = ""

@export var icon: Texture2D
@export var kind: Kind = Kind.PASSIVE
@export var category: Category = Category.UTILITY

## Nur fuer ACTIVE: nach so vielen gecleareten Raeumen ist es wieder bereit.
@export var charge_rooms: int = 2

## Reine Stat-Boni, die ohne eigenen Code auskommen.
## Format: { PlayerStats.STAT_* : { "add": float, "mul": float } }
## Beispiel: { "damage": { "mul": 1.15 } } fuer +15 % Schaden.
@export var stat_modifiers: Dictionary = {}

## Farbe des schwebenden Sockel-Wuerfels im Raum. Rein kosmetisch.
@export var pedestal_color: Color = Color(0.95, 0.85, 0.35)

## Wie oft dasselbe Item in einem Run maximal droppen darf. 0 = unbegrenzt.
@export var max_stacks: int = 1


## Baut ein ItemData komplett im Code. Praktisch fuer den Katalog, damit
## nicht fuer jedes Item eine .tres-Datei angelegt werden muss.
static func create(
		p_id: String,
		p_name: String,
		p_flavor: String,
		p_description: String,
		p_kind: Kind = Kind.PASSIVE,
		p_category: Category = Category.UTILITY
) -> ItemData:
	var data := ItemData.new()
	data.id = p_id
	data.display_name = p_name
	data.flavor_text = p_flavor
	data.description = p_description
	data.kind = p_kind
	data.category = p_category
	return data


func is_active_item() -> bool:
	return kind == Kind.ACTIVE


func get_category_name() -> String:
	match category:
		Category.MELEE:
			return "Nahkampf"
		Category.MOVEMENT:
			return "Bewegung"
		Category.DEFENSE:
			return "Defensive"
	return "Sonstiges"
