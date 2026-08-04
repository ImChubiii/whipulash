

extends VBoxContainer
class_name ItemSummaryList

# ============================================================================
# ItemSummaryList — Liste der gesammelten Items fuer Pause-, Tod- und
# Siegbildschirm, mit Beschreibung beim Ueberfahren mit der Maus.
# ============================================================================
#
# WARUM EIN GEMEINSAMES SCRIPT UND NICHT DREIMAL DERSELBE CODE:
# Pause-, Tod- und Siegbildschirm brauchen exakt dieselbe Anzeige. Drei
# Kopien haetten bedeutet, dass ein neues Feld in ItemData an drei Stellen
# nachgetragen werden muss — und dass die dritte Stelle beim naechsten Mal
# vergessen wird. Die drei Screens haengen sich stattdessen jeweils EINE
# Instanz hiervon in ihren Baum.
#
# WARUM MAUS-HOVER UND NICHT DAUERHAFT ALLE BESCHREIBUNGEN:
# Mit acht Items waeren acht Beschreibungsabsaetze untereinander laenger als
# jeder dieser Bildschirme. Das In-Game-HUD loest dasselbe Problem ueber
# Naehe zum Sockel; hier ist die Maus ohnehin sichtbar (alle drei Screens
# pausieren das Spiel und geben den Cursor frei), also ist Hover das
# naheliegende Mittel.
#
# WICHTIG ZUM MAUS-FILTER: Dieser Node und seine Zeilen muessen
# MOUSE_FILTER_STOP bzw. PASS haben. Viele HUD-Elemente im Projekt stehen
# auf MOUSE_FILTER_IGNORE (Wert 2), damit sie keine Klicks abfangen — wer
# das hier uebernimmt, bekommt nie ein mouse_entered und wundert sich, warum
# der Hover "nicht funktioniert", obwohl der Code laeuft.
#
# ---------------------------------------------------------------------------
# WARUM DIE BESCHREIBUNGSKARTE NICHT MEHR TEIL DIESER LISTE IST (behobener
# Bug: "hoveren veraendert das Format")
# ---------------------------------------------------------------------------
# ItemSummaryList selbst ist ein VBoxContainer. Die Detailkarte stand bisher
# als normales Kind DARIN — ein Container legt die Groesse und Position
# JEDES Kindes bei jedem Layout-Durchlauf selbst fest. Sobald die Karte beim
# Hovern auf visible = true wechselte, hat der VBoxContainer sie in seinen
# Stapel eingerechnet und ALLES darunter (Waehrungszeile, ggf. der ganze
# Rest der Pause-/Tod-/Siegkarte) nach unten verschoben — das Popup hat
# buchstaeblich das Format des Bildschirms veraendert, weil es keins war,
# sondern eine ganz normale, layoutwirksame Zeile.
#
# Ein "Popup" darf per Definition NICHT layoutwirksam sein. Die Karte haengt
# deshalb jetzt an der TOPMOST Control der jeweiligen Szene (Pause-/Tod-/
# Siegbildschirm-Wurzel) — die ist ein einfaches Control, KEIN Container,
# und positioniert ihre Kinder nicht selbst um. Von dort aus wird die Karte
# manuell neben die gerade ueberfahrene Zeile gesetzt (_position_detail_panel).
# Das ist derselbe Trick wie bei der Item-Karte im normalen HUD
# (item_description_hud.gd) — dort aus demselben Grund.

## Ueberschrift ueber der Liste. Leer lassen = keine Ueberschrift.
@export var title_text: String = "GESAMMELTE ITEMS"

## Text, wenn das Inventar leer ist.
@export var empty_text: String = "Keine Items gesammelt"

## Zeigt zusaetzlich Muenzen und Bomben unter der Liste.
@export var show_currencies: bool = true

