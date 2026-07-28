extends VBoxContainer
class_name ItemDescriptionHud

# ============================================================================
# ItemDescriptionHud — Chip-Leiste unten links + freischwebende Item-Karte.
# ============================================================================
# Sitzt als Node IN hud.tscn (BottomLeft/ItemBar) und ist damit Teil des
# normalen HUD — kein eigener CanvasLayer, kein Autoload mehr.
#
# ZWEI EBENEN, WEIL ZWEI BEDUERFNISSE:
#   * Am Sockel will man WISSEN, was das Ding tut -> grosse Karte mittig auf
#     dem Bildschirm, im freien Feld, gut lesbar.
#   * Waehrend des Laufens will man nur SEHEN, was man hat -> kompakte
#     Chip-Leiste unten links.
#
# ---------------------------------------------------------------------------
# WARUM DIE KARTE NICHT MEHR UNTEN LINKS HAENGT
# ---------------------------------------------------------------------------
# Unten links stand sie im selben Block wie die Chips und das Stats-Panel und
# musste sich den Platz mit ihnen teilen — deshalb war sie schmal, deshalb
# schob sie beim Einblenden alles darunter nach oben, und deshalb las man sie
# beilaeufig statt bewusst.
#
# Jetzt haengt sie als eigenes Kind am HUD-Wurzelknoten, mittig verankert und
# leicht unterhalb der Bildmitte. Dort ist der einzige wirklich freie Bereich:
# darueber sitzt die Combo-Anzeige, rechts die Party- und Faehigkeitsleiste,
# links unten Chips und Stats. Sie verdeckt damit nichts und ist trotzdem da,
# wo der Blick beim Stehenbleiben ohnehin ist.
#
# WARUM SIE AM HUD-WURZELKNOTEN HAENGT UND NICHT AN DIESEM NODE:
# Dieser Node steht in einem VBoxContainer unten links. Ein Container
# ueberschreibt Position UND Groesse seiner Kinder bei jedem Layout-Durchlauf.
# Eine mittig verankerte Karte darin waere nach dem naechsten Frame wieder
# unten links — und zwar ohne Fehlermeldung.
#
# ---------------------------------------------------------------------------
# SICHTBARKEITS-REGEL DER KARTE
# ---------------------------------------------------------------------------
#   * Sockel in Reichweite  -> Karte an, DAUERHAFT, bis man weggeht.
#   * Sockel verlassen      -> Karte sofort weg (hide_item()).
#   * Item aufgesammelt     -> Karte an, blendet nach card_display_time aus.
#   * Chip in der Leiste gehovert -> Karte an, DAUERHAFT, bis die Maus weg ist.
# Vorher blieb die Karte nach jedem Trigger feste sechs Sekunden stehen — man
# lief also mit der Beschreibung eines Items durch die Gegend, das drei Raeume
# hinter einem lag.
#
# ---------------------------------------------------------------------------
# PHASE 2 (HUD-Ueberarbeitung):
# ---------------------------------------------------------------------------
#  1. UNTEN MITTIG statt unten links: dieser Node haengt jetzt selbst direkt
#     unter dem HUD-Wurzelknoten (mittig verankert, siehe hud.tscn), nicht
#     mehr in BottomLeft neben dem Stats-Panel. Chip-Leiste und Aktiv-Slot
#     bekommen dafuer SIZE_SHRINK_CENTER statt SIZE_SHRINK_BEGIN — sonst
#     waeren sie zwar in einer mittig verankerten Box, aber innerhalb dieser
#     Box weiterhin linksbuendig, also optisch NICHT mittig.
#
#  2. ECHTES HOVER-POPUP AUF DEN CHIPS: die Chips hatten mouse_filter =
#     IGNORE und reagierten damit ueberhaupt nicht auf die Maus — "Popup bei
#     Hover" existierte schlicht nicht. Jetzt bekommt jeder Chip
#     MOUSE_FILTER_STOP und zeigt beim Hovern dieselbe Karte an, die auch am
#     Sockel erscheint (persistent, bis die Maus wieder verlaesst).
#
#  3. FIX GEGEN DIE "MANCHMAL KAPUTTE" KARTE: _refresh_list() reisst bei
#     jeder Inventar-Aenderung ALLE Chips ab und baut sie neu. Passierte das
#     waehrend man genau einen Chip hoverte (z.B. neues Item waehrend man auf
#     der Leiste steht), wurde der gehoverte Chip mitsamt seinem Node
#     geloescht, OHNE dass zuverlaessig ein mouse_exited-Signal ankam — die
#     Karte blieb dann mit veraltetem Inhalt stehen, oder ein exited-Signal
#     kam verzoegert rein, WAEHREND schon ein neues Item eine zweite Karte
#     ausloeste. Zwei Trigger kurz hintereinander auf demselben Control ohne
#     garantierte Reihenfolge = genau das Bild, das als "komisches Format"
#     beschrieben wurde. Fix: _refresh_list() merkt sich die ID des aktuell
#     gehoverten Items VOR dem Rebuild, schliesst die Karte sauber, und
#     oeffnet sie danach neu, falls der gleiche Chip (an derselben Stelle)
#     weiterhin existiert.

