---
id: "plastic_halo"
name: "Plastik-Heiligenschein"
subtitle: "Aus dem Karnevalsbedarf"
kind: PASSIVE
category: DEFENSE
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "23"
table_ref: "2.10"
has_stat_modifiers: true
status_effects: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Plastik-Heiligenschein

> *Aus dem Karnevalsbedarf*

## Effekt

+1 maximales Leben. Jeder Kill hat 10 % Chance, 0,5 Leben zu heilen.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `plastic_halo` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.10 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_PLASTIC_HALO`, Variable `halo`)
