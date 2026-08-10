---
id: "updraft"
name: "Aufwind"
subtitle: "Nach oben, immer nach oben"
kind: ACTIVE
category: MOVEMENT
rarity: UNCOMMON
cooldown_seconds: 8.0
charge_rooms: 0
nr: "51"
table_ref: "1.14"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/uncommon"]
---

# Aufwind

> *Nach oben, immer nach oben*

## Effekt

Schleudert dich mit einem starken Aufwind senkrecht nach oben - perfekt, um Abgruende oder Angriffe zu ueberspringen.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- —

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
| ID | `updraft` |
| Kind | ACTIVE |
| Kategorie | MOVEMENT |
| Rarity | UNCOMMON |
| Cooldown | 8.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.14 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_UPDRAFT`, Variable `updraft`)
