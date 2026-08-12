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


## Zusatzwerte

| Konstante | Wert |
|---|---|
| `TINT_STRENGTH` | 0.30 |

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

## Wird abgefragt von (Items, ohne es auszuloesen)

- [[boombox]] — Effekt greift nur, wenn dieser Status bereits aktiv ist

## Gegner-Interaktion

- Sperrt in `enemy_ai.gd::is_attack_locked()` den Angriff **aller** Gegner ([[fighter]], [[stinger]], [[colossus]]).

## Erwaehnt in DevLogs

- [[2026-08-04_ec5e457_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef|2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]]

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/silenced.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **referenced_by (calls)**: [[car_alarm]] (Confidence: 1.0)
- **referenced_by (calls)**: [[lockdown]] (Confidence: 1.0)
- **referenced_by (calls)**: [[megaphone]] (Confidence: 1.0)
- **referenced_by (calls)**: [[modem_56k]] (Confidence: 1.0)
- **referenced_by (calls)**: [[nightfall]] (Confidence: 1.0)
- **referenced_by (calls)**: [[paranoia]] (Confidence: 1.0)
- **referenced_by (calls)**: [[pepper_mill]] (Confidence: 1.0)
- **referenced_by (calls)**: [[prowler]] (Confidence: 1.0)
