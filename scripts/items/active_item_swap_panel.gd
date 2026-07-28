extends VBoxContainer
class_name ActiveItemSwapPanel

# ============================================================================
# ActiveItemSwapPanel — zeigt die beiden aktiven Item-Slots (Q/E) im
# Pause-Screen nebeneinander mit einem Tausch-Button dazwischen.
# ============================================================================
#
# PHASE 5: seit item_manager.gd zwei unabhaengige aktive Slots kennt
# (Q = Slot 0, E = Slot 1), kann ein drittes gefundenes aktives Item nicht
# mehr automatisch ausgeruestet werden. Die einzige Moeglichkeit, die
# Zuordnung zu aendern, ist es, die BEIDEN GERADE AUSGERUESTETEN Items zu
# tauschen — z.B. weil man lieber das staerkere auf die bequemere Taste legen
# will. Bewusst KEIN voller Item-Picker: das war explizit nicht gewuenscht,
# und ein Picker fuer maximal zwei Elemente waere Overkill (siehe
# item_manager.gd fuer die Design-Entscheidung im Detail).
#
# WARUM EIN EIGENES SCRIPT UND NICHT INLINE IN pause_menu.gd:
# Gleiches Muster wie ItemSummaryList: pause_menu.gd baut nur den Rahmen
# (Buttons, Blur, Escape-Handling) und haengt sich fertige Bausteine in den
# Baum. Ein Baustein pro Datei bedeutet, dass ein Fehler in der Slot-
# Anzeige nicht das ganze Pause-Menu-Script durchsuchen laesst.
#
# WARUM KEIN MOUSE_FILTER_IGNORE:
# Der Tausch-Button muss klickbar sein. Dieser Node und seine Kinder bis zum
# Button brauchen deshalb den Standard-Mausfilter (PASS/STOP), nicht IGNORE
# wie die meisten anderen HUD-Bausteine in diesem Projekt — siehe
# item_summary_list.gd fuer denselben Hinweis an gleicher Stelle.

const BG_COLOR: Color = Color(0.05, 0.06, 0.075, 0.55)
const MUTED_COLOR: Color = Color(0.62, 0.66, 0.72)
const TEXT_COLOR: Color = Color(0.90, 0.90, 0.93)
const ACCENT_COLOR: Color = Color(0.45, 0.85, 0.95)
const KEY_LABELS: Array[String] = ["Q", "E"]

var _title: Label = null
var _slot_panels: Array[PanelContainer] = []
var _slot_name_labels: Array[Label] = []
var _slot_status_labels: Array[Label] = []
var _swap_button: Button = null

## BEWUSST get_node_or_null("/root/Items") statt des globalen "Items"-
## Bezeichners - siehe combat_base.gd fuer die ausfuehrliche Begruendung
## (Root Cause fuer "Invalid access ... on a base object of type Nil").
## Das ist im GANZEN restlichen Projekt so gehandhabt.
var _items_cache: Node = null

func _items() -> Node:
	if _items_cache == null or not is_instance_valid(_items_cache):
		_items_cache = get_node_or_null("/root/Items")
	return _items_cache


## Gleiches Fabrik-Muster wie ItemSummaryList.create() - der Aufrufer muss
## den Node nur noch in den Baum haengen.
static func create() -> ActiveItemSwapPanel:
	var panel := ActiveItemSwapPanel.new()
	return panel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_theme_constant_override("separation", 4)

	_title = Label.new()
	_title.text = "AKTIVE ITEMS"
	_title.add_theme_font_size_override("font_size", 12)
	_title.add_theme_color_override("font_color", MUTED_COLOR)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_theme_constant_override("separation", 8)
	add_child(row)

	row.add_child(_build_slot_panel(0))

	_swap_button = Button.new()
	_swap_button.text = "\u21c4"  # Tausch-Pfeile, braucht keine eigene Textur.
	_swap_button.custom_minimum_size = Vector2(32.0, 32.0)
	_swap_button.tooltip_text = "Q und E tauschen"
	_swap_button.pressed.connect(_on_swap_pressed)
	row.add_child(_swap_button)

	row.add_child(_build_slot_panel(1))

	if _items():
		_items().active_slots_changed.connect(_refresh)
		_items().active_item_charge_changed.connect(_on_charge_changed)
	_refresh()


func _build_slot_panel(slot: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(150.0, 0.0)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS

	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = Color(ACCENT_COLOR.r, ACCENT_COLOR.g, ACCENT_COLOR.b, 0.5)
	style.set_border_width_all(1)
	style.border_width_left = 3
	style.set_corner_radius_all(2)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", style)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 2)
	panel.add_child(column)

	var key_row := HBoxContainer.new()
	key_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(key_row)

	var key := Label.new()
	key.text = "[%s]" % KEY_LABELS[slot]
	key.add_theme_font_size_override("font_size", 10)
	key.add_theme_color_override("font_color", ACCENT_COLOR)
	key_row.add_child(key)

	var name_label := Label.new()
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	name_label.clip_text = true
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_row.add_child(name_label)

	var status_label := Label.new()
	status_label.add_theme_font_size_override("font_size", 10)
	status_label.add_theme_color_override("font_color", MUTED_COLOR)
	column.add_child(status_label)

	_slot_panels.append(panel)
	_slot_name_labels.append(name_label)
	_slot_status_labels.append(status_label)
	return panel


func _on_swap_pressed() -> void:
	if _items():
		_items().swap_active_slots()


## slot-Parameter wird ignoriert: bei einer Ladungsaenderung reicht es,
## einfach beide Anzeigen neu zu ziehen, das ist billig genug (zwei Slots).
func _on_charge_changed(_slot: int, _current: int, _needed: int) -> void:
	_refresh()


func _refresh() -> void:
	var items: Node = _items()
	if items == null or _slot_panels.size() < items.ACTIVE_SLOT_COUNT:
		return

	var equipped_count: int = 0
	for slot: int in range(items.ACTIVE_SLOT_COUNT):
		var item: ItemData = items.active_items[slot]
		if item != null:
			equipped_count += 1

		if item == null:
			_slot_name_labels[slot].text = "\u2014 leer \u2014"
			_slot_name_labels[slot].add_theme_color_override("font_color", MUTED_COLOR)
			_slot_status_labels[slot].text = ""
			continue

		_slot_name_labels[slot].text = item.display_name
		_slot_name_labels[slot].add_theme_color_override("font_color", TEXT_COLOR)

		if items.is_active_slot_ready(slot):
			_slot_status_labels[slot].text = "bereit"
		else:
			var remaining: int = int(items.get_active_charge_remaining(slot))
			_slot_status_labels[slot].text = "noch %d/%d Raeume" % [remaining, item.charge_rooms]

	# Tauschen mit nur einem oder keinem belegten Slot ist erlaubt (siehe
	# ready-Kommentar im Kopf: man will z.B. das einzige aktive Item gezielt
	# auf E statt Q legen), aber bei ZWEI leeren Slots gibt's schlicht
	# nichts zu tauschen.
	_swap_button.disabled = equipped_count == 0
	visible = true
