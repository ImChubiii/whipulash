---
commit: "5d63fe2351d99c11c0f8f345cfc5713e7ffccd65"
short_hash: "5d63fe2"
date: 2026-08-04
author: "ImChubiii"
subject: "feat(items,combat,levelgen,ui): Ouija-Board, Item-Reworks, Last-Stand, Boss-HP-Balken, diverse Bugfixes"
tags: [devlog]
---

# 2026-08-04 — feat(items,combat,levelgen,ui): Ouija-Board, Item-Reworks, Last-Stand, Boss-HP-Balken, diverse Bugfixes

Item-System:
- Neues Item "Papp-Wahrsagerbrett": 20% Chance auf Nahkampftreffer, einen
  Rachegeist (revenge_ghost.gd) gegen Gegner im blinden Fleck zu beschwoeren
- Rostiger Dachnagel: unterbricht jetzt den Telegraph des Ziels und blockiert
  Knockback vollstaendig, solange "rooted" aktiv ist
- Omas Enge Hosen: Tritt loest jetzt auch bei abruptem Richtungswechsel aus
  und stoesst ~4m zurueck statt nur kosmetisch zu sein
- Mamas Stoeckelschuhe: jeder 3. Schritt loest eine Mikro-Stun-Schockwelle aus
- Verfluchter Glueckswuerfel repariert: pickup.gd fehlten die "pickups"-
  Gruppe und reroll(); loot_manager.gd fehlte der spawn_random_drop()-Fallback
- Milchreis-Schild bekommt eine sichtbare Aura statt unsichtbar zu wirken
- Schadenszahlen von Item-/Passiv-Quellen (Dash, Tritte, Geister, ...) nutzen
  jetzt eine eigene Farbe (damage_number.gd, Kind.ITEM) statt normaler Treffer

Party & Combat:
- Last-Stand-System: stirbt der aktive Charakter, uebernimmt automatisch der
  naechste lebende (HP auf max. 20%), statt sofort den Death-Screen zu zeigen
- Boss-HP-Leiste von einem gemeinsamen Pool-Balken auf 3 individuelle,
  synchron mitlaufende Balken umgebaut
- EnemyAI: sanfte Zickzack-Kurven mit Lean-Telegraphing statt Teleport-Dash,
  automatische Unstuck-Routine, Auftrieb in Lava-Pools (2/3 Koerper sichtbar)

Level-Generation:
- Boss-/Tresor-Tueren lassen sich nicht mehr waehrend laufendem Kampf hacken
  (Raumzustand direkt in door.gd geprueft, plus korrigierte Freischaltung in
  level_generator.gd)
- Tresorraeume bekommen 35% Chance, direkt neben dem Startraum zu spawnen

UI/HUD:
- Low-HP-Vignette bei <= 20% HP
- Item-Karte: Layout-Fix (Spacer stahl die Haelfte der Titelzeile) + Entity-ID
- Tutorial-Hologramm laesst sich per [F] vergroessern (analog Minimap-Zoom)
- Veralteter "[C]"-Ladehinweis aus der Vor-Q/E-Zeit entfernt

Bugfixes:
- Debug-Teleporter-Pads erscheinen nach einem Neustart nicht mehr, weil das
  Autoload nie den neuen LevelGenerator fand (jetzt ueber node_added)
- Restart-Haltezeit: 1.0s beim ersten Mal, 0.5s bei jedem weiteren in der
  laufenden Sitzung

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Items:** [[cursed_die]], [[ouija_board]], [[roof_nail]], [[stiletto_heels]], [[tight_pants]]

**Status-Effekte:** [[rooted]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `5d63fe2` |
| Autor | ImChubiii |
| Datum | 2026-08-04 |
