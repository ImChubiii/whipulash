
extends CombatBase
class_name CombatKarina

# Karina: Melee/Assassin — Mobilitaet, Debuffs, Hit-and-Run-Executes.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind weg - Q/E loesen jetzt immer das
# aktive Item im jeweiligen Slot aus, siehe combat_base.gd.
#
# Beide Faehigkeiten sind reine Halte-/Toggle-Zustaende statt Hitbox-Treffer -
# PrimaryHitbox/SecondaryHitbox aus char_karina.tscn bleiben komplett
# ungenutzt im Baum (siehe combat_base.gd-Kopfkommentar zu diesem Muster).
# Primary hat bewusst KEINEN klassischen Schlag: die Stance IST der gesamte
# Primary-Angriff.

const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")

## --- Primary "Acid Rush Mode" -----------------------------------------------
@export var stance_speed_bonus_mul: float = 1.2
@export var stance_max_duration: float = 10.0
@export var stance_reentry_cooldown: float = 1.0
@export var acid_aura_radius: float = 3.0
## Auf Rueckmeldung ("7 Schaden, sehr schneller Tick") von 15/0.4s umgestellt
## - 70 statt vorher 37.5 DPS, deutlich schneller lesbares Tick-Feedback.
@export var acid_tick_interval: float = 0.1
@export var acid_damage_per_tick: float = 7.0
@export var acid_effect_duration: float = 2.0

## --- Secondary "Phantom Execute" ---------------------------------------------
@export var stealth_max_duration: float = 5.0
@export var stealth_reentry_cooldown: float = 5.0
## War 1.6 - Rueckmeldung "Vernetzung (Markieren) funktioniert manchmal
## nicht, Hitbox sollte grosszuegiger sein". Auf 2.6 angehoben.
@export var stealth_touch_radius: float = 2.6
@export var detonation_damage: float = 220.0

const STANCE_MODIFIER_SOURCE: String = "karina_acid_rush"
## GeometryInstance3D.transparency (0=deckend, 1=unsichtbar) statt einzelne
## Material-Alpha-Werte umzubauen - funktioniert unabhaengig davon, welches
## Material das importierte Modell mitbringt, kein Material-Duplizieren
## noetig. Auf Rueckmeldung ("Deckkraft auf 4%") von 0.95 auf 0.96 (100%-4%)
## angehoben.
const STEALTH_MESH_TRANSPARENCY: float = 0.96
## War 0.15 - bei Karinas Lauftempo (~15-19 u/s) legt sie zwischen zwei
## Pruefungen bis zu ~2.85 Einheiten zurueck; bei einem Vorbeilaufen konnte
## das den Beruehrungs-Check komplett verpassen ("Vernetzung funktioniert
## manchmal nicht"). Auf 0.05 gesenkt (~20x/s statt ~6.7x/s).
const STEALTH_TOUCH_CHECK_INTERVAL: float = 0.05
## Motion-Blur-Trail (GhostTrail, siehe combat_base.gd) waehrend Phantom
## Execute auf 50% Staerke - deutlich ueber dem sehr dezenten Lauf-Trail-
## Default, siehe Rueckmeldung "motion blur trail auf 50%".
const STEALTH_TRAIL_ALPHA: float = 0.5

## "4x ihrer Groesse" fuer die Entladungs-Explosion beim Verlassen von
## Phantom Execute - CHARACTER_SIZE_ESTIMATE ist eine grobe Kapselgroesse
## als Basis, da keine exakte Charaktergroesse als Property existiert.
const DECLOAK_EXPLOSION_SIZE_MULTIPLIER: float = 4.0
const CHARACTER_SIZE_ESTIMATE: float = 2.0

var _stance_active: bool = false
var _acid_tick_timer: float = 0.0

var _stealth_active: bool = false
var _stealth_touch_timer: float = 0.0
var _marked_enemy_ids: Array[int] = []
## Array[Dictionary{beam: Dictionary (BeamVisual), from_id: int, to_id: int}]
## - Kettenverbindungen zwischen aufeinanderfolgend markierten Gegnern.
var _mark_beams: Array[Dictionary] = []

