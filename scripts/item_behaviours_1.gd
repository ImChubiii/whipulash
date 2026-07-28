extends Node
class_name ItemBehaviours

# ============================================================================
# ItemBehaviours — hier steht, was die Items TATSAECHLICH tun.
# ============================================================================
# Wird von item_manager.gd als Kind erzeugt und haengt sich an dessen
# Signale. Jeder Effekt liegt in einem eigenen, klar benannten Block. Items,
# die nur Stat-Boni geben (Magnetischer Kompass, Saeurefeste Stiefel),
# tauchen hier gar nicht auf — die erledigt ItemData.stat_modifiers.
#
# ALLE Zahlen liegen als Konstanten oben im jeweiligen Block, nicht mitten
# im Code. Balancing soll man an einer Stelle drehen koennen, ohne die Logik
# zu lesen.

# --- VFX-Szenen ---
## Generischer Trefferfunke, ueber VFX.spawn() bei jedem Item-Treffer.
const HIT_SPARK_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

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
## Ab diesem Tempo (Einheiten/s, horizontal) zaehlt eine Beruehrung als Ramme.
const HORNS_MIN_SPEED: float = 18.0
const HORNS_CONTACT_RANGE: float = 2.0
const HORNS_DAMAGE: float = 35.0
const HORNS_KNOCKBACK: float = 18.0
## Sperre pro Gegner, damit ein Durchlaufen nicht 60x pro Sekunde trifft.
const HORNS_COOLDOWN_PER_TARGET: float = 0.8

# --- 5. Heiliges Oel ---
const OIL_SPAWN_INTERVAL: float = 0.2
const OIL_LIFETIME: float = 3.0
const OIL_RADIUS: float = 1.1
const OIL_DAMAGE_PER_TICK: float = 3.0
const OIL_TICK_INTERVAL: float = 0.5
const OIL_SLOW_AMOUNT: float = 0.25
## Erst ab diesem Tempo wird eine Spur gelegt — sonst pflastert Herumstehen
## den halben Raum zu.
const OIL_MIN_SPEED: float = 3.0

# --- 6. Papas Starthilfekabel ---
const CABLES_SPEED: float = 45.0
const CABLES_DURATION: float = 0.28
const CABLES_DAMAGE: float = 45.0
const CABLES_STUN: float = 2.0
const CABLES_HIT_RADIUS: float = 2.6

var _items: Node = null

# --- Laufzeit-Zustand ---
var _sock_hit_count: int = 0
var _horns_cooldowns: Dictionary = {}   # Gegner-InstanceID -> Restsperre
var _oil_timer: float = 0.0
var _cables_timer: float = 0.0
var _cables_hit: Array[int] = []
var _cables_direction: Vector3 = Vector3.ZERO


func _ready() -> void:
	_items = get_parent()
	if _items == null:
		return

	_items.player_hit_enemy.connect(_on_player_hit_enemy)
	_items.active_item_used.connect(_on_active_item_used)


func _player() -> CharacterBody3D:
	if _items == null:
		return null
	var p = _items.player
	if p is CharacterBody3D and is_instance_valid(p): 
		return p
	return null


# ============================================================================
# Treffer-Events
# ============================================================================
func _on_player_hit_enemy(target: Node3D, hitbox: Hitbox) -> void:
	if _items.has_item(ItemCatalog.ID_WOODEN_SPOON):
		_apply_wooden_spoon()

	if _items.has_item(ItemCatalog.ID_RUSTY_CLEAVER):
		_apply_rusty_cleaver(target)

	if _items.has_item(ItemCatalog.ID_STATIC_SOCK):
		_apply_static_sock(hitbox)

	# --- Trefferfunken -----------------------------------------------------
	# Generischer VFX-Funke bei jedem Item-Treffer. VFX.spawn() kuemmert
	# sich um Ausrichtung und Aufraeumen, siehe scripts/vfx_manager.gd.
	if is_instance_valid(target):
		VFX.spawn(HIT_SPARK_SCENE, target.global_position + Vector3.UP * 1.0)

	# --- Game Juice -----------------------------------------------------
	# Der Hit-Stop haengt an der Wucht des Angriffs, nicht am Item: die
	# SecondaryHitbox macht doppelten Schaden und bekommt deshalb den
	# laengeren Freeze. Das ist der Grund, warum _on_hitbox_hit die Hitbox
	# mitgibt statt nur das Ziel.
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

	var health := player.get_node_or_null("Health") as Health
	if health:
		health.set_invulnerable(SPOON_DURATION)

	if _items.stats:
		_items.stats.add_timed_modifier(
			"buff:wooden_spoon",
			PlayerStats.STAT_MOVE_SPEED,
			SPOON_DURATION,
			0.0,
			SPOON_SPEED_MULTIPLIER
		)


