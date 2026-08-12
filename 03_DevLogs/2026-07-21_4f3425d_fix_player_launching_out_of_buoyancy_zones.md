---
commit: "4f3425d87d1cc6d6a0880d983d18a4084e224212"
short_hash: "4f3425d"
date: 2026-07-21
author: "ImChubiii"
subject: "Fix player launching out of buoyancy zones"
tags: [devlog]
---

# 2026-07-21 — Fix player launching out of buoyancy zones

Implement proper submersion depth capping and bobbing animation for buoyancy physics. Previously, buoyancy_rise_speed would continuously pull the player upward until they exited the trigger zone entirely, which immediately disabled all buoyancy effects.

Changes:
- Add submersion_body_ratio export to define how much of the body stays submerged passively
- Implement depth-based target system: once at target depth, player bobs gently instead of continuing to rise
- Add cosmetic bobbing animation with configurable amplitude/frequency/response
- Only when Space is actively held does the player rise above the capped depth
- Pass surface Y height from lemonade.gd to player for precise depth calculations
- Adjust level_01 Lemonade settings for balanced buoyancy feel

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `4f3425d` |
| Autor | ImChubiii |
| Datum | 2026-07-21 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-21_4f3425d_fix_player_launching_out_of_buoyancy_zones]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
