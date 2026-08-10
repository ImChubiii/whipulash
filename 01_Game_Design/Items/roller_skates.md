---
id: "roller_skates"
name: "Alte Rollschuhe"
subtitle: "Bremsen? Kannte man nicht."
kind: PASSIVE
category: MOVEMENT
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "48"
table_ref: "2.35"
has_stat_modifiers: false
status_effects: ["confused"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/epic"]
---

# Alte Rollschuhe

> *Bremsen? Kannte man nicht.*

## Effekt

Dash-Treffer stossen Gegner extrem weit zurueck und verwirren sie kurz.

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

## Erwaehnt in DevLogs

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `roller_skates` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.35 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_ROLLER_SKATES`, Variable `skates`)
