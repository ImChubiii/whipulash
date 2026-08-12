---
id: "paintbox"
name: "Tuschkasten"
subtitle: "Bunter als der Rest"
kind: PASSIVE
category: UTILITY
rarity: COMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "92"
table_ref: "2.47"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/common"]
---

# Tuschkasten

> *Bunter als der Rest*

## Effekt

Schuesse leuchten in zufaelligen Farben. +5 Max-HP.

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
| ID | `paintbox` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | COMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.47 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_PAINTBOX`, Variable `paintbox`)
