---
id: "snake_bite"
name: "Schlangenbiss"
subtitle: "Gift wirkt langsam, aber sicher"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 10.0
charge_rooms: 0
nr: "76"
table_ref: "1.38"
has_stat_modifiers: false
status_effects: ["acid", "vulnerable"]
tags: [item, "item/active", "rarity/rare"]
---

# Schlangenbiss

> *Gift wirkt langsam, aber sicher*

## Effekt

Legt eine Saeurepfuetze ab. Gegner darin sind verwundbar und nehmen erhoehten Schaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]
- [[vulnerable]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `snake_bite` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 10.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.38 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_SNAKE_BITE`, Variable `snake_bite`)
