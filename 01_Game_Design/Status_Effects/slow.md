---
id: "slow"
duration: 1.5
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: "2.0"
synergies: ["amount_on"]
triggered_by_items: ["holy_oil", "chewing_gum", "hairspray", "ice_bag", "stiletto_heels", "bubble_gum", "pocket_fan", "slow_orb", "nightfall"]
tags: [status-effect]
---

# slow

SLOW — prozentuale Verlangsamung.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 1.5 s |
| Tick-Intervall | — |
| Schaden/Tick | — |
| Heavy-Variante | 2.0 |


## Zusatzwerte

| Konstante | Wert |
|---|---|
| `DEFAULT_AMOUNT` | 0.25 |
| `HEAVY_AMOUNT` | 0.40 |
| `TINT_STRENGTH` | 0.28 |

## Synergien

- `amount_on()`

## Ausgeloest von (Items)

- [[holy_oil]]
- [[chewing_gum]]
- [[hairspray]]
- [[ice_bag]]
- [[stiletto_heels]]
- [[bubble_gum]]
- [[pocket_fan]]
- [[slow_orb]]
- [[nightfall]]

## Wird abgefragt von (Items, ohne es auszuloesen)

- —

## Gegner-Interaktion

- —

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/slow.gd`
