---
id: "shock_bolt"
name: "Schockbolzen"
subtitle: "Kurzschluss garantiert"
kind: ACTIVE
category: UTILITY
rarity: UNCOMMON
cooldown_seconds: 7.0
charge_rooms: 0
nr: "64"
table_ref: "1.26"
has_stat_modifiers: false
status_effects: ["stun"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/uncommon"]
---

# Schockbolzen

> *Kurzschluss garantiert*

## Effekt

Feuert einen Energiebolzen ab, der den ersten getroffenen Gegner betaeubt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[stun]]

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
| ID | `shock_bolt` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | UNCOMMON |
| Cooldown | 7.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.26 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_SHOCK_BOLT`, Variable `shock_bolt`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[stun]] (Confidence: 1.0)
