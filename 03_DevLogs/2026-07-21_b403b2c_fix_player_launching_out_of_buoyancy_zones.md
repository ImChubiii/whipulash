---
commit: "b403b2c69188cb5d1ab30762d8b6f1b8706cf260"
short_hash: "b403b2c"
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

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `b403b2c` |
| Autor | ImChubiii |
| Datum | 2026-07-21 |
