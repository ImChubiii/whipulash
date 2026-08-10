---
id: "rolling_thunder"
name: "Donnergrollen"
subtitle: "Der Boden bebt"
kind: ACTIVE
category: UTILITY
rarity: LEGENDARY
cooldown_seconds: 18.0
charge_rooms: 0
nr: "68"
table_ref: "1.30"
has_stat_modifiers: false
status_effects: ["stun"]
tags: [item, "item/active", "rarity/legendary"]
---

# Donnergrollen

> *Der Boden bebt*

## Effekt

Eine gewaltige Schockwelle betaeubt und stoesst alle nahen Gegner zurueck.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `rolling_thunder` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | LEGENDARY |
| Cooldown | 18.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.30 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_ROLLING_THUNDER`, Variable `rolling_thunder`)
