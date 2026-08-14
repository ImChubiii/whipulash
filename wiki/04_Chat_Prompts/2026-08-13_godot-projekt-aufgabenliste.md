---
title: "Godot-Projekt-Aufgabenliste"
date: 2026-08-13
tags: [chatlog, prompt-log, whiplash, lemonade, thema/meta, thema/feature, ki/antigravity]
ki_art: "antigravity"
---
# Godot-Projekt-Aufgabenliste

[Antigravity Session](file:///C:/Users/thvnh/.gemini/antigravity/brain/313b05b8-57cd-4243-9734-cd0eac8e36f6/.system_generated/logs/transcript_full.jsonl)

## User

Du arbeitest im Godot-Projekt unter c:\Users\thvnh\Documents\GitHub\whiplash.

Bitte mache folgende 3 Änderungen:

## Änderung 1: debug_teleporter.gd deaktivieren (alle Pads entfernen)

Ersetze c:\Users\thvnh\Documents\GitHub\whiplash\scripts\debug_teleporter.gd komplett:
- Der Autoload bleibt registriert (kein project.godot anfassen)
- Aber `_ready()` soll sofort returnen ohne Pads zu spawnen
- Alle Pad-Logik entfernen
- Das Script bleibt ein valides GDScript-Node aber tut nichts

Neuer Inhalt für debug_teleporter.gd:
```gdscript
extends Node

# ============================================================================
# DebugTeleporter — deaktiviert.
# ============================================================================
# Die physischen Teleporter-Pads wurden entfernt. Teleportation ist jetzt
# ausschliesslich ueber das ADMIN-Panel im Pause-Menue verfuegbar
# (scripts/pause_menu.gd, Methode _build_admin_panel()).
# Dieses Script bleibt als Autoload registriert, tut aber nichts mehr.

func _ready() -> void:
	pass
```

## Änderung 2: ADMIN-Panel in pause_menu.gd

In c:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd:

Füge am ENDE von `_ready()` (nach `_build_item_list()`) hinzu:
```
	_build_admin_panel()
```

Füge dann NACH der `_first_button_index()` Funktion (also ans Ende des Files) die neue Methode `_build_admin_panel()` hinzu:

```gdscript
# ============================================================================
# ADMIN-Panel — Teleportation zu Debug-Räumen (ersetzt die physischen Pads)
# ============================================================================
func _build_admin_panel() -> void:
	var column: VBoxContainer = get_node_or_null("Panel/VBoxContainer")
	if column == null:
		return

	# Trennlinie
	var sep := HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 8)
	column.add_child(sep)

	# Überschrift
	var title := Label.new()
	title.text = "— ADMIN —"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 13)
	title.modulate = Color(0.6, 0.85, 1.0, 0.8)
	column.add_child(title)

	var row1 := HBoxContainer.new()
	row1.alignment = BoxContainer.ALIGNMENT_CENTER
	row1.add_theme_constant_override("separation", 6)
	column.add_child(row1)

	# Zurück zum Start
	var back_btn := _make_admin_btn("← Start")
	back_btn.pressed.connect(_admin_teleport_to_start)
	row1.add_child(back_btn)

	# Tresorraum
	var treasure_btn := _make_admin_btn("Tresor")
	treasure_btn.pressed.connect(func() -> void: _admin_teleport_to_room_type(RoomData.RoomType.TREASURE))
	row1.add_child(treasure_btn)

	# Bossraum
	var boss_btn := _make_admin_btn("Boss")
	boss_btn.pressed.connect(func() -> void: _admin_teleport_to_room_type(RoomData.RoomType.BOSS))
	row1.add_child(boss_btn)

	var row2 := HBoxContainer.new()
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	row2.add_theme_constant_override("separation", 6)
	column.add_child(row2)

	# Item-Testraum
	var item_btn := _make_admin_btn("Items")
	item_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: ItemTestRoom.teleport_player_in()))
	row2.add_child(item_btn)

	# Sandbox
	var sandbox_btn := _make_admin_btn("Sandbox")
	sandbox_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: EnemySandboxRoom.teleport_player_in()))
	row2.add_child(sandbox_btn)

	# Hub
	var hub_btn := _make_admin_btn("Hub")
	hub_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: HubRoom.teleport_player_in()))
	row2.add_child(hub_btn)

	# VFX-Test
	var vfx_btn := _make_admin_btn("VFX")
	vfx_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: VfxTestRoom.teleport_player_in()))
	row2.add_child(vfx_btn)


func _make_admin_btn(label: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(60, 28)
	btn.add_theme_font_size_override("font_size", 12)
	return btn


## Teleportiert den Spieler zum Startraum zurück (erster START-Raum im Layout).
func _admin_teleport_to_start() -> void:
	_admin_teleport_to_room_type(RoomData.RoomType.START)


## Sucht den ersten Raum des gegebenen Typs im aktuellen Layout und
## teleportiert den aktiven Spieler dorthin. Schliesst danach das Pause-Menue.
func _admin_teleport_to_room_type(room_type: int) -> void:
	var gen: LevelGenerator = _find_level_generator()
	if gen == null:
		return
	var target_room: RoomInstance = null
	for grid_pos in gen._instances.keys():
		var room: RoomInstance = gen._instances[grid_pos]
		if room == null or not is_instance_valid(room):
			continue
		var cell = gen._current_layout.get(grid_pos)
		if cell != null and int(cell.get("room_type", -1)) == room_type:
			target_room = room
			break
	if target_room == null:
		push_warning("ADMIN: Kein Raum vom Typ %d gefunden." % room_type)
		return
	_admin_move_player_to_room(target_room)


## Ruft einen Pocket-Dimension-Teleport-Callable auf und schliesst das Pause-Menue.
func _admin_pocket(tp: Callable) -> void:
	_resume()
	await get_tree().process_frame
	tp.call()


func _admin_move_player_to_room(room: RoomInstance) -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return
	player.global_position = room.global_position + Vector3(0, 2.0, 0)
	player.velocity = Vector3.ZERO
	_resume()


func _find_level_generator() -> LevelGenerator:
	var nodes: Array[Node] = get_tree().get_nodes_in_group("level_generator")
	if nodes.is_empty():
		return null
	return nodes[0] as LevelGenerator


func _find_player() -> CharacterBody3D:
	if PartyManager.has_player():
		return PartyManager.player
	return null
```

## Änderung 3: main_menu.gd — _show_screen("character") startet beim aktuell gespielten Charakter

In c:\Users\thvnh\Documents\GitHub\whiplash\scripts\main_menu.gd:

Ändere die Methode `_show_screen()` so, dass wenn der Screen "character" gezeigt wird UND `GameStats.has_live_run == true`, der `_character_index` auf den aktuell aktiven PartyManager-Index gesetzt wird.

Die aktuelle `_show_screen()` sieht so aus (Zeilen 560-571):
```gdscript
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
```

Ersetze es durch:
```gdscript
func _show_screen(id: String) -> void:
	_current_screen_id = id
	for key: String in _screens.keys():
		(_screens[key] as Control).visible = (key == id)
	if id == "stats":
		_refresh_stats_screen()
	elif id == "character":
		# Wenn gerade ein Run läuft (Pause-Overlay-Kontext), direkt zum
		# aktiven Spieler springen statt immer bei Index 0 zu starten.
		if GameStats.has_live_run and not _roster.is_empty():
			var active_idx: int = PartyManager.get_active_index()
			if active_idx >= 0 and active_idx < _roster.size():
				_character_index = active_idx
		_refresh_character_screen()
	elif id == "root":
		_refresh_continue_button()
		if _root_first_button != null and is_instance_valid(_root_first_button):
			_root_first_button.grab_focus()
```

Bitte führe alle 3 Änderungen aus und berichte wenn fertig.

## Assistant

Ich lese zuerst die relevanten Dateien, um die exakten Zeilen zu finden.

## Assistant

Alle Dateien gelesen. Jetzt führe ich alle 3 Änderungen gleichzeitig aus.

## Assistant

Alle 3 Änderungen erfolgreich durchgeführt:

---

**Änderung 1 — [`debug_teleporter.gd`](file:///c:/Users/thvnh/Documents/GitHub/whiplash/scripts/debug_teleporter.gd)**  
Komplett ersetzt. Autoload bleibt registriert, `_ready()` macht nur noch `pass`. Keine Pad-Logik mehr.

**Änderung 2 — [`pause_menu.gd`](file:///c:/Users/thvnh/Documents/GitHub/whiplash/scripts/pause_menu.gd)**  
- `_build_admin_panel()` wird am Ende von `_ready()` aufgerufen  
- ADMIN-Sektion ans Dateiende angehängt: Trennlinie, Überschrift, 2 Zeilen mit 7 Buttons (← Start, Tresor, Boss, Items, Sandbox, Hub, VFX)  
- Hilfsfunktionen `_make_admin_btn()`, `_admin_teleport_to_start/room_type()`, `_admin_pocket()`, `_admin_move_player_to_room()`, `_find_level_generator()`, `_find_player()` vollständig eingefügt

**Änderung 3 — [`main_menu.gd`](file:///c:/Users/thvnh/Documents/GitHub/whiplash/scripts/main_menu.gd)**  
`_show_screen("character")` springt jetzt bei `GameStats.has_live_run == true` direkt zum aktiven `PartyManager`-Index statt immer bei 0 zu starten.
