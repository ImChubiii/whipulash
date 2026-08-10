---
commit: "d76e8233bd37597f655eb97022856b963b9ea1f2"
short_hash: "d76e823"
date: 2026-07-23
author: "ImChubiii"
subject: "Refactor settings menu with tabs & accessibility"
tags: [devlog]
---

# 2026-07-23 — Refactor settings menu with tabs & accessibility

- Reorganized settings into tabbed interface: General (with accessibility options), Video, Audio, Controls
- Added colorblind mode support with shader-based correction (Protanopia, Deuteranopia, Tritanopia)
- Added display mode selection (Windowed, Fullscreen, Borderless) with window size preservation
- Added V-Sync and FPS limit controls
- Added HUD visibility toggle connected to all relevant screens
- Added screen shake toggle that affects camera trauma
- Implemented shared blur overlay (menu_blur.gdshader) for pause/death/win screens
- Fixed Panel styling to work with blur effect overlay
- Improved keybind UI with better event handling and ui_accept special case
- Removed legacy FOV, damage numbers, and minimap opacity settings

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `d76e823` |
| Autor | ImChubiii |
| Datum | 2026-07-23 |
