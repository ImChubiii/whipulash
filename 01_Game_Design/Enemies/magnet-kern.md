---
id: "magnet-kern"
display_name: "Magnet-Kern"
class_name: "MagnetCore"
tier: sandbox
role: "Stationaer · Kontrolle (Sog + Abstossungs-Schockwelle)"
base_hp: 160.0
status_effects: []
tags: [enemy, "enemy/sandbox"]
---

# Magnet-Kern

> Stationaer · Kontrolle (Sog + Abstossungs-Schockwelle)

**Jetzt im Threat-Budget:** `threat_cost = 8`, `weight = 0.5` (sehr niedrig),
`max_per_room = 1`, siehe `resources/enemies/es_magnet_core.tres` und
[[level_generator]]. Weiterhin auch einzeln ueber [[enemy_sandbox_room]]
(Debug-Teleporter) testbar. Baut wie alle sechs neuen Typen auf
[[custom_enemy_base]] statt auf `enemy_ai.gd` auf.

Balancing-Hinweis (echtes Risiko, nicht nur Kosten): der Sog kann den Spieler
in andere Gefahren ziehen (Lava-/[[lemonade]]-Pfuetzen, Explosionsradien) und
— sobald Parkour-Korridore mit Abgruenden existieren — an eine Kante ohne
Gegenwehr. Kandidat fuer eine spaetere Raum-Ausschlussregel (kein Magnet-Kern
in Raeumen/Korridoren mit `extra_void_pits`), aktuell noch nicht umgesetzt.

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

- [[2026-08-10_5d04371_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]

## Quelle

`scripts/enemies/magnet_core.gd` (Modul-Scope-`var`-Deklarationen, `_configure()`)
