extends Control
class_name MainMenu

# ============================================================================
# MainMenu — Hauptmenue (Play/Continue/Character/Stats/Settings/Quit).
# ============================================================================
# Komplett prozedural gebaut (gleiches Prinzip wie die Turrets/Hazards/VFX
# dieser Session) — die zugehoerige .tscn enthaelt nur einen leeren
# CanvasLayer + Control-Root mit diesem Script, kein Hand-Layout im Editor.
# Grund: dieses Script muss in zwei UNTERSCHIEDLICHEN Kontexten funktionieren
# (siehe unten), und ein rein codebasierter Aufbau macht beide Kontexte zum
# selben Pfad, statt zwei leicht unterschiedliche Szenen pflegen zu muessen.
#
# ZWEI VERWENDUNGSKONTEXTE:
#   1. TITEL-BILDSCHIRM: res://scenes/main_menu.tscn ist run/main_scene
#      (project.godot) — die Anwendung startet direkt hier, es existiert noch
#      keine lebende Spieler-Instanz. "Fortsetzen" ist hier IMMER deaktiviert.
#   2. PAUSE-OVERLAY: pause_menu.gd instanziert dieses Script zusaetzlich als
#      Kind-Node UEBER der weiterhin lebenden, pausierten Spielszene (neuer
#      "Hauptmenue"-Button, siehe pause_menu.gd). "Fortsetzen" schliesst hier
#      nur das Overlay wieder und pausiert die Welt nicht neu.
#
# "FORTSETZEN" IST BEWUSST NICHT DASSELBE WIE "SPIELSTAND LADEN": es gibt in
# diesem Projekt keine Serialisierung des prozeduralen Dungeons (Raum-Layout,
# Gegner-Zustaende, Position). Ein echtes Fortsetzen nach einem kompletten
# Neustart der Anwendung ist damit ausserhalb dessen, was hier sicher blind
# (ohne lokale Godot-Instanz zum Testen) gebaut werden kann. "Fortsetzen"
# funktioniert deshalb ausschliesslich innerhalb DERSELBEN Laufzeit-Sitzung,
# ueber den Pause-Overlay-Weg oben — dort wird nie irgendetwas abgebaut, es
# muss also auch nichts wiederhergestellt werden. Siehe GameStats.has_live_run.
#
# ---------------------------------------------------------------------------
# PHASE "MENU REWORK": asymmetrisches Layout + Game Juice
# ---------------------------------------------------------------------------
# Vorher: zentriertes Panel mit reinen Text-Buttons auf schwarzem Grund.
# Jetzt:
#   * Hintergrund ist ein SubViewport mit eigener 3D-Welt (own_world_3d) statt
#     eines flachen ColorRects - background_scene (@export) kann spaeter eine
#     der Dungeon-Szenen hineinladen, ohne dass dieses Script noch einmal
#     angefasst werden muss. Ohne zugewiesene Szene faellt die Umgebung auf
#     die reine Hintergrundfarbe zurueck - optisch identisch zum alten
#     ColorRect, also kein Regressions-Risiko.
#   * Das UI-Menue selbst haengt linksbuendig in der linken Bildschirmhaelfte
#     (MarginContainer mit anchor_right = 0.46), damit die rechte Haelfte frei
#     fuer die 3D-Szene bleibt.
#   * Buttons sind in drei Gruppen unterteilt (Play/Continue - Character/Stats
#     - Settings/Quit), getrennt durch Spacer-Controls fuer eine klare
#     visuelle Hierarchie.
#   * Hover/Fokus ruecken den Button-Text per Tween nach rechts ein und faerben
#     ihn rot ein - siehe _wire_button_juice(). WICHTIG: es wird NICHT direkt
#     button.position animiert, weil der Button in einer VBoxContainer haengt,
#     die seine Position bei jedem Sort-Durchgang ueberschreiben wuerde (siehe
#     denselben Fallstrick, den item_description_hud.gd im Kopfkommentar
#     dokumentiert). Stattdessen wird der linke Rand eines umschliessenden
#     MarginContainer per Theme-Override getweent - der VBoxContainer
#     positioniert nur den WRAPPER, das Einruecken passiert INNERHALB davon.

signal continue_requested()

const GAMEPLAY_SCENE_PATH: String = "res://scenes/level_generation_test.tscn"
## Deckt sich mit StageManager.final_stage's Skript-Default (stage_manager.gd)
## - wird hier NICHT von dort gelesen, weil Stages.final_stage zur Laufzeit
## durch eine vorherige Speedrun-Runde bereits auf 1 stehen KOENNTE (Autoloads
## ueberleben Szenenwechsel innerhalb derselben Anwendungssitzung).
const NORMAL_FINAL_STAGE: int = 5
const SPEEDRUN_FINAL_STAGE: int = 1

const PANEL_COLOR: Color = Color(0.05, 0.05, 0.08, 0.86)
const BG_COLOR: Color = Color(0.03, 0.03, 0.05, 1.0)
const TITLE_COLOR: Color = Color(0.92, 0.92, 0.98)
const ACCENT_COLOR: Color = Color(0.55, 0.75, 1.0)

## Menue-Buttons: Ruhefarbe (heller Grauton) und Hover/Fokus-Farbe (kraeftiges
## Rot, passend zum Dungeon-/Lava-Look des Spiels).
const MENU_TEXT_COLOR: Color = Color(0.88, 0.88, 0.92, 0.95)
const MENU_HOVER_COLOR: Color = Color(0.92, 0.20, 0.20, 1.0)
## Wie weit ein gehoverter/fokussierter Button nach rechts einrueckt.
const BUTTON_INDENT_PX: float = 18.0
const BUTTON_TWEEN_DURATION: float = 0.22

const LOGO_BOB_AMPLITUDE: float = 5.0
const LOGO_BOB_LEG_DURATION: float = 1.8

const CHARACTER_RESOURCE_PATHS: Array[String] = [
	"res://resources/char_1.tres",
	"res://resources/char_2.tres",
	"res://resources/char_3.tres",
	"res://resources/char_4.tres",
]

