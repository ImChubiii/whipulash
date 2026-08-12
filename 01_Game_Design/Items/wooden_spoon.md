---
id: "wooden_spoon"
name: "Mamas Kochloeffel"
subtitle: "Schlag die Hitze zurueck"
kind: PASSIVE
category: MELEE
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "14"
table_ref: "2.1"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Mamas Kochloeffel

> *Schlag die Hitze zurueck*

## Effekt

Ein Treffer auf einen Gegner gibt 0,75 s lang 1,5x Tempo und Unverwundbarkeit.

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

- [[2026-07-27_f88829f_feat_treasure_room_items_hud_overhaul_balancing_mu|2026-07-27 — feat: Treasure room items, HUD overhaul, balancing, multiple bug fixes]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `wooden_spoon` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.1 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_WOODEN_SPOON`, Variable `spoon`)
