extends Label3D
class_name DamageNumber

## Schadenszahl, die ueber dem getroffenen Ziel aufsteigt und ausblendet.
##
## SCHADENSARTEN: Die Farbe sagt, WOHER der Schaden kam. Das ist in einem
## schnellen Kampf die einzige Rueckmeldung, die man im Vorbeirennen noch
## lesen kann - deshalb bekommt jede Quelle ihre eigene Farbe statt nur
## "normal / crit":
##   NORMAL - Nahkampf-Hitbox (cyan)
##   CRIT   - kritischer Treffer (orange-rot)
##   DASH   - Durchdashen (gelb) - siehe CombatBase.dash_damage
##   ITEM   - Passiv-/Item-Schaden (Tritt, Ramm-Attacke, Geister, ...) -
##            siehe item_behaviours.gd. EIGENE Farbe noetig: ohne die sah
##            Item-Schaden identisch zu einem normalen Treffer aus, obwohl
##            er von einer ganz anderen Quelle kam.
##
## show_damage(amount, is_crit) bleibt unveraendert erhalten, damit die
## bestehenden Aufrufe in primary_hitbox.gd weiterlaufen.
enum Kind { NORMAL, CRIT, DASH, ITEM }

@export var rise_distance: float = 2.5
@export var horizontal_drift: float = 0.9  # max. seitliche Abweichung
@export var duration: float = 1.5
@export var normal_color: Color = Color(0.0, 0.918, 0.882, 1.0)
@export var crit_color: Color = Color(1.0, 0.349, 0.102, 0.855)
@export var outline_color: Color = Color(0.0, 0.773, 0.933, 1.0)

## Dash-Schaden: kraeftiges Gelb, damit es sich sowohl vom cyanfarbenen
## Nahkampf- als auch vom orange-roten Crit-Schaden klar abhebt.
@export var dash_color: Color = Color(1.0, 0.85, 0.1, 1.0)
@export var dash_outline_color: Color = Color(1.0, 0.55, 0.0, 1.0)
@export var crit_outline_color: Color = Color(1.0, 0.2, 0.0, 1.0)

## Neon-Magenta: bewusst der einzige Ton im Set, der weder in Richtung Cyan
## (normal) noch Gelb (dash) noch Orange-Rot (crit) driftet - eindeutig als
## "das kam von einem Item, nicht von einem Schlag" lesbar.
@export var item_color: Color = Color(1.0, 0.25, 0.95, 1.0)
@export var item_outline_color: Color = Color(0.55, 0.0, 0.65, 1.0)
@export var horizontal_stretch: float = 3  # >1.0 = breiter, <1.0 = schmaler

func _ready() -> void:
	# Sinnvolle Defaults direkt im Code, damit man im Editor nichts
	# vergessen kann — Billboard sorgt dafür, dass die Zahl immer zur
	# Kamera zeigt. no_depth_test verhindert, dass die Zahl hinter/in
	# Gegnern verschwindet (die dank depth_draw_always im PSX-Shader
	# immer noch "solide" im Tiefenpuffer sind, auch wenn sie optisch
	# transparent aussehen).
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	outline_size = 0
	font_size = 128
	scale.x = horizontal_stretch
	outline_modulate = outline_color

## Bestehende API - unveraendert nutzbar (primary_hitbox.gd ruft genau das
## auf). Leitet nur noch auf die Kind-Variante um.
func show_damage(amount: float, is_crit: bool = false) -> void:
	show_damage_kind(amount, Kind.CRIT if is_crit else Kind.NORMAL)


## Bequemer Einzeiler fuer den Dash - spart dem Aufrufer den Enum-Import.
func show_dash_damage(amount: float) -> void:
	show_damage_kind(amount, Kind.DASH)


## Bequemer Einzeiler fuer Item-/Passiv-Schaden - siehe item_behaviours.gd.
func show_item_damage(amount: float) -> void:
	show_damage_kind(amount, Kind.ITEM)


func show_damage_kind(amount: float, kind: int) -> void:
	text = str(int(round(amount)))

	match kind:
		Kind.CRIT:
			modulate = crit_color
			outline_modulate = crit_outline_color
		Kind.DASH:
			modulate = dash_color
			outline_modulate = dash_outline_color
		Kind.ITEM:
			modulate = item_color
			outline_modulate = item_outline_color
		_:
			modulate = normal_color
			outline_modulate = outline_color

	# Jede Zahl bekommt ihre EIGENE zufällige Richtung — sowohl seitlich
	# (X/Z) als auch wie stark sie nach oben steigt. randf_range() liefert
	# bei jedem Aufruf einen neuen Zufallswert, daher ist jede Instanz anders.
	var random_offset := Vector3(
		randf_range(-horizontal_drift, horizontal_drift),
		rise_distance * randf_range(0.8, 1.3),
		randf_range(-horizontal_drift, horizontal_drift)
	)
	var target_position: Vector3 = position + random_offset

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", target_position, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# WICHTIG: modulate UND outline_modulate müssen beide gefadet werden —
	# sind zwei komplett separate Color-Properties in Label3D. Ohne diese
	# zweite Zeile bleibt die Outline stehen, während der Rest verblasst.
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_property(self, "outline_modulate:a", 0.0, duration)
	tween.chain().tween_callback(queue_free)
