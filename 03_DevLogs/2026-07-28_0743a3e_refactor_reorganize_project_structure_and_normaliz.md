---
commit: "0743a3ec3729e7d4523abbbc45dc4fd31bdef30b"
short_hash: "0743a3e"
date: 2026-07-28
author: "ImChubiii"
subject: "refactor: reorganize project structure and normalize res:// paths"
tags: [devlog]
---

# 2026-07-28 — refactor: reorganize project structure and normalize res:// paths

- Move scripts from root and scenes/ into scripts/{core,enemies,hazards,level,ui}
- Move scenes into scenes/{enemies,environment,hazards,ui}
- Move assets into assets/{characters,environments,textures,ui}
- Update all res:// references in .gd, .tscn, .tres, .cfg and .import files
- Remove empty directories after migration
- Add reorganize.py helper script for future structure changes

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `0743a3e` |
| Autor | ImChubiii |
| Datum | 2026-07-28 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-28_0743a3e_refactor_reorganize_project_structure_and_normaliz]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
