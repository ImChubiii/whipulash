---
id: "chewing_gum"
name: "Kaugummi unter dem Schuh"
subtitle: "Da war doch was am Absatz"
kind: PASSIVE
category: MOVEMENT
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "26"
table_ref: "2.13"
has_stat_modifiers: false
status_effects: ["acid", "slow"]
tags: [item, "item/passive", "rarity/rare"]
---

# Kaugummi unter dem Schuh

> *Da war doch was am Absatz*

## Effekt

Jeder Dash hinterlaesst eine klebrige Spur: Gegner darin werden 1,5 s verlangsamt. Steht ein Gegner in Saeure, haelt die Saeure 50 % laenger.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]
- [[slow]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `chewing_gum` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.13 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_CHEWING_GUM`, Variable `gum`)
