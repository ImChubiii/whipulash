---
id: "laser_pointer"
name: "Laser-Pointer aus dem Kiosk"
subtitle: "Die Katze ist woanders"
kind: PASSIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "30"
table_ref: "2.17"
has_stat_modifiers: false
status_effects: []
tags: [item, "item/passive", "rarity/epic"]
---

# Laser-Pointer aus dem Kiosk

> *Die Katze ist woanders*

## Effekt

Markiert dauerhaft den Gegner mit den meisten Lebenspunkten: +15 % Schaden gegen ihn. Erleidet er Schaden ueber Zeit, springt die Haelfte davon auf umstehende Gegner ueber.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `laser_pointer` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.17 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_LASER_POINTER`, Variable `laser`)
