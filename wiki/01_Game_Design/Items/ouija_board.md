---
id: "ouija_board"
name: "Papp-Wahrsagerbrett"
subtitle: "Etwas antwortet"
kind: PASSIVE
category: MELEE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: ""
table_ref: ""
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Papp-Wahrsagerbrett

> *Etwas antwortet*

## Effekt

Nahkampftreffer haben 20 % Chance, einen Rachegeist zu beschwoeren. Er visiert gezielt Gegner an, die hinter dir oder ausserhalb deiner Nahkampf-Reichweite stehen.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Reagiert auf (ohne selbst auszuloesen)

Der Effekt dieses Items greift nur, wenn der Status bereits durch eine
ANDERE Quelle aktiv ist (`StatusX.active()`-Abfrage im Code-Pfad):

- —

## Synergien

Codeverifiziert (`ItemCatalog.ID_Y`-Referenz im aufgeloesten Effekt-Pfad
dieses Items ODER umgekehrt):

- —

## Erwaehnt in DevLogs

- [[2026-08-05_e5b4cf6_feat_massive_gameplay-erweiterung_47_neue_items_ma|2026-08-05 — feat: Massive Gameplay-Erweiterung, 47 neue Items & Main Menu Rework]]
- [[2026-08-04_c28ab95_featitems_ai_ui_levelgen_party-revive_item-reworks|2026-08-04 — feat(items, ai, ui, levelgen): Party-Revive, Item-Reworks, Boss-HP-Split & Lava-Buoyancy]]
- [[2026-08-04_e9b2b1f_featitemscombatlevelgenui_ouija-board_item-reworks|2026-08-04 — feat(items,combat,levelgen,ui): Ouija-Board, Item-Reworks, Last-Stand, Boss-HP-Balken, diverse Bugfixes]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `ouija_board` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | — |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_OUIJA_BOARD`, Variable `ouija`)
