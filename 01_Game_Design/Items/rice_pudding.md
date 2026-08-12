---
id: "rice_pudding"
name: "Ueberkochter Milchreis"
subtitle: "Steht seit Dienstag auf dem Herd"
kind: PASSIVE
category: DEFENSE
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "31"
table_ref: "2.18"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/epic"]
---

# Ueberkochter Milchreis

> *Steht seit Dienstag auf dem Herd*

## Effekt

Stehen bleiben baut einen Schild auf (bis 15 % deiner Maximal-HP). Solange der Schild haelt, bist du komplett immun gegen Saeure und Boden-Hazards.

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

- [[2026-08-04_c63b397_featitems_ai_ui_levelgen_party-revive_item-reworks|2026-08-04 — feat(items, ai, ui, levelgen): Party-Revive, Item-Reworks, Boss-HP-Split & Lava-Buoyancy]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `rice_pudding` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.18 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_RICE_PUDDING`, Variable `rice`)
