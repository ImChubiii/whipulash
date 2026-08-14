---
id: "set_square"
name: "Geodreieck"
subtitle: "Immer im rechten Winkel"
kind: PASSIVE
category: UTILITY
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "86"
table_ref: "2.41"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Geodreieck

> *Immer im rechten Winkel*

## Effekt

+15% Trefferflaeche.

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
| ID | `set_square` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.41 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_SET_SQUARE`, Variable `set_square`)
