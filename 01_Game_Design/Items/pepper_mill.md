---
id: "pepper_mill"
name: "Omas Pfeffermuehle"
subtitle: "Immer zu viel"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 8.0
charge_rooms: 0
nr: "6"
table_ref: "1.6"
has_stat_modifiers: false
status_effects: ["silenced"]
tags: [item, "item/active", "rarity/epic"]
---

# Omas Pfeffermuehle

> *Immer zu viel*

## Effekt

Erzeugt eine Pfefferwolke: Gegner niesen und koennen 2 s nicht angreifen. Alle laufenden Schaden-ueber-Zeit-Effekte halten 3 s laenger.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `pepper_mill` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 8.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.6 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_PEPPER_MILL`, Variable `pepper`)
