@tool
extends Node3D
class_name SpawnTutorialHologram

# ============================================================================
# SpawnTutorialHologram — grosses Hologramm-Schild am Spieler-Spawn, das ein
# fertiges Tutorial-Bild zeigt und sich immer zum Spieler dreht.
# ============================================================================
#
# BENUTZUNG
# ---------
# Als Kind in die Startraum-Szene haengen (res://scenes/rooms/room_start_01.tscn),
# Node-Typ Node3D, dieses Script drauf, dann im Inspector nur
# tutorial_texture zuweisen. Die Position sucht sich das Hologramm selbst:
# es stellt sich VOR den PlayerSpawnPoint desselben Raums, in dessen
# Blickrichtung.
#
# WARUM ES SICH SELBST POSITIONIERT
# ---------------------------------
# Ein von Hand gesetzter Abstand waere genau einmal richtig. Der Spawnpunkt
# kann verschoben werden, die Raumgroesse aendert sich ueber room_scale im
# LevelGenerator, und der Startraum koennte spaeter ein zweiter werden. Der
# Abstand wird deshalb IMMER relativ zum Marker gerechnet - dann stimmt er
# auch nach jeder dieser Aenderungen noch.
#
# ############################################################################
# WO IST "VORNE"? NICHT RATEN - VON DER KAMERA HOLEN
# ############################################################################
# Dieser Punkt hat mehr Fallstricke, als er verdient. Im Projekt gibt es
# ZWEI verschiedene "vorne", und sie zeigen in entgegengesetzte Richtungen:
#
#   1. Das MODELL faced +Z. Deshalb steht in player_base.gd und enemy_ai.gd
#      ueberall mesh.rotation.y = atan2(dir.x, dir.z) - diese Formel dreht
#      die lokale +Z-Achse auf die Bewegungsrichtung.
#
#   2. Die KAMERA/Bewegung faced -Z. In player_base.gd:
#          var forward := camera_pivot.global_transform.basis.z
#          direction   := forward * input_dir.y
#      Input.get_vector() liefert fuer "ui_up" (W) input_dir.y = -1, das
#      Produkt zeigt also entlang -Z. Passend dazu sitzen SecondaryHitbox
#      (z = -0.64) und PrimaryHitbox (z = -2.99) beide auf der -Z-Seite:
#      dorthin schlaegt der Charakter, dorthin schaut man.
#
# Ein Schild entlang +Z zu setzen (die "Modell-Vorne"-Achse) landet damit
# GENAU HINTER dem Spieler - und weil die Kamera hinter ihm haengt, sogar
# hinter der Kamera. Man sieht es beim Start nie.
#
# Statt sich fuer eine der beiden Konventionen zu entscheiden, fragt der
# Standardmodus (Placement.CAMERA_VIEW) einfach die echte Kamera, sobald
# der Spieler existiert. Das ist immun gegen jede kuenftige Aenderung an
# Achsen, Spawn-Yaw oder Kamera-Rig - und beantwortet exakt die Frage, um
# die es geht: "was sieht der Spieler im ersten Frame?"
#
# ############################################################################
# EINHEITEN SIND LOKAL, NICHT WELT
# ############################################################################
# Der LevelGenerator instanziiert Raeume mit einer skalierten Basis
# (room_scale, aktuell 2x). Alles, was hier als Abstand oder Groesse steht,
# wird davon mitskaliert: distance = 5.0 sind bei room_scale = 2 also 10
# Meter in der Welt. Das ist gewollt - so bleibt das Verhaeltnis von
# Schildgroesse zu Raumgroesse konstant, egal wie gross die Raeume noch
# werden.
#
# ############################################################################
# WARUM Sprite3D UND KEIN QuadMesh MIT MATERIAL
# ############################################################################
# Sprite3D bringt Billboard, Texturfilter, Alpha-Modus und pixel_size fertig
# mit und braucht kein eigenes Material-Setup. Fuer ein Bild, das immer zur
# Kamera zeigt, ist das genau das richtige Werkzeug. Die Rueckplatte
# darunter ist dagegen ein QuadMesh - die braucht kein Bild, nur eine
# Flaeche in Hologrammfarbe.

