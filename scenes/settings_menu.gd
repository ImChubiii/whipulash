extends Control
class_name SettingsMenu

## Einstellungsmenue.
##
## AUFBAU-PHILOSOPHIE: Die .tscn bleibt bewusst so flach wie sie ist. Die
## Gruppierung (Klapp-Sektionen im General-Tab), der Minimap-Block und das
## zweispaltige Keybind-Raster werden zur LAUFZEIT gebaut und die
## bestehenden Zeilen per reparent() in die passende Gruppe verschoben.
##
## RESET: Der Button unten setzt NUR die gerade sichtbare Seite zurueck.
## Ein globaler Reset ist im Alltag gefaehrlich — wer in den Keybinds
## sitzt und zuruecksetzen will, verliert sonst nebenbei Lautstaerke,
## Aufloesung und Minimap-Einstellungen. Der Buttontext nennt deshalb
## immer explizit, WAS zurueckgesetzt wird.

signal back_pressed

@onready var tab_container: TabContainer = $Panel/VBoxContainer/TabContainer

# --- General (Original-Pfade, werden zur Laufzeit umgehaengt) ---
@onready var hud_visible_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/General/HUDVisibleRow
@onready var hud_visible_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/HUDVisibleRow/HUDVisibleCheck
@onready var minimap_rotate_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/General/MinimapRotateRow
@onready var minimap_rotate_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/MinimapRotateRow/MinimapRotateCheck
@onready var crt_filter_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/General/CRTFilterRow
@onready var crt_filter_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/CRTFilterRow/CRTFilterCheck
@onready var screen_shake_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/General/ScreenShakeRow
@onready var screen_shake_check: CheckButton = $Panel/VBoxContainer/TabContainer/General/ScreenShakeRow/ScreenShakeCheck
@onready var colorblind_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/General/ColorblindRow
@onready var colorblind_option: OptionButton = $Panel/VBoxContainer/TabContainer/General/ColorblindRow/ColorblindOption

# --- Video ---
@onready var display_mode_option: OptionButton = $Panel/VBoxContainer/TabContainer/Video/DisplayModeRow/DisplayModeOption
@onready var vsync_check: CheckButton = $Panel/VBoxContainer/TabContainer/Video/VSyncRow/VSyncCheck
@onready var fps_limit_option: OptionButton = $Panel/VBoxContainer/TabContainer/Video/FPSLimitRow/FPSLimitOption

# --- Audio ---
@onready var master_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/Audio/MasterVolumeRow
@onready var master_slider: HSlider = $Panel/VBoxContainer/TabContainer/Audio/MasterVolumeRow/MasterVolumeSlider
@onready var music_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/Audio/MusicVolumeRow
@onready var music_slider: HSlider = $Panel/VBoxContainer/TabContainer/Audio/MusicVolumeRow/MusicVolumeSlider
@onready var sfx_row: HBoxContainer = $Panel/VBoxContainer/TabContainer/Audio/SFXVolumeRow
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/TabContainer/Audio/SFXVolumeRow/SFXVolumeSlider

# --- Controls ---
@onready var sensitivity_slider: HSlider = $Panel/VBoxContainer/TabContainer/Controls/SensitivityRow/SensitivitySlider
@onready var sensitivity_value_label: Label = $Panel/VBoxContainer/TabContainer/Controls/SensitivityRow/SensitivityValueLabel
@onready var keybinds_container: VBoxContainer = $Panel/VBoxContainer/TabContainer/Controls/KeybindsContainer

# --- Footer ---
@onready var conflict_label: Label = $Panel/VBoxContainer/ConflictLabel
@onready var reset_button: Button = $Panel/VBoxContainer/BottomRow/ResetButton
@onready var back_button: Button = $Panel/VBoxContainer/BottomRow/BackButton

@export var conflict_warning_duration: float = 2.5

## Breite der Beschriftungsspalte in den Einstellungszeilen.
const LABEL_WIDTH: float = 240.0
## Einrueckung der Zeilen innerhalb einer Klapp-Gruppe.
const GROUP_INDENT: float = 14.0
## Breite einer Keybind-Spalte (Label + Button).
const KEYBIND_LABEL_WIDTH: float = 170.0
const KEYBIND_BUTTON_WIDTH: float = 130.0
## Anzahl der NEBENEINANDER stehenden Keybind-Paare.
const KEYBIND_COLUMNS: int = 2

