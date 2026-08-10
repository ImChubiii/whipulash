---
commit: "ae734fd9935c854d2f0e23d687e28d0178a32592"
short_hash: "ae734fd"
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
| Commit | `ae734fd` |
| Autor | ImChubiii |
| Datum | 2026-07-28 |
