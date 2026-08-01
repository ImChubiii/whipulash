extends Area3D
class_name Pickup

# ============================================================================
# Pickup — alles, was am Boden liegt und aufgesammelt werden kann.
# ============================================================================
# BAUT SEIN AUSSEHEN SELBST. Es gibt bewusst KEINE pickup.tscn:
#   * Vier Varianten (Muenze, Herz, Bombe, Item-Sockel) in einer Szene haetten
#     entweder vier deaktivierte Modelle im Baum oder vier fast identische
#     Szenendateien bedeutet.
#   * Der LootManager spawnt Pickups zur Laufzeit an Marker-Positionen. Eine
#     Szene haette dort nur einen weiteren Ressourcenpfad eingefuehrt, der
#     kaputtgehen kann.
# Wer spaeter richtige Modelle will, weist mesh_override im Inspector zu
# oder ersetzt _build_visual().

signal collected(kind: int, pickup: Pickup)

enum Kind {
	COIN,   ## Waehrung
	HEAL,   ## +heal_amount HP
	BOMB,   ## +1 Bombe im Inventar
	ITEM,   ## Sockel mit einem ItemData — muss aktiv genommen werden
}

@export var kind: Kind = Kind.COIN
@export var coin_value: int = 1
@export var heal_amount: float = 30.0
@export var bomb_amount: int = 1

## Optionales fertiges Modell. Bleibt es leer, wird die Form unten gebaut.
@export var mesh_override: Mesh

## Wie hoch/schnell das Pickup schwebt.
@export var bob_height: float = 0.18
@export var bob_speed: float = 2.2
@export var spin_speed: float = 1.6

## Ab dieser Naehe wird eingesammelt. Der Magnetradius kommt dagegen aus
## PlayerStats (Magnetischer Kompass erhoeht ihn).
@export var collect_distance: float = 1.1
@export var magnet_speed: float = 9.0

## Kurze Sperre nach dem Spawn: sonst saugt der Magnet ein Pickup ein, bevor
## der Spieler ueberhaupt sieht, dass etwas gedroppt ist.
@export var arm_delay: float = 0.35

## --- Bodenglanz (Lesbarkeit) ------------------------------------------
##
## Muenzen, Herzen und Bomben gehen im PSX-Dungeon unter: die Meshes sind
## klein, der Nebel schluckt Kontrast, und die Eigenfarbe (gelb/gruen/
## dunkelgrau) haelt gegen einen dunklen Boden kaum durch. Die Bombe ist
## als fast schwarze Kugel praktisch unsichtbar.
##
## Deshalb bekommt jedes einsammelbare Pickup zwei Zutaten:
##   1. einen WEISSEN, additiv gemischten Halo hinter dem Modell
##      (Billboard-Quad mit radialer GradientTexture2D — bewusst per Code
##      erzeugt statt als .png, damit kein Asset-Import noetig ist),
##   2. ein kleines weisses OmniLight3D, das den Boden ringsum aufhellt.
##
## Der Halo ist WEISS und nicht in der Item-Farbe: die Farbe unterscheidet
## die Sorten, die Helligkeit meldet "hier liegt was". Waere der Halo
## eingefaerbt, waere die Bombe wieder die dunkelste Fundsache im Raum.
##
## Kind.ITEM bleibt aussen vor — der Sockel hat bereits Label3D-Prompt und
## eigene Farbe.
@export var glow_enabled: bool = true
@export var glow_color: Color = Color(1.0, 1.0, 1.0)
## Kantenlaenge des Halo-Quads in Metern.
@export var glow_size: float = 1.5
## Deckkraft des Halos. Additiv gemischt — Werte ueber ~0.5 fressen die
## Silhouette des Modells auf.
@export_range(0.0, 1.0) var glow_opacity: float = 0.35
@export var glow_light_range: float = 3.2
@export var glow_light_energy: float = 1.4
## Wie stark Halo und Licht mit der Schwebebewegung pulsieren (0 = aus).
@export_range(0.0, 1.0) var glow_pulse: float = 0.25

## Nur fuer Kind.ITEM.
var item_data: ItemData = null

var _time: float = 0.0
var _base_y: float = 0.0
var _armed: bool = false
var _age: float = 0.0
var _collected: bool = false
var _visual: Node3D = null
var _prompt: Label3D = null
var _glow_quad: MeshInstance3D = null
var _glow_light: OmniLight3D = null
var _glow_material: StandardMaterial3D = null


func _ready() -> void:
	_base_y = global_position.y
	monitoring = true
	monitorable = false
	# Layer 0 lassen und nur die Maske setzen waere hier falsch: wir pruefen
	# die Distanz selbst in _physics_process, weil der Magnet ohnehin jeden
	# Frame rechnet. Die Area dient nur als Traeger fuer die Kollisionsform.
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = collect_distance
	shape.shape = sphere
	add_child(shape)

	_build_visual()

	if kind == Kind.ITEM:
		_build_prompt()


## Bequemer Konstruktor fuer den LootManager.
static func create(pickup_kind: Kind) -> Pickup:
	var pickup := Pickup.new()
	pickup.kind = pickup_kind
	pickup.name = "Pickup_%s" % Kind.keys()[pickup_kind]
	return pickup


