---
commit: "058b54ef3c0faca5bf114d1f8c8368b463509435"
short_hash: "058b54e"
date: 2026-07-26
author: "ImChubiii"
subject: "feat(settings, minimap): modulare Settings-Gruppen, Minimap-Konfiguration, Cursor-Zoom & Bugfixes"
tags: [devlog]
---

# 2026-07-26 — feat(settings, minimap): modulare Settings-Gruppen, Minimap-Konfiguration, Cursor-Zoom & Bugfixes

SettingsManager (scripts/settings_manager.gd)
- Neue Minimap-Sektion in settings.cfg: zoom, ui_scale, opacity, grid_placement,
  show_player_arrow, show_coords, show_zone_label
- Sammelsignal minimap_setting_changed statt vieler Einzelsignale
- Alle Minimap-Werte clampen beim Laden UND Setzen (Schutz vor korrupter Config)
- Reset jetzt pro Seite statt global: reset_general/video/audio/controls_settings()
- Migration für alte Configs (general/minimap_rotate_with_player, bg_opacity)
- Entfernt: minimap_grid_scale, minimap_big_map_zoom (siehe Minimap-Änderungen)

SettingsMenu (scenes/settings_menu.gd)
- General-Tab in Klapp-Gruppen: HUD / MINIMAP / DARSTELLUNG & BARRIEREFREIHEIT
  (zur Laufzeit gebaut, .tscn unverändert, ScrollContainer gegen Overflow)
- Keybinds als 2-spaltiges GridContainer (12 Actions → 6 statt 12 Zeilen)
- Reset-Button wirkt nur noch auf den aktuell offenen Tab, Label passt sich an
- Bugfixes: Keybind-Anzeige nutzte events[0] statt get_action_event()
  (zeigte bei ui_up/ui_left teils die falsche von zwei gebundenen Tasten)
- Bugfix: Signalsturm beim Öffnen des Menüs (_suppress_signals)

Minimap (scripts/minimap.gd)
- Nur noch EINE Deckkraft für Fläche + Rahmen (vorher getrennte Werte für
  Karte/Hintergrund, die den "Kasten-im-Kasten"-Effekt erzeugten)
- SubViewport rendert transparent (BG_CLEAR_COLOR) statt mit eigener
  deckender Hintergrundfarbe
- Großkarte: Maus wird freigegeben (stoppt Spielerkamera automatisch,
  kein Extra-Schalter im Player nötig), Mausrad zoomt auf den Cursor,
  Linksklick-Drag verschiebt den Kartenausschnitt
- Entfernt: separater Regler für Großkarten-Zoom/Grid-Scale (Zoom läuft
  jetzt per Mausrad direkt in der Karte, kein Setting mehr)
- Neu: minimap_show_player_arrow (Pfeil abschaltbar)
- Neu: static Minimap.big_map_open als Combat-Gate (siehe combat_base.gd)

MinimapRooms (scripts/minimap_rooms.gd)
- Eigene Hintergrundfläche (color_background) entfernt – Grid rendert
  jetzt transparent, einziger Hintergrund kommt aus minimap.gd

CombatBase (scripts/combat_base.gd)
- _process() blockt Angriffe, solange Minimap.big_map_open true ist
  (LMB ist attack_primary und wird gepollt – ohne Gate würde Kartenziehen
  den Charakter zuschlagen lassen)
- Fix: Einrücke-/Parsingfehler behoben (_do_primary war fälschlich als
  verschachtelter Block innerhalb von _process() gelandet und hatte den
  globalen Klassen-Cache zum Absturz gebracht → "Could not resolve class
  PlayerBase" in allen Subklassen)

BREAKING CHANGE: settings.cfg-Schlüssel [minimap] grid_scale, big_map_zoom,
bg_opacity entfallen (werden beim nächsten Speichern automatisch bereinigt,
Migration greift beim Laden alter Configs).

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `058b54e` |
| Autor | ImChubiii |
| Datum | 2026-07-26 |
