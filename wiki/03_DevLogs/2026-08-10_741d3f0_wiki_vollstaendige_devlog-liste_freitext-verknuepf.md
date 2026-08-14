---
commit: "741d3f0cf8dff97fd95cadd88c8831ae2dd35f86"
short_hash: "741d3f0"
date: 2026-08-10
author: "ImChubiii"
subject: "Wiki: vollstaendige DevLog-Liste + Freitext-Verknuepfung Commits<->Spielinhalt"
tags: [devlog]
---

# 2026-08-10 — Wiki: vollstaendige DevLog-Liste + Freitext-Verknuepfung Commits<->Spielinhalt

- 03_DevLogs/_MOC_DevLogs.md: chronologische Gesamtliste WIRKLICH aller
  Commits (nach Monat gruppiert), nicht nur die juengsten 20 wie im
  Dashboard.
- Jede Item-/Gegner-/Raum-/Status-Effekt-/Architektur-Notiz bekommt einen
  "Erwaehnt in DevLogs"-Rueckverweis, jede DevLog-Notiz umgekehrt einen
  "Erwaehnte Entitaeten"-Abschnitt - per wortgrenzensicherem Freitext-
  Abgleich zwischen Commit-Nachrichten und bekannten Namen/IDs
  (build_entity_index/compute_devlog_mentions), da die Commit-Historie
  keine strukturierten Referenzen enthaelt.
- main() dafuer in eine Parse-Phase (alle Datenquellen inkl. git log)
  gefolgt von einer Write-Phase umgebaut, damit die Verknuepfung vor dem
  Schreiben jeder einzelnen Notiz bereits feststeht.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `741d3f0` |
| Autor | ImChubiii |
| Datum | 2026-08-10 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-10_741d3f0_wiki_vollstaendige_devlog-liste_freitext-verknuepf]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