static func create_item(data: ItemData) -> Pickup:
	var pickup := Pickup.create(Kind.ITEM)
	pickup.item_data = data
	return pickup


# ============================================================================
# Darstellung
# ============================================================================
func _build_visual() -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)

	if mesh_override != null:
		var custom := MeshInstance3D.new()
		custom.mesh = mesh_override
		custom.material_override = _make_material(_color_for_kind())
		_visual.add_child(custom)
		return

	match kind:
		Kind.COIN:
			_build_coin()
		Kind.HEAL:
			_build_cross()
		Kind.BOMB:
			_build_bomb()
		Kind.ITEM:
			_build_pedestal()

	if glow_enabled and kind != Kind.ITEM:
		_build_glow()


## Weisser Halo + Punktlicht.
##
## Der Halo haengt am _visual und macht dessen Schwebe- und Drehbewegung
## mit — er ist aber ein Billboard, die Drehung ist also unsichtbar. Das
## Licht haengt bewusst am Pickup SELBST und nicht am _visual: ein
## mitschwebendes Licht laesst den Boden atmen statt zu leuchten.
func _build_glow() -> void:
	# Radialer Verlauf weiss -> transparent. GradientTexture2D mit
	# FILL_RADIAL erspart eine .png im Repo und bleibt aufloesungsarm
	# genug fuer den PSX-Look.
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 64
	texture.height = 64

	_glow_material = StandardMaterial3D.new()
	_glow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_glow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_glow_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_glow_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_glow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Kein depth_draw, aber depth_TEST bleibt an: der Halo soll von Waenden
	# verdeckt werden, sonst leuchtet ein Pickup durch den halben Dungeon.
	_glow_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	_glow_material.no_depth_test = false
	_glow_material.albedo_texture = texture
	_glow_material.albedo_color = Color(glow_color.r, glow_color.g, glow_color.b, glow_opacity)
	_glow_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var quad := QuadMesh.new()
	quad.size = Vector2(glow_size, glow_size)

	_glow_quad = MeshInstance3D.new()
	_glow_quad.name = "Glow"
	_glow_quad.mesh = quad
	_glow_quad.material_override = _glow_material
	# Hinter dem Modell sortieren, damit die Silhouette oben bleibt.
	_glow_quad.sorting_offset = -0.05
	_glow_quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_visual.add_child(_glow_quad)

	_glow_light = OmniLight3D.new()
	_glow_light.name = "GlowLight"
	_glow_light.light_color = glow_color
	_glow_light.light_energy = glow_light_energy
	_glow_light.omni_range = glow_light_range
	# Schatten aus: ein Dutzend schattenwerfender Punktlichter nach einem
	# geraeumten Raum kostet auf Forward Mobile spuerbar Leistung, und ein
	# Pickup-Halo braucht keinen Schattenwurf.
	_glow_light.shadow_enabled = false
	_glow_light.position = Vector3(0.0, 0.35, 0.0)
	add_child(_glow_light)


func _color_for_kind() -> Color:
	match kind:
		Kind.COIN:
			return Color(0.98, 0.80, 0.22)
		Kind.HEAL:
			return Color(0.30, 0.95, 0.40)
		Kind.BOMB:
			return Color(0.20, 0.20, 0.24)
		Kind.ITEM:
			return item_data.pedestal_color if item_data else Color(0.95, 0.85, 0.35)
	return Color.WHITE


## Unshaded + volle Farbe: PSX-Optik lebt von flachen, gesaettigten Flaechen,
## und ein Pickup soll in einem dunklen Dungeon von weitem lesbar sein.
func _make_material(color: Color, emission: float = 0.6) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission
	return material


func _build_coin() -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.28
	mesh.bottom_radius = 0.28
	mesh.height = 0.07
	mesh.radial_segments = 10  # bewusst grob: PSX-Look

	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _make_material(_color_for_kind())
	# Hochkant, damit sich die Muenze beim Drehen zeigt statt zu liegen.
	instance.rotation_degrees.x = 90.0
	_visual.add_child(instance)


func _build_cross() -> void:
	var color: Color = _color_for_kind()
	var material := _make_material(color, 0.9)

	for i: int in range(2):
		var box := BoxMesh.new()
		box.size = Vector3(0.55, 0.18, 0.12) if i == 0 else Vector3(0.18, 0.55, 0.12)
		var instance := MeshInstance3D.new()
		instance.mesh = box
		instance.material_override = material
		_visual.add_child(instance)


func _build_bomb() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.26
	sphere.height = 0.52
	sphere.radial_segments = 10
	sphere.rings = 6

	var instance := MeshInstance3D.new()
	instance.mesh = sphere
	instance.material_override = _make_material(_color_for_kind(), 0.15)
	_visual.add_child(instance)

	# Zuendschnur, damit die Kugel nicht wie ein Stein aussieht.
	var fuse := CylinderMesh.new()
	fuse.top_radius = 0.03
	fuse.bottom_radius = 0.03
	fuse.height = 0.22
	var fuse_instance := MeshInstance3D.new()
	fuse_instance.mesh = fuse
	fuse_instance.material_override = _make_material(Color(0.75, 0.62, 0.35), 0.2)
	fuse_instance.position = Vector3(0.0, 0.32, 0.0)
	_visual.add_child(fuse_instance)


