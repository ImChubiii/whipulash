---
id: "modem_56k"
name: "Altes Modulations-Modem"
subtitle: "Kshhh-pshhh-diiing"
kind: PASSIVE
category: MELEE
rarity: EPIC
cooldown_seconds: 0.0
charge_rooms: 0
nr: "29"
table_ref: "2.16"
has_stat_modifiers: false
status_effects: ["silenced", "stun"]
tags: [item, "item/passive", "rarity/epic"]
---

# Altes Modulations-Modem

> *Kshhh-pshhh-diiing*

## Effekt

Jeder 10. Schlag sendet eine Einwahl-Welle: Gegner koennen 1 s lang keine Spezialangriffe starten. Betaeubte Gegner nehmen kritischen Zusatzschaden.

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

- [[silenced]]
- [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| ID | `modem_56k` |
| Kind | PASSIVE |
| Kategorie | MELEE |
| Rarity | EPIC |
| Cooldown | — |
| Charge (Raeume) | — |
| Design-Doc-Ref | 2.16 |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_MODEM_56K`, Variable `modem`)
