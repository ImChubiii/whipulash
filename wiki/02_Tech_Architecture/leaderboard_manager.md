---
script_path: scripts/leaderboard_manager.gd
autoload_name: LeaderboardManager
tags: [architecture, autoload]
---

# leaderboard_manager.gd

Autoload (`LeaderboardManager`) — Steam-Leaderboards fuer "Lemonade". Redet
mit Steam ausschliesslich ueber [[steam_manager]] (`SteamManager.get_steam()`
/ `SteamManager.is_available()`), nie direkt mit `Engine.get_singleton()`.

## Warum eine strikte Warteschlange

Die Steam-API erlaubt pro Leaderboard immer nur **eine** laufende Operation
gleichzeitig. Wer Upload und Download parallel anstoesst, bekommt still
verworfene Callbacks — typisches Symptom: ein Leaderboard, das "manchmal"
leer bleibt, ohne erkennbaren Fehler. Deshalb laeuft hier alles seriell durch
`_queue: Array[Dictionary]` und einen einzigen Zustand `_op` (`enum _Op {
NONE, FIND, UPLOAD, DOWNLOAD }`): `_pump()` startet nur dann den naechsten
Job, wenn `_op == NONE`. Fehlt fuer den anstehenden Scope noch ein
Leaderboard-Handle, wird der Job zurueck an den Anfang der Queue gehaengt
(`_queue.push_front`) und stattdessen erst `findOrCreateLeaderboard`
aufgerufen — die eigentliche Job-Reihenfolge bleibt dabei erhalten.

## Zwei Bretter: ALLTIME vs. DAILY

- `SCOPE_ALLTIME` (`LEMONADE_ANY_PERCENT`) — jeder Run, der Seed steckt in
  den Score-Details und macht den Lauf nachspielbar, aber die Layouts der
  einzelnen Eintraege unterscheiden sich je nach Seed.
- `SCOPE_DAILY` (`LEMONADE_DAILY_<YYYYMMDD>`) — alle Spieler bekommen denselben
  Tages-Seed (`get_daily_seed()`), wodurch Zeiten hier erst wirklich direkt
  vergleichbar werden, weil das Level-Layout identisch ist.

`get_daily_seed()` leitet den Seed deterministisch aus dem **UTC**-Datum ab
(`DetRng.derive(20260101, "YYYY-MM-DD")`), bewusst nicht aus der lokalen
Zeitzone — sonst haetten zwei Spieler in unterschiedlichen Zeitzonen an
unterschiedlichen Tagen ein anderes "Heute" und damit unterschiedliche
Boards. Boards werden lazy per `findOrCreateLeaderboard` angelegt, damit
niemand taeglich von Hand ein neues Daily-Board im Steamworks-Partnerportal
pflegen muss.

## `details_max` muss vor dem Download gesetzt sein

`_ensure_ready()` ruft `setLeaderboardDetailsMax(details_max)` genau einmal
beim ersten scharfgeschalteten Zugriff (`_signals_connected`-Flag verhindert
Mehrfachverbindung). Wird das vergessen oder zu spaet gesetzt, liefert Steam
bei `downloadLeaderboardEntries` die Score-Details — und damit den fuer
Nachspielbarkeit noetigen Seed — gar nicht erst mit. `details_max` ist per
Default `RunRecord.DETAIL_COUNT` (7), passend zu `RunRecord.to_details()` /
`RunRecord.from_entry()`.

## Defensives Signal-Binding

`_connect()` prueft `_steam.has_signal(signal_name)`, bevor verbunden wird:
GodotSteam hat Signalnamen ueber die Versionen mehrfach umbenannt. Ein
fehlendes Signal erzeugt nur eine `push_warning` ("Leaderboard bleibt
unvollstaendig"), nicht einen Absturz beim Spielstart. Gebunden werden
`leaderboard_find_result`, `leaderboard_score_uploaded`,
`leaderboard_scores_downloaded`.

## Fehlerpfad bei nicht auffindbarem Board

Schlaegt `findOrCreateLeaderboard` fehl (`found == 0` oder Handle `0`), wirft
`_on_find_result` nicht nur eine Warnung, sondern entfernt **alle** noch in
der Queue wartenden Jobs desselben Scope
(`_queue.filter(... j.scope != scope)`). Ohne das wuerde der Manager beim
naechsten `_pump()` denselben kaputten Scope endlos erneut zu finden
versuchen.

## Ohne Steam

Ist [[steam_manager]] nicht verfuegbar, emittiert `_ensure_ready()` einmalig
`unavailable(reason)` und bricht ab (`submit_run`/`request_*` beenden sich
sofort mit `submit_finished.emit(false, false)` bzw. tun nichts). Das Spiel
laeuft ohne Bestenliste normal weiter — es gibt keinen Retry-Mechanismus,
Consumer muessen selbst auf `unavailable` reagieren.

## Nutzung: `win_screen.gd`

Der einzige Konsument im Projekt ist `scenes/win_screen.gd`: verbindet
`submit_finished`, `entries_ready`, `unavailable`; ruft beim Anzeigen des
Bestenlisten-Blocks `LeaderboardManager.submit_run(_own_record)` gefolgt von
`request_top()` auf (bewusst in dieser Reihenfolge — dank der
Warteschlange laeuft der Download garantiert erst nach dem Upload, sodass der
eigene neue Rang schon in der Liste steckt) und liest fuer die
Eigenmarkierung in der Liste `SteamManager.get_steam_id()`.

## Manipulationssicherheit

Siehe [[steam_manager]]: der mitgeschriebene `run_seed` macht Runs
nachspielbar/pruefbar, nicht faelschungssicher — Uploads kommen vom Client.

## Verwandt

- [[steam_manager]] — einzige Quelle des Steam-Singletons, siehe dort fuer
  den `Engine.get_singleton()`-Workaround und die Manipulationssicherheits-
  Einordnung.

## Erwaehnt in DevLogs

- [[2026-08-04_ec5e457_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef]] —
  Item-ID-Umbenennungen machen alte Leaderboard-Eintraege, die diese IDs in
  ihren Details referenzieren, nicht mehr aufloesbar.
- [[2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef]] —
  dieselbe Notiz (paralleler Commit-Hash).
- [[2026-07-26_161c399_feat_stat-system_loot-drops_bomben_items_und_game_]] —
  Begruendung, warum Loot einen eigenen RNG statt des globalen bekommt: der
  globale RNG haette sonst Seeds auf dem Leaderboard entwertet.
- [[2026-07-26_ec9ce70_feat_stat-system_loot-drops_bomben_items_und_game_]] —
  dieselbe Notiz (paralleler Commit-Hash).