const FPS_OPTIONS: Array[int] = [30, 60, 120, 144, 240, 0]

## Tab-Node-Name -> Anzeigename fuer den Reset-Button. Der Node-Name ist
## die stabile Zuordnung; der Tab-TITEL kann sich durch Uebersetzungen
## oder Umbenennen im Editor aendern und waere als Schluessel unsicher.
const TAB_RESET_LABELS: Dictionary = {
	"General": "Allgemein zuruecksetzen",
	"Video": "Video zuruecksetzen",
	"Audio": "Audio zuruecksetzen",
	"Controls": "Steuerung zuruecksetzen",
}

var _rebinding_action: String = ""
var _keybind_buttons: Dictionary = {}

# --- Gruppen-Infrastruktur (General-Tab) ---
var _general_content: VBoxContainer = null
var _group_bodies: Dictionary = {}     # group_id (String) -> VBoxContainer
var _group_headers: Dictionary = {}    # group_id (String) -> Button
var _group_titles: Dictionary = {}     # group_id (String) -> String

# --- Modulares HUD-Dropdown ---
var _hud_dropdown_button: Button = null
var _hud_elements_box: VBoxContainer = null
var _hud_element_checks: Dictionary = {}  # element (String) -> CheckButton
var _hud_dropdown_open: bool = false

# --- Minimap-Steuerelemente (alle zur Laufzeit erzeugt) ---
var _minimap_zoom_slider: HSlider = null
var _minimap_ui_scale_slider: HSlider = null
var _minimap_opacity_slider: HSlider = null
var _minimap_grid_placement_option: OptionButton = null
var _minimap_arrow_check: CheckButton = null
var _minimap_coords_check: CheckButton = null
var _minimap_zone_check: CheckButton = null
## slider -> Wert-Label.
var _slider_value_labels: Dictionary = {}
## Verhindert, dass _refresh_from_settings() beim Setzen der Slider-Werte
## deren value_changed feuert und dadurch sofort wieder save_settings()
## ausloest (Schreibsturm auf settings.cfg beim Menue-Oeffnen).
var _suppress_signals: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	z_index = PauseMenu.Z_INDEX_MENU + 10

	_fix_panel_background()
	_setup_slider_ranges()
	_populate_option_buttons()
	_hide_missing_audio_buses()

	conflict_label.visible = false

	_connect_signals()

	# Reihenfolge ist wichtig: erst die Gruppen-Container anlegen und die
	# bestehenden Zeilen einsortieren, DANN die dynamischen Inhalte
	# (HUD-Dropdown, Minimap-Regler) in die fertigen Gruppen haengen.
	_build_general_layout()
	_build_hud_element_dropdown()
	_build_minimap_group()

	_build_keybind_rows()
	_refresh_from_settings()
	_refresh_hud_element_checks()
	_update_reset_button_label()


# Panel hat opaken Standardhintergrund — fix auf halbtransparent damit der
# BackgroundBlur (flaches, dunkles ColorRect) dahinter sichtbar wird.
func _fix_panel_background() -> void:
	var panel := get_node_or_null("Panel") as Panel
	if panel == null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.82)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	panel.add_theme_stylebox_override("panel", style)


func _setup_slider_ranges() -> void:
	sensitivity_slider.min_value = 0.0005
	sensitivity_slider.max_value = 0.01
	sensitivity_slider.step = 0.0001

	for slider in [master_slider, music_slider, sfx_slider]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01


func _populate_option_buttons() -> void:
	display_mode_option.clear()
	display_mode_option.add_item("Windowed", SettingsManager.DISPLAY_MODE_WINDOWED)
	display_mode_option.add_item("Fullscreen", SettingsManager.DISPLAY_MODE_FULLSCREEN)
	display_mode_option.add_item("Borderless Windowed", SettingsManager.DISPLAY_MODE_BORDERLESS)

	fps_limit_option.clear()
	for fps in FPS_OPTIONS:
		var label: String = "Unlimited" if fps == 0 else "%d FPS" % fps
		fps_limit_option.add_item(label, fps)

	colorblind_option.clear()
	colorblind_option.add_item("Off", SettingsManager.COLORBLIND_OFF)
	colorblind_option.add_item("Protanopia", SettingsManager.COLORBLIND_PROTANOPIA)
	colorblind_option.add_item("Deuteranopia", SettingsManager.COLORBLIND_DEUTERANOPIA)
	colorblind_option.add_item("Tritanopia", SettingsManager.COLORBLIND_TRITANOPIA)


