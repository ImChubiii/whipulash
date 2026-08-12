---
commit: "c555d9982bff87fefea9d128d43d82651c5db84a"
short_hash: "c555d99"
date: 2026-08-01
author: "ImChubiii"
subject: "Fix Kamera-Drill zurückgesetzt, Motion-Blur-Feature verworfen"
tags: [devlog]
---

# 2026-08-01 — Fix Kamera-Drill zurückgesetzt, Motion-Blur-Feature verworfen

Dash-Drill-Kameraroll auf ursprüngliche Werte zurückgesetzt (9°, keine Overshoot-Sequenz)
Motion-Blur-Feature komplett entfernt (Canvas-Shader und 3D-Quad-Ansatz scheiterten beide an fehlender Screen-Textur unter Forward Mobile; Speed-Lines-Alternative auf Wunsch verworfen)
player_base.gd bereinigt, keine Motion-Blur-Reste mehr enthalten

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `c555d99` |
| Autor | ImChubiii |
| Datum | 2026-08-01 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-01_c555d99_fix_kamera-drill_zurueckgesetzt_motion-blur-featur]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
