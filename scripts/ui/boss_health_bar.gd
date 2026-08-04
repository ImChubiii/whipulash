
extends Control
class_name BossHealthBar

# ============================================================================
# BossHealthBar — Isaac-artige Boss-Leisten am unteren Bildschirmrand.
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
# ############################################################################
# REWORK: gemeinsamer HP-Pool -> 3 individuelle Balken
# ############################################################################
#
# VORHER: GENAU EIN Balken zeigte summe(current)/summe(max) ueber alle Bosse
# des Raums. Der Bossraum spawnt ueber boss_table drei gleichwertige Gegner
# (siehe level_generator.gd) - ein einzelner Pool-Balken macht dabei nicht
# sichtbar, WELCHER der drei Bosse gerade wie viel Schaden abbekommt, und ein
# sterbender Boss liess den gemeinsamen Balken nur um seinen Anteil sinken
# statt sichtbar zu verschwinden.
#
# JETZT: bis zu MAX_BOSSES (3) eigene Balken, jeder an GENAU EINEN Boss
# gebunden. Jeder Balken faehrt seinen eigenen current/max nach (rot,
# spiegelbildlich zur echten Boss-HP) und blendet sich SELBSTSTAENDIG aus,
# sobald sein eigener Boss stirbt - kein gemeinsamer Pool mehr, keine
# wandernde Bindung.
#
# SLOT-ZUWEISUNG: der zuerst gefundene Boss bekommt IMMER den untersten
# (bildschirmnaechsten) Balken, spaeter hinzukommende stapeln sich nach oben.
# Ein bereits sichtbarer Balken springt dadurch nie an eine andere Position,
# wenn ein zweiter/dritter Boss dazugefunden wird.
#
# WIE DIE BOSSE GEFUNDEN WERDEN — und warum es zwei Wege gibt:
#   1. Gruppe "boss": ist auch nur EIN Gegner so markiert, zaehlen
#      ausschliesslich die markierten. Das ist der saubere Weg fuer spaeter.
#   2. Fallback: im Bossraum jeder Gegner, dessen max_health mindestens
#      boss_health_ratio des staerksten Gegners erreicht. Aktuell markiert
#      nichts im Projekt einen Boss als solchen — die boss_table des
#      LevelGenerators spawnt normale EnemyAI-Instanzen mit groesseren
#      Werten. Ohne diesen Fallback blieben die Leisten heute dauerhaft leer.
#
# Ob wir ueberhaupt im Bossraum sind, kommt aus dem LevelGenerator
# (get_map_cells()/get_current_room()). Bewusst nicht ueber eine Abfrage an
# den Raum selbst: der LevelGenerator veroeffentlicht keine Referenz auf die
# RoomInstance, und dafuer eine neue oeffentliche Methode einzufuehren waere
# eine Aenderung an einer Datei, die dieses Feature sonst nicht anfasst.

const GENERATOR_GROUP: String = "level_generator"
const ENEMY_GROUP: String = "enemies"
const BOSS_GROUP: String = "boss"

## Feste Anzahl Balken: der Bossraum spawnt seine Gegner ueber boss_table
## immer als Dreiergruppe. Weniger Bosse lassen ueberzaehlige Slots einfach
## unsichtbar.
const MAX_BOSSES: int = 3

## Abstand zum unteren Bildschirmrand. Muss unter den Item-Buttons liegen —
## bei 24 sitzt die unterste Leiste knapp darunter; nach oben verschieben
## heisst: Wert erhoehen.
@export var margin_bottom: float = 24.0
@export var bar_width: float = 420.0
@export var bar_height: float = 14.0
## Vertikaler Abstand zwischen zwei gestapelten Balken.
@export var bar_gap: float = 8.0
@export var bar_color: Color = Color(0.86, 0.18, 0.20, 0.95)
@export var bar_background: Color = Color(0.05, 0.04, 0.05, 0.85)
@export var bar_border: Color = Color(0.98, 0.80, 0.22, 0.75)

