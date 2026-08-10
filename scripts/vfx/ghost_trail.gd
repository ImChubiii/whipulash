extends Node
class_name GhostTrail

# ============================================================================
# GhostTrail — "Fake" Per-Object Motion Blur ueber ausblendende Mesh-Kopien.
# ============================================================================
# WARUM NICHT ECHTER SCREEN-SPACE MOTION BLUR:
# Forward Mobile hat keinen Velocity-Buffer und damit keinen performanten
# Screen-Space-Motion-Blur-Pfad. Ein Per-Object-"Ghost Trail" (mehrere
# durchsichtige Nachbilder des Meshes, die sich ausblenden) verkauft dieselbe
# "das bewegt sich verdammt schnell"-Lesbarkeit rein per Geometrie/Material -
# funktioniert auf Mobile/Compatibility genauso wie auf Forward+.
#
# VERWENDUNG:
# Als Kind-Node an den Charakter-Root haengen (Sibling von CharacterModel,
# gleiches Prinzip wie "DashTrail" in combat_base.gd) ODER zur Laufzeit per
# set_mesh() an ein bereits aufgeloestes Modell binden (siehe enemy_ai.gd,
# das GhostTrail-Nodes prozedural erzeugt statt sie in jede einzelne
# Gegner-.tscn einzubauen).
#
# ZWEI UNABHAENGIGE MODI:
#   * start_trail(duration)  - BURST, fuer einmalige schnelle Bewegungen
#     (Dash, Gegner-Ansturm). Krasser (weiter sichtbare, langsamer
#     ausblendende Nachbilder), laeuft genau "duration" Sekunden und stoppt
#     dann von selbst.
#   * set_running(active)    - DAUERSCHALTER, fuer normale Fortbewegung
#     (siehe player_base.gd/enemy_ai.gd _physics_process, JEDEN Frame anhand
#     der aktuellen Geschwindigkeit gesetzt). Enger getaktet UND kuerzer
#     sichtbar als der Burst - soll wie ein knappes Nachziehen wirken, nicht
#     wie klassisches Kamera-Motion-Blur mit langem Schweif. Eigene,
#     dezentere Farb-/Energie-Werte, damit ein Dauereinsatz waehrend des
#     gesamten normalen Laufens nicht erschlaegt.
#
# Ist BEIDES gleichzeitig aktiv (ein Dash schiebt z.B. auch die
# Lauf-Geschwindigkeit ueber die Schwelle des Aufrufers), gewinnt IMMER der
# Burst - siehe _process(). Der Dash soll sich weiterhin absetzen, nicht mit
# dem subtileren Dauer-Trail verschmelzen.

## Pfad zum Mesh-Root, relativ zu DIESEM Node. Default passt zum ueblichen
## Aufbau "CharacterBody3D { CharacterModel, Combat, Health, GhostTrail, ... }".
## Wird ignoriert, sobald set_mesh() von aussen aufgerufen wurde.
@export var mesh_node_path: NodePath = NodePath("../CharacterModel")

@export_group("Farben (siehe set_colors())")
## Zwei Trail-Farben, GEWICHTET auf aufeinanderfolgende Nachbilder verteilt
## (siehe _spawn_ghost() / color_a_weight) - ergibt ein sichtbar ZWEIFARBIGES
## Muster statt einer gemittelten Mischfarbe. Default ist neutral Grau fuer
## Gegner ohne eigene Zuordnung; combat_base.gd ueberschreibt sie beim
## Charakter-Setup mit CharacterData.attack_color/attack_color_secondary.
@export var color_a: Color = Color(0.62, 0.64, 0.68)
@export var color_b: Color = Color(0.78, 0.80, 0.84)
## Anteil der Nachbilder, die color_a statt color_b bekommen. Hoeher als 0.5,
## weil color_b bei mehreren Charakteren Weiss ist (siehe character_data.gd
## attack_color_secondary) - ein reiner 50/50-Wechsel liess den Trail dadurch
## zu hell/weiss wirken. 0.7 haelt die charaktereigene Farbe dominant und
## laesst Weiss nur als seltenen Akzent aufblitzen.
@export_range(0.0, 1.0) var color_a_weight: float = 0.7

@export_group("Dash-Burst (start_trail)")
## Wie oft waehrend eines laufenden Burst-Trails ein neues Nachbild entsteht.
@export var spawn_interval: float = 0.05
## Wie lange EIN Burst-Nachbild braucht, um komplett zu verschwinden.
@export_range(0.1, 1.0) var fade_duration: float = 0.25
## Alpha am Start des Ausblendens - bewusst NIEDRIG ("wenig Deckkraft"),
## sonst liest sich der Trail wie klassisches Kamera-Motion-Blur statt wie
## ein dezentes Nachbild.
@export_range(0.0, 1.0) var burst_alpha: float = 0.20
## Zusaetzliches Selbstleuchten, damit die Nachbilder auch vor dunklem
## Dungeon-Hintergrund gut lesbar bleiben statt nur wie ein Schatten zu wirken.
@export var emission_energy: float = 0.6

