---
id: "jumper_cables"
name: "Papas Starthilfekabel"
subtitle: "Zisch & Zap"
kind: ACTIVE
category: MOVEMENT
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 2
nr: "1"
table_ref: "1.1"
has_stat_modifiers: false
status_effects: ["stun"]
tags: [item, "item/active", "rarity/epic"]
---

# Papas Starthilfekabel

> *Zisch & Zap*

## Effekt

Sofortiger Dash nach vorne. Durchquerte Gegner nehmen hohen Schaden und werden 2 s betaeubt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `jumper_cables` |
| Kind | ACTIVE |
| Kategorie | MOVEMENT |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | 2 |
| Design-Doc-Ref | 1.1 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_JUMPER_CABLES`, Variable `cables`)
