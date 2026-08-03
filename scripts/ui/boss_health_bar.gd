
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
# ############################################################################
# BUGFIX: "bar ist da aber hp ist nicht synchronisiert mit den 3 boessen"
# ############################################################################
#
# URSACHE
# -------
# Die alte Fassung hat in _acquire_boss() GENAU EINEN Gegner gebunden:
#
#     for node in get_tree().get_nodes_in_group(ENEMY_GROUP):
#         if maximum > best_max:
#             best_max = maximum
#             best = enemy          # <- nur der Staerkste ueberlebt
#
# Der Bossraum spawnt aber ueber boss_table drei gleichwertige Gegner
# (boss_threat_hard_cap = 40 ist genau dafuer da, siehe level_generator.gd).
# Die Leiste hat also die HP von EINEM der drei gezeigt. Sichtbare Folgen:
#
#   * Man schlaegt auf Boss B ein, die Leiste bewegt sich nicht — sie haengt
#     an Boss A.
#   * Stirbt A, springt die Leiste auf 0, wartet death_hold_time ab und
#     blendet aus — obwohl noch zwei Bosse leben.
#   * Danach greift _acquire_boss() erneut, die Leiste kommt mit VOLLEM
#     Balken zurueck. Aus Spielersicht: die Anzeige zaehlt nicht mit.
#
# FIX
# ---
# Die Leiste verfolgt jetzt ALLE Bosse des Raums als EINEN gemeinsamen
# HP-Pool: angezeigt wird summe(current) / summe(max). Tote Bosse bleiben
# mit ihrem max_health im Nenner stehen — sonst wuerde der Balken beim Tod
# des ersten Bosses nach OBEN springen (2/2 statt 2/3 der Restgesundheit).
#
# Zusaetzlich zeichnet die Leiste Trennstriche, einen pro Boss. Man sieht
# dadurch auf einen Blick, wie viele Gegner noch im Pool stecken — dasselbe
# Mittel, das Isaac fuer mehrteilige Bosse benutzt.
#
# WIE DIE BOSSE GEFUNDEN WERDEN — und warum es zwei Wege gibt:
#   1. Gruppe "boss": ist auch nur EIN Gegner so markiert, zaehlen
#      ausschliesslich die markierten. Das ist der saubere Weg fuer spaeter.
#   2. Fallback: im Bossraum jeder Gegner, dessen max_health mindestens
#      boss_health_ratio des staerksten Gegners erreicht. Aktuell markiert
#      nichts im Projekt einen Boss als solchen — die boss_table des
#      LevelGenerators spawnt normale EnemyAI-Instanzen mit groesseren
#      Werten. Ohne diesen Fallback bliebe die Leiste heute dauerhaft leer.
#      Das Verhaeltnis (statt "alle Gegner im Raum") sorgt dafuer, dass
#      spaeter dazugespawnte Kleingegner den Pool nicht verwaessern.
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

## Farbe der Trennstriche zwischen den einzelnen Bossen.
@export var segment_color: Color = Color(0.02, 0.02, 0.03, 0.85)
@export var segment_width: float = 2.0

## Wie schnell die Leiste dem echten Wert folgt (Anteil pro Sekunde). Ein
## sofortiger Sprung liest sich bei grossen Treffern wie ein Ruckeln.
@export var fill_lerp_speed: float = 8.0

## Wie lange die Leiste nach dem Tod des LETZTEN Bosses noch stehen bleibt,
## bevor sie ausblendet. Ohne diese Pause verschwindet sie im selben Frame
## wie der letzte Treffer und der Kill fuehlt sich unbestaetigt an.
@export var death_hold_time: float = 0.9
@export var fade_time: float = 0.35

## Ab welchem Anteil der HOECHSTEN max_health im Raum ein Gegner als Boss
## gilt (nur fuer den Fallback ohne "boss"-Gruppe). 0.5 = alles, was
## mindestens halb so zaeh ist wie der staerkste Gegner.
@export_range(0.05, 1.0) var boss_health_ratio: float = 0.5

## Wie oft nach neu dazugekommenen Bossen gesucht wird (Sekunden). Der
## Bossraum spawnt seine Gegner ueber mehrere Frames verteilt; ohne
## Nachsuche haenge die Leiste an dem, was im ersten Frame zufaellig schon
## da war.
@export var rescan_interval: float = 0.5

