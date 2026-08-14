---
commit: "336b15e44763000004bf6a8416e3111fc655d90b"
short_hash: "336b15e"
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
| Commit | `336b15e` |
| Autor | ImChubiii |
| Datum | 2026-08-01 |
