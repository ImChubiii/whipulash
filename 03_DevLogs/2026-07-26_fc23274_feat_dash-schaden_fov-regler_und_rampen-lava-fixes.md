---
commit: "fc232744688ca453376846a8bd42916b0634cb17"
short_hash: "fc23274"
date: 2026-07-26
author: "ImChubiii"
subject: "feat: Dash-Schaden, FOV-Regler und Rampen-/Lava-Fixes"
tags: [devlog]
---

# 2026-07-26 — feat: Dash-Schaden, FOV-Regler und Rampen-/Lava-Fixes

Dash-Schaden (combat_base.gd, damage_number.gd)
- Dash verursacht 20 Schaden, aber NUR beim Durchqueren eines Gegners.
  Erkennung über den Vorzeichenwechsel entlang der Dash-Achse statt über
  eine Area3D: ein body_entered-Hitbox haette schon beim Antippen oder beim
  Stehenbleiben vor dem Gegner ausgeloest.
- Trefferfenster im Inspector einstellbar (dash_hit_radius,
  dash_hit_height_up/-_down, dash_hit_vertical_offset). Hoehenfenster
  bewusst asymmetrisch: der Gegner-Ursprung sitzt bei den Fuessen, der
  Spieler-Ursprung in der Kapselmitte.
- dash_debug_draw zeichnet das Fenster als Quader in die Welt.
- Kein Hit-Lock bei Dash-Treffern - der wuerde den laufenden Dash
  ausbremsen. Combo-Zaehler und Target-Lock laufen mit.
- DamageNumber: enum Kind { NORMAL, CRIT, DASH }, Dash-Schaden in Gelb.
  show_damage(amount, is_crit) bleibt abwaertskompatibel.

FOV-Regler (settings_manager.gd, settings_menu.gd, player_base.gd)
- Neuer Regler im Video-Tab, Standard 90 statt Godot-Default 75.
- player_base liest den FOV aus dem SettingsManager statt aus camera.fov -
  ueberlebt damit den Charakterwechsel.
- _apply_sensitivity_to_player nutzt die Gruppe "player" statt
  find_child("Player"), das war nach jedem Charakterwechsel tot.

Lava-Schaden (lemonade.gd)
- Fix: Eintrittsschaden hing am Betreten des Trigger-Volumens. Beim Sprung
  von oben sind die Fuesse da noch über der Oberflaeche, der erste Treffer
  kam deshalb erst nach vollen tick_interval Sekunden. Haengt jetzt am
  Uebergang "Fuesse durchstossen die Oberflaeche".
- Gameplay von _process nach _physics_process verschoben.
- predict_falling_entry rechnet die Fallstrecke des nächsten Schritts vor.

Rampen (room_instance.gd, enemy_ai.gd)
- configure_slope zieht Waende, Decke, Tuerstuerze, Minimap-Platten und die
  Trigger-Volumen auf das neue Hoehenband. Vorher schaute man am hohen Ende
  über die Wand und am tiefen Ende unter ihr hindurch.
- Rampe ist ein massiver Keil statt einer 1 m duennen Platte.
- Spawn-Marker werden per Raycast auf den echten Boden gesetzt. Sie lagen
  fest auf y = 0.5 und steckten auf einer Rampe im Collider - Godots
  Depenetration hat die Gegner nach unten durchgedrueckt.
- EnemyAI: floor_snap_length 0.6, floor_max_angle 55 Grad gegen das
  Abreissen beim Bergablaufen.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `fc23274` |
| Autor | ImChubiii |
| Datum | 2026-07-26 |
