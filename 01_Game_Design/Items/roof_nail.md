---
id: "roof_nail"
name: "Rostiger Dachnagel"
subtitle: "Festgenagelt"
kind: PASSIVE
category: MELEE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "25"
table_ref: "2.12"
has_stat_modifiers: false
status_effects: ["rooted"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Rostiger Dachnagel

> *Festgenagelt*

## Effekt

25 % Chance, einen getroffenen Gegner 1,5 s lang festzunageln: er kann sich nicht mehr bewegen, sein Angriff wird sofort unterbrochen, und er ist gegen Rueckstoss immun.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[rooted]]

## Reagiert auf (ohne selbst auszuloesen)

Der Effekt dieses Items greift nur, wenn der Status bereits durch eine
ANDERE Quelle aktiv ist (`StatusX.active()`-Abfrage im Code-Pfad):

- —

## Synergien

Codeverifiziert (`ItemCatalog.ID_Y`-Referenz im aufgeloesten Effekt-Pfad
dieses Items ODER umgekehrt):

- —

## Erwaehnt in DevLogs

- [[2026-08-04_c63b397_featitems_ai_ui_levelgen_party-revive_item-reworks|2026-08-04 — feat(items, ai, ui, levelgen): Party-Revive, Item-Reworks, Boss-HP-Split & Lava-Buoyancy]]
- [[2026-08-04_5d63fe2_featitemscombatlevelgenui_ouija-board_item-reworks|2026-08-04 — feat(items,combat,levelgen,ui): Ouija-Board, Item-Reworks, Last-Stand, Boss-HP-Balken, diverse Bugfixes]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `roof_nail` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.12 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_ROOF_NAIL`, Variable `nail`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[rooted]] (Confidence: 1.0)
