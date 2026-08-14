

@tool
extends Node3D
class_name LavaHazard

## Saure Limonade als Umgebungs-Hazard.
##
## ZWEI MODI (das war der Grund, warum die Lava in den generierten Raeumen
## keinen Schaden gemacht hat):
##
##  POOL    - klassische Grube: der Boden ist unter der Lache ausgespart,
##            man faellt rein, treibt auf (Auftrieb) und nimmt Schaden.
##            So ist es in level_01 gebaut.
##  SURFACE - flache Pfuetze, die AUF einem durchgehenden Boden liegt.
##            Man kann nicht einsinken (da ist Kollision drunter), also
##            zaehlt hier bereits das Durchwaten als "drin": Schaden +
##            Verlangsamung, aber kein Auftrieb.
##            Genau dieser Fall liegt in room_combat_02/04/05/06 vor.
##
## BUGFIXES gegenueber der alten Version:
##  1. CapsuleShape3D.height enthaelt in Godot 4 die Halbkugel-Kappen
##     BEREITS. Die alte Rechnung (radius + height*0.5) hat den Fusspunkt
##     um genau radius zu tief angesetzt.
##  2. BoxShape3D und StandardMaterial3D sind SubResources der
##     lemonade.tscn und werden damit von ALLEN Instanzen geteilt. Jede
##     Instanz hat der vorherigen die Groesse/Farbe ueberschrieben. Beide
##     werden jetzt pro Instanz dupliziert.
##  3. Zusaetzlicher Sicherheits-Rescan ueber get_overlapping_bodies():
##     falls ein body_entered-Signal verschluckt wird (passiert beim
##     Spawn/Instanziieren im selben Frame), findet der Poll den Body
##     trotzdem.
##  4. NEU - "Lava macht zu spaet Schaden, wenn man reinspringt":
##     Der Eintrittsschaden hing frueher AUSSCHLIESSLICH an _register(),
##     also am Betreten des Trigger-VOLUMENS. Beim Sprung von oben feuert
##     body_entered aber, waehrend die Fuesse noch UEBER der Oberflaeche
##     sind -> starts_submerged = false, kein Schaden. Der Uebergang
##     "jetzt wirklich drin" ein paar Frames spaeter hat dann nur die
##     Optik gestartet und den Tick-Timer bei 0 losrechnen lassen: der
##     erste Treffer kam erst nach vollen tick_interval Sekunden.
##     Der Eintrittsschaden haengt jetzt am UEBERGANG, nicht am Volumen.
##  5. NEU - Gameplay laeuft in _physics_process(): die Fusspunkte werden
##     im Physik-Schritt aktualisiert. Ein Check in _process() arbeitet je
##     nach Framerate mit veralteten Positionen.
##  6. NEU - predict_falling_entry: bei hoher Fallgeschwindigkeit wird der
##     Fusspunkt des naechsten Physik-Schritts vorausberechnet, damit ein
##     schneller Sprung nicht ueber eine duenne Lache "hinwegspringt".
##
## ############################################################################
##  7. "DIE LAVA FAENGT ZU SPAET MIT DEM SCHADEN AN" - ROOT CAUSE
## ############################################################################
##     Die Ursache lag NICHT in diesem Script, sondern in scenes/lemonade.tscn.
##     Die Szene ueberschreibt die Exports und setzte dort
##
##         damage_on_entry = false
##         tick_interval   = 1.0
##
##     Der unter Punkt 4 beschriebene Eintrittsschaden war damit
##     abgeschaltet: der erste Treffer kam erst nach einer VOLLEN Sekunde
##     in der Lache. Wer durchgelaufen ist, hat oft gar keinen Schaden
##     genommen - was von aussen aussieht, als wuerde der Hazard "zu spaet"
##     oder gar nicht reagieren.
##
##     Das ist die typische Falle bei @export-Werten: der Wert im Script
##     ist nur der Default fuer NEUE Instanzen. Eine .tscn, die ihn
##     ueberschreibt, gewinnt immer - und der Script-Default steht daneben
##     und sieht richtig aus.
##
##     Zwei Aenderungen:
##       a) Die Szene setzt damage_on_entry = true und tick_interval = 0.5.
##       b) NEU hier: first_tick_interval. Der ZWEITE Treffer kommt jetzt
##          schneller als alle folgenden. Ohne das war die Abfolge
##          "Schaden - lange Pause - Schaden", und die lange Pause direkt
##          nach dem Eintauchen liest sich fuer den Spieler wieder wie
##          "reagiert zu spaet".

