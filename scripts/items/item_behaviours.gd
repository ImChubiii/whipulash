
extends Node
class_name ItemBehaviours

# ============================================================================
# ItemBehaviours — hier steht, was die Items TATSAECHLICH tun.
# ============================================================================
# Wird von item_manager.gd als Kind erzeugt und haengt sich an dessen
# Signale. Jeder Effekt liegt in einem eigenen, klar benannten Block. Items,
# die NUR Stat-Boni geben (Magnetischer Kompass, Saeurefeste Stiefel,
# Proteinshake-Schadensteil), tauchen hier gar nicht auf — die erledigt
# ItemData.stat_modifiers.
#
# ALLE Zahlen liegen als Konstanten oben im jeweiligen Block, nicht mitten
# im Code. Balancing soll man an einer Stelle drehen koennen, ohne die Logik
# zu lesen.
#
# ############################################################################
# WICHTIG: DIESE DATEI ERSETZT AUCH item_behaviours_1.gd
# ############################################################################
# Es gab zwei Dateien mit demselben `class_name ItemBehaviours`. Godot bricht
# beim Projektladen ab, sobald beide existieren ("hides a global script
# class"). item_behaviours_1.gd muss geloescht werden; ihr einziger inhalt-
# licher Vorsprung (VFX-Preloads) ist hier eingearbeitet.
#
# ############################################################################
# WIE KILLS ERKANNT WERDEN — und wo die Grenze liegt
# ############################################################################
# Hitbox.take_damage laeuft VOR hit_landed. Wenn player_hit_enemy hier
# ankommt, ist der Gegner also schon tot, falls der Schlag toedlich war —
# ein Blick auf Health.is_alive() reicht als Kill-Erkennung.
#
# NICHT erfasst werden dadurch Kills durch Blutung, Schockwelle oder
# Umgebungsschaden. Das ist bewusst so: die Alternative waere, sich an das
# died-Signal JEDES Gegners zu haengen und dabei den Verursacher zu
# rekonstruieren (Health.last_damage_source zeigt bei einem Bleed-Tick auf
# den Spieler, bei Lava auf den Hazard). Der Aufwand steht in keinem
# Verhaeltnis zu "der Heiligenschein heilt gelegentlich nicht".
#
# ############################################################################
# WARUM MANCHE EFFEKTE UEBER Health.damage_taken LAUFEN
# ############################################################################
# Health.take_damage kann von aussen nicht abgebrochen werden. Effekte, die
# einen Treffer "verhindern" sollen (Wackelpudding-Ring, Handball-Polster),
# haengen sich deshalb an das damage_taken-Signal und machen den Schaden
# NACHTRAEGLICH rueckgaengig. Das ist kein Trick, sondern die einzige
# Reihenfolge, die funktioniert:
#
#     current_health -= schaden
#     health_changed.emit()
#     damage_taken.emit()      <- wir sind hier
#     if current_health <= 0: died.emit()
#
# Der Todes-Check kommt NACH unserem Signal. Wer hier current_health wieder
# auf 1 setzt, verhindert died.emit() vollstaendig — genau das braucht das
# Handball-Polster.

# --- VFX-Szenen -------------------------------------------------------------
# preload statt load: fehlt eine Szene, faellt das beim Projektstart auf und
# nicht erst, wenn zufaellig das passende Item droppt.
const HIT_SPARK_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")
const DUST_RING_SCENE: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const SPARK_YELLOW_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const HOLOGRAM_BLUE_SCENE: PackedScene = preload("res://scenes/vfx/hologram_blue.tscn")
const FLASH_WHITE_SCENE: PackedScene = preload("res://scenes/vfx/flash_white.tscn")

## Die Saeure-Lache der Stoeckelschuhe ist eine bestehende Hazard-Szene.
## Bewusst load() statt preload(): wer den Hazard-Ordner umbenennt, soll eine
## Warnung bekommen und keinen Parse-Fehler im ganzen Item-System.
const LEMONADE_SCENE_PATH: String = "res://scenes/hazards/lemonade.tscn"

const ENEMY_GROUP: String = "enemies"

# --- 1. Mamas Kochloeffel ---
const SPOON_DURATION: float = 0.75
const SPOON_SPEED_MULTIPLIER: float = 1.5

# --- 2. Rostiges Beil ---
const CLEAVER_CHANCE: float = 0.30
const BLEED_DURATION: float = 4.0
const BLEED_TICK_INTERVAL: float = 1.0
const BLEED_DAMAGE_PER_TICK: float = 5.0

# --- 3. Statische Socke ---
const SOCK_HITS_NEEDED: int = 6
const SOCK_RADIUS: float = 6.0
const SOCK_DAMAGE_MULTIPLIER: float = 2.0
const SOCK_KNOCKBACK: float = 14.0

# --- 4. Hoellenfeuer-Hoerner ---
const HORNS_MIN_SPEED: float = 18.0
const HORNS_CONTACT_RANGE: float = 2.0
const HORNS_DAMAGE: float = 35.0
const HORNS_KNOCKBACK: float = 18.0
const HORNS_COOLDOWN_PER_TARGET: float = 0.8

# --- 5. Heiliges Oel ---
const OIL_SPAWN_INTERVAL: float = 0.2
const OIL_LIFETIME: float = 3.0
const OIL_RADIUS: float = 1.1
const OIL_DAMAGE_PER_TICK: float = 3.0
const OIL_TICK_INTERVAL: float = 0.5
const OIL_SLOW_AMOUNT: float = 0.25
const OIL_MIN_SPEED: float = 3.0

# --- 6. Papas Starthilfekabel ---
const CABLES_DURATION: float = 0.28
const CABLES_DAMAGE: float = 45.0
const CABLES_STUN: float = 2.0
const CABLES_HIT_RADIUS: float = 2.6

# --- P4/1. Proteinshake aus den 90ern ---
## Faktor auf die Skalierung der Angriffs-Hitboxen. 0.85 = 15 % kleiner.
const SHAKE_HITBOX_SCALE: float = 0.85

# --- P4/2. Omas Enge Hosen ---
const PANTS_MIN_SPEED: float = 8.0
const PANTS_RANGE: float = 2.4
const PANTS_DAMAGE_FACTOR: float = 0.5
const PANTS_COOLDOWN_PER_TARGET: float = 1.0

# --- P4/3. Plastik-Heiligenschein ---
const HALO_HEAL_CHANCE: float = 0.10
const HALO_HEAL_AMOUNT: float = 0.5

# --- P4/4. Das Blutpakt ---
const PACT_HITS_PER_COST: int = 5
const PACT_SELF_DAMAGE: float = 0.5

# --- P4/5. Rostiger Dachnagel ---
const NAIL_CHANCE: float = 0.25
const NAIL_ROOT_DURATION: float = 1.5

# --- P4/6. Sturmfeuerzeug ---
const LIGHTER_RANGE: float = 8.0
## Halber Oeffnungswinkel in Grad. 45 = 90-Grad-Bogen.
const LIGHTER_HALF_ANGLE_DEG: float = 45.0
const LIGHTER_DAMAGE_MULTIPLIER: float = 3.0
const LIGHTER_BURN_DURATION: float = 3.0
const LIGHTER_BURN_TICK: float = 0.75
const LIGHTER_BURN_DAMAGE: float = 6.0

# --- P4/7. Schulbibliotheks-Buch ---
const BOOK_EXECUTE_THRESHOLD: float = 0.20

