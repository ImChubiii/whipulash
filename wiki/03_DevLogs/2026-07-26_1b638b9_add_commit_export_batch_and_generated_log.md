---
commit: "1b638b983ba3f1d9feeaaa72039064599b7e5c08"
short_hash: "1b638b9"
date: 2026-07-26
author: "ImChubiii"
subject: "Add commit export batch and generated log"
tags: [devlog]
---

# 2026-07-26 — Add commit export batch and generated log

Add _Commit_Exportieren.bat — a Windows batch that switches the console to UTF-8 and runs `git -c core.quotepath=false log` to produce a UTF-8 commits.txt in the repository root (with simple success/error feedback). Also add the generated commits.txt containing the repository's commit history. This prevents charset issues when exporting git logs on Windows.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `1b638b9` |
| Autor | ImChubiii |
| Datum | 2026-07-26 |
