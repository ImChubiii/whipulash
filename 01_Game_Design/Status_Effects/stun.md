---
id: "stun"
duration: 2.0
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: ""
synergies: ["damage_multiplier_against"]
triggered_by_items: ["jumper_cables", "modem_56k", "stiletto_heels", "battery_pack", "megaphone", "shock_bolt", "rolling_thunder", "fault_line", "lockdown"]
tags: [status-effect]
---

# stun

STUN — vollstaendige Handlungsunfaehigkeit.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 2.0 s |
| Tick-Intervall | — |
| Schaden/Tick | — |
| Heavy-Variante | — |

## Synergien

- `damage_multiplier_against()`

## Ausgeloest von (Items)

- [[jumper_cables]]
- [[modem_56k]]
- [[stiletto_heels]]
- [[battery_pack]]
- [[megaphone]]
- [[shock_bolt]]
- [[rolling_thunder]]
- [[fault_line]]
- [[lockdown]]

## Gegner-Interaktion

- Sperrt in `enemy_ai.gd::is_attack_locked()` den Angriff **aller** Gegner ([[fighter]], [[stinger]], [[colossus]]).

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/stun.gd`
