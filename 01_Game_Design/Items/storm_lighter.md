---
id: "storm_lighter"
name: "Sturmfeuerzeug"
subtitle: "Haelt jedem Wind stand"
kind: ACTIVE
category: MELEE
rarity: EPIC
cooldown_seconds: 3.0
charge_rooms: 0
nr: "2"
table_ref: "1.2"
has_stat_modifiers: false
status_effects: ["burn"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Sturmfeuerzeug

> *Haelt jedem Wind stand*

## Effekt

Spuckt einen 90-Grad-Feuerbogen nach vorn: dreifacher Schaden, Gegner brennen 3 s lang nach.

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

## Metadaten

| Feld | Wert |
|---|---|
| ID | `storm_lighter` |
| Kind | ACTIVE |
| Kategorie | MELEE |
| Rarity | EPIC |
| Cooldown | 3.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.2 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_STORM_LIGHTER`, Variable `lighter`)
