---
script_path: scripts/treasure_manager.gd
autoload_name: Treasure
tags: [architecture, autoload]
---

# treasure_manager.gd

Autoload (`Treasure`). Setzt in jeden erkannten Schatzraum genau einen
Item-Sockel (`TreasurePedestal`). Existiert, weil `item_catalog.gd`,
`item_behaviours.gd`, `player_stats.gd` und `item_description_hud.gd` schon
vollstaendig fertig waren, aber `Pickup.create_item()` nirgends im Projekt
aufgerufen wurde — acht fertige Items existierten im Spiel schlicht nicht.
`treasure_manager.gd` schliesst genau diese Luecke, nicht mehr.

**Design-Vorgabe (Isaac-Vorbild):** Items findet man ausschliesslich im
Schatzraum, einzeln, mittig auf einem Sockel. Bewusst NICHT ueber
[[loot_manager]] (existiert nicht als Notiz, siehe `scripts/loot_manager.gd`)
gebaut: der wuerfelt Verbrauchsgueter nach Raum-Clear aus und waere fuer
eine garantierte, einmalige Belohnung der falsche Mechanismus.

## Erkennung: SceneTree.node_added statt Generator-Hook

Genau wie `loot_manager.gd` haengt sich `Treasure` ueber
`get_tree().node_added` an neu hinzugefuegte `RoomInstance`-Nodes, statt
`level_generator.gd`/`room_instance.gd` direkt zu aendern. Damit funktioniert
die Erkennung sowohl fuer generierte Level als auch fuer handgebaute
Testszenen, die eine `RoomInstance` direkt in der `.tscn` haben.

Ein Raum gilt als Schatzraum, wenn EINER von drei Wegen zutrifft
(`_detection_reason()`, als String statt bool, damit im Log steht, WELCHER
Weg gegriffen hat):

1. Raum ist in der Gruppe `"treasure_room"`.
2. `scene_file_path` enthaelt `/treasure/`.
3. Der LevelGenerator meldet fuer die Rasterzelle `RoomData.RoomType.TREASURE`
   (Zugriff auf `generator._map_cells`, das per Gruppe `"level_generator"`
   gefunden wird).

## Bekannter, behobener Fehler: verfrühte Auswertung in `_on_node_added`

`level_generator.load_room()` laeuft in dieser Reihenfolge ab:
`instantiate()` → `add_child()` (hier feuert `node_added`) → erst danach
wird `global_transform` gesetzt, und im Aufrufer erst danach
`grid_position`. Die urspruengliche Fassung werten direkt in
`_on_node_added` aus und sah deshalb einen Raum, der noch bei `(0,0,0)`
stand und dessen `grid_position` noch `(0,0)` war — der dritte Erkennungsweg
(Generator-Zellentyp) war dadurch faktisch tot, und der RNG-Salt fuer die
Item-Auswahl (siehe unten) haette fuer verschiedene Raeume denselben Wert
ergeben.

**Fix:** `_on_node_added` merkt sich jetzt nur noch, dass ein `RoomInstance`
aufgetaucht ist, und sperrt ihn sofort in `_handled_rooms` (vor jedem
`await`, sonst laeuft derselbe Raum ueber `node_added` UND ueber den
`_scan_existing()`-Rekursionsdurchlauf beim Start doppelt durch). Die
eigentliche Pruefung/Spawn-Entscheidung passiert eine Physik-Frame spaeter
in `_process_room_deferred()`, wenn Transform, `grid_position` und
Kollisionsformen stehen.

## Sockelposition: warum der Bodenstrahl nicht von ganz oben startet

`room_instance.gd` baut in `_build_ceiling()` eine kollidierende Decke
(`StaticBody3D`, Oberkante bei exakt `y = 15.0`). Ein Strahl, der 40 m ueber
dem Raum startet, traf frueher zuerst das Dach statt des Bodens — der Sockel
landete bei `y = 15.02`, ausserhalb des begehbaren Raums, unsichtbar fuer
den Spieler, und zwar **ohne jede Fehlermeldung**, weil der Raycast
technisch erfolgreich war.

