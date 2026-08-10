---
commit: "f874fed89739a15eff21df7b48f55a6fd1c54c34"
short_hash: "f874fed"
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

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `f874fed` |
| Autor | ImChubiii |
| Datum | 2026-07-23 |
