extends AnimatedFxSprite3D

static var cached_frames: SpriteFrames = null

func _ready() -> void:
	if cached_frames == null:
		# Sehr schnell für Muzzle Flash
		cached_frames = build_frames("res://assets/vfx/explosion/explosion001/explosion_0011%d.png", 5, 16, "Explosion-Bilder")
	self.sprite_frames = cached_frames
	setup_and_play(BaseMaterial3D.BILLBOARD_ENABLED, 0.04, 0.05, true)
