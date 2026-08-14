---
id: "megaphone"
name: "Megafon aus der Schule"
subtitle: "RUHE JETZT"
kind: ACTIVE
category: MELEE
rarity: EPIC
cooldown_seconds: 5.0
charge_rooms: 0
nr: "8"
table_ref: "1.8"
has_stat_modifiers: false
status_effects: ["silenced"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Megafon aus der Schule

> *RUHE JETZT*

## Effekt

Ein Schrei nach vorn unterbricht Gegner und verursacht Schaden. Gegen bereits betaeubte Gegner dreifacher Schaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]

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
| ID | `megaphone` |
| Kind | ACTIVE |
| Kategorie | MELEE |
| Rarity | EPIC |
| Cooldown | 5.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.8 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_MEGAPHONE`, Variable `megaphone`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[silenced]] (Confidence: 1.0)