## Das fertige Tutorial-Bild. PSX-Look: im Import-Dialog "Filter" aus und
## "Mipmaps" aus, sonst matscht die Schrift bei Entfernung weg.
@export var tutorial_texture: Texture2D:
	set(value):
		tutorial_texture = value
		_rebuild_deferred()

## Breite des Schildes in LOKALEN Einheiten (siehe Einheiten-Block oben).
## Die Hoehe ergibt sich aus dem Seitenverhaeltnis der Textur - ein
## getrennter Hoehenwert koennte das Bild nur verzerren.
@export var board_width: float = 9.0:
	set(value):
		board_width = maxf(value, 0.1)
		_rebuild_deferred()

## Wie die Richtung bestimmt wird, in die das Schild gesetzt wird.
##
##   CAMERA_VIEW    Blickrichtung der echten Spielerkamera im ersten Frame.
##                  Standard - siehe Block im Dateikopf.
##   SPAWN_VIEW_Z   Statisch entlang -Z des Spawn-Markers. Das ist bei
##                  Yaw 0 dieselbe Richtung, nur ohne auf den Spieler zu
##                  warten. Fuer Testszenen ohne PartyManager.
##   SPAWN_BACK_Z   Statisch entlang +Z, also HINTER den Spieler. Nur
##                  sinnvoll, wenn man das Schild bewusst erst beim
##                  Umdrehen zeigen will.
enum Placement {
	CAMERA_VIEW,
	SPAWN_VIEW_Z,
	SPAWN_BACK_Z,
}

@export var placement: Placement = Placement.CAMERA_VIEW:
	set(value):
		placement = value
		_reposition()

## Abstand vom Spawnpunkt in der gewaehlten Richtung. Negative Werte
## drehen die Richtung um.
@export var distance: float = 6.0:
	set(value):
		distance = value
		_reposition()

## Hoehe der SCHILDMITTE, gemessen VOM SPAWNPUNKT AUS (nicht von der
## Weltnull). Negative Werte sind erlaubt und haengen das Schild tiefer.
##
## 3.0 lokale Einheiten sind bei room_scale = 2 sechs Meter ueber dem
## Spawnpunkt - das Schild steht damit gross im Bild, ohne den Blick auf
## die Tueren zu verstellen.
@export var height: float = 3.0:
	set(value):
		height = value
		_reposition()

## Wie viele Frames auf die Spieler-Instanz gewartet wird, bevor
## CAMERA_VIEW auf SPAWN_VIEW_Z zurueckfaellt.
##
## Der Spieler entsteht nicht im selben Frame wie der Raum: PartySetup,
## PlayerSpawnPoint und PartyManager._spawn_active_character() haengen
## ueber mehrere call_deferred()-Stufen hintereinander. Ein einzelnes
## await process_frame reicht dafuer nicht zuverlaessig.
@export var camera_wait_frames: int = 30

## Wenn true, dreht sich das Schild um die Y-Achse immer zur Kamera.
## Ausschalten, wenn es fest in eine Richtung zeigen soll.
@export var face_player: bool = true:
	set(value):
		face_player = value
		_rebuild_deferred()

## --- Optik ------------------------------------------------------------
## Faerbung des Bildes. Weiss = Bild unveraendert. Ein leichter Cyan-Stich
## laesst es nach Hologramm aussehen, ohne die Lesbarkeit zu kosten.
@export var tint: Color = Color(0.72, 0.94, 1.0)
@export_range(0.0, 1.0) var opacity: float = 0.92

## Rueckplatte hinter dem Bild. Ohne sie steht helle Schrift auf hellem
## Hintergrund praktisch unlesbar im Raum.
@export var backdrop_enabled: bool = true
@export var backdrop_color: Color = Color(0.03, 0.09, 0.13, 0.55)
## Wie weit die Platte ueber das Bild hinausragt (Anteil der Bildbreite).
@export_range(0.0, 0.5) var backdrop_padding: float = 0.06