var _health: Health = null
## Fuer Karinas feste Passive "Reflexe" (Lifesteal-on-Hit, siehe
## item_behaviours.gd::try_karina_lifesteal()) - Karinas Angriffe laufen nie
## ueber Hitbox.hit_landed (siehe Klassenkommentar), das normale
## player_hit_enemy-Signal feuert fuer sie also nie. Direkter Aufruf bei
## jedem eigenen Treffer statt dessen.
var _item_behaviours: Node = null
var _meshes: Array[MeshInstance3D] = []
var _aura_visual: MeshInstance3D = null
var _aura_pulse_tween: Tween = null
## Urspruenglicher running_alpha-Wert des GhostTrail, VOR Phantom Execute -
## wird beim Betreten hochgesetzt (siehe STEALTH_TRAIL_ALPHA) und beim
## Verlassen exakt hierauf zurueckgesetzt statt auf einen fest verdrahteten
## Wert, falls der Trail char-spezifisch abweichend konfiguriert ist.
var _default_trail_alpha: float = 0.015


func _init() -> void:
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_health = player.get_node_or_null("Health") as Health
	_item_behaviours = get_node_or_null("/root/Items/ItemBehaviours")
	var model: Node = player.get_node_or_null("CharacterModel")
	_meshes = _collect_mesh_instances(model) if model else []
	if ghost_trail:
		_default_trail_alpha = ghost_trail.running_alpha


# ============================================================================
# Acid Rush Mode - Primary IST die Stance, es gibt keinen separaten Schlag.
# _primary_timer wird zweckentfremdet: waehrend der Stance zaehlt er die
# verbleibende Standzeit runter (Start bei stance_max_duration), danach die
# 1s-Wiedereintritts-Sperre - der bestehende Primary-Cooldown-Ring im HUD
# zeigt dadurch automatisch beides, ohne dass hud.gd etwas davon wissen muss.
# ============================================================================
func _poll_primary_input(delta: float) -> void:
	if _stance_active:
		if not Input.is_action_pressed("attack_primary") or _primary_timer <= 0.0:
			_exit_stance()
			return
		if _aura_visual and is_instance_valid(_aura_visual):
			_aura_visual.global_position = player.global_position + Vector3.UP * 0.05
		_tick_acid_aura(delta)
		return

	if Input.is_action_pressed("attack_primary") and _primary_timer <= 0.0:
		_enter_stance()


func _enter_stance() -> void:
	_stance_active = true
	_primary_timer = stance_max_duration
	_acid_tick_timer = 0.0

	if player:
		var data: CharacterData = PartyManager.get_active_data()
		var color: Color = data.attack_color if data else Color(0.9, 0.1, 0.25)
		VFX.spawn_dual_tinted(HIT_VFX_SCENE, player.global_position + Vector3.UP, color, color, Vector3.UP)
		_spawn_aura_visual(color)

	var stats: PlayerStats = PlayerStats.find_for(self)
	if stats:
		# Ueber die bestehende Item-Modifier-API statt player.speed direkt zu
		# schreiben - PlayerStats ist alleinige Autoritaet ueber den Wert
		# (siehe player_stats.gd-Kopfkommentar), ein direkter Schreibzugriff
		# hier wuerde beim naechsten Item-Pickup wieder ueberschrieben.
		stats.add_modifier(STANCE_MODIFIER_SOURCE, PlayerStats.STAT_MOVE_SPEED, 0.0, stance_speed_bonus_mul)


func _exit_stance() -> void:
	_stance_active = false
	_primary_timer = stance_reentry_cooldown
	_free_aura_visual()

	var stats: PlayerStats = PlayerStats.find_for(self)
	if stats:
		stats.remove_source(STANCE_MODIFIER_SOURCE)


## Durchsichtiger Ring am Boden, der acid_aura_radius sichtbar macht -
## vorher gab es fuer die Aura ausser einzelnen Treffer-Funken auf bereits
## infizierten Gegnern keinerlei Dauer-Feedback, wie weit sie tatsaechlich
## reicht.
func _spawn_aura_visual(color: Color) -> void:
	_free_aura_visual()
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(acid_aura_radius - 0.15, 0.05)
	torus.outer_radius = acid_aura_radius
	ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	# Angehoben (Rueckmeldung "sieht schwach aus"): kraeftigeres Leuchten,
	# damit die Aura auch aus Kampfdistanz klar als aktiver Effekt auffaellt.
	mat.emission_energy_multiplier = 2.2
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.7
	ring.material_override = mat
	get_tree().current_scene.add_child(ring)
	ring.global_position = player.global_position + Vector3.UP * 0.05
	_aura_visual = ring

	# Dauerhafte Rotation, damit die Aura als AKTIVER Effekt liest statt als
	# ruhendes Boden-Decal.
	var spin: Tween = ring.create_tween()
	spin.set_loops()
	spin.tween_property(ring, "rotation:y", TAU, 3.0).from(0.0).set_trans(Tween.TRANS_LINEAR)


