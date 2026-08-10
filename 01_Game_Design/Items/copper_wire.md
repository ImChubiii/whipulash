---
id: "copper_wire"
name: "Kupferdraht-Spule"
subtitle: "Isolierung? War mal."
kind: PASSIVE
category: MOVEMENT
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "50"
table_ref: "2.37"
has_stat_modifiers: false
status_effects: ["burn"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Kupferdraht-Spule

> *Isolierung? War mal.*

## Effekt

Ein Dash durch verlangsamte oder festgenagelte Gegner setzt sie sofort in Brand.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[burn]]

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
| ID | `copper_wire` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.37 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_COPPER_WIRE`, Variable `copper`)
