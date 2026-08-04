extends Control
class_name LowHpVignette

# ============================================================================
# LowHpVignette — dunkelrote pulsierende Bildschirm-Vignette bei <= 20% HP.
# ============================================================================
# Haengt wie BossHealthBar/ItemDescriptionHud als eigenes Kind am HUD-
# Wurzelknoten (hud.tscn) und baut sein Aussehen komplett per Code - ein per
# Code erzeugter radialer Gradient braucht kein Asset im Repo (derselbe
# Grund wie beim Glow in pickup.gd).
#
# WARUM UEBER PartyManager UND NICHT UEBER EINE FEST GEBUNDENE Health:
# Der aktive CharacterBody3D wird bei jedem Charakterwechsel komplett
# ausgetauscht (siehe party_manager.gd) - eine einmal gebundene Health-
# Referenz waere nach dem ersten Wechsel eine Leiche. active_player_changed
# feuert bei JEDEM Wechsel (auch beim allerersten Spawn) und ist deshalb die
# einzige verlaessliche Stelle, an der sich neu binden laesst.

## Ab welchem Lebens-Anteil die Vignette einblendet.
const HEALTH_THRESHOLD: float = 0.20

@export var vignette_color: Color = Color(0.55, 0.02, 0.02, 1.0)
@export_range(0.0, 1.0) var max_opacity: float = 0.55
@export var pulse_speed: float = 2.6
@export_range(0.0, 1.0) var pulse_strength: float = 0.35
@export var fade_time: float = 0.35

## Wie weit der transparente Kern in die Vignette hineinreicht (Anteil des
## Radius). Groesser = mehr freie Bildmitte, kleiner = fruehere Faerbung.
@export_range(0.0, 0.9) var clear_center_radius: float = 0.55

var _overlay: TextureRect = null
var _health: Health = null
var _time: float = 0.0
var _visible_target: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_overlay()

	if not PartyManager.active_player_changed.is_connected(_on_active_player_changed):
		PartyManager.active_player_changed.connect(_on_active_player_changed)
	if PartyManager.has_player():
		_on_active_player_changed(PartyManager.player)


## Radialer Gradient: Mitte transparent (das eigentliche Kampf-Sichtfeld
## bleibt frei), Rand kraeftig eingefaerbt - der klassische "wenig Leben"-
## Rahmen. GradientTexture2D per Code statt einer .png, damit kein
## Asset-Import noetig ist.
func _build_overlay() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(vignette_color.r, vignette_color.g, vignette_color.b, 0.0))
	gradient.add_point(clampf(clear_center_radius, 0.0, 0.95), Color(vignette_color.r, vignette_color.g, vignette_color.b, 0.0))
	gradient.set_color(1, Color(vignette_color.r, vignette_color.g, vignette_color.b, 1.0))

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 256
	texture.height = 256

	_overlay = TextureRect.new()
	_overlay.texture = texture
	# STRETCH_SCALE: dehnt sich nicht-uniform auf die volle Rechteckgroesse -
	# aus dem Kreis wird dadurch eine Ellipse, die exakt zu den Bildecken
	# passt. Genau das will eine Vignette.
	_overlay.stretch_mode = TextureRect.STRETCH_SCALE
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.modulate.a = 0.0
	add_child(_overlay)


func _process(delta: float) -> void:
	if _overlay == null or not _visible_target:
		return
	_time += delta * pulse_speed
	# Pulsiert zwischen (1 - pulse_strength) und 1.0 der max_opacity - nie
	# ganz auf 0, sonst "verschwindet" die Warnung kurz und wirkt wie ein
	# Darstellungsfehler statt wie ein Herzschlag.
	var pulse: float = 1.0 - pulse_strength * 0.5 * (1.0 + sin(_time))
	_overlay.modulate.a = max_opacity * pulse


func _on_active_player_changed(new_player: CharacterBody3D) -> void:
	if _health != null and is_instance_valid(_health):
		if _health.health_changed.is_connected(_on_health_changed):
			_health.health_changed.disconnect(_on_health_changed)
	_health = null

	if new_player == null or not is_instance_valid(new_player):
		_set_target_visible(false)
		return

	var health_node: Node = new_player.find_child("Health", true, false)
	if health_node == null or not (health_node is Health):
		_set_target_visible(false)
		return

	_health = health_node
	_health.health_changed.connect(_on_health_changed)
	_on_health_changed(_health.current_health, _health.max_health)


func _on_health_changed(current: float, max_hp: float) -> void:
	var ratio: float = current / maxf(max_hp, 0.001)
	_set_target_visible(ratio > 0.0 and ratio <= HEALTH_THRESHOLD)


func _set_target_visible(should_show: bool) -> void:
	if should_show == _visible_target:
		return
	_visible_target = should_show
	if _overlay == null:
		return

	if should_show:
		# Frischer Puls-Einstieg statt mittendrin: sonst kann die Vignette
		# beim genauen Ueberschreiten der Schwelle mit einem sichtbaren
		# Sprung statt sanft einsetzen.
		_time = 0.0
	else:
		var tween: Tween = create_tween()
		tween.tween_property(_overlay, "modulate:a", 0.0, fade_time)