func _build_pedestal() -> void:
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 0.5, 0.5)
	var instance := MeshInstance3D.new()
	instance.mesh = box
	instance.material_override = _make_material(_color_for_kind(), 1.0)
	instance.rotation_degrees = Vector3(0.0, 45.0, 35.0)
	_visual.add_child(instance)


func _build_prompt() -> void:
	_prompt = Label3D.new()
	_prompt.text = "[F]"
	_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt.no_depth_test = true
	_prompt.pixel_size = 0.006
	_prompt.position = Vector3(0.0, 0.9, 0.0)
	_prompt.modulate = Color(1.0, 1.0, 1.0, 0.85)
	_prompt.visible = false
	add_child(_prompt)


# ============================================================================
# Bewegung, Magnet, Einsammeln
# ============================================================================
func _physics_process(delta: float) -> void:
	if _collected:
		return

	_age += delta
	if not _armed and _age >= arm_delay:
		_armed = true

	_time += delta
	if _visual:
		_visual.position.y = sin(_time * bob_speed) * bob_height
		_visual.rotate_y(spin_speed * delta)

	# Halo und Licht pulsieren im Takt der Schwebebewegung. Der Puls laeuft
	# ueber den KOSINUS, ist gegenueber der Hoehe also um eine
	# Viertelperiode versetzt: hell im Aufsteigen, matt im Absinken. Waeren
	# beide in Phase, saehe es aus, als wuerde das Modell blinken.
	if glow_pulse > 0.0:
		var pulse: float = 1.0 + cos(_time * bob_speed) * glow_pulse
		if _glow_material:
			_glow_material.albedo_color = Color(
				glow_color.r, glow_color.g, glow_color.b,
				clampf(glow_opacity * pulse, 0.0, 1.0)
			)
		if _glow_light:
			_glow_light.light_energy = glow_light_energy * pulse

	var player: Node3D = _find_player()
	if player == null:
		return

	var distance: float = global_position.distance_to(player.global_position)

	if kind == Kind.ITEM:
		_update_item_prompt(distance, player)
		return

	if not _armed:
		return

	# --- Magnet ------------------------------------------------------
	# Der Radius kommt aus PlayerStats, damit der Magnetische Kompass ihn
	# einfach anheben kann, ohne dass das Pickup das Item kennen muss.
	var magnet_range: float = _get_magnet_range()
	if distance <= magnet_range and distance > collect_distance:
		var to_player: Vector3 = (player.global_position - global_position)
		# Auf Bauchhoehe zielen statt auf die Fuesse: sonst kriecht die
		# Muenze am Boden entlang und bleibt an Kanten haengen.
		to_player.y += 0.6
		var step: float = magnet_speed * delta * clampf(1.0 - distance / maxf(magnet_range, 0.01), 0.35, 1.0) * 3.0
		global_position += to_player.normalized() * step
		return

	if distance <= collect_distance:
		_collect(player)


func _update_item_prompt(distance: float, player: Node3D) -> void:
	if _prompt:
		_prompt.visible = distance <= 2.5

	if distance > 2.5:
		return
	if not Input.is_action_just_pressed("interact"):
		return
	_collect(player)


func _get_magnet_range() -> float:
	var stats := _get_stats()
	if stats == null:
		return 2.2
	return stats.get_pickup_range()


func _get_stats() -> PlayerStats:
	var items: Node = get_node_or_null("/root/Items")
	if items == null:
		return null
	var stats = items.stats
	if stats is PlayerStats:
		return stats
	return null


func _find_player() -> Node3D:
	var players: Array = get_tree().get_nodes_in_group("player")
	for node: Node in players:
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


func _collect(player: Node3D) -> void:
	if _collected:
		return
	_collected = true

	var items: Node = get_node_or_null("/root/Items")

	match kind:
		Kind.COIN:
			if items:
				items.add_coins(coin_value)
		Kind.HEAL:
			var health := player.get_node_or_null("Health") as Health
			if health:
				health.heal(heal_amount)
		Kind.BOMB:
			if items:
				items.add_bombs(bomb_amount)
		Kind.ITEM:
			if items and item_data:
				if not items.add_item(item_data):
					# Maximale Stapelzahl erreicht — Sockel bleibt stehen.
					_collected = false
					return

	collected.emit(kind, self)
	_play_collect_feedback()


## Kurzes Aufploppen statt sofortigem Verschwinden. Ohne das fuehlt sich
## Einsammeln an, als waere das Pickup nie da gewesen.
func _play_collect_feedback() -> void:
	set_deferred("monitoring", false)
	if _prompt:
		_prompt.visible = false
	if _visual == null:
		queue_free()
		return

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_visual, "scale", Vector3.ONE * 1.6, 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual, "position:y", _visual.position.y + 0.7, 0.18)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(queue_free)
