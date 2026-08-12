---
commit: "161c399f496aac4c0e5004f565a902558864de94"
short_hash: "161c399"
date: 2026-07-26
author: "ImChubiii"
subject: "feat: Stat-System, Loot-Drops, Bomben, Items und Game Juice"
tags: [devlog]
---

# 2026-07-26 — feat: Stat-System, Loot-Drops, Bomben, Items und Game Juice

Neues Fundament fuer Progression und Trefferfeedback. Bewusst so gebaut,
dass keine Charakter- oder Raum-Szene angefasst werden musste: die
Laufzeit-Komponenten haengen sich selbst an, alle Pickups und HUD-Teile
bauen ihr Aussehen im Code auf. Damit gibt es keine neuen .tscn und keine
Ressourcenpfade, die brechen koennen.

Stat-System (player_stats.gd)
- Zentrale Werte fuer Schaden, Tempo, Angriffstempo, Glueck, Magnetradius,
  Ruestung und Hazard-Widerstand. Formel je Stat: (basis + add) * mul —
  additive Boni zuerst, damit die Aufsammel-Reihenfolge das Ergebnis nicht
  veraendert.
- PUSH statt PULL: die Komponente merkt sich beim Anhaengen die Basiswerte
  des Charakters und schreibt die fertig gerechneten Werte zurueck in
  player_base.speed, Hitbox.damage, CombatBase.dash_damage und
  Health.max_health. player_base.gd und combat_base.gd bleiben dadurch
  komplett unangetastet — ein Pull-Ansatz haette Eingriffe in vier heisse
  Schleifen gebraucht.
- Basiswerte werden pro Spieler-INSTANZ gecached. Da der PartyManager die
  Instanz bei jedem Wechsel austauscht, behaelt jeder Charakter seine
  eigenen Grundwerte und die Item-Boni legen sich prozentual obendrauf.
- Zeitlich begrenzte Buffs (add_timed_modifier) laufen selbst ab.

Health (health.gd)
- Neu: Unverwundbarkeit mit eigenem Timer, incoming_damage_multiplier,
  set_max_health() und die Signale damage_taken / invulnerability_changed.
- Die Invuln-Pruefung liegt bewusst IN der Komponente statt in den
  Aufrufern: sonst muesste jede Schadensquelle (Hitbox, Lava, Bombe, Dash)
  sie einzeln pruefen, und die erste vergessene Stelle macht den Effekt
  wertlos.
- Abwaertskompatibel: take_damage/heal/is_alive/health_changed/died
  verhalten sich unveraendert.

Loot (loot_manager.gd, pickup.gd)
- Drops bei Raum-Clear. Basis 78 %, plus Glueck-Stat, plus 0,2 % pro
  Combo-Stufe, gedeckelt bei 95 %. Gewichte Muenze/Heilung/Bombe 40/30/15.
- Haengt sich ueber SceneTree.node_added an die Raeume, NICHT ueber den
  LevelGenerator: level_01 und die Testlevel enthalten RoomInstances direkt
  in der Szenendatei und haetten sonst nie gedroppt.
- Eigener RNG pro Raum, abgeleitet aus Run-Seed und Rasterposition. Der
  globale RNG laeuft laut det_rng.gd auch fuer Shake und Schadenszahlen —
  Loot daran zu haengen haette Seeds auf dem Leaderboard entwertet.
- Fallback-Position ist der Spieler, nicht get_room_center(): saemtliche
  Combat-Raeume haben (noch) keine LootSpawnPoints, und get_room_center()
  liefert bei leerer Markerliste den Raum-URSPRUNG zurueck. Das Pickup waere
  je nach Prefab in einer Wand oder unter dem Boden gelandet — ohne Fehler
  im Log, also praktisch nicht auffindbar.
- Pickup baut Muenze, Herz, Bombe und Item-Sockel selbst auf. Magnetradius
  kommt aus PlayerStats, damit das Kompass-Item ihn anheben kann, ohne dass
  das Pickup das Item kennen muss.

Bomben (bomb.gd, bomb_carrier.gd)
- X ruestet aus, X erneut legt ab, LMB wirft. Die Zuendschnur laeuft ab dem
  AUSRUESTEN: nur dadurch entsteht die Entscheidung "jetzt werfen oder noch
  kurz zielen". Ein Timer, der erst beim Ablegen startet, ist nur eine
  Verzoegerung.
- Waehrend die Bombe in der Hand ist, wird das Combat-Node stillgelegt.
  LMB ist gleichzeitig attack_primary, und CombatBase POLLT die Action —
  set_input_as_handled() greift dagegen nicht.
- Schiebbar ueber einen eigenen Push-Bereich: CharacterBody3D uebertraegt in
  Godot 4 keinen Impuls auf RigidBody3D, move_and_slide gleitet nur ab. Ohne
  den Umweg fuehlt sich die Bombe wie ein festgeschraubter Stein an.
- Explosion mit Entfernungs-Abfall (am Rand noch 40 %), Kettenreaktion ueber
  die Gruppe "bombs", halber Schaden am Spieler.

Items (item_data.gd, item_catalog.gd, item_manager.gd, item_behaviours.gd)
- 8 Items aus dem Design-Dokument. Definition im Code statt als .tres:
  ein neues Item ist ein Funktionsaufruf, Balancing-Aenderungen sind im
  Diff lesbar, und es gibt keine kaputten Resource-Pfade.
- ItemManager ist Autoload, kein Node am Spieler: Items gehoeren dem RUN,
  nicht der Figur, und wuerden beim ersten Charakterwechsel sonst verloren
  gehen. Er haengt PlayerStats und BombCarrier bei jedem Wechsel selbst an
  und verbindet sich mit den Hitboxen der neuen Instanz.
- Bluten laeuft ueber den bestehenden StatusEffectManager statt ueber eine
  eigene Coroutine: der Effekt endet dann automatisch mit dem Gegner und ist
  im Debug sichtbar wie jeder andere Status.
- Ramm-Attacke wertet Tempo plus Naehe aus statt get_slide_collision():
  eine Kollisionsabfrage haette einen Eingriff in player_base gebraucht und
  gegen fliehende Gegner je nach Frame gar nichts gemeldet.
- Starthilfekabel setzt den Dash-Zustand von CombatBase direkt, statt eine
  eigene Bewegung zu bauen — laeuft damit ueber denselben getesteten
  Codepfad inklusive Federarm-Schutz.

Game Juice (game_juice.gd)
- Hit-Stop ueber Engine.time_scale. Kurz bei Primary, laenger bei Secondary,
  am laengsten bei Explosionen.
- Der Restore-Timer laeuft ueber die Systemzeit, nicht ueber delta oder
  create_timer(): bei time_scale nahe 0 wuerde ein skalierter Timer nie
  ablaufen und das Spiel dauerhaft einfrieren.
- Ueberlappende Treffer stapeln nicht, sondern verlaengern nur bis zu einem
  harten Cap — eine lange Combo haette das Spiel sonst sekundenlang
  angehalten.

HUD (hud_extra.gd, stats_panel.gd, item_description_hud.gd, reset_overlay.gd)
- Eigenes Autoload mit CanvasLayer statt Nodes in hud.tscn: hud.tscn wird
  nicht in jeder Szene benutzt, und der Layer ueberlebt
  reload_current_scene().
- Stats-Panel und Item-HUD sitzen unten links in einer gemeinsamen Spalte.
  Stats stehen unten (feste Hoehe, wandern nie), das Item-HUD

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `161c399` |
| Autor | ImChubiii |
| Datum | 2026-07-26 |
