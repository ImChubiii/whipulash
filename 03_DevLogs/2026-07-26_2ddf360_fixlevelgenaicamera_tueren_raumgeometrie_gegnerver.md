---
commit: "2ddf3601cf9501c9ff1833dc46b78ebb29e42a4c"
short_hash: "2ddf360"
date: 2026-07-26
author: "ImChubiii"
subject: "fix(levelgen,ai,camera): Tueren, Raumgeometrie, Gegnerverhalten und Kamera"
tags: [devlog]
---

# 2026-07-26 — fix(levelgen,ai,camera): Tueren, Raumgeometrie, Gegnerverhalten und Kamera

Sammelcommit aus einer Debug-Session am generierten Dungeon. Schwerpunkt:
Durchgaenge, die sich nicht wie Durchgaenge verhalten, und Systeme, die
gebaut aber nie angeschlossen waren.

LEVEL-GENERIERUNG
- Boss und Tresor liegen garantiert in echten Sackgassen. _place_special_rooms
  hat Sackgassen bisher nur bevorzugt und ist im Zweifel auf den entferntesten
  Raum ausgewichen - egal mit wie vielen Ausgaengen. _reserve_dead_end() baut
  jetzt notfalls eine Sackgasse an (Layout wird dadurch 1-2 Zellen groesser).
- Boss und Tresor duerfen nicht mehr am selben Nachbarraum haengen. Sonst
  steht der Spieler in einer Vorkammer mit zwei Sondertueren nebeneinander
  und der Tresor liest sich nicht als eigener Abstecher.
- Ungenutzte Ausgaenge werden zugemauert statt als dauerhaft verriegeltes
  Tuerblatt stehenzubleiben. apply_exit_flags() hat bisher nur den
  exit_points-Eintrag geloescht; jede Raum-Szene zeigte damit vier Tueren,
  von denen sich nur ein bis drei oeffnen liessen.
- Gegnerstaerke skaliert mit der Etage (enemy_health_per_stage /
  enemy_damage_per_stage, gedeckelt). Bisher stieg ueber threat_per_stage
  ausschliesslich die ANZAHL - ein Stinger in Etage 5 hatte dieselben 25 HP
  wie in Etage 1.
- Tuer-Protokoll: hack-gegatete Durchgaenge landen in einer eigenen Kategorie
  HACK-SPERREN statt in AUFFAELLIGKEITEN. Das gewollte Verhalten eines
  Sonderraums war bisher als Fehler gemeldet.

RAUMGEOMETRIE
- Tuersturz ueber jedem Durchgang. Wandsegmente sind room_height hoch, das
  Tuerblatt nur 10 - bei 48er-Raeumen an einem 48er-Grid lagen die Loecher
  zweier Nachbarraeume deckungsgleich uebereinander. Masse werden aus der
  Tuer-Collision abgeleitet, ueberleben also eine spaetere Skalierung.
- Absteigende Korridore sind begehbar. configure_slope() hat die Rampe
  ZUSAETZLICH zur flachen Bodenplatte gebaut; bei negativem rise lag sie
  darunter, der Spieler lief flach weiter und fiel am Ende einen ungefederten
  Absatz. Die Platte wird jetzt abgeschaltet und gibt ihr Material an die
  Rampe weiter (die renderte vorher im Standardgrau).
- pit_floor.gd an alle Raeume mit Limonade gehaengt. Das Skript war fertig
  im Projekt, aber an keinem einzigen Floor-Node - deshalb lief man ueber
  die Lachen statt hineinzufallen.
- Spawn-Marker pro Raum von 6-8 auf 11-14 erhoeht (Boss 12, Korridore 6),
  jeder gegen Hazards, Pfeiler, Stufen, Plattformen und Tuerbereiche
  geprueft. _roll_enemy_mix() deckelt die Gegnerzahl auf die Markerzahl.
- room_combat_06: Enemy7 aus dem Limonaden-Pool geholt.
- Tote Duplikate scenes/rooms/combat/room_corridor_01+02.tscn entfernt,
  unbenutzte Sub-Resourcen aus den lebenden Korridoren geraeumt.

RAUM-ZUSTAND
- Raum bleibt nach einem RESET nicht mehr fuer immer verriegelt.
  reset_room() hat _counted_dead_enemies geleert, waehrend die
  tree_exited-Signale der gerade gefreeten Gegner erst im naechsten Frame
  feuerten - _active_enemies rutschte ins Negative und der Raum setzte sich
  faelschlich auf CLEARED. Jede Spawn-Welle hat jetzt eine Generationsnummer.
- room_entered feuert bei JEDEM Betreten, nicht nur beim ersten. Die
  _has_entered-Sperre bleibt reine Spawn-Sperre; vorher zeigte die
  Markierung auf der Grid-Karte weiter auf den zuletzt neu betretenen Raum.

MINIMAP
- Fog of War auf der 3D-Minimap: nicht aufgedeckte Raeume wandern auf einen
  Visual-Layer, den nur die Minimap-Kamera aus ihrer cull_mask streicht.
  Gleiche Sichtbarkeitsregel wie im Grid-Overlay.
- Tuerzustand auf der 3D-Minimap sichtbar. Von oben sah jeder Durchgang
  gleich aus, weil die Kamera durch die Wandluecke auf den Sturz schaut.
  Flache, eingefaerbte Platte pro Durchgang auf einem reinen Minimap-Layer.
- Spielerpfeil folgt der verschobenen Grosskarte statt in der Mitte zu
  kleben (unproject_position statt fester Mittelposition).

GEGNER-KI
- Zickzack-Verfolgung fuer Scouts: zick - stehen - zack - stehen. Inklusive
  Ausblenden des Ausschlags nahe am Ziel, sonst kaeme der Gegner nie in
  attack_range.
- Fokus-Verlust: Gegner verlieren gelegentlich das Interesse, laufen kurz
  woanders hin und docken wieder an. Loest die Horde optisch in
  Einzelgegner auf. Poisson-verteilt, also bildratenunabhaengig; bricht
  keinen laufenden Angriff ab und prueft Kanten beim Umherlaufen.

KAMERA / UI
- Kamera zoomt beim Dash nicht mehr in den Spieler. SpringArm3D castete
  ohne shape nur einen Strahl und setzte die Laenge ungedaempft - ein
  einzelner Fehltreffer schickte die Kamera auf 0. Jetzt Kugel-Cast,
  Ausschluss des eigenen Koerpers und gedaempftes Nachfuehren (rein
  schnell, raus langsam). Kollision bleibt aktiv, die Kamera faehrt also
  nicht durch Waende.
- Dash-FOV-Tween wird vor einem neuen Dash abgeraeumt; zwei ueberlappende
  Tweens liessen das Sichtfeld auf einem Zwischenwert haengen.
- SubmersionOverlay funktioniert auch in den generierten Levels.
  show_submersion() hat nur die Farbe getweent - in
  level_generation_test.tscn steht am Node aber visible = false.
- seed_button.gd: Run-Seed anzeigen und per Klick in die Zwischenablage
  kopieren.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Gegner:** [[stinger]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `2ddf360` |
| Autor | ImChubiii |
| Datum | 2026-07-26 |
