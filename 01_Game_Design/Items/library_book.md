---
id: "library_book"
name: "Schulbibliotheks-Buch"
subtitle: "Ueberfaellig seit 1997"
kind: ACTIVE
category: UTILITY
rarity: LEGENDARY
cooldown_seconds: 0.0
charge_rooms: 0
nr: "3"
table_ref: "1.3"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/legendary"]
---

# Schulbibliotheks-Buch

> *Ueberfaellig seit 1997*

## Effekt

Toetet sofort alle Gegner im Raum unter 20 % Leben. Nur einmal pro Etage.

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

- [[2026-08-04_ec5e457_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef|2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `library_book` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | LEGENDARY |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.3 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_LIBRARY_BOOK`, Variable `book`)