enum HazardMode { POOL, SURFACE }

# --- Groesse & Optik ---
@export var size: Vector3 = Vector3(4.0, 1.0, 4.0):
	set(value):
		size = value
		_apply_size()

@export var lava_color: Color = Color(0.667, 0.843, 0.216):
	set(value):
		lava_color = value
		_apply_color()

@export var glow_energy: float = 2.5:
	set(value):
		glow_energy = value
		_apply_color()

@export_range(0.0, 1.0) var alpha: float = 0.85:
	set(value):
		alpha = value
		_apply_color()

@export var pulse_enabled: bool = true
@export var pulse_speed: float = 2.0
@export_range(0.0, 1.0) var pulse_amount: float = 0.4

# --- Gameplay ---
## POOL fuer echte Gruben (Boden ausgespart), SURFACE fuer flache
## Pfuetzen auf durchgehendem Boden.
@export var hazard_mode: HazardMode = HazardMode.SURFACE

@export var damage_per_tick: float = 15.0
@export var tick_interval: float = 0.5

## Abstand vom Eintrittsschaden zum ZWEITEN Treffer. Kuerzer als
## tick_interval - Begruendung unter Punkt 7 im Kopfkommentar.
@export var first_tick_interval: float = 0.3

@export var damage_on_entry: bool = true

## Nur im POOL-Modus relevant.
@export var buoyancy_rise_speed: float = 2.5
@export_range(0.0, 1.0) var entry_dampening: float = 0.15

## Nur im SURFACE-Modus: Anteil der Verlangsamung beim Durchwaten
## (0.45 = 45% langsamer). Wird als Status-Effekt "slow" gesetzt und
## jeden Frame aufgefrischt, damit er beim Verlassen sofort ausleuft.
@export_range(0.0, 0.9) var surface_slow_amount: float = 0.45

## Ab welchem Hazard-Multiplikator die Verlangsamung ganz entfaellt.
## Die Saeurefesten Stiefel setzen den Multiplikator auf 0.25 — der
## Standardwert liegt bewusst knapp darueber.
@export_range(0.0, 1.0) var wade_slow_immunity_threshold: float = 0.3

## Wie weit ueber der berechneten Oberflaeche noch als "drin" zaehlt.
## Im SURFACE-Modus bewusst grosszuegiger, weil die Fuesse dort auf dem
## Boden UNTER der Lache stehen und nie richtig eintauchen koennen.
@export var submersion_tolerance: float = 0.3
@export var surface_wade_tolerance: float = 0.9

## Rechnet die im naechsten Physik-Schritt zurueckgelegte Fallstrecke mit
## ein. Ohne das kann ein schneller Sprung von oben ueber eine duenne Lache
## hinwegspringen: bei gravity = 40 liegen zwischen zwei Frames schnell mehr
## Meter als die Toleranz breit ist.
@export var predict_falling_entry: bool = true

# --- VFX ---
## Zischen/Rauch, das bei JEDEM Schadens-Tick am getroffenen Koerper
## aufblitzt ("aetzend"). One-Shot-Szene, Root = GPUParticles3D.
@export var corrosion_vfx: PackedScene
## Hoehe ueber der Limonaden-Oberflaeche, auf der der Effekt erscheint.
@export var corrosion_vfx_height: float = 0.4

## Bodies in dieser Gruppe werden komplett ignoriert - kein Schaden, keine
## Verlangsamung, kein Auftrieb, kein Overlay.
##
## GEBRAUCHT FUER: Items, die selbst Saeure-Pfuetzen legen ("Mamas
## Stoeckelschuhe"). Ohne das wuerde der Spieler in seine eigene Spur laufen
## und sich selbst zerlegen. Leer lassen = Standardverhalten (trifft jeden).
@export var ignore_group: String = ""

@export var display_name: String = "Lemonade"
@export var debug_logging: bool = false

## Sicherheits-Poll gegen verschluckte body_entered-Signale (Sekunden).
## Von 0.2 auf 0.1 halbiert: der Poll ist das Sicherheitsnetz fuer
## verschluckte body_entered-Signale. Bei 0.2 s konnte genau dieser Fall
## bis zu einer Fuenftelsekunde Schadensverzoegerung erzeugen.
@export var rescan_interval: float = 0.1

