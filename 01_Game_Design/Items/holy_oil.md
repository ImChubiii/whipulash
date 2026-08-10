---
id: "holy_oil"
name: "Heiliges Oel"
subtitle: "Hinterlasse eine Spur"
kind: PASSIVE
category: MOVEMENT
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "18"
table_ref: "2.5"
has_stat_modifiers: false
status_effects: ["acid", "slow"]
tags: [item, "item/passive", "rarity/epic"]
---

# Heiliges Oel

> *Hinterlasse eine Spur*

## Effekt

Hinterlaesst beim Laufen eine Pfuetze. Gegner darin erleiden Schaden und werden 25 % verlangsamt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]
- [[slow]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `holy_oil` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.5 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_HOLY_OIL`, Variable `oil`)
