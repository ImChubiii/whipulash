---
id: "paint_shells"
name: "Streugranaten"
subtitle: "Bunter Regen"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 11.0
charge_rooms: 0
nr: "57"
table_ref: "1.20"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Streugranaten

> *Bunter Regen*

## Effekt

Wirft mehrere kleine Granaten in einem Streumuster vor dir, die kurz danach explodieren.

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
| ID | `paint_shells` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 11.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.20 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_PAINT_SHELLS`, Variable `paint_shells`)
