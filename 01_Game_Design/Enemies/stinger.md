---
id: "stinger"
display_name: "Stinger"
threat_cost: 1
base_hp: 25.0
move_speed: 15.0
speed_variance: 0.16
attack_damage: 6.0
attack_cooldown: 1.4
detection_range: 100.0
is_heavy: false
is_large_enemy: false
zigzag_enabled: true
weight: 3.0
max_per_room: 36
guaranteed_count: 0
tier: levelgen
tags: [enemy, role/melee, tier/levelgen]
---

# Stinger

> *Ein flinker, unberechenbarer Schwarm-Gegner, der dir in Schlangenlinien ausweicht und in der Masse ueberwaeltigt.*

## Übersicht
| Feld | Wert |
|---|---|
| Typ | Nahkämpfer |
| Gefahr | Niedrig |
| HP | 25.0 |
| Schaden | 6.0 |
| Geschwindigkeit | 15.0 |
| Threat-Cost | 1 |

## Verhalten
Der Stinger ist ein schneller Flankierer, der sich mit aktivierter Zigzag-Verfolgung in unvorhersehbaren Kurven annaehert. Gelegentlich verliert er dich aus den Augen und wandert umher, bevor er erneut andockt. Auch er besitzt den systemweiten Stun-Lock-Schutz.

## Tipps & Schwachstellen
- Ziele sorgfaeltig oder nutze Flaechenschaden, da seine Schlangenlinien schwer vorauszusehen sind.
- Nutze die Momente, in denen er das Ziel verliert, um ihn gefahrlos auszuschalten.
- Lass dich nicht einkreisen – in grosser Zahl (bis zu 36 pro Raum!) wird ihr geringer Schaden gefährlich.

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
