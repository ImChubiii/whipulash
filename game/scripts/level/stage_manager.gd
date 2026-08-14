# res://scripts/level/stage_manager.gd
extends Node

# ============================================================================
# StageManager — Etagenwechsel (Autoload "Stages")
# ============================================================================
# PHASE 3.2. Beim Betreten der GoalZone wird die naechste Etage gebaut:
# neues Layout, neues Thema, staerkere Gegner. Der Spieler behaelt dabei
# ALLES — HP, Inventar, Items, Muenzen, Bomben, aktive Slots.
#
# ############################################################################
# WARUM DER SPIELERZUSTAND VON SELBST ERHALTEN BLEIBT
# ############################################################################
# Der entscheidende Punkt ist, was NICHT passiert: es gibt kein
# reload_current_scene(). Items, PartyManager, PlayerStats und der Spieler-
# Node ueberleben den Etagenwechsel unveraendert; nur die Raeume werden
# ausgetauscht.
#
# Das ist der Unterschied zu RunRestart (run_restart.gd): DER laedt die Szene
# neu und raeumt bewusst alles ab. Wer hier versehentlich denselben Weg geht,
# schickt den Spieler mit leerem Inventar in Etage 2.
#
# ############################################################################
# REGISTRIEREN
# ############################################################################
# Project Settings -> Autoload
#   Pfad: res://scripts/level/stage_manager.gd
#   Name: Stages
#
# Ohne diesen Eintrag faellt goal_zone.gd auf den alten WinScreen zurueck —
# sichtbar im Log als "[StageManager] Autoload 'Stages' nicht gefunden".

signal stage_advancing(from_stage: int, to_stage: int)
signal stage_ready(stage: int, theme_name: String)

const GENERATOR_GROUP: String = "level_generator"
const PLAYER_GROUP: String = "player"

## Nach so vielen Etagen ist der Run gewonnen. 0 = endlos.
##
## WARUM UEBERHAUPT EIN DECKEL: die Speedrun-Bestenliste braucht einen
## definierten Endpunkt, sonst ist keine Zeit mit einer anderen vergleichbar.
@export var final_stage: int = 5

## Kurze Schwarzblende zwischen den Etagen. Verdeckt das Aufbauen der Raeume
## und das Umsetzen des Spielers.
@export var transition_duration: float = 0.65

var _current_theme: StageTheme = null
var _busy: bool = false


func _ready() -> void:
	# process_mode ALWAYS: der Etagenwechsel muss auch dann durchlaufen,
	# wenn irgendetwas den Baum kurz pausiert (Hit-Stop von Juice setzt
	# Engine.time_scale, aber ein Pause-Menue waehrend des Uebergangs wuerde
	# den Tween sonst einfrieren und den Spieler im Schwarzbild lassen).
	process_mode = Node.PROCESS_MODE_ALWAYS


func get_current_theme() -> StageTheme:
	if _current_theme == null:
		_current_theme = StageTheme.for_stage(get_current_stage())
	return _current_theme


func get_current_stage() -> int:
	var gen: Node = _find_generator()
	if gen != null and gen.has_method("get_current_stage"):
		return int(gen.get_current_stage())
	return 1


func _find_generator() -> Node:
	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		return null
	return found[0]


func _find_player() -> Node3D:
	# Gruppe statt find_child("Player"): PartyManager tauscht die Spieler-
	# Instanz beim Charakterwechsel aus, ein Namensfund waere danach eine
	# tote Referenz.
	var found: Array[Node] = get_tree().get_nodes_in_group(PLAYER_GROUP)
	for node: Node in found:
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


## Wird von goal_zone.gd gerufen.
##
## Rueckgabe false = kein Wechsel moeglich (letzte Etage erreicht oder gerade
## schon ein Wechsel unterwegs). Die GoalZone zeigt dann den WinScreen.
func advance_stage() -> bool:
	if _busy:
		return true

	var gen: Node = _find_generator()
	if gen == null:
		push_warning("[StageManager] Kein LevelGenerator gefunden — Etagenwechsel nicht moeglich.")
		return false

	var from_stage: int = get_current_stage()
	if final_stage > 0 and from_stage >= final_stage:
		print("[StageManager] Letzte Etage (%d) abgeschlossen — Run gewonnen." % from_stage)
		return false

	_busy = true
	_do_advance(gen, from_stage)
	return true


