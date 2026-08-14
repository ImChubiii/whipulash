---
commit: "1c9735a1b2ed74c1658c5d4f3e7aff012f68bb9b"
short_hash: "1c9735a"
date: 2026-08-14
author: "ImChubiii"
subject: "fix: BinbunVFX-Asset-Packs an ihren erwarteten Pfad verschieben"
tags: [devlog]
---

# 2026-08-14 — fix: BinbunVFX-Asset-Packs an ihren erwarteten Pfad verschieben

Winters Projektil-VFX lud eine Szene über den alten "res://test vfx/"-Pfad
(mit Leerzeichen) - seit dem wiki/game-Split-Rename zu "test_vfx/" war
dieser preload() defekt. Statt nur den Pfad zu reparieren: beide
Asset-Packs referenzieren in ihren eigenen .tscn/.tres-Dateien bereits
res://assets/BinbunVFX/... bzw. res://assets/BinbunVFX_Vol2/... - sie waren
also nie richtig an ihrem vorgesehenen Ort. Jetzt liegen sie dort.

- game/test_vfx/MagicProjectilesVFX/assets/BinbunVFX/ -> game/assets/BinbunVFX/
- game/test_vfx/HitFXFree/HitFXFree/assets/BinbunVFX_Vol2/ -> game/assets/BinbunVFX_Vol2/
- combat_winter.gd: Preload-Pfad auf den neuen Ort korrigiert
- vfx_test_room.gd (Debug-Sandbox): scannt jetzt beide neuen Asset-Roots
- leeren test_vfx/-Ordner entfernt

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `1c9735a` |
| Autor | ImChubiii |
| Datum | 2026-08-14 |
