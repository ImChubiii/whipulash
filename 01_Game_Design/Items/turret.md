---
id: "turret"
name: "Geschuetzturm"
subtitle: "Automatische Unterstuetzung"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 20.0
charge_rooms: 0
nr: "82"
table_ref: "1.44"
has_stat_modifiers: false
status_effects: []
tags: [item, "item/active", "rarity/epic"]
---

# Geschuetzturm

> *Automatische Unterstuetzung*

## Effekt

Stellt einen freundlichen Geschuetzturm auf, der automatisch auf nahe Gegner feuert.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `turret` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 20.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.44 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_TURRET`, Variable `turret_item`)
