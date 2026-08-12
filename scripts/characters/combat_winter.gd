
extends CombatBase
class_name CombatWinter

# Winter: Energy/Crowd Control — Zonen-Kontrolle und stetiger DoT.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind weg - Q/E loesen jetzt immer das
# aktive Item im jeweiligen Slot aus, siehe combat_base.gd.
#
# Beide Faehigkeiten sind Hitscan/Projektil- statt Hitbox-basiert -
# PrimaryHitbox/SecondaryHitbox aus char_winter.tscn bleiben bewusst
# ungenutzt im Baum (siehe combat_base.gd-Kopfkommentar zu diesem Muster).

const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

## --- Primary "Magnetic Plasma" ---------------------------------------------
@export var plasma_damage: float = 12.0
## War 22.0 - Rueckmeldung "mehr Range der Enemy Detection beim Schiessen".
@export var plasma_range: float = 32.0
## Rueckmeldung "mehr Kugeln schiessen": statt eines einzelnen Bolts auf das
## naechste Ziel feuert Primary jetzt auf bis zu plasma_bolt_count
## UNTERSCHIEDLICHE nahe Ziele gleichzeitig - verteilt den Zusatzschaden auf
## die Gruppe, statt nur ein Ziel schneller zu ueberkillen.
@export var plasma_bolt_count: int = 2
## War als fester Parameter (16.0) an HomingBolt.spawn() durchgereicht -
## Rueckmeldung "schnellere Traveltime der Kugeln".
@export var plasma_bolt_speed: float = 24.0
@export var plasma_bolt_lifetime: float = 3.0
## Impuls, den ein getroffener Gegner Richtung Einschlag abbekommt - deutlich
## unter magnet_core.gd's PULL_IMPULSE_STRENGTH (16.0): stark genug, um kurz
## aus der Laufrichtung zu reissen, schwach genug, um niemanden komplett aus
## der Position zu ziehen.
@export var plasma_pull_strength: float = 10.0

## --- Secondary "Heavy Laser Stream" -----------------------------------------
@export var laser_damage_per_tick: float = 5.0
@export var laser_tick_interval: float = 0.05
@export var laser_range: float = 25.0
@export var laser_max_charge: float = 10.0
@export var laser_recharge_time: float = 5.0
@export var aim_assist_angle_deg: float = 5.0
@export var aim_assist_strength: float = 0.5
## Rework "Auto-Target wie Giselles Uzi" (Rueckmeldung): Blickkegel-
## Halbwinkel, in dem sich der Laser selbst sein Ziel sucht (siehe
## EnemyQuery.best_target_in_cone()) - ersetzt den alten praezisen, engen
## Aim-Assist oben fuer den Laser (aim_assist_* bleibt ungenutzt, falls
## spaeter wieder ein weicherer Modus gebraucht wird).
@export var laser_target_cone_deg: float = 35.0
## Farbe des ESP-Markers ueber dem gerade vom Laser anvisierten Ziel.
@export var laser_esp_color: Color = Color(1.0, 0.15, 0.1)

var _laser_energy: float = 10.0
var _laser_tick_timer: float = 0.0
var _laser_beam: Dictionary = {}
var _laser_locked_target: Node3D = null
var _laser_esp_marker: Label3D = null

var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null


func _init() -> void:
	primary_cooldown = 0.4
	# secondary_cooldown bleibt auf dem geerbten Standardwert - fuer den
	# Laser irrelevant, da _poll_secondary_input() ihn komplett durch das
	# Batterie-System unten ersetzt und nie _do_secondary() aufruft.
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_laser_energy = laser_max_charge


