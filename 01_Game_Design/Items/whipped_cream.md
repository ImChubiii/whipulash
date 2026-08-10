---
id: "whipped_cream"
name: "Spruehsahne-Dose"
subtitle: "Direkt aus der Dose"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 7.0
charge_rooms: 0
nr: "9"
table_ref: "1.9"
has_stat_modifiers: false
status_effects: ["rooted"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Spruehsahne-Dose

> *Direkt aus der Dose*

## Effekt

Legt einen Sahneteppich aus: Gegner rutschen aus und liegen 1,5 s am Boden. Loescht brennende Gegner und richtet dabei massiven Schaden an.

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
| ID | `whipped_cream` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 7.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.9 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_WHIPPED_CREAM`, Variable `cream`)
