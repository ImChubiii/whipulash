---
commit: "f88829fa57d40c6a3bceea2f4c0da86bf35d9480"
short_hash: "f88829f"
date: 2026-07-27
author: "ImChubiii"
subject: "feat: Treasure room items, HUD overhaul, balancing, multiple bug fixes"
tags: [devlog]
---

# 2026-07-27 — feat: Treasure room items, HUD overhaul, balancing, multiple bug fixes

Here is the full English translation of your commit message/dev log, keeping the technical Godot terminology, GDScript naming, and structure intact:

Closes the gap between the fully completed item system (catalog, effects, stat integration) and actual gameplay: Pickup.create_item() was never called anywhere in the project, meaning there were eight functional items that could never spawn during a run. Additionally includes a comprehensive HUD refactor (moving away from a separate Autoload overlay into the standard HUD scene), two balancing adjustments (bombs, base damage), and a series of independent bug fixes identified while testing these changes.

This commit is intentionally kept large to wrap up an entire work session; if needed, split it into individual commits based on the sections below when merging.

Treasure Room Pedestal (treasure_manager.gd NEW, treasure_pedestal.gd NEW)
Autoload "Treasure": Hooks into every room via SceneTree.node_added (similar to loot), identifies treasure rooms via group/scene path/LevelGenerator grid cell (in that order), and places EXACTLY ONE item pedestal in the center of the room.

Item selection is deterministic based on the run seed + grid position, with no duplicate items within a single run until the pool is exhausted.

TreasurePedestal builds itself completely in code (pillar, light column, floor ring, floating item, point light) — no .tscn file, following the same pattern as Pickup and Bomb.

Bugfix during development: The ground raycast for the pedestal position originally started above the ceiling built by room_instance.gd and hit the ceiling first — causing the pedestal to land on the roof. The start point is now set to half the room height, and ceilings/door lintels are additionally excluded via RID.

Bugfix: The pedestal was attached several physics frames after the room's single Fog-of-War pass, leaving it permanently visible on the 3D minimap even in unvisited rooms (appearing as a floating point of light in the empty fog). The pedestal now synchronizes its visibility layer with its parent room's layer on every map_updated signal.

Bombs (bomb.gd, bomb_carrier.gd)
Explosion radius: Increased from 4.5 to 9.0 (2x2 to 4x4 tiles). Self-damage remains restricted to a smaller radius (55% of the total radius), otherwise the player gets caught in their own explosion after every throw.

Throw distance: The actual cause of short throws was linear_damp, not the throw force — the bomb lost momentum while still airborne. Bomb.launch() now reduces damping during the flight phase and only restores it upon actual ground contact (detected via raycast, not vertical velocity). Increased throw_force from 14 to 26 and throw_arc from 5 to 9.

Explosion VFX: Now split across three layers (core, fireball, ground shockwave) instead of a single sphere — the shockwave serves as the only visual indicator of how far the expanded explosion actually reaches.

Added an aiming trajectory preview while holding a bomb (analytical throw parabola rendered as a point series).

HUD Refactor (hud.tscn, hud_extra.gd, stats_panel.gd, item_description_hud.gd, item_summary_list.gd NEW, settings_manager.gd)
The Stats Panel and Item Bar are now native nodes in hud.tscn (BottomLeft/StatsPanel, BottomLeft/ItemBar) instead of a separate CanvasLayer constructed at runtime by hud_extra.gd. hud_extra.gd now only builds the reset overlay, which still requires its own layer to cover everything. Side effect: Scenes without hud.tscn (pure test levels) will no longer display the Stats Panel or Item Bar.

Stats Panel: Colored bars per stat instead of plain numbers, flash effect on stat changes, and coins/bombs displayed as labeled rows (the previous chip layout with Unicode symbols rendered as missing-character placeholder boxes in many fonts). Removed the standalone HP bar since it duplicated the main display.

Item Bar: Chip grid with color coding per item (matching the pedestal color in treasure rooms) plus a dedicated slot with charge points for the active item.

Item Detail Card: No longer a fixed 6-second display; it is now distance-bound. Appears centered in the open viewport area as soon as the player stands near a pedestal and disappears INSTANTLY when walking away. After picking up the item, it fades out normally after 5 seconds.

New HUD elements ("Stats Panel" and "Item Display") can now be toggled individually in the Settings menu (SettingsManager.HUD_ELEMENT_STATS / _ITEMS).

