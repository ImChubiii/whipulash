---
id: "nightfall"
name: "Anbruch der Nacht"
subtitle: "Durch Mauern hindurch"
kind: ACTIVE
category: UTILITY
rarity: LEGENDARY
cooldown_seconds: 18.0
charge_rooms: 0
nr: "71"
table_ref: "1.33"
has_stat_modifiers: false
status_effects: ["silenced", "slow"]
tags: [item, "item/active", "rarity/legendary"]
---

# Anbruch der Nacht

> *Durch Mauern hindurch*

## Effekt

Eine Welle, die durch Waende dringt und alle Gegner im Raum verlangsamt und stumm schaltet.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]
- [[slow]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `nightfall` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | LEGENDARY |
| Cooldown | 18.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.33 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_NIGHTFALL`, Variable `nightfall`)
