---
id: "pocket_calculator"
name: "Taschenrechner"
subtitle: "Rechnet die Trefferchance aus"
kind: PASSIVE
category: UTILITY
rarity: COMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "84"
table_ref: "2.39"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/common"]
---

# Taschenrechner

> *Rechnet die Trefferchance aus*

## Effekt

+3% Krit-Chance.

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
| ID | `pocket_calculator` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | COMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.39 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_POCKET_CALCULATOR`, Variable `calculator`)
