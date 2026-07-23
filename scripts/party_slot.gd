extends Control
class_name PartySlot

# Eine Charakterkarte rechts im HUD: Portrait, HP-Bar, Name.
# Der aktive Charakter wird groesser skaliert und zeigt zusaetzlich
# den Namen neben der HP-Leiste an.

@onready var panel: Panel = $Panel
@onready var portrait: TextureRect = $Panel/Portrait
@onready var health_bar: ProgressBar = $Panel/HealthBar
@onready var hp_label: Label = $Panel/HealthBar/HpLabel
@onready var name_label: Label = $Panel/NameLabel
@onready var dead_overlay: ColorRect = $Panel/DeadOverlay
@onready var key_hint: Label = $Panel/KeyHint

@export var active_scale: float = 1.0
@export var inactive_scale: float = 0.72

var _index: int = 0
var _is_active: bool = false
var _scale_tween: Tween

func _ready() -> void:
	# Pivot am RECHTEN Rand, damit beim Skalieren die rechte
	# Bildschirmkante buendig bleibt und nichts flattert.
	pivot_offset = Vector2(size.x, size.y * 0.5)

func setup(index: int, set: AbilitySet) -> void:
	_index = index
	key_hint.text = str(index + 1)

	if set == null:
		visible = false
		return

	visible = true
	name_label.text = set.character_name
	if set.portrait:
		portrait.texture = set.portrait

	dead_overlay.visible = false

func set_active(active: bool) -> void:
	_is_active = active

	# Nur der aktive Charakter zeigt den Namen
	name_label.visible = active

	var target: float = active_scale if active else inactive_scale
	if _scale_tween and _scale_tween.is_valid():
		_scale_tween.kill()
	_scale_tween = create_tween()
	_scale_tween.tween_property(self, "scale", Vector2(target, target), 0.22)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if active:
		panel.modulate = Color.WHITE
	else:
		panel.modulate = Color(0.6, 0.6, 0.65, 1.0)

func update_health(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current
	hp_label.text = "%d / %d" % [int(current), int(max_hp)]

	# Farbverlauf: gruen -> gelb -> rot
	var ratio: float = current / max_hp if max_hp > 0.0 else 0.0
	var bar_color: Color
	if ratio > 0.5:
		bar_color = Color(0.9, 0.85, 0.2).lerp(Color(0.35, 0.85, 0.3), (ratio - 0.5) * 2.0)
	else:
		bar_color = Color(0.85, 0.2, 0.2).lerp(Color(0.9, 0.85, 0.2), ratio * 2.0)

	var style: StyleBox = health_bar.get_theme_stylebox("fill")
	if style is StyleBoxFlat:
		var flat: StyleBoxFlat = (style as StyleBoxFlat).duplicate()
		flat.bg_color = bar_color
		health_bar.add_theme_stylebox_override("fill", flat)

	dead_overlay.visible = current <= 0.0

func get_party_index() -> int:
	return _index
