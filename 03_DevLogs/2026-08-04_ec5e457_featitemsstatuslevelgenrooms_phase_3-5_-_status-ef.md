---
commit: "ec5e45720b2a9399f1006dc89a9a27710badfc69"
short_hash: "ec5e457"
date: 2026-08-04
author: "ImChubiii"
subject: "feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Räume, Etagen-Progression"
tags: [devlog]
---

# 2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Räume, Etagen-Progression

Setzt die Phasen 3, 4 und 5 des Design-Dokuments in einem Zug um. Die
Reihenfolge der Abschnitte unten entspricht der empfohlenen Einspiel-
Reihenfolge (siehe EINSPIEL_ANLEITUNG.md).

PHASE 4.1: STATUS-EFFEKT-SYSTEM (scripts/status_effects/)
---------------------------------------------------------
Sieben Effekte mit eigener Dauer, Tick-Logik, VFX und Cleanup:
rooted, burn, slow, acid, confused, silenced, stun. Jeder Effekt liegt
in einer eigenen Datei und enthaelt NUR seine Balancing-Zahlen und seine
VFX-Entscheidung - die Laufzeit bleibt im StatusEffectManager.

* status_effect_base.gd (neu): gemeinsamer Lookup/Apply/VFX-Block. Stand
  sonst siebenmal wortgleich im Projekt; die achte Kopie waere die
  gewesen, die beim nächsten Umbau vergessen wird.
* status_effect_manager.gd: get_effect_tick_interval(), extend_effect(),
  extend_all(), snapshot_dots(), zentrale DOT_IDS.
  apply_effect() taugt für Verlaengerungen NICHT - es nimmt das Maximum
  aus alt und neu, eine Pfeffermuehle mit +3s waere bei einem noch 4s
  laufenden Effekt also wirkungslos geblieben.
* Synergien als Effekt-Regel statt als Item-Code: StatusBurn.detonate()
  (Toaster-Feuersturm), StatusBurn.thermal_shock() (Gefrierbeutel),
  StatusAcid.extend_for_gum(). Sie beschreiben, wie sich FEUER bzw.
  SAEURE verhaelt - nicht, was ein bestimmtes Item tut.

ROOT CAUSE: Dauer-Tint verschwand beim ersten Treffer
------------------------------------------------------
psx.gdshader hat GENAU EIN Paar flash_color/flash_strength. Der
Hit-Flash-Tween in enemy_ai.gd faehrt es hoch und wieder auf 0 - jede
dauerhafte Effekt-Einfaerbung wurde damit beim nächsten Schlag
geloescht. Ein brennender Gegner hoerte also genau in dem Moment auf zu
gluehen, in dem man hinschaut.

* status_effect_visuals.gd (neu): schreibt den Tint pro Frame neu. Der
  Hit-Flash ueberschreibt kurz, im nächsten Frame steht der Tint wieder.
  Prioritaetsliste entscheidet bei mehreren gleichzeitigen Effekten;
  confused dreht die Farbe im HSV-Kreis (HOLOGRAM_RAINBOW-Ersatz).

ROOT CAUSE: Stun-Interrupt haette Gegner dauerhaft gelaehmt
------------------------------------------------------------
_do_attack() ist eine Coroutine über mehrere await-Punkte. Ein reines
"return" beim Interrupt haette _is_attacking dauerhaft auf true stehen
lassen - der Gegner haette NIE WIEDER angegriffen, der Stun waere
permanent gewesen. Die Interrupt-Ausstiege rufen jetzt _abort_attack(),
das Flag, Telegraph und Armpose aufraeumt und auf CHASE zuruecksetzt.

* enemy_ai.gd: "acid" in DOT_EFFECT_IDS (sonst tickt es ins Leere -
  exakt der alte bleed/burn-Fehler), is_attack_locked() für
  stun/silenced, interrupt_attack() bricht laufende Telegraphs ab,
  _on_status_effect_applied() reagiert sofort statt erst im nächsten
  Frame.
