extends DestructibleProp
class_name SecretWall

# ============================================================================
# SecretWall — Blueprint Nr. 4 "Geheimräume". Eine Wand mit hoher HP, die
# realistisch nur ein Explosions-Item (Kaputter Toaster, Chili-Oel, ...)
# innerhalb einer vernuenftigen Zeit durchbricht, nicht normaler Dauerbeschuss.
# Dahinter liegt eine kleine Nische mit einem zufaelligen Bonus-Item als
# Boden-Pickup (Pickup.create_item(), siehe pickup.gd - derselbe
# Konstruktionsweg wie ein normaler Item-Drop, kein eigener Sockel noetig).
# ============================================================================
# VEREINFACHUNG GEGENUEBER DEM URSPRUENGLICHEN BLUEPRINT-VORSCHLAG: statt
# einer dynamischen 15%-Chance im Level-Generator (neuer RoomType, Eingriff
# in room_grid_generator.gd UND das Tuer-/Fog-System, siehe Kommentar in
# 05_Gedanken/02_Game_Design_Blueprint.md) ist das hier eine FEST in ein
# Raum-Template eingebaute Nische - funktional dieselbe Spielerfahrung
# ("Wand aufsprengen, Bonusraum finden"), aber ohne die riskantesten,
# ausserhalb des Godot-Editors nicht gegenpruefbaren Aenderungen an
# gemeinsam genutzten Generator-Systemen.

## Weltraum-Position (nicht lokal!), an der das Bonus-Item nach dem
## Durchbruch erscheint.
@export var reward_global_position: Vector3 = Vector3.ZERO


func _destroy() -> void:
	var pos: Vector3 = reward_global_position
	super._destroy()
	_spawn_reward(pos)


func _spawn_reward(pos: Vector3) -> void:
	var items: Node = get_node_or_null("/root/Items")
	if items == null:
		return

	var pool: Array = []
	for entry in items.catalog:
		if not (entry is ItemData):
			continue
		var data: ItemData = entry as ItemData
		if data.max_stacks > 0 and items.count_item(data.id) >= data.max_stacks:
			continue
		pool.append(data)
	if pool.is_empty():
		return

	var chosen: ItemData = pool[randi() % pool.size()]
	var pickup: Pickup = Pickup.create_item(chosen)
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = pos
