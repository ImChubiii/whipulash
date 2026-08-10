---
id: "silenced"
duration: 1.0
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: ""
synergies: []
triggered_by_items: ["modem_56k", "car_alarm", "pepper_mill", "megaphone", "boombox", "prowler", "nightfall", "paranoia", "lockdown"]
tags: [status-effect]
---

# silenced

SILENCED — keine Spezialangriffe, keine Telegraphs.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 1.0 s |
| Tick-Intervall | — |
| Schaden/Tick | — |
| Heavy-Variante | — |

## Synergien

- —

## Ausgeloest von (Items)

- [[modem_56k]]
- [[car_alarm]]
- [[pepper_mill]]
- [[megaphone]]
- [[boombox]]
- [[prowler]]
- [[nightfall]]
- [[paranoia]]
- [[lockdown]]

## Gegner-Interaktion

- Sperrt in `enemy_ai.gd::is_attack_locked()` den Angriff **aller** Gegner ([[fighter]], [[stinger]], [[colossus]]).

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/silenced.gd`
