extends StaticBody3D
class_name BreakableProp

# ============================================================================
# BreakableProp — Deko-/Randobjekte, die durch Spielerschaden zerbrechen:
# faerbige Truemmer (VFX.spawn_ground_fragments(), siehe dortiger Kopf-
# kommentar) + eine kleine Chance auf Loot oder ein verstecktes Podest.
# ============================================================================
# Bekommt bewusst einen ECHTEN Health-Kindnode (statt DestructibleProp's
# eigenem take_damage()) - Hitscan.fire()/Hitbox/Bomb-Explosionsschaden suchen
# AUSSCHLIESSLICH per find_child("Health", true, false) nach einem Ziel (siehe
# primary_hitbox.gd/hitscan.gd/bomb.gd) und haben KEINEN
# has_method("take_damage")-Fallback. DestructibleProp.take_damage() ist
# deshalb fuer Schuesse/Nahkampf komplett unerreichbar (nur der separate
# Ramm-Erkennungspfad funktioniert) - fuer ein Objekt, das der SPIELER
# kaputtschiessen soll, ist ein echter Health-Kindnode die einzige Stelle,
# die von allen drei Schadens-Systemen ohne jede Aenderung an denen gefunden
# wird.
#
# Bleibt auf dem Standard-Kollisionslayer (1 = "World", kein expliziter
# Override) - Hitscan.fire()'s Maske (1|4) und die Melee-PrimaryHitbox-Maske
# (5 = 1+4) decken beide bereits Layer 1 ab. "breakables" ist eine eigene
# Gruppe, NICHT "enemies" - haelt das Objekt bewusst aus EnemyQuery's
# Standard-Zielpool und aus Bomb's Explosions-Schadens-Sweep (beide iterieren
# nur "enemies"/"player") heraus; siehe enemy_query.gd fuer den expliziten
# Fallback-Zielpfad, der "breakables" gezielt (aber nachrangig) mit einschliesst.
#
# ZWEI KONSTRUKTIONSWEGE:
#   create(visual, color)       - baut eine NEUE Huelle um ein frisch
#                                  instanziertes, noch elternloses Prop
#                                  (z.B. eine wandmontierte KayKit-Requisite).
#   wrap_existing(body, color)  - haengt sich stattdessen direkt an einen
#                                  BEREITS im Baum haengenden, von Hand
#                                  platzierten StaticBody3D (z.B. "Pillar2" in
#                                  einer room_*.tscn) - dessen eigene Mesh/
#                                  Collision bleibt unangetastet, kein
#                                  zweiter Wrapper-Node noetig.

const _PEDESTAL_CHANCE: float = 0.01
## Kumulatives Fenster: [0, _PEDESTAL_CHANCE) Podest, [_PEDESTAL_CHANCE,
## _LOOT_CHANCE_END) normaler Loot (also 15 Prozentpunkte breit), Rest nichts.
const _LOOT_CHANCE_END: float = 0.16
const STINGER_SCENE: PackedScene = preload("res://scenes/scout_dummy.tscn")

static var SMOKE_FRAMES: Array[SpriteFrames] = []

