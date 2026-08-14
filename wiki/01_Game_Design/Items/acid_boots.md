---
id: "acid_boots"
name: "Saeurefeste Stiefel"
subtitle: "Die Limonade beisst nicht mehr"
kind: PASSIVE
category: DEFENSE
rarity: LEGENDARY
cooldown_seconds: 0.0
charge_rooms: 0
nr: "20"
table_ref: "2.7"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/legendary"]
---

# Saeurefeste Stiefel

> *Die Limonade beisst nicht mehr*

## Effekt

75 % weniger Schaden durch saure Limonade und keine Verlangsamung mehr beim Durchwaten.

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
| ID | `acid_boots` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | LEGENDARY |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.7 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_ACID_BOOTS`, Variable `boots`)

## 🧠 Semantische Verbindungen (Graphify)
- **references**: [[lemonade]] (Confidence: 1.0)
