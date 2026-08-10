---
id: "hairspray"
name: "Mutters Haarspray"
subtitle: "FCKW-frei, angeblich"
kind: PASSIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "28"
table_ref: "2.15"
has_stat_modifiers: false
status_effects: ["burn", "slow"]
tags: [item, "item/passive", "rarity/rare"]
---

# Mutters Haarspray

> *FCKW-frei, angeblich*

## Effekt

Schlaege erzeugen eine Spruehwolke: Gegner darin brauchen 0,5 s laenger fuer ihre Angriffe. Trifft die Wolke Feuer, explodiert sie.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[burn]]
- [[slow]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `hairspray` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.15 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_HAIRSPRAY`, Variable `spray`)
