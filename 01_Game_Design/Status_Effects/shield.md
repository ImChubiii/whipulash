---
id: "shield"
duration: 1.0
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: ""
synergies: []
triggered_by_items: []
tags: [status-effect]
---

# shield

SHIELD — neuer Status-Effekt: Schild-Drohne verpasst bis zu drei Gegnern einen Schild (siehe scripts/enemies/shield_drone.gd).

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
| `TINT_STRENGTH` | 0.3 |
| `MAX_HEALTH_BONUS_FACTOR` | 0.25 |
| `VISUAL_SCALE_BONUS` | 0.15 |

## Synergien

- —

## Ausgeloest von (Items)

- —

## Wird abgefragt von (Items, ohne es auszuloesen)

- —

## Gegner-Interaktion

- Ausgeloest von [[schild-drohne]] auf bis zu drei verbundene Gegner gleichzeitig (`MAX_SHIELDED = 3`), per Strahl-Refresh alle `SHIELD_REFRESH_INTERVAL` (0.5s) — bricht die Drohne die Verbindung ab, laeuft der Schild von selbst aus.
- Wirkung ist **doppelt implementiert**, einmal pro Basisklasse: `enemy_ai.gd::_apply_shield_visual()` fuer [[fighter]]/[[stinger]]/[[colossus]], `custom_enemy_base.gd::_apply_shield_visual()` fuer die sechs Sandbox-Prototypen ueber [[custom_enemy_base]]. Beide lesen dieselben `StatusShield`-Konstanten, damit +25 % HP / Aura-Farbe an einer Stelle gepflegt werden.

## Erwaehnt in DevLogs

- [[2026-08-10_5d04371_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]
- [[2026-08-04_c63b397_featitems_ai_ui_levelgen_party-revive_item-reworks|2026-08-04 — feat(items, ai, ui, levelgen): Party-Revive, Item-Reworks, Boss-HP-Split & Lava-Buoyancy]]

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

`scripts/status_effects/shield.gd`
