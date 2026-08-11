---
id: "plasmastrahl-bot"
display_name: "Plasmastrahl-Bot"
class_name: "PlasmaBeamBot"
tier: sandbox
role: "Flieger · Fernkampf (Flaechenlaser), kein Pflicht-Kill"
base_hp: 65.0
status_effects: []
tags: [enemy, "enemy/sandbox"]
---

# Plasmastrahl-Bot

> Flieger · Fernkampf (Flaechenlaser), kein Pflicht-Kill

**Jetzt im Threat-Budget:** `threat_cost = 10`, `weight = 1.0` (bewusst niedrig
statt mittel gesetzt — dazu unten mehr), `max_per_room = 1`, siehe
`resources/enemies/es_plasma_beam_bot.tres` und [[level_generator]].
Weiterhin auch einzeln ueber [[enemy_sandbox_room]] (Debug-Teleporter)
testbar. Baut wie alle sechs neuen Typen auf [[custom_enemy_base]] statt auf
`enemy_ai.gd` auf.

Balancing-Hinweis: der urspruenglich vorgeschlagene Sichtblockade-Effekt
("man sieht den Abgrund gar nicht mehr") wurde bewusst als starke
Vignette/Nebel statt Komplett-Blackout umgesetzt — ein voller Blackout neben
einem Abgrund waere ein Tod ohne Gegenspiel, kein faires Risiko. Weight aus
demselben Grund von "mittel" auf "niedrig" reduziert, damit die seltenste/
gefaehrlichste Mechanik auch tatsaechlich selten bleibt.

## Mechanik

Driftet langsam ueber dem Schlachtfeld, laedt sichtbar auf (`charge_time`) und zieht danach einen [[burn]]-Laser als wandernde Linie ueber den Boden (`beam_duration`), zentriert auf die Spielerposition beim Feuern - wer nicht seitlich ausweicht, sammelt mehrere Burn-Ticks. Wie [[schild-drohne]] kein Pflicht-Kill fuer den Raum-Clear und despawnt von selbst, sobald der Raum sonst leer ist.

## Balancing (roh aus `scripts/enemies/plasma_beam_bot.gd`)

| Wert | Betrag |
|---|---|
| Basis-HP | 65 |
| Schwebehoehe | 8 |
| Anflug-Geschwindigkeit | 2 |
| Aufladezeit (s) | 1.1 |
| Strahl-Dauer (s) | 1.4 |
| Strahlbreite | 2 |
| Strahl-Sweep-Laenge | 14 |
| Cooldown nach Schuss (s) | 3.2 |
| Erkennungsreichweite | 40 |

## Status-Effekte (ausgeloest)

- — (reiner Schaden/Knockback, kein Status-Effekt)

## Erwaehnt in DevLogs

- [[2026-08-10_5d04371_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]

## Quelle

`scripts/enemies/plasma_beam_bot.gd` (Modul-Scope-`var`-Deklarationen, `_configure()`)
