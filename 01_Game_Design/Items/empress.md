---
id: "empress"
name: "Kaiserin"
subtitle: "Regiert das Schlachtfeld"
kind: ACTIVE
category: MOVEMENT
rarity: LEGENDARY
cooldown_seconds: 20.0
charge_rooms: 0
nr: "61"
table_ref: "1.23"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/legendary"]
---

# Kaiserin

> *Regiert das Schlachtfeld*

## Effekt

Erhoeht dein Tempo drastisch. Waehrend der Wirkung setzen Kills die Abklingzeit deines Aktiv-Items zurueck und machen dich kurz unsichtbar.

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
| ID | `empress` |
| Kind | ACTIVE |
| Kategorie | MOVEMENT |
| Rarity | LEGENDARY |
| Cooldown | 20.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.23 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_EMPRESS`, Variable `empress`)