static func _init_smoke_frames() -> void:
	if not SMOKE_FRAMES.is_empty(): return
	var frames_004 := SpriteFrames.new()
	frames_004.add_animation("default")
	frames_004.set_animation_speed("default", 12)
	frames_004.set_animation_loop("default", false)
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00410.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00411.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00412.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00413.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00414.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00415.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00416.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00417.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00418.png"))
	frames_004.add_frame("default", preload("res://assets/vfx/smoke/smoke004/smoke_00419.png"))
	SMOKE_FRAMES.append(frames_004)

	var frames_005 := SpriteFrames.new()
	frames_005.add_animation("default")
	frames_005.set_animation_speed("default", 12)
	frames_005.set_animation_loop("default", false)
	frames_005.add_frame("default", preload("res://assets/vfx/smoke/smoke005/smoke_00510.png"))
	frames_005.add_frame("default", preload("res://assets/vfx/smoke/smoke005/smoke_00511.png"))
	frames_005.add_frame("default", preload("res://assets/vfx/smoke/smoke005/smoke_00512.png"))
	frames_005.add_frame("default", preload("res://assets/vfx/smoke/smoke005/smoke_00513.png"))
	frames_005.add_frame("default", preload("res://assets/vfx/smoke/smoke005/smoke_00514.png"))
	frames_005.add_frame("default", preload("res://assets/vfx/smoke/smoke005/smoke_00515.png"))
	frames_005.add_frame("default", preload("res://assets/vfx/smoke/smoke005/smoke_00516.png"))
	frames_005.add_frame("default", preload("res://assets/vfx/smoke/smoke005/smoke_00517.png"))
	SMOKE_FRAMES.append(frames_005)

	var frames_007 := SpriteFrames.new()
	frames_007.add_animation("default")
	frames_007.set_animation_speed("default", 12)
	frames_007.set_animation_loop("default", false)
	frames_007.add_frame("default", preload("res://assets/vfx/smoke/smoke007/smoke_00710.png"))
	frames_007.add_frame("default", preload("res://assets/vfx/smoke/smoke007/smoke_00711.png"))
	frames_007.add_frame("default", preload("res://assets/vfx/smoke/smoke007/smoke_00712.png"))
	frames_007.add_frame("default", preload("res://assets/vfx/smoke/smoke007/smoke_00713.png"))
	SMOKE_FRAMES.append(frames_007)

	var frames_010 := SpriteFrames.new()
	frames_010.add_animation("default")
	frames_010.set_animation_speed("default", 12)
	frames_010.set_animation_loop("default", false)
	frames_010.add_frame("default", preload("res://assets/vfx/smoke/smoke010/smoke_01010.png"))
	frames_010.add_frame("default", preload("res://assets/vfx/smoke/smoke010/smoke_01011.png"))
	frames_010.add_frame("default", preload("res://assets/vfx/smoke/smoke010/smoke_01012.png"))
	frames_010.add_frame("default", preload("res://assets/vfx/smoke/smoke010/smoke_01013.png"))
	frames_010.add_frame("default", preload("res://assets/vfx/smoke/smoke010/smoke_01014.png"))
	frames_010.add_frame("default", preload("res://assets/vfx/smoke/smoke010/smoke_01015.png"))
	frames_010.add_frame("default", preload("res://assets/vfx/smoke/smoke010/smoke_01016.png"))
	SMOKE_FRAMES.append(frames_010)

	var frames_011 := SpriteFrames.new()
	frames_011.add_animation("default")
	frames_011.set_animation_speed("default", 12)
	frames_011.set_animation_loop("default", false)
	frames_011.add_frame("default", preload("res://assets/vfx/smoke/smoke011/smoke_01110.png"))
	frames_011.add_frame("default", preload("res://assets/vfx/smoke/smoke011/smoke_01111.png"))
	frames_011.add_frame("default", preload("res://assets/vfx/smoke/smoke011/smoke_01112.png"))
	frames_011.add_frame("default", preload("res://assets/vfx/smoke/smoke011/smoke_01113.png"))
	frames_011.add_frame("default", preload("res://assets/vfx/smoke/smoke011/smoke_01114.png"))
	frames_011.add_frame("default", preload("res://assets/vfx/smoke/smoke011/smoke_01115.png"))
	SMOKE_FRAMES.append(frames_011)

	var frames_012 := SpriteFrames.new()
	frames_012.add_animation("default")
	frames_012.set_animation_speed("default", 12)
	frames_012.set_animation_loop("default", false)
	frames_012.add_frame("default", preload("res://assets/vfx/smoke/smoke012/smoke_01210.png"))
	frames_012.add_frame("default", preload("res://assets/vfx/smoke/smoke012/smoke_01211.png"))
	frames_012.add_frame("default", preload("res://assets/vfx/smoke/smoke012/smoke_01212.png"))
	frames_012.add_frame("default", preload("res://assets/vfx/smoke/smoke012/smoke_01213.png"))
	frames_012.add_frame("default", preload("res://assets/vfx/smoke/smoke012/smoke_01214.png"))
	frames_012.add_frame("default", preload("res://assets/vfx/smoke/smoke012/smoke_01215.png"))
	frames_012.add_frame("default", preload("res://assets/vfx/smoke/smoke012/smoke_01216.png"))
	frames_012.add_frame("default", preload("res://assets/vfx/smoke/smoke012/smoke_01217.png"))
	SMOKE_FRAMES.append(frames_012)

	var frames_013 := SpriteFrames.new()
	frames_013.add_animation("default")
	frames_013.set_animation_speed("default", 12)
	frames_013.set_animation_loop("default", false)
	frames_013.add_frame("default", preload("res://assets/vfx/smoke/smoke013/smoke_01310.png"))
	frames_013.add_frame("default", preload("res://assets/vfx/smoke/smoke013/smoke_01311.png"))
	frames_013.add_frame("default", preload("res://assets/vfx/smoke/smoke013/smoke_01312.png"))
	frames_013.add_frame("default", preload("res://assets/vfx/smoke/smoke013/smoke_01313.png"))
	frames_013.add_frame("default", preload("res://assets/vfx/smoke/smoke013/smoke_01314.png"))
	frames_013.add_frame("default", preload("res://assets/vfx/smoke/smoke013/smoke_01315.png"))
	SMOKE_FRAMES.append(frames_013)

	var frames_014 := SpriteFrames.new()
	frames_014.add_animation("default")
	frames_014.set_animation_speed("default", 12)
	frames_014.set_animation_loop("default", false)
	frames_014.add_frame("default", preload("res://assets/vfx/smoke/smoke014/smoke_01410.png"))
	frames_014.add_frame("default", preload("res://assets/vfx/smoke/smoke014/smoke_01411.png"))
	frames_014.add_frame("default", preload("res://assets/vfx/smoke/smoke014/smoke_01412.png"))
	frames_014.add_frame("default", preload("res://assets/vfx/smoke/smoke014/smoke_01413.png"))
	frames_014.add_frame("default", preload("res://assets/vfx/smoke/smoke014/smoke_01414.png"))
	frames_014.add_frame("default", preload("res://assets/vfx/smoke/smoke014/smoke_01415.png"))
	SMOKE_FRAMES.append(frames_014)