func _free_aura_visual() -> void:
	if _aura_visual and is_instance_valid(_aura_visual):
		_aura_visual.queue_free()
	_aura_visual = null


func _tick_acid_aura(delta: float) -> void:
	_acid_tick_timer -= delta
	if _acid_tick_timer > 0.0:
		return
	_acid_tick_timer = acid_tick_interval

	# Kein DOT-Tick im Spiel spawnt normalerweise eine Schadenszahl (siehe
	# custom_enemy_base.gd/enemy_ai.gd::_on_status_effect_ticked() - ruft
	# take_damage() direkt auf, ohne Zahl) - fuer Karina wird das hier
	# explizit nachgezogen, da die Aura sonst komplett stumm ist. Nicht 1:1
	# mit dem tatsaechlichen internen Tick-Timer des StatusEffectManagers
	# synchron, aber nah genug (gleiches Intervall) fuer klares Feedback.
	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var hit_anyone: bool = false

	# BUGFIX "Primärangriff trifft in der Luft nicht": enemies_within() misst
	# volle 3D-Kugel-Distanz von Karinas Ursprung. Springt sie, wandert dieser
	# Ursprung nach oben, waehrend Gegner-Ursprünge am Boden bleiben - ab
	# Sprunghoehe + Fuesse-Versatz reicht das, um direkt daneben stehende
	# Gegner rechnerisch aus dem Radius fallen zu lassen (siehe enemy_query.gd
	# fuer die volle Herleitung). enemies_within_flat() trennt Horizontal-
	# Radius von einem grosszuegigen Hoehenfenster und trifft dadurch auch
	# waehrend eines Sprungs zuverlaessig.
	for enemy: Node3D in EnemyQuery.enemies_within_flat(player.global_position, acid_aura_radius, 3.0, 5.0):
		if enemy.has_method("apply_status_effect"):
			hit_anyone = true
			enemy.apply_status_effect("acid", acid_effect_duration, acid_damage_per_tick, player, acid_tick_interval)
			
			# Blut-VFX spawnen, da Karina sonst überhaupt kein Hit-Feedback am Gegner hat
			VFX.spawn(HIT_VFX_SCENE, enemy.global_position + Vector3.UP, Vector3.UP)
				
			if _item_behaviours:
				_item_behaviours.try_karina_lifesteal()
			if dns != null:
				var number: Node = dns.instantiate()
				get_tree().current_scene.add_child(number)
				(number as Node3D).global_position = enemy.global_position + Vector3(0.0, 1.8, 0.0)
				if number.has_method("show_damage"):
					number.show_damage(acid_damage_per_tick)

	# Kurzer Aufblitz-Puls am Aura-Ring, wenn sie GERADE tatsaechlich etwas
	# trifft - macht bei den schnellen 0.1s-Ticks (siehe acid_tick_interval)
	# lesbar, dass die Aura wirkt, ohne bei jedem einzelnen Tick eine neue
	# VFX-Szene abzufeuern (waere bei 10 Ticks/s reine Bildschirm-Unruhe).
	# Eigener, EXPLIZIT gekillter Tween statt eines neuen pro Tick: die
	# Pulsdauer (0.15s) ist laenger als das Tick-Intervall (0.1s) - ohne das
	# Killen wuerden sich mehrere Scale-Tweens ueberlappen und gegeneinander
	# ruckeln.
	if hit_anyone and _aura_visual and is_instance_valid(_aura_visual):
		if _aura_pulse_tween != null and _aura_pulse_tween.is_valid():
			_aura_pulse_tween.kill()
		_aura_visual.scale = Vector3.ONE * 1.25
		_aura_pulse_tween = _aura_visual.create_tween()
		_aura_pulse_tween.tween_property(_aura_visual, "scale", Vector3.ONE, 0.15) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## BUGFIX "Cooldown-Ring spinnt": der geerbte primary_cooldown (0.4s, fuer
