---
id: "executioner_hood"
name: "Scharfrichter-Kapuze"
subtitle: "Der letzte Weg ist kurz"
kind: PASSIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "43"
table_ref: "2.30"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/epic"]
---

# Scharfrichter-Kapuze

> *Der letzte Weg ist kurz*

## Effekt

Kill-Heal: Kills an betaeubten oder festgenagelten Gegnern heilen +1 Leben und loesen eine Schockwelle aus.

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
| ID | `executioner_hood` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.30 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_EXECUTIONER_HOOD`, Variable `executioner`)
