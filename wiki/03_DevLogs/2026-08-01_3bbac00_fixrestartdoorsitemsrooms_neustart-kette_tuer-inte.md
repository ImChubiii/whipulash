---
commit: "3bbac00b91c534e9658be9ef6849d6657ed81900"
short_hash: "3bbac00"
date: 2026-08-01
author: "ImChubiii"
subject: "fix(restart,doors,items,rooms): Neustart-Kette, Tür-Interaktion, Item-Rarity, Lava-Timing, Bomben-VFX, Spawn-Hologramm"
tags: [devlog]
---

# 2026-08-01 — fix(restart,doors,items,rooms): Neustart-Kette, Tür-Interaktion, Item-Rarity, Lava-Timing, Bomben-VFX, Spawn-Hologramm

Mehrere unabhängige Root-Cause-Fixes und ein neues Feature, gesammelt
aus einer Debugging-Session. Reihenfolge der Punkte unten entspricht
der empfohlenen Einspiel-Reihenfolge (siehe Datei-Übergabe-Chat).

ROOT CAUSE: Neustart tut nichts (Button und [R])
--------------------------------------------------
party_manager.gd hielt nach reload_current_scene() weiterhin einen
Zeiger auf die freigegebene alte Spieler-Instanz. In GDScript wird
ein freed Object nicht automatisch auf null gesetzt: "player == null"
lieferte danach FALSE, obwohl die Instanz tot war. Der komplette
Spawn-Pfad hing an genau dieser Prüfung (register_spawn_point(),
setup_party(), _spawn_active_character()) und blieb nach jedem
Neustart dauerhaft blockiert - das Level wurde neu generiert, aber
nie wieder ein Charakter gespawnt.

* party_manager.gd: alle Lebend-Prüfungen auf has_player() /
  is_instance_valid() umgestellt, neue notify_scene_reset()
* run_restart.gd (neu, Autoload "RunRestart"): einziger Neustart-Pfad
  für alle vier Auslöser (Taste, Pause-, Death-, Win-Screen-Button).
  Räumt vor dem Szenenwechsel Items/Loot/Treasure/StatusEffects auf,
  setzt Juice.cancel() und Engine.time_scale zurück, verhindert
  doppelte reload_current_scene()-Aufrufe im selben Frame.
* reset_overlay.gd: Haltezeit läuft jetzt über Time.get_ticks_msec()
  statt über skalierte delta-Summe (lief bei aktivem Hit-Stop in
  Zeitlupe), Fallback auf physische [R]-Taste falls die InputMap-
  Action fehlt, delegiert den eigentlichen Restart an RunRestart.
* pause_menu.gd, death_screen.gd, scenes/win_screen.gd: Restart-
  Buttons rufen jetzt RunRestart.restart() statt direkt
  reload_current_scene() - vorher hatten diese drei Wege WENIGER
  aufgeräumt als der Tasten-Pfad.

HINWEIS: RunRestart muss unter Projekteinstellungen -> Autoload
als "RunRestart" eingetragen sein. Fehlt der Eintrag, fällt jeder
Aufrufer auf einen Notfall-Reload ohne Aufräumen zurück (sichtbar
im Log als "Autoload 'RunRestart' nicht gefunden").

fix(rooms): Wand-Hug-Exploit umgeht Raum-Kampf
-----------------------------------------------
room_commit_guard.gd war unvollständig - die Funktion _attach() brach
mitten im Aufbau ab (kein CollisionShape3D, kein add_child(), kein
_process()). Das Feature war dadurch komplett wirkungslos, ohne jede
Fehlermeldung. Datei neu geschrieben: Commit-Area jetzt vollständig
gebaut, zusätzlich zur Verweildauer eine geschwindigkeitsunabhängige
Strecken-Bedingung (7 m zurückgelegt im Grundriss), die den Trick
auch bei hohem Bewegungstempo schließt.

feat(enemies): Gegnerdichte pro Raum erhöht
---------------------------------------------
Zwei Deckel begrenzten die Gegneranzahl gleichzeitig: das Threat-
Budget in level_generation_test.tscn (combat_threat_budget=16,
threat_hard_cap=28, überschrieb die Script-Defaults wirkungslos) UND
die Anzahl der Marker3D unter EnemySpawnPoints pro Raum-Szene (harte
Obergrenze in room_instance._roll_enemy_mix()).

* level_generation_test.tscn: Budgets angehoben (combat 60, corridor
  20, boss 70, hard_cap 120/90)
* enemy_density.gd (neu, Autoload "EnemyDensity"): verdreifacht die
  Spawn-Punkte jedes Raums durch geometrisch (nicht zufällig)
  berechnete Zusatzmarker um jeden Original-Marker, bodengeschnappt
  per Raycast, Lava-Flächen ausgespart. Determinismus für seed-
  basierte Speedruns bleibt erhalten.

fix(hazards): Lava-Schaden setzt zu spät ein
-----------------------------------------------
Root Cause lag nicht im Script, sondern in scenes/lemonade.tscn: die
Szene überschrieb damage_on_entry=false und tick_interval=1.0 und
machte damit den bereits vorhandenen Eintrittsschaden-Fix im Script
wirkungslos - der erste Treffer kam erst nach einer vollen Sekunde.

* lemonade.gd: tick_interval-Default 0.5, neuer first_tick_interval
  (0.3) für einen schnelleren zweiten Treffer, rescan_interval
  0.2 -> 0.1
* lemonade.tscn: damage_on_entry=true, tick_interval=0.5,
  first_tick_interval=0.3 explizit gesetzt