const HUD_ELEMENT: String = "items"

## Wie lange die Karte nach dem AUFSAMMELN stehen bleibt. Fuer die Anzeige am
## Sockel gilt sie nicht — die haengt allein an der Entfernung.
@export var card_display_time: float = 5.0
@export var card_fade_time: float = 0.45

## Breite der Chip-Leiste, bevor sie umbricht. War vorher an die Breite des
## Stats-Panels gekoppelt (210) — seit die Leiste unten MITTIG statt in der
## linken Spalte haengt, ist das nicht mehr sinnvoll. Als eigener Wert
## bestimmt er jetzt, wie breit die zentrierte Leiste maximal wird, bevor
## Chips in eine zweite Zeile umbrechen.
@export var chip_row_width: float = 460.0

## Groesse und Lage der Karte. offset_y wird von der Bildmitte aus gemessen;
## positiv = nach unten.
@export var card_width: float = 420.0
@export var card_offset_y: float = 70.0

const CHIP_SIZE: float = 26.0
const BG_COLOR: Color = Color(0.045, 0.052, 0.065, 0.94)
const MUTED_COLOR: Color = Color(0.62, 0.66, 0.72)
const TEXT_COLOR: Color = Color(0.91, 0.91, 0.94)

var _card: PanelContainer = null
var _card_style: StyleBoxFlat = null
var _card_icon: Panel = null
var _card_icon_label: Label = null
var _card_name: Label = null
var _card_tag: Label = null
var _card_tag_panel: PanelContainer = null
var _card_flavor: Label = null
var _card_description: Label = null
var _card_charge: Label = null
var _card_hint: Label = null

## PHASE 5: aus dem EINEN aktiven Item-Slot sind zwei geworden (Q und E,
## siehe item_manager.gd). Statt drei Einzelvariablen zu verdoppeln (was
## garantiert dazu fuehrt, dass irgendwann eine Stelle nur fuer Slot 0
## aktualisiert wird), sind es jetzt Arrays der Groesse ACTIVE_SLOT_COUNT,
## Index == Slot-Index.
var _active_slot_panels: Array[PanelContainer] = []
var _active_slot_names: Array[Label] = []
var _active_slot_pips: Array[HBoxContainer] = []

var _chip_row: HFlowContainer = null
var _items: Node = null
var _card_tween: Tween = null
## true = Karte haengt an einer Entfernung (Sockel) und blendet NICHT selbst aus.
var _card_persistent: bool = false

## Welches Item die Detailkarte gerade zeigt. Noetig, damit
## _on_charge_changed() weiss, ob eine Ladungsaenderung ueberhaupt die
## GERADE SICHTBARE Karte betrifft.
var _shown_item: ItemData = null