func _do_advance(gen: Node, from_stage: int) -> void:
	var to_stage: int = from_stage + 1
	stage_advancing.emit(from_stage, to_stage)
	print("[StageManager] Etagenwechsel %d -> %d" % [from_stage, to_stage])

	var overlay: ColorRect = _build_fade_overlay()
	await _fade(overlay, 0.0, 1.0, transition_duration * 0.45)

	# --- Aufraeumen, was an die ALTE Etage gebunden ist ------------------
	# Status-Effekte des Spielers: ein Brand aus Etage 1 soll nicht in
	# Etage 2 weiterticken. HP, Items und Stats bleiben ausdruecklich.
	var player: Node3D = _find_player()
	if player != null:
		var effects: Node = player.get_node_or_null("StatusEffectManager")
		if effects != null and effects.has_method("clear_all"):
			effects.clear_all()

	# Herumliegende Drops und Hazards der alten Etage entfernen — sie haengen
	# an Raeumen, die gleich verschwinden.
	for group_name: String in ["pickups", "hazard", "projectiles", "floor_debris"]:
		for node: Node in get_tree().get_nodes_in_group(group_name):
			if is_instance_valid(node):
				node.queue_free()

	# --- Neue Etage bauen -------------------------------------------------
	if gen.has_method("generate_stage"):
		gen.generate_stage(to_stage)
	else:
		push_error("[StageManager] LevelGenerator kennt generate_stage() nicht — bitte die gepatchte level_generator.gd einspielen.")

	# Ein Frame Pause: die Raeume sind erst nach dem naechsten
	# Physik-Frame vollstaendig im Baum (Kollisionen, Areas).
	await get_tree().process_frame
	await get_tree().physics_frame

	_current_theme = StageTheme.for_stage(to_stage)
	_apply_environment(_current_theme)

	_move_player_to_start(gen)

	await _fade(overlay, 1.0, 0.0, transition_duration * 0.55)
	if is_instance_valid(overlay):
		overlay.queue_free()

	_busy = false
	stage_ready.emit(to_stage, _current_theme.theme_name)
	print("[StageManager] Etage %d bereit (Thema: %s)." % [to_stage, _current_theme.theme_name])


## Setzt den Spieler in den Startraum der neuen Etage.
##
## WICHTIG: global_position DIREKT setzen und velocity nullen. Ein
## CharacterBody3D, der mit Restgeschwindigkeit umgesetzt wird, schiebt sich
## im naechsten Frame durch die frisch gebaute Wand.
func _move_player_to_start(gen: Node) -> void:
	var player: Node3D = _find_player()
	if player == null:
		push_warning("[StageManager] Kein Spieler in Gruppe 'player' gefunden.")
		return

	var target: Vector3 = Vector3.ZERO
	if gen.has_method("get_start_room_spawn"):
		target = gen.get_start_room_spawn()

	player.global_position = target
	if player is CharacterBody3D:
		(player as CharacterBody3D).velocity = Vector3.ZERO


## Legt Nebel und Umgebungslicht der Etage auf die WorldEnvironment.
##
## Fehlt eine, passiert nichts — das ist kein Fehlerfall, sondern der
## Normalzustand in Testszenen ohne eigenes Environment.
func _apply_environment(theme: StageTheme) -> void:
	if theme == null:
		return
	var envs: Array[Node] = []
	_collect_world_environments(get_tree().get_root(), envs)
	for node: Node in envs:
		var world := node as WorldEnvironment
		if world == null or world.environment == null:
			continue
		# Duplizieren: die Environment-Resource kann zwischen Szenen geteilt
		# sein, und eine geaenderte Nebelfarbe wuerde sonst im Hauptmenue
		# nachwirken.
		var env: Environment = world.environment.duplicate()
		env.fog_enabled = true
		env.fog_light_color = theme.fog_color
		env.fog_density = theme.fog_density
		env.ambient_light_energy = theme.ambient_energy
		world.environment = env


func _collect_world_environments(node: Node, out: Array[Node]) -> void:
	if node is WorldEnvironment:
		out.append(node)
	for child: Node in node.get_children():
		_collect_world_environments(child, out)


## Schwarzblende. Wird im Code gebaut statt als Szene, damit der
## Etagenwechsel keine zusaetzliche .tscn-Abhaengigkeit hat.
func _build_fade_overlay() -> ColorRect:
	var layer := CanvasLayer.new()
	layer.layer = 128
	layer.name = "StageTransitionLayer"

	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)

	get_tree().get_root().add_child(layer)
	# Der Aufrufer raeumt das RECT ab; damit die Ebene mitgeht, haengt sie als
	# Elternknoten daran und wird ueber owner-freie queue_free() mit entfernt.
	rect.tree_exited.connect(func() -> void:
		if is_instance_valid(layer):
			layer.queue_free()
	)
	return rect


func _fade(rect: ColorRect, from_alpha: float, to_alpha: float, duration: float) -> void:
	if not is_instance_valid(rect):
		return
	rect.color = Color(0, 0, 0, from_alpha)
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(rect, "color:a", to_alpha, maxf(duration, 0.01))
	await tween.finished
