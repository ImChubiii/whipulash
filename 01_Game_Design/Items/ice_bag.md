---
id: "ice_bag"
name: "Gefrierbeutel voll Eis"
subtitle: "Fuer die Schwellung"
kind: PASSIVE
category: MELEE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "34"
table_ref: "2.21"
has_stat_modifiers: false
status_effects: ["slow"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Gefrierbeutel voll Eis

> *Fuer die Schwellung*

## Effekt

15 % Chance, einen Gegner 2 s lang um 40 % zu verlangsamen. Trifft es einen brennenden Gegner, entlaedt der Thermoschock den gesamten Restbrand auf einen Schlag.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[slow]]

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
| ID | `ice_bag` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.21 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_ICE_BAG`, Variable `ice`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[slow]] (Confidence: 1.0)