## Zeigt "2/3" hinter dem Namen, solange mehr als ein Boss im Pool ist.
@export var show_alive_count: bool = true

@export var boss_label_text: String = "BOSS"

var _name_label: Label = null
var _bar_bg: Panel = null
var _bar_fill: ColorRect = null
var _bar_style: StyleBoxFlat = null
## Trennstriche zwischen den Boss-Segmenten. Liegen als Kinder auf _bar_bg,
## also UEBER der Fuellung.
var _segments: Array[ColorRect] = []

var _generator: Node = null

## instance_id -> { "node": Node3D, "health": Node, "max": float }
##
## Warum ein Dictionary und kein Array: Bosse werden nachtraeglich ergaenzt
## (_rescan) und muessen dabei zuverlaessig auf Doppelung geprueft werden.
## Ueber die instance_id geht das in O(1) und ohne is_instance_valid()-
## Vergleiche auf bereits freigegebenen Objekten.
var _bosses: Dictionary = {}
## Summe aller max_health, die JE im Pool waren. Waechst mit, schrumpft nie
## innerhalb eines Kampfes — siehe Bugfix-Block oben.
var _total_max: float = 0.0
var _displayed_percent: float = 1.0
var _death_timer: float = 0.0
var _rescan_timer: float = 0.0
var _fade_tween: Tween = null
## Anzahl Bosse, fuer die zuletzt Trennstriche gezeichnet wurden. Verhindert,
## dass die Segmente jeden Frame neu aufgebaut werden.
var _segment_count_drawn: int = 0


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
		_release_all()
		return

	# Erst aufraeumen (tote/abgeraeumte Instanzen), dann nachsehen, ob
	# jemand dazugekommen ist. Reihenfolge ist wichtig: _prune() darf
	# _total_max NICHT senken, sonst springt der Balken beim ersten Kill
	# nach oben.
	_prune()

	_rescan_timer -= delta
	if _rescan_timer <= 0.0:
		_rescan_timer = maxf(rescan_interval, 0.1)
		_rescan()

	if _bosses.is_empty():
		# Alle Bosse tot -> Balken auf 0 ziehen, kurz halten, ausblenden.
		if visible:
			_displayed_percent = lerpf(_displayed_percent, 0.0, clampf(fill_lerp_speed * delta, 0.0, 1.0))
			_apply_fill(_displayed_percent)
			if _death_timer > 0.0:
				_death_timer -= delta
				if _death_timer <= 0.0:
					_hide_bar()
		return

	if _total_max <= 0.0:
		return

	var current_total: float = 0.0
	for id: int in _bosses.keys():
		var entry: Dictionary = _bosses[id]
		var health: Node = entry["health"]
		if health == null or not is_instance_valid(health):
			continue
		current_total += maxf(float(health.get("current_health")), 0.0)

	var target: float = clampf(current_total / _total_max, 0.0, 1.0)
	_displayed_percent = lerpf(_displayed_percent, target, clampf(fill_lerp_speed * delta, 0.0, 1.0))
	_apply_fill(_displayed_percent)
	_update_label()

	# Sobald der letzte Boss faellt, laeuft der Nachlauf an. _bosses ist im
	# naechsten _prune() leer, der Zweig oben uebernimmt dann.
	if target <= 0.0:
		_death_timer = death_hold_time


func _apply_fill(percent: float) -> void:
	if _bar_fill == null or _bar_bg == null:
		return
	# Innenbreite = Balkenbreite minus die 2 px Rand auf beiden Seiten.
	var inner: float = maxf(_bar_bg.size.x - 4.0, 0.0)
	_bar_fill.offset_right = -(inner * (1.0 - percent)) - 2.0


# ============================================================================
# Boss-Verwaltung
# ============================================================================

