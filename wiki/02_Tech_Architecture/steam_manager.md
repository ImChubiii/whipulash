---
script_path: scripts/steam_manager.gd
autoload_name: SteamManager
tags: [architecture, autoload]
---

# steam_manager.gd

Autoload (`SteamManager`) — die einzige Stelle im Projekt, die GodotSteam
direkt anfasst. Alles andere (insbesondere [[leaderboard_manager]]) redet nur
ueber `SteamManager.get_steam()` mit Steam, nie direkt mit dem Singleton.

## Warum `Engine.get_singleton()` statt `Steam.xy()`

Wuerde irgendwo im Code direkt `Steam.steamInit()` stehen, waere das ein
**Parse-Fehler**, sobald das GodotSteam-Addon fehlt — das ganze Projekt liesse
sich dann nicht mehr oeffnen, auch nicht um am Combat zu arbeiten. Ueber
`Engine.get_singleton("Steam")` plus `.call()`/`.has_method()` bleibt der Code
syntaktisch gueltiges GDScript unabhaengig davon, ob die Extension geladen
ist. Fehlt Steam, laeuft das Spiel normal weiter — nur ohne Leaderboard.
`has_api(method_name)` exponiert dieselbe Absicherung nach aussen, weil sich
die GodotSteam-API ueber die Versionen mehrfach umbenannt hat und man lieber
vorher fragt als pro Frame eine Fehlermeldung zu produzieren.

## Der irrefuehrende Versionsstring

Godots eigener `v4.7.1.stable.steam.a13da4feb`-Tag im Log enthaelt `.steam` —
das ist der **Distributor-Tag** der Godot-Engine aus dem Steam-Shop und sagt
nichts darueber aus, ob GodotSteam installiert ist. Ob die Extension wirklich
da ist, verraet einzig die `[SteamManager] ...`-Zeile beim Start (entweder
"Verbunden als ..." oder "GodotSteam nicht gefunden").

## Init-Ablauf und Fallback-App-ID

`_try_init()` prueft zuerst `Engine.has_singleton("Steam")`, holt sich dann
das Singleton und ruft `steamInitEx` (neuere GodotSteam-Signatur) oder
`steamInit` (aeltere, liefert ebenfalls ein Dictionary mit `status`) auf.
Status `0` (`k_ESteamAPIInitResult_OK`) ist der einzige Erfolgsfall — alles
andere geht durch `_fail()`, setzt `_available = false` und `_steam = null`
und feuert `steam_failed`. `fallback_app_id = 480` ist Valves oeffentliches
Testspiel "Spacewar": damit laesst sich die komplette Leaderboard-Pipeline
durchspielen, bevor eine eigene Steam-App-ID existiert.

## `_process()` pumpt Callbacks

GodotSteam-Versionen unterscheiden sich darin, ob sie Callbacks selbst
pumpen. `pump_callbacks` ist deshalb standardmaessig `true` und ruft in
`_process()` jeden Frame `run_callbacks()` auf, falls die Methode existiert.
Doppeltes Pumpen schadet nicht — fehlendes Pumpen laesst dagegen jede
Leaderboard-Antwort (Upload, Download, Find) still verhungern, ohne
Fehlermeldung. `process_mode = PROCESS_MODE_ALWAYS` sorgt dafuer, dass das
auch bei pausiertem Spiel weiterlaeuft.

## Manipulationssicherheit — bewusst keine

Steam-Leaderboards werden vom **Client** beschrieben. Wer den Prozess
manipuliert, kann jederzeit einen Score hochladen — das gilt fuer jedes Spiel
mit Client-Upload, nicht nur fuer dieses. Der in [[leaderboard_manager]]
mitgeschriebene Seed (`RunRecord.run_seed`) macht Runs **nachspielbar** und
damit menschlich pruefbar, aber nicht faelschungssicher. Fuer harte
Verifikation braeuchte es serverseitiges Replay, was hier bewusst nicht
gebaut wurde.

## Dev-Setup (aus dem Datei-Header)

1. GodotSteam-GDExtension nach `res://addons/godotsteam/` entpacken.
2. `steam_appid.txt` mit der App-ID neben die Projektdatei legen (`480` =
   Spacewar zum Testen ohne eigene App).
3. Steam-Client muss laufen und eingeloggt sein.
4. Autoload eintragen: `SteamManager` → `res://scripts/steam_manager.gd`.

## Oeffentliche API

`is_available()`, `get_steam_id()`, `get_persona_name()`, `has_api()` sowie
`get_steam()` — Letzteres bewusst kein globaler Alias auf das Steam-Singleton
selbst, sondern ein Zugriffspunkt nur fuer [[leaderboard_manager]]. Die
Absicht: der Rest des Projekts soll nicht selbst mit Steam reden, sondern
ausschliesslich ueber diese beiden Autoloads.

## Verwandt

- [[leaderboard_manager]] — einziger Konsument von `get_steam()`, baut darauf
  die eigentliche Leaderboard-Logik.

## Erwaehnt in DevLogs

- —
