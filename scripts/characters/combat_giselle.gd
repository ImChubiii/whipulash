
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
@export var uzi_magazine_size: int = 40
@export var uzi_reload_time: float = 1.0
@export var uzi_damage: float = 7.0
@export var uzi_range: float = 40.0
## Rework "Auto-Target" (Rueckmeldung: "man sollte nur in die Richtung
## schauen, damit die Uzi die Gegner erkennt und selber drauf schiesst"):
## Blickkegel-Halbwinkel, in dem sich die Uzi selbst ihr Ziel sucht (siehe
## EnemyQuery.best_target_in_cone()) - deutlich weiter als der praezise
## Aim-Assist unten, weil hier kein Zielen mehr noetig sein soll, nur noch
## grobes Hinschauen.
@export var uzi_target_cone_deg: float = 35.0
## Farbe/Groesse des ESP-Markers ueber dem gerade automatisch anvisierten
## Ziel - siehe _build_esp_marker().
@export var uzi_esp_color: Color = Color(1.0, 0.15, 0.1)

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

## --- Aim-Assist (Sniper) ----------------------------------------------------
## Nur noch fuer den Sniper: die Uzi hat seit dem Auto-Target-Rework ihr
## eigenes uzi_target_cone_deg (harter Lock statt weichem Assist, siehe oben).
## Rueckmeldung "RMB soll einen soft aim assist haben": Winkel von 5 auf 10
## Grad angehoben, damit er ueberhaupt spuerbar greift - strength bleibt bei
## 0.5 (weich, kein harter Lock wie bei der Uzi).
@export var aim_assist_angle_deg: float = 10.0
@export var aim_assist_strength: float = 0.5

var _uzi_ammo: int = 40
var _uzi_reloading: bool = false
var _uzi_locked_target: Node3D = null
var _uzi_esp_marker: Label3D = null

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
#
# REWORK "Auto-Target" (Rueckmeldung): frueher ein enger, praeziser Aim-
# Assist auf die reine Kamera-Blickrichtung (5 Grad Kegel, sanft eingeblendet
# per Slerp) - jetzt sucht sich die Uzi selbst den besten Gegner in einem
# breiten Blickkegel (uzi_target_cone_deg) und feuert DIREKT auf ihn, nicht
# mehr auf die rohe Blickrichtung. Ohne Ziel im Kegel faellt sie auf die
# alte reine Blickrichtung zurueck, damit LMB nie komplett ins Leere geht.
# ============================================================================
func _perform_primary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung.
	var look_dir: Vector3 = -_camera.global_transform.basis.z
	var target: Node3D = _resolve_uzi_target(origin, look_dir)
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_uzi_esp(target)

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	_spawn_muzzle_vfx(origin, dir)
	_spawn_tracer(origin, result["position"], 0.35, 0.06)
	if result["hit"]:
		var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		if spark:
			spark.scale *= 1.6
		_lock_model_to(result["target"])
		if player and player.has_method("shake_camera"):
			player.shake_camera(0.18)

	_uzi_ammo -= 1
	if _uzi_ammo <= 0:
		_uzi_ammo = uzi_magazine_size
		_uzi_reloading = true
		_primary_timer = uzi_reload_time


## Sticky Targeting - gleicher Grund wie combat_winter.gd::
## _resolve_laser_target(): ohne das koennte das gewaehlte Ziel bei mehreren
## nah beieinander stehenden Gegnern von Schuss zu Schuss wechseln.
func _resolve_uzi_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _uzi_locked_target != null and is_instance_valid(_uzi_locked_target):
		var health: Node = _uzi_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_uzi_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= uzi_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(uzi_target_cone_deg * 1.5)
		if alive and in_range and in_cone:
			return _uzi_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, uzi_range, uzi_target_cone_deg)


## Haelt einen einzelnen Label3D-Marker (billboard + no_depth_test, gleiches
## Muster wie damage_number.gd) ueber dem gerade automatisch anvisierten
## Ziel fest - das ist das in der Rueckmeldung verlangte "ESP" auf den
## beschossenen Gegner. no_depth_test sorgt dafuer, dass er auch durch
## Gegner/Deckung hindurch klar lesbar bleibt, nicht nur durch Waende.
func _update_uzi_esp(target: Node3D) -> void:
	if target == _uzi_locked_target and target != null and is_instance_valid(target):
		if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
			_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		return

	_clear_uzi_esp()
	_uzi_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_uzi_esp_marker = _build_esp_marker()
	get_tree().current_scene.add_child(_uzi_esp_marker)
	_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2


