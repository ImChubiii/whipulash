---
id: "paranoia"
name: "Paranoia"
subtitle: "Sie sind ueberall"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 9.0
charge_rooms: 0
nr: "75"
table_ref: "1.37"
has_stat_modifiers: false
status_effects: ["confused", "silenced"]
tags: [item, "item/active", "rarity/rare"]
---

# Paranoia

> *Sie sind ueberall*

## Effekt

Eine schwaechere Welle durch Waende hindurch, die Gegner kurz verwirrt und stumm schaltet.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[confused]]
- [[silenced]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `paranoia` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 9.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.37 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_PARANOIA`, Variable `paranoia`)
