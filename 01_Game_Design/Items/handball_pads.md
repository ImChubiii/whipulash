---
id: "handball_pads"
name: "Handball-Schulterpolster"
subtitle: "Kreislaeufer-Ausruestung"
kind: PASSIVE
category: DEFENSE
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "38"
table_ref: "2.25"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/epic"]
---

# Handball-Schulterpolster

> *Kreislaeufer-Ausruestung*

## Effekt

Einmal pro Raum: toedlicher Schaden laesst dich stattdessen mit 1 Leben stehen.

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
| ID | `handball_pads` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.25 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_HANDBALL_PADS`, Variable `pads`)
