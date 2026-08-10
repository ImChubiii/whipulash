---
id: "graffiti_can"
name: "Spruehdose aus dem Tunnel"
subtitle: "Kunst ist, was Kunst macht"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 11.0
charge_rooms: 0
nr: "13"
table_ref: "1.13"
has_stat_modifiers: false
status_effects: ["charm"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/rare"]
---

# Spruehdose aus dem Tunnel

> *Kunst ist, was Kunst macht*

## Effekt

Huellt die Umgebung in eine Farbwolke: Gegner darin sind 5 s verwirrt und treffen sich gegenseitig.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[charm]]

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
| ID | `graffiti_can` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 11.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.13 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_GRAFFITI_CAN`, Variable `graffiti`)
