---
id: "confused"
duration: 2.0
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: "4.0"
synergies: ["max_angle_rad"]
triggered_by_items: ["disco_ball", "roller_skates", "walkman", "leer", "fakeout", "prowler", "paranoia"]
tags: [status-effect]
---

# confused

CONFUSED — der Gegner schlaegt in die falsche Richtung.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 2.0 s |
| Tick-Intervall | — |
| Schaden/Tick | — |
| Heavy-Variante | 4.0 |

## Synergien

- `max_angle_rad()`

## Ausgeloest von (Items)

- [[disco_ball]]
- [[roller_skates]]
- [[walkman]]
- [[leer]]
- [[fakeout]]
- [[prowler]]
- [[paranoia]]

## Gegner-Interaktion

- —

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/confused.gd`
