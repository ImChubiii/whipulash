---
id: "rusty_cleaver"
name: "Rostiges Beil"
subtitle: "Schwere Hiebe"
kind: PASSIVE
category: MELEE
rarity: COMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "15"
table_ref: "2.2"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: ["knitting_needles"]
tags: [item, "item/passive", "rarity/common"]
---

# Rostiges Beil

> *Schwere Hiebe*

## Effekt

30 % Chance, Bluten zuzufuegen: 4 s lang jede Sekunde Schaden.

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

- [[knitting_needles]] — *Omas Stricknadeln*

## Erwaehnt in DevLogs

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `rusty_cleaver` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | COMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.2 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_RUSTY_CLEAVER`, Variable `cleaver`)
