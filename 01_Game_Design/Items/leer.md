---
id: "leer"
name: "Schwebendes Auge"
subtitle: "Es beobachtet dich alle"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 16.0
charge_rooms: 0
nr: "59"
table_ref: "1.22"
has_stat_modifiers: false
status_effects: ["confused"]
tags: [item, "item/active", "rarity/epic"]
---

# Schwebendes Auge

> *Es beobachtet dich alle*

## Effekt

Beschwoert ein schwebendes Auge, das nahe Gegner regelmaessig verwirrt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[confused]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `leer` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 16.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.22 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_LEER`, Variable `leer`)
