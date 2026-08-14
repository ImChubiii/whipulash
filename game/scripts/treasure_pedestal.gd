extends Node3D
class_name TreasurePedestal

# ============================================================================
# TreasurePedestal — der Isaac-Sockel in der Mitte des Schatzraums.
# ============================================================================
# EIN Item pro Schatzraum, frei schwebend ueber einer Saeule, mit Lichtsaeule
# und Bodenring. Wer nah genug steht, sieht die Item-Karte unten links und
# kann mit [F] zugreifen.
#
# WARUM EIN EIGENES SCRIPT UND NICHT Pickup.Kind.ITEM:
# Pickup ist bewusst ein Wegwerf-Objekt: es liegt am Boden, wird magnetisch
# angezogen und verschwindet beim Beruehren. Der Schatzsockel ist das
# Gegenteil — er steht fest, saugt nichts an, muss aktiv bedient werden und
# soll den halben Raum beleuchten. Beides in eine Klasse zu quetschen haette
# in Pickup vier weitere "if kind == ITEM: anders"-Zweige bedeutet, und genau
# solche Zweige sind spaeter die Stellen, an denen ein Bugfix fuer Muenzen den
# Schatzraum kaputtmacht.
#
# BAUT SICH KOMPLETT SELBST AUF — konsequent wie pickup.gd und bomb.gd. Es
# gibt also KEINE treasure_pedestal.tscn, die man vergessen kann zu laden.
#
# ALLE MATERIALIEN WERDEN PRO INSTANZ NEU ERZEUGT (siehe _make_material).
# Wuerde hier eine geteilte Ressource liegen, faerbte der zweite Sockel einer
# Etage rueckwirkend den ersten um.

signal item_taken(item: ItemData, pedestal: TreasurePedestal)

## Wie nah der Spieler stehen muss, damit [F] greift.
@export var interact_distance: float = 3.0

## Ab dieser Entfernung wird die Item-Karte mittig auf dem Bildschirm
## eingeblendet — und beim Verlassen sofort wieder ausgeblendet.
##
## Bewusst knapp gehalten: die Karte soll aussagen "du stehst am Sockel",
## nicht "irgendwo in diesem Raum liegt ein Item". Bei einem 48 m breiten
## Schatzraum heisst das ein Radius um die Mittelplattform herum.
@export var preview_distance: float = 7.0

## Schwebe-Animation des Items ueber der Saeule.
@export var bob_height: float = 0.14
@export var bob_speed: float = 1.8
@export var spin_speed: float = 1.1

## Hoehe des schwebenden Items ueber der Saeulen-Oberkante.
@export var float_height: float = 1.15

## Hoehe der Lichtsaeule. Sie ist das, was den Raum auf Distanz lesbar macht.
@export var beam_height: float = 7.0

## Reichweite der Punktlichtquelle im Sockel.
@export var light_range: float = 9.0
@export var light_energy: float = 2.2

## Muss mit SettingsManager.DEFAULT_KEYBINDS uebereinstimmen ("interact" = F).
const INTERACT_ACTION: String = "interact"

## Gruppe, in der sich ItemDescriptionHud anmeldet.
const ITEM_HUD_GROUP: String = "item_hud"

## Gruppe, in der sich der LevelGenerator selbst eintraegt — fuer das
## map_updated-Signal, siehe _sync_minimap_visibility().
const GENERATOR_GROUP: String = "level_generator"

## Das Item, das auf diesem Sockel liegt. Wird vom TreasureManager gesetzt,
## BEVOR der Sockel in den Baum gehaengt wird.
var item_data: ItemData = null

var _taken: bool = false
var _time: float = 0.0
var _float_root: Node3D = null
var _gem: MeshInstance3D = null
var _halo: MeshInstance3D = null
var _beam: MeshInstance3D = null
var _ring: MeshInstance3D = null
var _light: OmniLight3D = null
var _name_label: Label3D = null
var _prompt_label: Label3D = null
var _preview_shown: bool = false
var _accent: Color = Color(0.95, 0.85, 0.35)

