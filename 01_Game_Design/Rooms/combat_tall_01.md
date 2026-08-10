---
id: "combat_tall_01"
room_type: COMBAT
footprint_cells: "1x2"
available_exits: ["Norden", "Sueden", "Osten", "Westen"]
spawn_weight: 1.0
min_stage: 0
unique_per_run: false
scene_path: "scenes/rooms/combat/room_combat_tall_01.tscn"
tags: [room, "room/combat"]
---

# combat_tall_01

## Layout

| Feld | Wert |
|---|---|
| Typ | COMBAT |
| Grundflaeche | 1x2 Rasterzellen |
| Tueren | Norden, Sueden, Osten, Westen |
| Ziehgewicht | 1.0 |
| Min. Etage | 0 |
| Einmalig pro Run | Nein |

Multi-Zellen-Raum: hat nur die Ausgaenge seiner Ankerzelle (RoomInstance._doors_by_dir bleibt unveraendert). Grundflaeche in Welt-Einheiten = footprint_cells * 48.

## Quelle

`resources/rooms/rd_combat_tall_01.tres` → `scenes/rooms/combat/room_combat_tall_01.tscn`
