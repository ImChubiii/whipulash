extends Node
class_name DungeonAtmosphere

## Duesterer Dungeon-Look: alles, was weiter weg ist, saeuft in schwarzem
## Nebel ab (Minecraft-"Blindness"-Prinzip, nur deutlich milder - Waende
## und Ecken werden dunkler, statt die Sicht auf 2 Meter zu kappen).
##
## Als Kind-Node neben die WorldEnvironment haengen (z.B. unter
## LevelGenerationTest). Findet die WorldEnvironment automatisch und
## schreibt Fog + Ambient direkt in deren Environment-Resource.
##
## Umgesetzt wird das ueber den DEPTH-Fog (Distanz-Nebel), nicht ueber
## Volumetric Fog: Depth-Fog kostet praktisch nichts und passt besser zum
## PSX-Look, weil er wie eine harte Sichtweiten-Kappung wirkt.

## Wenn leer, wird die erste WorldEnvironment im Baum benutzt.
@export var world_environment: WorldEnvironment

@export var enabled: bool = true

## Farbe des Nebels. Sehr dunkel, leicht gruenstichig passend zur Limonade.
@export var fog_color: Color = Color(0.02, 0.03, 0.02)
## Ab hier beginnt das Abdunkeln (Meter vor der Kamera).
##
## BUGFIX "Character wirkt schwarz/im Schatten, obwohl der Raum hell ist":
## bei 20 griff der Nebel schon recht nah an der Kamera - kombiniert mit dem
## niedrigen ambient_energy weiter unten sackte alles ausserhalb der
## unmittelbaren Naehe sichtbar ab. Weiter nach hinten geschoben, damit mehr
## vom Raum in der eigentlichen Beleuchtung bleibt.
@export var fog_begin: float = 30.0
## Ab hier ist praktisch alles schwarz.
@export var fog_end: float = 85.0
## Wie schnell der Nebel zwischen begin und end zumacht (>1 = spaeter,
## dafuer haerter; das fuehlt sich weniger nach Milchglas an).
@export var fog_curve: float = 2.2
## Maximale Nebeldichte. 1.0 = Ziel komplett schwarz.
@export_range(0.0, 1.0) var fog_density: float = 0.95

## Ambient-Licht runterziehen - ohne das leuchten die Waende trotz Nebel.
## BUGFIX "Character wirkt schwarz": 0.35 war zu knapp, um Charaktermodelle
## (echtes Shading, nicht die eher flachen Wand/Boden-Flaechen) lesbar zu
## halten, solange keine Fackel (torch.gd) direkt danebensteht - siehe auch
## fog_begin oben.
##
## Rueckmeldung "Raum mehr belichten": ambient_light_color wird von
## stage_manager.gd::_apply_environment() NICHT ueberschrieben (nur die
## Energy, siehe StageTheme.ambient_energy dort) - bleibt also ueber die
## ganze Laufzeit/alle Etagen hinweg wirksam. War (0.105, 0.12, 0.105)/0.55.
@export var override_ambient: bool = true
@export var ambient_color: Color = Color(0.16, 0.18, 0.16, 1.0)
@export var ambient_energy: float = 0.80

## Himmel/Hintergrund ebenfalls auf Nebelfarbe ziehen, damit ueber der
## Nebelgrenze keine helle Kante steht.
@export var match_background: bool = true

var _env: Environment = null


func _ready() -> void:
	_resolve_environment()
	if _env == null:
		push_warning("DungeonAtmosphere: Keine WorldEnvironment mit Environment-Resource gefunden.")
		return
	apply()


func _resolve_environment() -> void:
	var we: WorldEnvironment = world_environment
	if we == null:
		we = _find_world_environment(get_tree().current_scene)
	if we == null:
		return
	if we.environment == null:
		return
	# Duplizieren: die Environment-Resource haengt sonst evtl. an mehreren
	# Szenen gleichzeitig und wuerde global veraendert.
	we.environment = we.environment.duplicate()
	_env = we.environment


func _find_world_environment(node: Node) -> WorldEnvironment:
	if node == null:
		return null
	if node is WorldEnvironment:
		return node
	for child in node.get_children():
		var found: WorldEnvironment = _find_world_environment(child)
		if found:
			return found
	return null


func apply() -> void:
	if _env == null:
		return

	_env.fog_enabled = enabled
	if not enabled:
		return

	_env.fog_mode = Environment.FOG_MODE_DEPTH
	_env.fog_light_color = fog_color
	_env.fog_light_energy = 0.0
	_env.fog_density = fog_density
	_env.fog_depth_begin = fog_begin
	_env.fog_depth_end = fog_end
	_env.fog_depth_curve = fog_curve
	# Sky-Affect auf 0: sonst wird der Nebel von einem hellen Himmel
	# aufgehellt und man sieht wieder zu weit.
	_env.fog_sky_affect = 0.0
	_env.fog_aerial_perspective = 0.0

	if override_ambient:
		_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		_env.ambient_light_color = ambient_color
		_env.ambient_light_energy = ambient_energy

	if match_background:
		_env.background_mode = Environment.BG_COLOR
		_env.background_color = fog_color


## Laufzeit-Umschaltung, z.B. fuer helle Bossraeume oder einen spaeteren
## echten "Blindness"-Debuff.
func set_visibility_range(begin: float, end: float) -> void:
	fog_begin = begin
	fog_end = end
	apply()