## Wie schnell ein Balken dem echten Wert folgt (Anteil pro Sekunde). Ein
## sofortiger Sprung liest sich bei grossen Treffern wie ein Ruckeln.
@export var fill_lerp_speed: float = 8.0

## Wie lange ein Balken nach dem Tod SEINES Bosses noch stehen bleibt, bevor
## er ausblendet. Ohne diese Pause verschwindet er im selben Frame wie der
## letzte Treffer und der Kill fuehlt sich unbestaetigt an.
@export var death_hold_time: float = 0.9
@export var fade_time: float = 0.35

## Ab welchem Anteil der HOECHSTEN max_health im Raum ein Gegner als Boss
## gilt (nur fuer den Fallback ohne "boss"-Gruppe). 0.5 = alles, was
## mindestens halb so zaeh ist wie der staerkste Gegner.
@export_range(0.05, 1.0) var boss_health_ratio: float = 0.5

## Wie oft nach neu dazugekommenen Bossen gesucht wird (Sekunden). Der
## Bossraum spawnt seine Gegner ueber mehrere Frames verteilt; ohne
## Nachsuche haengt der erste Balken an dem, was im ersten Frame zufaellig
## schon da war.
@export var rescan_interval: float = 0.5

@export var boss_label_text: String = "BOSS"

## Laufzeit-Zustand EINES Balkens/Bosses.
class BossSlot:
	var root: Control = null
	var name_label: Label = null
	var bar_bg: Panel = null
	var bar_fill: ColorRect = null

	var bound_id: int = -1
	var node: Node3D = null
	var health: Node = null
	var max_health: float = 1.0

	var displayed_percent: float = 1.0
	var death_timer: float = 0.0
	## true, solange ein Boss gebunden ist ODER die Sterbe-Animation dieses
	## Slots noch laeuft - erst danach wird der Slot wieder frei.
	var active: bool = false
	var fade_tween: Tween = null

var _slots: Array[BossSlot] = []
var _generator: Node = null
var _rescan_timer: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 1.0
	anchor_bottom = 1.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BEGIN

	var slot_height: float = bar_height + 20.0
	var total_height: float = slot_height * MAX_BOSSES + bar_gap * (MAX_BOSSES - 1)
	offset_left = -bar_width * 0.5
	offset_right = bar_width * 0.5
	offset_top = -(margin_bottom + total_height)
	offset_bottom = -margin_bottom

	_build_slots(slot_height)
	visible = false


func _build_slots(slot_height: float) -> void:
	for i: int in range(MAX_BOSSES):
		var slot := BossSlot.new()

		var root := Control.new()
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.set_anchors_preset(Control.PRESET_TOP_WIDE)
		# Slot 0 ganz unten (naeher am Bildschirmrand), hoehere Indizes
		# stapeln sich nach oben - siehe Kopfkommentar "SLOT-ZUWEISUNG".
		var from_bottom: int = (MAX_BOSSES - 1) - i
		root.offset_top = float(from_bottom) * (slot_height + bar_gap)
		root.offset_bottom = root.offset_top + slot_height
		root.modulate.a = 0.0
		root.visible = false
		add_child(root)
		slot.root = root

		var name_label := Label.new()
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		name_label.offset_bottom = 16.0
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.62))
		name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		name_label.add_theme_constant_override("outline_size", 4)
		root.add_child(name_label)

		var bar_bg := Panel.new()
		bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar_bg.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		bar_bg.offset_top = -bar_height
		bar_bg.offset_bottom = 0.0

		var style := StyleBoxFlat.new()
		style.bg_color = bar_background
		style.border_color = bar_border
		style.set_border_width_all(2)
		style.set_corner_radius_all(1)
		bar_bg.add_theme_stylebox_override("panel", style)
		root.add_child(bar_bg)

		# ColorRect statt ProgressBar: die Fuellung soll exakt so aussehen wie
		# der Rest des HUD, und eine ProgressBar brauchte dafuer drei
		# Theme-Overrides plus eine eigene StyleBox fuer den Fuellbalken.
		var bar_fill := ColorRect.new()
		bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar_fill.color = bar_color
		bar_fill.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
		bar_fill.offset_left = 2.0
		bar_fill.offset_top = 2.0
		bar_fill.offset_bottom = -2.0
		bar_bg.add_child(bar_fill)

		slot.name_label = name_label
		slot.bar_bg = bar_bg
		slot.bar_fill = bar_fill
		_slots.append(slot)


