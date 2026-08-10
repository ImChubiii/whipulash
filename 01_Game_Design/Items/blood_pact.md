---
id: "blood_pact"
name: "Das Blutpakt"
subtitle: "Unterschrieben, nicht gelesen"
kind: PASSIVE
category: MELEE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "24"
table_ref: "2.11"
has_stat_modifiers: true
status_effects: []
tags: [item, "item/passive", "rarity/rare"]
---

# Das Blutpakt

> *Unterschrieben, nicht gelesen*

## Effekt

+40 % Schaden. Jeder 5. Treffer kostet dich selbst 0,5 Leben.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `blood_pact` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.11 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BLOOD_PACT`, Variable `pact`)
