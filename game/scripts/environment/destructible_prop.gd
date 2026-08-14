extends StaticBody3D
class_name DestructibleProp

# ============================================================================
# DestructibleProp — Requisiten, die ein ramm-attackierender schwerer Gegner
# (Colossus) beim Durchbrechen zerlegt (Blueprint "Zerstoerbare Umgebungen").
# ============================================================================
# StaticBody3D statt RigidBody3D: der NavMesh-Baker geometry_parsed_geometry_
# type = STATIC_COLLIDERS sieht nur StaticBody3D/CollisionShape3D-Paare (siehe
# pit_floor.gd fuer dieselbe Begruendung) - eine RigidBody3D-Saeule wuerde
# beim Baken als Loch im Navmesh fehlen, bis sie zerstoert wird.
#
# ERKENNUNG "Ramm-Treffer": is_heavy + eine Mindestgeschwindigkeit, damit ein
# langsam vorbeischlurfender Colossus die Saeule nicht einfach im Vorbeigehen
# zerstoert - nur ein echter Dash/Sprint-Aufprall zaehlt.

## Schaden, den die Requisite aushaelt, falls sie stattdessen ueber
## take_damage() (Hitbox-Treffer, Item-Explosionen) zerstoert werden soll.
@export var health: float = 40.0

## Ab dieser Geschwindigkeit gilt ein Koerperkontakt als Ramm-Treffer eines
## schweren Gegners, nicht als normales Vorbeischieben.
@export var heavy_impact_speed_threshold: float = 6.0

## Wie lange der ramm-attackierende Gegner nach dem Durchbruch gestunnt ist.
@export var stagger_stun_duration: float = 2.0

## Optionaler Partikeleffekt (Low-Poly-Truemmer). Bleibt leer funktionsfaehig -
## das Projekt hat noch keine fertige Debris-VFX-Szene, siehe Blueprint-
## Umsetzungsnotiz.
@export var debris_vfx: PackedScene

var _current_health: float
var _destroyed: bool = false
var _impact_area: Area3D


func _ready() -> void:
	_current_health = health
	_build_impact_area()


## BUGFIX "Identifier 'body_entered' not declared": StaticBody3D hat KEIN
## body_entered-Signal - das gehoert zu Area3D. Eine eigene, rein
## ueberwachende Area3D (collision_layer = 0, monitorable = false) macht die
## Ramm-Erkennung, waehrend die physische Kollision beim StaticBody3D
## bleibt - gleiches Prinzip wie pit_floor.gd::_build_void_kill_zone().
## collision_mask = 5 ist derselbe dort bereits bewaehrte Wert fuer
## "Spieler + Gegner".
func _build_impact_area() -> void:
	_impact_area = Area3D.new()
	_impact_area.collision_layer = 0
	_impact_area.collision_mask = 5
	_impact_area.monitorable = false
	add_child(_impact_area)

	var col := CollisionShape3D.new()
	var own_shape: CollisionShape3D = _find_own_collision_shape()
	if own_shape != null and own_shape.shape != null:
		col.shape = own_shape.shape.duplicate()
	else:
		var fallback := BoxShape3D.new()
		fallback.size = Vector3(3.0, 10.0, 3.0)
		col.shape = fallback
	_impact_area.add_child(col)

	_impact_area.body_entered.connect(_on_body_entered)


func _find_own_collision_shape() -> CollisionShape3D:
	for child in get_children():
		if child is CollisionShape3D:
			return child as CollisionShape3D
	return null


## Fuer Hitbox-/Item-Schaden (z.B. Explosionen) - dieselbe Signatur wie
## Health.take_damage(), damit primary_hitbox.gd sie ueber find_child("Health")
## NICHT findet (Requisiten sind kein Kampf-Ziel) und Items sie stattdessen
## gezielt per has_method("take_damage") ansprechen koennen.
func take_damage(amount: float, _source: Node = null) -> void:
	if _destroyed or amount <= 0.0:
		return
	_current_health -= amount
	if _current_health <= 0.0:
		_destroy()


func _on_body_entered(body: Node3D) -> void:
	if _destroyed or not (body is CharacterBody3D):
		return
	if body.get("is_heavy") != true:
		return
	var speed: float = (body as CharacterBody3D).velocity.length()
	if speed < heavy_impact_speed_threshold:
		return

	_destroy()
	if body.has_method("apply_stun"):
		body.apply_stun(stagger_stun_duration)


func _destroy() -> void:
	if _destroyed:
		return
	_destroyed = true

	if debris_vfx != null:
		VFX.spawn(debris_vfx, global_position, Vector3.UP)

	for child in get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).set_deferred("disabled", true)
	visible = false
	queue_free()
