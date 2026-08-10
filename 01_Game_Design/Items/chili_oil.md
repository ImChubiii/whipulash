---
id: "chili_oil"
name: "Omas Scharfes Chili-Oel"
subtitle: "Ein Tropfen reicht"
kind: PASSIVE
category: MELEE
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "44"
table_ref: "2.31"
has_stat_modifiers: false
status_effects: ["acid"]
reacts_to_status: ["burn"]
synergizes_with: []
tags: [item, "item/passive", "rarity/epic"]
---

# Omas Scharfes Chili-Oel

> *Ein Tropfen reicht*

## Effekt

Treffer auf brennende Gegner loesen Saeure-Spritzer auf alle umliegenden Gegner aus.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]

## Reagiert auf (ohne selbst auszuloesen)

Der Effekt dieses Items greift nur, wenn der Status bereits durch eine
ANDERE Quelle aktiv ist (`StatusX.active()`-Abfrage im Code-Pfad):

- [[burn]] — setzt den Effekt voraus, loest ihn aber nicht selbst aus

## Synergien

Codeverifiziert (`ItemCatalog.ID_Y`-Referenz im aufgeloesten Effekt-Pfad
dieses Items ODER umgekehrt):

- —

## Erwaehnt in DevLogs

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `chili_oil` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.31 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_CHILI_OIL`, Variable `chili`)
