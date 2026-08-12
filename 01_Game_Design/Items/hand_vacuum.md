---
id: "hand_vacuum"
name: "Alter Handstaubsauger"
subtitle: "Beutel seit Jahren nicht gewechselt"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 6.0
charge_rooms: 0
nr: "5"
table_ref: "1.5"
has_stat_modifiers: false
status_effects: ["acid"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Alter Handstaubsauger

> *Beutel seit Jahren nicht gewechselt*

## Effekt

Saugt 2,5 s lang Gegner im Kegel zu dir heran. Saugt dabei Saeure vom Boden auf und feuert sie als Strahl zurueck.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]

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
| ID | `hand_vacuum` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 6.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.5 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_HAND_VACUUM`, Variable `vacuum`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[acid]] (Confidence: 1.0)
