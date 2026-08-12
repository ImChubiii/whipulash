---
id: "combat_arena_01"
room_type: COMBAT
footprint_cells: "2x2"
available_exits: ["Norden", "Sueden", "Osten", "Westen"]
spawn_weight: 1.0
min_stage: 2
unique_per_run: false
scene_path: "scenes/rooms/combat/room_combat_arena_01.tscn"
tags: [room, "room/combat"]
---

# combat_arena_01

## Layout

| Feld | Wert |
|---|---|
| Typ | COMBAT |
| Grundflaeche | 2x2 Rasterzellen |
| Tueren | Norden, Sueden, Osten, Westen |
| Ziehgewicht | 1.0 |
| Min. Etage | 2 |
| Einmalig pro Run | Nein |

Multi-Zellen-Raum: hat nur die Ausgaenge seiner Ankerzelle (RoomInstance._doors_by_dir bleibt unveraendert). Grundflaeche in Welt-Einheiten = footprint_cells * 48.

## Erwaehnt in DevLogs

- —

## Quelle

`resources/rooms/rd_combat_arena_01.tres` → `scenes/rooms/combat/room_combat_arena_01.tscn`

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[combat_arena_01]] (Confidence: 1.0)
