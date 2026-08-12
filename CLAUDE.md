# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**Whiplash** (in-game title "Lemonade") is a 3D action roguelite built in **Godot 4.7** (GDScript, Jolt physics, mobile renderer, PSX-style look). A run is a series of procedurally generated dungeon floors: clear combat rooms of enemies picked by a threat-budget, unlock the boss/treasure doors, beat the boss, advance to the next floor. Four playable characters (Karina, Winter, Giselle, NingNing) are swappable mid-run. German is the primary language of code comments and design docs; the player-facing README is in German.

## Commands

There is no CLI build/test/lint toolchain — this is a Godot editor project.

- **Run the game**: open `project.godot` in the Godot 4.7 editor and press Play (or `godot --path .` from the CLI if the Godot binary is on `PATH`). Main scene: `scenes/main_menu.tscn`.
- **Export a build**: File → Export in the editor, using the presets in `export_presets.cfg` (currently only "Windows Desktop", output to `Game Export/Whiplash.exe`).
- **No automated test suite** exists. Two in-game debug rooms substitute for manual testing:
  - `EnemySandboxRoom` (autoload) — spawn any enemy type (including the six prototypes not yet in the level generator's spawn tables) in isolation. Reached via the 4th pad in `scripts/debug_teleporter.gd`.
  - `ItemTestRoom` (autoload) — same idea for items.
- **Full project text dump** (for pasting into an LLM chat, not for Claude Code): `run_management_export.bat` regenerates `_project_export.txt` via a PowerShell one-liner and copies it to the clipboard. Not needed inside this session.

### Knowledge base / wiki tooling

The repo carries an Obsidian vault (`00_Dashboard/`, `01_Game_Design/`, `02_Tech_Architecture/`, `03_DevLogs/`, `04_Chat_Prompts/`, `05_Gedanken/`) plus a `graphify-out/` knowledge graph, generated from the actual project files (not hand-written):

- `python generate_vault.py` — full idempotent rebuild of the vault (items, enemies, rooms, status effects, devlogs from git log, architecture notes, MOC/dashboard pages) from `scripts/items/item_catalog.gd`, `resources/enemies/es_*.tres`, `resources/rooms/rd_*.tres`, `scripts/status_effects/*.gd`, and git history. Run after larger content changes (new items/enemies/rooms).
  - `write_wiki_sync()` inside it also regenerates `98_Scripts/wiki_sync.py`, its own incremental counterpart — don't hand-edit that file's sync logic.
- `python 98_Scripts/wiki_sync.py [--apply]` — lighter-weight: refreshes only YAML frontmatter of existing item/room notes from current source, without touching hand-written prose sections. Enemies/status-effects are not yet wired up there (marked TODO in the file).
- `graphify update .` — refresh the knowledge graph after code changes (AST-only, no API cost); see the global CLAUDE.md graphify rules for query usage.
- `02_Tech_Architecture/*.md` are hand-maintained architecture notes per key script (see below) — read these before diving into the corresponding `.gd` file, they document *why*, not just *what*.

## Architecture

### Autoloads (singletons, `project.godot` → `[autoload]`)

| Name | Script | Role |
|---|---|---|
| `SettingsManager` | `scripts/settings_manager.gd` | video/audio/input/accessibility settings |
| `PartyManager` | `scripts/party_manager.gd` | active party, character switching, last-stand |
| `SteamManager` | `scripts/steam_manager.gd` | Steam integration |
| `LeaderboardManager` | `scripts/leaderboard_manager.gd` | speedrun leaderboards |
| `VFX` | `scripts/vfx_manager.gd` | shared particle/VFX spawning |
| `Juice` | `scripts/game_juice.gd` | hit-stop / camera-feedback ("game juice") |
| `Items` | `scripts/items/item_manager.gd` | inventory, currencies, item-effect event bus |
| `Loot` | `scripts/loot_manager.gd` | drops when a room is cleared |
| `RunRestart` | `scripts/run_restart.gd` | the one legitimate full-scene-reload path |
| `Treasure` | `scripts/treasure_manager.gd` | treasure room / pedestal logic |
| `RoomGuard` | `scripts/room_commit_guard.gd` | anti-exploit: commits room-clear state |
| `EnemyDensity` | `scripts/enemies/enemy_density.gd` | per-stage enemy HP/damage scaling |
| `HudExtra` | `scripts/hud_extra.gd` | secondary HUD elements |
| `Teleporter` | `scripts/debug_teleporter.gd` | debug teleport pads (incl. sandbox rooms) |
| `Stages` | `scripts/level/stage_manager.gd` | floor-to-floor progression |
| `GameStats` | `scripts/game_stats.gd` | run statistics |
| `ItemTestRoom` / `EnemySandboxRoom` | `scripts/item_test_room.gd` / `scripts/enemy_sandbox_room.gd` | debug-only sandbox rooms |

### Level generation (`scenes/level_generation/`)

`level_generator.gd` builds each floor's layout from `RoomData` templates (`resources/rooms/rd_*.tres` + scenes under `scenes/rooms/{combat,corridor,treasure,boss}/`), growing a tree via `room_grid_generator.gd`. Key points documented in `02_Tech_Architecture/level_generator.md`:

- **Threat-budget spawning**: combat rooms get a point budget; each enemy type (`EnemySpawnEntry.threat_cost`) costs points, so a room may have many cheap enemies or few expensive ones instead of a fixed spawn list.
- **Multi-cell rooms** (`footprint_cells`, e.g. `2x1`/`2x2`) are assigned *after* tree growth (`_assign_footprints`), not during, so a large room doesn't consume multiple frontier slots and break branching. Their exits are fixed in the `.tscn` itself, not generator-assigned.
- **Floor progression** (`generate_stage()`): the seed + stage number drive layout generation; there is deliberately **no `reload_current_scene()`** on floor change — only rooms/hazards/projectiles/status-effects reset, while `Items`, `PartyManager`, `PlayerStats`, and the player node persist (contrast with `RunRestart`, which *does* reload and wipes everything — see `scripts/level/stage_manager.gd` header for the distinction).
- Rooms lock their doors on entry until cleared; boss/treasure doors are additionally lockable/hackable (`hack_prompt.gd`), gated by `treasure_door_cleared()`/room state.
- `room_instance.gd` owns per-room door/exit bookkeeping (`_doors_by_dir`, bitmask constants `EXIT_NORTH/SOUTH/EAST/WEST`) and fog-of-war visual layering for the minimap.

### Player & party (`scripts/party_manager.gd`, `scripts/player_base.gd`, `scripts/combat_base.gd`, `scripts/characters/`)

Exactly **one** active `CharacterBody3D` exists at a time. Switching characters destroys the current instance and instantiates the new one at the same position/camera/HP (`PartyManager`). Each of the 4 characters is `char_<name>.tscn` + `scripts/characters/char_<name>.gd` (extends `player_base.gd`) paired with `combat_<name>.gd` (extends `combat_base.gd`).

- `player_base.gd`: camera rig, two-stage stun-lock protection (diminishing returns, then an immunity window), status-effect binding, void-death, ragdoll death.
- `combat_base.gd`: shared cooldown/combo/hit-lock/dash system; characters override virtual `_perform_*` methods and cooldown `@export`s. Q/E are **not** character abilities — they are the two active-item slots (`Items.use_active_item(0/1)`), charged by clearing rooms rather than by a timer; the HUD's radial cooldown display is reused to show item charge instead.
- Last-stand: when the active character dies with teammates alive, the next one auto-takes over; the *whole* remaining party's HP is capped to `LAST_STAND_HP_FRACTION`, with a brief switch-invulnerability window to avoid the same hit killing the new character too. `party_wiped` (death screen) only fires when everyone is down.
- Switching *away* from a character puts a 10s cooldown on switching back *to* them.

### Combat (`scripts/primary_hitbox.gd`, `scripts/health.gd`, `scripts/combat_base.gd`)

`Hitbox` (`Area3D`) carries damage/knockback/stun/status-effect payload and VFX refs; on landing it applies to any node reachable via a `Health` child node. Enemies and players both expose damage taking the same way, which is what lets a single `Hitbox`/`primary_hitbox.gd` implementation serve both.

### Enemies — two parallel systems

- **`scripts/enemies/enemy_ai.gd`** (`EnemyAI`, `CharacterBody3D`, states `IDLE/CHASE/ATTACK`): the three level-generator enemies (Fighter, Stinger, Colossus). Imported robot mesh, chase/attack state machine, per-instance speed variance so packs don't move in lockstep.
- **`scripts/enemies/custom_enemy_base.gd`**: an intentionally *separate* base (NOT inheriting `EnemyAI`) for six newer, simpler enemy types (turret/flyer archetypes built from primitive meshes, no run animation) — `mörser-bot`, `säure-sprinkler`, `magnet-kern`, `divebomber`, `schild-drohne`, `plasmastrahl-bot`. Lifecycle: `_ready()` → `_configure()` → `_build_health()` → `_build_status_effects()` → `_build()`; teardown via `_on_died()`/`despawn()` → `_teardown()`.
  - **These six are not yet in `level_generator.gd`'s threat-budget spawn tables** — the *only* place they currently spawn is `scripts/enemy_sandbox_room.gd` (the debug sandbox), via `ClassName.new()` since they have no `.tscn`.
  - To interoperate with the rest of the game both systems must independently satisfy: group `"enemies"` (how items/bombs/homing-bolts find targets), `collision_layer = 4` (matches `PrimaryHitbox.collision_mask`), and a child node literally named `"Health"` (found via `find_child`).
  - Forced removal (e.g. `enemy_sandbox_room.gd`'s "clear enemies" pad) must call `_cleanup_effects()` explicitly — `queue_free()` does not fire `Health.died`, so anything relying on that signal (beams, telegraphs) would otherwise leak until its own timeout.

See `02_Tech_Architecture/custom_enemy_base.md` and `enemy_sandbox_room.md` for the full rationale.

### Items (`scripts/items/`)

`ItemCatalog` (`item_catalog.gd`) defines every item **in code**, not as `.tres` resources — deliberate, so a new item is a function call, balance changes show in `git diff`, and there are no broken resource paths. Items carry a rarity (`COMMON`→`LEGENDARY`) that `ItemData` derives a pedestal color from — never set `pedestal_color` directly, it silently overrides rarity-based coloring.

`Items` (autoload, `item_manager.gd`) is the run-scoped inventory and item-effect event bus — deliberately an autoload rather than a player component, because `PartyManager` fully replaces the player instance on every character switch. It re-attaches runtime components (`PlayerStats`, `BombCarrier`) to each new player instance and knows no item *rules* itself; `item_behaviours.gd` listens to its signals and implements anything with a condition/timer/status-effect/VFX (pure stat-boost items only need an entry in `item_catalog.gd`'s `stat_modifiers`, no `item_behaviours.gd` code). Active items occupy exactly 2 slots (Q/E), first-come-first-served; a third active item stays in inventory but is unequipped.

### Status effects (`scripts/status_effects/`)

`status_effect_manager.gd` is a per-entity (player or enemy) runtime component: timers, ticking, cleanup, all centralized here so the ~20+ individual effect files under `scripts/status_effects/*.gd` only need to define balancing numbers and VFX choice. `apply_effect()` takes the max of old/new value (not additive — use `extend_effect()`/`extend_all()` to actually lengthen a running effect). `DOT_IDS` is the authoritative list of damage-over-time effect ids; a new DOT must be added there or it never ticks in `enemy_ai.gd`.

### Progression & run lifecycle

- `scripts/level/stage_manager.gd` (`Stages`): advances floors on entering the goal zone; player state persists (see Level generation above).
- `scripts/run_restart.gd` (`RunRestart`): the only path that actually reloads the scene tree, wiping the run. Calls `PartyManager.notify_scene_reset()` first — without it, `PartyManager` holds a stale-but-non-null player reference after reload (`player == null` is `false` even though `is_instance_valid(player)` is `false`), which used to silently break the restart button/`R` key. Liveness checks must go through `has_player()`/`is_instance_valid()`, not `player == null`.
- `scripts/loot_manager.gd` (`Loot`): hooks `SceneTree.node_added` (not the level generator directly) so drops also work in hand-built test scenes containing `RoomInstance` nodes directly. Uses a per-room RNG derived from run-seed + grid position, deliberately independent of the global gameplay RNG (`det_rng.gd`), so a leaderboard seed produces identical loot on replay even though the global RNG's position drifts unpredictably during play.
- `scripts/treasure_manager.gd` (`Treasure`): treasure room/pedestal item selection, gated behind the same clear-state checks as boss doors.

### Design docs vs. code

`01_Game_Design/` (Items, Enemies, Rooms, Status_Effects) documents *balance intent*; `02_Tech_Architecture/` documents *implementation rationale* per key script, cross-linked via `[[wikilinks]]`. When changing balancing numbers or adding items/enemies/rooms, prefer updating the source file (`item_catalog.gd`, `es_*.tres`, `rd_*.tres`, `status_effects/*.gd`) and then regenerating the vault — the vault content is derived, not authored by hand (frontmatter and structural sections at least; some prose sections are hand-maintained, see `wiki_sync.py` docstring).


## Verwandte Seiten
- [[HOME]]
