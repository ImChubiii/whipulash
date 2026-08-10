---
id: "burn"
duration: 3.0
tick_interval: 0.75
damage_per_tick: 6.0
is_damage_over_time: true
heavy_duration: ""
synergies: ["detonate", "thermal_shock"]
triggered_by_items: ["hairspray", "copper_wire", "storm_lighter", "spicy_ramen", "incendiary", "blaze", "hot_hands"]
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


## Zusatzwerte

| Konstante | Wert |
|---|---|
| `TINT_STRENGTH` | 0.45 |
| `DETONATE_MULTIPLIER` | 2.0 |

## Synergien

- `detonate()`
- `thermal_shock()`

## Ausgeloest von (Items)

- [[hairspray]]
- [[copper_wire]]
- [[storm_lighter]]
- [[spicy_ramen]]
- [[incendiary]]
- [[blaze]]
- [[hot_hands]]

## Wird abgefragt von (Items, ohne es auszuloesen)

- [[chili_oil]] — Effekt greift nur, wenn dieser Status bereits aktiv ist

## Gegner-Interaktion

- Zaehlt in `enemy_ai.gd` als `DOT_EFFECT_IDS`-Eintrag: tickt automatisch Schaden auf **alle** Gegner ([[fighter]], [[stinger]], [[colossus]], sowie ueber [[custom_enemy_base]] auch die sechs Sandbox-Prototypen).

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/burn.gd`
