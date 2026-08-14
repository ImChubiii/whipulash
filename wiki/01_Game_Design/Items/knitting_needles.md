---
id: "knitting_needles"
name: "Omas Stricknadeln"
subtitle: "Zwei rechts, eine durch"
kind: PASSIVE
category: MELEE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "35"
table_ref: "2.22"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: ["rusty_cleaver"]
tags: [item, "item/passive", "rarity/rare"]
---

# Omas Stricknadeln

> *Zwei rechts, eine durch*

## Effekt

+10 % Angriffsgeschwindigkeit, kritische Treffer ignorieren Ruestung. Die Blutungs-Chance im Nahkampf steigt von 30 % auf 50 %.

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

- [[rusty_cleaver]] — *Rostiges Beil*

## Erwaehnt in DevLogs

- —

## Metadaten

| Feld | Wert |
|---|---|
| ID | `knitting_needles` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.22 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_KNITTING_NEEDLES`, Variable `needles`)

## 🧠 Semantische Verbindungen (Graphify)
- **conceptually_related_to**: [[rusty_cleaver]] (Confidence: 1.0)