# --- P4/8. Wackelpudding-Ring ---
const JELLY_COOLDOWN: float = 4.0

# --- P4/9. Teufelchen-Outfit ---
const DEVIL_HEALTH_THRESHOLD: float = 0.50
const DEVIL_DAMAGE_MULTIPLIER: float = 1.50

# --- P4/10. Nonnen-Kutte ---
const HABIT_CHANCE: float = 0.25

# --- P4/12. Goldene Kreditkarte ---
const CARD_COINS_PER_STEP: int = 10
const CARD_BONUS_PER_STEP: float = 0.02
const CARD_MAX_BONUS: float = 0.50

# --- P4/13. Phiole Heiligenblut ---
const VIAL_RADIUS: float = 4.5
const VIAL_DAMAGE: float = 22.0

# --- P4/14. Papp-Wahrsagerbrett ---
const OUIJA_CHANCE: float = 0.20
const OUIJA_PIERCE_RANGE: float = 4.0

# --- P4/15. Ungerader Wuerfel ---
const DIE_BUFF_DURATION: float = 25.0
const DIE_BUFF_STRENGTH: float = 0.25

# --- P4/16. Plastik-Teufelshoerner ---
const PLASTIC_CONTACT_RANGE: float = 1.8
const PLASTIC_DAMAGE_FACTOR: float = 0.3
const PLASTIC_COOLDOWN_PER_TARGET: float = 0.6

# --- P4/17. Defekter Gameboy ---
const GAMEBOY_CHAIN_RANGE: float = 7.0
const GAMEBOY_DAMAGE_FACTOR: float = 0.45

# --- P4/18. Rote Pappfluegel ---
const WINGS_DURATION: float = 0.3
const WINGS_SPEED: float = 26.0

# --- P4/19. Mamas Stoeckelschuhe ---
const HEELS_MIN_SPEED: float = 6.0
const HEELS_SPAWN_INTERVAL: float = 0.45
const HEELS_LIFETIME: float = 2.0
const HEELS_SIZE: Vector3 = Vector3(3.0, 0.5, 3.0)
const HEELS_DAMAGE_PER_TICK: float = 4.0

# --- P4/20. Verfluchter Glueckswuerfel ---
const CURSED_RADIUS: float = 30.0

# --- Shader-Flash (FLASH_RED / FLASH_WHITE auf dem Spielermodell) ---
const FLASH_DURATION: float = 0.22
const FLASH_STRENGTH: float = 0.85

var _items: Node = null

# --- Laufzeit-Zustand -------------------------------------------------------
var _sock_hit_count: int = 0
var _pact_hit_count: int = 0
var _horns_cooldowns: Dictionary = {}
var _pants_cooldowns: Dictionary = {}
var _plastic_cooldowns: Dictionary = {}
var _oil_timer: float = 0.0
var _heels_timer: float = 0.0
var _cables_timer: float = 0.0
var _cables_hit: Array[int] = []
var _wings_timer: float = 0.0
var _wings_direction: Vector3 = Vector3.ZERO
var _jelly_cooldown: float = 0.0
var _pads_used_this_room: bool = false
var _book_used_in_stage: int = -1
var _devil_active: bool = false

## Zuletzt gesehener Raum bzw. Etage. Der ItemManager kennt kein
## "room_entered", nur "room_cleared" — fuer den Ungeraden Wuerfel und das
## Zuruecksetzen des Handball-Polsters brauchen wir aber den EINTRITT. Statt
## eine neue Signalkette durch RoomInstance und LevelGenerator zu ziehen,
## wird der aktuelle Raum hier abgefragt. Der Generator veroeffentlicht ihn
## ohnehin schon fuer Minimap und Boss-Leiste.
var _last_room: Vector2i = Vector2i(2147483647, 2147483647)
var _room_poll_timer: float = 0.0
const ROOM_POLL_INTERVAL: float = 0.25

var _player_health: Health = null
## Hitboxen, deren Skalierung wir veraendert haben — zum Zuruecksetzen beim
## Charakterwechsel.
var _scaled_hitboxes: Array[Node3D] = []


func _ready() -> void:
	_items = get_parent()
	if _items == null:
		return

	_items.player_hit_enemy.connect(_on_player_hit_enemy)
	_items.active_item_used.connect(_on_active_item_used)
	_items.player_ready.connect(_on_player_ready)
	_items.item_added.connect(_on_item_added)
	_items.coins_changed.connect(_on_coins_changed)
	_items.room_cleared.connect(_on_room_cleared)


# ============================================================================
# Grundlagen
# ============================================================================
func _player() -> CharacterBody3D:
	if _items == null:
		return null
	var p = _items.player
	if p is CharacterBody3D and is_instance_valid(p):
		return p
	return null


func _has(item_id: String) -> bool:
	return _items != null and _items.has_item(item_id)


func _stats() -> PlayerStats:
	if _items == null:
		return null
	var s = _items.stats
	return s as PlayerStats


func _health_of(enemy: Node) -> Health:
	if enemy == null or not is_instance_valid(enemy):
		return null
	return enemy.find_child("Health", true, false) as Health


## Alle lebenden Gegner im Umkreis, aufsteigend nach Entfernung.
func _enemies_near(origin: Vector3, radius: float, exclude: Node = null) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy) or enemy == exclude:
			continue
		if enemy.global_position.distance_to(origin) > radius:
			continue
		var health: Health = _health_of(enemy)
		if health == null or not health.is_alive():
			continue
		result.append(enemy)

	result.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		return a.global_position.distance_to(origin) < b.global_position.distance_to(origin)
	)
	return result


## Flache Blickrichtung des Spielers.
##
## Gerechnet ueber -basis.z des CameraPivot, NICHT ueber +Z. Das Projekt nutzt
## zwar +Z als Vorne fuer die MODELL-Ausrichtung (siehe atan2(dir.x, dir.z) in
## enemy_ai.gd), der CameraPivot folgt aber der Godot-Konvention. Die
## Starthilfekabel rechnen seit jeher genauso — wer das hier umdreht, dreht
## auch den Feuerbogen des Sturmfeuerzeugs um 180 Grad.
func _player_forward(player: CharacterBody3D) -> Vector3:
	var pivot := player.get_node_or_null("CameraPivot") as Node3D
	var forward: Vector3
	if pivot != null:
		forward = -pivot.global_transform.basis.z
	else:
		forward = -player.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() < 0.0001:
		return Vector3.FORWARD
	return forward.normalized()


func _spawn_vfx(scene: PackedScene, world_pos: Vector3, direction: Vector3 = Vector3.ZERO) -> void:
	if scene == null:
		return
	VFX.spawn(scene, world_pos, direction)


## Faerbt das Spielermodell kurz ein (FLASH_RED / FLASH_WHITE).
##
## Setzt flash_color/flash_strength im psx.gdshader. Modelle ohne
## ShaderMaterial werden stillschweigend uebersprungen — der Effekt ist
## Zuckerguss, kein Spielmechanismus, und darf nichts abbrechen.
func _flash_player(color: Color) -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	var materials: Array[ShaderMaterial] = []
	_collect_shader_materials(player, materials)
	if materials.is_empty():
		return

	for material: ShaderMaterial in materials:
		material.set_shader_parameter("flash_color", color)

	var tween: Tween = create_tween()
	tween.tween_method(
		func(value: float) -> void:
			for material: ShaderMaterial in materials:
				if is_instance_valid(material):
					material.set_shader_parameter("flash_strength", value),
		FLASH_STRENGTH, 0.0, FLASH_DURATION
	)


