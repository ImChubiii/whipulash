---
id: "old_compass"
name: "Alter Zirkel"
subtitle: "Zieht groessere Kreise"
kind: PASSIVE
category: MELEE
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "89"
table_ref: "2.44"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Alter Zirkel

> *Zieht groessere Kreise*

## Effekt

+25% Nahkampf-Reichweite.

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
| ID | `old_compass` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.44 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_OLD_COMPASS`, Variable `old_compass`)
