extends Node

# ============================================================================
# SaveGameManager (Autoload "SaveGame") — Blueprint "Meta-Progression: Was
# passiert nach dem Tod?".
# ============================================================================
# Persistente Meta-Waehrung "Drops", die einen Tod UEBERLEBT - im Gegensatz
# zu Items.coins, das mit jedem Run zurueckgesetzt wird. Gleicher Aufbau wie
# settings_manager.gd: ein ConfigFile unter user://, eine Sektion, load()/
# save() um jede Aenderung.
#
# ANBINDUNG AN DEN RUN: hoert direkt auf PartyManager.party_wiped, statt dass
# death_screen.gd/party_manager.gd etwas ueber Meta-Progression wissen
# muessten - additiv, keine bestehende Death-Flow-Logik wird angefasst.
#
# HUB/SHOP: scripts/hub_room.gd (Autoload "HubRoom", siehe project.godot -
# keine eigene .tscn, kein separates drops_shop.gd, der Shop lebt direkt
# darin) liest/schreibt ausschliesslich ueber die oeffentliche API hier
# (get_item_weight_bonus() etc.), NIE direkt am ConfigFile.

signal drops_changed(amount: int)
signal item_weight_bonus_changed(bonus: float)

const SAVE_PATH: String = "user://meta_save.cfg"
const SECTION: String = "meta"

## Pro Hub-Upgrade-Stufe: +5% Drop-Gewicht auf ALLE Items im Schatzraum-Pool
## (TreasureManager._weighted_pick(), additiv zum Synergie-Bonus aus
## Blueprint Nr. 6), gedeckelt bei insgesamt 40% - siehe Design-Dokument.
const WEIGHT_PER_UPGRADE_LEVEL: float = 0.05
const MAX_ITEM_WEIGHT_BONUS: float = 0.4
const MAX_UPGRADE_LEVEL: int = 8  # 8 * 0.05 = 0.4

const UPGRADE_BASE_COST: int = 20
const UPGRADE_COST_STEP: int = 15

## Basis-Drops pro Tod, plus ein Bonus pro erreichter Etage - ein Run, der
## weiter kommt, soll spuerbar mehr Meta-Fortschritt bringen als ein Run,
## der in Etage 1 endet.
const BASE_DEATH_DROPS: int = 10
const DROPS_PER_STAGE: int = 5

var drops: int = 0
var item_weight_upgrade_level: int = 0


func _ready() -> void:
	load_save()
	if not PartyManager.party_wiped.is_connected(_on_party_wiped):
		PartyManager.party_wiped.connect(_on_party_wiped)


func _on_party_wiped() -> void:
	var stage: int = 1
	if Stages != null and Stages.has_method("get_current_stage"):
		stage = maxi(Stages.get_current_stage(), 1)
	add_drops(BASE_DEATH_DROPS + DROPS_PER_STAGE * (stage - 1))


# ============================================================================
# Persistenz
# ============================================================================
func load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	drops = int(cfg.get_value(SECTION, "drops", 0))
	item_weight_upgrade_level = clampi(
		int(cfg.get_value(SECTION, "item_weight_upgrade_level", 0)), 0, MAX_UPGRADE_LEVEL
	)


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SECTION, "drops", drops)
	cfg.set_value(SECTION, "item_weight_upgrade_level", item_weight_upgrade_level)
	cfg.save(SAVE_PATH)


# ============================================================================
# Drops
# ============================================================================
func add_drops(amount: int) -> void:
	if amount <= 0:
		return
	drops += amount
	drops_changed.emit(drops)
	save()


# ============================================================================
# Hub-Upgrade: Item-Drop-Gewicht
# ============================================================================
func get_upgrade_cost() -> int:
	return UPGRADE_BASE_COST + UPGRADE_COST_STEP * item_weight_upgrade_level


func is_upgrade_maxed() -> bool:
	return item_weight_upgrade_level >= MAX_UPGRADE_LEVEL


func can_afford_upgrade() -> bool:
	return not is_upgrade_maxed() and drops >= get_upgrade_cost()


func buy_item_weight_upgrade() -> bool:
	if not can_afford_upgrade():
		return false
	drops -= get_upgrade_cost()
	item_weight_upgrade_level += 1
	drops_changed.emit(drops)
	item_weight_bonus_changed.emit(get_item_weight_bonus())
	save()
	return true


## Gelesen von TreasureManager._weighted_pick() - additiv auf das
## Grundgewicht 1.0 jedes Pool-Kandidaten, gedeckelt bei 40%.
func get_item_weight_bonus() -> float:
	return minf(item_weight_upgrade_level * WEIGHT_PER_UPGRADE_LEVEL, MAX_ITEM_WEIGHT_BONUS)