# ============================================================================
# Magnetic Plasma - feuert ueber das UNVERAENDERTE _poll_primary_input()/
# _do_primary() aus combat_base.gd (gehalten -> feuert erneut sobald
# primary_cooldown abgelaufen). Sucht sich selbst ein Ziel statt in
# Blickrichtung zu feuern - "soft homing" gemaess Spec.
# ============================================================================
func _perform_primary() -> void:
	var targets: Array[Node3D] = _pick_plasma_targets()
	if targets.is_empty():
		return

	var origin: Vector3 = player.global_position + Vector3.UP * 1.4
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color if data else Color(0.5, 1.0, 0.7)
	var dmg: float = plasma_damage * _damage_multiplier()

	for target: Node3D in targets:
		var on_strike: Callable = func(hit_target: Node3D) -> void:
			_on_plasma_strike(hit_target, origin, dmg)

		var bolt: HomingBolt = HomingBolt.spawn(
			self, origin, target, color, on_strike, plasma_bolt_speed, plasma_bolt_lifetime, false, player
		)
		if bolt:
			_attach_plasma_trail(bolt, color)


## Bis zu plasma_bolt_count lebende Gegner in Reichweite, naechster zuerst.
func _pick_plasma_targets() -> Array[Node3D]:
	var candidates: Array[Node3D] = EnemyQuery.enemies_within(player.global_position, plasma_range)
	var origin: Vector3 = player.global_position
	candidates.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position)
	)
	if candidates.size() > plasma_bolt_count:
		candidates.resize(plasma_bolt_count)
	return candidates


## HomingBolts nackte Kugel-Optik (geteilter Code mit Item-Minions, siehe
## homing_bolt.gd-Kopfkommentar - NICHT global aendern) liest sich als
## Magie-Geschoss, nicht als Plasma. Ein locker gestreuter Partikel-Schweif
## als Kind-Node behebt das, ohne die geteilte Basis anzufassen.
## local_coords = false: Partikel bleiben an ihrem Entstehungsort liegen,
## waehrend der Bolt weiterfliegt - genau das erzeugt den Schweif-Effekt.
func _attach_plasma_trail(bolt: Node3D, color: Color) -> void:
	var particles := GPUParticles3D.new()
	particles.emitting = true
	# Angehoben (Rueckmeldung "sieht schwach aus"): mehr, groessere Partikel
	# und ein eigenes Licht am Bolt selbst (unten) sollen ihn aus der
	# gesamten Kampfdistanz klar als staerkere Faehigkeit lesbar machen.
	particles.amount = 32
	particles.lifetime = 0.5
	particles.local_coords = false
	particles.one_shot = false

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3.ZERO
	mat.spread = 180.0
	mat.gravity = Vector3.ZERO
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.8
	mat.scale_min = 0.16
	mat.scale_max = 0.4
	mat.color = color
	particles.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.14
	mesh.height = 0.28
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_mat.albedo_color = color
	mesh_mat.emission_enabled = true
	mesh_mat.emission = color
	mesh_mat.emission_energy_multiplier = 3.2
	mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mesh_mat
	particles.draw_pass_1 = mesh

	bolt.add_child(particles)

	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 1.6
	light.omni_range = 4.5
	light.shadow_enabled = false
	bolt.add_child(light)


## origin ist die Abschusspositon (NICHT die aktuelle Bolt-Position - der
## Bolt selbst reicht seine Position nicht an den Callback durch, siehe
## homing_bolt.gd::_strike()). Die Zug-Richtung ist deshalb "vom Abschussort
## zum Einschlag", nicht "vom Ziel weg vom Einschlag" - liest sich als
## Schubs weiter in Flugrichtung, siehe Kopfkommentar-Entscheidung im Plan.
func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float) -> void:
	if not is_instance_valid(target):
		return
	var health: Node = target.find_child("Health", true, false)
	if health == null or not (health is Health) or not (health as Health).is_alive():
		return

	(health as Health).take_damage(dmg, player)

	# BUGFIX "LMB hat keine Damage Numbers": anders als der Laser (Hitscan.fire
	# bekommt eine damage_number_scene mit) spawnte der Plasma-Bolt-Treffer nie
	# eine Schadenszahl - derselbe Anzeigeweg wie Karinas Aura-Tick.
	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	if dns != null:
		var number: Node = dns.instantiate()
		get_tree().current_scene.add_child(number)
		(number as Node3D).global_position = target.global_position + Vector3(0.0, 1.8, 0.0)
		if number.has_method("show_damage"):
			number.show_damage(dmg)

	var pull_dir: Vector3 = target.global_position - origin
	pull_dir.y = 0.0
	# has_method()-Wache: NUR enemy_ai.gd und player_base.gd implementieren
	# apply_knockback() - die sechs CustomEnemyBase-Gegner (Moerser-Bot,
	# Saeure-Sprinkler, Magnet-Kern, Divebomber, Schild-Drohne, Plasmastrahl-
	# Bot) tun es NICHT und sollen einfach nur Schaden nehmen, ohne Fehler.
	if pull_dir.length_squared() > 0.01 and target.has_method("apply_knockback"):
		target.apply_knockback(pull_dir.normalized() * plasma_pull_strength)

	var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, target.global_position + Vector3.UP, Vector3.UP)
	if spark:
		spark.scale *= 1.7
	if player and player.has_method("shake_camera"):
		player.shake_camera(0.15)
	_lock_model_to(target)


