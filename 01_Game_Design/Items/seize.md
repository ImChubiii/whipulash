---
id: "seize"
name: "Ergreifen"
subtitle: "Kein Entkommen"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 11.0
charge_rooms: 0
nr: "70"
table_ref: "1.32"
has_stat_modifiers: false
status_effects: ["acid", "rooted"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/rare"]
---

# Ergreifen

> *Kein Entkommen*

## Effekt

Legt eine Falle ab, die Gegner darin festwurzelt und mit Saeure uebergiesst.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]
- [[rooted]]

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
| ID | `seize` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 11.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.32 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_SEIZE`, Variable `seize`)
