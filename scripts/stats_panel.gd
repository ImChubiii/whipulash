
extends PanelContainer
class_name StatsPanel

# ============================================================================
# StatsPanel — Dauer-Anzeige der Spieler-Stats unten links.
# ============================================================================
# Baut seine Zeilen im Code auf, damit keine weitere .tscn gepflegt werden
# muss und ein neues Stat nur einen Eintrag in ROWS kostet.
#
# Es wird NICHT jeden Frame neu gezeichnet: das Panel haengt an
# PlayerStats.stats_changed und an den Waehrungs-Signalen des ItemManagers.
# Nur die Combo laeuft ueber _process, weil sie
# sich ohnehin staendig aendert und kein eigenes "hat sich geaendert"-Signal
# mit Zahlenwert hat, das haeufig genug feuert.
#
# ---------------------------------------------------------------------------
# UMBAU DER OPTIK
# ---------------------------------------------------------------------------
# Vorher war das Panel eine Liste aus grauen "Beschriftung .... Zahl"-Zeilen.
# Das Problem daran ist nicht der Geschmack, sondern die Lesbarkeit im
# Gefecht: alle Zeilen sahen gleich aus, also musste man sie LESEN, um eine
# Veraenderung zu bemerken. In einem Spiel, in dem man permanent ausweicht,
# passiert das schlicht nie.
#
# Was jetzt anders ist und warum:
#   * BALKEN STATT NUR ZAHLEN. Eine Fuellstandsaenderung erkennt man im
#     Augenwinkel, eine Ziffernaenderung nicht.
#   * EIGENE FARBE PRO STAT. Damit ist die Zeile ohne Lesen identifizierbar;
#     "der orange Balken ist laenger geworden" reicht als Information.
#   * KEINE LEBENSANZEIGE. Bewusst weggelassen: die Lebensleiste steht
#     bereits rechts im Haupt-HUD. Denselben Wert an zwei Stellen zu zeigen
#     kostet nur Platz und zwingt den Blick zur Entscheidung, wo er
#     hinschaut.
#   * KURZE AUFBLITZ-ANIMATION bei Aenderungen (_flash_row). Wer gerade ein
#     Item aufgehoben hat, sieht sofort, WELCHER Wert sich bewegt hat.
#   * AKZENT-STREIFEN LINKS + Kopfzeile, damit der Block als eine Einheit
#     gelesen wird und nicht als Text, der zufaellig auf dem Bild klebt.
#
# Die Balkenlaenge braucht einen Bezugswert. Fuer Multiplikator-Stats ist das
# 1.0 (= unveraendert), fuer absolute Werte eine Anzeige-Obergrenze aus
# BAR_MAX. Wichtig: das ist eine reine ANZEIGE-Skala, kein Cap. Werte
# darueber fuellen den Balken einfach ganz aus.

## Schluessel fuer SettingsManager.is_hud_element_visible().
const HUD_ELEMENT: String = "stats"

## Reihenfolge und Auswahl der angezeigten Stats.
const ROWS: Array = [
	PlayerStats.STAT_DAMAGE,
	PlayerStats.STAT_MOVE_SPEED,
	PlayerStats.STAT_COOLDOWN,
	PlayerStats.STAT_LUCK,
	PlayerStats.STAT_PICKUP_RANGE,
	PlayerStats.STAT_ARMOR,
]

## Eigene Farbe pro Stat — der eigentliche Grund, warum man die Zeilen ohne
## Lesen auseinanderhalten kann.
const STAT_COLORS: Dictionary = {
	PlayerStats.STAT_DAMAGE: Color(0.98, 0.42, 0.30),
	PlayerStats.STAT_MOVE_SPEED: Color(0.36, 0.86, 0.95),
	PlayerStats.STAT_COOLDOWN: Color(0.75, 0.55, 0.98),
	PlayerStats.STAT_LUCK: Color(0.50, 0.92, 0.52),
	PlayerStats.STAT_PICKUP_RANGE: Color(0.45, 0.66, 0.98),
	PlayerStats.STAT_ARMOR: Color(0.72, 0.78, 0.86),
	PlayerStats.STAT_HAZARD_RESIST: Color(0.98, 0.72, 0.35),
}

