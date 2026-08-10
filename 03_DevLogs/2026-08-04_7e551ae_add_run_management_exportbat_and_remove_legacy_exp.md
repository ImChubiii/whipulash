---
commit: "7e551ae48bd79a2365f156633d323c0f5091f092"
short_hash: "7e551ae"
date: 2026-08-04
author: "ImChubiii"
subject: "Add run_management_export.bat and remove legacy exporters"
tags: [devlog]
---

# 2026-08-04 — Add run_management_export.bat and remove legacy exporters

Introduce run_management_export.bat — a UTF‑8 Windows batch that collects the git log, a file overview and all relevant project code (.gd/.tscn/.tres/.gdshader/.cfg/.import) into _project_export.txt and copies it to the clipboard. Remove older/duplicate export helpers and generated artifacts (_Commit_Exportieren.bat, export_*.ps1, _file_list.txt, commits.txt, export_single_file.ps1, export_full_project.ps1, etc.). Also update _project_export.txt content to the new combined export format (commits + file list + project code). This consolidates and modernizes project export on Windows.

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `7e551ae` |
| Autor | ImChubiii |
| Datum | 2026-08-04 |
