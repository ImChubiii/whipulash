---
id: "saeure-sprinkler"
display_name: "Saeure-Sprinkler"
class_name: "AcidSprinkler"
tier: sandbox
role: "Stationaer · Fernkampf (Gebiets-DoT ueber Pfuetzen)"
base_hp: 70.0
status_effects: []
tags: [enemy, "enemy/sandbox"]
---

# Saeure-Sprinkler

> Stationaer · Fernkampf (Gebiets-DoT ueber Pfuetzen)

**Jetzt im Threat-Budget:** `threat_cost = 5`, `weight = 1.0` (niedrig),
`max_per_room = 3`, siehe `resources/enemies/es_acid_sprinkler.tres` und
[[level_generator]]. Weiterhin auch einzeln ueber [[enemy_sandbox_room]]
(Debug-Teleporter) testbar. Baut wie alle sechs neuen Typen auf
[[custom_enemy_base]] statt auf `enemy_ai.gd` auf.

Balancing-Hinweis: Pfuetzen sind additiv mit anderer Flaechenkontrolle (Moerser-
Krater, Divebomber-Truemmer) — in Kombination kann ein kleiner Raum spuerbar
an begehbarer Flaeche verlieren, auch wenn jeder Typ einzeln fair gedeckelt ist.

## Mechanik

Bewegt sich nie. Spuckt alle `fire_interval` Sekunden ein Saeure-Geschoss auf die aktuelle Spielerposition; am Einschlagsort bleibt eine tickende [[acid]]-Pfuetze liegen (gleiches Area3D-Prinzip wie [[lemonade|Lemonade]] aus `item_behaviours.gd`). NICHT das Geschoss selbst verursacht den Effekt, sondern das Stehen in der Pfuetze - mehrere Pfuetzen ueberlappen sich mit der Zeit zu einem Bereich, den der Spieler aktiv meiden muss.

## Balancing (roh aus `scripts/enemies/acid_sprinkler.gd`)

| Wert | Betrag |
|---|---|
| Basis-HP | 70 |
| Feuerintervall (s) | 2.6 |
| Flugzeit Geschoss (s) | 0.7 |
| Pfuetzenradius | 2.6 |
| Pfuetzen-Lebensdauer (s) | 6 |
| Erkennungsreichweite | 40 |

## Status-Effekte (ausgeloest)

- — (reiner Schaden/Knockback, kein Status-Effekt)

## Erwaehnt in DevLogs

- [[2026-08-10_5d04371_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]

## Quelle

`scripts/enemies/acid_sprinkler.gd` (Modul-Scope-`var`-Deklarationen, `_configure()`)
