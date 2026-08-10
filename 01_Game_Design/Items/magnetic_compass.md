---
id: "magnetic_compass"
name: "Magnetischer Kompass"
subtitle: "Alles kommt zu dir"
kind: PASSIVE
category: DEFENSE
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "19"
table_ref: "2.6"
has_stat_modifiers: true
status_effects: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Magnetischer Kompass

> *Alles kommt zu dir*

## Effekt

Zieht Muenzen, Herzen und abgelegte Bomben im Umkreis von 6 m automatisch an.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `magnetic_compass` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.6 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_MAGNETIC_COMPASS`, Variable `compass`)
