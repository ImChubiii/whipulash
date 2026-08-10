---
id: "lockdown"
name: "Lockdown"
subtitle: "Alles steht still"
kind: ACTIVE
category: UTILITY
rarity: LEGENDARY
cooldown_seconds: 26.0
charge_rooms: 0
nr: "83"
table_ref: "1.45"
has_stat_modifiers: false
status_effects: ["silenced", "stun"]
tags: [item, "item/active", "rarity/legendary"]
---

# Lockdown

> *Alles steht still*

## Effekt

Nach kurzem Aufladen betaeubt und schaltet eine gewaltige Druckwelle alle Gegner im Raum stumm.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]
- [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `lockdown` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | LEGENDARY |
| Cooldown | 26.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.45 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_LOCKDOWN`, Variable `lockdown`)