## Optionale 3D-Szene fuer den Hintergrund-Viewport (siehe Kopfkommentar).
## Leer lassen = reine Hintergrundfarbe, kein Fehler.
@export var background_scene: PackedScene = null
## Optionales Logo-Bild. Leer lassen = Fallback auf einen grossen Schriftzug
## ("WHIPLASH"), damit das Menue auch ohne fertige Logo-Grafik funktioniert.
@export var logo_texture: Texture2D = null

## Wie schnell die Hintergrund-Kamera um die Szene kreist (Grad/Sekunde) -
## bewusst sehr langsam: soll dynamisch wirken (siehe Minecraft-Titelbild-
## Panorama als Vorbild), nicht ablenken oder Bewegungsunwohlsein ausloesen.
@export var camera_orbit_speed_deg: float = 3.0

var _roster: Array[CharacterData] = []
var _character_index: int = 0

var _screens: Dictionary = {}  # String -> Control
## Welcher Screen gerade sichtbar ist - siehe _show_screen(). Fuer die
## ESC-Navigation (_handle_escape): "sind wir gerade in einem Submenue?"
var _current_screen_id: String = "root"
var _continue_button: Button = null
var _settings_instance: SettingsMenu = null
## Button, der beim Anzeigen des Root-Screens den Eingabefokus bekommt -
## noetig fuer Tastatur-/Gamepad-Navigation ohne Maus.
var _root_first_button: Button = null

## Live-3D-Vorschau statt einer flachen Portrait-Textur (die bei keinem der
## vier Charaktere gepflegt ist - ohne diesen Umbau war im Character-Screen
## schlicht nichts zu sehen). Eigener, isolierter Viewport wie beim
## Hintergrund, damit Kamera/Licht unabhaengig vom Rest des Menues bleiben.
var _character_viewport: SubViewport = null
## Aktuell gezeigtes Modell - wird bei jedem Charakterwechsel ersetzt (siehe
## _refresh_character_preview_model()) und in _process() sanft gedreht.
var _character_preview_model: Node3D = null

var _character_name_label: Label = null
var _character_desc_label: Label = null
var _character_abilities_label: Label = null

var _stats_label: Label = null

var _background_viewport: SubViewport = null
var _logo_node: Control = null
## Traegt die Hintergrund-Kamera - wird in _process() kontinuierlich um Y
## gedreht, siehe camera_orbit_speed_deg.
var _camera_rig: Node3D = null

## Button -> laufender Hover/Fokus-Tween. Noetig, damit ein zweiter Hover
## kurz nach dem ersten (schnelle Mausbewegung) den alten Tween abbricht
## statt gegen ihn anzulaufen.
var _button_tweens: Dictionary = {}
## Button -> das separate Text-Label daneben (siehe _make_button() fuer den
## Grund der Trennung von Hitbox und sichtbarem Text).
var _button_labels: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_load_roster()
	_build_background()
	_build_root_screen()
	_build_play_screen()
	_build_character_screen()
	_build_stats_screen()

	_show_screen("root")


## ESC schliesst IMMER genau EINE Ebene: zuerst Settings (falls offen), sonst
## zurueck zum Root-Screen (falls gerade ein Submenue - Play/Character/Stats -
## offen ist). Auf dem Root-Screen selbst tut ESC nichts, da ist bereits die
## oberste Ebene.
##
## Raw KEY_ESCAPE statt der "ui_cancel"-Action, damit dasselbe Muster wie
## pause_menu.gd/settings_menu.gd gilt (siehe dort) - dieses Projekt prueft
## Escape durchgehend so, unabhaengig davon, ob "ui_cancel" im Input-Map
## angepasst wurde.
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		return
	if _handle_escape():
		get_viewport().set_input_as_handled()


func _handle_escape() -> bool:
	if _settings_instance != null and is_instance_valid(_settings_instance) and _settings_instance.visible:
		_on_settings_back()
		return true
	if _current_screen_id != "root":
		_show_screen("root")
		return true
	return false


const CHARACTER_PREVIEW_SPIN_DEG: float = 14.0

## Laesst die Hintergrund-Kamera langsam um die Szene kreisen (siehe
## camera_orbit_speed_deg). Laeuft dank process_mode = PROCESS_MODE_ALWAYS
## auch weiter, wenn dieses Menue als pausiertes Overlay ueber einem
## laufenden Run haengt. Dreht ausserdem sanft das Charakter-Vorschaumodell,
## solange der Character-Screen tatsaechlich sichtbar ist (kein Grund, ein
## unsichtbares Modell weiterzudrehen).
func _process(delta: float) -> void:
	if _camera_rig != null and is_instance_valid(_camera_rig):
		_camera_rig.rotation.y += deg_to_rad(camera_orbit_speed_deg) * delta

	if _current_screen_id == "character" and _character_preview_model != null \
			and is_instance_valid(_character_preview_model):
		_character_preview_model.rotation.y += deg_to_rad(CHARACTER_PREVIEW_SPIN_DEG) * delta


func _load_roster() -> void:
	for path: String in CHARACTER_RESOURCE_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var data: CharacterData = load(path) as CharacterData
		if data != null:
			_roster.append(data)