## normale Angriffe gedacht) blieb ungenutzt/unveraendert, waehrend
## _primary_timer hier auf bis zu stance_max_duration (10s) gesetzt wird.
## get_primary_cooldown_percent() haette also 10.0 / 0.4 = 2500% berechnet -
## der Ring-Overlay bekommt einen anchor_top weit ausserhalb [0,1] und sieht
## kaputt aus. Gleicher Fehler wie Giselles Uzi-Reload, hier fuer die Stance.
func _get_effective_primary_cooldown() -> float:
	return stance_max_duration if _stance_active else stance_reentry_cooldown


# ============================================================================
# Phantom Execute - Halten statt Toggle: aktiviert per just_pressed, bleibt
# aktiv solange RMB gehalten wird und endet (inkl. Detonation) SOFORT beim
# Loslassen, oder frueher bei Ablauf von stealth_max_duration. Ruft NIE
# _do_secondary() auf, da der Cooldown erst NACH der Detonation starten soll,
# nicht beim Aktivieren.
#
# BUGFIX "muss nach dem Loslassen nochmal RMB druecken, damit die Explosion
# stattfindet": war urspruenglich ein Toggle (erneutes just_pressed beendet
# die Tarnung) - dadurch blieb man nach dem Loslassen unsichtbar stehen, bis
# man RMB ein zweites Mal drueckte. Jetzt beendet das simple Loslassen
# (nicht mehr gedrueckt) die Tarnung direkt und loest die Explosion sofort aus.
# ============================================================================
func _poll_secondary_input(delta: float) -> void:
	if _stealth_active:
		_tick_stealth(delta, not Input.is_action_pressed("attack_secondary"))
		return

	if Input.is_action_just_pressed("attack_secondary") and _secondary_timer <= 0.0:
		_start_stealth()


func _start_stealth() -> void:
	_stealth_active = true
	# Wiederverwendet fuer die aktive Restzeit (statt einer eigenen
	# _stealth_timer-Variable) - genau wie _primary_timer bei der Stance:
	# der bestehende Secondary-Cooldown-Ring zeigt dadurch waehrend der
	# gesamten Stealth-Dauer sichtbar "noch X Sekunden aktiv" an, statt die
	# ganze Zeit "bereit" zu zeigen und keinerlei Feedback zu geben, dass
	# ueberhaupt etwas passiert ist.
	_secondary_timer = stealth_max_duration
	_stealth_touch_timer = 0.0
	_marked_enemy_ids.clear()
	_clear_mark_beams()

	# Defensive Neubeschaffung, falls setup() vor der vollstaendigen
	# Instanziierung von CharacterModel/Health gelaufen sein sollte - kostet
	# im Normalfall nichts (Arrays/Referenzen sind schon gesetzt).
	if _health == null:
		_health = player.get_node_or_null("Health") as Health
	if _meshes.is_empty():
		var model: Node = player.get_node_or_null("CharacterModel")
		if model:
			_meshes = _collect_mesh_instances(model)

	if _health:
		_health.set_invulnerable_permanent(true)
	for mesh: MeshInstance3D in _meshes:
		mesh.transparency = STEALTH_MESH_TRANSPARENCY

	if ghost_trail:
		ghost_trail.running_alpha = STEALTH_TRAIL_ALPHA
		ghost_trail.set_running(true)

	_spawn_stealth_toggle_vfx()


