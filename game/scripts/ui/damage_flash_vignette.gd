extends Control
class_name DamageFlashVignette

# ============================================================================
# DamageFlashVignette — kurzer roter Vignetten-Blitz bei erlittenem Schaden.
# ============================================================================
# Ergaenzt low_hp_vignette.gd (die dauerhafte, pulsierende Warnung ab <= 20%
# HP): dieser Blitz feuert bei JEDEM Treffer, unabhaengig vom aktuellen HP-
# Stand, und blendet sofort wieder aus - reines "ich wurde gerade getroffen"-
# Feedback statt eines anhaltenden Warnzustands. Beide Overlays haengen
# unabhaengig voneinander am HUD und ueberlagern sich bei niedrigem Leben
# einfach (Blitz on top of der pulsierenden Basis-Vignette).
#
# Gleiches Bindungs-Muster wie low_hp_vignette.gd (siehe dortiger Kopf-
# kommentar): ueber PartyManager.active_player_changed neu binden, da der
# aktive CharacterBody3D bei jedem Charakterwechsel komplett ausgetauscht
# wird.

@export var vignette_color: Color = Color(0.85, 0.03, 0.03, 1.0)
@export_range(0.0, 1.0) var flash_opacity: float = 0.5
@export var fade_time: float = 0.35

## Wie weit der transparente Kern in die Vignette hineinreicht (Anteil des
## Radius) - siehe low_hp_vignette.gd fuer dieselbe Ueberlegung.
@export_range(0.0, 0.9) var clear_center_radius: float = 0.5

var _overlay: TextureRect = null
var _health: Health = null
var _last_known_health: float = -1.0
var _fade_tween: Tween = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_overlay()

	if not PartyManager.active_player_changed.is_connected(_on_active_player_changed):
		PartyManager.active_player_changed.connect(_on_active_player_changed)
	if PartyManager.has_player():
		_on_active_player_changed(PartyManager.player)


## Identischer radialer Gradient wie low_hp_vignette.gd::_build_overlay() -
## Mitte transparent, Rand voll eingefaerbt, per Code statt Asset.
func _build_overlay() -> void:
	var gradient := Gradient.new()
	var center: float = clampf(clear_center_radius, 0.0, 0.95)
	gradient.offsets = PackedFloat32Array([0.0, center, 1.0])
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


func _on_active_player_changed(new_player: CharacterBody3D) -> void:
	if _health != null and is_instance_valid(_health):
		if _health.health_changed.is_connected(_on_health_changed):
			_health.health_changed.disconnect(_on_health_changed)
	_health = null
	_last_known_health = -1.0

	if new_player == null or not is_instance_valid(new_player):
		return

	var health_node: Node = new_player.find_child("Health", true, false)
	if health_node == null or not (health_node is Health):
		return

	_health = health_node
	_health.health_changed.connect(_on_health_changed)
	# Nur als Referenzwert merken, NICHT _on_health_changed() aufrufen wie bei
	# low_hp_vignette.gd - sonst wuerde ein Charakterwechsel selbst schon
	# einen Blitz ausloesen, weil "current" von der neuen Instanz anders sein
	# kann als der (nicht existente) alte Wert.
	_last_known_health = _health.current_health


## Gleiches Delta-Muster wie player_base.gd::_on_own_health_changed() - nur
## ein tatsaechlicher RUECKGANG loest den Blitz aus, Heilung nicht.
func _on_health_changed(current: float, _max_hp: float) -> void:
	if _last_known_health >= 0.0 and current < _last_known_health:
		_flash()
	_last_known_health = current


func _flash() -> void:
	if _overlay == null:
		return
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_overlay.modulate.a = flash_opacity
	_fade_tween = create_tween()
	_fade_tween.tween_property(_overlay, "modulate:a", 0.0, fade_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
