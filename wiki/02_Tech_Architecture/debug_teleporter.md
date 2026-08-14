---
script_path: scripts/debug_teleporter.gd
autoload_name: Teleporter
tags: [architecture, autoload, debug-tool]
---

# debug_teleporter.gd

Autoload (`Teleporter`), heute deaktiviert. Das Script besteht nur noch aus
einem leeren `_ready()` — die physischen Teleporter-Pads, die es einmal im
Startraum spawnte, wurden entfernt.

Teleportation ist inzwischen ausschliesslich ueber das ADMIN-Panel im
Pause-Menue verfuegbar (`scripts/pause_menu.gd`, Methode
`_build_admin_panel()`). Das Script bleibt trotzdem als Autoload
registriert (`project.godot`), damit bestehende Referenzen und der
Autoload-Slot nicht brechen — es tut nur nichts mehr.

## Historischer Kontext

Urspruenglich spawnte dieses Autoload Interaktions-Pads fuer den direkten
Transfer zu Tresor-, Boss- und Debug-Raeumen — darunter das vierte Pad, das
zu [[enemy_sandbox_room]] fuehrte ("Zugang ausschliesslich ueber das vierte
Teleport-Pad in `debug_teleporter.gd`", siehe dortige Notiz). Diese
Pad-basierte Navigation wurde durch das Admin-Panel im Pause-Menue abgeloest.

## Verwandt

- [[enemy_sandbox_room]] — der Debug-Raum, der frueher ueber das vierte Pad
  dieses Autoloads erreicht wurde; heute vermutlich ueber das Admin-Panel
  in `pause_menu.gd` verlinkt.

## Erwaehnt in DevLogs

- [[2026-08-04_678339b_featdebug_ui_combat_teleporter-system_boss-hp-mult]]
- [[2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult]]
