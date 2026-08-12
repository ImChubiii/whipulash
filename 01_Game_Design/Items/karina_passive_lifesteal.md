---
id: "karina_passive_lifesteal"
name: "Karinas Reflexe"
subtitle: ""
kind: PASSIVE
category: DEFENSE
rarity: COMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: ""
table_ref: ""
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/common"]
---

# Karinas Reflexe

> **

## Effekt

15% Chance, bei einem Treffer 5 HP zu heilen.

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
| ID | `karina_passive_lifesteal` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | COMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | — |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_KARINA_PASSIVE_LIFESTEAL`, Variable `item`)

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[karina_passive_lifesteal]] (Confidence: 1.0)
