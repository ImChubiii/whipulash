---
id: "prowler"
name: "Schatten-Pirscher"
subtitle: "Laeuft unter dem Radar"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 15.0
charge_rooms: 0
nr: "69"
table_ref: "1.31"
has_stat_modifiers: false
status_effects: ["confused", "silenced"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Schatten-Pirscher

> *Laeuft unter dem Radar*

## Effekt

Entsendet einen Schattenwolf, der von Gegner zu Gegner hetzt und sie kurz verwirrt und stumm schaltet.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[confused]]
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
| ID | `prowler` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 15.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.31 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_PROWLER`, Variable `prowler`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[confused]] (Confidence: 1.0)
- **calls**: [[silenced]] (Confidence: 1.0)
