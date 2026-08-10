---
id: "rooted"
duration: 1.5
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: ""
synergies: ["_play_vfx"]
triggered_by_items: ["roof_nail", "super_glue", "copper_wire", "whipped_cream", "seize"]
tags: [status-effect]
---

# rooted

ROOTED — festgenagelt. Bewegung gesperrt, Angriffe weiterhin erlaubt.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 1.5 s |
| Tick-Intervall | — |
| Schaden/Tick | — |
| Heavy-Variante | — |

## Synergien

- `_play_vfx()`

## Ausgeloest von (Items)

- [[roof_nail]]
- [[super_glue]]
- [[copper_wire]]
- [[whipped_cream]]
- [[seize]]

## Gegner-Interaktion

- Bewusst NICHT in `is_attack_locked()`: `rooted` sperrt nur die Bewegung, nicht den Angriff — Abgrenzung zu `stun`.

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/rooted.gd`