## Bodenprojektor: schmaler Lichtkegel vom Boden zum Schild. Erklaert, WOHER
## das Hologramm kommt - ohne ihn schwebt einfach ein Bild in der Luft.
##
## ##########################################################################
## FIX: "der Kegel steckt IM Bild statt darunter"
## ##########################################################################
## Der Kegel lief vom Spawnpunkt (lokal y = 0) bis y = height - und height
## ist die MITTE des Schildes, nicht dessen Unterkante. Die obere Haelfte
## des Kegels steckte damit zwangslaeufig im Bild.
##
## Rechenbeispiel mit den Standardwerten (board_width = 9, Bild im
## Verhaeltnis 16:9 -> aspect 0.5625):
##     Schildhoehe        = 9 * 0.5625      = 5.06
##     halbe Schildhoehe                    = 2.53
##     Schild reicht von y = 3 - 2.53 = 0.47  bis  y = 3 + 2.53 = 5.53
##     Kegel reichte bis y = 3
## Der Kegel endete also 2,53 Einheiten INNERHALB des Bildes - und weil er
## additiv gemischt ist, hat er die untere Bildhaelfte zusaetzlich
## aufgehellt.
##
## Jetzt endet er an der UNTERKANTE des Schildes (inklusive der Rueckplatte
## und projector_gap Abstand). Die Rechnung dafuer steht in
## _board_half_height() und _projector_top_y().
@export var projector_enabled: bool = true
@export var projector_color: Color = Color(0.35, 0.85, 1.0, 0.18)

## Luft zwischen Kegelspitze und Schildunterkante. 0 = der Kegel beruehrt
## das Schild genau.
@export var projector_gap: float = 0.25

## Radius der Kegelspitze (oben, am Schild) als Anteil der Schildbreite.
@export_range(0.0, 1.0) var projector_top_ratio: float = 0.30

## Radius am Boden, in lokalen Einheiten.
@export var projector_bottom_radius: float = 0.25

## Feinverschiebung des Kegels, falls er nicht mittig unter dem Schild
## sitzen soll. Wird AUF die berechnete Position addiert.
@export var projector_offset: Vector3 = Vector3.ZERO

## --- Bewegung ---------------------------------------------------------
@export var bob_enabled: bool = true
@export var bob_height: float = 0.4
@export var bob_speed: float = 1.2

## Flackern. Bewusst dezent: ein Schild, das man lesen soll, darf nicht
## staendig verschwinden.
@export var flicker_enabled: bool = true
@export_range(0.0, 0.5) var flicker_amount: float = 0.08
@export var flicker_speed: float = 9.0

## --- Sichtbarkeit -----------------------------------------------------
## Ab dieser Entfernung (lokale Einheiten) blendet das Schild aus. 0 = nie
## ausblenden.
##
## Der Sinn: das Tutorial soll beim Start da sein, aber nicht den halben
## Raum verdecken, wenn man zurueckkommt. Ausblenden ueber die Entfernung
## statt ueber einen Timer, weil ein Timer bei jemandem, der die Steuerung
## zum ersten Mal liest, zwangslaeufig zu frueh ablaeuft.
@export var fade_out_distance: float = 26.0
@export var fade_in_distance: float = 22.0
@export var fade_duration: float = 0.4

@export var debug_logging: bool = false

## --- Interaktion: Vergroessern zum Lesen ------------------------------
## Analog zum Minimap-Zoom (minimap.gd: TAB/M oeffnet eine groessere,
## besser lesbare Ansicht derselben Karte) - dieselbe Idee hier: [interact]
## in der Naehe skaliert das Schild groesser, ein zweites Mal (oder
## Weggehen) skaliert zurueck.
@export var interact_zoom_enabled: bool = true
## Abstand in LOKALEN Einheiten, ab dem der Interaktions-Hinweis erscheint.
@export var interact_range: float = 4.0
@export var interact_zoom_scale: float = 1.7
@export var interact_zoom_duration: float = 0.3

const PLAYER_GROUP: String = "player"

var _board: Sprite3D = null
var _backdrop: MeshInstance3D = null
var _backdrop_material: StandardMaterial3D = null
var _projector: MeshInstance3D = null
var _projector_material: StandardMaterial3D = null

