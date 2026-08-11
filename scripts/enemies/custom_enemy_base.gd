extends CharacterBody3D
class_name CustomEnemyBase

# ============================================================================
# CustomEnemyBase — gemeinsamer Unterbau fuer die neuen, rein
# code-gebauten Gegnertypen (Moerser-Bot, Saeure-Sprinkler, Magnet-Kern,
# Divebomber, Schild-Drohne, Plasmastrahl-Bot).
# ============================================================================
# Bewusst NICHT von EnemyAI geerbt: EnemyAI ist fest auf ein
# Chase-Attack-State-Machine-Muster mit importiertem Roboter-Mesh
# zugeschnitten (siehe dessen Kopfkommentare). Die neuen Gegner brauchen
# davon nichts - sie stehen fest (Turret-Typen) oder fliegen eigene
# Flugmuster (Divebomber/Drohnen), haben keine Laufanimation und bauen sich
# wie die Hazards (cannon.gd/turret.gd) komplett aus Primitiv-Meshes auf.
#
# Was trotzdem geteilt werden MUSS, damit diese Gegner mit dem Rest des
# Spiels kompatibel sind:
#   - Gruppe "enemies": Items (_enemies_near), Bomben-Explosionen und
#     Homing-Bolts finden ihre Ziele ausschliesslich darueber.
#   - collision_layer = 4: exakt die Ebene, die PrimaryHitbox.collision_mask
#     (siehe char_*.tscn) abhorcht - ohne sie liefe der Spieler-Nahkampf
#     durch diese Gegner hindurch.
#   - Ein Kind-Node NAMENS "Health" vom Typ Health: primary_hitbox.gd und
#     TurretProjectile suchen ausschliesslich per find_child("Health", ...).
#
# Alle sechs Typen sind sowohl ueber die LevelGenerator-Threat-Budget-
# Tabellen (siehe resources/enemies/es_*.tres) als auch einzeln ueber
# EnemySandboxRoom (scripts/enemy_sandbox_room.gd) spawnbar.

const HIT_SPARK_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

## Einheitliches Rot fuer alle Boden-Telegraphen ("hier schlaegt gleich etwas
## ein") ueber alle sechs Typen hinweg - Rueckmeldung: die einzelnen Typen
## tippten vorher leicht unterschiedliche Rottoene von Hand ein (z.B.
## Moerser-Bot 1.0/0.1/0.1 vs. Divebomber 1.0/0.15/0.1), was auf den ersten
## Blick nach zwei verschiedenen Signalfarben aussehen konnte. Wert
## identisch zum bereits etablierten Rot der ORIGINALEN drei Threat-Budget-
## Gegner (Fighter/Stinger/Colossus, siehe deren TelegraphInner/OuterRing in
## scenes/{enemies/dummy,scout_dummy,tank_dummy}.tscn) - EIN Rot fuers ganze
## Spiel statt eines pro Gegnertyp neu erfundenen.
const DANGER_TELEGRAPH_COLOR: Color = Color(1.0, 0.15686275, 0.1254902)

## Kopie von StatusEffectManager.DOT_IDS/enemy_ai.DOT_EFFECT_IDS - const
## Ausdruecke duerfen in GDScript nicht auf andere Klassen zugreifen, siehe
## Kommentar dort. Wer eine Liste aendert, aendert alle drei mit.
const DOT_EFFECT_IDS: PackedStringArray = ["poison", "bleed", "burn", "acid"]

var health: Health = null
var visual_root: Node3D = null
var status_effects: StatusEffectManager = null
var _dead: bool = false

## Von RoomInstance._spawn_one() gesetzt (bleibt null bei Sandbox-Spawns).
## BUGFIX "Schild-Drohne/Plasmastrahl-Bot sterben nie, Raum bleibt
## gesperrt": _despawn_if_room_clear() (siehe shield_drone.gd/
## plasma_beam_bot.gd) hat vorher die GLOBALE Gruppe "enemies" durchsucht -
## damit hat ein ueberlebender Gegner IRGENDWO SONST auf der Etage (z.B. ein
## Verfolger aus einem vorherigen, nicht ganz leergeraeumten Raum) die
## Drohne fuer immer am Despawnen gehindert, auch wenn IHR EIGENER Raum
## laengst leer war. spawn_room erlaubt den beiden Klassen, nur noch
## Gegner AUS DEMSELBEN RAUM zu zaehlen.
var spawn_room: Node = null


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1

	visual_root = Node3D.new()
	visual_root.name = "Visual"
	add_child(visual_root)

	_configure()
	_build_health()
	_build_status_effects()
	_build()


