extends Area3D
class_name SwitchPad

# ============================================================================
# SwitchPad — ein einzelner Bodenschalter der Schalter-Puzzle-Arena
# (Blueprint Nr. 2, "Switch Arena"). Aktiviert sich EINMALIG und dauerhaft,
# sobald der Spieler ihn beruehrt, und meldet das per Signal an
# room_switch_arena.gd weiter.
# ============================================================================
# collision_mask = 1 (Spieler-Layer): derselbe Maskenwert, den pit_floor.gd
# bereits fuer "trifft garantiert den Spieler" benutzt - kein zusaetzlicher
# Typ-Check auf dem Body noetig.

signal activated

@export var color_off: Color = Color(0.65, 0.15, 0.15)
@export var color_on: Color = Color(0.2, 0.85, 0.3)

var _active: bool = false
@onready var _mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	_paint(color_off)


func _on_body_entered(_body: Node3D) -> void:
	if _active:
		return
	_active = true
	_paint(color_on)
	activated.emit()


func _paint(color: Color) -> void:
	if _mesh == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.6
	_mesh.material_override = mat
