extends Button
class_name SeedButton

## Zeigt den Run-Seed an und legt ihn beim Anklicken in die Zwischenablage.
##
## WARUM EIN BUTTON UND KEIN LABEL:
## Ein Label kann keine Klicks empfangen. Der Button laeuft flat, ohne
## Fokusrahmen und ohne Hover-Verschiebung - optisch ist er von einem Label
## nicht zu unterscheiden, reagiert aber auf die Maus.
##
## WO ER FUNKTIONIERT:
## player_base.gd haelt die Maus waehrend des Spiels auf
## MOUSE_MODE_CAPTURED. Ein Klick kommt also NUR dort an, wo der Cursor
## sichtbar ist - Pausenmenue, grosse Karte [M], Death- und Win-Screen.
## Im normalen HUD ist derselbe Node trotzdem sinnvoll: er zeigt den Seed
## an, er ist dort eben nur nicht klickbar. Das ist kein Fehler.
##
## WOHER DER SEED KOMMT:
## Der LevelGenerator traegt sich in die Gruppe "level_generator" ein und
## feuert run_seed_ready(seed, code). Beides wird abgedeckt: existiert der
## Generator beim _ready() dieses Buttons schon, wird der Wert direkt
## abgefragt; sonst wartet der Button auf das Signal. Ohne diese doppelte
## Absicherung bliebe die Anzeige je nach Knoten-Reihenfolge in der Szene
## mal leer und mal nicht.

const GENERATOR_GROUP := "level_generator"

## Text vor dem Seed. Leer lassen fuer die nackte Zahl.
@export var label_prefix: String = "SEED  "

## true  = der kurze, teilbare Code ("4F2K9") wird angezeigt UND kopiert.
## false = die rohe Zahl (2147481234). Der Code ist fuer Leaderboard und
##         Weitergabe gedacht, die Zahl fuer das Feld LevelGenerator.random_seed.
@export var use_seed_code: bool = true

## Wird nach dem Kopieren kurz statt des Seeds angezeigt.
@export var feedback_text: String = "KOPIERT!"
@export var feedback_duration: float = 1.2

## Text, solange noch kein Seed bekannt ist.
@export var placeholder_text: String = "SEED  ----"

var _seed_value: int = 0
var _seed_code: String = ""
var _feedback_timer: float = 0.0


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Im Pausenmenue laeuft der Baum nicht - ohne das bliebe "KOPIERT!"
	# stehen, bis der Spieler weiterspielt.
	process_mode = Node.PROCESS_MODE_ALWAYS
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS

	text = placeholder_text
	tooltip_text = "Klicken kopiert den Seed in die Zwischenablage"

	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

	set_process(false)
	_hook_generator()


## Sucht den Generator und haengt sich an. Laeuft der Generator schon,
## wird der Seed sofort uebernommen - sonst wartet der Button auf das
## Signal.
func _hook_generator() -> void:
	var generators: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if generators.is_empty():
		# Der Generator kann sich erst spaeter eintragen (eigene Szene,
		# spaeter instanziiert). Einmal pro Frame nachsehen, bis er da ist.
		await get_tree().process_frame
		if not is_inside_tree():
			return
		generators = get_tree().get_nodes_in_group(GENERATOR_GROUP)
		if generators.is_empty():
			push_warning("SeedButton (%s): Kein Node in der Gruppe '%s' - Seed bleibt leer." % [name, GENERATOR_GROUP])
			return

	var generator: Node = generators[0]

	if generator.has_signal("run_seed_ready") and not generator.is_connected("run_seed_ready", _on_run_seed_ready):
		generator.connect("run_seed_ready", _on_run_seed_ready)

	# Nachziehen, falls run_seed_ready schon gefeuert hat.
	if generator.has_method("get_run_seed"):
		var value: int = generator.get_run_seed()
		if value != 0:
			var code: String = ""
			if generator.has_method("get_run_seed_code"):
				code = generator.get_run_seed_code()
			_on_run_seed_ready(value, code)


func _on_run_seed_ready(run_seed: int, seed_code: String) -> void:
	_seed_value = run_seed
	_seed_code = seed_code
	_refresh_text()


func _refresh_text() -> void:
	if _seed_value == 0:
		text = placeholder_text
		return
	text = label_prefix + get_copy_string()


## Was tatsaechlich in die Zwischenablage geht.
func get_copy_string() -> String:
	if use_seed_code and _seed_code != "":
		return _seed_code
	return str(_seed_value)


func _on_pressed() -> void:
	if _seed_value == 0:
		return
	DisplayServer.clipboard_set(get_copy_string())
	text = feedback_text
	_feedback_timer = feedback_duration
	set_process(true)


func _process(delta: float) -> void:
	_feedback_timer -= delta
	if _feedback_timer <= 0.0:
		set_process(false)
		_refresh_text()
