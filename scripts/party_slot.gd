extends Control
class_name PartySlot

# Eine Charakterkarte rechts im HUD: Portrait, HP-Bar, Name.
# Der aktive Charakter wird groesser skaliert und zeigt zusaetzlich
# den Namen neben der HP-Leiste an. Zusaetzlich: Switch-Cooldown-Anzeige
# (dunkles Overlay + Countdown-Zahl + Ready-Blitz), optisch identisch zum
# Cooldown-Verhalten der AbilitySlots im HUD.

@onready var panel: Panel = $Panel
@onready var portrait: TextureRect = $Panel/Portrait
@onready var health_bar: ProgressBar = $Panel/HealthBar
@onready var hp_label: Label = $Panel/HealthBar/HpLabel
@onready var name_label: Label = $Panel/NameLabel
@onready var dead_overlay: ColorRect = $Panel/DeadOverlay
@onready var key_hint: Label = $Panel/KeyHint
@onready var switch_cooldown_overlay: ColorRect = $Panel/SwitchCooldownOverlay
@onready var switch_cooldown_label: Label = $Panel/SwitchCooldownLabel
@onready var switch_ready_flash: ColorRect = $Panel/SwitchReadyFlash

@export var active_scale: float = 1.0
@export var inactive_scale: float = 0.72

var _index: int = 0
var _is_active: bool = false
var _scale_tween: Tween
var _switch_flash_tween: Tween
var _was_on_switch_cooldown: bool = false

func _ready() -> void:
	# Pivot am RECHTEN Rand, damit beim Skalieren die rechte
	# Bildschirmkante buendig bleibt und nichts flattert.
	pivot_offset = Vector2(size.x, size.y * 0.5)

	switch_cooldown_overlay.color = Color(0.0, 0.0, 0.0, 0.65)
	switch_cooldown_overlay.anchor_top = 0.0
	switch_cooldown_overlay.visible = false
	switch_cooldown_label.text = ""
	switch_ready_flash.modulate.a = 0.0

func setup(index: int, data: CharacterData) -> void:
	_index = index
	key_hint.text = str(index + 1)

	if data == null:
		visible = false
		return

	visible = true
	name_label.text = data.character_name
	if data.portrait:
		portrait.texture = data.portrait

	dead_overlay.visible = false

func set_active(active: bool) -> void:
	_is_active = active

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

# percent: 1.0 = Cooldown gerade erst gestartet, 0.0 = bereit.
# Gleiche Optik/Logik wie AbilitySlot.update_cooldown().
func update_switch_cooldown(percent: float, remaining: float) -> void:
	var on_cd: bool = percent > 0.001

	switch_cooldown_overlay.visible = on_cd
	switch_cooldown_overlay.anchor_top = 1.0 - percent

	if on_cd:
		if remaining < 10.0:
			switch_cooldown_label.text = "%.1f" % remaining
		else:
			switch_cooldown_label.text = "%d" % int(remaining)
	else:
		switch_cooldown_label.text = ""

	if _was_on_switch_cooldown and not on_cd:
		_play_switch_ready_flash()

	_was_on_switch_cooldown = on_cd

func _play_switch_ready_flash() -> void:
	switch_ready_flash.modulate.a = 0.85
	if _switch_flash_tween and _switch_flash_tween.is_valid():
		_switch_flash_tween.kill()
	_switch_flash_tween = create_tween()
	_switch_flash_tween.tween_property(switch_ready_flash, "modulate:a", 0.0, 0.35)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func get_party_index() -> int:
	return _index