## ID des Items, dessen Chip GERADE gehovert wird ("" = keins). Wird von
## _refresh_list() genutzt, um die Karte beim Chip-Rebuild sauber zu
## schliessen/neu zu oeffnen statt sie in einem undefinierten Zustand
## haengen zu lassen — siehe PHASE-2-Kommentar #3 im Dateikopf.
var _hovered_item_id: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 6)
	# TreasurePedestal findet das HUD ueber diese Gruppe. Ein fester
	# Knotenpfad waere bei der ersten Umbenennung in hud.tscn stillschweigend
	# kaputtgegangen.
	add_to_group("item_hud")

	# WICHTIG: _items MUSS vor _build_active_slot() gesetzt sein - die
	# Funktion liest _items.ACTIVE_SLOT_COUNT, um die Anzahl der Slot-Panels
	# zu bauen. Vorher stand diese Zeile weiter unten, NACH den _build_*-
	# Aufrufen - _items war zu dem Zeitpunkt noch der Default-Wert null,
	# was zu "Invalid access to property or key 'ACTIVE_SLOT_COUNT' on a
	# base object of type 'Nil'" fuehrte. Root Cause war also nicht (nur)
	# der bare "Items"-Bezeichner aus der letzten Runde, sondern zusaetzlich
	# diese Reihenfolge hier in _ready() selbst.
	_items = get_node_or_null("/root/Items")

	_build_active_slot()
	_build_chip_row()
	# Die Karte wird erst gebaut, wenn der Baum steht — sie braucht den
	# HUD-Wurzelknoten als Elternteil.
	_build_card.call_deferred()

	if _items:
		_items.item_added.connect(_on_item_added)
		_items.inventory_changed.connect(_refresh_list)
		_items.active_item_charge_changed.connect(_on_charge_changed)
		_items.active_slots_changed.connect(_refresh_active_slot)
		_refresh_list()

	SettingsManager.hud_visible_changed.connect(_on_visibility_setting_changed)
	SettingsManager.hud_element_visible_changed.connect(_on_element_setting_changed)
	_apply_visibility()


func _exit_tree() -> void:
	# Die Karte ist KEIN Kind dieses Nodes — sie wuerde beim Szenenwechsel
	# sonst als Waise stehenbleiben.
	if _card and is_instance_valid(_card):
		_card.queue_free()
	_card = null


## Oberster Control-Vorfahr = der HUD-Wurzelknoten aus hud.tscn. Dort haengt
## die Karte, weil er den ganzen Bildschirm aufspannt und kein Container ist.
func _find_card_host() -> Control:
	var host: Control = self
	var node: Node = get_parent()
	while node is Control:
		host = node as Control
		node = node.get_parent()
	return host


# ============================================================================
# Detailkarte
# ============================================================================
func _build_card() -> void:
	if _card != null and is_instance_valid(_card):
		return

	_card = PanelContainer.new()
	_card.name = "ItemInfoCard"
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.visible = false
	_card.modulate.a = 0.0

	# Mittig verankert, um card_offset_y nach unten versetzt. Die Hoehe
	# bleibt offen (offset_bottom = offset_top), PanelContainer waechst mit
	# dem Inhalt.
	_card.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_card.anchor_left = 0.5
	_card.anchor_right = 0.5
	_card.anchor_top = 0.5
	_card.anchor_bottom = 0.5
	_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_card.grow_vertical = Control.GROW_DIRECTION_END
	_card.offset_left = -card_width * 0.5
	_card.offset_right = card_width * 0.5
	_card.offset_top = card_offset_y
	_card.offset_bottom = card_offset_y
	_card.pivot_offset = Vector2(card_width * 0.5, 0.0)

	_card_style = StyleBoxFlat.new()
	_card_style.bg_color = BG_COLOR
	_card_style.border_color = Color(0.98, 0.80, 0.22, 0.85)
	_card_style.set_border_width_all(1)
	# Der breite Streifen links wird pro Item in die Item-Farbe gesetzt.
	_card_style.border_width_left = 4
	_card_style.set_corner_radius_all(2)
	_card_style.content_margin_left = 14.0
	_card_style.content_margin_right = 16.0
	_card_style.content_margin_top = 12.0
	_card_style.content_margin_bottom = 12.0
	# Schlagschatten: die Karte schwebt jetzt ueber der Spielwelt statt in
	# einer Bildschirmecke zu kleben und braucht eine Kante gegen unruhige
	# Hintergruende.
	_card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	_card_style.shadow_size = 8
	_card.add_theme_stylebox_override("panel", _card_style)

	var outer := HBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	_card.add_child(outer)

	# --- Farbfeld links: dasselbe Kuerzel wie auf dem Chip -------------
	_card_icon = Panel.new()
	_card_icon.custom_minimum_size = Vector2(48.0, 48.0)
	_card_icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_card_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(_card_icon)

	_card_icon_label = Label.new()
	_card_icon_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_card_icon_label.add_theme_font_size_override("font_size", 18)
	_card_icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_icon.add_child(_card_icon_label)

	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 3)
	outer.add_child(column)

	# --- Kopfzeile: Name + Kategorie-Tag -------------------------------
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	column.add_child(title_row)

	_card_name = Label.new()
	_card_name.add_theme_font_size_override("font_size", 18)
	_card_name.add_theme_color_override("font_color", Color(0.98, 0.95, 0.84))
	title_row.add_child(_card_name)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(spacer)

	_card_tag_panel = PanelContainer.new()
	_card_tag_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_row.add_child(_card_tag_panel)

	_card_tag = Label.new()
	_card_tag.add_theme_font_size_override("font_size", 10)
	_card_tag_panel.add_child(_card_tag)

	_card_flavor = Label.new()
	_card_flavor.add_theme_font_size_override("font_size", 12)
	_card_flavor.add_theme_color_override("font_color", MUTED_COLOR)
	_card_flavor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_card_flavor)

	_card_description = Label.new()
	_card_description.add_theme_font_size_override("font_size", 14)
	_card_description.add_theme_color_override("font_color", TEXT_COLOR)
	_card_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_card_description)

	_card_charge = Label.new()
	_card_charge.add_theme_font_size_override("font_size", 12)
	_card_charge.add_theme_color_override("font_color", Color(0.45, 0.85, 0.95))
	_card_charge.visible = false
	column.add_child(_card_charge)

	_card_hint = Label.new()
	_card_hint.add_theme_font_size_override("font_size", 12)
	_card_hint.add_theme_color_override("font_color", Color(0.98, 0.80, 0.22))
	_card_hint.visible = false
	column.add_child(_card_hint)

	_find_card_host().add_child(_card)