func _hide_missing_audio_buses() -> void:
	music_row.visible = SettingsManager.has_audio_bus("Music")
	sfx_row.visible = SettingsManager.has_audio_bus("SFX")


func _connect_signals() -> void:
	hud_visible_check.toggled.connect(_on_hud_visible_toggled)
	minimap_rotate_check.toggled.connect(_on_minimap_rotate_toggled)
	crt_filter_check.toggled.connect(_on_crt_filter_toggled)
	screen_shake_check.toggled.connect(_on_screen_shake_toggled)
	colorblind_option.item_selected.connect(_on_colorblind_selected)

	display_mode_option.item_selected.connect(_on_display_mode_selected)
	vsync_check.toggled.connect(_on_vsync_toggled)
	fps_limit_option.item_selected.connect(_on_fps_limit_selected)

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)

	tab_container.tab_changed.connect(_on_tab_changed)

	SettingsManager.keybind_changed.connect(_on_keybind_changed)


func open() -> void:
	visible = true
	_refresh_from_settings()
	_refresh_hud_element_checks()
	_update_reset_button_label()


func close() -> void:
	visible = false
	_rebinding_action = ""


func is_rebinding() -> bool:
	return _rebinding_action != ""


# ============================================================================
# General-Tab: Gruppierung
# ============================================================================

## Baut die Klapp-Gruppen und sortiert die bestehenden .tscn-Zeilen ein.
##
## Der General-Tab wird zusaetzlich in einen ScrollContainer gepackt: mit
## Minimap-Block sind es ueber 20 Zeilen, die sonst unten aus dem Panel
## herauslaufen wuerden (VBoxContainer clippt nicht, er schiebt einfach
## ueber den Rand hinaus — man sieht die Zeilen dann gar nicht).
func _build_general_layout() -> void:
	var general := tab_container.get_node_or_null("General") as VBoxContainer
	if general == null:
		push_warning("SettingsMenu: Tab 'General' nicht gefunden — Gruppierung wird uebersprungen.")
		return

	# Bestehende Zeilen zwischenspeichern, BEVOR der Scroll-Container
	# eingehaengt wird — sonst wandert er beim Iterieren mit durch.
	var existing_rows: Array[Node] = []
	for child in general.get_children():
		existing_rows.append(child)

	var scroll := ScrollContainer.new()
	scroll.name = "GeneralScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	general.add_child(scroll)

	_general_content = VBoxContainer.new()
	_general_content.name = "GeneralContent"
	_general_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_general_content.add_theme_constant_override("separation", 4)
	scroll.add_child(_general_content)

	_create_group("hud", "HUD")
	_create_group("minimap", "MINIMAP")
	_create_group("visuals", "DARSTELLUNG & BARRIEREFREIHEIT")

	_move_row_to_group(hud_visible_row, "hud")
	_move_row_to_group(minimap_rotate_row, "minimap")
	_move_row_to_group(crt_filter_row, "visuals")
	_move_row_to_group(screen_shake_row, "visuals")
	_move_row_to_group(colorblind_row, "visuals")

	# Falls in der .tscn spaeter Zeilen dazukommen, die hier niemand
	# einsortiert hat: nicht verschlucken, sondern unten anhaengen. Ohne
	# das waeren sie nach dem Umbau unsichtbar (sie blieben Kind von
	# "general", stuenden aber hinter dem ScrollContainer).
	for row in existing_rows:
		if row.get_parent() == general and row != scroll:
			row.reparent(_general_content)


