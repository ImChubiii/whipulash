---
id: "alarmbot"
name: "Alarm-Bot"
subtitle: "Markiert das Ziel"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 9.0
charge_rooms: 0
nr: "81"
table_ref: "1.43"
has_stat_modifiers: false
status_effects: ["vulnerable"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/rare"]
---

# Alarm-Bot

> *Markiert das Ziel*

## Effekt

Rast auf den naechsten Gegner zu und markiert ihn - er nimmt danach kurzzeitig doppelten Schaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[vulnerable]]

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
| ID | `alarmbot` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 9.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.43 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_ALARMBOT`, Variable `alarmbot`)

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[alarmbot]] (Confidence: 1.0)
