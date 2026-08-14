extends Node

## Autoload "SteamManager" - einzige Stelle im Projekt, die GodotSteam
## direkt anfasst.
##
## WARUM UEBER Engine.get_singleton() STATT DIREKT UEBER "Steam":
## Wuerde hier "Steam.steamInit()" stehen, waere das ein PARSE-Fehler,
## sobald das GodotSteam-Addon fehlt - das ganze Projekt liesse sich dann
## nicht mehr oeffnen, auch nicht zum Arbeiten am Combat. Ueber
## Engine.get_singleton("Steam") und .call() bleibt der Code gueltiges
## GDScript, egal ob die Extension da ist. Ohne Steam laeuft das Spiel
## normal weiter, nur eben ohne Leaderboard.
##
## ACHTUNG ZUM EDITOR-BUILD:
## Dein Log meldet "Godot Engine v4.7.1.stable.steam.a13da4feb". Das
## ".steam" ist der DISTRIBUTOR-Tag der Godot-Version aus dem Steam-Shop -
## es bedeutet NICHT, dass GodotSteam installiert ist. Ob die Extension
## wirklich vorhanden ist, sagt dir beim Start die Zeile
## "[SteamManager] ...". Steht dort "GodotSteam nicht gefunden", musst du
## das Addon erst installieren (godotsteam GDExtension, Godot 4.x).
##
## DEV-SETUP:
##   1. GodotSteam GDExtension nach res://addons/godotsteam/ entpacken
##   2. steam_appid.txt mit der App-ID neben die Projektdatei legen
##      (480 = Spacewar, funktioniert zum Testen ohne eigene App)
##   3. Steam-Client muss laufen und eingeloggt sein
##   4. Autoload eintragen: SteamManager -> res://scripts/steam_manager.gd
##
## EHRLICHER HINWEIS ZUR MANIPULATIONSSICHERHEIT:
## Steam-Leaderboards werden vom CLIENT beschrieben. Wer den Prozess
## manipuliert, kann jede Zeit hochladen - das gilt fuer jedes Spiel mit
## Client-Upload. Der mitgeschriebene Seed macht Runs NACHSPIELBAR und
## damit menschlich pruefbar; er macht sie nicht faelschungssicher. Fuer
## harte Verifikation braeuchtest du serverseitiges Replay.

signal steam_ready(steam_id: int, persona_name: String)
signal steam_failed(reason: String)

## App-ID fuer die Entwicklung. 480 ist Valves oeffentliches Testspiel
## "Spacewar" - damit laesst sich die komplette Leaderboard-Pipeline
## testen, bevor eine eigene App existiert.
@export var fallback_app_id: int = 480

## Manche GodotSteam-Versionen pumpen die Callbacks selbst, andere nicht.
## Doppeltes Aufrufen schadet nicht, fehlendes Aufrufen laesst jede
## Leaderboard-Antwort still verhungern - deshalb per Default an.
@export var pump_callbacks: bool = true

var _steam: Object = null
var _available: bool = false
var _steam_id: int = 0
var _persona_name: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_try_init()


func _process(_delta: float) -> void:
	if not _available or not pump_callbacks:
		return
	if _steam.has_method("run_callbacks"):
		_steam.call("run_callbacks")


func _try_init() -> void:
	if not Engine.has_singleton("Steam"):
		_fail("GodotSteam nicht gefunden - Leaderboard ist deaktiviert. (Addon fehlt oder ist nicht aktiviert.)")
		return

	_steam = Engine.get_singleton("Steam")

	var result: Dictionary = {}
	if _steam.has_method("steamInitEx"):
		result = _steam.call("steamInitEx", fallback_app_id, false)
	elif _steam.has_method("steamInit"):
		# Aeltere Signatur liefert ebenfalls ein Dictionary mit "status".
		result = _steam.call("steamInit", true)
	else:
		_fail("GodotSteam-Singleton ohne steamInit/steamInitEx - Version zu alt?")
		return

	var status: int = int(result.get("status", -1))
	# 0 = k_ESteamAPIInitResult_OK
	if status != 0:
		_fail("Steam-Init fehlgeschlagen (status %d): %s" % [status, str(result.get("verbal", "kein Text"))])
		return

	_available = true
	if _steam.has_method("getSteamID"):
		_steam_id = int(_steam.call("getSteamID"))
	if _steam.has_method("getPersonaName"):
		_persona_name = str(_steam.call("getPersonaName"))

	print("[SteamManager] Verbunden als '%s' (SteamID %d)." % [_persona_name, _steam_id])
	steam_ready.emit(_steam_id, _persona_name)


func _fail(reason: String) -> void:
	_available = false
	_steam = null
	print("[SteamManager] %s" % reason)
	steam_failed.emit(reason)


# --- Oeffentliche API ---------------------------------------------------

func is_available() -> bool:
	return _available and _steam != null


## Direkter Zugriff auf das Singleton fuer den LeaderboardManager. Bewusst
## kein globaler Alias: alles andere im Projekt soll NICHT selbst mit
## Steam reden.
func get_steam() -> Object:
	return _steam


func get_steam_id() -> int:
	return _steam_id


func get_persona_name() -> String:
	return _persona_name


## Prueft, ob eine bestimmte GodotSteam-Methode existiert. Die API hat
## sich ueber die Versionen mehrfach umbenannt - lieber vorher fragen als
## im Spiel eine Fehlermeldung pro Frame produzieren.
func has_api(method_name: String) -> bool:
	return is_available() and _steam.has_method(method_name)
