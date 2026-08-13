extends AnimatedSprite3D

var velocity: Vector3 = Vector3.ZERO

static var cached_frames: SpriteFrames = null

func _ready() -> void:
	if cached_frames != null:
		self.sprite_frames = cached_frames
	else:
		var frames := SpriteFrames.new()
		frames.add_animation("default")
		frames.set_animation_loop("default", false)
		frames.set_animation_speed("default", 9)
		
		var loaded_count: int = 0
		for i in range(0, 5):
			var path := "res://assets/vfx/impact/impact001/impact_0011%d.png" % i
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
	
	# Zufällige Variation, damit es nicht immer gleich aussieht
	self.flip_h = randf() > 0.5
	self.flip_v = randf() > 0.5
	self.rotation.z = randf_range(0, 2 * PI)
	
	# Deutlich größerer Offset, damit das Blut weiträumiger um den Gegner verteilt wird
	var random_offset := Vector3(randf_range(-1.0, 1.0), randf_range(-0.8, 1.2), randf_range(-1.0, 1.0))
	self.position += random_offset
	
	# Garantiert, dass es immer VOR dem Gegner gerendert wird und nicht clippt
	self.no_depth_test = true
	self.render_priority = 2
	
	# Zufällige Größe für jeden Spritzer (Basisgröße wurde auf Giselles Level angehoben)
	self.pixel_size = randf_range(0.032, 0.072)
	
	# Schieße die Spritzer mit Wucht nach außen!
	var outward_dir := Vector3(randf_range(-1.0, 1.0), randf_range(0.2, 1.2), randf_range(-1.0, 1.0)).normalized()
	# Geschwindigkeit wieder etwas reduziert, damit es nicht übertrieben ist
	var speed := randf_range(6.0, 10.0)
	velocity = outward_dir * speed
	
	if self.sprite_frames != null and self.sprite_frames.get_frame_count("default") > 0:
		animation_finished.connect(queue_free)
		play("default")
	else:
		queue_free()

func _process(delta: float) -> void:
	# Bewege den Spritzer und wende Schwerkraft an, während die Animation abspielt
	position += velocity * delta
	velocity.y -= 10.0 * delta # Etwas weniger Schwerkraft, damit es weiter fliegt
