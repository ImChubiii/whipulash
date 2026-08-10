---
id: "vampire_teeth"
name: "Plastik-Vampirgebiss"
subtitle: "Aus dem Faschingsladen"
kind: PASSIVE
category: UTILITY
rarity: LEGENDARY
cooldown_seconds: 0.0
charge_rooms: 0
nr: "42"
table_ref: "2.29"
has_stat_modifiers: false
status_effects: []
tags: [item, "item/passive", "rarity/legendary"]
---

# Plastik-Vampirgebiss

> *Aus dem Faschingsladen*

## Effekt

Kill-Heal: Kills an Gegnern mit einem aktiven Statuseffekt heilen garantiert +0,5 Leben.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `vampire_teeth` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | LEGENDARY |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.29 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_VAMPIRE_TEETH`, Variable `vampire`)
