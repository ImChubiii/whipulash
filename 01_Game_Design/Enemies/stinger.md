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
tags: [enemy]
---

# Stinger

## Mechanik

Schneller Flankierer mit Zigzag-Verfolgung (`zigzag_enabled = true`, `zigzag_angle_degrees = 58`): naehert sich in weich interpolierten Schlangenlinien statt geradem Kurs an, inklusive sichtbarem Lean-Telegraphing beim Kurvenwechsel statt hartem Snap. `focus_loss_enabled` laesst ihn gelegentlich das Ziel kurz verlieren und umherwandern, bevor er erneut andockt.

**Stun-Lock-Schutz (global, [[player_base]]):** zweistufig. 1) Diminishing Returns — jeder weitere Stun innerhalb des Ketten-Zeitfensters wirkt nur noch `stun_diminish_factor` so lang wie der vorherige. 2) Immunitaetsfenster — nach `stun_max_chain` Stuns in Folge greift eine kurze Stun-Immunitaet, bevor die Kette von vorn beginnt.

## Balancing (Threat-Budget-System)

| Wert | Betrag |
|---|---|
| Threat-Cost | 1 |
| Basis-HP | 25.0 |
| Move-Speed | 15.0 (Varianz 0.16) |
| Angriffsschaden | 6.0 |
| Angriffs-Cooldown | 1.4 s |
| Erkennungsreichweite | 100.0 |
| Ziehgewicht | 3.0 |
| Max. pro Raum | 36 |
| Garantierte Anzahl | 0 |
| Mindest-Raumhoehe | 0.0 |

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



## Verwandt

Basiert auf `enemy_ai.gd` (Chase-Attack-State-Machine, importiertes
Roboter-Mesh). Seit Phase 5 existiert daneben ein zweiter, unabhaengiger
Gegner-Unterbau — [[custom_enemy_base]] — fuer stationaere/fliegende
Spezialtypen ohne Laufanimation. Siehe MOC_Enemies fuer den vollstaendigen
Ueberblick beider Systeme.

## Quelle

`scenes/scout_dummy.tscn` (Root-Node-Properties), `resources/enemies/es_stinger.tres`
