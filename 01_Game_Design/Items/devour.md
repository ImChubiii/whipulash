---
id: "devour"
name: "Verschlingen"
subtitle: "Nimmt, was uebrig bleibt"
kind: PASSIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "60"
table_ref: "2.38"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Verschlingen

> *Nimmt, was uebrig bleibt*

## Effekt

Passiv: Toetest du einen Gegner, heilst du sofort um einen kleinen Teil deines Maximal-Lebens.

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

## Metadaten

| Feld | Wert |
|---|---|
| ID | `devour` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.38 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_DEVOUR`, Variable `devour`)
