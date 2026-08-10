---
id: "fault_line"
name: "Verwerfungslinie"
subtitle: "Riss im Boden"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 12.0
charge_rooms: 0
nr: "67"
table_ref: "1.29"
has_stat_modifiers: false
status_effects: ["stun"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Verwerfungslinie

> *Riss im Boden*

## Effekt

Ein seismischer Riss laeuft geradeaus vor dir und betaeubt jeden Gegner, den er durchquert.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[stun]]

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
| ID | `fault_line` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 12.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.29 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_FAULT_LINE`, Variable `fault_line`)
