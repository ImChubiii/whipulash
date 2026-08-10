---
id: "golden_credit_card"
name: "Goldene Kreditkarte"
subtitle: "Limit? Welches Limit?"
kind: PASSIVE
category: UTILITY
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "39"
table_ref: "2.26"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Goldene Kreditkarte

> *Limit? Welches Limit?*

## Effekt

+2 % Schaden je 10 Muenzen im Beutel, bis maximal +50 %.

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

## Metadaten

| Feld | Wert |
|---|---|
| ID | `golden_credit_card` |
| Kind | PASSIVE |
| Kategorie | UTILITY |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.26 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_GOLDEN_CREDIT_CARD`, Variable `card`)
