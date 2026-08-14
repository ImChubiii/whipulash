---
commit: "c19780a97b45391dd3601f1097541b76a312d738"
short_hash: "c19780a"
date: 2026-08-12
author: "ImChubiii"
subject: "docs(wiki): overhaul of game design docs, item balance & graph view"
tags: [devlog]
---

# 2026-08-12 — docs(wiki): overhaul of game design docs, item balance & graph view

- Refactored entire Game Design Wiki (Characters, Enemies, Status Effects, Rooms) into a player-friendly, German Fandom-style format.
- Restructured `05_Gedanken` folder: Renamed files logically (01 to 08), added proper frontmatter tags, and linked to MOCs.
- Created `01_Workflow_Tools.md` documenting the AI dev loop (Antigravity, Warp, Godot, Obsidian).
- Created `02_Game_Design_Blueprint.md` with detailed implementation concepts.
- Added 18 new Common/Uncommon items to balance and dilute the legendary loot pool.
- Executed a safe, vault-wide dictionary replacement converting `ae/oe/ue` to proper German umlauts (`ä/ö/ü`) in text, while preserving Godot file paths and IDs.
- Configured custom Obsidian Graph View colors (Red for enemies, Blue for characters, etc.) and added a DataviewJS execution script.
- Fixed orphaned graph nodes by linking `README.md`, `CLAUDE.md`, `graphify-out` reports, and `rooms_overview.md` to `HOME`.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `c19780a` |
| Autor | ImChubiii |
| Datum | 2026-08-12 |