@export_group("Lauf-Trail (set_running)")
## Deutlich enger getaktet als der Burst - mehr, aber jeweils kuerzer
## sichtbare Nachbilder, damit es beim normalen Laufen nicht wie ein langer
## Kamera-Motion-Blur-Schweif wirkt, sondern wie ein knappes Nachziehen.
@export var running_spawn_interval: float = 0.025
## Deutlich kuerzer als fade_duration - ein Lauf-Nachbild ist schon fast weg,
## bevor das naechste entsteht.
@export_range(0.05, 0.5) var running_fade_duration: float = 0.10
## Noch dezenter als burst_alpha - laeuft potenziell dauerhaft waehrend des
## gesamten Sprintens, darf also nicht so kraeftig wirken wie der seltene
## Dash-Burst. Bewusst SEHR niedrig - beim normalen Laufen soll es nur ein
## kaum wahrnehmbarer Hauch sein, nicht ablenken.
@export_range(0.0, 1.0) var running_alpha: float = 0.015
@export var running_emission_energy: float = 0.12

var _mesh: Node3D = null
var _spawn_timer: float = 0.0

var _burst_remaining: float = 0.0
var _running: bool = false


func _ready() -> void:
	if _mesh == null:
		_mesh = get_node_or_null(mesh_node_path)
	if _mesh == null:
		push_warning("GhostTrail (%s): Mesh-Node '%s' nicht gefunden - Trail bleibt wirkungslos." % [get_path(), mesh_node_path])
	set_process(false)


## Bindet den Trail zur Laufzeit an ein bereits aufgeloestes Mesh - fuer
## Faelle, in denen der Aufrufer den Modell-Node selbst schon kennt (siehe
## enemy_ai.gd: dort steht der tatsaechliche Modell-Root erst nach
## _setup_visuals() fest, ein statischer mesh_node_path waere dort fragil).
## Ueberschreibt mesh_node_path fuer den Rest der Lebenszeit dieses Nodes.
func set_mesh(node: Node3D) -> void:
	_mesh = node


## Setzt die beiden Trail-Farben - von combat_base.gd beim Charakter-Setup
## mit CharacterData.attack_color/attack_color_secondary aufgerufen (siehe
## dort). Wirkt auf BEIDE Modi (Burst und Lauf-Trail), da beide denselben
## Node/Zustand teilen.
func set_colors(a: Color, b: Color) -> void:
	color_a = a
	color_b = b


## Startet den Burst-Trail fuer "duration" Sekunden. Ein Aufruf WAEHREND ein
## Burst schon laeuft VERLAENGERT ihn nur, statt ihn neu zu starten (max
## statt addiert) - gleiches Muster wie Health.set_invulnerable() im
## Projekt, damit sich zwei kurz aufeinanderfolgende Trigger nicht
## gegenseitig verkuerzen.
func start_trail(duration: float) -> void:
	if _mesh == null or duration <= 0.0:
		return

	_burst_remaining = maxf(_burst_remaining, duration)
	_ensure_processing()


## Dauerschalter fuer den Lauf-Trail - vom Aufrufer JEDEN Frame passend zur
## aktuellen Bewegung gesetzt (siehe player_base.gd/enemy_ai.gd
## _physics_process), NICHT zeitbasiert wie start_trail(). Solange ein
## Burst laeuft, bleibt diese Einstellung wirkungslos (siehe Kopfkommentar).
func set_running(active: bool) -> void:
	if _mesh == null or _running == active:
		return
	_running = active
	if active:
		_ensure_processing()


func _ensure_processing() -> void:
	if is_processing():
		return
	_spawn_timer = 0.0
	set_process(true)
	# Sofort ein erstes Nachbild, nicht erst nach dem ersten Intervall.
	_spawn_ghost(_burst_remaining > 0.0)


func _process(delta: float) -> void:
	if _mesh == null or not is_instance_valid(_mesh):
		_burst_remaining = 0.0
		_running = false
		set_process(false)
		return

	if _burst_remaining > 0.0:
		_burst_remaining -= delta

	if _burst_remaining <= 0.0 and not _running:
		set_process(false)
		return

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		var use_burst: bool = _burst_remaining > 0.0
		_spawn_timer = spawn_interval if use_burst else running_spawn_interval
		_spawn_ghost(use_burst)


