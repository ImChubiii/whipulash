extends AnimatedSprite3D
class_name AnimatedFxSprite3D

# ============================================================================
# Gemeinsame Basis fuer "spiele eine nummerierte PNG-Sequenz einmal ab, dann
# gib dich selbst frei"-VFX-Sprites (Slash, Fire, Muzzle-Flash, Blut-Impact).
# ============================================================================
# Vorher hatten 5 Dateien (animated_slash_ningning.gd, animated_fire_
# ningning.gd, animated_muzzle_flash.gd, animated_muzzle_flash_winter.gd,
# animated_blood_hit.gd) dasselbe ~25-zeilige Setup jede fuer sich komplett
# dupliziert. Tatsaechlich unterschieden sich nur: Bildpfad-Muster,
# Frame-Anzahl, Abspielgeschwindigkeit, Billboard-Modus, Pixelgroesse und ob
# die Rotation zufaellig gestreut wird. Alles darueber hinaus (z.B. die
# Blutspritzer-Physik in animated_blood_hit.gd) bleibt in der jeweiligen
# Subklasse - diese Basis erzwingt keine gemeinsame Form fuer sowas, sie
# spart nur das echte Duplikat.


## Laedt eine nummerierte PNG-Sequenz ("path_pattern % i" fuer i in
## [0, frame_count)) in ein neues SpriteFrames mit einer einzigen, nicht
## loopenden Animation "default". Reine Ladefunktion ohne Seiteneffekt auf
## self - null bei komplett fehlgeschlagenem Laden (mit push_error).
##
## Bewusst NICHT hier gecacht: jede Subklasse deklariert ihre EIGENE
## "static var cached_frames" und ruft dies nur beim ersten Spawn auf. Ein
## gemeinsamer Cache HIER in der Basisklasse wuerde von ALLEN Subklassen
## geteilt (GDScript-static-vars gehoeren zur Klasse, in der sie deklariert
## sind) - Slash und Fire wuerden sich dann gegenseitig die falschen Frames
## unterschieben.
static func build_frames(path_pattern: String, frame_count: int, animation_speed: float, error_label: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	# BUGFIX (bereits im urspruenglichen, duplizierten Code vorhanden): eine
	# frische SpriteFrames-Resource hat bereits eine Animation namens
	# "default" eingebaut - add_animation("default") schlug deshalb immer
	# mit "SpriteFrames already has animation 'default'" fehl. Nicht fatal
	# (die nachfolgenden set_animation_loop()/set_animation_speed()/
	# add_frame()-Aufrufe griffen trotzdem auf die schon vorhandene
	# Animation zu), aber unnoetiger Fehler-Spam bei jedem einzelnen Spawn.
	frames.set_animation_loop("default", false)
	frames.set_animation_speed("default", animation_speed)

	var loaded_count: int = 0
	for i in range(0, frame_count):
		var path := path_pattern % i
		var tex: Texture2D = load(path) as Texture2D
		if tex:
			frames.add_frame("default", tex)
			loaded_count += 1

	if loaded_count == 0:
		push_error("VFX: %s konnten nicht geladen werden!" % error_label)
		return null
	return frames


## Traegt die gemeinsamen Render-/Material-Einstellungen ein und startet die
## Animation - bzw. gibt den Node sofort frei, falls keine Frames geladen
## werden konnten. Subklassen setzen VORHER self.sprite_frames und rufen
## das dann am Ende ihrer eigenen _ready() auf.
##
## pixel_size_min == pixel_size_max ergibt eine feste Groesse (randf_range
## mit gleichem Ober-/Untergrenze liefert exakt diesen Wert) - Subklassen mit
## fester Groesse (Slash/Fire) muessen dafuer keinen Sonderfall pflegen.
func setup_and_play(billboard_mode: BaseMaterial3D.BillboardMode, pixel_size_min: float, pixel_size_max: float, randomize_rotation: bool) -> void:
	if self.sprite_frames == null or self.sprite_frames.get_frame_count("default") == 0:
		queue_free()
		return

	self.billboard = billboard_mode
	self.transparent = true
	self.shaded = false
	self.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	self.no_depth_test = true
	self.render_priority = 2
	self.pixel_size = randf_range(pixel_size_min, pixel_size_max)
	if randomize_rotation:
		self.rotation.z = randf_range(0.0, TAU)

	animation_finished.connect(queue_free)
	play("default")
