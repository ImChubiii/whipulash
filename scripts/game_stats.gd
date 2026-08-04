extends Node

# ============================================================================
# GameStats — Autoload-Singleton fuer persistente Meta-Statistiken.
# ============================================================================
# Speichert/laedt in user://game_stats.cfg (ConfigFile) — gleiches Muster wie
# SettingsManager (settings_manager.gd) mit user://settings.cfg. Muss unter
# Project Settings -> Autoload als "GameStats" eingetragen sein.
#
# WARUM HIER UND NICHT IM JEWEILIGEN SYSTEM (item_manager.gd, enemy_ai.gd, ...):
# Diese Werte muessen ueber Raum-, Etagen- UND Run-Grenzen hinweg ueberleben,
# also unabhaengig von jeder einzelnen Spielinstanz. Ein Autoload ist der
# einzige Ort im Projekt, der garantiert nicht mit dem jeweiligen Level
# zusammen abgebaut wird.
#
# has_live_run WIRD BEWUSST NICHT PERSISTIERT: echtes Fortsetzen eines Runs
# nach einem Abgesturzten/kompletten Neustart der Anwendung wuerde eine volle
# Serialisierung des prozeduralen Dungeons (Raum-Layout, Gegner-Zustaende,
# Seed-Fortschritt) voraussetzen, die es in diesem Projekt nicht gibt.
# "Fortsetzen" heisst hier ausschliesslich: ueber das Hauptmenue, das aus der
# Pause heraus als Overlay UEBER der weiterhin lebenden Spielszene angezeigt
# wird (siehe main_menu.gd/pause_menu.gd) — dort wird nie irgendetwas
# abgebaut, es muss also auch nichts wiederhergestellt werden.

signal stats_changed()

const STATS_PATH: String = "user://game_stats.cfg"

var kills: int = 0
var bosses_killed: int = 0
var deaths: int = 0
var wins: int = 0
var winstreak: int = 0
var best_combo: int = 0
var playtime_seconds: float = 0.0

## item_id -> true. Ein Dictionary statt eines Array/Set, weil ConfigFile
## Dictionaries nicht direkt kann — beim Speichern wird daraus ein
## PackedStringArray der Schluessel (siehe save_stats()).
var _items_discovered: Dictionary = {}

## NUR fuer die aktuelle Anwendungssitzung (siehe Kopfkommentar) — absichtlich
## NICHT in save_stats()/load_stats().
var has_live_run: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_stats()
	if Items != null and not Items.item_added.is_connected(_on_item_added):
		Items.item_added.connect(_on_item_added)


func _process(delta: float) -> void:
	# Laeuft absichtlich IMMER, nicht nur waehrend has_live_run: "Playtime" im
	# Stats-Screen soll die Zeit im Spiel insgesamt sein (inkl. Zeit, die im
	# Menue selbst verbracht wird), nicht nur aktive Kampfzeit — dafuer gibt
	# es bereits den separaten RunTimer fuers HUD.
	playtime_seconds += delta


func _on_item_added(item: ItemData) -> void:
	if item == null:
		return
	report_item_discovered(item.id)


# ============================================================================
# Report-API — wird aus enemy_ai.gd, combat_base.gd, death_screen.gd,
# win_screen.gd und main_menu.gd aufgerufen.
# ============================================================================
func report_kill(is_boss: bool) -> void:
	kills += 1
	if is_boss:
		bosses_killed += 1
	stats_changed.emit()
	save_stats()


func report_death() -> void:
	deaths += 1
	winstreak = 0
	has_live_run = false
	stats_changed.emit()
	save_stats()


func report_win() -> void:
	wins += 1
	winstreak += 1
	has_live_run = false
	stats_changed.emit()
	save_stats()


func report_combo(count: int) -> void:
	if count <= best_combo:
		return
	best_combo = count
	stats_changed.emit()
	save_stats()


func report_item_discovered(item_id: String) -> void:
	if item_id == "" or _items_discovered.has(item_id):
		return
	_items_discovered[item_id] = true
	stats_changed.emit()
	save_stats()


func get_items_discovered_count() -> int:
	return _items_discovered.size()


## Gesamtzahl aller im Katalog moeglichen Items — der Nenner im "X / Y"-
## Anzeigewert im Stats-Screen.
func get_items_total_count() -> int:
	return ItemCatalog.build_all().size()


func get_playtime_string() -> String:
	var total: int = int(playtime_seconds)
	var hours: int = total / 3600
	var minutes: int = (total % 3600) / 60
	var seconds: int = total % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, seconds]
	return "%02d:%02d" % [minutes, seconds]


# ============================================================================
# Persistenz
# ============================================================================
func save_stats() -> void:
	var config := ConfigFile.new()
	config.set_value("stats", "kills", kills)
	config.set_value("stats", "bosses_killed", bosses_killed)
	config.set_value("stats", "deaths", deaths)
	config.set_value("stats", "wins", wins)
	config.set_value("stats", "winstreak", winstreak)
	config.set_value("stats", "best_combo", best_combo)
	config.set_value("stats", "playtime_seconds", playtime_seconds)
	config.set_value("stats", "items_discovered", PackedStringArray(_items_discovered.keys()))

	var err: Error = config.save(STATS_PATH)
	if err != OK:
		push_warning("GameStats: Speichern nach '%s' fehlgeschlagen (Fehlercode %d)." % [STATS_PATH, err])


func load_stats() -> void:
	var config := ConfigFile.new()
	var err: Error = config.load(STATS_PATH)
	if err != OK:
		return  # Erster Start — Defaults behalten

	kills = int(config.get_value("stats", "kills", 0))
	bosses_killed = int(config.get_value("stats", "bosses_killed", 0))
	deaths = int(config.get_value("stats", "deaths", 0))
	wins = int(config.get_value("stats", "wins", 0))
	winstreak = int(config.get_value("stats", "winstreak", 0))
	best_combo = int(config.get_value("stats", "best_combo", 0))
	playtime_seconds = float(config.get_value("stats", "playtime_seconds", 0.0))

	_items_discovered.clear()
	var discovered: PackedStringArray = config.get_value("stats", "items_discovered", PackedStringArray())
	for id: String in discovered:
		_items_discovered[id] = true