## Der Raum, in dem dieser Sockel steht. Wird beim _ready() gesetzt (der
## Sockel ist immer ein direktes Kind des Raums, siehe treasure_manager.gd).
## Bleibt null bei debug_spawn_at_player() — dort greift keine Fog-Logik.
var _room: RoomInstance = null
var _generator: Node = null


## Bequemer Konstruktor fuer den TreasureManager.
static func create(data: ItemData) -> TreasurePedestal:
	var pedestal := TreasurePedestal.new()
	pedestal.item_data = data
	pedestal.name = "TreasurePedestal_%s" % (data.id if data else "empty")
	return pedestal


func _ready() -> void:
	add_to_group("treasure_pedestals")

	if item_data != null:
		_accent = item_data.pedestal_color

	_build_column()
	_build_ring()
	_build_beam()
	_build_float_group()
	_build_light()
	_build_labels()

	# ------------------------------------------------------------------
	# Fog-of-War-Anschluss (behobener Bug: Sockel leuchtet durch die Wand
	# eines noch nicht besuchten Schatzraums auf der Karte)
	# ------------------------------------------------------------------
	# room_instance.gd blendet einen kompletten unbesuchten Raum auf der
	# 3D-Minimap aus, indem es EINMALIG alle VisualInstance3D-Kinder auf
	# einen Layer verschiebt, den die Kartenkamera nicht rendert
	# (set_minimap_revealed() -> _apply_minimap_layer()). "Einmalig" ist der
	# entscheidende Teil: ein zweiter Aufruf mit demselben Sichtbarkeits-
	# zustand ist ein bewusster No-Op (siehe die Sperre dort), damit der
	# Baum nicht bei jedem Kartenupdate neu durchlaufen wird.
	#
	# treasure_manager.gd haengt diesen Sockel aber ERST ein bis zwei
	# Physik-Frames NACH der Raumgenerierung ein (siehe dort: der Boden fuer
	# die Sockelposition muss erst kollidierbar sein). Zu diesem Zeitpunkt
	# hat der Raum sein "verstecken" laengst hinter sich — der Sockel wird
	# also NIE von _apply_minimap_layer() erfasst und bleibt fuer die
	# Kartenkamera dauerhaft auf dem normalen, sichtbaren Layer. Ergebnis:
	# eine helle, mehrere Meter hohe Lichtsaeule schwebt sichtbar in einem
	# Raum, dessen Waende und Boden korrekt ausgeblendet sind — auf der
	# Karte sieht das aus wie "man sieht durch die Wand".
	#
	# Die Lösung hier dupliziert NICHT die Versteck-Logik, sondern fragt bei
	# jeder Kartenaktualisierung (map_updated-Signal des Generators) aktiv
	# nach dem AKTUELLEN Sichtbarkeitszustand des eigenen Elternraums und
	# wendet ihn auf die eigenen Kinder an. Kein Eingriff in room_instance.gd
	# noetig.
	_room = get_parent() as RoomInstance
	_sync_minimap_visibility.call_deferred()
	_bind_generator.call_deferred()


# ============================================================================
# Aufbau
# ============================================================================
## Unshaded + Emission: PSX-Optik lebt von flachen, gesaettigten Flaechen.
## Ein Schatzsockel muss ausserdem quer durch einen dunklen Raum lesbar sein,
## ohne dass eine Lichtquelle ihn zufaellig richtig trifft.
func _make_material(color: Color, emission: float = 0.8, unshaded: bool = true) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission
	return material


