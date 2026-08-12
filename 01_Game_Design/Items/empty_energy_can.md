---
id: "empty_energy_can"
name: "Leere Energy-Dose"
subtitle: "Der Zucker wirkt nach"
kind: PASSIVE
category: MOVEMENT
rarity: COMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "88"
table_ref: "2.43"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/common"]
---

# Leere Energy-Dose

> *Der Zucker wirkt nach*

## Effekt

+20% Lauftempo fuer 1.5s nach dem Dashen.

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
| ID | `empty_energy_can` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | COMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.43 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_EMPTY_ENERGY_CAN`, Variable `energy_can`)
