---
id: "combat_01"
display_name: "Die Kammer"
room_type: COMBAT
footprint_cells: "1x1"
available_exits: ["Norden", "Sueden", "Osten", "Westen"]
spawn_weight: 1.0
min_stage: 0
unique_per_run: false
scene_path: "scenes/rooms/combat/room_combat_01.tscn"
tags: [room, "room/combat"]
---

# combat_01 - Die Kammer

> *Ein kompakter 1x1 Kampfraum, der beim Betreten verriegelt wird.*

## Layout
| Feld | Wert |
|---|---|
| Typ | COMBAT |
| Grundflaeche | 1x1 |
| Ausgaenge | Norden, Sueden, Osten, Westen |
| Spawn-Gewicht | 1.0 |
| Ab Etage | 0 |

## Was dich erwartet
Sobald du diesen Raum betrittst, schnappen die Tueren zu und verriegeln sich automatisch. Das Spawnsystem nutzt das Threat-Budget, um den Raum entweder mit einer Welle schwacher Gegner oder wenigen schweren Brocken zu füllen. Erst wenn der letzte Feind besiegt ist, entriegeln sich die Tueren wieder.

## Tipps
- Nutze die verbleibende Deckung, um Feinde nacheinander auszuschalten, anstatt dich umzingeln zu lassen.
- Halte die Tueren im Auge, um nach dem Entriegeln schnell den nächsten Bereich anzusteuern.

## Weitere Räume
- [[_MOC_Rooms|Alle Räume]]
