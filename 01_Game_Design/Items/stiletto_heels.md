---
id: "stiletto_heels"
name: "Mamas Stoeckelschuhe"
subtitle: "Klack. Klack. Zisch."
kind: PASSIVE
category: MOVEMENT
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "40"
table_ref: "2.27"
has_stat_modifiers: false
status_effects: ["acid", "slow", "stun"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/epic"]
---

# Mamas Stoeckelschuhe

> *Klack. Klack. Zisch.*

## Effekt

Beim Rennen bleiben 2 s lange Saeure-Lachen zurueck. Gegner darin nehmen Saeureschaden und werden langsamer. Jeder 3. Schritt loest eine Schockwelle aus, die nahe Gegner kurz straucheln laesst.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[acid]]
- [[slow]]
- [[stun]]

## Reagiert auf (ohne selbst auszuloesen)

Der Effekt dieses Items greift nur, wenn der Status bereits durch eine
ANDERE Quelle aktiv ist (`StatusX.active()`-Abfrage im Code-Pfad):

- —

## Synergien

Codeverifiziert (`ItemCatalog.ID_Y`-Referenz im aufgeloesten Effekt-Pfad
dieses Items ODER umgekehrt):

- —

## Erwaehnt in DevLogs

- [[2026-08-04_c63b397_featitems_ai_ui_levelgen_party-revive_item-reworks|2026-08-04 — feat(items, ai, ui, levelgen): Party-Revive, Item-Reworks, Boss-HP-Split & Lava-Buoyancy]]
- [[2026-08-04_5d63fe2_featitemscombatlevelgenui_ouija-board_item-reworks|2026-08-04 — feat(items,combat,levelgen,ui): Ouija-Board, Item-Reworks, Last-Stand, Boss-HP-Balken, diverse Bugfixes]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `stiletto_heels` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.27 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_STILETTO_HEELS`, Variable `heels`)

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[acid]] (Confidence: 1.0)
- **calls**: [[slow]] (Confidence: 1.0)
- **calls**: [[stun]] (Confidence: 1.0)
