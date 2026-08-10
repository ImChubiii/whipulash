---
id: "pocket_fan"
name: "USB-Mini-Ventilator"
subtitle: "5V, aber mit Haltung"
kind: ACTIVE
category: UTILITY
rarity: UNCOMMON
cooldown_seconds: 7.0
charge_rooms: 0
nr: "12"
table_ref: "1.12"
has_stat_modifiers: false
status_effects: ["slow"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/uncommon"]
---

# USB-Mini-Ventilator

> *5V, aber mit Haltung*

## Effekt

Ein Windstoss nach vorn verlangsamt Gegner 3 s lang und ueberträgt ihre laufenden Schaden-ueber-Zeit-Effekte auf Nachbarn.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[slow]]

## Reagiert auf (ohne selbst auszuloesen)

Der Effekt dieses Items greift nur, wenn der Status bereits durch eine
ANDERE Quelle aktiv ist (`StatusX.active()`-Abfrage im Code-Pfad):

- —

## Synergien

Codeverifiziert (`ItemCatalog.ID_Y`-Referenz im aufgeloesten Effekt-Pfad
dieses Items ODER umgekehrt):

- —

## Erwaehnt in DevLogs

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `pocket_fan` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | UNCOMMON |
| Cooldown | 7.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.12 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_POCKET_FAN`, Variable `fan`)