Zwei Absicherungen in `_find_spawn_position()`:

1. Der Strahl startet auf halber Raumhoehe (`room.room_height * 0.5`,
   geklemmt), also garantiert unterhalb der Decke.
2. Decke und Tuersturz-Koerper (`Ceiling`, `DoorLintel*`) werden zusaetzlich
   explizit per `query.exclude` ausgeschlossen (`_collect_ceiling_rids()`),
   falls `room_height` irgendwann kleiner als die Deckenhoehe gesetzt wird.

Der Raum-Ursprung (Raummitte) wird als Ausgangspunkt genutzt, nicht
`room.get_room_center()` — die liefert im Schatzraum-Prefab den ersten
`LootSpawnPoint`-Marker bei `(-4, 2.1, -4)`, also eine Ecke der Plattform,
was den Sockel sichtbar schief haette stehen lassen.

## Item-Auswahl: deterministisch, gewichtet, pool-basiert

`_pick_item()` baut einen Pool aus dem `Items`-Katalog (Autoload-Reihenfolge
`Items` VOR `Treasure` ist Voraussetzung — fehlt `Items`, gibt es keinen
Sockel). Items mit erreichter `max_stacks`-Grenze fallen raus (sonst stuende
der Spieler vor einem `[F]`, das nichts tut). Ist der Pool nach Abzug
bereits reservierter IDs leer, werden Duplikate wieder zugelassen
(`_reserved_ids.clear()`) — ein Duplikat gilt als besser als ein leerer
Schatzraum. `avoid_duplicates` ist standardmaessig `false`: da jedes Item
ohnehin `max_stacks = 0` (unbegrenzt) hat, sollen Items beliebig oft wieder
angeboten werden koennen; `true` stellt die alte "ein Item nur einmal pro
Lauf"-Regel wieder her.

`_weighted_pick()` gewichtet nicht gleich: Grundgewicht `1.0` pro Item, plus
`ItemManager.get_synergy_weight()` fuer bereits gesammelte Synergie-Tags,
plus ein additiver `SaveGame.get_item_weight_bonus()` (Meta-Progression aus
dem Hub) — beide Boni stapeln sich. Ohne jeden Bonus (frischer Run, keine
Meta-Upgrades) ist `total_weight == pool.size()` und das Ergebnis entspricht
reiner Gleichverteilung.

Die RNG selbst ist **deterministisch aus Run-Seed + Rasterposition +
aktueller Etage** (`_make_rng()`, Salt `"treasure:<x>:<y>:<stage>"`, ueber
`DetRng.derive()`), nicht der globale Gameplay-RNG (`det_rng.gd`) — analog
zur Begruendung bei [[level_generator]]/`loot_manager.gd`: derselbe
Leaderboard-Seed soll denselben Sockelinhalt reproduzieren.

## Drei Sockel-Varianten aus einem Pfad

`_spawn_pedestal()` verzweigt VOR der Item-Auswahl:

- `room.character_unlock != null` (Tutorial-Modus, `RoomInstance`-Export) →
  `CharacterPedestal` statt Item-Sockel; `_pick_item()`/`_reserved_ids`
  bleiben fuer diesen Raum komplett unberuehrt. `character_taken` (eigenes
  Signal-Paar statt Ueberladung von `treasure_item_taken`) treibt in
  `level_generator._setup_tutorial_ui()` die Charakter-Vorstellung.
- `room.is_sacrifice_room == true` (Blutzoll-Raeume, siehe
  [[treasure_sacrifice_01]]) → `SacrificePedestal` statt `TreasurePedestal`:
  optisch/interaktiv identisch, kostet aber HP beim Nehmen. Der Zugriff
  laeuft bewusst ueber den statisch typisierten `room.is_sacrifice_room`
  und nicht mehr ueber `bool(room.get("is_sacrifice_room"))` — ein
  dynamischer Property-Zugriff wuerde bei Tippfehler/umbenanntem Feld still
  auf `null` (→ `false`) zurueckfallen statt beim Laden einen Parse-Fehler
  zu werfen.
