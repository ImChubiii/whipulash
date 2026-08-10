---
script_path: scripts/player_base.gd
tags: [architecture, player]
---

# player_base.gd

Basisklasse der spielbaren Charaktere. Kamera-Rig (Feder/Probe-Kollision,
Dash-FOV/-Drill-Effekte), Statuseffekt-Anbindung, Stun-Handling, Void-Death
und Ragdoll-Tod.

## Stun-Lock-Schutz

Zweistufig, analog den meisten Action-Spielen:

1. **Diminishing Returns:** jeder weitere Stun innerhalb des
   Ketten-Zeitfensters wirkt nur noch `stun_diminish_factor` so lang wie der
   vorherige.
2. **Immunitaet:** nach `stun_max_chain` Stuns in Folge greift ein kurzes
   Immunitaetsfenster (`_begin_stun_immunity()`), bevor die Kette von vorn
   beginnt.

Siehe `apply_stun()`, `is_stun_immune()`, `_tick_stun_guard()`.

## Statuseffekt-Anbindung

`apply_status_effect()` / `has_status_effect()` / `_on_status_effect_ticked()`
/ `_on_status_effect_expired()` binden den Spieler an denselben
`StatusEffectManager` wie Gegner an — siehe [[status_effect_manager]].

## Bekannte Bugfixes (Auszug)

- **"Beim Dash zoomt die Kamera in den Spieler rein"**
- **"Die Kamera geht beim Dashen durch Waende"**
- **"Leiche blockiert Kamera und Spieler"** — Ragdoll-Leichen werden nach
  dem Tod aus kamerarelevanten Kollisionsebenen entfernt.

## Void-Death-System

`_update_void_death()` / `_die_from_void_fall()`: der Spieler stirbt beim
Fall in tiefe Abgruende, statt endlos zu fallen.

## Verwandt

- [[party_manager]] — Switch-Invulnerabilitaet beim Last-Stand-Wechsel.
- [[status_effect_manager]] — zentrale Tick-/Verlaengerungs-Logik.
