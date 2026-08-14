---
commit: "e5b4cf61427ba810b01b448dfa11f9e61c5e2171"
short_hash: "e5b4cf6"
date: 2026-08-05
author: "ImChubiii"
subject: "feat: Massive Gameplay-Erweiterung, 47 neue Items & Main Menu Rework"
tags: [devlog]
---

# 2026-08-05 — feat: Massive Gameplay-Erweiterung, 47 neue Items & Main Menu Rework

Dieses Update integriert den Großteil der fehlenden Design-Dokument-Features,
überarbeitet die Kernsysteme und behebt kritische Gameplay-Blocker.

Items & Status-Effekte:
- feat(items): 14 bisher fehlende Standard-Items in Katalog und Behaviours integriert.
- feat(items): 33 neue "Ultimate"-Items (ID 51-83) inkl. Mechaniken, VFX und Synergien vollständig implementiert.
- feat(status): Neue Statuseffekte 'charm' (Gegner greifen sich gegenseitig an) und 'vulnerable' hinzugefügt.
- feat(items): Ouija-Board beschwört nun zielsuchende Rachegeister (revenge_ghost.gd).

Gameplay & Level-Systeme:
- feat(level): Lokale Raumbeleuchtung eingeführt; globales DirectionalLight entfernt für tieferes Dunkel in Abgründen.
- feat(level): Void-Death-System eingebaut (Spieler stirbt beim Fall in tiefe Abgründe).
- feat(hazards): Neues modulares Turret-System (Wall, Pillar, Homing, Bomb) inkl. turret_projectile.gd.
- feat(party): Last-Stand-Rework; der Tod eines Charakters bestraft nun die gesamte Rest-Party mit einem 20% HP-Cap.
- feat(gen): Treasure-Räume haben nun eine 35%-Chance, direkt am Startraum zu spawnen.

KI & Combat:
- feat(ai): Zentrales `_current_target()` für Gegner etabliert, um nahtloses Targeting während des 'charm'-Effekts zu gewährleisten.
- feat(ai): Gegner treiben jetzt physisch in Lava (Buoyancy), statt auf den Grund zu sinken.
- refactor(ai): Zigzag-Bewegung interpoliert nun weich (inkl. Lean-Telegraphing) statt zu springen.
- feat(ai): Auto-Unstuck-Routine für feststeckende Gegner hinzugefügt.

UI, VFX & Menüs:
- feat(ui): Neues, vollständig prozedurales Hauptmenü (main_menu.gd/tscn) implementiert.
- feat(ui): Pause-, Win- und Death-Screens leiten nun ins Hauptmenü weiter, anstatt das Spiel direkt zu beenden.
- feat(ui): Boss-HP-System von einem globalen Balken auf 3 individuelle Balken pro Boss-Entity umgeschrieben.
- feat(ui): Rote, pulsierende Low-HP Vignette (<= 20% HP) hinzugefügt.
- feat(vfx): Magenta eingefärbte Damage-Numbers für passiven Item-Schaden integriert.
- feat(vfx): Blood-Decals spawnen nun beim Tod von Gegnern.
- feat(stats): GameStats-Autoload für persistentes Tracking von Kills, Deaths, Wins und Combos erstellt.

Bug Fixes:
- fix(doors): Türen lassen sich während eines aktiven Kampfes nicht mehr hacken.
- fix(teleporter): Teleporter-Pads spawnen nun auch beim 2. Run nach einem Restart zuverlässig wieder.
- fix(items): Verfluchter Würfel rerollt Drops jetzt korrekt (Fallback in loot_manager.gd ergänzt).
- fix(ui): Layout-Bug in Item-Karten behoben (Spacer entfernte halbe Zeilenbreite) und Entity-ID-Anzeige hinzugefügt.
- fix(items): Alter "[C]"-Cooldown-Text in der Item-UI entfernt und an das neue Q/E-System angepasst.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Items:** [[ouija_board]]

**Status-Effekte:** [[charm]], [[vulnerable]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `e5b4cf6` |
| Autor | ImChubiii |
| Datum | 2026-08-05 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-05_e5b4cf6_feat_massive_gameplay-erweiterung_47_neue_items_ma]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
