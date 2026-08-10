---
id: "healing_orb"
name: "Heil-Orb"
subtitle: "Warmes Licht"
kind: ACTIVE
category: DEFENSE
rarity: EPIC
cooldown_seconds: 16.0
charge_rooms: 0
nr: "79"
table_ref: "1.41"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Heil-Orb

> *Warmes Licht*

## Effekt

Heilt dich sofort um einen Teil deines Maximal-Lebens und dann ueber 4 s weiter.

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
| ID | `healing_orb` |
| Kind | ACTIVE |
| Kategorie | DEFENSE |
| Rarity | EPIC |
| Cooldown | 16.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.41 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_HEALING_ORB`, Variable `healing_orb`)
