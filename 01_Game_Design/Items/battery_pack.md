---
id: "battery_pack"
name: "Ausgelaufene Flachbatterie"
subtitle: "Klebt an den Fingern"
kind: PASSIVE
category: DEFENSE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "45"
table_ref: "2.32"
has_stat_modifiers: false
status_effects: ["stun"]
tags: [item, "item/passive", "rarity/rare"]
---

# Ausgelaufene Flachbatterie

> *Klebt an den Fingern*

## Effekt

Betreten von Saeure/Limonade entlaedt einen Stromschlag: nahe Gegner werden betaeubt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `battery_pack` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.32 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BATTERY_PACK`, Variable `battery`)
