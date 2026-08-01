extends Control
class_name BossHealthBar

# ============================================================================
# BossHealthBar — Isaac-artige Boss-Leiste am unteren Bildschirmrand.
# ============================================================================
#
# WO SIE HAENGT:
# Als Kind des HUD-Wurzelknotens in hud.tscn. Sie verankert sich in
# _ready() SELBST unten mittig — die Position muss also nicht in der Szene
# gepflegt werden und rutscht nicht, wenn sich das restliche HUD aendert.
#
# WARUM KEIN AUTOLOAD-OVERLAY:
# Sie ist ein HUD-Element und muss mit dem HUD zusammen aus- und
# eingeblendet werden (Screenshots, Cutscenes, HUD-Master-Schalter). Ein
# eigener CanvasLayer wuerde beim Ausblenden des HUD stehen bleiben.
#
# WIE DER BOSS GEFUNDEN WIRD — und warum es zwei Wege gibt:
#   1. Gruppe "boss": wenn ein Gegner explizit so markiert ist, gewinnt er.
#      Das ist der saubere Weg fuer spaeter.
#   2. Fallback: im Bossraum der Gegner mit der HOECHSTEN max_health.
#      Aktuell markiert nichts im Projekt einen Boss als solchen — die
#      boss_table des LevelGenerators spawnt normale EnemyAI-Instanzen mit
#      groesseren Werten. Ohne diesen Fallback bliebe die Leiste heute
#      dauerhaft leer.
#
# Ob wir ueberhaupt im Bossraum sind, kommt aus dem LevelGenerator
# (get_map_cells()/get_current_room()). Bewusst nicht ueber eine Abfrage an
# den Raum selbst: der LevelGenerator veroeffentlicht keine Referenz auf
# die RoomInstance, und dafuer eine neue oeffentliche Methode einzufuehren
# waere eine Aenderung an einer Datei, die dieses Feature sonst nicht
# anfasst.

const GENERATOR_GROUP: String = "level_generator"
const ENEMY_GROUP: String = "enemies"
const BOSS_GROUP: String = "boss"

## Abstand zum unteren Bildschirmrand. Muss unter den Item-Buttons liegen —
## bei 24 sitzt sie knapp darunter; nach oben verschieben heisst: Wert
## erhoehen.
@export var margin_bottom: float = 24.0
@export var bar_width: float = 520.0
@export var bar_height: float = 18.0
@export var bar_color: Color = Color(0.86, 0.18, 0.20, 0.95)
@export var bar_background: Color = Color(0.05, 0.04, 0.05, 0.85)
@export var bar_border: Color = Color(0.98, 0.80, 0.22, 0.75)

## Wie schnell die Leiste dem echten Wert folgt (Anteil pro Sekunde). Ein
## sofortiger Sprung liest sich bei grossen Treffern wie ein Ruckeln.
@export var fill_lerp_speed: float = 8.0

## Wie lange die Leiste nach dem Boss-Tod noch stehen bleibt, bevor sie
## ausblendet. Ohne diese Pause verschwindet sie im selben Frame wie der
## letzte Treffer und der Kill fuehlt sich unbestaetigt an.
@export var death_hold_time: float = 0.9
@export var fade_time: float = 0.35

var _name_label: Label = null
var _bar_bg: Panel = null
var _bar_fill: ColorRect = null
var _bar_style: StyleBoxFlat = null

var _generator: Node = null
var _boss: Node3D = null
var _boss_health: Node = null
var _displayed_percent: float = 1.0
var _death_timer: float = 0.0
var _fade_tween: Tween = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Unten mittig verankern, Breite und Hoehe selbst setzen.
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 1.0
	anchor_bottom = 1.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BEGIN

	var total_height: float = bar_height + 20.0
	offset_left = -bar_width * 0.5
	offset_right = bar_width * 0.5
	offset_top = -(margin_bottom + total_height)
	offset_bottom = -margin_bottom

	_build()
	modulate.a = 0.0
	visible = false


func _build() -> void:
	_name_label = Label.new()
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_name_label.offset_bottom = 16.0
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 12)
	_name_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.62))
	_name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_name_label.add_theme_constant_override("outline_size", 4)
	add_child(_name_label)

	_bar_bg = Panel.new()
	_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_bar_bg.offset_top = -bar_height
	_bar_bg.offset_bottom = 0.0

	_bar_style = StyleBoxFlat.new()
	_bar_style.bg_color = bar_background
	_bar_style.border_color = bar_border
	_bar_style.set_border_width_all(2)
	_bar_style.set_corner_radius_all(1)
	_bar_bg.add_theme_stylebox_override("panel", _bar_style)
	add_child(_bar_bg)

	# ColorRect statt ProgressBar: die Fuellung soll exakt so aussehen wie
	# der Rest des HUD, und eine ProgressBar brauchte dafuer drei
	# Theme-Overrides plus eine eigene StyleBox fuer den Fuellbalken.
	_bar_fill = ColorRect.new()
	_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_fill.color = bar_color
	_bar_fill.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	_bar_fill.offset_left = 2.0
	_bar_fill.offset_top = 2.0
	_bar_fill.offset_bottom = -2.0
	_bar_bg.add_child(_bar_fill)