## Subclasses setzen hier ihre Werte (display_name, max_health, ...), BEVOR
## Health gebaut wird.
func _configure() -> void:
	pass


## Subclasses bauen hier ihre Meshes/Collision/Timer/Attack-Logik auf.
func _build() -> void:
	pass


func _build_health() -> void:
	health = Health.new()
	health.name = "Health"
	health.max_health = max_health
	health.regen_enabled = false
	add_child(health)
	health.died.connect(_on_died)


## Ohne diesen Manager liefe JEDER Status-Effekt (Saeure, Brand, Betaeubung,
## der neue "shield"-Buff) lautlos ins Leere - StatusEffectBase.apply_raw()
## faellt ohne "apply_status_effect"-Methode UND ohne StatusEffectManager-
## Kind komplett tot durch (siehe deren Kopfkommentar). Vorher hatte KEINER
## der sechs neuen Gegnertypen ueberhaupt einen Manager.
func _build_status_effects() -> void:
	status_effects = StatusEffectManager.get_or_create(self)
	status_effects.effect_ticked.connect(_on_status_effect_ticked)
	status_effects.effect_applied.connect(_on_status_effect_applied)
	status_effects.effect_expired.connect(_on_status_effect_expired)


func apply_status_effect(id: String, duration: float, magnitude: float = 1.0, source: Node = null, tick_interval: float = 0.0) -> void:
	status_effects.apply_effect(id, duration, magnitude, source, tick_interval)


func has_status_effect(id: String) -> bool:
	return status_effects.has_effect(id)


func _on_status_effect_ticked(id: String, magnitude: float, source: Node) -> void:
	if health != null and id in DOT_EFFECT_IDS:
		health.take_damage(magnitude, source)


func _on_status_effect_applied(id: String, _duration: float, _magnitude: float, _source: Node) -> void:
	if id == "shield":
		_apply_shield_visual()


func _on_status_effect_expired(id: String) -> void:
	if id == "shield":
		_remove_shield_visual()


# ============================================================================
# Schild-Buff (Schild-Drohne) — +25 % Maximal-HP, der Gegner selbst leuchtet.
# ============================================================================
# GEAENDERT (Rueckmeldung: "shield sollte die Gegner nur zum Leuchten
# bringen"): vorher eine zusaetzliche, halbtransparente Kugel-Aura UM den
# Gegner herum PLUS ein 25% groesseres Modell - je nach Gegner-Silhouette
# sah die ueberlappende Kugel seltsam aus und die Groessenaenderung war ein
# zweiter, unabhaengiger visueller Hinweis, den niemand gefordert hat. Jetzt
# pulsiert stattdessen die Emission der EIGENEN Meshes des Gegners direkt -
# der Gegner leuchtet, statt in einer fremden Kugel zu stecken. Gleiche
# Werte/Regeln wie enemy_ai.gd (dort weiterhin die alte Aura, siehe
# Kopfkommentar dort), siehe scripts/status_effects/shield.gd fuer die
# ausfuehrliche Begruendung des HP-Bonus.
var _shield_active: bool = false
var _shield_pre_max_health: float = 0.0
## Array[Dictionary{mesh: MeshInstance3D, original: Material, glow: Material}]
var _shield_glow_entries: Array = []
var _shield_glow_tween: Tween = null