func _clear_uzi_esp() -> void:
	if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
		_uzi_esp_marker.queue_free()
	_uzi_esp_marker = null
	_uzi_locked_target = null


func _build_esp_marker() -> Label3D:
	var label := Label3D.new()
	label.text = "◆"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 72
	label.outline_size = 14
	label.modulate = uzi_esp_color
	label.outline_modulate = Color(uzi_esp_color.r * 0.2, uzi_esp_color.g * 0.2, uzi_esp_color.b * 0.2, 0.9)
	return label


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
	if _uzi_locked_target != null and not Input.is_action_pressed("attack_primary"):
		_clear_uzi_esp()


func get_uzi_ammo_remaining() -> int:
	return _uzi_ammo


func get_uzi_magazine_size() -> int:
	return uzi_magazine_size


## _uzi_esp_marker haengt unter current_scene, NICHT unter diesem Combat-Node
## (siehe _build_esp_marker()/_update_uzi_esp()) - ueberlebt einen
## Charakterwechsel also nicht automatisch. Explizit aufraeumen, sonst bleibt
## ein verwaister Marker in der Szene stehen, falls LMB genau beim Wechsel
## gehalten wurde.
func _exit_tree() -> void:
	_clear_uzi_esp()


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
	var dir: Vector3 = EnemyQuery.aim_assisted_direction(
		origin, -_camera.global_transform.basis.z, sniper_range, aim_assist_angle_deg, aim_assist_strength
	)
	var dmg: float = sniper_damage_per_shot * _damage_multiplier()
	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null
	var landed_hit: bool = false

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		_spawn_muzzle_vfx(origin, dir)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(origin, result["position"], 0.9, 0.12)
		if result["hit"]:
			landed_hit = true
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			if spark:
				spark.scale *= 2.2
			_lock_model_to(result["target"])
		if i < sniper_shot_count - 1:
			await get_tree().create_timer(0.03).timeout

	if landed_hit:
		# Kurzer Hit-Stop + kraeftige Kamera-Erschuetterung statt nur Shake -
		# verkauft das Gewicht eines Treffers, der die meisten Gegner sofort
		# toetet, deutlich staerker als reines Wackeln.
		Juice.impact(0.6, Juice.DURATION_HEAVY)


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


## "dir" ist hier die reine Schuss-/Blickrichtung (-Camera-Z). VFX.spawn()/
## _aim() orientieren aber nach der PROJEKT-Konvention "+Z ist vorne" (siehe
## primary_hitbox.gd swing_vfx-Kommentar) - deshalb hier NEGIERT uebergeben,
## sonst zeigt der Muendungsblitz sichtbar rueckwaerts, obwohl der Raycast
## selbst (der "dir" unnegiert bekommt) korrekt in Blickrichtung feuert.
## Sichtbarer Muendungsblitz-bis-Trefferpunkt-Streifen, kurz aufblitzend und
## sofort wieder weg (BeamVisual.create()/update() einmalig statt jeden
## Frame, siehe Winters Dauerstrahl fuer den Unterschied). Vorher hatte
## Giselle GAR KEINE sichtbare Flugbahn - nur Muendungsfunke und Einschlag,
## ohne Verbindung dazwischen wirkten ihre Schuesse kraftlos (Rueckmeldung
## "sieht sehr schwach aus").
func _spawn_tracer(origin: Vector3, endpoint: Vector3, radius_scale: float, life: float) -> void:
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color if data else Color(1.0, 0.85, 0.4)
	var beam: Dictionary = BeamVisual.create(self, color, radius_scale)
	if beam.is_empty():
		return
	BeamVisual.update(beam, origin, endpoint, 0.0)
	get_tree().create_timer(life).timeout.connect(func() -> void:
		BeamVisual.free_beam(beam)
	)


func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3) -> void:
	var vfx_dir: Vector3 = -dir
	var data: CharacterData = PartyManager.get_active_data()
	if data != null:
		VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, pos, data.attack_color, data.attack_color_secondary, vfx_dir)
	else:
		VFX.spawn(MUZZLE_VFX_SCENE, pos, vfx_dir)