## Legt eine Klapp-Gruppe an: Kopfzeile (Button) + eingerueckter Koerper.
func _create_group(group_id: String, title: String) -> VBoxContainer:
	var header := Button.new()
	header.name = "Group_%s_Header" % group_id
	header.toggle_mode = true
	header.button_pressed = true
	header.flat = true
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.focus_mode = Control.FOCUS_NONE
	_general_content.add_child(header)

	var body := VBoxContainer.new()
	body.name = "Group_%s_Body" % group_id
	body.add_theme_constant_override("separation", 2)
	_general_content.add_child(body)

	var separator := HSeparator.new()
	separator.name = "Group_%s_Separator" % group_id
	_general_content.add_child(separator)

	_group_headers[group_id] = header
	_group_bodies[group_id] = body
	_group_titles[group_id] = title

	header.toggled.connect(_on_group_toggled.bind(group_id))
	_update_group_header(group_id)
	return body


func _on_group_toggled(is_open: bool, group_id: String) -> void:
	var body: VBoxContainer = _group_bodies.get(group_id)
	if body:
		body.visible = is_open
	_update_group_header(group_id)


func _update_group_header(group_id: String) -> void:
	var header: Button = _group_headers.get(group_id)
	if header == null:
		return
	var arrow: String = "v" if header.button_pressed else ">"
	header.text = "%s  %s" % [arrow, _group_titles.get(group_id, group_id)]


## Haengt eine bestehende .tscn-Zeile in eine Gruppe und rueckt sie ein.
## Die Einrueckung passiert ueber einen Spacer als erstes Kind — nicht
## ueber theme_constant, weil die Zeilen HBoxContainer sind und dort kein
## Margin-Konstrukt existiert.
func _move_row_to_group(row: Control, group_id: String) -> void:
	var body: VBoxContainer = _group_bodies.get(group_id)
	if body == null or row == null:
		return
	row.reparent(body)
	if row is HBoxContainer and not row.has_node("GroupIndent"):
		var spacer := Control.new()
		spacer.name = "GroupIndent"
		spacer.custom_minimum_size = Vector2(GROUP_INDENT, 0)
		row.add_child(spacer)
		row.move_child(spacer, 0)


# ============================================================================
# Minimap-Gruppe
# ============================================================================

## Baut alle Minimap-Regler in die Gruppe "minimap". Die Zeile
## "Mit Spieler drehen" liegt bereits dort (aus der .tscn umgehaengt).
##
## BEWUSST NICHT HIER: ein Regler fuer den Grosskarten-Zoom. Der laeuft
## ueber das Mausrad direkt auf der offenen Karte (minimap.gd) — ein
## zusaetzlicher Schieber waere eine zweite Bedienung fuer dieselbe Sache
## und wuerde bei jeder Mausrad-Nutzung veralten.
## Ebenfalls entfallen: "Groesse Raum-Grid". Das Grid hat mit
## grid_placement bereits eine sinnvolle Steuerung; ein Scale-Regler
## daneben hat in der Praxis nur das Layout zerschossen.
func _build_minimap_group() -> void:
	var body: VBoxContainer = _group_bodies.get("minimap")
	if body == null:
		return

	_minimap_zoom_slider = _add_slider_row(
		body, "Zoom (Karte)",
		SettingsManager.MINIMAP_ZOOM_MIN, SettingsManager.MINIMAP_ZOOM_MAX, 0.05,
		_on_minimap_zoom_changed)

	_minimap_ui_scale_slider = _add_slider_row(
		body, "Groesse der Minimap",
		SettingsManager.MINIMAP_UI_SCALE_MIN, SettingsManager.MINIMAP_UI_SCALE_MAX, 0.05,
		_on_minimap_ui_scale_changed)

	_minimap_opacity_slider = _add_slider_row(
		body, "Deckkraft",
		SettingsManager.MINIMAP_OPACITY_MIN, SettingsManager.MINIMAP_OPACITY_MAX, 0.02,
		_on_minimap_opacity_changed)

	_minimap_grid_placement_option = _add_option_row(body, "Raum-Grid Position")
	_minimap_grid_placement_option.add_item("Unter der Karte", SettingsManager.MINIMAP_GRID_BELOW)
	_minimap_grid_placement_option.add_item("In der Karte (Ecke)", SettingsManager.MINIMAP_GRID_INSIDE)
	_minimap_grid_placement_option.add_item("Ausgeblendet", SettingsManager.MINIMAP_GRID_HIDDEN)
	_minimap_grid_placement_option.item_selected.connect(_on_minimap_grid_placement_selected)

	_minimap_arrow_check = _add_check_row(body, "Spielerpfeil anzeigen", _on_minimap_arrow_toggled)
	_minimap_coords_check = _add_check_row(body, "Koordinaten anzeigen", _on_minimap_coords_toggled)
	_minimap_zone_check = _add_check_row(body, "Zonen-/Etagenname anzeigen", _on_minimap_zone_toggled)

	var hint := Label.new()
	hint.text = "    Grosskarte (M): Mausrad = Zoom auf Cursor, Ziehen = verschieben"
	hint.add_theme_font_size_override("font_size", 12)
	hint.modulate = Color(1, 1, 1, 0.55)
	body.add_child(hint)

	var reset_row := HBoxContainer.new()
	body.add_child(reset_row)
	var reset_spacer := Control.new()
	reset_spacer.custom_minimum_size = Vector2(GROUP_INDENT, 0)
	reset_row.add_child(reset_spacer)
	var minimap_reset := Button.new()
	minimap_reset.text = "Nur Minimap zuruecksetzen"
	reset_row.add_child(minimap_reset)
	minimap_reset.pressed.connect(_on_minimap_reset_pressed)


