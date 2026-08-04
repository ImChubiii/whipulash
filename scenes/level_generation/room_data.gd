
extends Resource
class_name RoomData

## Referenz auf die tatsächliche Raum-Szene (.tscn)
@export var scene: PackedScene

## Kategorie steuert, wo der Raum im Layout eingesetzt werden darf
enum RoomType { COMBAT, TREASURE, BOSS, CORRIDOR, SHOP, START }
@export var room_type: RoomType = RoomType.COMBAT

## Welche Seiten dieser Raum-Vorlage physisch eine Tür besitzen.
## Bitmask: Norden=1, Süden=2, Osten=4, Westen=8 - deckt sich exakt mit
## RoomGridGenerator.DIRECTION_FLAG und RoomInstance.EXIT_*.
## Der Grid-Generator wählt nur Räume, deren available_exits MINDESTENS
## die vom Layout geforderten Richtungen abdeckt (required & available
## == required). Überschüssige Türen der Vorlage werden zur Laufzeit
## dauerhaft zugesperrt (siehe RoomInstance.apply_exit_flags).
@export_flags("Norden:1", "Süden:2", "Osten:4", "Westen:8") var available_exits: int = 15

## Optionale Gewichtung, wie oft dieser Raum im Vergleich zu anderen
## des gleichen Typs gezogen wird (höher = wahrscheinlicher)
@export var spawn_weight: float = 1.0

## Mindest-Spielfortschritt (z.B. "Etage 3"), ab dem dieser Raum
## überhaupt in den Pool aufgenommen wird (für schwierigere Varianten)
@export var min_stage: int = 0

## Verhindert, dass derselbe Raum zweimal im gleichen Run vorkommt
@export var unique_per_run: bool = false

## ############################################################################
## PHASE 3.1 — MULTI-ZELLEN-RAEUME
## ############################################################################
## Wie viele RASTERZELLEN diese Raum-Vorlage belegt. (1,1) = klassischer
## Einzelraum, (2,1) = doppelt so breit, (2,2) = grosse Arena.
##
## MUSS ZUR SZENE PASSEN: RoomInstance.room_footprint in der .tscn ist die
## Groesse in WELT-Einheiten. Bei einer Basiszelle von 48x48 gilt
##     room_footprint == footprint_cells * 48
## Ein Raum mit footprint_cells = (2,1) braucht also room_footprint =
## Vector2(96, 48). Stimmt das nicht ueberein, sitzt der Raum zwar an der
## richtigen Stelle, aber Decke, EntryTrigger und PresenceArea haben die
## falsche Groesse — sichtbar daran, dass der Kampf schon ausloest, bevor man
## den Raum betreten hat, oder gar nicht.
##
## GRENZE: der Grid-Generator blaest nur KAMPFRAEUME auf. Start, Boss, Tresor
## und Korridore bleiben immer (1,1); eine Vorlage mit anderem Typ und
## groesserer Grundflaeche wird nie gezogen.
@export var footprint_cells: Vector2i = Vector2i.ONE


## Anzahl belegter Rasterzellen. Praktisch fuer Gewichtungen und Logausgaben.
func cell_count() -> int:
	return maxi(footprint_cells.x, 1) * maxi(footprint_cells.y, 1)


func is_multi_cell() -> bool:
	return footprint_cells.x > 1 or footprint_cells.y > 1
