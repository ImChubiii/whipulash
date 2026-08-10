---
commit: "f4f2185c3495df0aa30f9309ef6713aec7fd24f1"
short_hash: "f4f2185"
date: 2026-08-10
author: "ImChubiii"
subject: "Verkleinere Hitboxen/Meshes bei Turret, Auge, Koeder, Nanoswarm; fixe Lockdown-Treffer auf Telegraph-Position"
tags: [devlog]
---

# 2026-08-10 — Verkleinere Hitboxen/Meshes bei Turret, Auge, Koeder, Nanoswarm; fixe Lockdown-Treffer auf Telegraph-Position

Die alten Meshes (Box/Sphere/Capsule/Cylinder) waren zu grossflaechig
im Verhaeltnis zu ihrer tatsaechlichen Trefferwirkung.

Lockdown schlug bisher am aktuellen Spielerstandort zu statt am
sichtbaren Telegraph-Ring - gleiches Muster wie bei Orbitalschlag,
Koeder und Nachbeben.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Items:** [[aftershock]], [[fakeout]], [[lockdown]], [[nanoswarm]], [[orbital_strike]], [[turret]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `f4f2185` |
| Autor | ImChubiii |
| Datum | 2026-08-10 |