@onready var visual: CSGBox3D = $LemonadeVisual
@onready var trigger: Area3D = $LemonadeTrigger
@onready var collision_shape: CollisionShape3D = $LemonadeTrigger/CollisionShape3D

var _occupants: Dictionary = {}
var _pulse_time: float = 0.0
var _rescan_timer: float = 0.0
var _material: StandardMaterial3D


func get_display_name() -> String:
	return display_name


func _debug(msg: String) -> void:
	if debug_logging:
		print("Lemonade DEBUG [%s]: %s" % [name, msg])


func _ready() -> void:
	_make_resources_unique()
	_apply_size()
	_apply_color()

	if Engine.is_editor_hint():
		return

	add_to_group("lava_hazards")

	if trigger:
		trigger.body_entered.connect(_on_body_entered)
		trigger.body_exited.connect(_on_body_exited)


## Ohne das teilen sich ALLE Lemonade-Instanzen dieselbe BoxShape3D und
## dasselbe StandardMaterial3D aus der lemonade.tscn - die zuletzt
## instanziierte Lache diktiert dann Groesse und Farbe aller anderen.
##
## HINWEIS fuer den Dauer-Emitter (Blasen an der Oberflaeche): sobald du
## dessen ParticleProcessMaterial pro Instanz an 'size' anpasst, gilt
## exakt dasselbe Problem — dann hier ebenfalls duplizieren.
func _make_resources_unique() -> void:
	if collision_shape and collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
	if visual and visual.material:
		visual.material = visual.material.duplicate()


func _apply_size() -> void:
	if visual:
		visual.size = size
	if collision_shape and collision_shape.shape is BoxShape3D:
		# Trigger im SURFACE-Modus etwas hoeher machen als die sichtbare
		# Lache: der Spieler steht ja OBEN DRAUF, seine Kapsel muss die
		# Zone trotzdem sicher schneiden.
		var trigger_size: Vector3 = size
		if hazard_mode == HazardMode.SURFACE:
			trigger_size.y = maxf(size.y, 2.0)
		(collision_shape.shape as BoxShape3D).size = trigger_size


func _apply_color() -> void:
	if not visual:
		return
	if _material == null or _material != visual.material:
		_material = visual.material as StandardMaterial3D
		if _material == null:
			_material = StandardMaterial3D.new()
			visual.material = _material

	_material.albedo_color = Color(lava_color.r, lava_color.g, lava_color.b, alpha)
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	_material.emission_enabled = true
	_material.emission = lava_color
	_material.emission_energy_multiplier = glow_energy


func _get_surface_top_world_y() -> float:
	var y_scale: float = global_transform.basis.y.length()
	return global_position.y + (size.y * 0.5 * y_scale)


func _effective_tolerance() -> float:
	if hazard_mode == HazardMode.SURFACE:
		return surface_wade_tolerance
	return submersion_tolerance


## delta > 0: der Fusspunkt wird um die im naechsten Physik-Schritt
## zurueckgelegte Fallstrecke vorausberechnet - siehe predict_falling_entry.
func _is_body_submerged(body: Node3D, delta: float = 0.0) -> bool:
	var feet_y: float = _get_body_feet_y(body)

	if predict_falling_entry and delta > 0.0 and body is CharacterBody3D:
		var vertical: float = (body as CharacterBody3D).velocity.y
		if vertical < 0.0:
			feet_y += vertical * delta

	return feet_y <= _get_surface_top_world_y() + _effective_tolerance()


## FIX: CapsuleShape3D.height ist in Godot 4 die GESAMThoehe inklusive der
## beiden Halbkugel-Kappen. Die alte Formel (radius + height*0.5) hat den
## Fusspunkt um radius zu tief angesetzt.
func _get_body_feet_y(body: Node3D) -> float:
	var shape_node: CollisionShape3D = body.get_node_or_null("CollisionShape3D")
	if shape_node == null or shape_node.shape == null:
		return body.global_position.y

	var shape: Shape3D = shape_node.shape
	var y_scale: float = shape_node.global_transform.basis.y.length()
	var half_height: float = 0.0

	if shape is CapsuleShape3D:
		half_height = (shape as CapsuleShape3D).height * 0.5 * y_scale
	elif shape is CylinderShape3D:
		half_height = (shape as CylinderShape3D).height * 0.5 * y_scale
	elif shape is BoxShape3D:
		half_height = (shape as BoxShape3D).size.y * 0.5 * y_scale
	elif shape is SphereShape3D:
		half_height = (shape as SphereShape3D).radius * y_scale

	return shape_node.global_position.y - half_height