# ============================================================================
# Hintergrund — SubViewport mit eigener 3D-Welt statt flachem ColorRect.
# ============================================================================
## Baut den Hintergrund aus mehreren Ebenen unter dem UI:
##   1. SubViewportContainer/SubViewport mit eigener 3D-Welt (own_world_3d) -
##      isoliert von der ggf. weiterhin lebenden Spielwelt im Pause-Overlay-
##      Fall. background_scene wird hier hineingeladen, falls gesetzt.
##   2. MEHRERE MOEGLICHE "SZENEN" STATT EINER (wie beim Minecraft-Titelbild-
##      Panorama): ohne eigene background_scene wird eines der eingebauten
##      Etagen-Themen (stage_theme.gd - Kellergewoelbe/Tiefkuehlhaus/Sandgrube/
##      Fleischfabrik/Neon-Keller) zufaellig gewaehlt und faerbt sowohl die
##      Umgebung (Nebel/Ambient) als auch die Deko-Alkove ein - bei jedem
##      Aufbau dieses Menues (Titelbildschirm-Start, Rueckkehr aus einem Run)
##      kann so ein spuerbar anderes Bild herauskommen, ohne 5 komplett
##      separate 3D-Layouts pflegen zu muessen.
##   3. Eine langsam um die Szene kreisende Kamera (siehe _process()) fuer
##      den dynamischen Panorama-Effekt.
##   4. Ein paar stillgelegte Gegner-Instanzen als Deko (_build_backdrop_enemy)
##      - stehen/lauern nur herum, komplett handlungsunfaehig (siehe dortiger
##      Kommentar), machen die Szene aber weniger leer/eintoenig.
##      HINWEIS: KEIN Charakter-Standbild mehr hier - das gehoert stattdessen
##      in den Character-Screen (siehe _build_character_preview()), wo man
##      tatsaechlich gezielt hinschaut.
##   5/6. Abdunklungs-Ebenen: ein gleichmaessiges Overlay (macht Text auf
##      JEDER Szene lesbar) plus ein Verlauf, der NUR die linke Seite (wo das
##      Menue sitzt) staerker abdunkelt, damit die rechte Bildhaelfte die
##      3D-Szene trotzdem sichtbar zeigt.
func _build_background() -> void:
	var viewport_container := SubViewportContainer.new()
	viewport_container.name = "BackgroundViewport"
	viewport_container.stretch = true
	viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(viewport_container)

	var viewport := SubViewport.new()
	viewport.name = "Background3D"
	# Eigene Welt: im Pause-Overlay-Kontext laeuft dieses Menue UEBER der
	# weiterhin existierenden, nur pausierten Spielszene - ohne own_world_3d
	# wuerde der Hintergrund-Viewport versehentlich dieselbe 3D-Welt (und
	# damit dieselben Lichter/Nebel/Kamera-Konflikte) wie das Spiel teilen.
	viewport.own_world_3d = true
	viewport.handle_input_locally = false
	viewport.transparent_bg = false
	viewport_container.add_child(viewport)
	_background_viewport = viewport

	var theme: StageTheme = _pick_backdrop_theme()
	_build_environment(viewport, theme)
	_build_camera_rig(viewport)

	if background_scene != null:
		viewport.add_child(background_scene.instantiate())
	else:
		# Kein Hintergrund zugewiesen -> nicht einfach schwarz stehenlassen,
		# aber auch KEINE echte Raum-Szene laden (siehe Kopfkommentar bei
		# background_scene: die erwartet Level-Generator-Pipeline/Autoloads,
		# die am Titelbildschirm gar nicht existieren). Stattdessen eine
		# kleine, komplett ungefaehrliche Deko-Alkove aus denselben Bausteinen
		# wie die echten Raeume (psx_material, Lava-Hazard-Szene, Fackel-
		# Script) - rein optisch, ohne Gameplay-Abhaengigkeiten.
		_build_default_backdrop(viewport, theme)

	var overlay := ColorRect.new()
	overlay.name = "BackgroundOverlay"
	overlay.color = Color(0.02, 0.02, 0.03, 0.55)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.01, 0.01, 0.02, 0.88))
	gradient.set_color(1, Color(0.01, 0.01, 0.02, 0.0))
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_LINEAR
	gradient_texture.fill_from = Vector2(0.0, 0.5)
	gradient_texture.fill_to = Vector2(0.62, 0.5)
	var side_shade := TextureRect.new()
	side_shade.name = "SideShade"
	side_shade.texture = gradient_texture
	side_shade.stretch_mode = TextureRect.STRETCH_SCALE
	side_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	side_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(side_shade)


## Zufaellige Wahl aus den eingebauten Etagen-Themen (stage_theme.gd) - siehe
## Kopfkommentar bei _build_background() fuer die "mehrere Szenen"-Idee
## dahinter. null nur, falls build_all() aus irgendeinem Grund leer waere.
func _pick_backdrop_theme() -> StageTheme:
	var themes: Array[StageTheme] = StageTheme.build_all()
	if themes.is_empty():
		return null
	return themes[randi() % themes.size()]


## WorldEnvironment mit Farbwerten aus dem gewaehlten Theme (Fallback auf die
## alten festen Werte, falls kein Theme vorliegt).
func _build_environment(viewport: SubViewport, theme: StageTheme) -> void:
	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = theme.fog_color if theme != null else BG_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = theme.fog_color if theme != null else Color(0.10, 0.10, 0.14)
	environment.ambient_light_energy = (theme.ambient_energy if theme != null else 0.5) * 0.6
	environment.fog_enabled = true
	environment.fog_light_color = theme.fog_color if theme != null else Color(0.04, 0.04, 0.06)
	environment.fog_density = theme.fog_density if theme != null else 0.025
	world_env.environment = environment
	viewport.add_child(world_env)


## CameraRig (Node3D) + Camera3D als dessen Kind. _process() dreht NUR den
## Rig um Y - die Kamera behaelt ihre lokale Position/Neigung relativ dazu
## bei und kreist dadurch gleichmaessig um den Szenenmittelpunkt, waehrend
## sie ihn im Blick behaelt.
func _build_camera_rig(viewport: SubViewport) -> void:
	var rig := Node3D.new()
	rig.name = "CameraRig"
	viewport.add_child(rig)
	_camera_rig = rig

	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(0.0, 2.4, 6.5)
	camera.rotation_degrees = Vector3(-7.0, -10.0, 0.0)
	camera.current = true
	rig.add_child(camera)


