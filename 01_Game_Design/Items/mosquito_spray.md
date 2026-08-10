---
id: "mosquito_spray"
name: "Mueckenspray der Tante"
subtitle: "Riecht nach 1994"
kind: PASSIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "41"
table_ref: "2.28"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Mueckenspray der Tante

> *Riecht nach 1994*

## Effekt

Kill-Heal: Toetest du einen Gegner, der unter Blutung, Brand oder Saeure leidet, hast du 15 % Chance auf +0,5 Leben.

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
| ID | `mosquito_spray` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.28 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_MOSQUITO_SPRAY`, Variable `mosquito`)
