---
script_path: scripts/loot_manager.gd
autoload_name: Loot
tags: [architecture, autoload]
---

# loot_manager.gd

Autoload (`Loot`). Wuerfelt Drops (Muenzen/Heilung/Bombe), sobald ein Raum
`room_cleared` feuert. Kein eigener Zustand ueber den Lauf hinaus ausser
`_handled_rooms` (InstanceID → true) zur Doppel-Drop-Sperre.

## Warum ueber `SceneTree.node_added` statt ueber den LevelGenerator

`_on_node_added()` reagiert auf jeden neu eingefuegten `RoomInstance`-Node
und verbindet dessen `room_cleared`-Signal, unabhaengig davon, ob der Raum
vom `LevelGenerator` prozedural gebaut oder direkt in einer `.tscn`
(`level_01.tscn`, `nav_test_level.tscn`) verbaut wurde. Ein Autoload, das
sich stattdessen beim Generator anmeldet, wuerde in genau diesen
handgebauten Testszenen nie einen Drop ausloesen — und das faellt beim
Testen nicht auf, weil dort ohnehin selten aufgeraeumt wird. `_ready()`
verbindet `node_added` UND raeumt per `_scan_existing.call_deferred()` /
`_scan_recursive()` alle bereits vor dem Autoload-Start existierenden
Raeume nach, damit auch der allererste Raum einer Szene erfasst wird.

## Doppel-Drop-Sperre

`_on_room_cleared()` haelt `room_cleared` bewusst fuer wiederholbar:
laut `room_instance.gd` feuert das Signal aus mindestens zwei Stellen
(regulaeres Herunterzaehlen der Gegner und ein Watchdog). Ohne die
`_handled_rooms`-Sperre wuerde ein Raum bei doppeltem Feuern zweimal
droppen. Die Sperre lebt nur fuer die Dauer des Runs — `reset_run()` muss
beim Runstart explizit aufgerufen werden (siehe `pause_menu.gd`), sonst
haelt `Loot` Raeume aus dem vorherigen Lauf faelschlich fuer bereits
abgehandelt und droppt in einem neuen Run in denselben Grid-Positionen
nichts mehr.

## Deterministischer Pro-Raum-RNG statt globalem RNG

Die Drops haengen NICHT am globalen Gameplay-RNG (`det_rng.gd`). Der laeuft
auch fuer Screen-Shake und Schadenszahlen mit und ist nach ein paar Minuten
Spielzeit voellig unvorhersehbar weit fortgeschritten — ein Leaderboard-Seed
waere damit wertlos, weil zwei Laeufe mit identischem Seed trotzdem
unterschiedliches Loot haetten. `_make_rng()` leitet stattdessen pro Raum
einen eigenen RNG ab: `DetRng.derive(run_seed, "loot:<grid.x>:<grid.y>:<stage>")`.
Der Salt-String kombiniert Rasterposition und aktuelle Etage, sodass
identische Grid-Koordinaten auf verschiedenen Etagen nicht denselben RNG-
Zustand recyceln. `run_seed`/`stage` werden ueber die `level_generator`-
Gruppe (`get_tree().get_nodes_in_group("level_generator")`) abgefragt, nicht
per Autoload-Referenz — fehlt der Generator (z. B. in einer Testszene ganz
ohne Generator-Node), fallen `_get_run_seed()`/`_get_current_stage()` auf
`0`/`1` zurueck statt zu crashen.

## Dropchance: Basis + Glueck + Combo, gedeckelt

`_get_drop_chance()` addiert `BASE_DROP_CHANCE` (0.9), den `Items.get_luck()`-
Stat und einen Combo-Bonus (`get_combo_count() * LUCK_PER_COMBO_STEP`), dann
`clampf(..., 0.0, MAX_DROP_CHANCE)`. Die Deckelung auf 0.95 ist bewusst
knapp unter 100 % — bei exakt 100 % waere der Zufall komplett entwertet und
Loot Selbstverstaendlichkeit statt Belohnung. `max_drops_per_room` (Default
2) und `BASE_DROP_CHANCE` (0.78 → 0.9) wurden beide zusammen angehoben, um
auf Spieler-Feedback "Drop-Raten spuerbar erhoehen" zu reagieren: nicht nur
wahrscheinlicher, dass ueberhaupt etwas droppt, sondern auch mehr auf
einmal.

## Drop-Position: Marker bevorzugt, Spieler als Fallback — NICHT Raummitte

`_pick_position()` bevorzugt einen von Hand gesetzten `LootSpawnPoint`-
Marker (`room.loot_spawn_points`), weil der garantiert auf begehbarem Boden
liegt. Aktuell haben nur `room_treasure_01` und `room_boss_01` ueberhaupt
solche Marker — alle Combat- und Korridor-Raeume nicht. Der Fallback ist
deshalb bewusst NICHT `room.get_room_center()`: bei leerer Marker-Liste
liefert diese Methode laut `room_instance.gd` den Raum-URSPRUNG, nicht die
geometrische Mitte, und der liegt je nach Prefab in einer Ecke oder unter
dem Boden — der Drop waere ohne jede Fehlermeldung unsichtbar und praktisch
nicht auffindbar. Der tatsaechliche Fallback ist deshalb die Position des
Spielers selbst (der den Raum gerade geleert hat, also zwangslaeufig auf
begehbarem Boden steht) plus zufaelligem Versatz (±1.6 m horizontal), damit
mehrere Drops nicht exakt uebereinanderlanden. `room.get_room_center()`
bleibt nur die allerletzte Rueckfalloption, falls kein Spieler gefunden
wird.

## `spawn_random_drop()` — Sonderfall Verfluchter Gluecksduerfel

Oeffentliche Methode, aufgerufen aus `item_behaviours.gd`
(`_use_cursed_die`) als Fallback fuer am Boden liegende Pickups OHNE eigene
`reroll()`-Methode. Nutzt bewusst einen eigenen, nicht-deterministischen
`RandomNumberGenerator` (`randomize()`) statt `_make_rng()`, weil dieser
Aufruf kein Raum-Clear-Event ist und keinen Raumkontext hat, an dem sich
ein Seed festmachen liesse.

## Verwandt

- [[room_commit_guard]] — beide Autoloads haengen sich unabhaengig ueber
  `SceneTree.node_added` an `RoomInstance`-Nodes; `Loot` reagiert auf das
  `room_cleared`-Ende des Raum-Lebenszyklus, den `RoomGuard` am Anfang
  (Kampf-Ausloesung) absichert.
- [[level_generator]] — Quelle von `run_seed`/`current_stage`, die den
  Pro-Raum-RNG seeden.

## Erwaehnt in DevLogs

- [[2026-07-26_161c399_feat_stat-system_loot-drops_bomben_items_und_game_]]
- [[2026-07-26_ec9ce70_feat_stat-system_loot-drops_bomben_items_und_game_]]
- [[2026-08-12_5f8cd6d_feat_combat_mechanics_weighted_item_drops_and_ui_t]]
- [[2026-08-12_e219233_feat_combat_mechanics_weighted_item_drops_and_ui_t]]
- [[2026-08-12_f23c551_feat_combat_mechanics_weighted_item_drops_and_ui_t]]