var _pivot: Node3D = null
var _base_y: float = 0.0
var _time: float = 0.0
var _visible_target: float = 1.0
var _current_fade: float = 1.0
var _rebuild_queued: bool = false

## --- Interaktions-Zustand ----------------------------------------------
var _interact_prompt: Label3D = null
var _zoomed: bool = false
var _zoom_tween: Tween = null
var _player_in_interact_range: bool = false


func _debug(msg: String) -> void:
	if debug_logging:
		print("[SpawnHologram] %s" % msg)


func _ready() -> void:
	_build()

	if Engine.is_editor_hint():
		_reposition()
		return

	# Eine Frame warten: der LevelGenerator setzt die Weltposition des
	# Raums erst NACH add_child(). Genau dieselbe Begruendung wie in
	# player_spawn_point.gd und room_commit_guard.gd.
	await get_tree().process_frame
	if not is_inside_tree():
		return

	# Erste, vorlaeufige Platzierung ueber den Marker - damit das Schild
	# schon steht, falls der Spieler laenger braucht.
	_reposition()

	if placement == Placement.CAMERA_VIEW:
		await _wait_for_player()
		if not is_inside_tree():
			return
		_reposition()


## Wartet, bis PartyManager eine Spieler-Instanz mit Kamera gebaut hat.
func _wait_for_player() -> void:
	var frames: int = 0
	while frames < maxi(camera_wait_frames, 1):
		if _find_camera_pivot() != null:
			return
		await get_tree().process_frame
		if not is_inside_tree():
			return
		frames += 1
	_debug("Nach %d Frames keine Spielerkamera gefunden - Fallback auf SPAWN_VIEW_Z." % camera_wait_frames)


# ============================================================================
# Aufbau
# ============================================================================
## Sammelt mehrere Aenderungen aus dem Inspector zu EINEM Neuaufbau. Ohne
## das wuerde jeder einzelne Tastendruck in einem Zahlenfeld die komplette
## Geometrie neu erzeugen.
func _rebuild_deferred() -> void:
	if _rebuild_queued or not is_inside_tree():
		return
	_rebuild_queued = true
	_do_rebuild.call_deferred()


func _do_rebuild() -> void:
	_rebuild_queued = false
	_build()
	_reposition()


func _build() -> void:
	_clear()

	_pivot = Node3D.new()
	_pivot.name = "HologramPivot"
	add_child(_pivot)

	_build_backdrop()
	_build_board()
	_build_projector()
	_build_interact_prompt()

	_base_y = _pivot.position.y
	_zoomed = false


## remove_child() VOR queue_free(): queue_free() raeumt erst am Frame-Ende
## auf. Ohne das vorherige Aushaengen laege der alte Aufbau beim Neubau
## noch im Baum, Godot wuerde den neuen Nodes Namen wie
## "HologramPivot2" geben, und _pivot zeigte auf etwas anderes als das,
## was der Editor anzeigt.
func _clear() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_pivot = null
	_board = null
	_backdrop = null
	_backdrop_material = null
	_projector = null
	_projector_material = null
	_interact_prompt = null
	if _zoom_tween != null and _zoom_tween.is_valid():
		_zoom_tween.kill()
	_zoom_tween = null


func _build_board() -> void:
	if tutorial_texture == null:
		_debug("Keine tutorial_texture gesetzt - es wird nur die Ruecklatte gebaut.")
		return

	_board = Sprite3D.new()
	_board.name = "TutorialBoard"
	_board.texture = tutorial_texture

	# pixel_size aus der gewuenschten Breite ableiten statt einen festen
	# Wert zu setzen: sonst haengt die Schildgroesse an der Aufloesung des
	# Bildes, und ein Austausch der Textur gegen eine groessere wuerde das
	# Schild ploetzlich ueber den halben Raum spannen.
	var tex_width: int = maxi(tutorial_texture.get_width(), 1)
	_board.pixel_size = board_width / float(tex_width)

	_board.shaded = false
	_board.double_sided = true
	_board.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_board.transparent = true
	# ALPHA_CUT_DISABLED: bei einem Tutorial-Bild mit weichen Kanten oder
	# halbtransparentem Hintergrund wuerde ALPHA_CUT_DISCARD harte,
	# ausgefranste Raender erzeugen.
	_board.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	_board.modulate = Color(tint.r, tint.g, tint.b, opacity)

	if face_player:
		# FIXED_Y: dreht sich nur um die Hochachse. BILLBOARD_ENABLED
		# wuerde das Schild auch kippen, sobald der Spieler naeher kommt
		# und die Kamera nach unten schaut - dann steht das Tutorial
		# schraeg im Bild.
		_board.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

	_pivot.add_child(_board)


