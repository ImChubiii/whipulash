---
id: "fighter"
display_name: "Fighter"
threat_cost: 3
base_hp: 30.0
move_speed: 8.0
speed_variance: 0.0
attack_damage: 30.0
attack_cooldown: 1.8
detection_range: 90.0
is_heavy: true
is_large_enemy: false
zigzag_enabled: false
weight: 2.0
max_per_room: 15
guaranteed_count: 0
tier: levelgen
tags: [enemy, role/melee, tier/levelgen]
---

# Fighter

> *Ein traeger, aber schwer gepanzerter Nahkämpfer, der mit grosser Reichweite und Knockback-Resistenz ordentlich Druck macht.*

## Übersicht
| Feld | Wert |
|---|---|
| Typ | Nahkämpfer |
| Gefahr | Mittel |
| HP | 30.0 |
| Schaden | 30.0 |
| Geschwindigkeit | 8.0 |
| Threat-Cost | 3 |

## Verhalten
Der Fighter ist ein massiver Nahkämpfer, der dank `is_heavy=true` gegen Knockbacks resistent ist. Er nutzt Sprung- und Ledge-Checks, um Hindernisse im Level gnadenlos zu ueberwinden. Zudem greift bei ihm ein Stun-Lock-Schutz, der ihn immun gegen endloses Betaeuben macht.

## Tipps & Schwachstellen
- Halte Abstand und lass dich nicht in Ecken draengen, da seine Nahkampfreichweite hoch ist.
- Da er Knockback-resistent ist, solltest du auf Schaden-über-Zeit-Effekte oder starke Einzelangriffe setzen.
- Nutze das kurze Stun-Fenster effektiv, bevor seine Immunitaet greift.

## Wirksame Status-Effekte
| Status | Wirkung |
|---|---|
| [[burn\|Brand]] | Schaden über Zeit |
| [[acid\|Säure]] | Schaden über Zeit |
| [[stun\|Betäubung]] | Handlungsunfaehig (auf Diminishing Returns achten) |
| [[silenced\|Stille]] | Sperrt Angriffe |
| [[rooted\|Verwurzelung]]| Sperrt Bewegung |

## Verwandt
- [[_MOC_Enemies|Alle Gegner]] . [[custom_enemy_base|Basisklasse]] . [[enemy_models|Modelle]]