# ============================================================================
# Heavy Laser Stream - Batterie statt Cooldown: ersetzt _poll_secondary_input
# komplett, ruft NIE _do_secondary()/den geerbten Cooldown-Mechanismus auf.
# ============================================================================
func _poll_secondary_input(delta: float) -> void:
	var held: bool = Input.is_action_pressed("attack_secondary")

	if held:
		# BUGFIX "Batterie laedt trotz gehaltener Taste wieder auf": vorher
		# fiel "gehalten, aber Energie=0" durch dieselbe Bedingung wie
		# "nicht gehalten" und startete sofort das Aufladen - solange man RMB
		# weiter gedrueckt hielt, pendelte die Energie dadurch nie richtig
		# hoch UND der Strahl blieb aus, obwohl man aktiv zu feuern versuchte.
		# Jetzt: solange gehalten wird, passiert entweder Feuern (Energie > 0)
		# oder GAR NICHTS (Energie leer) - aufgeladen wird ausschliesslich
		# nach dem Loslassen.
		if _laser_energy > 0.0:
			_laser_energy = maxf(_laser_energy - delta, 0.0)
			_update_laser(delta)
			if _laser_energy <= 0.0:
				_stop_laser()
		elif not _laser_beam.is_empty():
			_stop_laser()
		return

	if not _laser_beam.is_empty():
		_stop_laser()

	# Kein Mindest-Schwellenwert: die Formel selbst sorgt schon dafuer, dass
	# ein Teil-Ladezustand sofort wieder nutzbar ist, statt erst komplett
	# vollladen zu muessen ("partial charge = partial use" laut Spec).
	_laser_energy = minf(_laser_energy + delta * (laser_max_charge / laser_recharge_time), laser_max_charge)


func _update_laser(delta: float) -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung, siehe combat_giselle.gd.
	# Auto-Target statt weichem Aim-Assist (Rueckmeldung "wie bei Giselles
	# Uzi"): breiter Blickkegel, direkter Schuss aufs gefundene Ziel statt auf
	# die rohe Blickrichtung. Ohne Ziel im Kegel faellt der Strahl auf die
	# reine Blickrichtung zurueck.
	var look_dir: Vector3 = -_camera.global_transform.basis.z
	var target: Node3D = _resolve_laser_target(origin, look_dir)
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_laser_esp(target)

	_laser_tick_timer -= delta
	var do_damage: bool = _laser_tick_timer <= 0.0
	var dmg: float = laser_damage_per_tick * _damage_multiplier() if do_damage else 0.0
	var dns: PackedScene = (secondary_hitbox.damage_number_scene if secondary_hitbox else null) if do_damage else null

	# EIN Raycast pro Frame bedient beides: Schadenstick (nur wenn faellig)
	# UND die visuelle Strahl-Endposition (jeden Frame, damit der sichtbare
	# Strahl nicht zwischen zwei Ticks am alten Trefferpunkt "klebt").
	var result: Dictionary = Hitscan.fire(self, origin, dir, laser_range, dmg, player, dns)

	if do_damage:
		_laser_tick_timer = laser_tick_interval
		if result["hit"]:
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			if spark:
				spark.scale *= 1.4
			_lock_model_to(result["target"])
			# Leichtes Dauer-Rattern statt eines einzelnen Shakes - passt
			# besser zu einem Dauerstrahl als ein einmaliger Ausschlag und
			# macht spuerbar, dass der Strahl laufend Schaden macht statt
			# nur huebsch auszusehen (Rueckmeldung "sieht schwach aus").
			if player and player.has_method("shake_camera"):
				player.shake_camera(0.06)

	if _laser_beam.is_empty():
		var data: CharacterData = PartyManager.get_active_data()
		var color: Color = data.attack_color if data else Color(0.5, 0.9, 1.0)
		# Deutlich dicker als vorher (0.7 -> 1.3) - ein duenner Strahl liest
		# sich als schwacher Laserpointer statt als "Heavy Laser Stream".
		_laser_beam = BeamVisual.create(self, color, 1.3)

	BeamVisual.update(_laser_beam, origin, result["position"], delta)


