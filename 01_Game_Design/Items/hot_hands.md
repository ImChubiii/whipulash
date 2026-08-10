---
id: "hot_hands"
name: "Heisse Haende"
subtitle: "Direkt aus dem Ofen"
kind: ACTIVE
category: UTILITY
rarity: RARE
cooldown_seconds: 6.0
charge_rooms: 0
nr: "54"
table_ref: "1.17"
has_stat_modifiers: false
status_effects: ["burn"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/rare"]
---

# Heisse Haende

> *Direkt aus dem Ofen*

## Effekt

Schleudert einen Feuerball, der bei Einschlag sofort Schaden macht und Gegner in Brand setzt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[burn]]

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
| ID | `hot_hands` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | RARE |
| Cooldown | 6.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.17 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_HOT_HANDS`, Variable `hot_hands`)