func _on_item_added(item: ItemData) -> void:
	show_item(item)


## persistent = true: die Karte bleibt stehen, bis hide_item() kommt. Genau
## das benutzt TreasurePedestal, solange der Spieler in Reichweite ist.
## persistent = false: die Karte blendet nach card_display_time aus — der
## Fall "gerade eingesammelt".
func show_item(item: ItemData, persistent: bool = false) -> void:
	if item == null:
		return
	if _card == null or not is_instance_valid(_card):
		_build_card()
	if _card == null:
		return

	_shown_item = item
	var color: Color = item.pedestal_color

	_card_style.border_color = Color(color.r, color.g, color.b, 0.85)
	_apply_icon_style(_card_icon, color)
	_card_icon_label.text = _initials(item.display_name)
	_card_icon_label.add_theme_color_override("font_color", color)

	_card_name.text = item.display_name
	_card_flavor.text = "\u201c%s\u201d" % item.flavor_text if item.flavor_text != "" else ""
	_card_flavor.visible = item.flavor_text != ""
	_card_description.text = item.description

	_apply_tag(item)

	if item.is_active_item():
		_card_charge.visible = true
		_card_charge.text = _format_active_status(item)
	else:
		_card_charge.visible = false

	# Der Aufnehmen-Hinweis steht NUR am Sockel. Nach dem Einsammeln waere er
	# eine Aufforderung zu etwas, das man gerade getan hat.
	_card_hint.visible = persistent
	if persistent:
		_card_hint.text = "[F] Nehmen"

	_card_persistent = persistent
	_play_card_intro()


## Blendet die Karte aus. TreasurePedestal ruft das auf, sobald der Spieler
## die Reichweite verlaesst.
func hide_item() -> void:
	if _card == null or not is_instance_valid(_card) or not _card.visible:
		return
	if _card_tween and _card_tween.is_valid():
		_card_tween.kill()

	_card_persistent = false
	_card_tween = create_tween()
	_card_tween.tween_property(_card, "modulate:a", 0.0, card_fade_time * 0.6)
	_card_tween.tween_callback(func() -> void:
		if is_instance_valid(_card):
			_card.visible = false
	)


