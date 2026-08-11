
extends CombatBase
class_name CombatGiselle

# Giselle: Ranged/Precision — zielsicherer Fernkampf, gezielte Eliminierung
# von High-Threat-Targets.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind komplett weg - Q und E loesen jetzt
# immer das aktive Item im jeweiligen Slot aus, siehe CombatBase.
#
# Beide Waffen sind Hitscan (scripts/core/hitscan.gd) statt Hitbox-basiert -
# PrimaryHitbox/SecondaryHitbox aus char_giselle.tscn bleiben bewusst
# ungenutzt im Baum (siehe combat_base.gd-Kopfkommentar zu diesem Muster),
# nur ihre bereits im Inspector gesetzten damage_number_scene-Referenzen
# werden noch mitbenutzt, um keine zweite Ressourcen-Zuweisung zu brauchen.

const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

## --- Primary "Uzi Spray" -------------------------------------------------
@export var uzi_magazine_size: int = 25
@export var uzi_reload_time: float = 1.0
@export var uzi_damage: float = 7.0
@export var uzi_range: float = 40.0

## --- Secondary "Sniper Burst" ---------------------------------------------
@export var sniper_shot_count: int = 3
@export var sniper_damage_per_shot: float = 100.0
@export var sniper_range: float = 60.0
## FOV, auf den beim Halten von RMB gezoomt wird - deutlich unter dem
## Kamera-Standard-FOV, simuliert ein Zielfernrohr OHNE die Third-Person-
## Kamera selbst zu verschieben (das macht weiterhin unabhaengig davon das
## bestehende Mausrad-Zoom/SpringArm3D-System aus player_base.gd).
@export var sniper_zoom_fov: float = 28.0
@export var sniper_zoom_in_time: float = 0.5
@export var sniper_zoom_out_time: float = 0.35

var _uzi_ammo: int = 25
var _uzi_reloading: bool = false

var _sniper_charging: bool = false
var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null
var _default_fov: float = 75.0
var _fov_tween: Tween = null


func _init() -> void:
	primary_cooldown = 0.08
	secondary_cooldown = 5.0
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_uzi_ammo = uzi_magazine_size
	if _camera:
		_default_fov = _camera.fov


# ============================================================================
# Uzi Spray - haelt Halten von LMB, feuert ueber das UNVERAENDERTE
# _poll_primary_input()/_do_primary() aus combat_base.gd jeden Frame erneut,
# solange der (sehr kurze) primary_cooldown abgelaufen ist.
# ============================================================================
func _perform_primary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Bewusst OHNE jeglichen Zufalls-Jitter auf "dir" - die Spec verlangt
	# "extrem hohe Genauigkeit, Schuesse verreissen nicht", ein Streuwinkel
	# wuerde genau das kaputt machen.
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung. Bewusst ueber die Camera3D selbst
	# statt SpringArm3D berechnet, damit hier keine Annahme ueber gleiche
	# Rotation zwischen beiden Nodes mehr noetig ist.
	var dir: Vector3 = -_camera.global_transform.basis.z

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	_spawn_muzzle_vfx(origin, dir)
	if result["hit"]:
		VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		_lock_model_to(result["target"])
		if player and player.has_method("shake_camera"):
			player.shake_camera(0.12)

	_uzi_ammo -= 1
	if _uzi_ammo <= 0:
		_uzi_ammo = uzi_magazine_size
		_uzi_reloading = true
		_primary_timer = uzi_reload_time


## Waehrend des Nachladens gilt der feste Reload-Cooldown statt des
## kombo-reduzierten Basis-Cooldowns - sonst wuerde get_primary_cooldown_
## percent() (HUD-Ring) durch den winzigen primary_cooldown teilen und einen
## Wert weit ueber 1.0 liefern.
func _get_effective_primary_cooldown() -> float:
	if _uzi_reloading:
		return uzi_reload_time
	return super._get_effective_primary_cooldown()