item_summary_list.gd (NEW): Reusable item overview with a hover tooltip description, shared across the Pause, Game Over, and Victory screens instead of using three separate implementations. Previously, death_screen.gd displayed hardcoded placeholder text ("No items collected") regardless of actual inventory, while the Pause and Victory screens had no item display at all.

Bugfix: The hover description card was originally a standard child inside the list's VBoxContainer, causing everything below it to shift when it appeared (a popup that triggers layout reflow isn't a proper popup). It is now attached to the screen root (a simple Control, not a container), positioned manually next to the hovered row, and clamped to the screen edges.

Minimap (minimap_rooms.gd)
Every doorway between two cells was being drawn from the perspective of BOTH adjacent rooms, effectively filling it twice. For open doors between two visited rooms, this resulted in nearly full opacity, making doorways appear brighter than the rooms themselves (the "flicker" upon entering was caused by swapping between single and double fill). Fixed using a sorted cell-pair key to ensure each doorway is drawn exactly once. Lowered the base color opacity as well.

Spoiler Protection: Doors leading to an UNVISITED neighboring room are now always drawn in the neutral default color and width, regardless of the actual room type (Treasure/Boss). Previously, the door's map color (golden yellow/red, sometimes pulsing) gave away Treasure and Boss rooms before they were entered.

Enemy AI (enemy_ai.gd)
Bugfix "Fighter misses attacks": In the ATTACK state, the state machine sets velocity to 0, but separation forces from other enemies were immediately applied unconditionally right after. At the moment of attacking, all enemies are clustered tightly together AND close to the player — meaning separation pushes away from the player. Over the pre_attack_delay + attack_windup_time window (1.8s), this pushed the enemy back so far that the AttackHitbox was swinging into thin air. Separation is now heavily dampened during an active attack (attack_separation_factor, default 0.12); the bump-away force from _handle_standing_on_player() is completely disabled during attacks.

Item Effects (lemonade.gd)
Acid-resistant boots were ineffective: the item correctly set a hazard_resist multiplier of 0.25 in PlayerStats, but the Lava/Lemonade hazard script never read this stat — meaning it was defined and displayed, but had no effect. Tick damage and wade slowdown now account for the multiplier; below a specific threshold (wade_slow_immunity_threshold), the slowdown is removed entirely as intended by design.

Room Exploit (room_commit_guard.gd NEW)
The EntryTrigger that initiates combat is indented from every wall by entry_trigger_depth (an intentional anti-baiting design). In a 48x48 room, this left a 9m-wide strip along the walls where no trigger existed. Result: players could enter a door, hug the wall, and exit through another door without spawning any enemies.

Autoload "RoomGuard": Attaches an Area covering the FULL floor plan to every room, triggering combat if the player remains inside uninterrupted for commit_dwell_time (default 1.1s). Briefly peeking inside has no effect, but wall-hugging is no longer faster than walking straight through the middle of the room.

R Key / Restart Closing the Game (pause_menu.gd, reset_overlay.gd)
Root Cause: Two independent, competing systems were listening to the same action. pause_menu.gd triggered reload_current_scene() IMMEDIATELY on keypress via _unhandled_input; in parallel, reset_overlay.gd polled the same key using Input.is_action_pressed() (unaffected by set_input_as_handled()) to build the intended 1.5-second hold confirmation. Pressing R caused pause_menu.gd to reload instantly without confirmation, and holding it longer caused reset_overlay.gd to fire a SECOND reload on a scene that was already freed — causing both the silent window crash and the runtime error "Cannot call method 'set_input_as_handled' on a null value".

reset_overlay.gd is now the sole owner of the reset action. PauseMenu.is_reset_blocked() (a new public method wrapping the previous private locks for Death/Victory transitions) is queried via a new "pause_menu" group. This preserves input locking during Death/Victory transitions without duplicating code across two places.

Balancing
Primary damage increased from 9 -> 14. Secondary damage (previously using the script default of 10.0 without an explicit value) increased -> 30 across all four character scenes and player.tscn.

Known Open Issues (Not Part of This Commit)
Visible effect/VFX feedback is still missing for several passive items (Wooden Spoon, Hatchet, Sock, Hellfire Horns) — the underlying game logic functions correctly (see item_behaviours.gd), but there is no custom visual feedback beyond the generic hit-stop. Planned as a separate task block.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Items:** [[wooden_spoon]]

**Gegner:** [[fighter]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `f88829f` |
| Autor | ImChubiii |
| Datum | 2026-07-27 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-27_f88829f_feat_treasure_room_items_hud_overhaul_balancing_mu]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