func _process(delta: float) -> void:
	_bind_generator()

	if not _is_boss_room():
		_release_all()
		return

	_rescan_timer -= delta
	if _rescan_timer <= 0.0:
		_rescan_timer = maxf(rescan_interval, 0.1)
		_rescan()

	var any_active: bool = false
	for slot: BossSlot in _slots:
		if not slot.active:
			continue
		any_active = true
		_update_slot(slot, delta)

	if any_active and not visible:
		visible = true
	elif not any_active and visible:
		visible = false


func _update_slot(slot: BossSlot, delta: float) -> void:
	var alive: bool = slot.health != null and is_instance_valid(slot.health) \
		and (not slot.health.has_method("is_alive") or slot.health.is_alive())

	if not alive:
		# Boss gerade gestorben (oder Instanz weg) -> diesen einen Balken auf
		# 0 fahren, kurz halten, dann NUR IHN ausblenden.
		slot.displayed_percent = lerpf(slot.displayed_percent, 0.0, clampf(fill_lerp_speed * delta, 0.0, 1.0))
		_apply_fill(slot, slot.displayed_percent)
		slot.death_timer -= delta
		if slot.death_timer <= 0.0:
			_release_slot(slot)
		return

	var current: float = maxf(float(slot.health.get("current_health")), 0.0)
	var target: float = clampf(current / maxf(slot.max_health, 1.0), 0.0, 1.0)
	slot.displayed_percent = lerpf(slot.displayed_percent, target, clampf(fill_lerp_speed * delta, 0.0, 1.0))
	_apply_fill(slot, slot.displayed_percent)

	if target <= 0.0:
		slot.death_timer = death_hold_time


func _apply_fill(slot: BossSlot, percent: float) -> void:
	if slot.bar_fill == null or slot.bar_bg == null:
		return
	# Innenbreite = Balkenbreite minus die 2 px Rand auf beiden Seiten.
	var inner: float = maxf(slot.bar_bg.size.x - 4.0, 0.0)
	slot.bar_fill.offset_right = -(inner * (1.0 - percent)) - 2.0


# ============================================================================
# Boss-Verwaltung
# ============================================================================

## Sucht neue Bosse und bindet sie an freie Balken-Slots.
func _rescan() -> void:
	var candidates: Array[Node3D] = _collect_candidates()
	if candidates.is_empty():
		return

	for enemy: Node3D in candidates:
		var id: int = enemy.get_instance_id()
		if _is_bound(id):
			continue

		var slot: BossSlot = _find_free_slot()
		if slot == null:
			break  # alle MAX_BOSSES Slots belegt

		var health: Node = _health_of(enemy)
		if health == null:
			continue

		var maximum: float = maxf(float(health.get("max_health")), 1.0)
		var current: float = maxf(float(health.get("current_health")), 0.0)

		slot.bound_id = id
		slot.node = enemy
		slot.health = health
		slot.max_health = maximum
		slot.displayed_percent = clampf(current / maximum, 0.0, 1.0)
		slot.death_timer = 0.0
		slot.active = true

		_update_label(slot)
		_apply_fill(slot, slot.displayed_percent)
		_show_slot(slot)


