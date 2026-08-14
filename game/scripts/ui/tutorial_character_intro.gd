extends Control
class_name TutorialCharacterIntro

# ============================================================================
# TutorialCharacterIntro — Tutorial-UI: EIN fixierter "Allgemeine Mechaniken"-
# Eintrag + EIN Charakter-Slot, der beim Unlock zum naechsten Charakter
# ueberblendet (level_generator.gd::generate_tutorial_stage()).
# ============================================================================
# Rueckmeldung (2026-08-13) "Descriptions ueberlappen sich, alte Charakter-
# Description soll wegfaden und die neue an ihre Stelle sliden, allgemeine
# Description bleibt fixiert": VORHER haengte jeder freigeschaltete
# Charakter einen weiteren, dauerhaft sichtbaren Eintrag an eine wachsende
# Liste - die Liste wurde mit jedem Unlock hoeher und überlappte irgendwann
# andere HUD-Elemente. JETZT gibt es nur zwei Karten insgesamt:
#   - _general_card: einmalig per set_general_entry() gebaut (Dash/Bomben),
#     bleibt danach unveraendert stehen.
#   - _character_slot: ein fester Platz, dessen Inhalt show_character() bei
#     jedem Charakterwechsel AUSTAUSCHT statt einen weiteren Eintrag
#     anzuhaengen - die alte Karte faded weg, danach slided die neue an
#     genau dieselbe Stelle.
#
# WARUM DER SLOT KEIN CONTAINER-KIND IST:
# _character_slot haengt zwar selbst in der aeusseren _list (VBoxContainer),
# aber SEINE Kind-Karten (alt/neu) sind NICHT direkte Kinder eines
# Containers - ein Container wuerde die Kind-Position bei jedem Sortier-
# Durchlauf auf die Layout-Position zwingen und damit jede manuelle
# position/modulate-Tween-Animation sofort wieder ueberschreiben. Innerhalb
# von _character_slot (ein einfacher Control) bleibt die von uns per Tween
# gesetzte position/modulate dagegen unangetastet.
#
# --- Andocken an die Minimap ------------------------------------------------
# Statt einer festen Bildschirmposition haengt sich die Liste UNTER die
# Minimap - exakt dasselbe Problem/dieselbe Loesung wie run_timer.gd (dockt
# rechts daneben): Minimap.get_docking_rect() liefert das tatsaechlich
# belegte, mit SettingsManager.minimap_ui_scale skalierungskorrigierte
# Rechteck.
#
# --- Pause-Menu-Layering -----------------------------------------------------
# Ein normaler Control statt eines eigenen CanvasLayers - level_generator.gd
# haengt diese Node INS SELBE CanvasLayer wie HUD/PauseMenu (siehe dortiges
# _find_overlay_layer()), damit PauseMenu.z_index wie ueberall sonst gilt
# und diese Karten beim Pausieren korrekt dahinter verschwinden.

const PANEL_COLOR: Color = Color(0.05, 0.05, 0.08, 0.86)
const NAME_COLOR: Color = Color(0.95, 0.85, 0.35)
const DESC_COLOR: Color = Color(0.88, 0.88, 0.92)
const MAX_WIDTH: float = 420.0

const MINIMAP_GROUP: String = "minimap"

## Abstand zwischen Minimap-Rahmen und der Liste in Pixeln.
@export var dock_gap: float = 16.0
## Abstand zwischen der fixierten "Allgemein"-Karte und dem Charakter-Slot.
@export var entry_gap: float = 10.0

## Wie lange die alte Charakter-Karte braucht, um komplett wegzufaden.
@export var fade_out_time: float = 0.35
## Wie lange die neue Charakter-Karte braucht, um in ihre Position zu sliden.
@export var slide_in_time: float = 0.4
## Waagerechter Versatz, aus dem die neue Karte hereinslided (negativ = von
## links, positiv = von rechts).
@export var slide_in_offset: Vector2 = Vector2(0.0, 26.0)

## Position, falls keine Minimap existiert (z.B. Testszene ohne HUD).
const FALLBACK_POSITION: Vector2 = Vector2(24.0, 24.0)

