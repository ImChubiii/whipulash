---
commit: "0d3ad304c8706adf64e793ef6e2a63c708cfcf08"
short_hash: "0d3ad30"
date: 2026-07-21
author: "ImChubiii"
subject: "Fix enemy movement freeze and enhance ledge detection"
tags: [devlog]
---

# 2026-07-21 — Fix enemy movement freeze and enhance ledge detection

Critical fix to _get_feet_y() calculation that was double-counting capsule radius, causing continuous false "ledge ahead" detections and enemy freeze. Now correctly calculates feet position: half_height = shape.height * 0.5 instead of (radius + height * 0.5).

Added dynamic ledge detection that scales with body radius and uses lateral samples for reliability. Implemented proper standing-on-player detection with height verification to prevent false positives from side collisions. Added property setters for gravity and jump_height to recalculate jump_velocity at runtime.

Refactored collision shape detection into reusable helper functions and removed verbose German comments for readability. Adjusted Fighter spawn point in level_01 to match new coordinates.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Gegner:** [[fighter]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `0d3ad30` |
| Autor | ImChubiii |
| Datum | 2026-07-21 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-21_0d3ad30_fix_enemy_movement_freeze_and_enhance_ledge_detect]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
