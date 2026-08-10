# res://scripts/level/stage_theme.gd
extends Resource
class_name StageTheme

# ============================================================================
# StageTheme — das visuelle Thema EINER Etage.
# ============================================================================
# PHASE 3.2. Jede Etage bekommt eine eigene Farbwelt: Dungeon, Eiswelt,
# Wueste, ... Das Theme beschreibt NUR Optik und Atmosphaere, keine
# Spielregeln — Gegnerstaerke und Raumauswahl bleiben Sache des
# LevelGenerators.
#
# WARUM FARBEN STATT MATERIAL-SETS:
# Alle Raum-Szenen benutzen dasselbe psx_material.tres. Ein komplettes
# Material-Set pro Theme haette bedeutet, jede der jetzt 20 Raum-Szenen mit
# einem Theme-Schalter zu versehen. Ein Farbton, der beim Etagenwechsel auf
# die duplizierten Materialien gelegt wird, erreicht dieselbe Wirkung und
# laesst die Szenen unangetastet. Wer spaeter echte Texturen pro Theme will,
# haengt sie an floor_texture/wall_texture und liest sie in
# RoomInstance.apply_theme() aus.

@export var theme_name: String = "Dungeon"

## Grundton der Boeden.
@export var floor_color: Color = Color(0.62, 0.60, 0.55)
## Grundton der Waende.
@export var wall_color: Color = Color(0.48, 0.47, 0.44)
## Decke und Wandkappen (die Minimap-Deckel).
@export var ceiling_color: Color = Color(0.035, 0.04, 0.035)
## Tueren heben sich bewusst leicht ab, damit sie lesbar bleiben - ABER im
## selben Hue wie die Wand (siehe _door_shade()), nur heller/dunkler. Vorher
## stand hier pro Theme ein frei erfundener Farbton, der teils in eine ganz
## andere Farbfamilie kippte (z.B. Neon-Theme: lila Wand, aber magenta Tuer)
## und dadurch wie ein Stilbruch statt wie eine Lesbarkeits-Hilfe wirkte.
@export var door_color: Color = Color(0.70, 0.62, 0.45)

## Nebelfarbe/Umgebungslicht der Etage. Wird von stage_manager.gd auf die
## WorldEnvironment gelegt, falls eine vorhanden ist.
@export var fog_color: Color = Color(0.05, 0.05, 0.07)
@export var fog_density: float = 0.012
## BUGFIX "Character wirkt schwarz/im Schatten": siehe dungeon_atmosphere.gd
## - dieselbe Anhebung, damit sie nach einem Etagenwechsel (stage_manager.gd
## _apply_environment() ueberschreibt ambient_light_energy pro Etage mit
## diesem Wert) nicht wieder zurueckfaellt.
@export var ambient_energy: float = 0.55

## Farbe der Lava-/Limonaden-Hazards dieser Etage. Rein kosmetisch —
## der Schaden bleibt gleich.
@export var hazard_color: Color = Color(0.85, 0.95, 0.20)

## Optionale Texturen. Bleiben leer, solange alles ueber Farben laeuft.
@export var floor_texture: Texture2D
@export var wall_texture: Texture2D


## Ordnet einem Node-Namen den passenden Grundton zu.
##
## Die Namenskonvention der Raum-Szenen ist ueber alle 20 Szenen einheitlich
## (Floor, WallNorth_A, DoorEast, ...), deshalb reicht ein Praefix-Vergleich.
## Alles Unbekannte bekommt den Wandton — das ist der haeufigste Fall und
## faellt bei einem Sonderobjekt am wenigsten auf.
func tint_for_node_name(node_name: String) -> Color:
	var lower: String = node_name.to_lower()
	if lower.begins_with("floor") or lower.begins_with("platform") or lower.begins_with("ramp"):
		return floor_color
	if lower.begins_with("door"):
		return door_color
	if lower.begins_with("lava") or lower.begins_with("lemonade") or lower.begins_with("hazard"):
		return hazard_color
	return wall_color


## Leitet den Tuerton AUS dem Wandton ab: gleicher Hue/gleiche Saettigung,
## nur heller — statt eines frei erfundenen Tons pro Theme (der frueher teils
## in eine andere Farbfamilie kippte, siehe door_color-Kommentar). So bleibt
## die Tuer immer erkennbar heller als die Wand, ohne wie ein Stilbruch zu
## wirken.
static func _door_shade(wall: Color) -> Color:
	return Color.from_hsv(wall.h, wall.s * 0.85, clampf(wall.v * 1.4 + 0.12, 0.0, 1.0))


