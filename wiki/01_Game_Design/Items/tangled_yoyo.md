---
id: "tangled_yoyo"
name: "Verheddertes Jo-Jo"
subtitle: "Kommt von weit her zurueck"
kind: PASSIVE
category: UTILITY
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "90"
table_ref: "2.45"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Verheddertes Jo-Jo

> *Kommt von weit her zurueck*

## Effekt

+30% Schaden auf maximaler Schuss-Reichweite.

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
| ID | `tangled_yoyo` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.45 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_TANGLED_YOYO`, Variable `yoyo`)
