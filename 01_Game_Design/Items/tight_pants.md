---
id: "tight_pants"
name: "Omas Enge Hosen"
subtitle: "Sitzt wie angegossen. Zu gut."
kind: PASSIVE
category: MOVEMENT
rarity: UNCOMMON
cooldown_seconds: 0.0
charge_rooms: 0
nr: "22"
table_ref: "2.9"
has_stat_modifiers: true
status_effects: []
reacts_to_status: []
synergizes_with: []
tags: [item, "item/passive", "rarity/uncommon"]
---

# Omas Enge Hosen

> *Sitzt wie angegossen. Zu gut.*

## Effekt

+20 % Tempo. Vorbeirennen oder ein abrupter Richtungswechsel loesen einen Tritt aus: halber Schaden und starker Rueckstoss (~4 m).

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
| ID | `tight_pants` |
| Kind | PASSIVE |
| Kategorie | MOVEMENT |
| Rarity | UNCOMMON |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.9 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_TIGHT_PANTS`, Variable `pants`)
