---
title: "Godot-Projekt-Setup und Szenen-Optimierung"
date: 2026-08-04
tags: [chatlog, prompt-log, whiplash, lemonade, thema/tooling, thema/meta, ki/claude]
ki_art: "claude"
---
# Godot-Projekt-Setup und Szenen-Optimierung

[Conversation Link](https://claude.ai/chat/2fae33f7-0a06-49e5-b3e3-4a12a8a9c2ea)

## User

[Datei-Upload ohne Text — zwei leer angekommene Dokumente]

## Assistant

Setup verstanden. Ich arbeite nach deinen Regeln: vollständige Dateien mit Pfad-Kommentar in Zeile 1, danach die sortierte Anleitung (A Pfade → B Nodes → C Inspector → D Signale/Autoloads), strenge Typisierung, keine Built-in Scripts.

**Zwei Hinweise vorab:**

1. Die beiden angehängten Dokumente sind **leer** angekommen — kein Inhalt, nur leere Container. Falls das der aktuelle `_project_export.txt` sein sollte, häng ihn bitte nochmal an (ggf. als `.txt`, nicht als Paste).

2. In der Projekt-Knowledge liegt bereits ein `_project_export.txt` samt Export-Skripten (`run_management_export.bat`, `export_file_tree.ps1`). Den nutze ich als Basis, solange du nichts Neueres lieferst — aber der Stand kann veraltet sein. Bevor ich eine Datei überschreibe, frage ich dich nach der aktuellen Version.

Was steht an? Aus dem letzten Stand offen:

- Steam-Leaderboard: Daily-Seed-Menüeintrag noch nicht verdrahtet
- VFX-Feedback für Passiv-Items (Kochlöffel, Hackbeil, Statiksocke, Schwefelhörner)
- `room_combat_06.tscn`: Spawn-Marker liegt in der Lava-Pfütze
- Zwei tote Duplikat-Korridor-Szenen in `scenes/rooms/combat/`
- 9 neue Räume

---

## User

[Datei-Upload ohne Text — `_project_export.txt`]

## Assistant

Export geladen und indexiert. **358 Code-Dateien**, 2,0 MB, Git-Log bis Commit `7e551ae` (04.08.2026, 02:10). Ich arbeite ab jetzt exakt auf diesem Stand.

**Ein Loch im Export, das du kennen solltest:**
`project.godot` steht zwar in TEIL 2 (Dateiübersicht), aber der Inhalt fehlt in TEIL 3. Grund: dein `run_management_export.bat` filtert über `$ExtArray = @('.gd','.tscn','.tres','.gdshader','.cfg','.import')` — die Endung `.godot` ist nicht dabei. Ergebnis: **ich kann Autoloads, Input-Actions und Layer-Namen nicht verifizieren**, sondern nur aus dem Code rückschließen. Bei Autoload-Themen frage ich dich also nach, statt zu raten. Fix wäre ein Wort mehr im Array (`'.godot'`) — sag Bescheid, dann geb ich dir die `.bat` komplett neu raus.

**Stand der offenen Punkte (verifiziert gegen den Export):**

| Punkt | Status |
|---|---|
| `room_combat_06` Spawn im Lava-Pool | ✅ erledigt (Commit `678339b`, Enemy7 → `11, 0.5, -19`) |
| Duplikat-Korridore in `scenes/rooms/combat/` | ✅ weg, nur noch `combat_01`–`06` |
| Daily-Seed-Menüeintrag | ❌ offen — `leaderboard_manager.gd` hat `get_daily_seed()`/`get_daily_board_name()`, aber **kein einziger Aufrufer** im Projekt. `seed_button.gd` verdrahtet das nicht. |
| VFX für Passiv-Items | ❌ offen |
| 9 neue Räume | ❌ offen (aktuell 6 Combat, 2 Korridor, 1 Boss, 1 Tresor, 1 Start) |

Zusätzlich aufgefallen: in `scenes/vfx/` liegt `bleed_vfx.tscn` **doppelt** — einmal direkt in `scenes/vfx/` und einmal in `scenes/vfx/status/`. Und im Root von `scenes/` stehen noch `lemonade.tscn` (Duplikat zu `scenes/hazards/lemonade.tscn`), `test level.tscn`, `Testlevel für gridmap.tscn`, `SMALLER SCALE Testlevel für gridmap .tscn` (mit Leerzeichen vor der Endung) und `level_02test.tscn` als Altlasten.

Was packen wir an?

