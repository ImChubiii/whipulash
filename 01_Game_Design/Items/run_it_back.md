---
id: "run_it_back"
name: "Run It Back"
subtitle: "Zweite Chance"
kind: ACTIVE
category: DEFENSE
rarity: LEGENDARY
cooldown_seconds: 25.0
charge_rooms: 0
nr: "55"
table_ref: "1.18"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/legendary"]
---

# Run It Back

> *Zweite Chance*

## Effekt

Setzt eine Marke an deiner Position. Wuerdest du sterben, wirst du stattdessen dorthin zurueckgeholt und teilweise geheilt.

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
| ID | `run_it_back` |
| Kind | ACTIVE |
| Kategorie | DEFENSE |
| Rarity | LEGENDARY |
| Cooldown | 25.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.18 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_RUN_IT_BACK`, Variable `run_it_back`)
