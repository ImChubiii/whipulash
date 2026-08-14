class_name TutorialContent

# ============================================================================
# TutorialContent — reine Daten/Fabrik-Sammlung fuer den generator-basierten
# Tutorial-Modus (level_generator.gd::generate_tutorial_stage()).
# ============================================================================
# Kein Node, keine Instanz - nur statische Konstanten/Funktionen. Legt die
# Raumfolge, die exakten Gegnerlisten und die Charakter-Unlocks fest.
#
# Eine EINZIGE durchgehende Kette (kein Spine/Spur-Unterschied mehr) - jede
# Zelle ist nur ueber die vorherige/naechste erreichbar, Tresorraeume liegen
# INLINE mit Eingang+Ausgang statt als Sackgasse. Index 0..8:
#   0 Fight1, 1 Treasure(Giselle), 2 Fight2, 3 Treasure(Karina), 4 Fight3,
#   5 Treasure(Winter), 6 Fight4, 7 Treasure(Item), 8 FinalFight/Boss.

const DUMMY_SCENE: PackedScene = preload("res://scenes/enemies/dummy.tscn")
const SCOUT_DUMMY_SCENE: PackedScene = preload("res://scenes/scout_dummy.tscn")

const NINGNING_DATA: CharacterData = preload("res://resources/char_1.tres")
const GISELLE_DATA: CharacterData = preload("res://resources/char_2.tres")
const KARINA_DATA: CharacterData = preload("res://resources/char_3.tres")
const WINTER_DATA: CharacterData = preload("res://resources/char_4.tres")

## Rueckmeldung "Tutorial-Texte sollen Tasten-Inputs erwaehnen und die
## Dash-Mechanik erklaeren" (2026-08-13), dann per Rueckmeldung "eigener
## Container pro Charakter/Faehigkeit, nicht alles in einem Textblock"
## nachgeschaerft: jede Faehigkeit (Dash, Bomben, LMB, RMB) ist jetzt eine
## EIGENE Zeile/Array-Eintrag statt eines einzigen Fliesstext-Blocks - siehe
## scripts/ui/tutorial_character_intro.gd, das pro Zeile einen eigenen Label
## baut. Q/E bleiben bewusst unerwaehnt, die sind laut CLAUDE.md keine
## Charakter-Faehigkeiten, sondern die beiden aktiven Item-Slots.
##
## DASH und BOMBEN sind keine Charakter-, sondern allgemeine,
## charakterunabhaengige Mechaniken (siehe combat_base.gd bzw.
## bomb_carrier.gd) - deshalb ein eigener, FIXIERTER Eintrag statt Teil
## irgendeiner Charakterbeschreibung, siehe level_generator.gd::
## _setup_tutorial_ui() und tutorial_character_intro.gd::set_general_entry().
const GENERAL_TITLE: String = "Allgemeine Mechaniken"
const GENERAL_DESCRIPTION: Array[String] = [
	"Dash: DRÜCKE Shift, um einen schnellen Dash auszuführen, Hindernisse zu überwinden, Angriffen sicher auszuweichen und getroffenen Gegnern Schaden zuzufügen.",
	"Bomben: DRÜCKE LMB, um eine Bombe zu werfen und ganze Gegnergruppen mit massivem Flächenschaden zu vernichten.",
]

const NINGNING_DESCRIPTION: Array[String] = [
	"DRÜCKE LMB, um extrem schnelle Nahkampfschläge auszuführen und den Gegner dadurch im Stunlock zu halten.",
	"DRÜCKE RMB, um zu einem wuchtigen Haymaker auszuholen und massiven Schaden zu verursachen, der deine Feinde zurückwirft.",
]
const GISELLE_DESCRIPTION: Array[String] = [
	"HALTE LMB, um deine Waffen im Dauerfeuer abzufeuern und deinen Gegnern auf Distanz konstanten Schaden zuzufügen.",
	"HALTE RMB und LASSE LOS, um die Kamera heranzuzoomen und einen präzisen 3-Schuss-Burst abzufeuern, der einzelne Ziele mit extremem Burst-Schaden vernichtet.",
]
const KARINA_DESCRIPTION: Array[String] = [
	"HALTE LMB, um die Acid-Aura zu aktivieren und dein Tempo zu erhöhen, wodurch alle Gegner in deiner Nähe über Zeit vergiftet werden.",
	"DRÜCKE RMB, um Tarnung sowie Unverwundbarkeit zu aktivieren und berührte Gegner zu markieren, um sie bei Deaktivierung der Fähigkeit vernichtend in die Luft zu sprengen.",
]
const WINTER_DESCRIPTION: Array[String] = [
	"DRÜCKE LMB, um zielsuchende Plasmabolzen abzufeuern, die Schaden verursachen und getroffene Gegner in Richtung des Einschlags ziehen.",
	"HALTE RMB, um einen kontinuierlichen Hitscan-Laserstrahl abzufeuern und alle Gegner in der Schusslinie zu schmelzen, solange deine Energiezelle reicht.",
]