## Obergrenze der ANZEIGE-Skala je Stat. Nur fuer die Balkenlaenge relevant.
const BAR_MAX: Dictionary = {
	PlayerStats.STAT_DAMAGE: 3.0,
	PlayerStats.STAT_MOVE_SPEED: 30.0,
	PlayerStats.STAT_COOLDOWN: 3.0,
	PlayerStats.STAT_LUCK: 0.5,
	PlayerStats.STAT_PICKUP_RANGE: 8.0,
	PlayerStats.STAT_ARMOR: 2.0,
	PlayerStats.STAT_HAZARD_RESIST: 2.0,
}

const BG_COLOR: Color = Color(0.035, 0.042, 0.055, 0.86)
const BORDER_COLOR: Color = Color(0.18, 0.20, 0.24, 0.95)
const TRACK_COLOR: Color = Color(0.11, 0.12, 0.15, 0.95)
const LABEL_COLOR: Color = Color(0.62, 0.66, 0.72)
const VALUE_COLOR: Color = Color(0.96, 0.94, 0.88)
const ACCENT_COLOR: Color = Color(0.98, 0.80, 0.22)
const BOMB_COLOR: Color = Color(0.95, 0.52, 0.38)
const COMBO_COLOR: Color = Color(0.98, 0.45, 0.35)

const BAR_HEIGHT: float = 6.0
const NAME_WIDTH: float = 80.0
const VALUE_WIDTH: float = 52.0

var _rows: Dictionary = {}        # stat -> { "value": Label, "fill": ColorRect }
var _coin_label: Label = null
var _bomb_label: Label = null
var _combo_label: Label = null
var _combo_panel: PanelContainer = null

var _stats: PlayerStats = null
var _items: Node = null
var _last_combo: int = -1
var _last_values: Dictionary = {}  # stat -> float


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()

	_items = get_node_or_null("/root/Items")
	if _items:
		_items.coins_changed.connect(_on_coins_changed)
		_items.bombs_changed.connect(_on_bombs_changed)
		_items.player_ready.connect(_on_player_ready)
		_on_coins_changed(_items.coins)
		_on_bombs_changed(_items.bombs)
		if _items.stats:
			_bind_stats(_items.stats)

	SettingsManager.hud_visible_changed.connect(_on_visibility_setting_changed)
	SettingsManager.hud_element_visible_changed.connect(_on_element_setting_changed)
	_apply_visibility()


# ============================================================================
# Aufbau
# ============================================================================
func _build_ui() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = BORDER_COLOR
	style.set_border_width_all(1)
	# Breiter Akzentstreifen links: bindet den Block optisch zusammen und
	# ist dieselbe Sprache wie die Item-Karte darueber.
	style.border_width_left = 3
	style.set_corner_radius_all(2)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 7.0
	style.content_margin_bottom = 8.0
	add_theme_stylebox_override("panel", style)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	add_child(column)

	column.add_child(_build_header())
	column.add_child(_build_currency_row())
	column.add_child(_make_separator())

	for stat: String in ROWS:
		column.add_child(_build_stat_row(stat))


