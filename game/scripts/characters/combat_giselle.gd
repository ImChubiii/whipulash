
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

const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_muzzle_flash.tscn")
const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")

## BUGFIX "Muendungsblitz-Partikel fliegen in die Kamera": _spawn_muzzle_vfx()
## bekam bisher die Camera3D-Position selbst als Spawn-Punkt - der Effekt
## sass damit direkt AM Objektiv, und sein 75-Grad-Streuwinkel (siehe
## spark_yellow.tscn) rendert dadurch sichtbar ueber den ganzen Bildschirm
## statt als kleiner Blitz vor dem Lauf. Schiebt den Spawn-Punkt ein Stueck
## in Schussrichtung nach vorn, weg vom Objektiv.
const MUZZLE_FORWARD_OFFSET: float = 0.6

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
## Farbe des ESP-Markers ueber dem gerade automatisch anvisierten Ziel -
## siehe scripts/vfx/esp_target.gd.
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

## Zusaetzlicher seitlicher Kamera-Versatz waehrend des Sniper-Zooms, ON TOP
## von player_base.gd's staendigem camera_shoulder_offset - der Charakter
## steht beim Reinzoomen sonst mitten im Bild und verdeckt genau das Ziel,
## das man gerade anvisiert. Siehe _start_sniper_charge()/
## _release_sniper_charge() - laeuft als eigener Tween parallel zum FOV-Tween.
@export var sniper_aim_shoulder_offset: float = 1.1

## --- Aim-Assist (Sniper) ----------------------------------------------------
## Nur noch fuer den Sniper: die Uzi hat seit dem Auto-Target-Rework ihr
## eigenes uzi_target_cone_deg (harter Lock statt weichem Assist, siehe oben).
## War 10/0.5 ("soft aim assist"). Rueckmeldung "reicht nicht, Fadenkreuz
## soll viel staerker am Gegner kleben bleiben": Winkel auf 18 Grad und
## strength auf 0.85 angehoben - deutlich klebriger, aber bewusst NICHT 1.0,
## damit ein grob daneben gezielter Schuss noch knapp danebengehen kann statt
## komplett zum Aim-Bot zu werden. Bei Bedarf im Inspector weiter hochdrehen.
@export var aim_assist_angle_deg: float = 18.0
@export var aim_assist_strength: float = 0.85

var _uzi_ammo: int = 40
var _uzi_reloading: bool = false
var _uzi_locked_target: Node3D = null

var _sniper_charging: bool = false
var _sniper_locked_target: Node3D = null
var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null
var _default_fov: float = 75.0
var _fov_tween: Tween = null
## Ausgangswert von _spring_arm.position.x, EINMAL in setup() gelesen -
## player_base.gd hat den Shoulder-Offset zu dem Zeitpunkt schon gesetzt
## (siehe player_base.gd::_ready(), laeuft VOR combat.setup()). Der Sniper-
## Zoom tweent dorthin zurueck statt hart auf 0.0, damit ein evtl. per
## Inspector abweichender Standard-Offset erhalten bleibt.
var _default_shoulder_offset: float = 0.6
var _shoulder_tween: Tween = null


func _init() -> void:
	# War 0.08 - Rueckmeldung "schiesst minimal zu schnell". Leicht angehoben.
	primary_cooldown = 0.1
	secondary_cooldown = 5.0
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_uzi_ammo = uzi_magazine_size
	if _camera:
		_default_fov = _camera.fov
	if _spring_arm:
		_default_shoulder_offset = _spring_arm.position.x


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
	
	# Wenn kein Gegner im Visier ist, gar nicht erst schießen (Munition sparen)
	if target == null:
		return
		
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized()
	_update_uzi_esp(target)
	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man einen
	# Gegner beschiesst": frueher haengte _lock_model_to() nur am BESTAETIGTEN
	# Treffer (unten im result["hit"]-Zweig) - ein Ziel im Kegel, das die Uzi
	# gerade anvisiert, liess das Modell also stehen, solange der Schuss aus
	# irgendeinem Grund (Deckung, Rand des Kegels) nicht ankam. "Schiesst auf"
	# heisst schon "hat ein Ziel gewaehlt", nicht erst "hat getroffen".
	_lock_model_to(target)

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	
	var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
	_spawn_muzzle_vfx(muzzle_pos, dir)
	_spawn_tracer(muzzle_pos, result["position"], 0.35, 0.06)
	if result["hit"]:
		VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		if player and player.has_method("shake_camera"):
			player.shake_camera(0.18)
		EspTarget.flash(target)

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