func _apply_shield_visual() -> void:
	if _shield_active or _dead:
		return
	_shield_active = true

	if health != null:
		_shield_pre_max_health = health.max_health
		health.set_max_health(_shield_pre_max_health * (1.0 + StatusShield.MAX_HEALTH_BONUS_FACTOR), true)

	_shield_glow_entries.clear()
	if visual_root != null and is_instance_valid(visual_root):
		for mesh: MeshInstance3D in _collect_mesh_instances(visual_root):
			var original: Material = mesh.material_override
			if original == null:
				continue
			var glow_mat: Material = original.duplicate()
			mesh.material_override = glow_mat
			_shield_glow_entries.append({"mesh": mesh, "original": original, "glow": glow_mat})

	_shield_glow_tween = create_tween()
	_shield_glow_tween.set_loops()
	_shield_glow_tween.tween_method(_set_shield_glow_strength, 0.35, 1.0, 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_shield_glow_tween.tween_method(_set_shield_glow_strength, 1.0, 0.35, 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Alle sechs Sandbox-Typen bauen ihre Meshes ausschliesslich ueber
## _make_unshaded_material() (immer StandardMaterial3D) - kein Fall hier
## nutzt die geteilte psx-ShaderMaterial, deshalb genuegt dieser eine Zweig.
func _set_shield_glow_strength(strength: float) -> void:
	for entry: Dictionary in _shield_glow_entries:
		var mat: Material = entry["glow"]
		if mat is StandardMaterial3D:
			var sm := mat as StandardMaterial3D
			sm.emission_enabled = true
			sm.emission = StatusShield.TINT_COLOR
			sm.emission_energy_multiplier = lerpf(0.6, 3.2, strength)


## Rekursiv, damit auch verschachtelte Meshes (z.B. Divebomber: Fluegel als
## Kind von _visual_body) mitleuchten.
func _collect_mesh_instances(node: Node) -> Array:
	var found: Array = []
	if node is MeshInstance3D:
		found.append(node)
	for child: Node in node.get_children():
		found.append_array(_collect_mesh_instances(child))
	return found


func _remove_shield_visual() -> void:
	if not _shield_active:
		return
	_shield_active = false

	if health != null and _shield_pre_max_health > 0.0:
		health.set_max_health(_shield_pre_max_health, false)

	if _shield_glow_tween != null and _shield_glow_tween.is_valid():
		_shield_glow_tween.kill()
	_shield_glow_tween = null

	for entry: Dictionary in _shield_glow_entries:
		var mesh: MeshInstance3D = entry["mesh"]
		if is_instance_valid(mesh):
			mesh.material_override = entry["original"]
	_shield_glow_entries.clear()


@export var display_name: String = "Gegner"
@export var max_health: float = 60.0


func get_display_name() -> String:
	return display_name


func _find_player() -> CharacterBody3D:
	return get_tree().get_first_node_in_group(PartyManager.PLAYER_GROUP) as CharacterBody3D


## Subclasses, die eigene Effekt-Nodes AUSSERHALB ihrer selbst anlegen (z.B.
## ShieldDrone/PlasmaBeamBot: Beam-Meshes haengen unter current_scene, nicht
## unter dem Gegner selbst, weil sie Start- UND Endpunkt unabhaengig von der
## eigenen Transform brauchen) raeumen die hier auf. WICHTIG: wird nicht nur
## von _on_died() aufgerufen, sondern auch von aussen ueber
## enemy_sandbox_room.gd::_clear_enemies() - dort wird der Gegner per
## queue_free() zwangsentfernt (Health.died feuert dabei NICHT), sonst
## blieben Beams/Telegraphs bis zu ihrem eigenen Timeout einsam in der Luft
## haengen, obwohl der Gegner, der sie erzeugt hat, laengst weg ist.
func _cleanup_effects() -> void:
	pass


func _on_died() -> void:
	await _teardown(true)


## Fuer "kein Pflicht-Kill"-Typen (Schild-Drohne/Plasmastrahl-Bot):
## Gegner-Liste, auf die sich ihr eigener _despawn_if_room_clear() beim
## Pruefen beschraenkt. Mit spawn_room gesetzt (Normalfall: ueber
## RoomInstance gespawnt) NUR die eigenen Raum-Kameraden - ohne spawn_room
## (Sandbox-Spawn) faellt es auf die globale Gruppe "enemies" zurueck, weil
## dort kein Raum-Konzept existiert.
func _room_scoped_enemies() -> Array:
	if spawn_room != null and is_instance_valid(spawn_room) and spawn_room.has_method("get_spawned_enemies"):
		return spawn_room.get_spawned_enemies()
	return get_tree().get_nodes_in_group("enemies")


## Fuer Gegner, die NICHT im Kampf getoetet werden muessen, um zu
## verschwinden - aktuell Schild-Drohne/Plasmastrahl-Bot, siehe deren
## _despawn_if_room_clear(). Gleicher Ablauf wie _on_died() (Kollision aus,
## Effekte aufraeumen, wegschrumpfen), NUR ohne den Treffer-Funken - es war
## kein Treffer, der sie entfernt hat.
func despawn() -> void:
	await _teardown(false)


func _teardown(with_hit_vfx: bool) -> void:
	if _dead:
		return
	_dead = true

	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	remove_from_group("enemies")
	_cleanup_effects()

	if with_hit_vfx:
		VFX.spawn(HIT_SPARK_SCENE, global_position + Vector3.UP, Vector3.ZERO)

	if visual_root != null and is_instance_valid(visual_root):
		var tween: Tween = create_tween()
		tween.tween_property(visual_root, "scale", Vector3.ZERO, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await tween.finished

	queue_free()


## Kleine Bau-Helfer, identisch zum Stil in cannon.gd/turret.gd - vermeidet,
## dass jeder Subtyp dieselben acht Zeilen fuer Mesh+Material neu schreibt.
func _make_unshaded_material(color: Color, emission_mul: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	if emission_mul > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission_mul
	return mat


func _add_box_collision(size: Vector3, offset: Vector3 = Vector3.ZERO) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = offset
	add_child(shape)


## Positioniert/skaliert/dreht einen duennen Cylinder-Mesh so, dass er als
## Verbindungsbeam zwischen zwei Punkten erscheint (Y-Achse = Laenge).
##
## NICHT einfach node.look_at(to, Vector3.UP): das wirft eine
## Godot-Warnung und liefert eine undefinierte Basis, sobald die
## Blickrichtung fast exakt parallel zum Up-Vektor liegt - z.B. bei einem
## fast senkrechten Strahl (Plasmastrahl-Bot -> Bodenpunkt direkt darunter).
## Weicht in dem Fall auf FORWARD als Referenzachse aus.
func _orient_beam_segment(node: Node3D, from: Vector3, to: Vector3) -> void:
	var dist: float = from.distance_to(to)
	node.global_position = from.lerp(to, 0.5)

	# BUGFIX "Strahl sieht wie ein hochkantes Rechteck aus": Godots
	# look_at() liest die aktuelle node.scale VOR der Rotation aus und legt
	# sie danach unveraendert auf die (noch lokale, nicht neu ausgerichtete)
	# Achsen um - stand die Laengen-Skalierung schon VOR look_at() auf der
	# Y-Achse, landet sie dadurch auf der FALSCHEN Achse (der "Hoch"-Achse
	# des Strahls statt seiner Laengsachse) und der duenne Zylinder wird
	# quer zur Blickrichtung zu einer Ellipse/einem Rechteck aufgeblaeht,
	# statt sich zwischen from/to zu strecken. Deshalb: Skalierung erst
	# NACHDEM look_at() + die 90-Grad-Korrektur die endgueltige
	# Ausrichtung stehen haben, direkt auf die dann korrekte Laengsachse
	# (lokal Y) anwenden.
	node.scale = Vector3.ONE
	if dist <= 0.01:
		node.scale = Vector3(1.0, 0.01, 1.0)
		return
	var dir: Vector3 = (to - from) / dist
	var up_hint: Vector3 = Vector3.FORWARD if absf(dir.dot(Vector3.UP)) > 0.95 else Vector3.UP
	node.look_at(to, up_hint)
	node.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))
	node.scale = Vector3(1.0, dist, 1.0)


## Baut einen deutlich lesbaren Energiestrahl: duenner heller Kern + breiterer
## weicher Glow-Mantel + eine Puls-Kugel, die den Strahl entlanglaeuft.
##
## ERSETZT den fruehereren einzelnen duennen Zylinder (0.06-0.08 Radius) aus
## Schild-Drohne/Plasmastrahl-Bot - auf dem Bildschirm kaum von der Umgebung
## zu unterscheiden. Kern+Glow+Puls zusammen lesen sich auch aus der
## Kampfkamera-Distanz eindeutig als "das ist ein aktiver Strahl".
##
## Rueckgabe: Dictionary{root, core, glow, pulse, t} - "root" haengt unter
## current_scene (Start-/Endpunkt sind unabhaengig von dieser Instanz-
## Transform), muss also explizit ueber _free_beam_visual() aufgeraeumt
## werden, NICHT automatisch beim Tod dieser Instanz.
## radius_scale weitet Kern/Glow/Puls proportional auf (Default 1.0 = alte
## Groesse, unveraendert fuer Schild-Drohnen-Verbindungsstrahl) - gebraucht
## vom Plasmastrahl-Bot, dessen Bodenstrahl deutlich breiter ist als der
## duenne Verbindungsstrahl (siehe dortiger Aufrufer).
func _create_beam_visual(color: Color, radius_scale: float = 1.0) -> Dictionary:
	var root := Node3D.new()
	get_tree().current_scene.add_child(root)

	var glow := MeshInstance3D.new()
	var glow_cyl := CylinderMesh.new()
	glow_cyl.top_radius = 0.3 * radius_scale
	glow_cyl.bottom_radius = 0.3 * radius_scale
	glow_cyl.height = 1.0
	glow.mesh = glow_cyl
	var glow_mat := _make_unshaded_material(color, 0.8)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color.a = 0.3
	glow.material_override = glow_mat
	root.add_child(glow)

	var core := MeshInstance3D.new()
	var core_cyl := CylinderMesh.new()
	core_cyl.top_radius = 0.09 * radius_scale
	core_cyl.bottom_radius = 0.09 * radius_scale
	core_cyl.height = 1.0
	core.mesh = core_cyl
	core.material_override = _make_unshaded_material(color, 2.8)
	root.add_child(core)

	var pulse := MeshInstance3D.new()
	var pulse_mesh := SphereMesh.new()
	pulse_mesh.radius = 0.24 * radius_scale
	pulse_mesh.height = 0.48 * radius_scale
	pulse.mesh = pulse_mesh
	pulse.material_override = _make_unshaded_material(color, 3.2)
	root.add_child(pulse)

	return {"root": root, "core": core, "glow": glow, "pulse": pulse, "t": 0.0}


## Aktualisiert Position/Ausrichtung/Puls eines mit _create_beam_visual()
## erzeugten Strahls. delta wird nur fuer die Pulsgeschwindigkeit gebraucht.
func _update_beam_visual(beam: Dictionary, from: Vector3, to: Vector3, delta: float) -> void:
	if beam.is_empty() or not is_instance_valid(beam["root"]):
		return
	_orient_beam_segment(beam["core"], from, to)
	_orient_beam_segment(beam["glow"], from, to)

	beam["t"] = fmod(float(beam["t"]) + delta * 1.6, 1.0)
	var pulse: MeshInstance3D = beam["pulse"]
	if is_instance_valid(pulse):
		pulse.global_position = from.lerp(to, float(beam["t"]))


func _free_beam_visual(beam: Dictionary) -> void:
	if not beam.is_empty() and is_instance_valid(beam["root"]):
		(beam["root"] as Node3D).queue_free()


const _GROUND_RAYCAST_MASK: int = 1

## Projiziert eine Position senkrecht auf den Boden darunter. Gebraucht von
## Moerser-Bot/Saeure-Sprinkler (Einschlag/Pfuetze sollen auf dem Boden
## liegen, nicht auf Spieler-Kopfhoehe, falls der gerade springt o.ae.) und
## Plasmastrahl-Bot (Laser-Fussabdruck).
func _project_to_ground(pos: Vector3) -> Vector3:
	var world: World3D = get_world_3d()
	if world == null:
		return pos
	var query := PhysicsRayQueryParameters3D.create(
		pos + Vector3.UP * 2.0, pos - Vector3.UP * 20.0
	)
	query.collision_mask = _GROUND_RAYCAST_MASK
	query.exclude = [get_rid()]
	var result := world.direct_space_state.intersect_ray(query)
	if result.is_empty():
		return pos
	return result.position