## Additiv + ohne Tiefen-Test-Verlust: fuer Lichtsaeule und Halo. Cull
## deaktiviert, damit man auch von innen etwas sieht.
func _make_glow_material(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.disable_receive_shadows = true
	return material


## Die Saeule ist bewusst zweiteilig: dunkler Schaft, heller Deckstein in der
## Item-Farbe. So sieht man die Farbe des Items auch dann noch, wenn das
## schwebende Objekt gerade von einer Wand verdeckt wird.
func _build_column() -> void:
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = 0.42
	shaft_mesh.bottom_radius = 0.58
	shaft_mesh.height = 0.95
	shaft_mesh.radial_segments = 8  # bewusst grob: PSX-Look

	var shaft := MeshInstance3D.new()
	shaft.name = "Shaft"
	shaft.mesh = shaft_mesh
	# material_override statt surface_material_override — Vorrangregel.
	shaft.material_override = _make_material(Color(0.14, 0.15, 0.18), 0.0, false)
	shaft.position = Vector3(0.0, 0.475, 0.0)
	add_child(shaft)

	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.72
	base_mesh.bottom_radius = 0.82
	base_mesh.height = 0.18
	base_mesh.radial_segments = 8

	var base := MeshInstance3D.new()
	base.name = "Base"
	base.mesh = base_mesh
	base.material_override = _make_material(Color(0.10, 0.11, 0.13), 0.0, false)
	base.position = Vector3(0.0, 0.09, 0.0)
	add_child(base)

	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.52
	cap_mesh.bottom_radius = 0.46
	cap_mesh.height = 0.12
	cap_mesh.radial_segments = 8

	var cap := MeshInstance3D.new()
	cap.name = "Cap"
	cap.mesh = cap_mesh
	cap.material_override = _make_material(_accent, 0.9)
	cap.position = Vector3(0.0, 1.0, 0.0)
	add_child(cap)


## Leuchtring auf dem Boden. Markiert die Interaktions-Reichweite, ohne dass
## dafuer eine UI noetig waere.
func _build_ring() -> void:
	var torus := TorusMesh.new()
	torus.inner_radius = 1.05
	torus.outer_radius = 1.22
	torus.rings = 20
	torus.ring_segments = 5

	_ring = MeshInstance3D.new()
	_ring.name = "GroundRing"
	_ring.mesh = torus
	_ring.material_override = _make_glow_material(_accent, 0.55)
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ring.position = Vector3(0.0, 0.04, 0.0)
	add_child(_ring)


## Lichtsaeule nach oben. Der eigentliche "hier liegt was"-Wegweiser: sie ist
## auch dann sichtbar, wenn der Sockel selbst hinter einer Stufe verschwindet.
func _build_beam() -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.95
	cylinder.bottom_radius = 0.30
	cylinder.height = beam_height
	cylinder.radial_segments = 10
	cylinder.rings = 1

	_beam = MeshInstance3D.new()
	_beam.name = "LightBeam"
	_beam.mesh = cylinder
	_beam.material_override = _make_glow_material(_accent, 0.13)
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_beam.position = Vector3(0.0, 1.1 + beam_height * 0.5, 0.0)
	add_child(_beam)


## Alles Schwebende haengt an EINEM Knoten, damit Bob und Rotation nicht auf
## drei Meshes einzeln nachgezogen werden muessen.
func _build_float_group() -> void:
	_float_root = Node3D.new()
	_float_root.name = "FloatRoot"
	_float_root.position = Vector3(0.0, 1.06 + float_height, 0.0)
	add_child(_float_root)

	# --- Halo hinter dem Item ----------------------------------------
	var quad := QuadMesh.new()
	quad.size = Vector2(1.5, 1.5)

	_halo = MeshInstance3D.new()
	_halo.name = "Halo"
	_halo.mesh = quad
	var halo_material := _make_glow_material(_accent, 0.35)
	halo_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_halo.material_override = halo_material
	_halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(_halo)

	# --- Das Item selbst: facettierter Edelstein ----------------------
	# radial_segments 6 / rings 3 ergibt eine kantige Form, die zum
	# Vertex-Snapping passt. Eine glatte Kugel saehe hier wie ein Fremd-
	# koerper aus.
	var gem_mesh := SphereMesh.new()
	gem_mesh.radius = 0.30
	gem_mesh.height = 0.84
	gem_mesh.radial_segments = 6
	gem_mesh.rings = 3

	_gem = MeshInstance3D.new()
	_gem.name = "Gem"
	_gem.mesh = gem_mesh
	_gem.material_override = _make_material(_accent, 1.4)
	_gem.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(_gem)

	# Fertiges Icon-Modell schlaegt den Platzhalter, falls eines existiert.
	if item_data != null and item_data.icon != null:
		_apply_icon_billboard(item_data.icon)


## Sobald es Item-Icons gibt, wird der Edelstein zum Traeger einer Textur.
## Bis dahin passiert hier nichts — das ist kein Fehlerfall.
func _apply_icon_billboard(icon: Texture2D) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(0.85, 0.85)

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = icon
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var icon_instance := MeshInstance3D.new()
	icon_instance.name = "Icon"
	icon_instance.mesh = quad
	icon_instance.material_override = material
	icon_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(icon_instance)

	# Der Stein bleibt als farbiger Hintergrund stehen, wird aber kleiner,
	# damit das Icon lesbar bleibt.
	if _gem:
		_gem.scale = Vector3.ONE * 0.55


func _build_light() -> void:
	_light = OmniLight3D.new()
	_light.name = "ShrineLight"
	_light.light_color = _accent
	_light.light_energy = light_energy
	_light.omni_range = light_range
	# Schatten aus: eine einzelne bewegte Punktlichtquelle mit Schatten
	# kostet in einem Raum voller Wandsegmente deutlich mehr, als sie
	# optisch bringt.
	_light.shadow_enabled = false
	_light.position = Vector3(0.0, 1.6, 0.0)
	add_child(_light)


func _build_labels() -> void:
	_name_label = Label3D.new()
	_name_label.name = "NameLabel"
	_name_label.text = item_data.display_name if item_data else "???"
	_name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_name_label.no_depth_test = true
	_name_label.pixel_size = 0.0055
	_name_label.outline_size = 8
	_name_label.modulate = Color(1.0, 0.98, 0.92, 0.95)
	_name_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_name_label.position = Vector3(0.0, 2.85, 0.0)
	_name_label.visible = false
	add_child(_name_label)

	_prompt_label = Label3D.new()
	_prompt_label.name = "PromptLabel"
	_prompt_label.text = "[F] Nehmen"
	_prompt_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt_label.no_depth_test = true
	_prompt_label.pixel_size = 0.0045
	_prompt_label.outline_size = 6
	_prompt_label.modulate = _accent
	_prompt_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_prompt_label.position = Vector3(0.0, 2.5, 0.0)
	_prompt_label.visible = false
	add_child(_prompt_label)


# ============================================================================
# Laufzeit
# ============================================================================
func _physics_process(delta: float) -> void:
	_time += delta
	_animate(delta)

	if _taken:
		return

	var player: Node3D = _find_player()
	if player == null:
		return

	var distance: float = global_position.distance_to(player.global_position)
	_update_labels(distance)
	_update_preview(distance)

	if distance > interact_distance:
		return
	if not Input.is_action_just_pressed(INTERACT_ACTION):
		return
	take()


func _animate(delta: float) -> void:
	if _float_root and not _taken:
		_float_root.position.y = 1.06 + float_height + sin(_time * bob_speed) * bob_height
		_float_root.rotate_y(spin_speed * delta)

	if _ring:
		# Langsames Pulsieren: zieht den Blick, ohne zu flackern.
		var pulse: float = 0.45 + 0.25 * (sin(_time * 2.0) * 0.5 + 0.5)
		var material: StandardMaterial3D = _ring.material_override
		if material:
			material.albedo_color.a = pulse if not _taken else 0.08

	if _light and not _taken:
		_light.light_energy = light_energy * (0.85 + 0.15 * sin(_time * 3.1))


func _update_labels(distance: float) -> void:
	var near: bool = distance <= preview_distance
	if _name_label:
		_name_label.visible = near
	if _prompt_label:
		_prompt_label.visible = distance <= interact_distance


## Blendet die Item-Karte ein, sobald der Spieler in Reichweite kommt, und
## sofort wieder aus, wenn er sie verlaesst.
##
## Nur bei der FLANKE, nicht jeden Frame: ein Dauerfeuer von show_item()
## wuerde die Einblend-Animation jeden Frame neu starten, die Karte stuende
## also dauerhaft auf 97 % Groesse und zuckte.
##
## Das Ausblenden beim Weggehen ist der eigentliche Grund fuer diese
## Funktion. Vorher lief die Karte nach einem festen Timer aus — man trug
## die Beschreibung also noch durch zwei Raeume mit sich herum.
func _update_preview(distance: float) -> void:
	var near: bool = distance <= preview_distance
	if near == _preview_shown:
		return
	_preview_shown = near

	var hud: ItemDescriptionHud = _find_item_hud()
	if hud == null:
		return

	if near and item_data != null:
		# persistent = true: die Karte bleibt, solange man hier steht.
		hud.show_item(item_data, true)
	else:
		hud.hide_item()


## Das Item-HUD ist jetzt ein Node IN hud.tscn, kein Autoload-Kind mehr.
## Deshalb wird es ueber die Gruppe gesucht statt ueber einen festen Pfad —
## ein Pfad wie "/root/HudExtra/..." haette sich bei jeder Umbenennung im
## Szenenbaum stillschweigend in null verwandelt.
func _find_item_hud() -> ItemDescriptionHud:
	for node: Node in get_tree().get_nodes_in_group(ITEM_HUD_GROUP):
		if node is ItemDescriptionHud and is_instance_valid(node):
			return node as ItemDescriptionHud
	return null


func _find_player() -> Node3D:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


# ============================================================================
# Aufnehmen
# ============================================================================
## Gibt true zurueck, wenn das Item wirklich ins Inventar gewandert ist.
## Bei erreichter Stapelgrenze bleibt der Sockel bestueckt stehen — das ist
## dieselbe Regel wie in pickup.gd und verhindert, dass ein Item wortlos
## verschwindet.
func take() -> bool:
	if _taken or item_data == null:
		return false

	var items: Node = get_node_or_null("/root/Items")
	if items == null:
		return false

	# pickup_active_item() statt add_item(): sind beide Aktiv-Slots (Q/E)
	# schon belegt und item_data ist selbst aktiv, wird das bisherige
	# Q-Item verdraengt und muss zurueck auf DIESEN Sockel (Swap statt
	# nutzlos unausgeruestet im Inventar landen), siehe item_manager.gd.
	var result: Dictionary = items.pickup_active_item(item_data)
	if not bool(result.get("picked_up", false)):
		return false
	var displaced: ItemData = result.get("displaced") as ItemData

	var taken_item: ItemData = item_data
	_taken = true
	# Die Anzeige stand auf "dauerhaft" (Sockel in Reichweite). Ohne diesen
	# Wechsel bliebe die Karte fuer immer stehen, weil hide_item() erst beim
	# Verlassen der Reichweite kaeme — und Items.item_added() setzt sie
	# gleich darauf ohnehin neu, dann mit Auto-Ausblendung.
	var hud: ItemDescriptionHud = _find_item_hud()
	if hud:
		hud.hide_item()

	item_taken.emit(taken_item, self)
	_play_take_feedback(displaced)
	return true


## Der Sockel bleibt als leere Saeule stehen. Ein komplett verschwindender
## Sockel wuerde beim Zurueckkommen so aussehen, als waere der Schatzraum nie
## bestueckt gewesen.
## displaced: nur bei einem Q/E-Swap gesetzt (siehe take()) - der Sockel
## bestueckt sich nach der Wegnahme-Animation selbst neu, statt leer zu
## bleiben (siehe _finish_take()/_restock()).
func _play_take_feedback(displaced: ItemData = null) -> void:
	if _prompt_label:
		_prompt_label.visible = false
	if _name_label:
		_name_label.visible = false

	Juice.hit_stop(Juice.DURATION_LIGHT)
	Juice.shake(0.35)

	var tween := create_tween()
	tween.set_parallel(true)

	if _float_root:
		tween.tween_property(_float_root, "position:y", _float_root.position.y + 1.4, 0.45) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_float_root, "scale", Vector3.ONE * 0.01, 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	if _beam and _beam.material_override is StandardMaterial3D:
		tween.tween_property(_beam.material_override, "albedo_color:a", 0.0, 0.5)

	if _light:
		tween.tween_property(_light, "light_energy", 0.25, 0.5)

	tween.chain().tween_callback(_finish_take.bind(displaced))


func _finish_take(displaced: ItemData = null) -> void:
	if _float_root and is_instance_valid(_float_root):
		_float_root.queue_free()
		_float_root = null
	if _beam and is_instance_valid(_beam):
		_beam.queue_free()
		_beam = null

	if displaced != null:
		_restock(displaced)


## Verdraengtes Q-Item (siehe ItemManager.pickup_active_item() - beide
## Aktiv-Slots waren voll) landet wieder auf DIESEM Sockel statt spurlos zu
## verschwinden ("Swap"). Baut Lichtsaeule + schwebendes Item neu auf, exakt
## wie beim ersten _ready() - _float_root/_beam wurden gerade erst in
## _finish_take() freigegeben, es gibt also keine Namenskollision.
func _restock(new_item: ItemData) -> void:
	item_data = new_item
	_accent = new_item.pedestal_color
	_taken = false

	var cap: MeshInstance3D = get_node_or_null("Cap")
	if cap:
		cap.material_override = _make_material(_accent, 0.9)

	_build_beam()
	_build_float_group()

	if _light:
		_light.light_color = _accent
	if _ring and _ring.material_override is StandardMaterial3D:
		var ring_mat: StandardMaterial3D = _ring.material_override as StandardMaterial3D
		ring_mat.albedo_color = Color(_accent.r, _accent.g, _accent.b, ring_mat.albedo_color.a)
	if _name_label:
		_name_label.text = new_item.display_name

	_preview_shown = false


func is_taken() -> bool:
	return _taken


# ============================================================================
# Fog-of-War-Anschluss
# ============================================================================
func _bind_generator() -> void:
	if _room == null:
		# debug_spawn_at_player() haengt den Sockel direkt in current_scene,
		# nicht in einen Raum — dort gibt es keine Fog-of-War-Zustaende, mit
		# denen synchronisiert werden muesste.
		return

	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)


