---
id: "nanoswarm"
name: "Nano-Schwarm"
subtitle: "Unsichtbar, bis es zu spaet ist"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 10.0
charge_rooms: 0
nr: "80"
table_ref: "1.42"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Nano-Schwarm

> *Unsichtbar, bis es zu spaet ist*

## Effekt

Legt eine unsichtbare Mine ab, die sich nach kurzer Zeit scharf macht und beim naechsten Gegner in der Naehe explodiert.

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

- [[2026-08-10_43a32e9_verkleinere_hitboxenmeshes_bei_turret_auge_koeder_|2026-08-10 — Verkleinere Hitboxen/Meshes bei Turret, Auge, Koeder, Nanoswarm; fixe Lockdown-Treffer auf Telegraph-Position]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `nanoswarm` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 10.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.42 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_NANOSWARM`, Variable `nanoswarm`)
