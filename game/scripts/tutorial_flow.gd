extends Node

# ============================================================================
# TutorialFlow — Autoload: minimaler Zustand fuer den generator-basierten
# Tutorial-Modus.
# ============================================================================
# main_menu.gd und debug_teleporter.gd setzen "pending" auf true und laden
# DANACH dieselbe Gameplay-Szene wie ein normaler Run
# (level_generator.gd::GAMEPLAY_SCENE_PATH). LevelGenerator._ready() liest
# das Flag beim Autostart EINMALIG aus und setzt es sofort zurueck - dadurch
# ueberlebt kein Tutorial-Zustand versehentlich einen RunRestart oder einen
# spaeteren Etagenwechsel.

## Von main_menu.gd/debug_teleporter.gd VOR change_scene_to_file() gesetzt.
## Von level_generator.gd._ready() konsumiert und sofort zurueckgesetzt.
var pending: bool = false

## Wird von level_generator.gd gesetzt, wenn pending konsumiert wurde.
## win_screen.gd liest dieses Flag, um GameStats.complete_tutorial()
## aufzurufen. Wird in show_win() zurueckgesetzt.
var was_active: bool = false

## Index des naechsten freizuschaltenden Charakters (0-basiert auf
## CHARACTER_RESOURCE_PATHS in main_menu.gd). Wird von
## level_generator.gd._on_tutorial_character_unlocked() gesetzt, sobald
## ein Charakter per CharacterPedestal freigeschaltet wird.
## level_generator.gd::generate_tutorial_stage() liest diesen Wert beim
## Start und beginnt die Party mit dem richtigen Charakter.
## -1 = noch kein Charakter freigeschaltet (Start: Ningning, Index 0).
var next_character_index: int = -1
