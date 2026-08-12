---
id: "moerser-bot"
display_name: "Moerser-Bot"
class_name: "MortarBot"
alternative_names: 
tier: sandbox
role: "Stationaer · Fernkampf (Wurfparabel, Flaechenschaden)"
base_hp: 90.0
status_effects: []
tags: [enemy, "enemy/sandbox"]
---

# Moerser-Bot

> Stationaer · Fernkampf (Wurfparabel, Flaechenschaden)

**Sandbox-Prototyp:** spawnt Stand jetzt ausschliesslich im
[[enemy_sandbox_room]] (Debug-Teleporter), noch nicht Teil der
[[level_generator]]-Threat-Budget-Tabellen — zaehlt also noch nicht zum
Raum-Clear und hat keinen `threat_cost`. Baut wie alle sechs neuen Typen auf
[[custom_enemy_base]] statt auf `enemy_ai.gd` auf.

## Mechanik

Bewegt sich nie. Feuert alle `fire_interval` Sekunden eine zweiphasige Wurfparabel (Aufstieg dann Fall) auf die AKTUELLE Spielerposition zum Schusszeitpunkt, bodenprojiziert. Der rote Telegraph-Ring erscheint sofort schwach und wird waehrend der gesamten Flugzeit kraeftiger, bleibt aber exakt an der urspruenglichen Zielposition stehen - Schaden liest beim Einschlag die TELEGRAPH-Position, nicht die aktuelle Spielerposition (gleiche Regel wie Orbitalschlag/[[lockdown]], siehe dortiger Bugfix in item_behaviours.gd).

## Balancing (roh aus `scripts/enemies/mortar_bot.gd`)

| Wert | Betrag |
|---|---|
| Basis-HP | 90 |
| Feuerintervall (s) | 3.6 |
| Flugzeit Geschoss (s) | 1.3 |
| Wurfhoehe (Bogen) | 4 |
| Explosionsradius | 4.2 |
| Schaden | 22 |
| Erkennungsreichweite | 45 |

## Status-Effekte (ausgeloest)

- — (reiner Schaden/Knockback, kein Status-Effekt)

## Erwaehnt in DevLogs

- [[2026-08-10_5d04371_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]

## Quelle

`scripts/enemies/mortar_bot.gd` (Modul-Scope-`var`-Deklarationen, `_configure()`)
