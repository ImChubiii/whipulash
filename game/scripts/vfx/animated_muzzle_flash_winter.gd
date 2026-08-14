extends AnimatedFxSprite3D

static var cached_frames: SpriteFrames = null

func _ready() -> void:
	if cached_frames == null:
		cached_frames = build_frames("res://assets/vfx/impact/impact004/impact_0041%d.png", 6, 16, "Impact-Bilder")
	self.sprite_frames = cached_frames
	setup_and_play(BaseMaterial3D.BILLBOARD_ENABLED, 0.04, 0.05, true)