func _on_map_updated() -> void:
	_sync_minimap_visibility()


## Spiegelt den AKTUELLEN Sichtbarkeitszustand des Elternraums auf die
## eigenen Kinder — Meshes UND Licht. Wird beim Bauen einmal aufgerufen und
## danach bei jedem map_updated erneut (Raum wird betreten -> aufgedeckt).
func _sync_minimap_visibility() -> void:
	if _room == null or not is_instance_valid(_room):
		return

	# _minimap_revealed ist ein gewoehnliches Skript-Feld (kein echtes
	# "private" in GDScript) und traegt IMMER einen gueltigen Wert, auch
	# ohne LevelGenerator (Default true) — Testszenen ohne Fog bleiben damit
	# unangetastet sichtbar.
	var revealed: bool = true
	if "_minimap_revealed" in _room:
		revealed = bool(_room.get("_minimap_revealed"))

	_apply_own_minimap_layer(self, revealed)

	# Fuer Lichter reicht das Verschieben auf einen unsichtbaren Layer NICHT:
	# layers steuert bei Light3D nur, was der Editor-Gizmo tut, nicht ob das
	# Licht real weiterstrahlt. .visible = false schaltet das Licht dagegen
	# vollstaendig ab — sonst wuerde eine unsichtbar gewordene Lichtquelle
	# trotzdem noch Flaechen in einem eigentlich verdeckten Raum aufhellen.
	if _light:
		_light.visible = revealed


## Rekursiv wie room_instance.gd::_apply_minimap_layer(), aber nur auf den
## eigenen Unterbaum angewendet. RoomInstance.MINIMAP_HIDDEN_LAYER ist die
## SELBE Konstante, die die Kartenkamera aus ihrer cull_mask streicht — auf
## einen eigenen, zweiten Layer-Wert zu bestehen waere eine zweite Quelle
## der Wahrheit, die irgendwann auseinanderlaufen kann.
func _apply_own_minimap_layer(node: Node, revealed: bool) -> void:
	for child: Node in node.get_children():
		if child is VisualInstance3D:
			var visual: VisualInstance3D = child as VisualInstance3D
			if not visual.has_meta("minimap_base_layers"):
				visual.set_meta("minimap_base_layers", visual.layers)
			if revealed:
				visual.layers = int(visual.get_meta("minimap_base_layers"))
			else:
				visual.layers = 1 << (RoomInstance.MINIMAP_HIDDEN_LAYER - 1)
		_apply_own_minimap_layer(child, revealed)
