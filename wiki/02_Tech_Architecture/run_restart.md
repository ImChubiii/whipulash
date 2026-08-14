---
script_path: scripts/run_restart.gd
autoload_name: RunRestart
tags: [architecture, autoload]
---

# run_restart.gd

Autoload (`RunRestart`). Der EINE legitime Pfad, der `get_tree().reload_current_scene()`
aufruft und damit den kompletten Run wegwirft — nicht nur die Raeume,
sondern auch Party, Items, Loot, Treasure-State und Status-Effekte. Das
ist der Gegenentwurf zu [[stage_manager]] (`Stages`), der Etagen wechselt
**ohne** die Szene neu zu laden und den Spielerzustand bewusst erhaelt.
Wer die beiden verwechselt, schickt entweder einen frischen Charakter mit
vollem Inventar in einen Neustart oder loescht versehentlich das Inventar
beim Etagenwechsel.

## Warum ein eigenes Autoload

Vor `run_restart.gd` loeste ein Neustart an VIER Stellen unabhaengig
denselben Vorgang aus — `reset_overlay.gd` ([R] gehalten), sowie die
Restart-Buttons in `pause_menu.gd`, `death_screen.gd` und `win_screen.gd`.
Drei der vier Wege raeumten dabei WENIGER auf als der vierte (`reset_overlay.gd`
rief zusaetzlich `Juice.cancel()` und den Items/Loot-Reset auf, die anderen
drei nur `unpause` + `reload`). Das ist die klassische Bauform fuer "der
Restart-Button verhaelt sich anders als [R]" — genau die Art Unterschied,
die eine Fehlersuche im Neustart-Pfad am laengsten aufhaelt. Seit
`run_restart.gd` rufen alle vier Stellen `RunRestart.restart()` auf; wer
einen Aufraeumschritt ergaenzt, ergaenzt ihn zwangslaeufig fuer alle.

## Der Bug, der den Autoload ausgeloest hat

`reload_current_scene()` baut die Szene ab und neu auf, Autoloads bleiben
aber bestehen — inklusive [[party_manager]], der einen Zeiger auf die
Spieler-Instanz der ALTEN Szene haelt. Ein freigegebenes Godot-`Object`
wird in GDScript nicht automatisch auf `null` gesetzt: `player == null`
war danach `false`, obwohl die Instanz tot war. `PartyManager` hielt sich
damit fuer bereits bespielt und spawnte nach dem Reload keinen neuen
Charakter — sichtbar als "Level baut sich neu auf, aber der Spieler bleibt
weg". Der eigentliche Fix (`has_player()` / `is_instance_valid()` statt
`player == null`-Vergleichen) sitzt in `party_manager.gd` — siehe
[[party_manager]] fuer die volle Herleitung. `run_restart.gd` traegt dazu
bei, dass die tote Instanz erst gar keinen Frame lang mitlaeuft: `restart()`
ruft `PartyManager.notify_scene_reset()` als **allerersten** Schritt in
`_cleanup_run_state()` auf, noch vor dem eigentlichen Szenenwechsel.

## Ablauf von `restart()`

1. `_restart_pending`-Guard: ein zweiter Aufruf im selben Frame (z.B. wenn
   zwei UI-Elemente gleichzeitig reagieren) wird ignoriert, statt einen
   zweiten Szenenwechsel auf eine bereits halb abgebaute Szene loszulassen.
2. `restart_started` wird emittiert (bevor irgendetwas aufgeraeumt ist —
   Listener sehen also noch den alten Zustand).
3. `_cleanup_run_state()`: `PartyManager.notify_scene_reset()` (siehe oben),
   danach best-effort `reset_run()` auf `Items`, `Loot`, `Treasure` und
   `clear_all()` auf `StatusEffectManager` — jeder Aufruf einzeln per
   `get_node_or_null()` + `has_method()` abgesichert, damit der Neustart
   auch in einer Testszene ohne alle Autoloads durchlaeuft.
4. `_restore_engine_state()`: `Juice.cancel()`, `Engine.time_scale = 1.0`,
   `tree.paused = false`, Maus wieder `MOUSE_MODE_CAPTURED`. Notwendig, weil
   ein laufender Hit-Stop `Engine.time_scale` auf ~0.05 haelt — wuerde die
   Szene genau in diesem Moment wechseln, liefe der neue Run in Zeitlupe an,
   und der Timer, der `time_scale` normalerweise zuruecksetzt, ist mit der
   alten Szene bereits verschwunden.
5. `_do_reload.call_deferred()`: der eigentliche `reload_current_scene()`
   passiert erst am Frame-Ende, nicht synchron aus dem Button-Signal oder
   `_process()` heraus. Ein Szenenabbau mitten im Frame, waehrend noch
   Nodes der alten Szene verarbeitet werden, ist genau die Situation, aus
   der "Cannot call method on a null value"-Kaskaden entstehen.
6. Nach erfolgreichem Reload wartet `_do_reload()` zwei `process_frame`s,
   bevor `_restart_pending` wieder freigegeben wird — Puffer, damit die neue
   Szene ihre `_ready()`-Kaskade fertig hat.

`reload_current_scene()` kann fehlschlagen (Rueckgabewert `!= OK`); in dem
Fall wird nur ein `push_error` geloggt und `_restart_pending` zurueckgesetzt,
es gibt keinen Retry.

## Aufrufer

`scripts/main_menu.gd` ist der einzige direkt gegrepte Aufrufer
(`RunRestart.restart()`, abgesichert mit `GameStats.has_live_run` und einer
`has_method`-Pruefung); die vier urspruenglichen UI-Quellen (Reset-Overlay,
Pause-, Death-, Win-Screen) rufen laut Kommentar im Skript ebenfalls hierueber.

## Verwandt

- [[stage_manager]] — der andere, bewusst NICHT reloadende Weg,
  Levelinhalt auszutauschen. Siehe dort fuer die Gegenueberstellung.
- [[party_manager]] — haelt die Root-Cause-Erklaerung des
  `player == null`-vs-`is_instance_valid()`-Bugs und dessen eigentlichen Fix.

## Erwaehnt in DevLogs

- [[2026-08-01_5d2ca05_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
- [[2026-08-01_3bbac00_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