## --- Beschreibungs-Popup (Phase 2.4) ----------------------------------
##
## PROBLEM: Das Popup hatte eine FESTE Breite von 280 px und wurde direkt
## neben die ueberfahrene Zeile gesetzt. Im Pausemenue haengt die
## Item-Liste aber IN derselben zentrierten Spalte wie Resume/Settings/
## Restart/Quit ("Panel/VBoxContainer"). Ein 280 px breiter Kasten neben
## einer Zeile dieser Spalte landet zwangslaeufig ueber den Buttons - und
## weil er mouse_filter = IGNORE hat, sind die Buttons darunter zwar
## klickbar, aber unlesbar.
##
## LOESUNG, zwei Teile:
##   1. Die Breite richtet sich nach dem laengsten Textabschnitt und wird
##      nur noch nach oben gedeckelt. Kurze Beschreibungen bekommen keinen
##      halbleeren Kasten mehr.
##   2. Das Popup weicht dem Menue-Panel AUS statt nur dem Bildschirmrand.
##      Der auszuweichende Bereich wird automatisch ermittelt (siehe
##      _resolve_avoid_rect) - das Pausemenue muss dafuer nichts liefern.
@export var detail_max_width: float = 260.0
@export var detail_min_width: float = 150.0
## Abstand zwischen Popup und Zeile bzw. Menue-Panel.
@export var detail_gap: float = 10.0
## Name des Knotens, dem ausgewichen wird, gesucht ab dem Bildschirm-Wurzel-
## Control. Leer lassen, um das Ausweichen abzuschalten.
##
## GEAENDERT (Rueckmeldung: "das popup soll neben dem item im pausescreen sein
## nicht mittig an der linken seite"): Default ist jetzt LEER.
##
## Mit "Panel" sprang die Karte an die AUSSENKANTE des Menue-Kastens - im
## Pausemenue also an den linken bzw. rechten Bildschirmrand, weit weg von der
## Zeile, zu der sie gehoert. Der Bezug zwischen ueberfahrenem Item und
## Beschreibung ging dabei verloren.
##
## Leer = die Karte klebt an der Zeile selbst (rechts bevorzugt, links als
## Ausweichroute) und wird nur noch am Bildschirmrand geklemmt. Wer das alte
## Verhalten zurueck will, traegt hier wieder "Panel" ein.
@export var avoid_node_name: String = ""

const ROW_HEIGHT: float = 30.0
const SWATCH_SIZE: float = 22.0
const BG_COLOR: Color = Color(0.05, 0.06, 0.075, 0.55)
const MUTED_COLOR: Color = Color(0.62, 0.66, 0.72)
const TEXT_COLOR: Color = Color(0.90, 0.90, 0.93)

var _title: Label = null
var _rows_box: VBoxContainer = null
var _empty_label: Label = null
var _currency_label: Label = null
var _detail_panel: PanelContainer = null
var _detail_name: Label = null
var _detail_text: Label = null

var _items: Node = null


func _exit_tree() -> void:
	# _detail_panel haengt an der Bildschirm-Wurzel, nicht an self — bei
	# einem Szenenwechsel (Level-Neustart) wird sie zwar META im selben
	# Teilbaum mitgeloescht, aber ein manuelles Aufraeumen ist billiger als
	# sich auf implizite Baum-Reihenfolge zu verlassen.
	if _detail_panel and is_instance_valid(_detail_panel):
		_detail_panel.queue_free()
	_detail_panel = null


func _ready() -> void:
	# STOP statt IGNORE — sonst kommt kein mouse_entered an. Siehe Kopf.
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_theme_constant_override("separation", 6)

	# Deferred: die Liste selbst wird von aussen per add_child() in
	# "Panel/VBoxContainer" gehaengt (death_screen.gd / pause_menu.gd /
	# win_screen.gd). _find_floating_host() muss dabei bereits die volle
	# Vorfahrenkette bis zur Bildschirmwurzel sehen — unmittelbar in _ready()
	# ist das zwar meistens schon der Fall, aber ein Frame Sicherheitsabstand
	# kostet nichts und macht die Reihenfolge robust gegen kuenftige
	# Umbauten der drei Screens.
	_build.call_deferred()
	_items = get_node_or_null("/root/Items")
	if _items and _items.has_signal("inventory_changed"):
		_items.inventory_changed.connect(refresh)
	refresh()


