---
id: "walkman"
name: "Walkman (kaputt)"
subtitle: "Band verheddert, Bass intakt"
kind: ACTIVE
category: DEFENSE
rarity: LEGENDARY
cooldown_seconds: 12.0
charge_rooms: 0
nr: "7"
table_ref: "1.7"
has_stat_modifiers: false
status_effects: ["confused"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/active", "rarity/legendary"]
---

# Walkman (kaputt)

> *Band verheddert, Bass intakt*

## Effekt

Eine Schockwelle zerstoert alle Projektile und stoesst Gegner zurueck. Getroffene sind 4 s lang voellig orientierungslos.

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

- [[2026-08-04_ec5e457_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef|2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `walkman` |
| Kind | ACTIVE |
| Kategorie | DEFENSE |
| Rarity | LEGENDARY |
| Cooldown | 12.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.7 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_WALKMAN`, Variable `walkman`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[confused]] (Confidence: 1.0)
