extends Node3D

# ============================================================================
# Ningnings Secondary "Heavy Haymaker" (RMB) - Feuer-VFX als GEKREUZTES
# Doppel-Plane ("Cross-Quad") statt einer einzelnen flachen Ebene.
# ============================================================================
# Rueckmeldung: soll "insgesamt groesser" UND "dreidimensionaler" wirken.
# Zwei identische AnimatedFxSprite3D-Ebenen (siehe scripts/vfx/
# animated_fx_sprite3d.gd), um 90 Grad zueinander verdreht ("Cross-Quad"/
# "X-Sprite" - klassischer Retro-3D-Trick): aus fast jedem Blickwinkel ist
# immer mindestens eine der beiden Ebenen halbwegs flaechig sichtbar statt
# nur als duenne Kante von der Seite - liest sich dadurch raeumlicher als
# eine einzelne Flaeche, ohne echtes (teureres) 3D-Modell.
#
# Beide Ebenen bleiben bewusst UNGEBILLBOARDET (BILLBOARD_DISABLED, wie
# vorher schon bei der einzelnen Ebene) - genau das ist der Punkt am
# Cross-Quad-Trick: die beiden Ebenen stehen fest zueinander UND fest zur
# eigenen Ausrichtung (die dieser Wrapper-Node einmalig beim Spawnen per
# vfx_manager.gd::_aim() bekommt), keine der beiden dreht sich einzeln zur
# Kamera - sonst wuerde sich die X-Form beim Drehen der Kamera auflösen.

## War 0.2 (bereits einmal von 0.12 angehoben) - Rueckmeldung "insgesamt
## groesser" nochmal deutlich draufgelegt.
const PIXEL_SIZE: float = 0.32

## Wie zuvor: EIN gemeinsamer Cache fuer BEIDE Ebenen dieses Effekts (nicht
## pro Ebene getrennt) - beide zeigen exakt dieselbe Animation, nur anders
## herum gedreht.
static var cached_frames: SpriteFrames = null


# BUGFIX "Partikel passieren in ihr drinne statt vor ihr": frueher stand hier
# ein fest verdrahteter "self.position += Vector3(0, 1.2, -1.5)" - das ist
# ein Offset im PARENT-Koordinatensystem (current_scene, siehe
# vfx_manager.gd::spawn()), NICHT entlang der eigenen, per _aim() bereits
# gesetzten Blickrichtung. Bei jeder Kamerarichtung ausser der einen, fuer
# die der Wert urspruenglich per Auge getunt wurde, landete die -1.5 in der
# falschen Weltrichtung - sichtbar im Charaktermodell statt davor.
# global_position kommt jetzt schon korrekt vorpositioniert von
# primary_hitbox.gd::activate() (spawnt an der CollisionShape3D-Position,
# nicht mehr am Hitbox-Root), ein zusaetzlicher Offset hier ist nicht mehr
# noetig.
func _ready() -> void:
	if cached_frames == null:
		cached_frames = AnimatedFxSprite3D.build_frames("res://assets/vfx/firefx/firefx003/fire_fx_0031%d.png", 6, 16, "Fire-Bilder")
	if cached_frames == null:
		queue_free()
		return

	var plane_a: AnimatedFxSprite3D = _spawn_plane(0.0)
	_spawn_plane(90.0)

	# Beide Ebenen spielen exakt dieselben, gleich langen Frames, im selben
	# Frame gestartet - sie sind praktisch gleichzeitig fertig. Es reicht,
	# auf EINE der beiden zu hoeren, um den WRAPPER (sich selbst)
	# freizugeben, statt einen leeren Node3D dauerhaft haengen zu lassen.
	# Jede Ebene raeumt sich zusaetzlich ueber ihre eigene
	# AnimatedFxSprite3D.setup_and_play()-Verbindung auch selbst auf -
	# ueberschneidet sich hier unschaedlich, Godot vertraegt eine
	# queue_free() auf einen Node, dessen Parent im selben Frame ebenfalls
	# schon queue_free() bekommen hat.
	plane_a.animation_finished.connect(queue_free)


func _spawn_plane(yaw_degrees: float) -> AnimatedFxSprite3D:
	var plane := AnimatedFxSprite3D.new()
	add_child(plane)
	plane.rotation.y = deg_to_rad(yaw_degrees)
	plane.sprite_frames = cached_frames
	plane.setup_and_play(BaseMaterial3D.BILLBOARD_DISABLED, PIXEL_SIZE, PIXEL_SIZE, false)
	return plane