## Die eingebauten Themen. Bewusst im Code und nicht als .tres-Dateien —
## dieselbe Begruendung wie beim ItemCatalog: ein neues Theme ist ein
## Funktionsaufruf, und Balancing-Aenderungen bleiben im Git-Diff lesbar.
##
## Die Reihenfolge ist die Reihenfolge der Etagen. Ist die Liste
## durchgespielt, wird von vorn begonnen (siehe for_stage).
static func build_all() -> Array[StageTheme]:
	var themes: Array[StageTheme] = []

	var dungeon := StageTheme.new()
	dungeon.theme_name = "Kellergewoelbe"
	dungeon.floor_color = Color(0.58, 0.55, 0.50)
	dungeon.wall_color = Color(0.44, 0.43, 0.40)
	dungeon.ceiling_color = Color(0.035, 0.040, 0.035)
	dungeon.door_color = _door_shade(dungeon.wall_color)
	dungeon.fog_color = Color(0.05, 0.05, 0.06)
	dungeon.fog_density = 0.012
	dungeon.ambient_energy = 0.55
	dungeon.hazard_color = Color(0.88, 0.95, 0.22)
	themes.append(dungeon)

	var ice := StageTheme.new()
	ice.theme_name = "Tiefkuehlhaus"
	ice.floor_color = Color(0.72, 0.84, 0.95)
	ice.wall_color = Color(0.52, 0.68, 0.86)
	ice.ceiling_color = Color(0.06, 0.09, 0.14)
	ice.door_color = _door_shade(ice.wall_color)
	ice.fog_color = Color(0.10, 0.16, 0.24)
	ice.fog_density = 0.020
	ice.ambient_energy = 0.70
	ice.hazard_color = Color(0.55, 0.90, 1.0)
	themes.append(ice)

	var desert := StageTheme.new()
	desert.theme_name = "Sandgrube"
	desert.floor_color = Color(0.88, 0.76, 0.48)
	desert.wall_color = Color(0.70, 0.56, 0.34)
	desert.ceiling_color = Color(0.12, 0.09, 0.05)
	desert.door_color = _door_shade(desert.wall_color)
	desert.fog_color = Color(0.26, 0.20, 0.12)
	desert.fog_density = 0.008
	desert.ambient_energy = 0.85
	desert.hazard_color = Color(0.95, 0.65, 0.15)
	themes.append(desert)

	var flesh := StageTheme.new()
	flesh.theme_name = "Fleischfabrik"
	flesh.floor_color = Color(0.62, 0.30, 0.30)
	flesh.wall_color = Color(0.45, 0.20, 0.22)
	flesh.ceiling_color = Color(0.10, 0.03, 0.04)
	flesh.door_color = _door_shade(flesh.wall_color)
	flesh.fog_color = Color(0.16, 0.05, 0.06)
	flesh.fog_density = 0.018
	flesh.ambient_energy = 0.60
	flesh.hazard_color = Color(0.95, 0.25, 0.25)
	themes.append(flesh)

	var neon := StageTheme.new()
	neon.theme_name = "Neon-Keller"
	neon.floor_color = Color(0.30, 0.28, 0.45)
	neon.wall_color = Color(0.22, 0.20, 0.38)
	neon.ceiling_color = Color(0.04, 0.03, 0.09)
	neon.door_color = _door_shade(neon.wall_color)
	neon.fog_color = Color(0.10, 0.04, 0.18)
	neon.fog_density = 0.022
	neon.ambient_energy = 0.65
	neon.hazard_color = Color(0.40, 1.0, 0.85)
	themes.append(neon)

	return themes


## Theme fuer eine Etage. stage ist 1-basiert.
##
## Modulo statt Deckel: ein Run, der laenger laeuft als es Themen gibt, soll
## weiterlaufen und nicht ab Etage 6 dauerhaft im letzten Thema haengen.
static func for_stage(stage: int) -> StageTheme:
	var themes: Array[StageTheme] = build_all()
	if themes.is_empty():
		return StageTheme.new()
	var index: int = (maxi(stage, 1) - 1) % themes.size()
	return themes[index]