## Baut eine Zeile "Label | Slider | Wert" und haengt den Callback an.
func _add_slider_row(parent: VBoxContainer, label_text: String,
		min_value: float, max_value: float, step: float,
		callback: Callable) -> HSlider:
	var row := HBoxContainer.new()
	parent.add_child(row)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(GROUP_INDENT, 0)
	row.add_child(spacer)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
	row.add_child(label)

	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.custom_minimum_size = Vector2(200, 0)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)

	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(56, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	_slider_value_labels[slider] = value_label
	slider.value_changed.connect(callback)
	return slider


func _add_option_row(parent: VBoxContainer, label_text: String) -> OptionButton:
	var row := HBoxContainer.new()
	parent.add_child(row)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(GROUP_INDENT, 0)
	row.add_child(spacer)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
	row.add_child(label)

	var option := OptionButton.new()
	option.custom_minimum_size = Vector2(200, 0)
	row.add_child(option)
	return option


func _add_check_row(parent: VBoxContainer, label_text: String, callback: Callable) -> CheckButton:
	var row := HBoxContainer.new()
	parent.add_child(row)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(GROUP_INDENT, 0)
	row.add_child(spacer)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
	row.add_child(label)

	var check := CheckButton.new()
	row.add_child(check)
	check.toggled.connect(callback)
	return check


func _set_slider_display(slider: HSlider, text: String) -> void:
	var label: Label = _slider_value_labels.get(slider)
	if label:
		label.text = text


func _refresh_minimap_labels() -> void:
	_set_slider_display(_minimap_zoom_slider, "%.2fx" % SettingsManager.minimap_zoom)
	_set_slider_display(_minimap_ui_scale_slider, "%.2fx" % SettingsManager.minimap_ui_scale)
	_set_slider_display(_minimap_opacity_slider, "%d%%" % int(round(SettingsManager.minimap_opacity * 100.0)))


# ============================================================================
# Callbacks
# ============================================================================

func _on_hud_visible_toggled(is_on: bool) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_hud_visible(is_on)


func _on_minimap_rotate_toggled(is_on: bool) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_minimap_rotate_with_player(is_on)


func _on_crt_filter_toggled(is_on: bool) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_crt_filter_enabled(is_on)


func _on_screen_shake_toggled(is_on: bool) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_screen_shake_enabled(is_on)


func _on_vsync_toggled(is_on: bool) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_vsync(is_on)


func _on_master_volume_changed(value: float) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_volume("Master", value)


func _on_music_volume_changed(value: float) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_volume("Music", value)


func _on_sfx_volume_changed(value: float) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_volume("SFX", value)


func _on_colorblind_selected(index: int) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_colorblind_mode(colorblind_option.get_item_id(index))


func _on_display_mode_selected(index: int) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_display_mode(display_mode_option.get_item_id(index))


func _on_fps_limit_selected(index: int) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_fps_limit(fps_limit_option.get_item_id(index))


func _on_sensitivity_changed(value: float) -> void:
	sensitivity_value_label.text = str(int(round(value * 10000.0)))
	if _suppress_signals:
		return
	SettingsManager.set_sensitivity(value)


func _on_minimap_zoom_changed(value: float) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_minimap_zoom(value)
	_refresh_minimap_labels()


func _on_minimap_ui_scale_changed(value: float) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_minimap_ui_scale(value)
	_refresh_minimap_labels()


func _on_minimap_opacity_changed(value: float) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_minimap_opacity(value)
	_refresh_minimap_labels()


func _on_minimap_grid_placement_selected(index: int) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_minimap_grid_placement(_minimap_grid_placement_option.get_item_id(index))


func _on_minimap_arrow_toggled(is_on: bool) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_minimap_show_player_arrow(is_on)


func _on_minimap_coords_toggled(is_on: bool) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_minimap_show_coords(is_on)


func _on_minimap_zone_toggled(is_on: bool) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_minimap_show_zone_label(is_on)


func _on_minimap_reset_pressed() -> void:
	SettingsManager.reset_minimap_settings()
	_refresh_from_settings()


# ============================================================================
# Reset — nur die aktuelle Seite
# ============================================================================

## Liefert den Node-Namen des aktuell sichtbaren Tabs. get_tab_control()
## statt get_tab_title(): der Titel ist Anzeigetext und kann sich aendern,
## der Node-Name ist die stabile Kennung.
func _current_tab_name() -> String:
	var control: Control = tab_container.get_tab_control(tab_container.current_tab)
	return control.name if control else ""


func _update_reset_button_label() -> void:
	var tab_name: String = _current_tab_name()
	reset_button.text = TAB_RESET_LABELS.get(tab_name, "Seite zuruecksetzen")


func _on_tab_changed(_index: int) -> void:
	_update_reset_button_label()
	# Ein laufendes Rebinding beim Tab-Wechsel abbrechen: sonst wartet der
	# unsichtbare Controls-Tab weiter auf einen Tastendruck und schluckt
	# den naechsten Klick des Spielers in einem ganz anderen Tab.
	if _rebinding_action != "":
		var cancelled: String = _rebinding_action
		_rebinding_action = ""
		_refresh_keybind_label(cancelled)


func _on_reset_pressed() -> void:
	match _current_tab_name():
		"General":
			SettingsManager.reset_general_settings()
		"Video":
			SettingsManager.reset_video_settings()
		"Audio":
			SettingsManager.reset_audio_settings()
		"Controls":
			SettingsManager.reset_controls_settings()
		_:
			push_warning("SettingsMenu: Unbekannter Tab — Reset uebersprungen.")
			return

	_refresh_from_settings()
	_refresh_hud_element_checks()


func _on_back_pressed() -> void:
	back_pressed.emit()


# ============================================================================
# Zustand aus dem SettingsManager zurueckspiegeln
# ============================================================================

## _suppress_signals kapselt den GESAMTEN Block: Sliders und OptionButtons
## feuern beim programmatischen Setzen ihre Change-Signale. Ohne die Sperre
## wuerde jedes Oeffnen des Menues mehrfach save_settings() ausloesen — und
## bei geclampten Werten sogar den gespeicherten Wert veraendern.
func _refresh_from_settings() -> void:
	_suppress_signals = true

	hud_visible_check.button_pressed = SettingsManager.hud_visible
	minimap_rotate_check.button_pressed = SettingsManager.minimap_rotate_with_player
	crt_filter_check.button_pressed = SettingsManager.crt_filter_enabled
	screen_shake_check.button_pressed = SettingsManager.screen_shake_enabled
	_select_option_by_id(colorblind_option, SettingsManager.colorblind_mode)

	_select_option_by_id(display_mode_option, SettingsManager.display_mode)
	vsync_check.button_pressed = SettingsManager.vsync_enabled
	_select_option_by_id(fps_limit_option, SettingsManager.fps_limit)

	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume

	sensitivity_slider.value = SettingsManager.mouse_sensitivity
	sensitivity_value_label.text = str(int(round(SettingsManager.mouse_sensitivity * 10000.0)))

	if _minimap_zoom_slider:
		_minimap_zoom_slider.value = SettingsManager.minimap_zoom
	if _minimap_ui_scale_slider:
		_minimap_ui_scale_slider.value = SettingsManager.minimap_ui_scale
	if _minimap_opacity_slider:
		_minimap_opacity_slider.value = SettingsManager.minimap_opacity
	if _minimap_grid_placement_option:
		_select_option_by_id(_minimap_grid_placement_option, SettingsManager.minimap_grid_placement)
	if _minimap_arrow_check:
		_minimap_arrow_check.button_pressed = SettingsManager.minimap_show_player_arrow
	if _minimap_coords_check:
		_minimap_coords_check.button_pressed = SettingsManager.minimap_show_coords
	if _minimap_zone_check:
		_minimap_zone_check.button_pressed = SettingsManager.minimap_show_zone_label

	_refresh_minimap_labels()

	_suppress_signals = false


func _select_option_by_id(option: OptionButton, id: int) -> void:
	for i in option.item_count:
		if option.get_item_id(i) == id:
			option.selected = i
			return


# ============================================================================
# Keybinds — zweispaltiges Raster
# ============================================================================

## Baut die Tastenbelegung als GridContainer mit KEYBIND_COLUMNS Paaren
## nebeneinander. Bei 12 Actions ergibt das 6 Zeilen statt 12.
##
## columns = KEYBIND_COLUMNS * 2, weil jedes Paar zwei Zellen belegt
## (Beschriftung + Button). Godots GridContainer fuellt zeilenweise, die
## Reihenfolge der Actions bleibt dadurch von links nach rechts lesbar.
func _build_keybind_rows() -> void:
	for child in keybinds_container.get_children():
		child.queue_free()
	_keybind_buttons.clear()

	var grid := GridContainer.new()
	grid.name = "KeybindGrid"
	grid.columns = KEYBIND_COLUMNS * 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 4)
	keybinds_container.add_child(grid)

	for action in SettingsManager.REBINDABLE_ACTIONS.keys():
		var display_name: String = SettingsManager.REBINDABLE_ACTIONS[action]

		var label := Label.new()
		label.text = display_name
		label.custom_minimum_size = Vector2(KEYBIND_LABEL_WIDTH, 0)
		label.clip_text = true
		grid.add_child(label)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(KEYBIND_BUTTON_WIDTH, 0)
		grid.add_child(btn)
		_keybind_buttons[action] = btn

		_refresh_keybind_label(action)
		btn.pressed.connect(_on_keybind_button_pressed.bind(action))


