# res://scripts/status_effects/status_effect_base.gd
extends RefCounted
class_name StatusEffectBase

# ============================================================================
# StatusEffectBase — gemeinsame Hilfsfunktionen aller Status-Effekte.
# ============================================================================
# WARUM ES DIESE DATEI GIBT (obwohl sie nicht im Design-Dokument steht):
# Jeder der sieben Effekte braucht exakt dieselben vier Schritte:
#   1. Ziel auf Gueltigkeit pruefen
#   2. StatusEffectManager des Ziels holen
#   3. Effekt eintragen
#   4. VFX ausloesen
# Ohne diese Basis stuende dieser Block siebenmal wortgleich im Projekt —
# und die achte Kopie waere dann die, die beim naechsten Umbau vergessen wird.
#
# Die Effekt-Dateien selbst enthalten NUR noch ihre eigenen Zahlen und ihre
# eigene VFX-Entscheidung. Genau dort wird balanciert.

const ENEMY_GROUP: String = "enemies"

# --- VFX-Szenen -------------------------------------------------------------
# preload: fehlt eine Szene, faellt das beim Projektstart auf und nicht erst,
# wenn zufaellig der passende Effekt ausgeloest wird.
const VFX_HIT_SPARK: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")
const VFX_DUST_RING: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const VFX_SPARK_YELLOW: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const VFX_FLASH_WHITE: PackedScene = preload("res://scenes/vfx/flash_white.tscn")
const VFX_HOLOGRAM_BLUE: PackedScene = preload("res://scenes/vfx/hologram_blue.tscn")
const VFX_BLEED: PackedScene = preload("res://scenes/vfx/bleed_vfx.tscn")
const VFX_CORROSION: PackedScene = preload("res://scenes/vfx/corrosion_vfx.tscn")
const VFX_OIL_BUBBLES: PackedScene = preload("res://scenes/vfx/oil_bubbles.tscn")


## Holt den StatusEffectManager eines Ziels.
##
## WICHTIG: enemy_ai.gd und player_base.gd legen ihren Manager erst in
## _ready() an. Ein Effekt, der im selben Frame wie der Spawn auftrifft,
## bekommt hier also null zurueck — das ist KEIN Fehlerfall, sondern wird in
## apply_raw() sauber abgefangen.
static func manager_of(target: Node) -> StatusEffectManager:
	if target == null or not is_instance_valid(target):
		return null
	var direct: Variant = target.get("status_effects")
	if direct is StatusEffectManager:
		return direct as StatusEffectManager
	return target.get_node_or_null("StatusEffectManager") as StatusEffectManager


## Der eigentliche Eintrag in den Manager. Alle Effekt-Dateien laufen hier
## zusammen.
##
## Rueckgabe: true, wenn der Effekt wirklich angekommen ist. Die Items werten
## das aus, um ihre eigenen VFX nur dann zu zeigen, wenn auch etwas passiert
## ist — ein Funkenregen ohne Wirkung ist schlimmer als gar keiner.
static func apply_raw(
		target: Node,
		id: String,
		duration: float,
		magnitude: float = 1.0,
		source: Node = null,
		tick_interval: float = 0.0
) -> bool:
	if duration <= 0.0:
		return false
	if target == null or not is_instance_valid(target):
		return false

	# Bevorzugt die oeffentliche Methode des Ziels: enemy_ai.gd macht dort
	# noch eigene Dinge (Telegraph abbrechen, Animation umschalten), die beim
	# direkten Manager-Zugriff wegfielen.
	if target.has_method("apply_status_effect"):
		target.call("apply_status_effect", id, duration, magnitude, source, tick_interval)
		return true

	var manager: StatusEffectManager = manager_of(target)
	if manager == null:
		return false
	manager.apply_effect(id, duration, magnitude, source, tick_interval)
	return true


static func is_active(target: Node, id: String) -> bool:
	var manager: StatusEffectManager = manager_of(target)
	return manager != null and manager.has_effect(id)


static func remaining(target: Node, id: String) -> float:
	var manager: StatusEffectManager = manager_of(target)
	if manager == null:
		return 0.0
	return manager.get_effect_remaining(id)


static func magnitude_of(target: Node, id: String) -> float:
	var manager: StatusEffectManager = manager_of(target)
	if manager == null:
		return 0.0
	return manager.get_effect_magnitude(id)


static func remove(target: Node, id: String) -> void:
	var manager: StatusEffectManager = manager_of(target)
	if manager != null:
		manager.remove_effect(id)


## Spawnt einen One-Shot-Effekt ueber das VFX-Autoload.
##
## Engine.is_editor_hint(): Autoloads existieren im Editor-Modus nicht. Ohne
## diese Pruefung wirft jede @tool-Vorschau einen Nullzugriff.
static func spawn_vfx(scene: PackedScene, world_pos: Vector3, direction: Vector3 = Vector3.ZERO) -> void:
	if scene == null or Engine.is_editor_hint():
		return
	VFX.spawn(scene, world_pos, direction)


## Position knapp ueber dem Boden des Ziels — Standardpunkt fuer Fuss-Effekte
## (DUST_RING, Saeure-Pfuetzen).
static func foot_position(target: Node) -> Vector3:
	var node := target as Node3D
	if node == null or not is_instance_valid(node):
		return Vector3.ZERO
	return node.global_position + Vector3(0.0, 0.1, 0.0)


## Position auf Brust-/Kopfhoehe — fuer Treffer-Funken und Icons.
static func chest_position(target: Node, height: float = 1.2) -> Vector3:
	var node := target as Node3D
	if node == null or not is_instance_valid(node):
		return Vector3.ZERO
	return node.global_position + Vector3(0.0, height, 0.0)


## Health-Komponente eines beliebigen Ziels.
static func health_of(target: Node) -> Health:
	if target == null or not is_instance_valid(target):
		return null
	return target.find_child("Health", true, false) as Health


static func is_alive(target: Node) -> bool:
	var health: Health = health_of(target)
	return health != null and health.is_alive()