## Oberster Control-Vorfahr = die Bildschirm-Wurzel (PauseMenu, DeathScreen
## oder WinScreen, alle "extends Control" OHNE Container-Verhalten). Dort
## haengt die Detailkarte, weil ein einfaches Control seine Kinder NICHT
## selbst positioniert — im Gegensatz zu einem VBoxContainer.
func _find_floating_host() -> Control:
	var host: Control = self
	var node: Node = get_parent()
	while node is Control:
		host = node as Control
		node = node.get_parent()
	return host


# ============================================================================
# Aufbau
# ============================================================================
func _build() -> void:
	if title_text != "":
		_title = Label.new()
		_title.text = title_text
		_title.add_theme_font_size_override("font_size", 12)
		_title.add_theme_color_override("font_color", MUTED_COLOR)
		_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_title)

	_rows_box = VBoxContainer.new()
	_rows_box.add_theme_constant_override("separation", 2)
	_rows_box.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_rows_box)

	_empty_label = Label.new()
	_empty_label.text = empty_text
	_empty_label.add_theme_font_size_override("font_size", 13)
	_empty_label.add_theme_color_override("font_color", MUTED_COLOR)
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_empty_label)

	# --- Beschreibungsfeld, gefuellt beim Ueberfahren ------------------
	_detail_panel = PanelContainer.new()
	_detail_panel.visible = false
	_detail_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.065, 0.92)
	style.border_color = Color(0.30, 0.33, 0.38, 0.9)
	style.set_border_width_all(1)
	style.border_width_left = 3
	style.set_corner_radius_all(2)
	# Enger als vorher (10/10/7/7): jeder Millimeter Innenrand ist Breite,
	# die das Popup zusaetzlich in die Button-Spalte schiebt.
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 5.0
	style.content_margin_bottom = 5.0
	_detail_panel.add_theme_stylebox_override("panel", style)
	# TOP_LEFT: Position wird ueber .position gesetzt (siehe
	# _position_detail_panel), nicht ueber Anker relativ zu einem Container.
	_detail_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	# Die Breite setzt jetzt _apply_detail_width() pro Item. Hier nur die
	# Untergrenze, damit ein einzeiliger Name nicht zu einem Streifen
	# zusammenfaellt.
	_detail_panel.custom_minimum_size = Vector2(detail_min_width, 0.0)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	_detail_panel.add_child(column)

	_detail_name = Label.new()
	_detail_name.add_theme_font_size_override("font_size", 13)
	_detail_name.add_theme_color_override("font_color", Color(0.98, 0.95, 0.84))
	column.add_child(_detail_name)

	_detail_text = Label.new()
	_detail_text.add_theme_font_size_override("font_size", 12)
	_detail_text.add_theme_color_override("font_color", TEXT_COLOR)
	_detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_detail_text)

	# NICHT add_child(_detail_panel) auf self (VBoxContainer) — das ist
	# genau der Fehler, den dieser Umbau behebt. Stattdessen an die Wurzel
	# der Szene haengen, wo kein Container mehr mitredet.
	_find_floating_host().add_child(_detail_panel)

	if show_currencies:
		_currency_label = Label.new()
		_currency_label.add_theme_font_size_override("font_size", 12)
		_currency_label.add_theme_color_override("font_color", MUTED_COLOR)
		_currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_currency_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_currency_label)