func _build_backdrop() -> void:
	if not backdrop_enabled:
		return

	var pad: float = board_width * backdrop_padding
	var quad := QuadMesh.new()
	quad.size = Vector2(board_width + pad * 2.0, _board_image_height() + pad * 2.0)

	_backdrop_material = StandardMaterial3D.new()
	_backdrop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_backdrop_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_backdrop_material.albedo_color = backdrop_color
	_backdrop_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_backdrop_material.disable_receive_shadows = true
	if face_player:
		_backdrop_material.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		# Ohne keep_scale schrumpft ein Billboard-Quad auf Einheitsgroesse.
		_backdrop_material.billboard_keep_scale = true

	_backdrop = MeshInstance3D.new()
	_backdrop.name = "Backdrop"
	_backdrop.mesh = quad
	_backdrop.material_override = _backdrop_material
	_backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Minimal nach hinten, damit die Platte nicht mit dem Bild um dieselben
	# Tiefenwerte kaempft (Z-Fighting).
	_backdrop.position.z = -0.02
	_pivot.add_child(_backdrop)


## Hoehe des BILDES selbst in lokalen Einheiten, abgeleitet aus dem
## Seitenverhaeltnis der Textur.
##
## Eine Stelle fuer beide Verbraucher (Rueckplatte und Projektor): stuende
## die Rechnung zweimal im Code, koennten die beiden nach einer Aenderung
## unterschiedlich gross sein - und genau daraus entsteht ein Kegel, der
## nicht mehr zum Schild passt.
func _board_image_height() -> float:
	var aspect: float = 0.6
	if tutorial_texture != null and tutorial_texture.get_width() > 0:
		aspect = float(tutorial_texture.get_height()) / float(tutorial_texture.get_width())
	return board_width * aspect


## Halbe Hoehe des SICHTBAREN Schildes - also inklusive der Rueckplatte,
## denn die ragt ueber das Bild hinaus und ist das, was man als Unterkante
## wahrnimmt.
func _board_half_height() -> float:
	var total: float = _board_image_height()
	if backdrop_enabled:
		total += board_width * backdrop_padding * 2.0
	return total * 0.5


## Y-Koordinate, an der der Kegel endet: die dem Spawnpunkt ZUGEWANDTE
## Kante des Schildes, minus projector_gap.
##
## Bei positivem height ist das die Unterkante, bei negativem height die
## Oberkante - der Kegel zeigt dann nach unten. Deshalb wird mit dem
## Vorzeichen gerechnet und nicht einfach subtrahiert.
func _projector_top_y() -> float:
	var half: float = _board_half_height()
	var gap: float = maxf(projector_gap, 0.0)
	if height >= 0.0:
		return maxf(height - half - gap, 0.0)
	return minf(height + half + gap, 0.0)