* "rooted" sperrt bewusst WEITERHIN nur die Bewegung, nicht den Angriff -
  das ist der Unterschied zu stun und macht den Dachnagel taktisch statt
  zu einem schwaecheren Stun.
* confused: gehaltener Fehlwinkel (0.5s Reroll) statt Frame-Zufall. Ein
  pro Frame neu gewuerfelter Winkel liest sich als Zittern, der Gegner
  steht im Mittel doch richtig und trifft.

PHASE 4.2: 20 PASSIVE + 8 AKTIVE ITEMS
---------------------------------------
* item_catalog.gd: komplett nach Design-Dokument neu aufgebaut,
  36 Items (8 Bestand + 20 passiv + 8 aktiv), jeweils mit Rarity.
* item_behaviours.gd: alle Event-Hooks verdrahtet - player_hit_enemy,
  take_damage, enemy_died, room_cleared, step_tick, dash_started.
* dash_started laeuft als FLANKENERKENNUNG aus combat.is_dashing() im
  ohnehin laufenden _physics_process. Ein Signal in combat_base.gd
  haette alle vier Combat-Unterklassen angefasst, ohne etwas zu koennen,
  was der Poll nicht kann.
* Laufzeit-Nodes (Pfützen, Laserstrahl, Schallwellen, Sahneteppich)
  haengen in current_scene, NICHT am Spieler: Hitboxen werden 0.15s nach
  dem Schlag deaktiviert, Gegner rufen bei Tod queue_free(), und
  PartyManager tauscht beim Charakterwechsel die ganze Spieler-Instanz.

feat(items): sekundenbasierte Cooldowns für Aktiv-Items
---------------------------------------------------------
Das Design-Dokument nennt für sieben der acht Aktiv-Items Sekunden
("Sturmfeuerzeug 3s", "Walkman 12s"). Das bestehende System lud
ausschliesslich über GECLEARTE RAEUME auf - ein Item, das man erst nach
dem nächsten Raum wieder benutzen darf, ist etwas voellig anderes als
eines mit 3 Sekunden Abklingzeit.

* item_data.gd: neues cooldown_seconds. 0.0 = alte Raum-Aufladung,
  > 0.0 = Sekunden-Cooldown (charge_rooms bleibt dann unbeachtet).
  Beides gleichzeitig waere ein Doppel-Gate, bei dem nie klar ist,
  welches gerade blockiert.
* item_manager.gd: _active_cooldowns bewusst GETRENNT von
  _active_charges - unterschiedliche Einheiten und Nullpunkte. In einem
  Dictionary gemischt haette jede Abfrage erst den Item-Typ nachschlagen
  muessen, um zu wissen, was der Wert bedeutet.
* Neue force_recharge_active() für die Nonnen-Kutte, funktioniert mit
  beiden Mechaniken. reset_run() raeumt die Cooldowns mit ab.
* Einzige Ausnahme: Schulbibliotheks-Buch ("1x pro Etage") - weder Zeit
  noch Raumzahl, laeuft über _book_used_in_stage in item_behaviours.gd.

PHASE 3.1: MULTI-ZELLEN-RAEUME
-------------------------------
Räume duerfen mehr als eine Rasterzelle belegen (2x1, 1x2, 2x2).
Ueberlappung wird über eine Belegungstabelle im Grid-Generator
verhindert.

Entwurfspunkt: die Grundflaechen werden NACHGELAGERT vergeben
(_assign_footprints), nicht waehrend des Baumwachstums. Ein 2x2-Raum
haette waehrend des Wachstums vier Frontier-Positionen auf einmal
verbraucht und die Verzweigung zerstoert - das Layout waere ein Schlauch
geworden. Nachtraeglich ist jede Erweiterungszelle garantiert LEER und
bringt damit keine eigenen Ausgaenge mit.

