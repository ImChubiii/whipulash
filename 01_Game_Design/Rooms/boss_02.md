---
id: "boss_02"
room_type: BOSS
footprint_cells: "1x1"
available_exits: ["Norden", "Sueden", "Osten", "Westen"]
spawn_weight: 1.0
min_stage: 0
unique_per_run: true
scene_path: "scenes/rooms/boss/room_boss_02.tscn"
tags: [room, "room/boss"]
---

# boss_02

Zweite Boss-Arena neben [[boss_01]] — gleiches 48x48/24 hohes Grundgeruest
(gleiche Wand-/Tuer-Konfiguration, damit die Geometrie erprobt bleibt), aber
bewusst anders in Layout und Hazard:

- **Deckung statt offener Flaeche:** vier 4x14x4-Pfeiler (`Pillars/Pillar1..4`)
  brechen die Sichtlinie zwischen den Ecken - der offene 48x48-Raum von
  [[boss_01]] gibt Fernkampf-Bossen/Adds freie Sicht auf jeden Punkt, hier
  muss man sich um Deckung bewegen.
- **Andere Hazard-Mechanik:** [[boss_01]] hat vier Lava-GRUBEN
  (`auto_pits_from_lava` bleibt an, PitFloor haengt sie ab). boss_02 setzt
  `auto_pits_from_lava = false` und `build_basin = false` - die zwei
  [[lemonade|Lemonade]]-Instanzen bleiben im SURFACE-Modus: flache,
  begehbare Pfuetzen (Schaden + Verlangsamung beim Durchwaten), KEIN
  Hinunterfallen. Liegen als zwei Baender quer durch die Raummitte, nicht in
  den Ecken - wer die Pfeiler-Deckung an den Seiten nutzt, umgeht sie.

Da beide Boss-Vorlagen `unique_per_run = true` und gleiches `spawn_weight`
haben, waehlt der Generator pro Run zufaellig genau eine der beiden fuer den
Bosskampf - nicht jeder Run sieht dieselbe Arena.

Offene Folgearbeit (nicht in dieser Iteration umgesetzt): echte
Gegner-Wellen (aktuell spawnt ein Boss-Raum wie jeder andere Raum einmalig
aus `boss_table`) sowie eigene, boss-spezifische Gegnerzusammensetzungen pro
Arena-Variante - beides braucht eine Erweiterung von [[level_generator]],
nicht nur ein neues Raum-Template.

## Layout

| Feld | Wert |
|---|---|
| Typ | BOSS |
| Grundflaeche | 1x1 Rasterzellen |
| Tueren | Norden, Sueden, Osten, Westen |
| Ziehgewicht | 1.0 |
| Min. Etage | 0 |
| Einmalig pro Run | Ja |
| Deckung | 4 Pfeiler (4x14x4), diagonal versetzt |
| Hazard | 2x Lemonade, SURFACE-Modus (keine Grube) |

## Erwaehnt in DevLogs

- —

## Quelle

`resources/rooms/rd_boss_02.tres` → `scenes/rooms/boss/room_boss_02.tscn`
