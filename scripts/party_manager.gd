extends Node

# AUTOLOAD — Name: PartyManager
# Projekt -> Projekteinstellungen -> Autoload -> res://scripts/party_manager.gd
#
# Verwaltet die 4 Party-Mitglieder, ihren HP-Stand und wer gerade aktiv ist.
# Inaktive Charaktere haben KEINE Health-Node in der Szene — ihr HP-Stand
# wird hier gespiegelt, damit das HUD alle 4 Bars anzeigen kann.

signal party_changed
signal active_character_changed(index: int)
signal member_health_changed(index: int, current: float, max_hp: float)

const MAX_PARTY_SIZE: int = 4

var ability_sets: Array[AbilitySet] = []

var _current_health: Array[float] = []
var _max_health: Array[float] = []
var _active_index: int = 0

var player: CharacterBody3D = null
var _player_health: Health = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Wird vom Level (oder einem Charakter-Auswahl-Menue) aufgerufen.
func setup_party(sets: Array[AbilitySet]) -> void:
	ability_sets.clear()
	_current_health.clear()
	_max_health.clear()

	for i: int in range(min(sets.size(), MAX_PARTY_SIZE)):
		var set: AbilitySet = sets[i]
		if set == null:
			continue
		ability_sets.append(set)
		_max_health.append(set.max_health)
		_current_health.append(set.max_health)

	_active_index = 0
	party_changed.emit()

# Verbindet den echten Player-Node mit dem aktiven Party-Slot.
func register_player(p: CharacterBody3D) -> void:
	player = p
	var h := p.find_child("Health", true, false)
	if h and h is Health:
		_player_health = h
		if not _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.connect(_on_player_health_changed)

	_apply_active_set_to_player()

func _on_player_health_changed(current: float, max_hp: float) -> void:
	if _active_index < 0 or _active_index >= _current_health.size():
		return
	_current_health[_active_index] = current
	_max_health[_active_index] = max_hp
	member_health_changed.emit(_active_index, current, max_hp)

func switch_to(index: int) -> void:
	if index < 0 or index >= ability_sets.size():
		return
	if index == _active_index:
		return
	if not is_member_alive(index):
		return

	_active_index = index
	_apply_active_set_to_player()
	active_character_changed.emit(index)

# Uebertraegt AbilitySet + gespeicherten HP-Stand auf den Player-Node.
func _apply_active_set_to_player() -> void:
	if player == null:
		return
	var set: AbilitySet = get_active_set()
	if set == null:
		return

	var combat := player.find_child("Combat", true, false)
	if combat and combat is Combat:
		combat.apply_ability_set(set)

	if _player_health and _active_index < _max_health.size():
		_player_health.max_health = _max_health[_active_index]
		_player_health.current_health = _current_health[_active_index]
		_player_health.health_changed.emit(
			_player_health.current_health,
			_player_health.max_health
		)

func get_active_index() -> int:
	return _active_index

func get_active_set() -> AbilitySet:
	if _active_index >= 0 and _active_index < ability_sets.size():
		return ability_sets[_active_index]
	return null

func get_set(index: int) -> AbilitySet:
	if index >= 0 and index < ability_sets.size():
		return ability_sets[index]
	return null

func get_party_size() -> int:
	return ability_sets.size()

func get_member_health(index: int) -> float:
	if index >= 0 and index < _current_health.size():
		return _current_health[index]
	return 0.0

func get_member_max_health(index: int) -> float:
	if index >= 0 and index < _max_health.size():
		return _max_health[index]
	return 1.0

func is_member_alive(index: int) -> bool:
	return get_member_health(index) > 0.0

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	for i: int in range(MAX_PARTY_SIZE):
		var action: String = "switch_char_%d" % (i + 1)
		if InputMap.has_action(action) and event.is_action_pressed(action):
			switch_to(i)
			return
