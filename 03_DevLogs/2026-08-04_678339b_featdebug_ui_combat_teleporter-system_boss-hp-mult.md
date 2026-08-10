---
commit: "678339b6ea352206bd9b42643e6bf84bd7fcefcf"
short_hash: "678339b"
date: 2026-08-04
author: "ImChubiii"
subject: "feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes"
tags: [devlog]
---

# 2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes

- feat(debug): Debug-Teleporter-System hinzugefügt (`debug_teleporter.gd`)
  - Spawnt Interaktions-Pads im Startraum für den direkten Transfer zum Tresor- oder Bossraum.
  - Höheneinstellungen und Ziel-Landeposition angepasst (spawnt oberhalb von Podesten).
  - Typen-Inferenz in `_unhandled_input` explizit typisiert (`is_interact: bool`), um GDScript-Parser-Fehler zu beheben.

- fix(ui): Boss-HP-Leiste für Räume mit mehreren Bossen synchronisiert (`boss_health_bar.gd`)
  - HP-Berechnung summiert nun dynamisch die Lebenspunkte aller aktiven Bosse im Raum (bis zu 3 Bosse).
  - Verhindert falsche Maximal-HP-Sprüunge bei Boss-Tötungen.

- fix(ui): Positionierung der Item-Beschreibung im Pausemenü korrigiert (`item_summary_list.gd`)
  - Störenden Links-Versatz (`avoid_node_name = "Panel"`) entfernt; Popup-Karten richten sich nun direkt an der jeweiligen Item-Zeile aus.

- fix(levelgen): Gegner-Despawn in engen Korridoren behoben (`room_instance.gd`)
  - EntryTrigger-Einrückung bei schmalen Räumen proportional gedeckelt (verhindert fälschliches Auslösen von `reset_room()`).
  - Geometrischen Anwesenheits-Fallback in `_player_is_present()` integriert.

- fix(hazards, combat): Status-Effekte und Hazard-Marker korrigiert
  - `enemy_ai.gd`: Schadens-Ticks für Bleed, Burn, Poison sowie Rooted/Stun-Handling verdrahtet.
  - `lemonade.gd`: `ignore_group`-Export hinzugefügt.
  - `room_combat_06.tscn`: Spawn-Marker von `Enemy7` aus dem Lava-Pool nach (11, 0.5, -19) verschoben.

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `678339b` |
| Autor | ImChubiii |
| Datum | 2026-08-04 |
