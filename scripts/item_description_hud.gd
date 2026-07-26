extends VBoxContainer
class_name ItemDescriptionHud

# ============================================================================
# ItemDescriptionHud — unten links: Liste der gesammelten Items plus eine
# ausfuehrliche Karte, sobald etwas Neues aufgenommen wurde.
# ============================================================================
# ZWEI EBENEN, WEIL ZWEI BEDUERFNISSE:
#   * Beim Aufsammeln will man WISSEN, was das Ding tut -> grosse Karte mit
#     Name, Flavour und Mechanik, blendet nach ein paar Sekunden aus.
#   * Waehrend des Laufens will man nur SEHEN, was man hat -> kompakte
#     Dauerliste darunter.
# Eine einzige Anzeige haette entweder staendig den halben Bildschirm belegt
# oder die Mechanik nie gezeigt.

const HUD_ELEMENT: String = "items"

## Wie lange die Detailkarte nach dem Aufsammeln stehen bleibt.
@export var card_display_time: float = 6.0
@export var card_fade_time: float = 0.6

var _card: PanelContainer = null
var _card_name: Label = null
var _card_flavor: Label = null
var _card_description: Label = null
var _card_charge: Label = null

var _list: VBoxContainer = null
var _items: Node = null
var _card_tween: Tween = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 6)

	_build_card()
	_build_list()

	_items = get_node_or_null("/root/Items")
	if _items:
		_items.item_added.connect(_on_item_added)
		_items.inventory_changed.connect(_refresh_list)
		_items.active_item_charge_changed.connect(_on_charge_changed)
		_refresh_list()

	SettingsManager.hud_visible_changed.connect(_on_visibility_setting_changed)
	SettingsManager.hud_element_visible_changed.connect(_on_element_setting_changed)
	_apply_visibility()


# ============================================================================
# Aufbau
# ============================================================================
func _build_card() -> void:
	_card = PanelContainer.new()
	_card.custom_minimum_size = Vector2(340.0, 0.0)
	_card.modulate.a = 0.0
	_card.visible = false

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.07, 0.09, 0.88)
	style.border_color = Color(0.98, 0.80, 0.22, 0.85)
	style.set_border_width_all(1)
	style.border_width_left = 3
	style.set_corner_radius_all(3)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 9.0
	style.content_margin_bottom = 9.0
	_card.add_theme_stylebox_override("panel", style)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	_card.add_child(column)

	_card_name = Label.new()
	_card_name.add_theme_font_size_override("font_size", 15)
	_card_name.add_theme_color_override("font_color", Color(0.98, 0.94, 0.80))
	column.add_child(_card_name)

	_card_flavor = Label.new()
	_card_flavor.add_theme_font_size_override("font_size", 11)
	_card_flavor.add_theme_color_override("font_color", Color(0.62, 0.66, 0.72))
	_card_flavor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_card_flavor)

	_card_description = Label.new()
	_card_description.add_theme_font_size_override("font_size", 12)
	_card_description.add_theme_color_override("font_color", Color(0.88, 0.88, 0.90))
	_card_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_card_description)

	_card_charge = Label.new()
	_card_charge.add_theme_font_size_override("font_size", 11)
	_card_charge.add_theme_color_override("font_color", Color(0.45, 0.85, 0.95))
	_card_charge.visible = false
	column.add_child(_card_charge)

	add_child(_card)


func _build_list() -> void:
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 1)
	add_child(_list)


# ============================================================================
# Detailkarte
# ============================================================================
func _on_item_added(item: ItemData) -> void:
	show_item(item)


## Auch von aussen aufrufbar — z.B. wenn der Spieler an einem Sockel steht
## und das Item noch nicht genommen hat (Vorschau).
func show_item(item: ItemData) -> void:
	if item == null or _card == null:
		return

	_card_name.text = item.display_name
	_card_flavor.text = "\u201c%s\u201d" % item.flavor_text if item.flavor_text != "" else ""
	_card_flavor.visible = item.flavor_text != ""
	_card_description.text = item.description

	if item.is_active_item():
		_card_charge.visible = true
		_card_charge.text = "Aktiv \u2014 [C] \u00b7 laedt ueber %d Raeume" % item.charge_rooms
	else:
		_card_charge.visible = false

	if _card_tween and _card_tween.is_valid():
		_card_tween.kill()

	_card.visible = true
	_card.modulate.a = 1.0

	_card_tween = create_tween()
	_card_tween.tween_interval(card_display_time)
	_card_tween.tween_property(_card, "modulate:a", 0.0, card_fade_time)
	_card_tween.tween_callback(func() -> void: _card.visible = false)


func _on_charge_changed(current: int, needed: int) -> void:
	if _card == null or not _card.visible or not _card_charge.visible:
		return
	if current <= 0:
		_card_charge.text = "Aktiv \u2014 [C] \u00b7 BEREIT"
	else:
		_card_charge.text = "Aktiv \u2014 [C] \u00b7 noch %d/%d Raeume" % [current, needed]


# ============================================================================
# Dauerliste
# ============================================================================
func _refresh_list() -> void:
	if _list == null or _items == null:
		return

	for child: Node in _list.get_children():
		child.queue_free()

	# Gleiche Items zusammenfassen statt untereinander zu stapeln — mit drei
	# Exemplaren desselben Items waere die Liste sonst schnell laenger als
	# der Bildschirm.
	var counts: Dictionary = {}
	var order: Array[ItemData] = []
	for item: ItemData in _items.inventory:
		if counts.has(item.id):
			counts[item.id] = int(counts[item.id]) + 1
		else:
			counts[item.id] = 1
			order.append(item)

	for item: ItemData in order:
		var count: int = int(counts[item.id])
		var label := Label.new()
		label.text = item.display_name if count <= 1 else "%s  x%d" % [item.display_name, count]
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", Color(0.70, 0.72, 0.76))
		_list.add_child(label)


# ============================================================================
# Sichtbarkeit
# ============================================================================
func _on_visibility_setting_changed(_visible: bool) -> void:
	_apply_visibility()


func _on_element_setting_changed(_element: String, _is_visible: bool) -> void:
	_apply_visibility()


func _apply_visibility() -> void:
	visible = SettingsManager.hud_visible and SettingsManager.is_hud_element_visible(HUD_ELEMENT)
