extends Resource
class_name CharacterData

# Ersetzt die alte "AbilitySet"-Resource.
#
# WICHTIG: Enthält NUR noch Meta-/Anzeigedaten fuers HUD und die Party-
# Auswahl (Name, Portrait, Icons, Anzeigenamen, max_health) — KEINE
# Cooldown-Werte mehr! Cooldowns und die eigentliche Fähigkeits-Logik
# leben jetzt direkt im jeweiligen Combat-Script des Charakters
# (z.B. res://scripts/characters/combat_ningning.gd), da jeder Charakter
# eigene, unterschiedliche Fähigkeiten haben soll.
#
# Als .tres im Ordner /resources ablegen, z.B. res://resources/char_1.tres

@export var character_id: StringName = &""
@export var character_name: String = "Char"
@export var portrait: Texture2D = null

## Kurzbeschreibung fuer den Charakter-Screen im Hauptmenue (main_menu.gd).
## Leer ist ein gueltiger Default: bestehende .tres-Ressourcen ohne diesen
## Wert zeigen dort einfach keinen Beschreibungstext an.
@export_multiline var description: String = ""

# Die komplette Charakter-Szene (CharacterBody3D-Root), die PartyManager
# instanziert, sobald dieser Charakter aktiv wird.
# z.B. res://scenes/characters/char_ningning.tscn
@export var player_scene: PackedScene = null

@export_group("Icons")
@export var icon_primary: Texture2D = null
@export var icon_secondary: Texture2D = null
@export var icon_utility: Texture2D = null
@export var icon_ability_q: Texture2D = null
@export var icon_ability_e: Texture2D = null

@export_group("Stats")
@export var max_health: float = 100.0

@export_group("Display Names")
@export var name_primary: String = "Slash"
@export var name_secondary: String = "Heavy"
@export var name_utility: String = "Dash"
@export var name_ability_q: String = "Q-Ability"
@export var name_ability_e: String = "E-Ability"
