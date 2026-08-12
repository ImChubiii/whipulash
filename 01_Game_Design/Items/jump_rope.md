---
id: "jump_rope"
name: "Springseil"
subtitle: "Immer in Bewegung"
kind: PASSIVE
category: MOVEMENT
rarity: COMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "85"
table_ref: "2.40"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/common"]
---

# Springseil

> *Immer in Bewegung*

## Effekt

-5% Dash-Cooldown.

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
| ID | `jump_rope` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | COMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.40 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_JUMP_ROPE`, Variable `jump_rope`)
