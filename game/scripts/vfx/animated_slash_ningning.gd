extends AnimatedFxSprite3D

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
		cached_frames = build_frames("res://assets/vfx/slash/slash001/slash_0011%d.png", 5, 16, "Slash-Bilder")
	self.sprite_frames = cached_frames
	setup_and_play(BaseMaterial3D.BILLBOARD_DISABLED, 0.05, 0.05, false)