# ============================================================================
# Inhalt
# ============================================================================
## Oeffentlich, damit die Screens sie beim Einblenden erneut aufrufen koennen.
func refresh() -> void:
	if _rows_box == null:
		return

	for child: Node in _rows_box.get_children():
		child.queue_free()

	_hide_detail()

	if _items == null:
		_items = get_node_or_null("/root/Items")
	if _items == null:
		_empty_label.visible = true
		return

	# Gleiche Items zusammenfassen. Ohne das stuenden drei Exemplare
	# desselben Items als drei identische Zeilen untereinander.
	var counts: Dictionary = {}
	var order: Array[ItemData] = []
	for item: ItemData in _items.inventory:
		if counts.has(item.id):
			counts[item.id] = int(counts[item.id]) + 1
		else:
			counts[item.id] = 1
			order.append(item)

	_empty_label.visible = order.is_empty()

	for item: ItemData in order:
		_rows_box.add_child(_make_row(item, int(counts[item.id])))

	if _currency_label:
		_currency_label.text = "%d Muenzen  \u00b7  %d Bomben" % [
			int(_items.coins), int(_items.bombs)
		]


func _make_row(item: ItemData, count: int) -> Control:
	var color: Color = item.pedestal_color

	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(0.0, ROW_HEIGHT)
	# PASS: die Zeile meldet Hover, schluckt aber keine Klicks, die an die
	# Buttons dahinter gehen sollen.
	row.mouse_filter = Control.MOUSE_FILTER_PASS

	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = Color(color.r, color.g, color.b, 0.55)
	style.set_border_width_all(0)
	style.border_width_left = 3
	style.set_corner_radius_all(2)
	style.content_margin_left = 8.0
	style.content_margin_right = 10.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	row.add_theme_stylebox_override("panel", style)

	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(box)

	# --- Farbfeld mit Kuerzel: dieselbe Farbe wie am Sockel ------------
	var swatch := Panel.new()
	swatch.custom_minimum_size = Vector2(SWATCH_SIZE, SWATCH_SIZE)
	swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var swatch_style := StyleBoxFlat.new()
	swatch_style.bg_color = Color(color.r, color.g, color.b, 0.18)
	swatch_style.border_color = Color(color.r, color.g, color.b, 0.9)
	swatch_style.set_border_width_all(1)
	swatch_style.set_corner_radius_all(2)
	swatch.add_theme_stylebox_override("panel", swatch_style)
	box.add_child(swatch)

	var initials := Label.new()
	initials.text = _initials(item.display_name)
	initials.set_anchors_preset(Control.PRESET_FULL_RECT)
	initials.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initials.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initials.add_theme_font_size_override("font_size", 10)
	initials.add_theme_color_override("font_color", color)
	initials.mouse_filter = Control.MOUSE_FILTER_IGNORE
	swatch.add_child(initials)

	var name_label := Label.new()
	name_label.text = item.display_name if count <= 1 else "%s  x%d" % [item.display_name, count]
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", TEXT_COLOR)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(name_label)

	var kind_label := Label.new()
	kind_label.text = "AKTIV" if item.is_active_item() else item.get_category_name().to_upper()
	kind_label.add_theme_font_size_override("font_size", 9)
	kind_label.add_theme_color_override("font_color",
		Color(0.45, 0.85, 0.95) if item.is_active_item() else MUTED_COLOR)
	kind_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	kind_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(kind_label)

	# bind() haengt Item UND Zeile an — die Zeile braucht es fuer die
	# Positionierung der Karte (siehe _position_detail_panel).
	row.mouse_entered.connect(_show_detail.bind(item, style, color, row))
	row.mouse_exited.connect(_on_row_exited.bind(style, color))

	return row


func _show_detail(item: ItemData, style: StyleBoxFlat, color: Color, row: Control) -> void:
	if _detail_panel == null:
		return

	_detail_name.text = item.display_name
	var text: String = item.description
	if item.flavor_text != "":
		text = "\u201c%s\u201d\n%s" % [item.flavor_text, item.description]
	if item.is_active_item():
		text += "\n%s" % _format_active_status(item)
	_detail_text.text = text

	var panel_style: StyleBox = _detail_panel.get_theme_stylebox("panel")
	if panel_style is StyleBoxFlat:
		(panel_style as StyleBoxFlat).border_color = Color(color.r, color.g, color.b, 0.85)

	_apply_detail_width(text, item.display_name)

	_detail_panel.visible = true
	_position_detail_panel(row)

	# Zeile hervorheben, damit klar ist, wozu die Beschreibung gehoert.
	style.bg_color = Color(color.r, color.g, color.b, 0.16)