## Kopfzeile: Titel links, Combo-Badge rechts. Die Combo steht bewusst OBEN
## und nicht mehr als letzte Zeile — sie ist der einzige Wert hier, der sich
## im Sekundentakt aendert, und gehoert damit an die auffaelligste Stelle.
func _build_header() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var title := Label.new()
	title.text = "STATUS"
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.50, 0.54, 0.60))
	row.add_child(title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	_combo_panel = PanelContainer.new()
	var combo_style := StyleBoxFlat.new()
	combo_style.bg_color = Color(COMBO_COLOR.r, COMBO_COLOR.g, COMBO_COLOR.b, 0.18)
	combo_style.border_color = Color(COMBO_COLOR.r, COMBO_COLOR.g, COMBO_COLOR.b, 0.75)
	combo_style.set_border_width_all(1)
	combo_style.set_corner_radius_all(2)
	combo_style.content_margin_left = 6.0
	combo_style.content_margin_right = 6.0
	combo_style.content_margin_top = 1.0
	combo_style.content_margin_bottom = 1.0
	_combo_panel.add_theme_stylebox_override("panel", combo_style)
	_combo_panel.visible = false
	row.add_child(_combo_panel)

	_combo_label = Label.new()
	_combo_label.text = "x0"
	_combo_label.add_theme_font_size_override("font_size", 13)
	_combo_label.add_theme_color_override("font_color", COMBO_COLOR)
	_combo_panel.add_child(_combo_label)

	return row


## Muenzen und Bomben.
##
## GEAENDERT: waren vorher zwei nebeneinanderliegende Chips mit einem
## Unicode-Symbol als Icon. Zwei Probleme damit, die beide dazu fuehrten,
## dass man die Zahlen praktisch nicht gesehen hat:
##   * Die Symbole (Raute/Kreis) sind in vielen Standardschriften nicht
##     enthalten und wurden als Platzhalterkasten gerendert — daneben ging
##     die eigentliche Zahl optisch unter.
##   * Zwei Chips nebeneinander in einem 210 px breiten Panel liessen jeder
##     Zahl rund 90 px, davon die Haelfte fuer das Symbol.
##
## Jetzt zwei ausgeschriebene Zeilen im selben Raster wie die Stats
## darunter — gleiche Ausrichtung, gleiche Lesart, und die Zahl steht
## rechts, wo sie bei allen anderen Zeilen auch steht.
func _build_currency_row() -> VBoxContainer:
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 2)

	_coin_label = _add_value_row(block, "Muenzen", ACCENT_COLOR)
	_bomb_label = _add_value_row(block, "Bomben", BOMB_COLOR)

	return block


## Zeile "Beschriftung ........ Wert" ohne Balken. Der Spacer in der Mitte
## haelt den Wert rechtsbuendig, ohne dass eine feste Panelbreite noetig
## waere.
func _add_value_row(parent: VBoxContainer, label_text: String, value_color: Color) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", LABEL_COLOR)
	name_label.custom_minimum_size = Vector2(NAME_WIDTH, 0.0)
	row.add_child(name_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var value_label := Label.new()
	value_label.text = "0"
	value_label.add_theme_font_size_override("font_size", 15)
	value_label.add_theme_color_override("font_color", value_color)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.custom_minimum_size = Vector2(VALUE_WIDTH, 0.0)
	row.add_child(value_label)

	parent.add_child(row)
	return value_label


## Eine Stat-Zeile: Name | Balken | Wert. Feste Breiten links und rechts
## halten alle Balken buendig — ohne das hoppeln sie je nach Textlaenge und
## der Block wirkt unruhig.
func _build_stat_row(stat: String) -> VBoxContainer:
	var color: Color = STAT_COLORS.get(stat, VALUE_COLOR)

	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", 1)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var name_label := Label.new()
	name_label.text = String(PlayerStats.STAT_LABELS.get(stat, stat))
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", LABEL_COLOR)
	name_label.custom_minimum_size = Vector2(NAME_WIDTH, 0.0)
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.text = "-"
	value_label.add_theme_font_size_override("font_size", 13)
	value_label.add_theme_color_override("font_color", color)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.custom_minimum_size = Vector2(VALUE_WIDTH, 0.0)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_label)

	block.add_child(row)

	var bar := _make_bar(BAR_HEIGHT, color)
	block.add_child(bar[0])

	# Die Farbe wandert MIT in den Eintrag. Sie spaeter aus dem Label
	# zurueckzulesen waere ein Fehler: startet ein zweiter Aufblitzer,
	# waehrend der erste noch laeuft, waere der "Originalwert" bereits die
	# Blitzfarbe — und die Zeile bliebe dauerhaft gruen oder rot.
	_rows[stat] = {"value": value_label, "fill": bar[1], "color": color}
	return block


## Balken = dunkle Spur + farbige Fuellung. Die Fuellung sitzt per ANKER im
## Track (anchor_right = Anteil), nicht per Groesse.
##
## Der Unterschied ist wichtig: eine per size gesetzte Fuellung wird vom
## Container beim naechsten Layout-Durchlauf wieder ueberschrieben, und der
## Balken springt scheinbar zufaellig auf null zurueck. Ueber Anker geht das
## nicht, weil Anker das Layout-Ergebnis selbst sind.
func _make_bar(height: float, color: Color) -> Array:
	var track := Panel.new()
	track.custom_minimum_size = Vector2(0.0, height)
	track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var track_style := StyleBoxFlat.new()
	track_style.bg_color = TRACK_COLOR
	track_style.set_corner_radius_all(1)
	track.add_theme_stylebox_override("panel", track_style)

	var fill := ColorRect.new()
	fill.color = color
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	fill.anchor_right = 0.0
	fill.offset_left = 0.0
	fill.offset_top = 0.0
	fill.offset_right = 0.0
	fill.offset_bottom = 0.0
	track.add_child(fill)

	return [track, fill]