## Kleine, symmetrische Alkove (Boden + Rueckwand + zwei Seitenwaende), damit
## die Kamera aus _build_background() bei JEDER Blickrichtung auf feste
## Geometrie statt auf Leere trifft. Verwendet dasselbe psx_material.tres wie
## die echten Raeume (optische Konsistenz, im gewaehlten Theme eingefaerbt),
## plus eine dekorative Lava-Lache (scenes/hazards/lemonade.tscn - komplett
## selbststaendig, reagiert nur auf Koerper mit einer Health-Komponente, von
## denen hier keine existieren) und zwei Fackeln (scripts/vfx/torch.gd -
## reines Licht+Partikel-Script ohne Autoload-Abhaengigkeiten) fuer etwas
## Lebendigkeit. Alles rein dekorativ, keine Collision fuer irgendwen
## relevant, da dieser Viewport nie einen Spieler-Koerper enthaelt.
func _build_default_backdrop(viewport: SubViewport, theme: StageTheme) -> void:
	var floor_material: Material = _make_backdrop_material(theme, true)
	var wall_material: Material = _make_backdrop_material(theme, false)

	var floor_mesh := MeshInstance3D.new()
	floor_mesh.name = "BackdropFloor"
	var floor_box := BoxMesh.new()
	floor_box.size = Vector3(26.0, 1.0, 26.0)
	floor_mesh.mesh = floor_box
	floor_mesh.position = Vector3(0.0, -0.5, 0.0)
	if floor_material != null:
		floor_mesh.material_override = floor_material
	viewport.add_child(floor_mesh)

	_add_backdrop_wall(viewport, Vector3(26.0, 9.0, 1.0), Vector3(0.0, 4.0, -11.0), wall_material)
	_add_backdrop_wall(viewport, Vector3(1.0, 9.0, 22.0), Vector3(-12.5, 4.0, -2.0), wall_material)
	_add_backdrop_wall(viewport, Vector3(1.0, 9.0, 22.0), Vector3(12.5, 4.0, -2.0), wall_material)

	var lava_scene: PackedScene = load("res://scenes/hazards/lemonade.tscn")
	if lava_scene != null:
		var lava: LavaHazard = lava_scene.instantiate() as LavaHazard
		if lava != null:
			lava.position = Vector3(1.5, 0.02, -5.0)
			lava.size = Vector3(5.0, 0.6, 5.0)
			if theme != null:
				lava.lava_color = theme.hazard_color
			viewport.add_child(lava)

	_add_backdrop_torch(viewport, Vector3(-11.9, 3.4, -4.0))
	_add_backdrop_torch(viewport, Vector3(11.9, 3.4, -6.0))

	# Zwei stillgelegte Gegner als Deko (siehe _build_backdrop_enemy()) -
	# reine Atmosphaere, "etwas lauert im Dunkeln", statt einer leeren Alkove.
	_build_backdrop_enemy(viewport, load("res://scenes/enemies/dummy.tscn"), Vector3(-7.5, 0.0, -6.5), 35.0)
	_build_backdrop_enemy(viewport, load("res://scenes/scout_dummy.tscn"), Vector3(7.0, 0.0, -8.0), -50.0)


## Eigene Kopie von psx_material.tres, eingefaerbt in floor_color/wall_color
## des Themes.
##
## WARUM duplicate(): psx_material.tres ist eine gecachte, GETEILTE Resource
## - dieselbe, mit der auch das eigentliche Spiel seine Waende/Boeden
## einfaerbt. Ohne eigene Kopie wuerde das Einfaerben hier rueckwirkend JEDE
## Wand im ganzen Spiel mitfaerben (derselbe Fallstrick, den
## room_instance.gd._apply_theme_recursive() und vfx_manager.gd._apply_dual_tint()
## aus genau diesem Grund ebenfalls per duplicate() umgehen).
func _make_backdrop_material(theme: StageTheme, is_floor: bool) -> Material:
	var base: Material = load("res://materials/psx_material.tres")
	if base == null:
		return null
	var unique: Material = base.duplicate()
	if theme != null and unique is ShaderMaterial:
		var tint: Color = theme.floor_color if is_floor else theme.wall_color
		(unique as ShaderMaterial).set_shader_parameter("albedo_color", tint)
	return unique


func _add_backdrop_wall(viewport: SubViewport, size: Vector3, pos: Vector3, material: Material) -> void:
	var wall := MeshInstance3D.new()
	wall.name = "BackdropWall"
	var box := BoxMesh.new()
	box.size = size
	wall.mesh = box
	wall.position = pos
	if material != null:
		wall.material_override = material
	viewport.add_child(wall)


func _add_backdrop_torch(viewport: SubViewport, pos: Vector3) -> void:
	var torch := Node3D.new()
	torch.name = "BackdropTorch"
	torch.set_script(load("res://scripts/vfx/torch.gd"))
	torch.position = pos
	viewport.add_child(torch)


## Platziert einen KOMPLETTEN Gegner (nicht nur sein Modell) als Deko-Figur
## in die Szene, dann sofort - im selben Aufruf, kein Frame Verzoegerung -
## neutralisiert: Zustandsautomat/Bewegung/Kollision/Angriff sind tot, NUR
## die Lauf-Animation laeuft optisch weiter (siehe Kommentar bei
## _neutralize_backdrop_enemy() dazu) - "steht auf der Stelle, animiert aber
## weiter", nicht buchstaeblich eingefroren wie eine Statue.
##
## ##########################################################################
## WARUM DIE GANZE GEGNER-SZENE UND NICHT NUR EIN HERAUSGELOESTES MODELL:
## ##########################################################################
## Anders als beim Spieler (ein Modell pro Charakter-Szene) liegt in der
## Gegner-.glb (assets/characters/lowpoly_robots.glb) ALLE Robotertypen
## nebeneinander in EINEM Koordinatensystem - enemy_ai.gd._setup_visuals()
## waehlt beim Eintreten in den Baum das passende Armature aus, zentriert es
## ueber der Bindepose und baut pro Surface das PSX-Shader-Material. Das
## liesse sich nicht gefahrlos von Hand nachbauen, ohne genau diesen Code zu
## duplizieren. Die Szene wird deshalb GANZ NORMAL instanziert (add_child()
## loest _ready()/_setup_visuals() synchron aus und erledigt die Arbeit
## korrekt) - aber noch WAEHREND desselben Funktionsaufrufs, ohne dass
## zwischendurch je ein Physik-/Prozess-Frame lief, neutralisiert: Kollision/
## Hitbox/Navigation entfernt, aus der Gruppe "enemies" ausgetragen (sonst
## zaehlt eine Deko-Leiche anderswo im Spiel - z.B. bei einer Raum-
## Gegneranzahl - faelschlich mit) und die PartyManager-Signalverbindung
## geloest.
func _build_backdrop_enemy(viewport: SubViewport, enemy_scene: PackedScene, pos: Vector3, yaw_deg: float) -> void:
	if enemy_scene == null:
		return
	var enemy: EnemyAI = enemy_scene.instantiate() as EnemyAI
	if enemy == null:
		return

	viewport.add_child(enemy)  # loest _ready()/_setup_visuals() synchron aus
	_neutralize_backdrop_enemy(enemy)

	enemy.position = pos
	enemy.rotation.y = deg_to_rad(yaw_deg)