## BUGFIX "zeigt manchmal noch [C]": stammte noch aus der Vor-Phase-5-Zeit
## mit genau einem aktiven Item auf Taste C. Seit Q/E zwei unabhaengige Slots
## sind (siehe item_manager.gd) UND es zeitbasierte Cooldowns neben den alten
## Raum-Ladungen gibt, war der Text sowohl in der Taste als auch im
## Ladungstyp falsch. Spiegelt jetzt dieselbe Logik wie
## item_description_hud.gd._format_active_status().
func _format_active_status(item: ItemData) -> String:
	if _items == null:
		return ""

	var slot: int = -1
	for i: int in range(_items.ACTIVE_SLOT_COUNT):
		if _items.active_items[i] == item:
			slot = i
			break

	if slot < 0:
		return "Aktiv — nicht ausgeruestet (Q/E bereits belegt)"

	var key: String = ["Q", "E"][slot]
	if item.uses_time_cooldown():
		return "%s · laedt in %d s" % [key, int(ceilf(item.cooldown_seconds))]
	return "%s · laedt ueber %d Raeume" % [key, item.charge_rooms]


## Setzt die Karte neben die ueberfahrene Zeile — rechts bevorzugt, links
## als Ausweichroute, wenn rechts kein Platz mehr ist, und in beiden Faellen
## innerhalb des Bildschirms geklemmt. get_combined_minimum_size() liefert
## die Groesse SOFORT auf Basis des gerade gesetzten Texts, ohne auf einen
## Layout-Durchlauf warten zu muessen.
## Breite aus dem Inhalt statt fest.
##
## Gemessen wird die LAENGSTE Zeile des Textes, nicht der ganze String:
## der Text enthaelt Zeilenumbrueche (Flavor, Ladehinweis), und die Summe
## aller Zeichen waere ein Vielfaches der tatsaechlich noetigen Breite.
##
## get_string_size() liefert das Ergebnis SOFORT, ohne auf einen
## Layout-Durchlauf zu warten - genauso wie get_combined_minimum_size()
## weiter unten.
func _apply_detail_width(body: String, title: String) -> void:
	if _detail_panel == null or _detail_text == null:
		return

	var font: Font = _detail_text.get_theme_font("font")
	var font_size: int = _detail_text.get_theme_font_size("font_size")
	var widest: float = 0.0

	if font != null:
		for line: String in body.split("\n"):
			widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x)

		var title_font: Font = _detail_name.get_theme_font("font")
		var title_size: int = _detail_name.get_theme_font_size("font_size")
		if title_font != null:
			widest = maxf(widest, title_font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, title_size).x)

	# Innenraender der StyleBox draufrechnen - die Messung oben kennt nur
	# den Text, nicht den Kasten drumherum.
	var padding: float = 0.0
	var panel_style: StyleBox = _detail_panel.get_theme_stylebox("panel")
	if panel_style != null:
		padding = panel_style.get_margin(SIDE_LEFT) + panel_style.get_margin(SIDE_RIGHT)

	var width: float = clampf(widest + padding, detail_min_width, detail_max_width)
	_detail_panel.custom_minimum_size = Vector2(width, 0.0)
	# size zuruecksetzen: der PanelContainer behaelt sonst die Breite des
	# zuletzt angezeigten, laengeren Items bei.
	_detail_panel.size = Vector2(width, 0.0)