Daraus folgt die Kerneigenschaft: ein Multi-Zellen-Raum hat GENAU DIE
AUSGAENGE SEINER ANKERZELLE, also hoechstens einen je Himmelsrichtung.
Das bestehende Tuer-System (RoomInstance._doors_by_dir) laeuft damit
unveraendert weiter.

* room_data.gd: footprint_cells. Muss zu room_footprint der .tscn
  passen (footprint_cells * 48), sonst haben Decke, EntryTrigger und
  PresenceArea die falsche Größe.
* room_grid_generator.gd: generate_layout() nimmt jetzt zusätzlich
  stage, RoomCell traegt footprint/covered_cells/center_offset(),
  get_occupancy() für Minimap und Fog-of-War.
* level_generator.gd: Multi-Zellen-Platzierung auf den Flaechen-
  Mittelpunkt, _pick_room() filtert nach footprint_cells mit
  1x1-Fallback plus Warnung, Fog-of-War leitet Zusatzzellen auf den
  Anker um.
* room_instance.gd: set_exit_offset() (verschiebt Tuer, ExitPoint und
  Tuersturz gemeinsam).

VERWORFENER ANSATZ: automatischer Tuer-Versatz im Generator
------------------------------------------------------------
Erster Entwurf hat set_exit_offset() automatisch für jeden
Multi-Zellen-Raum gerufen. Das ist prinzipiell falsch: der Generator
kann eine Tuer verschieben, aber NICHT die Wandluecke - die steht als
fester Transform3D in der .tscn. Ergebnis waere eine Tuer vor
geschlossener Wand plus ein offenes Loch an der alten Stelle gewesen.

Geloest über eine Konvention statt Code: Szenen mit
footprint_cells != (1,1) platzieren Tuer, ExitPoint UND Wandluecke
selbst auf der Ankerachse (-24 bei zwei Zellen, -48 bei drei).
set_exit_offset() bleibt als Werkzeug erhalten, wird aber nicht mehr
automatisch gerufen.

PHASE 3.2: ETAGEN-PROGRESSION MIT THEMEN
-----------------------------------------
* stage_theme.gd (neu): Farbwelt einer Etage - Boden, Waende, Decke,
  Tueren, Nebel, Umgebungslicht, Hazard-Ton. Fuenf eingebaute Themen
  (Kellergewoelbe, Tiefkuehlhaus, Sandgrube, Fleischfabrik,
  Neon-Keller), danach von vorn.
  Farben statt Material-Sets: alle Raum-Szenen benutzen dasselbe
  psx_material.tres. Ein Material-Set pro Theme haette jede der jetzt
  20 Raum-Szenen mit einem Theme-Schalter versehen.
* stage_manager.gd (neu, Autoload "Stages"): Schwarzblende, Aufbau der
  neuen Etage, Umsetzen des Spielers, Environment-Anpassung.
* goal_zone.gd: versucht zuerst den Etagenwechsel, WinScreen nur noch
  bei erreichter final_stage oder fehlendem Autoload.
* level_generator.gd: generate_stage(), get_start_room_spawn(),
  get_stage_theme(). Der Seed geht mit der Etagennummer in die
  Ableitung ein ("layout:<stage>") - jede Etage bekommt damit ein
  eigenes Muster, der Run bleibt trotzdem vollständig reproduzierbar.
* room_instance.apply_theme(): dupliziert die Materialien pro
  MeshInstance3D, BEVOR gefaerbt wird - derselbe geteilte-Resource-
  Fehler wie bei den BoxMeshes haette sonst alle Etagen gleich
  eingefaerbt.

WARUM DER SPIELERZUSTAND ERHALTEN BLEIBT: es gibt bewusst KEIN
reload_current_scene(). Items, PartyManager, PlayerStats und der
Spieler-Node ueberleben unveraendert, nur die Räume werden getauscht.
Das ist der Unterschied zu run_restart.gd, das genau umgekehrt arbeitet.
Geleert werden nur die Status-Effekte des Spielers (ein Brand aus Etage 1
soll nicht in Etage 2 weiterticken) sowie Drops, Hazards und Projektile
der alten Etage.