## set_process(false)/set_physics_process(false) schalten NUR die skript-
## seitigen _process()/_physics_process()-Callbacks ab - also die komplette
## Zustandsautomat-/Bewegungs-/Angriffslogik in enemy_ai.gd. Ein AnimationPlayer
## laeuft aber ueber Godots INTERNE Prozess-Benachrichtigung weiter (davon
## unberuehrt) und spult die zuletzt gestartete Lauf-Animation einfach weiter
## ab - der Gegner "geht" also optisch auf der Stelle, bewegt sich aber nie
## vom Platz. Bewusst SO belassen (nicht zusaetzlich per .stop()/.pause() auf
## dem AnimationPlayer eingefroren): wirkt lebendiger als eine reine Statue,
## ohne dass er tatsaechlich herumlaeuft.
func _neutralize_backdrop_enemy(enemy: EnemyAI) -> void:
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.remove_from_group("enemies")

	if PartyManager.active_player_changed.is_connected(enemy._on_active_player_changed):
		PartyManager.active_player_changed.disconnect(enemy._on_active_player_changed)

	for node: Node in _iterate_all_descendants(enemy):
		if node is CollisionShape3D or node is Area3D or node is NavigationAgent3D \
				or node is AudioStreamPlayer or node is AudioStreamPlayer3D:
			node.queue_free()
		else:
			node.set_process(false)
			node.set_physics_process(false)


func _iterate_all_descendants(node: Node) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in node.get_children():
		out.append(child)
		out.append_array(_iterate_all_descendants(child))
	return out


# ============================================================================
# Bau-Helfer — gemeinsamer Look fuer alle Screens.
# ============================================================================
func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	return style


## Legt einen neuen Screen als zentrierten Panel/VBox-Aufbau an, haengt ihn
## direkt unter self und traegt ihn in _screens ein. Der Aufrufer fuellt
## anschliessend das zurueckgegebene VBoxContainer mit eigenem Inhalt.
func _create_screen(id: String) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.visible = false
	add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	panel.custom_minimum_size = Vector2(420, 0)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	_screens[id] = center
	return box


func _show_screen(id: String) -> void:
	_current_screen_id = id
	for key: String in _screens.keys():
		(_screens[key] as Control).visible = (key == id)
	if id == "stats":
		_refresh_stats_screen()
	elif id == "character":
		_refresh_character_screen()
	elif id == "root":
		_refresh_continue_button()
		if _root_first_button != null and is_instance_valid(_root_first_button):
			_root_first_button.grab_focus()


func _make_title(text: String, size: int = 28) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TITLE_COLOR)
	return label


func _make_spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


## Baut eine STATISCHE Hitbox (Button, unsichtbar, ohne eigenen Text) plus
## ein separates, frei darueber schwebendes Text-Label. Haengt beides direkt
## an "parent" und gibt den BUTTON zum Verbinden von .pressed zurueck -
## Aufrufer muessen ihn NICHT mehr selbst per add_child() einhaengen.
##
## ##########################################################################
## BUGFIX "Hover-Effekt zuckt, weil die Hitbox mitwandert"
## ##########################################################################
## Die erste Version tweente die Position des BUTTONS selbst (bzw. eines ihn
## umschliessenden Wrappers). Der Button IST aber gleichzeitig seine eigene
## Maus-Hitbox: sobald er beim Hovern nach rechts einrueckt, steht die Maus
## (die sich ja nicht mitbewegt) nicht mehr ueber ihm -> mouse_exited feuert
## -> der Button faehrt zurueck -> die Maus steht wieder drueber ->
## mouse_entered feuert -> er rueckt wieder ein -> Endlosschleife, sichtbar
## als staendiges Zucken.
##
## LOESUNG: Hitbox und sichtbarer Text werden getrennt. "button" bleibt IMMER
## an derselben Stelle (volle Flaeche von "row", per Anker - reagiert also
## normal auf Fenstergroessen-Aenderungen, bewegt sich aber nie durch die
## Animation). Er hat keinen eigenen Text (text = ""), sondern dient nur als
## Hover-/Fokus-/Klick-Empfaenger. Das sichtbare "label" liegt daneben, hat
## mouse_filter = IGNORE (bekommt also selbst nie Maus-Events) und ist NICHT
## containerverwaltet (row ist ein einfaches Control, kein Container) - sein
## .position darf deshalb frei getweent werden, ohne dass irgendetwas dagegen
## ankaempft. Die Maus bleibt so waehrend der ganzen Animation ueber der
## unbewegten Hitbox, das Zucken ist strukturell unmoeglich.
func _make_button(
	parent: Control, text: String, font_size: int = 20,
	min_size: Vector2 = Vector2(0.0, 40.0), center: bool = false
) -> Button:
	var row := Control.new()
	row.custom_minimum_size = min_size
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	parent.add_child(row)

	var button := Button.new()
	button.text = ""
	button.focus_mode = Control.FOCUS_ALL
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_clear_button_chrome(button)
	row.add_child(button)

	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", MENU_TEXT_COLOR)
	label.position = Vector2.ZERO
	if center:
		# Kleine, fest dimensionierte Buttons (die "<"/">"-Pfeile): Label
		# deckt exakt die Hitbox ab und zentriert den Text darin.
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size = min_size
	else:
		# Menue-Zeilen: die Hitbox ("row") wird von ihrem Container auf die
		# volle Spaltenbreite gestreckt, aber diese Breite kennen wir hier
		# noch nicht (steht erst nach dem Layout fest). Grosszuegige feste
		# Breite statt dessen - reicht fuer jeden kurzen Menuepunkt-Text
		# dieses Spiels, ohne dass er abgeschnitten wird.
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.size = Vector2(420.0, min_size.y)
	row.add_child(label)

	_button_labels[button] = label
	_wire_button_juice(button, label)
	return button


