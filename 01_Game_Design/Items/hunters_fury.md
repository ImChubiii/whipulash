---
id: "hunters_fury"
name: "Jaegerzorn"
subtitle: "Durch alles hindurch"
kind: ACTIVE
category: UTILITY
rarity: LEGENDARY
cooldown_seconds: 16.0
charge_rooms: 0
nr: "65"
table_ref: "1.27"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/legendary"]
---

# Jaegerzorn

> *Durch alles hindurch*

## Effekt

Feuert drei Energiestrahlen geradeaus ab, die Waende durchdringen und alle getroffenen Gegner schwer verletzen.

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
| ID | `hunters_fury` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | LEGENDARY |
| Cooldown | 16.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.27 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_HUNTERS_FURY`, Variable `hunters_fury`)
