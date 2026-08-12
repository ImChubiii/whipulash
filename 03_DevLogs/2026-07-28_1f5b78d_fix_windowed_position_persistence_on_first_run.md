---
commit: "1f5b78d92bfff600dd65f423a99976d0cee1ca59"
short_hash: "1f5b78d"
date: 2026-07-28
author: "ImChubiii"
subject: "Fix windowed position persistence on first run"
tags: [devlog]
---

# 2026-07-28 — Fix windowed position persistence on first run

Prevent the window from jumping to absolute desktop coordinate (0,0) on first start by adding a _has_valid_windowed_position flag in scripts/settings_manager.gd. Only apply saved windowed position when a real position was previously stored; save/load the validity flag, position and size. Also update _apply_display_mode to respect the guard. Adjust project.godot to define viewport size and initial_position_type for correct initial placement. Minor updates: removed the Web export preset in export_presets.cfg and updated a texture resource UID in scenes/level_generation_test.tscn; Game Export pck was updated.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `1f5b78d` |
| Autor | ImChubiii |
| Datum | 2026-07-28 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-28_1f5b78d_fix_windowed_position_persistence_on_first_run]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
