---
id: "rusty_cleaver"
name: "Rostiges Beil"
subtitle: "Schwere Hiebe"
kind: PASSIVE
category: MELEE
rarity: COMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "15"
table_ref: "2.2"
has_stat_modifiers: true
status_effects: []
tags: [item, "item/passive", "rarity/common"]
---

# Rostiges Beil

> *Schwere Hiebe*

## Effekt

30 % Chance, Bluten zuzufuegen: 4 s lang jede Sekunde Schaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `rusty_cleaver` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | COMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.2 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_RUSTY_CLEAVER`, Variable `cleaver`)
