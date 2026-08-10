---
id: "cursed_die"
name: "Verfluchter Glueckswuerfel"
subtitle: "Neu wuerfeln kostet dich etwas"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 10.0
charge_rooms: 0
nr: "4"
table_ref: "1.4"
has_stat_modifiers: false
status_effects: []
tags: [item, "item/active", "rarity/rare"]
---

# Verfluchter Glueckswuerfel

> *Neu wuerfeln kostet dich etwas*

## Effekt

Wandelt alle herumliegenden Drops im Raum in zufaellige andere Drops um.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `cursed_die` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 10.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.4 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_CURSED_DIE`, Variable `cursed`)