## Raumtyp je Kettenzelle, 1:1 an RoomGridGenerator.generate_fixed_layout()
## durchgereicht.
static func room_types() -> Array[int]:
	return [
		RoomData.RoomType.COMBAT,    # 0: Fight1
		RoomData.RoomType.TREASURE,  # 1: Giselle
		RoomData.RoomType.COMBAT,    # 2: Fight2
		RoomData.RoomType.TREASURE,  # 3: Karina
		RoomData.RoomType.COMBAT,    # 4: Fight3
		RoomData.RoomType.TREASURE,  # 5: Winter
		RoomData.RoomType.COMBAT,    # 6: Fight4
		RoomData.RoomType.TREASURE,  # 7: Item
		RoomData.RoomType.BOSS,      # 8: Final Fight
	]


## Richtung von Zelle i-1 zu Zelle i (Index 0 = vom Startraum zur ersten
## Zelle). Bewusst ein einfaches, garantiert ueberschneidungsfreies
## Zickzack (nur EAST/NORTH, also monoton in beiden Achsen) statt einer
## geraden Linie - erfuellt "nicht nur in einer geraden Linie generiert"
## ohne jedes Kollisions-Risiko.
static func directions() -> Array[String]:
	return [
		RoomGridGenerator.EAST,
		RoomGridGenerator.EAST,
		RoomGridGenerator.NORTH,
		RoomGridGenerator.EAST,
		RoomGridGenerator.EAST,
		RoomGridGenerator.NORTH,
		RoomGridGenerator.EAST,
		RoomGridGenerator.EAST,
		RoomGridGenerator.EAST,
	]


## Exakte Gegnerliste je Kettenindex, als Callables fuer
## RoomInstance.prepare_fixed_enemies(). Leeres Array (Tresorzellen) = keine
## Ueberschreibung, wird von generate_tutorial_stage() uebersprungen.
##
## Rueckmeldung "Tutorial-Raeume etwas schwerer machen, aber KEINE neuen
## Gegnertypen/-arten - einfach die Anzahl der jeweiligen verdoppeln"
## (2026-08-13): jeder Gegnertyp kommt jetzt doppelt so oft vor wie vorher,
## die Zusammensetzung (welche Typen pro Raum) bleibt unveraendert.
static func fixed_enemies_for(index: int) -> Array[Callable]:
	match index:
		0: # Fight1: nur Fighter und Scouts
			return [
				_fighter_factory(), _fighter_factory(),
				_scout_factory(), _scout_factory(), _scout_factory(), _scout_factory(),
			]
		2: # Fight2: Moerser, Saeure-Sprinkler, Diver
			return [
				_mortar_factory(), _mortar_factory(),
				_acid_sprinkler_factory(), _acid_sprinkler_factory(),
				_dive_bomber_factory(), _dive_bomber_factory(),
			]
		4: # Fight3: Scouts und Shield
			return [
				_scout_factory(), _scout_factory(), _scout_factory(), _scout_factory(),
				_shield_drone_factory(), _shield_drone_factory(),
			]
		6: # Fight4: Plasma Shooter und 2 Fighter (verdoppelt: 4 Fighter)
			return [
				_plasma_beam_bot_factory(), _plasma_beam_bot_factory(),
				_fighter_factory(), _fighter_factory(), _fighter_factory(), _fighter_factory(),
			]
		8: # Final Fight: Mix aus allen zuvor gezeigten Gegnern
			return [
				_fighter_factory(), _fighter_factory(),
				_scout_factory(), _scout_factory(),
				_shield_drone_factory(), _shield_drone_factory(),
				_plasma_beam_bot_factory(), _plasma_beam_bot_factory(),
			]
		_:
			var empty: Array[Callable] = []
			return empty


## CharacterData je Kettenindex, oder null (Kampfraeume + Raum 7/Item-Tresor
## - dort faehrt treasure_manager.gd mit der normalen Item-Auswahl fort).
static func character_unlock_for(index: int) -> CharacterData:
	match index:
		1:
			return GISELLE_DATA
		3:
			return KARINA_DATA
		5:
			return WINTER_DATA
		_:
			return null


## UI-Beschreibungszeilen fuer einen soeben freigeschalteten Charakter -
## anhand character_id statt Objekt-Identitaet, robust gegen dupliziert
## geladene Ressourcen. Array statt einem String: jede Zeile wird als
## eigener Label dargestellt, siehe tutorial_character_intro.gd::show_character().
static func description_for(data: CharacterData) -> Array[String]:
	if data == null:
		return []
	match String(data.character_id):
		"ningning":
			return NINGNING_DESCRIPTION
		"giselle":
			return GISELLE_DESCRIPTION
		"karina":
			return KARINA_DESCRIPTION
		"winter":
			return WINTER_DESCRIPTION
		_:
			return [data.description]


static func _fighter_factory() -> Callable:
	return func() -> Node3D: return DUMMY_SCENE.instantiate()


static func _scout_factory() -> Callable:
	return func() -> Node3D: return SCOUT_DUMMY_SCENE.instantiate()


static func _mortar_factory() -> Callable:
	return func() -> Node3D: return MortarBot.new()


static func _acid_sprinkler_factory() -> Callable:
	return func() -> Node3D: return AcidSprinkler.new()


static func _dive_bomber_factory() -> Callable:
	return func() -> Node3D: return DiveBomber.new()


static func _shield_drone_factory() -> Callable:
	return func() -> Node3D: return ShieldDrone.new()


static func _plasma_beam_bot_factory() -> Callable:
	return func() -> Node3D: return PlasmaBeamBot.new()
