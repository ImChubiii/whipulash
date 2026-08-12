---
id: "colossus"
display_name: "Colossus"
threat_cost: 10
base_hp: 400.0
move_speed: 5.5
speed_variance: 0.08
attack_damage: 70.0
attack_cooldown: 1.5
detection_range: 200.0
is_heavy: true
is_large_enemy: true
zigzag_enabled: false
weight: 1.0
max_per_room: 3
guaranteed_count: 3
tier: levelgen
tags: [enemy, role/melee, role/heavy, tier/levelgen]
---

# Colossus

> *Ein massiver, vernichtender Boss-Gegner, der Unmengen an Treffern einsteckt und bei unvorsichtigem Nahkampf kurzen Prozess macht.*

## Übersicht
| Feld | Wert |
|---|---|
| Typ | Nahkämpfer |
| Gefahr | Sehr Hoch |
| HP | 400.0 |
| Schaden | 70.0 |
| Geschwindigkeit | 5.5 |
| Threat-Cost | 10 |

## Verhalten
Diese Boss-Klasse ist ein absolutes Schwergewicht und komplett immun gegen Knockback. Er sinkt nicht in Lava, sondern bobbt an der Oberflaeche. Sollte er je steckenbleiben, befreit er sich automatisch durch eine Unstuck-Routine mit einem starken Impuls.

## Tipps & Schwachstellen
- Bleibe staendig in Bewegung! Mit 70 Schaden pro Treffer ist direkter Nahkampf extrem toedlich.
- Sein hoher HP-Pool macht Schaden-über-Zeit-Effekte wie Brand oder Säure besonders wertvoll.
- Er ist langsam, also kitzel ihn aus der Distanz und achte darauf, nicht in Sackgassen zu geraten.

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
