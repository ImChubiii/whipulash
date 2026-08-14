---
script_path: scripts/game_stats.gd
autoload_name: GameStats
tags: [architecture, autoload]
---

# game_stats.gd

Autoload (`GameStats`). Persistente Meta-Statistiken ueber `kills`,
`bosses_killed`, `deaths`, `wins`, `winstreak`, `best_combo`,
`playtime_seconds`, entdeckte Items (`_items_discovered`) und
`tutorial_completed` — gespeichert/geladen als `ConfigFile` unter
`user://game_stats.cfg`, exakt das gleiche Muster wie `SettingsManager`
(`settings_manager.gd` / `user://settings.cfg`).

## Warum ein eigenes Autoload und nicht Teil von PartyManager/Items

Diese Werte muessen ueber Raum-, Etagen- **und** Run-Grenzen hinweg
ueberleben — also unabhaengig von jeder einzelnen Spielinstanz. Ein
Autoload ist der einzige Ort im Projekt, der garantiert nicht mitsamt dem
jeweiligen Level abgebaut wird. Waere das Tracking z. B. Teil von `Items`
oder `PartyManager`, wuerde es implizit an deren Lebenszyklus haengen statt
wirklich global zu sein.

## `has_live_run` wird bewusst NICHT persistiert

Ein echtes Fortsetzen eines Runs nach einem Absturz/kompletten
Anwendungsneustart wuerde eine volle Serialisierung des prozeduralen
Dungeons (Raum-Layout, Gegner-Zustaende, Seed-Fortschritt) voraussetzen,
die es in diesem Projekt nicht gibt. "Fortsetzen" heisst hier ausschliesslich:
ueber das Hauptmenue, das aus der Pause heraus als Overlay UEBER der
weiterhin lebenden Spielszene angezeigt wird (`main_menu.gd`/`pause_menu.gd`)
— dort wird nie etwas abgebaut, es muss also auch nichts wiederhergestellt
werden. `has_live_run` ist deshalb reine Sitzungslaufzeit-Information und
fehlt absichtlich in `save_stats()`/`load_stats()`.

Der Flag-Lebenszyklus ist ueber mehrere Dateien verteilt:
- `party_manager.gd::_spawn_active_character()` setzt ihn auf `true`, sobald
  tatsaechlich eine lebende Spieler-Instanz in der Welt existiert (bewusst
  nicht schon in `setup_party()`).
- `death_screen.gd::_on_player_died()` und `win_screen.gd::show_win()` setzen
  ihn ueber `report_death()`/`report_win()` auf `false`.
- `pause_menu.gd::_on_quit_pressed()` setzt ihn direkt auf `false` (Zurueck
  ins Hauptmenue gilt als Verlassen des Runs).
- `main_menu.gd` liest ihn, um den "Fortsetzen"-Button zu (de)aktivieren
  (`_apply_play_mode_state`-Umfeld, Zeilen ~884-995) und um zu entscheiden,
  ob ein neuer Run ueber `RunRestart` gestartet werden muss.

## Report-API statt direkter Feldzugriffe

`report_kill(is_boss)`, `report_death()`, `report_win()`,
`report_combo(count)` und `report_item_discovered(item_id)` kapseln jeweils
Feld-Update + `stats_changed.emit()` + `save_stats()` in einem Aufruf, damit
Aufrufer (`enemy_ai.gd::report_kill`, `combat_base.gd` bei jedem Combo-Hit,
`death_screen.gd`, `win_screen.gd`) nie vergessen koennen zu speichern oder
das Signal zu feuern. `report_combo()` schreibt nur bei einem neuen Rekord
(`count <= best_combo` bricht fruehzeitig ab) — `best_combo` ist ein
Allzeit-Hoechstwert, kein Wert des aktuellen Runs.

`report_item_discovered()` wird nicht nur direkt aufgerufen, sondern auch
automatisch ueber `Items.item_added`-Signal (`_on_item_added()` in
`_ready()` verbunden) — so werden Item-Funde erfasst, ohne dass
`item_manager.gd` selbst etwas von `GameStats` wissen muss.

## `_process()` laeuft immer, nicht nur waehrend eines Runs

`playtime_seconds` zaehlt bewusst durchgehend hoch, auch im Hauptmenue —
"Playtime" im Stats-Screen (`main_menu.gd::_refresh_stats_screen()`) soll
die Gesamtzeit im Spiel sein, nicht nur aktive Kampfzeit. Dafuer existiert
bereits ein separater `RunTimer` fuers HUD/die Speedrun-Anzeige auf
Death-/Win-Screen (`_stop_and_read_run_timer()`).

## `_items_discovered` als Dictionary statt Array/Set

`ConfigFile` kann keine Dictionaries direkt speichern, deshalb wird beim
Speichern nur `PackedStringArray(_items_discovered.keys())` persistiert und
beim Laden wieder in ein Dictionary (Werte immer `true`) zurueckgebaut.
`get_items_total_count()` liest dynamisch `ItemCatalog.build_all().size()`
statt eine feste Zahl zu pflegen — der "X / Y"-Anzeigewert im Stats-Screen
bleibt damit automatisch korrekt, wenn neue Items in `item_catalog.gd`
hinzukommen.

## Keine Verbindung zu LeaderboardManager

Trotz naheliegender Vermutung liest `leaderboard_manager.gd` **nicht** aus
`GameStats`: Leaderboard-Eintraege (`RunRecord`, `submit_run()`) werden in
`win_screen.gd::_build_own_record()` unabhaengig aus der Lauf-Zeit des
separaten `RunTimer` und dem Run-Seed gebaut. `GameStats.report_win()` und
`LeaderboardManager.submit_run()` werden zwar im selben `show_win()`-Aufruf
kurz nacheinander getriggert, sind aber zwei komplett getrennte Systeme —
eines fuer persistente Lifetime-Statistiken, eines fuer einzelne
Speedrun-Eintraege pro Board/Scope.

## Verwandt

- [[party_manager]] — setzt `has_live_run = true` beim Spawnen der aktiven
  Charakterinstanz.

## Erwaehnt in DevLogs

- [[2026-08-05_603fc49_feat_massive_gameplay-erweiterung_47_neue_items_ma]]
- [[2026-08-05_e5b4cf6_feat_massive_gameplay-erweiterung_47_neue_items_ma]]
