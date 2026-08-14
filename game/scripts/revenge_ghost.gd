extends Node3D
class_name RevengeGhost

# ============================================================================
# RevengeGhost — vom Papp-Wahrsagerbrett beschworen.
# ============================================================================
# ITEM: ID_OUIJA_BOARD (item_catalog.gd). Nahkampftreffer haben 20 % Chance,
# einen Rachegeist zu beschwoeren (siehe item_behaviours.gd._apply_ouija_
# board()). Die ZIELAUSWAHL sitzt bewusst DORT und nicht hier: sie muss
# wissen, wo der Spieler steht und in welche Richtung er schaut (Gegner
# "hinter dem Spieler oder ausserhalb der Melee-Reichweite"), also Wissen,
# das zur Item-Logik gehoert, nicht zum Geist selbst. Dieses Script bekommt
# sein Ziel bereits fertig zugewiesen und kennt nur noch: hinfliegen,
# zuschlagen, verschwinden.
#
# WARUM KEINE .tscn: Wie Pickup, Tennisball und Laserstrahl in
# item_behaviours.gd wird die komplette Optik per Code gebaut — kein
# Asset-Import noetig, und ein neuer Rachegeist ist ein Funktionsaufruf,
# kein Datei-Anlege-Ritual (dieselbe Begruendung wie in item_catalog.gd).
#
# WARUM ER DURCH WAENDE FLIEGT: Er ist ein Geist. Die Zielauswahl draussen
# bevorzugt ohnehin GENAU die Gegner, die der Spieler im Nahkampf gerade
# NICHT erreicht (hinter sich oder zu weit weg) — ein Geist, der an einer
# Wand haengen bleibt, wuerde diesen Zweck direkt unterlaufen.

const CHANCE: float = 0.20
const DEFAULT_DAMAGE: float = 18.0
const SPEED: float = 16.0
const HIT_RANGE: float = 1.2
const LIFETIME: float = 4.0
const KNOCKBACK: float = 6.0
const WEAVE_AMPLITUDE: float = 0.6
const WEAVE_SPEED: float = 6.0
const COLOR: Color = Color(0.55, 0.90, 0.55, 0.75)
const DAMAGE_NUMBER_SCENE_PATH: String = "res://scenes/ui/damage_number.tscn"

@export var damage: float = DEFAULT_DAMAGE

var _target: Node3D = null
var _source: Node = null
var _weave_time: float = 0.0
var _age: float = 0.0
var _struck: bool = false

var _mesh: MeshInstance3D = null
var _light: OmniLight3D = null


## Bequemer Einzeiler fuer item_behaviours.gd — baut die Instanz komplett
## und haengt sie in die aktuelle Szene, ohne dass der Aufrufer irgendetwas
## ueber den inneren Aufbau wissen muss (gleiches Prinzip wie
## Pickup.create()/Pickup.create_item()).
static func spawn(player: Node3D, target: Node3D, dmg: float = DEFAULT_DAMAGE, source: Node = null) -> RevengeGhost:
	if player == null or not is_instance_valid(player):
		return null
	if target == null or not is_instance_valid(target):
		return null

	var ghost := RevengeGhost.new()
	ghost._target = target
	ghost._source = source if source != null else player
	ghost.damage = dmg

	var parent: Node = player.get_tree().current_scene
	if parent == null:
		parent = player.get_tree().get_root()
	parent.add_child(ghost)
	ghost.global_position = player.global_position + Vector3.UP * 1.6

	ghost._build_visual()
	return ghost


func _build_visual() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.4
	sphere.height = 0.8
	sphere.radial_segments = 10
	sphere.rings = 6

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = COLOR
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(COLOR.r, COLOR.g, COLOR.b)
	mat.emission_energy_multiplier = 2.2
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	_mesh = MeshInstance3D.new()
	_mesh.name = "Visual"
	_mesh.mesh = sphere
	_mesh.material_override = mat
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh)

	_light = OmniLight3D.new()
	_light.name = "GhostLight"
	_light.light_color = COLOR
	_light.light_energy = 1.3
	_light.omni_range = 3.0
	_light.shadow_enabled = false
	add_child(_light)


func _process(delta: float) -> void:
	_age += delta
	if _struck:
		return

	if _age >= LIFETIME or _target == null or not is_instance_valid(_target):
		_dissipate()
		return

	var to_target: Vector3 = (_target.global_position + Vector3.UP * 1.0) - global_position
	var dist: float = to_target.length()

	if dist <= HIT_RANGE:
		_strike()
		return

	var dir: Vector3 = to_target / maxf(dist, 0.001)
	global_position += dir * SPEED * delta

	# Leichtes Schweben quer zur Flugrichtung - ein Geist fliegt nicht
	# schnurgerade wie ein Pfeil.
	_weave_time += delta * WEAVE_SPEED
	var side: Vector3 = dir.cross(Vector3.UP)
	if side.length_squared() > 0.0001:
		global_position += side.normalized() * sin(_weave_time) * WEAVE_AMPLITUDE * delta

	if dir.length_squared() > 0.0001:
		look_at(global_position + dir, Vector3.UP)


func _strike() -> void:
	_struck = true

	if _target != null and is_instance_valid(_target):
		var health: Node = _target.find_child("Health", true, false)
		if health != null and health.has_method("take_damage"):
			health.take_damage(damage, _source)
			if _target.has_method("apply_knockback"):
				var push: Vector3 = _target.global_position - global_position
				push.y = 0.0
				if push.length_squared() > 0.0001:
					_target.apply_knockback(push.normalized() * KNOCKBACK)
			_spawn_hit_number()

	_dissipate()


## Schadenszahl in der Item-Farbe (damage_number.gd, Kind.ITEM) - derselbe
## Weg wie ItemBehaviours._spawn_item_damage_number(), hier lokal
## nachgebaut, weil dieses Script kein Kind von ItemBehaviours ist.
func _spawn_hit_number() -> void:
	if not ResourceLoader.exists(DAMAGE_NUMBER_SCENE_PATH):
		return
	var scene: PackedScene = load(DAMAGE_NUMBER_SCENE_PATH)
	var number: Node = scene.instantiate()
	get_tree().current_scene.add_child(number)
	(number as Node3D).global_position = _target.global_position + Vector3.UP * 1.8
	if number.has_method("show_item_damage"):
		number.show_item_damage(damage)
	elif number.has_method("show_damage"):
		number.show_damage(damage)


func _dissipate() -> void:
	set_process(false)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	if _mesh != null and is_instance_valid(_mesh):
		tween.tween_property(_mesh, "scale", Vector3.ZERO, 0.3)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if _light != null and is_instance_valid(_light):
		tween.tween_property(_light, "light_energy", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
