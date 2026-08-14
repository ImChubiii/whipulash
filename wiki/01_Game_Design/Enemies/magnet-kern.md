---
id: "magnet-kern"
display_name: "Magnet-Kern"
class_name: "MagnetCore"
alternative_names: 
tier: sandbox
role: "Stationaer · Kontrolle (Sog + Abstossungs-Schockwelle)"
base_hp: 160.0
status_effects: []
tags: [enemy, "enemy/sandbox"]
---

# Magnet-Kern

> Stationaer · Kontrolle (Sog + Abstossungs-Schockwelle)

**Sandbox-Prototyp:** spawnt Stand jetzt ausschliesslich im
[[enemy_sandbox_room]] (Debug-Teleporter), noch nicht Teil der
[[level_generator]]-Threat-Budget-Tabellen — zaehlt also noch nicht zum
Raum-Clear und hat keinen `threat_cost`. Baut wie alle sechs neuen Typen auf
[[custom_enemy_base]] statt auf `enemy_ai.gd` auf.

## Mechanik

Bewegt sich nie, schiesst nicht. Zieht den Spieler und freiliegende Pickups kontinuierlich per Einzelimpulsen (`PULL_TICK_INTERVAL`, bewusst gepulst statt Dauerkraft: player_base.gd baut Knockback-Impulse per `knockback_friction` ab, ein Dauer-Impuls pro Frame ginge im Reibungs-Rauschen unter) zu sich heran. Kommt der Spieler unter `too_close_radius`, feuert der Kern stattdessen eine Schockwelle mit massivem Abstossungs-Knockback - bestraft also sowohl Abstand halten (Sog) als auch draufhalten (Schockwelle).

## Balancing (roh aus `scripts/enemies/magnet_core.gd`)

| Wert | Betrag |
|---|---|
| Basis-HP | 160 |
| Sog-Reichweite | 20 |
| Schockwellen-Ausloeseradius | 7 |
| Schockwellen-Kraft | 30 |
| Schockwellen-Cooldown (s) | 1.6 |
| Pickup-Sog-Geschwindigkeit | 7 |

## Status-Effekte (ausgeloest)

- — (reiner Schaden/Knockback, kein Status-Effekt)

## Erwaehnt in DevLogs

- [[2026-08-10_bcd3e81_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]

## Quelle

`scripts/enemies/magnet_core.gd` (Modul-Scope-`var`-Deklarationen, `_configure()`)

## 🧠 Semantische Verbindungen (Graphify)
- **implements**: [[enemy_sandbox_room]] (Confidence: 1.0)
