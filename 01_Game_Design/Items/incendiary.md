---
id: "incendiary"
name: "Brandsatz"
subtitle: "Alles brennt lichterloh"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 10.0
charge_rooms: 0
nr: "73"
table_ref: "1.35"
has_stat_modifiers: false
status_effects: ["burn"]
tags: [item, "item/active", "rarity/rare"]
---

# Brandsatz

> *Alles brennt lichterloh*

## Effekt

Legt ein Napalm-Feld vor dir ab, das Gegner darin kontinuierlich verbrennt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[burn]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `incendiary` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 10.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.35 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_INCENDIARY`, Variable `incendiary`)
