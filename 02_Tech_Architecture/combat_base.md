---
script_path: scripts/combat_base.gd
tags: [architecture, player, combat]
---

# combat_base.gd

Basisklasse ALLER Charakter-Combat-Skripte (`combat_ningning.gd`,
`combat_giselle.gd`, `combat_winter.gd`, `combat_karina.gd` — als "Combat"-
Kind-Node neben [[player_base]] am Spieler haengend). Enthaelt das komplette
GETEILTE Cooldown-, Combo-, Hit-Lock- und Dash-Schadenssystem; was Primary/
Secondary/Utility tatsaechlich TUN, ueberschreibt jeder Charakter individuell.

## Primary/Secondary-Erweiterungspunkte

`_process()` ruft pro Frame zwei ueberschreibbare virtuelle Methoden auf,
`_poll_primary_input(delta)`/`_poll_secondary_input(delta)` — Standard-
verhalten: gehaltene Taste feuert erneut, sobald der jeweilige Cooldown
abgelaufen ist (passt für klassische Nahkampf-/Dauerfeuer-Fähigkeiten wie
[[ningning]]s Quick Jab oder [[giselle]]s Uzi Spray unveraendert).
Fähigkeiten, die nicht ins "gehalten -> feuert" Schema passen, über-
schreiben NUR diese eine Methode statt `_process()` komplett zu duplizieren:

- [[giselle]]s Sniper Burst laedt bei gedrueckter Taste (Kamera-FOV-Zoom) und
  feuert erst beim LOSLASSEN — ruft dabei den unveraenderten `_do_secondary()`
  auf, nur zeitlich verschoben von "press" zu "release".
- [[winter]]s Heavy Laser Stream ersetzt den Cooldown komplett durch eine
  Energiezelle/Batterie statt eines Timers.
- [[karina]]s Acid Rush Mode (Primary) und Phantom Execute (Secondary) sind
  reine Halte-/Toggle-Zustaende ohne klassischen Hitbox-Treffer — Primary
  IST bei ihr die gesamte Fähigkeit, kein zusätzlicher Schlag.

WICHTIG für jede Ueberschreibung: `_primary_timer`/`_secondary_timer` werden
schon WEITER OBEN im selben `_process()`-Durchlauf heruntergezaehlt, bevor die
Poll-Methoden aufgerufen werden — eine Ueberschreibung darf sie nur LESEN und
bei Zustandswechseln neu SETZEN, nie ein zweites Mal dekrementieren.

## Combo-/Hit-Lock-System

Jeder TATSAECHLICHE Treffer (nicht jeder Schwung) setzt einen kurzen Hit-Lock
(reduzierte Bewegung, gekappte Schwerkraft) und zaehlt die Combo hoch; ab dem
zweiten Treffer sinkt `primary_cooldown` linear, hart gedeckelt bei
`combo_max_reduction` (Standard 50 %). Ein "Bohrer"-Kamera-Tilt waechst mit
der Combo und flippt nur bei Zielwechsel.

## Dash-Schaden

Reines Durchqueren loest Schaden aus, kein Antippen und kein Davorstehen-
bleiben — erkannt über den Vorzeichenwechsel der Gegnerposition entlang der
Dash-Achse (`_dash_along()`), nicht über ein simples `body_entered`.

## Q/E = aktive Item-Slots

Seit "PHASE 5" lösen Q/E IMMER das aktive Item im jeweiligen Slot aus
(`Items.use_active_item()`), keine charakterspezifischen Fähigkeiten mehr —
siehe [[party_manager]]/`item_manager.gd`. Die alten zeitbasierten Cooldown-
Getter (`get_ability_q_cooldown_percent()`) liefern seitdem die Item-Ladung
(Räume statt Sekunden), das HUD selbst musste dafuer nicht angefasst werden.

## Verwandt

- [[player_base]] — Schwester-Komponente, Bewegung/Kamera/Status/Tod.
- [[ningning]], [[giselle]], [[winter]], [[karina]] — die vier
  Charakter-spezifischen Ueberschreibungen dieser Basisklasse.

## Erwaehnt in DevLogs

- —
