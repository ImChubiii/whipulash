---
id: "roof_nail"
name: "Rostiger Dachnagel"
subtitle: "Festgenagelt"
kind: PASSIVE
category: MELEE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "25"
table_ref: "2.12"
has_stat_modifiers: false
status_effects: ["rooted"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Rostiger Dachnagel

> *Festgenagelt*

## Effekt

25 % Chance, einen getroffenen Gegner 1,5 s lang festzunageln: er kann sich nicht mehr bewegen, sein Angriff wird sofort unterbrochen, und er ist gegen Rueckstoss immun.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

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
| ID | `roof_nail` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.12 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_ROOF_NAIL`, Variable `nail`)
