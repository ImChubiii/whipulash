---
id: "blaze"
name: "Feuerwand"
subtitle: "Nichts kommt durch"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 12.0
charge_rooms: 0
nr: "53"
table_ref: "1.16"
has_stat_modifiers: false
status_effects: ["burn"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Feuerwand

> *Nichts kommt durch*

## Effekt

Legt eine Reihe brennender Flaechen vor dir ab, die Gegner darin fortlaufend verbrennen.

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
| ID | `blaze` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 12.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.16 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BLAZE`, Variable `blaze`)
