---
id: "broken_toaster"
name: "Kaputter Toaster"
subtitle: "Bitte nicht mit der Gabel"
kind: PASSIVE
category: DEFENSE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "27"
table_ref: "2.14"
has_stat_modifiers: false
status_effects: ["burn"]
tags: [item, "item/passive", "rarity/rare"]
---

# Kaputter Toaster

> *Bitte nicht mit der Gabel*

## Effekt

Wenn du getroffen wirst, stossen Funken alle Nahkampf-Gegner zurueck. Brennende Gegner nehmen dabei sofort doppelten Feuerschaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[burn]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `broken_toaster` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.14 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BROKEN_TOASTER`, Variable `toaster`)