var main_color: Color = Color.WHITE
var max_health: float = 25.0
var _visual: Node3D = null
var _health: Health = null
var _broken: bool = false


## visual muss VOR dem Aufruf aus jedem bisherigen Elternknoten entfernt sein
## (remove_child) - wird in _ready() als eigenes Kind unter dieser neuen
## Huelle neu eingehaengt, mit zurueckgesetztem Transform (siehe dort).
static func create(visual: Node3D, color: Color, hp: float = 20.0) -> BreakableProp:
	var prop := BreakableProp.new()
	prop.main_color = color
	prop.max_health = hp
	prop._visual = visual
	
	var simple_name := "prop"
	if visual:
		simple_name = visual.name
		# Simplify KayKit names (e.g. "barrel_large_A" -> "Barrel Large")
		simple_name = simple_name.replace("_A", "").replace("_B", "").replace("_C", "")
		simple_name = simple_name.replace("_decorated", "").replace("_stack", "")
		simple_name = simple_name.capitalize()
		
	prop.name = "Breakable_%s" % simple_name
	return prop


## Fuer bereits im Baum haengende, von Hand platzierte StaticBody3D-Objekte
## (z.B. Pillar2..4 in diversen room_*.tscn) - im Gegensatz zu create() wird
## HIER NICHTS neu gebaut: das Ziel-Objekt hat schon eine eigene
## MeshInstance3D + CollisionShape3D aus der Szenendatei, ein zweiter
## Wrapper-Node waere nur unnoetiger Baum-Umbau mit Transform-Fehlerpotenzial.
## No-op, falls body schon irgendein anderes Skript traegt (z.B.
## destructible_prop.gd auf "Pillar1" in room_combat_01.tscn) - nicht anfassen.
##
## set_script() auf einem BEREITS im Baum haengenden Node loest KEIN erneutes
## _ready() aus (Godot ruft _ready() nur beim Eintreten in den Baum, nicht
## pro Skript-Zuweisung) - deshalb wird der Aufbau hier explizit ueber
## _retrofit() nachgezogen statt sich auf _ready() zu verlassen.
static func wrap_existing(body: StaticBody3D, color: Color, hp: float = 20.0) -> void:
	if body.get_script() != null:
		return
	body.set_script(BreakableProp)
	(body as BreakableProp)._retrofit(color, hp)