# ----------------------------------------------------------------------------
# 2. Rostiges Beil — Blutung
# ----------------------------------------------------------------------------
# Nutzt bewusst den bestehenden StatusEffectManager statt einer eigenen
# Coroutine: der Effekt laeuft dann automatisch mit ab, wenn der Gegner
# stirbt oder der Raum zurueckgesetzt wird, und ist im Debug sichtbar wie
# jeder andere Status auch.
#
# Das visuelle Bluten kommt automatisch mit: scenes/vfx/bleed_vfx.tscn
# traegt status_vfx.gd mit effect_id = "bleed" und schaltet sich selbst
# ueber StatusEffectManager.effect_applied/effect_expired. Diese Szene muss
# als Kind-Node in jeder Gegner-Szene liegen (siehe README, Schritt unten).
#
# WICHTIG: enemy_ai.gd muss "bleed" in _on_status_effect_ticked kennen,
# sonst tickt der Effekt ins Leere. Siehe README, Schritt 5.
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

	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		var offset: Vector3 = enemy.global_position - origin
		if offset.length() > SOCK_RADIUS:
			continue

		var health := enemy.find_child("Health", true, false) as Health
		if health == null or not health.is_alive():
			continue

		health.take_damage(wave_damage, player)

		if enemy.get("is_heavy") == true:
			continue

		var push: Vector3 = Vector3(offset.x, 0.0, offset.z)
		if push.length() < 0.01:
			push = -player.global_transform.basis.z
		push = push.normalized() * SOCK_KNOCKBACK

		if enemy.has_method("apply_knockback"):
			enemy.apply_knockback(push)
		elif enemy is CharacterBody3D:
			(enemy as CharacterBody3D).velocity += push

	Juice.impact(0.6, Juice.DURATION_HEAVY)


# ============================================================================
# Pro-Frame-Effekte
# ============================================================================
func _physics_process(delta: float) -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	_tick_horns_cooldowns(delta)

	if _items.has_item(ItemCatalog.ID_BRIMSTONE_HORNS):
		_process_brimstone_horns(player)

	if _items.has_item(ItemCatalog.ID_HOLY_OIL):
		_process_holy_oil(player, delta)

	if _cables_timer > 0.0:
		_process_jumper_cables(player, delta)


func _tick_horns_cooldowns(delta: float) -> void:
	if _horns_cooldowns.is_empty():
		return
	var expired: Array = []
	for id in _horns_cooldowns.keys():
		var remaining: float = float(_horns_cooldowns[id]) - delta
		if remaining <= 0.0:
			expired.append(id)
		else:
			_horns_cooldowns[id] = remaining
	for id in expired:
		_horns_cooldowns.erase(id)


# ----------------------------------------------------------------------------
# 4. Hoellenfeuer-Hoerner — Ramm-Attacke bei hohem Tempo
# ----------------------------------------------------------------------------
# Ausgewertet wird die HORIZONTALE Geschwindigkeit plus die Naehe zum
# Gegner, nicht get_slide_collision(). Der Grund: eine Kollisionsabfrage
# haette einen Eingriff in player_base._physics_process gebraucht, und
# gegen einen Gegner, der selbst wegrennt, meldet move_and_slide je nach
# Frame gar keine Kollision — die Ramme haette dann zufaellig ausgesetzt.
func _process_brimstone_horns(player: CharacterBody3D) -> void:
	var flat_velocity := Vector3(player.velocity.x, 0.0, player.velocity.z)
	if flat_velocity.length() < HORNS_MIN_SPEED:
		return

	var direction: Vector3 = flat_velocity.normalized()

	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		var id: int = enemy.get_instance_id()
		if _horns_cooldowns.has(id):
			continue

		var offset: Vector3 = enemy.global_position - player.global_position
		var flat_offset := Vector3(offset.x, 0.0, offset.z)
		if flat_offset.length() > HORNS_CONTACT_RANGE:
			continue
		# Nur, wenn der Gegner tatsaechlich VOR mir liegt — sonst rammt man
		# jemanden, an dem man gerade vorbeigelaufen ist.
		if direction.dot(flat_offset.normalized()) < 0.3:
			continue

		var health := enemy.find_child("Health", true, false) as Health
		if health == null or not health.is_alive():
			continue

		health.take_damage(HORNS_DAMAGE, player)
		_horns_cooldowns[id] = HORNS_COOLDOWN_PER_TARGET

		if enemy.get("is_heavy") != true:
			var push: Vector3 = direction * HORNS_KNOCKBACK
			if enemy.has_method("apply_knockback"):
				enemy.apply_knockback(push)

		Juice.impact(0.7, Juice.DURATION_HEAVY)


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
	# Leicht ueber dem Boden, sonst z-fightet die Scheibe mit der Bodenplatte.
	puddle.global_position = player.global_position + Vector3(0.0, -0.85, 0.0)


