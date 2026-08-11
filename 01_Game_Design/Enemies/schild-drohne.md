---
id: "schild-drohne"
display_name: "Schild-Drohne"
class_name: "ShieldDrone"
tier: sandbox
role: "Flieger · Support, kein Pflicht-Kill (Schild-Buff)"
base_hp: 45.0
status_effects: ["shield"]
tags: [enemy, "enemy/sandbox"]
---

# Schild-Drohne

> Flieger · Support, kein Pflicht-Kill (Schild-Buff)

**Jetzt im Threat-Budget:** `threat_cost = 4`, `weight = 2.0`, `max_per_room = 2`
(bewusst auf 2 statt 3 gedeckelt), siehe `resources/enemies/es_shield_drone.tres`
und [[level_generator]]. Weiterhin auch einzeln ueber
[[enemy_sandbox_room]] (Debug-Teleporter) testbar. Baut wie alle sechs neuen
Typen auf [[custom_enemy_base]] statt auf `enemy_ai.gd` auf.

Balancing-Hinweis: der Kostenpunkt bildet nur die eigene HP/Praesenz ab, NICHT
den Multiplikator-Effekt auf bis zu drei geschildete Verbuendete — eine
zufaellige Paarung mit teuren Einheiten (Colossus) kann den Raum effektiv
zaeher machen, als das Budget zeigt. Deshalb `max_per_room` niedrig gehalten.

## Mechanik

Greift nie direkt an. Schwebt in einer weichen Lissajous-Bahn und verbindet sich per Strahl mit bis zu `MAX_SHIELDED` (3) anderen Gegnern aus der Gruppe "enemies" (naechste zuerst, bereits verbundene werden bevorzugt beibehalten, damit der Strahl nicht bei jedem Rescan springt). Jeder Verbundene bekommt per Strahl-Refresh alle `SHIELD_REFRESH_INTERVAL` (0.5s) den [[shield]]-Status erneuert. Reiner Support-Typ - muss fuer den Raum-Clear NICHT sterben (siehe `_despawn_if_room_clear()`); verschwindet von selbst, sobald nur noch fliegende Support-Typen (sich selbst eingeschlossen) uebrig sind.

## Balancing (roh aus `scripts/enemies/shield_drone.gd`)

| Wert | Betrag |
|---|---|
| Basis-HP | 45 |
| Schwebehoehe | 9 |
| Schwebe-Bahnradius | 3 |
| Schwebe-Winkelgeschwindigkeit | 0.5 |
| Strahl-Verbindungsreichweite | 22 |

## Status-Effekte (ausgeloest)

- [[shield]]

## Erwaehnt in DevLogs

- [[2026-08-10_5d04371_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]

## Quelle

`scripts/enemies/shield_drone.gd` (Modul-Scope-`var`-Deklarationen, `_configure()`)
