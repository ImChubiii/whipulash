---
id: "protein_shake"
name: "Proteinshake aus den 90ern"
subtitle: "Abgelaufen, aber wirksam"
kind: PASSIVE
category: MELEE
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "21"
table_ref: "2.8"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Proteinshake aus den 90ern

> *Abgelaufen, aber wirksam*

## Effekt

+25 % Schaden. Deine Angriffs-Reichweite schrumpft dafuer um 15 %.

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

## Metadaten

| Feld | Wert |
|---|---|
| ID | `protein_shake` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.8 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_PROTEIN_SHAKE`, Variable `shake`)
