extends Node3D
class_name CharacterPedestal

# ============================================================================
# CharacterPedestal — Tutorial-Modus: derselbe Isaac-Sockel wie
# TreasurePedestal, aber fuer einen Charakter-Unlock statt eines Items.
# ============================================================================
# BEWUSST NICHT "extends TreasurePedestal": dessen take()/_restock()/
# _apply_icon_billboard()/_update_preview() sind alle namentlich auf
# ItemData/Items.pickup_active_item()/ItemDescriptionHud festgenagelt,
# inklusive der Q/E-Verdraengungs-/Restock-Logik, die fuer einen einmaligen
# Charakter-Unlock keinen Sinn ergibt. Stattdessen wird hier dasselbe
# VISUELLE Baumuster (Saeule/Ring/Beam/Float-Gruppe/Licht/Label) kopiert,
# siehe treasure_pedestal.gd.

signal character_taken(data: CharacterData, pedestal: CharacterPedestal)

@export var interact_distance: float = 3.0

@export var bob_height: float = 0.14
@export var bob_speed: float = 1.8
@export var spin_speed: float = 1.1
@export var float_height: float = 1.15
@export var beam_height: float = 7.0
@export var light_range: float = 9.0
@export var light_energy: float = 2.2

const INTERACT_ACTION: String = "interact"
const GENERATOR_GROUP: String = "level_generator"

## Der Charakter, der auf diesem Sockel freigeschaltet wird. Wird vom
## TreasureManager gesetzt, BEVOR der Sockel in den Baum gehaengt wird.
var character_data: CharacterData = null

var _taken: bool = false
var _time: float = 0.0
var _float_root: Node3D = null
var _gem: MeshInstance3D = null
var _beam: MeshInstance3D = null
var _ring: MeshInstance3D = null
var _light: OmniLight3D = null
var _name_label: Label3D = null
var _prompt_label: Label3D = null
var _accent: Color = Color(0.95, 0.85, 0.35)

var _room: RoomInstance = null
var _generator: Node = null


static func create(data: CharacterData) -> CharacterPedestal:
	var pedestal := CharacterPedestal.new()
	pedestal.character_data = data
	pedestal.name = "CharacterPedestal_%s" % (data.character_id if data else "empty")
	return pedestal


func _ready() -> void:
	add_to_group("treasure_pedestals")

	if character_data != null:
		_accent = character_data.attack_color

	_build_column()
	_build_ring()
	_build_beam()
	_build_float_group()
	_build_light()
	_build_labels()

	_room = get_parent() as RoomInstance
	_sync_minimap_visibility.call_deferred()
	_bind_generator.call_deferred()


# ============================================================================
# Aufbau — identisches Baumuster wie treasure_pedestal.gd
# ============================================================================
func _make_material(color: Color, emission: float = 0.8, unshaded: bool = true) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission
	return material


