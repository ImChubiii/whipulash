extends CustomEnemyBase
class_name ShieldDrone

# ============================================================================
# Schild-Drohne — fliegender Support-Gegner.
# ============================================================================
# Greift den Spieler nie direkt an. Schwebt ueber dem Schlachtfeld und
# verbindet sich per Strahl mit bis zu MAX_SHIELDED anderen Gegnern aus der
# Gruppe "enemies" (nicht sich selbst). Jeder Verbundene bekommt den
# "shield"-Status-Effekt (siehe scripts/status_effects/shield.gd): +25 %
# Maximal-HP, ein etwas groesseres Modell und eine blau schwankende Aura -
# die eigentliche Wirkung sitzt in custom_enemy_base.gd/enemy_ai.gd
# (_apply_shield_visual/_remove_shield_visual), je nachdem was fuer ein
# Gegnertyp verbunden ist.
#
# Fliegt ausserhalb der Nahkampf-Reichweite und muss fuer einen Raum-Clear
# NICHT getoetet werden (siehe _despawn_if_room_clear() unten) - sie ist
# reiner Support, kein Ziel im eigentlichen Sinn. Wird der Raum trotzdem
# leergeraeumt (alle "echten" Gegner tot), verschwindet sie von selbst.

const MAX_SHIELDED: int = 3
const RESCAN_INTERVAL: float = 1.0
const SHIELD_REFRESH_INTERVAL: float = 0.5
## Deutlich laenger als SHIELD_REFRESH_INTERVAL: faellt die Drohne kurz aus
## der Reichweite oder haengt ein Frame, soll der Schild NICHT sofort
## abreissen - siehe shield.gd fuer das Refresh-Prinzip.
const SHIELD_DURATION: float = 1.4
const CLEAR_CHECK_INTERVAL: float = 1.0

var hover_height: float = 9.0
var hover_radius: float = 3.0
var hover_speed: float = 0.5
var link_range: float = 22.0

var _anchor: Vector3 = Vector3.ZERO
var _angle: float = 0.0
var _rescan_timer: float = 0.0
var _shield_tick_timer: float = 0.0
var _clear_check_timer: float = 0.0
var _allies: Array[Node3D] = []
var _beams: Dictionary = {}  # instance_id (int) -> Dictionary (siehe _create_beam_visual)


func _configure() -> void:
	display_name = "Schild-Drohne"
	max_health = 45.0


func _build() -> void:
	_build_visual()
	_add_box_collision(Vector3(1.2, 1.0, 1.2))
	_angle = randf() * TAU


func _build_visual() -> void:
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.9
	disc_mesh.bottom_radius = 0.9
	disc_mesh.height = 0.25
	var disc := MeshInstance3D.new()
	disc.mesh = disc_mesh
	disc.material_override = _make_unshaded_material(Color(0.3, 0.85, 1.0), 1.4)
	visual_root.add_child(disc)

	var light := OmniLight3D.new()
	light.light_color = Color(0.3, 0.85, 1.0)
	light.light_energy = 1.0
	light.omni_range = 5.0
	light.shadow_enabled = false
	visual_root.add_child(light)


func _physics_process(delta: float) -> void:
	# Anker erst HIER (nicht in _build()) einlesen: die aufrufende Stelle
	# (enemy_sandbox_room.gd) setzt global_transform ERST NACH add_child(),
	# also nach _ready()/_build() - zu dem Zeitpunkt stuende hier noch (0,0,0).
	if _anchor == Vector3.ZERO:
		_anchor = global_position

	_angle += hover_speed * delta
	var offset := Vector3(cos(_angle), sin(_angle * 1.7) * 0.3, sin(_angle)) * hover_radius
	global_position = _anchor + Vector3.UP * hover_height + offset

	_rescan_timer -= delta
	if _rescan_timer <= 0.0:
		_rescan_timer = RESCAN_INTERVAL
		_rescan_allies()

	_update_beams(delta)

	_shield_tick_timer -= delta
	if _shield_tick_timer <= 0.0:
		_shield_tick_timer = SHIELD_REFRESH_INTERVAL
		_refresh_shields()

	_clear_check_timer -= delta
	if _clear_check_timer <= 0.0:
		_clear_check_timer = CLEAR_CHECK_INTERVAL
		_despawn_if_room_clear()


func _rescan_allies() -> void:
	# Bereits verbundene, noch gueltige Allies zuerst behalten - sonst
	# springt der Strahl bei jedem Rescan auf ein neues Ziel, nur weil kurz
	# ein naeher liegender Gegner vorbeigelaufen ist.
	var kept: Array[Node3D] = []
	for ally: Node3D in _allies:
		if is_instance_valid(ally) and _is_valid_ally(ally) and global_position.distance_to(ally.global_position) <= link_range:
			kept.append(ally)

	if kept.size() < MAX_SHIELDED:
		var candidates: Array[Node3D] = []
		for node: Node in get_tree().get_nodes_in_group("enemies"):
			if not (node is Node3D) or node in kept or not _is_valid_ally(node as Node3D):
				continue
			var dist: float = global_position.distance_to((node as Node3D).global_position)
			if dist <= link_range:
				candidates.append(node as Node3D)
		candidates.sort_custom(func(a: Node3D, b: Node3D) -> bool:
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		for c: Node3D in candidates:
			if kept.size() >= MAX_SHIELDED:
				break
			kept.append(c)

	_allies = kept
	_sync_beams()


func _is_valid_ally(node: Node3D) -> bool:
	if node == self or not is_instance_valid(node):
		return false
	var candidate_health := node.find_child("Health", true, false) as Health
	return candidate_health != null and candidate_health.is_alive()


func _sync_beams() -> void:
	var wanted_ids: Dictionary = {}
	for ally: Node3D in _allies:
		wanted_ids[ally.get_instance_id()] = true

	for id: int in _beams.keys().duplicate():
		if not wanted_ids.has(id):
			_free_beam_visual(_beams[id])
			_beams.erase(id)

	for ally: Node3D in _allies:
		var id: int = ally.get_instance_id()
		if not _beams.has(id):
			_beams[id] = _create_beam_visual(Color(0.3, 0.85, 1.0))


func _update_beams(delta: float) -> void:
	for ally: Node3D in _allies:
		if not is_instance_valid(ally):
			continue
		var id: int = ally.get_instance_id()
		if not _beams.has(id):
			continue
		_update_beam_visual(_beams[id], global_position, ally.global_position + Vector3.UP, delta)


func _refresh_shields() -> void:
	for ally: Node3D in _allies:
		if not is_instance_valid(ally):
			continue
		StatusShield.apply(ally, SHIELD_DURATION, self)


## Support-Flieger muessen fuer den Raum-Clear nicht sterben (siehe
## Kopfkommentar) - sobald ausser fliegenden Support-Typen (sich selbst
## eingeschlossen) niemand mehr in "enemies" steht, verschwindet die Drohne
## von selbst.
func _despawn_if_room_clear() -> void:
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if node == self or not (node is Node3D):
			continue
		if node is ShieldDrone or node is PlasmaBeamBot:
			continue
		return
	despawn()


func _cleanup_effects() -> void:
	for beam: Dictionary in _beams.values():
		_free_beam_visual(beam)
	_beams.clear()