func _tick_stealth(delta: float, force_end: bool) -> void:
	if force_end or _secondary_timer <= 0.0:
		_end_stealth()
		return

	# Jeden Frame, NICHT hinter dem Beruehrungs-Timer unten - sonst wuerden
	# die Verbindungslinien zwischen markierten Gegnern nur alle
	# STEALTH_TOUCH_CHECK_INTERVAL Sekunden nachziehen und sichtbar ruckeln,
	# waehrend sich Gegner dazwischen weiterbewegen.
	_update_mark_beams(delta)

	_stealth_touch_timer -= delta
	if _stealth_touch_timer > 0.0:
		return
	_stealth_touch_timer = STEALTH_TOUCH_CHECK_INTERVAL

	# Gleicher Grund wie in _tick_acid_aura(): flach statt Kugel-Radius, damit
	# ein Sprung waehrend Phantom Execute die "Vernetzung" nicht verpasst.
	for enemy: Node3D in EnemyQuery.enemies_within_flat(player.global_position, stealth_touch_radius, 3.0, 5.0):
		var id: int = enemy.get_instance_id()
		if not _marked_enemy_ids.has(id):
			# Verbindet den NEU markierten Gegner mit dem zuletzt markierten -
			# eine Kette statt aller Paare (N Verbindungen statt N*(N-1)/2),
			# bleibt dadurch auch bei vielen Markierungen lesbar. Siehe
			# Rueckmeldung "verbindet Gegner miteinander, damit man besser
			# erkennt wann ein Gegner gehittet wurde".
			if not _marked_enemy_ids.is_empty():
				_connect_marked_enemies(_marked_enemy_ids[_marked_enemy_ids.size() - 1], id)
			_marked_enemy_ids.append(id)
			_spawn_mark_vfx(enemy)


func _connect_marked_enemies(from_id: int, to_id: int) -> void:
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color_secondary if data else Color(1.0, 0.3, 0.7)
	_mark_beams.append({
		"beam": BeamVisual.create(self, color, 0.8),
		"from_id": from_id,
		"to_id": to_id,
	})


## Laeuft jeden Frame waehrend Phantom Execute aktiv ist - haelt die Ketten-
## Verbindungen an den aktuellen Positionen der (ggf. sich bewegenden)
## markierten Gegner fest. Ungueltig gewordene Enden (Gegner in dem Fenster
## gestorben) werden uebersprungen statt die Verbindung zu entfernen - sie
## verschwindet ohnehin spaetestens bei der naechsten _clear_mark_beams().
func _update_mark_beams(delta: float) -> void:
	for entry: Dictionary in _mark_beams:
		var from_obj: Object = instance_from_id(entry["from_id"])
		var to_obj: Object = instance_from_id(entry["to_id"])
		if from_obj == null or not is_instance_valid(from_obj) or not (from_obj is Node3D):
			continue
		if to_obj == null or not is_instance_valid(to_obj) or not (to_obj is Node3D):
			continue
		BeamVisual.update(
			entry["beam"],
			(from_obj as Node3D).global_position + Vector3.UP,
			(to_obj as Node3D).global_position + Vector3.UP,
			delta
		)


func _clear_mark_beams() -> void:
	for entry: Dictionary in _mark_beams:
		BeamVisual.free_beam(entry["beam"])
	_mark_beams.clear()


func _end_stealth() -> void:
	_stealth_active = false
	_clear_mark_beams()

	if _health:
		_health.clear_invulnerable()
	for mesh: MeshInstance3D in _meshes:
		mesh.transparency = 0.0

	if ghost_trail:
		ghost_trail.set_running(false)
		ghost_trail.running_alpha = _default_trail_alpha

	_spawn_stealth_toggle_vfx()
	_spawn_decloak_explosion()
	_detonate()
	# Erst JETZT, nach der Detonation, startet der Cooldown - waere er schon
	# in _start_stealth() gesetzt worden, liefe er waehrend der gesamten
	# Stealth-Dauer schon mit statt erst danach, siehe Spec ("Cooldown NACH
	# der Deaktivierung").
	_secondary_timer = stealth_reentry_cooldown


## "Beim Verlassen von Secondary entsteht zusaetzlich eine Explosion, 4x
## ihrer Groesse, mit demselben Effekt wie bei Bomben" - instanziiert
## deshalb woertlich eine echte Bomb-Instanz (scripts/bomb.gd) an Karinas
## Position und zuendet sie sofort per trigger_now(), statt deren komplette
## VFX-Kaskade (Feuerball/Kern/Schockwelle/Ring/Splitter/Licht/Brandfleck)
## hier zu duplizieren. damages_player = false: die Detonation soll ihr
## Abgang sein, nicht ein Strafschaden gegen sich selbst, direkt nachdem
## ihre Unverwundbarkeit endet.
func _spawn_decloak_explosion() -> void:
	if player == null:
		return
	var bomb := Bomb.new()
	bomb.explosion_radius = CHARACTER_SIZE_ESTIMATE * DECLOAK_EXPLOSION_SIZE_MULTIPLIER
	bomb.damage *= _damage_multiplier()
	bomb.damages_player = false
	bomb.thrower = player
	get_tree().current_scene.add_child(bomb)
	bomb.global_position = player.global_position
	bomb.trigger_now()


