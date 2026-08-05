extends Node3D
class_name VictoryTrophy

## Goldener Zylinder, der nach dem Bosskampf in die Mitte des Bossraums
## faellt. Aufsammeln -> WinScreen.
##
## KEINE KOLLISION (wie gefordert): Der sichtbare Zylinder ist ein reines
## MeshInstance3D ohne StaticBody/CollisionShape - man kann durch ihn
## hindurchlaufen. Das Einsammeln laeuft ueber eine separate Area3D, die
## NUR monitoring betreibt (collision_layer = 0), also selbst nichts
## blockiert und von keinem anderen Body als Hindernis gesehen wird.
##
## FALLANIMATION: bewusst per Tween statt per RigidBody3D. Ein Rigidbody
## braeuchte einen Boden zum Aufkommen - der ist im Bossraum aber nicht
## garantiert (Lava, Loecher, Rampen). Der Tween landet immer exakt auf
## der vorgesehenen Hoehe.

signal collected

## Aus welcher Hoehe UEBER der Zielposition der Zylinder herunterfaellt.
@export var drop_height: float = 14.0
@export var drop_duration: float = 1.1

## Erst NACH dem Aufkommen einsammelbar - sonst koennte man ihn im
## Vorbeilaufen \"aus der Luft\" mitnehmen, bevor die Belohnung ueberhaupt
## sichtbar war.
@export var arm_delay_after_landing: float = 0.15

@export var pickup_radius: float = 3.0

## --- Bodensuche ----------------------------------------------------------
## Statt blind auf der uebergebenen Y-Hoehe zu landen, tastet die Trophaee
## einmalig nach unten und legt sich auf die erste getroffene Flaeche.
@export var snap_to_floor: bool = true
@export var floor_probe_up: float = 4.0
@export var floor_probe_down: float = 40.0
@export var floor_clearance: float = 0.15
## Nur Welt-Geometrie (Layer 1 = Default/Static) abtasten.
@export_flags_3d_physics var floor_probe_mask: int = 1

## --- Optik ---------------------------------------------------------------
@export var trophy_color: Color = Color(1.0, 0.82, 0.22)
@export var emission_energy: float = 2.4
@export var cylinder_radius: float = 1.1
@export var cylinder_height: float = 3.2

## Idle-Animation nach der Landung.
@export var spin_speed_degrees: float = 55.0
@export var bob_height: float = 0.35
@export var bob_speed: float = 2.0

## Lichtsaeule nach oben - macht die Trophaee auch quer durch den Raum
## und auf der Minimap-Draufsicht sofort sichtbar.
@export var beam_enabled: bool = true
@export var beam_height: float = 40.0
@export var beam_radius: float = 0.35
@export_range(0.0, 1.0) var beam_alpha: float = 0.22

var _mesh: MeshInstance3D = null
var _beam: MeshInstance3D = null
var _area: Area3D = null
var _armed: bool = false
var _collected: bool = false
var _landed: bool = false
var _bob_time: float = 0.0
var _rest_y: float = 0.0
var _drop_started: bool = false


## BUGFIX "Trophaee liegt unter dem Boden":
##
## Der LevelGenerator instanziiert die Trophaee, haengt sie per add_child()
## ein und setzt ERST DANACH global_position. add_child() loest _ready()
## aber SOFORT aus - zu diesem Zeitpunkt steht die Trophaee noch auf
## (0, 0, 0). Frueher wurde hier direkt _rest_y = global_position.y
## gelesen (also 0.0) und der Fall-Tween sofort gestartet. Der Tween
## animiert "global_position:y" und ueberschreibt damit jede Positionierung,
## die der Generator danach vornimmt - die Trophaee landet immer auf
## Welt-Y 0.
##
## Sichtbar wird das nur, wenn der Bossraum NICHT auf Hoehenstufe 0 liegt:
## bei elevation = 1 (Welt-Y 6.0) faellt die Trophaee 6 Meter unter den
## Bossraumboden. Das Log meldete trotzdem "gespawnt bei (-144.0, 6.3, 0.0)",
## weil dort die GEWOLLTE Position steht, nicht die, auf der der Tween endet.
##
## Fix: Der Fall startet nicht mehr blind in _ready(), sondern entweder
## explizit ueber start_drop_at() (Generator-Weg) oder - falls die Szene
## von Hand ins Level gesetzt wurde - im naechsten Frame, wenn die
## Position garantiert steht.
func _ready() -> void:
	_build_visuals()
	_build_pickup_area()
	call_deferred("_autostart_drop")


