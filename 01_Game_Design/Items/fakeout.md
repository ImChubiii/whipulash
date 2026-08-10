---
id: "fakeout"
name: "Koeder"
subtitle: "Nicht die echte"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 10.0
charge_rooms: 0
nr: "62"
table_ref: "1.24"
has_stat_modifiers: false
status_effects: ["confused"]
tags: [item, "item/active", "rarity/rare"]
---

# Koeder

> *Nicht die echte*

## Effekt

Stellt einen Koeder auf, der nach kurzer Zeit explodiert und nahe Gegner verwirrt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[confused]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `fakeout` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 10.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.24 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_FAKEOUT`, Variable `fakeout`)
