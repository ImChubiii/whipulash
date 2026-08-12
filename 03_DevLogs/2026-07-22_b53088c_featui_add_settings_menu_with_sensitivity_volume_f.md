---
commit: "b53088c74a6dba842fbc655e029d5564161cc836"
short_hash: "b53088c"
date: 2026-07-22
author: "ImChubiii"
subject: "feat(ui): add settings menu with sensitivity, volume, fullscreen and rebindable keybinds"
tags: [devlog]
---

# 2026-07-22 — feat(ui): add settings menu with sensitivity, volume, fullscreen and rebindable keybinds

- Add SettingsManager autoload (scripts/settings_manager.gd) for persistent
  settings storage via ConfigFile (user://settings.cfg): mouse sensitivity,
  master/music/sfx volume, fullscreen, and rebindable input actions
- Add SettingsMenu UI (scripts/settings_menu.gd, scenes/settings_menu.tscn)
  with live sliders for sensitivity/volume, fullscreen toggle, and a
  dynamically generated key-rebind list (attack_primary, attack_secondary,
  utility, interact, ui_accept, ui_left/right/up/down) incl. conflict
  detection and per-action reset-to-default
- Extend PauseMenu (scripts/pause_menu.gd) with SettingsButton and
  settings_menu_path export to open/close the new panel; Escape now
  correctly routes: cancel rebind -> close settings -> resume game
- Fix: moved settings_menu.gd from scenes/ to scripts/ to match the
  ext_resource path referenced in settings_menu.tscn (was causing
  "min_value on null instance" due to unattached script)
- Fix: instantiate settings_menu.tscn as a sibling under CanvasLayer in
  level_01.tscn and wire PauseMenu.settings_menu_path to it (menu was
  silently doing nothing on click due to unset NodePath)

Known follow-up: level scenes other than level_01.tscn still need the
same SettingsMenu instance + PauseMenu wiring; "interact " input action
has a trailing-space typo in project.godot that should be cleaned up.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `b53088c` |
| Autor | ImChubiii |
| Datum | 2026-07-22 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-22_b53088c_featui_add_settings_menu_with_sensitivity_volume_f]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
