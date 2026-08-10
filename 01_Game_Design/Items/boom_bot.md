---
id: "boom_bot"
name: "Boom-Bot"
subtitle: "Rollt, dann kracht's"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 9.0
charge_rooms: 0
nr: "56"
table_ref: "1.19"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/rare"]
---

# Boom-Bot

> *Rollt, dann kracht's*

## Effekt

Entsendet einen kleinen Bot, der zum naechsten Gegner rollt und explodiert.

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
| ID | `boom_bot` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 9.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.19 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BOOM_BOT`, Variable `boom_bot`)
