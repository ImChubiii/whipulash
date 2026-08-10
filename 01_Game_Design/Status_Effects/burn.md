---
id: "burn"
duration: 3.0
tick_interval: 0.75
damage_per_tick: 6.0
is_damage_over_time: true
heavy_duration: ""
synergies: ["detonate", "thermal_shock"]
triggered_by_items: ["broken_toaster", "hairspray", "ice_bag", "copper_wire", "storm_lighter", "whipped_cream", "spicy_ramen", "incendiary", "blaze", "hot_hands"]
tags: [status-effect]
---

# burn

BURN — Feuer-DoT. Der Gegner leuchtet rot/orange, solange er brennt.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 3.0 s |
| Tick-Intervall | 0.75 s |
| Schaden/Tick | 6.0 |
| Heavy-Variante | — |

## Synergien

- `detonate()`
- `thermal_shock()`

## Ausgeloest von (Items)

- [[broken_toaster]]
- [[hairspray]]
- [[ice_bag]]
- [[copper_wire]]
- [[storm_lighter]]
- [[whipped_cream]]
- [[spicy_ramen]]
- [[incendiary]]
- [[blaze]]
- [[hot_hands]]

## Gegner-Interaktion

- Zaehlt in `enemy_ai.gd` als `DOT_EFFECT_IDS`-Eintrag: tickt automatisch Schaden auf **alle** Gegner ([[fighter]], [[stinger]], [[colossus]]).

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/burn.gd`
