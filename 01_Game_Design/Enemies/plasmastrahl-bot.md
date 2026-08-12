---
id: "plasmastrahl-bot"
display_name: "Plasmastrahl-Bot"
class_name: "PlasmaBeamBot"
alternative_names: 
tier: sandbox
role: "Flieger · Fernkampf (Flaechenlaser), kein Pflicht-Kill"
base_hp: 65.0
status_effects: []
tags: [enemy, "enemy/sandbox"]
---

# Plasmastrahl-Bot

> Flieger · Fernkampf (Flaechenlaser), kein Pflicht-Kill

**Sandbox-Prototyp:** spawnt Stand jetzt ausschliesslich im
[[enemy_sandbox_room]] (Debug-Teleporter), noch nicht Teil der
[[level_generator]]-Threat-Budget-Tabellen — zaehlt also noch nicht zum
Raum-Clear und hat keinen `threat_cost`. Baut wie alle sechs neuen Typen auf
[[custom_enemy_base]] statt auf `enemy_ai.gd` auf.

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

## 🧠 Semantische Verbindungen (Graphify)
- **implements**: [[enemy_sandbox_room]] (Confidence: 1.0)