func _make_separator() -> HSeparator:
	var separator := HSeparator.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.20, 0.22, 0.26, 0.55)
	style.content_margin_top = 2.0
	style.content_margin_bottom = 2.0
	separator.add_theme_stylebox_override("separator", style)
	return separator


# ============================================================================
# Datenanbindung
# ============================================================================
func _on_player_ready(_player: CharacterBody3D) -> void:
	if _items and _items.stats:
		_bind_stats(_items.stats)


func _bind_stats(stats: PlayerStats) -> void:
	if _stats and is_instance_valid(_stats) and _stats.stats_changed.is_connected(_refresh_stats):
		_stats.stats_changed.disconnect(_refresh_stats)

	_stats = stats
	if _stats:
		_stats.stats_changed.connect(_refresh_stats)
	_refresh_stats()


func _refresh_stats() -> void:
	if _stats == null or not is_instance_valid(_stats):
		return

	for stat: String in _rows.keys():
		var entry: Dictionary = _rows[stat]
		var value_label: Label = entry["value"]
		var fill: ColorRect = entry["fill"]

		var raw: float = _stats.get_stat(stat)
		value_label.text = _stats.format_stat(stat)
		fill.anchor_right = clampf(raw / float(BAR_MAX.get(stat, 2.0)), 0.0, 1.0)

		# Nur bei echter Aenderung aufblitzen — sonst blinkt beim Binden
		# eines neuen Charakters das komplette Panel auf einmal.
		var previous = _last_values.get(stat)
		if previous != null and not is_equal_approx(float(previous), raw):
			_flash_row(entry, raw > float(previous))
		_last_values[stat] = raw


## Kurzer Aufblitzer auf Wert UND Balken. Grun = besser geworden, rot =
## schlechter. Der Balken selbst bleibt in seiner Stat-Farbe, es faerbt sich
## nur die Fuellung fuer den Moment um.
func _flash_row(entry: Dictionary, improved: bool) -> void:
	var value_label: Label = entry["value"]
	var fill: ColorRect = entry["fill"]
	var flash_color: Color = Color(0.55, 1.0, 0.60) if improved else Color(1.0, 0.45, 0.42)
	var base_color: Color = entry["color"]

	value_label.add_theme_color_override("font_color", flash_color)
	fill.color = flash_color

	var tween := create_tween()
	tween.tween_interval(0.28)
	tween.tween_callback(func() -> void:
		if is_instance_valid(value_label):
			value_label.add_theme_color_override("font_color", base_color)
		if is_instance_valid(fill):
			fill.color = base_color
	)


func _on_coins_changed(amount: int) -> void:
	if _coin_label:
		_coin_label.text = str(amount)


func _on_bombs_changed(amount: int) -> void:
	if _bomb_label:
		_bomb_label.text = str(amount)


func _process(_delta: float) -> void:
	if _items == null or _combo_label == null:
		return
	var combo: int = _items.get_combo_count()
	if combo == _last_combo:
		return
	_last_combo = combo

	var show_combo: bool = combo > 1
	if _combo_panel:
		_combo_panel.visible = show_combo
	if show_combo:
		_combo_label.text = "x%d" % combo


# ============================================================================
# Sichtbarkeit
# ============================================================================
# Gleiche Regel wie in hud.gd: Master-Schalter UND Einzelschalter muessen
# beide true sein. is_hud_element_visible() liefert fuer unbekannte
# Schluessel true zurueck — das Panel funktioniert also auch, solange
# "stats" noch nicht in SettingsManager.HUD_ELEMENTS eingetragen ist.
func _on_visibility_setting_changed(_visible: bool) -> void:
	_apply_visibility()


func _on_element_setting_changed(_element: String, _is_visible: bool) -> void:
	_apply_visibility()


func _apply_visibility() -> void:
	visible = SettingsManager.hud_visible and SettingsManager.is_hud_element_visible(HUD_ELEMENT)


