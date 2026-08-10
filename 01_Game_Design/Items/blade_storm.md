---
id: "blade_storm"
name: "Klingensturm"
subtitle: "Fuenffacher Schnitt"
kind: ACTIVE
category: MELEE
rarity: LEGENDARY
cooldown_seconds: 14.0
charge_rooms: 0
nr: "52"
table_ref: "1.15"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/legendary"]
---

# Klingensturm

> *Fuenffacher Schnitt*

## Effekt

Wirft fuenf Klingen im Faecher; ein Kill mit diesem Wurf laedt das Item sofort komplett neu auf.

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
| ID | `blade_storm` |
| Kind | ACTIVE |
| Kategorie | MELEE |
| Rarity | LEGENDARY |
| Cooldown | 14.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.15 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BLADE_STORM`, Variable `blade_storm`)
