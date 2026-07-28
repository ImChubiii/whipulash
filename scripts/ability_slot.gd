
extends Control
class_name AbilitySlot

# Ein einzelnes Ability-Icon im HUD mit Cooldown-Verdunkelung,
# Tastenkuerzel-Label und Ready-Blitz beim Verfuegbarwerden.

@onready var icon: TextureRect = $Icon
@onready var cooldown_overlay: ColorRect = $CooldownOverlay
@onready var cooldown_label: Label = $CooldownLabel
@onready var key_label: Label = $KeyLabel
@onready var ready_flash: ColorRect = $ReadyFlash

var _was_on_cooldown: bool = false

# Schaltet Tastenkuerzel + Cooldown-Zahl aus (HUD-Einstellung
# "Keybinds / Cooldowns"). Der Cooldown-BALKEN bleibt bewusst sichtbar —
# ausgeblendet werden nur die LABELS, sonst waere nicht mehr erkennbar,
# ob eine Faehigkeit ueberhaupt bereit ist.
var _labels_visible: bool = true

func set_labels_visible(is_visible: bool) -> void:
	_labels_visible = is_visible
	if key_label:
		key_label.visible = is_visible
	if cooldown_label:
		cooldown_label.visible = is_visible

func _ready() -> void:
	pivot_offset = size * 0.5
	cooldown_overlay.color = Color(0.0, 0.0, 0.0, 0.65)
	cooldown_overlay.anchor_top = 0.0
	cooldown_overlay.visible = false
	cooldown_label.text = ""
	ready_flash.modulate.a = 0.0

func setup(texture: Texture2D, key_text: String) -> void:
	if texture:
		icon.texture = texture
	key_label.text = key_text
	# Der Sichtbarkeits-Schalter darf durch ein Icon-Update NICHT verloren
	# gehen — sonst blinken die Keybinds bei jedem Charakterwechsel wieder auf.
	key_label.visible = _labels_visible
	cooldown_label.visible = _labels_visible

func set_icon(texture: Texture2D) -> void:
	icon.texture = texture

# percent: 1.0 = gerade gestartet, 0.0 = bereit
func update_cooldown(percent: float, remaining: float) -> void:
	var on_cd: bool = percent > 0.001

	# Overlay schrumpft von oben nach unten weg, waehrend der CD ablaeuft
	cooldown_overlay.visible = on_cd
	cooldown_overlay.anchor_top = 1.0 - percent

	if on_cd:
		icon.modulate = Color(0.45, 0.45, 0.5, 1.0)
		# PHASE 5: Q/E zeigen hier "Raeume bis Ladung" statt Sekunden - das
		# sind immer ganze Zahlen. "%.1f" haette daraus "2.0" statt "2"
		# gemacht, was fuer eine Raumanzahl falsch aussieht. Zeitbasierte
		# Cooldowns (Primary/Secondary/Utility) sind fast nie ganzzahlig
		# und zeigen weiterhin die Nachkommastelle.
		if remaining < 10.0 and remaining != floor(remaining):
			cooldown_label.text = "%.1f" % remaining
		else:
			cooldown_label.text = "%d" % int(remaining)
	else:
		icon.modulate = Color.WHITE
		cooldown_label.text = ""

	if _was_on_cooldown and not on_cd:
		_play_ready_flash()

	_was_on_cooldown = on_cd

func _play_ready_flash() -> void:
	ready_flash.modulate.a = 0.85
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(ready_flash, "modulate:a", 0.0, 0.35)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.08)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.18)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