## Entfernt die Standard-Button-Kaestchen (normal/hover/pressed/focus) - der
## Button ist jetzt reine Hitbox (kein eigener Text mehr, siehe _make_button),
## sichtbares Feedback kommt ausschliesslich vom Label.
func _clear_button_chrome(button: Button) -> void:
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("pressed", empty)
	button.add_theme_stylebox_override("focus", empty)
	button.add_theme_stylebox_override("disabled", empty)


## Game-Juice: Hover ODER Fokus (Maus bzw. Tastatur/Gamepad) rueckt den
## Button-Text nach rechts ein und faerbt ihn rot; beim Verlassen faehrt
## beides sanft zurueck. Siehe _make_button()-Kopfkommentar dafuer, warum das
## auf dem LABEL laeuft und nicht auf der Hitbox selbst.
func _wire_button_juice(button: Button, label: Label) -> void:
	var on_focus := func() -> void: _animate_button(button, label, true)
	var on_unfocus := func() -> void: _animate_button(button, label, false)

	button.mouse_entered.connect(on_focus)
	button.focus_entered.connect(on_focus)
	button.mouse_exited.connect(on_unfocus)
	button.focus_exited.connect(on_unfocus)


func _animate_button(button: Button, label: Label, active: bool) -> void:
	if not is_instance_valid(button) or not is_instance_valid(label):
		return
	# Deaktivierte Buttons (z.B. "Continue" ohne laufenden Run) sollen nicht
	# rot aufleuchten oder einruecken - siehe _set_button_disabled().
	if button.disabled:
		return

	var old_tween: Tween = _button_tweens.get(button)
	if old_tween != null and old_tween.is_valid():
		old_tween.kill()

	var start_color: Color = label.get_theme_color("font_color")
	var target_color: Color = MENU_HOVER_COLOR if active else MENU_TEXT_COLOR
	var target_x: float = BUTTON_INDENT_PX if active else 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:x", target_x, BUTTON_TWEEN_DURATION) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(v: Color) -> void:
			if is_instance_valid(label):
				label.add_theme_color_override("font_color", v),
		start_color, target_color, BUTTON_TWEEN_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	_button_tweens[button] = tween


## Einziger erlaubter Weg, um button.disabled zu setzen (statt es direkt von
## aussen zuzuweisen): der Button traegt seit dem Hitbox/Label-Split (siehe
## _make_button) keinen eigenen Text mehr, Godots eingebautes
## font_disabled_color wirkt also ins Leere. Dimmt stattdessen das Label und
## bricht einen evtl. laufenden Hover-Tween sauber ab, statt den Button
## eingerueckt/rot "einzufrieren".
func _set_button_disabled(button: Button, disabled: bool) -> void:
	if not is_instance_valid(button):
		return
	button.disabled = disabled

	var label: Label = _button_labels.get(button)
	if label == null or not is_instance_valid(label):
		return

	if disabled:
		var old_tween: Tween = _button_tweens.get(button)
		if old_tween != null and old_tween.is_valid():
			old_tween.kill()
		label.position.x = 0.0

	label.add_theme_color_override(
		"font_color", Color(MENU_TEXT_COLOR, 0.35) if disabled else MENU_TEXT_COLOR
	)


# ============================================================================
# Logo — Bild (falls zugewiesen) oder Text-Fallback, mit Schwebe-Animation.
# ============================================================================
func _build_logo(parent: Control) -> void:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(0.0, 88.0)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(holder)

	if logo_texture != null:
		var rect := TextureRect.new()
		rect.texture = logo_texture
		rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.custom_minimum_size = Vector2(0.0, 88.0)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(rect)
		_logo_node = rect
	else:
		var label := _make_title("WHIPLASH", 42)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(label)
		_logo_node = label

	_start_logo_bob()


## Leichte, unendliche Auf-Ab-Bewegung. Laeuft auf _logo_node.position - das
## ist sicher, weil "holder" ein einfaches Control (KEIN Container) ist und
## seine Kinder deshalb nicht selbst positioniert; anders als bei den
## Buttons oben besteht hier also kein Konflikt mit einem Layout-Durchgang.
func _start_logo_bob() -> void:
	if _logo_node == null:
		return
	var tween: Tween = create_tween()
	tween.set_loops(0)
	tween.tween_property(_logo_node, "position:y", -LOGO_BOB_AMPLITUDE, LOGO_BOB_LEG_DURATION) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_logo_node, "position:y", LOGO_BOB_AMPLITUDE, LOGO_BOB_LEG_DURATION) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# ============================================================================
