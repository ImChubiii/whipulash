---
commit: "43a32e9e91784778fde6faf2e850dce6d449a24b"
short_hash: "43a32e9"
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
| Commit | `43a32e9` |
| Autor | ImChubiii |
| Datum | 2026-08-10 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-10_43a32e9_verkleinere_hitboxenmeshes_bei_turret_auge_koeder_]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
