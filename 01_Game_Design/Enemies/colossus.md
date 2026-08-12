---
id: "colossus"
display_name: "Colossus"
alternative_names: 
threat_cost: 15
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
tags: [enemy]
---

# Colossus

## Mechanik

Boss-Klasse Schwergewicht (`is_large_enemy = true`, `is_heavy = true`, kein Sprung). Besitzt Lava-Buoyancy ueber `set_buoyancy()`: statt im Lavabecken komplett zu versinken, bobbt er auf ca. 2/3 seiner Koerperhoehe. Alle Gegnertypen teilen ausserdem eine Auto-Unstuck-Routine (`unstuck_enabled`), die nach `unstuck_stationary_time` Sekunden ohne Fortschritt einen Impuls nach oben/seitlich ausloest.

**Stun-Lock-Schutz (global, [[player_base]]):** zweistufig. 1) Diminishing Returns — jeder weitere Stun innerhalb des Ketten-Zeitfensters wirkt nur noch `stun_diminish_factor` so lang wie der vorherige. 2) Immunitaetsfenster — nach `stun_max_chain` Stuns in Folge greift eine kurze Stun-Immunitaet, bevor die Kette von vorn beginnt.

## Balancing (Threat-Budget-System)

| Wert | Betrag |
|---|---|
| Threat-Cost | 15 |
| Basis-HP | 400.0 |
| Move-Speed | 5.5 (Varianz 0.08) |
| Angriffsschaden | 70.0 |
| Angriffs-Cooldown | 1.5 s |
| Erkennungsreichweite | 200.0 |
| Ziehgewicht | 1.0 |
| Max. pro Raum | 3 |
| Garantierte Anzahl | 3 |
| Mindest-Raumhoehe | 20.0 |

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

- [[boss_01]] — `min_room_height = 20.0` in `es_colossus.tres` ist laut Kommentar in `enemy_spawn_entry.gd` bewusst auf die 24 Units hohe Boss-Arena zugeschnitten; kein anderer Raumtyp ist hoch genug.

## Verwandt

Basiert auf `enemy_ai.gd` (Chase-Attack-State-Machine, importiertes
Roboter-Mesh). Seit Phase 5 existiert daneben ein zweiter, unabhaengiger
Gegner-Unterbau — [[custom_enemy_base]] — fuer stationaere/fliegende
Spezialtypen ohne Laufanimation. Siehe [[_MOC_Enemies]] fuer den vollstaendigen
Ueberblick beider Systeme.

## Erwaehnt in DevLogs

- [[2026-08-10_bcd3e81_wiki_sechs_neue_sandbox-gegner_item-item-synergien|2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten]]
- [[2026-07-26_61765de_feat_combat-tuning_hud-overhaul_anti-baiting_sieg-|2026-07-26 — feat: Combat-Tuning, HUD-Overhaul, Anti-Baiting, Sieg-Trophäe, Menü-Fixes, Türsystem-Debugging]]
- [[2026-07-25_905d144_feat_level-generation-polish_minimap-overhaul_haza|2026-07-25 — feat: Level-Generation-Polish, Minimap-Overhaul, Hazard/Door-Fixes, Atmosphäre]]

## Quelle

`scenes/tank_dummy.tscn` (Root-Node-Properties), `resources/enemies/es_colossus.tres`

## 🧠 Semantische Verbindungen (Graphify)
- **references**: [[level_generator]] (Confidence: 1.0)