func _collect_shader_materials(node: Node, out: Array[ShaderMaterial]) -> void:
	var mesh := node as MeshInstance3D
	if mesh != null:
		# material_override hat Vorrang vor surface_material_override —
		# deshalb zuerst pruefen. Steht dort ein ShaderMaterial, sind die
		# Surface-Overrides ohnehin wirkungslos.
		if mesh.material_override is ShaderMaterial:
			out.append(mesh.material_override as ShaderMaterial)
		else:
			for i: int in range(mesh.get_surface_override_material_count()):
				var surface: Material = mesh.get_surface_override_material(i)
				if surface is ShaderMaterial:
					out.append(surface as ShaderMaterial)
	for child: Node in node.get_children():
		_collect_shader_materials(child, out)


# ============================================================================
# Anbindung an den Spieler (laeuft bei jedem Charakterwechsel neu)
# ============================================================================
func _on_player_ready(player: CharacterBody3D) -> void:
	if player == null or not is_instance_valid(player):
		return

	# Die alte Health-Instanz stirbt mit der alten Spieler-Instanz; Godot
	# loest deren Verbindungen selbst. Nur die Referenz wird neu gesetzt.
	_player_health = player.get_node_or_null("Health") as Health
	if _player_health != null:
		if not _player_health.damage_taken.is_connected(_on_player_damaged):
			_player_health.damage_taken.connect(_on_player_damaged)
		if not _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.connect(_on_player_health_changed)

	_scaled_hitboxes.clear()
	_apply_protein_shake_hitbox()
	_apply_ghost_collision()
	_refresh_credit_card_bonus()
	_refresh_devil_outfit()


## Wird bei JEDEM neu aufgesammelten Item gerufen — die passiven Dauereffekte
## unten muessen sich sofort einschalten und nicht erst beim naechsten
## Charakterwechsel.
func _on_item_added(_item: ItemData) -> void:
	_apply_protein_shake_hitbox()
	_apply_ghost_collision()
	_refresh_credit_card_bonus()
	_refresh_devil_outfit()


func _on_room_cleared(_room: Node) -> void:
	# Neuer Raum in Sicht -> Rettung des Handball-Polsters wieder scharf.
	_pads_used_this_room = false


# ----------------------------------------------------------------------------
# P4/1. Proteinshake aus den 90ern — kleinere Hitbox
# ----------------------------------------------------------------------------
# Der Schadensbonus steckt in stat_modifiers. Hier wird nur die Reichweite
# verkleinert.
#
# WARUM DIE HITBOX SKALIERT WIRD UND NICHT DIE COLLISIONSHAPE:
# Die Form ist eine SubResource der Charakter-Szene und wird von allen vier
# Charakteren geteilt. Sie zu veraendern wuerde in den anderen Charakteren
# nachwirken — derselbe geteilte-Resource-Fehler wie bei den BoxMeshes der
# Raeume. Die Area3D selbst zu skalieren ist instanzlokal und kostet nichts.
func _apply_protein_shake_hitbox() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	var wanted: float = SHAKE_HITBOX_SCALE if _has(ItemCatalog.ID_PROTEIN_SHAKE) else 1.0

	for path: String in ["CameraPivot/PrimaryHitbox", "CameraPivot/SecondaryHitbox"]:
		var hitbox := player.get_node_or_null(path) as Node3D
		if hitbox == null:
			continue
		hitbox.scale = Vector3.ONE * wanted


# ----------------------------------------------------------------------------
# P4/16. Plastik-Teufelshoerner — durch Gegner hindurchlaufen
# ----------------------------------------------------------------------------
# add_collision_exception_with() statt an den Kollisions-Layern zu drehen:
# welche Ebene "Gegner" ist, steht in den Charakter- und Gegner-Szenen und
# nicht im Code. Eine Ausnahme pro Paar ist layer-unabhaengig und laesst
# alles andere (Waende, Boden, Hazards) unangetastet.
func _apply_ghost_collision() -> void:
	var player: CharacterBody3D = _player()
	if player == null or not _has(ItemCatalog.ID_DEVIL_HORNS_PLASTIC):
		return

	for node: Node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		var enemy := node as PhysicsBody3D
		if enemy != null and is_instance_valid(enemy):
			player.add_collision_exception_with(enemy)


# ============================================================================
# Treffer-Events
# ============================================================================
func _on_player_hit_enemy(target: Node3D, hitbox: Hitbox) -> void:
	if target == null or not is_instance_valid(target):
		return

	var health: Health = _health_of(target)
	# Die Hitbox hat den Schaden bereits ausgeteilt, bevor dieses Signal
	# ankommt. Ein toter Gegner heisst also: dieser Schlag war der letzte.
	var was_kill: bool = health != null and not health.is_alive()
	var base_damage: float = hitbox.damage if hitbox != null else 15.0

	# --- Bestandsitems ---
	if _has(ItemCatalog.ID_WOODEN_SPOON):
		_apply_wooden_spoon()
	if _has(ItemCatalog.ID_RUSTY_CLEAVER):
		_apply_rusty_cleaver(target)
	if _has(ItemCatalog.ID_STATIC_SOCK):
		_apply_static_sock(hitbox)

	# --- Phase 4 ---
	if _has(ItemCatalog.ID_ROOF_NAIL):
		_apply_roof_nail(target)
	if _has(ItemCatalog.ID_BLOOD_PACT):
		_apply_blood_pact()
	if _has(ItemCatalog.ID_OUIJA_BOARD):
		_apply_ouija_board(target, base_damage)
	if _has(ItemCatalog.ID_BROKEN_GAMEBOY):
		_apply_broken_gameboy(target, base_damage)
	if _has(ItemCatalog.ID_GOLDEN_CREDIT_CARD):
		_spawn_vfx(SPARK_YELLOW_SCENE, target.global_position + Vector3.UP * 1.2)

	if was_kill:
		if _has(ItemCatalog.ID_PLASTIC_HALO):
			_apply_plastic_halo(target)
		if _has(ItemCatalog.ID_HOLY_BLOOD_VIAL):
			_apply_holy_blood_vial(target)

	# --- Game Juice -----------------------------------------------------
	# Der Hit-Stop haengt an der Wucht des Angriffs, nicht am Item: die
	# SecondaryHitbox macht doppelten Schaden und bekommt deshalb den
	# laengeren Freeze.
	if hitbox != null and hitbox.name.begins_with("Secondary"):
		Juice.hit_stop(Juice.DURATION_HEAVY)
	else:
		Juice.hit_stop(Juice.DURATION_LIGHT)


# ----------------------------------------------------------------------------
# 1. Mamas Kochloeffel — kurzer Schub + Unverwundbarkeit
# ----------------------------------------------------------------------------
func _apply_wooden_spoon() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	if _player_health != null:
		_player_health.set_invulnerable(SPOON_DURATION)

	var stats: PlayerStats = _stats()
	if stats != null:
		stats.add_timed_modifier(
			"buff:wooden_spoon",
			PlayerStats.STAT_MOVE_SPEED,
			SPOON_DURATION,
			0.0,
			SPOON_SPEED_MULTIPLIER
		)


