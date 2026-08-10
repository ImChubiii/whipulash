---
id: "vulnerable"
duration: 0.0
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: ""
synergies: []
triggered_by_items: ["snake_bite", "alarmbot"]
tags: [status-effect]
---

# vulnerable

VULNERABLE — generischer Status ohne eigene Datei. Erhoeht den Schaden, den das Ziel durch NACHFOLGENDE Treffer erleidet, um einen Item-spezifischen Bonusfaktor.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 0.0 s |
| Tick-Intervall | — |
| Schaden/Tick | — |
| Heavy-Variante | — |


## Synergien

- —

## Ausgeloest von (Items)

- [[snake_bite]]
- [[alarmbot]]

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

`scripts/items/item_behaviours.gd` (`StatusEffectBase.apply_raw(target, "vulnerable", ...)`, z.B. Schlangenbiss +49 %/3.75s, Alarm-Bot +140 %/5s)
