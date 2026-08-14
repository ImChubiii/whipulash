---
id: "turret"
name: "Geschuetzturm"
subtitle: "Automatische Unterstuetzung"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 20.0
charge_rooms: 0
nr: "82"
table_ref: "1.44"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Geschuetzturm

> *Automatische Unterstuetzung*

## Effekt

Stellt einen freundlichen Geschuetzturm auf, der automatisch auf nahe Gegner feuert.

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
| ID | `turret` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 20.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.44 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_TURRET`, Variable `turret_item`)