# ----------------------------------------------------------------------------
# 2. Rostiges Beil — Blutung
# ----------------------------------------------------------------------------
# Nutzt den bestehenden StatusEffectManager statt einer eigenen Coroutine:
# der Effekt laeuft dann automatisch mit ab, wenn der Gegner stirbt oder der
# Raum zurueckgesetzt wird.
#
# Seit dem Patch an enemy_ai.gd tickt "bleed" auch wirklich Schaden — vorher
# stand dort nur "poison" und der Effekt lief ins Leere.
func _apply_rusty_cleaver(target: Node3D) -> void:
	if randf() > CLEAVER_CHANCE:
		return
	if not target.has_method("apply_status_effect"):
		return

	target.apply_status_effect(
		"bleed",
		BLEED_DURATION,
		BLEED_DAMAGE_PER_TICK,
		_player(),
		BLEED_TICK_INTERVAL
	)


# ----------------------------------------------------------------------------
# 3. Statische Socke — Schockwelle bei jedem 6. Treffer
# ----------------------------------------------------------------------------
func _apply_static_sock(hitbox: Hitbox) -> void:
	_sock_hit_count += 1
	if _sock_hit_count < SOCK_HITS_NEEDED:
		return
	_sock_hit_count = 0

	var player: CharacterBody3D = _player()
	if player == null:
		return

	var base_damage: float = hitbox.damage if hitbox != null else 15.0
	var wave_damage: float = base_damage * SOCK_DAMAGE_MULTIPLIER
	var origin: Vector3 = player.global_position

	for enemy: Node3D in _enemies_near(origin, SOCK_RADIUS):
		var health: Health = _health_of(enemy)
		if health == null:
			continue
		health.take_damage(wave_damage, player)

		if enemy.get("is_heavy") == true:
			continue

		var offset: Vector3 = enemy.global_position - origin
		var push := Vector3(offset.x, 0.0, offset.z)
		if push.length() < 0.01:
			push = _player_forward(player)
		push = push.normalized() * SOCK_KNOCKBACK

		if enemy.has_method("apply_knockback"):
			enemy.apply_knockback(push)
		elif enemy is CharacterBody3D:
			(enemy as CharacterBody3D).velocity += push

	_spawn_vfx(SPARK_YELLOW_SCENE, origin + Vector3.UP)
	Juice.impact(0.6, Juice.DURATION_HEAVY)


# ----------------------------------------------------------------------------
# P4/5. Rostiger Dachnagel — Gegner festnageln
# ----------------------------------------------------------------------------
# "rooted" wird von enemy_ai.is_movement_locked() ausgewertet und setzt das
# effektive Tempo auf 0. Angreifen darf ein gewurzelter Gegner weiterhin —
# das ist der Unterschied zu "stun".
func _apply_roof_nail(target: Node3D) -> void:
	if randf() > NAIL_CHANCE:
		return
	if not target.has_method("apply_status_effect"):
		return

	target.apply_status_effect("rooted", NAIL_ROOT_DURATION, 1.0, _player(), 0.0)
	_spawn_vfx(DUST_RING_SCENE, target.global_position)


# ----------------------------------------------------------------------------
# P4/4. Das Blutpakt — jeder 5. Treffer kostet eigenes Leben
# ----------------------------------------------------------------------------
# Der Schadensbonus steckt in stat_modifiers, hier steht nur der Preis.
#
# clear_invulnerable() wird NICHT aufgerufen: laeuft gerade eine
# Unverwundbarkeit (Kochloeffel, Pappfluegel), soll der Pakt sie nicht
# aushebeln. Der Spieler kommt dann eben einmal umsonst davon.
func _apply_blood_pact() -> void:
	_pact_hit_count += 1
	if _pact_hit_count < PACT_HITS_PER_COST:
		return
	_pact_hit_count = 0

	if _player_health == null or not _player_health.is_alive():
		return

	_player_health.take_damage(PACT_SELF_DAMAGE, null)
	_flash_player(Color(1.0, 0.1, 0.1))


# ----------------------------------------------------------------------------
# P4/3. Plastik-Heiligenschein — Heilung bei Kill
# ----------------------------------------------------------------------------
func _apply_plastic_halo(target: Node3D) -> void:
	if randf() > HALO_HEAL_CHANCE:
		return
	if _player_health == null:
		return

	_player_health.heal(HALO_HEAL_AMOUNT)

	var player: CharacterBody3D = _player()
	if player != null:
		_spawn_vfx(HOLOGRAM_BLUE_SCENE, player.global_position + Vector3.UP * 2.2)
	_spawn_vfx(HOLOGRAM_BLUE_SCENE, target.global_position + Vector3.UP)


# ----------------------------------------------------------------------------
# P4/13. Phiole Heiligenblut — Gegner explodieren bei Tod
# ----------------------------------------------------------------------------
func _apply_holy_blood_vial(target: Node3D) -> void:
	var origin: Vector3 = target.global_position
	var player: CharacterBody3D = _player()

	for enemy: Node3D in _enemies_near(origin, VIAL_RADIUS, target):
		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(VIAL_DAMAGE, player)

	_spawn_vfx(SPARK_YELLOW_SCENE, origin + Vector3.UP)
	_spawn_vfx(HIT_SPARK_SCENE, origin + Vector3.UP * 1.5)
	Juice.impact(0.5, Juice.DURATION_HEAVY)


# ----------------------------------------------------------------------------
# P4/14. Papp-Wahrsagerbrett — Schlag geht durch
# ----------------------------------------------------------------------------
# "Geht durch den Gegner hindurch" ist im Code die Aussage: der Schlag
# trifft ZUSAETZLICH den naechsten Gegner dahinter. Eine echte
# Kollisions-Durchdringung haette einen Eingriff in Hitbox._on_body_entered
# gebraucht, und die Wirkung waere fuer den Spieler dieselbe.
func _apply_ouija_board(target: Node3D, base_damage: float) -> void:
	if randf() > OUIJA_CHANCE:
		return

	var player: CharacterBody3D = _player()
	if player == null:
		return

	var forward: Vector3 = _player_forward(player)
	for enemy: Node3D in _enemies_near(target.global_position, OUIJA_PIERCE_RANGE, target):
		var offset: Vector3 = enemy.global_position - target.global_position
		offset.y = 0.0
		if offset.length_squared() < 0.0001:
			continue
		# Nur wer WEITER in Schlagrichtung steht, gilt als "dahinter".
		if forward.dot(offset.normalized()) < 0.4:
			continue

		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(base_damage, player)
		_spawn_vfx(FLASH_WHITE_SCENE, enemy.global_position + Vector3.UP * 1.2)
		break

	_flash_player(Color(1.0, 1.0, 1.0))


# ----------------------------------------------------------------------------
# P4/17. Defekter Gameboy — Kettenblitz
# ----------------------------------------------------------------------------
func _apply_broken_gameboy(target: Node3D, base_damage: float) -> void:
	var chain: Array[Node3D] = _enemies_near(target.global_position, GAMEBOY_CHAIN_RANGE, target)
	if chain.is_empty():
		return

	var next: Node3D = chain[0]
	var health: Health = _health_of(next)
	if health != null:
		health.take_damage(base_damage * GAMEBOY_DAMAGE_FACTOR, _player())

	# Zwei Funkenpunkte statt eines: der Blitz soll als STRECKE lesbar sein,
	# nicht als zweiter, zusammenhangloser Treffer.
	_spawn_vfx(SPARK_YELLOW_SCENE, target.global_position.lerp(next.global_position, 0.5) + Vector3.UP)
	_spawn_vfx(SPARK_YELLOW_SCENE, next.global_position + Vector3.UP)


