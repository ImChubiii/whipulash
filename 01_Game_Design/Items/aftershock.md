---
id: "aftershock"
name: "Nachbeben"
subtitle: "Verzoegerte Wucht"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 10.0
charge_rooms: 0
nr: "66"
table_ref: "1.28"
has_stat_modifiers: false
status_effects: []
tags: [item, "item/active", "rarity/rare"]
---

# Nachbeben

> *Verzoegerte Wucht*

## Effekt

Feuert eine Energieladung geradeaus, die am ersten Treffer oder maximaler Reichweite explodiert.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `aftershock` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 10.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.28 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_AFTERSHOCK`, Variable `aftershock`)
