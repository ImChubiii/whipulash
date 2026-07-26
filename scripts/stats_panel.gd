extends PanelContainer
class_name StatsPanel

# ============================================================================
# StatsPanel — Dauer-Anzeige der Spieler-Stats an der linken Bildschirmseite.
# ============================================================================
# Baut seine Zeilen im Code auf, damit keine weitere .tscn gepflegt werden
# muss und ein neues Stat nur einen Eintrag in ROWS kostet.
#
# Es wird NICHT jeden Frame neu gezeichnet: das Panel haengt an
# PlayerStats.stats_changed und an den Waehrungs-Signalen des ItemManagers.
# Nur die Combo laeuft ueber _process, weil sie sich ohnehin staendig
# aendert und kein eigenes "hat sich geaendert"-Signal mit Zahlenwert hat,
# das haeufig genug feuert.

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

const LABEL_COLOR: Color = Color(0.72, 0.74, 0.78)
const VALUE_COLOR: Color = Color(0.96, 0.94, 0.88)
const ACCENT_COLOR: Color = Color(0.98, 0.80, 0.22)

var _rows: Dictionary = {}       # stat -> Label (Wertspalte)
var _coin_label: Label = null
var _bomb_label: Label = null
var _combo_label: Label = null
var _stats: PlayerStats = null
var _items: Node = null
var _last_combo: int = -1


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
	style.bg_color = Color(0.05, 0.06, 0.07, 0.72)
	style.border_color = Color(0.25, 0.27, 0.30, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 10.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	add_theme_stylebox_override("panel", style)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	add_child(column)

	column.add_child(_make_header("STATS"))
	column.add_child(_make_separator())

	# --- Waehrungen ---------------------------------------------------
	_coin_label = _add_row(column, "Muenzen", ACCENT_COLOR)
	_bomb_label = _add_row(column, "Bomben", Color(0.85, 0.55, 0.45))
	column.add_child(_make_separator())

	# --- Stats --------------------------------------------------------
	for stat: String in ROWS:
		var label_text: String = String(PlayerStats.STAT_LABELS.get(stat, stat))
		_rows[stat] = _add_row(column, label_text, VALUE_COLOR)

	column.add_child(_make_separator())
	_combo_label = _add_row(column, "Combo", Color(0.98, 0.45, 0.35))


func _make_header(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.55, 0.58, 0.62))
	return label


func _make_separator() -> HSeparator:
	var separator := HSeparator.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.27, 0.30, 0.55)
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	separator.add_theme_stylebox_override("separator", style)
	return separator


## Eine Zeile "Beschriftung ........ Wert". Der Spacer in der Mitte haelt
## die Werte rechtsbuendig, ohne dass eine feste Panelbreite noetig waere.
func _add_row(parent: VBoxContainer, label_text: String, value_color: Color) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", LABEL_COLOR)
	row.add_child(name_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.custom_minimum_size = Vector2(24.0, 0.0)
	row.add_child(spacer)

	var value_label := Label.new()
	value_label.text = "-"
	value_label.add_theme_font_size_override("font_size", 12)
	value_label.add_theme_color_override("font_color", value_color)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	parent.add_child(row)
	return value_label


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
		(_rows[stat] as Label).text = _stats.format_stat(stat)


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
	_combo_label.text = ("x%d" % combo) if combo > 1 else "-"


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