var _list: VBoxContainer = null
var _general_card: PanelContainer = null
var _character_slot: Control = null
var _current_character_card: PanelContainer = null
var _minimap: Control = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_list = VBoxContainer.new()
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_list.add_theme_constant_override("separation", entry_gap)
	add_child(_list)
	_list.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_list.position = FALLBACK_POSITION

	# Fester Platz fuer die Charakter-Karte, ausserhalb jeder Container-
	# Sortierlogik (siehe Kopfkommentar) - Groesse wird bei jedem
	# show_character() auf die tatsaechliche Karten-Groesse nachgezogen.
	_character_slot = Control.new()
	_character_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_slot.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	_list.add_child(_character_slot)

	if SettingsManager != null and SettingsManager.has_signal("minimap_setting_changed"):
		if not SettingsManager.minimap_setting_changed.is_connected(_update_dock):
			SettingsManager.minimap_setting_changed.connect(_update_dock)
	get_viewport().size_changed.connect(_update_dock)

	# Ein Frame warten: die Minimap baut ihr Raum-Overlay/ihren Rahmen noch
	# in ihrer eigenen _ready() fertig - wer vorher misst, dockt an die noch
	# unfertige Groesse an (identisches Muster wie run_timer.gd).
	_update_dock.call_deferred()


## Setzt die Y-Position direkt unter die Minimap. Idempotent.
func _update_dock() -> void:
	if _minimap == null or not is_instance_valid(_minimap):
		var found: Array[Node] = get_tree().get_nodes_in_group(MINIMAP_GROUP)
		if found.is_empty():
			_list.position = FALLBACK_POSITION
			return
		_minimap = found[0] as Control

	if _minimap == null or not _minimap.has_method("get_docking_rect"):
		_list.position = FALLBACK_POSITION
		return

	if not _minimap.visible:
		_list.position = FALLBACK_POSITION
		return

	var rect: Rect2 = _minimap.get_docking_rect()
	_list.position = Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)


func _process(_delta: float) -> void:
	# Guenstiger Abgleich, deckt die getweente Groessenaenderung beim
	# Oeffnen/Schliessen der Grosskarte ab, die kein eigenes Signal hat -
	# identisches Muster wie run_timer.gd::_process().
	if _minimap == null or not is_instance_valid(_minimap) or _list == null:
		return
	if not _minimap.visible:
		return
	var rect: Rect2 = _minimap.get_docking_rect()
	var wanted := Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)
	if not _list.position.is_equal_approx(wanted):
		_list.position = wanted


## Baut die fixierte "Allgemeine Mechaniken"-Karte (Dash/Bomben) - EINMALIG,
## wird danach nie wieder veraendert oder ausgetauscht.
func set_general_entry(title: String, description_lines: Array[String]) -> void:
	if _general_card != null and is_instance_valid(_general_card):
		_general_card.queue_free()
	_general_card = _build_card(title, description_lines)
	_list.add_child(_general_card)
	# VOR den Charakter-Slot einsortieren, damit "Allgemein" immer oben
	# steht, egal in welcher Reihenfolge die beiden Methoden aufgerufen
	# werden.
	_list.move_child(_general_card, 0)


## Tauscht die Charakter-Karte im festen Slot aus: die alte faded komplett
## weg, danach slided die neue aus slide_in_offset an ihre Position -
## siehe Kopfkommentar, wieso das ueber manuelle Tweens statt Container-
## Layout laeuft.
func show_character(title: String, description_lines: Array[String]) -> void:
	if _character_slot == null:
		return

	var old_card: PanelContainer = _current_character_card
	_current_character_card = null

	if old_card != null and is_instance_valid(old_card):
		old_card.queue_free()

	_slide_in_character_card(title, description_lines)


func _slide_in_character_card(title: String, description_lines: Array[String]) -> void:
	if _character_slot == null or not is_instance_valid(_character_slot):
		return

	var card: PanelContainer = _build_card(title, description_lines)
	_character_slot.add_child(card)
	card.position = slide_in_offset
	_current_character_card = card

	# Ein Frame warten, bis die Labels ihre Autowrap-Hoehe kennen - erst
	# dann hat "card" seine tatsaechliche Groesse, an die der Slot (fuer die
	# Hoehe innerhalb der aeusseren _list) angeglichen wird.
	await get_tree().process_frame
	if not is_instance_valid(card) or not is_instance_valid(_character_slot):
		return
	_character_slot.custom_minimum_size = card.size

	var slide_tween: Tween = create_tween()
	slide_tween.tween_property(card, "position", Vector2.ZERO, slide_in_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _build_card(title: String, description_lines: Array[String]) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", style)

	var entry := VBoxContainer.new()
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.add_theme_constant_override("separation", 4)
	card.add_child(entry)

	var name_label := Label.new()
	name_label.text = title
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", NAME_COLOR)
	entry.add_child(name_label)

	for line: String in description_lines:
		var desc_label := Label.new()
		desc_label.text = line
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", DESC_COLOR)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.custom_minimum_size = Vector2(MAX_WIDTH - 32.0, 0.0)
		entry.add_child(desc_label)

	return card
