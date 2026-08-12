---
id: "fighter"
display_name: "Fighter"
alternative_names: 
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



## Verwandt

Basiert auf `enemy_ai.gd` (Chase-Attack-State-Machine, importiertes
Roboter-Mesh). Seit Phase 5 existiert daneben ein zweiter, unabhaengiger
Gegner-Unterbau — [[custom_enemy_base]] — fuer stationaere/fliegende
Spezialtypen ohne Laufanimation. Siehe [[_MOC_Enemies]] fuer den vollstaendigen
Ueberblick beider Systeme.

## Erwaehnt in DevLogs

- [[2026-08-10_bcd3e81_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]
- [[2026-07-27_f88829f_feat_treasure_room_items_hud_overhaul_balancing_mu|2026-07-27 — feat: Treasure room items, HUD overhaul, balancing, multiple bug fixes]]
- [[2026-07-26_61765de_feat_combat-tuning_hud-overhaul_anti-baiting_sieg-|2026-07-26 — feat: Combat-Tuning, HUD-Overhaul, Anti-Baiting, Sieg-Trophäe, Menü-Fixes, Türsystem-Debugging]]
- [[2026-07-25_905d144_feat_level-generation-polish_minimap-overhaul_haza|2026-07-25 — feat: Level-Generation-Polish, Minimap-Overhaul, Hazard/Door-Fixes, Atmosphäre]]
- [[2026-07-25_170eb45_featlevel-gen_threat-budget_enemy_mix_lava_hazards|2026-07-25 — feat(level-gen): threat-budget enemy mix, lava hazards, elevation, minimap overlay]]
- [[2026-07-21_0d3ad30_fix_enemy_movement_freeze_and_enhance_ledge_detect|2026-07-21 — Fix enemy movement freeze and enhance ledge detection]]
- [[2026-07-25_66b3f05_featlevel-gen_threat-budget_enemy_mix_lava_hazards|2026-07-25 — feat(level-gen): threat-budget enemy mix, lava hazards, elevation, minimap overlay]]
- [[2026-07-21_2135fc5_fix_enemy_movement_freeze_and_enhance_ledge_detect|2026-07-21 — Fix enemy movement freeze and enhance ledge detection]]

## Quelle

`scenes/enemies/dummy.tscn` (Root-Node-Properties), `resources/enemies/es_fighter.tres`

## 🧠 Semantische Verbindungen (Graphify)
- **referenced_by (references)**: [[level_generator]] (Confidence: 1.0)