feat(bomb): größerer Radius, Flugsplitter, Brandfleck
--------------------------------------------------------
* bomb.gd: explosion_radius 9.0 -> 14.0, self_damage_radius_factor
  0.55 -> 0.40 (absolute Eigengefahr bleibt etwa konstant),
  knockback_force 26 -> 34
* neue VFX-Ebenen: Brandfleck vor der Explosion, zweiter schnellerer
  Außenring, 14 fliegende Splitter mit Wurfparabel (als getweente
  Meshes, keine GPUParticles3D - Bombe baut sich komplett im Code
  auf), Juice.shake 1.4 -> 2.0

feat(items): Rarity-System mit Farbschema
---------------------------------------------
* item_data.gd: neues Rarity-Enum (COMMON/UNCOMMON/RARE/EPIC/
  LEGENDARY), Setter leitet pedestal_color automatisch ab
  (grau/grün/blau/lila/rot), Handeingabe bleibt über
  _pedestal_color_overridden möglich
* item_catalog.gd: alle acht Items einer Rarity zugeordnet, alte
  manuelle pedestal_color-Zeilen entfernt (hätten die Rarity-Farbe
  sonst überschrieben)
  Keine Änderung an Anzeige-Code nötig - Sockel, Drop, HUD-Chip und
  Run-Übersicht lesen bereits alle dieselbe pedestal_color-Property.

fix(ui): Item-Beschreibungskarte läuft aus dem Bild
-------------------------------------------------------
card_width war eine feste Breite (offset_left/-right = ±210). Labels
mit autowrap ohne gesetzte custom_minimum_size.x verlangten im ersten
Layout-Durchgang ihre volle einzeilige Textbreite; die frei hängende
(containerlose) Karte konnte dagegen nicht schrumpfen und wuchs bei
langen Texten über die Sollbreite - da sie mittig verankert ist und
nach beiden Seiten wächst, ragte sie links und rechts aus dem Bild.

* item_description_hud.gd: card_width jetzt Obergrenze statt fixer
  Wert, neue card_min_width/card_screen_margin, Name/Flavor/
  Description-Labels auf custom_minimum_size.x=1 gesetzt (dürfen
  umbrechen statt die Karte zu sprengen), _resize_card_to_content()
  misst Textbreite über den Font und klemmt gegen Viewport,
  _clamp_card_vertically() verhindert Überstand am unteren Rand

fix(doors): Interaktions-Hitbox erfordert Sprung
------------------------------------------------------------
Die Interaktionszone war eine Kugel mit Radius hack_range, zentriert
auf den Tür-Node-Ursprung (halbe Blatthöhe). Bei room_scale=2
skalierte der Kugelmittelpunkt mit hoch, der Spieler blieb gleich
groß - die Zone endete über Kopfhöhe, einziger Weg hinein war ein
Sprung.

* door.gd: Interaktionszone jetzt ein BoxShape3D, aus den tatsäch-
  lichen Maßen des Türblatts abgeleitet (Breite/Höhe = sichtbares
  Blatt, nur Tiefe wächst mit hack_range), lokal gerechnet und damit
  automatisch mit jeder Raumgröße konsistent. hack_range-Semantik
  geändert (Abstand von der Fläche statt vom Mittelpunkt), Default
  4.0 -> 2.5. Neue rebuild_interact_area() für nachträgliche Höhen-
  änderungen (Rampen-Korridore).

BEKANNTER RESTFEHLER (nicht in diesem Commit behoben):
_measure_door_height() liefert Weltmaße (skaliert mit
global_transform), _closed_y ist dagegen lokal - bei room_scale=2
fährt die Tür beim Öffnen weiter hoch als nötig.

feat(tutorial): Hologramm-Schild am Spawnpunkt
----------------------------------------------------
spawn_tutorial_hologram.gd (neu): zeigt ein fertiges Tutorial-Bild
als Sprite3D-Hologramm vor dem Spieler-Spawn.

* Placement.CAMERA_VIEW (Standard) fragt die tatsächliche Blick-
  richtung der Spielerkamera ab, statt eine feste Achse anzunehmen -
  das Projekt hat zwei widersprüchliche "vorne"-Konventionen
  (Modell +Z, Kamera/Bewegung -Z), ein statisch gesetztes +Z hätte
  das Schild hinter den Spieler UND hinter die Kamera gesetzt
* Rückplatte gegen unlesbare helle Schrift auf hellem Hintergrund,
  Bodenprojektor-Kegel, Bob- und Flacker-Animation, distanzbasiertes
  Ein-/Ausblenden
* Bodenprojektor-Fix: Kegel endete ursprünglich an der Bildmitte
  (height) statt an der Bildunterkante und steckte damit zur Hälfte
  im Schild; jetzt über _board_half_height()/_projector_top_y() an
  der tatsächlichen sichtbaren Unterkante (inkl. Rückplatte) verankert

NICHT UMGESETZT (siehe gesonderte Liste offener Punkte):
Minimap-Grid-Autozoom, Pause-Buttons hinter Item-Card, Multi-Zellen-
Raumgrößen, Kamera-Drill bei A/D-Dash, Tür-Sturz-Gaps in Rampen-
Korridoren, PresenceArea-Reset im Boss-Vorraum-Korridor,
ItemBehaviours._player freed-instance-Fehler, drei Shadowing-
Warnungen (speed/basis/is_visible), lemonade.tscn UID-Verweis
invalide, _get_or_create_shared_blur() add_child-Timing-Fehler

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `3bbac00` |
| Autor | ImChubiii |
| Datum | 2026-08-01 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-01_3bbac00_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