## Entfernt Eintraege, deren Gegner tot oder abgeraeumt ist. _total_max
## bleibt dabei ABSICHTLICH stehen — siehe Bugfix-Block im Dateikopf.
func _prune() -> void:
	var dead: Array[int] = []
	for id: int in _bosses.keys():
		var entry: Dictionary = _bosses[id]
		var node: Node = entry["node"]
		var health: Node = entry["health"]
		if node == null or not is_instance_valid(node):
			dead.append(id)
			continue
		if health == null or not is_instance_valid(health):
			dead.append(id)
			continue
		if health.has_method("is_alive") and not health.is_alive():
			dead.append(id)
	for id: int in dead:
		_bosses.erase(id)


## Sucht neue Bosse und nimmt sie in den Pool auf.
func _rescan() -> void:
	var candidates: Array[Node3D] = _collect_candidates()
	if candidates.is_empty():
		return

	var added: bool = false
	for enemy: Node3D in candidates:
		var id: int = enemy.get_instance_id()
		if _bosses.has(id):
			continue
		var health: Node = _health_of(enemy)
		if health == null:
			continue

		var maximum: float = maxf(float(health.get("max_health")), 1.0)
		_bosses[id] = {"node": enemy, "health": health, "max": maximum}
		_total_max += maximum
		added = true

	if not added:
		return

	if not visible:
		# Erster Boss dieses Kampfes -> Leiste frisch aufziehen.
		_displayed_percent = 1.0
		_apply_fill(1.0)
		_death_timer = 0.0
		_show_bar()

	_rebuild_segments()
	_update_label()


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

	# Bereits aufgenommene Bosse heben die Messlatte mit an: sonst koennte
	# ein spaet gespawnter Kleingegner die Schwelle druecken, wenn der
	# staerkste Boss zu dem Zeitpunkt schon tot ist.
	for id: int in _bosses.keys():
		strongest = maxf(strongest, float((_bosses[id] as Dictionary)["max"]))

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

## Ein Trennstrich pro Boss-Grenze. Die Striche haengen auf _bar_bg und
## liegen damit ueber der Fuellung — sie bleiben also auch sichtbar, wenn
## der Balken an dieser Stelle noch voll ist.
func _rebuild_segments() -> void:
	var count: int = _bosses.size()
	if count == _segment_count_drawn:
		return
	_segment_count_drawn = count

	for rect: ColorRect in _segments:
		if is_instance_valid(rect):
			rect.queue_free()
	_segments.clear()

	if count <= 1:
		return

	for i: int in range(1, count):
		var divider := ColorRect.new()
		divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		divider.color = segment_color
		divider.set_anchors_preset(Control.PRESET_TOP_LEFT)
		# anchor_left/right auf denselben Anteil: der Strich sitzt dadurch
		# prozentual, nicht in Pixeln — er wandert also korrekt mit, wenn
		# sich die Fensterbreite und damit bar_width aendert.
		var fraction: float = float(i) / float(count)
		divider.anchor_left = fraction
		divider.anchor_right = fraction
		divider.anchor_top = 0.0
		divider.anchor_bottom = 1.0
		divider.offset_left = -segment_width * 0.5
		divider.offset_right = segment_width * 0.5
		divider.offset_top = 2.0
		divider.offset_bottom = -2.0
		_bar_bg.add_child(divider)
		_segments.append(divider)


func _update_label() -> void:
	if _name_label == null:
		return

	var label: String = boss_label_text
	# Namen des ersten noch lebenden Bosses uebernehmen, falls der Gegner
	# einen anbietet.
	for id: int in _bosses.keys():
		var node: Node = (_bosses[id] as Dictionary)["node"]
		if node == null or not is_instance_valid(node):
			continue
		if node.has_method("get_display_name"):
			label = String(node.call("get_display_name")).to_upper()
		break

	if show_alive_count and _segment_count_drawn > 1:
		label = "%s  %d/%d" % [label, _bosses.size(), _segment_count_drawn]

	_name_label.text = label


## Raum verlassen oder Kampf vorbei: kompletter Reset. Erst hier faellt
## _total_max wieder auf 0 — innerhalb eines Kampfes nie.
func _release_all() -> void:
	_bosses.clear()
	_total_max = 0.0
	_death_timer = 0.0
	_rescan_timer = 0.0
	_segment_count_drawn = 0
	for rect: ColorRect in _segments:
		if is_instance_valid(rect):
			rect.queue_free()
	_segments.clear()
	if visible:
		_hide_bar()


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
