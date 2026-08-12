---
id: "stun"
duration: 2.0
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: ""
synergies: ["damage_multiplier_against"]
triggered_by_items: ["jumper_cables", "stiletto_heels", "battery_pack", "shock_bolt", "rolling_thunder", "fault_line", "lockdown"]
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


## Zusatzwerte

| Konstante | Wert |
|---|---|
| `TINT_STRENGTH` | 0.40 |
| `MEGAPHONE_DAMAGE_MULTIPLIER` | 3.0 |
| `MODEM_CRIT_MULTIPLIER` | 1.75 |

## Synergien

- `damage_multiplier_against()`

## Ausgeloest von (Items)

- [[jumper_cables]]
- [[stiletto_heels]]
- [[battery_pack]]
- [[shock_bolt]]
- [[rolling_thunder]]
- [[fault_line]]
- [[lockdown]]

## Wird abgefragt von (Items, ohne es auszuloesen)

- —

## Gegner-Interaktion

- Sperrt in `enemy_ai.gd::is_attack_locked()` den Angriff **aller** Gegner ([[fighter]], [[stinger]], [[colossus]]).

## Erwaehnt in DevLogs

- [[2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef|2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]]
- [[2026-07-26_61765de_feat_combat-tuning_hud-overhaul_anti-baiting_sieg-|2026-07-26 — feat: Combat-Tuning, HUD-Overhaul, Anti-Baiting, Sieg-Trophäe, Menü-Fixes, Türsystem-Debugging]]
- [[2026-07-25_905d144_feat_level-generation-polish_minimap-overhaul_haza|2026-07-25 — feat: Level-Generation-Polish, Minimap-Overhaul, Hazard/Door-Fixes, Atmosphäre]]

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/stun.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **referenced_by (calls)**: [[fault_line]] (Confidence: 1.0)
- **referenced_by (calls)**: [[jumper_cables]] (Confidence: 1.0)
- **referenced_by (calls)**: [[lockdown]] (Confidence: 1.0)
- **referenced_by (calls)**: [[rolling_thunder]] (Confidence: 1.0)
- **referenced_by (calls)**: [[shock_bolt]] (Confidence: 1.0)
- **referenced_by (calls)**: [[stiletto_heels]] (Confidence: 1.0)
- **referenced_by (references)**: [[_MOC_Status_Effects]] (Confidence: 1.0)