# Root-Screen — linksbuendig, drei Button-Gruppen.
# ============================================================================
func _build_root_screen() -> void:
	var root_layer := Control.new()
	root_layer.name = "RootScreen"
	root_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_layer.visible = false
	add_child(root_layer)
	_screens["root"] = root_layer

	# Linke Bildschirmhaelfte (etwas weniger als 50%, damit rechts sichtbar
	# Platz fuer die 3D-Hintergrundszene bleibt).
	var side := MarginContainer.new()
	side.anchor_left = 0.0
	side.anchor_top = 0.0
	side.anchor_right = 0.46
	side.anchor_bottom = 1.0
	side.offset_left = 0.0
	side.offset_top = 0.0
	side.offset_right = 0.0
	side.offset_bottom = 0.0
	side.mouse_filter = Control.MOUSE_FILTER_PASS
	side.add_theme_constant_override("margin_left", 80)
	side.add_theme_constant_override("margin_top", 64)
	side.add_theme_constant_override("margin_right", 40)
	side.add_theme_constant_override("margin_bottom", 64)
	root_layer.add_child(side)

	# SHRINK_CENTER: der Inhalt haengt vertikal mittig in der linken Spalte,
	# statt oben zu kleben oder ueber die volle Hoehe gestreckt zu werden.
	var content := VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_theme_constant_override("separation", 4)
	side.add_child(content)

	_build_logo(content)
	content.add_child(_make_spacer(40.0))

	# --- Gruppe 1: Play/Continue -----------------------------------------
	var play_button: Button = _make_button(content, "Play", 22)
	play_button.pressed.connect(func() -> void: _show_screen("play"))

	_continue_button = _make_button(content, "Continue", 22)
	_continue_button.pressed.connect(_on_continue_pressed)

	content.add_child(_make_spacer(22.0))

	# --- Gruppe 2: Character/Stats -----------------------------------------
	var character_button: Button = _make_button(content, "Character", 22)
	character_button.pressed.connect(func() -> void: _show_screen("character"))

	var stats_button: Button = _make_button(content, "Stats", 22)
	stats_button.pressed.connect(func() -> void: _show_screen("stats"))

	content.add_child(_make_spacer(22.0))

	# --- Gruppe 3: Settings/Quit -----------------------------------------
	var settings_button: Button = _make_button(content, "Settings", 22)
	settings_button.pressed.connect(_on_settings_pressed)

	var quit_button: Button = _make_button(content, "Quit", 22)
	quit_button.pressed.connect(func() -> void: get_tree().quit())

	_root_first_button = play_button


func _refresh_continue_button() -> void:
	if _continue_button == null:
		return
	_set_button_disabled(_continue_button, not GameStats.has_live_run)


func _on_continue_pressed() -> void:
	if not GameStats.has_live_run:
		return
	continue_requested.emit()


# ============================================================================
# Play-Submenu — Normal / Speedrun
# ============================================================================
func _build_play_screen() -> void:
	var box: VBoxContainer = _create_screen("play")
	box.add_child(_make_title("Play", 22))

	var normal_button: Button = _make_button(box, "Normal")
	normal_button.pressed.connect(func() -> void: _start_run(false))

	var speedrun_button: Button = _make_button(box, "Speedrun")
	speedrun_button.pressed.connect(func() -> void: _start_run(true))

	var speedrun_hint := Label.new()
	speedrun_hint.text = "Speedrun: eine Etage, Bestenliste nach Zeit."
	speedrun_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speedrun_hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	speedrun_hint.add_theme_font_size_override("font_size", 13)
	box.add_child(speedrun_hint)

	var back_button: Button = _make_button(box, "Back")
	back_button.pressed.connect(func() -> void: _show_screen("root"))


## Startet einen neuen Run. In der PAUSE-OVERLAY-Nutzung (GameStats.has_live_run
## == true) wird der bereits laufende ueber RunRestart verworfen und neu
## aufgebaut — derselbe Weg, den auch der Restart-Button in pause_menu.gd
## nimmt (siehe dortiger Kopfkommentar zu _restart_level: Juice/Items/Loot/
## PartyManager muessen ALLE zurueckgesetzt werden, ein blosses
## change_scene_to_file() wuerde das nicht leisten).
func _start_run(speedrun: bool) -> void:
	Stages.final_stage = SPEEDRUN_FINAL_STAGE if speedrun else NORMAL_FINAL_STAGE

	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if GameStats.has_live_run and RunRestart != null and RunRestart.has_method("restart"):
		RunRestart.restart()
		continue_requested.emit()
		return

	get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH)


# ============================================================================
# Character-Screen
# ============================================================================
## Eigener, kleiner 3D-Viewport fuer die Charakter-Vorschau - isoliert
## (own_world_3d) wie der Hintergrund-Viewport, mit eigenem Licht/Kamera,
## unabhaengig davon, was gerade im Hintergrund zu sehen ist. Der Rahmen
## (PanelContainer) gibt ihm eine feste Flaeche innerhalb der zentrierten
## Character-Karte.
func _build_character_preview(parent: Control) -> void:
	var frame := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.03, 0.045, 0.9)
	style.set_corner_radius_all(4)
	style.set_border_width_all(1)
	style.border_color = Color(1.0, 1.0, 1.0, 0.08)
	frame.add_theme_stylebox_override("panel", style)
	frame.custom_minimum_size = Vector2(0.0, 240.0)
	parent.add_child(frame)

	var viewport_container := SubViewportContainer.new()
	viewport_container.stretch = true
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(viewport_container)

	var viewport := SubViewport.new()
	viewport.own_world_3d = true
	viewport.handle_input_locally = false
	viewport.transparent_bg = false
	viewport_container.add_child(viewport)
	_character_viewport = viewport

	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.03, 0.03, 0.045, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.55, 0.62)
	environment.ambient_light_energy = 1.0
	world_env.environment = environment
	viewport.add_child(world_env)

	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
	key_light.light_energy = 1.2
	viewport.add_child(key_light)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 1.1, 3.4)
	camera.rotation_degrees = Vector3(-8.0, 0.0, 0.0)
	camera.current = true
	viewport.add_child(camera)


