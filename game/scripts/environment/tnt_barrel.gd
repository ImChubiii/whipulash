extends StaticBody3D
class_name TntBarrel

# ============================================================================
# TntBarrel — zerstoerbares Fass. Bei JEDEM Treffer (nicht erst bei
# depletiertem HP-Pool) startet eine kurze Zuendschnur, danach explodiert es
# per Bomb (bomb.gd) - identische VFX-Kaskade/AOE-Schaden/Chain-Reaction wie
# ein regulaer geworfener Sprengsatz. Gleicher "spawn+trigger"-Aufbau wie
# combat_karina.gd::_spawn_decloak_explosion(), nur mit echtem fuse_time
# statt trigger_now() - das ist die Zuendschnur, die das Ticket verlangt.
# ============================================================================
# Reagiert auf Health.damage_taken (JEDE tatsaechliche, nicht-invulnerable
# Schadensmenge - siehe health.gd), nicht auf Health.died: ein echter HP-Pool
# wuerde erst nach genug Treffern ausloesen, hier soll ein einziger Treffer
# reichen. max_health bleibt deshalb absichtlich winzig (siehe _build_health())
# - damage_taken ist trotzdem der robustere Ausloeser, falls ein sehr kleiner
# Streuschaden (z.B. Explosions-Falloff am Radius-Rand) den 1-HP-Pool knapp
# verfehlen wuerde.
#
# Gleiche Health-Kindnode-Begruendung wie breakable_prop.gd (siehe dortiger
# Kopfkommentar): Hitscan.fire()/Hitbox/Bomb-Explosionsschaden suchen
# ausschliesslich per find_child("Health", ...) nach einem Ziel. Bleibt auf
# dem Standard-Kollisionslayer (1 = "World"), "breakables"-Gruppe wie
# breakable_prop.gd - gleiche Auto-Target-Nachrangigkeit, siehe enemy_query.gd.

const KAYKIT_BARREL_PATH: String = "res://assets/environments/KayKit_Dungeon_Pack_1.1_FREE/Assets/gltf/barrel_large.gltf"
const _FUSE_TIME: float = 0.2
const _WARN_TINT: Color = Color(1.0, 0.35, 0.25)
const _PROP_IMPORT_SCALE: float = 1.0

@export var explosion_radius: float = 10.0
@export var explosion_damage: float = 60.0

var _health: Health = null
var _visual: Node3D = null
var _armed: bool = false


func _ready() -> void:
	add_to_group("breakables")
	_build_visual()
	_build_collision()
	_build_health()


func _build_visual() -> void:
	var scene: PackedScene = load(KAYKIT_BARREL_PATH) as PackedScene
	if scene == null:
		push_warning("TntBarrel: KayKit-Fass nicht gefunden unter %s" % KAYKIT_BARREL_PATH)
		return
	_visual = scene.instantiate() as Node3D
	if _visual == null:
		return
	add_child(_visual)
	_visual.scale *= _PROP_IMPORT_SCALE
	_tint_visual(_visual)


## Faerbt jedes Mesh-Material warnend rot statt der KayKit-Standardfarbe -
## dieselbe duplicate()-vor-Farbaenderung-Regel wie
## room_instance.gd::_psxify_prop_materials(): ein Surface-Override-Material
## PRO Instanz, sonst faerbte das Faerben EINES Fasses rueckwirkend jede
## andere Instanz derselben geteilten PackedScene mit.
func _tint_visual(node: Node3D) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			for surface: int in range(mi.mesh.get_surface_count()):
				var mat := StandardMaterial3D.new()
				mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				mat.albedo_color = _WARN_TINT
				mat.emission_enabled = true
				mat.emission = _WARN_TINT
				mat.emission_energy_multiplier = 0.5
				mi.set_surface_override_material(surface, mat)
	for child: Node in node.get_children():
		if child is Node3D:
			_tint_visual(child as Node3D)


func _build_collision() -> void:
	var shape := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 0.45
	cyl.height = 1.0
	shape.shape = cyl
	shape.position = Vector3.UP * 0.5
	add_child(shape)


func _build_health() -> void:
	_health = Health.new()
	_health.name = "Health"
	_health.max_health = 1.0
	_health.regen_enabled = false
	add_child(_health)
	_health.damage_taken.connect(_on_damage_taken)


func _on_damage_taken(_amount: float, _source: Node3D) -> void:
	if _armed:
		return
	_armed = true
	_flash_warning()

	var bomb := Bomb.new()
	bomb.fuse_time = _FUSE_TIME
	bomb.explosion_radius = explosion_radius
	bomb.damage = explosion_damage
	bomb.thrower = self
	get_tree().current_scene.add_child(bomb)
	# Kein launch() - das Fass bleibt stehen, die Bombe zuendet ueber ihre
	# eigene fuse_time-Countdown-Logik statt sofortigem trigger_now(), genau
	# das gibt die 0.2s-Zuendschnur.
	bomb.global_position = global_position + Vector3.UP * 0.5
	bomb.exploded.connect(_on_bomb_exploded)


func _on_bomb_exploded(_position: Vector3) -> void:
	queue_free()


## Kurzes Aufblitzen/Pulsieren waehrend der 0.2s-Lunte - das einzige
## Vorwarn-Signal, das in dieser kurzen Zeit ueberhaupt wahrnehmbar ist.
func _flash_warning() -> void:
	var tween: Tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "scale", Vector3.ONE * 1.08, _FUSE_TIME / 6.0)
	tween.tween_property(self, "scale", Vector3.ONE, _FUSE_TIME / 6.0)
