---
id: "charm"
duration: 4.0
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: ""
synergies: []
triggered_by_items: ["graffiti_can"]
tags: [status-effect]
---

# charm

CHARM — betroffene Gegner greifen sich gegenseitig an statt den Spieler.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 4.0 s |
| Tick-Intervall | — |
| Schaden/Tick | — |
| Heavy-Variante | — |


## Zusatzwerte

| Konstante | Wert |
|---|---|
| `TINT_STRENGTH` | 0.32 |

## Synergien

- —

## Ausgeloest von (Items)

- [[graffiti_can]]

## Wird abgefragt von (Items, ohne es auszuloesen)

- —

## Gegner-Interaktion

- —

## Erwaehnt in DevLogs

- [[2026-08-05_e5b4cf6_feat_massive_gameplay-erweiterung_47_neue_items_ma|2026-08-05 — feat: Massive Gameplay-Erweiterung, 47 neue Items & Main Menu Rework]]

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/charm.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **referenced_by (calls)**: [[graffiti_can]] (Confidence: 1.0)
- **referenced_by (references)**: [[_MOC_Status_Effects]] (Confidence: 1.0)