## _uzi_locked_target bleibt das Sticky-Targeting-Gedaechtnis fuer
## _resolve_uzi_target() - die Anzeige selbst laeuft ueber den
## projektweiten Singular-Indikator, siehe scripts/vfx/esp_target.gd.
func _update_uzi_esp(target: Node3D) -> void:
	if target == null or not is_instance_valid(target):
		_clear_uzi_esp()
		return
	_uzi_locked_target = target
	EspTarget.acquire(target, uzi_esp_color)


func _clear_uzi_esp() -> void:
	if _uzi_locked_target != null:
		EspTarget.release(_uzi_locked_target)
	_uzi_locked_target = null


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


## EspTarget.release() raeumt nur auf, wenn diese Waffe gerade tatsaechlich
## den projektweiten Indikator haelt - explizit noetig, sonst bliebe er
## verwaist stehen, falls LMB/RMB genau beim Charakterwechsel gehalten wurde.
func _exit_tree() -> void:
	_clear_uzi_esp()
	_clear_sniper_esp()


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
		# ESP-Box waehrend des GESAMTEN Ladevorgangs aktuell halten - sticky
		# Targeting (siehe _resolve_sniper_esp_target()) sorgt dafuer, dass
		# sie nicht bei jedem winzigen Maus-Zittern auf einen anderen Gegner
		# umspringt.
		if _camera != null:
			var origin: Vector3 = _camera.global_position
			var look_dir: Vector3 = -_camera.global_transform.basis.z
			_update_sniper_esp(_resolve_sniper_esp_target(origin, look_dir))
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

	# Schulterblick-Versatz: der Charakter steht sonst mitten im Bild und
	# verdeckt beim Reinzoomen genau das Ziel (Rueckmeldung "Kamera-Shift
	# beim Zielen"). Reine Positions-Verschiebung des SpringArm3D-Ursprungs,
	# KEINE Rotationsaenderung - siehe player_base.gd::camera_shoulder_offset
	# fuer die ausfuehrliche Begruendung, warum das (statt Camera3D.h_offset)
	# den Schuss-Raycast (origin=Kamera-Position, dir=Kamera-Blickrichtung)
	# automatisch treffergenau mitverschiebt, ohne dass hier irgendetwas am
	# Zielsystem angepasst werden muss.
	if _spring_arm:
		_kill_shoulder_tween()
		_shoulder_tween = _spring_arm.create_tween()
		_shoulder_tween.tween_property(_spring_arm, "position:x", sniper_aim_shoulder_offset, sniper_zoom_in_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _release_sniper_charge() -> void:
	_sniper_charging = false
	if _camera:
		_kill_fov_tween()
		_fov_tween = _camera.create_tween()
		_fov_tween.tween_property(_camera, "fov", _default_fov, sniper_zoom_out_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	if _spring_arm:
		_kill_shoulder_tween()
		_shoulder_tween = _spring_arm.create_tween()
		_shoulder_tween.tween_property(_spring_arm, "position:x", _default_shoulder_offset, sniper_zoom_out_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Der Schuss loest erst HIER aus (nicht beim Druecken) - deshalb bleibt
	# der 5s-Cooldown fuer die volle Ladedauer unangetastet und startet
	# tatsaechlich erst beim Loslassen, wie in der Spec verlangt.
	if _secondary_timer <= 0.0:
		_do_secondary()


func _kill_fov_tween() -> void:
	if _fov_tween != null and _fov_tween.is_valid():
		_fov_tween.kill()


func _kill_shoulder_tween() -> void:
	if _shoulder_tween != null and _shoulder_tween.is_valid():
		_shoulder_tween.kill()


## Sticky Targeting fuer die Sniper-ESP-Box waehrend Ladevorgang + Burst -
## gleiches Muster wie _resolve_uzi_target()/combat_winter.gd::
## _resolve_laser_target(). Rein visuell, unabhaengig vom eigentlichen
## Schuss-Aim-Assist (der bleibt der reine Richtungs-Slerp unten in
## _perform_secondary() - EnemyQuery.aim_assisted_direction() feuert immer
## auf den WINKEL-naechsten Kandidaten im Feuermoment, nicht zwingend auf
## dieses gelockte Ziel; beide finden in der Praxis fast immer denselben
## Gegner, weil dieselbe Kegel-/Reichweiten-Logik zugrunde liegt).
func _resolve_sniper_esp_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
		var health: Node = _sniper_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_sniper_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= sniper_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(aim_assist_angle_deg * 1.5)
		if alive and in_range and in_cone:
			return _sniper_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, sniper_range, aim_assist_angle_deg)


## _sniper_locked_target bleibt das Sticky-Targeting-Gedaechtnis fuer
## _resolve_sniper_esp_target() - die Anzeige selbst laeuft ueber den
## projektweiten Singular-Indikator, siehe scripts/vfx/esp_target.gd.
func _update_sniper_esp(target: Node3D) -> void:
	if target == null or not is_instance_valid(target):
		_clear_sniper_esp()
		return
	_sniper_locked_target = target
	EspTarget.acquire(target, uzi_esp_color)


func _clear_sniper_esp() -> void:
	if _sniper_locked_target != null:
		EspTarget.release(_sniper_locked_target)
	_sniper_locked_target = null


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

	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man schiesst"
	# - gleicher Grund wie bei der Uzi: nicht erst auf einen bestaetigten
	# Treffer warten. _sniper_locked_target ist bereits waehrend des Ladens
	# (siehe _poll_secondary_input()) ermittelt.
	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
		_lock_model_to(_sniper_locked_target)

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		
		var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
		_spawn_muzzle_vfx(muzzle_pos, dir, 2.5)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(muzzle_pos, result["position"], 0.9, 0.12)
		if result["hit"]:
			landed_hit = true
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			if spark:
				spark.scale *= 2.2
			_lock_model_to(result["target"])
			EspTarget.flash(result["target"])
		if i < sniper_shot_count - 1:
			await get_tree().create_timer(0.03).timeout

	if landed_hit:
		# Kurzer Hit-Stop + kraeftige Kamera-Erschuetterung statt nur Shake -
		# verkauft das Gewicht eines Treffers, der die meisten Gegner sofort
		# toetet, deutlich staerker als reines Wackeln.
		Juice.impact(0.6, Juice.DURATION_HEAVY)

	# Burst ist fertig (RMB feuert nur einmal pro Ladevorgang) - ESP-Box
	# wieder einsammeln, statt sie bis zum naechsten Ladevorgang haengen zu
	# lassen.
	_clear_sniper_esp()


func is_sniper_charging() -> bool:
	return _sniper_charging


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
# _damage_multiplier() und _lock_model_to() leben jetzt in combat_base.gd
# (identisch dupliziert in Giselle/Karina/Winter - siehe dortige Kommentare).
# Hitscan-Treffer loesen _lock_model_to() nicht automatisch aus, da sie NIE
# ueber die Hitbox-Signale laufen (siehe Kopfkommentar oben) - deshalb wird
# es hier weiterhin explizit nachgezogen.


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


## BUGFIX "Partikel fliegen Richtung Kamera statt zum Ziel": vfx_dir war
## bisher "-dir" (also zurueck zum Schuetzen). vfx_manager.gd::spawn() ist
## eindeutig dokumentiert ("-Z des Effekts zeigt darauf, Godot-Konvention von
## look_at()") - mit "-dir" zeigte das lokale -Z des Muendungsblitzes damit
## RUECKWAERTS zur Kamera und +Z (nicht -Z) nach vorne zum Ziel, also genau
## verkehrt herum. Die alte Begruendung dafuer berief sich auf den
## "+Z ist vorne"-Kommentar in primary_hitbox.gd - der gilt aber nur fuer
## PrimaryHitbox, weil DIESES eine Area3D-Node im .tscn von Hand so gedreht
## wurde, dass sein +Z nach vorne zeigt. Das ist eine Eigenheit dieses einen
## Nodes, keine projektweite Konvention - fuer alles, was per VFX.spawn()
## ausgerichtet wird (wie hier), gilt ausschliesslich die -Z-Regel oben.
## "dir" (unnegiert) ist bereits die reine Schuss-/Blickrichtung, siehe
## Aufrufer - richtig ausgerichtet zeigt das jetzt tatsaechlich zum Ziel.
func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3, scale_mul: float = 1.0) -> void:
	var vfx_dir: Vector3 = dir
	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
	var data: CharacterData = PartyManager.get_active_data()
	var vfx: Node3D
	
	# Da AnimatedSprite3D von vfx_manager.gd (spawn_dual_tinted) nicht gefärbt wird,
	# funktioniert hier spawn() genauso gut für Originalfarben.
	if data != null:
		vfx = VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, spawn_pos, data.attack_color, data.attack_color_secondary, vfx_dir)
	else:
		vfx = VFX.spawn(MUZZLE_VFX_SCENE, spawn_pos, vfx_dir)
		
	if vfx != null and scale_mul != 1.0:
		vfx.scale *= scale_mul