# ----------------------------------------------------------------------------
# 6. Papas Starthilfekabel — aktiver Stoss-Dash
# ----------------------------------------------------------------------------
func _on_active_item_used(item: ItemData) -> void:
	if item.id != ItemCatalog.ID_JUMPER_CABLES:
		return

	var player: CharacterBody3D = _player()
	if player == null:
		return

	var combat := player.get_node_or_null("Combat") as CombatBase
	var pivot := player.get_node_or_null("CameraPivot") as Node3D
	if combat == null or pivot == null:
		return

	# Blickrichtung flach: ein Stoss-Dash soll nicht in den Boden zielen.
	var forward: Vector3 = -pivot.global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		forward = Vector3.FORWARD
	_cables_direction = forward.normalized()

	# Der bestehende Dash-Zustand von CombatBase wird direkt gesetzt, statt
	# eine eigene Bewegung zu bauen: player_base._physics_process fragt
	# combat.is_dashing() bereits ab und uebernimmt dann die Dash-Velocity.
	# So laeuft der Stoss ueber exakt denselben, getesteten Codepfad wie
	# der normale Dash — inklusive Kamera-Federarm-Schutz.
	combat.set("_dash_direction", _cables_direction)
	combat.set("_dash_timer", CABLES_DURATION)
	combat.set("_is_dashing", true)

	if player.has_method("play_dash_fov_effect"):
		player.play_dash_fov_effect()

	_cables_timer = CABLES_DURATION
	_cables_hit.clear()
	Juice.shake(0.35)


func _process_jumper_cables(player: CharacterBody3D, delta: float) -> void:
	_cables_timer -= delta

	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		var id: int = enemy.get_instance_id()
		if id in _cables_hit:
			continue

		var offset: Vector3 = enemy.global_position - player.global_position
		if Vector3(offset.x, 0.0, offset.z).length() > CABLES_HIT_RADIUS:
			continue
		if absf(offset.y) > 3.0:
			continue

		var health := enemy.find_child("Health", true, false) as Health
		if health == null or not health.is_alive():
			continue

		_cables_hit.append(id)
		health.take_damage(CABLES_DAMAGE, player)

		if enemy.has_method("apply_stun"):
			enemy.apply_stun(CABLES_STUN)
		elif enemy.has_method("apply_status_effect"):
			enemy.apply_status_effect("stun", CABLES_STUN, 1.0, player, 0.0)

		Juice.impact(0.5, Juice.DURATION_HEAVY)

	if _cables_timer <= 0.0:
		_cables_hit.clear()


# ============================================================================
# Oel-Pfuetze
# ============================================================================
# Als verschachtelte Klasse statt eigener Datei: sie wird ausschliesslich
# von diesem Item benutzt und braucht weder Szene noch Inspector-Werte.
class OilPuddle extends Area3D:
	## Kontinuierliche Blasen-Partikel, solange die Pfuetze existiert.
	## Eigener const in der inneren Klasse, damit preload() hier zweifelsfrei
	## aufgeloest wird — Zugriff auf Outer-Class-Consts ist in verschachtelten
	## GDScript-Klassen nicht garantiert stabil.
	const BUBBLES_SCENE: PackedScene = preload("res://scenes/vfx/oil_bubbles.tscn")

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

		# Blasen als Kind-Emitter: teilen sich Lebenszyklus mit der Pfuetze
		# und werden automatisch mit queue_free() entsorgt — kein separates
		# Aufraeumen noetig.
		var bubbles: GPUParticles3D = BUBBLES_SCENE.instantiate()
		add_child(bubbles)
		bubbles.position = Vector3(0.0, 0.05, 0.0)
		bubbles.emitting = true

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