## Kategorie-Chip rechts oben. Passiv und Aktiv unterscheiden sich zusaetzlich
## in der Farbe, weil das die einzige Eigenschaft ist, die die BEDIENUNG
## veraendert — alles andere ist Geschmack.
func _apply_tag(item: ItemData) -> void:
	var is_active: bool = item.is_active_item()
	var tag_color: Color = Color(0.45, 0.85, 0.95) if is_active else Color(0.62, 0.68, 0.76)

	_card_tag.text = ("AKTIV \u00b7 " + item.get_category_name().to_upper()) if is_active \
		else item.get_category_name().to_upper()
	_card_tag.add_theme_color_override("font_color", tag_color)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(tag_color.r, tag_color.g, tag_color.b, 0.14)
	style.border_color = Color(tag_color.r, tag_color.g, tag_color.b, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	_card_tag_panel.add_theme_stylebox_override("panel", style)


## Aufklappen statt hartem Einblenden. scale wird benutzt und nicht position:
## die Karte haengt zwar an einem freien Control, aber scale laesst den
## Anker-Mittelpunkt in Ruhe — eine Positionsanimation muesste die Anker
## nachrechnen.
func _play_card_intro() -> void:
	if _card_tween and _card_tween.is_valid():
		_card_tween.kill()

	_card.visible = true
	_card.modulate.a = 1.0
	_card.scale = Vector2(0.97, 0.97)

	_card_tween = create_tween()
	_card_tween.tween_property(_card, "scale", Vector2.ONE, 0.14) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if _card_persistent:
		return

	_card_tween.tween_interval(card_display_time)
	_card_tween.tween_property(_card, "modulate:a", 0.0, card_fade_time)
	_card_tween.tween_callback(func() -> void:
		if is_instance_valid(_card):
			_card.visible = false
	)


## PHASE 5: neue Signalsignatur (slot, current, needed) - vorher gab es nur
## EIN aktives Item, jetzt muss geprueft werden, ob der gemeldete Slot
## ueberhaupt zu dem Item gehoert, das die Karte gerade zeigt (falls der
## Spieler z.B. gerade das Item in E anschaut, waehrend Q einen Raum
## abschliesst).
func _on_charge_changed(slot: int, _current: int, _needed: int) -> void:
	_refresh_active_slot()

	if _card == null or not is_instance_valid(_card):
		return
	if not _card.visible or not _card_charge.visible:
		return
	if _shown_item == null or _items.active_items[slot] != _shown_item:
		return
	_card_charge.text = _format_active_status(_shown_item)


## Baut die Statuszeile fuer die Detailkarte: welcher Slot (Q/E/keiner) und
## wie weit geladen. Ein einzelner Ort dafuer, weil sowohl show_item() als
## auch _on_charge_changed() denselben Text brauchen.
func _format_active_status(item: ItemData) -> String:
	var slot: int = _slot_of(item)
	if slot < 0:
		return "Aktiv \u2014 nicht ausgeruestet (Q/E bereits belegt)"

	var key: String = ACTIVE_KEY_LABELS[slot]
	if _items.is_active_slot_ready(slot):
		return "Aktiv \u2014 [%s] \u00b7 BEREIT" % key

	var remaining: int = int(_items.get_active_charge_remaining(slot))
	return "Aktiv \u2014 [%s] \u00b7 noch %d/%d Raeume" % [key, remaining, item.charge_rooms]


## -1, falls das Item aktuell in keinem Slot steckt (dritter+ aktiver Fund,
## siehe Kopfkommentar in item_manager.gd), oder falls _items aus
## irgendeinem Grund gar nicht existiert.
func _slot_of(item: ItemData) -> int:
	if _items == null:
		return -1
	for slot: int in range(_items.ACTIVE_SLOT_COUNT):
		if _items.active_items[slot] == item:
			return slot
	return -1


# ============================================================================
# Slots fuer die aktiven Items (PHASE 5: Q und E statt nur ein Slot mit [C])
# ============================================================================
const ACTIVE_KEY_LABELS: Array[String] = ["Q", "E"]

## Container, der die beiden Slot-Panels nebeneinander haelt. Eigenes Kind
## dieses VBoxContainers, damit die Slots als EINE Einheit ueber der
## Chip-Leiste sitzen, nicht als zwei unabhaengig zentrierte Elemente.
var _active_slots_row: HBoxContainer = null


func _build_active_slot() -> void:
	_active_slots_row = HBoxContainer.new()
	_active_slots_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_active_slots_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_active_slots_row.add_theme_constant_override("separation", 6)
	add_child(_active_slots_row)

	_active_slot_panels.clear()
	_active_slot_names.clear()
	_active_slot_pips.clear()

	# Falls das Items-Autoload aus irgendeinem Grund fehlt, lieber gar
	# keine Slot-Panels bauen als abzustuerzen - _refresh_active_slot()
	# hat ohnehin denselben Guard und wuerde dann einfach nichts tun.
	if _items == null:
		return

	for slot: int in range(_items.ACTIVE_SLOT_COUNT):
		_active_slots_row.add_child(_build_one_active_panel(slot))


func _build_one_active_panel(slot: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = Color(0.45, 0.85, 0.95, 0.6)
	style.set_border_width_all(1)
	style.border_width_left = 3
	style.set_corner_radius_all(2)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	panel.add_theme_stylebox_override("panel", style)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)

	var key := Label.new()
	key.text = "[%s]" % ACTIVE_KEY_LABELS[slot]
	key.add_theme_font_size_override("font_size", 10)
	key.add_theme_color_override("font_color", Color(0.45, 0.85, 0.95))
	row.add_child(key)

	var name_label := Label.new()
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)

	var pips := HBoxContainer.new()
	pips.add_theme_constant_override("separation", 2)
	row.add_child(pips)

	_active_slot_panels.append(panel)
	_active_slot_names.append(name_label)
	_active_slot_pips.append(pips)
	return panel


