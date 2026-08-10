---
commit: "17b4f895ae0463a5a026e4b7f2f5834433fc7945"
short_hash: "17b4f89"
date: 2026-07-28
author: "ImChubiii"
subject: "feat(enemy): integrate 3D robot models and procedural combat animation"
tags: [devlog]
---

# 2026-07-28 — feat(enemy): integrate 3D robot models and procedural combat animation

- Import `lowpoly_robots.glb` asset containing animated lowpoly robot armatures (RA/RB/RC).
- Enhance `enemy_ai.gd` to dynamically manage imported models:
  - Dynamically assign PSX ShaderMaterial to all mesh surfaces to preserve hit-flashes and health-based transparency.
  - Automatically center and orient models to align with +Z forward direction.
  - Hide unselected armatures based on `robot_variant`.
  - Sync locomotion animation speed with current velocity.
  - Implement a procedural attack swing using bone manipulation to complement the single-loop locomotion track.
- Instantiated `lowpoly_robots.glb` inside `scenes/dummy.tscn` under `CharacterModel`.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `17b4f89` |
| Autor | ImChubiii |
| Datum | 2026-07-28 |
