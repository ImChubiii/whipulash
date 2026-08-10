---
id: "slow_orb"
name: "Frost-Orb"
subtitle: "Kuehler Kopf"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 9.0
charge_rooms: 0
nr: "78"
table_ref: "1.40"
has_stat_modifiers: false
status_effects: ["slow"]
tags: [item, "item/active", "rarity/rare"]
---

# Frost-Orb

> *Kuehler Kopf*

## Effekt

Legt eine Eisflaeche vor dir ab, die Gegner darin stark verlangsamt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[slow]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `slow_orb` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 9.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.40 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_SLOW_ORB`, Variable `slow_orb`)
