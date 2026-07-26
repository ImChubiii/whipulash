extends Node

# ============================================================================
# HudExtra — Autoload, das die neuen HUD-Elemente in JEDE Szene einhaengt.
# Muss unter Project Settings -> Autoload als "HudExtra" stehen.
# ============================================================================
#
# WARUM EIN AUTOLOAD STATT NODES IN hud.tscn:
# hud.tscn wird nicht in jeder Szene benutzt (Testlevel, Menue-Szenen), und
# jede Aenderung daran betrifft eine Datei, an der ohnehin schon viel
# haengt. Ein eigener CanvasLayer ueber allem ist unabhaengig davon,
# ueberlebt reload_current_scene() und braucht keinen einzigen Klick im
# Editor.
#
# LAYOUT (geaendert): Stats-Panel und Item-HUD sitzen jetzt BEIDE unten
# links in EINER gemeinsamen Spalte, statt das Stats-Panel oben links unter
# die Minimap zu haengen.
#
# WARUM EINE GEMEINSAME SPALTE UND NICHT ZWEI EINZELN POSITIONIERTE BLOECKE:
# Das Item-HUD waechst mit jedem gesammelten Item nach oben, die Detailkarte
# blendet sich zusaetzlich ein und aus. Zwei unabhaengig positionierte
# Controls in derselben Ecke wuerden sich frueher oder spaeter ueberlappen —
# und zwar genau dann, wenn viele Items im Inventar sind, also im spaeten
# Run. Ein VBoxContainer loest das Stapeln selbst und garantiert, dass
# nichts verdeckt wird.
#
# REIHENFOLGE IN DER SPALTE: Stats stehen UNTEN, das Item-HUD darueber.
# Das Stats-Panel hat eine feste Hoehe und ist der Wert, den man im Kampf
# im Augenwinkel sucht — der darf nicht wandern, sobald ein Item dazukommt.
# Alles Variable waechst deshalb nach oben weg.
#
# LAYER 10: hoch genug, um ueber dem normalen HUD zu liegen, aber unter
# typischen Pause-/Death-Screens (die liegen meist bei 100+). Das
# Reset-Overlay muss beim Abblenden das komplette Spiel verdecken, deshalb
# sitzt es in einem eigenen, hoeheren Layer.

const HUD_LAYER: int = 10
const OVERLAY_LAYER: int = 128

## Abstand der Spalte zum Bildschirmrand.
const MARGIN: float = 14.0
## Luft zwischen Item-HUD und Stats-Panel.
const COLUMN_SEPARATION: int = 8
## Feste Breite des Stats-Panels.
const STATS_WIDTH: float = 190.0

var hud_layer: CanvasLayer = null
var overlay_layer: CanvasLayer = null

var bottom_left_column: VBoxContainer = null
var stats_panel: StatsPanel = null
var item_hud: ItemDescriptionHud = null
var reset_overlay: ResetOverlay = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_layers()


func _build_layers() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "HudExtraLayer"
	hud_layer.layer = HUD_LAYER
	add_child(hud_layer)

	overlay_layer = CanvasLayer.new()
	overlay_layer.name = "ResetLayer"
	overlay_layer.layer = OVERLAY_LAYER
	overlay_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay_layer)

	_build_bottom_left_column()
	_build_reset_overlay()


## Eine Spalte unten links, die nach OBEN waechst.
##
## grow_vertical = GROW_DIRECTION_BEGIN ist hier der entscheidende Teil:
## ohne das waechst ein Container an einem Bottom-Anker nach UNTEN aus dem
## Bild heraus, sobald sein Inhalt groesser wird — der Fehler faellt erst
## auf, wenn man drei Items eingesammelt hat.
func _build_bottom_left_column() -> void:
	bottom_left_column = VBoxContainer.new()
	bottom_left_column.name = "BottomLeftColumn"
	bottom_left_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_left_column.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	bottom_left_column.grow_horizontal = Control.GROW_DIRECTION_END
	bottom_left_column.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom_left_column.position = Vector2(MARGIN, -MARGIN)
	bottom_left_column.alignment = BoxContainer.ALIGNMENT_END
	bottom_left_column.add_theme_constant_override("separation", COLUMN_SEPARATION)
	hud_layer.add_child(bottom_left_column)

	# --- Item-HUD: oben in der Spalte, waechst nach oben weg -----------
	item_hud = ItemDescriptionHud.new()
	item_hud.name = "ItemDescriptionHud"
	# SHRINK_BEGIN: die Karte soll ihre eigene Breite behalten und nicht
	# auf die Spaltenbreite aufgeblasen werden.
	item_hud.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bottom_left_column.add_child(item_hud)

	# --- Stats-Panel: unterste Zeile, feste Position -------------------
	stats_panel = StatsPanel.new()
	stats_panel.name = "StatsPanel"
	stats_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	stats_panel.custom_minimum_size = Vector2(STATS_WIDTH, 0.0)
	bottom_left_column.add_child(stats_panel)


func _build_reset_overlay() -> void:
	reset_overlay = ResetOverlay.new()
	reset_overlay.name = "ResetOverlay"
	overlay_layer.add_child(reset_overlay)


## Blendet alle Zusatz-Elemente aus — z.B. fuer Screenshots oder Cutscenes.
func set_extra_hud_visible(is_visible: bool) -> void:
	if hud_layer:
		hud_layer.visible = is_visible