## Ladepunkte statt Text: "noch 2 Raeume" muss man lesen, zwei dunkle Punkte
## nicht. Aktualisiert BEIDE Slots - fuer einen einzelnen Slot gezielt
## reicht der schmalere _refresh_one_active_slot() weiter unten.
func _refresh_active_slot() -> void:
	if _items == null or _active_slot_panels.size() < _items.ACTIVE_SLOT_COUNT:
		return
	for slot: int in range(_items.ACTIVE_SLOT_COUNT):
		_refresh_one_active_slot(slot)


func _refresh_one_active_slot(slot: int) -> void:
	var panel: PanelContainer = _active_slot_panels[slot]
	var item: ItemData = _items.active_items[slot]

	if item == null:
		panel.visible = false
		return

	panel.visible = true
	_active_slot_names[slot].text = item.display_name

	var pips: HBoxContainer = _active_slot_pips[slot]
	for child: Node in pips.get_children():
		child.queue_free()

	var needed: int = maxi(item.charge_rooms, 1)
	var remaining: int = int(_items.get_active_charge_remaining(slot))
	var filled: int = clampi(needed - remaining, 0, needed)

	for i: int in range(needed):
		var pip := Panel.new()
		pip.custom_minimum_size = Vector2(7.0, 7.0)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pip_style := StyleBoxFlat.new()
		pip_style.set_corner_radius_all(4)
		pip_style.bg_color = Color(0.45, 0.85, 0.95, 0.95) if i < filled \
			else Color(0.22, 0.25, 0.29, 0.95)
		pip.add_theme_stylebox_override("panel", pip_style)
		pips.add_child(pip)


# ============================================================================
# Chip-Leiste
# ============================================================================
func _build_chip_row() -> void:
	_chip_row = HFlowContainer.new()
	_chip_row.custom_minimum_size = Vector2(chip_row_width, 0.0)
	# SHRINK_CENTER statt SHRINK_BEGIN, gleicher Grund wie beim Aktiv-Slot
	# oben: dieser Node haengt jetzt unten MITTIG am HUD.
	_chip_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_chip_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chip_row.add_theme_constant_override("h_separation", 4)
	_chip_row.add_theme_constant_override("v_separation", 4)
	add_child(_chip_row)


func _refresh_list() -> void:
	_refresh_active_slot()

	if _chip_row == null or _items == null:
		return

	# Race-Fix (siehe PHASE-2-Kommentar #3 im Dateikopf): merken, welches
	# Item GERADE gehovert wird, BEVOR die Chips darunter weggerissen
	# werden. Ohne das haengt die Karte nach einem Rebuild waehrend des
	# Hovers in einem undefinierten Zustand — sie bekommt kein zuverlaessiges
	# mouse_exited von einem Node, der gerade geloescht wird.
	var was_hovering: String = _hovered_item_id
	if was_hovering != "":
		hide_item()
		_hovered_item_id = ""

	for child: Node in _chip_row.get_children():
		child.queue_free()

	# Gleiche Items zusammenfassen statt nebeneinander zu stapeln — mit drei
	# Exemplaren desselben Items waere die Leiste sonst schnell breiter als
	# der halbe Bildschirm.
	var counts: Dictionary = {}
	var order: Array[ItemData] = []
	var rehover_item: ItemData = null
	for item: ItemData in _items.inventory:
		if counts.has(item.id):
			counts[item.id] = int(counts[item.id]) + 1
		else:
			counts[item.id] = 1
			order.append(item)
		if item.id == was_hovering and rehover_item == null:
			rehover_item = item

	for item: ItemData in order:
		_chip_row.add_child(_make_chip(item, int(counts[item.id])))

	# Item, das man gerade hoverte, ist nach dem Rebuild immer noch im
	# Inventar (z.B. ein ZWEITES Item kam dazu, waehrend man auf dem ersten
	# stand) -> Karte sofort wieder zeigen, statt dass sie kurz verschwindet
	# und der Spieler denkt, der Hover sei abgebrochen.
	if rehover_item != null:
		_on_chip_hover(rehover_item)