## Setzt die Zielposition UND startet den Fall. Vom LevelGenerator nach
## add_child() aufzurufen. Ersetzt das fruehere "global_position setzen und
## hoffen, dass _ready() schon durch ist".
func start_drop_at(world_position: Vector3) -> void:
	if _drop_started:
		return
	_drop_started = true

	var target: Vector3 = world_position
	if snap_to_floor:
		target = _snapped_to_floor(world_position)

	global_position = target
	_rest_y = target.y
	_play_drop()


## Fallback fuer von Hand platzierte Trophaeen: laeuft einen Frame nach
## _ready(), also nachdem der Editor/Parent die Transform gesetzt hat.
func _autostart_drop() -> void:
	if _drop_started:
		return
	start_drop_at(global_position)


## Sucht den echten Boden unter der Zielposition. Schuetzt gegen Rampen,
## Podeste und leicht verschobene Raum-Urspruenge - ohne den Raycast
## wuerde die Trophaee bei jeder Bodenhoehe != Raum-Ursprung wieder
## daneben landen. Findet der Strahl nichts, bleibt die uebergebene
## Position unveraendert.
func _snapped_to_floor(from_position: Vector3) -> Vector3:
	var space := get_world_3d().direct_space_state
	if space == null:
		return from_position

	var query := PhysicsRayQueryParameters3D.create(
		from_position + Vector3(0.0, floor_probe_up, 0.0),
		from_position - Vector3(0.0, floor_probe_down, 0.0)
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = floor_probe_mask

	var hit: Dictionary = space.intersect_ray(query)
	if hit.is_empty():
		return from_position

	var point: Vector3 = hit["position"]
	return Vector3(from_position.x, point.y + floor_clearance, from_position.z)


func _build_visuals() -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = cylinder_radius
	cylinder.bottom_radius = cylinder_radius
	cylinder.height = cylinder_height

	var mat := StandardMaterial3D.new()
	mat.albedo_color = trophy_color
	mat.emission_enabled = true
	mat.emission = trophy_color
	mat.emission_energy_multiplier = emission_energy
	mat.metallic = 0.8
	mat.roughness = 0.25

	_mesh = MeshInstance3D.new()
	_mesh.name = "TrophyMesh"
	_mesh.mesh = cylinder
	# material_override statt surface_material_override - Vorrangregel:
	# material_override gewinnt IMMER, also wird hier auch genau das
	# gesetzt, was sichtbar sein soll.
	_mesh.material_override = mat
	_mesh.position = Vector3(0.0, cylinder_height * 0.5, 0.0)
	add_child(_mesh)

	if not beam_enabled:
		return

	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = beam_radius
	beam_mesh.bottom_radius = beam_radius
	beam_mesh.height = beam_height

	var beam_mat := StandardMaterial3D.new()
	beam_mat.albedo_color = Color(trophy_color.r, trophy_color.g, trophy_color.b, beam_alpha)
	beam_mat.emission_enabled = true
	beam_mat.emission = trophy_color
	beam_mat.emission_energy_multiplier = emission_energy * 0.6
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Von innen UND aussen sichtbar - sonst verschwindet die Saeule, sobald
	# man in ihr steht.
	beam_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	_beam = MeshInstance3D.new()
	_beam.name = "TrophyBeam"
	_beam.mesh = beam_mesh
	_beam.material_override = beam_mat
	_beam.position = Vector3(0.0, beam_height * 0.5, 0.0)
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_beam)


