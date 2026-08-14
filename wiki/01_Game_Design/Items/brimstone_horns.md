---
id: "brimstone_horns"
name: "Hoellenfeuer-Hoerner"
subtitle: "Ramm sie!"
kind: PASSIVE
category: MOVEMENT
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "17"
table_ref: "2.4"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Hoellenfeuer-Hoerner

> *Ramm sie!*

## Effekt

Wer mit hohem Tempo in einen Gegner laeuft, loest eine Ramm-Attacke aus: hoher Kontaktschaden und Rueckstoss.

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
| ID | `brimstone_horns` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.4 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BRIMSTONE_HORNS`, Variable `horns`)
