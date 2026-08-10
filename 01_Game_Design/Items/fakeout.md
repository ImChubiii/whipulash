---
id: "fakeout"
name: "Koeder"
subtitle: "Nicht die echte"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 10.0
charge_rooms: 0
nr: "62"
table_ref: "1.24"
has_stat_modifiers: false
status_effects: ["confused"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/rare"]
---

# Koeder

> *Nicht die echte*

## Effekt

Stellt einen Koeder auf, der nach kurzer Zeit explodiert und nahe Gegner verwirrt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[confused]]

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
| ID | `fakeout` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 10.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.24 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_FAKEOUT`, Variable `fakeout`)