func _stop_laser() -> void:
	BeamVisual.free_beam(_laser_beam)
	_laser_beam = {}
	_laser_tick_timer = 0.0
	_clear_laser_esp()


## BUGFIX "Strahl sieht aus wie einzelne Kugeln statt wie ein durchgehender
## Strahl (wie bei der Schild-Drohne)": ohne Sticky-Targeting waehlte
## best_target_in_cone() JEDEN Frame neu den "besten" Gegner - stehen mehrere
## nah beieinander, kann das Ergebnis frame-zu-frame kippen, und der
## Strahl-Endpunkt springt zwischen ihnen hin und her statt ruhig auf einem
## Ziel zu stehen. Jetzt wird das aktuelle Ziel gehalten, solange es lebt,
## in Reichweite ist und noch (grosszuegiger als der Such-Kegel, damit es
## nicht direkt an der Kegelgrenze flackert) im Blickfeld liegt - neu gesucht
## wird nur, wenn es wirklich wegfaellt.
func _resolve_laser_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _laser_locked_target != null and is_instance_valid(_laser_locked_target):
		var health: Node = _laser_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_laser_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= laser_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(laser_target_cone_deg * 1.5)
		if alive and in_range and in_cone:
			return _laser_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, laser_range, laser_target_cone_deg)


## Gleiches Muster wie combat_giselle.gd::_update_uzi_esp() - Label3D
## (billboard + no_depth_test) ueber dem gerade automatisch anvisierten Ziel.
func _update_laser_esp(target: Node3D) -> void:
	if target == _laser_locked_target and target != null and is_instance_valid(target):
		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		return

	_clear_laser_esp()
	_laser_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_laser_esp_marker = _build_laser_esp_marker()
	get_tree().current_scene.add_child(_laser_esp_marker)
	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2


func _clear_laser_esp() -> void:
	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
		_laser_esp_marker.queue_free()
	_laser_esp_marker = null
	_laser_locked_target = null


func _build_laser_esp_marker() -> Label3D:
	var label := Label3D.new()
	label.text = "◆"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 72
	label.outline_size = 14
	label.modulate = laser_esp_color
	label.outline_modulate = Color(laser_esp_color.r * 0.2, laser_esp_color.g * 0.2, laser_esp_color.b * 0.2, 0.9)
	return label


func get_laser_energy_percent() -> float:
	return _laser_energy / laser_max_charge if laser_max_charge > 0.0 else 0.0


## _laser_beam und _laser_esp_marker haengen unter current_scene, nicht unter
## diesem Combat-Node - ueberleben einen Charakterwechsel also nicht
## automatisch (gleicher Grund wie combat_giselle.gd::_exit_tree()).
func _exit_tree() -> void:
	_stop_laser()


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
func _damage_multiplier() -> float:
	var stats: PlayerStats = PlayerStats.find_for(self)
	return stats.get_damage_multiplier() if stats else 1.0


## Dreht das Charaktermodell zum getroffenen Ziel - dieselbe player_base.gd-
## Funktion, die auch Nahkampf-Treffer schon nutzen (siehe combat_base.gd::
## _on_hit_landed()). Weder HomingBolt-Treffer noch Hitscan-Treffer loesen
## das automatisch aus, da beide nie ueber die Hitbox-Signale laufen.
func _lock_model_to(target: Variant) -> void:
	if player and player.has_method("set_target") and target is Node3D:
		player.set_target(target)
