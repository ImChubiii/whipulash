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
		for i in range(0, 5):
			var path := "res://assets/vfx/slash/slash001/slash_0011%d.png" % i
			var tex: Texture2D = load(path) as Texture2D
			if tex:
				frames.add_frame("default", tex)
				loaded_count += 1
				
		if loaded_count == 0:
			push_error("VFX: Slash-Bilder konnten nicht geladen werden!")
		else:
			cached_frames = frames
			
		self.sprite_frames = frames
	
	self.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	self.transparent = true
	self.shaded = false
	self.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	
	self.no_depth_test = true
	self.render_priority = 2
	
	self.pixel_size = 0.05
	
	# Leicht versetzt, damit es vor dem Charakter erscheint
	self.position += Vector3(0, 1.2, -1.5)
	
	if self.sprite_frames != null and self.sprite_frames.get_frame_count("default") > 0:
		animation_finished.connect(queue_free)
		play("default")
	else:
		queue_free()