## Schmaler Lichtkegel vom Boden bis UNTER das Schild.
##
## Sitzt bewusst NICHT im _pivot: der wippt (bob), und ein Lichtkegel, der
## mitwippt, loest sich sichtbar vom Boden.
func _build_projector() -> void:
	if not projector_enabled:
		return

	var top_y: float = _projector_top_y()
	var span: float = absf(top_y)

	# Zu kurz zum Zeichnen: das passiert, wenn das Schild so gross ist,
	# dass seine Unterkante schon fast auf dem Boden liegt. Ein Kegel von
	# wenigen Zentimetern waere dann nur ein Fleck am Spawnpunkt.
	if span < 0.15:
		_debug("Schildunterkante liegt fast auf Spawnhoehe - Projektor entfaellt.")
		return

	var cone := CylinderMesh.new()
	cone.height = span
	cone.radial_segments = 12
	cone.rings = 1

	var wide: float = board_width * projector_top_ratio
	var narrow: float = maxf(projector_bottom_radius, 0.01)

	# Die breite Seite gehoert IMMER ans Schild, die schmale an den
	# Spawnpunkt. Bei negativem height liegt das Schild unten, also
	# tauschen.
	if height >= 0.0:
		cone.top_radius = wide
		cone.bottom_radius = narrow
	else:
		cone.top_radius = narrow
		cone.bottom_radius = wide

	_projector_material = StandardMaterial3D.new()
	_projector_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_projector_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_projector_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_projector_material.albedo_color = projector_color
	_projector_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_projector_material.disable_receive_shadows = true
	# Ohne das schiebt sich der additive Kegel vor das Bild, sobald man
	# schraeg davorsteht: er wuerde die Schrift ueberstrahlen. Mit
	# no_depth_test = false und deaktiviertem Tiefenschreiben sortiert er
	# sich korrekt hinter undurchsichtige Geometrie ein, ohne selbst
	# andere transparente Flaechen zu verdecken.
	_projector_material.no_depth_test = false

	_projector = MeshInstance3D.new()
	_projector.name = "Projector"
	_projector.mesh = cone
	_projector.material_override = _projector_material
	_projector.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Der Kegel ist um seinen Mittelpunkt gebaut: er soll die Strecke von
	# y = 0 (Spawnpunkt) bis y = top_y (Schildunterkante) fuellen, sein
	# Mittelpunkt liegt also auf halber Strecke. Vorher stand hier
	# height * 0.5 - und height ist die Schildmitte, nicht die Unterkante.
	_projector.position = Vector3(0.0, top_y * 0.5, 0.0) + projector_offset
	add_child(_projector)


## Kleiner Hinweis unter dem Schild, nur sichtbar wenn der Spieler nah genug
## steht - siehe _update_interact() weiter unten.
func _build_interact_prompt() -> void:
	if not interact_zoom_enabled or _pivot == null:
		return
	_interact_prompt = Label3D.new()
	_interact_prompt.name = "InteractPrompt"
	_interact_prompt.text = "[F] Vergroessern"
	_interact_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_interact_prompt.no_depth_test = true
	_interact_prompt.font_size = 40
	_interact_prompt.pixel_size = 0.008
	_interact_prompt.outline_size = 10
	_interact_prompt.modulate = Color(0.72, 0.94, 1.0, 0.9)
	_interact_prompt.position = Vector3(0.0, -_board_half_height() - 0.4, 0.0)
	_interact_prompt.visible = false
	_pivot.add_child(_interact_prompt)


# ============================================================================
# Platzierung
# ============================================================================
## Stellt das Hologramm vor den PlayerSpawnPoint des eigenen Raums.
##
## Der Marker wird im GESCHWISTERBEREICH gesucht, nicht global: in einem
## generierten Level koennen mehrere Raeume gleichzeitig existieren, und
## ein globaler Suchlauf wuerde irgendeinen davon finden.
func _reposition() -> void:
	if not is_inside_tree():
		return

	var marker: Node3D = _find_spawn_marker()
	if marker == null:
		_debug("Kein PlayerSpawnPoint im Raum gefunden - Node bleibt, wo er im Editor liegt.")
		if _pivot != null:
			_pivot.position.y = height
			_base_y = height
		return

	var dir: Vector3 = _placement_direction(marker)

	position = marker.position + dir * distance
	position.y = marker.position.y

	if _pivot != null:
		_pivot.position.y = height
		_base_y = height

	if not face_player:
		# Das Schild soll den Spawnpunkt ANSEHEN, also muss seine eigene
		# +Z-Achse (Vorderseite von Sprite3D und QuadMesh) entgegen der
		# Aufstellrichtung zeigen.
		rotation.y = atan2(-dir.x, -dir.z)

	_debug("Platziert bei %s (Modus %s)." % [position, Placement.keys()[placement]])


