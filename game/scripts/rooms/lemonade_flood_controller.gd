extends Node3D
class_name LemonadeFloodController

# ============================================================================
# LemonadeFloodController — Blueprint Nr. 3 "The Lemonade Flood" (Boss-
# kampf-Mechanik). Hebt langsam die Y-Position einer vorhandenen LavaHazard-
# Instanz (SURFACE-Modus, siehe scripts/hazards/lemonade.gd) an, waehrend
# der Bosskampf laeuft - der Spieler muss auf erhoehte Plattformen
# ausweichen, um trocken zu bleiben.
# ============================================================================
# KEINE eigene Schadens-/Verlangsamungslogik: die kommt komplett von der
# bestehenden LavaHazard-Komponente (_get_surface_top_world_y() liest einfach
# die aktuelle Y-Position + halbe Groesse). Dieses Skript aendert nur diese
# eine Position ueber die Zeit - denselben Mechanismus nutzt auch der Editor-
# Setter von LavaHazard.size, nur eben fuer position statt size.

@export var hazard_path: NodePath
@export var rise_duration: float = 90.0
@export var start_y: float = -1.0
@export var end_y: float = 2.0
@export var auto_start: bool = true

var _hazard: Node3D
var _tween: Tween


func _ready() -> void:
	_hazard = get_node_or_null(hazard_path)
	if _hazard == null:
		push_warning("LemonadeFloodController: hazard_path zeigt auf keinen Node.")
		return

	_hazard.position.y = start_y
	if auto_start:
		start_flood()


func start_flood() -> void:
	if _hazard == null or (_tween != null and _tween.is_valid()):
		return
	_tween = create_tween()
	_tween.tween_property(_hazard, "position:y", end_y, rise_duration) \
		.set_trans(Tween.TRANS_LINEAR)


func stop_flood() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