## Dupliziert das aktuelle Mesh an Ort und Stelle (Position/Rotation/Skalierung
## UND - bei geskinnten Modellen - der aktuellen Skeleton3D-Pose, da
## Bone-Transforms als Node-Zustand mitkopiert werden), faerbt die Kopie
## transparent ein und laesst sie ausblenden.
##
## use_burst entscheidet, welcher der beiden Parameter-Saetze (siehe
## Kopfkommentar) fuer DIESES eine Nachbild gilt. Bewusst PFLICHT-Argument
## statt Default-Wert: ein Default haette hier auf _burst_remaining zugreifen
## muessen, und GDScript laesst Default-Werte nur als konstante Ausdruecke
## zu, keine Instanz-Zugriffe.
func _spawn_ghost(use_burst: bool) -> void:
	if _mesh == null or not is_instance_valid(_mesh):
		return

	# DUPLICATE_USE_INSTANTIATION: bei einem Mesh, das selbst aus einer
	# importierten Szene (.glb) instanziert wurde, werden dessen innere
	# Instanzen dabei korrekt erneut instanziert statt flachgeklopft -
	# wichtig fuer Skeleton3D/Sub-Szenen im Charaktermodell.
	var ghost: Node3D = _mesh.duplicate(DUPLICATE_USE_INSTANTIATION) as Node3D
	if ghost == null:
		return

	# In die aktuelle Szene haengen, NICHT unter den Charakter selbst - der
	# bewegt sich ja weiter, das Nachbild soll an dieser Stelle stehenbleiben.
	get_tree().current_scene.add_child(ghost)
	ghost.global_transform = _mesh.global_transform

	_sanitize_ghost(ghost)

	# GEWICHTET statt strikt abwechselnd - siehe color_a_weight-Kommentar
	# oben: verhindert, dass ein reiner 50/50-Wechsel den (oft weissen)
	# color_b genauso oft zeigt wie die eigentliche Charakterfarbe.
	var base_color: Color = color_a if randf() < color_a_weight else color_b

	var alpha: float = burst_alpha if use_burst else running_alpha
	var energy: float = emission_energy if use_burst else running_emission_energy
	var fade: float = fade_duration if use_burst else running_fade_duration
	var color: Color = Color(base_color.r, base_color.g, base_color.b, alpha)

	var material: StandardMaterial3D = _apply_ghost_material(ghost, color, energy)
	_fade_and_free(ghost, material, fade)


## Entfernt alles an der Kopie, das unerwuenschte Nebenwirkungen haette:
## Audio (doppelte Schritt-/Trefferklaenge), aktive Skripte (die sonst z.B.
## eine IK- oder Footstep-Logik eigenstaendig weiterlaufen liessen) und
## Kollision (das Nachbild ist reine Optik, kein zweiter Koerper).
func _sanitize_ghost(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer3D or node is AudioStreamPlayer2D:
		node.queue_free()
		return
	if node is CollisionObject3D or node is CollisionShape3D or node is CollisionShape2D:
		node.queue_free()
		return

	if node.get_script() != null and not (node is MeshInstance3D or node is Skeleton3D or node is BoneAttachment3D):
		node.set_script(null)
	node.set_process(false)
	node.set_physics_process(false)

	for child: Node in node.get_children():
		_sanitize_ghost(child)


## Setzt EIN gemeinsames, transparentes Unlit-Material auf alle Mesh-
## Oberflaechen der Kopie (unabhaengig vom PSX-Original-Shader/-Textur - die
## waeren als Nachbild unlesbar/zu dominant) und gibt es zurueck, damit
## _fade_and_free() nur DIESES eine Material (statt jeder einzelnen Surface)
## ausblenden muss.
func _apply_ghost_material(ghost: Node3D, color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b)
	material.emission_energy_multiplier = energy
	material.cull_mode = BaseMaterial3D.CULL_DISABLED

	var meshes: Array[MeshInstance3D] = []
	_collect_mesh_instances(ghost, meshes)
	for mesh_instance: MeshInstance3D in meshes:
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var surface_count: int = mesh_instance.mesh.get_surface_count() if mesh_instance.mesh else 0
		if surface_count == 0:
			mesh_instance.material_override = material
			continue
		for i in range(surface_count):
			mesh_instance.set_surface_override_material(i, material)

	return material


func _collect_mesh_instances(node: Node, out: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		out.append(node as MeshInstance3D)
	for child: Node in node.get_children():
		_collect_mesh_instances(child, out)


## Blendet die Kopie per Tween aus (Alpha auf 0 ueber "fade") und entfernt
## sie danach.
func _fade_and_free(ghost: Node3D, material: StandardMaterial3D, fade: float) -> void:
	var tween: Tween = ghost.create_tween()
	tween.tween_property(material, "albedo_color:a", 0.0, fade) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(ghost.queue_free)
