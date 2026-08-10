---
script_path: scenes/level_generation/level_generator.gd
tags: [architecture, levelgen]
---

# level_generator.gd

Zentrale Klasse der prozeduralen Level-Generierung. Baut ein Etagen-Layout
aus `RoomData`-Vorlagen, platziert Gegner ueber ein **Threat-Budget**-System
(siehe `_table_for_type()` / `_budget_for_type()` / `_pick_room()`) und
verwaltet Minimap-Fog-of-War, Bosstueren und Etagenwechsel.

## Threat-Budget statt fester Spawn-Listen

Jeder Kampfraum bekommt ein Punktebudget; jeder Gegnertyp kostet Punkte
(`EnemySpawnEntry.threat_cost`, siehe [[fighter]], [[stinger]],
[[colossus]]). Ein Raum kann dadurch entweder viele billige Stinger ODER
wenige teure Fighter enthalten — die Schwierigkeit bleibt vergleichbar, die
Zusammensetzung variiert.

## Multi-Zellen-Raeume (Phase 3.1)

Raeume koennen mehr als eine Rasterzelle belegen (`footprint_cells`, z.B.
`2x1`, `1x2`, `2x2` — siehe [[combat_arena_01]], [[combat_wide_01]],
[[combat_tall_01]]). Die Grundflaechen werden NACHGELAGERT vergeben
(`_assign_footprints`), nicht waehrend des Baumwachstums — ein 2x2-Raum
haette waehrend des Wachstums vier Frontier-Positionen auf einmal
verbraucht und die Verzweigung zerstoert. Ein Multi-Zellen-Raum hat dadurch
GENAU DIE Ausgaenge seiner Ankerzelle (hoechstens einen je Himmelsrichtung);
`RoomInstance._doors_by_dir` bleibt unveraendert nutzbar.

Wichtig: der Generator kann eine Tuer verschieben (`set_exit_offset()`),
aber NICHT die Wandluecke — die steht als fester `Transform3D` in der
`.tscn`. Deshalb platzieren Multi-Zellen-Szenen Tuer, ExitPoint und
Wandluecke selbst auf der Ankerachse, statt `set_exit_offset()` automatisch
aufzurufen.

## Etagen-Progression

`generate_stage()` / `get_stage_theme()`: der Seed geht mit der
Etagennummer in die Layout-Ableitung ein (`"layout:<stage>"`), jede Etage
bekommt so ein eigenes, reproduzierbares Muster. Es gibt bewusst KEIN
`reload_current_scene()` beim Etagenwechsel — Items, PartyManager,
PlayerStats und der Spieler-Node ueberleben, nur die Raeume werden
getauscht. Geleert werden ausschliesslich Statuseffekte, Drops, Hazards und
Projektile der alten Etage.

## Bekannte Bugfixes (Auszug)

- **"1x2-Raum zeigt sich als 1x1 auf Minimap/ingame"**
- **"Stufe vor der Tuer / Rampe endet auf falscher Hoehe"**
- **"Boss-Tuer ist manchmal nicht rot"**
- **"Im Bossraum eingesperrt"**
- **"Hacking waehrend des Kampfs moeglich"** — Tresor-/Boss-Tueren pruefen
  jetzt `treasure_door_cleared()` bzw. den Raumzustand, bevor sie sich
  hacken lassen.
- **"Trophaee liegt unter dem Boden"**

## Verwandt

- [[stage_theme]] (falls vorhanden) — Farbwelt pro Etage.
- Alle Notizen unter `01_Game_Design/Rooms/`.
- [[custom_enemy_base]] / [[enemy_sandbox_room]] — sechs neue Gegnertypen,
  die noch NICHT in den Threat-Budget-Tabellen dieser Klasse stecken.

## Erwaehnt in DevLogs

- —
