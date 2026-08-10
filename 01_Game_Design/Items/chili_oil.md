---
id: "chili_oil"
name: "Omas Scharfes Chili-Oel"
subtitle: "Ein Tropfen reicht"
kind: PASSIVE
category: MELEE
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "44"
table_ref: "2.31"
has_stat_modifiers: false
status_effects: ["acid"]
tags: [item, "item/passive", "rarity/epic"]
---

# Omas Scharfes Chili-Oel

> *Ein Tropfen reicht*

## Effekt

Treffer auf brennende Gegner loesen Saeure-Spritzer auf alle umliegenden Gegner aus.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `chili_oil` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.31 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_CHILI_OIL`, Variable `chili`)