## collision_layer = 0 -> die Area ist selbst fuer nichts ein Hindernis.
## collision_mask = 1 -> sie sieht nur den Player-Layer.
func _build_pickup_area() -> void:
	_area = Area3D.new()
	_area.name = "PickupArea"
	_area.collision_layer = 0
	_area.collision_mask = 1
	_area.monitorable = false
	add_child(_area)

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = pickup_radius
	shape.shape = sphere
	shape.position = Vector3(0.0, cylinder_height * 0.5, 0.0)
	_area.add_child(shape)

	_area.body_entered.connect(_on_body_entered)


func _play_drop() -> void:
	global_position.y = _rest_y + drop_height

	var tween := create_tween()
	tween.tween_property(self, "global_position:y", _rest_y, drop_duration)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void:
		_landed = true
	)
	tween.tween_interval(arm_delay_after_landing)
	tween.tween_callback(func() -> void:
		_armed = true
		# Falls der Spieler beim Landen bereits IN der Area steht, feuert
		# body_entered nie - deshalb hier einmal aktiv nachsehen.
		_check_overlap_now()
	)


func _check_overlap_now() -> void:
	if _area == null:
		return
	for body in _area.get_overlapping_bodies():
		if _is_player(body):
			_collect()
			return


func _process(delta: float) -> void:
	if _collected or not _landed:
		return

	rotate_y(deg_to_rad(spin_speed_degrees) * delta)

	_bob_time += delta * bob_speed
	if _mesh:
		_mesh.position.y = cylinder_height * 0.5 + sin(_bob_time) * bob_height


func _is_player(body: Node) -> bool:
	if body == null:
		return false
	if body.is_in_group(PartyManager.PLAYER_GROUP):
		return true
	# Fallback wie in goal_zone.gd: der Player traegt set_target() aus dem
	# Lock-On-System.
	return body.has_method("set_target")


func _on_body_entered(body: Node3D) -> void:
	if not _armed or _collected:
		return
	if not _is_player(body):
		return
	_collect()


func _collect() -> void:
	if _collected:
		return
	_collected = true
	collected.emit()

	if _beam:
		_beam.visible = false

	# Kurzer Einsammel-Pop, DANN erst der WinScreen - sonst waere der
	# Effekt hinter dem sofort erscheinenden Panel unsichtbar.
	if _mesh:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(_mesh, "scale", Vector3(1.6, 0.2, 1.6), 0.18)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_mesh, "position:y", _mesh.position.y + 3.0, 0.25)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tween.finished

	# BUGFIX "Normal-Modus geht nach der Trophaee nicht weiter": vorher wurde
	# hier IMMER _show_win_screen() gerufen. Gleiches Muster wie
	# goal_zone.gd:_on_body_entered() - erst versuchen, in die naechste Etage
	# zu wechseln; der WinScreen kommt nur, wenn es keine naechste Etage mehr
	# gibt (Stages.advance_stage() gibt dann false zurueck, z.B. bei
	# final_stage = 1 im Speedrun-Modus oder auf der letzten Etage im Normal-
	# Modus).
	var stages: Node = get_node_or_null("/root/Stages")
	if stages != null and stages.has_method("advance_stage"):
		if stages.advance_stage():
			queue_free()
			return
	else:
		push_warning("VictoryTrophy: Autoload 'Stages' nicht gefunden — es geht direkt zum WinScreen.")

	_show_win_screen()
	queue_free()


func _show_win_screen() -> void:
	var win_screen := get_tree().get_root().find_child("WinScreen", true, false)
	if win_screen and win_screen.has_method("show_win"):
		win_screen.show_win()
	else:
		push_warning("VictoryTrophy: Konnte keinen Node namens 'WinScreen' finden.")


