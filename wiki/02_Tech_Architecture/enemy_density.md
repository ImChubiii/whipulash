---
script_path: scripts/enemies/enemy_density.gd
autoload_name: EnemyDensity
tags: [architecture, autoload]
---

# enemy_density.gd

Autoload (`EnemyDensity`). Vervielfacht nachtraeglich die Gegner-Spawnpunkte
jedes [[level_generator|generierten]] Raums, ohne `room_instance.gd` selbst
anzufassen.

## Zwei Deckel, nur einer war das Budget

"Mehr Gegner" liess sich nicht einfach durch Hochdrehen des Threat-Budgets
erreichen, weil zwei unabhaengige Obergrenzen gleichzeitig griffen:

1. **Budget** — `level_generation_test.tscn` ueberschreibt
   `combat_threat_budget`/`threat_hard_cap`; der Script-Default in
   `level_generator.gd` ist dadurch wirkungslos.
2. **Spawnpunkte** — `room_instance._roll_enemy_mix()` bricht hart ab, sobald
   `result.size() >= enemy_spawn_points.size()`. Die Anzahl der `Marker3D`
   unter `EnemySpawnPoints` in der Raum-Szene ist damit die tatsaechliche
   Obergrenze, unabhaengig vom Budget.

Der zweite Deckel ist der Grund fuer dieses Autoload.

## Warum als Autoload statt als Aenderung an room_instance.gd

Die Alternative waere, in jeder Raum-Szene von Hand zusaetzliche Marker zu
setzen — und das bei jedem neuen Raum erneut, oder `room_instance.gd`
(~1800 Zeilen) umzubauen. Stattdessen haengt sich `EnemyDensity` von aussen
in `SceneTree.node_added` ein: sobald ein `RoomInstance` im Baum auftaucht,
ergaenzt es dessen `enemy_spawn_points`-Liste um zusaetzliche, ringfoermig um
jeden Original-Marker verteilte Punkte (`extra_points_per_marker`, Default 2
= dreifache Gesamtzahl). Der bestehende Spawn-Code merkt keinen Unterschied,
er sieht nur eine laengere Liste — dasselbe Muster wie bei `Loot`,
`Treasure` und `RoomGuard`.

## Timing

`LevelGenerator` ruft `prepare_enemies()` direkt nach dem Instanziieren auf,
prueft die Spawnpunkt-Liste dort aber nur auf "ist sie leer". Die eigentliche
Auswahl (`_roll_enemy_mix`) und das Spawnen laufen erst beim Betreten des
Raums. Die Zusatzmarker muessen also lediglich vor dem Betreten stehen — ein
`call_deferred` plus eine abgewartete `physics_frame` reicht mit deutlichem
Abstand, da erst danach `room_footprint`, die Welt-Transform und die bereits
bodengeschnappten Original-Marker feststehen.

## Determinismus

Kein `RandomNumberGenerator`: Position und Reihenfolge der Zusatzpunkte
ergeben sich rein geometrisch aus Marker-Index und Winkel. Zwei Runs mit
demselben Seed erzeugen dadurch exakt dieselben Zusatzmarker in derselben
Reihenfolge — sonst waeren die verifizierbaren Speedrun-Seeds (`det_rng.gd`)
beim ersten Gegner schon hinfaellig.

## Gueltigkeits-Checks pro Kandidat

Jeder Zusatzpunkt muss nacheinander bestehen: innerhalb des Grundrisses mit
Sicherheitsabstand (`_is_inside_room`, im lokalen Raumkoordinatensystem
gerechnet, da `room_footprint` dort definiert ist), ein Boden-Raycast von
oberhalb des Punktes nach unten (`_snap_to_ground` — von oben, nicht von der
Decke aus, sonst trifft der Strahl zuerst die Decke, derselbe Fehler wie
einst beim Sockel-Raycast in `treasure_manager.gd`), und optional kein
Ueberlapp mit einer `lava_hazards`-Flaeche (`avoid_hazards`) — ein Gegner,
der sofort beim Spawn Schaden nimmt, sieht nach Bug aus, nicht nach Absicht.

`ring_radius = 4.5` liegt bewusst zwischen dem `min_spawn_spacing` von
Stinger (3.0) und Fighter (6.0): Stinger duerfen sich dicht draengen, Fighter
verteilen sich ueber `_take_spawn_point()` automatisch auf weiter
auseinanderliegende Punkte.

## Verwandt

- [[level_generator]] — Threat-Budget und Raum-Instanziierung, deren
  Spawnpunkt-Deckel dieses Autoload umgeht.

## Erwaehnt in DevLogs

- [[2026-08-01_5d2ca05_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
- [[2026-08-01_3bbac00_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
