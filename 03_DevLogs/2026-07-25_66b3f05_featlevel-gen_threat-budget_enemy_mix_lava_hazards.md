---
commit: "66b3f05af37663506fe73dcb5d3c0e09315307c2"
short_hash: "66b3f05"
date: 2026-07-25
author: "ImChubiii"
subject: "feat(level-gen): threat-budget enemy mix, lava hazards, elevation, minimap overlay"
tags: [devlog]
---

# 2026-07-25 — feat(level-gen): threat-budget enemy mix, lava hazards, elevation, minimap overlay

Enemy spawning:
- Add EnemySpawnEntry resource (cost/weight/min_stage/guaranteed_count)
- RoomInstance now rolls enemy mix against a per-room threat budget
  instead of a flat min/max count, so Fighters displace Stingers
  rather than stacking on top of them
- LevelGenerator exposes enemy_table/boss_table + threat budget knobs,
  ramps difficulty via threat_per_stage
- Fix dummy.tscn (Fighter): unscaled collider was embedded in the
  floor, regen_enabled left at default true, AttackHitbox had no
  layer/mask set (was hitting walls)

Room generation:
- Add lava hazards (reusing existing LavaHazard/lemonade.gd) with
  NavigationObstacle3D carving so enemies path around them
- Fix lemonade.tscn: stray 52x23x70 CSGBox3D leftover from Level 01
  editing was baked into the reusable hazard scene
- Add stair/platform generation to gen_rooms2.py, step rise/run tuned
  to stay within agent_max_climb for clean navmesh baking
- Add room_combat_05 (lava moat) and room_combat_06 (split level)

Minimap:
- Increase map_size 30->90 and map_height 40->60 so the current room
  and adjacent doorways are visible
- Add minimap_rooms.gd: schematic room-grid overlay showing room
  type (start/combat/corridor/treasure/boss), cleared state, current
  room, and door connections, built at runtime off LevelGenerator's
  new map_cells API (grid_position, room_entered/room_cleared signals,
  map_updated/stage_cleared signals)

BREAKING: LevelGenerator.enemy_pool/boss_pool replaced by
enemy_table/boss_table (Array[EnemySpawnEntry]); old
combat_enemy_min/max etc. replaced by *_threat_budget.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Gegner:** [[fighter]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `66b3f05` |
| Autor | ImChubiii |
| Datum | 2026-07-25 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-25_66b3f05_featlevel-gen_threat-budget_enemy_mix_lava_hazards]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