func _refresh_keybind_label(action: String) -> void:
	var btn: Button = _keybind_buttons.get(action)
	if btn == null:
		return

	if _rebinding_action == action:
		btn.text = "[ ... ]"
		return

	var events := InputMap.action_get_events(action)
	if events.is_empty():
		btn.text = "---"
		return

	# get_action_event() statt events[0]: bei ui_up/ui_left etc. haengen
	# zwei Events an derselben Action (Pfeiltaste + WASD). events[0] waere
	# die Pfeiltaste — der Button wuerde also "Up" statt "W" anzeigen,
	# obwohl der Spieler mit W laeuft.
	var ev: InputEvent = SettingsManager.get_action_event(action)
	if ev == null:
		btn.text = "---"
	elif ev is InputEventKey:
		btn.text = OS.get_keycode_string(ev.physical_keycode)
	elif ev is InputEventMouseButton:
		btn.text = "Mouse %d" % ev.button_index
	else:
		btn.text = ev.as_text()


func _on_keybind_button_pressed(action: String) -> void:
	if _rebinding_action != "":
		return
	_rebinding_action = action
	_refresh_keybind_label(action)


func _on_keybind_changed(action: String) -> void:
	_refresh_keybind_label(action)


func _input(event: InputEvent) -> void:
	if not visible or _rebinding_action == "":
		return

	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		var cancelled: String = _rebinding_action
		_rebinding_action = ""
		_refresh_keybind_label(cancelled)
		get_viewport().set_input_as_handled()
		return

	var capture_event: InputEvent = null
	if event is InputEventKey and event.pressed and not event.echo:
		capture_event = InputEventKey.new()
		capture_event.physical_keycode = event.physical_keycode
	elif event is InputEventMouseButton and event.pressed:
		capture_event = InputEventMouseButton.new()
		capture_event.button_index = event.button_index

	if capture_event == null:
		return

	var action: String = _rebinding_action
	var conflict: String = SettingsManager.find_conflicting_action(capture_event, action)

	_rebinding_action = ""
	SettingsManager.rebind_action(action, capture_event)
	_refresh_keybind_label(action)

	if conflict != "":
		var conflict_name: String = SettingsManager.REBINDABLE_ACTIONS.get(conflict, conflict)
		conflict_label.text = "Hinweis: Taste war bereits '%s' zugewiesen." % conflict_name
		conflict_label.visible = true
		var timer := get_tree().create_timer(conflict_warning_duration)
		timer.timeout.connect(func() -> void: conflict_label.visible = false)

	get_viewport().set_input_as_handled()


