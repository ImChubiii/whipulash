---
commit: "61765dee332eec8f2ddd1a687db776fdc4523f7b"
short_hash: "61765de"
date: 2026-07-26
author: "ImChubiii"
subject: "feat: Combat-Tuning, HUD-Overhaul, Anti-Baiting, Sieg-Trophäe, Menü-Fixes, Türsystem-Debugging"
tags: [devlog]
---

# 2026-07-26 — feat: Combat-Tuning, HUD-Overhaul, Anti-Baiting, Sieg-Trophäe, Menü-Fixes, Türsystem-Debugging

## Gegner-KI (scenes/enemy_ai.gd)
- Neu: speed_variance – jede Instanz würfelt einmalig einen Tempo-Multiplikator
  (Stinger 0.16 / Fighter 0.12 / Colossus 0.08), verhindert "Zug"-Formation
- Fix: attack_range korrigiert auf tatsächliche Hitbox-Reichweite
  (Fighter 6.5→5.0, Colossus 9.0→8.0, Stinger 2.5→2.1)
- Fix: attack_commit_range_multiplier prüft Distanz unmittelbar vor
  Hitbox-Aktivierung, bricht Angriff sauber ab statt ins Leere zu schlagen
- Fix: Facing-Check (attack_min_facing_dot) gegen Ziel-Yaw von _face_player()
  statt gegen falsche -Z-Achse (Projekt nutzt +Z als vorne) – behebt
  "Gegner greifen nicht an"

## Hitbox (scripts/primary_hitbox.gd)
- Fix: _sweep_initial_overlaps() trägt Bodies nach, die beim Aktivieren
  bereits in der Hitbox standen (body_entered feuert nur beim Eintreten)

## Stun-Lock-Schutz (scripts/player_base.gd)
- Fix: Death-Trap durch mehrere Stinger – Stun-Diminishing-Returns
  (je Treffer -50%, Minimum 0.12s) + garantierte Immunität nach jedem
  abgelaufenen Stun (1.1s) und nach 3 Stuns in Folge
- apply_status_effect("stun", ...) leitet zwingend über apply_stun() um

## Level-Generierung (scenes/level_generation/)
- level_generator.gd:
  - Fix: Guard gegen doppelten LevelGenerator in der Szene (harter Abbruch
    mit Pfad-Ausgabe statt stillem Doppel-Layout)
  - Fix: Boss-/Tresor-Türfärbung nur bei verifizierter beidseitiger
    Verbindung (exit_flags beider Zellen), beidseitig eingefärbt
  - Neu: print_door_report() – vollständiges Tür-Debug-Protokoll
    (Layout/Marker/Node/Zustand/Nachbar/Hack je Richtung + Auffälligkeiten)
  - Fix: Innenseite von Boss-/Tresorräumen via set_door_hack_exempt()
    freigestellt – behebt Einsperr-Falle nach Bosskampf
- room_instance.gd:
  - Fix: Anti-Baiting – EntryTrigger jetzt kompakter Quader in Raummitte
    (entry_trigger_depth) + Verweildauer-Check statt fast raumgroßer Box
  - Fix: Gegner-Zählung verbindet alle Signalquellen (died/Health.died/
    tree_exited) mit Dedup statt nur einer – behebt hängende Türverriegelung
  - Neu: Watchdog prüft sekündlich auf verwaiste Zähler, gibt Raum notfalls
    zwangsweise frei
  - Neu: get_door_report() / door_state_name() für Debug-Protokoll
  - Neu: set_door_hack_exempt() Passthrough zu Door
- door.gd:
  - Fix: hack_exempt trennt Optik (door_kind) von Mechanik (requires_hack) –
    behebt "im Bossraum eingesperrt" nach Clear
  - Fix: _find_mesh() sucht robust nach MeshInstance3D (direkt/Kinder/
    rekursiv) statt starrem @onready-Pfad – behebt "Boss-Tür nicht rot"
  - Neu: set_locked() warnt statt still zu verweigern; force_unlock() als Notausgang
  - Neu: Hacking-Hologramm (Billboard-Label3D) vor Boss-/Tresortüren,
    verschwindet bei Interaktionsbeginn
- minimap_rooms.gd: Türzustand live von Door/RoomInstance/LevelGenerator
  abgefragt statt aus Layout-Bitmaske – behebt Minimap/Realität-Diskrepanz,
  neue Riegel-Darstellung für LOCKED/HACK_LOCKED/HACK_READY

## HUD (scripts/hud.gd, scenes/hud.tscn, scripts/run_timer.gd, scripts/ability_slot.gd)
- Neu: Combo-Counter zentriert, Sway-Animation (alternierende Richtung,
  TRANS_ELASTIC), verdeckt Minimap nicht mehr
- Neu: run_timer.gd – Speedrun-Timer (Format m.ss.cc), Auto-Start bei Spawn,
  pausiert automatisch mit der Engine
- Neu: Minimap-Tastenhinweis "MAP [M]"
- Neu: Modulare HUD-Sichtbarkeit (Minimap/Party/Abilities/Keybinds/Timer/
  Combo einzeln togglebar) über settings_manager.gd + settings_menu.gd
  Dropdown (Laufzeit-generiert)

## Menüs (scripts/settings_manager.gd, scenes/settings_menu.gd,
           scripts/death_screen.gd, scripts/pause_menu.gd, scenes/win_screen.gd)
- Fix: reset_to_defaults() → reset_all_to_defaults() (Methode existierte nicht)
- Neu: DEFAULT_KEYBINDS – hart definierte Standardbelegung (LMB/RMB/Shift/
  Q/E/F/Space/WASD/R), Reset stellt jetzt garantiert diese wieder her statt
  einer möglicherweise fehlerhaften InputMap-Momentaufnahme
- Neu: "reset"-Action (Level-Neustart, Fallback-Taste R) in
  REBINDABLE_ACTIONS, wird bei Fehlen automatisch angelegt
- Fix: Death-Screen-Button-Position zentral im Code korrigiert
  (vorher lief Inhalt unten aus dem Panel)
- Neu: Timer-Stop + Anzeige der Endzeit in Death-/Win-Screen

## Sieg-Trophäe (scripts/victory_trophy.gd, scenes/victory_trophy.tscn)
- Neu: Goldener Zylinder fällt nach Boss-Tod in Raummitte (Tween statt
  RigidBody3D wegen unsicherem Bodenkontakt), keine Kollision am Mesh,
  separate Area3D fürs Einsammeln, löst WinScreen aus

## Betroffene Dateien (chronologisch einzuspielen)
scenes/enemy_ai.gd · scenes/dummy.tscn · scenes/scout_dummy.tscn ·
scenes/tank_dummy.tscn · scenes/level_generation/room_instance.gd ·
scenes/level_generation/door.gd · scenes/level_generation/level_generator.gd ·
scripts/primary_hitbox.gd · scripts/player_base.gd ·
scripts/settings_manager.gd · scenes/settings_menu.gd ·
scripts/death_screen.gd · scripts/pause_menu.gd · scenes/win_screen.gd ·
scripts/victory_trophy.gd · scenes/victory_trophy.tscn ·
scripts/minimap_rooms.gd · scripts/hud.gd · scenes/hud.tscn ·
scripts/run_timer.gd · scripts/ability_slot.gd

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Gegner:** [[colossus]], [[fighter]], [[stinger]]

**Status-Effekte:** [[stun]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `61765de` |
| Autor | ImChubiii |
| Datum | 2026-07-26 |
