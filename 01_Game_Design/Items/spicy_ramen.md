---
id: "spicy_ramen"
name: "Scharfe Instant-Nudeln"
subtitle: "Achtung: wirklich scharf"
kind: ACTIVE
category: MELEE
rarity: RARE
cooldown_seconds: 9.0
charge_rooms: 0
nr: "11"
table_ref: "1.11"
has_stat_modifiers: false
status_effects: ["acid", "burn"]
tags: [item, "item/active", "rarity/rare"]
---

# Scharfe Instant-Nudeln

> *Achtung: wirklich scharf*

## Effekt

Speit einen breiten Flammenkegel, der Telegraphs sofort abbricht und Gegner 4 s lang brennen laesst.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]
- [[burn]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `spicy_ramen` |
| Kind | ACTIVE |
| Kategorie | MELEE |
| Rarity | RARE |
| Cooldown | 9.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.11 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_SPICY_RAMEN`, Variable `ramen`)
