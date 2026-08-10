---
id: "car_alarm"
name: "Alarmanlage vom Parkplatz"
subtitle: "WIIIU WIIIU WIIIU"
kind: PASSIVE
category: DEFENSE
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "46"
table_ref: "2.33"
has_stat_modifiers: false
status_effects: ["silenced"]
tags: [item, "item/passive", "rarity/uncommon"]
---

# Alarmanlage vom Parkplatz

> *WIIIU WIIIU WIIIU*

## Effekt

Nimmst du Schaden, werden alle Gegner im Raum stummgeschaltet.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `car_alarm` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.33 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_CAR_ALARM`, Variable `alarm`)