## Liefert die Richtung, in die das Schild vom Marker aus gesetzt wird -
## als Einheitsvektor im LOKALEN System des Elternknotens.
##
## WARUM LOKAL UND NICHT GLOBAL:
## Der Raum wird mit einer skalierten Basis instanziiert (room_scale).
## Eine Weltrichtung mit einem lokalen Abstand zu multiplizieren, mischt
## zwei Koordinatensysteme - das Schild waere dann bei jeder Aenderung von
## room_scale unterschiedlich weit weg. Die Kamerarichtung wird deshalb
## ueber die inverse Elternbasis heruntergerechnet.
func _placement_direction(marker: Node3D) -> Vector3:
	match placement:
		Placement.SPAWN_BACK_Z:
			return marker.transform.basis.z.normalized()
		Placement.SPAWN_VIEW_Z:
			return -marker.transform.basis.z.normalized()
		_:
			pass

	# CAMERA_VIEW
	var pivot: Node3D = _find_camera_pivot()
	if pivot == null:
		# Fallback: bei Spawn-Yaw 0 zeigt die Kamera ohnehin nach -Z.
		return -marker.transform.basis.z.normalized()

	# Blickrichtung der Kamera in Weltkoordinaten. -Z, weil Camera3D wie
	# jedes Godot-Node entlang seiner NEGATIVEN Z-Achse schaut - und weil
	# genau dorthin auch Bewegung und Angriffe zeigen (siehe Dateikopf).
	var world_dir: Vector3 = -pivot.global_transform.basis.z
	world_dir.y = 0.0
	if world_dir.length() < 0.001:
		return -marker.transform.basis.z.normalized()
	world_dir = world_dir.normalized()

	var parent_3d: Node3D = get_parent() as Node3D
	if parent_3d == null:
		return world_dir

	var local_dir: Vector3 = parent_3d.global_transform.basis.inverse() * world_dir
	local_dir.y = 0.0
	if local_dir.length() < 0.001:
		return -marker.transform.basis.z.normalized()
	return local_dir.normalized()


## Der CameraPivot haengt unter der Spieler-Instanz (siehe
## char_*.tscn: Player/CameraPivot/SpringArm3D/Camera3D). Gesucht wird
## ueber die Gruppe, nicht ueber einen Pfad - PartyManager tauscht die
## Instanz bei jedem Charakterwechsel komplett aus.
func _find_camera_pivot() -> Node3D:
	var player: Node3D = _find_player()
	if player == null:
		return null
	var pivot: Node = player.get_node_or_null("CameraPivot")
	if pivot is Node3D:
		return pivot as Node3D
	# Fallback: der Koerper selbst. Sein Yaw kommt beim Spawnen direkt vom
	# Marker, taugt also als grobe Ersatzrichtung.
	return player


func _find_spawn_marker() -> Node3D:
	var parent: Node = get_parent()
	if parent == null:
		return null

	for child: Node in parent.get_children():
		if child == self:
			continue
		if child is PlayerSpawnPoint:
			return child as Node3D

	# Zweiter Versuch ueber den Namen - deckt Szenen ab, in denen der Marker
	# (noch) kein Script traegt.
	var by_name: Node = parent.get_node_or_null("PlayerSpawnPoint")
	if by_name is Node3D:
		return by_name as Node3D

	return null


# ============================================================================
# Laufzeit
# ============================================================================
func _process(delta: float) -> void:
	if _pivot == null or not is_instance_valid(_pivot):
		return

	_time += delta

	if bob_enabled:
		_pivot.position.y = _base_y + sin(_time * bob_speed) * bob_height

	if Engine.is_editor_hint():
		return

	_update_distance_fade(delta)
	_apply_alpha()
	_update_interact(delta)


## Zwei getrennte Schwellen (fade_out_distance / fade_in_distance) statt
## einer: mit nur einer Grenze flackert die Anzeige, sobald man genau auf
## ihr steht und sich minimal bewegt.
func _update_distance_fade(delta: float) -> void:
	if fade_out_distance <= 0.0:
		_visible_target = 1.0
	else:
		var player: Node3D = _find_player()
		if player != null:
			var d: float = global_position.distance_to(player.global_position)
			# Die Schwellen sind in LOKALEN Einheiten angegeben, die
			# Entfernung faellt in Weltmassen an - also umrechnen, sonst
			# stimmen die Werte bei room_scale != 1 nicht.
			var world_scale: float = maxf(global_transform.basis.x.length(), 0.001)
			var out_limit: float = fade_out_distance * world_scale
			var in_limit: float = fade_in_distance * world_scale

			if d > out_limit:
				_visible_target = 0.0
			elif d < in_limit:
				_visible_target = 1.0

	var step: float = delta / maxf(fade_duration, 0.01)
	_current_fade = move_toward(_current_fade, _visible_target, step)


