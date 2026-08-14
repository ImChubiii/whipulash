extends AnimatedFxSprite3D

var velocity: Vector3 = Vector3.ZERO

static var cached_frames: SpriteFrames = null

func _ready() -> void:
	if cached_frames == null:
		cached_frames = build_frames("res://assets/vfx/impact/impact001/impact_0011%d.png", 5, 9, "Impact-Bilder")
	self.sprite_frames = cached_frames
	# Zufaellige Groesse fuer jeden Spritzer (Basisgroesse wurde auf Giselles Level angehoben)
	setup_and_play(BaseMaterial3D.BILLBOARD_ENABLED, 0.032, 0.072, true)

	# Zufällige Variation, damit es nicht immer gleich aussieht
	self.flip_h = randf() > 0.5
	self.flip_v = randf() > 0.5

	# Deutlich größerer Offset, damit das Blut weiträumiger um den Gegner verteilt wird
	var random_offset := Vector3(randf_range(-1.0, 1.0), randf_range(-0.8, 1.2), randf_range(-1.0, 1.0))
	self.position += random_offset

	# Schieße die Spritzer mit Wucht nach außen!
	var outward_dir := Vector3(randf_range(-1.0, 1.0), randf_range(0.2, 1.2), randf_range(-1.0, 1.0)).normalized()
	# Geschwindigkeit wieder etwas reduziert, damit es nicht übertrieben ist
	var speed := randf_range(6.0, 10.0)
	velocity = outward_dir * speed


func _process(delta: float) -> void:
	# Bewege den Spritzer und wende Schwerkraft an, während die Animation abspielt
	position += velocity * delta
	velocity.y -= 10.0 * delta # Etwas weniger Schwerkraft, damit es weiter fliegt
