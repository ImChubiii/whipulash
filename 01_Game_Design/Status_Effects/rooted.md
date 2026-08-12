---
id: "rooted"
duration: 1.5
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: ""
synergies: ["_play_vfx"]
triggered_by_items: ["roof_nail", "super_glue", "whipped_cream", "seize"]
tags: [status-effect]
---

# rooted

ROOTED — festgenagelt. Bewegung gesperrt, Angriffe weiterhin erlaubt.

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | 1.5 s |
| Tick-Intervall | — |
| Schaden/Tick | — |
| Heavy-Variante | — |


## Zusatzwerte

| Konstante | Wert |
|---|---|
| `TINT_STRENGTH` | 0.30 |
| `DUST_RING_COUNT` | 2 |
| `DUST_RING_SPREAD` | 0.45 |

## Synergien

- `_play_vfx()`

## Ausgeloest von (Items)

- [[roof_nail]]
- [[super_glue]]
- [[whipped_cream]]
- [[seize]]

## Wird abgefragt von (Items, ohne es auszuloesen)

- —

## Gegner-Interaktion

- Bewusst NICHT in `is_attack_locked()`: `rooted` sperrt nur die Bewegung, nicht den Angriff — Abgrenzung zu `stun`.

## Erwaehnt in DevLogs

- [[2026-08-04_e9b2b1f_featitemscombatlevelgenui_ouija-board_item-reworks|2026-08-04 — feat(items,combat,levelgen,ui): Ouija-Board, Item-Reworks, Last-Stand, Boss-HP-Balken, diverse Bugfixes]]
- [[2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef|2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]]
- [[2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult|2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]]

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/rooted.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **referenced_by (calls)**: [[roof_nail]] (Confidence: 1.0)
- **referenced_by (calls)**: [[seize]] (Confidence: 1.0)
- **referenced_by (calls)**: [[super_glue]] (Confidence: 1.0)
- **referenced_by (calls)**: [[whipped_cream]] (Confidence: 1.0)
- **referenced_by (references)**: [[_MOC_Status_Effects]] (Confidence: 1.0)
