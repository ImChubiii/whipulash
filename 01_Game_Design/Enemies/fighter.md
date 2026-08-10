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
tags: [enemy]
---

# Fighter

## Mechanik

Traeger Nahkaempfer mit hoher Reichweite (`is_heavy = true`, Knockback-resistent). Nutzt Sprung- und Ledge-Checks, um Huerden im Level zu ueberwinden (`can_jump_across_ledges`).

**Stun-Lock-Schutz (global, [[player_base]]):** zweistufig. 1) Diminishing Returns — jeder weitere Stun innerhalb des Ketten-Zeitfensters wirkt nur noch `stun_diminish_factor` so lang wie der vorherige. 2) Immunitaetsfenster — nach `stun_max_chain` Stuns in Folge greift eine kurze Stun-Immunitaet, bevor die Kette von vorn beginnt.

## Balancing (Threat-Budget-System)

| Wert | Betrag |
|---|---|
| Threat-Cost | 3 |
| Basis-HP | 30.0 |
| Move-Speed | 8.0 (Varianz 0.0) |
| Angriffsschaden | 30.0 |
| Angriffs-Cooldown | 1.8 s |
| Erkennungsreichweite | 90.0 |
| Ziehgewicht | 2.0 |
| Max. pro Raum | 15 |
| Garantierte Anzahl | 0 |
| Mindest-Raumhoehe | 12.0 |

Statt fester Spawn-Listen zieht der `LevelGenerator` Gegner ueber ein
**Threat-Budget** pro Raum: viele billige Stinger ODER wenige teure Fighter/
Colossi ergeben vergleichbare Schwierigkeit bei abwechslungsreicher
Zusammensetzung. Siehe [[level_generator]].

## Status-Effekt-Interaktion (enemy_ai.gd, gilt fuer alle Gegner)

- [[acid]] — Damage-over-Time (`DOT_EFFECT_IDS`)
- [[burn]] — Damage-over-Time (`DOT_EFFECT_IDS`)
- [[silenced]] — sperrt Angriffe (`is_attack_locked()`)
- [[stun]] — sperrt Angriffe (`is_attack_locked()`)
- [[rooted]] — sperrt bewusst NUR die Bewegung, nicht den Angriff (Abgrenzung zu `stun`)



## Quelle

`scenes/enemies/dummy.tscn` (Root-Node-Properties), `resources/enemies/es_fighter.tres`