## Nur noch Optik. Das komplette Gameplay haengt in _physics_process() -
## siehe Bugfix 5 im Kopfkommentar.
func _process(delta: float) -> void:
	if pulse_enabled and _material:
		_pulse_time += delta * pulse_speed
		var pulse: float = 1.0 + sin(_pulse_time) * pulse_amount
		_material.emission_energy_multiplier = glow_energy * pulse


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	_rescan_timer -= delta
	if _rescan_timer <= 0.0:
		_rescan_timer = maxf(rescan_interval, 0.05)
		_rescan_overlaps()

	if _occupants.is_empty():
		return

	for body in _occupants.keys():
		if not is_instance_valid(body):
			_occupants.erase(body)
			continue

		var entry: Dictionary = _occupants[body]
		var now_submerged: bool = _is_body_submerged(body, delta)
		var was_submerged: bool = entry["submerged"]

		if now_submerged and not was_submerged:
			_start_submersion_effects(body)
			# DER eigentliche Fix gegen "Schaden kommt zu spaet": der
			# Eintrittsschaden haengt am UEBERGANG, nicht am Betreten des
			# Trigger-Volumens. Wer von oben reinspringt, nimmt jetzt in
			# genau dem Physik-Schritt Schaden, in dem die Fuesse die
			# Oberflaeche durchstossen - vorher vergingen erst volle
			# tick_interval Sekunden.
			if damage_on_entry:
				_damage_body(body)
			# Auch OHNE Eintrittsschaden wird der Timer hier neu gesetzt:
			# der Uebergang ist der ehrliche Startpunkt der Zaehlung.
			entry["tick_timer"] = 0.0
			entry["first_tick_done"] = false
		elif was_submerged and not now_submerged:
			_stop_submersion_effects(body)

		entry["submerged"] = now_submerged

		if now_submerged:
			_apply_wade_slow(body)
			entry["tick_timer"] += delta

			# Der erste Treffer nach dem Eintauchen kommt frueher als die
			# folgenden - siehe Punkt 7 im Kopfkommentar.
			var wait: float = tick_interval
			if not entry.get("first_tick_done", true):
				wait = minf(first_tick_interval, tick_interval)

			if entry["tick_timer"] >= wait:
				entry["tick_timer"] = 0.0
				entry["first_tick_done"] = true
				_damage_body(body)

		_occupants[body] = entry

## Sicherheitsnetz: body_entered kann verloren gehen, wenn Raum und
## Spieler im selben Frame instanziiert/verschoben werden.
func _rescan_overlaps() -> void:
	if trigger == null or not trigger.monitoring:
		return
	for body in trigger.get_overlapping_bodies():
		if not _occupants.has(body):
			_register(body)


func _register(body: Node3D) -> void:
	# ZUERST die Ausnahme pruefen, VOR dem Health-Check: sonst landet der
	# Spieler trotzdem in _occupants und bekommt ueber _update_occupants()
	# Auftrieb und Submersion-Overlay ab.
	if ignore_group != "" and body.is_in_group(ignore_group):
		return

	var health: Node = body.find_child("Health", true, false)
	if health == null or not (health is Health):
		return

	var starts_submerged: bool = _is_body_submerged(body)
	_occupants[body] = {
		"tick_timer": 0.0,
		"submerged": starts_submerged,
		"first_tick_done": false,
	}
	_debug("registriert '%s' | Fuesse=%.2f | Oberflaeche=%.2f | drin=%s" % [
		body.name, _get_body_feet_y(body), _get_surface_top_world_y(), starts_submerged
	])

	if starts_submerged:
		if damage_on_entry:
			_damage_body(body)
		_start_submersion_effects(body)


