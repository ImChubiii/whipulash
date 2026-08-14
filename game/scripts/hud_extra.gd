extends Node

# ============================================================================
# HudExtra — Autoload, das nur noch das Reset-Overlay bereitstellt.
# Muss unter Project Settings -> Autoload als "HudExtra" stehen.
# ============================================================================
#
# WAS SICH GEAENDERT HAT
# ----------------------
# Dieses Autoload hat frueher auch das Stats-Panel und die Item-Anzeige
# gebaut und in einen eigenen CanvasLayer gehaengt. Beides sitzt jetzt als
# echter Node in hud.tscn (BottomLeft/StatsPanel und BottomLeft/ItemBar).
#
# WARUM DER UMZUG RICHTIG IST:
# Es gab damit zwei getrennte HUD-Systeme mit zwei getrennten Layouts, zwei
# Sichtbarkeitslogiken und zwei Stellen, an denen man nach einem verrutschten
# Element sucht. Ein Element, das aussieht wie HUD und sich verhaelt wie HUD,
# gehoert in die HUD-Szene — dann sieht man es im Editor an der richtigen
# Stelle liegen, kann es dort verschieben und muss den Abstand zum Bildrand
# nicht als Konstante in einem Script pflegen.
#
# WAS DER UMZUG KOSTET (bewusst in Kauf genommen):
# Szenen OHNE hud.tscn — also die reinen Testlevel — haben jetzt kein
# Stats-Panel und keine Item-Leiste mehr. Genau dafuer gab es dieses
# Autoload. Wer im Testlevel beides braucht, zieht hud.tscn dort einmal als
# Kind in die Szene; das ist ein Handgriff und dafuer eine Anzeige weniger,
# die sich anders verhaelt als im echten Spiel.
#
# WARUM DAS RESET-OVERLAY HIER BLEIBT:
# Es ist kein HUD-Element, sondern eine Vollbild-Abdunklung, die beim Halten
# von [R] das komplette Spiel verdecken muss — inklusive HUD, Pause-Menue und
# allem anderen. Es braucht deshalb einen eigenen, sehr hohen CanvasLayer und
# PROCESS_MODE_ALWAYS. In hud.tscn waere es zwangslaeufig unter dem HUD und
# wuerde beim Ausblenden des HUD mitverschwinden.

## Sehr hoch: das Overlay muss beim Abblenden ueber Pause- und Death-Screen
## liegen (die sitzen typischerweise bei 100+).
const OVERLAY_LAYER: int = 128

var overlay_layer: CanvasLayer = null
var reset_overlay: ResetOverlay = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_overlay_layer()


func _build_overlay_layer() -> void:
	overlay_layer = CanvasLayer.new()
	overlay_layer.name = "ResetLayer"
	overlay_layer.layer = OVERLAY_LAYER
	overlay_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay_layer)

	reset_overlay = ResetOverlay.new()
	reset_overlay.name = "ResetOverlay"
	overlay_layer.add_child(reset_overlay)


## Schaltet das Reset-Overlay ab — z.B. fuer Screenshots oder Cutscenes, in
## denen ein versehentlich gehaltenes [R] nicht abdunkeln soll.
func set_overlay_enabled(enabled: bool) -> void:
	if overlay_layer:
		overlay_layer.visible = enabled
	if reset_overlay:
		reset_overlay.set_process_input(enabled)
