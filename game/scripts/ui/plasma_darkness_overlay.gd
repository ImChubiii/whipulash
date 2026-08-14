extends Control
class_name PlasmaDarknessOverlay

# ============================================================================
# PlasmaDarknessOverlay — starke Bildschirm-Vignette waehrend ein
# Plasmastrahl-Bot (siehe scripts/enemies/plasma_beam_bot.gd) in Reichweite
# auflaedt oder feuert.
# ============================================================================
# URSPRUENGLICHE IDEE war ein kompletter Blackout, damit man einen Abgrund
# in der Naehe gar nicht mehr sieht und "einfach in den Tod faellt". Bewusst
# NICHT so umgesetzt: ein Tod ohne jede Gegenwehr (man sieht buchstaeblich
# nichts) ist kein faires Risiko, sondern reiner Zufall. Stattdessen eine
# sehr starke, aber nie ganz blickdichte Vignette (siehe MAX_OPACITY) - der
# Bildschirmrand wird praktisch schwarz, ein kleiner Kernbereich in der Mitte
# bleibt sichtbar. Wer die Kante eines Abgrunds im Blick behaelt, kann noch
# reagieren; wer nicht hinschaut, sieht sie zu spaet.
#
# Gleiches Baumuster wie low_hp_vignette.gd (radialer GradientTexture2D-
# Vignette statt Shader/Asset), aber Distanz-getrieben statt HP-getrieben:
# jeder Frame sucht ueber die Gruppe "enemies" nach aktiven Plasmastrahl-Bots
# in der Naehe des Spielers, statt sich an ein einzelnes Signal zu binden -
# es koennen gleichzeitig mehrere Bots existieren/despawnen.

const ACTIVATION_RADIUS: float = 16.0
const FADE_MARGIN: float = 6.0
const MAX_OPACITY: float = 0.72
const CLEAR_CENTER_RADIUS: float = 0.26
const FADE_SPEED: float = 3.0

@export var vignette_color: Color = Color(0.05, 0.0, 0.07, 1.0)

var _overlay: TextureRect = null
var _current_alpha: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_overlay()


func _build_overlay() -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, CLEAR_CENTER_RADIUS, 1.0])
	gradient.colors = PackedColorArray([
		Color(vignette_color.r, vignette_color.g, vignette_color.b, 0.0),
		Color(vignette_color.r, vignette_color.g, vignette_color.b, 0.0),
		Color(vignette_color.r, vignette_color.g, vignette_color.b, 1.0),
	])

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256

	_overlay = TextureRect.new()
	_overlay.texture = texture
	_overlay.stretch_mode = TextureRect.STRETCH_SCALE
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.modulate.a = 0.0
	add_child(_overlay)


func _process(delta: float) -> void:
	if _overlay == null:
		return

	var target: float = _compute_target_alpha()
	_current_alpha = move_toward(_current_alpha, target, FADE_SPEED * delta)
	_overlay.modulate.a = _current_alpha


## Naehester aktiver Plasmastrahl-Bot bestimmt die Staerke - lineares
## Einblenden zwischen ACTIVATION_RADIUS+FADE_MARGIN (0) und ACTIVATION_RADIUS
## (voll), statt hart an- und auszuschalten.
func _compute_target_alpha() -> float:
	if not PartyManager.has_player():
		return 0.0
	var player: CharacterBody3D = PartyManager.player
	if player == null or not is_instance_valid(player):
		return 0.0

	var closest: float = INF
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not (node is PlasmaBeamBot):
			continue
		var bot: PlasmaBeamBot = node as PlasmaBeamBot
		if not is_instance_valid(bot) or not bot.is_beam_active():
			continue
		var dist: float = bot.global_position.distance_to(player.global_position)
		if dist < closest:
			closest = dist

	if closest == INF:
		return 0.0
	if closest <= ACTIVATION_RADIUS:
		return MAX_OPACITY
	if closest >= ACTIVATION_RADIUS + FADE_MARGIN:
		return 0.0

	var t: float = 1.0 - (closest - ACTIVATION_RADIUS) / FADE_MARGIN
	return MAX_OPACITY * t