# ============================================================================
# Reaktionen auf erlittenen Schaden
# ============================================================================
# Reihenfolge ist hier entscheidend, siehe Kopfkommentar:
#   1. Handball-Polster (verhindert den Tod - muss VOR allem anderen laufen)
#   2. Wackelpudding-Ring (macht den Schaden rueckgaengig)
#   3. Nonnen-Kutte / Pappfluegel (reagieren auf den Treffer)
func _on_player_damaged(amount: float, _source: Node3D) -> void:
	if _player_health == null:
		return

	if _has(ItemCatalog.ID_HANDBALL_PADS):
		_apply_handball_pads()

	if _has(ItemCatalog.ID_JELLY_RING):
		_apply_jelly_ring(amount)

	if _has(ItemCatalog.ID_NUN_HABIT):
		_apply_nun_habit()

	if _has(ItemCatalog.ID_CARDBOARD_WINGS):
		_apply_cardboard_wings()


# ----------------------------------------------------------------------------
# P4/11. Handball-Schulterpolster — einmal pro Raum den Tod verhindern
# ----------------------------------------------------------------------------
func _apply_handball_pads() -> void:
	if _pads_used_this_room:
		return
	if _player_health.current_health > 0.0:
		return

	_pads_used_this_room = true
	# died.emit() wird erst NACH diesem Signal geprueft — wer hier wieder
	# ueber 0 steht, stirbt nicht.
	_player_health.current_health = 1.0
	_player_health.health_changed.emit(1.0, _player_health.max_health)
	_player_health.set_invulnerable(1.0)

	var player: CharacterBody3D = _player()
	if player != null:
		_spawn_vfx(FLASH_WHITE_SCENE, player.global_position + Vector3.UP)
	_flash_player(Color(1.0, 1.0, 1.0))
	Juice.impact(0.9, Juice.DURATION_HEAVY)


# ----------------------------------------------------------------------------
# P4/8. Wackelpudding-Ring — Treffer blocken
# ----------------------------------------------------------------------------
func _apply_jelly_ring(amount: float) -> void:
	if _jelly_cooldown > 0.0:
		return
	_jelly_cooldown = JELLY_COOLDOWN

	_player_health.heal(amount)
	# Kurze Unverwundbarkeit hinterher: sonst schlaegt derselbe Gegner im
	# naechsten Frame nochmal zu und der Block fuehlt sich wirkungslos an.
	_player_health.set_invulnerable(0.25)

	var player: CharacterBody3D = _player()
	if player != null:
		_spawn_vfx(HOLOGRAM_BLUE_SCENE, player.global_position + Vector3.UP)


# ----------------------------------------------------------------------------
# P4/10. Nonnen-Kutte — Aktiv-Item aufladen
# ----------------------------------------------------------------------------
# Greift direkt in _active_charges des ItemManagers. Der fuehrende
# Unterstrich ist in GDScript reine Namenskonvention, kein Zugriffsschutz —
# und eine oeffentliche "recharge()"-Methode nur fuer dieses eine Item waere
# eine Aenderung an einer Datei, die das Feature sonst nicht anfasst.
func _apply_nun_habit() -> void:
	if randf() > HABIT_CHANCE:
		return
	if _items == null:
		return

	var charges = _items.get("_active_charges")
	if not (charges is Dictionary):
		return

	for slot: int in range(2):
		var item: ItemData = _items.active_items[slot]
		if item == null:
			continue
		if int((charges as Dictionary).get(item.id, 0)) <= 0:
			continue
		(charges as Dictionary)[item.id] = 0
		_items.active_item_charge_changed.emit(slot, 0, item.charge_rooms)
		_flash_player(Color(1.0, 1.0, 1.0))
		var player: CharacterBody3D = _player()
		if player != null:
			_spawn_vfx(FLASH_WHITE_SCENE, player.global_position + Vector3.UP)
		return


# ----------------------------------------------------------------------------
# P4/18. Rote Pappfluegel — Rueckwaerts-Dash mit I-Frames
# ----------------------------------------------------------------------------
func _apply_cardboard_wings() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	_wings_direction = -_player_forward(player)
	_wings_timer = WINGS_DURATION
	_player_health.set_invulnerable(WINGS_DURATION)
	_spawn_vfx(DUST_RING_SCENE, player.global_position)


# ----------------------------------------------------------------------------
# P4/9. Teufelchen-Outfit — Schadensbonus unter 50 % Leben
# ----------------------------------------------------------------------------
func _on_player_health_changed(_current: float, _maximum: float) -> void:
	_refresh_devil_outfit()


func _refresh_devil_outfit() -> void:
	var stats: PlayerStats = _stats()
	if stats == null:
		return

	var should_be_active: bool = false
	if _has(ItemCatalog.ID_DEVIL_OUTFIT) and _player_health != null:
		should_be_active = _player_health.get_health_percent() < DEVIL_HEALTH_THRESHOLD

	if should_be_active == _devil_active:
		return
	_devil_active = should_be_active

	if should_be_active:
		stats.add_modifier("buff:devil_outfit", PlayerStats.STAT_DAMAGE, 0.0, DEVIL_DAMAGE_MULTIPLIER)
		_flash_player(Color(1.0, 0.15, 0.15))
	else:
		stats.remove_source("buff:devil_outfit")


# ----------------------------------------------------------------------------
# P4/12. Goldene Kreditkarte — Schaden skaliert mit Muenzen
# ----------------------------------------------------------------------------
func _on_coins_changed(_amount: int) -> void:
	_refresh_credit_card_bonus()


func _refresh_credit_card_bonus() -> void:
	var stats: PlayerStats = _stats()
	if stats == null:
		return

	if not _has(ItemCatalog.ID_GOLDEN_CREDIT_CARD):
		stats.remove_source("buff:credit_card")
		return

	var steps: int = int(_items.coins) / CARD_COINS_PER_STEP
	var bonus: float = minf(float(steps) * CARD_BONUS_PER_STEP, CARD_MAX_BONUS)
	stats.add_modifier("buff:credit_card", PlayerStats.STAT_DAMAGE, 0.0, 1.0 + bonus)


# ============================================================================
# Aktive Items
# ============================================================================
# Signatur mit slot: das Signal heisst seit dem Q/E-Umbau
# active_item_used(item, slot). Die alte Fassung dieser Datei hat nur (item)
# entgegengenommen — Godot bricht so eine Verbindung zur Laufzeit mit
# "Error calling from signal" ab, und das aktive Item tut schlicht nichts.
func _on_active_item_used(item: ItemData, _slot: int) -> void:
	if item == null:
		return

	match item.id:
		ItemCatalog.ID_JUMPER_CABLES:
			_use_jumper_cables()
		ItemCatalog.ID_STORM_LIGHTER:
			_use_storm_lighter()
		ItemCatalog.ID_LIBRARY_BOOK:
			_use_library_book()
		ItemCatalog.ID_CURSED_DIE:
			_use_cursed_die()