# ============================================================================
# Modulares HUD-Dropdown (Gruppe "hud")
# ============================================================================

func _build_hud_element_dropdown() -> void:
	var body: VBoxContainer = _group_bodies.get("hud")
	if body == null:
		push_warning("SettingsMenu: HUD-Gruppe fehlt — HUD-Dropdown wird uebersprungen.")
		return

	var toggle_row := HBoxContainer.new()
	body.add_child(toggle_row)

	var toggle_spacer := Control.new()
	toggle_spacer.custom_minimum_size = Vector2(GROUP_INDENT, 0)
	toggle_row.add_child(toggle_spacer)

	_hud_dropdown_button = Button.new()
	_hud_dropdown_button.name = "HUDElementsDropdown"
	_hud_dropdown_button.toggle_mode = true
	_hud_dropdown_button.flat = true
	_hud_dropdown_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	toggle_row.add_child(_hud_dropdown_button)

	_hud_elements_box = VBoxContainer.new()
	_hud_elements_box.name = "HUDElementsBox"
	_hud_elements_box.visible = false
	_hud_elements_box.add_theme_constant_override("separation", 2)
	body.add_child(_hud_elements_box)

	for element in SettingsManager.HUD_ELEMENTS.keys():
		var row := HBoxContainer.new()
		_hud_elements_box.add_child(row)

		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(GROUP_INDENT * 2.0, 0)
		row.add_child(spacer)

		var label := Label.new()
		label.text = SettingsManager.HUD_ELEMENTS[element]
		label.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
		row.add_child(label)

		var check := CheckButton.new()
		row.add_child(check)
		_hud_element_checks[element] = check

		# bind() haengt die Element-ID an — sonst wuesste der Callback
		# nicht, WELCHE Checkbox geschaltet wurde.
		check.toggled.connect(_on_hud_element_toggled.bind(element))

	_hud_dropdown_button.toggled.connect(_on_hud_dropdown_toggled)
	_update_hud_dropdown_label()


