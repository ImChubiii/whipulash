---
id: "orbital_strike"
name: "Orbitalschlag"
subtitle: "Einschlag in 3... 2... 1..."
kind: ACTIVE
category: UTILITY
rarity: LEGENDARY
cooldown_seconds: 22.0
charge_rooms: 0
nr: "74"
table_ref: "1.36"
has_stat_modifiers: false
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/legendary"]
---

# Orbitalschlag

> *Einschlag in 3... 2... 1...*

## Effekt

Markiert die Stelle vor dir - nach kurzer Verzoegerung schlaegt ein gewaltiger Strahl ein und verwuestet den Bereich.

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

- [[2026-08-10_f4f2185_verkleinere_hitboxenmeshes_bei_turret_auge_koeder_|2026-08-10 — Verkleinere Hitboxen/Meshes bei Turret, Auge, Koeder, Nanoswarm; fixe Lockdown-Treffer auf Telegraph-Position]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `orbital_strike` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | LEGENDARY |
| Cooldown | 22.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.36 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_ORBITAL_STRIKE`, Variable `orbital_strike`)
