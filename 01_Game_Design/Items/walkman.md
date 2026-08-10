---
id: "walkman"
name: "Walkman (kaputt)"
subtitle: "Band verheddert, Bass intakt"
kind: ACTIVE
category: DEFENSE
rarity: LEGENDARY
cooldown_seconds: 12.0
charge_rooms: 0
nr: "7"
table_ref: "1.7"
has_stat_modifiers: false
status_effects: ["confused"]
tags: [item, "item/active", "rarity/legendary"]
---

# Walkman (kaputt)

> *Band verheddert, Bass intakt*

## Effekt

Eine Schockwelle zerstoert alle Projektile und stoesst Gegner zurueck. Getroffene sind 4 s lang voellig orientierungslos.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[confused]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `walkman` |
| Kind | ACTIVE |
| Kategorie | DEFENSE |
| Rarity | LEGENDARY |
| Cooldown | 12.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.7 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_WALKMAN`, Variable `walkman`)
