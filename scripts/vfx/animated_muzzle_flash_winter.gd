extends AnimatedSprite3D

static var cached_frames: SpriteFrames = null

func _ready() -> void:
	if cached_frames != null:
		self.sprite_frames = cached_frames
	else:
		var frames := SpriteFrames.new()
		frames.add_animation("default")
		frames.set_animation_loop("default", false)
		frames.set_animation_speed("default", 16)
		
		var loaded_count: int = 0
		for i in range(0, 6):
			var path := "res://assets/vfx/impact/impact004/impact_0041%d.png" % i
			var tex: Texture2D = load(path) as Texture2D
			if tex:
				frames.add_frame("default", tex)
				loaded_count += 1
				
		if loaded_count == 0:
			push_error("VFX: Impact-Bilder konnten nicht geladen werden!")
		else:
			cached_frames = frames
			
		self.sprite_frames = frames
	
	self.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	self.transparent = true
	self.shaded = false
	self.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	
	self.no_depth_test = true
	self.render_priority = 2
	
	self.pixel_size = randf_range(0.04, 0.05)
	
	self.rotation.z = randf_range(0, 2 * PI)
	
	if self.sprite_frames != null and self.sprite_frames.get_frame_count("default") > 0:
		animation_finished.connect(queue_free)
		play("default")
	else:
		queue_free()
