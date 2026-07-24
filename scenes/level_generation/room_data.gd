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
