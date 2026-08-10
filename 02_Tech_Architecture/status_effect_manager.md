---
script_path: scripts/status_effects/status_effect_manager.gd
tags: [architecture, status-effects]
---

# status_effect_manager.gd

Laufzeit-Komponente pro Entity (Spieler wie Gegner) fuer alle aktiven
Statuseffekte. Die einzelnen Effekt-Dateien (`scripts/status_effects/*.gd`,
siehe `01_Game_Design/Status_Effects/`) enthalten NUR ihre Balancing-Zahlen
und VFX-Entscheidung — die Laufzeit (Timer, Tick, Cleanup) sitzt zentral
hier. Diese Trennung existiert, weil sieben Effekte denselben
Lookup/Apply/VFX-Block sonst wortgleich dupliziert haetten.

## Zentrale Funktionen

- `apply_effect(id, duration, magnitude, source, tick_interval)` — **nimmt
  bei einem bereits aktiven Effekt das MAXIMUM aus altem und neuem Wert.**
  Fuer Verlaengerungen ungeeignet: eine Pfeffermuehle mit +3s waere bei
  einem noch 4s laufenden Effekt wirkungslos geblieben.
- `extend_effect(id, extra_seconds)` / `extend_all(extra_seconds, ids)` —
  die tatsaechliche Verlaengerung.
- `get_effect_tick_interval(id)`, `snapshot_dots()` — fuer Synergie-Rechnungen
  wie `StatusBurn.thermal_shock()` (Gefrierbeutel: kompletter Restschaden auf
  einmal).
- `DOT_IDS` — zentrale Liste der Damage-over-Time-Effekte (`poison`, `bleed`,
  `burn`, `acid`). `enemy_ai.gd` muss eine neue ID hier eintragen, sonst
  tickt sie ins Leere.

## Root-Cause-Fixes bei Einfuehrung

- **Dauer-Tint verschwand beim ersten Treffer:** `psx.gdshader` hat GENAU
  EIN Paar `flash_color`/`flash_strength`. Der Hit-Flash-Tween in
  `enemy_ai.gd` fuhr es hoch und wieder auf 0 — jede dauerhafte
  Effekt-Einfaerbung wurde beim naechsten Schlag geloescht. Fix:
  `status_effect_visuals.gd` schreibt den Tint jeden Frame neu; der
  Hit-Flash ueberschreibt nur kurz.
- **Stun-Interrupt haette Gegner dauerhaft gelaehmt:** `_do_attack()` ist
  eine Coroutine ueber mehrere `await`-Punkte. Ein reines `return` beim
  Interrupt haette `_is_attacking` dauerhaft auf `true` stehen lassen.
  Fix: Interrupt-Ausstiege rufen jetzt `_abort_attack()`, das Flag,
  Telegraph und Armpose aufraeumt und den Gegner auf `CHASE` zuruecksetzt.

## Verwandt

- [[player_base]] — Spieler-seitige Anbindung.
- [[custom_enemy_base]] — zweite Anbindungsstelle fuer die sechs neuen
  Sandbox-Prototyp-Gegner (`enemy_ai.gd` deckt nur Fighter/Stinger/Colossus ab).
- Alle Notizen unter `01_Game_Design/Status_Effects/`.

## Erwaehnt in DevLogs

- —