# ----------------------------------------------------------------------------
# 6. Papas Starthilfekabel — Stoss-Dash
# ----------------------------------------------------------------------------
func _use_jumper_cables() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	var combat := player.get_node_or_null("Combat") as CombatBase
	if combat == null:
		return

	var forward: Vector3 = _player_forward(player)

	# Der bestehende Dash-Zustand von CombatBase wird direkt gesetzt, statt
	# eine eigene Bewegung zu bauen: player_base._physics_process fragt
	# combat.is_dashing() bereits ab und uebernimmt dann die Dash-Velocity.
	# So laeuft der Stoss ueber exakt denselben, getesteten Codepfad wie der
	# normale Dash — inklusive Kamera-Federarm-Schutz.
	combat.set("_dash_direction", forward)
	combat.set("_dash_timer", CABLES_DURATION)
	combat.set("_is_dashing", true)

	if player.has_method("play_dash_fov_effect"):
		player.play_dash_fov_effect()

	_cables_timer = CABLES_DURATION
	_cables_hit.clear()
	Juice.shake(0.35)


# ----------------------------------------------------------------------------
# P4/6. Sturmfeuerzeug — 90-Grad-Feuerbogen
# ----------------------------------------------------------------------------
func _use_storm_lighter() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	var forward: Vector3 = _player_forward(player)
	var origin: Vector3 = player.global_position
	var base_damage: float = 15.0
	var primary := player.get_node_or_null("CameraPivot/PrimaryHitbox") as Hitbox
	if primary != null:
		base_damage = primary.damage

	var cos_limit: float = cos(deg_to_rad(LIGHTER_HALF_ANGLE_DEG))
	var hit_any: bool = false

	for enemy: Node3D in _enemies_near(origin, LIGHTER_RANGE):
		var offset: Vector3 = enemy.global_position - origin
		offset.y = 0.0
		if offset.length_squared() < 0.0001:
			continue
		if forward.dot(offset.normalized()) < cos_limit:
			continue

		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(base_damage * LIGHTER_DAMAGE_MULTIPLIER, player)
		if enemy.has_method("apply_status_effect"):
			enemy.apply_status_effect("burn", LIGHTER_BURN_DURATION, LIGHTER_BURN_DAMAGE, player, LIGHTER_BURN_TICK)

		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
		hit_any = true

	# Funkenkranz im Bogen, auch ohne Treffer — sonst wirkt eine Fehlzuendung
	# wie ein nicht ausgeloestes Item.
	for step: int in range(5):
		var angle: float = deg_to_rad(lerpf(-LIGHTER_HALF_ANGLE_DEG, LIGHTER_HALF_ANGLE_DEG, float(step) / 4.0))
		var direction: Vector3 = forward.rotated(Vector3.UP, angle)
		_spawn_vfx(SPARK_YELLOW_SCENE, origin + direction * 3.0 + Vector3.UP, direction)

	Juice.impact(0.8 if hit_any else 0.3, Juice.DURATION_HEAVY)


# ----------------------------------------------------------------------------
# P4/7. Schulbibliotheks-Buch — Hinrichtung, einmal pro Etage
# ----------------------------------------------------------------------------
func _use_library_book() -> void:
	var stage: int = _current_stage()
	if stage == _book_used_in_stage:
		return
	_book_used_in_stage = stage

	var player: CharacterBody3D = _player()
	if player == null:
		return

	for node: Node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var health: Health = _health_of(enemy)
		if health == null or not health.is_alive():
			continue
		if health.get_health_percent() > BOOK_EXECUTE_THRESHOLD:
			continue

		# Grosszuegig ueberdosiert: Ruestungs-Multiplikatoren des Gegners
		# duerfen die Hinrichtung nicht in einen Kratzer verwandeln.
		health.take_damage(health.max_health * 10.0, player)
		_spawn_vfx(FLASH_WHITE_SCENE, enemy.global_position + Vector3.UP)

	_spawn_vfx(FLASH_WHITE_SCENE, player.global_position + Vector3.UP * 2.0)
	_flash_player(Color(1.0, 1.0, 1.0))
	Juice.impact(1.0, Juice.DURATION_HEAVY)


# ----------------------------------------------------------------------------
# P4/20. Verfluchter Glueckswuerfel — Drops umwandeln
# ----------------------------------------------------------------------------
# Bestehende Pickups werden ERSETZT, nicht umgeschrieben: pickup.gd baut sein
# Aussehen komplett in _ready() (Mesh, Farbe, Glow, Licht). Ein nachtraeglich
# geaendertes `kind` waere mechanisch ein Herz und optisch weiter eine Muenze.
func _use_cursed_die() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	var found: Array[Pickup] = []
	_collect_pickups(get_tree().current_scene, found)

	var kinds: Array[int] = [Pickup.Kind.COIN, Pickup.Kind.HEAL, Pickup.Kind.BOMB]
	var converted: int = 0

	for pickup: Pickup in found:
		if not is_instance_valid(pickup):
			continue
		# ITEM-Sockel bleiben unangetastet: ein Item gegen eine Muenze zu
		# tauschen waere kein Glueckswuerfel, sondern eine Strafe.
		if pickup.kind == Pickup.Kind.ITEM:
			continue
		if pickup.global_position.distance_to(player.global_position) > CURSED_RADIUS:
			continue

		var parent: Node = pickup.get_parent()
		if parent == null:
			continue

		var new_kind: int = kinds[randi() % kinds.size()]
		var position: Vector3 = pickup.global_position

		var replacement: Pickup = Pickup.create(new_kind)
		parent.add_child(replacement)
		replacement.global_position = position

		_spawn_vfx(SPARK_YELLOW_SCENE, position + Vector3.UP * 0.5)
		pickup.queue_free()
		converted += 1

	if converted > 0:
		Juice.impact(0.4, Juice.DURATION_LIGHT)


func _collect_pickups(node: Node, out: Array[Pickup]) -> void:
	if node == null:
		return
	if node is Pickup:
		out.append(node as Pickup)
	for child: Node in node.get_children():
		_collect_pickups(child, out)


# ============================================================================
# Pro-Frame-Effekte
# ============================================================================
func _physics_process(delta: float) -> void:
	_tick_cooldowns(delta)
	_poll_current_room(delta)

	var player: CharacterBody3D = _player()
	if player == null:
		return

	if _has(ItemCatalog.ID_BRIMSTONE_HORNS):
		_process_brimstone_horns(player)
	if _has(ItemCatalog.ID_HOLY_OIL):
		_process_holy_oil(player, delta)
	if _has(ItemCatalog.ID_TIGHT_PANTS):
		_process_tight_pants(player)
	if _has(ItemCatalog.ID_DEVIL_HORNS_PLASTIC):
		_process_plastic_horns(player)
	if _has(ItemCatalog.ID_STILETTO_HEELS):
		_process_stiletto_heels(player, delta)

	if _cables_timer > 0.0:
		_process_jumper_cables(player, delta)
	if _wings_timer > 0.0:
		_process_cardboard_wings(player, delta)


func _tick_cooldowns(delta: float) -> void:
	_jelly_cooldown = maxf(_jelly_cooldown - delta, 0.0)
	_tick_dictionary(_horns_cooldowns, delta)
	_tick_dictionary(_pants_cooldowns, delta)
	_tick_dictionary(_plastic_cooldowns, delta)


func _tick_dictionary(store: Dictionary, delta: float) -> void:
	if store.is_empty():
		return
	var expired: Array = []
	for id in store.keys():
		var remaining: float = float(store[id]) - delta
		if remaining <= 0.0:
			expired.append(id)
		else:
			store[id] = remaining
	for id in expired:
		store.erase(id)


