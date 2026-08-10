---
id: "stiletto_heels"
name: "Mamas Stoeckelschuhe"
subtitle: "Klack. Klack. Zisch."
kind: PASSIVE
category: MOVEMENT
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "40"
table_ref: "2.27"
has_stat_modifiers: false
status_effects: ["acid", "slow", "stun"]
tags: [item, "item/passive", "rarity/epic"]
---

# Mamas Stoeckelschuhe

> *Klack. Klack. Zisch.*

## Effekt

Beim Rennen bleiben 2 s lange Saeure-Lachen zurueck. Gegner darin nehmen Saeureschaden und werden langsamer. Jeder 3. Schritt loest eine Schockwelle aus, die nahe Gegner kurz straucheln laesst.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]
- [[slow]]
- [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `stiletto_heels` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.27 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_STILETTO_HEELS`, Variable `heels`)
