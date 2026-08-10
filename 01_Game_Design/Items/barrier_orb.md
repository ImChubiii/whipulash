---
id: "barrier_orb"
name: "Barriere-Orb"
subtitle: "Kommst du hier nicht vorbei"
kind: ACTIVE
category: DEFENSE
rarity: EPIC
cooldown_seconds: 14.0
charge_rooms: 0
nr: "77"
table_ref: "1.39"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Barriere-Orb

> *Kommst du hier nicht vorbei*

## Effekt

Errichtet eine kurzlebige, undurchdringliche Eiswand vor dir - blockiert Gegner und Geschosse.

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
| ID | `barrier_orb` |
| Kind | ACTIVE |
| Kategorie | DEFENSE |
| Rarity | EPIC |
| Cooldown | 14.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.39 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BARRIER_ORB`, Variable `barrier_orb`)