## Sample-Farbe fuer ein MeshInstance3D-Subtree - dieselbe Technik wie
## room_instance.gd::_psxify_prop_materials() (erstes Surface-Material,
## albedo_color), damit die Truemmer dynamisch die tatsaechliche Hauptfarbe
## des zerstoerten Assets annehmen statt eine feste Palette zu benutzen.
static func sample_main_color(node: Node3D) -> Color:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null and mi.mesh.get_surface_count() > 0:
			var mat: Material = mi.get_surface_override_material(0)
			if mat == null:
				mat = mi.get_active_material(0)
			if mat is BaseMaterial3D:
				return (mat as BaseMaterial3D).albedo_color
	for child: Node in node.get_children():
		if child is Node3D:
			var found: Color = sample_main_color(child as Node3D)
			if found != Color.WHITE:
				return found
	return Color.WHITE


func _ready() -> void:
	if _visual != null:
		add_child(_visual)
		# _visual trug bisher einen Transform relativ zu SEINEM alten
		# Elternknoten (z.B. dem Wand-Props-Container) - der Aufrufer setzt
		# GENAU diesen alten lokalen Transform gleich auf DIESE Huelle
		# (siehe room_instance.gd::_wrap_wall_prop_as_breakable()), sonst
		# wuerde die Position doppelt angewendet.
		_visual.transform = Transform3D.IDENTITY
	_build_collision()
	_build_health()


func _retrofit(color: Color, hp: float) -> void:
	main_color = color
	max_health = hp
	_build_health()


## Nur fuer den create()-Pfad - wrap_existing() laesst die vorhandene
## CollisionShape3D des Ziel-Nodes unangetastet.
func _build_collision() -> void:
	var aabb: AABB = _local_aabb(self)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	if aabb.size.length() > 0.01:
		box.size = aabb.size
		shape.position = aabb.position + aabb.size * 0.5
	else:
		# Kein Mesh gefunden (sollte nicht vorkommen) - kleiner Notfall-Quader,
		# damit das Objekt trotzdem physisch existiert statt unsichtbar/
		# unantastbar zu bleiben.
		box.size = Vector3.ONE
	shape.shape = box
	add_child(shape)


func _build_health() -> void:
	add_to_group("breakables")
	_health = Health.new()
	_health.name = "Health"
	_health.max_health = max_health
	_health.regen_enabled = false
	add_child(_health)
	_health.died.connect(_on_broken)
	_health.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, max_hp: float) -> void:
	var percent: float = clamp(current / max(max_hp, 0.001), 0.0, 1.0)
	var alpha: float = lerpf(0.15, 1.0, percent)
	_set_materials_alpha(self, alpha)


func _set_materials_alpha(node: Node, alpha: float) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			var mat_count: int = mi.mesh.get_surface_count()
			for i in range(mat_count):
				var mat: Material = mi.get_surface_override_material(i)
				if mat == null:
					mat = mi.mesh.surface_get_material(i)
				if mat is BaseMaterial3D:
					var new_mat := mat.duplicate() as BaseMaterial3D
					new_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					new_mat.albedo_color.a = alpha
					mi.set_surface_override_material(i, new_mat)
	
	for child in node.get_children():
		_set_materials_alpha(child, alpha)


func _on_broken() -> void:
	if _broken:
		return
	_broken = true

	var light_brown := Color("c29363")
	VFX.spawn_ground_fragments(
		[light_brown, light_brown.darkened(0.3)], global_position + Vector3.UP * 0.5, 6, self
	)
	_spawn_smoke()
	_roll_loot()
	_roll_stinger()

	remove_from_group("breakables")
	for child in get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).set_deferred("disabled", true)

	# scale statt visible=false: gibt der Zerstoerung einen kurzen "schrumpft
	# weg"-Moment statt hart zu verschwinden - gleicher Stil wie
	# CustomEnemyBase._teardown()'s visual_root-Tween. Wirkt fuer BEIDE
	# Konstruktionswege (create()'s eigener _visual-Kind-Node UND
	# wrap_existing()'s bereits vorhandene Mesh-Kinder direkt an self), da
	# hier bewusst "self" statt "_visual" skaliert wird.
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()