func _damage_body(body: Node3D) -> void:
	var health: Node = body.find_child("Health", true, false)
	if health and health is Health:
		# HAZARD_RESIST wird hier eingerechnet — vorher gar nicht.
		#
		# Das war der Grund, warum die "Saeurefesten Stiefel" wirkungslos
		# waren: das Item traegt korrekt einen Multiplikator von 0.25 in
		# PlayerStats ein, aber niemand hat ihn je gelesen. Der Stat war
		# definiert, angezeigt und komplett folgenlos — ein Fehler, der sich
		# nur dadurch bemerkbar macht, dass ein Item "nichts tut".
		var amount: float = damage_per_tick * _get_hazard_multiplier(body)
		health.take_damage(amount, self)
		_debug("Tick-Schaden %.1f an '%s'" % [amount, body.name])

	# --- VFX ---
	# Engine.is_editor_hint() ist Pflicht: dieses Script ist @tool, das
	# VFX-Autoload existiert im Editor aber nicht (Autoloads werden dort
	# nur instanziiert, wenn sie selbst @tool sind).
	if corrosion_vfx and not Engine.is_editor_hint():
		# An der Oberflaeche statt am Koerper-Pivot: im POOL-Modus steckt
		# der Pivot unter der Fluessigkeit, der Effekt waere unsichtbar.
		var spawn_pos: Vector3 = body.global_position
		spawn_pos.y = _get_surface_top_world_y() + corrosion_vfx_height
		VFX.spawn(corrosion_vfx, spawn_pos, Vector3.UP)


## Im SURFACE-Modus haelt sich der Slow nur solange, wie man drin steht:
## kurze Dauer, jeden Frame aufgefrischt.
## Schadensmultiplikator aus PlayerStats.STAT_HAZARD_RESIST. Gegner haben
## keine PlayerStats-Komponente und bekommen deshalb immer 1.0 — das ist
## Absicht, sonst wuerden die Stiefel auch die Gegner in der Limonade
## schuetzen.
func _get_hazard_multiplier(body: Node3D) -> float:
	if Engine.is_editor_hint():
		return 1.0
	var stats := body.get_node_or_null("PlayerStats")
	if stats == null or not (stats is PlayerStats):
		return 1.0
	return maxf((stats as PlayerStats).get_hazard_resist(), 0.0)


func _apply_wade_slow(body: Node3D) -> void:
	if hazard_mode != HazardMode.SURFACE:
		return
	# Dieselbe Resistenz entscheidet auch ueber die Verlangsamung: bei einem
	# Multiplikator unter dieser Schwelle watet man ohne Tempoverlust durch.
	# Die Design-Vorgabe zu den Stiefeln nennt beides in einem Satz
	# ("75 % weniger Schaden UND keine Verlangsamung") — es waere kaum
	# nachvollziehbar, wenn nur die eine Haelfte griffe.
	if _get_hazard_multiplier(body) <= wade_slow_immunity_threshold:
		return
	if surface_slow_amount <= 0.0:
		return
	if body.has_method("apply_status_effect"):
		body.apply_status_effect("slow", 0.25, surface_slow_amount, self, 0.0)


func _is_player(body: Node3D) -> bool:
	return body.has_method("set_target")


func _start_submersion_effects(body: Node3D) -> void:
	if hazard_mode == HazardMode.POOL:
		if body is CharacterBody3D and body.velocity.y < 0.0:
			body.velocity.y *= entry_dampening
		if body.has_method("set_buoyancy"):
			body.set_buoyancy(true, buoyancy_rise_speed, _get_surface_top_world_y())

	if _is_player(body):
		var overlay: Node = get_tree().get_root().find_child("SubmersionOverlay", true, false)
		if overlay and overlay.has_method("show_submersion"):
			overlay.show_submersion(lava_color)


func _stop_submersion_effects(body: Node3D) -> void:
	if body.has_method("set_buoyancy"):
		body.set_buoyancy(false)

	if _is_player(body):
		if not _player_still_in_any_other_lemonade(body):
			var overlay: Node = get_tree().get_root().find_child("SubmersionOverlay", true, false)
			if overlay and overlay.has_method("hide_submersion"):
				overlay.hide_submersion()


func _on_body_entered(body: Node3D) -> void:
	_debug("body_entered: '%s'" % body.name)
	if _occupants.has(body):
		return
	_register(body)


func _on_body_exited(body: Node3D) -> void:
	if _occupants.has(body):
		var was_submerged: bool = _occupants[body]["submerged"]
		_occupants.erase(body)
		if was_submerged:
			_stop_submersion_effects(body)


func _player_still_in_any_other_lemonade(player_body: Node3D) -> bool:
	for hazard in get_tree().get_nodes_in_group("lava_hazards"):
		if hazard == self:
			continue
		if hazard is LavaHazard and hazard._occupants.has(player_body):
			if hazard._occupants[player_body]["submerged"]:
				return true
	return false