func _process(delta: float) -> void:
	_bind_generator()

	if not _is_boss_room():
		_release_boss()
		return

	if _boss == null or not is_instance_valid(_boss):
		_acquire_boss()

	if _boss == null or _boss_health == null:
		# Boss war da und ist jetzt weg -> Nachlauf, dann ausblenden.
		if visible and _death_timer > 0.0:
			_death_timer -= delta
			if _death_timer <= 0.0:
				_hide_bar()
		return

	var maximum: float = float(_boss_health.get("max_health"))
	var current: float = float(_boss_health.get("current_health"))
	if maximum <= 0.0:
		return

	var target: float = clampf(current / maximum, 0.0, 1.0)
	_displayed_percent = lerpf(_displayed_percent, target, clampf(fill_lerp_speed * delta, 0.0, 1.0))
	_apply_fill(_displayed_percent)

	if target <= 0.0:
		_death_timer = death_hold_time
		_release_boss_reference_only()


func _apply_fill(percent: float) -> void:
	if _bar_fill == null or _bar_bg == null:
		return
	# Innenbreite = Balkenbreite minus die 2 px Rand auf beiden Seiten.
	var inner: float = maxf(_bar_bg.size.x - 4.0, 0.0)
	_bar_fill.offset_right = -(inner * (1.0 - percent)) - 2.0


func _bind_generator() -> void:
	if _generator != null and is_instance_valid(_generator):
		return
	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if not found.is_empty():
		_generator = found[0]


func _is_boss_room() -> bool:
	if _generator == null or not is_instance_valid(_generator):
		return false
	if not _generator.has_method("get_map_cells") or not _generator.has_method("get_current_room"):
		return false

	var cells: Dictionary = _generator.get_map_cells()
	var current: Vector2i = _generator.get_current_room()
	if not cells.has(current):
		return false
	return int(cells[current].get("type", -1)) == RoomData.RoomType.BOSS


## Sucht den Boss. Reihenfolge: explizite Gruppe, sonst der Gegner mit der
## hoechsten max_health.
func _acquire_boss() -> void:
	var best: Node3D = null
	var best_max: float = -1.0

	for node: Node in get_tree().get_nodes_in_group(BOSS_GROUP):
		var tagged := node as Node3D
		if tagged != null and is_instance_valid(tagged) and _health_of(tagged) != null:
			best = tagged
			break

	if best == null:
		for node: Node in get_tree().get_nodes_in_group(ENEMY_GROUP):
			var enemy := node as Node3D
			if enemy == null or not is_instance_valid(enemy):
				continue
			var health: Node = _health_of(enemy)
			if health == null:
				continue
			var maximum: float = float(health.get("max_health"))
			if maximum > best_max:
				best_max = maximum
				best = enemy

	if best == null:
		return

	_boss = best
	_boss_health = _health_of(best)
	_displayed_percent = 1.0
	_apply_fill(1.0)

	var label: String = "BOSS"
	if _boss.has_method("get_display_name"):
		label = String(_boss.call("get_display_name"))
	elif _boss.name != "":
		label = String(_boss.name).to_upper()
	_name_label.text = label

	_show_bar()


## Liefert die Health-Komponente eines Gegners oder null. Ueber
## get_node_or_null statt einer typisierten Referenz, damit dieses Script
## nichts ueber den inneren Aufbau von EnemyAI wissen muss.
func _health_of(enemy: Node) -> Node:
	var health: Node = enemy.get_node_or_null("Health")
	if health == null:
		return null
	if health.has_method("is_alive") and not health.is_alive():
		return null
	return health


## Boss tot: Referenz loesen, Leiste aber stehen lassen (Nachlauf).
func _release_boss_reference_only() -> void:
	_boss = null
	_boss_health = null


## Raum verlassen: sofort weg.
func _release_boss() -> void:
	_boss = null
	_boss_health = null
	_death_timer = 0.0
	if visible:
		_hide_bar()


func _show_bar() -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	visible = true
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, fade_time)


func _hide_bar() -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, fade_time)
	_fade_tween.tween_callback(func() -> void: visible = false)
