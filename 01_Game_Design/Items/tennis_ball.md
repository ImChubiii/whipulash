---
id: "tennis_ball"
name: "Tennisball an der Schnur"
subtitle: "Kommt immer zurueck"
kind: PASSIVE
category: MOVEMENT
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "32"
table_ref: "2.19"
has_stat_modifiers: false
status_effects: []
tags: [item, "item/passive", "rarity/rare"]
---

# Tennisball an der Schnur

> *Kommt immer zurueck*

## Effekt

Jeder Dash feuert einen Tennisball nach vorn, der Gegner auf Distanz zurueckstoesst. Blutende Getroffene bluten wieder von vorn.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `tennis_ball` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.19 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_TENNIS_BALL`, Variable `tennis`)