## Bereich, den das Popup NICHT ueberdecken darf.
##
## Gesucht wird ab dem Bildschirm-Wurzel-Control ein direktes Kind mit dem
## Namen avoid_node_name ("Panel"). Im Pausemenue, Death- und Win-Screen
## ist das jeweils der Kasten mit den Buttons. Findet sich keiner - etwa
## weil die Liste irgendwo anders eingehaengt wird - liefert die Funktion
## ein leeres Rechteck und die Positionierung faellt auf das alte
## Verhalten zurueck.
func _resolve_avoid_rect() -> Rect2:
	if avoid_node_name == "":
		return Rect2()
	var host: Control = _find_floating_host()
	var panel := host.get_node_or_null(avoid_node_name) as Control
	if panel == null or not panel.is_visible_in_tree():
		return Rect2()
	return panel.get_global_rect()


func _position_detail_panel(row: Control) -> void:
	if _detail_panel == null or row == null or not is_instance_valid(row):
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var row_rect: Rect2 = row.get_global_rect()
	var panel_size: Vector2 = _detail_panel.get_combined_minimum_size()
	var avoid: Rect2 = _resolve_avoid_rect()

	# Senkrecht an der Zeile ausrichten statt buendig an deren Oberkante: bei
	# mehrzeiligen Beschreibungen wirkt die Karte sonst nach unten "abgerutscht".
	var pos := Vector2(
		row_rect.position.x + row_rect.size.x + detail_gap,
		row_rect.position.y + row_rect.size.y * 0.5 - panel_size.y * 0.5
	)

	if avoid.size.x > 0.0:
		# NEBEN das Menue-Panel setzen, nicht neben die Zeile. Die Zeile
		# liegt mitten in der Button-Spalte; alles, was direkt an ihr
		# klebt, deckt zwangslaeufig Buttons zu.
		#
		# Rechts bevorzugt, links als Ausweichroute. Passt keine der
		# beiden Seiten in den Bildschirm, gewinnt die mit mehr Platz -
		# ein Popup am Rand ist immer noch besser als eines auf den
		# Buttons.
		var right_x: float = avoid.position.x + avoid.size.x + detail_gap
		var left_x: float = avoid.position.x - panel_size.x - detail_gap
		var right_fits: bool = right_x + panel_size.x <= viewport_size.x - 8.0
		var left_fits: bool = left_x >= 8.0

		if right_fits:
			pos.x = right_x
		elif left_fits:
			pos.x = left_x
		else:
			var space_right: float = viewport_size.x - (avoid.position.x + avoid.size.x)
			pos.x = right_x if space_right >= avoid.position.x else left_x
	elif pos.x + panel_size.x > viewport_size.x - 8.0:
		pos.x = row_rect.position.x - panel_size.x - detail_gap

	pos.x = clampf(pos.x, 8.0, maxf(viewport_size.x - panel_size.x - 8.0, 8.0))
	pos.y = clampf(pos.y, 8.0, maxf(viewport_size.y - panel_size.y - 8.0, 8.0))

	_detail_panel.position = pos


func _on_row_exited(style: StyleBoxFlat, _color: Color) -> void:
	style.bg_color = BG_COLOR
	_hide_detail()


func _hide_detail() -> void:
	if _detail_panel:
		_detail_panel.visible = false


## Kuerzel aus dem Anzeigenamen: "Mamas Kochloeffel" -> "MK".
func _initials(display_name: String) -> String:
	var words: PackedStringArray = display_name.replace("-", " ").split(" ", false)
	var result: String = ""
	for word: String in words:
		if word.is_empty():
			continue
		result += word.substr(0, 1).to_upper()
		if result.length() >= 2:
			break
	return result if result != "" else "?"


## Bequemer Konstruktor fuer die Screens.
static func create(p_title: String = "GESAMMELTE ITEMS", p_currencies: bool = true) -> ItemSummaryList:
	var list := ItemSummaryList.new()
	list.name = "ItemSummaryList"
	list.title_text = p_title
	list.show_currencies = p_currencies
	return list


