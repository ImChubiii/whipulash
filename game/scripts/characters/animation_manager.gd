extends Node
class_name AnimationManager

# Essential-Animations-Pack (Mixamo-artige Rohnamen wie "Hips", "LeftArm").
# Idle.fbx/Run.fbx/etc. tragen ausserdem im Import ein BoneMap-Retarget auf
# SkeletonProfileHumanoid (siehe .import-Dateien), genau wie
# KayKit_Skeletons_1.1_FREE/kaykit_bone_map.tres es fuer die Charaktermodelle
# tut - beide werden dadurch auf dieselben kanonischen Profil-Knochennamen
# umbenannt, wodurch die Tracks nach dem Neu-Import direkt (ohne
# Namensuebersetzung) auf das Ziel-Skeleton passen sollten.
const MIXAMO_ANIM_PATHS := {
	"idle": "res://assets/animations/Idle.fbx",
	"run": "res://assets/animations/Run.fbx",
	"attack": "res://assets/animations/Attack.fbx",
	"hit": "res://assets/animations/Hit.fbx",
	"death": "res://assets/animations/Death.fbx"
}

var entity: CharacterBody3D = null
var anim_player: AnimationPlayer = null
var current_anim: String = ""
var _anim_map := {
	"idle": "idle",
	"run": "run",
	"attack": "attack",
	"hit": "hit",
	"death": "death"
}

var _blend_time: float = 0.25
var _is_dead: bool = false
var _is_hitting: bool = false
var _is_attacking: bool = false
var _last_known_health: float = 0.0

func _init(p_entity: CharacterBody3D) -> void:
	entity = p_entity

func _ready() -> void:
	if not entity:
		queue_free()
		return

	# Finde den automatisch generierten AnimationPlayer im CharacterModel
	anim_player = entity.find_child("AnimationPlayer", true, false) as AnimationPlayer

	# KayKit-Charaktermodelle (Skeleton_Warrior.glb etc.) liefern selbst
	# KEINEN AnimationPlayer mit (0 eingebaute Animationen im glb), da der
	# glTF-Import dafuer keinen Node anlegt. Wenn wir trotzdem ein Skeleton3D
	# finden, bauen wir uns den AnimationPlayer selbst dazu statt tatenlos
	# aufzugeben (das fuehrte bisher zur reglosen T-Pose).
	var target_skel: Skeleton3D = _find_skeleton(entity)
	if not anim_player:
		if not target_skel:
			push_warning("AnimationManager: Weder AnimationPlayer noch Skeleton3D in %s gefunden." % entity.name)
			set_process(false)
			return
		anim_player = AnimationPlayer.new()
		anim_player.name = "AnimationPlayer"
		target_skel.get_parent().add_child(anim_player)

	# Stelle sicher, dass eine Library existiert
	var lib: AnimationLibrary
	if anim_player.has_animation_library(""):
		lib = anim_player.get_animation_library("")
		# Suche nach existierenden Animationen (z.B. bei zukuenftigen Modellen
		# mit bereits eingebauten Animationen)
		var existing = lib.get_animation_list()
		for a in existing:
			var l = a.to_lower()
			if "idle" in l: _anim_map["idle"] = a
			elif "run" in l or "walk" in l: _anim_map["run"] = a
			elif "attack" in l: _anim_map["attack"] = a
			elif "hit" in l or "damage" in l: _anim_map["hit"] = a
			elif "death" in l or "defeat" in l or "die" in l: _anim_map["death"] = a
	else:
		lib = AnimationLibrary.new()
		anim_player.add_animation_library("", lib)

	# Lade externe Animationen dynamisch, WENN wir keine eigenen gefunden haben
	if _anim_map["idle"] == "idle" and not anim_player.has_animation("idle") and target_skel:
		var ap_parent := anim_player.get_parent()
		var skel_path := ap_parent.get_path_to(target_skel)

		for anim_name in _anim_map.keys():
			var anim = _load_mixamo_clip(MIXAMO_ANIM_PATHS[anim_name], target_skel, skel_path)
			if not anim:
				continue
			if anim_name == "idle" or anim_name == "run":
				anim.loop_mode = Animation.LOOP_LINEAR
			else:
				anim.loop_mode = Animation.LOOP_NONE
			lib.add_animation(anim_name, anim)

	# Signale binden
	anim_player.animation_finished.connect(_on_animation_finished)
	
	var health_node = entity.find_child("Health", true, false)
	if health_node:
		_last_known_health = health_node.current_health if "current_health" in health_node else 100.0
		if health_node.has_signal("health_changed"):
			health_node.health_changed.connect(_on_health_changed)
		if health_node.has_signal("died"):
			health_node.died.connect(_on_died)
			
	if "combat" in entity and entity.combat:
		if entity.combat.has_signal("primary_used"):
			entity.combat.primary_used.connect(func(): trigger_attack())
		if entity.combat.has_signal("secondary_used"):
			entity.combat.secondary_used.connect(func(): trigger_attack())
	
	play_anim("idle")

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var found := _find_skeleton(child)
		if found:
			return found
	return null

