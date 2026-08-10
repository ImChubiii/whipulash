---
id: "super_glue"
name: "Ausgelaufener Sekundenkleber"
subtitle: "Finger weg. Zu spaet."
kind: PASSIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "47"
table_ref: "2.34"
has_stat_modifiers: false
status_effects: ["rooted"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Ausgelaufener Sekundenkleber

> *Finger weg. Zu spaet.*

## Effekt

Kills hinterlassen eine klebrige Stelle am Boden, die nachfolgende Gegner festnagelt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[rooted]]

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
| ID | `super_glue` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.34 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_SUPER_GLUE`, Variable `glue`)