func _spawn_smoke() -> void:
	_init_smoke_frames()
	if SMOKE_FRAMES.is_empty():
		return
		
	var sprite := AnimatedSprite3D.new()
	sprite.sprite_frames = SMOKE_FRAMES[randi() % SMOKE_FRAMES.size()]
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.transparent = true
	sprite.modulate.a = 0.9
	sprite.alpha_cut = Sprite3D.ALPHA_CUT_DISABLED
	
	# Random size: max size can be quite large, min size not too small
	var s: float = randf_range(10.0, 19.0)
	sprite.scale = Vector3(s, s, s)
	
	# Add to current_scene so it outlives the prop
	get_tree().current_scene.add_child(sprite)
	sprite.global_position = global_position + Vector3.UP * 1.0
	
	sprite.play("default")
	sprite.animation_finished.connect(sprite.queue_free)
	
	# Optional slight upward drift
	var tween: Tween = sprite.create_tween()
	tween.tween_property(sprite, "global_position:y", sprite.global_position.y + randf_range(0.8, 1.8), 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _roll_loot() -> void:
	var roll: float = randf()
	if roll < _PEDESTAL_CHANCE:
		_spawn_hidden_pedestal()
	elif roll < _LOOT_CHANCE_END:
		var loot: Node = get_node_or_null("/root/Loot")
		if loot:
			loot.spawn_random_drop(global_position)


## Gleiche Auswahl-Logik wie secret_wall.gd::_spawn_reward() (zufaelliges
## ItemData aus Items.catalog, max_stacks respektiert) - bewusst OHNE
## Abhaengigkeit an treasure_manager.gd's privates Gewichtungssystem, das an
## Raum-/DetRng-Kontext gebunden ist, den ein zerbrochenes Deko-Objekt nicht hat.
func _roll_stinger() -> void:
	if STINGER_SCENE == null:
		return
	var n: String = name.to_lower()
	if "barrel" in n or "bed" in n or "trunk" in n:
		if randf() < 0.04:
			var stinger: Node3D = STINGER_SCENE.instantiate() as Node3D
			if stinger:
				get_tree().current_scene.add_child(stinger)
				stinger.global_position = global_position + Vector3.UP * 0.5


func _spawn_hidden_pedestal() -> void:
	var items: Node = get_node_or_null("/root/Items")
	if items == null:
		return

	var pool: Array = []
	for entry in items.catalog:
		if not (entry is ItemData):
			continue
		var data: ItemData = entry as ItemData
		if data.max_stacks > 0 and items.count_item(data.id) >= data.max_stacks:
			continue
		pool.append(data)
	if pool.is_empty():
		return

	var chosen: ItemData = pool[randi() % pool.size()]
	# start_hidden=true: existiert unsichtbar/nicht-interagierbar, bis reveal()
	# direkt danach die Aufdeck-Animation startet - siehe treasure_pedestal.gd.
	var pedestal: TreasurePedestal = TreasurePedestal.create(chosen, true)
	get_tree().current_scene.add_child(pedestal)
	pedestal.global_position = global_position
	pedestal.reveal()


## Kombinierte lokale AABB aller MeshInstance3D-Nachfahren von "root" - gleiche
## Technik wie room_instance.gd::_prop_local_aabb()/_collect_local_aabbs(),
## hier als eigene kleine Kopie statt einer Abhaengigkeit zu RoomInstance.
static func _local_aabb(root: Node3D) -> AABB:
	var aabbs: Array = []
	_collect_local_aabbs(root, Transform3D.IDENTITY, aabbs)
	if aabbs.is_empty():
		return AABB()
	var combined: AABB = aabbs[0]
	for i: int in range(1, aabbs.size()):
		combined = combined.merge(aabbs[i])
	return combined


static func _collect_local_aabbs(node: Node, xform: Transform3D, out: Array) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			out.append(xform * mi.get_aabb())
	for child: Node in node.get_children():
		if child is Node3D:
			_collect_local_aabbs(child, xform * (child as Node3D).transform, out)