func _find_free_slot() -> BossSlot:
	for slot: BossSlot in _slots:
		if not slot.active:
			return slot
	return null


func _is_bound(id: int) -> bool:
	for slot: BossSlot in _slots:
		if slot.active and slot.bound_id == id:
			return true
	return false


## Kandidatenliste. Gruppe "boss" hat Vorrang; sonst der Verhaeltnis-Filter.
func _collect_candidates() -> Array[Node3D]:
	var result: Array[Node3D] = []

	for node: Node in get_tree().get_nodes_in_group(BOSS_GROUP):
		var tagged := node as Node3D
		if tagged != null and is_instance_valid(tagged) and _health_of(tagged) != null:
			result.append(tagged)
	if not result.is_empty():
		return result

	# --- Fallback ohne Markierung -------------------------------------
	var enemies: Array[Node3D] = []
	var strongest: float = 0.0
	for node: Node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var health: Node = _health_of(enemy)
		if health == null:
			continue
		enemies.append(enemy)
		strongest = maxf(strongest, float(health.get("max_health")))

	if enemies.is_empty() or strongest <= 0.0:
		return result

	# Bereits gebundene Bosse heben die Messlatte mit an: sonst koennte ein
	# spaet gespawnter Kleingegner die Schwelle druecken, wenn der staerkste
	# Boss zu dem Zeitpunkt schon tot ist.
	for slot: BossSlot in _slots:
		if slot.active:
			strongest = maxf(strongest, slot.max_health)

	var threshold: float = strongest * clampf(boss_health_ratio, 0.05, 1.0)
	for enemy: Node3D in enemies:
		var health: Node = _health_of(enemy)
		if health != null and float(health.get("max_health")) >= threshold:
			result.append(enemy)
	return result


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


# ============================================================================
# Darstellung
# ============================================================================
func _update_label(slot: BossSlot) -> void:
	if slot.name_label == null:
		return
	var label: String = boss_label_text
	if slot.node != null and is_instance_valid(slot.node) and slot.node.has_method("get_display_name"):
		label = String(slot.node.call("get_display_name")).to_upper()
	slot.name_label.text = label


func _show_slot(slot: BossSlot) -> void:
	if slot.root == null:
		return
	if slot.fade_tween and slot.fade_tween.is_valid():
		slot.fade_tween.kill()
	slot.root.visible = true
	slot.fade_tween = create_tween()
	slot.fade_tween.tween_property(slot.root, "modulate:a", 1.0, fade_time)


## Blendet NUR DIESEN Balken aus und gibt seinen Slot fuer einen spaeter
## erscheinenden Boss wieder frei.
func _release_slot(slot: BossSlot) -> void:
	slot.bound_id = -1
	slot.node = null
	slot.health = null
	slot.active = false
	slot.death_timer = 0.0

	if slot.root == null:
		return
	if slot.fade_tween and slot.fade_tween.is_valid():
		slot.fade_tween.kill()
	slot.fade_tween = create_tween()
	slot.fade_tween.tween_property(slot.root, "modulate:a", 0.0, fade_time)
	slot.fade_tween.tween_callback(func() -> void:
		if is_instance_valid(slot.root):
			slot.root.visible = false
	)


## Raum verlassen oder Kampf vorbei: alle Balken hart zuruecksetzen (kein
## Fade-Out - der Raumwechsel selbst blendet die Kamera bereits aus).
func _release_all() -> void:
	for slot: BossSlot in _slots:
		if slot.fade_tween and slot.fade_tween.is_valid():
			slot.fade_tween.kill()
		slot.bound_id = -1
		slot.node = null
		slot.health = null
		slot.active = false
		slot.death_timer = 0.0
		slot.displayed_percent = 1.0
		if slot.root != null:
			slot.root.visible = false
			slot.root.modulate.a = 0.0
	if visible:
		visible = false


# ============================================================================
# Umgebung
# ============================================================================
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