func _apply_alpha() -> void:
	var flicker: float = 1.0
	if flicker_enabled:
		# Zwei ueberlagerte Sinuskurven mit unpassenden Frequenzen: eine
		# einzelne Welle liest sich als gleichmaessiges Pulsieren, nicht
		# als instabile Projektion.
		var noise: float = sin(_time * flicker_speed) * 0.6 + sin(_time * flicker_speed * 2.7) * 0.4
		flicker = 1.0 - flicker_amount * (noise * 0.5 + 0.5)

	var alpha: float = _current_fade * flicker

	if _board != null and is_instance_valid(_board):
		_board.modulate = Color(tint.r, tint.g, tint.b, opacity * alpha)
		_board.visible = alpha > 0.01

	if _backdrop_material != null:
		_backdrop_material.albedo_color = Color(
			backdrop_color.r, backdrop_color.g, backdrop_color.b, backdrop_color.a * alpha
		)
	if _backdrop != null and is_instance_valid(_backdrop):
		_backdrop.visible = alpha > 0.01

	if _projector_material != null:
		_projector_material.albedo_color = Color(
			projector_color.r, projector_color.g, projector_color.b, projector_color.a * alpha
		)
	if _projector != null and is_instance_valid(_projector):
		_projector.visible = alpha > 0.01


## Interaktion: [F] in der Naehe vergroessert das Schild (analog zum
## Minimap-Zoom - dieselbe Grundidee, dieselbe Karte/dasselbe Bild groesser
## fuer bessere Lesbarkeit statt eines separaten Ansicht-Modus).
func _update_interact(_delta: float) -> void:
	if not interact_zoom_enabled:
		return

	var player: Node3D = _find_player()
	var in_range: bool = false
	if player != null:
		var d: float = global_position.distance_to(player.global_position)
		# Gleiche lokal->Welt-Umrechnung wie _update_distance_fade(), aus
		# demselben Grund (room_scale).
		var world_scale: float = maxf(global_transform.basis.x.length(), 0.001)
		in_range = d <= interact_range * world_scale

	if in_range != _player_in_interact_range:
		_player_in_interact_range = in_range
		if not in_range and _zoomed:
			_set_zoomed(false)
		if _interact_prompt != null and is_instance_valid(_interact_prompt):
			_interact_prompt.visible = in_range

	if not in_range:
		return

	if _interact_prompt != null and is_instance_valid(_interact_prompt):
		_interact_prompt.text = "[F] Verkleinern" if _zoomed else "[F] Vergroessern"

	if Input.is_action_just_pressed("interact"):
		_set_zoomed(not _zoomed)


func _set_zoomed(value: bool) -> void:
	_zoomed = value
	if _pivot == null or not is_instance_valid(_pivot):
		return
	if _zoom_tween != null and _zoom_tween.is_valid():
		_zoom_tween.kill()

	var target_scale: Vector3 = Vector3.ONE * (interact_zoom_scale if value else 1.0)
	_zoom_tween = create_tween()
	_zoom_tween.tween_property(_pivot, "scale", target_scale, interact_zoom_duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Ueber die Gruppe statt find_child("Player"): der PartyManager tauscht die
## Spieler-Instanz bei jedem Charakterwechsel komplett aus, eine gemerkte
## Referenz waere danach eine Leiche.
func _find_player() -> Node3D:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(PLAYER_GROUP)
	for node: Node in nodes:
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


## Von aussen ein-/ausblendbar, falls das Tutorial spaeter ueber eine
## Einstellung abschaltbar sein soll.
func set_hologram_visible(value: bool) -> void:
	_visible_target = 1.0 if value else 0.0
