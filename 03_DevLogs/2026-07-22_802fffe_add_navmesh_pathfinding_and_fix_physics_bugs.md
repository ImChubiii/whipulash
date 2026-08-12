---
commit: "802fffe7f24c1ef5b4f77f8ed9c312112132ddcd"
short_hash: "802fffe"
date: 2026-07-22
author: "ImChubiii"
subject: "Add NavMesh pathfinding and fix physics bugs"
tags: [devlog]
---

# 2026-07-22 — Add NavMesh pathfinding and fix physics bugs

Implement NavigationAgent3D-based pathfinding for enemies with intelligent ledge-drop behavior. Fix player buoyancy launch bug by capping submersion depth and adding bobbing animation. Restructure levels to use NavigationRegion3D for proper NavMesh baking. Improve collision shape detection for accurate enemy foot positioning. Add lateral raycast sampling for more reliable ledge detection. Refactor gravity/jump velocity setters to recalculate on inspector changes.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `802fffe` |
| Autor | ImChubiii |
| Datum | 2026-07-22 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-22_802fffe_add_navmesh_pathfinding_and_fix_physics_bugs]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