# ----------------------------------------------------------------------------
# 4. Hoellenfeuer-Hoerner — Ramm-Attacke bei hohem Tempo
# ----------------------------------------------------------------------------
# Ausgewertet wird die HORIZONTALE Geschwindigkeit plus die Naehe zum Gegner,
# nicht get_slide_collision(). Der Grund: eine Kollisionsabfrage haette einen
# Eingriff in player_base._physics_process gebraucht, und gegen einen Gegner,
# der selbst wegrennt, meldet move_and_slide je nach Frame gar keine
# Kollision — die Ramme haette dann zufaellig ausgesetzt.
func _process_brimstone_horns(player: CharacterBody3D) -> void:
	var flat := Vector3(player.velocity.x, 0.0, player.velocity.z)
	if flat.length() < HORNS_MIN_SPEED:
		return
	var direction: Vector3 = flat.normalized()

	for enemy: Node3D in _enemies_near(player.global_position, HORNS_CONTACT_RANGE):
		var id: int = enemy.get_instance_id()
		if _horns_cooldowns.has(id):
			continue

		var offset: Vector3 = enemy.global_position - player.global_position
		offset.y = 0.0
		if offset.length_squared() < 0.0001:
			continue
		# Nur, wenn der Gegner tatsaechlich VOR mir liegt — sonst rammt man
		# jemanden, an dem man gerade vorbeigelaufen ist.
		if direction.dot(offset.normalized()) < 0.3:
			continue

		var health: Health = _health_of(enemy)
		if health == null:
			continue
		health.take_damage(HORNS_DAMAGE, player)
		_horns_cooldowns[id] = HORNS_COOLDOWN_PER_TARGET

		if enemy.get("is_heavy") != true and enemy.has_method("apply_knockback"):
			enemy.apply_knockback(direction * HORNS_KNOCKBACK)

		_spawn_vfx(HIT_SPARK_SCENE, enemy.global_position + Vector3.UP, direction)
		Juice.impact(0.7, Juice.DURATION_HEAVY)


# ----------------------------------------------------------------------------
# P4/2. Omas Enge Hosen — Tritt im Vorbeilaufen
# ----------------------------------------------------------------------------
# Schwaechere, aber breitere Variante der Hoerner: kein Mindesttempo von 18,
# dafuer nur halber Schaden und kein Rueckstoss.
func _process_tight_pants(player: CharacterBody3D) -> void:
	var flat := Vector3(player.velocity.x, 0.0, player.velocity.z)
	if flat.length() < PANTS_MIN_SPEED:
		return

	var base_damage: float = 15.0
	var primary := player.get_node_or_null("CameraPivot/PrimaryHitbox") as Hitbox
	if primary != null:
		base_damage = primary.damage

	for enemy: Node3D in _enemies_near(player.global_position, PANTS_RANGE):
		var id: int = enemy.get_instance_id()
		if _pants_cooldowns.has(id):
			continue
		_pants_cooldowns[id] = PANTS_COOLDOWN_PER_TARGET

		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(base_damage * PANTS_DAMAGE_FACTOR, player)

		# Staubring AM FUSS des Gegners, nicht auf Brusthoehe — der Tritt
		# soll als Bodenkontakt lesbar sein.
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position)
		Juice.hit_stop(Juice.DURATION_LIGHT)


# ----------------------------------------------------------------------------
# P4/16. Plastik-Teufelshoerner — Beruehrungsschaden beim Durchlaufen
# ----------------------------------------------------------------------------
func _process_plastic_horns(player: CharacterBody3D) -> void:
	var base_damage: float = 15.0
	var primary := player.get_node_or_null("CameraPivot/PrimaryHitbox") as Hitbox
	if primary != null:
		base_damage = primary.damage

	for enemy: Node3D in _enemies_near(player.global_position, PLASTIC_CONTACT_RANGE):
		var id: int = enemy.get_instance_id()
		if _plastic_cooldowns.has(id):
			continue
		_plastic_cooldowns[id] = PLASTIC_COOLDOWN_PER_TARGET

		var health: Health = _health_of(enemy)
		if health != null:
			health.take_damage(base_damage * PLASTIC_DAMAGE_FACTOR, player)
		_spawn_vfx(DUST_RING_SCENE, enemy.global_position)


# ----------------------------------------------------------------------------
# 5. Heiliges Oel — Spur aus Pfuetzen
# ----------------------------------------------------------------------------
func _process_holy_oil(player: CharacterBody3D, delta: float) -> void:
	var flat_speed: float = Vector3(player.velocity.x, 0.0, player.velocity.z).length()
	if flat_speed < OIL_MIN_SPEED:
		return

	_oil_timer -= delta
	if _oil_timer > 0.0:
		return
	_oil_timer = OIL_SPAWN_INTERVAL

	var parent: Node = get_tree().current_scene
	if parent == null:
		return

	var puddle := OilPuddle.new()
	puddle.setup(OIL_RADIUS, OIL_LIFETIME, OIL_DAMAGE_PER_TICK, OIL_TICK_INTERVAL, OIL_SLOW_AMOUNT, player)
	parent.add_child(puddle)
	# Leicht unter dem Pivot, sonst z-fightet die Scheibe mit der Bodenplatte.
	puddle.global_position = player.global_position + Vector3(0.0, -0.85, 0.0)


# ----------------------------------------------------------------------------
# P4/19. Mamas Stoeckelschuhe — Saeure-Lachen
# ----------------------------------------------------------------------------
# Nutzt die BESTEHENDE lemonade.tscn statt einer zweiten Pfuetzen-Klasse: die
# Lache bringt Schaden, Verlangsamung, Partikel und Optik bereits mit, und
# der Spieler erkennt sofort, dass es dieselbe Substanz ist wie die Hazards
# im Level.
#
# ignore_group = "player" ist Pflicht — ohne das laeuft man in die eigene
# Spur und zerlegt sich selbst. Der Export dafuer kam mit dem Lemonade-Patch
# aus Paket 1.
func _process_stiletto_heels(player: CharacterBody3D, delta: float) -> void:
	var flat_speed: float = Vector3(player.velocity.x, 0.0, player.velocity.z).length()
	if flat_speed < HEELS_MIN_SPEED:
		return

	_heels_timer -= delta
	if _heels_timer > 0.0:
		return
	_heels_timer = HEELS_SPAWN_INTERVAL

	var packed: PackedScene = load(LEMONADE_SCENE_PATH) as PackedScene
	if packed == null:
		push_warning("[Items] Stoeckelschuhe: '%s' nicht gefunden - keine Saeure-Lache." % LEMONADE_SCENE_PATH)
		return

	var parent: Node = get_tree().current_scene
	if parent == null:
		return

	var puddle: Node3D = packed.instantiate() as Node3D
	if puddle == null:
		return

	# VOR add_child(): _ready() der Lache registriert bereits ueberlappende
	# Bodies. Stuende ignore_group erst danach, waere der Spieler im ersten
	# Frame schon eingetragen.
	puddle.set("ignore_group", PartyManager.PLAYER_GROUP)
	puddle.set("hazard_mode", LavaHazard.HazardMode.SURFACE)
	puddle.set("damage_per_tick", HEELS_DAMAGE_PER_TICK)
	puddle.set("damage_on_entry", true)

	parent.add_child(puddle)
	puddle.global_position = player.global_position + Vector3(0.0, -0.75, 0.0)
	# size NACH add_child: der Setter greift auf @onready-Referenzen zu, die
	# vorher null sind (er ist null-sicher, aber die Groesse wuerde nicht
	# angewendet).
	puddle.set("size", HEELS_SIZE)

	_spawn_vfx(DUST_RING_SCENE, player.global_position)
	_despawn_after(puddle, HEELS_LIFETIME)


