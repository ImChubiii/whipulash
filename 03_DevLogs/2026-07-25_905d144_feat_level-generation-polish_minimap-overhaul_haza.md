---
commit: "905d144d96ff50a595a5d50b7f03bc9879d4a3d3"
short_hash: "905d144"
date: 2026-07-25
author: "ImChubiii"
subject: "feat: Level-Generation-Polish, Minimap-Overhaul, Hazard/Door-Fixes, Atmosphäre"
tags: [devlog]
---

# 2026-07-25 — feat: Level-Generation-Polish, Minimap-Overhaul, Hazard/Door-Fixes, Atmosphäre

Lava/Hazard:
- lemonade.gd: POOL/SURFACE-Modus für Lava (Durchwaten vs. echtes
  Einsinken), CapsuleShape3D-Fußhöhe korrigiert (height enthält Kappen
  bereits), SubResource-Sharing-Bug behoben (Shape/Material werden jetzt
  pro Instanz dupliziert), Rescan-Poll gegen verschluckte body_entered-
  Signale
- pit_floor.gd (neu): baut echte Bodenlöcher (Segmentierung statt CSG,
  da NavMesh nur aus StaticBody-Collidern bakt) + Wanne, senkt Lava
  automatisch ab und schaltet sie auf POOL

Level-Generierung:
- room_grid_generator.gd: erzwungene Korridor-Anzahl (min_connectors),
  Hoehenstufen-Planung per BFS, Rampen-Vorgabe pro Korridor
- level_generator.gd: Hoehenversatz beim Instanziieren, Tuer-Kind-
  Zuweisung (Boss=rot/Treasure=gold) an Nachbarzellen, Freischaltung der
  Boss-Tuer nach Raum-Clear
- room_instance.gd: dunkle, aber texturierte Decke (PSX-Material,
  180°-geflipptes PlaneMesh wg. cull_back im Shader), Rampen-Geometrie
  für Korridor-Steigungen, dunkle Minimap-Kappen auf jeder Wand
  (Grund-Textur bleibt identisch zum Boden)
- door.gd: Boss/Treasure-Einfärbung, Hold-to-Hack (4s), Hack-Area jetzt
  IMMER in _ready() erzeugt (Bugfix: door_kind wird erst nach _ready()
  gesetzt, Hack-Area existierte vorher nie)
- hack_prompt.gd (neu): Bildschirm-Prompt mit Fortschrittsbalken fürs
  Hacken

Minimap:
- minimap.gd: Raum-Overlay liegt jetzt unterhalb statt über der 3D-
  Karte, Großkarten-Toggle (Action "toggle_map"/M) mit Nebeneinander-
  Layout, Pfeil folgt Kamera- statt Modell-Yaw, eigenes fog-freies/
  helles Kamera-Environment gegen Mitverdunklung durch dungeon_atmosphere
- minimap_rooms.gd: Tür-Verbindungen als gefüllte Durchgänge statt
  dünner Stege (liest sich als offener Gang statt Gitter), Grid-
  Rotation nur auf Positionsberechnung angewendet (Buchstaben/Glyphen
  bleiben aufrecht)
- pause_menu.gd: ESC schließt zuerst eine offene Großkarte, erst der
  nächste Druck öffnet Pause

Atmosphäre:
- dungeon_atmosphere.gd (neu): Distanz-Nebel + gedimmtes Ambient-Licht
  fürs "Blindness"-Gefühl, per Node auf Environment anwendbar

Stun-System:
- player_base.gd: Stun-Immunitätsfenster + Diminishing Returns nach
  jedem Stun (fixt Stunlock durch 3+ Stinger), nur noch stun_duration
  > 0 an Stinger-Hitbox (Fighter/Colossus stunnen nicht mehr - Wert in
  den jeweiligen .tscn auf 0 gesetzt)

Input:
- settings_manager.gd: Interact-Action-Key von "interact " (Leerzeichen-
  Tippfehler) auf

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `905d144` |
| Autor | ImChubiii |
| Datum | 2026-07-25 |