## Ersetzt das gezeigte Modell durch das des uebergebenen Charakters.
##
## Instanziert bewusst NICHT die volle Spieler-Szene dauerhaft: die haengt
## Kamera-/Input-/Combat-/Health-Logik dran, die hier weder gebraucht wird
## noch sicher liefe (kein PartyManager-Setup fuer diesen Titelbildschirm-
## Kontext). Stattdessen wird nur der CharacterModel-Teilbaum herausgeloest
## und der Rest der temporaeren Instanz sofort wieder freigegeben.
func _refresh_character_preview_model(data: CharacterData) -> void:
	if _character_viewport == null:
		return

	if _character_preview_model != null and is_instance_valid(_character_preview_model):
		_character_preview_model.queue_free()
	_character_preview_model = null

	if data == null or data.player_scene == null:
		return

	var instance: Node = data.player_scene.instantiate()
	var model: Node3D = instance.get_node_or_null("CharacterModel") as Node3D
	if model == null:
		instance.queue_free()
		return

	instance.remove_child(model)
	instance.queue_free()

	_sanitize_character_model(model)
	_character_viewport.add_child(model)
	model.position += Vector3(0.0, -1.0, 0.0)
	# KEINE zusaetzliche Y-Rotation: die Kamera hat selbst keinen Yaw (schaut
	# von +Z geradeaus auf -Z), und CharacterModel traegt in den Charakter-
	# Szenen bereits KEINE eigene Rotation (nur Skalierung/Boden-Ausgleich,
	# siehe char_ningning.tscn etc.) - das Modell schaut im Rohzustand also
	# schon zur Kamera. Ein vorheriger Versuch, hier zusaetzlich einzudrehen
	# (+200 Grad), drehte es stattdessen VON der Kamera weg.
	_character_preview_model = model


## Entfernt alles am Vorschau-Modell, das unerwuenschte Nebenwirkungen haette:
## Audio, aktive Skripte (IK-/Footstep-Logik) und Kollision - gleiche
## Begruendung wie ghost_trail.gd._sanitize_ghost().
func _sanitize_character_model(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer3D or node is AudioStreamPlayer2D:
		node.queue_free()
		return
	if node is CollisionObject3D or node is CollisionShape3D or node is CollisionShape2D:
		node.queue_free()
		return

	if node.get_script() != null and not (node is MeshInstance3D or node is Skeleton3D or node is BoneAttachment3D):
		node.set_script(null)
	node.set_process(false)
	node.set_physics_process(false)

	for child: Node in node.get_children():
		_sanitize_character_model(child)


func _build_character_screen() -> void:
	var box: VBoxContainer = _create_screen("character")
	box.add_child(_make_title("Character", 22))

	_build_character_preview(box)

	var nav_row := HBoxContainer.new()
	nav_row.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_row.add_theme_constant_override("separation", 24)
	box.add_child(nav_row)

	var prev_button: Button = _make_button(nav_row, "<", 20, Vector2(44, 44), true)
	prev_button.pressed.connect(func() -> void: _step_character(-1))

	_character_name_label = _make_title("", 20)
	_character_name_label.custom_minimum_size = Vector2(200, 0)
	nav_row.add_child(_character_name_label)

	var next_button: Button = _make_button(nav_row, ">", 20, Vector2(44, 44), true)
	next_button.pressed.connect(func() -> void: _step_character(1))

	_character_desc_label = Label.new()
	_character_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_character_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_character_desc_label.custom_minimum_size = Vector2(360, 0)
	box.add_child(_character_desc_label)

	_character_abilities_label = Label.new()
	_character_abilities_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_character_abilities_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_character_abilities_label.add_theme_font_size_override("font_size", 13)
	_character_abilities_label.add_theme_color_override("font_color", ACCENT_COLOR)
	box.add_child(_character_abilities_label)

	var back_button: Button = _make_button(box, "Back")
	back_button.pressed.connect(func() -> void: _show_screen("root"))


func _step_character(delta: int) -> void:
	if _roster.is_empty():
		return
	_character_index = wrapi(_character_index + delta, 0, _roster.size())
	_refresh_character_screen()


func _refresh_character_screen() -> void:
	if _roster.is_empty():
		if _character_name_label != null:
			_character_name_label.text = "Kein Charakter gefunden"
		return

	var data: CharacterData = _roster[_character_index]
	_refresh_character_preview_model(data)
	_character_name_label.text = data.character_name
	_character_desc_label.text = data.description if data.description != "" else ""
	_character_abilities_label.text = "%s | %s | %s | %s | %s" % [
		data.name_primary, data.name_secondary, data.name_utility,
		data.name_ability_q, data.name_ability_e,
	]


# ============================================================================
# Stats-Screen
# ============================================================================
func _build_stats_screen() -> void:
	var box: VBoxContainer = _create_screen("stats")
	box.add_child(_make_title("Stats", 22))

	_stats_label = Label.new()
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_stats_label.add_theme_constant_override("line_spacing", 6)
	box.add_child(_stats_label)

	var back_button: Button = _make_button(box, "Back")
	back_button.pressed.connect(func() -> void: _show_screen("root"))


func _refresh_stats_screen() -> void:
	if _stats_label == null:
		return
	var discovered: int = GameStats.get_items_discovered_count()
	var total: int = GameStats.get_items_total_count()
	_stats_label.text = (
		"Bosses Killed: %d\n" +
		"Kills: %d\n" +
		"Deaths: %d\n" +
		"Items Discovered: %d / %d\n" +
		"Best Combo: %d\n" +
		"Winstreak: %d\n" +
		"Playtime: %s"
	) % [
		GameStats.bosses_killed, GameStats.kills, GameStats.deaths,
		discovered, total, GameStats.best_combo, GameStats.winstreak,
		GameStats.get_playtime_string(),
	]


# ============================================================================
# Settings — instanziert die bestehende settings_menu.tscn statt eine
# eigene Version zu bauen. Gleiches open()/close()/back_pressed-API wie in
# pause_menu.gd bereits verwendet.
# ============================================================================
func _on_settings_pressed() -> void:
	if _settings_instance == null:
		var scene: PackedScene = load("res://scenes/settings_menu.tscn")
		if scene == null:
			push_warning("MainMenu: settings_menu.tscn nicht gefunden.")
			return
		_settings_instance = scene.instantiate()
		add_child(_settings_instance)
		_settings_instance.back_pressed.connect(_on_settings_back)

	for key: String in _screens.keys():
		(_screens[key] as Control).visible = false
	_settings_instance.open()


func _on_settings_back() -> void:
	if _settings_instance != null:
		_settings_instance.close()
	_show_screen("root")
