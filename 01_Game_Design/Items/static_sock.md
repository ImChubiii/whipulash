---
id: "static_sock"
name: "Statische Socke"
subtitle: "Ladung baut sich auf"
kind: PASSIVE
category: MELEE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "16"
table_ref: "2.3"
has_stat_modifiers: false
status_effects: []
tags: [item, "item/passive", "rarity/rare"]
---

# Statische Socke

> *Ladung baut sich auf*

## Effekt

Jeder 6. Treffer entlaedt eine Schockwelle: doppelter Schaden im Umkreis, Gegner werden zurueckgestossen.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `static_sock` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.3 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_STATIC_SOCK`, Variable `sock`)
