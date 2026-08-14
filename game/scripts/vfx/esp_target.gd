extends Node

# ============================================================================
# EspTarget — Autoload: projektweiter Singular-ESP-Indikator.
# ============================================================================
# Rueckmeldung (2026-08-13) "ESP bei Winter/Giselle: manchmal mehrere Kaesten
# auf demselben Gegner, verschwindet nicht immer beim Tod - soll auf GENAU
# EINEN Indikator im ganzen Spiel vereinfacht werden, der springt, statt
# dass jede Waffe ihren eigenen mitschleppt".
#
# Vorher hielt jedes Waffensystem (combat_giselle.gd::_uzi_esp_*/
# _sniper_esp_box, combat_winter.gd::_laser_esp_*/ein esp_box PRO Plasma-
# Bolt) seinen EIGENEN Label3D+EnemyEspBox. Zwei gleichzeitig aktive Waffen
# (z.B. Winters gehaltener Laser UND ihr Plasma-Primary) oder mehrere
# schnelle Treffer auf denselben Gegner konnten dadurch mehrere Kaesten
# gleichzeitig erzeugen - und ein Kasten verschwand nur, wenn GENAU die
# Waffe, die ihn gebaut hatte, das selbst bemerkte (z.B. erst beim naechsten
# Schuss, nicht sofort beim Tod).
#
# Dieser Autoload ersetzt das: es gibt hier genau EIN Label3D + EINE
# EnemyEspBox, nie mehr. Jedes Waffensystem meldet per acquire() sein
# gerade anvisiertes Ziel - der zuletzt aufgerufene Aufruf "gewinnt" den
# Indikator (in der Praxis: das Ziel, auf das aktuell tatsaechlich gehalten/
# geschossen wird). _process() prueft JEDEN Frame die Lebendigkeit des
# aktuellen Ziels, unabhaengig davon, welche Waffe gerade feuert - das ist
# der eigentliche Fix fuer "verschwindet nicht immer beim Tod".

var _target: Node3D = null
var _marker: Label3D = null
var _box: EnemyEspBox = null


## Meldet "target" als das aktuell anvisierte Ziel des Aufrufers an. Baut
## nur neu, wenn sich das Ziel tatsaechlich aendert - ein Aufruf mit
## demselben Ziel jeden Frame (z.B. Winters Laser) rebuilded also nichts,
## nur _process() unten haelt die Position aktuell.
func acquire(target: Node3D, color: Color) -> void:
	if target == null or not is_instance_valid(target) or not _is_alive(target):
		return
	if target == _target:
		return

	_clear()
	_target = target
	_marker = _build_marker(color)
	get_tree().current_scene.add_child(_marker)
	_box = EnemyEspBox.build_for(target, color)
	get_tree().current_scene.add_child(_box)
	_reposition()


## Raeumt den Indikator NUR auf, wenn "target" auch tatsaechlich das gerade
## angezeigte Ziel ist - so kann ein Waffensystem, das gerade kein eigenes
## Ziel mehr hat (z.B. LMB losgelassen), niemals versehentlich den
## Indikator eines ANDEREN, noch aktiven Waffensystems mitreissen.
func release(target: Node3D) -> void:
	if target != null and target == _target:
		_clear()


## Kurzer Aufleucht-Puls bei einem tatsaechlichen Treffer - no-op, falls
## "target" gerade gar nicht der angezeigte Indikator ist (z.B. Winters
## Plasma trifft ein Zweit-Ziel, das gar keinen eigenen Kasten mehr hat).
func flash(target: Node3D) -> void:
	if target != null and target == _target and _box != null and is_instance_valid(_box):
		_box.flash()


func _process(_delta: float) -> void:
	if _target == null:
		return
	if not is_instance_valid(_target) or not _is_alive(_target):
		_clear()
		return
	_reposition()


func _is_alive(target: Node3D) -> bool:
	var health: Node = target.find_child("Health", true, false)
	return health != null and health is Health and (health as Health).is_alive()


func _reposition() -> void:
	if _marker != null and is_instance_valid(_marker):
		_marker.global_position = _target.global_position + Vector3.UP * 2.2
	if _box != null and is_instance_valid(_box):
		_box.global_position = _target.global_position + Vector3.UP * (_box.size.y * 0.5)


func _clear() -> void:
	if _marker != null and is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null
	if _box != null and is_instance_valid(_box):
		_box.queue_free()
	_box = null
	_target = null


func _build_marker(color: Color) -> Label3D:
	var label := Label3D.new()
	label.text = "◆"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 72
	label.outline_size = 14
	label.modulate = color
	label.outline_modulate = Color(color.r * 0.2, color.g * 0.2, color.b * 0.2, 0.9)
	return label