func _get_anim_from_player(player: AnimationPlayer, clip_name: String = "") -> Animation:
	for lib_name in player.get_animation_library_list():
		var lib = player.get_animation_library(lib_name)
		if clip_name != "" and lib.has_animation(clip_name):
			return lib.get_animation(clip_name)
		elif clip_name == "":
			var anims = lib.get_animation_list()
			if anims.size() > 0:
				return lib.get_animation(anims[0])
	return null

func _load_mixamo_clip(path: String, target_skel: Skeleton3D, skel_path: NodePath) -> Animation:
	var scene: PackedScene = load(path) as PackedScene
	if not scene:
		return null
	var instance := scene.instantiate()
	var source_player := instance.find_child("AnimationPlayer", true, false) as AnimationPlayer
	var anim: Animation = null
	if source_player:
		var source_anim = _get_anim_from_player(source_player)
		if source_anim:
			anim = _retarget(source_anim, target_skel, skel_path)
	instance.queue_free()
	return anim

# Knochennamen-Aliase auf die rohen KayKit-Namen (z.B. "upperarm.l"). Deckt
# sowohl die rohen Mixamo-Namen ("LeftArm") als auch die kanonischen
# SkeletonProfileHumanoid-Namen ("LeftUpperArm") ab, falls Quelle und/oder
# Ziel (noch) nicht ueber das BoneMap-Retarget im Import umbenannt wurden -
# siehe kaykit_bone_map.tres / Idle.fbx.import. Wird nur als Fallback
# benutzt, wenn der Knochenname am Ziel-Skeleton nicht direkt existiert.
const BONE_ALIASES := {
	"Root": "root",
	"Hips": "hips",
	"Spine": "spine",
	"Chest": "chest",
	"Spine1": "chest",
	"Spine2": "chest",
	"UpperChest": "chest",
	"Neck": "head",
	"Head": "head",
	"LeftShoulder": "upperarm.l",
	"LeftArm": "upperarm.l",
	"LeftUpperArm": "upperarm.l",
	"LeftForeArm": "lowerarm.l",
	"LeftLowerArm": "lowerarm.l",
	"LeftHand": "hand.l",
	"RightShoulder": "upperarm.r",
	"RightArm": "upperarm.r",
	"RightUpperArm": "upperarm.r",
	"RightForeArm": "lowerarm.r",
	"RightLowerArm": "lowerarm.r",
	"RightHand": "hand.r",
	"LeftUpLeg": "upperleg.l",
	"LeftUpperLeg": "upperleg.l",
	"LeftLeg": "lowerleg.l",
	"LeftLowerLeg": "lowerleg.l",
	"LeftFoot": "foot.l",
	"LeftToeBase": "toes.l",
	"LeftToes": "toes.l",
	"RightUpLeg": "upperleg.r",
	"RightUpperLeg": "upperleg.r",
	"RightLeg": "lowerleg.r",
	"RightLowerLeg": "lowerleg.r",
	"RightFoot": "foot.r",
	"RightToeBase": "toes.r",
	"RightToes": "toes.r"
}

