extends Resource
class_name AbilitySet

# Definiert das komplette Loadout EINES Charakters.
# Als .tres im Ordner /resources ablegen, z.B. res://resources/char_1.tres

@export var character_name: String = "Lemon"
@export var portrait: Texture2D = null

@export_group("Icons")
@export var icon_primary: Texture2D = null
@export var icon_secondary: Texture2D = null
@export var icon_utility: Texture2D = null
@export var icon_ability_q: Texture2D = null
@export var icon_ability_e: Texture2D = null

@export_group("Cooldowns")
@export var primary_cooldown: float = 0.4
@export var secondary_cooldown: float = 5
@export var utility_cooldown: float = 5
@export var ability_q_cooldown: float = 6.0
@export var ability_e_cooldown: float = 10.0

@export_group("Stats")
@export var max_health: float = 100.0

@export_group("Display Names")
@export var name_primary: String = "Slash"
@export var name_secondary: String = "Heavy"
@export var name_utility: String = "Dash"
@export var name_ability_q: String = "Q-Ability"
@export var name_ability_e: String = "E-Ability"
