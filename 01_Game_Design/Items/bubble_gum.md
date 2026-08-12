---
id: "bubble_gum"
name: "Riesige Kaugummiblase"
subtitle: "Groesser als der Kopf"
kind: PASSIVE
category: DEFENSE
rarity: RARE
cooldown_seconds: 0.0
charge_rooms: 0
nr: "49"
table_ref: "2.36"
has_stat_modifiers: false
status_effects: ["slow"]
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/rare"]
---

# Riesige Kaugummiblase

> *Groesser als der Kopf*

## Effekt

Beim Stillstehen baut sich eine Blase auf. Nimmst du Schaden, platzt sie und verlangsamt Gegner ringsum massiv.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[slow]]

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
| ID | `bubble_gum` |
| Kind | PASSIVE |
| Kategorie | DEFENSE |
| Rarity | RARE |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.36 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_BUBBLE_GUM`, Variable `bubble`)