func _retarget(source_anim: Animation, target_skel: Skeleton3D, skel_path: NodePath) -> Animation:
	var anim: Animation = source_anim.duplicate()
	for i in range(anim.get_track_count()):
		var old_path := anim.track_get_path(i)
		var prop := old_path.get_concatenated_subnames()

		# Nur uebersetzen, wenn der Knochenname nicht schon direkt existiert -
		# nach erfolgreichem BoneMap-Retarget im Import tragen Quelle und
		# Ziel bereits identische Namen und brauchen keine Uebersetzung.
		if target_skel.find_bone(prop) == -1 and BONE_ALIASES.has(prop):
			prop = BONE_ALIASES[prop]

		anim.track_set_path(i, NodePath(str(skel_path) + ":" + prop))

		# Hueft-/Root-Position-Tracks NICHT aus der Quelle uebernehmen: die
		# absolute Hoehe im Essential-Animations-Clip passt trotz gleicher
		# Knochennamen oft nicht zur Rest-Pose des KayKit-Ziel-Skeletts
		# (andere Rig-Proportionen) - das liess den Gegner ueber/unter dem
		# Boden schweben, obwohl _orient_model() (enemy_ai.gd) die Rest-Pose
		# bereits korrekt am Boden ausrichtet. Rotation bleibt animiert, nur
		# die absolute Position wird auf die Rest-Pose des Ziels gepinnt -
		# damit stimmt die Lauf-/Idle-Animation IMMER mit der Bodenkorrektur
		# ueberein, die auf derselben Rest-Pose basiert.
		if anim.track_get_type(i) == Animation.TYPE_POSITION_3D and (prop == "hips" or prop == "root"):
			var bone_idx := target_skel.find_bone(prop)
			if bone_idx != -1:
				var rest_pos: Vector3 = target_skel.get_bone_rest(bone_idx).origin
				for k in range(anim.track_get_key_count(i)):
					anim.track_set_key_value(i, k, rest_pos)
	return anim

func play_anim(logical_name: String, force: bool = false) -> void:
	var real_name = _anim_map.get(logical_name, logical_name)
	if not anim_player or not anim_player.has_animation(real_name):
		return
	if current_anim == real_name and not force:
		return
	
	current_anim = real_name
	anim_player.play(real_name, _blend_time)

func _process(delta: float) -> void:
	if not anim_player or _is_dead:
		return
		
	if _is_hitting or _is_attacking:
		return
		
	# Basis-State-Machine: Laufen oder Stehen
	var horizontal_speed := Vector3(entity.velocity.x, 0, entity.velocity.z).length()
	
	# Ein bisschen Puffer, damit er nicht beim winzigsten Rutschen rennt
	if horizontal_speed > 0.5:
		play_anim("run")
		anim_player.speed_scale = maxf(1.0, horizontal_speed / 16.0)
	else:
		play_anim("idle")
		anim_player.speed_scale = 1.0

func _on_health_changed(current: float, max_hp: float) -> void:
	if _is_dead or current >= _last_known_health:
		_last_known_health = current
		return
	_last_known_health = current
	
	if not anim_player:
		return
	
	# Hit-Priorität
	_is_hitting = true
	_is_attacking = false
	anim_player.speed_scale = 1.5 # Snappy Hit Reaction
	play_anim("hit", true)

func _on_died() -> void:
	if _is_dead: return
	_is_dead = true
	
	if not anim_player:
		return
		
	anim_player.speed_scale = 1.0
	play_anim("death", true)

func trigger_attack(speed: float = 1.5) -> void:
	if _is_dead or _is_hitting: return
	_is_attacking = true
	
	if not anim_player:
		return
		
	anim_player.speed_scale = speed
	play_anim("attack", true)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		_is_hitting = false
	elif anim_name == "attack":
		_is_attacking = false
