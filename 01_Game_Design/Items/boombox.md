---
id: "boombox"
name: "Alte Ghettoblaster-Box"
subtitle: "Bass, der Waende einreisst"
kind: ACTIVE
category: DEFENSE
rarity: EPIC
cooldown_seconds: 9.0
charge_rooms: 0
nr: "10"
table_ref: "1.10"
has_stat_modifiers: false
status_effects: ["silenced"]
tags: [item, "item/active", "rarity/epic"]
---

# Alte Ghettoblaster-Box

> *Bass, der Waende einreisst*

## Effekt

Sendet eine 4 s lange Basswelle: zerstoert Projektile und schaltet Gegner in Reichweite stumm. Stumme Gegner erleiden +30 % Nahkampfschaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `boombox` |
| Kind | ACTIVE |
| Kategorie | DEFENSE |
| Rarity | EPIC |
| Cooldown | 9.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.10 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BOOMBOX`, Variable `boombox`)
