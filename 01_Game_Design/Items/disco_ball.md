---
id: "disco_ball"
name: "Disco-Kugel-Anhaenger"
subtitle: "Samstagnacht, jede Nacht"
kind: PASSIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "33"
table_ref: "2.20"
has_stat_modifiers: false
status_effects: ["confused"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Disco-Kugel-Anhaenger

> *Samstagnacht, jede Nacht*

## Effekt

Kills werfen Lichtreflexe durch den Raum. 10 % Chance, umstehende Gegner 2 s zu verwirren. Verwirrte Gegner nehmen 25 % mehr Schaden, wenn sie betaeubt sind.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[confused]]

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
| ID | `disco_ball` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.20 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_DISCO_BALL`, Variable `disco`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[confused]] (Confidence: 1.0)