- Alles andere → normaler `TreasurePedestal`.

## Tuer-Sperre / Gate (Zusammenspiel mit level_generator.gd)

`treasure_manager.gd` selbst prueft keine Tuer-Locks — das Freischalten des
Schatzraums (Hacken der Tuer) ist Sache von `room_instance.gd`/
`hack_prompt.gd` und `level_generator.gd`. Ein behobener Bug dort
("Hacking waehrend des Kampfs moeglich") liess sich erst hacken, nachdem
`treasure_door_cleared()` bzw. der Raumzustand geprueft wird — siehe
[[level_generator]]. `Treasure` reagiert nur auf das Erscheinen der
`RoomInstance` selbst, nicht auf deren Freischalt-Zustand; der Sockel steht
also schon im Raum, bevor die Tuer offen ist, nur eben unerreichbar.

## Run-Reset ueber Seed-Vergleich statt expliziten Reset-Aufruf

`_maybe_reset_for_new_run()` erkennt einen neuen Lauf daran, dass sich der
Run-Seed (`_get_run_seed()`, ueber die `"level_generator"`-Gruppe) gegenueber
`_last_seen_seed` geaendert hat, und leert dann `_reserved_ids`. Das ist
noetig, weil `generate_stage()` bewusst KEIN `reload_current_scene()`
ausloest (siehe [[level_generator]]) — ohne diesen Vergleich wuerde
`Treasure` reservierte Item-IDs ueber Etagenwechsel hinweg mitschleppen.
`reset_run()` existiert zusaetzlich als expliziter Aufruf fuer einen echten
Neustart, parallel zu `Loot.reset_run()`/`Items.reset_run()`.

## Diagnose-Bausteine

`debug_logging` (@export, Default `true`) loggt jeden gesehenen Raum
inklusive Erkennungsergebnis unter `[Treasure]` — die Start-Zeile
"Autoload aktiv. Warte auf RoomInstances." ist der Lebensbeweis: fehlt sie,
ist der Autoload nicht eingetragen, und jede andere Fehlersuche waere
Zeitverschwendung. `debug_spawn_in_every_room` erzwingt einen Sockel in
JEDEM Raum, um zu klaeren, ob ein Problem bei der Raum-Erkennung oder beim
Spawnen selbst liegt. `debug_spawn_at_player()` setzt sofort einen
Test-Sockel vor die Spielerposition, ohne einen echten Schatzraum
freizuhacken.

## Verwandt

- [[level_generator]] — dritter Erkennungsweg (`_map_cells`/`RoomType.TREASURE`),
  Run-Seed/Etagenwechsel-Semantik, Tuer-Hack-Gating.
- [[treasure_sacrifice_01]] — Raumvorlage, die `is_sacrifice_room` setzt.
- [[party_manager]] — `character_taken` treibt im Tutorial-Modus den
  Charakterwechsel/-freischaltung.

## Erwaehnt in DevLogs

- [[2026-07-27_0c0e515_feat_treasure_room_items_hud_overhaul_balancing_mu]]
- [[2026-07-27_f88829f_feat_treasure_room_items_hud_overhaul_balancing_mu]]
- [[2026-08-01_3bbac00_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
- [[2026-08-01_5d2ca05_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
- [[2026-08-12_f23c551_feat_combat_mechanics_weighted_item_drops_and_ui_t]]
- [[2026-08-14_e766d00_feat_umfangreiches_update_-_gameplay_ui_level-gene]]
- [[2026-07-26_161c399_feat_stat-system_loot-drops_bomben_items_und_game_]]
- [[2026-07-26_ec9ce70_feat_stat-system_loot-drops_bomben_items_und_game_]]
