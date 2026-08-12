---
id: "acid"
duration: 3.0
tick_interval: 0.5
damage_per_tick: 4.0
is_damage_over_time: true
heavy_duration: ""
synergies: ["extend_for_gum"]
triggered_by_items: ["holy_oil", "stiletto_heels", "chili_oil", "hand_vacuum", "seize", "snake_bite"]
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


## Zusatzwerte

| Konstante | Wert |
|---|---|
| `TINT_STRENGTH` | 0.35 |
| `GUM_EXTENSION_FACTOR` | 0.50 |
| `VULNERABILITY_MULTIPLIER` | 1.2 |

## Synergien

- `extend_for_gum()`

## Ausgeloest von (Items)

- [[holy_oil]]
- [[stiletto_heels]]
- [[chili_oil]]
- [[hand_vacuum]]
- [[seize]]
- [[snake_bite]]

## Wird abgefragt von (Items, ohne es auszuloesen)

- —

## Gegner-Interaktion

- Zaehlt in `enemy_ai.gd` als `DOT_EFFECT_IDS`-Eintrag: tickt automatisch Schaden auf **alle** Gegner ([[fighter]], [[stinger]], [[colossus]], sowie ueber [[custom_enemy_base]] auch die sechs Sandbox-Prototypen).

## Erwaehnt in DevLogs

- [[2026-08-12_5f8cd6d_feat_combat_mechanics_weighted_item_drops_and_ui_t|2026-08-12 — ﻿feat: combat mechanics, weighted item drops and UI tweaks]]
- [[2026-08-04_ec5e457_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef|2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]]

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/acid.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **referenced_by (calls)**: [[chili_oil]] (Confidence: 1.0)
- **referenced_by (calls)**: [[hand_vacuum]] (Confidence: 1.0)
- **referenced_by (calls)**: [[holy_oil]] (Confidence: 1.0)
- **referenced_by (calls)**: [[seize]] (Confidence: 1.0)
- **referenced_by (calls)**: [[snake_bite]] (Confidence: 1.0)
- **referenced_by (calls)**: [[stiletto_heels]] (Confidence: 1.0)
