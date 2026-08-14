extends AnimatedFxSprite3D

static var cached_frames: SpriteFrames = null

func _ready() -> void:
	if cached_frames == null:
		# impact004 has 6 frames: 410 to 415
		cached_frames = build_frames("res://assets/vfx/impact/impact004/impact_0041%d.png", 6, 15, "Blue Impact")
	self.sprite_frames = cached_frames
	
	# Skalierung etwas groesser fuer einen satten Hit
	setup_and_play(BaseMaterial3D.BILLBOARD_ENABLED, 0.06, 0.1, true)
	
	self.flip_h = randf() > 0.5
	self.flip_v = randf() > 0.5