func _on_hud_dropdown_toggled(pressed: bool) -> void:
	_hud_dropdown_open = pressed
	if _hud_elements_box:
		_hud_elements_box.visible = pressed
	_update_hud_dropdown_label()


func _update_hud_dropdown_label() -> void:
	if _hud_dropdown_button == null:
		return
	var arrow: String = "v" if _hud_dropdown_open else ">"
	var active: int = 0
	for element in SettingsManager.HUD_ELEMENTS.keys():
		if SettingsManager.is_hud_element_visible(element):
			active += 1
	_hud_dropdown_button.text = "%s  HUD-Elemente  (%d/%d aktiv)" % [
		arrow, active, SettingsManager.HUD_ELEMENTS.size()
	]


func _on_hud_element_toggled(is_on: bool, element: String) -> void:
	if _suppress_signals:
		return
	SettingsManager.set_hud_element_visible(element, is_on)
	_update_hud_dropdown_label()


## set_pressed_no_signal() statt button_pressed, sonst wuerde das Setzen
## selbst wieder toggled() feuern.
func _refresh_hud_element_checks() -> void:
	for element in _hud_element_checks.keys():
		var check: CheckButton = _hud_element_checks[element]
		if is_instance_valid(check):
			check.set_pressed_no_signal(SettingsManager.is_hud_element_visible(element))
	_update_hud_dropdown_label()