## BUGFIX "Cooldown-Ring spinnt" (Secondary-Variante, siehe
## _get_effective_primary_cooldown() oben): der geerbte secondary_cooldown
## (3.0s) blieb ungenutzt, waehrend _secondary_timer hier bis zu
## stealth_max_duration (5s) UND stealth_reentry_cooldown (ebenfalls 5s,
## zufaellig gleich) haelt - beides wuerde gegen den falschen Nenner
## rechnen. Als Nebeneffekt zeigt der Ring jetzt auch waehrend der aktiven
## Stealth-Phase sichtbar "noch X Sekunden" - vorher blieb er die ganze Zeit
## auf "bereit" stehen, obwohl die Faehigkeit laengst aktiv war.
func get_secondary_cooldown_percent() -> float:
	var cd: float = stealth_max_duration if _stealth_active else stealth_reentry_cooldown
	return _secondary_timer / cd if cd > 0.0 else 0.0


func _detonate() -> void:
	var had_marks: bool = not _marked_enemy_ids.is_empty()
	var dmg: float = detonation_damage * _damage_multiplier()
	# Aus dem ansonsten ungenutzten SecondaryHitbox-Node uebernommen statt
	# eine zweite damage_number_scene-Referenz zu pflegen - gleiche Idee wie
	# bei Giselle/Winter, siehe Kopfkommentar.
	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null

	for id: int in _marked_enemy_ids:
		var enemy: Object = instance_from_id(id)
		if enemy == null or not is_instance_valid(enemy) or not (enemy is Node3D):
			continue
		var enemy_3d: Node3D = enemy as Node3D
		var health: Node = enemy_3d.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue
		(health as Health).take_damage(dmg, player)
		if _item_behaviours:
			_item_behaviours.try_karina_lifesteal()
		VFX.spawn(HIT_VFX_SCENE, enemy_3d.global_position + Vector3.UP, Vector3.UP)

		if dns != null:
			var number: Node = dns.instantiate()
			get_tree().current_scene.add_child(number)
			(number as Node3D).global_position = enemy_3d.global_position + Vector3(0.0, 1.8, 0.0)
			if number.has_method("show_damage"):
				number.show_damage(dmg)

	_marked_enemy_ids.clear()

	if had_marks and player and player.has_method("shake_camera"):
		player.shake_camera(0.6)


func _spawn_mark_vfx(enemy: Node3D) -> void:
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color_secondary if data else Color(1.0, 0.3, 0.7)
	VFX.spawn_dual_tinted(HIT_VFX_SCENE, enemy.global_position + Vector3.UP, color, color, Vector3.UP)


## Unmissverstaendlicher Blitz am eigenen Charakter beim Ein-/Austreten aus
## Phantom Execute - die 95%-Transparenz allein (siehe STEALTH_MESH_
## TRANSPARENCY) ist aus Kampfdistanz/PSX-Dithering leicht zu uebersehen,
## das hier macht "hier ist gerade etwas passiert" unmissverstaendlich klar.
func _spawn_stealth_toggle_vfx() -> void:
	if player == null:
		return
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color_secondary if data else Color(1.0, 0.3, 0.7)
	VFX.spawn_dual_tinted(HIT_VFX_SCENE, player.global_position + Vector3.UP, color, color, Vector3.UP)
	if player.has_method("shake_camera"):
		player.shake_camera(0.2)


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
func _damage_multiplier() -> float:
	var stats: PlayerStats = PlayerStats.find_for(self)
	return stats.get_damage_multiplier() if stats else 1.0


## Rekursiv, damit auch verschachtelte Meshes des importierten Modells
## mitgezaehlt werden - gleiche Idee wie custom_enemy_base.gd's
## _collect_mesh_instances(), hier bewusst als eigene kleine Kopie statt
## einer Abhaengigkeit zu einer Gegner-Basisklasse.
func _collect_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		found.append(node)
	for child: Node in node.get_children():
		found.append_array(_collect_mesh_instances(child))
	return found
