---
id: "stim_beacon"
name: "Stim-Beacon"
subtitle: "Pumpt dich auf"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 15.0
charge_rooms: 0
nr: "72"
table_ref: "1.34"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Stim-Beacon

> *Pumpt dich auf*

## Effekt

Wirft ein Beacon, das dir Tempo und Angriffskraft verleiht, solange du in seiner Naehe bleibst.

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
| ID | `stim_beacon` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 15.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.34 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_STIM_BEACON`, Variable `stim_beacon`)
