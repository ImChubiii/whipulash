

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

## Seltenheitsstufe. Bestimmt die Farbe, in der das Item UEBERALL
## dargestellt wird: Sockel im Schatzraum, Drop am Boden, Chip in der
## HUD-Leiste, Eintrag in der Run-Uebersicht.
##
## WARUM DIE FARBE NICHT EINZELN PRO OBERFLAECHE GESETZT WIRD:
## Alle vier Anzeigen lesen bereits dieselbe Eigenschaft aus
## (pedestal_color - siehe treasure_pedestal.gd, pickup.gd,
## item_description_hud.gd, item_summary_list.gd). Die Rarity schreibt
## deshalb einfach in genau diese Eigenschaft. Damit war fuer das komplette
## Farbschema KEINE Aenderung an den Anzeige-Scripten noetig - und es kann
## auch keine Oberflaeche geben, die eine andere Farbe zeigt als die
## anderen.
##
## Reihenfolge = aufsteigende Wertigkeit: grau, gruen, blau, lila, rot.
enum Rarity {
	COMMON,     ## grau
	UNCOMMON,   ## gruen
	RARE,       ## blau
	EPIC,       ## lila
	LEGENDARY,  ## rot
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

## --- Organisatorische Metadaten aus dem Design-Dokument ------------------
## Werden aktuell NIRGENDS im Spiel gelesen (kein UI, keine Logik haengt
## dran) - reine Buchhaltung, damit sich ein Item im Code eindeutig auf
## seine Zeile in der Item-Tabelle zurueckfuehren laesst.
##   nr        - fortlaufende Nummer ueber ALLE Items (Tabellenspalte "Nr.")
##   entity_id - "A.B": A = 1 (Aktiv) oder 2 (Passiv), B = laufender Index
##               INNERHALB des Typs (Tabellenspalte "Entity ID")
## id (oben) entspricht der Tabellenspalte "ITEM ID" - dafuer ist kein
## separates Feld noetig.
@export var nr: int = 0
@export var entity_id: String = ""

## Der kursive Einzeiler unter dem Namen ("Schlag die Hitze zurueck").
@export_multiline var flavor_text: String = ""

## Die mechanische Erklaerung fuers HUD unten links.
@export_multiline var description: String = ""

@export var icon: Texture2D
@export var kind: Kind = Kind.PASSIVE
@export var category: Category = Category.UTILITY

## Nur fuer ACTIVE: nach so vielen gecleareten Raeumen ist es wieder bereit.
##
## Wird IGNORIERT, sobald cooldown_seconds > 0 ist.
@export var charge_rooms: int = 2

## PHASE 4 — NEU: sekundenbasierter Cooldown.
##
## WARUM ES BEIDE MECHANIKEN GIBT:
## Das urspruengliche Aktiv-Item-System laedt ueber GECLEARTE RAEUME auf
## (charge_rooms). Fuer die acht Aktiv-Items aus dem Design-Dokument passt
## das nicht: dort stehen Sekunden ("Sturmfeuerzeug 3s", "Walkman 12s"), und
## ein Item, das man erst nach dem naechsten Raum wieder benutzen darf, ist
## etwas voellig anderes als eines mit 3 Sekunden Abklingzeit.
##
## 0.0 = alte Raum-Aufladung benutzen. > 0.0 = Sekunden-Cooldown, wobei
## charge_rooms dann unbeachtet bleibt. Beides gleichzeitig waere ein
## Doppel-Gate, bei dem nie klar ist, welches gerade blockiert.
##
## SONDERFALL "1x pro Etage" (Schulbibliotheks-Buch): weder das eine noch
## das andere. Das laeuft ueber charge_rooms = 0 UND cooldown_seconds = 0
## plus die Sperre in item_behaviours.gd (_book_used_in_stage).
@export var cooldown_seconds: float = 0.0


## true, wenn dieses Item ueber Sekunden statt ueber Raeume auflaedt.
func uses_time_cooldown() -> bool:
	return cooldown_seconds > 0.0

## Reine Stat-Boni, die ohne eigenen Code auskommen.
## Format: { PlayerStats.STAT_* : { "add": float, "mul": float } }
## Beispiel: { "damage": { "mul": 1.15 } } fuer +15 % Schaden.
@export var stat_modifiers: Dictionary = {}

## Seltenheit. Setzt beim Zuweisen automatisch pedestal_color mit - es sei
## denn, pedestal_color wurde vorher von Hand gesetzt (dann gewinnt die
## Handeingabe, siehe _pedestal_color_overridden).
@export var rarity: Rarity = Rarity.COMMON:
	set(value):
		rarity = value
		if not _pedestal_color_overridden:
			pedestal_color = rarity_color(value)

## Farbe des schwebenden Sockel-Wuerfels im Raum - und, seit Einfuehrung
## der Rarity, auch die Farbe des Drops, des HUD-Chips und des Eintrags in
## der Run-Uebersicht. Wird normalerweise NICHT mehr von Hand gesetzt,
## sondern aus rarity abgeleitet.
## Literal statt rarity_color(...): ein Member-Initialisierer, der eine
## statische Funktion DERSELBEN Klasse aufruft, laeuft waehrend die Klasse
## noch initialisiert wird. Der Wert unten ist identisch mit
## rarity_color(Rarity.COMMON) - bei einer Palettenaenderung mit anpassen.
@export var pedestal_color: Color = Color(0.72, 0.74, 0.78):
	set(value):
		pedestal_color = value
		_pedestal_color_overridden = true

## true, sobald pedestal_color explizit gesetzt wurde. Verhindert, dass
## eine spaetere Rarity-Zuweisung eine bewusst gewaehlte Sonderfarbe
## ueberschreibt.
var _pedestal_color_overridden: bool = false


## Die Farbtabelle. EINE Stelle - wer die Palette aendern will, aendert sie
## hier und nirgends sonst.
##
## Die Werte sind bewusst hell und gesaettigt: die Sockel-Wuerfel stehen in
## dunklen Raeumen und leuchten mit emission, gedaempfte Toene waeren dort
## nicht auseinanderzuhalten.
static func rarity_color(value: Rarity) -> Color:
	match value:
		Rarity.UNCOMMON:
			return Color(0.42, 0.85, 0.40)   # gruen
		Rarity.RARE:
			return Color(0.35, 0.62, 0.98)   # blau
		Rarity.EPIC:
			return Color(0.70, 0.42, 0.95)   # lila
		Rarity.LEGENDARY:
			return Color(0.95, 0.28, 0.26)   # rot
	return Color(0.72, 0.74, 0.78)           # grau (COMMON)


static func rarity_name(value: Rarity) -> String:
	match value:
		Rarity.UNCOMMON:
			return "Ungewoehnlich"
		Rarity.RARE:
			return "Selten"
		Rarity.EPIC:
			return "Episch"
		Rarity.LEGENDARY:
			return "Legendaer"
	return "Gewoehnlich"


func get_rarity_color() -> Color:
	return rarity_color(rarity)


func get_rarity_name() -> String:
	return rarity_name(rarity)

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
		p_category: Category = Category.UTILITY,
		p_rarity: Rarity = Rarity.COMMON,
		p_nr: int = 0,
		p_entity_id: String = ""
) -> ItemData:
	var data := ItemData.new()
	data.id = p_id
	data.display_name = p_name
	data.flavor_text = p_flavor
	data.description = p_description
	data.kind = p_kind
	data.category = p_category
	data.nr = p_nr
	data.entity_id = p_entity_id
	# ZULETZT: der Setter von rarity schreibt pedestal_color mit. Stuende
	# die Zeile weiter oben, koennte eine spaetere Zuweisung sie wieder
	# ueberschreiben.
	data.rarity = p_rarity
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