func _make_glow_material(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.disable_receive_shadows = true
	return material


func _build_column() -> void:
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = 0.42
	shaft_mesh.bottom_radius = 0.58
	shaft_mesh.height = 0.95
	shaft_mesh.radial_segments = 8

	var shaft := MeshInstance3D.new()
	shaft.name = "Shaft"
	shaft.mesh = shaft_mesh
	shaft.material_override = _make_material(Color(0.14, 0.15, 0.18), 0.0, false)
	shaft.position = Vector3(0.0, 0.475, 0.0)
	add_child(shaft)

	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.72
	base_mesh.bottom_radius = 0.82
	base_mesh.height = 0.18
	base_mesh.radial_segments = 8

	var base := MeshInstance3D.new()
	base.name = "Base"
	base.mesh = base_mesh
	base.material_override = _make_material(Color(0.10, 0.11, 0.13), 0.0, false)
	base.position = Vector3(0.0, 0.09, 0.0)
	add_child(base)

	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.52
	cap_mesh.bottom_radius = 0.46
	cap_mesh.height = 0.12
	cap_mesh.radial_segments = 8

	var cap := MeshInstance3D.new()
	cap.name = "Cap"
	cap.mesh = cap_mesh
	cap.material_override = _make_material(_accent, 0.9)
	cap.position = Vector3(0.0, 1.0, 0.0)
	add_child(cap)


func _build_ring() -> void:
	var torus := TorusMesh.new()
	torus.inner_radius = 1.05
	torus.outer_radius = 1.22
	torus.rings = 20
	torus.ring_segments = 5

	_ring = MeshInstance3D.new()
	_ring.name = "GroundRing"
	_ring.mesh = torus
	_ring.material_override = _make_glow_material(_accent, 0.55)
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ring.position = Vector3(0.0, 0.04, 0.0)
	add_child(_ring)


func _build_beam() -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.95
	cylinder.bottom_radius = 0.30
	cylinder.height = beam_height
	cylinder.radial_segments = 10
	cylinder.rings = 1

	_beam = MeshInstance3D.new()
	_beam.name = "LightBeam"
	_beam.mesh = cylinder
	_beam.material_override = _make_glow_material(_accent, 0.13)
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_beam.position = Vector3(0.0, 1.1 + beam_height * 0.5, 0.0)
	add_child(_beam)


## Statt eines Item-Edelsteins schwebt hier ein Portrait-Billboard des
## Charakters (falls vorhanden), sonst ein einfacher farbiger Platzhalter.
func _build_float_group() -> void:
	_float_root = Node3D.new()
	_float_root.name = "FloatRoot"
	_float_root.position = Vector3(0.0, 1.06 + float_height, 0.0)
	add_child(_float_root)

	var quad := QuadMesh.new()
	quad.size = Vector2(1.5, 1.5)

	var halo := MeshInstance3D.new()
	halo.name = "Halo"
	halo.mesh = quad
	var halo_material := _make_glow_material(_accent, 0.35)
	halo_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	halo.material_override = halo_material
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(halo)

	var portrait: Texture2D = character_data.portrait if character_data else null
	if portrait != null:
		_apply_portrait_billboard(portrait)
		return

	var gem_mesh := SphereMesh.new()
	gem_mesh.radius = 0.30
	gem_mesh.height = 0.84
	gem_mesh.radial_segments = 6
	gem_mesh.rings = 3

	_gem = MeshInstance3D.new()
	_gem.name = "Gem"
	_gem.mesh = gem_mesh
	_gem.material_override = _make_material(_accent, 1.4)
	_gem.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(_gem)


func _apply_portrait_billboard(portrait: Texture2D) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(0.95, 0.95)

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = portrait
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var portrait_instance := MeshInstance3D.new()
	portrait_instance.name = "Portrait"
	portrait_instance.mesh = quad
	portrait_instance.material_override = material
	portrait_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(portrait_instance)


func _build_light() -> void:
	_light = OmniLight3D.new()
	_light.name = "ShrineLight"
	_light.light_color = _accent
	_light.light_energy = light_energy
	_light.omni_range = light_range
	_light.shadow_enabled = false
	_light.position = Vector3(0.0, 1.6, 0.0)
	add_child(_light)


func _build_labels() -> void:
	_name_label = Label3D.new()
	_name_label.name = "NameLabel"
	_name_label.text = character_data.character_name if character_data else "???"
	_name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_name_label.no_depth_test = true
	_name_label.pixel_size = 0.0055
	_name_label.outline_size = 8
	_name_label.modulate = Color(1.0, 0.98, 0.92, 0.95)
	_name_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_name_label.position = Vector3(0.0, 2.85, 0.0)
	add_child(_name_label)

	_prompt_label = Label3D.new()
	_prompt_label.name = "PromptLabel"
	_prompt_label.text = "[F] Freischalten"
	_prompt_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt_label.no_depth_test = true
	_prompt_label.pixel_size = 0.0045
	_prompt_label.outline_size = 6
	_prompt_label.modulate = _accent
	_prompt_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_prompt_label.position = Vector3(0.0, 2.5, 0.0)
	_prompt_label.visible = false
	add_child(_prompt_label)


# ============================================================================
# Laufzeit
# ============================================================================
func _physics_process(delta: float) -> void:
	_time += delta
	_animate(delta)

	if _taken:
		return

	var player: Node3D = _find_player()
	if player == null:
		return

	var distance: float = global_position.distance_to(player.global_position)
	if _prompt_label:
		_prompt_label.visible = distance <= interact_distance

	if distance > interact_distance:
		return
	if not Input.is_action_just_pressed(INTERACT_ACTION):
		return
	take()


func _animate(delta: float) -> void:
	if _float_root and not _taken:
		_float_root.position.y = 1.06 + float_height + sin(_time * bob_speed) * bob_height
		_float_root.rotate_y(spin_speed * delta)

	if _ring:
		var pulse: float = 0.45 + 0.25 * (sin(_time * 2.0) * 0.5 + 0.5)
		var material: StandardMaterial3D = _ring.material_override
		if material:
			material.albedo_color.a = pulse if not _taken else 0.08

	if _light and not _taken:
		_light.light_energy = light_energy * (0.85 + 0.15 * sin(_time * 3.1))


func _find_player() -> Node3D:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


# ============================================================================
# Aufnehmen
# ============================================================================
func take() -> bool:
	if _taken or character_data == null:
		return false

	PartyManager.add_party_member(character_data)

	# Direkt zum neu freigeschalteten Charakter wechseln, damit der Spieler
	# ihn sofort ausprobieren kann (Tutorial-Flow: Ningning -> Giselle -> ...).
	var new_index: int = PartyManager.get_party_size() - 1
	if new_index > 0:
		PartyManager.switch_to(new_index)

	_taken = true
	character_taken.emit(character_data, self)
	_play_take_feedback()
	return true


func _play_take_feedback() -> void:
	if _prompt_label:
		_prompt_label.visible = false
	if _name_label:
		_name_label.visible = true

	Juice.hit_stop(Juice.DURATION_LIGHT)
	Juice.shake(0.35)

	var tween := create_tween()
	tween.set_parallel(true)

	if _float_root:
		tween.tween_property(_float_root, "position:y", _float_root.position.y + 1.4, 0.45) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_float_root, "scale", Vector3.ONE * 0.01, 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	if _beam and _beam.material_override is StandardMaterial3D:
		tween.tween_property(_beam.material_override, "albedo_color:a", 0.0, 0.5)

	if _light:
		tween.tween_property(_light, "light_energy", 0.25, 0.5)

	tween.chain().tween_callback(_finish_take)


func _finish_take() -> void:
	if _float_root and is_instance_valid(_float_root):
		_float_root.queue_free()
		_float_root = null
	if _beam and is_instance_valid(_beam):
		_beam.queue_free()
		_beam = null


func is_taken() -> bool:
	return _taken


# ============================================================================
# Fog-of-War-Anschluss — identisch zu treasure_pedestal.gd
# ============================================================================
func _bind_generator() -> void:
	if _room == null:
		return

	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)


func _on_map_updated() -> void:
	_sync_minimap_visibility()


func _sync_minimap_visibility() -> void:
	if _room == null or not is_instance_valid(_room):
		return

	var revealed: bool = true
	if "_minimap_revealed" in _room:
		revealed = bool(_room.get("_minimap_revealed"))

	_apply_own_minimap_layer(self, revealed)

	if _light:
		_light.visible = revealed


func _apply_own_minimap_layer(node: Node, revealed: bool) -> void:
	for child: Node in node.get_children():
		if child is VisualInstance3D:
			var visual: VisualInstance3D = child as VisualInstance3D
			if not visual.has_meta("minimap_base_layers"):
				visual.set_meta("minimap_base_layers", visual.layers)
			if revealed:
				visual.layers = int(visual.get_meta("minimap_base_layers"))
			else:
				visual.layers = 1 << (RoomInstance.MINIMAP_HIDDEN_LAYER - 1)
		_apply_own_minimap_layer(child, revealed)
