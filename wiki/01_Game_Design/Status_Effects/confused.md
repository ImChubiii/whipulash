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


## Zusatzwerte

| Konstante | Wert |
|---|---|
| `DEFAULT_MAX_ANGLE_DEG` | 75.0 |
| `HEAVY_MAX_ANGLE_DEG` | 140.0 |
| `TINT_STRENGTH` | 0.35 |
| `RAINBOW_SPEED` | 0.9 |
| `STUN_DAMAGE_BONUS` | 0.25 |

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

## Wird abgefragt von (Items, ohne es auszuloesen)

- —

## Gegner-Interaktion

- —

## Erwaehnt in DevLogs

- [[2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef|2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]]

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/confused.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **referenced_by (calls)**: [[disco_ball]] (Confidence: 1.0)
- **referenced_by (calls)**: [[fakeout]] (Confidence: 1.0)
- **referenced_by (calls)**: [[leer]] (Confidence: 1.0)
- **referenced_by (calls)**: [[paranoia]] (Confidence: 1.0)
- **referenced_by (calls)**: [[prowler]] (Confidence: 1.0)
- **referenced_by (calls)**: [[roller_skates]] (Confidence: 1.0)
- **referenced_by (calls)**: [[walkman]] (Confidence: 1.0)
- **referenced_by (references)**: [[_MOC_Status_Effects]] (Confidence: 1.0)
