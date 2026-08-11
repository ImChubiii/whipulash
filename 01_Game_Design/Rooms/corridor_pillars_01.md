---
id: "corridor_pillars_01"
room_type: CORRIDOR
footprint_cells: "1x1"
available_exits: ["Norden", "Sueden"]
spawn_weight: 1.0
min_stage: 0
unique_per_run: false
scene_path: "scenes/rooms/corridor/room_corridor_pillars_01.tscn"
tags: [room, "room/corridor", "room/parkour"]
---

# corridor_pillars_01

Neuer Parkour-Korridortyp neben [[corridor_abyss_01]]/[[corridor_abyss_02]]/
[[corridor_abyss_03]]: statt eines einzelnen ueberspringbaren Spalts liegt
hier EIN durchgehender Instant-Kill-Abgrund (`extra_void_pits`, siehe
[[pit_floor|PitFloor]]) ueber den mittleren 28 der 48 Laengeneinheiten des
Korridors. Fuenf im Zickzack versetzte Pfeiler (2.4x2.4, `Pillars/Pillar1..5`)
sind der einzige Weg hinueber - wer daneben springt, faellt in die
Instant-Kill-Zone (siehe `void_kill_depth` in `pit_floor.gd`).

## Layout

| Feld | Wert |
|---|---|
| Typ | CORRIDOR |
| Grundflaeche | 1x1 Rasterzellen |
| Tueren | Norden, Sueden |
| Ziehgewicht | 1.0 |
| Min. Etage | 0 |
| Einmalig pro Run | Nein |
| Abgrund | 1x durchgehend, 20x28 (statt 2x kurzer Spalt bei den abyss-Varianten) |
| Pfeiler | 5, zickzack versetzt (x = ±4) |

Achtung: Pfeiler-Abstaende sind eine erste Annahme (kein In-Editor-Playtest
moeglich) - vor dem Live-Einsatz Sprungdistanz gegen die tatsaechliche
Spieler-Sprungweite pruefen und ggf. `Pillars/Pillar*`-Transforms nachziehen.

## Erwaehnt in DevLogs

- —

## Quelle

`resources/rooms/rd_corridor_pillars_01.tres` → `scenes/rooms/corridor/room_corridor_pillars_01.tscn`
