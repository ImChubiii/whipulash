---
commit: "9e59d70274debe94c8fc102fa49558535f272053"
short_hash: "9e59d70"
date: 2026-08-04
author: "ImChubiii"
subject: "Add run_management_export.bat and remove legacy exporters"
tags: [devlog]
---

# 2026-08-04 — Add run_management_export.bat and remove legacy exporters

Introduce run_management_export.bat — a UTF‑8 Windows batch that collects the git log, a file overview and all relevant project code (.gd/.tscn/.tres/.gdshader/.cfg/.import) into _project_export.txt and copies it to the clipboard. Remove older/duplicate export helpers and generated artifacts (_Commit_Exportieren.bat, export_*.ps1, _file_list.txt, commits.txt, export_single_file.ps1, export_full_project.ps1, etc.). Also update _project_export.txt content to the new combined export format (commits + file list + project code). This consolidates and modernizes project export on Windows.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `9e59d70` |
| Autor | ImChubiii |
| Datum | 2026-08-04 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-04_9e59d70_add_run_management_exportbat_and_remove_legacy_exp]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
