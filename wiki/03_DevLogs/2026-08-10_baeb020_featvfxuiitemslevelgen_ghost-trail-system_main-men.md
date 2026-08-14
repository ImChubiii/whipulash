---
commit: "baeb0205d42314387c960a4a21f103ba65f8d887"
short_hash: "baeb020"
date: 2026-08-10
author: "ImChubiii"
subject: "feat(vfx,ui,items,levelgen): Ghost-Trail-System, Main-Menu-Rework, Item-Testraum & Bugfixes"
tags: [devlog]
---

# 2026-08-10 — feat(vfx,ui,items,levelgen): Ghost-Trail-System, Main-Menu-Rework, Item-Testraum & Bugfixes

- scripts/vfx/ghost_trail.gd(.uid) — wiederverwendbare Ghost-Trail-Komponente (Lauf- + Angriffs-Trail, zweifarbig pro Charakter)
- scenes/vfx/hit_spark_primary.gd/.tscn — großer, charakterfarbiger Treffer-Partikeleffekt (2 Draw-Passes)
- scripts/item_test_room.gd(.uid) — Admin-Item-Testraum (alle Items, Delete-Plate, nur per Teleporter erreichbar)

Geänderte Dateien (nach Feature gruppiert)

Bugfixes
- scenes/level_generation/room_instance.gd, 5× room_*.tscn — Lava-Pools jetzt hohl (Pit statt Solid-Floor); Voidshaft-Mesh vom Theme-Tinting ausgenommen
- scripts/party_manager.gd — 2s Invuln + Blink-Effekt beim erzwungenen Charakterwechsel
- scripts/level/stage_theme.gd — Türfarbe jetzt gleicher Hue wie Wand, nur heller/dunkler
- scripts/items/item_summary_list.gd — Item-Description-Card: synchrone Größenberechnung statt Container-Timing-Bug

Ghost Trail & Treffer-VFX
- scripts/combat_base.gd, scripts/character_data.gd, scripts/vfx_manager.gd, scripts/primary_hitbox.gd, resources/char_1-4.tres, 4× char_*.tscn — Zweifarbige Charakter-Trails/Partikel (Ningning blau/weiß, Giselle rot/orange, Karina rot/pink, Winter grün/weiß), finale Deckkraft (Run 1.5%, Burst 20%)
- Ghost Trail bei Gegnern komplett entfernt (Performance)

Main Menu Rework
- scripts/main_menu.gd (+829 Zeilen) — SubViewport-3D-Hintergrund, neues Layout, Hover-Juice, ESC-Navigation, Live-3D-Charakter-Preview im Charakter-Screen

Admin Item-Testraum
- scripts/items/item_manager.gd, scripts/debug_teleporter.gd, project.godot — Teleporter-Pad + Autoload-Eintrag, clear_inventory()

Item-Balance (aktive Items)
- scripts/items/item_behaviours.gd (358 Zeilen geändert) — Schaden/Heilung ×1.75, Reichweite/Radius/Winkel ×1.4 dann nochmal ×1.7 (Kegel-Winkel bei ~71–80° gedeckelt), Gatecrash-Anker-Lifetime-Bugfix (12.5→20.0), diverse Summon-Mesh-Größen erhöht

Sonstiges
- scripts/player_base.gd, scripts/vfx/blood_decal.gd — kleinere Anpassungen (nicht Teil der oben genannten Session-Arbeiten, vermutlich Nebenwirkungen/Vorarbeiten)
- _project_export.txt — automatisch von Godot aktualisierte Exportdatei

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.



## Metadaten

| Feld | Wert |
|---|---|
| Commit | `baeb020` |
| Autor | ImChubiii |
| Datum | 2026-08-10 |