## Ein Chip: farbiges Quadrat mit Kuerzel, bei mehreren Exemplaren mit
## Zaehler. Die Farbe ist item.pedestal_color — dieselbe, in der das Item
## auf dem Sockel im Schatzraum leuchtete.
##
## NEU: MOUSE_FILTER_STOP statt IGNORE + hover-Signale. Vorher gab es auf
## den Chips ueberhaupt keine Maus-Interaktion — "Popup bei Hover" existierte
## im Code schlicht nicht (siehe PHASE-2-Kommentar #2 im Dateikopf).
func _make_chip(item: ItemData, count: int) -> Control:
	var color: Color = item.pedestal_color

	var chip := Panel.new()
	chip.custom_minimum_size = Vector2(CHIP_SIZE, CHIP_SIZE)
	chip.mouse_filter = Control.MOUSE_FILTER_STOP
	chip.mouse_entered.connect(_on_chip_hover.bind(item))
	chip.mouse_exited.connect(_on_chip_unhover.bind(item.id))
	_apply_icon_style(chip, color)

	var label := Label.new()
	label.text = _initials(item.display_name)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", color)
	# Muss IGNORE bleiben, sonst blockt das Label die Hover-Signale des Chips.
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(label)

	if count > 1:
		var badge := Label.new()
		badge.text = str(count)
		badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		badge.offset_left = -12.0
		badge.offset_top = -12.0
		badge.offset_right = -1.0
		badge.offset_bottom = -1.0
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		badge.add_theme_font_size_override("font_size", 9)
		badge.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.92))
		# Muss IGNORE bleiben, gleicher Grund wie beim Label oben.
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(badge)

	return chip


## Zeigt die Karte persistent an, solange die Maus auf dem Chip steht.
func _on_chip_hover(item: ItemData) -> void:
	_hovered_item_id = item.id
	show_item(item, true)


## Nur ausblenden, wenn die Maus tatsaechlich DIESEN Chip verlassen hat —
## nicht irgendeinen. Ohne den ID-Abgleich koennte ein spaet ankommendes
## mouse_exited von einem laengst ersetzten Chip die Karte eines ANDEREN,
## gerade gehoverten Items wegreissen.
func _on_chip_unhover(item_id: String) -> void:
	if _hovered_item_id != item_id:
		return
	_hovered_item_id = ""
	hide_item()


## Gemeinsamer Stil fuer Chip und Karten-Farbfeld: getoenter Hintergrund,
## kraeftiger Rand in der Item-Farbe.
func _apply_icon_style(panel: Panel, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.16)
	style.border_color = Color(color.r, color.g, color.b, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	panel.add_theme_stylebox_override("panel", style)


## Kuerzel aus dem Anzeigenamen: "Mamas Kochloeffel" -> "MK".
## Solange es keine Icon-Texturen gibt, ist das der einzige Weg, einen Chip
## ohne Grafik unterscheidbar zu machen.
func _initials(display_name: String) -> String:
	var words: PackedStringArray = display_name.replace("-", " ").split(" ", false)
	var result: String = ""
	for word: String in words:
		if word.is_empty():
			continue
		result += word.substr(0, 1).to_upper()
		if result.length() >= 2:
			break
	if result.is_empty():
		return "?"
	return result


# ============================================================================
# Sichtbarkeit
# ============================================================================
func _on_visibility_setting_changed(_visible: bool) -> void:
	_apply_visibility()


func _on_element_setting_changed(_element: String, _is_visible: bool) -> void:
	_apply_visibility()


## Die Karte haengt woanders im Baum und wird deshalb getrennt geschaltet —
## sonst bliebe sie beim Ausblenden des HUD als einziges Element stehen.
func _apply_visibility() -> void:
	var show_hud: bool = SettingsManager.hud_visible \
		and SettingsManager.is_hud_element_visible(HUD_ELEMENT)
	visible = show_hud
	if _card and is_instance_valid(_card) and not show_hud:
		_card.visible = false
