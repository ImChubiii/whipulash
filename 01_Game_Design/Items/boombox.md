---
id: "boombox"
name: "Alte Ghettoblaster-Box"
subtitle: "Bass, der Waende einreisst"
kind: ACTIVE
category: DEFENSE
rarity: EPIC
cooldown_seconds: 9.0
charge_rooms: 0
nr: "10"
table_ref: "1.10"
has_stat_modifiers: false
status_effects: ["silenced"]
reacts_to_status: ["silenced"]
synergizes_with: []
tags: [item, "item/active", "rarity/epic"]
---

# Alte Ghettoblaster-Box

> *Bass, der Waende einreisst*

## Effekt

Sendet eine 4 s lange Basswelle: zerstoert Projektile und schaltet Gegner in Reichweite stumm. Stumme Gegner erleiden +30 % Nahkampfschaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]

## Reagiert auf (ohne selbst auszuloesen)

Der Effekt dieses Items greift nur, wenn der Status bereits durch eine
ANDERE Quelle aktiv ist (`StatusX.active()`-Abfrage im Code-Pfad):

- [[silenced]] — setzt den Effekt voraus, loest ihn aber nicht selbst aus

## Synergien

Codeverifiziert (`ItemCatalog.ID_Y`-Referenz im aufgeloesten Effekt-Pfad
dieses Items ODER umgekehrt):

- —

## Erwaehnt in DevLogs

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `boombox` |
| Kind | ACTIVE |
| Kategorie | DEFENSE |
| Rarity | EPIC |
| Cooldown | 9.0 s |
| Charge (Raeume) | — |
| Design-Doc-Ref | 1.10 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BOOMBOX`, Variable `boombox`)

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[boombox]] (Confidence: 1.0)
