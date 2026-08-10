---
id: "acid"
duration: 3.0
tick_interval: 0.5
damage_per_tick: 4.0
is_damage_over_time: true
heavy_duration: ""
synergies: ["extend_for_gum"]
triggered_by_items: ["holy_oil", "chewing_gum", "stiletto_heels", "chili_oil", "hand_vacuum", "spicy_ramen", "seize", "snake_bite"]
tags: [status-effect]
---

# acid

ACID — Saeure-DoT aus Limonade, Pfuetzen und dem Handstaubsauger.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 3.0 s |
| Tick-Intervall | 0.5 s |
| Schaden/Tick | 4.0 |
| Heavy-Variante | — |

## Synergien

- `extend_for_gum()`

## Ausgeloest von (Items)

- [[holy_oil]]
- [[chewing_gum]]
- [[stiletto_heels]]
- [[chili_oil]]
- [[hand_vacuum]]
- [[spicy_ramen]]
- [[seize]]
- [[snake_bite]]

## Gegner-Interaktion

- Zaehlt in `enemy_ai.gd` als `DOT_EFFECT_IDS`-Eintrag: tickt automatisch Schaden auf **alle** Gegner ([[fighter]], [[stinger]], [[colossus]]).

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/acid.gd`