PHASE 5: 12 NEUE RAUM-SZENEN
-----------------------------
Gefordert waren 9 (6 Combat, 2 Treasure, 1 Corridor) - dazu kommen drei
Multi-Zellen-Vorlagen, ohne die Phase 3.1 keinen Inhalt haette.

* Combat: room_combat_07 bis _12 (Saeulenhalle, Lavagraben,
  Podest-Arena, Kreuzgang, Saeuresuempfe, offene Kammer)
* Multi-Zellen: room_combat_wide_01 (2x1), _tall_01 (1x2),
  _arena_01 (2x2, ab Etage 2)
* Treasure: room_treasure_02, _03
* Corridor: room_corridor_03 (Ost/West, 48x20)
* 12 passende rd_*.tres

Ein Pruefskript verifiziert über alle neuen Szenen, dass Tuer,
ExitPoint und Wandsegmente exakt uebereinstimmen - 0 Abweichungen.

PHASE 5.1: MINIMAP
-------------------
* minimap_rooms.gd: neues corridor_width_factor (0.42). Im Level sind
  Korridore nur 20 statt 48 Einheiten breit, auf der Karte sahen sie
  aber aus wie vollwertige Räume - der Rhythmus "Arena - Gang - Arena",
  der das Layout ausmacht, war damit unsichtbar.
  Laufrichtung wird aus den exit_flags abgeleitet (Nord|Sued =
  senkrecht); Korridore haben per Konstruktion immer genau diese beiden
  Muster, ein Sonderfall für Ecken ist nicht noetig.
* merge_multi_cell_rooms: Grossraum als EIN Rechteck über die gesamte
  Flaeche inkl. Fugen statt mehrerer Quadrate - sonst waere nicht zu
  erkennen, ob dort ein grosser Raum steht oder zwei kleine.

HINWEISE ZUM EINSPIELEN
------------------------
1. Autoload: res://scripts/level/stage_manager.gd muss unter
   Projekteinstellungen -> Autoload als "Stages" eingetragen sein
   (mit "*"-Praefix). Fehlt der Eintrag, springt goal_zone.gd direkt
   zum WinScreen und meldet das im Log.
2. room_pool im LevelGenerator um die 12 neuen rd_*.tres erweitern.
   Die drei Multi-Zellen-Vorlagen sind PFLICHT, sobald
   allowed_footprints Groessen != (1,1) enthaelt - sonst faellt
   _pick_room() mit einer Warnung auf 1x1 zurueck und die
   Zusatzzellen bleiben als Loch im Level stehen.
3. Nach dem Kopieren Godot-Dateisystem neu einlesen, sonst finden die
   .tres ihre .tscn nicht.

BREAKING: Item-IDs
-------------------
Sieben Items des alten Satzes sind entfallen und durch die Items des
Design-Dokuments ersetzt: jelly_ring, holy_blood_vial, ouija_board,
crooked_die, devil_horns_plastic, broken_gameboy, cardboard_wings.
Laufende Runs und gespeicherte Leaderboard-Eintraege, die diese IDs
referenzieren, sind damit nicht mehr aufloesbar.

BEKANNTE GRENZE (nicht in diesem Commit)
-----------------------------------------
Mehrere Tuer-Slots pro Aussenkante eines Multi-Zellen-Raums. Verlangt
einen Umbau von RoomInstance._doors_by_dir auf eine Liste und zieht sich
durch get_door_state(), _seal_exit(), set_door_kind(),
force_unlock_door(), das Tuer-Protokoll im LevelGenerator und
minimap_rooms._draw_passage(). Bewusst als eigener Durchgang
zurueckgestellt.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Items:** [[leer]], [[library_book]], [[nun_habit]], [[storm_lighter]], [[walkman]]

**Status-Effekte:** [[acid]], [[burn]], [[confused]], [[rooted]], [[silenced]], [[slow]], [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `ec5e457` |
| Autor | ImChubiii |
| Datum | 2026-08-04 |