func _process(delta: float) -> void:
	super._process(delta)
	if _uzi_reloading and _primary_timer <= 0.0:
		_uzi_reloading = false


func get_uzi_ammo_remaining() -> int:
	return _uzi_ammo


func get_uzi_magazine_size() -> int:
	return uzi_magazine_size


# ============================================================================
# Sniper Burst - komplett eigenes Press/Hold/Release-Handling statt des
# Standard-"gehalten -> feuert jeden Frame"-Musters: RMB druecken startet
# einen Ladevorgang (Kamera-FOV zoomt), RMB LOSLASSEN loest den eigentlichen
# Schuss aus. Das Feuern selbst laeuft trotzdem ueber das unveraenderte
# _do_secondary() (Cooldown/Signale/Ghost-Trail) - nur der Zeitpunkt des
# Aufrufs wandert von "press" zu "release".
# ============================================================================
func _poll_secondary_input(_delta: float) -> void:
	if _sniper_charging:
		if not Input.is_action_pressed("attack_secondary"):
			_release_sniper_charge()
		return

	if Input.is_action_just_pressed("attack_secondary") and _secondary_timer <= 0.0:
		_start_sniper_charge()


func _start_sniper_charge() -> void:
	if _camera == null:
		return
	_sniper_charging = true
	_kill_fov_tween()
	_fov_tween = _camera.create_tween()
	_fov_tween.tween_property(_camera, "fov", sniper_zoom_fov, sniper_zoom_in_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _release_sniper_charge() -> void:
	_sniper_charging = false
	if _camera:
		_kill_fov_tween()
		_fov_tween = _camera.create_tween()
		_fov_tween.tween_property(_camera, "fov", _default_fov, sniper_zoom_out_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Der Schuss loest erst HIER aus (nicht beim Druecken) - deshalb bleibt
	# der 5s-Cooldown fuer die volle Ladedauer unangetastet und startet
	# tatsaechlich erst beim Loslassen, wie in der Spec verlangt.
	if _secondary_timer <= 0.0:
		_do_secondary()


func _kill_fov_tween() -> void:
	if _fov_tween != null and _fov_tween.is_valid():
		_fov_tween.kill()


func _perform_secondary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung. Bewusst ueber die Camera3D selbst
	# statt SpringArm3D berechnet, damit hier keine Annahme ueber gleiche
	# Rotation zwischen beiden Nodes mehr noetig ist.
	var dir: Vector3 = -_camera.global_transform.basis.z
	var dmg: float = sniper_damage_per_shot * _damage_multiplier()
	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null
	var landed_hit: bool = false

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		_spawn_muzzle_vfx(origin, dir)
		if result["hit"]:
			landed_hit = true
			VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			_lock_model_to(result["target"])
		if i < sniper_shot_count - 1:
			await get_tree().create_timer(0.03).timeout

	if landed_hit and player and player.has_method("shake_camera"):
		player.shake_camera(0.4)


func is_sniper_charging() -> bool:
	return _sniper_charging


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
func _damage_multiplier() -> float:
	var stats: PlayerStats = PlayerStats.find_for(self)
	return stats.get_damage_multiplier() if stats else 1.0


## Dreht das Charaktermodell zum getroffenen Ziel - dieselbe player_base.gd-
## Funktion, die auch Nahkampf-Treffer schon nutzen (siehe combat_base.gd::
## _on_hit_landed()). Hitscan-Treffer loesen das nicht automatisch aus, da sie
## NIE ueber die Hitbox-Signale laufen (siehe Kopfkommentar) - deshalb hier
## explizit nachgezogen.
func _lock_model_to(target: Variant) -> void:
	if player and player.has_method("set_target") and target is Node3D:
		player.set_target(target)


func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3) -> void:
	var data: CharacterData = PartyManager.get_active_data()
	if data != null:
		VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, pos, data.attack_color, data.attack_color_secondary, dir)
	else:
		VFX.spawn(MUZZLE_VFX_SCENE, pos, dir)
