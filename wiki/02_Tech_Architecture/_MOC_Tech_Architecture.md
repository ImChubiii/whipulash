---
tags: [moc, architecture]
---

# MOC — Tech-Architektur

Übersicht aller `02_Tech_Architecture`-Notizen. Jede Notiz dokumentiert das
*Warum* eines Scripts (Design-Entscheidungen, Stolperfallen, historische
Bugs) — nicht das *Was*, das steht im Code selbst. Die meisten Einträge sind
Autoloads (Singletons aus `game/project.godot`).

### Player & Party
- [[party_manager]]
- [[player_base]]

### Combat & Feedback
- [[combat_base]]
- [[status_effect_manager]]
- [[vfx_manager]]
- [[game_juice]]
- [[esp_target]]

### Gegner
- [[custom_enemy_base]]
- [[enemy_density]]
- [[enemy_sandbox_room]]

### Level & Räume
- [[level_generator]]
- [[room_commit_guard]]
- [[stage_manager]]

### Items & Belohnungen
- [[item_manager]]
- [[loot_manager]]
- [[treasure_manager]]

### Run-Lifecycle & Progression
- [[run_restart]]
- [[game_stats]]
- [[leaderboard_manager]]

### Plattform & Tools
- [[steam_manager]]
- [[settings_manager]]
- [[hud_extra]]
- [[debug_teleporter]]
