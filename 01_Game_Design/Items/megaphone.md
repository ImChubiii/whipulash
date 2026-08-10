---
id: "megaphone"
name: "Megafon aus der Schule"
subtitle: "RUHE JETZT"
kind: ACTIVE
category: MELEE
rarity: EPIC
cooldown_seconds: 5.0
charge_rooms: 0
nr: "8"
table_ref: "1.8"
has_stat_modifiers: false
status_effects: ["silenced", "stun"]
tags: [item, "item/active", "rarity/epic"]
---

# Megafon aus der Schule

> *RUHE JETZT*

## Effekt

Ein Schrei nach vorn unterbricht Gegner und verursacht Schaden. Gegen bereits betaeubte Gegner dreifacher Schaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]
- [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `megaphone` |
| Kind | ACTIVE |
| Kategorie | MELEE |
| Rarity | EPIC |
| Cooldown | 5.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.8 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_MEGAPHONE`, Variable `megaphone`)