## Raeumt einen Node nach Ablauf wieder ab. Eigene Funktion, weil ein await
## mitten im _physics_process den restlichen Frame verschlucken wuerde.
func _despawn_after(node: Node, seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	if is_instance_valid(node):
		node.queue_free()


# ----------------------------------------------------------------------------
# 6. Papas Starthilfekabel — Trefferauswertung waehrend des Dashs
# ----------------------------------------------------------------------------
func _process_jumper_cables(player: CharacterBody3D, delta: float) -> void:
	_cables_timer -= delta

	for enemy: Node3D in _enemies_near(player.global_position, CABLES_HIT_RADIUS):
		var id: int = enemy.get_instance_id()
		if id in _cables_hit:
			continue
		if absf(enemy.global_position.y - player.global_position.y) > 3.0:
			continue

		var health: Health = _health_of(enemy)
		if health == null:
			continue

		_cables_hit.append(id)
		health.take_damage(CABLES_DAMAGE, player)

		if enemy.has_method("apply_stun"):
			enemy.apply_stun(CABLES_STUN)

		_spawn_vfx(SPARK_YELLOW_SCENE, enemy.global_position + Vector3.UP)
		Juice.impact(0.5, Juice.DURATION_HEAVY)

	if _cables_timer <= 0.0:
		_cables_hit.clear()


# ----------------------------------------------------------------------------
# P4/18. Rote Pappfluegel — der eigentliche Rueckwaerts-Schub
# ----------------------------------------------------------------------------
# Direkt auf velocity statt ueber den Dash-Zustand von CombatBase: der Dash
# richtet den Charakter aus und zaehlt in die Combo. Ein Treffer-Rueckstoss
# soll beides NICHT tun.
func _process_cardboard_wings(player: CharacterBody3D, delta: float) -> void:
	_wings_timer -= delta
	player.velocity.x = _wings_direction.x * WINGS_SPEED
	player.velocity.z = _wings_direction.z * WINGS_SPEED


# ============================================================================
# Raum- und Etagenwechsel
# ============================================================================
func _poll_current_room(delta: float) -> void:
	_room_poll_timer -= delta
	if _room_poll_timer > 0.0:
		return
	_room_poll_timer = ROOM_POLL_INTERVAL

	var generator: Node = _generator()
	if generator == null:
		return

	var current: Vector2i = generator.get_current_room()
	if current == _last_room:
		return
	_last_room = current

	# Neuer Raum betreten.
	_pads_used_this_room = false
	if _has(ItemCatalog.ID_CROOKED_DIE):
		_roll_crooked_die()


func _generator() -> Node:
	var found: Array[Node] = get_tree().get_nodes_in_group("level_generator")
	if found.is_empty():
		return null
	var generator: Node = found[0]
	if not is_instance_valid(generator) or not generator.has_method("get_current_room"):
		return null
	return generator


func _current_stage() -> int:
	var generator: Node = _generator()
	if generator == null or not generator.has_method("get_current_stage"):
		return 1
	return int(generator.get_current_stage())


# ----------------------------------------------------------------------------
# P4/15. Ungerader Wuerfel — zufaelliger Buff beim Raumbeitritt
# ----------------------------------------------------------------------------
# Bewusst randi() statt eines abgeleiteten RNG: Buffs sind reine Optik fuer
# den Speedrun-Vergleich - sie veraendern weder Layout noch Gegnermischung.
# Ein eigener Stream haette den Seed nur unnoetig verzweigt.
func _roll_crooked_die() -> void:
	var stats: PlayerStats = _stats()
	if stats == null:
		return

	var player: CharacterBody3D = _player()
	match randi() % 3:
		0:
			stats.add_timed_modifier("buff:crooked_die", PlayerStats.STAT_MOVE_SPEED,
				DIE_BUFF_DURATION, 0.0, 1.0 + DIE_BUFF_STRENGTH)
		1:
			stats.add_timed_modifier("buff:crooked_die", PlayerStats.STAT_DAMAGE,
				DIE_BUFF_DURATION, 0.0, 1.0 + DIE_BUFF_STRENGTH)
		_:
			# STAT_ARMOR ist ein Multiplikator auf ANKOMMENDEN Schaden -
			# kleiner ist besser. Deshalb hier 1 - Staerke statt 1 + Staerke.
			stats.add_timed_modifier("buff:crooked_die", PlayerStats.STAT_ARMOR,
				DIE_BUFF_DURATION, 0.0, 1.0 - DIE_BUFF_STRENGTH)

	if player != null:
		_spawn_vfx(HOLOGRAM_BLUE_SCENE, player.global_position + Vector3.UP * 2.0)


# ============================================================================
# Oel-Pfuetze
# ============================================================================
# Als verschachtelte Klasse statt eigener Datei: sie wird ausschliesslich von
# "Heiliges Oel" benutzt und braucht weder Szene noch Inspector-Werte.
class OilPuddle extends Area3D:
	var _lifetime: float = 3.0
	var _damage: float = 3.0
	var _tick_interval: float = 0.5
	var _slow_amount: float = 0.25
	var _source: Node3D = null
	var _tick_timer: float = 0.0
	var _age: float = 0.0
	var _mesh: MeshInstance3D = null

	func setup(radius: float, lifetime: float, damage: float, tick_interval: float, slow_amount: float, source: Node3D) -> void:
		_lifetime = lifetime
		_damage = damage
		_tick_interval = tick_interval
		_tick_timer = tick_interval
		_slow_amount = slow_amount
		_source = source

		var shape := CollisionShape3D.new()
		var cylinder := CylinderShape3D.new()
		cylinder.radius = radius
		cylinder.height = 0.6
		shape.shape = cylinder
		add_child(shape)

		var cyl_mesh := CylinderMesh.new()
		cyl_mesh.top_radius = radius
		cyl_mesh.bottom_radius = radius
		cyl_mesh.height = 0.06

		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.95, 0.90, 0.45, 0.55)

		_mesh = MeshInstance3D.new()
		_mesh.mesh = cyl_mesh
		# material_override statt surface_material_override — Vorrangregel.
		_mesh.material_override = material
		_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_mesh)

		monitoring = true
		# Siehe bomb.gd: enge Masken fallen beim Testen nicht auf.
		collision_mask = 0xFFFFF

	func _physics_process(delta: float) -> void:
		_age += delta
		if _age >= _lifetime:
			queue_free()
			return

		# Ausblenden statt hart verschwinden — sonst sieht die Spur aus wie
		# ein Fehler in der Darstellung.
		if _mesh and _mesh.material_override is StandardMaterial3D:
			var fade: float = clampf(1.0 - _age / _lifetime, 0.0, 1.0)
			var mat: StandardMaterial3D = _mesh.material_override
			mat.albedo_color.a = 0.55 * fade

		_tick_timer -= delta
		if _tick_timer > 0.0:
			return
		_tick_timer = _tick_interval

		for body: Node3D in get_overlapping_bodies():
			if not body.is_in_group("enemies"):
				continue
			var health := body.find_child("Health", true, false) as Health
			if health and health.is_alive():
				health.take_damage(_damage, _source)
			if body.has_method("apply_status_effect"):
				body.apply_status_effect("slow", _tick_interval + 0.1, _slow_amount, _source, 0.0)
