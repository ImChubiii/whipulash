---
id: "leer"
name: "Schwebendes Auge"
subtitle: "Es beobachtet dich alle"
kind: ACTIVE
category: UTILITY
rarity: EPIC
cooldown_seconds: 16.0
charge_rooms: 0
nr: "59"
table_ref: "1.22"
has_stat_modifiers: false
status_effects: ["confused"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Schwebendes Auge

> *Es beobachtet dich alle*

## Effekt

Beschwoert ein schwebendes Auge, das nahe Gegner regelmaessig verwirrt.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[confused]]

## Reagiert auf (ohne selbst auszuloesen)

Der Effekt dieses Items greift nur, wenn der Status bereits durch eine
ANDERE Quelle aktiv ist (`StatusX.active()`-Abfrage im Code-Pfad):

- —

## Synergien

Codeverifiziert (`ItemCatalog.ID_Y`-Referenz im aufgeloesten Effekt-Pfad
dieses Items ODER umgekehrt):

- —

## Erwaehnt in DevLogs

- [[2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef|2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `leer` |
| Kind | ACTIVE |
| Kategorie | UTILITY |
| Rarity | EPIC |
| Cooldown | 16.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.22 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_LEER`, Variable `leer`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[confused]] (Confidence: 1.0)
