---
title: "Weitere Anpassungen, UI-Änderungen und Bugfixes"
date: 2026-08-13
tags: [chatlog, prompt-log, whiplash, lemonade, thema/ui, thema/balancing, thema/feature, ki/claude-cli]
ki_art: "claude cli"
---
# Weitere Anpassungen, UI-Änderungen und Bugfixes

[Source File](file:///C:/Users/thvnh/.claude/projects/C--Users-thvnh-Documents-GitHub-whiplash/session-1c0545a3-7a57-4f6c-a512-50c2a368b01b.html)

# 📋 Session `1c0545a3` — Model: `claude-sonnet-5`

## 🤷 User: *Ich habe noch ein paar weitere Anpassungen…*

**`2026-08-13`** `19:33:54`

Ich habe noch ein paar weitere Anpassungen, UI-Änderungen und Bugfixes für das Spiel, die umgesetzt werden müssen:

### 1. Tutorial-Texte & Erklärungen verbessern

Die Texte im Tutorial sollen detaillierter werden und dem Spieler die genaue Steuerung erklären.

- **Aufgabe:** Bitte überarbeite die permanenten UI-Texte im Tutorial. Sie sollen Tasten-Inputs erwähnen (z.B. "Drücke RMB [Rechte Maustaste] für...", "LMB für...").
- **Dash-Mechanik:** Füge in der Tutorial-Beschreibung unbedingt hinzu, dass der Spieler mit der **Shift-Taste über Hindernisse dashen** kann.

### 2. UI & Kamera-Anpassungen

- **Minimap Zoom:** Bitte setze den Default-Wert für den Kartenzoom auf **1.60**.
- **Cooldown HUD:** Das Cooldown-UI unten rechts auf dem Bildschirm ist zu klein. Bitte vergrößere das HUD-Element (Scale/Size anpassen).

### 3. Gegner-Skalierung

- **Aufgabe:** Die Gegner "Mörser" und "Säure-Kanonen" sind zu groß. Bitte verkleinere das 3D-Modell (Scale) dieser beiden Gegner-Typen ein bisschen, damit sie besser ins Spiel passen.

### 4. Bugfix & Überarbeitung: Enemy ESP (Winter & Giselle)

Es gibt aktuell Probleme mit dem ESP-Indikator (Enemy Target/Highlight) bei den Charakteren Winter und Giselle.

- **Bug 1 (Mehrfaches ESP):** Wenn ein Gegner mehrfach getroffen wird (z.B. durch jeden einzelnen Schuss), entstehen teilweise mehrere ESP-Indikatoren auf demselben Gegner.
- **Bug 2 (ESP bleibt):** Das ESP verschwindet nicht immer, wenn der Gegner stirbt.
- **Neue ESP-Logik (Singuläres Target):** Ich möchte das System vereinfachen. Es soll zu jedem Zeitpunkt im Spiel **nur exakt einen aktiven ESP-Indikator** geben. Dieser eine Indikator soll dynamisch von Gegner zu Gegner springen, je nachdem, welchen Gegner der Spieler gerade anvisiert hat bzw. auf welchen er schießt. Wenn der anvisierte Gegner stirbt, muss das ESP sofort verschwinden, bis ein neuer Gegner anvisiert wird.

Bitte zeige mir, welche Skripte für diese Änderungen angepasst werden müssen (vor allem das ESP-Targeting-Skript, Enemy-Prefabs und das UI/Tutorial-Manager-Skript) und stelle den entsprechenden Code bereit.

### 💭 Thinking

`19:33:58`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash: *Check graphify-out directory contents*

`19:33:59`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && ls graphify-out/ | head -20 && echo "---" && ls graphify-out/graph.json 2>&1
```

```
2026-08-12
2026-08-13
GRAPH_REPORT.md
cache
graph.html
graph.json
manifest.json
---
graphify-out/graph.json
```

### 💭 Thinking

`19:34:07`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash: *Query graphify knowledge graph for ESP targeting system*

`19:34:08`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify query "enemy ESP target indicator highlight system" 2>&1 | head -100
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Traversal: BFS depth=2 | Start: ['Highlights der Überarbeitung', '2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes', 'enemy_sandbox_room.gd', 'Enemy Behavior: No Fleeing Code', 'User Raw Lisieren Lisieren 1 Thought 2 Systems'] | 103 nodes found



[!] TRUNCATED: showing 34 of 103 nodes (~2000-token budget). The answer may be among the 69 cut nodes — raise the token budget (CLI: --budget) or narrow the query (e.g. context_filter=['call'], or get_node for a specific symbol).



NODE Highlights der Überarbeitung [src=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md loc=L114 community=Assistant]

NODE 2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L10 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE enemy_sandbox_room.gd [src=02_Tech_Architecture/enemy_sandbox_room.md loc= community=custom_enemy_base.gd]

NODE Enemy Behavior: No Fleeing Code [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L6 community=Enemy Behavior: No Fleeing Code]

NODE User Raw Lisieren Lisieren 1 Thought 2 Systems [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L6 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE custom_enemy_base.gd [src=02_Tech_Architecture/enemy_sandbox_room.md loc= community=custom_enemy_base.gd]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md loc=L82 community=Assistant]

NODE 2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L1 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE Erwaehnte Entitaeten [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L33 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE Metadaten [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L41 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE 🧠 Semantische Verbindungen (Graphify) [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L49 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE 2026-07-26_enemy-behavior-no-fleeing-code-1.md [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L1 community=Enemy Behavior: No Fleeing Code]

NODE Gemini [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L15 community=Enemy Behavior: No Fleeing Code]

NODE Gemini [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L139 community=Enemy Behavior: No Fleeing Code]

NODE Gemini [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L443 community=Enemy Behavior: No Fleeing Code]

NODE Gemini [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L48 community=Enemy Behavior: No Fleeing Code]

NODE User [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L10 community=Enemy Behavior: No Fleeing Code]

NODE User [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L187 community=Enemy Behavior: No Fleeing Code]

NODE User [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L44 community=Enemy Behavior: No Fleeing Code]

NODE User [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L64 community=Enemy Behavior: No Fleeing Code]

NODE 2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L1 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L39 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L132 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L139 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L143 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L151 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L155 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L163 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L167 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L175 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L179 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L187 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L191 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md loc=L199 community=User Raw Lisieren Lisieren 1 Thought 2 Systems]

... (truncated — 69 more nodes cut by ~2000-token budget. Narrow with context_filter=['call'] or use get_node for a specific symbol)
```

### 🤖 Assistant: *Graphify query returned mostly wiki/chat…*

`19:34:18`

<details>
<summary>Thinking...</summary>

> 
</details>

> Graphify query returned mostly wiki/chat-log noise, not source code. Let me search directly with grep for the actual scripts involved.

#### 🔎 Grep `esp|ESP|target_indicator|TargetIndicator|enemy_highlight|EnemyHighlight` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:34:19`

```
Found 39 files
scripts\items\item_manager.gd
scripts\items\item_behaviours.gd
scripts\party_manager.gd
scripts\treasure_manager.gd
scripts\characters\combat_winter.gd
scripts\combat_base.gd
scripts\player_base.gd
scripts\enemy_sandbox_room.gd
scripts\enemies\enemy_ai.gd
scripts\characters\combat_karina.gd
scripts\characters\combat_giselle.gd
scripts\level\stage_theme.gd
scripts\primary_hitbox.gd
scripts\health.gd
scripts\enemies\custom_enemy_base.gd
scripts\vfx\blood_decal.gd
scripts\pit_floor.gd
scripts\minimap.gd
scripts\vfx\enemy_esp_box.gd
scripts\enemies\mortar_bot.gd
scripts\hud.gd
scripts\pause_menu.gd
scripts\death_screen.gd
scripts\enemies\shield_drone.gd
scripts\enemies\plasma_beam_bot.gd
scripts\enemies\magnet_core.gd
scripts\rooms\room_switch_arena.gd
scripts\ui\plasma_darkness_overlay.gd
scripts\bomb.gd
scripts\victory_trophy.gd
scripts\ui\boss_health_bar.gd
scripts\status_effects\rooted.gd
scripts\settings_manager.gd
scripts\run_restart.gd
scripts\reset_overlay.gd
scripts\hazards\turret_projectile.gd
scripts\hazards\turret.gd
scripts\hazards\lemonade.gd
scripts\bomb_carrier.gd
```

### 💭 Thinking

`19:34:25`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash: *Query graphify for enemy_esp_box.gd relationships*

`19:34:25`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify explain "enemy_esp_box.gd" 2>&1 | head -80
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

No node matching 'enemy_esp_box.gd' found.
```

### 💭 Thinking

`19:34:36`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash: *Query graphify with larger budget for ESP box*

`19:34:37`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify query "EnemyESPBox target enemy highlight indicator script" --budget 4000 2>&1 | head -150
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Traversal: BFS depth=2 | Start: ['Highlights der Überarbeitung', 'enemy_sandbox_room.gd', 'Enemy Behavior: No Fleeing Code', '2026-07-23 — fix: reassign Area3D script to correct parent node', '2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes'] | 33 nodes found



NODE Highlights der Überarbeitung [src=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md loc=L114 community=Assistant]

NODE enemy_sandbox_room.gd [src=02_Tech_Architecture/enemy_sandbox_room.md loc= community=custom_enemy_base.gd]

NODE Enemy Behavior: No Fleeing Code [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L6 community=Enemy Behavior: No Fleeing Code]

NODE 2026-07-23 — fix: reassign Area3D script to correct parent node [src=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md loc=L10 community=2026-07-23 — fix: reassign Area3D script to correct parent node]

NODE 2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L10 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE custom_enemy_base.gd [src=02_Tech_Architecture/enemy_sandbox_room.md loc= community=custom_enemy_base.gd]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md loc=L82 community=Assistant]

NODE 2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md [src=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md loc=L1 community=2026-07-23 — fix: reassign Area3D script to correct parent node]

NODE 2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L1 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE Erwaehnte Entitaeten [src=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md loc=L14 community=2026-07-23 — fix: reassign Area3D script to correct parent node]

NODE Metadaten [src=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md loc=L22 community=2026-07-23 — fix: reassign Area3D script to correct parent node]

NODE 🧠 Semantische Verbindungen (Graphify) [src=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md loc=L30 community=2026-07-23 — fix: reassign Area3D script to correct parent node]

NODE Erwaehnte Entitaeten [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L33 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE Metadaten [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L41 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE 🧠 Semantische Verbindungen (Graphify) [src=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md loc=L49 community=2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes]

NODE 2026-07-26_enemy-behavior-no-fleeing-code-1.md [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L1 community=Enemy Behavior: No Fleeing Code]

NODE Gemini [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L15 community=Enemy Behavior: No Fleeing Code]

NODE Gemini [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L139 community=Enemy Behavior: No Fleeing Code]

NODE Gemini [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L443 community=Enemy Behavior: No Fleeing Code]

NODE Gemini [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L48 community=Enemy Behavior: No Fleeing Code]

NODE User [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L10 community=Enemy Behavior: No Fleeing Code]

NODE User [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L187 community=Enemy Behavior: No Fleeing Code]

NODE User [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L44 community=Enemy Behavior: No Fleeing Code]

NODE User [src=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md loc=L64 community=Enemy Behavior: No Fleeing Code]

NODE _MOC_DevLogs.md [src=03_DevLogs/_MOC_DevLogs.md loc=L1 community=_MOC_DevLogs.md]

NODE Du Bist Ein Wiki Autor Fuer Das Spiel Lemonade [src=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md loc=L6 community=Assistant]

NODE Divebomber [src=01_Game_Design/Enemies/divebomber.md loc= community=custom_enemy_base.gd]

NODE Magnet-Kern [src=01_Game_Design/Enemies/magnet-kern.md loc= community=custom_enemy_base.gd]

NODE Moerser-Bot [src=01_Game_Design/Enemies/moerser-bot.md loc= community=custom_enemy_base.gd]

NODE Plasmastrahl-Bot [src=01_Game_Design/Enemies/plasmastrahl-bot.md loc= community=custom_enemy_base.gd]

NODE Saeure-Sprinkler [src=01_Game_Design/Enemies/saeure-sprinkler.md loc= community=custom_enemy_base.gd]

NODE Schild-Drohne [src=01_Game_Design/Enemies/schild-drohne.md loc= community=custom_enemy_base.gd]

NODE Bearbeitete Dateien [src=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md loc=L86 community=Assistant]

EDGE enemy_sandbox_room.gd --calls [EXTRACTED]--> custom_enemy_base.gd

EDGE 2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md --contains [EXTRACTED]--> 2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes at=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md:L10

EDGE 2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes --contains [EXTRACTED]--> Erwaehnte Entitaeten at=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md:L33

EDGE 2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes --contains [EXTRACTED]--> Metadaten at=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md:L41

EDGE 2026-08-04 — feat(debug, ui, combat): Teleporter-System, Boss-HP-Multi-Targeting, Popup-Positionierung und Despawn-Fixes --contains [EXTRACTED]--> 🧠 Semantische Verbindungen (Graphify) at=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md:L49

EDGE 2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md --contains [EXTRACTED]--> 2026-07-23 — fix: reassign Area3D script to correct parent node at=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md:L10

EDGE 2026-07-23 — fix: reassign Area3D script to correct parent node --contains [EXTRACTED]--> Erwaehnte Entitaeten at=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md:L14

EDGE 2026-07-23 — fix: reassign Area3D script to correct parent node --contains [EXTRACTED]--> Metadaten at=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md:L22

EDGE 2026-07-23 — fix: reassign Area3D script to correct parent node --contains [EXTRACTED]--> 🧠 Semantische Verbindungen (Graphify) at=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md:L30

EDGE Assistant --contains [EXTRACTED]--> Highlights der Überarbeitung at=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md:L114

EDGE 2026-07-26_enemy-behavior-no-fleeing-code-1.md --contains [EXTRACTED]--> Enemy Behavior: No Fleeing Code at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L6

EDGE Enemy Behavior: No Fleeing Code --contains [EXTRACTED]--> User at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L10

EDGE Enemy Behavior: No Fleeing Code --contains [EXTRACTED]--> Gemini at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L139

EDGE Enemy Behavior: No Fleeing Code --contains [EXTRACTED]--> Gemini at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L15

EDGE Enemy Behavior: No Fleeing Code --contains [EXTRACTED]--> User at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L187

EDGE Enemy Behavior: No Fleeing Code --contains [EXTRACTED]--> User at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L44

EDGE Enemy Behavior: No Fleeing Code --contains [EXTRACTED]--> Gemini at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L443

EDGE Enemy Behavior: No Fleeing Code --contains [EXTRACTED]--> Gemini at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L48

EDGE Enemy Behavior: No Fleeing Code --contains [EXTRACTED]--> User at=04_Chat_Prompts/2026-07-26_enemy-behavior-no-fleeing-code-1.md:L64

EDGE 2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md --references [EXTRACTED]--> _MOC_DevLogs.md at=03_DevLogs/2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult.md:L51

EDGE Divebomber --implements [EXTRACTED]--> custom_enemy_base.gd

EDGE Magnet-Kern --implements [EXTRACTED]--> custom_enemy_base.gd

EDGE Moerser-Bot --implements [EXTRACTED]--> custom_enemy_base.gd

EDGE Plasmastrahl-Bot --implements [EXTRACTED]--> custom_enemy_base.gd

EDGE Saeure-Sprinkler --implements [EXTRACTED]--> custom_enemy_base.gd

EDGE Schild-Drohne --implements [EXTRACTED]--> custom_enemy_base.gd

EDGE 2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md --references [EXTRACTED]--> _MOC_DevLogs.md at=03_DevLogs/2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node.md:L32

EDGE Assistant --contains [EXTRACTED]--> Bearbeitete Dateien at=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md:L86

EDGE Du Bist Ein Wiki Autor Fuer Das Spiel Lemonade --contains [EXTRACTED]--> Assistant at=04_Chat_Prompts/2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md:L82
```

### 💭 Thinking: *The graph isn't capturing the .gd source…*

`19:34:47`

<details>
<summary>Thinking...</summary>

> The graph isn't capturing the .gd source files at the level of detail I need—it's mostly picking up wiki and devlog content. I've already satisfied the requirement to query graphify first, so now I'll move to direct file reading since the graph didn't provide enough context, and grep can…
</details>

#### 👀 Read `enemy_esp_box.gd`

`19:34:47`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\enemy_esp_box.gd</code></summary>

```
extends Node3D
class_name EnemyEspBox

# ============================================================================
# EnemyEspBox — "ESP-Hack"-Kastenumriss um ein anvisiertes Ziel.
# ============================================================================
# Macht sichtbar, WEN das jeweilige Waffensystem gerade automatisch anvisiert
# hat - dieselbe Grundidee wie die bereits existierenden Label3D-Diamant-
# Marker (siehe combat_giselle.gd::_build_esp_marker(), combat_winter.gd::
# _build_laser_esp_marker()), nur als Kastenumriss statt Text, und zusaetzlich
# mit einem kurzen Aufleucht-Puls (flash()) bei jedem tatsaechlichen Treffer.
#
# Haengt wie die Diamant-Marker unabhaengig unter current_scene, NICHT unter
# dem Ziel selbst - der aufrufende Combat-Node aktualisiert die Position
# jeden Frame per global_position, exakt das gleiche Muster wie
# _update_uzi_esp()/_update_laser_esp().
#
# Gebaut als zwoelf duenne, unshaded/emissive BoxMesh-Kanten statt eines
# echten Wireframe-Materials/Shaders - passt damit zum Rest des Projekts
# (siehe dive_bomber.gd::_build_visual(), custom_enemy_base.gd), das
# durchgehend einfache Primitiv-Meshes fuer Debug-/Hack-Optik nutzt statt
# eigener Shader.

const EDGE_THICKNESS: float = 0.045
const FLASH_DURATION: float = 0.18
## Rueckmeldung "Material/Shader deutlich sichtbarer/leuchtender machen":
## IDLE_ENERGY war 1.7, FLASH_ENERGY 5.0 - beide angehoben, PLUS Wechsel von
## alpha-gemischter Transparenz auf additive Blendung (siehe _add_edge()).
## Additiv heisst: die Kanten hellen den Hintergrund auf statt ihn nur zu
## ueberdecken - genau der "leuchtet durch alles hindurch"-Hack-Look, den
## z.B. auch treasure_pedestal.gd fuer seine Lichtsaeule nutzt
## (_make_glow_material()).
const FLASH_ENERGY: float = 9.0
const IDLE_ENERGY: float = 3.2
const IDLE_ALPHA: float = 0.95

## Rundherum-Zuschlag auf die aus der Kollisionsform berechnete Groesse
## (siehe compute_box_size()) - der Kasten soll den Gegner sichtbar
## UMGEBEN, nicht seine Huelle exakt nachzeichnen.
const SIZE_PADDING: float = 1.2
## Mindestgroesse pro Achse, falls ein Gegner keine (oder eine winzige)
## Kollisionsform hat - verhindert einen unsichtbar kleinen Punkt-Kasten.
const MIN_SIZE: Vector3 = Vector3(1.0, 1.0, 1.0)

## corner-index-Paare, die die zwoelf Kanten eines Quaders aus den acht
## Eckpunkten unten (_corners()) bilden - vier auf dem Boden, vier auf dem
## Deckel, vier vertikal dazwischen.
const EDGES: Array = [
	[0, 1], [1, 2], [2, 3], [3, 0],
	[4, 5], [5, 6], [6, 7], [7, 4],
	[0, 4], [1, 5], [2, 6], [3, 7],
]

var _color: Color = Color(1.0, 0.15, 0.15)
var _materials: Array[StandardMaterial3D] = []
var _flash_tween: Tween = null

## Groesse, mit der diese Box gebaut wurde - Aufrufer nutzen size.y * 0.5,
## um den vertikalen Versatz zum Ziel korrekt zu zentrieren (siehe
## combat_giselle.gd/combat_winter.gd), statt eines festen Werts, der bei
## einem Colossus zu tief und bei einem Fighter zu hoch saesse.
var size: Vector3 = Vector3.ONE


## Baut eine freistehende EnemyEspBox-Instanz, NICHT in den Baum gehaengt -
## der Aufrufer haengt sie selbst per add_child() unter current_scene
## (gleiches Muster wie _build_esp_marker()) und setzt global_position.
static func build(color: Color, box_size: Vector3 = Vector3(1.6, 2.2, 1.6)) -> EnemyEspBox:
	var box := EnemyEspBox.new()
	box._color = color
	box.size = box_size
	box._build_edges(box_size)
	return box


## Wie build(), bestimmt die Groesse aber selbst aus der Kollisionsform des
## Ziels statt einen festen Wert zu nehmen - Rueckmeldung "Kasten muss
## dynamisch mit der Groesse des jeweiligen Gegners skalieren (Colossus
## braucht groesseren Kasten als Fighter)".
static func build_for(enemy: Node3D, color: Color) -> EnemyEspBox:
	return build(color, compute_box_size(enemy))


## Sammelt alle CollisionShape3D-Nachfahren des Ziels und liefert eine
## gepolsterte Bounding-Box in Weltmasseinheiten. Deckt beide Gegnersysteme
## des Projekts ab (siehe CLAUDE.md-Architekturnotiz "zwei parallele
## Gegner-Systeme"): EnemyAI (Fighter/Stinger/Colossus) nutzt eine
## CapsuleShape3D, CustomEnemyBase-Gegner (Moerser-Bot etc., siehe
## custom_enemy_base.gd::_add_box_collision()) eine BoxShape3D. Die
## Shape-GROESSE selbst ist dort schon in Weltunits (inkl. VISUAL_SCALE)
## angegeben - hier wird nur noch die lokale Position/Rotation der jeweiligen
## CollisionShape3D-Node mit einbezogen, damit ein versetzt sitzender
## Collider die Bounding-Box nicht verfaelscht.
static func compute_box_size(enemy: Node3D) -> Vector3:
	if enemy == null or not is_instance_valid(enemy):
		return MIN_SIZE

	var min_corner := Vector3.INF
	var max_corner := -Vector3.INF
	var found: bool = false

	for shape_node: CollisionShape3D in _collect_collision_shapes(enemy):
		var extents: Vector3 = _shape_half_extents(shape_node.shape)
		if extents == Vector3.ZERO:
			continue
		found = true
		# Acht Eckpunkte der lokalen Shape-AABB, durch die Node-eigene
		# Transform (Position/Rotation innerhalb des Gegners) geschickt -
		# einfacher und robust genug fuer die hier ausschliesslich
		# achsenausgerichteten Formen, statt eine echte OBB zu rechnen.
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				for sz in [-1.0, 1.0]:
					var corner: Vector3 = shape_node.transform * Vector3(
						extents.x * sx, extents.y * sy, extents.z * sz
					)
					min_corner = min_corner.min(corner)
					max_corner = max_corner.max(corner)

	if not found:
		return MIN_SIZE

	var size: Vector3 = (max_corner - min_corner) * SIZE_PADDING
	return Vector3(maxf(size.x, MIN_SIZE.x), maxf(size.y, MIN_SIZE.y), maxf(size.z, MIN_SIZE.z))


static func _collect_collision_shapes(node: Node) -> Array[CollisionShape3D]:
	var result: Array[CollisionShape3D] = []
	if node is CollisionShape3D:
		result.append(node as CollisionShape3D)
	for child: Node in node.get_children():
		result.append_array(_collect_collision_shapes(child))
	return result


## Halbe Ausdehnung (lokale AABB-Extents, NICHT Weltmasse) fuer die in
## diesem Projekt vorkommenden Formtypen. Vector3.ZERO fuer alles andere
## (z.B. noch kein Shape zugewiesen) - vom Aufrufer als "ueberspringen"
## behandelt.
static func _shape_half_extents(shape: Shape3D) -> Vector3:
	if shape is BoxShape3D:
		return (shape as BoxShape3D).size * 0.5
	if shape is CapsuleShape3D:
		var capsule := shape as CapsuleShape3D
		return Vector3(capsule.radius, capsule.height * 0.5, capsule.radius)
	if shape is SphereShape3D:
		var r: float = (shape as SphereShape3D).radius
		return Vector3(r, r, r)
	if shape is CylinderShape3D:
		var cyl := shape as CylinderShape3D
		return Vector3(cyl.radius, cyl.height * 0.5, cyl.radius)
	return Vector3.ZERO


func _corners(size: Vector3) -> Array[Vector3]:
	var half: Vector3 = size * 0.5
	return [
		Vector3(-half.x, -half.y, -half.z), Vector3(half.x, -half.y, -half.z),
		Vector3(half.x, -half.y, half.z), Vector3(-half.x, -half.y, half.z),
		Vector3(-half.x, half.y, -half.z), Vector3(half.x, half.y, -half.z),
		Vector3(half.x, half.y, half.z), Vector3(-half.x, half.y, half.z),
	]


func _build_edges(size: Vector3) -> void:
	var corners: Array[Vector3] = _corners(size)
	for edge: Array in EDGES:
		_add_edge(corners[edge[0]], corners[edge[1]])


## Ein einzelner Kantenbalken: ein duenner BoxMesh, dessen lange Achse
## (lokal Z) per Basis.looking_at() auf die Kante ausgerichtet wird.
## Basis.looking_at() arbeitet rein in lokalen Vektoren (keine Baum-
## Zugehoerigkeit noetig) - anders als Node3D.look_at(), das schon
## global_position braucht und deshalb erst NACH add_child() funktionieren
## wuerde.
func _add_edge(from: Vector3, to: Vector3) -> void:
	var delta: Vector3 = to - from
	var length: float = delta.length()
	if length < 0.001:
		return
	var dir: Vector3 = delta / length
	var up: Vector3 = Vector3.FORWARD if absf(dir.dot(Vector3.UP)) > 0.99 else Vector3.UP

	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(EDGE_THICKNESS, EDGE_THICKNESS, length)
	mesh_instance.mesh = box

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(_color.r, _color.g, _color.b, IDLE_ALPHA)
	mat.emission_enabled = true
	mat.emission = _color
	mat.emission_energy_multiplier = IDLE_ENERGY
	# Additiv statt alpha-gemischt: hellt den Hintergrund auf statt ihn nur
	# zu ueberdecken - der eigentliche "leuchtet/glueht"-Unterschied (siehe
	# Konstanten-Kommentar oben).
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mesh_instance.material_override = mat
	_materials.append(mat)

	add_child(mesh_instance)
	mesh_instance.transform = Transform3D(Basis.looking_at(dir, up), from + delta * 0.5)


## Kurzer heller Puls bei einem tatsaechlichen Treffer - macht den Effekt
## reaktiv statt eines dauerhaft gleich hellen Umrisses ("laeuchtet auf, wenn
## der Angriff trifft" laut Rueckmeldung), statt nur staendig sichtbar zu
## sein, solange ein Ziel gelockt ist.
func flash() -> void:
	if _materials.is_empty():
		return
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()

	for mat: StandardMaterial3D in _materials:
		mat.emission_energy_multiplier = FLASH_ENERGY

	_flash_tween = create_tween()
	_flash_tween.set_parallel(true)
	for mat: StandardMaterial3D in _materials:
		_flash_tween.tween_property(mat, "emission_energy_multiplier", IDLE_ENERGY, FLASH_DURATION)

```
</details>

### 💭 Thinking

`19:34:52`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `esp|Esp|ESP` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd`

`19:34:53`

```
58:## Farbe des ESP-Markers ueber dem gerade vom Laser anvisierten Ziel.
59:@export var laser_esp_color: Color = Color(1.0, 0.15, 0.1)
65:var _laser_esp_marker: Label3D = null
66:## Kastenumriss um das gelockte Ziel, siehe scripts/vfx/enemy_esp_box.gd -
68:var _laser_esp_box: EnemyEspBox = null
117:		# ESP-Box PRO ZIEL, nicht ein einzelnes gelocktes Ziel wie bei Uzi/
121:		var esp_box: EnemyEspBox = EnemyEspBox.build_for(target, color)
122:		get_tree().current_scene.add_child(esp_box)
123:		esp_box.global_position = target.global_position + Vector3.UP * (esp_box.size.y * 0.5)
126:			_on_plasma_strike(hit_target, origin, dmg, esp_box)
134:			esp_box.queue_free()
142:				if is_instance_valid(esp_box):
143:					esp_box.queue_free()
176:func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float, esp_box: EnemyEspBox = null) -> void:
177:	if esp_box != null and is_instance_valid(esp_box):
178:		esp_box.flash()
181:		get_tree().create_timer(EnemyEspBox.FLASH_DURATION).timeout.connect(
183:				if is_instance_valid(esp_box):
184:					esp_box.queue_free()
270:	_update_laser_esp(target)
298:			if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
299:				_laser_esp_box.flash()
315:	_clear_laser_esp()
341:## Gleiches Muster wie combat_giselle.gd::_update_uzi_esp() - Label3D
342:## (billboard + no_depth_test) PLUS EnemyEspBox-Kastenumriss ueber dem gerade
344:func _update_laser_esp(target: Node3D) -> void:
346:		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
347:			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
348:		if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
349:			_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)
352:	_clear_laser_esp()
357:	_laser_esp_marker = _build_laser_esp_marker()
358:	get_tree().current_scene.add_child(_laser_esp_marker)
359:	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
361:	_laser_esp_box = EnemyEspBox.build_for(target, laser_esp_color)
362:	get_tree().current_scene.add_child(_laser_esp_box)
363:	_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)
366:func _clear_laser_esp() -> void:
367:	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
368:		_laser_esp_marker.queue_free()
369:	_laser_esp_marker = null
370:	if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
371:		_laser_esp_box.queue_free()
372:	_laser_esp_box = null
376:func _build_laser_esp_marker() -> Label3D:
383:	label.modulate = laser_esp_color
384:	label.outline_modulate = Color(laser_esp_color.r * 0.2, laser_esp_color.g * 0.2, laser_esp_color.b * 0.2, 0.9)
392:## _laser_beam und _laser_esp_marker haengen unter current_scene, nicht unter
```

### 💭 Thinking

`19:34:57`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`19:34:57`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```

extends CombatBase
class_name CombatWinter

# Winter: Energy/Crowd Control — Zonen-Kontrolle und stetiger DoT.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind weg - Q/E loesen jetzt immer das
# aktive Item im jeweiligen Slot aus, siehe combat_base.gd.
#
# Beide Faehigkeiten sind Hitscan/Projektil- statt Hitbox-basiert -
# PrimaryHitbox/SecondaryHitbox aus char_winter.tscn bleiben bewusst
# ungenutzt im Baum (siehe combat_base.gd-Kopfkommentar zu diesem Muster).

const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")
const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_muzzle_flash_winter.tscn")
const PROJECTILE_VFX_SCENE: PackedScene = preload("res://test vfx/MagicProjectilesVFX/assets/BinbunVFX/magic_projectiles/effects/mprojectile_basic/Magic Projectile Basic 3.tscn")
const PROJECTILE_HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_impact_004.tscn")
const MUZZLE_FORWARD_OFFSET: float = 0.8

## --- Primary "Magnetic Plasma" ---------------------------------------------
@export var plasma_damage: float = 12.0
## War 22.0 - Rueckmeldung "mehr Range der Enemy Detection beim Schiessen".
@export var plasma_range: float = 32.0
## Rueckmeldung "mehr Kugeln schiessen": statt eines einzelnen Bolts auf das
## naechste Ziel feuert Primary jetzt auf bis zu plasma_bolt_count
## UNTERSCHIEDLICHE nahe Ziele gleichzeitig - verteilt den Zusatzschaden auf
## die Gruppe, statt nur ein Ziel schneller zu ueberkillen.
@export var plasma_bolt_count: int = 2
## War als fester Parameter (16.0) an HomingBolt.spawn() durchgereicht -
## Rueckmeldung "schnellere Traveltime der Kugeln".
@export var plasma_bolt_speed: float = 24.0
@export var plasma_bolt_lifetime: float = 3.0
## Impuls, den ein getroffener Gegner Richtung Einschlag abbekommt - deutlich
## unter magnet_core.gd's PULL_IMPULSE_STRENGTH (16.0): stark genug, um kurz
## aus der Laufrichtung zu reissen, schwach genug, um niemanden komplett aus
## der Position zu ziehen.
@export var plasma_pull_strength: float = 10.0

## --- Secondary "Heavy Laser Stream" -----------------------------------------
@export var laser_damage_per_tick: float = 5.0
@export var laser_tick_interval: float = 0.05
@export var laser_range: float = 25.0
@export var laser_max_charge: float = 10.0
@export var laser_recharge_time: float = 5.0
@export var aim_assist_angle_deg: float = 5.0
@export var aim_assist_strength: float = 0.5
## Rework "Auto-Target wie Giselles Uzi" (Rueckmeldung): Blickkegel-
## Halbwinkel, in dem sich der Laser selbst sein Ziel sucht (siehe
## EnemyQuery.best_target_in_cone()) - ersetzt den alten praezisen, engen
## Aim-Assist oben fuer den Laser (aim_assist_* bleibt ungenutzt, falls
## spaeter wieder ein weicherer Modus gebraucht wird).
@export var laser_target_cone_deg: float = 35.0
## Farbe des ESP-Markers ueber dem gerade vom Laser anvisierten Ziel.
@export var laser_esp_color: Color = Color(1.0, 0.15, 0.1)

var _laser_energy: float = 10.0
var _laser_tick_timer: float = 0.0
var _laser_beam: Dictionary = {}
var _laser_locked_target: Node3D = null
var _laser_esp_marker: Label3D = null
## Kastenumriss um das gelockte Ziel, siehe scripts/vfx/enemy_esp_box.gd -
## leuchtet bei jedem Schadens-Tick kurz auf (_update_laser()).
var _laser_esp_box: EnemyEspBox = null

var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null


func _init() -> void:
	primary_cooldown = 0.4
	# secondary_cooldown bleibt auf dem geerbten Standardwert - fuer den
	# Laser irrelevant, da _poll_secondary_input() ihn komplett durch das
	# Batterie-System unten ersetzt und nie _do_secondary() aufruft.
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_laser_energy = laser_max_charge


# ============================================================================
# Magnetic Plasma - feuert ueber das UNVERAENDERTE _poll_primary_input()/
# _do_primary() aus combat_base.gd (gehalten -> feuert erneut sobald
# primary_cooldown abgelaufen). Sucht sich selbst ein Ziel statt in
# Blickrichtung zu feuern - "soft homing" gemaess Spec.
# ============================================================================
func _perform_primary() -> void:
	var targets: Array[Node3D] = _pick_plasma_targets()
	if targets.is_empty():
		return

	var origin: Vector3 = player.global_position + Vector3.UP * 1.4
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color if data else Color(0.5, 1.0, 0.7)
	var dmg: float = plasma_damage * _damage_multiplier()

	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man
	# schiesst": targets[0] ist der naechste (siehe _pick_plasma_targets()'
	# Sortierung) - nicht erst auf den Einschlag eines Bolts warten (der
	# Flug dauert je nach Distanz spuerbar).
	var primary_target = targets[0]
	_lock_model_to(primary_target)
	
	var dir = (primary_target.global_position + Vector3.UP - origin).normalized()
	var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
	_spawn_muzzle_vfx(muzzle_pos, dir)

	for target: Node3D in targets:
		# ESP-Box PRO ZIEL, nicht ein einzelnes gelocktes Ziel wie bei Uzi/
		# Sniper/Laser: Plasma kann bis zu plasma_bolt_count Gegner
		# gleichzeitig anfliegen. Kurzlebig statt "gelockt, bis es
		# wegfaellt" - passt zum Ein-Schuss-Charakter jedes einzelnen Bolts.
		var esp_box: EnemyEspBox = EnemyEspBox.build_for(target, color)
		get_tree().current_scene.add_child(esp_box)
		esp_box.global_position = target.global_position + Vector3.UP * (esp_box.size.y * 0.5)

		var on_strike: Callable = func(hit_target: Node3D) -> void:
			_on_plasma_strike(hit_target, origin, dmg, esp_box)

		var bolt: HomingBolt = HomingBolt.spawn(
			self, origin, target, color, on_strike, plasma_bolt_speed, plasma_bolt_lifetime, false, player
		)
		if bolt:
			_attach_plasma_trail(bolt, color)
		else:
			esp_box.queue_free()

		# Sicherheitsnetz: stirbt/entkommt das Ziel, bevor der Bolt trifft,
		# feuert HomingBolt._strike() (und damit der on_strike-Callback,
		# der die Box sonst aufraeumt) nie - die Box wuerde sonst dauerhaft
		# haengen bleiben.
		get_tree().create_timer(plasma_bolt_lifetime + 0.1).timeout.connect(
			func() -> void:
				if is_instance_valid(esp_box):
					esp_box.queue_free()
		)


## Bis zu plasma_bolt_count lebende Gegner in Reichweite, naechster zuerst.
func _pick_plasma_targets() -> Array[Node3D]:
	var candidates: Array[Node3D] = EnemyQuery.enemies_within(player.global_position, plasma_range)
	var origin: Vector3 = player.global_position
	candidates.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position)
	)
	if candidates.size() > plasma_bolt_count:
		candidates.resize(plasma_bolt_count)
	return candidates


func _attach_plasma_trail(bolt: Node3D, color: Color) -> void:
	for child in bolt.get_children():
		if child is MeshInstance3D:
			child.visible = false

	if PROJECTILE_VFX_SCENE != null:
		var vfx = PROJECTILE_VFX_SCENE.instantiate()
		if vfx is Node3D:
			vfx.rotation_degrees = Vector3(0, 90, 0)
		bolt.add_child(vfx)


## origin ist die Abschusspositon (NICHT die aktuelle Bolt-Position - der
## Bolt selbst reicht seine Position nicht an den Callback durch, siehe
## homing_bolt.gd::_strike()). Die Zug-Richtung ist deshalb "vom Abschussort
## zum Einschlag", nicht "vom Ziel weg vom Einschlag" - liest sich als
## Schubs weiter in Flugrichtung, siehe Kopfkommentar-Entscheidung im Plan.
func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float, esp_box: EnemyEspBox = null) -> void:
	if esp_box != null and is_instance_valid(esp_box):
		esp_box.flash()
		# Kurz nach dem Aufblitzen aufraeumen statt sofort - der Puls soll
		# noch sichtbar sein, bevor die Box mit dem Bolt zusammen verschwindet.
		get_tree().create_timer(EnemyEspBox.FLASH_DURATION).timeout.connect(
			func() -> void:
				if is_instance_valid(esp_box):
					esp_box.queue_free()
		)

	if not is_instance_valid(target):
		return
	var health: Node = target.find_child("Health", true, false)
	if health == null or not (health is Health) or not (health as Health).is_alive():
		return

	(health as Health).take_damage(dmg, player)

	# BUGFIX "LMB hat keine Damage Numbers": anders als der Laser (Hitscan.fire
	# bekommt eine damage_number_scene mit) spawnte der Plasma-Bolt-Treffer nie
	# eine Schadenszahl - derselbe Anzeigeweg wie Karinas Aura-Tick.
	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	if dns != null:
		var number: Node = dns.instantiate()
		get_tree().current_scene.add_child(number)
		(number as Node3D).global_position = target.global_position + Vector3(0.0, 1.8, 0.0)
		if number.has_method("show_damage"):
			number.show_damage(dmg)

	var pull_dir: Vector3 = target.global_position - origin
	pull_dir.y = 0.0
	# has_method()-Wache: NUR enemy_ai.gd und player_base.gd implementieren
	# apply_knockback() - die sechs CustomEnemyBase-Gegner (Moerser-Bot,
	# Saeure-Sprinkler, Magnet-Kern, Divebomber, Schild-Drohne, Plasmastrahl-
	# Bot) tun es NICHT und sollen einfach nur Schaden nehmen, ohne Fehler.
	if pull_dir.length_squared() > 0.01 and target.has_method("apply_knockback"):
		target.apply_knockback(pull_dir.normalized() * plasma_pull_strength)

	var spark: Node3D = VFX.spawn(PROJECTILE_HIT_VFX_SCENE if PROJECTILE_HIT_VFX_SCENE else HIT_VFX_SCENE, target.global_position + Vector3.UP, Vector3.UP)
	if player and player.has_method("shake_camera"):
		player.shake_camera(0.15)
	_lock_model_to(target)


# ============================================================================
# Heavy Laser Stream - Batterie statt Cooldown: ersetzt _poll_secondary_input
# komplett, ruft NIE _do_secondary()/den geerbten Cooldown-Mechanismus auf.
# ============================================================================
func _poll_secondary_input(delta: float) -> void:
	var held: bool = Input.is_action_pressed("attack_secondary")

	if held:
		# BUGFIX "Batterie laedt trotz gehaltener Taste wieder auf": vorher
		# fiel "gehalten, aber Energie=0" durch dieselbe Bedingung wie
		# "nicht gehalten" und startete sofort das Aufladen - solange man RMB
		# weiter gedrueckt hielt, pendelte die Energie dadurch nie richtig
		# hoch UND der Strahl blieb aus, obwohl man aktiv zu feuern versuchte.
		# Jetzt: solange gehalten wird, passiert entweder Feuern (Energie > 0)
		# oder GAR NICHTS (Energie leer) - aufgeladen wird ausschliesslich
		# nach dem Loslassen.
		if _laser_energy > 0.0:
			_laser_energy = maxf(_laser_energy - delta, 0.0)
			_update_laser(delta)
			if _laser_energy <= 0.0:
				_stop_laser()
		elif not _laser_beam.is_empty():
			_stop_laser()
		return

	if not _laser_beam.is_empty():
		_stop_laser()

	# Kein Mindest-Schwellenwert: die Formel selbst sorgt schon dafuer, dass
	# ein Teil-Ladezustand sofort wieder nutzbar ist, statt erst komplett
	# vollladen zu muessen ("partial charge = partial use" laut Spec).
	_laser_energy = minf(_laser_energy + delta * (laser_max_charge / laser_recharge_time), laser_max_charge)


func _update_laser(delta: float) -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung, siehe combat_giselle.gd.
	# Auto-Target statt weichem Aim-Assist (Rueckmeldung "wie bei Giselles
	# Uzi"): breiter Blickkegel, direkter Schuss aufs gefundene Ziel statt auf
	# die rohe Blickrichtung. Ohne Ziel im Kegel faellt der Strahl auf die
	# reine Blickrichtung zurueck.
	var look_dir: Vector3 = -_camera.global_transform.basis.z
	var target: Node3D = _resolve_laser_target(origin, look_dir)
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_laser_esp(target)
	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man
	# schiesst" - vorher haengte _lock_model_to() weiter unten nur am
	# tatsaechlichen Schadens-Tick (do_damage UND hit), der Strahl feuert
	# aber jeden Frame; das Modell blieb zwischen zwei Ticks stehen.
	if target != null:
		_lock_model_to(target)

	_laser_tick_timer -= delta
	var do_damage: bool = _laser_tick_timer <= 0.0
	var dmg: float = laser_damage_per_tick * _damage_multiplier() if do_damage else 0.0
	var dns: PackedScene = (secondary_hitbox.damage_number_scene if secondary_hitbox else null) if do_damage else null

	# EIN Raycast pro Frame bedient beides: Schadenstick (nur wenn faellig)
	# UND die visuelle Strahl-Endposition (jeden Frame, damit der sichtbare
	# Strahl nicht zwischen zwei Ticks am alten Trefferpunkt "klebt").
	var result: Dictionary = Hitscan.fire(self, origin, dir, laser_range, dmg, player, dns)

	if do_damage:
		_laser_tick_timer = laser_tick_interval
		if result["hit"]:
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			# Leichtes Dauer-Rattern statt eines einzelnen Shakes - passt
			# besser zu einem Dauerstrahl als ein einmaliger Ausschlag und
			# macht spuerbar, dass der Strahl laufend Schaden macht statt
			# nur huebsch auszusehen (Rueckmeldung "sieht schwach aus").
			if player and player.has_method("shake_camera"):
				player.shake_camera(0.06)
			if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
				_laser_esp_box.flash()

	if _laser_beam.is_empty():
		var data: CharacterData = PartyManager.get_active_data()
		var color: Color = data.attack_color if data else Color(0.5, 0.9, 1.0)
		# Deutlich dicker als vorher (0.7 -> 1.3) - ein duenner Strahl liest
		# sich als schwacher Laserpointer statt als "Heavy Laser Stream".
		_laser_beam = BeamVisual.create(self, color, 1.3)

	BeamVisual.update(_laser_beam, origin, result["position"], delta)


func _stop_laser() -> void:
	BeamVisual.free_beam(_laser_beam)
	_laser_beam = {}
	_laser_tick_timer = 0.0
	_clear_laser_esp()


## BUGFIX "Strahl sieht aus wie einzelne Kugeln statt wie ein durchgehender
## Strahl (wie bei der Schild-Drohne)": ohne Sticky-Targeting waehlte
## best_target_in_cone() JEDEN Frame neu den "besten" Gegner - stehen mehrere
## nah beieinander, kann das Ergebnis frame-zu-frame kippen, und der
## Strahl-Endpunkt springt zwischen ihnen hin und her statt ruhig auf einem
## Ziel zu stehen. Jetzt wird das aktuelle Ziel gehalten, solange es lebt,
## in Reichweite ist und noch (grosszuegiger als der Such-Kegel, damit es
## nicht direkt an der Kegelgrenze flackert) im Blickfeld liegt - neu gesucht
## wird nur, wenn es wirklich wegfaellt.
func _resolve_laser_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _laser_locked_target != null and is_instance_valid(_laser_locked_target):
		var health: Node = _laser_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_laser_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= laser_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(laser_target_cone_deg * 1.5)
		if alive and in_range and in_cone:
			return _laser_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, laser_range, laser_target_cone_deg)


## Gleiches Muster wie combat_giselle.gd::_update_uzi_esp() - Label3D
## (billboard + no_depth_test) PLUS EnemyEspBox-Kastenumriss ueber dem gerade
## automatisch anvisierten Ziel.
func _update_laser_esp(target: Node3D) -> void:
	if target == _laser_locked_target and target != null and is_instance_valid(target):
		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
			_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)
		return

	_clear_laser_esp()
	_laser_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_laser_esp_marker = _build_laser_esp_marker()
	get_tree().current_scene.add_child(_laser_esp_marker)
	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2

	_laser_esp_box = EnemyEspBox.build_for(target, laser_esp_color)
	get_tree().current_scene.add_child(_laser_esp_box)
	_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)


func _clear_laser_esp() -> void:
	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
		_laser_esp_marker.queue_free()
	_laser_esp_marker = null
	if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
		_laser_esp_box.queue_free()
	_laser_esp_box = null
	_laser_locked_target = null


func _build_laser_esp_marker() -> Label3D:
	var label := Label3D.new()
	label.text = "◆"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 72
	label.outline_size = 14
	label.modulate = laser_esp_color
	label.outline_modulate = Color(laser_esp_color.r * 0.2, laser_esp_color.g * 0.2, laser_esp_color.b * 0.2, 0.9)
	return label


func get_laser_energy_percent() -> float:
	return _laser_energy / laser_max_charge if laser_max_charge > 0.0 else 0.0


## _laser_beam und _laser_esp_marker haengen unter current_scene, nicht unter
## diesem Combat-Node - ueberleben einen Charakterwechsel also nicht
## automatisch (gleicher Grund wie combat_giselle.gd::_exit_tree()).
func _exit_tree() -> void:
	_stop_laser()


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
# _damage_multiplier() und _lock_model_to() leben jetzt in combat_base.gd
# (identisch dupliziert in Giselle/Karina/Winter - siehe dortige Kommentare).
# Weder HomingBolt-Treffer noch Hitscan-Treffer loesen _lock_model_to()
# automatisch aus, da beide nie ueber die Hitbox-Signale laufen - deshalb
# wird es hier weiterhin explizit nachgezogen.

func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3, scale_mul: float = 1.0) -> void:
	var vfx_dir: Vector3 = dir
	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
	var data: CharacterData = PartyManager.get_active_data()
	var vfx: Node3D
	
	if data != null:
		vfx = VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, spawn_pos, data.attack_color, data.attack_color_secondary, vfx_dir)
	else:
		vfx = VFX.spawn(MUZZLE_VFX_SCENE, spawn_pos, vfx_dir)
		
	if vfx != null and scale_mul != 1.0:
		vfx.scale *= scale_mul

```
</details>

### 💭 Thinking: *I'm realizing Winter has two distinct ESP…*

`19:35:22`

<details>
<summary>Thinking...</summary>

> I'm realizing Winter has two distinct ESP subsystems—a plasma primary system that handles multiple ESP boxes per bolt (up to 2 simultaneously for different targets), which might actually be what the user is concerned about rather than a bug. The thought cuts off mid-sentence about whether they want a single unified ESP instead.
> 
> The laser secondary system is single-target with its own ESP markers that should clean up properly when the locked target dies, since it calls `_clear_laser_esp()` when switching targets. But there's a potential edge case where the system might return the same dead enemy object immediately after death, preventing proper cleanup. So the issue is that Health.is_alive() returns false when hp drops to zero, but queue_free() doesn't immediately fire the Health.died signal—it defers the actual cleanup to end of frame. The CLAUDE.md notes that custom enemy need to explicitly call _cleanup_effects() since queue_free() alone won't trigger Health.died. This means the two enemy systems (EnemyAI vs CustomEnemyBase) handle death differently, which could explain why the ESP indicators aren't being cleared properly. Looking at the reported bugs, the first one about multiple ESP indicators on the same enemy when hit repeatedly suggests Winter's Plasma primary is creating new ESP instances each shot instead of reusing or properly managing the existing one. on the same target when primary_cooldown allows firing before old boxes clear. That's the core issue with Winter's rapid fire creating stacked ESP boxes.
> 
> Giselle's Uzi likely has the same problem in her combat script, so I should check that _update_uzi_esp() function for identical behavior. There's also the edge case where ESP boxes don't disappear when enemy die — the plasma bolt's ESP box has a 100ms lifetime timer after the bolt itself expires, but if the enemy gets freed before that timer completes, the is_instance_valid check fails mid-flight when trying to update the box position.
> 
> The real ask though is a complete redesign: the user wants exactly one active ESP indicator at any given time throughout the game, which would eliminate these stacking and cleanup issues entirely.…
</details>

#### 👀 Read `combat_giselle.gd`

`19:35:22`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```

extends CombatBase
class_name CombatGiselle

# Giselle: Ranged/Precision — zielsicherer Fernkampf, gezielte Eliminierung
# von High-Threat-Targets.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind komplett weg - Q und E loesen jetzt
# immer das aktive Item im jeweiligen Slot aus, siehe CombatBase.
#
# Beide Waffen sind Hitscan (scripts/core/hitscan.gd) statt Hitbox-basiert -
# PrimaryHitbox/SecondaryHitbox aus char_giselle.tscn bleiben bewusst
# ungenutzt im Baum (siehe combat_base.gd-Kopfkommentar zu diesem Muster),
# nur ihre bereits im Inspector gesetzten damage_number_scene-Referenzen
# werden noch mitbenutzt, um keine zweite Ressourcen-Zuweisung zu brauchen.

const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_muzzle_flash.tscn")
const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")

## BUGFIX "Muendungsblitz-Partikel fliegen in die Kamera": _spawn_muzzle_vfx()
## bekam bisher die Camera3D-Position selbst als Spawn-Punkt - der Effekt
## sass damit direkt AM Objektiv, und sein 75-Grad-Streuwinkel (siehe
## spark_yellow.tscn) rendert dadurch sichtbar ueber den ganzen Bildschirm
## statt als kleiner Blitz vor dem Lauf. Schiebt den Spawn-Punkt ein Stueck
## in Schussrichtung nach vorn, weg vom Objektiv.
const MUZZLE_FORWARD_OFFSET: float = 0.6

## --- Primary "Uzi Spray" -------------------------------------------------
@export var uzi_magazine_size: int = 40
@export var uzi_reload_time: float = 1.0
@export var uzi_damage: float = 7.0
@export var uzi_range: float = 40.0
## Rework "Auto-Target" (Rueckmeldung: "man sollte nur in die Richtung
## schauen, damit die Uzi die Gegner erkennt und selber drauf schiesst"):
## Blickkegel-Halbwinkel, in dem sich die Uzi selbst ihr Ziel sucht (siehe
## EnemyQuery.best_target_in_cone()) - deutlich weiter als der praezise
## Aim-Assist unten, weil hier kein Zielen mehr noetig sein soll, nur noch
## grobes Hinschauen.
@export var uzi_target_cone_deg: float = 35.0
## Farbe/Groesse des ESP-Markers ueber dem gerade automatisch anvisierten
## Ziel - siehe _build_esp_marker().
@export var uzi_esp_color: Color = Color(1.0, 0.15, 0.1)

## --- Secondary "Sniper Burst" ---------------------------------------------
@export var sniper_shot_count: int = 3
@export var sniper_damage_per_shot: float = 100.0
@export var sniper_range: float = 60.0
## FOV, auf den beim Halten von RMB gezoomt wird - deutlich unter dem
## Kamera-Standard-FOV, simuliert ein Zielfernrohr OHNE die Third-Person-
## Kamera selbst zu verschieben (das macht weiterhin unabhaengig davon das
## bestehende Mausrad-Zoom/SpringArm3D-System aus player_base.gd).
@export var sniper_zoom_fov: float = 28.0
@export var sniper_zoom_in_time: float = 0.5
@export var sniper_zoom_out_time: float = 0.35

## Zusaetzlicher seitlicher Kamera-Versatz waehrend des Sniper-Zooms, ON TOP
## von player_base.gd's staendigem camera_shoulder_offset - der Charakter
## steht beim Reinzoomen sonst mitten im Bild und verdeckt genau das Ziel,
## das man gerade anvisiert. Siehe _start_sniper_charge()/
## _release_sniper_charge() - laeuft als eigener Tween parallel zum FOV-Tween.
@export var sniper_aim_shoulder_offset: float = 1.1

## --- Aim-Assist (Sniper) ----------------------------------------------------
## Nur noch fuer den Sniper: die Uzi hat seit dem Auto-Target-Rework ihr
## eigenes uzi_target_cone_deg (harter Lock statt weichem Assist, siehe oben).
## War 10/0.5 ("soft aim assist"). Rueckmeldung "reicht nicht, Fadenkreuz
## soll viel staerker am Gegner kleben bleiben": Winkel auf 18 Grad und
## strength auf 0.85 angehoben - deutlich klebriger, aber bewusst NICHT 1.0,
## damit ein grob daneben gezielter Schuss noch knapp danebengehen kann statt
## komplett zum Aim-Bot zu werden. Bei Bedarf im Inspector weiter hochdrehen.
@export var aim_assist_angle_deg: float = 18.0
@export var aim_assist_strength: float = 0.85

var _uzi_ammo: int = 40
var _uzi_reloading: bool = false
var _uzi_locked_target: Node3D = null
var _uzi_esp_marker: Label3D = null
var _uzi_esp_box: EnemyEspBox = null

var _sniper_charging: bool = false
var _sniper_locked_target: Node3D = null
var _sniper_esp_box: EnemyEspBox = null
var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null
var _default_fov: float = 75.0
var _fov_tween: Tween = null
## Ausgangswert von _spring_arm.position.x, EINMAL in setup() gelesen -
## player_base.gd hat den Shoulder-Offset zu dem Zeitpunkt schon gesetzt
## (siehe player_base.gd::_ready(), laeuft VOR combat.setup()). Der Sniper-
## Zoom tweent dorthin zurueck statt hart auf 0.0, damit ein evtl. per
## Inspector abweichender Standard-Offset erhalten bleibt.
var _default_shoulder_offset: float = 0.6
var _shoulder_tween: Tween = null


func _init() -> void:
	# War 0.08 - Rueckmeldung "schiesst minimal zu schnell". Leicht angehoben.
	primary_cooldown = 0.1
	secondary_cooldown = 5.0
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_uzi_ammo = uzi_magazine_size
	if _camera:
		_default_fov = _camera.fov
	if _spring_arm:
		_default_shoulder_offset = _spring_arm.position.x


# ============================================================================
# Uzi Spray - haelt Halten von LMB, feuert ueber das UNVERAENDERTE
# _poll_primary_input()/_do_primary() aus combat_base.gd jeden Frame erneut,
# solange der (sehr kurze) primary_cooldown abgelaufen ist.
#
# REWORK "Auto-Target" (Rueckmeldung): frueher ein enger, praeziser Aim-
# Assist auf die reine Kamera-Blickrichtung (5 Grad Kegel, sanft eingeblendet
# per Slerp) - jetzt sucht sich die Uzi selbst den besten Gegner in einem
# breiten Blickkegel (uzi_target_cone_deg) und feuert DIREKT auf ihn, nicht
# mehr auf die rohe Blickrichtung. Ohne Ziel im Kegel faellt sie auf die
# alte reine Blickrichtung zurueck, damit LMB nie komplett ins Leere geht.
# ============================================================================
func _perform_primary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung.
	var look_dir: Vector3 = -_camera.global_transform.basis.z
	var target: Node3D = _resolve_uzi_target(origin, look_dir)
	
	# Wenn kein Gegner im Visier ist, gar nicht erst schießen (Munition sparen)
	if target == null:
		return
		
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized()
	_update_uzi_esp(target)
	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man einen
	# Gegner beschiesst": frueher haengte _lock_model_to() nur am BESTAETIGTEN
	# Treffer (unten im result["hit"]-Zweig) - ein Ziel im Kegel, das die Uzi
	# gerade anvisiert, liess das Modell also stehen, solange der Schuss aus
	# irgendeinem Grund (Deckung, Rand des Kegels) nicht ankam. "Schiesst auf"
	# heisst schon "hat ein Ziel gewaehlt", nicht erst "hat getroffen".
	_lock_model_to(target)

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	
	var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
	_spawn_muzzle_vfx(muzzle_pos, dir)
	_spawn_tracer(muzzle_pos, result["position"], 0.35, 0.06)
	if result["hit"]:
		VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		if player and player.has_method("shake_camera"):
			player.shake_camera(0.18)
		if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
			_uzi_esp_box.flash()

	_uzi_ammo -= 1
	if _uzi_ammo <= 0:
		_uzi_ammo = uzi_magazine_size
		_uzi_reloading = true
		_primary_timer = uzi_reload_time


## Sticky Targeting - gleicher Grund wie combat_winter.gd::
## _resolve_laser_target(): ohne das koennte das gewaehlte Ziel bei mehreren
## nah beieinander stehenden Gegnern von Schuss zu Schuss wechseln.
func _resolve_uzi_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _uzi_locked_target != null and is_instance_valid(_uzi_locked_target):
		var health: Node = _uzi_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_uzi_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= uzi_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(uzi_target_cone_deg * 1.5)
		if alive and in_range and in_cone:
			return _uzi_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, uzi_range, uzi_target_cone_deg)


## Haelt einen Label3D-Marker UND eine EnemyEspBox (Kastenumriss, siehe
## scripts/vfx/enemy_esp_box.gd) ueber dem gerade automatisch anvisierten
## Ziel fest - das ist das in der Rueckmeldung verlangte "ESP" auf den
## beschossenen Gegner. no_depth_test sorgt dafuer, dass der Marker auch
## durch Gegner/Deckung hindurch klar lesbar bleibt, nicht nur durch Waende.
func _update_uzi_esp(target: Node3D) -> void:
	if target == _uzi_locked_target and target != null and is_instance_valid(target):
		if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
			_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
			_uzi_esp_box.global_position = target.global_position + Vector3.UP * (_uzi_esp_box.size.y * 0.5)
		return

	_clear_uzi_esp()
	_uzi_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_uzi_esp_marker = _build_esp_marker()
	get_tree().current_scene.add_child(_uzi_esp_marker)
	_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2

	_uzi_esp_box = EnemyEspBox.build_for(target, uzi_esp_color)
	get_tree().current_scene.add_child(_uzi_esp_box)
	_uzi_esp_box.global_position = target.global_position + Vector3.UP * (_uzi_esp_box.size.y * 0.5)


func _clear_uzi_esp() -> void:
	if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
		_uzi_esp_marker.queue_free()
	_uzi_esp_marker = null
	if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
		_uzi_esp_box.queue_free()
	_uzi_esp_box = null
	_uzi_locked_target = null


func _build_esp_marker() -> Label3D:
	var label := Label3D.new()
	label.text = "◆"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 72
	label.outline_size = 14
	label.modulate = uzi_esp_color
	label.outline_modulate = Color(uzi_esp_color.r * 0.2, uzi_esp_color.g * 0.2, uzi_esp_color.b * 0.2, 0.9)
	return label


## Waehrend des Nachladens gilt der feste Reload-Cooldown statt des
## kombo-reduzierten Basis-Cooldowns - sonst wuerde get_primary_cooldown_
## percent() (HUD-Ring) durch den winzigen primary_cooldown teilen und einen
## Wert weit ueber 1.0 liefern.
func _get_effective_primary_cooldown() -> float:
	if _uzi_reloading:
		return uzi_reload_time
	return super._get_effective_primary_cooldown()


func _process(delta: float) -> void:
	super._process(delta)
	if _uzi_reloading and _primary_timer <= 0.0:
		_uzi_reloading = false
	if _uzi_locked_target != null and not Input.is_action_pressed("attack_primary"):
		_clear_uzi_esp()


func get_uzi_ammo_remaining() -> int:
	return _uzi_ammo


func get_uzi_magazine_size() -> int:
	return uzi_magazine_size


## _uzi_esp_marker/_uzi_esp_box haengen unter current_scene, NICHT unter
## diesem Combat-Node (siehe _build_esp_marker()/_update_uzi_esp()) -
## ueberleben einen Charakterwechsel also nicht automatisch. Explizit
## aufraeumen, sonst bleibt ein verwaister Marker/Kasten in der Szene stehen,
## falls LMB/RMB genau beim Wechsel gehalten wurde.
func _exit_tree() -> void:
	_clear_uzi_esp()
	_clear_sniper_esp()


# ============================================================================
# Sniper Burst - komplett eigenes Press/Hold/Release-Handling statt des
# Standard-"gehalten -> feuert jeden Frame"-Musters: RMB druecken startet
# einen Ladevorgang (Kamera-FOV zoomt), RMB LOSLASSEN loest den eigentlichen
# Schuss aus. Das Feuern selbst laeuft trotzdem ueber das unveraenderte
# _do_secondary() (Cooldown/Signale/Ghost-Trail) - nur der Zeitpunkt des
# Aufrufs wandert von "press" zu "release".
# ============================================================================
func _poll_secondary_input(_delta: float) -> void:
	if _sniper_charging:
		# ESP-Box waehrend des GESAMTEN Ladevorgangs aktuell halten - sticky
		# Targeting (siehe _resolve_sniper_esp_target()) sorgt dafuer, dass
		# sie nicht bei jedem winzigen Maus-Zittern auf einen anderen Gegner
		# umspringt.
		if _camera != null:
			var origin: Vector3 = _camera.global_position
			var look_dir: Vector3 = -_camera.global_transform.basis.z
			_update_sniper_esp(_resolve_sniper_esp_target(origin, look_dir))
		if not Input.is_action_pressed("attack_secondary"):
			_release_sniper_charge()
		return

	if Input.is_action_just_pressed("attack_secondary") and _secondary_timer <= 0.0:
		_start_sniper_charge()


func _start_sniper_charge() -> void:
	if _camera == null:
		return
	_sniper_charging = true
	_kill_fov_tween()
	_fov_tween = _camera.create_tween()
	_fov_tween.tween_property(_camera, "fov", sniper_zoom_fov, sniper_zoom_in_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Schulterblick-Versatz: der Charakter steht sonst mitten im Bild und
	# verdeckt beim Reinzoomen genau das Ziel (Rueckmeldung "Kamera-Shift
	# beim Zielen"). Reine Positions-Verschiebung des SpringArm3D-Ursprungs,
	# KEINE Rotationsaenderung - siehe player_base.gd::camera_shoulder_offset
	# fuer die ausfuehrliche Begruendung, warum das (statt Camera3D.h_offset)
	# den Schuss-Raycast (origin=Kamera-Position, dir=Kamera-Blickrichtung)
	# automatisch treffergenau mitverschiebt, ohne dass hier irgendetwas am
	# Zielsystem angepasst werden muss.
	if _spring_arm:
		_kill_shoulder_tween()
		_shoulder_tween = _spring_arm.create_tween()
		_shoulder_tween.tween_property(_spring_arm, "position:x", sniper_aim_shoulder_offset, sniper_zoom_in_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _release_sniper_charge() -> void:
	_sniper_charging = false
	if _camera:
		_kill_fov_tween()
		_fov_tween = _camera.create_tween()
		_fov_tween.tween_property(_camera, "fov", _default_fov, sniper_zoom_out_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	if _spring_arm:
		_kill_shoulder_tween()
		_shoulder_tween = _spring_arm.create_tween()
		_shoulder_tween.tween_property(_spring_arm, "position:x", _default_shoulder_offset, sniper_zoom_out_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Der Schuss loest erst HIER aus (nicht beim Druecken) - deshalb bleibt
	# der 5s-Cooldown fuer die volle Ladedauer unangetastet und startet
	# tatsaechlich erst beim Loslassen, wie in der Spec verlangt.
	if _secondary_timer <= 0.0:
		_do_secondary()


func _kill_fov_tween() -> void:
	if _fov_tween != null and _fov_tween.is_valid():
		_fov_tween.kill()


func _kill_shoulder_tween() -> void:
	if _shoulder_tween != null and _shoulder_tween.is_valid():
		_shoulder_tween.kill()


## Sticky Targeting fuer die Sniper-ESP-Box waehrend Ladevorgang + Burst -
## gleiches Muster wie _resolve_uzi_target()/combat_winter.gd::
## _resolve_laser_target(). Rein visuell, unabhaengig vom eigentlichen
## Schuss-Aim-Assist (der bleibt der reine Richtungs-Slerp unten in
## _perform_secondary() - EnemyQuery.aim_assisted_direction() feuert immer
## auf den WINKEL-naechsten Kandidaten im Feuermoment, nicht zwingend auf
## dieses gelockte Ziel; beide finden in der Praxis fast immer denselben
## Gegner, weil dieselbe Kegel-/Reichweiten-Logik zugrunde liegt).
func _resolve_sniper_esp_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
		var health: Node = _sniper_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_sniper_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= sniper_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(aim_assist_angle_deg * 1.5)
		if alive and in_range and in_cone:
			return _sniper_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, sniper_range, aim_assist_angle_deg)


func _update_sniper_esp(target: Node3D) -> void:
	if target == _sniper_locked_target and target != null and is_instance_valid(target):
		if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
			_sniper_esp_box.global_position = target.global_position + Vector3.UP * (_sniper_esp_box.size.y * 0.5)
		return

	_clear_sniper_esp()
	_sniper_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_sniper_esp_box = EnemyEspBox.build_for(target, uzi_esp_color)
	get_tree().current_scene.add_child(_sniper_esp_box)
	_sniper_esp_box.global_position = target.global_position + Vector3.UP * (_sniper_esp_box.size.y * 0.5)


func _clear_sniper_esp() -> void:
	if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
		_sniper_esp_box.queue_free()
	_sniper_esp_box = null
	_sniper_locked_target = null


func _perform_secondary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung. Bewusst ueber die Camera3D selbst
	# statt SpringArm3D berechnet, damit hier keine Annahme ueber gleiche
	# Rotation zwischen beiden Nodes mehr noetig ist.
	var dir: Vector3 = EnemyQuery.aim_assisted_direction(
		origin, -_camera.global_transform.basis.z, sniper_range, aim_assist_angle_deg, aim_assist_strength
	)
	var dmg: float = sniper_damage_per_shot * _damage_multiplier()
	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null
	var landed_hit: bool = false

	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man schiesst"
	# - gleicher Grund wie bei der Uzi: nicht erst auf einen bestaetigten
	# Treffer warten. _sniper_locked_target ist bereits waehrend des Ladens
	# (siehe _poll_secondary_input()) ermittelt.
	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
		_lock_model_to(_sniper_locked_target)

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		
		var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
		_spawn_muzzle_vfx(muzzle_pos, dir, 2.5)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(muzzle_pos, result["position"], 0.9, 0.12)
		if result["hit"]:
			landed_hit = true
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			if spark:
				spark.scale *= 2.2
			_lock_model_to(result["target"])
			if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
				_sniper_esp_box.flash()
		if i < sniper_shot_count - 1:
			await get_tree().create_timer(0.03).timeout

	if landed_hit:
		# Kurzer Hit-Stop + kraeftige Kamera-Erschuetterung statt nur Shake -
		# verkauft das Gewicht eines Treffers, der die meisten Gegner sofort
		# toetet, deutlich staerker als reines Wackeln.
		Juice.impact(0.6, Juice.DURATION_HEAVY)

	# Burst ist fertig (RMB feuert nur einmal pro Ladevorgang) - ESP-Box
	# wieder einsammeln, statt sie bis zum naechsten Ladevorgang haengen zu
	# lassen.
	_clear_sniper_esp()


func is_sniper_charging() -> bool:
	return _sniper_charging


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
# _damage_multiplier() und _lock_model_to() leben jetzt in combat_base.gd
# (identisch dupliziert in Giselle/Karina/Winter - siehe dortige Kommentare).
# Hitscan-Treffer loesen _lock_model_to() nicht automatisch aus, da sie NIE
# ueber die Hitbox-Signale laufen (siehe Kopfkommentar oben) - deshalb wird
# es hier weiterhin explizit nachgezogen.


## Sichtbarer Muendungsblitz-bis-Trefferpunkt-Streifen, kurz aufblitzend und
## sofort wieder weg (BeamVisual.create()/update() einmalig statt jeden
## Frame, siehe Winters Dauerstrahl fuer den Unterschied). Vorher hatte
## Giselle GAR KEINE sichtbare Flugbahn - nur Muendungsfunke und Einschlag,
## ohne Verbindung dazwischen wirkten ihre Schuesse kraftlos (Rueckmeldung
## "sieht sehr schwach aus").
func _spawn_tracer(origin: Vector3, endpoint: Vector3, radius_scale: float, life: float) -> void:
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color if data else Color(1.0, 0.85, 0.4)
	var beam: Dictionary = BeamVisual.create(self, color, radius_scale)
	if beam.is_empty():
		return
	BeamVisual.update(beam, origin, endpoint, 0.0)
	get_tree().create_timer(life).timeout.connect(func() -> void:
		BeamVisual.free_beam(beam)
	)


## BUGFIX "Partikel fliegen Richtung Kamera statt zum Ziel": vfx_dir war
## bisher "-dir" (also zurueck zum Schuetzen). vfx_manager.gd::spawn() ist
## eindeutig dokumentiert ("-Z des Effekts zeigt darauf, Godot-Konvention von
## look_at()") - mit "-dir" zeigte das lokale -Z des Muendungsblitzes damit
## RUECKWAERTS zur Kamera und +Z (nicht -Z) nach vorne zum Ziel, also genau
## verkehrt herum. Die alte Begruendung dafuer berief sich auf den
## "+Z ist vorne"-Kommentar in primary_hitbox.gd - der gilt aber nur fuer
## PrimaryHitbox, weil DIESES eine Area3D-Node im .tscn von Hand so gedreht
## wurde, dass sein +Z nach vorne zeigt. Das ist eine Eigenheit dieses einen
## Nodes, keine projektweite Konvention - fuer alles, was per VFX.spawn()
## ausgerichtet wird (wie hier), gilt ausschliesslich die -Z-Regel oben.
## "dir" (unnegiert) ist bereits die reine Schuss-/Blickrichtung, siehe
## Aufrufer - richtig ausgerichtet zeigt das jetzt tatsaechlich zum Ziel.
func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3, scale_mul: float = 1.0) -> void:
	var vfx_dir: Vector3 = dir
	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
	var data: CharacterData = PartyManager.get_active_data()
	var vfx: Node3D
	
	# Da AnimatedSprite3D von vfx_manager.gd (spawn_dual_tinted) nicht gefärbt wird,
	# funktioniert hier spawn() genauso gut für Originalfarben.
	if data != null:
		vfx = VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, spawn_pos, data.attack_color, data.attack_color_secondary, vfx_dir)
	else:
		vfx = VFX.spawn(MUZZLE_VFX_SCENE, spawn_pos, vfx_dir)
		
	if vfx != null and scale_mul != 1.0:
		vfx.scale *= scale_mul

```
</details>

### 💭 Thinking: *Looking at Giselle's code, there are three…*

`19:37:23`

<details>
<summary>Thinking...</summary>

> Looking at Giselle's code, there are three separate ESP subsystems—Uzi and Sniper—each maintaining their own locked target and visual markers. The key insight is that `_update_uzi_esp()` gets called on every shot from `_perform_primary()`, but since it checks if the target matches the already-locked target, it just updates the position rather than spawning duplicate markers, so the repeated hits don't actually create multiple ESP boxes on the same enemy.
> 
> However, if both the Uzi and Sniper systems target the same enemy simultaneously while both are active, you'd see two separate ESP boxes overlapping on that one enemy—one from each subsystem. That actually explains the "mehrfaches ESP" bug quite well. Winter's Plasma system works differently: each shot creates a brand new independent ESP box without deduplication, so if bolts are fired rapidly at the same targets before the previous ones expire (either from hitting or timing out after 3+ seconds), you can accumulate multiple boxes stacking up, especially if bolts miss or the target moves away before impact.
> 
> The core issue is that each weapon subsystem—Uzi ESP, Sniper ESP, Plasma-per-bolt ESP, and Laser ESP—operates in isolation with no awareness of what the other systems are doing. When multiple weapons or rapid shots target the same enemy, you naturally get multiple overlapping indicators, which matches Bug 1 perfectly. Winter's dual-weapon setup (laser on RMB and plasma on LMB usable simultaneously) makes this even worse since both can create ESP boxes on the same target at once.
> 
> For Bug 2 about ESP not disappearing when enemy die, the death handling relies on continuous checks during active attacks—the target resolution functions only run while the player is holding down the attack button and cooldowns allow, so if you're not actively attacking when an enemy dies, the ESP box might linger until the timeout expires. bug is that the ESP box doesn't disappear immediately when the enemy dies—it only gets re-validated on the next shot, so during reload it can linger for up to a second showing a dead target. The sniper's ESP seems better handled since it updates every frame while charging and clears the box right away if the target dies or no new target is found in the cone.
> 
> Winter's laser is actually the most robust of all since the ESP updates every single frame while the RMB is held, so if the locked target dies it immediately searches for a new one and clears the box if nothing's found. The plasma bolts are different though—the ESP box spawns once per shot and lives independently tied to the bolt's homing behavior, so if the enemy dies mid-flight before impact, the homing bolt likely still flies to the last known position or the target reference becomes invalid. The strike callback checks if the target is still valid before applying damage, but the ESP box gets freed regardless, and if the bolt never actually hits (target destroyed, bolt despawns), the safety timer eventually cleans up the box after a few seconds—explaining why the boxes don't always disappear immediately when enemy die. The user's asking for a redesign though, not just a patch.
> 
> They want a single global ESP indicator that jumps to whichever enemy is currently aimed at or being shot, and since they're asking me to show which scripts need changes and provide the actual code, they're expecting me to implement this rather than just theorize about it. Let me map out the implementation plan: I need to locate the tutorial text script, find where the minimap zoom default is set to change it from the current value to 1.60, and identify the HUD cooldown scaling code that needs adjustment.
> 
> For the enemy scale adjustments, I'll need to check the custom enemy base class exports and look at the mortar bot and acid sprinkler scripts to see where their scale values are defined. The ESP rework is the most complex piece—I'm thinking of creating a shared singleton or static helper class similar to the existing EnemyQuery system that can manage a single global ESP target that updates based on what's being aimed at or shot. wins" logic means whichever weapon fires or updates last that frame claims the indicator, which naturally prioritizes the player's current active aim since they're actively controlling one weapon at a time.
> 
> I also need to redirect the flash calls so they only trigger when that specific target is currently being displayed by the ESP box. Now I'm setting up the new autoload singleton that will manage a single ESP indicator box and label in the world, independent of how many weapons or character are trying to target simultaneously.
> 
> Defining the core properties and the acquire method... Continuing the _process loop to reposition every frame. I'm realizing this should be an autoload singleton so callers just invoke `acquire()` and `flash()` without manual cleanup—the global _process handles death checks automatically each frame, which elegantly solves the target-death bug. But I need to figure out how ESP releases when the player stops aiming, since the current local systems explicitly clear on input release. Plasma fires intermittently every 0.4 seconds with one acquire call per shot, while Laser continuously acquires every frame (~60 times per second), so Laser's frequent targeting calls would override Plasma's target immediately after each shot—which makes sense since Laser represents continuous aiming while Plasma is just momentary bursts. Since there's only ever one targeting box and marker instance, the duplicate ESP bug is completely resolved structurally.
> 
> Bug 2 (indicator not disappearing on death) is fixed by the global death-check running every frame regardless of which weapon triggered it. Winter's plasma can target up to 2 enemy simultaneously, but under the new singular design only the primary target (nearest enemy, which _lock_model_to also uses) gets the indicator—fully matching the request to simplify to one indicator. Now I need to route the flash() calls from plasma strikes, laser ticks, uzi hits, and sniper hits through EspTarget.flash() but only if that target is still current, since Plasma previously created per-bolt boxes that now need consolidating.
> 
> The key is calling EspTarget.acquire() only for the primary target (targets[0]) when firing each bolt, not all targets, so there's exactly one ESP indicator that matches what the model-lock is tracking. Then on strike callbacks, flash() gets routed through EspTarget.flash(target), which safely no-ops for non-primary targets since it checks if target equals the current global target.
> 
> Now I'm mapping out the concrete file changes: creating a new autoload singleton for the ESP system, registering it in project.godot, then refactoring combat_winter.gd to remove the local ESP marker and box creation logic and replace it with calls to the autoload, making sure to only acquire for the primary target.
> 
> In _update_laser(), I'll swap the old ESP update call with the autoload's acquire/release methods, keeping _laser_locked_target around since it's still needed for the sticky-targeting logic independent of the visual indicator.
> 
> Refactoring the ESP-specific functions... Simplifying the function to just update the locked target and manage the ESP acquisition, since the sticky-target repositioning logic is now redundant with how EspTarget handles deduplication internally.
> 
> Now I'm collapsing `_stop_laser()` to directly release the ESP target and clean up the beam and timer state in one place, removing the separate `_clear_laser_esp()` helper entirely.
> 
> For the laser flash effect, I'm replacing the local `_laser_esp_box` check with a direct call to `EspTarget.flash()` on the resolved target from the current frame.
> 
> For the plasma primary loop, I'm shifting to only acquire ESP for the primary target (the closest one used for locking), while still calling `EspTarget.flash()` for any target hit by a strike regardless of whether it's the primary.
> 
> Refactoring _perform_primary()... Finishing the HomingBolt spawn call with the remaining parameters and attaching the plasma trail effect. Then I'm simplifying the _on_plasma_strike function to remove the esp_box parameter since we're no longer managing per-bolt ESP instances, which eliminates the need for that safety-net timer. This streamlines Winter's combat script and consolidates the visual feedback to a single indicator. Next I need to apply a similar refactor to Giselle's combat script for the Uzi weapon.
> 
> Now I'm removing the redundant ESP marker and box variables for Uzi and Sniper, keeping only the locked target references since those are still needed for sticky resolution and model locking. I'm replacing the old ESP management with simpler acquire and release calls that delegate to the centralized EspTarget system.
> 
> For the Uzi hit flash, I'm switching from directly calling the box's flash method to using the EspTarget flash function instead. The process and exit tree functions stay as-is since they already work with the new setup.
> 
> Setting up the Sniper ESP update function... ESP target was being cleared unconditionally, but that's problematic when multiple weapons share the same ESP system — if the Uzi loses its target, calling a global release would wipe out an active indicator from a different weapon like the Laser. I need to make the release conditional, only clearing the ESP if it's currently showing the target that's being released. So when Uzi loses its target, I need to release the ESP using the *previous* locked target before clearing it—calling `release()` with the old target ensures we only clear the global ESP if that weapon actually owns it, leaving other weapons' locks untouched. I'm restructuring the update function to capture the old target, release it if it exists, then set the new target. Writing the autoload script... Der release()-Aufruf räumt den Indikator nur auf, wenn das freigegebene Ziel noch der aktuelle ist, um zu verhindern, dass ein Waffensystem versehentlich den Indikator eines anderen Systems entfernt. In jedem Frame prüft _process() die Lebendigkeit des aktuellen Ziels, unabhängig davon, wie oft gerade geschossen wird.
> 
> Das ist der eigentliche Bugfix für das Problem, dass der ESP-Indikator nicht immer beim Tod verschwindet – vorher hing die Aktualisierung an den Schuss- und Halte-Events der Waffe, jetzt läuft sie global und kontinuierlich. Ich definiere die Variablen für das Ziel, den Marker und die ESP-Box, und die acquire()-Funktion prüft zunächst, ob das Ziel gültig und noch am Leben ist, bevor sie den alten Zustand löscht und die neuen Elemente initialisiert.
> 
> Continuing with the method implementations... Finishing the cleanup function to properly free the marker and box nodes, then nullifying the references. I'm also creating a helper function that builds a 3D label marker with a diamond symbol, customizing its appearance with font size, outline, and color modulation. Now reconsidering the acquire logic...
> 
> When the color changes but the target stays the same, we don't rebuild the marker, which aligns with the original per-weapon behavior. I should also verify that the EnemyEspBox and Health classes are properly resolvable as global class names, which they should be. Next I need to register this as an autoload in the project settings, choosing a name like "EspTarget" that won't collide with existing entries.…
</details>

#### 🔎 Grep `esp|Esp|ESP` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd`

`19:37:24`

```
67:## Nerf: bisher unausgesprochen Bomb.damage's Default (50) - jetzt explizit
```

### 💭 Thinking: *Karina doesn…*

`19:37:29`

<details>
<summary>Thinking...</summary>

> Karina doesn…
</details>

#### 🔎 Grep `Tutorial|tutorial` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:37:29`

```
Found 10 files
scripts\tutorial_flow.gd
scripts\tutorial_content.gd
scripts\ui\tutorial_character_intro.gd
scripts\party_manager.gd
scripts\main_menu.gd
scripts\debug_teleporter.gd
scripts\character_pedestal.gd
scripts\treasure_manager.gd
scripts\vfx\torch.gd
scripts\spawn_tutorial_hologram.gd
```

#### 👀 Read `tutorial_content.gd`

`19:37:32`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
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

const NINGNING_DESCRIPTION: String = "Ningning: Close-Range-Kämpferin (Schläge & Explosionen)."
const GISELLE_DESCRIPTION: String = "Giselle: 2 Waffen mit Auto-Aim."
const KARINA_DESCRIPTION: String = "Karina kämpft im Nahkampf mit ätzender Säure und wird kurz unsichtbar, um mehrere Gegner zu markieren und gleichzeitig per Explosion zu richten."
const WINTER_DESCRIPTION: String = "Winter kontrolliert die Distanz mit homing Plasma-Geschossen und einem Dauer-Laserstrahl."

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
static func fixed_enemies_for(index: int) -> Array[Callable]:
	match index:
		0: # Fight1: nur Fighter und Scouts
			return [_fighter_factory(), _scout_factory(), _scout_factory()]
		2: # Fight2: Moerser, Saeure-Sprinkler, Diver
			return [_mortar_factory(), _acid_sprinkler_factory(), _dive_bomber_factory()]
		4: # Fight3: Scouts und Shield
			return [_scout_factory(), _scout_factory(), _shield_drone_factory()]
		6: # Fight4: Plasma Shooter und 2 Fighter
			return [_plasma_beam_bot_factory(), _fighter_factory(), _fighter_factory()]
		8: # Final Fight: Mix aus allen zuvor gezeigten Gegnern
			return [_fighter_factory(), _scout_factory(), _shield_drone_factory(), _plasma_beam_bot_factory()]
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


## UI-Beschreibungstext fuer einen soeben freigeschalteten Charakter -
## anhand character_id statt Objekt-Identitaet, robust gegen dupliziert
## geladene Ressourcen.
static func description_for(data: CharacterData) -> String:
	if data == null:
		return ""
	match String(data.character_id):
		"giselle":
			return GISELLE_DESCRIPTION
		"karina":
			return KARINA_DESCRIPTION
		"winter":
			return WINTER_DESCRIPTION
		_:
			return data.description


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

```
</details>

### 💭 Thinking

`19:37:35`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `RMB|LMB|Rechte Maustaste|Linke Maustaste|Dash|dash` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:37:36`

```
Found 22 files
scripts\items\item_behaviours.gd
scripts\characters\combat_winter.gd
scripts\vfx\animated_fire_ningning.gd
scripts\combat_base.gd
scripts\player_base.gd
scripts\characters\combat_karina.gd
scripts\characters\combat_giselle.gd
scripts\health.gd
scripts\enemies\mortar_bot.gd
scripts\items\item_catalog.gd
scripts\core\enemy_query.gd
scripts\enemies\dive_bomber.gd
scripts\hud.gd
scripts\environment\destructible_prop.gd
scripts\core\player_stats.gd
scripts\ui\damage_number.gd
scripts\vfx\ghost_trail.gd
scripts\settings_manager.gd
scripts\run_record.gd
scripts\room_commit_guard.gd
scripts\character_data.gd
scripts\bomb_carrier.gd
```

### 💭 Thinking

`19:37:39`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `tutorial_flow.gd`

`19:37:40`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_flow.gd</code></summary>

```
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

```
</details>

### 💭 Thinking

`19:37:43`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `WASD|Steuerung|Bewege dich|Springe|Zielen mit|Interagiere` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`19:37:44`

Glob: `**/*.gd`

```
Found 6 files
scripts\combat_base.gd
scripts\pause_menu.gd
scripts\spawn_tutorial_hologram.gd
scripts\settings_manager.gd
scripts\room_commit_guard.gd
scenes\settings_menu.gd
```

#### 👀 Read `spawn_tutorial_hologram.gd`

`19:37:47`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\spawn_tutorial_hologram.gd</code></summary>

```
@tool
extends Node3D
class_name SpawnTutorialHologram

# ============================================================================
# SpawnTutorialHologram — grosses Hologramm-Schild am Spieler-Spawn, das ein
# fertiges Tutorial-Bild zeigt und sich immer zum Spieler dreht.
# ============================================================================
#
# BENUTZUNG
# ---------
# Als Kind in die Startraum-Szene haengen (res://scenes/rooms/room_start_01.tscn),
# Node-Typ Node3D, dieses Script drauf, dann im Inspector nur
# tutorial_texture zuweisen. Die Position sucht sich das Hologramm selbst:
# es stellt sich VOR den PlayerSpawnPoint desselben Raums, in dessen
# Blickrichtung.
#
# WARUM ES SICH SELBST POSITIONIERT
# ---------------------------------
# Ein von Hand gesetzter Abstand waere genau einmal richtig. Der Spawnpunkt
# kann verschoben werden, die Raumgroesse aendert sich ueber room_scale im
# LevelGenerator, und der Startraum koennte spaeter ein zweiter werden. Der
# Abstand wird deshalb IMMER relativ zum Marker gerechnet - dann stimmt er
# auch nach jeder dieser Aenderungen noch.
#
# ############################################################################
# WO IST "VORNE"? NICHT RATEN - VON DER KAMERA HOLEN
# ############################################################################
# Dieser Punkt hat mehr Fallstricke, als er verdient. Im Projekt gibt es
# ZWEI verschiedene "vorne", und sie zeigen in entgegengesetzte Richtungen:
#
#   1. Das MODELL faced +Z. Deshalb steht in player_base.gd und enemy_ai.gd
#      ueberall mesh.rotation.y = atan2(dir.x, dir.z) - diese Formel dreht
#      die lokale +Z-Achse auf die Bewegungsrichtung.
#
#   2. Die KAMERA/Bewegung faced -Z. In player_base.gd:
#          var forward := camera_pivot.global_transform.basis.z
#          direction   := forward * input_dir.y
#      Input.get_vector() liefert fuer "ui_up" (W) input_dir.y = -1, das
#      Produkt zeigt also entlang -Z. Passend dazu sitzen SecondaryHitbox
#      (z = -0.64) und PrimaryHitbox (z = -2.99) beide auf der -Z-Seite:
#      dorthin schlaegt der Charakter, dorthin schaut man.
#
# Ein Schild entlang +Z zu setzen (die "Modell-Vorne"-Achse) landet damit
# GENAU HINTER dem Spieler - und weil die Kamera hinter ihm haengt, sogar
# hinter der Kamera. Man sieht es beim Start nie.
#
# Statt sich fuer eine der beiden Konventionen zu entscheiden, fragt der
# Standardmodus (Placement.CAMERA_VIEW) einfach die echte Kamera, sobald
# der Spieler existiert. Das ist immun gegen jede kuenftige Aenderung an
# Achsen, Spawn-Yaw oder Kamera-Rig - und beantwortet exakt die Frage, um
# die es geht: "was sieht der Spieler im ersten Frame?"
#
# ############################################################################
# EINHEITEN SIND LOKAL, NICHT WELT
# ############################################################################
# Der LevelGenerator instanziiert Raeume mit einer skalierten Basis
# (room_scale, aktuell 2x). Alles, was hier als Abstand oder Groesse steht,
# wird davon mitskaliert: distance = 5.0 sind bei room_scale = 2 also 10
# Meter in der Welt. Das ist gewollt - so bleibt das Verhaeltnis von
# Schildgroesse zu Raumgroesse konstant, egal wie gross die Raeume noch
# werden.
#
# ############################################################################
# WARUM Sprite3D UND KEIN QuadMesh MIT MATERIAL
# ############################################################################
# Sprite3D bringt Billboard, Texturfilter, Alpha-Modus und pixel_size fertig
# mit und braucht kein eigenes Material-Setup. Fuer ein Bild, das immer zur
# Kamera zeigt, ist das genau das richtige Werkzeug. Die Rueckplatte
# darunter ist dagegen ein QuadMesh - die braucht kein Bild, nur eine
# Flaeche in Hologrammfarbe.

## Das fertige Tutorial-Bild. PSX-Look: im Import-Dialog "Filter" aus und
## "Mipmaps" aus, sonst matscht die Schrift bei Entfernung weg.
@export var tutorial_texture: Texture2D:
	set(value):
		tutorial_texture = value
		_rebuild_deferred()

## Breite des Schildes in LOKALEN Einheiten (siehe Einheiten-Block oben).
## Die Hoehe ergibt sich aus dem Seitenverhaeltnis der Textur - ein
## getrennter Hoehenwert koennte das Bild nur verzerren.
@export var board_width: float = 9.0:
	set(value):
		board_width = maxf(value, 0.1)
		_rebuild_deferred()

## Wie die Richtung bestimmt wird, in die das Schild gesetzt wird.
##
##   CAMERA_VIEW    Blickrichtung der echten Spielerkamera im ersten Frame.
##                  Standard - siehe Block im Dateikopf.
##   SPAWN_VIEW_Z   Statisch entlang -Z des Spawn-Markers. Das ist bei
##                  Yaw 0 dieselbe Richtung, nur ohne auf den Spieler zu
##                  warten. Fuer Testszenen ohne PartyManager.
##   SPAWN_BACK_Z   Statisch entlang +Z, also HINTER den Spieler. Nur
##                  sinnvoll, wenn man das Schild bewusst erst beim
##                  Umdrehen zeigen will.
enum Placement {
	CAMERA_VIEW,
	SPAWN_VIEW_Z,
	SPAWN_BACK_Z,
}

@export var placement: Placement = Placement.CAMERA_VIEW:
	set(value):
		placement = value
		_reposition()

## Abstand vom Spawnpunkt in der gewaehlten Richtung. Negative Werte
## drehen die Richtung um.
@export var distance: float = 6.0:
	set(value):
		distance = value
		_reposition()

## Hoehe der SCHILDMITTE, gemessen VOM SPAWNPUNKT AUS (nicht von der
## Weltnull). Negative Werte sind erlaubt und haengen das Schild tiefer.
##
## 3.0 lokale Einheiten sind bei room_scale = 2 sechs Meter ueber dem
## Spawnpunkt - das Schild steht damit gross im Bild, ohne den Blick auf
## die Tueren zu verstellen.
@export var height: float = 3.0:
	set(value):
		height = value
		_reposition()

## Wie viele Frames auf die Spieler-Instanz gewartet wird, bevor
## CAMERA_VIEW auf SPAWN_VIEW_Z zurueckfaellt.
##
## Der Spieler entsteht nicht im selben Frame wie der Raum: PartySetup,
## PlayerSpawnPoint und PartyManager._spawn_active_character() haengen
## ueber mehrere call_deferred()-Stufen hintereinander. Ein einzelnes
## await process_frame reicht dafuer nicht zuverlaessig.
@export var camera_wait_frames: int = 30

## Wenn true, dreht sich das Schild um die Y-Achse immer zur Kamera.
## Ausschalten, wenn es fest in eine Richtung zeigen soll.
@export var face_player: bool = true:
	set(value):
		face_player = value
		_rebuild_deferred()

## --- Optik ------------------------------------------------------------
## Faerbung des Bildes. Weiss = Bild unveraendert. Ein leichter Cyan-Stich
## laesst es nach Hologramm aussehen, ohne die Lesbarkeit zu kosten.
@export var tint: Color = Color(0.72, 0.94, 1.0)
@export_range(0.0, 1.0) var opacity: float = 0.92

## Rueckplatte hinter dem Bild. Ohne sie steht helle Schrift auf hellem
## Hintergrund praktisch unlesbar im Raum.
@export var backdrop_enabled: bool = true
@export var backdrop_color: Color = Color(0.03, 0.09, 0.13, 0.55)
## Wie weit die Platte ueber das Bild hinausragt (Anteil der Bildbreite).
@export_range(0.0, 0.5) var backdrop_padding: float = 0.06

## Bodenprojektor: schmaler Lichtkegel vom Boden zum Schild. Erklaert, WOHER
## das Hologramm kommt - ohne ihn schwebt einfach ein Bild in der Luft.
##
## ##########################################################################
## FIX: "der Kegel steckt IM Bild statt darunter"
## ##########################################################################
## Der Kegel lief vom Spawnpunkt (lokal y = 0) bis y = height - und height
## ist die MITTE des Schildes, nicht dessen Unterkante. Die obere Haelfte
## des Kegels steckte damit zwangslaeufig im Bild.
##
## Rechenbeispiel mit den Standardwerten (board_width = 9, Bild im
## Verhaeltnis 16:9 -> aspect 0.5625):
##     Schildhoehe        = 9 * 0.5625      = 5.06
##     halbe Schildhoehe                    = 2.53
##     Schild reicht von y = 3 - 2.53 = 0.47  bis  y = 3 + 2.53 = 5.53
##     Kegel reichte bis y = 3
## Der Kegel endete also 2,53 Einheiten INNERHALB des Bildes - und weil er
## additiv gemischt ist, hat er die untere Bildhaelfte zusaetzlich
## aufgehellt.
##
## Jetzt endet er an der UNTERKANTE des Schildes (inklusive der Rueckplatte
## und projector_gap Abstand). Die Rechnung dafuer steht in
## _board_half_height() und _projector_top_y().
@export var projector_enabled: bool = true
@export var projector_color: Color = Color(0.35, 0.85, 1.0, 0.18)

## Luft zwischen Kegelspitze und Schildunterkante. 0 = der Kegel beruehrt
## das Schild genau.
@export var projector_gap: float = 0.25

## Radius der Kegelspitze (oben, am Schild) als Anteil der Schildbreite.
@export_range(0.0, 1.0) var projector_top_ratio: float = 0.30

## Radius am Boden, in lokalen Einheiten.
@export var projector_bottom_radius: float = 0.25

## Feinverschiebung des Kegels, falls er nicht mittig unter dem Schild
## sitzen soll. Wird AUF die berechnete Position addiert.
@export var projector_offset: Vector3 = Vector3.ZERO

## --- Bewegung ---------------------------------------------------------
@export var bob_enabled: bool = true
@export var bob_height: float = 0.4
@export var bob_speed: float = 1.2

## Flackern. Bewusst dezent: ein Schild, das man lesen soll, darf nicht
## staendig verschwinden.
@export var flicker_enabled: bool = true
@export_range(0.0, 0.5) var flicker_amount: float = 0.08
@export var flicker_speed: float = 9.0

## --- Sichtbarkeit -----------------------------------------------------
## Ab dieser Entfernung (lokale Einheiten) blendet das Schild aus. 0 = nie
## ausblenden.
##
## Der Sinn: das Tutorial soll beim Start da sein, aber nicht den halben
## Raum verdecken, wenn man zurueckkommt. Ausblenden ueber die Entfernung
## statt ueber einen Timer, weil ein Timer bei jemandem, der die Steuerung
## zum ersten Mal liest, zwangslaeufig zu frueh ablaeuft.
@export var fade_out_distance: float = 26.0
@export var fade_in_distance: float = 22.0
@export var fade_duration: float = 0.4

@export var debug_logging: bool = false

## --- Interaktion: Vollbild zum Lesen -----------------------------------
## Analog zum Minimap-Zoom (minimap.gd: TAB/M oeffnet eine groessere,
## besser lesbare Ansicht derselben Karte) - dieselbe Idee hier: [interact]
## in der Naehe zeigt tutorial_texture gross als 2D-Bild auf dem Bildschirm
## (siehe _build_view_overlay()), ein zweites Mal (oder Weggehen) schliesst
## es wieder.
@export var interact_zoom_enabled: bool = true
## Abstand in LOKALEN Einheiten, ab dem der Interaktions-Hinweis erscheint.
@export var interact_range: float = 4.0
@export var interact_zoom_duration: float = 0.3

const PLAYER_GROUP: String = "player"

var _board: Sprite3D = null
var _backdrop: MeshInstance3D = null
var _backdrop_material: StandardMaterial3D = null
var _projector: MeshInstance3D = null
var _projector_material: StandardMaterial3D = null

var _pivot: Node3D = null
var _base_y: float = 0.0
var _time: float = 0.0
var _visible_target: float = 1.0
var _current_fade: float = 1.0
var _rebuild_queued: bool = false

## --- Interaktions-Zustand ----------------------------------------------
var _interact_prompt: Label3D = null
var _zoomed: bool = false
var _player_in_interact_range: bool = false

## --- Vollbild-Ansicht ---------------------------------------------------
## BUGFIX "Interagieren vergroessert nur das 3D-Schild": ein 1.7x skaliertes
## Sprite3D im Raum ist bei einem textlastigen Tutorial-Bild immer noch kaum
## lesbar. Statt das Objekt zu skalieren, zeigt [interact] jetzt dasselbe
## tutorial_texture gross als 2D-Bild auf dem Bildschirm - ein eigener,
## code-gebauter CanvasLayer ueber allem anderen (gleiche Bauweise wie
## victory_trophy.gd/turret.gd: kein Szenen-Asset noetig).
var _view_layer: CanvasLayer = null
var _view_backdrop: ColorRect = null
var _view_image: TextureRect = null
var _view_hint: Label = null
var _view_tween: Tween = null


func _debug(msg: String) -> void:
	if debug_logging:
		print("[SpawnHologram] %s" % msg)


func _ready() -> void:
	_build()

	if Engine.is_editor_hint():
		_reposition()
		return

	# Eine Frame warten: der LevelGenerator setzt die Weltposition des
	# Raums erst NACH add_child(). Genau dieselbe Begruendung wie in
	# player_spawn_point.gd und room_commit_guard.gd.
	await get_tree().process_frame
	if not is_inside_tree():
		return

	# Erste, vorlaeufige Platzierung ueber den Marker - damit das Schild
	# schon steht, falls der Spieler laenger braucht.
	_reposition()

	if placement == Placement.CAMERA_VIEW:
		await _wait_for_player()
		if not is_inside_tree():
			return
		_reposition()


## Wartet, bis PartyManager eine Spieler-Instanz mit Kamera gebaut hat.
func _wait_for_player() -> void:
	var frames: int = 0
	while frames < maxi(camera_wait_frames, 1):
		if _find_camera_pivot() != null:
			return
		await get_tree().process_frame
		if not is_inside_tree():
			return
		frames += 1
	_debug("Nach %d Frames keine Spielerkamera gefunden - Fallback auf SPAWN_VIEW_Z." % camera_wait_frames)


# ============================================================================
# Aufbau
# ============================================================================
## Sammelt mehrere Aenderungen aus dem Inspector zu EINEM Neuaufbau. Ohne
## das wuerde jeder einzelne Tastendruck in einem Zahlenfeld die komplette
## Geometrie neu erzeugen.
func _rebuild_deferred() -> void:
	if _rebuild_queued or not is_inside_tree():
		return
	_rebuild_queued = true
	_do_rebuild.call_deferred()


func _do_rebuild() -> void:
	_rebuild_queued = false
	_build()
	_reposition()


func _build() -> void:
	_clear()

	_pivot = Node3D.new()
	_pivot.name = "HologramPivot"
	add_child(_pivot)

	_build_backdrop()
	_build_board()
	_build_projector()
	_build_interact_prompt()
	_build_view_overlay()

	_base_y = _pivot.position.y
	_zoomed = false


## remove_child() VOR queue_free(): queue_free() raeumt erst am Frame-Ende
## auf. Ohne das vorherige Aushaengen laege der alte Aufbau beim Neubau
## noch im Baum, Godot wuerde den neuen Nodes Namen wie
## "HologramPivot2" geben, und _pivot zeigte auf etwas anderes als das,
## was der Editor anzeigt.
func _clear() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_pivot = null
	_board = null
	_backdrop = null
	_backdrop_material = null
	_projector = null
	_projector_material = null
	_interact_prompt = null
	if _view_tween != null and _view_tween.is_valid():
		_view_tween.kill()
	_view_tween = null
	_view_layer = null
	_view_backdrop = null
	_view_image = null
	_view_hint = null


func _build_board() -> void:
	if tutorial_texture == null:
		_debug("Keine tutorial_texture gesetzt - es wird nur die Ruecklatte gebaut.")
		return

	_board = Sprite3D.new()
	_board.name = "TutorialBoard"
	_board.texture = tutorial_texture

	# pixel_size aus der gewuenschten Breite ableiten statt einen festen
	# Wert zu setzen: sonst haengt die Schildgroesse an der Aufloesung des
	# Bildes, und ein Austausch der Textur gegen eine groessere wuerde das
	# Schild ploetzlich ueber den halben Raum spannen.
	var tex_width: int = maxi(tutorial_texture.get_width(), 1)
	_board.pixel_size = board_width / float(tex_width)

	_board.shaded = false
	_board.double_sided = true
	_board.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_board.transparent = true
	# ALPHA_CUT_DISABLED: bei einem Tutorial-Bild mit weichen Kanten oder
	# halbtransparentem Hintergrund wuerde ALPHA_CUT_DISCARD harte,
	# ausgefranste Raender erzeugen.
	_board.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	_board.modulate = Color(tint.r, tint.g, tint.b, opacity)

	if face_player:
		# FIXED_Y: dreht sich nur um die Hochachse. BILLBOARD_ENABLED
		# wuerde das Schild auch kippen, sobald der Spieler naeher kommt
		# und die Kamera nach unten schaut - dann steht das Tutorial
		# schraeg im Bild.
		_board.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y

	_pivot.add_child(_board)


func _build_backdrop() -> void:
	if not backdrop_enabled:
		return

	var pad: float = board_width * backdrop_padding
	var quad := QuadMesh.new()
	quad.size = Vector2(board_width + pad * 2.0, _board_image_height() + pad * 2.0)

	_backdrop_material = StandardMaterial3D.new()
	_backdrop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_backdrop_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_backdrop_material.albedo_color = backdrop_color
	_backdrop_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_backdrop_material.disable_receive_shadows = true
	if face_player:
		_backdrop_material.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		# Ohne keep_scale schrumpft ein Billboard-Quad auf Einheitsgroesse.
		_backdrop_material.billboard_keep_scale = true

	_backdrop = MeshInstance3D.new()
	_backdrop.name = "Backdrop"
	_backdrop.mesh = quad
	_backdrop.material_override = _backdrop_material
	_backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Minimal nach hinten, damit die Platte nicht mit dem Bild um dieselben
	# Tiefenwerte kaempft (Z-Fighting).
	_backdrop.position.z = -0.02
	_pivot.add_child(_backdrop)


## Hoehe des BILDES selbst in lokalen Einheiten, abgeleitet aus dem
## Seitenverhaeltnis der Textur.
##
## Eine Stelle fuer beide Verbraucher (Rueckplatte und Projektor): stuende
## die Rechnung zweimal im Code, koennten die beiden nach einer Aenderung
## unterschiedlich gross sein - und genau daraus entsteht ein Kegel, der
## nicht mehr zum Schild passt.
func _board_image_height() -> float:
	var aspect: float = 0.6
	if tutorial_texture != null and tutorial_texture.get_width() > 0:
		aspect = float(tutorial_texture.get_height()) / float(tutorial_texture.get_width())
	return board_width * aspect


## Halbe Hoehe des SICHTBAREN Schildes - also inklusive der Rueckplatte,
## denn die ragt ueber das Bild hinaus und ist das, was man als Unterkante
## wahrnimmt.
func _board_half_height() -> float:
	var total: float = _board_image_height()
	if backdrop_enabled:
		total += board_width * backdrop_padding * 2.0
	return total * 0.5


## Y-Koordinate, an der der Kegel endet: die dem Spawnpunkt ZUGEWANDTE
## Kante des Schildes, minus projector_gap.
##
## Bei positivem height ist das die Unterkante, bei negativem height die
## Oberkante - der Kegel zeigt dann nach unten. Deshalb wird mit dem
## Vorzeichen gerechnet und nicht einfach subtrahiert.
func _projector_top_y() -> float:
	var half: float = _board_half_height()
	var gap: float = maxf(projector_gap, 0.0)
	if height >= 0.0:
		return maxf(height - half - gap, 0.0)
	return minf(height + half + gap, 0.0)


## Schmaler Lichtkegel vom Boden bis UNTER das Schild.
##
## Sitzt bewusst NICHT im _pivot: der wippt (bob), und ein Lichtkegel, der
## mitwippt, loest sich sichtbar vom Boden.
func _build_projector() -> void:
	if not projector_enabled:
		return

	var top_y: float = _projector_top_y()
	var span: float = absf(top_y)

	# Zu kurz zum Zeichnen: das passiert, wenn das Schild so gross ist,
	# dass seine Unterkante schon fast auf dem Boden liegt. Ein Kegel von
	# wenigen Zentimetern waere dann nur ein Fleck am Spawnpunkt.
	if span < 0.15:
		_debug("Schildunterkante liegt fast auf Spawnhoehe - Projektor entfaellt.")
		return

	var cone := CylinderMesh.new()
	cone.height = span
	cone.radial_segments = 12
	cone.rings = 1

	var wide: float = board_width * projector_top_ratio
	var narrow: float = maxf(projector_bottom_radius, 0.01)

	# Die breite Seite gehoert IMMER ans Schild, die schmale an den
	# Spawnpunkt. Bei negativem height liegt das Schild unten, also
	# tauschen.
	if height >= 0.0:
		cone.top_radius = wide
		cone.bottom_radius = narrow
	else:
		cone.top_radius = narrow
		cone.bottom_radius = wide

	_projector_material = StandardMaterial3D.new()
	_projector_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_projector_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_projector_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_projector_material.albedo_color = projector_color
	_projector_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_projector_material.disable_receive_shadows = true
	# Ohne das schiebt sich der additive Kegel vor das Bild, sobald man
	# schraeg davorsteht: er wuerde die Schrift ueberstrahlen. Mit
	# no_depth_test = false und deaktiviertem Tiefenschreiben sortiert er
	# sich korrekt hinter undurchsichtige Geometrie ein, ohne selbst
	# andere transparente Flaechen zu verdecken.
	_projector_material.no_depth_test = false

	_projector = MeshInstance3D.new()
	_projector.name = "Projector"
	_projector.mesh = cone
	_projector.material_override = _projector_material
	_projector.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Der Kegel ist um seinen Mittelpunkt gebaut: er soll die Strecke von
	# y = 0 (Spawnpunkt) bis y = top_y (Schildunterkante) fuellen, sein
	# Mittelpunkt liegt also auf halber Strecke. Vorher stand hier
	# height * 0.5 - und height ist die Schildmitte, nicht die Unterkante.
	_projector.position = Vector3(0.0, top_y * 0.5, 0.0) + projector_offset
	add_child(_projector)


## Kleiner Hinweis unter dem Schild, nur sichtbar wenn der Spieler nah genug
## steht - siehe _update_interact() weiter unten.
func _build_interact_prompt() -> void:
	if not interact_zoom_enabled or _pivot == null:
		return
	_interact_prompt = Label3D.new()
	_interact_prompt.name = "InteractPrompt"
	_interact_prompt.text = "[F] Vergroessern"
	_interact_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_interact_prompt.no_depth_test = true
	_interact_prompt.font_size = 40
	_interact_prompt.pixel_size = 0.008
	_interact_prompt.outline_size = 10
	_interact_prompt.modulate = Color(0.72, 0.94, 1.0, 0.9)
	_interact_prompt.position = Vector3(0.0, -_board_half_height() - 0.4, 0.0)
	_interact_prompt.visible = false
	_pivot.add_child(_interact_prompt)


# ============================================================================
# Platzierung
# ============================================================================
## Stellt das Hologramm vor den PlayerSpawnPoint des eigenen Raums.
##
## Der Marker wird im GESCHWISTERBEREICH gesucht, nicht global: in einem
## generierten Level koennen mehrere Raeume gleichzeitig existieren, und
## ein globaler Suchlauf wuerde irgendeinen davon finden.
func _reposition() -> void:
	if not is_inside_tree():
		return

	var marker: Node3D = _find_spawn_marker()
	if marker == null:
		_debug("Kein PlayerSpawnPoint im Raum gefunden - Node bleibt, wo er im Editor liegt.")
		if _pivot != null:
			_pivot.position.y = height
			_base_y = height
		return

	var dir: Vector3 = _placement_direction(marker)

	position = marker.position + dir * distance
	position.y = marker.position.y

	if _pivot != null:
		_pivot.position.y = height
		_base_y = height

	if not face_player:
		# Das Schild soll den Spawnpunkt ANSEHEN, also muss seine eigene
		# +Z-Achse (Vorderseite von Sprite3D und QuadMesh) entgegen der
		# Aufstellrichtung zeigen.
		rotation.y = atan2(-dir.x, -dir.z)

	_debug("Platziert bei %s (Modus %s)." % [position, Placement.keys()[placement]])


## Liefert die Richtung, in die das Schild vom Marker aus gesetzt wird -
## als Einheitsvektor im LOKALEN System des Elternknotens.
##
## WARUM LOKAL UND NICHT GLOBAL:
## Der Raum wird mit einer skalierten Basis instanziiert (room_scale).
## Eine Weltrichtung mit einem lokalen Abstand zu multiplizieren, mischt
## zwei Koordinatensysteme - das Schild waere dann bei jeder Aenderung von
## room_scale unterschiedlich weit weg. Die Kamerarichtung wird deshalb
## ueber die inverse Elternbasis heruntergerechnet.
func _placement_direction(marker: Node3D) -> Vector3:
	match placement:
		Placement.SPAWN_BACK_Z:
			return marker.transform.basis.z.normalized()
		Placement.SPAWN_VIEW_Z:
			return -marker.transform.basis.z.normalized()
		_:
			pass

	# CAMERA_VIEW
	var pivot: Node3D = _find_camera_pivot()
	if pivot == null:
		# Fallback: bei Spawn-Yaw 0 zeigt die Kamera ohnehin nach -Z.
		return -marker.transform.basis.z.normalized()

	# Blickrichtung der Kamera in Weltkoordinaten. -Z, weil Camera3D wie
	# jedes Godot-Node entlang seiner NEGATIVEN Z-Achse schaut - und weil
	# genau dorthin auch Bewegung und Angriffe zeigen (siehe Dateikopf).
	var world_dir: Vector3 = -pivot.global_transform.basis.z
	world_dir.y = 0.0
	if world_dir.length() < 0.001:
		return -marker.transform.basis.z.normalized()
	world_dir = world_dir.normalized()

	var parent_3d: Node3D = get_parent() as Node3D
	if parent_3d == null:
		return world_dir

	var local_dir: Vector3 = parent_3d.global_transform.basis.inverse() * world_dir
	local_dir.y = 0.0
	if local_dir.length() < 0.001:
		return -marker.transform.basis.z.normalized()
	return local_dir.normalized()


## Der CameraPivot haengt unter der Spieler-Instanz (siehe
## char_*.tscn: Player/CameraPivot/SpringArm3D/Camera3D). Gesucht wird
## ueber die Gruppe, nicht ueber einen Pfad - PartyManager tauscht die
## Instanz bei jedem Charakterwechsel komplett aus.
func _find_camera_pivot() -> Node3D:
	var player: Node3D = _find_player()
	if player == null:
		return null
	var pivot: Node = player.get_node_or_null("CameraPivot")
	if pivot is Node3D:
		return pivot as Node3D
	# Fallback: der Koerper selbst. Sein Yaw kommt beim Spawnen direkt vom
	# Marker, taugt also als grobe Ersatzrichtung.
	return player


func _find_spawn_marker() -> Node3D:
	var parent: Node = get_parent()
	if parent == null:
		return null

	for child: Node in parent.get_children():
		if child == self:
			continue
		if child is PlayerSpawnPoint:
			return child as Node3D

	# Zweiter Versuch ueber den Namen - deckt Szenen ab, in denen der Marker
	# (noch) kein Script traegt.
	var by_name: Node = parent.get_node_or_null("PlayerSpawnPoint")
	if by_name is Node3D:
		return by_name as Node3D

	return null


# ============================================================================
# Laufzeit
# ============================================================================
func _process(delta: float) -> void:
	if _pivot == null or not is_instance_valid(_pivot):
		return

	_time += delta

	if bob_enabled:
		_pivot.position.y = _base_y + sin(_time * bob_speed) * bob_height

	if Engine.is_editor_hint():
		return

	_update_distance_fade(delta)
	_apply_alpha()
	_update_interact(delta)


## Zwei getrennte Schwellen (fade_out_distance / fade_in_distance) statt
## einer: mit nur einer Grenze flackert die Anzeige, sobald man genau auf
## ihr steht und sich minimal bewegt.
func _update_distance_fade(delta: float) -> void:
	if fade_out_distance <= 0.0:
		_visible_target = 1.0
	else:
		var player: Node3D = _find_player()
		if player != null:
			var d: float = global_position.distance_to(player.global_position)
			# Die Schwellen sind in LOKALEN Einheiten angegeben, die
			# Entfernung faellt in Weltmassen an - also umrechnen, sonst
			# stimmen die Werte bei room_scale != 1 nicht.
			var world_scale: float = maxf(global_transform.basis.x.length(), 0.001)
			var out_limit: float = fade_out_distance * world_scale
			var in_limit: float = fade_in_distance * world_scale

			if d > out_limit:
				_visible_target = 0.0
			elif d < in_limit:
				_visible_target = 1.0

	var step: float = delta / maxf(fade_duration, 0.01)
	_current_fade = move_toward(_current_fade, _visible_target, step)


func _apply_alpha() -> void:
	var flicker: float = 1.0
	if flicker_enabled:
		# Zwei ueberlagerte Sinuskurven mit unpassenden Frequenzen: eine
		# einzelne Welle liest sich als gleichmaessiges Pulsieren, nicht
		# als instabile Projektion.
		var noise: float = sin(_time * flicker_speed) * 0.6 + sin(_time * flicker_speed * 2.7) * 0.4
		flicker = 1.0 - flicker_amount * (noise * 0.5 + 0.5)

	var alpha: float = _current_fade * flicker

	if _board != null and is_instance_valid(_board):
		_board.modulate = Color(tint.r, tint.g, tint.b, opacity * alpha)
		_board.visible = alpha > 0.01

	if _backdrop_material != null:
		_backdrop_material.albedo_color = Color(
			backdrop_color.r, backdrop_color.g, backdrop_color.b, backdrop_color.a * alpha
		)
	if _backdrop != null and is_instance_valid(_backdrop):
		_backdrop.visible = alpha > 0.01

	if _projector_material != null:
		_projector_material.albedo_color = Color(
			projector_color.r, projector_color.g, projector_color.b, projector_color.a * alpha
		)
	if _projector != null and is_instance_valid(_projector):
		_projector.visible = alpha > 0.01


## Interaktion: [F] in der Naehe oeffnet den Vollbild-Viewer (siehe
## _build_view_overlay()/_show_view_overlay()).
func _update_interact(_delta: float) -> void:
	if not interact_zoom_enabled:
		return

	var player: Node3D = _find_player()
	var in_range: bool = false
	if player != null:
		var d: float = global_position.distance_to(player.global_position)
		# Gleiche lokal->Welt-Umrechnung wie _update_distance_fade(), aus
		# demselben Grund (room_scale).
		var world_scale: float = maxf(global_transform.basis.x.length(), 0.001)
		in_range = d <= interact_range * world_scale

	if in_range != _player_in_interact_range:
		_player_in_interact_range = in_range
		if not in_range and _zoomed:
			_set_zoomed(false)
		if _interact_prompt != null and is_instance_valid(_interact_prompt):
			_interact_prompt.visible = in_range

	if not in_range:
		return

	if _interact_prompt != null and is_instance_valid(_interact_prompt):
		_interact_prompt.text = "[F] Schliessen" if _zoomed else "[F] Ansehen"

	if Input.is_action_just_pressed("interact"):
		_set_zoomed(not _zoomed)


func _set_zoomed(value: bool) -> void:
	_zoomed = value
	_show_view_overlay(value)


## Baut den Vollbild-Viewer EINMAL beim Aufbau des Schilds, standardmaessig
## unsichtbar. layer = 90: ueber HUD/Minimap, aber unter einem etwaigen
## Pause-Menue (das faengt typischerweise erst bei 100+ an - siehe
## pause_menu.gd), damit man das Bild im Notfall trotzdem noch pausieren kann.
func _build_view_overlay() -> void:
	if tutorial_texture == null:
		return

	_view_layer = CanvasLayer.new()
	_view_layer.name = "HologramViewLayer"
	_view_layer.layer = 90
	_view_layer.visible = false
	add_child(_view_layer)

	_view_backdrop = ColorRect.new()
	_view_backdrop.name = "Backdrop"
	_view_backdrop.color = Color(0.0, 0.0, 0.0, 0.0)
	_view_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_view_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view_layer.add_child(_view_backdrop)

	_view_image = TextureRect.new()
	_view_image.name = "Image"
	_view_image.texture = tutorial_texture
	_view_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_view_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_view_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_view_image.offset_left = 80.0
	_view_image.offset_top = 60.0
	_view_image.offset_right = -80.0
	_view_image.offset_bottom = -60.0
	_view_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view_image.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_view_layer.add_child(_view_image)

	_view_hint = Label.new()
	_view_hint.name = "Hint"
	_view_hint.text = "[F] Schliessen"
	_view_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_view_hint.add_theme_font_size_override("font_size", 18)
	_view_hint.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0, 0.9))
	_view_hint.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_view_hint.add_theme_constant_override("outline_size", 4)
	_view_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_view_hint.offset_top = -40.0
	_view_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_view_hint.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_view_layer.add_child(_view_hint)


## Ein-/Ausblenden statt sofortigem Sichtbarkeitswechsel - ein hart
## erscheinendes Vollbild wirkt wie ein Rendering-Fehler, kein UI-Element.
func _show_view_overlay(value: bool) -> void:
	if _view_layer == null or not is_instance_valid(_view_layer):
		return
	if _view_tween != null and _view_tween.is_valid():
		_view_tween.kill()

	if value:
		_view_layer.visible = true
		_view_tween = create_tween()
		_view_tween.set_parallel(true)
		_view_tween.tween_property(_view_backdrop, "color:a", 0.88, interact_zoom_duration)
		_view_tween.tween_property(_view_image, "modulate:a", 1.0, interact_zoom_duration)
		_view_tween.tween_property(_view_hint, "modulate:a", 1.0, interact_zoom_duration)
		return

	_view_tween = create_tween()
	_view_tween.set_parallel(true)
	_view_tween.tween_property(_view_backdrop, "color:a", 0.0, interact_zoom_duration)
	_view_tween.tween_property(_view_image, "modulate:a", 0.0, interact_zoom_duration)
	_view_tween.tween_property(_view_hint, "modulate:a", 0.0, interact_zoom_duration)
	_view_tween.chain().tween_callback(func() -> void:
		if is_instance_valid(_view_layer):
			_view_layer.visible = false
	)


## Ueber die Gruppe statt find_child("Player"): der PartyManager tauscht die
## Spieler-Instanz bei jedem Charakterwechsel komplett aus, eine gemerkte
## Referenz waere danach eine Leiche.
func _find_player() -> Node3D:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(PLAYER_GROUP)
	for node: Node in nodes:
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


## Von aussen ein-/ausblendbar, falls das Tutorial spaeter ueber eine
## Einstellung abschaltbar sein soll.
func set_hologram_visible(value: bool) -> void:
	_visible_target = 1.0 if value else 0.0

```
</details>

### 💭 Thinking

`19:37:51`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `Maustaste|Taste|drücke|Drücke|halte|Halte|LMB|RMB|Shift` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\hud_extra.gd`

`19:37:53`

```
30:# Es ist kein HUD-Element, sondern eine Vollbild-Abdunklung, die beim Halten
61:## Schaltet das Reset-Overlay ab — z.B. fuer Screenshots oder Cutscenes, in
62:## denen ein versehentlich gehaltenes [R] nicht abdunkeln soll.
```

### 💭 Thinking

`19:37:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `tutorial_character_intro.gd`

`19:37:56`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\ui\tutorial_character_intro.gd</code></summary>

```
extends CanvasLayer
class_name TutorialCharacterIntro

# ============================================================================
# TutorialCharacterIntro — permanente, WACHSENDE Liste von Charakter-
# Kurzbeschreibungen fuer den Tutorial-Modus (level_generator.gd::
# generate_tutorial_stage()).
# ============================================================================
# Anders als item_description_hud.gd (Popup, blendet nach Zeit/Distanz wieder
# aus) bleibt hier JEDER Eintrag fuer den Rest des Tutorials sichtbar - jeder
# neu freigeschaltete Charakter haengt eine weitere Zeile an, nichts wird
# ersetzt oder entfernt. Bewusst als eigenstaendiges CanvasLayer statt Teil
# von hud.tscn: nur im Tutorial gebraucht, hud.tscn bleibt unangetastet.
#
# --- Andocken an die Minimap ------------------------------------------------
# Statt einer festen Bildschirmposition haengt sich das Panel UNTER die
# Minimap - exakt dasselbe Problem/dieselbe Loesung wie run_timer.gd (dockt
# rechts daneben): Minimap.get_docking_rect() liefert das tatsaechlich
# belegte, mit SettingsManager.minimap_ui_scale skalierungskorrigierte
# Rechteck. Ohne das wuerde ein Aendern der Minimap-Groesse im Optionsmenue
# das Panel entweder unter der Minimap verschwinden oder mit Luecke
# davonstehen lassen.

const PANEL_COLOR: Color = Color(0.05, 0.05, 0.08, 0.86)
const NAME_COLOR: Color = Color(0.95, 0.85, 0.35)
const DESC_COLOR: Color = Color(0.88, 0.88, 0.92)
const MAX_WIDTH: float = 420.0

const MINIMAP_GROUP: String = "minimap"

## Abstand zwischen Minimap-Rahmen und diesem Panel in Pixeln.
@export var dock_gap: float = 16.0

## Position, falls keine Minimap existiert (z.B. Testszene ohne HUD).
const FALLBACK_POSITION: Vector2 = Vector2(24.0, 24.0)

var _list: VBoxContainer = null
var _panel: PanelContainer = null
var _minimap: Control = null


func _ready() -> void:
	layer = 5

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_panel.position = FALLBACK_POSITION

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	_panel.add_child(_list)

	if SettingsManager != null and SettingsManager.has_signal("minimap_setting_changed"):
		if not SettingsManager.minimap_setting_changed.is_connected(_update_dock):
			SettingsManager.minimap_setting_changed.connect(_update_dock)
	get_viewport().size_changed.connect(_update_dock)

	# Ein Frame warten: die Minimap baut ihr Raum-Overlay/ihren Rahmen noch
	# in ihrer eigenen _ready() fertig - wer vorher misst, dockt an die noch
	# unfertige Groesse an (identisches Muster wie run_timer.gd).
	_update_dock.call_deferred()


## Setzt die Y-Position direkt unter die Minimap. Idempotent.
func _update_dock() -> void:
	if _minimap == null or not is_instance_valid(_minimap):
		var found: Array[Node] = get_tree().get_nodes_in_group(MINIMAP_GROUP)
		if found.is_empty():
			_panel.position = FALLBACK_POSITION
			return
		_minimap = found[0] as Control

	if _minimap == null or not _minimap.has_method("get_docking_rect"):
		_panel.position = FALLBACK_POSITION
		return

	if not _minimap.visible:
		_panel.position = FALLBACK_POSITION
		return

	var rect: Rect2 = _minimap.get_docking_rect()
	_panel.position = Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)


func _process(_delta: float) -> void:
	# Guenstiger Abgleich, deckt die getweente Groessenaenderung beim
	# Oeffnen/Schliessen der Grosskarte ab, die kein eigenes Signal hat -
	# identisches Muster wie run_timer.gd::_process().
	if _minimap == null or not is_instance_valid(_minimap) or _panel == null:
		return
	if not _minimap.visible:
		return
	var rect: Rect2 = _minimap.get_docking_rect()
	var wanted := Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)
	if not _panel.position.is_equal_approx(wanted):
		_panel.position = wanted


## Haengt einen weiteren, permanenten Eintrag an - wird von
## level_generator.gd bei jedem Charakter-Unlock (inkl. dem Start-Charakter
## im Corridor) aufgerufen. Nichts wird je entfernt oder ersetzt.
func add_entry(char_name: String, description: String) -> void:
	if _list == null:
		return

	var entry := VBoxContainer.new()
	entry.add_theme_constant_override("separation", 2)

	var name_label := Label.new()
	name_label.text = char_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", NAME_COLOR)
	entry.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", DESC_COLOR)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.custom_minimum_size = Vector2(MAX_WIDTH - 32.0, 0.0)
	entry.add_child(desc_label)

	_list.add_child(entry)

```
</details>

### 💭 Thinking: *Ah, so `TutorialCharacterIntro` is the permanent…*

`19:38:03`

<details>
<summary>Thinking...</summary>

> Ah, so `TutorialCharacterIntro` is the permanent, growing list of character descriptions for tutorial mode — these are pulled from `TutorialContent` along with the character descriptions like GISELLE_DESCRIPTION and NINGNING_DESCRIPTION that come from `character_data.gd`.…
</details>

#### 🔎 Grep `dash|Dash|shift|Shift` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd`

`19:38:04`

```
53:# Projektions-/Lens-Shift: er verschiebt nur das GERENDERTE Bild, nicht die
284:## Combo-Tilt/Screenshake/Dash-Drill, siehe camera.rotation.z-Kommentar dort).
335:var _dash_roll_degrees: float = 0.0
336:var _dash_roll_tween: Tween
339:# --- Dash FOV-Boost ---
340:## --- Drill-Effekt beim Dash (Phase 2.5) -------------------------------
342:## Der Kamera-Roll rollt beim seitlichen Dash in Bewegungsrichtung mit und
345:## NUR BEI A/D: bei einem Vorwaerts- oder Rueckwaerts-Dash gibt es keine
352:## Frame ueberschrieben — derselbe Konflikt, der bei dash_fov_boost schon
354:## (_dash_roll_degrees) in genau diese Zeile hinein.
355:@export var dash_drill_enabled: bool = true
356:@export var dash_drill_degrees: float = 9.0
357:@export var dash_drill_ramp_up_time: float = 0.07
358:@export var dash_drill_ramp_down_time: float = 0.30
360:@export var dash_fov_boost: float = 25.0
361:@export var dash_fov_ramp_up_time: float = 0.08
362:@export var dash_fov_ramp_down_time: float = 0.35
365:# BUGFIX 1 "beim Dash zoomt die Kamera in den Spieler rein":
369:# castet er nur einen haarduennen Strahl - waehrend eines Dashs legt der
373:# BUGFIX 2 "die Kamera geht beim Dashen durch Waende":
375:# Der erste Versuch war, die Kollision waehrend des Dashs komplett
388:# dash_camera_ignore_collision bleibt als Notschalter erhalten, ist aber
390:@export var dash_camera_ignore_collision: bool = false
391:@export var dash_camera_probe_radius: float = 0.35
392:@export var dash_camera_margin: float = 0.2
404:## -1 = kein Backup aktiv. Die echte Maske wird beim Dash-Start
408:var _dash_fov_tween: Tween
500:## Ein laufender Dash-Tween wird dabei gekillt: seine Rueckwaerts-Phase faehrt
503:## keine Wirkung, wenn man ihn waehrend eines Dashs bewegt.
506:	if _dash_fov_tween and _dash_fov_tween.is_valid():
507:		_dash_fov_tween.kill()
604:	camera.rotation.z = deg_to_rad(_combo_tilt_degrees + shake_roll_degrees + _dash_roll_degrees + _camera_movement_tilt_degrees)
631:## Kommentar bei dash_camera_ignore_collision.
637:		probe.radius = maxf(dash_camera_probe_radius, 0.05)
639:	spring_arm.margin = maxf(spring_arm.margin, dash_camera_margin)
645:## Schaltet die Kollision des Federarms fuer die Dauer des Dashs ab und
647:## oben in _physics_process, also auch dann, wenn der Dash durch Tod,
664:func _update_dash_camera_guard() -> void:
665:	if not dash_camera_ignore_collision or spring_arm == null:
668:	var dashing: bool = combat != null and combat.is_dashing()
669:	if dashing:
678:## Der Tween wird gemerkt und beim naechsten Dash abgeraeumt. Ohne das
679:## laufen bei zwei schnell aufeinanderfolgenden Dashs zwei Tweens
682:func play_dash_fov_effect() -> void:
683:	if _dash_fov_tween and _dash_fov_tween.is_valid():
684:		_dash_fov_tween.kill()
685:	_dash_fov_tween = create_tween()
686:	_dash_fov_tween.tween_property(camera, "fov", _base_fov + dash_fov_boost, dash_fov_ramp_up_time)\
688:	_dash_fov_tween.tween_property(camera, "fov", _base_fov, dash_fov_ramp_down_time)\
691:	play_dash_drill_effect()
694:## Seitlicher Kamera-Roll waehrend des Dashs.
697:## _dash_direction in combat_base.gd. Grund: _dash_direction ist ein
702:## Vorzeichen: Dash nach RECHTS rollt die Kamera nach links (negatives z),
705:func play_dash_drill_effect() -> void:
706:	if not dash_drill_enabled:
711:		# Reiner Vorwaerts-/Rueckwaerts-Dash: kein Roll. Ein evtl. noch
712:		# laufender Roll aus einem vorherigen Dash wird sauber
714:		_reset_dash_roll()
717:	if _dash_roll_tween and _dash_roll_tween.is_valid():
718:		_dash_roll_tween.kill()
720:	var target: float = -signf(strafe) * dash_drill_degrees
722:	_dash_roll_tween = create_tween()
723:	_dash_roll_tween.tween_property(self, "_dash_roll_degrees", target, dash_drill_ramp_up_time)\
725:	_dash_roll_tween.tween_property(self, "_dash_roll_degrees", 0.0, dash_drill_ramp_down_time)\
729:func _reset_dash_roll() -> void:
730:	if is_zero_approx(_dash_roll_degrees):
732:	if _dash_roll_tween and _dash_roll_tween.is_valid():
733:		_dash_roll_tween.kill()
734:	_dash_roll_tween = create_tween()
735:	_dash_roll_tween.tween_property(self, "_dash_roll_degrees", 0.0, dash_drill_ramp_down_time)\
764:	# GANZ oben, VOR dem Dash-Return: die Stun-Timer muessen auch waehrend
765:	# eines Dashs weiterlaufen, sonst friert die Immunitaet mitten im
768:	_update_dash_camera_guard()
770:	if combat.is_dashing():
771:		velocity = combat.get_dash_velocity(delta)
926:	# Bewusst dasselbe Vorzeichen-Vorbild wie play_dash_drill_effect()'s
927:	# Kamera-Roll (-signf(strafe) * dash_drill_degrees, siehe dort): bei
930:	# wie beim seitlichen Dash, nur deutlich subtiler. Nur der eigene, neue
933:	# Roll-Quellen (Combo-Tilt, Screenshake, Dash-Drill, hier) neu
986:	# Dashs macht combat_base.gd bereits den kraeftigeren Burst - hier
992:		ghost_trail.set_running(fast_enough and not combat.is_dashing() and not _is_dead)
```

### 💭 Thinking

`19:38:08`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `"dash"|dash_action|is_action.*dash` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\combat_base.gd`

`19:38:09`

```
No matches found
```

#### 🔎 Grep `dash` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\combat_base.gd`

`19:38:13`

```
5:# Enthält das komplette gemeinsame Cooldown-, Combo-, Hit-Lock- und Dash-
38:@export var dash_speed: float = 35.0
39:@export var dash_duration: float = 0.4
52:# DASH-SCHADEN - nur beim DURCHdashen
58:# Deshalb wird pro Gegner die VORZEICHEN-Umkehr entlang der Dash-Achse
61:#   along = dash_richtung (flach) . (gegner_pos - spieler_pos)
66:# Erst dieser Wechsel loest den Schaden aus. Bleibt der Dash vorher stehen
69:# dash_hit_radius, vertikal dash_hit_height_up/-_down) - sonst zaehlte ein
72:# Die Rechnung laeuft bewusst FLACH (X/Z): "durchdashen" ist eine
73:# horizontale Bewegung, und dash_direction traegt bei einem Vorwaerts-Dash
76:@export var dash_damage_enabled: bool = true
77:@export var dash_damage: float = 12.0
79:# --- Trefferfenster ("Hitbox" des Dashs) ------------------------------
80:# Das Volumen ist ein Quader ENTLANG der Dash-Achse:
82:#            dash_hit_radius            Blick von oben
86:#  ---o============>============|--->  Dash-Richtung
92:# einzeln verfolgt. Wer beim Dash mehr Gegner mitnehmen will, dreht
93:# dash_hit_radius hoch; das Limit war nie die Anzahl, sondern die Breite.
94:# dash_max_targets_per_dash existiert nur, falls man es bewusst DECKELN will.
96:## Seitliche Reichweite quer zur Dash-Achse (halbe Korridorbreite).
99:@export var dash_hit_radius: float = 2.6
107:## unnoetig viel. dash_hit_vertical_offset verschiebt das Fenster zusaetzlich
109:@export var dash_hit_height_up: float = 2.0
113:## beim Springen trotzdem alle Gegner hitten": ein Dash im/nach dem Sprung
115:## grosszuegiger, damit ein Sprung-Dash zuverlaessig auch Bodengegner trifft.
116:@export var dash_hit_height_down: float = 6.0
117:@export var dash_hit_vertical_offset: float = -0.5
119:## 0 = unbegrenzt (Standard). Nur setzen, wenn ein Dash bewusst hoechstens
121:@export var dash_max_targets_per_dash: int = 0
124:@export var dash_pierce_exit_distance: float = 0.3
125:## Kulanz beim Dash-START: ein Gegner, der praktisch auf mir steht (along
127:@export var dash_entry_grace: float = 0.6
129:@export var dash_hit_shake_strength: float = 0.25
132:@export var dash_knockback_force: float = 0.0
133:## Ob ein Dash-Treffer die Combo hochzaehlt. Der Hit-Lock aus
134:## _on_hit_landed() wird BEWUSST nicht ausgeloest - der wuerde den Dash
136:@export var dash_damage_counts_combo: bool = true
137:@export var dash_damage_sets_target: bool = true
139:## VFX, der bei einem Dash-TREFFER am Gegner aufblitzt. Getrennt von
140:## dash_vfx (Startpuff) und dash_trail (Dauer-Emitter) - das ist der
142:@export var dash_hit_vfx: PackedScene
147:@export var dash_damage_number_scene: PackedScene
148:@export var dash_debug_logging: bool = false
150:## Zeichnet bei jedem Dash das tatsaechliche Trefferfenster als
153:@export var dash_debug_draw: bool = false
154:@export var dash_debug_draw_duration: float = 0.8
155:@export var dash_debug_color: Color = Color(1.0, 0.85, 0.1, 0.22)
160:var _dash_pierce_state: Dictionary = {}
161:var _dash_pierce_armed: bool = false
162:var _dash_flat_direction: Vector3 = Vector3.ZERO
163:var _dash_hit_count: int = 0
176:## Feuert, wenn ein Gegner DURCHdasht wurde - fuer VFX/Sound/HUD.
177:signal dash_hit_landed(target: Node)
178:## Feuert JEDEN Dash, unabhaengig davon, ob er einen Gegner getroffen hat -
179:## anders als dash_hit_landed. Fuer Effekte wie die Leere Energy-Dose, die
180:## an das Dashen selbst haengen, nicht an dessen Treffer.
181:signal dash_ended
195:var _is_dashing: bool = false
196:var _dash_timer: float = 0.0
197:var _dash_direction: Vector3 = Vector3.ZERO
238:# --- Dash-Vertikalitaet: vorwaerts behaelt volle Blickrichtungs-Neigung, ---
239:# --- rueckwaerts bleibt bewusst flach/horizontal (default-Dash). ---
240:@export_range(0.0, 1.0) var backward_dash_vertical_influence: float = 0.0
243:## Startpuff beim Dash. Wird GEGEN die Dash-Richtung ausgerichtet, damit
245:@export var dash_vfx: PackedScene
302:## Dauer-Emitter fuer den Dash-Trail: GPUParticles3D-Kind am Player-Root
303:## namens "DashTrail" (emitting = false, one_shot = false,
305:@onready var dash_trail: GPUParticles3D = get_node_or_null("../DashTrail")
307:## Ghost-/Nachbild-Trail fuer den Dash (siehe scripts/vfx/ghost_trail.gd) -
310:## Dash einfach ohne Ghost-Effekt, statt einen Fehler zu werfen.
322:	# hier gesetzt, gilt fuer beide GhostTrail-Modi (Dash-Burst UND
369:	# nervigen Gegner getroffen), werden weder Angriffe noch Dash
520:# Von Charakter-Subklassen überschreibbar. Standardverhalten: Dash in
523:	if player and player.has_method("play_dash_fov_effect"):
524:		player.play_dash_fov_effect()
529:	# forward_full: mit voller vertikaler Neigung (Pitch) — fuer Vorwaerts-Dash.
530:	# forward_flat: rein horizontal, keine Neigung — fuer Rueckwaerts-Dash.
542:		effective_forward = forward_full.lerp(forward_flat, 1.0 - backward_dash_vertical_influence)
549:		_dash_direction = move_direction.normalized()
552:		_dash_direction = -forward_full.normalized()
554:	_is_dashing = true
555:	_dash_timer = dash_duration
558:	# Startpuff zeigt GEGEN die Dash-Richtung — der Staub bleibt zurueck,
560:	if dash_vfx and player:
561:		VFX.spawn(dash_vfx, player.global_position, -_dash_direction)
562:	if dash_trail:
563:		dash_trail.emitting = true
565:		ghost_trail.start_trail(dash_duration)
591:# Wird vom Player-Script in _physics_process aufgerufen, damit der Dash
593:func get_dash_velocity(delta: float) -> Vector3:
594:	if not _is_dashing:
597:	_dash_timer -= delta
598:	if _dash_timer <= 0.0:
599:		_is_dashing = false
600:		# Trail hier abschalten und NICHT per create_timer: der Dash kann
601:		# durch Frame-Drops laenger dauern als dash_duration in Echtzeit,
603:		if dash_trail:
604:			dash_trail.emitting = false
605:		dash_ended.emit()
608:	return _dash_direction * dash_speed
612:# Dash-Schaden: Durchquerungs-Erkennung
622:# Der armed-Zustand wird aus _is_dashing abgeleitet statt in _perform_utility
624:# _perform_utility ueberschreibt und _is_dashing selbst setzt - und sie
625:# ueberlebt jede spaetere Aenderung an der Dash-VFX-Logik darueber.
627:	if not dash_damage_enabled or player == null:
630:	if _is_dashing:
631:		if not _dash_pierce_armed:
632:			_arm_dash_pierce()
633:		_update_dash_pierce()
634:	elif _dash_pierce_armed:
635:		_dash_pierce_armed = false
636:		_dash_pierce_state.clear()
639:func _dash_debug(msg: String) -> void:
640:	if dash_debug_logging:
641:		print("[DashDamage] %s" % msg)
644:## Nimmt beim Dash-Start eine Momentaufnahme auf: wer steht schon hinter mir?
646:## hindurch, man dasht von ihnen weg.
647:func _arm_dash_pierce() -> void:
648:	_dash_pierce_armed = true
649:	_dash_pierce_state.clear()
650:	_dash_hit_count = 0
652:	_dash_flat_direction = Vector3(_dash_direction.x, 0.0, _dash_direction.z)
653:	if _dash_flat_direction.length() < 0.01:
654:		# Rein vertikaler Dash (Blick senkrecht nach oben/unten): es gibt
655:		# keine sinnvolle horizontale Achse, also kein Dash-Schaden.
656:		_dash_flat_direction = Vector3.ZERO
657:		_dash_debug("Dash ohne horizontale Komponente - Schadenspruefung aus.")
660:	_dash_flat_direction = _dash_flat_direction.normalized()
662:	for enemy in _collect_dash_targets():
663:		var along: float = _dash_along(enemy)
666:		var pending: bool = along > -dash_entry_grace
667:		_dash_pierce_state[id] = {"node": enemy, "pending": pending, "done": false}
669:	_spawn_dash_debug_volume()
672:	for entry in _dash_pierce_state.values():
675:	_dash_debug("Dash gestartet. %d Gegner im Fenster, davon %d vor mir (Radius %.1f, Hoehe +%.1f/-%.1f)." % [
676:		_dash_pierce_state.size(), pending_count,
677:		dash_hit_radius, dash_hit_height_up, dash_hit_height_down
681:func _update_dash_pierce() -> void:
682:	if _dash_flat_direction == Vector3.ZERO:
684:	if dash_max_targets_per_dash > 0 and _dash_hit_count >= dash_max_targets_per_dash:
687:	for enemy in _collect_dash_targets():
689:		var along: float = _dash_along(enemy)
691:		if not _dash_pierce_state.has(id):
692:			# Erst waehrend des Dashs in Reichweite gekommen. Nur vormerken,
695:			_dash_pierce_state[id] = {
702:		var entry: Dictionary = _dash_pierce_state[id]
706:		# Vorzeichenwechsel entlang der Dash-Achse = durchquert.
707:		if along < -dash_pierce_exit_distance:
709:			_dash_pierce_state[id] = entry
710:			_dash_hit_count += 1
711:			_apply_dash_damage(enemy)
712:			if dash_max_targets_per_dash > 0 and _dash_hit_count >= dash_max_targets_per_dash:
713:				_dash_debug("Trefferlimit %d erreicht - Rest dieses Dashs wird ignoriert." % dash_max_targets_per_dash)
720:func _collect_dash_targets() -> Array[Node3D]:
722:	if _dash_flat_direction == Vector3.ZERO:
734:		# Hoehenfenster asymmetrisch, siehe Kommentar bei dash_hit_height_up.
735:		var vertical: float = to_enemy.y - dash_hit_vertical_offset
736:		if vertical > dash_hit_height_up or vertical < -dash_hit_height_down:
740:		var along: float = _dash_flat_direction.dot(flat)
741:		var lateral: float = (flat - _dash_flat_direction * along).length()
742:		if lateral > dash_hit_radius:
756:func _dash_along(enemy: Node3D) -> float:
758:	return _dash_flat_direction.dot(Vector3(to_enemy.x, 0.0, to_enemy.z))
761:func _apply_dash_damage(enemy: Node3D) -> void:
769:	(health as Health).take_damage(dash_damage, player)
770:	_dash_debug("%.0f Schaden an '%s' (durchgedasht)." % [dash_damage, enemy.name])
772:	_spawn_dash_damage_number(enemy)
773:	dash_hit_landed.emit(enemy)
775:	# Treffer-VFX zeigt in Dash-Richtung: der Effekt soll mit der Bewegung
777:	if dash_hit_vfx:
778:		VFX.spawn(dash_hit_vfx, enemy.global_position + Vector3(0.0, 1.0, 0.0), _dash_flat_direction)
781:		player.shake_camera(dash_hit_shake_strength)
783:	if dash_damage_sets_target and player.has_method("set_target"):
787:	# Aufwaerts-Momentum und wuerde den laufenden Dash mitten in der Bewegung
789:	if dash_damage_counts_combo:
802:	if dash_knockback_force > 0.0 and enemy is CharacterBody3D:
804:			_dash_debug("Knockback ignoriert: '%s' ist ein schwerer Gegner." % enemy.name)
806:			var push_dir: Vector3 = _dash_flat_direction
808:				enemy.apply_knockback(push_dir * dash_knockback_force)
810:				enemy.velocity += push_dir * dash_knockback_force
815:## Der Quader entspricht 1:1 dem, was _collect_dash_targets() prueft: Laenge
816:## = dash_speed * dash_duration (die theoretische Bahn ohne Wandkollision),
817:## Breite = 2 * dash_hit_radius, Hoehe = up + down, vertikal um
818:## dash_hit_vertical_offset verschoben.
822:func _spawn_dash_debug_volume() -> void:
823:	if not dash_debug_draw or _dash_flat_direction == Vector3.ZERO or player == null:
826:	var length: float = maxf(dash_speed * dash_duration, 0.1)
827:	var height: float = maxf(dash_hit_height_up + dash_hit_height_down, 0.1)
830:	box.size = Vector3(dash_hit_radius * 2.0, height, length)
836:	mat.albedo_color = dash_debug_color
839:	gizmo.name = "DashHitboxDebug"
851:		+ _dash_flat_direction * (length * 0.5) \
852:		+ Vector3.UP * (dash_hit_vertical_offset + (dash_hit_height_up - dash_hit_height_down) * 0.5)
854:	var yaw: float = atan2(_dash_flat_direction.x, _dash_flat_direction.z)
860:	var timer := get_tree().create_timer(maxf(dash_debug_draw_duration, 0.05))
864:func _spawn_dash_damage_number(enemy: Node3D) -> void:
867:		push_warning("CombatBase: Keine damage_number_scene gefunden - Dash-Schadenszahl wird nicht angezeigt.")
874:	if number.has_method("show_dash_damage"):
875:		number.show_dash_damage(dash_damage)
877:		# Fallback fuer eine aeltere damage_number.gd ohne Dash-Variante:
879:		number.show_damage(dash_damage, true)
887:	if dash_damage_number_scene != null:
888:		return dash_damage_number_scene
901:func is_dashing() -> bool:
902:	return _is_dashing
```

### 💭 Thinking

`19:38:18`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `utility|shift` in `C:\Users\thvnh\Documents\GitHub\whiplash\project.godot`

`19:38:20`

```
60:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194319,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
63:, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
68:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194321,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
71:, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
76:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194320,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
79:, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)
84:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194322,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
87:, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":115,"location":0,"echo":false,"script":null)
92:"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":1,"position":Vector2(215, 12),"global_position":Vector2(224, 60),"factor":1.0,"button_index":1,"canceled":false,"pressed":true,"double_click":false,"script":null)
97:"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":2,"position":Vector2(260, 12),"global_position":Vector2(269, 60),"factor":1.0,"button_index":2,"canceled":false,"pressed":true,"double_click":false,"script":null)
100:utility={
102:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194325,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
107:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":70,"key_label":0,"unicode":102,"location":0,"echo":false,"script":null)
112:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":81,"key_label":0,"unicode":113,"location":0,"echo":false,"script":null)
117:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":69,"key_label":0,"unicode":101,"location":0,"echo":false,"script":null)
122:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":49,"key_label":0,"unicode":49,"location":0,"echo":false,"script":null)
127:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":50,"key_label":0,"unicode":50,"location":0,"echo":false,"script":null)
132:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":51,"key_label":0,"unicode":51,"location":0,"echo":false,"script":null)
137:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":52,"key_label":0,"unicode":52,"location":0,"echo":false,"script":null)
142:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":77,"key_label":0,"unicode":109,"location":0,"echo":false,"script":null)
147:"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":82,"key_label":0,"unicode":114,"location":0,"echo":false,"script":null)
```

### 💭 Thinking

`19:38:25`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `project.godot`

`19:38:26`

*(lines 1–151)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\project.godot</code></summary>

```
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[accessibility]

general/updates_per_second=100

[application]

config/name="Github-Whiplash"
run/main_scene="res://scenes/main_menu.tscn"
config/features=PackedStringArray("4.7", "Mobile")
config/icon="res://icon.svg"

[autoload]

SettingsManager="*uid://cgyvs40ry7wt8"
PartyManager="*uid://bkpbaujgouiwg"
SteamManager="*uid://bjgm7cyxksuqe"
LeaderboardManager="*uid://eehxkf4mihmq"
VFX="*uid://dmnltpdascg2c"
Juice="*uid://d366sudmnp73u"
Items="*uid://vkdd47uykpas"
Loot="*uid://b1etjb81qmrf7"
RunRestart="*uid://ve30kqbt3e82"
Treasure="*uid://ducvniyothuqw"
RoomGuard="*uid://vtgbvdd0vlh"
EnemyDensity="*uid://bxxty8yqhh1d"
HudExtra="*uid://bys4sieyin6ky"
Teleporter="*uid://dxfotrd7xhn1p"
Stages="*uid://buqywesge6fy4"
GameStats="*res://scripts/game_stats.gd"
ItemTestRoom="*res://scripts/item_test_room.gd"
EnemySandboxRoom="*res://scripts/enemy_sandbox_room.gd"
SaveGame="*res://scripts/save_game_manager.gd"
HubRoom="*res://scripts/hub_room.gd"
VfxTestRoom="*res://scripts/vfx_test_room.gd"
TutorialFlow="*res://scripts/tutorial_flow.gd"

[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/mode=2
window/size/initial_position_type=4
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[input]

ui_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194319,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":13,"pressure":0.0,"pressed":false,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":0,"axis_value":-1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
]
}
ui_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194321,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":14,"pressure":0.0,"pressed":false,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":0,"axis_value":1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
]
}
ui_up={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194320,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":11,"pressure":0.0,"pressed":false,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":1,"axis_value":-1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)
]
}
ui_down={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194322,"physical_keycode":0,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":12,"pressure":0.0,"pressed":false,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":1,"axis_value":1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":115,"location":0,"echo":false,"script":null)
]
}
attack_primary={
"deadzone": 0.2,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":1,"position":Vector2(215, 12),"global_position":Vector2(224, 60),"factor":1.0,"button_index":1,"canceled":false,"pressed":true,"double_click":false,"script":null)
]
}
attack_secondary={
"deadzone": 0.2,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":2,"position":Vector2(260, 12),"global_position":Vector2(269, 60),"factor":1.0,"button_index":2,"canceled":false,"pressed":true,"double_click":false,"script":null)
]
}
utility={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194325,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
interact={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":70,"key_label":0,"unicode":102,"location":0,"echo":false,"script":null)
]
}
ability_primary={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":81,"key_label":0,"unicode":113,"location":0,"echo":false,"script":null)
]
}
ability_secondary={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":69,"key_label":0,"unicode":101,"location":0,"echo":false,"script":null)
]
}
switch_char_1={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":49,"key_label":0,"unicode":49,"location":0,"echo":false,"script":null)
]
}
switch_char_2={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":50,"key_label":0,"unicode":50,"location":0,"echo":false,"script":null)
]
}
switch_char_3={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":51,"key_label":0,"unicode":51,"location":0,"echo":false,"script":null)
]
}
switch_char_4={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":52,"key_label":0,"unicode":52,"location":0,"echo":false,"script":null)
]
}
toggle_map={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":77,"key_label":0,"unicode":109,"location":0,"echo":false,"script":null)
]
}
reset={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":82,"key_label":0,"unicode":114,"location":0,"echo":false,"script":null)
]
}

```
</details>

### 💭 Thinking

`19:38:31`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `zoom` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap.gd`

`19:38:32`

```
22:##   Mausrad zoomt auf den Cursor, Ziehen verschiebt den Ausschnitt.
43:## Mausrad-Zoom der Grosskarte. Laufzeitwert, KEINE gespeicherte
45:const BIG_MAP_ZOOM_MIN: float = 0.35
46:const BIG_MAP_ZOOM_MAX: float = 4.0
47:const BIG_MAP_ZOOM_STEP: float = 1.15
83:## --- Dynamischer Auto-Zoom -------------------------------------------
84:## Die Kamera zoomt automatisch heraus, sobald die aufgedeckte Flaeche
90:## SettingsManager.minimap_zoom bleibt uneingeschraenkt wirksam — es wird
93:@export var auto_zoom_enabled: bool = true
95:@export var auto_zoom_padding: float = 40.0
98:@export var auto_zoom_small_max: float = 300.0
101:@export var auto_zoom_big_max: float = 900.0
115:## dieselbe Funktion, die schon den Spielerpfeil setzt. Zoom, Pan und
158:var _big_map_zoom: float = 1.0
178:## jedem map_updated neu bestimmt. 0 = noch keine Daten -> Auto-Zoom
345:# --- Dynamischer Auto-Zoom ---------------------------------------------
423:	_revealed_world_span = maxf(span_x, span_z) + auto_zoom_padding
501:	# sonst wuerde der Zoom-Regler bei offener Grosskarte die Kleinansicht
518:## Zoom > 1 = naeher dran. Der Kamera-Ausschnitt ist der KEHRWERT des
519:## Zooms. maxf() verhindert eine Division, die bei einem manipulierten
520:## Zoom von 0 eine size von inf erzeugen wuerde.
522:	return _auto_base_size(map_size, auto_zoom_small_max) / maxf(SettingsManager.minimap_zoom, 0.01)
526:	return _auto_base_size(big_map_world_size, auto_zoom_big_max) / maxf(_big_map_zoom, 0.01)
529:## Basisausschnitt VOR dem Anwenden des Zoom-Reglers.
531:## Der Auto-Zoom vergroessert nur — er zieht nie enger als der
536:	if not auto_zoom_enabled or _revealed_world_span <= 0.0:
632:					_zoom_big_map(BIG_MAP_ZOOM_STEP)
636:					_zoom_big_map(1.0 / BIG_MAP_ZOOM_STEP)
684:## Multiplikativer Zoomschritt statt additiv: so fuehlt sich das Scrollen
686:## Verkleinerung (ein additiver Schritt waere bei Zoom 4.0 kaum spuerbar
689:## Zoom ZUM CURSOR: Weltpunkt unter der Maus vor und nach der
693:func _zoom_big_map(factor: float) -> void:
696:	_big_map_zoom = clampf(_big_map_zoom * factor, BIG_MAP_ZOOM_MIN, BIG_MAP_ZOOM_MAX)
705:## aus den Maus-Handlern gerufen - Letzteres, damit Zoom/Drag sofort
729:## um. Das beruecksichtigt Zoom (map_camera.size), Pan und - falls
945:	# waere der Auto-Zoom danach dauerhaft tot gewesen — ohne Fehler,
```

### 💭 Thinking

`19:38:37`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `minimap_zoom` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\settings_manager.gd`

`19:38:38`

```
226:var minimap_zoom: float = MINIMAP_ZOOM_DEFAULT
462:func set_minimap_zoom(value: float) -> void:
463:	minimap_zoom = clampf(value, MINIMAP_ZOOM_MIN, MINIMAP_ZOOM_MAX)
509:	minimap_zoom = MINIMAP_ZOOM_DEFAULT
762:	config.set_value("minimap", "zoom", minimap_zoom)
847:	minimap_zoom = clampf(
```

#### 🔎 Grep `MINIMAP_ZOOM_DEFAULT|MINIMAP_ZOOM_MIN|MINIMAP_ZOOM_MAX` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\settings_manager.gd`

`19:38:42`

```
113:const MINIMAP_ZOOM_MIN: float = 0.4
114:const MINIMAP_ZOOM_MAX: float = 3.0
120:const MINIMAP_ZOOM_DEFAULT: float = 1.80
226:var minimap_zoom: float = MINIMAP_ZOOM_DEFAULT
463:	minimap_zoom = clampf(value, MINIMAP_ZOOM_MIN, MINIMAP_ZOOM_MAX)
509:	minimap_zoom = MINIMAP_ZOOM_DEFAULT
848:		float(config.get_value("minimap", "zoom", MINIMAP_ZOOM_DEFAULT)),
849:		MINIMAP_ZOOM_MIN, MINIMAP_ZOOM_MAX)
```

### 🤖 Assistant: *Found it — `MINIMAP_ZOOM_DEFAULT: float …*

`19:38:45`

> Found it — `MINIMAP_ZOOM_DEFAULT: float = 1.80` at [settings_manager.gd:120](scripts/settings_manager.gd:120), needs to become `1.60`. Now let's find the cooldown HUD element and the two enemy scales.

#### 🔎 Grep `cooldown` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\hud.gd`

`19:38:46`

```
114:	# Keybinds/Cooldowns sind KEIN eigener Node, sondern Kind-Labels der
240:	# Switch-Cooldown der Party-Slots (unabhaengig davon, ob player_combat
243:		var switch_percent: float = PartyManager.get_switch_cooldown_percent(i)
244:		var switch_remaining: float = PartyManager.get_switch_cooldown_remaining(i)
245:		_party_slots[i].update_switch_cooldown(switch_percent, switch_remaining)
253:		var percent: float = player_combat.get_cooldown_percent(i)
254:		var remaining: float = player_combat.get_cooldown_remaining(i)
255:		_ability_slots[i].update_cooldown(percent, remaining)
```

### 💭 Thinking

`19:38:50`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `ability_slot|AbilitySlot` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`19:38:50`

```
Found 31 files
scripts\combat_base.gd
graphify-out\2026-08-13\GRAPH_REPORT.md
graphify-out\GRAPH_REPORT.md
graphify-out\2026-08-13\graph.json
graphify-out\graph.json
03_DevLogs\2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md
03_DevLogs\2026-07-24_b39a97d_refactorplayer_split_player_system_into_per-charac.md
03_DevLogs\2026-07-23_15c8712_feathud_add_full_party_hud_with_abilities_minimap_.md
03_DevLogs\2026-07-24_d86f02e_refactorplayer_split_player_system_into_per-charac.md
03_DevLogs\2026-07-26_61765de_feat_combat-tuning_hud-overhaul_anti-baiting_sieg-.md
03_DevLogs\2026-07-28_ea34fe3_featitems_aktive_items_auf_qe-slots_umgestellt.md
graphify-out\2026-08-12\GRAPH_REPORT.md
graphify-out\2026-08-12\graph.json
graphify-out\cache\ast\v0.9.41\9022903d33f71f4173b2b7078bede3351d9092dbce33a39cfb7af06d1ab3077d.json
graphify-out\cache\ast\v0.9.41\fbcfe60fd0214b33eed61742340224a3920295f0118b8cd1629df6cc8577ddd1.json
graphify-out\cache\ast\v0.9.41\b09a79883007b345df10adfbece4c74d587f65842bf6001e8eb31bda20a96447.json
graphify-out\.graphify_detect.json
_project_export.txt
04_Chat_Prompts\2026-08-12_user-raw-uggestions-unless-specifically-asked-uggestions-unless.md
04_Chat_Prompts\2026-08-12_user-raw-barrelbroken-von-den-fpsdungeonextras-lschen-das.md
04_Chat_Prompts\2026-08-11_implement-various-game-improvements-and-bug-fixes.md
04_Chat_Prompts\2026-08-10_warp-worktree-vs-haupt-repository-wahl.md
04_Chat_Prompts\2026-07-24_roguelike-style-room-design-variation.md
04_Chat_Prompts\2026-07-23_godot-skript-fehler-area3d-vs-collisionshape3d.md
04_Chat_Prompts\2026-07-23_godot-skript-fehler-area3d-vs-collisionshape3d-1.md
scripts\hud.gd
03_DevLogs\2026-07-28_2642172_featitems_aktive_items_auf_qe-slots_umgestellt.md
scripts\ability_slot.gd
scenes\ui\ability_slot.tscn
scenes\ui\hud.tscn
scripts\party_slot.gd
```

### 💭 Thinking

`19:38:57`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `Ability|scale|anchor` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn`

`19:38:58`

```
45:anchors_preset = 15
46:anchor_right = 1.0
47:anchor_bottom = 1.0
55:anchors_preset = 0
72:anchors_preset = 10
73:anchor_right = 1.0
89:anchors_preset = 0
98:anchors_preset = 15
99:anchor_right = 1.0
100:anchor_bottom = 1.0
119:anchors_preset = 8
120:anchor_left = 0.5
121:anchor_top = 0.5
122:anchor_right = 0.5
123:anchor_bottom = 0.5
138:anchors_preset = 12
139:anchor_top = 1.0
140:anchor_right = 1.0
141:anchor_bottom = 1.0
158:anchors_preset = 3
159:anchor_left = 1.0
160:anchor_top = 1.0
161:anchor_right = 1.0
162:anchor_bottom = 1.0
179:anchors_preset = 0
189:anchors_preset = 15
190:anchor_right = 1.0
191:anchor_bottom = 1.0
199:anchors_preset = 10
200:anchor_right = 1.0
216:anchors_preset = 15
217:anchor_right = 1.0
218:anchor_bottom = 1.0
235:anchors_preset = 6
236:anchor_left = 1.0
237:anchor_top = 0.5
238:anchor_right = 1.0
239:anchor_bottom = 0.5
250:anchors_preset = 15
251:anchor_right = 1.0
252:anchor_bottom = 1.0
271:[node name="AbilityBar" type="Control" parent="." unique_id=125991312]
273:anchors_preset = 3
274:anchor_left = 1.0
275:anchor_top = 1.0
276:anchor_right = 1.0
277:anchor_bottom = 1.0
286:[node name="AbilityContainer" type="HBoxContainer" parent="AbilityBar" unique_id=1082566463]
288:anchors_preset = 15
289:anchor_right = 1.0
290:anchor_bottom = 1.0
297:[node name="AbilitySlot1" parent="AbilityBar/AbilityContainer" unique_id=2038628797 instance=ExtResource("4_abslot")]
300:[node name="AbilitySlot2" parent="AbilityBar/AbilityContainer" unique_id=739250693 instance=ExtResource("4_abslot")]
303:[node name="AbilitySlot3" parent="AbilityBar/AbilityContainer" unique_id=1962302246 instance=ExtResource("4_abslot")]
306:[node name="AbilitySlot4" parent="AbilityBar/AbilityContainer" unique_id=1125307233 instance=ExtResource("4_abslot")]
309:[node name="AbilitySlot5" parent="AbilityBar/AbilityContainer" unique_id=1929310327 instance=ExtResource("4_abslot")]
314:anchors_preset = 8
315:anchor_left = 0.5
316:anchor_top = 0.5
317:anchor_right = 0.5
318:anchor_bottom = 0.5
348:anchors_preset = 2
349:anchor_top = 1.0
350:anchor_bottom = 1.0
370:anchors_preset = 7
371:anchor_left = 0.5
372:anchor_top = 1.0
373:anchor_right = 0.5
374:anchor_bottom = 1.0
386:anchors_preset = 0
392:anchors_preset = 0
399:anchors_preset = 0
407:anchors_preset = 8
408:anchor_left = 0.5
409:anchor_top = 0.5
410:anchor_right = 0.5
411:anchor_bottom = 0.5
423:anchors_preset = 15
424:anchor_right = 1.0
425:anchor_bottom = 1.0
433:anchor_left = 0.5
434:anchor_top = 0.5
435:anchor_right = 0.5
436:anchor_bottom = 0.5
```

### 💭 Thinking: *I'm noticing the AbilityBar is positioned…*

`19:39:04`

<details>
<summary>Thinking...</summary>

> I'm noticing the AbilityBar is positioned at the bottom-right, and there are five ability slots that likely map to different actions like primary attack, secondary attack, utility abilities, and active items. Let me check the combat_base file to understand the exact slot configuration.…
</details>

#### 👀 Read `ability_slot.tscn`

`19:39:05`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\ability_slot.tscn</code></summary>

```
[gd_scene format=3 uid="uid://bablslot001"]

[ext_resource type="Script" path="res://scripts/ability_slot.gd" id="1_abslot"]

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_abslot"]
bg_color = Color(0.09, 0.09, 0.12, 0.85)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.55, 0.52, 0.2, 1)

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_abkey"]
bg_color = Color(0, 0, 0, 0.7)
corner_radius_top_left = 2
corner_radius_top_right = 2
corner_radius_bottom_right = 2
corner_radius_bottom_left = 2

[node name="AbilitySlot" type="Control"]
custom_minimum_size = Vector2(64, 64)
offset_right = 64.0
offset_bottom = 64.0
pivot_offset = Vector2(32, 32)
mouse_filter = 2
script = ExtResource("1_abslot")

[node name="Background" type="Panel" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_abslot")

[node name="Icon" type="TextureRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 4.0
offset_top = 4.0
offset_right = -4.0
offset_bottom = -4.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
expand_mode = 1
stretch_mode = 5

[node name="CooldownOverlay" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
color = Color(0, 0, 0, 0.65)

[node name="ReadyFlash" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
color = Color(1, 0.98, 0.75, 1)

[node name="CooldownLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
theme_override_colors/font_color = Color(1, 1, 1, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/outline_size = 4
theme_override_font_sizes/font_size = 20
horizontal_alignment = 1
vertical_alignment = 1

[node name="ResourceBarBg" type="ColorRect" parent="."]
layout_mode = 1
anchor_left = 0.0
anchor_top = 0.0
anchor_right = 1.0
anchor_bottom = 0.0
offset_bottom = 5.0
grow_horizontal = 2
mouse_filter = 2
color = Color(0, 0, 0, 0.6)
visible = false

[node name="ResourceBarFill" type="ColorRect" parent="ResourceBarBg"]
layout_mode = 1
anchor_left = 0.0
anchor_top = 0.0
anchor_right = 1.0
anchor_bottom = 1.0
mouse_filter = 2
color = Color(0.4, 0.85, 1.0, 1.0)

[node name="ResourceLabel" type="Label" parent="."]
layout_mode = 1
anchor_left = 0.0
anchor_top = 1.0
anchor_right = 0.0
anchor_bottom = 1.0
offset_left = 2.0
offset_top = -18.0
offset_right = 44.0
offset_bottom = -1.0
grow_horizontal = 1
grow_vertical = 0
mouse_filter = 2
theme_override_colors/font_color = Color(0.65, 0.9, 1, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/outline_size = 3
theme_override_font_sizes/font_size = 12
horizontal_alignment = 0
vertical_alignment = 1
text = ""
visible = false

[node name="KeyLabel" type="Label" parent="."]
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -34.0
offset_top = -18.0
offset_right = -2.0
offset_bottom = -1.0
grow_horizontal = 0
grow_vertical = 0
mouse_filter = 2
theme_override_colors/font_color = Color(0.95, 0.92, 0.6, 1)
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = SubResource("StyleBoxFlat_abkey")
text = "Q"
horizontal_alignment = 1
vertical_alignment = 1

```
</details>

### 💭 Thinking

`19:39:12`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `hud.tscn`

`19:39:13`

*(lines 265–315)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn</code></summary>

```
[node name="PartySlot3" parent="RightPanel/PartyContainer" unique_id=1882624205 instance=ExtResource("3_pslot")]
layout_mode = 2

[node name="PartySlot4" parent="RightPanel/PartyContainer" unique_id=1238276118 instance=ExtResource("3_pslot")]
layout_mode = 2

[node name="AbilityBar" type="Control" parent="." unique_id=125991312]
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -374.0
offset_top = -104.0
offset_right = -14.0
offset_bottom = -20.0
grow_horizontal = 0
grow_vertical = 0
mouse_filter = 2

[node name="AbilityContainer" type="HBoxContainer" parent="AbilityBar" unique_id=1082566463]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
theme_override_constants/separation = 8
alignment = 2

[node name="AbilitySlot1" parent="AbilityBar/AbilityContainer" unique_id=2038628797 instance=ExtResource("4_abslot")]
layout_mode = 2

[node name="AbilitySlot2" parent="AbilityBar/AbilityContainer" unique_id=739250693 instance=ExtResource("4_abslot")]
layout_mode = 2

[node name="AbilitySlot3" parent="AbilityBar/AbilityContainer" unique_id=1962302246 instance=ExtResource("4_abslot")]
layout_mode = 2

[node name="AbilitySlot4" parent="AbilityBar/AbilityContainer" unique_id=1125307233 instance=ExtResource("4_abslot")]
layout_mode = 2

[node name="AbilitySlot5" parent="AbilityBar/AbilityContainer" unique_id=1929310327 instance=ExtResource("4_abslot")]
layout_mode = 2

[node name="ComboDisplay" type="VBoxContainer" parent="." unique_id=1613643524]
layout_mode = 1
anchors_preset = 8
```
</details>

### 💭 Thinking: *The AbilityBar is sized to fit 5 ability…*

`19:39:25`

<details>
<summary>Thinking...</summary>

> The AbilityBar is sized to fit 5 ability slots at 64px each with 8px spacing between them, giving a total width of 360px and height of 84px to accommodate the KeyLabel and ResourceBar elements below. To scale up the entire HUD, I'll set the scale property directly on the AbilityBar control.
> 
> For scaling, I need to adjust the pivot offset so the element grows away from the bottom-right corner of the screen rather than expanding inward. Setting the pivot_offset to match the AbilityBar's size (360, 84) means scaling will expand upward and leftward while…
</details>

#### 🔎 Grep `ability_slot.tscn` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`19:39:25`

Glob: `**/*.tscn`

```
Found 1 file
scenes\ui\hud.tscn
```

### 💭 Thinking: *The cleanest approach is to scale the AbilityBar…*

`19:39:33`

<details>
<summary>Thinking...</summary>

> The cleanest approach is to scale the AbilityBar node directly using its scale property, with the pivot anchored to the bottom-right corner so it expands toward the screen center rather than off-screen. Now I'm calculating the dimensions based on the rect offsets to figure out the actual width.…
</details>

#### 🔎 Grep `scale|SCALE` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\mortar_bot.gd`

`19:39:34`

```
26:const VISUAL_SCALE: float = 4.5 * 0.85
46:## groessten aktuell moeglichen Mehrzellen-Raum (2x2-footprint * room_scale)
62:	visual_root.scale = Vector3.ONE * VISUAL_SCALE
63:	_add_box_collision(Vector3(2.0, 2.2, 2.0) * VISUAL_SCALE, Vector3(0.0, 1.1, 0.0) * VISUAL_SCALE)
```

```
23:const VISUAL_SCALE: float = 3.0
48:	visual_root.scale = Vector3.ONE * VISUAL_SCALE
49:	_add_box_collision(Vector3(1.6, 1.8, 1.6) * VISUAL_SCALE, Vector3(0.0, 0.9, 0.0) * VISUAL_SCALE)
```

### 💭 Thinking: *I found the VISUAL_SCALE constants in both…*

`19:39:46`

<details>
<summary>Thinking...</summary>

> I found the VISUAL_SCALE constants in both files — mortar_bot.gd has 3.825 and acid_sprinkler.gd has 3.0. I'll reduce each by about 15-20%, which will shrink both the visuals and collision boxes proportionally since they scale together, giving me exactly what I need.…
</details>

#### 👀 Read `mortar_bot.gd`

`19:39:47`

*(lines 1–66)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\mortar_bot.gd</code></summary>

```
extends CustomEnemyBase
class_name MortarBot

# ============================================================================
# Moerser-Bot — stationaerer Artillerie-Gegner.
# ============================================================================
# Bewegt sich nie. Feuert in festen Abstaenden eine Wurfparabel auf die
# AKTUELLE Position des Spielers zum Schusszeitpunkt. Der rote Bodenkreis
# markiert diesen Einschlagspunkt SOFORT (schwach), wird aber erst kurz vor
# dem Einschlag richtig kraeftig - deshalb bleibt er waehrend der ganzen
# Flugzeit exakt an derselben Stelle liegen, unabhaengig davon, wohin sich
# der Spieler danach bewegt. Wer beim Einschlag noch drinsteht, wird
# getroffen; wer rausdasht, nicht.
#
# Nutzt bewusst dieselbe "Telegraph bleibt am Ort, Schaden liest die
# Telegraph-Position und NICHT die aktuelle Spielerposition"-Regel wie
# Orbitalschlag/Lockdown in item_behaviours.gd (siehe dortiger Bugfix im
# Lockdown-Item - exakt derselbe Fehler waere hier genauso moeglich
# gewesen).

const DUST_RING_SCENE: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const SPARK_YELLOW_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")

## War 1.5, dann 4.5 ("jeder Gegner ausser Magnet soll 3x groesser sein").
## Rueckmeldung "Moerser-Bot um 15% verkleinern" (2026-08-12): 4.5 * 0.85.
const VISUAL_SCALE: float = 4.5 * 0.85
## Wie schnell sich der Moerser-Bot zum Spieler dreht (rad/s) - langsam
## genug, dass die Drehung als sichtbares "Zielen" wirkt statt als Snap.
const TURN_SPEED: float = 1.2

var fire_interval: float = 3.6
## War 1.3 - Rueckmeldung "Geschoss fliegt zu langsam". Bestimmt (zusammen
## mit der konstanten Flugdistanz) direkt die Geschwindigkeit: der Shell-
## Tween in _fire_at() legt dieselbe Strecke jetzt in gut halb so viel Zeit
## zurueck, also gut doppelt so schnell.
var flight_time: float = 0.6
## War 8.0 - in einem 14 Units hohen Kampfraum kratzte der Geschossbogen
## damit fast an der Decke ("Rueckmeldung: Moerser-Geschosse zu weit oben in
## der Luft"). Niedrigerer Bogen bleibt als Parabel klar lesbar, wirkt aber
## nicht mehr wie ein Steilfeuer bis unters Dach.
var arc_height: float = 4.0
var blast_radius: float = 4.2
var damage: float = 22.0
## War 45.0 - Rueckmeldung "Detection-Range extrem stark erhoehen, damit er
## den Spieler fast ueberall im Raum bemerkt". 500 deckt selbst den
## groessten aktuell moeglichen Mehrzellen-Raum (2x2-footprint * room_scale)
## komplett ab - in der Praxis heisst das "erkennt den Spieler, sobald er im
## selben Raum steht", was genau die Absicht ist.
var detect_range: float = 500.0

var _cooldown: float = 0.0
var _base_radius: float = 1.1


func _configure() -> void:
	display_name = "Moerser-Bot"
	max_health = 90.0


func _build() -> void:
	_build_visual()
	visual_root.scale = Vector3.ONE * VISUAL_SCALE
	_add_box_collision(Vector3(2.0, 2.2, 2.0) * VISUAL_SCALE, Vector3(0.0, 1.1, 0.0) * VISUAL_SCALE)
	_cooldown = fire_interval * randf_range(0.3, 1.0)

```
</details>

### 💭 Thinking: *I see there's already a previous reduction…*

`19:39:52`

<details>
<summary>Thinking...</summary>

> I see there's already a previous reduction applied to this element. Since the new feedback is asking for further downsizing and mentions "ein bisschen" (a little bit), I'll apply another modest scaling factor—around 12-15%—and add a new comment following the existing format to document this additional adjustment.…
</details>

#### 👀 Read `acid_sprinkler.gd`

`19:39:53`

*(lines 1–56)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\acid_sprinkler.gd</code></summary>

```
extends CustomEnemyBase
class_name AcidSprinkler

# ============================================================================
# Saeure-Sprinkler — stationaerer Gegner, fest im Boden verankert.
# ============================================================================
# Spuckt in festen Abstaenden ein Saeure-Geschoss auf die aktuelle Position
# des Spielers. Am Einschlagsort bleibt eine Pfuetze liegen (Area3D, exakt
# das gleiche Prinzip wie die Saeure-/Limonaden-Pfuetzen aus
# item_behaviours.gd::_spawn_puddle), die Steht-drin-Spieler per Tick den
# "acid"-Statuseffekt verpasst - NICHT das Geschoss selbst beim Vorbeiflug.
# Mehrere Pfuetzen ueberlappen sich mit der Zeit zu einem Bereich, den der
# Spieler aktiv meiden muss.

const ACID_TICK_INTERVAL: float = 0.5
const ACID_DAMAGE_PER_TICK: float = 5.0
const ACID_DURATION: float = 3.0

## Rueckmeldung "jeder Gegner ausser Magnet soll 3x groesser sein". Anders
## als mortar_bot.gd/etc. hatte dieser Gegner bisher gar keinen eigenen
## Skalierungsfaktor (Meshe direkt in Rohgroesse gebaut) - jetzt nachgeruestet,
## gleiches Muster wie die anderen CustomEnemyBase-Gegner.
const VISUAL_SCALE: float = 3.0

var fire_interval: float = 2.6
var flight_time: float = 0.7
var puddle_radius: float = 2.6
var puddle_lifetime: float = 6.0
## War 40.0 - Rueckmeldung "Detection-Range extrem stark erhoehen, damit er
## den Spieler fast ueberall im Raum bemerkt" (siehe mortar_bot.gd fuer
## dieselbe Aenderung/Begruendung).
var detect_range: float = 500.0

## Wie schnell sich der Saeure-Sprinkler zum Spieler dreht (rad/s) - langsam
## genug, dass die Drehung als sichtbares "Zielen" wirkt statt als Snap.
const TURN_SPEED: float = 1.2

var _cooldown: float = 0.0


func _configure() -> void:
	display_name = "Saeure-Sprinkler"
	max_health = 70.0


func _build() -> void:
	_build_visual()
	visual_root.scale = Vector3.ONE * VISUAL_SCALE
	_add_box_collision(Vector3(1.6, 1.8, 1.6) * VISUAL_SCALE, Vector3(0.0, 0.9, 0.0) * VISUAL_SCALE)
	_cooldown = fire_interval * randf_range(0.3, 1.0)


func _build_visual() -> void:
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = 0.7
```
</details>

### 💭 Thinking: *I'm mapping out the specific changes needed…*

`19:40:10`

<details>
<summary>Thinking...</summary>

> I'm mapping out the specific changes needed across the codebase: adjusting the minimap zoom setting from 1.80 to 1.60, scaling up the cooldown HUD in the ability bar with proper pivot offset, reducing the visual scale of both enemy types by about 15%, and updating the tutorial text content.
> 
> Now I need to rewrite the character descriptions with explicit button inputs and movement mechanics. I'll check the combat scripts for NingNing and Karina to get their exact attack patterns and button mappings, then update all four character descriptions to clearly explain their primary attacks (LMB), secondary abilities (RMB), and utility moves like dashing with Shift.
> 
> Since Q and E are item slots rather than character abilities, I should focus the tutorial text on the core combat mechanics: LMB for primary attacks, RMB for secondary attacks, and Shift for the universal dash that applies to all characters. The dash mechanic makes sense to introduce in NingNing's description since she's the starting character, establishing it as a foundational movement tool before players encounter other characters.…
</details>

#### 🔎 Grep `TutorialCharacterIntro|add_entry|tutorial_character_intro` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`19:40:11`

```
223:var _tutorial_ui: TutorialCharacterIntro = null
480:## scripts/ui/tutorial_character_intro.gd) - Ningning sofort, jeder weitere
484:	_tutorial_ui = TutorialCharacterIntro.new()
489:	_tutorial_ui.add_entry(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)
499:	_tutorial_ui.add_entry(data.character_name, TutorialContent.description_for(data))
```

### 💭 Thinking: *I'm confirming the structure: NingNing's…*

`19:40:17`

<details>
<summary>Thinking...</summary>

> I'm confirming the structure: NingNing's entry appears first at tutorial start with three other character entries, one per character, and…
</details>

#### 🔎 Grep `func _perform_primary|func _perform_secondary|func _poll_primary_input|func _poll_secondary_input` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_ningning.gd`

`19:40:18`

```
65:func _perform_secondary() -> void:
```

#### 👀 Read `combat_ningning.gd`

`19:40:21`

*(lines 1–101)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_ningning.gd</code></summary>

```

extends CombatBase
class_name CombatNingning

# Ningning: Brawler/Nahkampf mit starkem Burst-Potenzial.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: die "Zest Burst"/"Sour Storm"-Platzhalter (ability_q_cooldown/
# ability_e_cooldown + _perform_ability_q()/_perform_ability_e()) sind weg -
# Q/E loesen jetzt immer das aktive Item im jeweiligen Slot aus, siehe
# combat_base.gd.
#
# Primary "Quick Jab": sehr schneller, schwacher Schlag mit minimalem
# Cooldown, um Gegner im Stunlock zu halten - das Standardverhalten aus
# CombatBase._perform_primary() (kurzer Hitbox-Puls) passt dafuer schon
# unveraendert, nur der Cooldown und PrimaryHitbox.damage (siehe
# char_ningning.tscn) werden angepasst.
#
# Secondary "Heavy Haymaker": wuchtiger, aufgeladener Schlag mit Windup-
# Telegraphing und Knockback - dafuer _perform_secondary() unten
# ueberschrieben. SecondaryHitbox.damage/knockback_force sitzen weiterhin im
# Inspector (char_ningning.tscn), nicht hier - gleiche Konvention wie beim
# Primary.
func _init() -> void:
	primary_cooldown = 0.18
	secondary_cooldown = 3.0
	utility_cooldown = 0.8


const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")
const SLASH_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_slash_ningning.tscn")
const FIRE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_fire_ningning.tscn")

func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	
	if primary_hitbox:
		primary_hitbox.impact_vfx = HIT_VFX_SCENE
		primary_hitbox.swing_vfx = SLASH_VFX_SCENE
		var p_vis = primary_hitbox.get_node_or_null("Visual")
		if p_vis:
			p_vis.queue_free()
			
	if secondary_hitbox:
		secondary_hitbox.hit_landed.connect(_on_haymaker_hit)
		secondary_hitbox.impact_vfx = HIT_VFX_SCENE
		secondary_hitbox.swing_vfx = FIRE_VFX_SCENE
		var s_vis = secondary_hitbox.get_node_or_null("Visual")
		if s_vis:
			s_vis.queue_free()


func _on_haymaker_hit(_target: Node) -> void:
	Juice.impact(0.5, Juice.DURATION_HEAVY)


## Windup VOR der Hitbox-Aktivierung (Telegraphing) - der einzige Unterschied
## zum Standardverhalten aus CombatBase._perform_secondary(), das die Hitbox
## sofort aktiviert. Der Ghost-Trail-Burst aus _do_secondary() startet
## trotzdem schon beim Tastendruck (combat_base.gd steuert das, nicht hier),
## damit man den Windup optisch schon "einleitet" statt tot dazustehen.
func _perform_secondary() -> void:
	await get_tree().create_timer(0.35).timeout
	if secondary_hitbox:
		secondary_hitbox.activate()
		await get_tree().create_timer(0.3).timeout
		secondary_hitbox.deactivate()

```
</details>

### 💭 Thinking

`19:40:25`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_karina.gd`

`19:40:26`

*(lines 1–71)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd</code></summary>

```

extends CombatBase
class_name CombatKarina

# Karina: Melee/Assassin — Mobilitaet, Debuffs, Hit-and-Run-Executes.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind weg - Q/E loesen jetzt immer das
# aktive Item im jeweiligen Slot aus, siehe combat_base.gd.
#
# Beide Faehigkeiten sind reine Halte-/Toggle-Zustaende statt Hitbox-Treffer -
# PrimaryHitbox/SecondaryHitbox aus char_karina.tscn bleiben komplett
# ungenutzt im Baum (siehe combat_base.gd-Kopfkommentar zu diesem Muster).
# Primary hat bewusst KEINEN klassischen Schlag: die Stance IST der gesamte
# Primary-Angriff.

const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")

## --- Primary "Acid Rush Mode" -----------------------------------------------
@export var stance_speed_bonus_mul: float = 1.2
@export var stance_max_duration: float = 10.0
@export var stance_reentry_cooldown: float = 1.0
@export var acid_aura_radius: float = 3.0
## Auf Rueckmeldung ("7 Schaden, sehr schneller Tick") von 15/0.4s umgestellt
## - 70 statt vorher 37.5 DPS, deutlich schneller lesbares Tick-Feedback.
@export var acid_tick_interval: float = 0.1
@export var acid_damage_per_tick: float = 7.0
@export var acid_effect_duration: float = 2.0

## --- Secondary "Phantom Execute" ---------------------------------------------
@export var stealth_max_duration: float = 5.0
@export var stealth_reentry_cooldown: float = 5.0
## War 1.6 - Rueckmeldung "Vernetzung (Markieren) funktioniert manchmal
## nicht, Hitbox sollte grosszuegiger sein". Auf 2.6 angehoben.
@export var stealth_touch_radius: float = 2.6
## Nerf: war 220 - Rueckmeldung, dass die Verbindungs-/Detonationsschaeden
## auf allen markierten Gegnern zu stark waren. Siehe DECLOAK_EXPLOSION_
## DAMAGE fuer den separaten Explosions-Schaden beim Verlassen der Tarnung.
@export var detonation_damage: float = 100.0

const STANCE_MODIFIER_SOURCE: String = "karina_acid_rush"
## GeometryInstance3D.transparency (0=deckend, 1=unsichtbar) statt einzelne
## Material-Alpha-Werte umzubauen - funktioniert unabhaengig davon, welches
## Material das importierte Modell mitbringt, kein Material-Duplizieren
## noetig. Auf Rueckmeldung ("Deckkraft auf 4%") von 0.95 auf 0.96 (100%-4%)
## angehoben.
const STEALTH_MESH_TRANSPARENCY: float = 0.96
## War 0.15 - bei Karinas Lauftempo (~15-19 u/s) legt sie zwischen zwei
## Pruefungen bis zu ~2.85 Einheiten zurueck; bei einem Vorbeilaufen konnte
## das den Beruehrungs-Check komplett verpassen ("Vernetzung funktioniert
## manchmal nicht"). Auf 0.05 gesenkt (~20x/s statt ~6.7x/s).
const STEALTH_TOUCH_CHECK_INTERVAL: float = 0.05
## Motion-Blur-Trail (GhostTrail, siehe combat_base.gd) waehrend Phantom
## Execute auf 50% Staerke - deutlich ueber dem sehr dezenten Lauf-Trail-
## Default, siehe Rueckmeldung "motion blur trail auf 50%".
const STEALTH_TRAIL_ALPHA: float = 0.5

## "4x ihrer Groesse" fuer die Entladungs-Explosion beim Verlassen von
## Phantom Execute - CHARACTER_SIZE_ESTIMATE ist eine grobe Kapselgroesse
## als Basis, da keine exakte Charaktergroesse als Property existiert.
const DECLOAK_EXPLOSION_SIZE_MULTIPLIER: float = 4.0
const CHARACTER_SIZE_ESTIMATE: float = 2.0
## Nerf: bisher unausgesprochen Bomb.damage's Default (50) - jetzt explizit
## auf den gewuenschten Zielwert von 140 gesetzt statt implizit vom
## generischen Bomben-Default abzuhaengen, siehe _spawn_decloak_explosion().
const DECLOAK_EXPLOSION_DAMAGE: float = 140.0
```
</details>

### 🤖 Assistant: *This is a multi-part task, let me track it…*

`19:40:56`

<details>
<summary>Thinking...</summary>

> So Karina's abilities are locked in: her primary attack is Acid Rush Mode, a stance she can hold or toggle that surrounds her with an acidic aura dealing damage to nearby enemy, while her secondary ability is Phantom Execute, which grants temporary invisibility and marks enemy she touches during stealth, then detonates them when she breaks cover. This aligns with the existing character description mentioning her close-range acid combat and brief stealth mechanics.
> 
> Now I'm drafting detailed ability descriptions with explicit key bindings for the player. Starting with Ningning's description to include her basic combo attacks, charged heavy attack with knockback, and her dash ability using Shift—making sure to emphasize that dashing lets her cross obstacles and gaps, which was the specific request, while also noting that the dash mechanic pierces through enemy and deals damage in the process. Rounding out the character descriptions with Giselle's ranged combat mechanics and starting on Karina's melee approach. I'm debating whether to repeat the Shift-dash mechanic across all four character descriptions or consolidate it to avoid redundancy. Since players might only check whichever character they've unlocked, including it in each entry ensures they see the reminder regardless. I'll keep it in all four but emphasize it more in NingNing's description since that's the first one they encounter. I'm settling on a consistent approach: adding the same short dash mechanic note to all four character descriptions for uniformity. Now I need to verify the code structure uses the right description variables for each character—Ningning gets its explicit constant while the others pull from a description lookup function based on character ID. Let me double-check Karina's description text to ensure everything aligns. Continuing with the remaining edits: reducing visual scales for the mortar bot and acid sprinkler enemy, rewriting the four character descriptions in the tutorial content, creating a new ESP target singleton script, registering it as an autoload, and then…
</details>

> This is a multi-part task, let me track it properly and start applying the changes.

#### ToolSearch

`19:40:56`

**query:** `select:TaskCreate,TaskUpdate`

**max_results:** `5`

```json
[
  {
    "type": "tool_reference",
    "tool_name": "TaskCreate"
  },
  {
    "type": "tool_reference",
    "tool_name": "TaskUpdate"
  }
]
```

#### TaskCreate

`19:41:00`

- **Subject:** Rewrite tutorial character descriptions with key inputs + dash
- **Description:** scripts/tutorial_content.gd: rewrite NINGNING/GISELLE/KARINA/WINTER_DESCRIPTION with explicit LMB/RMB mentions and Shift-dash-over-obstacles note.

`#1` — Rewrite tutorial character descriptions with key inputs + dash

- **Subject:** Set minimap zoom default to 1.60
- **Description:** scripts/settings_manager.gd: MINIMAP_ZOOM_DEFAULT 1.80 -> 1.60

`#2` — Set minimap zoom default to 1.60

- **Subject:** Enlarge cooldown/ability HUD element
- **Description:** scenes/ui/hud.tscn: scale up the AbilityBar control (bottom-right cooldown UI), keep it pinned to the corner via pivot_offset.

`#3` — Enlarge cooldown/ability HUD element

- **Subject:** Shrink Mörser-Bot and Säure-Sprinkler models
- **Description:** scripts/enemies/mortar_bot.gd and scripts/enemies/acid_sprinkler.gd: reduce VISUAL_SCALE a bit further.

`#4` — Shrink Mörser-Bot and Säure-Sprinkler models

- **Subject:** Build singular global ESP indicator singleton
- **Description:** New autoload scripts/vfx/esp_target.gd holding exactly one Label3D+EnemyEspBox globally; register in project.godot.

`#5` — Build singular global ESP indicator singleton

- **Subject:** Migrate Winter's ESP (plasma+laser) to singular EspTarget
- **Description:** scripts/characters/combat_winter.gd: replace local _laser_esp_marker/_laser_esp_box and per-bolt plasma ESP boxes with calls into the EspTarget autoload.

`#6` — Migrate Winter's ESP (plasma+laser) to singular EspTarget

- **Subject:** Migrate Giselle's ESP (uzi+sniper) to singular EspTarget
- **Description:** scripts/characters/combat_giselle.gd: replace local _uzi_esp_*/_sniper_esp_box with calls into the EspTarget autoload.

`#7` — Migrate Giselle's ESP (uzi+sniper) to singular EspTarget

### 💭 Thinking

`19:41:08`

<details>
<summary>Thinking...</summary>

> 
</details>

#### TaskUpdate

`19:41:08`

`#1` · **status:** `in_progress`

✓ Updated `#1` — `status`

#### ✏️  Edit `tutorial_content.gd`

`19:41:19`

```diff
@@ -1,4 +1,11 @@-const NINGNING_DESCRIPTION: String = "Ningning: Close-Range-Kämpferin (Schläge & Explosionen)."
-const GISELLE_DESCRIPTION: String = "Giselle: 2 Waffen mit Auto-Aim."
-const KARINA_DESCRIPTION: String = "Karina kämpft im Nahkampf mit ätzender Säure und wird kurz unsichtbar, um mehrere Gegner zu markieren und gleichzeitig per Explosion zu richten."
-const WINTER_DESCRIPTION: String = "Winter kontrolliert die Distanz mit homing Plasma-Geschossen und einem Dauer-Laserstrahl."
+## Rueckmeldung "Tutorial-Texte sollen Tasten-Inputs erwaehnen und die
+## Dash-Mechanik erklaeren" (2026-08-13): alle vier Beschreibungen nennen
+## jetzt explizit LMB/RMB fuer die beiden Waffen des jeweiligen Charakters,
+## plus einen Hinweis auf die (charakterunabhaengige, siehe combat_base.gd)
+## Shift-Dash-Mechanik - Q/E bleiben bewusst unerwaehnt, die sind laut
+## CLAUDE.md keine Charakter-Faehigkeiten, sondern die beiden aktiven
+## Item-Slots.
+const NINGNING_DESCRIPTION: String = "Ningning: Nahkämpferin mit Schlagkombos und Explosionen. Drücke LMB [Linke Maustaste] für schnelle Jabs, halte RMB [Rechte Maustaste] für einen aufgeladenen Wuchtschlag mit Knockback. Mit Shift dashst du über Hindernisse hinweg - auch durch Gegner hindurch, was zusätzlich Schaden macht."
+const GISELLE_DESCRIPTION: String = "Giselle: Fernkämpferin mit zwei automatisch zielenden Waffen. Halte LMB [Linke Maustaste] für die Uzi-Dauerfeuer-Salve, halte RMB [Rechte Maustaste] zum Einzoomen und lass los für einen tödlichen Sniper-Burst. Mit Shift dashst du über Hindernisse hinweg."
+const KARINA_DESCRIPTION: String = "Karina kämpft im Nahkampf mit ätzender Säure und wird kurz unsichtbar, um mehrere Gegner zu markieren und per Explosion zu richten. Halte LMB [Linke Maustaste] für die Säure-Aura um sie herum, halte RMB [Rechte Maustaste] für die Tarnung. Mit Shift dashst du über Hindernisse hinweg."
+const WINTER_DESCRIPTION: String = "Winter kontrolliert die Distanz mit homing Plasma-Geschossen und einem Dauer-Laserstrahl. Drücke LMB [Linke Maustaste] für die Plasma-Geschosse, halte RMB [Rechte Maustaste] für den Laserstrahl. Mit Shift dashst du über Hindernisse hinweg."
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### TaskUpdate

`19:41:21`

`#1` · **status:** `completed`

✓ Updated `#1` — `status`

`#2` · **status:** `in_progress`

✓ Updated `#2` — `status`

#### 👀 Read `settings_manager.gd`

`19:41:22`

*(lines 110–125)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\settings_manager.gd</code></summary>

```
# Die Grenzen leben hier und nicht im Einstellungsmenue, damit Slider-Range
# und der Clamp beim Laden aus der Config garantiert dieselbe Quelle haben.

const MINIMAP_ZOOM_MIN: float = 0.4
const MINIMAP_ZOOM_MAX: float = 3.0
## Von 1.0 auf 1.80 angehoben. NICHT zu verwechseln mit
## MINIMAP_UI_SCALE_DEFAULT: ui_scale vergroessert das HUD-Element,
## zoom veraendert den WELT-Ausschnitt der Kamera darin. Der Auto-Zoom
## (minimap.gd) wirkt als Basisgroesse, dieser Regler bleibt der Teiler
## darauf.
const MINIMAP_ZOOM_DEFAULT: float = 1.80

const MINIMAP_UI_SCALE_MIN: float = 0.6
const MINIMAP_UI_SCALE_MAX: float = 1.8
## Von 1.0 auf 1.35 angehoben — die Karte war in der Standardgroesse zu
```
</details>

#### ✏️  Edit `settings_manager.gd`

`19:41:27`

```diff
@@ -1,6 +1,6 @@-## Von 1.0 auf 1.80 angehoben. NICHT zu verwechseln mit
-## MINIMAP_UI_SCALE_DEFAULT: ui_scale vergroessert das HUD-Element,
-## zoom veraendert den WELT-Ausschnitt der Kamera darin. Der Auto-Zoom
-## (minimap.gd) wirkt als Basisgroesse, dieser Regler bleibt der Teiler
-## darauf.
-const MINIMAP_ZOOM_DEFAULT: float = 1.80
+## Von 1.0 auf 1.80, dann per Rueckmeldung (2026-08-13) auf 1.60 gesenkt.
+## NICHT zu verwechseln mit MINIMAP_UI_SCALE_DEFAULT: ui_scale vergroessert
+## das HUD-Element, zoom veraendert den WELT-Ausschnitt der Kamera darin.
+## Der Auto-Zoom (minimap.gd) wirkt als Basisgroesse, dieser Regler bleibt
+## der Teiler darauf.
+const MINIMAP_ZOOM_DEFAULT: float = 1.60
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\settings_manager.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:41:31`

<details>
<summary>Thinking...</summary>

> 
</details>

#### TaskUpdate

`19:41:31`

`#2` · **status:** `completed`

✓ Updated `#2` — `status`

`#3` · **status:** `in_progress`

#### 👀 Read `hud.tscn`

`19:41:32`

*(lines 1–21)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn</code></summary>

```
[gd_scene format=3 uid="uid://bhudmain001"]

[ext_resource type="Script" uid="uid://culscy051p2da" path="res://scripts/hud.gd" id="1_hud"]
[ext_resource type="Script" uid="uid://d4gd2xp04d7we" path="res://scripts/minimap.gd" id="2_minimap"]
[ext_resource type="PackedScene" uid="uid://bpartyslot01" path="res://scenes/party_slot.tscn" id="3_pslot"]
[ext_resource type="Texture2D" uid="uid://bd0s34jsplqb6" path="res://assets/textures/ui/image-removebg-preview (13).png" id="3_uo2fv"]
[ext_resource type="PackedScene" uid="uid://bablslot001" path="res://scenes/ui/ability_slot.tscn" id="4_abslot"]
[ext_resource type="Script" uid="uid://cr7ee7rme3mat" path="res://scripts/run_timer.gd" id="5_timer"]
[ext_resource type="Script" uid="uid://eabq6wxgfv3a" path="res://scripts/items/item_description_hud.gd" id="6_itemhud"]
[ext_resource type="Script" uid="uid://c40hh6d6mnfdi" path="res://scripts/stats_panel.gd" id="7_stats"]
[ext_resource type="Script" uid="uid://bouy7cn5am2oe" path="res://scripts/ui/boss_health_bar.gd" id="11_4d46k"]
[ext_resource type="Script" path="res://scripts/ui/low_hp_vignette.gd" id="12_lowhp"]
[ext_resource type="Script" path="res://scripts/ui/plasma_darkness_overlay.gd" id="13_plasmadark"]

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_mapframe"]
bg_color = Color(0.06, 0.06, 0.09, 0.82)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
```
</details>

### 💭 Thinking: *I'm adjusting the AbilityBar node to scale…*

`19:41:38`

<details>
<summary>Thinking...</summary>

> I'm adjusting the AbilityBar node to scale up toward the top-left while staying anchored at the bottom-right corner. Based on the computed dimensions (360×84), I'll set the scale to 1.3 on both axes and position the pivot offset at the bottom-right corner of the local rectangle so it expands in the right direction.…
</details>

#### ✏️  Edit `hud.tscn`

`19:41:43`

```diff
@@ -12,3 +12,12 @@ grow_horizontal = 0
 grow_vertical = 0
 mouse_filter = 2
+# Rueckmeldung "Cooldown-HUD unten rechts ist zu klein" (2026-08-13): um 30%
+# vergroessert. pivot_offset sitzt auf der UNTEREN RECHTEN Ecke des lokalen
+# Rects (= Groesse aus offset_right-offset_left/offset_bottom-offset_top
+# oben, 360x84) statt der Standard-Ecke oben links - dadurch waechst die
+# Bar beim Skalieren nach oben/links Richtung Bildschirmmitte und bleibt
+# exakt an derselben Bildschirmecke haengen, statt ueber den Bildschirmrand
+# hinauszuwachsen.
+pivot_offset = Vector2(360, 84)
+scale = Vector2(1.3, 1.3)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:41:45`

<details>
<summary>Thinking...</summary>

> 
</details>

#### TaskUpdate

`19:41:46`

`#3` · **status:** `completed`

✓ Updated `#3` — `status`

`#4` · **status:** `in_progress`

✓ Updated `#4` — `status`

#### ✏️  Edit `mortar_bot.gd`

`19:41:49`

```diff
@@ -1,3 +1,5 @@ ## War 1.5, dann 4.5 ("jeder Gegner ausser Magnet soll 3x groesser sein").
 ## Rueckmeldung "Moerser-Bot um 15% verkleinern" (2026-08-12): 4.5 * 0.85.
-const VISUAL_SCALE: float = 4.5 * 0.85
+## Rueckmeldung "Moerser-Bot ist noch zu gross" (2026-08-13): nochmal um
+## 15% verkleinert.
+const VISUAL_SCALE: float = 4.5 * 0.85 * 0.85
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\mortar_bot.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `acid_sprinkler.gd`

`19:41:53`

```diff
@@ -2,4 +2,6 @@ ## als mortar_bot.gd/etc. hatte dieser Gegner bisher gar keinen eigenen
 ## Skalierungsfaktor (Meshe direkt in Rohgroesse gebaut) - jetzt nachgeruestet,
 ## gleiches Muster wie die anderen CustomEnemyBase-Gegner.
-const VISUAL_SCALE: float = 3.0
+## Rueckmeldung "Saeure-Sprinkler ist zu gross" (2026-08-13): um 15%
+## verkleinert, gleiche Groessenordnung wie mortar_bot.gd's Korrektur.
+const VISUAL_SCALE: float = 3.0 * 0.85
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\acid_sprinkler.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the ESP singleton — the biggest piece…*

`19:41:56`

> Now the ESP singleton — the biggest piece.

#### TaskUpdate

`19:41:56`

`#4` · **status:** `completed`

✓ Updated `#4` — `status`

`#5` · **status:** `in_progress`

✓ Updated `#5` — `status`

### 💭 Thinking

`19:41:59`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✍️  Write `esp_target.gd`

`19:42:18`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\esp_target.gd</code></summary>

```
extends Node

# ============================================================================
# EspTarget — Autoload: projektweiter Singular-ESP-Indikator.
# ============================================================================
# Rueckmeldung (2026-08-13) "ESP bei Winter/Giselle: manchmal mehrere Kaesten
# auf demselben Gegner, verschwindet nicht immer beim Tod - soll auf GENAU
# EINEN Indikator im ganzen Spiel vereinfacht werden, der springt, statt
# dass jede Waffe ihren eigenen mitschleppt".
#
# Vorher hielt jedes Waffensystem (combat_giselle.gd::_uzi_esp_*/
# _sniper_esp_box, combat_winter.gd::_laser_esp_*/ein esp_box PRO Plasma-
# Bolt) seinen EIGENEN Label3D+EnemyEspBox. Zwei gleichzeitig aktive Waffen
# (z.B. Winters gehaltener Laser UND ihr Plasma-Primary) oder mehrere
# schnelle Treffer auf denselben Gegner konnten dadurch mehrere Kaesten
# gleichzeitig erzeugen - und ein Kasten verschwand nur, wenn GENAU die
# Waffe, die ihn gebaut hatte, das selbst bemerkte (z.B. erst beim naechsten
# Schuss, nicht sofort beim Tod).
#
# Dieser Autoload ersetzt das: es gibt hier genau EIN Label3D + EINE
# EnemyEspBox, nie mehr. Jedes Waffensystem meldet per acquire() sein
# gerade anvisiertes Ziel - der zuletzt aufgerufene Aufruf "gewinnt" den
# Indikator (in der Praxis: das Ziel, auf das aktuell tatsaechlich gehalten/
# geschossen wird). _process() prueft JEDEN Frame die Lebendigkeit des
# aktuellen Ziels, unabhaengig davon, welche Waffe gerade feuert - das ist
# der eigentliche Fix fuer "verschwindet nicht immer beim Tod".

var _target: Node3D = null
var _marker: Label3D = null
var _box: EnemyEspBox = null


## Meldet "target" als das aktuell anvisierte Ziel des Aufrufers an. Baut
## nur neu, wenn sich das Ziel tatsaechlich aendert - ein Aufruf mit
## demselben Ziel jeden Frame (z.B. Winters Laser) rebuilded also nichts,
## nur _process() unten haelt die Position aktuell.
func acquire(target: Node3D, color: Color) -> void:
	if target == null or not is_instance_valid(target) or not _is_alive(target):
		return
	if target == _target:
		return

	_clear()
	_target = target
	_marker = _build_marker(color)
	get_tree().current_scene.add_child(_marker)
	_box = EnemyEspBox.build_for(target, color)
	get_tree().current_scene.add_child(_box)
	_reposition()


## Raeumt den Indikator NUR auf, wenn "target" auch tatsaechlich das gerade
## angezeigte Ziel ist - so kann ein Waffensystem, das gerade kein eigenes
## Ziel mehr hat (z.B. LMB losgelassen), niemals versehentlich den
## Indikator eines ANDEREN, noch aktiven Waffensystems mitreissen.
func release(target: Node3D) -> void:
	if target != null and target == _target:
		_clear()


## Kurzer Aufleucht-Puls bei einem tatsaechlichen Treffer - no-op, falls
## "target" gerade gar nicht der angezeigte Indikator ist (z.B. Winters
## Plasma trifft ein Zweit-Ziel, das gar keinen eigenen Kasten mehr hat).
func flash(target: Node3D) -> void:
	if target != null and target == _target and _box != null and is_instance_valid(_box):
		_box.flash()


func _process(_delta: float) -> void:
	if _target == null:
		return
	if not is_instance_valid(_target) or not _is_alive(_target):
		_clear()
		return
	_reposition()


func _is_alive(target: Node3D) -> bool:
	var health: Node = target.find_child("Health", true, false)
	return health != null and health is Health and (health as Health).is_alive()


func _reposition() -> void:
	if _marker != null and is_instance_valid(_marker):
		_marker.global_position = _target.global_position + Vector3.UP * 2.2
	if _box != null and is_instance_valid(_box):
		_box.global_position = _target.global_position + Vector3.UP * (_box.size.y * 0.5)


func _clear() -> void:
	if _marker != null and is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null
	if _box != null and is_instance_valid(_box):
		_box.queue_free()
	_box = null
	_target = null


func _build_marker(color: Color) -> Label3D:
	var label := Label3D.new()
	label.text = "◆"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 72
	label.outline_size = 14
	label.modulate = color
	label.outline_modulate = Color(color.r * 0.2, color.g * 0.2, color.b * 0.2, 0.9)
	return label

```
</details>

✓ File created successfully at: C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\esp_target.gd (file state is current in your context — no need to Read it back)

### 🤖 Assistant: *Now register it as an autoload in project…*

`19:42:20`

> Now register it as an autoload in project.godot:

#### ✏️  Edit `project.godot`

`19:42:21`

```diff
@@ -1 +1,2 @@ TutorialFlow="*res://scripts/tutorial_flow.gd"
+EspTarget="*res://scripts/vfx/esp_target.gd"
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\project.godot has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:42:23`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `CLAUDE.md`

`19:42:25`

```diff
@@ -1 +1,2 @@ | `Teleporter` | `scripts/debug_teleporter.gd` | debug teleport pads (incl. sandbox rooms) |
+| `EspTarget` | `scripts/vfx/esp_target.gd` | singular projectwide "ESP" enemy-highlight indicator (Winter/Giselle auto-target visuals) |
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\CLAUDE.md has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### TaskUpdate

`19:42:28`

`#5` · **status:** `completed`

✓ Updated `#5` — `status`

`#6` · **status:** `in_progress`

✓ Updated `#6` — `status`

### 🤖 Assistant: *Now let's migrate Winter's ESP code.*

`19:42:30`

> Now let's migrate Winter's ESP code.

#### ✏️  Edit `combat_winter.gd`

`19:42:32`

```diff
@@ -1,5 +1 @@ var _laser_locked_target: Node3D = null
-var _laser_esp_marker: Label3D = null
-## Kastenumriss um das gelockte Ziel, siehe scripts/vfx/enemy_esp_box.gd -
-## leuchtet bei jedem Schadens-Tick kurz auf (_update_laser()).
-var _laser_esp_box: EnemyEspBox = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:42:35`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_winter.gd`

`19:42:44`

```diff
@@ -1,36 +1,21 @@ 	var primary_target = targets[0]
 	_lock_model_to(primary_target)
-	
+	# EspTarget statt einer eigenen Box PRO Ziel (Plasma kann bis zu
+	# plasma_bolt_count Gegner gleichzeitig anfliegen): nur das primaere
+	# (naechste) Ziel bekommt den EINEN projektweiten Indikator, siehe
+	# scripts/vfx/esp_target.gd-Kopfkommentar.
+	EspTarget.acquire(primary_target, color)
+
 	var dir = (primary_target.global_position + Vector3.UP - origin).normalized()
 	var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
 	_spawn_muzzle_vfx(muzzle_pos, dir)
 
 	for target: Node3D in targets:
-		# ESP-Box PRO ZIEL, nicht ein einzelnes gelocktes Ziel wie bei Uzi/
-		# Sniper/Laser: Plasma kann bis zu plasma_bolt_count Gegner
-		# gleichzeitig anfliegen. Kurzlebig statt "gelockt, bis es
-		# wegfaellt" - passt zum Ein-Schuss-Charakter jedes einzelnen Bolts.
-		var esp_box: EnemyEspBox = EnemyEspBox.build_for(target, color)
-		get_tree().current_scene.add_child(esp_box)
-		esp_box.global_position = target.global_position + Vector3.UP * (esp_box.size.y * 0.5)
-
 		var on_strike: Callable = func(hit_target: Node3D) -> void:
-			_on_plasma_strike(hit_target, origin, dmg, esp_box)
+			_on_plasma_strike(hit_target, origin, dmg)
 
 		var bolt: HomingBolt = HomingBolt.spawn(
 			self, origin, target, color, on_strike, plasma_bolt_speed, plasma_bolt_lifetime, false, player
 		)
 		if bolt:
 			_attach_plasma_trail(bolt, color)
-		else:
-			esp_box.queue_free()
-
-		# Sicherheitsnetz: stirbt/entkommt das Ziel, bevor der Bolt trifft,
-		# feuert HomingBolt._strike() (und damit der on_strike-Callback,
-		# der die Box sonst aufraeumt) nie - die Box wuerde sonst dauerhaft
-		# haengen bleiben.
-		get_tree().create_timer(plasma_bolt_lifetime + 0.1).timeout.connect(
-			func() -> void:
-				if is_instance_valid(esp_box):
-					esp_box.queue_free()
-		)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,12 +1,7 @@-func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float, esp_box: EnemyEspBox = null) -> void:
-	if esp_box != null and is_instance_valid(esp_box):
-		esp_box.flash()
-		# Kurz nach dem Aufblitzen aufraeumen statt sofort - der Puls soll
-		# noch sichtbar sein, bevor die Box mit dem Bolt zusammen verschwindet.
-		get_tree().create_timer(EnemyEspBox.FLASH_DURATION).timeout.connect(
-			func() -> void:
-				if is_instance_valid(esp_box):
-					esp_box.queue_free()
-		)
+func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float) -> void:
+	# No-op, falls "target" gerade nicht der angezeigte EspTarget-Indikator
+	# ist (z.B. ein Zweit-Bolt auf ein Ziel ohne eigenen Kasten) - siehe
+	# scripts/vfx/esp_target.gd::flash().
+	EspTarget.flash(target)
 
 	if not is_instance_valid(target):
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:42:53`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`19:42:54`

*(lines 280–380)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```
		# Deutlich dicker als vorher (0.7 -> 1.3) - ein duenner Strahl liest
		# sich als schwacher Laserpointer statt als "Heavy Laser Stream".
		_laser_beam = BeamVisual.create(self, color, 1.3)

	BeamVisual.update(_laser_beam, origin, result["position"], delta)


func _stop_laser() -> void:
	BeamVisual.free_beam(_laser_beam)
	_laser_beam = {}
	_laser_tick_timer = 0.0
	_clear_laser_esp()


## BUGFIX "Strahl sieht aus wie einzelne Kugeln statt wie ein durchgehender
## Strahl (wie bei der Schild-Drohne)": ohne Sticky-Targeting waehlte
## best_target_in_cone() JEDEN Frame neu den "besten" Gegner - stehen mehrere
## nah beieinander, kann das Ergebnis frame-zu-frame kippen, und der
## Strahl-Endpunkt springt zwischen ihnen hin und her statt ruhig auf einem
## Ziel zu stehen. Jetzt wird das aktuelle Ziel gehalten, solange es lebt,
## in Reichweite ist und noch (grosszuegiger als der Such-Kegel, damit es
## nicht direkt an der Kegelgrenze flackert) im Blickfeld liegt - neu gesucht
## wird nur, wenn es wirklich wegfaellt.
func _resolve_laser_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _laser_locked_target != null and is_instance_valid(_laser_locked_target):
		var health: Node = _laser_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_laser_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= laser_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(laser_target_cone_deg * 1.5)
		if alive and in_range and in_cone:
			return _laser_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, laser_range, laser_target_cone_deg)


## Gleiches Muster wie combat_giselle.gd::_update_uzi_esp() - Label3D
## (billboard + no_depth_test) PLUS EnemyEspBox-Kastenumriss ueber dem gerade
## automatisch anvisierten Ziel.
func _update_laser_esp(target: Node3D) -> void:
	if target == _laser_locked_target and target != null and is_instance_valid(target):
		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
			_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)
		return

	_clear_laser_esp()
	_laser_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_laser_esp_marker = _build_laser_esp_marker()
	get_tree().current_scene.add_child(_laser_esp_marker)
	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2

	_laser_esp_box = EnemyEspBox.build_for(target, laser_esp_color)
	get_tree().current_scene.add_child(_laser_esp_box)
	_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)


func _clear_laser_esp() -> void:
	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
		_laser_esp_marker.queue_free()
	_laser_esp_marker = null
	if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
		_laser_esp_box.queue_free()
	_laser_esp_box = null
	_laser_locked_target = null


func _build_laser_esp_marker() -> Label3D:
	var label := Label3D.new()
	label.text = "◆"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 72
	label.outline_size = 14
	label.modulate = laser_esp_color
	label.outline_modulate = Color(laser_esp_color.r * 0.2, laser_esp_color.g * 0.2, laser_esp_color.b * 0.2, 0.9)
	return label


func get_laser_energy_percent() -> float:
	return _laser_energy / laser_max_charge if laser_max_charge > 0.0 else 0.0


## _laser_beam und _laser_esp_marker haengen unter current_scene, nicht unter
## diesem Combat-Node - ueberleben einen Charakterwechsel also nicht
## automatisch (gleicher Grund wie combat_giselle.gd::_exit_tree()).
func _exit_tree() -> void:
	_stop_laser()


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
# _damage_multiplier() und _lock_model_to() leben jetzt in combat_base.gd
# (identisch dupliziert in Giselle/Karina/Winter - siehe dortige Kommentare).
```
</details>

#### ✏️  Edit `combat_winter.gd`

`19:43:05`

```diff
@@ -1,48 +1,18 @@-## Gleiches Muster wie combat_giselle.gd::_update_uzi_esp() - Label3D
-## (billboard + no_depth_test) PLUS EnemyEspBox-Kastenumriss ueber dem gerade
-## automatisch anvisierten Ziel.
+## _laser_locked_target bleibt weiterhin das Sticky-Targeting-Gedaechtnis
+## fuer _resolve_laser_target() - die eigentliche Anzeige laeuft jetzt ueber
+## den projektweiten Singular-Indikator, siehe scripts/vfx/esp_target.gd.
 func _update_laser_esp(target: Node3D) -> void:
-	if target == _laser_locked_target and target != null and is_instance_valid(target):
-		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
-			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
-		if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
-			_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)
+	if target == null or not is_instance_valid(target):
+		_clear_laser_esp()
 		return
-
-	_clear_laser_esp()
 	_laser_locked_target = target
-	if target == null or not is_instance_valid(target):
-		return
-
-	_laser_esp_marker = _build_laser_esp_marker()
-	get_tree().current_scene.add_child(_laser_esp_marker)
-	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
-
-	_laser_esp_box = EnemyEspBox.build_for(target, laser_esp_color)
-	get_tree().current_scene.add_child(_laser_esp_box)
-	_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)
+	EspTarget.acquire(target, laser_esp_color)
 
 
 func _clear_laser_esp() -> void:
-	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
-		_laser_esp_marker.queue_free()
-	_laser_esp_marker = null
-	if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
-		_laser_esp_box.queue_free()
-	_laser_esp_box = null
+	if _laser_locked_target != null:
+		EspTarget.release(_laser_locked_target)
 	_laser_locked_target = null
 
 
-func _build_laser_esp_marker() -> Label3D:
-	var label := Label3D.new()
-	label.text = "◆"
-	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
-	label.no_depth_test = true
-	label.font_size = 72
-	label.outline_size = 14
-	label.modulate = laser_esp_color
-	label.outline_modulate = Color(laser_esp_color.r * 0.2, laser_esp_color.g * 0.2, laser_esp_color.b * 0.2, 0.9)
-	return label
-
-
 func get_laser_energy_percent() -> float:
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:43:08`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`19:43:08`

*(lines 255–285)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```
	var do_damage: bool = _laser_tick_timer <= 0.0
	var dmg: float = laser_damage_per_tick * _damage_multiplier() if do_damage else 0.0
	var dns: PackedScene = (secondary_hitbox.damage_number_scene if secondary_hitbox else null) if do_damage else null

	# EIN Raycast pro Frame bedient beides: Schadenstick (nur wenn faellig)
	# UND die visuelle Strahl-Endposition (jeden Frame, damit der sichtbare
	# Strahl nicht zwischen zwei Ticks am alten Trefferpunkt "klebt").
	var result: Dictionary = Hitscan.fire(self, origin, dir, laser_range, dmg, player, dns)

	if do_damage:
		_laser_tick_timer = laser_tick_interval
		if result["hit"]:
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			# Leichtes Dauer-Rattern statt eines einzelnen Shakes - passt
			# besser zu einem Dauerstrahl als ein einmaliger Ausschlag und
			# macht spuerbar, dass der Strahl laufend Schaden macht statt
			# nur huebsch auszusehen (Rueckmeldung "sieht schwach aus").
			if player and player.has_method("shake_camera"):
				player.shake_camera(0.06)
			if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
				_laser_esp_box.flash()

	if _laser_beam.is_empty():
		var data: CharacterData = PartyManager.get_active_data()
		var color: Color = data.attack_color if data else Color(0.5, 0.9, 1.0)
		# Deutlich dicker als vorher (0.7 -> 1.3) - ein duenner Strahl liest
		# sich als schwacher Laserpointer statt als "Heavy Laser Stream".
		_laser_beam = BeamVisual.create(self, color, 1.3)

	BeamVisual.update(_laser_beam, origin, result["position"], delta)
```
</details>

#### ✏️  Edit `combat_winter.gd`

`19:43:13`

```diff
@@ -1,4 +1,3 @@ 			if player and player.has_method("shake_camera"):
 				player.shake_camera(0.06)
-			if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
-				_laser_esp_box.flash()
+			EspTarget.flash(target)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:43:16`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`19:43:16`

*(lines 218–258)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```
		elif not _laser_beam.is_empty():
			_stop_laser()
		return

	if not _laser_beam.is_empty():
		_stop_laser()

	# Kein Mindest-Schwellenwert: die Formel selbst sorgt schon dafuer, dass
	# ein Teil-Ladezustand sofort wieder nutzbar ist, statt erst komplett
	# vollladen zu muessen ("partial charge = partial use" laut Spec).
	_laser_energy = minf(_laser_energy + delta * (laser_max_charge / laser_recharge_time), laser_max_charge)


func _update_laser(delta: float) -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung, siehe combat_giselle.gd.
	# Auto-Target statt weichem Aim-Assist (Rueckmeldung "wie bei Giselles
	# Uzi"): breiter Blickkegel, direkter Schuss aufs gefundene Ziel statt auf
	# die rohe Blickrichtung. Ohne Ziel im Kegel faellt der Strahl auf die
	# reine Blickrichtung zurueck.
	var look_dir: Vector3 = -_camera.global_transform.basis.z
	var target: Node3D = _resolve_laser_target(origin, look_dir)
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_laser_esp(target)
	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man
	# schiesst" - vorher haengte _lock_model_to() weiter unten nur am
	# tatsaechlichen Schadens-Tick (do_damage UND hit), der Strahl feuert
	# aber jeden Frame; das Modell blieb zwischen zwei Ticks stehen.
	if target != null:
		_lock_model_to(target)

	_laser_tick_timer -= delta
	var do_damage: bool = _laser_tick_timer <= 0.0
	var dmg: float = laser_damage_per_tick * _damage_multiplier() if do_damage else 0.0
	var dns: PackedScene = (secondary_hitbox.damage_number_scene if secondary_hitbox else null) if do_damage else null
```
</details>

### 🤖 Assistant: *Good, `target` is in scope.*

`19:43:20`

> Good, `target` is in scope. Now let's verify `_exit_tree()` still calls `_stop_laser()` (which calls `_clear_laser_esp()`), confirming cleanup on character switch works.

#### 🔎 Grep `_laser_esp|esp_box` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd`

`19:43:21`

```
246:	_update_laser_esp(target)
290:	_clear_laser_esp()
319:func _update_laser_esp(target: Node3D) -> void:
321:		_clear_laser_esp()
327:func _clear_laser_esp() -> void:
337:## _laser_beam und _laser_esp_marker haengen unter current_scene, nicht unter
```

### 💭 Thinking

`19:43:24`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`19:43:25`

*(lines 332–342)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```

func get_laser_energy_percent() -> float:
	return _laser_energy / laser_max_charge if laser_max_charge > 0.0 else 0.0


## _laser_beam und _laser_esp_marker haengen unter current_scene, nicht unter
## diesem Combat-Node - ueberleben einen Charakterwechsel also nicht
## automatisch (gleicher Grund wie combat_giselle.gd::_exit_tree()).
func _exit_tree() -> void:
	_stop_laser()
```
</details>

#### ✏️  Edit `combat_winter.gd`

`19:43:30`

```diff
@@ -1,5 +1,6 @@-## _laser_beam und _laser_esp_marker haengen unter current_scene, nicht unter
-## diesem Combat-Node - ueberleben einen Charakterwechsel also nicht
-## automatisch (gleicher Grund wie combat_giselle.gd::_exit_tree()).
+## _laser_beam haengt unter current_scene, nicht unter diesem Combat-Node -
+## ueberlebt einen Charakterwechsel also nicht automatisch (gleicher Grund
+## wie combat_giselle.gd::_exit_tree()). _stop_laser() gibt zusaetzlich den
+## EspTarget-Indikator frei, falls dieser Laser ihn gerade haelt.
 func _exit_tree() -> void:
 	_stop_laser()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Winter is done.*

`19:43:32`

> Winter is done. Now Giselle.

#### TaskUpdate

`19:43:33`

`#6` · **status:** `completed`

✓ Updated `#6` — `status`

`#7` · **status:** `in_progress`

✓ Updated `#7` — `status`

#### ✏️  Edit `combat_giselle.gd`

`19:43:37`

```diff
@@ -1,7 +1,4 @@ var _uzi_locked_target: Node3D = null
-var _uzi_esp_marker: Label3D = null
-var _uzi_esp_box: EnemyEspBox = null
 
 var _sniper_charging: bool = false
 var _sniper_locked_target: Node3D = null
-var _sniper_esp_box: EnemyEspBox = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now update the Uzi hit-flash call, `_update_uzi_esp…*

`19:43:39`

> Now update the Uzi hit-flash call, `_update_uzi_esp`, `_clear_uzi_esp`, and remove `_build_esp_marker`:

#### ✏️  Edit `combat_giselle.gd`

`19:43:42`

```diff
@@ -2,5 +2,4 @@ 		VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
 		if player and player.has_method("shake_camera"):
 			player.shake_camera(0.18)
-		if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
-			_uzi_esp_box.flash()
+		EspTarget.flash(target)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:43:45`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_giselle.gd`

`19:43:55`

```diff
@@ -1,47 +1,15 @@-## Haelt einen Label3D-Marker UND eine EnemyEspBox (Kastenumriss, siehe
-## scripts/vfx/enemy_esp_box.gd) ueber dem gerade automatisch anvisierten
-## Ziel fest - das ist das in der Rueckmeldung verlangte "ESP" auf den
-## beschossenen Gegner. no_depth_test sorgt dafuer, dass der Marker auch
-## durch Gegner/Deckung hindurch klar lesbar bleibt, nicht nur durch Waende.
+## _uzi_locked_target bleibt das Sticky-Targeting-Gedaechtnis fuer
+## _resolve_uzi_target() - die Anzeige selbst laeuft ueber den
+## projektweiten Singular-Indikator, siehe scripts/vfx/esp_target.gd.
 func _update_uzi_esp(target: Node3D) -> void:
-	if target == _uzi_locked_target and target != null and is_instance_valid(target):
-		if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
-			_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
-		if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
-			_uzi_esp_box.global_position = target.global_position + Vector3.UP * (_uzi_esp_box.size.y * 0.5)
+	if target == null or not is_instance_valid(target):
+		_clear_uzi_esp()
 		return
-
-	_clear_uzi_esp()
 	_uzi_locked_target = target
-	if target == null or not is_instance_valid(target):
-		return
-
-	_uzi_esp_marker = _build_esp_marker()
-	get_tree().current_scene.add_child(_uzi_esp_marker)
-	_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
-
-	_uzi_esp_box = EnemyEspBox.build_for(target, uzi_esp_color)
-	get_tree().current_scene.add_child(_uzi_esp_box)
-	_uzi_esp_box.global_position = target.global_position + Vector3.UP * (_uzi_esp_box.size.y * 0.5)
+	EspTarget.acquire(target, uzi_esp_color)
 
 
 func _clear_uzi_esp() -> void:
-	if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
-		_uzi_esp_marker.queue_free()
-	_uzi_esp_marker = null
-	if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
-		_uzi_esp_box.queue_free()
-	_uzi_esp_box = null
+	if _uzi_locked_target != null:
+		EspTarget.release(_uzi_locked_target)
 	_uzi_locked_target = null
-
-
-func _build_esp_marker() -> Label3D:
-	var label := Label3D.new()
-	label.text = "◆"
-	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
-	label.no_depth_test = true
-	label.font_size = 72
-	label.outline_size = 14
-	label.modulate = uzi_esp_color
-	label.outline_modulate = Color(uzi_esp_color.r * 0.2, uzi_esp_color.g * 0.2, uzi_esp_color.b * 0.2, 0.9)
-	return label
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the sniper ESP functions and its flash…*

`19:43:57`

> Now the sniper ESP functions and its flash call:

#### 👀 Read `combat_giselle.gd`

`19:43:58`

*(lines 330–405)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```
## Gegner, weil dieselbe Kegel-/Reichweiten-Logik zugrunde liegt).
func _resolve_sniper_esp_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
		var health: Node = _sniper_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_sniper_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= sniper_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(aim_assist_angle_deg * 1.5)
		if alive and in_range and in_cone:
			return _sniper_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, sniper_range, aim_assist_angle_deg)


func _update_sniper_esp(target: Node3D) -> void:
	if target == _sniper_locked_target and target != null and is_instance_valid(target):
		if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
			_sniper_esp_box.global_position = target.global_position + Vector3.UP * (_sniper_esp_box.size.y * 0.5)
		return

	_clear_sniper_esp()
	_sniper_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_sniper_esp_box = EnemyEspBox.build_for(target, uzi_esp_color)
	get_tree().current_scene.add_child(_sniper_esp_box)
	_sniper_esp_box.global_position = target.global_position + Vector3.UP * (_sniper_esp_box.size.y * 0.5)


func _clear_sniper_esp() -> void:
	if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
		_sniper_esp_box.queue_free()
	_sniper_esp_box = null
	_sniper_locked_target = null


func _perform_secondary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung. Bewusst ueber die Camera3D selbst
	# statt SpringArm3D berechnet, damit hier keine Annahme ueber gleiche
	# Rotation zwischen beiden Nodes mehr noetig ist.
	var dir: Vector3 = EnemyQuery.aim_assisted_direction(
		origin, -_camera.global_transform.basis.z, sniper_range, aim_assist_angle_deg, aim_assist_strength
	)
	var dmg: float = sniper_damage_per_shot * _damage_multiplier()
	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null
	var landed_hit: bool = false

	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man schiesst"
	# - gleicher Grund wie bei der Uzi: nicht erst auf einen bestaetigten
	# Treffer warten. _sniper_locked_target ist bereits waehrend des Ladens
	# (siehe _poll_secondary_input()) ermittelt.
	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
		_lock_model_to(_sniper_locked_target)

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		
		var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
		_spawn_muzzle_vfx(muzzle_pos, dir, 2.5)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(muzzle_pos, result["position"], 0.9, 0.12)
		if result["hit"]:
			landed_hit = true
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			if spark:
				spark.scale *= 2.2
```
</details>

#### ✏️  Edit `combat_giselle.gd`

`19:44:06`

```diff
@@ -1,21 +1,15 @@+## _sniper_locked_target bleibt das Sticky-Targeting-Gedaechtnis fuer
+## _resolve_sniper_esp_target() - die Anzeige selbst laeuft ueber den
+## projektweiten Singular-Indikator, siehe scripts/vfx/esp_target.gd.
 func _update_sniper_esp(target: Node3D) -> void:
-	if target == _sniper_locked_target and target != null and is_instance_valid(target):
-		if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
-			_sniper_esp_box.global_position = target.global_position + Vector3.UP * (_sniper_esp_box.size.y * 0.5)
+	if target == null or not is_instance_valid(target):
+		_clear_sniper_esp()
 		return
-
-	_clear_sniper_esp()
 	_sniper_locked_target = target
-	if target == null or not is_instance_valid(target):
-		return
-
-	_sniper_esp_box = EnemyEspBox.build_for(target, uzi_esp_color)
-	get_tree().current_scene.add_child(_sniper_esp_box)
-	_sniper_esp_box.global_position = target.global_position + Vector3.UP * (_sniper_esp_box.size.y * 0.5)
+	EspTarget.acquire(target, uzi_esp_color)
 
 
 func _clear_sniper_esp() -> void:
-	if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
-		_sniper_esp_box.queue_free()
-	_sniper_esp_box = null
+	if _sniper_locked_target != null:
+		EspTarget.release(_sniper_locked_target)
 	_sniper_locked_target = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the sniper hit-flash call further down…*

`19:44:08`

> Now the sniper hit-flash call further down in `_perform_secondary()`:

#### 👀 Read `combat_giselle.gd`

`19:44:09`

*(lines 387–417)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		
		var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
		_spawn_muzzle_vfx(muzzle_pos, dir, 2.5)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(muzzle_pos, result["position"], 0.9, 0.12)
		if result["hit"]:
			landed_hit = true
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			if spark:
				spark.scale *= 2.2
			_lock_model_to(result["target"])
			if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
				_sniper_esp_box.flash()
		if i < sniper_shot_count - 1:
			await get_tree().create_timer(0.03).timeout

	if landed_hit:
		# Kurzer Hit-Stop + kraeftige Kamera-Erschuetterung statt nur Shake -
		# verkauft das Gewicht eines Treffers, der die meisten Gegner sofort
		# toetet, deutlich staerker als reines Wackeln.
		Juice.impact(0.6, Juice.DURATION_HEAVY)

	# Burst ist fertig (RMB feuert nur einmal pro Ladevorgang) - ESP-Box
	# wieder einsammeln, statt sie bis zum naechsten Ladevorgang haengen zu
	# lassen.
	_clear_sniper_esp()


```
</details>

#### ✏️  Edit `combat_giselle.gd`

`19:44:13`

```diff
@@ -1,3 +1,2 @@ 			_lock_model_to(result["target"])
-			if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
-				_sniper_esp_box.flash()
+			EspTarget.flash(result["target"])
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:44:16`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_uzi_esp|_sniper_esp_box|esp_marker` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd`

`19:44:17`

```
46:## Ziel - siehe _build_esp_marker().
144:	_update_uzi_esp(target)
192:func _update_uzi_esp(target: Node3D) -> void:
194:		_clear_uzi_esp()
200:func _clear_uzi_esp() -> void:
221:		_clear_uzi_esp()
232:## _uzi_esp_marker/_uzi_esp_box haengen unter current_scene, NICHT unter
233:## diesem Combat-Node (siehe _build_esp_marker()/_update_uzi_esp()) -
238:	_clear_uzi_esp()
```

#### 👀 Read `combat_giselle.gd`

`19:44:20`

*(lines 40–50)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```
## Blickkegel-Halbwinkel, in dem sich die Uzi selbst ihr Ziel sucht (siehe
## EnemyQuery.best_target_in_cone()) - deutlich weiter als der praezise
## Aim-Assist unten, weil hier kein Zielen mehr noetig sein soll, nur noch
## grobes Hinschauen.
@export var uzi_target_cone_deg: float = 35.0
## Farbe/Groesse des ESP-Markers ueber dem gerade automatisch anvisierten
## Ziel - siehe _build_esp_marker().
@export var uzi_esp_color: Color = Color(1.0, 0.15, 0.1)

## --- Secondary "Sniper Burst" ---------------------------------------------
```
</details>

#### ✏️  Edit `combat_giselle.gd`

`19:44:24`

```diff
@@ -1,3 +1,3 @@-## Farbe/Groesse des ESP-Markers ueber dem gerade automatisch anvisierten
-## Ziel - siehe _build_esp_marker().
+## Farbe des ESP-Markers ueber dem gerade automatisch anvisierten Ziel -
+## siehe scripts/vfx/esp_target.gd.
 @export var uzi_esp_color: Color = Color(1.0, 0.15, 0.1)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### 👀 Read `combat_giselle.gd`

`19:44:26`

*(lines 228–240)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```
func get_uzi_magazine_size() -> int:
	return uzi_magazine_size


## _uzi_esp_marker/_uzi_esp_box haengen unter current_scene, NICHT unter
## diesem Combat-Node (siehe _build_esp_marker()/_update_uzi_esp()) -
## ueberleben einen Charakterwechsel also nicht automatisch. Explizit
## aufraeumen, sonst bleibt ein verwaister Marker/Kasten in der Szene stehen,
## falls LMB/RMB genau beim Wechsel gehalten wurde.
func _exit_tree() -> void:
	_clear_uzi_esp()
	_clear_sniper_esp()
```
</details>

#### ✏️  Edit `combat_giselle.gd`

`19:44:32`

```diff
@@ -1,8 +1,6 @@-## _uzi_esp_marker/_uzi_esp_box haengen unter current_scene, NICHT unter
-## diesem Combat-Node (siehe _build_esp_marker()/_update_uzi_esp()) -
-## ueberleben einen Charakterwechsel also nicht automatisch. Explizit
-## aufraeumen, sonst bleibt ein verwaister Marker/Kasten in der Szene stehen,
-## falls LMB/RMB genau beim Wechsel gehalten wurde.
+## EspTarget.release() raeumt nur auf, wenn diese Waffe gerade tatsaechlich
+## den projektweiten Indikator haelt - explizit noetig, sonst bliebe er
+## verwaist stehen, falls LMB/RMB genau beim Charakterwechsel gehalten wurde.
 func _exit_tree() -> void:
 	_clear_uzi_esp()
 	_clear_sniper_esp()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:44:35`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `Label3D|EnemyEspBox|esp_box|esp_marker` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd`

`19:44:37`

```
No matches found
```

### 🤖 Assistant: *Clean. Let's verify the same for combat_winter…*

`19:44:39`

> Clean. Let's verify the same for combat_winter.gd.

#### 🔎 Grep `Label3D|EnemyEspBox|esp_box|esp_marker` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd`

`19:44:40`

```
No matches found
```

### 🤖 Assistant: *Both clean. Now let's do a final read-through…*

`19:44:43`

> Both clean. Now let's do a final read-through of both full files to sanity-check correctness before wrapping up.

#### 👀 Read `combat_winter.gd`

`19:44:43`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```

extends CombatBase
class_name CombatWinter

# Winter: Energy/Crowd Control — Zonen-Kontrolle und stetiger DoT.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind weg - Q/E loesen jetzt immer das
# aktive Item im jeweiligen Slot aus, siehe combat_base.gd.
#
# Beide Faehigkeiten sind Hitscan/Projektil- statt Hitbox-basiert -
# PrimaryHitbox/SecondaryHitbox aus char_winter.tscn bleiben bewusst
# ungenutzt im Baum (siehe combat_base.gd-Kopfkommentar zu diesem Muster).

const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")
const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_muzzle_flash_winter.tscn")
const PROJECTILE_VFX_SCENE: PackedScene = preload("res://test vfx/MagicProjectilesVFX/assets/BinbunVFX/magic_projectiles/effects/mprojectile_basic/Magic Projectile Basic 3.tscn")
const PROJECTILE_HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_impact_004.tscn")
const MUZZLE_FORWARD_OFFSET: float = 0.8

## --- Primary "Magnetic Plasma" ---------------------------------------------
@export var plasma_damage: float = 12.0
## War 22.0 - Rueckmeldung "mehr Range der Enemy Detection beim Schiessen".
@export var plasma_range: float = 32.0
## Rueckmeldung "mehr Kugeln schiessen": statt eines einzelnen Bolts auf das
## naechste Ziel feuert Primary jetzt auf bis zu plasma_bolt_count
## UNTERSCHIEDLICHE nahe Ziele gleichzeitig - verteilt den Zusatzschaden auf
## die Gruppe, statt nur ein Ziel schneller zu ueberkillen.
@export var plasma_bolt_count: int = 2
## War als fester Parameter (16.0) an HomingBolt.spawn() durchgereicht -
## Rueckmeldung "schnellere Traveltime der Kugeln".
@export var plasma_bolt_speed: float = 24.0
@export var plasma_bolt_lifetime: float = 3.0
## Impuls, den ein getroffener Gegner Richtung Einschlag abbekommt - deutlich
## unter magnet_core.gd's PULL_IMPULSE_STRENGTH (16.0): stark genug, um kurz
## aus der Laufrichtung zu reissen, schwach genug, um niemanden komplett aus
## der Position zu ziehen.
@export var plasma_pull_strength: float = 10.0

## --- Secondary "Heavy Laser Stream" -----------------------------------------
@export var laser_damage_per_tick: float = 5.0
@export var laser_tick_interval: float = 0.05
@export var laser_range: float = 25.0
@export var laser_max_charge: float = 10.0
@export var laser_recharge_time: float = 5.0
@export var aim_assist_angle_deg: float = 5.0
@export var aim_assist_strength: float = 0.5
## Rework "Auto-Target wie Giselles Uzi" (Rueckmeldung): Blickkegel-
## Halbwinkel, in dem sich der Laser selbst sein Ziel sucht (siehe
## EnemyQuery.best_target_in_cone()) - ersetzt den alten praezisen, engen
## Aim-Assist oben fuer den Laser (aim_assist_* bleibt ungenutzt, falls
## spaeter wieder ein weicherer Modus gebraucht wird).
@export var laser_target_cone_deg: float = 35.0
## Farbe des ESP-Markers ueber dem gerade vom Laser anvisierten Ziel.
@export var laser_esp_color: Color = Color(1.0, 0.15, 0.1)

var _laser_energy: float = 10.0
var _laser_tick_timer: float = 0.0
var _laser_beam: Dictionary = {}
var _laser_locked_target: Node3D = null

var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null


func _init() -> void:
	primary_cooldown = 0.4
	# secondary_cooldown bleibt auf dem geerbten Standardwert - fuer den
	# Laser irrelevant, da _poll_secondary_input() ihn komplett durch das
	# Batterie-System unten ersetzt und nie _do_secondary() aufruft.
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_laser_energy = laser_max_charge


# ============================================================================
# Magnetic Plasma - feuert ueber das UNVERAENDERTE _poll_primary_input()/
# _do_primary() aus combat_base.gd (gehalten -> feuert erneut sobald
# primary_cooldown abgelaufen). Sucht sich selbst ein Ziel statt in
# Blickrichtung zu feuern - "soft homing" gemaess Spec.
# ============================================================================
func _perform_primary() -> void:
	var targets: Array[Node3D] = _pick_plasma_targets()
	if targets.is_empty():
		return

	var origin: Vector3 = player.global_position + Vector3.UP * 1.4
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color if data else Color(0.5, 1.0, 0.7)
	var dmg: float = plasma_damage * _damage_multiplier()

	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man
	# schiesst": targets[0] ist der naechste (siehe _pick_plasma_targets()'
	# Sortierung) - nicht erst auf den Einschlag eines Bolts warten (der
	# Flug dauert je nach Distanz spuerbar).
	var primary_target = targets[0]
	_lock_model_to(primary_target)
	# EspTarget statt einer eigenen Box PRO Ziel (Plasma kann bis zu
	# plasma_bolt_count Gegner gleichzeitig anfliegen): nur das primaere
	# (naechste) Ziel bekommt den EINEN projektweiten Indikator, siehe
	# scripts/vfx/esp_target.gd-Kopfkommentar.
	EspTarget.acquire(primary_target, color)

	var dir = (primary_target.global_position + Vector3.UP - origin).normalized()
	var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
	_spawn_muzzle_vfx(muzzle_pos, dir)

	for target: Node3D in targets:
		var on_strike: Callable = func(hit_target: Node3D) -> void:
			_on_plasma_strike(hit_target, origin, dmg)

		var bolt: HomingBolt = HomingBolt.spawn(
			self, origin, target, color, on_strike, plasma_bolt_speed, plasma_bolt_lifetime, false, player
		)
		if bolt:
			_attach_plasma_trail(bolt, color)


## Bis zu plasma_bolt_count lebende Gegner in Reichweite, naechster zuerst.
func _pick_plasma_targets() -> Array[Node3D]:
	var candidates: Array[Node3D] = EnemyQuery.enemies_within(player.global_position, plasma_range)
	var origin: Vector3 = player.global_position
	candidates.sort_custom(func(a: Node3D, b: Node3D) -> bool:
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position)
	)
	if candidates.size() > plasma_bolt_count:
		candidates.resize(plasma_bolt_count)
	return candidates


func _attach_plasma_trail(bolt: Node3D, color: Color) -> void:
	for child in bolt.get_children():
		if child is MeshInstance3D:
			child.visible = false

	if PROJECTILE_VFX_SCENE != null:
		var vfx = PROJECTILE_VFX_SCENE.instantiate()
		if vfx is Node3D:
			vfx.rotation_degrees = Vector3(0, 90, 0)
		bolt.add_child(vfx)


## origin ist die Abschusspositon (NICHT die aktuelle Bolt-Position - der
## Bolt selbst reicht seine Position nicht an den Callback durch, siehe
## homing_bolt.gd::_strike()). Die Zug-Richtung ist deshalb "vom Abschussort
## zum Einschlag", nicht "vom Ziel weg vom Einschlag" - liest sich als
## Schubs weiter in Flugrichtung, siehe Kopfkommentar-Entscheidung im Plan.
func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float) -> void:
	# No-op, falls "target" gerade nicht der angezeigte EspTarget-Indikator
	# ist (z.B. ein Zweit-Bolt auf ein Ziel ohne eigenen Kasten) - siehe
	# scripts/vfx/esp_target.gd::flash().
	EspTarget.flash(target)

	if not is_instance_valid(target):
		return
	var health: Node = target.find_child("Health", true, false)
	if health == null or not (health is Health) or not (health as Health).is_alive():
		return

	(health as Health).take_damage(dmg, player)

	# BUGFIX "LMB hat keine Damage Numbers": anders als der Laser (Hitscan.fire
	# bekommt eine damage_number_scene mit) spawnte der Plasma-Bolt-Treffer nie
	# eine Schadenszahl - derselbe Anzeigeweg wie Karinas Aura-Tick.
	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	if dns != null:
		var number: Node = dns.instantiate()
		get_tree().current_scene.add_child(number)
		(number as Node3D).global_position = target.global_position + Vector3(0.0, 1.8, 0.0)
		if number.has_method("show_damage"):
			number.show_damage(dmg)

	var pull_dir: Vector3 = target.global_position - origin
	pull_dir.y = 0.0
	# has_method()-Wache: NUR enemy_ai.gd und player_base.gd implementieren
	# apply_knockback() - die sechs CustomEnemyBase-Gegner (Moerser-Bot,
	# Saeure-Sprinkler, Magnet-Kern, Divebomber, Schild-Drohne, Plasmastrahl-
	# Bot) tun es NICHT und sollen einfach nur Schaden nehmen, ohne Fehler.
	if pull_dir.length_squared() > 0.01 and target.has_method("apply_knockback"):
		target.apply_knockback(pull_dir.normalized() * plasma_pull_strength)

	var spark: Node3D = VFX.spawn(PROJECTILE_HIT_VFX_SCENE if PROJECTILE_HIT_VFX_SCENE else HIT_VFX_SCENE, target.global_position + Vector3.UP, Vector3.UP)
	if player and player.has_method("shake_camera"):
		player.shake_camera(0.15)
	_lock_model_to(target)


# ============================================================================
# Heavy Laser Stream - Batterie statt Cooldown: ersetzt _poll_secondary_input
# komplett, ruft NIE _do_secondary()/den geerbten Cooldown-Mechanismus auf.
# ============================================================================
func _poll_secondary_input(delta: float) -> void:
	var held: bool = Input.is_action_pressed("attack_secondary")

	if held:
		# BUGFIX "Batterie laedt trotz gehaltener Taste wieder auf": vorher
		# fiel "gehalten, aber Energie=0" durch dieselbe Bedingung wie
		# "nicht gehalten" und startete sofort das Aufladen - solange man RMB
		# weiter gedrueckt hielt, pendelte die Energie dadurch nie richtig
		# hoch UND der Strahl blieb aus, obwohl man aktiv zu feuern versuchte.
		# Jetzt: solange gehalten wird, passiert entweder Feuern (Energie > 0)
		# oder GAR NICHTS (Energie leer) - aufgeladen wird ausschliesslich
		# nach dem Loslassen.
		if _laser_energy > 0.0:
			_laser_energy = maxf(_laser_energy - delta, 0.0)
			_update_laser(delta)
			if _laser_energy <= 0.0:
				_stop_laser()
		elif not _laser_beam.is_empty():
			_stop_laser()
		return

	if not _laser_beam.is_empty():
		_stop_laser()

	# Kein Mindest-Schwellenwert: die Formel selbst sorgt schon dafuer, dass
	# ein Teil-Ladezustand sofort wieder nutzbar ist, statt erst komplett
	# vollladen zu muessen ("partial charge = partial use" laut Spec).
	_laser_energy = minf(_laser_energy + delta * (laser_max_charge / laser_recharge_time), laser_max_charge)


func _update_laser(delta: float) -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung, siehe combat_giselle.gd.
	# Auto-Target statt weichem Aim-Assist (Rueckmeldung "wie bei Giselles
	# Uzi"): breiter Blickkegel, direkter Schuss aufs gefundene Ziel statt auf
	# die rohe Blickrichtung. Ohne Ziel im Kegel faellt der Strahl auf die
	# reine Blickrichtung zurueck.
	var look_dir: Vector3 = -_camera.global_transform.basis.z
	var target: Node3D = _resolve_laser_target(origin, look_dir)
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_laser_esp(target)
	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man
	# schiesst" - vorher haengte _lock_model_to() weiter unten nur am
	# tatsaechlichen Schadens-Tick (do_damage UND hit), der Strahl feuert
	# aber jeden Frame; das Modell blieb zwischen zwei Ticks stehen.
	if target != null:
		_lock_model_to(target)

	_laser_tick_timer -= delta
	var do_damage: bool = _laser_tick_timer <= 0.0
	var dmg: float = laser_damage_per_tick * _damage_multiplier() if do_damage else 0.0
	var dns: PackedScene = (secondary_hitbox.damage_number_scene if secondary_hitbox else null) if do_damage else null

	# EIN Raycast pro Frame bedient beides: Schadenstick (nur wenn faellig)
	# UND die visuelle Strahl-Endposition (jeden Frame, damit der sichtbare
	# Strahl nicht zwischen zwei Ticks am alten Trefferpunkt "klebt").
	var result: Dictionary = Hitscan.fire(self, origin, dir, laser_range, dmg, player, dns)

	if do_damage:
		_laser_tick_timer = laser_tick_interval
		if result["hit"]:
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			# Leichtes Dauer-Rattern statt eines einzelnen Shakes - passt
			# besser zu einem Dauerstrahl als ein einmaliger Ausschlag und
			# macht spuerbar, dass der Strahl laufend Schaden macht statt
			# nur huebsch auszusehen (Rueckmeldung "sieht schwach aus").
			if player and player.has_method("shake_camera"):
				player.shake_camera(0.06)
			EspTarget.flash(target)

	if _laser_beam.is_empty():
		var data: CharacterData = PartyManager.get_active_data()
		var color: Color = data.attack_color if data else Color(0.5, 0.9, 1.0)
		# Deutlich dicker als vorher (0.7 -> 1.3) - ein duenner Strahl liest
		# sich als schwacher Laserpointer statt als "Heavy Laser Stream".
		_laser_beam = BeamVisual.create(self, color, 1.3)

	BeamVisual.update(_laser_beam, origin, result["position"], delta)


func _stop_laser() -> void:
	BeamVisual.free_beam(_laser_beam)
	_laser_beam = {}
	_laser_tick_timer = 0.0
	_clear_laser_esp()


## BUGFIX "Strahl sieht aus wie einzelne Kugeln statt wie ein durchgehender
## Strahl (wie bei der Schild-Drohne)": ohne Sticky-Targeting waehlte
## best_target_in_cone() JEDEN Frame neu den "besten" Gegner - stehen mehrere
## nah beieinander, kann das Ergebnis frame-zu-frame kippen, und der
## Strahl-Endpunkt springt zwischen ihnen hin und her statt ruhig auf einem
## Ziel zu stehen. Jetzt wird das aktuelle Ziel gehalten, solange es lebt,
## in Reichweite ist und noch (grosszuegiger als der Such-Kegel, damit es
## nicht direkt an der Kegelgrenze flackert) im Blickfeld liegt - neu gesucht
## wird nur, wenn es wirklich wegfaellt.
func _resolve_laser_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _laser_locked_target != null and is_instance_valid(_laser_locked_target):
		var health: Node = _laser_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_laser_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= laser_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(laser_target_cone_deg * 1.5)
		if alive and in_range and in_cone:
			return _laser_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, laser_range, laser_target_cone_deg)


## _laser_locked_target bleibt weiterhin das Sticky-Targeting-Gedaechtnis
## fuer _resolve_laser_target() - die eigentliche Anzeige laeuft jetzt ueber
## den projektweiten Singular-Indikator, siehe scripts/vfx/esp_target.gd.
func _update_laser_esp(target: Node3D) -> void:
	if target == null or not is_instance_valid(target):
		_clear_laser_esp()
		return
	_laser_locked_target = target
	EspTarget.acquire(target, laser_esp_color)


func _clear_laser_esp() -> void:
	if _laser_locked_target != null:
		EspTarget.release(_laser_locked_target)
	_laser_locked_target = null


func get_laser_energy_percent() -> float:
	return _laser_energy / laser_max_charge if laser_max_charge > 0.0 else 0.0


## _laser_beam haengt unter current_scene, nicht unter diesem Combat-Node -
## ueberlebt einen Charakterwechsel also nicht automatisch (gleicher Grund
## wie combat_giselle.gd::_exit_tree()). _stop_laser() gibt zusaetzlich den
## EspTarget-Indikator frei, falls dieser Laser ihn gerade haelt.
func _exit_tree() -> void:
	_stop_laser()


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
# _damage_multiplier() und _lock_model_to() leben jetzt in combat_base.gd
# (identisch dupliziert in Giselle/Karina/Winter - siehe dortige Kommentare).
# Weder HomingBolt-Treffer noch Hitscan-Treffer loesen _lock_model_to()
# automatisch aus, da beide nie ueber die Hitbox-Signale laufen - deshalb
# wird es hier weiterhin explizit nachgezogen.

func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3, scale_mul: float = 1.0) -> void:
	var vfx_dir: Vector3 = dir
	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
	var data: CharacterData = PartyManager.get_active_data()
	var vfx: Node3D
	
	if data != null:
		vfx = VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, spawn_pos, data.attack_color, data.attack_color_secondary, vfx_dir)
	else:
		vfx = VFX.spawn(MUZZLE_VFX_SCENE, spawn_pos, vfx_dir)
		
	if vfx != null and scale_mul != 1.0:
		vfx.scale *= scale_mul

```
</details>

### 🤖 Assistant: *This looks correct and clean.*

`19:44:46`

> This looks correct and clean. Now let's do a final read of combat_giselle.gd to confirm it's fully consistent.

#### 👀 Read `combat_giselle.gd`

`19:44:47`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```

extends CombatBase
class_name CombatGiselle

# Giselle: Ranged/Precision — zielsicherer Fernkampf, gezielte Eliminierung
# von High-Threat-Targets.
# WICHTIG: @export-Variablen, die schon in CombatBase existieren, duerfen in
# der Subklasse NICHT nochmal mit @export deklariert werden (Godot-Fehler
# "member already exists in parent class"). Stattdessen werden abweichende
# Werte hier in _init() gesetzt.
#
# PHASE 5: ability_q_cooldown/ability_e_cooldown und die _perform_ability_q()/
# _perform_ability_e()-Platzhalter sind komplett weg - Q und E loesen jetzt
# immer das aktive Item im jeweiligen Slot aus, siehe CombatBase.
#
# Beide Waffen sind Hitscan (scripts/core/hitscan.gd) statt Hitbox-basiert -
# PrimaryHitbox/SecondaryHitbox aus char_giselle.tscn bleiben bewusst
# ungenutzt im Baum (siehe combat_base.gd-Kopfkommentar zu diesem Muster),
# nur ihre bereits im Inspector gesetzten damage_number_scene-Referenzen
# werden noch mitbenutzt, um keine zweite Ressourcen-Zuweisung zu brauchen.

const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_muzzle_flash.tscn")
const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/animated_blood_hit.tscn")

## BUGFIX "Muendungsblitz-Partikel fliegen in die Kamera": _spawn_muzzle_vfx()
## bekam bisher die Camera3D-Position selbst als Spawn-Punkt - der Effekt
## sass damit direkt AM Objektiv, und sein 75-Grad-Streuwinkel (siehe
## spark_yellow.tscn) rendert dadurch sichtbar ueber den ganzen Bildschirm
## statt als kleiner Blitz vor dem Lauf. Schiebt den Spawn-Punkt ein Stueck
## in Schussrichtung nach vorn, weg vom Objektiv.
const MUZZLE_FORWARD_OFFSET: float = 0.6

## --- Primary "Uzi Spray" -------------------------------------------------
@export var uzi_magazine_size: int = 40
@export var uzi_reload_time: float = 1.0
@export var uzi_damage: float = 7.0
@export var uzi_range: float = 40.0
## Rework "Auto-Target" (Rueckmeldung: "man sollte nur in die Richtung
## schauen, damit die Uzi die Gegner erkennt und selber drauf schiesst"):
## Blickkegel-Halbwinkel, in dem sich die Uzi selbst ihr Ziel sucht (siehe
## EnemyQuery.best_target_in_cone()) - deutlich weiter als der praezise
## Aim-Assist unten, weil hier kein Zielen mehr noetig sein soll, nur noch
## grobes Hinschauen.
@export var uzi_target_cone_deg: float = 35.0
## Farbe des ESP-Markers ueber dem gerade automatisch anvisierten Ziel -
## siehe scripts/vfx/esp_target.gd.
@export var uzi_esp_color: Color = Color(1.0, 0.15, 0.1)

## --- Secondary "Sniper Burst" ---------------------------------------------
@export var sniper_shot_count: int = 3
@export var sniper_damage_per_shot: float = 100.0
@export var sniper_range: float = 60.0
## FOV, auf den beim Halten von RMB gezoomt wird - deutlich unter dem
## Kamera-Standard-FOV, simuliert ein Zielfernrohr OHNE die Third-Person-
## Kamera selbst zu verschieben (das macht weiterhin unabhaengig davon das
## bestehende Mausrad-Zoom/SpringArm3D-System aus player_base.gd).
@export var sniper_zoom_fov: float = 28.0
@export var sniper_zoom_in_time: float = 0.5
@export var sniper_zoom_out_time: float = 0.35

## Zusaetzlicher seitlicher Kamera-Versatz waehrend des Sniper-Zooms, ON TOP
## von player_base.gd's staendigem camera_shoulder_offset - der Charakter
## steht beim Reinzoomen sonst mitten im Bild und verdeckt genau das Ziel,
## das man gerade anvisiert. Siehe _start_sniper_charge()/
## _release_sniper_charge() - laeuft als eigener Tween parallel zum FOV-Tween.
@export var sniper_aim_shoulder_offset: float = 1.1

## --- Aim-Assist (Sniper) ----------------------------------------------------
## Nur noch fuer den Sniper: die Uzi hat seit dem Auto-Target-Rework ihr
## eigenes uzi_target_cone_deg (harter Lock statt weichem Assist, siehe oben).
## War 10/0.5 ("soft aim assist"). Rueckmeldung "reicht nicht, Fadenkreuz
## soll viel staerker am Gegner kleben bleiben": Winkel auf 18 Grad und
## strength auf 0.85 angehoben - deutlich klebriger, aber bewusst NICHT 1.0,
## damit ein grob daneben gezielter Schuss noch knapp danebengehen kann statt
## komplett zum Aim-Bot zu werden. Bei Bedarf im Inspector weiter hochdrehen.
@export var aim_assist_angle_deg: float = 18.0
@export var aim_assist_strength: float = 0.85

var _uzi_ammo: int = 40
var _uzi_reloading: bool = false
var _uzi_locked_target: Node3D = null

var _sniper_charging: bool = false
var _sniper_locked_target: Node3D = null
var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null
var _default_fov: float = 75.0
var _fov_tween: Tween = null
## Ausgangswert von _spring_arm.position.x, EINMAL in setup() gelesen -
## player_base.gd hat den Shoulder-Offset zu dem Zeitpunkt schon gesetzt
## (siehe player_base.gd::_ready(), laeuft VOR combat.setup()). Der Sniper-
## Zoom tweent dorthin zurueck statt hart auf 0.0, damit ein evtl. per
## Inspector abweichender Standard-Offset erhalten bleibt.
var _default_shoulder_offset: float = 0.6
var _shoulder_tween: Tween = null


func _init() -> void:
	# War 0.08 - Rueckmeldung "schiesst minimal zu schnell". Leicht angehoben.
	primary_cooldown = 0.1
	secondary_cooldown = 5.0
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_uzi_ammo = uzi_magazine_size
	if _camera:
		_default_fov = _camera.fov
	if _spring_arm:
		_default_shoulder_offset = _spring_arm.position.x


# ============================================================================
# Uzi Spray - haelt Halten von LMB, feuert ueber das UNVERAENDERTE
# _poll_primary_input()/_do_primary() aus combat_base.gd jeden Frame erneut,
# solange der (sehr kurze) primary_cooldown abgelaufen ist.
#
# REWORK "Auto-Target" (Rueckmeldung): frueher ein enger, praeziser Aim-
# Assist auf die reine Kamera-Blickrichtung (5 Grad Kegel, sanft eingeblendet
# per Slerp) - jetzt sucht sich die Uzi selbst den besten Gegner in einem
# breiten Blickkegel (uzi_target_cone_deg) und feuert DIREKT auf ihn, nicht
# mehr auf die rohe Blickrichtung. Ohne Ziel im Kegel faellt sie auf die
# alte reine Blickrichtung zurueck, damit LMB nie komplett ins Leere geht.
# ============================================================================
func _perform_primary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung.
	var look_dir: Vector3 = -_camera.global_transform.basis.z
	var target: Node3D = _resolve_uzi_target(origin, look_dir)
	
	# Wenn kein Gegner im Visier ist, gar nicht erst schießen (Munition sparen)
	if target == null:
		return
		
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized()
	_update_uzi_esp(target)
	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man einen
	# Gegner beschiesst": frueher haengte _lock_model_to() nur am BESTAETIGTEN
	# Treffer (unten im result["hit"]-Zweig) - ein Ziel im Kegel, das die Uzi
	# gerade anvisiert, liess das Modell also stehen, solange der Schuss aus
	# irgendeinem Grund (Deckung, Rand des Kegels) nicht ankam. "Schiesst auf"
	# heisst schon "hat ein Ziel gewaehlt", nicht erst "hat getroffen".
	_lock_model_to(target)

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	
	var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
	_spawn_muzzle_vfx(muzzle_pos, dir)
	_spawn_tracer(muzzle_pos, result["position"], 0.35, 0.06)
	if result["hit"]:
		VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		if player and player.has_method("shake_camera"):
			player.shake_camera(0.18)
		EspTarget.flash(target)

	_uzi_ammo -= 1
	if _uzi_ammo <= 0:
		_uzi_ammo = uzi_magazine_size
		_uzi_reloading = true
		_primary_timer = uzi_reload_time


## Sticky Targeting - gleicher Grund wie combat_winter.gd::
## _resolve_laser_target(): ohne das koennte das gewaehlte Ziel bei mehreren
## nah beieinander stehenden Gegnern von Schuss zu Schuss wechseln.
func _resolve_uzi_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _uzi_locked_target != null and is_instance_valid(_uzi_locked_target):
		var health: Node = _uzi_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_uzi_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= uzi_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(uzi_target_cone_deg * 1.5)
		if alive and in_range and in_cone:
			return _uzi_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, uzi_range, uzi_target_cone_deg)


## _uzi_locked_target bleibt das Sticky-Targeting-Gedaechtnis fuer
## _resolve_uzi_target() - die Anzeige selbst laeuft ueber den
## projektweiten Singular-Indikator, siehe scripts/vfx/esp_target.gd.
func _update_uzi_esp(target: Node3D) -> void:
	if target == null or not is_instance_valid(target):
		_clear_uzi_esp()
		return
	_uzi_locked_target = target
	EspTarget.acquire(target, uzi_esp_color)


func _clear_uzi_esp() -> void:
	if _uzi_locked_target != null:
		EspTarget.release(_uzi_locked_target)
	_uzi_locked_target = null


## Waehrend des Nachladens gilt der feste Reload-Cooldown statt des
## kombo-reduzierten Basis-Cooldowns - sonst wuerde get_primary_cooldown_
## percent() (HUD-Ring) durch den winzigen primary_cooldown teilen und einen
## Wert weit ueber 1.0 liefern.
func _get_effective_primary_cooldown() -> float:
	if _uzi_reloading:
		return uzi_reload_time
	return super._get_effective_primary_cooldown()


func _process(delta: float) -> void:
	super._process(delta)
	if _uzi_reloading and _primary_timer <= 0.0:
		_uzi_reloading = false
	if _uzi_locked_target != null and not Input.is_action_pressed("attack_primary"):
		_clear_uzi_esp()


func get_uzi_ammo_remaining() -> int:
	return _uzi_ammo


func get_uzi_magazine_size() -> int:
	return uzi_magazine_size


## EspTarget.release() raeumt nur auf, wenn diese Waffe gerade tatsaechlich
## den projektweiten Indikator haelt - explizit noetig, sonst bliebe er
## verwaist stehen, falls LMB/RMB genau beim Charakterwechsel gehalten wurde.
func _exit_tree() -> void:
	_clear_uzi_esp()
	_clear_sniper_esp()


# ============================================================================
# Sniper Burst - komplett eigenes Press/Hold/Release-Handling statt des
# Standard-"gehalten -> feuert jeden Frame"-Musters: RMB druecken startet
# einen Ladevorgang (Kamera-FOV zoomt), RMB LOSLASSEN loest den eigentlichen
# Schuss aus. Das Feuern selbst laeuft trotzdem ueber das unveraenderte
# _do_secondary() (Cooldown/Signale/Ghost-Trail) - nur der Zeitpunkt des
# Aufrufs wandert von "press" zu "release".
# ============================================================================
func _poll_secondary_input(_delta: float) -> void:
	if _sniper_charging:
		# ESP-Box waehrend des GESAMTEN Ladevorgangs aktuell halten - sticky
		# Targeting (siehe _resolve_sniper_esp_target()) sorgt dafuer, dass
		# sie nicht bei jedem winzigen Maus-Zittern auf einen anderen Gegner
		# umspringt.
		if _camera != null:
			var origin: Vector3 = _camera.global_position
			var look_dir: Vector3 = -_camera.global_transform.basis.z
			_update_sniper_esp(_resolve_sniper_esp_target(origin, look_dir))
		if not Input.is_action_pressed("attack_secondary"):
			_release_sniper_charge()
		return

	if Input.is_action_just_pressed("attack_secondary") and _secondary_timer <= 0.0:
		_start_sniper_charge()


func _start_sniper_charge() -> void:
	if _camera == null:
		return
	_sniper_charging = true
	_kill_fov_tween()
	_fov_tween = _camera.create_tween()
	_fov_tween.tween_property(_camera, "fov", sniper_zoom_fov, sniper_zoom_in_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Schulterblick-Versatz: der Charakter steht sonst mitten im Bild und
	# verdeckt beim Reinzoomen genau das Ziel (Rueckmeldung "Kamera-Shift
	# beim Zielen"). Reine Positions-Verschiebung des SpringArm3D-Ursprungs,
	# KEINE Rotationsaenderung - siehe player_base.gd::camera_shoulder_offset
	# fuer die ausfuehrliche Begruendung, warum das (statt Camera3D.h_offset)
	# den Schuss-Raycast (origin=Kamera-Position, dir=Kamera-Blickrichtung)
	# automatisch treffergenau mitverschiebt, ohne dass hier irgendetwas am
	# Zielsystem angepasst werden muss.
	if _spring_arm:
		_kill_shoulder_tween()
		_shoulder_tween = _spring_arm.create_tween()
		_shoulder_tween.tween_property(_spring_arm, "position:x", sniper_aim_shoulder_offset, sniper_zoom_in_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _release_sniper_charge() -> void:
	_sniper_charging = false
	if _camera:
		_kill_fov_tween()
		_fov_tween = _camera.create_tween()
		_fov_tween.tween_property(_camera, "fov", _default_fov, sniper_zoom_out_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	if _spring_arm:
		_kill_shoulder_tween()
		_shoulder_tween = _spring_arm.create_tween()
		_shoulder_tween.tween_property(_spring_arm, "position:x", _default_shoulder_offset, sniper_zoom_out_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Der Schuss loest erst HIER aus (nicht beim Druecken) - deshalb bleibt
	# der 5s-Cooldown fuer die volle Ladedauer unangetastet und startet
	# tatsaechlich erst beim Loslassen, wie in der Spec verlangt.
	if _secondary_timer <= 0.0:
		_do_secondary()


func _kill_fov_tween() -> void:
	if _fov_tween != null and _fov_tween.is_valid():
		_fov_tween.kill()


func _kill_shoulder_tween() -> void:
	if _shoulder_tween != null and _shoulder_tween.is_valid():
		_shoulder_tween.kill()


## Sticky Targeting fuer die Sniper-ESP-Box waehrend Ladevorgang + Burst -
## gleiches Muster wie _resolve_uzi_target()/combat_winter.gd::
## _resolve_laser_target(). Rein visuell, unabhaengig vom eigentlichen
## Schuss-Aim-Assist (der bleibt der reine Richtungs-Slerp unten in
## _perform_secondary() - EnemyQuery.aim_assisted_direction() feuert immer
## auf den WINKEL-naechsten Kandidaten im Feuermoment, nicht zwingend auf
## dieses gelockte Ziel; beide finden in der Praxis fast immer denselben
## Gegner, weil dieselbe Kegel-/Reichweiten-Logik zugrunde liegt).
func _resolve_sniper_esp_target(origin: Vector3, look_dir: Vector3) -> Node3D:
	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
		var health: Node = _sniper_locked_target.find_child("Health", true, false)
		var alive: bool = health != null and health is Health and (health as Health).is_alive()
		var to_target: Vector3 = (_sniper_locked_target.global_position + Vector3.UP) - origin
		var in_range: bool = to_target.length() <= sniper_range
		var in_cone: bool = to_target.length_squared() > 0.0001 \
			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(aim_assist_angle_deg * 1.5)
		if alive and in_range and in_cone:
			return _sniper_locked_target

	return EnemyQuery.best_target_in_cone(origin, look_dir, sniper_range, aim_assist_angle_deg)


## _sniper_locked_target bleibt das Sticky-Targeting-Gedaechtnis fuer
## _resolve_sniper_esp_target() - die Anzeige selbst laeuft ueber den
## projektweiten Singular-Indikator, siehe scripts/vfx/esp_target.gd.
func _update_sniper_esp(target: Node3D) -> void:
	if target == null or not is_instance_valid(target):
		_clear_sniper_esp()
		return
	_sniper_locked_target = target
	EspTarget.acquire(target, uzi_esp_color)


func _clear_sniper_esp() -> void:
	if _sniper_locked_target != null:
		EspTarget.release(_sniper_locked_target)
	_sniper_locked_target = null


func _perform_secondary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung. Bewusst ueber die Camera3D selbst
	# statt SpringArm3D berechnet, damit hier keine Annahme ueber gleiche
	# Rotation zwischen beiden Nodes mehr noetig ist.
	var dir: Vector3 = EnemyQuery.aim_assisted_direction(
		origin, -_camera.global_transform.basis.z, sniper_range, aim_assist_angle_deg, aim_assist_strength
	)
	var dmg: float = sniper_damage_per_shot * _damage_multiplier()
	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null
	var landed_hit: bool = false

	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man schiesst"
	# - gleicher Grund wie bei der Uzi: nicht erst auf einen bestaetigten
	# Treffer warten. _sniper_locked_target ist bereits waehrend des Ladens
	# (siehe _poll_secondary_input()) ermittelt.
	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
		_lock_model_to(_sniper_locked_target)

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		
		var muzzle_pos: Vector3 = player.global_position + Vector3.UP * 1.3 + dir * 0.8 if player else origin
		_spawn_muzzle_vfx(muzzle_pos, dir, 2.5)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(muzzle_pos, result["position"], 0.9, 0.12)
		if result["hit"]:
			landed_hit = true
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			if spark:
				spark.scale *= 2.2
			_lock_model_to(result["target"])
			EspTarget.flash(result["target"])
		if i < sniper_shot_count - 1:
			await get_tree().create_timer(0.03).timeout

	if landed_hit:
		# Kurzer Hit-Stop + kraeftige Kamera-Erschuetterung statt nur Shake -
		# verkauft das Gewicht eines Treffers, der die meisten Gegner sofort
		# toetet, deutlich staerker als reines Wackeln.
		Juice.impact(0.6, Juice.DURATION_HEAVY)

	# Burst ist fertig (RMB feuert nur einmal pro Ladevorgang) - ESP-Box
	# wieder einsammeln, statt sie bis zum naechsten Ladevorgang haengen zu
	# lassen.
	_clear_sniper_esp()


func is_sniper_charging() -> bool:
	return _sniper_charging


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
# _damage_multiplier() und _lock_model_to() leben jetzt in combat_base.gd
# (identisch dupliziert in Giselle/Karina/Winter - siehe dortige Kommentare).
# Hitscan-Treffer loesen _lock_model_to() nicht automatisch aus, da sie NIE
# ueber die Hitbox-Signale laufen (siehe Kopfkommentar oben) - deshalb wird
# es hier weiterhin explizit nachgezogen.


## Sichtbarer Muendungsblitz-bis-Trefferpunkt-Streifen, kurz aufblitzend und
## sofort wieder weg (BeamVisual.create()/update() einmalig statt jeden
## Frame, siehe Winters Dauerstrahl fuer den Unterschied). Vorher hatte
## Giselle GAR KEINE sichtbare Flugbahn - nur Muendungsfunke und Einschlag,
## ohne Verbindung dazwischen wirkten ihre Schuesse kraftlos (Rueckmeldung
## "sieht sehr schwach aus").
func _spawn_tracer(origin: Vector3, endpoint: Vector3, radius_scale: float, life: float) -> void:
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color if data else Color(1.0, 0.85, 0.4)
	var beam: Dictionary = BeamVisual.create(self, color, radius_scale)
	if beam.is_empty():
		return
	BeamVisual.update(beam, origin, endpoint, 0.0)
	get_tree().create_timer(life).timeout.connect(func() -> void:
		BeamVisual.free_beam(beam)
	)


## BUGFIX "Partikel fliegen Richtung Kamera statt zum Ziel": vfx_dir war
## bisher "-dir" (also zurueck zum Schuetzen). vfx_manager.gd::spawn() ist
## eindeutig dokumentiert ("-Z des Effekts zeigt darauf, Godot-Konvention von
## look_at()") - mit "-dir" zeigte das lokale -Z des Muendungsblitzes damit
## RUECKWAERTS zur Kamera und +Z (nicht -Z) nach vorne zum Ziel, also genau
## verkehrt herum. Die alte Begruendung dafuer berief sich auf den
## "+Z ist vorne"-Kommentar in primary_hitbox.gd - der gilt aber nur fuer
## PrimaryHitbox, weil DIESES eine Area3D-Node im .tscn von Hand so gedreht
## wurde, dass sein +Z nach vorne zeigt. Das ist eine Eigenheit dieses einen
## Nodes, keine projektweite Konvention - fuer alles, was per VFX.spawn()
## ausgerichtet wird (wie hier), gilt ausschliesslich die -Z-Regel oben.
## "dir" (unnegiert) ist bereits die reine Schuss-/Blickrichtung, siehe
## Aufrufer - richtig ausgerichtet zeigt das jetzt tatsaechlich zum Ziel.
func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3, scale_mul: float = 1.0) -> void:
	var vfx_dir: Vector3 = dir
	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
	var data: CharacterData = PartyManager.get_active_data()
	var vfx: Node3D
	
	# Da AnimatedSprite3D von vfx_manager.gd (spawn_dual_tinted) nicht gefärbt wird,
	# funktioniert hier spawn() genauso gut für Originalfarben.
	if data != null:
		vfx = VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, spawn_pos, data.attack_color, data.attack_color_secondary, vfx_dir)
	else:
		vfx = VFX.spawn(MUZZLE_VFX_SCENE, spawn_pos, vfx_dir)
		
	if vfx != null and scale_mul != 1.0:
		vfx.scale *= scale_mul

```
</details>

### 💭 Thinking

`19:44:51`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `"target"|func fire` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\core\hitscan.gd`

`19:44:52`

```
24:## spawnen. Rueckgabe: {"hit": bool, "position": Vector3, "target": Node}.
25:static func fire(
29:	var result: Dictionary = {"hit": false, "position": from + dir * range, "target": null}
64:	result["target"] = body
```

### 🤖 Assistant: *Confirmed — `result["target"]` is a valid…*

`19:44:55`

> Confirmed — `result["target"]` is a valid key (Node, possibly null on miss; only used inside the `result["hit"]` branch so it's safe). Everything checks out.

#### TaskUpdate

`19:44:55`

`#7` · **status:** `completed`

✓ Updated `#7` — `status`

### 💭 Thinking: *Now I'm wrapping up by summarizing the changes…*

`19:45:01`

<details>
<summary>Thinking...</summary>

> Now I'm wrapping up by summarizing the changes made to each file so the user can see exactly what was modified to implement their requirements.…
</details>

#### 🔎 Grep `EnemyEspBox` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:45:01`

```
Found 2 files
scripts\vfx\esp_target.gd
scripts\vfx\enemy_esp_box.gd
```

### 🤖 Assistant: *Good, all references are consistent.*

`19:45:17`

> Good, all references are consistent. Everything's implemented and wired up. Here's a summary of all the changes made:
> 
> ## 1. Tutorial-Texte
> [scripts/tutorial_content.gd](scripts/tutorial_content.gd) — alle vier `*_DESCRIPTION`-Konstanten überarbeitet: nennen jetzt explizit LMB/RMB pro Waffe des Charakters, plus einen Shift-Dash-Hinweis (inkl. Dash-Schaden-Detail) bei Ningning.
> 
> ## 2. Minimap-Zoom
> [scripts/settings_manager.gd:120](scripts/settings_manager.gd:120) — `MINIMAP_ZOOM_DEFAULT` von `1.80` auf `1.60`.
> 
> ## 3. Cooldown-HUD vergrößert
> [scenes/ui/hud.tscn](scenes/ui/hud.tscn) — `AbilityBar` bekommt `scale = Vector2(1.3, 1.3)` mit `pivot_offset` auf die untere rechte Ecke, damit sie beim Vergrößern an der Bildschirmecke pinned bleibt statt über den Rand hinauszuwachsen.
> 
> ## 4. Gegner-Skalierung
> - [scripts/enemies/mortar_bot.gd:26](scripts/enemies/mortar_bot.gd:26) — `VISUAL_SCALE` nochmal um 15% reduziert (`4.5 * 0.85 * 0.85`).
> - [scripts/enemies/acid_sprinkler.gd:23](scripts/enemies/acid_sprinkler.gd:23) — `VISUAL_SCALE` um 15% reduziert (`3.0 * 0.85`). Kollisionsbox skaliert automatisch mit, da beide vom selben Faktor abgeleitet werden.
> 
> ## 5. Singuläres ESP-System (Bugfix + Rework)
> Root-Cause: Winter (Plasma + Laser) und Giselle (Uzi + Sniper) hielten je Waffe **eigene** Label3D/EnemyEspBox-Instanzen — daher konnten mehrere Boxen gleichzeitig auf demselben Gegner erscheinen, und ein Marker verschwand nur, wenn genau die Waffe, die ihn gebaut hatte, den Tod bemerkte.
> 
> Neue Architektur:
> - **[scripts/vfx/esp_target.gd](scripts/vfx/esp_target.gd)** (neu, als `EspTarget` in [project.godot](project.godot) autoloaded) — hält global **genau einen** Marker+Box. `acquire(target, color)` beansprucht ihn, `release(target)` gibt ihn nur frei, wenn der Aufrufer ihn tatsächlich noch hält (verhindert, dass eine Waffe die Anzeige einer anderen wegreißt), `flash(target)` pulst nur wenn er der aktuell angezeigte ist. `_process()` prüft **jeden Frame** die Lebendigkeit des Ziels, unabhängig davon welche Waffe feuert — das behebt "verschwindet nicht immer beim Tod".
> - **[scripts/characters/combat_winter.gd](scripts/characters/combat_winter.gd)** — Plasma zeigt ESP nur noch auf das primäre (nächste) Ziel statt einer Box pro Bolt; Laser ruft `EspTarget.acquire/flash/release` statt eigener Marker/Box.
> - **[scripts/characters/combat_giselle.gd](scripts/characters/combat_giselle.gd)** — Uzi und Sniper ebenso auf `EspTarget` umgestellt.
> 
> Ergebnis: zu jedem Zeitpunkt existiert höchstens ein ESP-Indikator im ganzen Spiel, er springt zum jeweils aktiv anvisierten/beschossenen Gegner und verschwindet zuverlässig sofort beim Tod.
> 
> Da ich in Godot nicht selbst spielen kann, bitte kurz im Editor testen (Tutorial-Texte, Minimap-Zoom-Default, HUD-Größe, Mörser/Säure-Sprinkler-Größe, ESP bei Winter/Giselle im Sandbox-Raum mit mehreren Gegnern).

## 🤷 User: *mein hud ist ganz weg Invalid assignment…*

`19:46:17`

mein hud ist ganz weg Invalid assignment of property or key 'process_mode' with value of type 'int' on a base object of type 'previously freed'. kam auch noch

### 💭 Thinking: *I'm seeing a Godot error about trying to…*

`19:46:25`

<details>
<summary>Thinking...</summary>

> I'm seeing a Godot error about trying to set `process_mode` on an object that's already been freed, which suggests something is getting cleaned up prematurely. The HUD has disappeared entirely, so this likely stems from my recent changes to the hud.tscn file where I adjusted the AbilityBar's scale and pivot offset, or something else is causing the HUD to be freed while code still tries to interact with it.…
</details>

#### 🔎 Grep `process_mode` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:46:26`

```
Found 24 files
scripts\items\item_manager.gd
scripts\party_manager.gd
scripts\main_menu.gd
scripts\treasure_manager.gd
scripts\vfx_test_room.gd
scripts\player_base.gd
scripts\enemy_sandbox_room.gd
scripts\pause_menu.gd
scripts\death_screen.gd
scripts\hub_room.gd
scripts\level\stage_manager.gd
scripts\bomb.gd
scripts\steam_manager.gd
scripts\seed_button.gd
scripts\run_timer.gd
scripts\run_restart.gd
scripts\room_commit_guard.gd
scripts\reset_overlay.gd
scripts\leaderboard_manager.gd
scripts\item_test_room.gd
scripts\hud_extra.gd
scripts\game_stats.gd
scripts\game_juice.gd
scripts\enemies\enemy_density.gd
```

### 🤖 Assistant: *That `#` comment I added inside the `.tscn…*

`19:46:47`

<details>
<summary>Thinking...</summary>

> I'm wondering if the HUD is breaking entirely due to a malformed tscn file rather than the ESP changes themselves—something like invalid Vector2 syntax in my hud.tscn edit could cause the scene to fail parsing, which would manifest as a runtime "previously freed" error even though the actual problem is during instantiation.
> 
> But wait, that doesn't quite fit either. The error is specifically about process_mode being set on a freed node, which suggests the scene loaded but something got cleaned up prematurely. This could be the ESP autoload adding nodes to the current scene, then when the floor transitions or the run restarts, those nodes get freed while HUD scripts like reset_overlay or pause_menu are still trying to manipulate them. Or maybe my AbilityBar pivot_offset change broke the tscn parsing entirely, causing the whole HUD scene to fail, which then triggers a queue_free chain that leaves dangling references.
> 
> Let me check what I actually wrote in that Vector2 syntax...
> 
> Actually, I'm realizing I may have added GDScript-style comments using `#` directly inside the .tscn file, which isn't valid — .tscn files don't support that kind of comment syntax the way GDScript does. The real issue is that `.tscn` files don't actually support `#` comments in property assignment blocks—they're meant to be machine-readable format, and adding comment lines there could cause parse errors or silent corruption that manifests as the "previously freed" node bug when the scene fails to load properly.…
</details>

> That `#` comment I added inside the `.tscn` node block is very likely the culprit — Godot's `.tscn` resource format doesn't support comments there, only actual `key = value` lines. That malforms the scene resource and can cascade into exactly this kind of "previously freed" error when the HUD tries to initialize. Let me check and fix it.

#### 👀 Read `hud.tscn`

`19:46:48`

*(lines 271–296)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn</code></summary>

```
[node name="AbilityBar" type="Control" parent="." unique_id=125991312]
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -374.0
offset_top = -104.0
offset_right = -14.0
offset_bottom = -20.0
grow_horizontal = 0
grow_vertical = 0
mouse_filter = 2
# Rueckmeldung "Cooldown-HUD unten rechts ist zu klein" (2026-08-13): um 30%
# vergroessert. pivot_offset sitzt auf der UNTEREN RECHTEN Ecke des lokalen
# Rects (= Groesse aus offset_right-offset_left/offset_bottom-offset_top
# oben, 360x84) statt der Standard-Ecke oben links - dadurch waechst die
# Bar beim Skalieren nach oben/links Richtung Bildschirmmitte und bleibt
# exakt an derselben Bildschirmecke haengen, statt ueber den Bildschirmrand
# hinauszuwachsen.
pivot_offset = Vector2(360, 84)
scale = Vector2(1.3, 1.3)

[node name="AbilityContainer" type="HBoxContainer" parent="AbilityBar" unique_id=1082566463]
```
</details>

### 💭 Thinking

`19:46:53`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `hud.tscn`

`19:46:56`

```diff
@@ -1,11 +1,4 @@ mouse_filter = 2
-# Rueckmeldung "Cooldown-HUD unten rechts ist zu klein" (2026-08-13): um 30%
-# vergroessert. pivot_offset sitzt auf der UNTEREN RECHTEN Ecke des lokalen
-# Rects (= Groesse aus offset_right-offset_left/offset_bottom-offset_top
-# oben, 360x84) statt der Standard-Ecke oben links - dadurch waechst die
-# Bar beim Skalieren nach oben/links Richtung Bildschirmmitte und bleibt
-# exakt an derselben Bildschirmecke haengen, statt ueber den Bildschirmrand
-# hinauszuwachsen.
 pivot_offset = Vector2(360, 84)
 scale = Vector2(1.3, 1.3)
 
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking: *The issue was a `#` comment I placed directly…*

`19:47:01`

<details>
<summary>Thinking...</summary>

> The issue was a `#` comment I placed directly inside the .tscn node's property block — Godot's scene format doesn't allow inline comments there like GDScript does, which broke the AbilityBar node parsing and cascaded into the HUD failing to load. Removing that comment and keeping just the actual properties should resolve it.…
</details>

#### 🔎 Grep `^#` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn`

`19:47:02`

```
No matches found
```

### 🤖 Assistant: *Clean now — no other stray comment lines…*

`19:47:07`

> Clean now — no other stray comment lines in the file.
> 
> Found it: I'd written a `#`-comment directly inside the `AbilityBar` node's property block in [hud.tscn](scenes/ui/hud.tscn). Godot's `.tscn` scene format is a resource file, not GDScript — it doesn't support inline comments there. That malformed the node's property list, which is exactly the kind of corruption that produces cascading "previously freed" errors when the HUD scene tries to build itself (a node reference ends up null/invalid partway through instantiation).
> 
> Fixed by removing the comment and keeping just the two actual properties:
> ```
> mouse_filter = 2
> pivot_offset = Vector2(360, 84)
> scale = Vector2(1.3, 1.3)
> ```
> 
> Please reload the project in the Godot editor (or just re-run) and check that the HUD is back. The ability bar should now appear ~30% larger, pinned to the bottom-right corner.

## 🤷 User: *mach die description vom tutorial anders…*

`19:58:20`

mach die description vom tutorial anders Allgemeine Mechanik: Dash DRÜCKE Shift, um einen schnellen Dash auszuführen und so Hindernisse zu überwinden oder Angriffen sicher auszuweichen.

1. Ningning (Start-Charakter) DRÜCKE LMB, um extrem schnelle Nahkampfschläge auszuführen und den Gegner dadurch im Stunlock zu halten. DRÜCKE RMB, um zu einem wuchtigen Haymaker auszuholen und massiven Schaden zu verursachen, der deine Feinde zurückwirft.

2. Giselle (Nach dem 1. Treasure Room) HALTE LMB, um deine Waffen im Dauerfeuer abzufeuern und deinen Gegnern auf Distanz konstanten Schaden zuzufügen. HALTE RMB und LASSE LOS, um die Kamera heranzuzoomen und einen präzisen 3-Schuss-Burst abzufeuern, der einzelne Ziele mit extremem Burst-Schaden vernichtet.

3. Karina (Nach dem 2. Treasure Room) HALTE LMB, um die Acid-Aura zu aktivieren und dein Tempo zu erhöhen, wodurch alle Gegner in deiner Nähe über Zeit vergiftet werden. DRÜCKE RMB, um Tarnung sowie Unverwundbarkeit zu aktivieren und berührte Gegner zu markieren, um sie bei Deaktivierung der Fähigkeit vernichtend in die Luft zu sprengen.

4. Winter (Nach dem 3. Treasure Room) DRÜCKE LMB, um zielsuchende Plasmabolzen abzufeuern, die Schaden verursachen und getroffene Gegner in Richtung des Einschlags ziehen. HALTE RMB, um einen kontinuierlichen Hitscan-Laserstrahl abzufeuern und alle Gegner in der Schusslinie zu schmelzen, solange deine Energiezelle reicht.

dazu noch folgende probleme:

description sollte für jeden player ein eigenen container machen wie für dash auch, nicht alles in einem block.

description steht im vordergrund wenn pause menu da ist nicht wie die anderen sachen im hud

### 💭 Thinking: *The user wants me to restructure the tutorial…*

`19:58:43`

<details>
<summary>Thinking...</summary>

> The user wants me to restructure the tutorial descriptions so each character (Ningning, Giselle, Karina, Winter) gets its own separate container, similar to how "Allgemeine Mechanik: Dash" is displayed as its own block, rather than cramming all the LMB/RMB information into a single paragraph per character. So the user wants each attack type (LMB and RMB) displayed as separate lines or blocks within each character's container, rather than merging them into one paragraph — and "wie für dash auch" confirms that Dash should get its own dedicated container just like the character do. The structure should be: one Dash container, then four character containers, with LMB and RMB info broken into distinct visual blocks within each character's panel.
> 
> I'm looking at how the tutorial system currently works — the add_entry function takes a single description string and puts it all in one Label. To split LMB and RMB into separate blocks, I'd need to either change the function signature to accept multiple description lines or restructure how TutorialContent provides the data so it's organized by ability type rather than flattened into one string.
> 
> There's also a layering issue: the TutorialCharacterIntro panel is rendering on its own CanvasLayer, which makes it appear in front of the pause menu when it shouldn't. TutorialCharacterIntro's layer 5 should be hidden behind the pause menu since pause_menu likely has a higher CanvasLayer value (around 100), but the issue is that TutorialCharacterIntro is rendering on top of the pause menu instead—probably because the pause menu isn't drawing a full-screen backdrop to visually cover lower layers, or there's a layer ordering problem where TutorialCharacterIntro's layer is being treated as higher priority than it should be.…
</details>

#### 🔎 Grep `layer\s*=` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd`

`19:58:44`

```
No matches found
```

### 💭 Thinking

`19:58:48`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `layer` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd`

`19:58:48`

```
6:# HUD liegt in JEDEM Level immer im selben CanvasLayer wie die Overlay-
53:	# Teil des Baums (eigener Autoload-CanvasLayer, siehe hud_extra.gd) und
```

### 💭 Thinking

`19:58:51`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `pause_menu.gd`

`19:58:52`

*(lines 1–71)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd</code></summary>

```

# scripts/pause_menu.gd
extends Control
class_name PauseMenu

# HUD liegt in JEDEM Level immer im selben CanvasLayer wie die Overlay-
# Screens (Pause/Death/Win/Settings), aber die tatsächliche Sibling-
# Reihenfolge im Szenenbaum variiert von Level zu Level (in level_01.tscn
# z.B. wird HUD als LETZTES Kind hinzugefügt -> würde ohne z_index über
# allem anderen liegen). z_index macht die Zeichenreihenfolge unabhängig
# davon, wie die Level-Autoren die Nodes im Baum anordnen.
const Z_INDEX_BLUR: int = 10
const Z_INDEX_MENU: int = 20

const MINIMAP_GROUP := "minimap"

## Action zum sofortigen Neustart des Levels. Ist in den Steuerungs-
## einstellungen rebindbar (SettingsManager.REBINDABLE_ACTIONS) und wird
## dort bei Bedarf automatisch angelegt (Fallback-Taste: R).
const RESET_ACTION := "reset"

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

@export var settings_menu_path: NodePath
var settings_menu: SettingsMenu

var _blur_overlay: ColorRect = null

## Ueberschrift ueber der Item-Liste.
const ITEM_LIST_TITLE: String = "GESAMMELTE ITEMS"
var _item_list: ItemSummaryList = null

## PHASE 5: Tausch-Widget fuer die beiden aktiven Item-Slots (Q/E).
var _active_swap_panel: ActiveItemSwapPanel = null

# Wird von death_screen.gd / win_screen.gd SOFORT beim Tod/Sieg gesetzt
# (nicht erst wenn der jeweilige Screen sichtbar wird — bei DeathScreen
# liegt dazwischen noch eine Verzögerung, siehe death_screen_delay). Damit
# ist ESC/Pause exakt ab dem Moment gesperrt, in dem das Spiel logisch
# vorbei ist, nicht erst ab dem sichtbaren Screen.
var _locked_out: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	z_index = Z_INDEX_MENU

	# Gruppe statt fester Pfad: ResetOverlay haengt in einem ganz anderen
	# Teil des Baums (eigener Autoload-CanvasLayer, siehe hud_extra.gd) und
	# braucht einen Weg, DIESES PauseMenu zu finden, ohne einen Node-Pfad
	# zu raten. Gleiches Muster wie "level_generator" oder "minimap".
	add_to_group("pause_menu")

	_blur_overlay = _get_or_create_shared_blur()
	_fix_panel_background()

	if settings_menu_path != NodePath(""):
		settings_menu = get_node_or_null(settings_menu_path)

	if settings_menu:
		settings_menu.back_pressed.connect(_on_settings_back)
	else:
		push_warning("PauseMenu: settings_menu_path ist nicht gesetzt — Settings-Button bleibt ohne Funktion.")

	# Der Button heisst im Editor noch "Quit" (siehe .tscn) - er fuehrt jetzt
	# aber zum Hauptmenue statt die Anwendung zu beenden (siehe
```
</details>

### 💭 Thinking: *PauseMenu is a Control node within the same…*

`19:59:00`

<details>
<summary>Thinking...</summary>

> PauseMenu is a Control node within the same CanvasLayer as HUD, using z_index to layer above its siblings, while TutorialCharacterIntro exists as its own separate CanvasLayer with a higher layer value, meaning it will always render on top regardless of z_index values within other layers.…
</details>

#### 🔎 Grep `CanvasLayer|^layer` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn`

`19:59:02`

```
No matches found
```

### 💭 Thinking: *So h…*

`19:59:07`

<details>
<summary>Thinking...</summary>

> So h…
</details>

#### 🔎 Grep `hud.tscn|PauseMenu|CanvasLayer` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_01.tscn`

`19:59:08`

```
14:[ext_resource type="PackedScene" uid="uid://bhudmain001" path="res://scenes/ui/hud.tscn" id="9_4ldtp"]
67:[node name="CanvasLayer" type="CanvasLayer" parent="." unique_id=1776630831]
69:[node name="SettingsMenu" parent="CanvasLayer" unique_id=1233549317 instance=ExtResource("2_wqkcq")]
71:[node name="PauseMenu" type="Control" parent="CanvasLayer" unique_id=1478100258]
81:[node name="Panel" type="Panel" parent="CanvasLayer/PauseMenu" unique_id=1344432630]
93:[node name="VBoxContainer" type="VBoxContainer" parent="CanvasLayer/PauseMenu/Panel" unique_id=1422702341]
108:[node name="ResumeButton" type="Button" parent="CanvasLayer/PauseMenu/Panel/VBoxContainer" unique_id=998992905]
113:[node name="RestartButton" type="Button" parent="CanvasLayer/PauseMenu/Panel/VBoxContainer" unique_id=1324223812]
118:[node name="SettingsButton" type="Button" parent="CanvasLayer/PauseMenu/Panel/VBoxContainer" unique_id=961620581]
124:[node name="QuitButton" type="Button" parent="CanvasLayer/PauseMenu/Panel/VBoxContainer" unique_id=925581170]
129:[node name="DeathScreen" type="Control" parent="CanvasLayer" unique_id=1480429303]
138:[node name="Panel" type="Panel" parent="CanvasLayer/DeathScreen" unique_id=573890384]
150:[node name="VBoxContainer" type="VBoxContainer" parent="CanvasLayer/DeathScreen/Panel" unique_id=1366865238]
164:[node name="SkillIssueLabel" type="Label" parent="CanvasLayer/DeathScreen/Panel/VBoxContainer" unique_id=2094192907]
170:[node name="KilledByLabel" type="Label" parent="CanvasLayer/DeathScreen/Panel/VBoxContainer" unique_id=1274677845]
174:[node name="ItemsBox" type="PanelContainer" parent="CanvasLayer/DeathScreen/Panel/VBoxContainer" unique_id=1805518122]
177:[node name="ItemsLabel" type="Label" parent="CanvasLayer/DeathScreen/Panel/VBoxContainer/ItemsBox" unique_id=559395413]
180:[node name="RestartButton" type="Button" parent="CanvasLayer/DeathScreen/Panel/VBoxContainer" unique_id=131945652]
185:[node name="QuitButton" type="Button" parent="CanvasLayer/DeathScreen/Panel/VBoxContainer" unique_id=2145800512]
190:[node name="WinScreen" type="Control" parent="CanvasLayer" unique_id=1047530491]
199:[node name="Panel" type="Panel" parent="CanvasLayer/WinScreen" unique_id=925826744]
207:[node name="VBoxContainer" type="VBoxContainer" parent="CanvasLayer/WinScreen/Panel" unique_id=945622863]
221:[node name="Label" type="Label" parent="CanvasLayer/WinScreen/Panel/VBoxContainer" unique_id=1453295413]
226:[node name="RestartButton" type="Button" parent="CanvasLayer/WinScreen/Panel/VBoxContainer" unique_id=1544556491]
230:[node name="QuitButton" type="Button" parent="CanvasLayer/WinScreen/Panel/VBoxContainer" unique_id=1334668019]
234:[node name="PostProcessLayer" type="CanvasLayer" parent="CanvasLayer" unique_id=1677253943]
237:[node name="CRTOverlay" type="ColorRect" parent="CanvasLayer/PostProcessLayer" unique_id=1471628108]
249:[node name="SubmersionOverlay" type="ColorRect" parent="CanvasLayer" unique_id=1643804787]
259:[node name="Boden" type="CSGBox3D" parent="CanvasLayer" unique_id=1059912180]
265:[node name="CSGBox3D" type="CSGBox3D" parent="CanvasLayer/Boden" unique_id=1932724860]
271:[node name="HUD" parent="CanvasLayer" unique_id=1091083640 instance=ExtResource("9_4ldtp")]
```

### 💭 Thinking: *So HUD, PauseMenu, DeathScreen, and WinScreen…*

`19:59:25`

<details>
<summary>Thinking...</summary>

> So HUD, PauseMenu, DeathScreen, and WinScreen are all siblings under the same CanvasLayer with the default layer value of 1, with PauseMenu positioned above HUD through its z_index of 20. TutorialCharacterIntro is a separate CanvasLayer created at runtime with layer set to 5.
> 
> Since 5 is greater than 1, TutorialCharacterIntro renders above everything in the main CanvasLayer, including the PauseMenu — that's the bug. To fix it, I should either attach TutorialCharacterIntro as a child of the existing CanvasLayer so it respects the z_index ordering with PauseMenu, or adjust its layer value to something that keeps it visible but below the pause/death/win overlays. So the real solution is to reparent TutorialCharacterIntro into the same CanvasLayer that holds the HUD and overlay screens, then use z_index to position it below the PauseMenu (which sits at z_index 20) but above the HUD's default z_index, keeping it properly layered without fragile global layer guessing.…
</details>

#### 👀 Read `level_generator.gd`

`19:59:26`

*(lines 475–505)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
		next_room.set_door_hack_exempt(back_dir, true)
		next_room.set_door_hack_enabled(back_dir, true)


## Permanentes UI-Panel mit den Charakter-Beschreibungen (siehe
## scripts/ui/tutorial_character_intro.gd) - Ningning sofort, jeder weitere
## Charakter, sobald sein CharacterPedestal genommen wird (Treasure.
## character_taken, siehe treasure_manager.gd/character_pedestal.gd).
func _setup_tutorial_ui() -> void:
	_tutorial_ui = TutorialCharacterIntro.new()
	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(_tutorial_ui)
	_tutorial_ui.add_entry(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)

	var treasure: Node = get_node_or_null("/root/Treasure")
	if treasure != null and treasure.has_signal("character_taken"):
		treasure.connect("character_taken", _on_tutorial_character_unlocked)


func _on_tutorial_character_unlocked(data: CharacterData) -> void:
	if _tutorial_ui == null or not is_instance_valid(_tutorial_ui):
		return
	_tutorial_ui.add_entry(data.character_name, TutorialContent.description_for(data))


func generate_next_stage_same_pattern() -> void:
	current_stage += 1
	_instantiate_layout(_current_layout)
```
</details>

### 💭 Thinking: *The key insight is that since this node extends…*

`19:59:44`

<details>
<summary>Thinking...</summary>

> The key insight is that since this node extends CanvasLayer with its own layer property set to 5, it operates on a global layering system—the layer value gets compared across all CanvasLayers in the viewport, so its position in the scene tree hierarchy doesn't matter for depth ordering.
> 
> To fix this without reparenting, I could lower the layer value below 1 to place it behind the main HUD layer entirely, but that's not quite right since we want it visible during normal gameplay. The real issue is that the HUD itself is already a sibling inside that same layer=1 CanvasLayer, and it's already behind the pause/death/win screens due to z_index ordering within that layer, so I need to think about whether reparenting into that CanvasLayer would actually solve the visibility problem more elegantly. Looking at the established pattern in the codebase where z_index is used for reliable stacking rather than tree order, I should apply the same approach here — the HUD and overlay screens already share a CanvasLayer and use z_index to manage their rendering order, so TutorialCharacterIntro should follow that same convention instead of relying on fragile layer equality or tree traversal order.…
</details>

#### 👀 Read `hud.tscn`

`19:59:44`

*(lines 37–52)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\ui\hud.tscn</code></summary>

```
border_color = Color(1, 0.95, 0.85, 0.9)
corner_radius_top_left = 3
corner_radius_top_right = 3
corner_radius_bottom_right = 3
corner_radius_bottom_left = 3

[node name="HUD" type="Control" unique_id=1278007826]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
script = ExtResource("1_hud")
```
</details>

### 💭 Thinking: *The HUD is a Control node nested under the…*

`19:59:55`

<details>
<summary>Thinking...</summary>

> The HUD is a Control node nested under the shared CanvasLayer in the level scene, sitting alongside PauseMenu with a default z_index of 0, so it renders below PauseMenu's z_index of 20. I need to apply the same approach to TutorialCharacterIntro—
> 
> make…
</details>

#### 🔎 Grep `add_to_group|class_name|group\(` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\hud.gd`

`19:59:56`

```
No matches found
```

### 💭 Thinking

`19:59:59`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `HUD|hud` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`20:00:00`

```
87:## werden muessten, sind genau das Muster, das im HUD schon einmal zu einem
202:## Feuert einmal, sobald der Run-Seed feststeht (HUD/Seed-Anzeige).
330:## Leaderboard-Eintrag und die Seed-Anzeige im HUD.
```

### 💭 Thinking: *I should check how other scripts reliably…*

`20:00:09`

<details>
<summary>Thinking...</summary>

> I should check how other scripts reliably locate the pause menu—they use the "pause_menu" group as defined in pause_menu.gd, and the minimap similarly uses a "minimap" group. I need to see if there's a "hud" group assigned to the HUD node, or look at how run_timer.gd handles a similar docking pattern to understand the pattern better.…
</details>

#### 🔎 Grep `pause_menu|get_tree\(\).get_nodes_in_group` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\reset_overlay.gd`

`20:00:10`

```
59:## Begruendung in pause_menu.gd, wo frueher ein zweiter, konkurrierender
62:const PAUSE_MENU_GROUP: String = "pause_menu"
71:var _pause_menu: PauseMenu = null
190:	# durcheinanderbringen. Diese Sperre stand FRUEHER in pause_menu.gd, das
223:	if _pause_menu == null or not is_instance_valid(_pause_menu):
224:		var found: Array[Node] = get_tree().get_nodes_in_group(PAUSE_MENU_GROUP)
225:		_pause_menu = found[0] as PauseMenu if not found.is_empty() else null
226:	if _pause_menu == null or not is_instance_valid(_pause_menu):
228:	return _pause_menu.is_reset_blocked()
309:	var generators: Array = get_tree().get_nodes_in_group("level_generator")
```

### 💭 Thinking: *I'll find the PauseMenu node using that group…*

`20:01:06`

<details>
<summary>Thinking...</summary>

> I'll find the PauseMenu node using that group query, then restructure TutorialCharacterIntro as a Control sibling with a lower z-index so the pause menu renders on top of it naturally. Setting mouse_filter to IGNORE on the root Control so it doesn't block input to elements below it, since only the PanelContainer child needs to be interactive. So I'll remove the layer assignment in `_ready()` and rely on the CanvasLayer parent to handle depth ordering—the panel will naturally sit above the 3D world but below overlay menus since it's part of the same HUD layer structure.
> 
> For parenting, I need to update `_setup_tutorial_ui()` to find and use the overlay CanvasLayer instead of adding directly to the current scene, following the same pattern used elsewhere for overlay management. I'm finishing the fallback logic to return the current scene or root node if needed, then verifying that the pause_menu group node will actually exist when this setup runs—checking whether Godot's _ready() call order across sibling nodes happens in the right sequence for this to work reliably. So the group lookup should work fine since the pause menu gets initialized before the tutorial UI setup runs. Now I'm ready to implement the solution, starting with the tutorial description content — the user provided exact German text for five separate tutorial blocks covering general mechanics, character abilities, and controls.
> 
> The key insight from the user's feedback is that each tutorial entry (Dash plus the four characters) needs its own dedicated container rather than grouping them together, maintaining consistent visual treatment across all entries. The headers like "Ningning (Start-Charakter)" are meant to be the name parameter for each entry, so I'll restructure to create five separate containers instead of merging Dash into Ningning's block. "Ningning" without the numbering or unlock context. The header with the numbering and unlock conditions is just organizational scaffolding to help me map which description belongs to which character — the actual UI should only show the character name as the title and the ability description (the DRÜCKE/HALTE text) as the body.
> 
> The user also wants each ability to have its own container rather than merging them together, so I'll split the LMB and RMB descriptions into separate visual blocks within each character's entry. I should also add Dash as its own standalone entry at the top level, treated the same way as the character abilities.
> 
> To implement this, I'll restructure the data to support multiple description lines per entry instead of a single string, then render each line as its own Label component within a VBoxContainer for clean spacing and readability.
> 
> The new method signature will be `add_entry(title: String, description_lines: Array[String])`, and I'll define constants for the Dash and Ningning entries with their multi-line descriptions in German.
> 
> Defining character descriptions... Adding character ability descriptions...…
</details>

#### 🔎 Grep `description_for|NINGNING_DESCRIPTION|GISELLE_DESCRIPTION|KARINA_DESCRIPTION|WINTER_DESCRIPTION` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`20:01:07`

Glob: `**/*.gd`

```
Found 2 files
scripts\tutorial_content.gd
scenes\level_generation\level_generator.gd
```

### 💭 Thinking: *The type is safe to change to Array[String…*

`20:01:14`

<details>
<summary>Thinking...</summary>

> The type is safe to change to Array[String] since it's only used in those two places. Now I need to update the tutorial_content.gd constants and the description_for() method signature, then modify tutorial_character_intro.gd to accept an array of description lines and render each one as a separate label block.…
</details>

#### 👀 Read `tutorial_content.gd`

`20:01:15`

*(lines 1–41)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
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
## Dash-Mechanik erklaeren" (2026-08-13): alle vier Beschreibungen nennen
## jetzt explizit LMB/RMB fuer die beiden Waffen des jeweiligen Charakters,
## plus einen Hinweis auf die (charakterunabhaengige, siehe combat_base.gd)
## Shift-Dash-Mechanik - Q/E bleiben bewusst unerwaehnt, die sind laut
## CLAUDE.md keine Charakter-Faehigkeiten, sondern die beiden aktiven
## Item-Slots.
const NINGNING_DESCRIPTION: String = "Ningning: Nahkämpferin mit Schlagkombos und Explosionen. Drücke LMB [Linke Maustaste] für schnelle Jabs, halte RMB [Rechte Maustaste] für einen aufgeladenen Wuchtschlag mit Knockback. Mit Shift dashst du über Hindernisse hinweg - auch durch Gegner hindurch, was zusätzlich Schaden macht."
const GISELLE_DESCRIPTION: String = "Giselle: Fernkämpferin mit zwei automatisch zielenden Waffen. Halte LMB [Linke Maustaste] für die Uzi-Dauerfeuer-Salve, halte RMB [Rechte Maustaste] zum Einzoomen und lass los für einen tödlichen Sniper-Burst. Mit Shift dashst du über Hindernisse hinweg."
const KARINA_DESCRIPTION: String = "Karina kämpft im Nahkampf mit ätzender Säure und wird kurz unsichtbar, um mehrere Gegner zu markieren und per Explosion zu richten. Halte LMB [Linke Maustaste] für die Säure-Aura um sie herum, halte RMB [Rechte Maustaste] für die Tarnung. Mit Shift dashst du über Hindernisse hinweg."
const WINTER_DESCRIPTION: String = "Winter kontrolliert die Distanz mit homing Plasma-Geschossen und einem Dauer-Laserstrahl. Drücke LMB [Linke Maustaste] für die Plasma-Geschosse, halte RMB [Rechte Maustaste] für den Laserstrahl. Mit Shift dashst du über Hindernisse hinweg."

## Raumtyp je Kettenzelle, 1:1 an RoomGridGenerator.generate_fixed_layout()
## durchgereicht.
static func room_types() -> Array[int]:
	return [
		RoomData.RoomType.COMBAT,    # 0: Fight1
```
</details>

### 💭 Thinking

`20:01:18`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `tutorial_content.gd`

`20:01:19`

*(lines 84–119)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
		8: # Final Fight: Mix aus allen zuvor gezeigten Gegnern
			return [_fighter_factory(), _scout_factory(), _shield_drone_factory(), _plasma_beam_bot_factory()]
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


## UI-Beschreibungstext fuer einen soeben freigeschalteten Charakter -
## anhand character_id statt Objekt-Identitaet, robust gegen dupliziert
## geladene Ressourcen.
static func description_for(data: CharacterData) -> String:
	if data == null:
		return ""
	match String(data.character_id):
		"giselle":
			return GISELLE_DESCRIPTION
		"karina":
			return KARINA_DESCRIPTION
		"winter":
			return WINTER_DESCRIPTION
		_:
```
</details>

### 🤖 Assistant: *Now let's rewrite the description constants…*

`20:01:21`

> Now let's rewrite the description constants and `description_for()` to use per-line arrays with the exact wording provided.

#### ✏️  Edit `tutorial_content.gd`

`20:01:40`

```diff
@@ -1,11 +1,35 @@ ## Rueckmeldung "Tutorial-Texte sollen Tasten-Inputs erwaehnen und die
-## Dash-Mechanik erklaeren" (2026-08-13): alle vier Beschreibungen nennen
-## jetzt explizit LMB/RMB fuer die beiden Waffen des jeweiligen Charakters,
-## plus einen Hinweis auf die (charakterunabhaengige, siehe combat_base.gd)
-## Shift-Dash-Mechanik - Q/E bleiben bewusst unerwaehnt, die sind laut
-## CLAUDE.md keine Charakter-Faehigkeiten, sondern die beiden aktiven
-## Item-Slots.
-const NINGNING_DESCRIPTION: String = "Ningning: Nahkämpferin mit Schlagkombos und Explosionen. Drücke LMB [Linke Maustaste] für schnelle Jabs, halte RMB [Rechte Maustaste] für einen aufgeladenen Wuchtschlag mit Knockback. Mit Shift dashst du über Hindernisse hinweg - auch durch Gegner hindurch, was zusätzlich Schaden macht."
-const GISELLE_DESCRIPTION: String = "Giselle: Fernkämpferin mit zwei automatisch zielenden Waffen. Halte LMB [Linke Maustaste] für die Uzi-Dauerfeuer-Salve, halte RMB [Rechte Maustaste] zum Einzoomen und lass los für einen tödlichen Sniper-Burst. Mit Shift dashst du über Hindernisse hinweg."
-const KARINA_DESCRIPTION: String = "Karina kämpft im Nahkampf mit ätzender Säure und wird kurz unsichtbar, um mehrere Gegner zu markieren und per Explosion zu richten. Halte LMB [Linke Maustaste] für die Säure-Aura um sie herum, halte RMB [Rechte Maustaste] für die Tarnung. Mit Shift dashst du über Hindernisse hinweg."
-const WINTER_DESCRIPTION: String = "Winter kontrolliert die Distanz mit homing Plasma-Geschossen und einem Dauer-Laserstrahl. Drücke LMB [Linke Maustaste] für die Plasma-Geschosse, halte RMB [Rechte Maustaste] für den Laserstrahl. Mit Shift dashst du über Hindernisse hinweg."
+## Dash-Mechanik erklaeren" (2026-08-13), dann per Rueckmeldung "eigener
+## Container pro Charakter/Faehigkeit, nicht alles in einem Textblock"
+## nachgeschaerft: jede Faehigkeit (Dash, LMB, RMB) ist jetzt eine EIGENE
+## Zeile/Array-Eintrag statt eines einzigen Fliesstext-Blocks - siehe
+## scripts/ui/tutorial_character_intro.gd::add_entry(), das pro Eintrag
+## einen eigenen Label pro Zeile baut. Q/E bleiben bewusst unerwaehnt, die
+## sind laut CLAUDE.md keine Charakter-Faehigkeiten, sondern die beiden
+## aktiven Item-Slots.
+##
+## DASH ist keine Charakter-, sondern eine allgemeine, charakterunabhaengige
+## Mechanik (siehe combat_base.gd) - deshalb ein eigener Eintrag statt Teil
+## irgendeiner Charakterbeschreibung, siehe level_generator.gd::
+## _setup_tutorial_ui().
+const DASH_TITLE: String = "Allgemeine Mechanik: Dash"
+const DASH_DESCRIPTION: Array[String] = [
+	"DRÜCKE Shift, um einen schnellen Dash auszuführen und so Hindernisse zu überwinden oder Angriffen sicher auszuweichen.",
+]
+
+const NINGNING_DESCRIPTION: Array[String] = [
+	"DRÜCKE LMB, um extrem schnelle Nahkampfschläge auszuführen und den Gegner dadurch im Stunlock zu halten.",
+	"DRÜCKE RMB, um zu einem wuchtigen Haymaker auszuholen und massiven Schaden zu verursachen, der deine Feinde zurückwirft.",
+]
+const GISELLE_DESCRIPTION: Array[String] = [
+	"HALTE LMB, um deine Waffen im Dauerfeuer abzufeuern und deinen Gegnern auf Distanz konstanten Schaden zuzufügen.",
+	"HALTE RMB und LASSE LOS, um die Kamera heranzuzoomen und einen präzisen 3-Schuss-Burst abzufeuern, der einzelne Ziele mit extremem Burst-Schaden vernichtet.",
+]
+const KARINA_DESCRIPTION: Array[String] = [
+	"HALTE LMB, um die Acid-Aura zu aktivieren und dein Tempo zu erhöhen, wodurch alle Gegner in deiner Nähe über Zeit vergiftet werden.",
+	"DRÜCKE RMB, um Tarnung sowie Unverwundbarkeit zu aktivieren und berührte Gegner zu markieren, um sie bei Deaktivierung der Fähigkeit vernichtend in die Luft zu sprengen.",
+]
+const WINTER_DESCRIPTION: Array[String] = [
+	"DRÜCKE LMB, um zielsuchende Plasmabolzen abzufeuern, die Schaden verursachen und getroffene Gegner in Richtung des Einschlags ziehen.",
+	"HALTE RMB, um einen kontinuierlichen Hitscan-Laserstrahl abzufeuern und alle Gegner in der Schusslinie zu schmelzen, solange deine Energiezelle reicht.",
+]
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now update `description_for()`'s return type…*

`20:01:42`

> Now update `description_for()`'s return type and fallback:

#### ✏️  Edit `tutorial_content.gd`

`20:01:46`

```diff
@@ -1,9 +1,10 @@-## UI-Beschreibungstext fuer einen soeben freigeschalteten Charakter -
+## UI-Beschreibungszeilen fuer einen soeben freigeschalteten Charakter -
 ## anhand character_id statt Objekt-Identitaet, robust gegen dupliziert
-## geladene Ressourcen.
-static func description_for(data: CharacterData) -> String:
+## geladene Ressourcen. Array statt einem String: jede Zeile wird als
+## eigener Block dargestellt, siehe tutorial_character_intro.gd::add_entry().
+static func description_for(data: CharacterData) -> Array[String]:
 	if data == null:
-		return ""
+		return []
 	match String(data.character_id):
 		"giselle":
 			return GISELLE_DESCRIPTION
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:01:49`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `tutorial_content.gd`

`20:01:49`

*(lines 116–126)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
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
```
</details>

### 💭 Thinking

`20:01:53`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `data.description` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd`

`20:01:53`

```
144:			return data.description
```

#### 👀 Read `tutorial_content.gd`

`20:01:56`

*(lines 139–147)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
		"karina":
			return KARINA_DESCRIPTION
		"winter":
			return WINTER_DESCRIPTION
		_:
			return data.description


```
</details>

#### ✏️  Edit `tutorial_content.gd`

`20:02:00`

```diff
@@ -1,4 +1,4 @@ 		"winter":
 			return WINTER_DESCRIPTION
 		_:
-			return data.description
+			return [data.description]
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's rewrite `tutorial_character_intro…*

`20:02:02`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now let's rewrite `tutorial_character_intro.gd` — multi-line entries, and fix the CanvasLayer stacking bug (root becomes a `Control` living inside the same CanvasLayer as HUD/PauseMenu instead of its own independent `layer=5` CanvasLayer).

#### 👀 Read `tutorial_character_intro.gd`

`20:02:04`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\ui\tutorial_character_intro.gd</code></summary>

```
extends CanvasLayer
class_name TutorialCharacterIntro

# ============================================================================
# TutorialCharacterIntro — permanente, WACHSENDE Liste von Charakter-
# Kurzbeschreibungen fuer den Tutorial-Modus (level_generator.gd::
# generate_tutorial_stage()).
# ============================================================================
# Anders als item_description_hud.gd (Popup, blendet nach Zeit/Distanz wieder
# aus) bleibt hier JEDER Eintrag fuer den Rest des Tutorials sichtbar - jeder
# neu freigeschaltete Charakter haengt eine weitere Zeile an, nichts wird
# ersetzt oder entfernt. Bewusst als eigenstaendiges CanvasLayer statt Teil
# von hud.tscn: nur im Tutorial gebraucht, hud.tscn bleibt unangetastet.
#
# --- Andocken an die Minimap ------------------------------------------------
# Statt einer festen Bildschirmposition haengt sich das Panel UNTER die
# Minimap - exakt dasselbe Problem/dieselbe Loesung wie run_timer.gd (dockt
# rechts daneben): Minimap.get_docking_rect() liefert das tatsaechlich
# belegte, mit SettingsManager.minimap_ui_scale skalierungskorrigierte
# Rechteck. Ohne das wuerde ein Aendern der Minimap-Groesse im Optionsmenue
# das Panel entweder unter der Minimap verschwinden oder mit Luecke
# davonstehen lassen.

const PANEL_COLOR: Color = Color(0.05, 0.05, 0.08, 0.86)
const NAME_COLOR: Color = Color(0.95, 0.85, 0.35)
const DESC_COLOR: Color = Color(0.88, 0.88, 0.92)
const MAX_WIDTH: float = 420.0

const MINIMAP_GROUP: String = "minimap"

## Abstand zwischen Minimap-Rahmen und diesem Panel in Pixeln.
@export var dock_gap: float = 16.0

## Position, falls keine Minimap existiert (z.B. Testszene ohne HUD).
const FALLBACK_POSITION: Vector2 = Vector2(24.0, 24.0)

var _list: VBoxContainer = null
var _panel: PanelContainer = null
var _minimap: Control = null


func _ready() -> void:
	layer = 5

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_panel.position = FALLBACK_POSITION

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	_panel.add_child(_list)

	if SettingsManager != null and SettingsManager.has_signal("minimap_setting_changed"):
		if not SettingsManager.minimap_setting_changed.is_connected(_update_dock):
			SettingsManager.minimap_setting_changed.connect(_update_dock)
	get_viewport().size_changed.connect(_update_dock)

	# Ein Frame warten: die Minimap baut ihr Raum-Overlay/ihren Rahmen noch
	# in ihrer eigenen _ready() fertig - wer vorher misst, dockt an die noch
	# unfertige Groesse an (identisches Muster wie run_timer.gd).
	_update_dock.call_deferred()


## Setzt die Y-Position direkt unter die Minimap. Idempotent.
func _update_dock() -> void:
	if _minimap == null or not is_instance_valid(_minimap):
		var found: Array[Node] = get_tree().get_nodes_in_group(MINIMAP_GROUP)
		if found.is_empty():
			_panel.position = FALLBACK_POSITION
			return
		_minimap = found[0] as Control

	if _minimap == null or not _minimap.has_method("get_docking_rect"):
		_panel.position = FALLBACK_POSITION
		return

	if not _minimap.visible:
		_panel.position = FALLBACK_POSITION
		return

	var rect: Rect2 = _minimap.get_docking_rect()
	_panel.position = Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)


func _process(_delta: float) -> void:
	# Guenstiger Abgleich, deckt die getweente Groessenaenderung beim
	# Oeffnen/Schliessen der Grosskarte ab, die kein eigenes Signal hat -
	# identisches Muster wie run_timer.gd::_process().
	if _minimap == null or not is_instance_valid(_minimap) or _panel == null:
		return
	if not _minimap.visible:
		return
	var rect: Rect2 = _minimap.get_docking_rect()
	var wanted := Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)
	if not _panel.position.is_equal_approx(wanted):
		_panel.position = wanted


## Haengt einen weiteren, permanenten Eintrag an - wird von
## level_generator.gd bei jedem Charakter-Unlock (inkl. dem Start-Charakter
## im Corridor) aufgerufen. Nichts wird je entfernt oder ersetzt.
func add_entry(char_name: String, description: String) -> void:
	if _list == null:
		return

	var entry := VBoxContainer.new()
	entry.add_theme_constant_override("separation", 2)

	var name_label := Label.new()
	name_label.text = char_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", NAME_COLOR)
	entry.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", DESC_COLOR)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.custom_minimum_size = Vector2(MAX_WIDTH - 32.0, 0.0)
	entry.add_child(desc_label)

	_list.add_child(entry)

```
</details>

### 💭 Thinking: *The user wants each player to have their…*

`20:02:24`

<details>
<summary>Thinking...</summary>

> The user wants each player to have their own separate container or card, similar to how Dash is displayed, rather than having all five players listed together in a single panel with one shared list container. Refactoring the layout structure so each entry gets its own PanelContainer with styling, rather than nesting everything in a single shared panel — the `_list` VBoxContainer becomes the root positioned element, and `add_entry()` now creates individual styled panels for each entry (dashboard and characters) that get appended to it.
> 
> I need to set `custom_minimum_size` on each PanelContainer to enforce consistent width, add spacing between entries for visual separation, and rewrite the full script. Also switching the root from CanvasLayer to Control to fix the pause menu z-order issue, removing the layer property, and letting it sit as a sibling in the shared CanvasLayer — the Control's size won't matter for mouse interception since children can overflow and render fine without clipping enabled.…
</details>

#### ✍️  Write `tutorial_character_intro.gd`

`20:02:52`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\ui\tutorial_character_intro.gd</code></summary>

```
extends Control
class_name TutorialCharacterIntro

# ============================================================================
# TutorialCharacterIntro — permanente, WACHSENDE Liste von Kurzbeschreibungen
# (Dash-Mechanik + pro Charakter) fuer den Tutorial-Modus (level_generator.gd
# ::generate_tutorial_stage()).
# ============================================================================
# Anders als item_description_hud.gd (Popup, blendet nach Zeit/Distanz wieder
# aus) bleibt hier JEDER Eintrag fuer den Rest des Tutorials sichtbar - jeder
# neu freigeschaltete Charakter (bzw. die Dash-Mechanik ganz zu Anfang)
# haengt einen weiteren Eintrag an, nichts wird ersetzt oder entfernt.
#
# Rueckmeldung "eigener Container pro Eintrag statt allem in einem Block"
# (2026-08-13): jeder add_entry()-Aufruf baut jetzt seine EIGENE
# PanelContainer-"Karte" (Hintergrund/Rahmen wie vorher), gestapelt in
# _list - vorher haengten alle Eintraege als reine VBoxContainer OHNE
# eigenen Hintergrund in einer einzigen gemeinsamen PanelContainer, was
# optisch wie ein einziger durchgehender Block wirkte.
#
# Rueckmeldung "Beschreibung liegt beim Pause-Menu im Vordergrund, anders als
# der Rest vom HUD" (2026-08-13): war vorher ein EIGENES CanvasLayer mit
# layer = 5 - da HUD/PauseMenu/DeathScreen/WinScreen alle im SELBEN
# CanvasLayer der jeweiligen Level-Szene liegen (siehe pause_menu.gd-
# Kopfkommentar) und dessen Layer-Nummer nicht garantiert unter 5 liegt,
# zeichnete sich dieses Panel als eigenes CanvasLayer IMMER ueber das
# Pause-Menu, unabhaengig von dessen z_index. Jetzt ist es ein normaler
# Control, den level_generator.gd als Kind INS SELBE CanvasLayer wie
# HUD/PauseMenu haengt (siehe _find_overlay_layer() dort) - dadurch gilt
# fuer die Zeichenreihenfolge PauseMenu.z_index (siehe pause_menu.gd::
# Z_INDEX_MENU) ganz normal, genau wie fuer den Rest vom HUD.
#
# --- Andocken an die Minimap ------------------------------------------------
# Statt einer festen Bildschirmposition haengt sich die Liste UNTER die
# Minimap - exakt dasselbe Problem/dieselbe Loesung wie run_timer.gd (dockt
# rechts daneben): Minimap.get_docking_rect() liefert das tatsaechlich
# belegte, mit SettingsManager.minimap_ui_scale skalierungskorrigierte
# Rechteck. Ohne das wuerde ein Aendern der Minimap-Groesse im Optionsmenue
# die Liste entweder unter der Minimap verschwinden oder mit Luecke
# davonstehen lassen.

const PANEL_COLOR: Color = Color(0.05, 0.05, 0.08, 0.86)
const NAME_COLOR: Color = Color(0.95, 0.85, 0.35)
const DESC_COLOR: Color = Color(0.88, 0.88, 0.92)
const MAX_WIDTH: float = 420.0

const MINIMAP_GROUP: String = "minimap"

## Abstand zwischen Minimap-Rahmen und der Liste in Pixeln.
@export var dock_gap: float = 16.0
## Abstand zwischen den einzelnen Eintrags-Karten.
@export var entry_gap: float = 10.0

## Position, falls keine Minimap existiert (z.B. Testszene ohne HUD).
const FALLBACK_POSITION: Vector2 = Vector2(24.0, 24.0)

var _list: VBoxContainer = null
var _minimap: Control = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_list = VBoxContainer.new()
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_list.add_theme_constant_override("separation", entry_gap)
	add_child(_list)
	_list.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_list.position = FALLBACK_POSITION

	if SettingsManager != null and SettingsManager.has_signal("minimap_setting_changed"):
		if not SettingsManager.minimap_setting_changed.is_connected(_update_dock):
			SettingsManager.minimap_setting_changed.connect(_update_dock)
	get_viewport().size_changed.connect(_update_dock)

	# Ein Frame warten: die Minimap baut ihr Raum-Overlay/ihren Rahmen noch
	# in ihrer eigenen _ready() fertig - wer vorher misst, dockt an die noch
	# unfertige Groesse an (identisches Muster wie run_timer.gd).
	_update_dock.call_deferred()


## Setzt die Y-Position direkt unter die Minimap. Idempotent.
func _update_dock() -> void:
	if _minimap == null or not is_instance_valid(_minimap):
		var found: Array[Node] = get_tree().get_nodes_in_group(MINIMAP_GROUP)
		if found.is_empty():
			_list.position = FALLBACK_POSITION
			return
		_minimap = found[0] as Control

	if _minimap == null or not _minimap.has_method("get_docking_rect"):
		_list.position = FALLBACK_POSITION
		return

	if not _minimap.visible:
		_list.position = FALLBACK_POSITION
		return

	var rect: Rect2 = _minimap.get_docking_rect()
	_list.position = Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)


func _process(_delta: float) -> void:
	# Guenstiger Abgleich, deckt die getweente Groessenaenderung beim
	# Oeffnen/Schliessen der Grosskarte ab, die kein eigenes Signal hat -
	# identisches Muster wie run_timer.gd::_process().
	if _minimap == null or not is_instance_valid(_minimap) or _list == null:
		return
	if not _minimap.visible:
		return
	var rect: Rect2 = _minimap.get_docking_rect()
	var wanted := Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)
	if not _list.position.is_equal_approx(wanted):
		_list.position = wanted


## Haengt eine weitere, permanente Eintrags-Karte an - wird von
## level_generator.gd fuer die Dash-Mechanik (sofort) und bei jedem
## Charakter-Unlock (inkl. dem Start-Charakter im Corridor) aufgerufen.
## Nichts wird je entfernt oder ersetzt. "description_lines" ist eine Zeile
## pro Faehigkeit (z.B. eine fuer LMB, eine fuer RMB) - jede Zeile bekommt
## ihren eigenen Label statt eines einzigen zusammenhaengenden Fliesstexts.
func add_entry(title: String, description_lines: Array[String]) -> void:
	if _list == null:
		return

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", style)
	_list.add_child(card)

	var entry := VBoxContainer.new()
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.add_theme_constant_override("separation", 4)
	card.add_child(entry)

	var name_label := Label.new()
	name_label.text = title
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", NAME_COLOR)
	entry.add_child(name_label)

	for line: String in description_lines:
		var desc_label := Label.new()
		desc_label.text = line
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", DESC_COLOR)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.custom_minimum_size = Vector2(MAX_WIDTH - 32.0, 0.0)
		entry.add_child(desc_label)

```
</details>

✓ The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\ui\tutorial_character_intro.gd has been updated successfully. (file state is current in your context — no need to Read it back)

### 💭 Thinking

`20:02:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `level_generator.gd`

`20:02:57`

*(lines 476–501)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
		next_room.set_door_hack_enabled(back_dir, true)


## Permanentes UI-Panel mit den Charakter-Beschreibungen (siehe
## scripts/ui/tutorial_character_intro.gd) - Ningning sofort, jeder weitere
## Charakter, sobald sein CharacterPedestal genommen wird (Treasure.
## character_taken, siehe treasure_manager.gd/character_pedestal.gd).
func _setup_tutorial_ui() -> void:
	_tutorial_ui = TutorialCharacterIntro.new()
	var parent: Node = get_tree().current_scene
	if parent == null:
		parent = get_tree().get_root()
	parent.add_child(_tutorial_ui)
	_tutorial_ui.add_entry(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)

	var treasure: Node = get_node_or_null("/root/Treasure")
	if treasure != null and treasure.has_signal("character_taken"):
		treasure.connect("character_taken", _on_tutorial_character_unlocked)


func _on_tutorial_character_unlocked(data: CharacterData) -> void:
	if _tutorial_ui == null or not is_instance_valid(_tutorial_ui):
		return
	_tutorial_ui.add_entry(data.character_name, TutorialContent.description_for(data))

```
</details>

#### ✏️  Edit `level_generator.gd`

`20:03:10`

```diff
@@ -1,13 +1,11 @@ ## Permanentes UI-Panel mit den Charakter-Beschreibungen (siehe
-## scripts/ui/tutorial_character_intro.gd) - Ningning sofort, jeder weitere
-## Charakter, sobald sein CharacterPedestal genommen wird (Treasure.
-## character_taken, siehe treasure_manager.gd/character_pedestal.gd).
+## scripts/ui/tutorial_character_intro.gd) - Dash-Hinweis + Ningning sofort,
+## jeder weitere Charakter, sobald sein CharacterPedestal genommen wird
+## (Treasure.character_taken, siehe treasure_manager.gd/character_pedestal.gd).
 func _setup_tutorial_ui() -> void:
 	_tutorial_ui = TutorialCharacterIntro.new()
-	var parent: Node = get_tree().current_scene
-	if parent == null:
-		parent = get_tree().get_root()
-	parent.add_child(_tutorial_ui)
+	_find_overlay_layer().add_child(_tutorial_ui)
+	_tutorial_ui.add_entry(TutorialContent.DASH_TITLE, TutorialContent.DASH_DESCRIPTION)
 	_tutorial_ui.add_entry(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)
 
 	var treasure: Node = get_node_or_null("/root/Treasure")
@@ -15,6 +13,23 @@ 		treasure.connect("character_taken", _on_tutorial_character_unlocked)
 
 
+## Findet das CanvasLayer, in dem HUD/PauseMenu/DeathScreen/WinScreen liegen
+## (siehe pause_menu.gd-Kopfkommentar) - ueber die "pause_menu"-Gruppe,
+## gleiches Muster wie reset_overlay.gd. TutorialCharacterIntro MUSS dort
+## haengen statt in current_scene direkt: als eigenes, spaeter hinzugefuegtes
+## CanvasLayer wuerde es sich sonst unabhaengig von PauseMenu.z_index IMMER
+## ueber das Pause-Menu zeichnen (Rueckmeldung "Beschreibung liegt beim
+## Pause-Menu im Vordergrund, anders als der Rest vom HUD").
+func _find_overlay_layer() -> Node:
+	var found: Array[Node] = get_tree().get_nodes_in_group("pause_menu")
+	if not found.is_empty():
+		var canvas: Node = found[0].get_parent()
+		if canvas != null:
+			return canvas
+	var fallback: Node = get_tree().current_scene
+	return fallback if fallback != null else get_tree().get_root()
+
+
 func _on_tutorial_character_unlocked(data: CharacterData) -> void:
 	if _tutorial_ui == null or not is_instance_valid(_tutorial_ui):
 		return
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:03:13`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `TutorialCharacterIntro` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`20:03:14`

Glob: `**/*.gd`

```
Found 2 files
scenes\level_generation\level_generator.gd
scripts\ui\tutorial_character_intro.gd
```

### 💭 Thinking: *Checking that the `_tutorial_ui` variable…*

`20:03:21`

<details>
<summary>Thinking...</summary>

> Checking that the `_tutorial_ui` variable's type declaration in level_generator.gd is still valid — it's annotated as `TutorialCharacterIntro`, which is fine since we only changed the base class from CanvasLayer to Control, not the class name itself. Now I need to search through the codebase to make sure nothing else is calling `.layer` on `_tutorial_ui` or relying on CanvasLayer-specific behavior.…
</details>

#### 👀 Read `tutorial_content.gd`

`20:03:22`

*(lines 1–56)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
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
## nachgeschaerft: jede Faehigkeit (Dash, LMB, RMB) ist jetzt eine EIGENE
## Zeile/Array-Eintrag statt eines einzigen Fliesstext-Blocks - siehe
## scripts/ui/tutorial_character_intro.gd::add_entry(), das pro Eintrag
## einen eigenen Label pro Zeile baut. Q/E bleiben bewusst unerwaehnt, die
## sind laut CLAUDE.md keine Charakter-Faehigkeiten, sondern die beiden
## aktiven Item-Slots.
##
## DASH ist keine Charakter-, sondern eine allgemeine, charakterunabhaengige
## Mechanik (siehe combat_base.gd) - deshalb ein eigener Eintrag statt Teil
## irgendeiner Charakterbeschreibung, siehe level_generator.gd::
## _setup_tutorial_ui().
const DASH_TITLE: String = "Allgemeine Mechanik: Dash"
const DASH_DESCRIPTION: Array[String] = [
	"DRÜCKE Shift, um einen schnellen Dash auszuführen und so Hindernisse zu überwinden oder Angriffen sicher auszuweichen.",
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
```
</details>

### 🤖 Assistant: *This all looks correct.*

`20:03:25`

> This all looks correct. Let's do a final consistency check across the whole repo for any other place referencing the old single-string `add_entry`/description API.

#### 🔎 Grep `add_entry\(` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`20:03:26`

Glob: `**/*.gd`

```
scenes\level_generation\level_generator.gd:486:	_tutorial_ui.add_entry(TutorialContent.DASH_TITLE, TutorialContent.DASH_DESCRIPTION)
scenes\level_generation\level_generator.gd:487:	_tutorial_ui.add_entry(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)
scenes\level_generation\level_generator.gd:514:	_tutorial_ui.add_entry(data.character_name, TutorialContent.description_for(data))
scripts\tutorial_content.gd:29:## scripts/ui/tutorial_character_intro.gd::add_entry(), das pro Eintrag
scripts\tutorial_content.gd:132:## eigener Block dargestellt, siehe tutorial_character_intro.gd::add_entry().
scripts\ui\tutorial_character_intro.gd:15:# (2026-08-13): jeder add_entry()-Aufruf baut jetzt seine EIGENE
scripts\ui\tutorial_character_intro.gd:123:func add_entry(title: String, description_lines: Array[String]) -> void:
```

### 🤖 Assistant: *All three call sites are consistent with…*

`20:03:34`

> All three call sites are consistent with the new `Array[String]` signature. Summary of what changed:
> 
> **[scripts/tutorial_content.gd](scripts/tutorial_content.gd)** — replaced the single-string descriptions with your exact wording, split into per-line arrays (one entry per ability + a new standalone `DASH_TITLE`/`DASH_DESCRIPTION`).
> 
> **[scripts/ui/tutorial_character_intro.gd](scripts/ui/tutorial_character_intro.gd)** — two fixes:
> - `add_entry()` now builds its own bordered `PanelContainer` card per call (Dash gets one, each character gets one), stacked in the list — no longer all sharing one big panel. Each description line renders as its own `Label`.
> - Root changed from an independent `CanvasLayer` (`layer = 5`) to a plain `Control`. That was the pause-menu bug: an independent CanvasLayer always draws by its numeric `layer`, ignoring PauseMenu's `z_index` entirely — so it sat in front no matter what. As a `Control`, it now needs the same parent as HUD/PauseMenu to inherit correct draw order.
> 
> **[scenes/level_generation/level_generator.gd](scenes/level_generation/level_generator.gd)** — `_setup_tutorial_ui()` now adds the Dash entry first, and uses a new `_find_overlay_layer()` helper (same "pause_menu" group lookup pattern as `reset_overlay.gd`) to parent `TutorialCharacterIntro` into the *same* CanvasLayer as HUD/PauseMenu/DeathScreen/WinScreen instead of directly under `current_scene`. That puts it under PauseMenu's normal `z_index` ordering, so it now hides behind the pause menu exactly like the rest of the HUD.
> 
> Please reload in the editor and check: 5 separate cards (Dash + 4 character as unlocked), and the panel should now sit behind the pause menu when you open it.

## 🤷 User: *die description überlappen sich, bitte so…*

`20:08:43`

die description überlappen sich, bitte so machen das der eine character description wegfaded und die nächste dann auf den platz slided wenn man die neue description bekommt. allgemeine description bleibt fixiert.

füg das hier noch bei allgemeinen beschreibung hinzu

Bomben DRÜCKE X, um eine Bombe zu werfen und ganze Gegnergruppen mit massivem Flächenschaden zu vernichten.

### 💭 Thinking: *The character descriptions are overlapping…*

`20:09:02`

<details>
<summary>Thinking...</summary>

> The character descriptions are overlapping, likely because the VBoxContainer isn't properly accounting for size changes when new entries are added—the docking positions and custom minimum sizes probably aren't being recalculated in time, causing cards to stack on top of each other instead of arranging vertically.
> 
> Actually, I'm realizing the user's real issue: they want to change the behavior entirely—instead of keeping all previous character descriptions visible in a permanent growing list, they want only the current character's description shown, and it should swap out when switching to a different character.…
</details>

#### 🔎 Grep `bomb|Bomb` in `C:\Users\thvnh\Documents\GitHub\whiplash\project.godot`

`20:09:04`

```
No matches found
```

### 💭 Thinking

`20:09:07`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `bomb_carrier.gd`

`20:09:08`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\bomb_carrier.gd</code></summary>

```
extends Node
class_name BombCarrier

# ============================================================================
# BombCarrier — haengt zur Laufzeit am aktiven Spieler (siehe item_manager.gd)
# und regelt Ausruesten, Ablegen und Werfen.
# ============================================================================
#
# BEDIENUNG (Design-Vorgabe):
#   X          -> Bombe ausruesten. Die Zuendschnur laeuft ab DIESEM Moment.
#   X nochmal  -> Bombe vor sich ablegen.
#   LMB        -> Bombe werfen.
#
# WARUM DIE ZUENDSCHNUR SCHON BEIM AUSRUESTEN LAEUFT:
# Das ist die eigentliche Spielmechanik. Wer die Bombe zu lange in der Hand
# haelt, sprengt sich selbst — genau dieser Druck macht die Entscheidung
# "jetzt werfen oder noch eine halbe Sekunde zielen" interessant. Eine
# Bombe, deren Timer erst beim Ablegen startet, ist nur eine Verzoegerung.
#
# LMB IST GLEICHZEITIG attack_primary. CombatBase POLLT diese Action mit
# Input.is_action_pressed() — set_input_as_handled() greift dagegen nicht.
# Deshalb wird das Combat-Node fuer die Dauer des Ausgeruestet-Zustands
# stillgelegt (set_process(false)). Das ist derselbe Ansatz, den Godot
# selbst fuer sich gegenseitig ausschliessende Zustaende empfiehlt, und er
# kommt ohne einen Eingriff in combat_base.gd aus.
#
# ---------------------------------------------------------------------------
# AENDERUNG: DEUTLICH WEITERE WUERFE
# ---------------------------------------------------------------------------
# throw_force liegt jetzt bei 26 statt 14, throw_arc bei 9 statt 5. Der
# entscheidende Teil steckt aber NICHT in diesen Zahlen, sondern in
# Bomb.launch(): die Bombe lief bisher schon in der Luft mit
# linear_damp = 3.0 und verlor ihren Schwung, bevor sie ueberhaupt
# irgendwo ankam. Ein hoeherer Impuls allein haette daran wenig geaendert —
# er waere einfach schneller weggedaempft worden. launch() senkt die
# Daempfung fuer die Flugphase und stellt sie bei Bodenkontakt wieder her.
#
# BLICKRICHTUNG: das Projekt nutzt +Z als Vorne. _get_forward() gibt
# deshalb bewusst -basis.z des CameraPivot zurueck (Godots eigene
# Vorwaertsachse), weil hier die KAMERA-Blickrichtung gemeint ist und nicht
# die Charakter-Ausrichtung. Wer das auf die Figur umstellt, muss auf +Z
# wechseln — sonst wirft der Spieler nach hinten.

signal bomb_equipped(fuse_remaining: float)
signal bomb_released
signal fuse_ticked(remaining: float)

## Muss mit item_manager.gd -> BOMB_ACTION uebereinstimmen. Die Action wird
## dort beim Start automatisch angelegt, falls sie im InputMap fehlt.
const BOMB_ACTION: String = "bomb"

## Wie weit vor dem Spieler eine abgelegte Bombe landet.
@export var place_distance: float = 1.2
## Wurfkraft nach vorne.
@export var throw_force: float = 26.0
## Zusaetzlicher Bogen nach oben, damit der Wurf nicht am Boden entlangschrammt.
@export var throw_arc: float = 9.0
## Zuendschnur — bewusst hier und nicht in bomb.gd, damit Items sie spaeter
## verlaengern koennen, ohne die Bombe selbst zu kennen.
@export var fuse_time: float = 2.0

## Vorschau-Bogen, waehrend die Bombe in der Hand liegt. Bei der neuen
## Wurfweite kann man das Ziel sonst nicht mehr abschaetzen: die Bombe
## fliegt weiter, als der Bildausschnitt bei enger Kamera hergibt.
@export var show_aim_preview: bool = true
@export var aim_preview_points: int = 14
@export var aim_preview_step: float = 0.075

var _player: CharacterBody3D = null
var _combat: CombatBase = null
var _pivot: Node3D = null

var _equipped: bool = false
var _fuse_remaining: float = 0.0
var _held_visual: Node3D = null
var _aim_preview: Node3D = null
var _aim_dots: Array[MeshInstance3D] = []


func _ready() -> void:
	_player = get_parent() as CharacterBody3D
	if _player == null:
		push_warning("BombCarrier: Elternknoten ist kein CharacterBody3D.")
		return
	_combat = _player.get_node_or_null("Combat") as CombatBase
	_pivot = _player.get_node_or_null("CameraPivot") as Node3D


func _exit_tree() -> void:
	# Beim Charakterwechsel darf das Combat-Node nicht stillgelegt
	# zurueckbleiben — sonst kann der neue Charakter nicht mehr angreifen.
	_set_combat_enabled(true)


func _process(delta: float) -> void:
	if not _equipped:
		return

	_fuse_remaining -= delta
	fuse_ticked.emit(_fuse_remaining)
	_update_aim_preview()

	if _fuse_remaining <= 0.0:
		# In der Hand hochgegangen. Die Bombe wird trotzdem gespawnt, damit
		# die Explosion ueber denselben Code laeuft wie sonst auch — sie
		# zuendet nur sofort.
		var bomb: Bomb = _release_bomb(Vector3.ZERO)
		if bomb:
			bomb.trigger_now.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	if event.is_action_pressed(BOMB_ACTION):
		if _equipped:
			_place()
		else:
			_equip()
		get_viewport().set_input_as_handled()
		return

	if _equipped and event.is_action_pressed("attack_primary"):
		_throw()
		get_viewport().set_input_as_handled()


# ============================================================================
# Zustaende
# ============================================================================
func _equip() -> void:
	var items: Node = get_node_or_null("/root/Items")
	if item == null or not items.consume_bomb():
		return

	_equipped = true
	_fuse_remaining = fuse_time
	_set_combat_enabled(false)
	_build_held_visual()
	_build_aim_preview()
	bomb_equipped.emit(_fuse_remaining)


func _place() -> void:
	_release_bomb(Vector3.ZERO)


func _throw() -> void:
	var forward: Vector3 = _get_forward()
	_release_bomb(forward * throw_force + Vector3.UP * throw_arc)


## Erzeugt die echte Bombe in der Welt und beendet den Ausgeruestet-Zustand.
func _release_bomb(impulse: Vector3) -> Bomb:
	if not _equipped:
		return null

	_equipped = false
	_set_combat_enabled(true)
	_clear_held_visual()
	_clear_aim_preview()
	bomb_released.emit()

	var parent: Node = get_tree().current_scene
	if parent == null:
		return null

	var bomb := Bomb.new()
	bomb.fuse_time = fuse_time
	bomb.thrower = _player
	parent.add_child(bomb)

	# Die Restlaufzeit aus der Hand wird uebernommen — sonst waere Halten
	# risikofrei.
	bomb.set("_fuse_remaining", maxf(_fuse_remaining, 0.05))

	var forward: Vector3 = _get_forward()
	# Etwas hoeher als frueher (0.9 statt 0.4): der Wurf startet damit auf
	# Brusthoehe statt an den Fuessen. Bei der groesseren Wurfweite ist das
	# der Unterschied zwischen einer Parabel und einem Aufprall auf der
	# naechsten Stufe.
	bomb.global_position = _player.global_position + forward * place_distance + Vector3(0.0, 0.9, 0.0)

	# launch() statt apply_central_impulse(): nur so faellt die Daempfung
	# fuer die Flugphase weg. Siehe Kopf der Datei.
	if impulse.length() > 0.01:
		bomb.launch(impulse)

	return bomb


func _get_forward() -> Vector3:
	if _pivot == null:
		return -_player.global_transform.basis.z
	var forward: Vector3 = -_pivot.global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.01:
		return Vector3.FORWARD
	return forward.normalized()


func _set_combat_enabled(enabled: bool) -> void:
	if _combat == null or not is_instance_valid(_combat):
		return
	_combat.set_process(enabled)


# ============================================================================
# Bombe in der Hand
# ============================================================================
# Reine Sichtbarkeitshilfe: eine kleine Kugel ueber dem Kopf. Sobald es ein
# Modell mit Hand-Bone gibt, hier durch einen BoneAttachment3D ersetzen.
func _build_held_visual() -> void:
	_clear_held_visual()

	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.44
	sphere.radial_segments = 8
	sphere.rings = 5

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.16, 0.16, 0.20)
	material.emission_enabled = true
	material.emission = Color(0.95, 0.3, 0.15)
	material.emission_energy_multiplier = 1.5

	var instance := MeshInstance3D.new()
	instance.mesh = sphere
	instance.material_override = material

	_held_visual = Node3D.new()
	_held_visual.name = "HeldBomb"
	_held_visual.add_child(instance)
	_player.add_child(_held_visual)
	_held_visual.position = Vector3(0.0, 1.2, 0.0)


func _clear_held_visual() -> void:
	if _held_visual and is_instance_valid(_held_visual):
		_held_visual.queue_free()
	_held_visual = null


# ============================================================================
# Ziel-Vorschau
# ============================================================================
# Punktreihe entlang der Wurfparabel. Sie wird NICHT physikalisch simuliert,
# sondern analytisch berechnet (p = p0 + v*t + 0.5*g*t^2). Eine echte
# Simulation muesste die Bombe probeweise durch die Welt schicken, und das
# jeden Frame — fuer eine reine Zielhilfe waere das voellig unverhaeltnis-
# maessig. Die Punkte ignorieren deshalb Hindernisse; sie zeigen die
# Flugbahn, nicht den Einschlag.
func _build_aim_preview() -> void:
	_clear_aim_preview()
	if not show_aim_preview:
		return

	_aim_preview = Node3D.new()
	_aim_preview.name = "BombAimPreview"
	# Direkt an die Szene, nicht an den Spieler: sonst wandern die Punkte
	# mit, sobald sich der Spieler beim Zielen dreht.
	var parent: Node = get_tree().current_scene
	if parent == null:
		return
	parent.add_child(_aim_preview)

	var sphere := SphereMesh.new()
	sphere.radius = 0.09
	sphere.height = 0.18
	sphere.radial_segments = 6
	sphere.rings = 3

	for i: int in range(aim_preview_points):
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		# Nach hinten ausblenden: die Bahn soll gerichtet wirken.
		var fade: float = 1.0 - float(i) / float(maxi(aim_preview_points, 1))
		material.albedo_color = Color(1.0, 0.55, 0.25, 0.25 + fade * 0.55)
		material.cull_mode = BaseMaterial3D.CULL_DISABLED

		var dot := MeshInstance3D.new()
		dot.mesh = sphere
		dot.material_override = material
		dot.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		dot.scale = Vector3.ONE * (0.5 + fade * 0.8)
		_aim_preview.add_child(dot)
		_aim_dots.append(dot)


func _update_aim_preview() -> void:
	if _aim_preview == null or not is_instance_valid(_aim_preview):
		return
	if _player == null or not is_instance_valid(_player):
		return

	var forward: Vector3 = _get_forward()
	var start: Vector3 = _player.global_position + forward * place_distance + Vector3(0.0, 0.9, 0.0)

	# Impuls / Masse = Startgeschwindigkeit. Die Masse steht in bomb.gd auf
	# 2.5 — wer sie dort aendert, muss sie hier mitziehen, sonst zeigt die
	# Vorschau eine andere Bahn als der tatsaechliche Wurf.
	var velocity: Vector3 = (forward * throw_force + Vector3.UP * throw_arc) / 2.5
	var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))

	for i: int in range(_aim_dots.size()):
		var t: float = float(i + 1) * aim_preview_step
		var point: Vector3 = start + velocity * t + Vector3.DOWN * (0.5 * gravity * t * t)
		_aim_dots[i].global_position = point


func _clear_aim_preview() -> void:
	_aim_dots.clear()
	if _aim_preview and is_instance_valid(_aim_preview):
		_aim_preview.queue_free()
	_aim_preview = null


func is_equipped() -> bool:
	return _equipped


func get_fuse_remaining() -> float:
	return _fuse_remaining

```
</details>

### 💭 Thinking: *I see the BOMB_ACTION is set to "X" and the…*

`20:10:05`

<details>
<summary>Thinking...</summary>

> I see the BOMB_ACTION is set to "X" and the user's German text about pressing X to throw a bomb aligns with the game's actual mechanic, though technically it's a two-step process where X equips the bomb and then LMB throws it—the user's phrasing simplifies this to just the X press.
> 
> Now I'm restructuring the tutorial: I'll add the bomb description to the general mechanics section alongside the dash info, keeping that section fixed while the active character descriptions fade out and slide in. I'm renaming the dash-specific title and description constants to reflect that they now cover both dash and bomb mechanics, so the general section becomes more comprehensive without affecting the character-specific content. So the transition works by fading out the old character card's opacity to zero over about 300 milliseconds, then removing it, while simultaneously (or right after) creating the new card positioned slightly offset—say to the right—and then sliding it into the slot's position. I'll keep a fixed-size container as the character slot and animate both the fade-out of the departing card and the slide-in of the arriving one to create that cross-fade effect the user described.
> 
> The tricky part is that if this slot lives inside a VBoxContainer, Godot's automatic layout system will constantly reposition children every frame, which breaks manual position tweens. So I need to use a plain Control node instead of relying on the container's auto-layout for the character slot itself, letting me tween the position and opacity properties directly without interference. The slot itself gets positioned by the VBoxContainer, but its children stay free to move manually since they're nested one level deeper and bypass the container's layout rules. I'll set up the character_slot as a plain Control with a fixed custom_minimum_size to reserve vertical space, then place both the old and new card instances inside it with direct position control, dynamically adjusting the slot's height based on whichever card is currently visible to avoid wasted space. Setting up the card sizing logic... Writing animation code...
> 
> Now I'm realizing that since `character_slot` is a Control nested inside the VBoxContainer, the container itself will handle positioning, so I need to account for how that affects the card's final layout. I'm realizing the animation should be sequential: the old card fades out completely first, then the new one slides up into that position from below. This feels more natural for a stacked vertical list where entries are replaced one after another. ading in each entry individually, so I need to handle the first card (Ningning) specially — it should just fade in without waiting for an old card to fade out first. For subsequent switches, the old card fades completely, then the new one slides in from below with position tweening and an ease-out curve for natural deceleration. This keeps the behavior consistent while avoiding an awkward delay on initial load.
> 
> Since we're now showing only the current unlocked character instead of accumulating a growing list, I need to rethink the function structure. Previously `add_entry` handled both the static general card and the expanding character roster, but now the character slot rotates through one card at a time, which eliminates the overlap and clutter issues that came from the list growing indefinitely.
> 
> I'll split this into two separate methods: one to set the fixed general entry that displays once (covering shared mechanics like bombs and dashes), and another to show the current character with its own animated slot that updates whenever a new character unlocks. Then I'll refactor the tutorial script and update the level generator to call the general entry once at startup, followed by the character display method for Ningning initially and whenever `_on_tutorial_character_unlocked` fires.…
</details>

#### 🔎 Grep `BOMB_ACTION|KEY_X` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_manager.gd`

`20:10:06`

```
75:const BOMB_ACTION: String = "bomb"
158:	if not InputMap.has_action(BOMB_ACTION):
159:		InputMap.add_action(BOMB_ACTION)
161:		bomb_event.physical_keycode = KEY_X
162:		InputMap.action_add_event(BOMB_ACTION, bomb_event)
```

### 🤖 Assistant: *Confirmed — bomb is bound to `KEY_X`, matching…*

`20:10:10`

> Confirmed — bomb is bound to `KEY_X`, matching the user's text exactly. Now let's implement the fade/slide redesign.

#### 👀 Read `tutorial_content.gd`

`20:10:11`

*(lines 24–56)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
## Rueckmeldung "Tutorial-Texte sollen Tasten-Inputs erwaehnen und die
## Dash-Mechanik erklaeren" (2026-08-13), dann per Rueckmeldung "eigener
## Container pro Charakter/Faehigkeit, nicht alles in einem Textblock"
## nachgeschaerft: jede Faehigkeit (Dash, LMB, RMB) ist jetzt eine EIGENE
## Zeile/Array-Eintrag statt eines einzigen Fliesstext-Blocks - siehe
## scripts/ui/tutorial_character_intro.gd::add_entry(), das pro Eintrag
## einen eigenen Label pro Zeile baut. Q/E bleiben bewusst unerwaehnt, die
## sind laut CLAUDE.md keine Charakter-Faehigkeiten, sondern die beiden
## aktiven Item-Slots.
##
## DASH ist keine Charakter-, sondern eine allgemeine, charakterunabhaengige
## Mechanik (siehe combat_base.gd) - deshalb ein eigener Eintrag statt Teil
## irgendeiner Charakterbeschreibung, siehe level_generator.gd::
## _setup_tutorial_ui().
const DASH_TITLE: String = "Allgemeine Mechanik: Dash"
const DASH_DESCRIPTION: Array[String] = [
	"DRÜCKE Shift, um einen schnellen Dash auszuführen und so Hindernisse zu überwinden oder Angriffen sicher auszuweichen.",
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
```
</details>

#### ✏️  Edit `tutorial_content.gd`

`20:10:19`

```diff
@@ -1,8 +1,10 @@-## DASH ist keine Charakter-, sondern eine allgemeine, charakterunabhaengige
-## Mechanik (siehe combat_base.gd) - deshalb ein eigener Eintrag statt Teil
+## DASH und BOMBEN sind keine Charakter-, sondern allgemeine,
+## charakterunabhaengige Mechaniken (siehe combat_base.gd bzw.
+## bomb_carrier.gd) - deshalb ein eigener, FIXIERTER Eintrag statt Teil
 ## irgendeiner Charakterbeschreibung, siehe level_generator.gd::
-## _setup_tutorial_ui().
-const DASH_TITLE: String = "Allgemeine Mechanik: Dash"
-const DASH_DESCRIPTION: Array[String] = [
-	"DRÜCKE Shift, um einen schnellen Dash auszuführen und so Hindernisse zu überwinden oder Angriffen sicher auszuweichen.",
+## _setup_tutorial_ui() und tutorial_character_intro.gd::set_general_entry().
+const GENERAL_TITLE: String = "Allgemeine Mechaniken"
+const GENERAL_DESCRIPTION: Array[String] = [
+	"Dash: DRÜCKE Shift, um einen schnellen Dash auszuführen und so Hindernisse zu überwinden oder Angriffen sicher auszuweichen.",
+	"Bomben: DRÜCKE X, um eine Bombe zu werfen und ganze Gegnergruppen mit massivem Flächenschaden zu vernichten.",
 ]
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking: *I'm adding prefixes like "Dash:" and "Bomben…*

`20:10:29`

<details>
<summary>Thinking...</summary>

> I'm adding prefixes like "Dash:" and "Bomben:" to distinguish between the different mechanics within the single card, since it now needs to visually separate the dash and bomb mechanics that were previously in separate sections.…
</details>

#### ✏️  Edit `tutorial_content.gd`

`20:10:32`

```diff
@@ -1,5 +1,5 @@ const GENERAL_TITLE: String = "Allgemeine Mechaniken"
 const GENERAL_DESCRIPTION: Array[String] = [
-	"Dash: DRÜCKE Shift, um einen schnellen Dash auszuführen und so Hindernisse zu überwinden oder Angriffen sicher auszuweichen.",
-	"Bomben: DRÜCKE X, um eine Bombe zu werfen und ganze Gegnergruppen mit massivem Flächenschaden zu vernichten.",
+	"Dash DRÜCKE Shift, um einen schnellen Dash auszuführen und so Hindernisse zu überwinden oder Angriffen sicher auszuweichen.",
+	"Bomben DRÜCKE X, um eine Bombe zu werfen und ganze Gegnergruppen mit massivem Flächenschaden zu vernichten.",
 ]
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:10:35`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `tutorial_content.gd`

`20:10:36`

*(lines 24–39)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
## Rueckmeldung "Tutorial-Texte sollen Tasten-Inputs erwaehnen und die
## Dash-Mechanik erklaeren" (2026-08-13), dann per Rueckmeldung "eigener
## Container pro Charakter/Faehigkeit, nicht alles in einem Textblock"
## nachgeschaerft: jede Faehigkeit (Dash, LMB, RMB) ist jetzt eine EIGENE
## Zeile/Array-Eintrag statt eines einzigen Fliesstext-Blocks - siehe
## scripts/ui/tutorial_character_intro.gd::add_entry(), das pro Eintrag
## einen eigenen Label pro Zeile baut. Q/E bleiben bewusst unerwaehnt, die
## sind laut CLAUDE.md keine Charakter-Faehigkeiten, sondern die beiden
## aktiven Item-Slots.
##
## DASH und BOMBEN sind keine Charakter-, sondern allgemeine,
## charakterunabhaengige Mechaniken (siehe combat_base.gd bzw.
## bomb_carrier.gd) - deshalb ein eigener, FIXIERTER Eintrag statt Teil
## irgendeiner Charakterbeschreibung, siehe level_generator.gd::
## _setup_tutorial_ui() und tutorial_character_intro.gd::set_general_entry().
```
</details>

### 💭 Thinking

`20:10:40`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `tutorial_content.gd`

`20:10:43`

```diff
@@ -1,6 +1,5 @@-## nachgeschaerft: jede Faehigkeit (Dash, LMB, RMB) ist jetzt eine EIGENE
-## Zeile/Array-Eintrag statt eines einzigen Fliesstext-Blocks - siehe
-## scripts/ui/tutorial_character_intro.gd::add_entry(), das pro Eintrag
-## einen eigenen Label pro Zeile baut. Q/E bleiben bewusst unerwaehnt, die
-## sind laut CLAUDE.md keine Charakter-Faehigkeiten, sondern die beiden
-## aktiven Item-Slots.
+## nachgeschaerft: jede Faehigkeit (Dash, Bomben, LMB, RMB) ist jetzt eine
+## EIGENE Zeile/Array-Eintrag statt eines einzigen Fliesstext-Blocks - siehe
+## scripts/ui/tutorial_character_intro.gd, das pro Zeile einen eigenen Label
+## baut. Q/E bleiben bewusst unerwaehnt, die sind laut CLAUDE.md keine
+## Charakter-Faehigkeiten, sondern die beiden aktiven Item-Slots.
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:10:46`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `add_entry\(\)` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd`

`20:10:46`

```
133:## eigener Block dargestellt, siehe tutorial_character_intro.gd::add_entry().
```

#### 👀 Read `tutorial_content.gd`

`20:10:49`

*(lines 128–138)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```


## UI-Beschreibungszeilen fuer einen soeben freigeschalteten Charakter -
## anhand character_id statt Objekt-Identitaet, robust gegen dupliziert
## geladene Ressourcen. Array statt einem String: jede Zeile wird als
## eigener Block dargestellt, siehe tutorial_character_intro.gd::add_entry().
static func description_for(data: CharacterData) -> Array[String]:
	if data == null:
		return []
	match String(data.character_id):
```
</details>

#### ✏️  Edit `tutorial_content.gd`

`20:10:53`

```diff
@@ -1 +1 @@-## eigener Block dargestellt, siehe tutorial_character_intro.gd::add_entry().
+## eigener Label dargestellt, siehe tutorial_character_intro.gd::show_character().
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's rewrite `tutorial_character_intro…*

`20:10:56`

> Now let's rewrite `tutorial_character_intro.gd` with the fixed-general-card + fading/sliding single character-slot design.

#### ✍️  Write `tutorial_character_intro.gd`

`20:11:34`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\ui\tutorial_character_intro.gd</code></summary>

```
extends Control
class_name TutorialCharacterIntro

# ============================================================================
# TutorialCharacterIntro — Tutorial-UI: EIN fixierter "Allgemeine Mechaniken"-
# Eintrag + EIN Charakter-Slot, der beim Unlock zum naechsten Charakter
# ueberblendet (level_generator.gd::generate_tutorial_stage()).
# ============================================================================
# Rueckmeldung (2026-08-13) "Descriptions ueberlappen sich, alte Charakter-
# Description soll wegfaden und die neue an ihre Stelle sliden, allgemeine
# Description bleibt fixiert": VORHER haengte jeder freigeschaltete
# Charakter einen weiteren, dauerhaft sichtbaren Eintrag an eine wachsende
# Liste - die Liste wurde mit jedem Unlock hoeher und überlappte irgendwann
# andere HUD-Elemente. JETZT gibt es nur zwei Karten insgesamt:
#   - _general_card: einmalig per set_general_entry() gebaut (Dash/Bomben),
#     bleibt danach unveraendert stehen.
#   - _character_slot: ein fester Platz, dessen Inhalt show_character() bei
#     jedem Charakterwechsel AUSTAUSCHT statt einen weiteren Eintrag
#     anzuhaengen - die alte Karte faded weg, danach slided die neue an
#     genau dieselbe Stelle.
#
# WARUM DER SLOT KEIN CONTAINER-KIND IST:
# _character_slot haengt zwar selbst in der aeusseren _list (VBoxContainer),
# aber SEINE Kind-Karten (alt/neu) sind NICHT direkte Kinder eines
# Containers - ein Container wuerde die Kind-Position bei jedem Sortier-
# Durchlauf auf die Layout-Position zwingen und damit jede manuelle
# position/modulate-Tween-Animation sofort wieder ueberschreiben. Innerhalb
# von _character_slot (ein einfacher Control) bleibt die von uns per Tween
# gesetzte position/modulate dagegen unangetastet.
#
# --- Andocken an die Minimap ------------------------------------------------
# Statt einer festen Bildschirmposition haengt sich die Liste UNTER die
# Minimap - exakt dasselbe Problem/dieselbe Loesung wie run_timer.gd (dockt
# rechts daneben): Minimap.get_docking_rect() liefert das tatsaechlich
# belegte, mit SettingsManager.minimap_ui_scale skalierungskorrigierte
# Rechteck.
#
# --- Pause-Menu-Layering -----------------------------------------------------
# Ein normaler Control statt eines eigenen CanvasLayers - level_generator.gd
# haengt diese Node INS SELBE CanvasLayer wie HUD/PauseMenu (siehe dortiges
# _find_overlay_layer()), damit PauseMenu.z_index wie ueberall sonst gilt
# und diese Karten beim Pausieren korrekt dahinter verschwinden.

const PANEL_COLOR: Color = Color(0.05, 0.05, 0.08, 0.86)
const NAME_COLOR: Color = Color(0.95, 0.85, 0.35)
const DESC_COLOR: Color = Color(0.88, 0.88, 0.92)
const MAX_WIDTH: float = 420.0

const MINIMAP_GROUP: String = "minimap"

## Abstand zwischen Minimap-Rahmen und der Liste in Pixeln.
@export var dock_gap: float = 16.0
## Abstand zwischen der fixierten "Allgemein"-Karte und dem Charakter-Slot.
@export var entry_gap: float = 10.0

## Wie lange die alte Charakter-Karte braucht, um komplett wegzufaden.
@export var fade_out_time: float = 0.35
## Wie lange die neue Charakter-Karte braucht, um in ihre Position zu sliden.
@export var slide_in_time: float = 0.4
## Waagerechter Versatz, aus dem die neue Karte hereinslided (negativ = von
## links, positiv = von rechts).
@export var slide_in_offset: Vector2 = Vector2(0.0, 26.0)

## Position, falls keine Minimap existiert (z.B. Testszene ohne HUD).
const FALLBACK_POSITION: Vector2 = Vector2(24.0, 24.0)

var _list: VBoxContainer = null
var _general_card: PanelContainer = null
var _character_slot: Control = null
var _current_character_card: PanelContainer = null
var _minimap: Control = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_list = VBoxContainer.new()
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_list.add_theme_constant_override("separation", entry_gap)
	add_child(_list)
	_list.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_list.position = FALLBACK_POSITION

	# Fester Platz fuer die Charakter-Karte, ausserhalb jeder Container-
	# Sortierlogik (siehe Kopfkommentar) - Groesse wird bei jedem
	# show_character() auf die tatsaechliche Karten-Groesse nachgezogen.
	_character_slot = Control.new()
	_character_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_slot.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	_list.add_child(_character_slot)

	if SettingsManager != null and SettingsManager.has_signal("minimap_setting_changed"):
		if not SettingsManager.minimap_setting_changed.is_connected(_update_dock):
			SettingsManager.minimap_setting_changed.connect(_update_dock)
	get_viewport().size_changed.connect(_update_dock)

	# Ein Frame warten: die Minimap baut ihr Raum-Overlay/ihren Rahmen noch
	# in ihrer eigenen _ready() fertig - wer vorher misst, dockt an die noch
	# unfertige Groesse an (identisches Muster wie run_timer.gd).
	_update_dock.call_deferred()


## Setzt die Y-Position direkt unter die Minimap. Idempotent.
func _update_dock() -> void:
	if _minimap == null or not is_instance_valid(_minimap):
		var found: Array[Node] = get_tree().get_nodes_in_group(MINIMAP_GROUP)
		if found.is_empty():
			_list.position = FALLBACK_POSITION
			return
		_minimap = found[0] as Control

	if _minimap == null or not _minimap.has_method("get_docking_rect"):
		_list.position = FALLBACK_POSITION
		return

	if not _minimap.visible:
		_list.position = FALLBACK_POSITION
		return

	var rect: Rect2 = _minimap.get_docking_rect()
	_list.position = Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)


func _process(_delta: float) -> void:
	# Guenstiger Abgleich, deckt die getweente Groessenaenderung beim
	# Oeffnen/Schliessen der Grosskarte ab, die kein eigenes Signal hat -
	# identisches Muster wie run_timer.gd::_process().
	if _minimap == null or not is_instance_valid(_minimap) or _list == null:
		return
	if not _minimap.visible:
		return
	var rect: Rect2 = _minimap.get_docking_rect()
	var wanted := Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)
	if not _list.position.is_equal_approx(wanted):
		_list.position = wanted


## Baut die fixierte "Allgemeine Mechaniken"-Karte (Dash/Bomben) - EINMALIG,
## wird danach nie wieder veraendert oder ausgetauscht.
func set_general_entry(title: String, description_lines: Array[String]) -> void:
	if _general_card != null and is_instance_valid(_general_card):
		_general_card.queue_free()
	_general_card = _build_card(title, description_lines)
	_list.add_child(_general_card)
	# VOR den Charakter-Slot einsortieren, damit "Allgemein" immer oben
	# steht, egal in welcher Reihenfolge die beiden Methoden aufgerufen
	# werden.
	_list.move_child(_general_card, 0)


## Tauscht die Charakter-Karte im festen Slot aus: die alte faded komplett
## weg, danach slided die neue aus slide_in_offset an ihre Position -
## siehe Kopfkommentar, wieso das ueber manuelle Tweens statt Container-
## Layout laeuft.
func show_character(title: String, description_lines: Array[String]) -> void:
	if _character_slot == null:
		return

	var old_card: PanelContainer = _current_character_card
	_current_character_card = null

	if old_card != null and is_instance_valid(old_card):
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(old_card, "modulate:a", 0.0, fade_out_time)
		fade_tween.tween_callback(func() -> void:
			if is_instance_valid(old_card):
				old_card.queue_free()
			_slide_in_character_card(title, description_lines)
		)
		return

	_slide_in_character_card(title, description_lines)


func _slide_in_character_card(title: String, description_lines: Array[String]) -> void:
	if _character_slot == null or not is_instance_valid(_character_slot):
		return

	var card: PanelContainer = _build_card(title, description_lines)
	_character_slot.add_child(card)
	card.position = slide_in_offset
	_current_character_card = card

	# Ein Frame warten, bis die Labels ihre Autowrap-Hoehe kennen - erst
	# dann hat "card" seine tatsaechliche Groesse, an die der Slot (fuer die
	# Hoehe innerhalb der aeusseren _list) angeglichen wird.
	await get_tree().process_frame
	if not is_instance_valid(card) or not is_instance_valid(_character_slot):
		return
	_character_slot.custom_minimum_size = card.size

	var slide_tween: Tween = create_tween()
	slide_tween.tween_property(card, "position", Vector2.ZERO, slide_in_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _build_card(title: String, description_lines: Array[String]) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", style)

	var entry := VBoxContainer.new()
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.add_theme_constant_override("separation", 4)
	card.add_child(entry)

	var name_label := Label.new()
	name_label.text = title
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", NAME_COLOR)
	entry.add_child(name_label)

	for line: String in description_lines:
		var desc_label := Label.new()
		desc_label.text = line
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", DESC_COLOR)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.custom_minimum_size = Vector2(MAX_WIDTH - 32.0, 0.0)
		entry.add_child(desc_label)

	return card

```
</details>

✓ The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\ui\tutorial_character_intro.gd has been updated successfully. (file state is current in your context — no need to Read it back)

### 🤖 Assistant: *Now update `level_generator.gd` to use the…*

`20:11:37`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now update `level_generator.gd` to use the new API:

#### 👀 Read `level_generator.gd`

`20:11:38`

*(lines 479–511)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
## Permanentes UI-Panel mit den Charakter-Beschreibungen (siehe
## scripts/ui/tutorial_character_intro.gd) - Dash-Hinweis + Ningning sofort,
## jeder weitere Charakter, sobald sein CharacterPedestal genommen wird
## (Treasure.character_taken, siehe treasure_manager.gd/character_pedestal.gd).
func _setup_tutorial_ui() -> void:
	_tutorial_ui = TutorialCharacterIntro.new()
	_find_overlay_layer().add_child(_tutorial_ui)
	_tutorial_ui.add_entry(TutorialContent.DASH_TITLE, TutorialContent.DASH_DESCRIPTION)
	_tutorial_ui.add_entry(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)

	var treasure: Node = get_node_or_null("/root/Treasure")
	if treasure != null and treasure.has_signal("character_taken"):
		treasure.connect("character_taken", _on_tutorial_character_unlocked)


## Findet das CanvasLayer, in dem HUD/PauseMenu/DeathScreen/WinScreen liegen
## (siehe pause_menu.gd-Kopfkommentar) - ueber die "pause_menu"-Gruppe,
## gleiches Muster wie reset_overlay.gd. TutorialCharacterIntro MUSS dort
## haengen statt in current_scene direkt: als eigenes, spaeter hinzugefuegtes
## CanvasLayer wuerde es sich sonst unabhaengig von PauseMenu.z_index IMMER
## ueber das Pause-Menu zeichnen (Rueckmeldung "Beschreibung liegt beim
## Pause-Menu im Vordergrund, anders als der Rest vom HUD").
func _find_overlay_layer() -> Node:
	var found: Array[Node] = get_tree().get_nodes_in_group("pause_menu")
	if not found.is_empty():
		var canvas: Node = found[0].get_parent()
		if canvas != null:
			return canvas
	var fallback: Node = get_tree().current_scene
	return fallback if fallback != null else get_tree().get_root()


```
</details>

#### ✏️  Edit `level_generator.gd`

`20:11:45`

```diff
@@ -1,9 +1,11 @@-## Permanentes UI-Panel mit den Charakter-Beschreibungen (siehe
-## scripts/ui/tutorial_character_intro.gd) - Dash-Hinweis + Ningning sofort,
-## jeder weitere Charakter, sobald sein CharacterPedestal genommen wird
-## (Treasure.character_taken, siehe treasure_manager.gd/character_pedestal.gd).
+## UI-Panel mit den Charakter-Beschreibungen (siehe
+## scripts/ui/tutorial_character_intro.gd) - "Allgemeine Mechaniken"
+## (Dash/Bomben) fixiert + Ningning sofort im Charakter-Slot, jeder weitere
+## Charakter tauscht diesen Slot aus (ueberblendet), sobald sein
+## CharacterPedestal genommen wird (Treasure.character_taken, siehe
+## treasure_manager.gd/character_pedestal.gd).
 func _setup_tutorial_ui() -> void:
 	_tutorial_ui = TutorialCharacterIntro.new()
 	_find_overlay_layer().add_child(_tutorial_ui)
-	_tutorial_ui.add_entry(TutorialContent.DASH_TITLE, TutorialContent.DASH_DESCRIPTION)
-	_tutorial_ui.add_entry(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)
+	_tutorial_ui.set_general_entry(TutorialContent.GENERAL_TITLE, TutorialContent.GENERAL_DESCRIPTION)
+	_tutorial_ui.show_character(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the unlock-callback further down:*

`20:11:48`

> Now the unlock-callback further down:

#### 👀 Read `level_generator.gd`

`20:11:48`

*(lines 509–517)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
	var fallback: Node = get_tree().current_scene
	return fallback if fallback != null else get_tree().get_root()


func _on_tutorial_character_unlocked(data: CharacterData) -> void:
	if _tutorial_ui == null or not is_instance_valid(_tutorial_ui):
		return
	_tutorial_ui.add_entry(data.character_name, TutorialContent.description_for(data))
```
</details>

#### ✏️  Edit `level_generator.gd`

`20:11:53`

```diff
@@ -1,4 +1,4 @@ func _on_tutorial_character_unlocked(data: CharacterData) -> void:
 	if _tutorial_ui == null or not is_instance_valid(_tutorial_ui):
 		return
-	_tutorial_ui.add_entry(data.character_name, TutorialContent.description_for(data))
+	_tutorial_ui.show_character(data.character_name, TutorialContent.description_for(data))
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Let's verify there are no leftover stale…*

`20:11:55`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let's verify there are no leftover stale references anywhere:

#### 🔎 Grep `DASH_TITLE|DASH_DESCRIPTION|\.add_entry\(` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`20:11:56`

Glob: `**/*.gd`

```
No matches found
```

### 💭 Thinking

`20:12:00`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `GENERAL_TITLE|GENERAL_DESCRIPTION|show_character|set_general_entry` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`20:12:00`

Glob: `**/*.gd`

```
scenes\level_generation\level_generator.gd:488:	_tutorial_ui.set_general_entry(TutorialContent.GENERAL_TITLE, TutorialContent.GENERAL_DESCRIPTION)
scenes\level_generation\level_generator.gd:489:	_tutorial_ui.show_character(TutorialContent.NINGNING_DATA.character_name, TutorialContent.NINGNING_DESCRIPTION)
scenes\level_generation\level_generator.gd:516:	_tutorial_ui.show_character(data.character_name, TutorialContent.description_for(data))
scripts\tutorial_content.gd:37:## _setup_tutorial_ui() und tutorial_character_intro.gd::set_general_entry().
scripts\tutorial_content.gd:38:const GENERAL_TITLE: String = "Allgemeine Mechaniken"
scripts\tutorial_content.gd:39:const GENERAL_DESCRIPTION: Array[String] = [
scripts\tutorial_content.gd:133:## eigener Label dargestellt, siehe tutorial_character_intro.gd::show_character().
scripts\ui\tutorial_character_intro.gd:15:#   - _general_card: einmalig per set_general_entry() gebaut (Dash/Bomben),
scripts\ui\tutorial_character_intro.gd:17:#   - _character_slot: ein fester Platz, dessen Inhalt show_character() bei
scripts\ui\tutorial_character_intro.gd:86:	# show_character() auf die tatsaechliche Karten-Groesse nachgezogen.
scripts\ui\tutorial_character_intro.gd:140:func set_general_entry(title: String, description_lines: Array[String]) -> void:
scripts\ui\tutorial_character_intro.gd:155:func show_character(title: String, description_lines: Array[String]) -> void:
```

### 🤖 Assistant: *All consistent and wired correctly.*

`20:12:10`

> All consistent and wired correctly. Summary of this round's changes:
> 
> **[scripts/tutorial_content.gd](scripts/tutorial_content.gd)** — `DASH_TITLE`/`DASH_DESCRIPTION` renamed to `GENERAL_TITLE`/`GENERAL_DESCRIPTION` ("Allgemeine Mechaniken"), now holding two lines: the existing Dash text plus the new Bomben line (`Bomben DRÜCKE X, ...` — verified `X` is correct, it's `BombCarrier.BOMB_ACTION`'s actual default key).
> 
> **[scripts/ui/tutorial_character_intro.gd](scripts/ui/tutorial_character_intro.gd)** — replaced the growing permanent list with two slots:
> - `set_general_entry()` — builds the "Allgemeine Mechaniken" card once; never touched again (fixed).
> - `show_character()` — the one character slot. On each unlock: the old card tweens `modulate:a` to 0 and gets freed, *then* the new card is built off-position (`slide_in_offset`) and tweens into place (`Tween.TRANS_CUBIC`/`EASE_OUT`). This is a manual `position`/`modulate` tween on children of a plain `Control` (not a `Container`), specifically so Godot's container layout pass doesn't fight the animation by snapping the position back every frame — that's also what was causing the overlap you saw before (the growing list of stacked cards had no ceiling and kept pushing further down).
> 
> **[scenes/level_generation/level_generator.gd](scenes/level_generation/level_generator.gd)** — `_setup_tutorial_ui()` now calls `set_general_entry()` once and `show_character()` for Ningning; `_on_tutorial_character_unlocked()` calls `show_character()` on each subsequent unlock instead of appending.
> 
> Please reload in-editor and check the tutorial run: one fixed "Allgemeine Mechaniken" card (Dash + Bomben) above, one character card below that fades out/slides in on each unlock.

## 🤷 User: *mein spiel ist schon gut aber ich will das…*

`21:11:56`

mein spiel ist schon gut aber ich will das die allgemeine beschreibung und character description NUR bei tutorial verfügbar ist. NICHT wen ich in der richitgen ebene bin. das bedeutet auch wenn ich im tutorial bin und das geschafft habe wechsel ich ja ins richtige level und da soll es NICHT mehr vorkommen. NUR im tutorial, keine andere level

### 💭 Thinking: *The user wants the tutorial description UI…*

`21:12:13`

<details>
<summary>Thinking...</summary>

> The user wants the tutorial description UI to only show during the tutorial stage, not regular levels. I need to check where `_setup_tutorial_ui()` is actually called to confirm whether it's gated to tutorial generation or runs unconditionally on every level.
> 
> I also notice the file was already modified externally - the fade-out tween logic in `show_character()` was simplified to just immediately free the old card and slide in the new one. Since this wasn't my change and the user hasn't asked to revert it, I should leave it alone and build on top of the current state, so I'll re-read the full file to get its exact current contents before making the tutorial-only restriction.
</details>

#### 👀 Read `tutorial_character_intro.gd`

`21:12:13`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\ui\tutorial_character_intro.gd</code></summary>

```
extends Control
class_name TutorialCharacterIntro

# ============================================================================
# TutorialCharacterIntro — Tutorial-UI: EIN fixierter "Allgemeine Mechaniken"-
# Eintrag + EIN Charakter-Slot, der beim Unlock zum naechsten Charakter
# ueberblendet (level_generator.gd::generate_tutorial_stage()).
# ============================================================================
# Rueckmeldung (2026-08-13) "Descriptions ueberlappen sich, alte Charakter-
# Description soll wegfaden und die neue an ihre Stelle sliden, allgemeine
# Description bleibt fixiert": VORHER haengte jeder freigeschaltete
# Charakter einen weiteren, dauerhaft sichtbaren Eintrag an eine wachsende
# Liste - die Liste wurde mit jedem Unlock hoeher und überlappte irgendwann
# andere HUD-Elemente. JETZT gibt es nur zwei Karten insgesamt:
#   - _general_card: einmalig per set_general_entry() gebaut (Dash/Bomben),
#     bleibt danach unveraendert stehen.
#   - _character_slot: ein fester Platz, dessen Inhalt show_character() bei
#     jedem Charakterwechsel AUSTAUSCHT statt einen weiteren Eintrag
#     anzuhaengen - die alte Karte faded weg, danach slided die neue an
#     genau dieselbe Stelle.
#
# WARUM DER SLOT KEIN CONTAINER-KIND IST:
# _character_slot haengt zwar selbst in der aeusseren _list (VBoxContainer),
# aber SEINE Kind-Karten (alt/neu) sind NICHT direkte Kinder eines
# Containers - ein Container wuerde die Kind-Position bei jedem Sortier-
# Durchlauf auf die Layout-Position zwingen und damit jede manuelle
# position/modulate-Tween-Animation sofort wieder ueberschreiben. Innerhalb
# von _character_slot (ein einfacher Control) bleibt die von uns per Tween
# gesetzte position/modulate dagegen unangetastet.
#
# --- Andocken an die Minimap ------------------------------------------------
# Statt einer festen Bildschirmposition haengt sich die Liste UNTER die
# Minimap - exakt dasselbe Problem/dieselbe Loesung wie run_timer.gd (dockt
# rechts daneben): Minimap.get_docking_rect() liefert das tatsaechlich
# belegte, mit SettingsManager.minimap_ui_scale skalierungskorrigierte
# Rechteck.
#
# --- Pause-Menu-Layering -----------------------------------------------------
# Ein normaler Control statt eines eigenen CanvasLayers - level_generator.gd
# haengt diese Node INS SELBE CanvasLayer wie HUD/PauseMenu (siehe dortiges
# _find_overlay_layer()), damit PauseMenu.z_index wie ueberall sonst gilt
# und diese Karten beim Pausieren korrekt dahinter verschwinden.

const PANEL_COLOR: Color = Color(0.05, 0.05, 0.08, 0.86)
const NAME_COLOR: Color = Color(0.95, 0.85, 0.35)
const DESC_COLOR: Color = Color(0.88, 0.88, 0.92)
const MAX_WIDTH: float = 420.0

const MINIMAP_GROUP: String = "minimap"

## Abstand zwischen Minimap-Rahmen und der Liste in Pixeln.
@export var dock_gap: float = 16.0
## Abstand zwischen der fixierten "Allgemein"-Karte und dem Charakter-Slot.
@export var entry_gap: float = 10.0

## Wie lange die alte Charakter-Karte braucht, um komplett wegzufaden.
@export var fade_out_time: float = 0.35
## Wie lange die neue Charakter-Karte braucht, um in ihre Position zu sliden.
@export var slide_in_time: float = 0.4
## Waagerechter Versatz, aus dem die neue Karte hereinslided (negativ = von
## links, positiv = von rechts).
@export var slide_in_offset: Vector2 = Vector2(0.0, 26.0)

## Position, falls keine Minimap existiert (z.B. Testszene ohne HUD).
const FALLBACK_POSITION: Vector2 = Vector2(24.0, 24.0)

var _list: VBoxContainer = null
var _general_card: PanelContainer = null
var _character_slot: Control = null
var _current_character_card: PanelContainer = null
var _minimap: Control = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_list = VBoxContainer.new()
	_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_list.add_theme_constant_override("separation", entry_gap)
	add_child(_list)
	_list.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_list.position = FALLBACK_POSITION

	# Fester Platz fuer die Charakter-Karte, ausserhalb jeder Container-
	# Sortierlogik (siehe Kopfkommentar) - Groesse wird bei jedem
	# show_character() auf die tatsaechliche Karten-Groesse nachgezogen.
	_character_slot = Control.new()
	_character_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_character_slot.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	_list.add_child(_character_slot)

	if SettingsManager != null and SettingsManager.has_signal("minimap_setting_changed"):
		if not SettingsManager.minimap_setting_changed.is_connected(_update_dock):
			SettingsManager.minimap_setting_changed.connect(_update_dock)
	get_viewport().size_changed.connect(_update_dock)

	# Ein Frame warten: die Minimap baut ihr Raum-Overlay/ihren Rahmen noch
	# in ihrer eigenen _ready() fertig - wer vorher misst, dockt an die noch
	# unfertige Groesse an (identisches Muster wie run_timer.gd).
	_update_dock.call_deferred()


## Setzt die Y-Position direkt unter die Minimap. Idempotent.
func _update_dock() -> void:
	if _minimap == null or not is_instance_valid(_minimap):
		var found: Array[Node] = get_tree().get_nodes_in_group(MINIMAP_GROUP)
		if found.is_empty():
			_list.position = FALLBACK_POSITION
			return
		_minimap = found[0] as Control

	if _minimap == null or not _minimap.has_method("get_docking_rect"):
		_list.position = FALLBACK_POSITION
		return

	if not _minimap.visible:
		_list.position = FALLBACK_POSITION
		return

	var rect: Rect2 = _minimap.get_docking_rect()
	_list.position = Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)


func _process(_delta: float) -> void:
	# Guenstiger Abgleich, deckt die getweente Groessenaenderung beim
	# Oeffnen/Schliessen der Grosskarte ab, die kein eigenes Signal hat -
	# identisches Muster wie run_timer.gd::_process().
	if _minimap == null or not is_instance_valid(_minimap) or _list == null:
		return
	if not _minimap.visible:
		return
	var rect: Rect2 = _minimap.get_docking_rect()
	var wanted := Vector2(rect.position.x, rect.position.y + rect.size.y + dock_gap)
	if not _list.position.is_equal_approx(wanted):
		_list.position = wanted


## Baut die fixierte "Allgemeine Mechaniken"-Karte (Dash/Bomben) - EINMALIG,
## wird danach nie wieder veraendert oder ausgetauscht.
func set_general_entry(title: String, description_lines: Array[String]) -> void:
	if _general_card != null and is_instance_valid(_general_card):
		_general_card.queue_free()
	_general_card = _build_card(title, description_lines)
	_list.add_child(_general_card)
	# VOR den Charakter-Slot einsortieren, damit "Allgemein" immer oben
	# steht, egal in welcher Reihenfolge die beiden Methoden aufgerufen
	# werden.
	_list.move_child(_general_card, 0)


## Tauscht die Charakter-Karte im festen Slot aus: die alte faded komplett
## weg, danach slided die neue aus slide_in_offset an ihre Position -
## siehe Kopfkommentar, wieso das ueber manuelle Tweens statt Container-
## Layout laeuft.
func show_character(title: String, description_lines: Array[String]) -> void:
	if _character_slot == null:
		return

	var old_card: PanelContainer = _current_character_card
	_current_character_card = null

	if old_card != null and is_instance_valid(old_card):
		old_card.queue_free()

	_slide_in_character_card(title, description_lines)


func _slide_in_character_card(title: String, description_lines: Array[String]) -> void:
	if _character_slot == null or not is_instance_valid(_character_slot):
		return

	var card: PanelContainer = _build_card(title, description_lines)
	_character_slot.add_child(card)
	card.position = slide_in_offset
	_current_character_card = card

	# Ein Frame warten, bis die Labels ihre Autowrap-Hoehe kennen - erst
	# dann hat "card" seine tatsaechliche Groesse, an die der Slot (fuer die
	# Hoehe innerhalb der aeusseren _list) angeglichen wird.
	await get_tree().process_frame
	if not is_instance_valid(card) or not is_instance_valid(_character_slot):
		return
	_character_slot.custom_minimum_size = card.size

	var slide_tween: Tween = create_tween()
	slide_tween.tween_property(card, "position", Vector2.ZERO, slide_in_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _build_card(title: String, description_lines: Array[String]) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(MAX_WIDTH, 0.0)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	card.add_theme_stylebox_override("panel", style)

	var entry := VBoxContainer.new()
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.add_theme_constant_override("separation", 4)
	card.add_child(entry)

	var name_label := Label.new()
	name_label.text = title
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", NAME_COLOR)
	entry.add_child(name_label)

	for line: String in description_lines:
		var desc_label := Label.new()
		desc_label.text = line
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", DESC_COLOR)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.custom_minimum_size = Vector2(MAX_WIDTH - 32.0, 0.0)
		entry.add_child(desc_label)

	return card

```
</details>

### 🤖 Assistant: *You've hit your session limit · resets 11…*

`21:12:14`

> You've hit your session limit · resets 11:30pm (Europe/Berlin)

## 🤷 User: *bitte die tutorial räume auch bisschen schwerer…*

`21:13:33`

bitte die tutorial räume auch bisschen schwerer machen also nicht wirklich neue enemy hinzufügen oder andere arten in die räume hinzufügen sondern einfach die anzahl der jeweiligen verdoppeln

### 🤖 Assistant: *You've hit your session limit · resets 11…*

`21:13:34`

> You've hit your session limit · resets 11:30pm (Europe/Berlin)

## 🤷 User: *mein spiel ist schon gut aber ich will das…*

`21:13:43`

mein spiel ist schon gut aber ich will das die allgemeine beschreibung und character description NUR bei tutorial verfügbar ist. NICHT wen ich in der richitgen ebene bin. das bedeutet auch wenn ich im tutorial bin und das geschafft habe wechsel ich ja ins richtige level und da soll es NICHT mehr vorkommen. NUR im tutorial, keine andere level

bitte die tutorial räume auch bisschen schwerer machen also nicht wirklich neue enemy hinzufügen oder andere arten in die räume hinzufügen sondern einfach die anzahl der jeweiligen verdoppeln

### 🤖 Assistant: *You've hit your session limit · resets 11…*

`21:13:44`

> You've hit your session limit · resets 11:30pm (Europe/Berlin)

## 🤷 User: *Erneut versuchen*

`21:30:03`

Erneut versuchen

### 💭 Thinking: *There are two requests to handle: restricting…*

`21:30:12`

<details>
<summary>Thinking...</summary>

> There are two requests to handle: restricting the tutorial description UI so it only shows during the tutorial stage and never reappears once the player moves to real levels, and doubling the enemy counts in the tutorial room by increasing the existing entries in `fixed_enemies_for()` rather than adding new enemy types. I'll start with the second task by reviewing the tutorial content file.
</details>

#### 👀 Read `tutorial_content.gd`

`21:30:12`

*(lines 55–130)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd</code></summary>

```
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
static func fixed_enemies_for(index: int) -> Array[Callable]:
	match index:
		0: # Fight1: nur Fighter und Scouts
			return [_fighter_factory(), _scout_factory(), _scout_factory()]
		2: # Fight2: Moerser, Saeure-Sprinkler, Diver
			return [_mortar_factory(), _acid_sprinkler_factory(), _dive_bomber_factory()]
		4: # Fight3: Scouts und Shield
			return [_scout_factory(), _scout_factory(), _shield_drone_factory()]
		6: # Fight4: Plasma Shooter und 2 Fighter
			return [_plasma_beam_bot_factory(), _fighter_factory(), _fighter_factory()]
		8: # Final Fight: Mix aus allen zuvor gezeigten Gegnern
			return [_fighter_factory(), _scout_factory(), _shield_drone_factory(), _plasma_beam_bot_factory()]
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


```
</details>

### 💭 Thinking: *I'm doubling the enemy counts per room: Fight1…*

`21:30:22`

<details>
<summary>Thinking...</summary>

> I'm doubling the enemy counts per room: Fight1 becomes two Fighters and four Scouts, Fight2 becomes two each of Mortar, AcidSprinkler, and DiveBomber, and I'm working through Fight3's Scouts and ShieldDrone next.
> 
> Fight3 becomes four Scouts and two ShieldDrones, Fight4 becomes two PlasmaBeamBots and four Fighters, and the final fight doubles each of Fighter, Scout, ShieldDrone, and PlasmaBeamBot to two each. This confirms the instruction just means doubling each existing enemy type's count per room rather than introducing new types, so I'll write the edit accordingly.
</details>

#### ✏️  Edit `tutorial_content.gd`

`21:30:28`

```diff
@@ -1,18 +1,41 @@ ## Exakte Gegnerliste je Kettenindex, als Callables fuer
 ## RoomInstance.prepare_fixed_enemies(). Leeres Array (Tresorzellen) = keine
 ## Ueberschreibung, wird von generate_tutorial_stage() uebersprungen.
+##
+## Rueckmeldung "Tutorial-Raeume etwas schwerer machen, aber KEINE neuen
+## Gegnertypen/-arten - einfach die Anzahl der jeweiligen verdoppeln"
+## (2026-08-13): jeder Gegnertyp kommt jetzt doppelt so oft vor wie vorher,
+## die Zusammensetzung (welche Typen pro Raum) bleibt unveraendert.
 static func fixed_enemies_for(index: int) -> Array[Callable]:
 	match index:
 		0: # Fight1: nur Fighter und Scouts
-			return [_fighter_factory(), _scout_factory(), _scout_factory()]
+			return [
+				_fighter_factory(), _fighter_factory(),
+				_scout_factory(), _scout_factory(), _scout_factory(), _scout_factory(),
+			]
 		2: # Fight2: Moerser, Saeure-Sprinkler, Diver
-			return [_mortar_factory(), _acid_sprinkler_factory(), _dive_bomber_factory()]
+			return [
+				_mortar_factory(), _mortar_factory(),
+				_acid_sprinkler_factory(), _acid_sprinkler_factory(),
+				_dive_bomber_factory(), _dive_bomber_factory(),
+			]
 		4: # Fight3: Scouts und Shield
-			return [_scout_factory(), _scout_factory(), _shield_drone_factory()]
-		6: # Fight4: Plasma Shooter und 2 Fighter
-			return [_plasma_beam_bot_factory(), _fighter_factory(), _fighter_factory()]
+			return [
+				_scout_factory(), _scout_factory(), _scout_factory(), _scout_factory(),
+				_shield_drone_factory(), _shield_drone_factory(),
+			]
+		6: # Fight4: Plasma Shooter und 2 Fighter (verdoppelt: 4 Fighter)
+			return [
+				_plasma_beam_bot_factory(), _plasma_beam_bot_factory(),
+				_fighter_factory(), _fighter_factory(), _fighter_factory(), _fighter_factory(),
+			]
 		8: # Final Fight: Mix aus allen zuvor gezeigten Gegnern
-			return [_fighter_factory(), _scout_factory(), _shield_drone_factory(), _plasma_beam_bot_factory()]
+			return [
+				_fighter_factory(), _fighter_factory(),
+				_scout_factory(), _scout_factory(),
+				_shield_drone_factory(), _shield_drone_factory(),
+				_plasma_beam_bot_factory(), _plasma_beam_bot_factory(),
+			]
 		_:
 			var empty: Array[Callable] = []
 			return empty
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\tutorial_content.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking: *For task 1, I need to make sure the tutorial…*

`21:30:35`

<details>
<summary>Thinking...</summary>

> For task 1, I need to make sure the tutorial UI is scoped strictly to the tutorial stage and never shows up in regular levels. I'm checking whether `_setup_tutorial_ui()` is only called during `generate_tutorial_stage()` or on every stage generation, so I'll search level_generator.gd for those call sites.
</details>

#### 🔎 Grep `_setup_tutorial_ui|generate_tutorial_stage|generate_stage\b|TutorialFlow` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`21:30:35`

```
217:## Von generate_tutorial_stage() befuellt, von _instantiate_layout() als
303:		# Tutorial-Modus: TutorialFlow.pending wurde von main_menu.gd/
307:		var tutorial_flow: Node = get_node_or_null("/root/TutorialFlow")
311:			call_deferred("generate_tutorial_stage")
411:func generate_tutorial_stage() -> void:
415:	# Party starten — wenn TutorialFlow.next_character_index gesetzt ist
418:	var _tf: Node = get_node_or_null("/root/TutorialFlow")
429:	_setup_tutorial_ui()
508:func _setup_tutorial_ui() -> void:
552:	var tf: Node = get_node_or_null("/root/TutorialFlow")
583:func generate_stage(stage: int) -> void:
```

### 💭 Thinking: *Graphify wasn't very useful earlier for source…*

`21:30:46`

<details>
<summary>Thinking...</summary>

> Graphify wasn't very useful earlier for source-level detail since it mostly indexes wiki/docs rather than deep .gd internals, but since the hook is flagging it as mandatory again, I'll run a quick query about tutorial stage generation and transitions to satisfy it, then continue with the grep results I already have.
</details>

#### 💻 Bash: *Query graphify about tutorial-to-regular-level stage transition*

`21:30:46`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify query "level_generator generate_stage vs generate_tutorial_stage transition from tutorial to regular level" --budget 3000 2>&1 | head -60
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Traversal: BFS depth=2 | Start: ['level_generator.gd', 'Tutorial Screen Design Simplification'] | 10 nodes found



NODE level_generator.gd [src=02_Tech_Architecture/level_generator.md loc= community=level_generator.gd]

NODE Tutorial Screen Design Simplification [src=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md loc=L6 community=Tutorial Screen Design Simplification]

NODE Colossus [src=01_Game_Design/Enemies/colossus.md loc= community=level_generator.gd]

NODE Fighter [src=01_Game_Design/Enemies/fighter.md loc= community=level_generator.gd]

NODE Stinger [src=01_Game_Design/Enemies/stinger.md loc= community=level_generator.gd]

NODE 2026-08-01_tutorial-screen-design-simplification.md [src=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md loc=L1 community=Tutorial Screen Design Simplification]

NODE Gemini [src=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md loc=L15 community=Tutorial Screen Design Simplification]

NODE Gemini [src=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md loc=L23 community=Tutorial Screen Design Simplification]

NODE User [src=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md loc=L10 community=Tutorial Screen Design Simplification]

NODE User [src=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md loc=L19 community=Tutorial Screen Design Simplification]

EDGE Colossus --references [EXTRACTED]--> level_generator.gd

EDGE level_generator.gd --references [EXTRACTED]--> Fighter

EDGE level_generator.gd --references [EXTRACTED]--> Stinger

EDGE 2026-08-01_tutorial-screen-design-simplification.md --contains [EXTRACTED]--> Tutorial Screen Design Simplification at=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md:L6

EDGE Tutorial Screen Design Simplification --contains [EXTRACTED]--> User at=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md:L10

EDGE Tutorial Screen Design Simplification --contains [EXTRACTED]--> Gemini at=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md:L15

EDGE Tutorial Screen Design Simplification --contains [EXTRACTED]--> User at=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md:L19

EDGE Tutorial Screen Design Simplification --contains [EXTRACTED]--> Gemini at=04_Chat_Prompts/2026-08-01_tutorial-screen-design-simplification.md:L23
```

### 💭 Thinking: *Graphify isn't surfacing enough code detail…*

`21:31:07`

<details>
<summary>Thinking...</summary>

> Graphify isn't surfacing enough code detail, so I'll fall back to direct file reads and greps as CLAUDE.md suggests. I want to look at the actual level_generator.gd sections for generate_tutorial_stage() and generate_stage(), and trace whether the tutorial transitions into a real level by eventually calling generate_stage().
> 
> Given CLAUDE.md's note that floor changes deliberately skip reload_current_scene() — only rooms/hazards/projectiles/status-effects reset while Items, PartyManager, PlayerStats, and the player persist — this means the tutorial's _tutorial_ui Control, added to the shared CanvasLayer, wouldn't get cleaned up automatically when transitioning to the first real stage. That confirms the bug: the tutorial UI likely persists indefinitely into subsequent levels since nothing frees it.
> 
> I need to trace where the tutorial-to-real-stage transition actually happens — whether finishing the tutorial's final room calls generate_stage() directly as part of normal progression, or whether it triggers a full run restart/reload instead. I should check stage_manager.gd and any tutorial-specific completion logic to see exactly how that handoff occurs.
</details>

#### Read

`21:31:07`

**__unparsedToolInput:**

```json
{
  "raw": "{\"file_path\": \"C:\\\\Users\\\\thvnh\\\\Documents\\\\GitHub\\\\whiplash\\\\scenes\\\\level_generation\\\\level_generator.gd\", \"offset\": 200, 320, \"limit\": 1}",
  "len": 140
}
```

```
InputValidationError: Read was called with input that could not be parsed as JSON.
You sent (first 140 of 140 bytes): {"file_path": "C:\\Users\\thvnh\\Documents\\GitHub\\whiplash\\scenes\\level_generation\\level_generator.gd", "offset": 200, 320, "limit": 1}
Common causes: unescaped backslashes in file paths (use / or \\), unescaped control character, or truncated output. Retry with valid JSON.
```

### 💭 Thinking: *That call didn't go through correctly, so…*

`21:31:12`

<details>
<summary>Thinking...</summary>

> That call didn't go through correctly, so I need to fix it and try again.
</details>

#### 👀 Read `level_generator.gd`

`21:31:12`

*(lines 295–435)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```

	if navigation_region == null:
		navigation_region = get_parent().get_node_or_null("NavigationRegion3D") as NavigationRegion3D
		if navigation_region == null:
			push_warning("[LevelGenerator] Keine NavigationRegion3D gefunden. Gegner fallen auf reines Direkt-Chasing zurueck.")

	_debug("[LevelGenerator] _ready() - autostart=%s, room_pool=%d, enemy_table=%d, boss_table=%d" % [autostart, room_pool.size(), enemy_table.size(), boss_table.size()])
	if autostart and grid_generator:
		# Tutorial-Modus: TutorialFlow.pending wurde von main_menu.gd/
		# debug_teleporter.gd VOR change_scene_to_file() gesetzt. Einmalig
		# konsumiert und sofort zurueckgesetzt, damit kein Tutorial-Zustand
		# einen spaeteren Etagenwechsel/RunRestart uebersteht.
		var tutorial_flow: Node = get_node_or_null("/root/TutorialFlow")
		if tutorial_flow != null and bool(tutorial_flow.get("pending")):
			tutorial_flow.set("pending", false)
			tutorial_flow.set("was_active", true)
			call_deferred("generate_tutorial_stage")
		else:
			call_deferred("generate_new_stage")
	elif autostart and grid_generator == null:
		push_error("[LevelGenerator] Kein RoomGridGenerator gefunden! Node muss 'RoomGridGenerator' heissen und Geschwister-Node sein, ODER im Inspector zugewiesen werden.")

# --- Oeffentliche API fuer die Minimap ------------------------------

func get_map_cells() -> Dictionary:
	return _map_cells


## PHASE 3.1: Rasterposition -> Ankerzelle des belegenden Raums. Die Minimap
## fuellt damit die komplette Flaeche eines Multi-Zellen-Raums auf.
func get_occupancy() -> Dictionary:
	return _occupancy

func get_current_room() -> Vector2i:
	return _current_room

func get_current_stage() -> int:
	return current_stage


## Der tatsaechlich verwendete Run-Seed - Grundlage fuer den
## Leaderboard-Eintrag und die Seed-Anzeige im HUD.
func get_run_seed() -> int:
	return _run_seed


## Teilbarer Kurzcode desselben Seeds ("4F2K9").
func get_run_seed_code() -> String:
	return DetRng.seed_to_code(_run_seed)

func is_stage_cleared() -> bool:
	return _stage_cleared


## PHASE 3: leitet cell_size und elevation_step aus room_scale ab, statt sie
## unabhaengig voneinander im Inspector pflegen zu lassen. Wird von _ready()
## aufgerufen, bevor irgendetwas generiert wird.
func _apply_room_scale() -> void:
	cell_size = Vector3(
		BASE_CELL_SIZE.x * room_scale.x,
		BASE_CELL_SIZE.y,
		BASE_CELL_SIZE.z * room_scale.z
	)
	elevation_step = BASE_ELEVATION_STEP * room_scale.y

## Echter Tuerzustand einer Zelle in einer Richtung - wird von der
## Minimap (minimap_rooms.gd) abgefragt, damit dort nur tatsaechlich
## vorhandene und tatsaechlich begehbare Durchgaenge als offen erscheinen.
func get_door_state(grid: Vector2i, dir: String) -> int:
	if not _instances.has(grid):
		return RoomInstance.DoorState.NONE
	var room: RoomInstance = _instances[grid]
	if not is_instance_valid(room):
		return RoomInstance.DoorState.NONE
	return room.get_door_state(dir)


func get_room_type_name(type: int) -> String:
	match type:
		RoomData.RoomType.START:
			return "START"
		RoomData.RoomType.COMBAT:
			return "COMBAT"
		RoomData.RoomType.CORRIDOR:
			return "CORRIDOR"
		RoomData.RoomType.TREASURE:
			return "TREASURE"
		RoomData.RoomType.BOSS:
			return "BOSS"
		RoomData.RoomType.SHOP:
			return "SHOP"
	return "UNKNOWN"

# --- Generierung ----------------------------------------------------

func generate_new_stage() -> void:
	if _tutorial_ui != null and is_instance_valid(_tutorial_ui):
		_tutorial_ui.queue_free()
		_tutorial_ui = null
		
	_current_layout = grid_generator.generate_layout(_run_seed, current_stage)
	_debug("[LevelGenerator] Layout generiert: %d Zellen (Etage %d)" % [_current_layout.size(), current_stage])
	_instantiate_layout(_current_layout)


## ############################################################################
## TUTORIAL-MODUS
## ############################################################################
## Laeuft als ETAGE 0 - eine Zahl, die kein normaler Run je erreicht (Etage 1
## ist der erste echte Run-Start). Der einzige Grund, warum das reicht: Die
## Sieg-Trophaee (_spawn_victory_trophy() unten) faerbt sich GOLD nur, wenn
## current_stage >= Stages.final_stage - bei current_stage = 0 ist das immer
## false, die Trophaee wird also automatisch SCHWARZ und ruft automatisch
## Stages.advance_stage() auf, was current_stage auf 1 hochzaehlt und eine
## GANZ NORMALE Etage 1 generiert. Kein Sonderfall in victory_trophy.gd oder
## _spawn_victory_trophy() noetig.
func generate_tutorial_stage() -> void:
	current_stage = 0
	_debug("[LevelGenerator] Baue Tutorial-Etage (0).")

	# Party starten — wenn TutorialFlow.next_character_index gesetzt ist
	# (weil der Spieler bereits einen Charakter freigeschaltet hat), die Party
	# mit diesem Charakter beginnen statt immer bei Ningning.
	var _tf: Node = get_node_or_null("/root/TutorialFlow")
	var _tf_idx: int = int(_tf.get("next_character_index")) if _tf != null else -1
	var _start_char: CharacterData = TutorialContent.NINGNING_DATA
	match _tf_idx:
		1:
			_start_char = TutorialContent.GISELLE_DATA
		2:
			_start_char = TutorialContent.KARINA_DATA
		3:
			_start_char = TutorialContent.WINTER_DATA
	PartyManager.setup_party([_start_char])
	_setup_tutorial_ui()

	tutorial_room_types = TutorialContent.room_types()
	var directions: Array[String] = TutorialContent.directions()

	# Rasterpositionen im selben Zickzack ablaufen, den generate_fixed_layout()
```
</details>

### 💭 Thinking: *Wait, this cleanup logic already exists in…*

`21:31:29`

<details>
<summary>Thinking...</summary>

> Wait, this cleanup logic already exists in generate_new_stage—it frees the tutorial UI before generating the new layout. I didn't write this, so it must already be part of the existing code.
> 
> Now I need to check whether generate_stage(stage), the function used for floor-to-floor progression after the first stage, has the same cleanup logic as generate_new_stage does.
> 
> The real question is which function the tutorial's victory trophy actually triggers when it turns black and calls advance_stage() — since current_stage starts at 0, the trophy condition for gold is always false, so it auto-advances to stage 1 as a normal floor. I need to check stage_manager.gd's advance_stage() to see exactly which level generator method gets called there.
</details>

#### 🔎 Grep `generate_stage\(|generate_new_stage\(|advance_stage` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\level\stage_manager.gd`

`21:31:29`

```
96:func advance_stage() -> bool:
141:		gen.generate_stage(to_stage)
143:		push_error("[StageManager] LevelGenerator kennt generate_stage() nicht — bitte die gepatchte level_generator.gd einspielen.")
```

### 💭 Thinking: *I'm confirming that `advance_stage()` actually…*

`21:31:45`

<details>
<summary>Thinking...</summary>

> I'm confirming that `advance_stage()` actually calls `gen.generate_stage(to_stage)` rather than `generate_new_stage()`, so when the tutorial transitions from stage 0 to 1, it's this different function being invoked. That means the cleanup logic I found earlier only applies to `generate_new_stage()`, which is used exclusively for starting a brand new non-tutorial run from scratch.
> 
> So the real bug is that `generate_stage()`, which handles the tutorial-to-floor-1 transition and all subsequent floor advances, never clears `_tutorial_ui` — the cleanup exists in the wrong method entirely. I'm also double-checking whether this cleanup code in `level_generator.gd` predates my session's edits, since the system reminder about a modified file referred specifically to `tutorial_character_intro.gd`, not this file — meaning I likely never touched `generate_new_stage()` this session at all.
> 
> This confirms the cleanup was pre-existing, probably written by whoever built the tutorial system but only wired into one of the two entry points. The fix is to add the same `_tutorial_ui` cleanup to `generate_stage(stage)`, ideally centralizing it in a shared helper called by both paths, guarded so it only runs for non-tutorial stages. I want to look at `generate_stage()`'s current implementation to find the best place to add this.
</details>

#### 💻 Bash: *Graphify orientation query before further grepping level_generator.gd*

`21:31:45`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify query "level_generator generate_stage function floor progression stage manager advance_stage" --budget 2000 2>&1 | head -40
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Traversal: BFS depth=2 | Start: ['level_generator.gd', 'party_manager.gd', 'status_effect_manager.gd', 'Rough Checked Floor Texture', '2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression'] | 18 nodes found



NODE level_generator.gd [src=02_Tech_Architecture/level_generator.md loc= community=level_generator.gd]

NODE party_manager.gd [src=02_Tech_Architecture/party_manager.md loc= community=player_base.gd]

NODE status_effect_manager.gd [src=02_Tech_Architecture/status_effect_manager.md loc= community=player_base.gd]

NODE Rough Checked Floor Texture [src=assets/textures/environment/rough-checked-texture-collage.jpg loc=None community=Rough Checked Floor Texture]

NODE 2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression [src=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md loc=L10 community=2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]

NODE player_base.gd [src=02_Tech_Architecture/player_base.md loc= community=player_base.gd]

NODE 2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md [src=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md loc=L1 community=2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]

NODE Colossus [src=01_Game_Design/Enemies/colossus.md loc= community=level_generator.gd]

NODE Fighter [src=01_Game_Design/Enemies/fighter.md loc= community=level_generator.gd]

NODE Stinger [src=01_Game_Design/Enemies/stinger.md loc= community=level_generator.gd]

NODE Erwaehnte Entitaeten [src=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md loc=L240 community=2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]

NODE Metadaten [src=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md loc=L250 community=2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]

NODE 🧠 Semantische Verbindungen (Graphify) [src=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md loc=L258 community=2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression]

NODE _MOC_DevLogs.md [src=03_DevLogs/_MOC_DevLogs.md loc=L1 community=_MOC_DevLogs.md]

NODE Giselle [src=01_Game_Design/Characters/giselle.md loc= community=player_base.gd]

NODE Karina [src=01_Game_Design/Characters/karina.md loc= community=player_base.gd]

NODE Ningning [src=01_Game_Design/Characters/ningning.md loc= community=player_base.gd]

NODE Winter [src=01_Game_Design/Characters/winter.md loc= community=player_base.gd]

EDGE player_base.gd --calls [EXTRACTED]--> status_effect_manager.gd

EDGE Colossus --references [EXTRACTED]--> level_generator.gd

EDGE level_generator.gd --references [EXTRACTED]--> Fighter

EDGE level_generator.gd --references [EXTRACTED]--> Stinger

EDGE 2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md --contains [EXTRACTED]--> 2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression at=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md:L10

EDGE 2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression --contains [EXTRACTED]--> Erwaehnte Entitaeten at=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md:L240

EDGE 2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression --contains [EXTRACTED]--> Metadaten at=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md:L250

EDGE 2026-08-04 — feat(items,status,levelgen,rooms): Phase 3-5 - Status-Effekt-System, Item-Overhaul, Multi-Zellen-Raeume, Etagen-Progression --contains [EXTRACTED]--> 🧠 Semantische Verbindungen (Graphify) at=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md:L258

EDGE party_manager.gd --references [EXTRACTED]--> player_base.gd

EDGE Giselle --inherits [EXTRACTED]--> player_base.gd

EDGE Karina --inherits [EXTRACTED]--> player_base.gd

EDGE Ningning --inherits [EXTRACTED]--> player_base.gd

EDGE Winter --inherits [EXTRACTED]--> player_base.gd

EDGE 2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md --references [EXTRACTED]--> _MOC_DevLogs.md at=03_DevLogs/2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef.md:L260
```

### 🤖 Assistant: *Now let's look at `generate_stage()` directly…*

`21:31:50`

> Now let's look at `generate_stage()` directly.

#### 🔎 Grep `func generate_stage` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`21:31:51`

```
583:func generate_stage(stage: int) -> void:
584-	current_stage = maxi(stage, 1)
585-	_stage_theme = StageTheme.for_stage(current_stage)
586-	_stage_theme.floor_texture = StageTheme.floor_ceiling_texture()
587-	_debug("[LevelGenerator] Baue Etage %d (Thema: %s)" % [current_stage, _stage_theme.theme_name])
588-	_current_layout = grid_generator.generate_layout(_run_seed, current_stage)
589-	_instantiate_layout(_current_layout)
590-
591-
592-## Weltposition, an der der Spieler in der neuen Etage abgesetzt wird.
593-##
594-## Bevorzugt den PlayerSpawnPoint der Startraum-Szene; ohne ihn die Raummitte.
595-## NIE Vector3.ZERO als Fallback: liegt der Startraum auf einer Hoehenstufe
596-## ungleich 0, faellt der Spieler sonst durch den Boden.
597-func get_start_room_spawn() -> Vector3:
598-	var start: RoomInstance = _instances.get(Vector2i.ZERO)
599-	if start == null or not is_instance_valid(start):
600-		return Vector3.ZERO
601-
602-	var marker: Node3D = start.find_child("PlayerSpawnPoint", true, false) as Node3D
603-	if marker != null:
604-		return marker.global_position
605-
606-	var center: Vector3 = start.get_room_center()
607-	center.y = start.global_position.y + 1.0
608-	return center
609-
610-
611-## Das aktuelle Thema der Etage. Die Minimap und der StageManager lesen hier.
612-func get_stage_theme() -> StageTheme:
613-	if _stage_theme == null:
614-		_stage_theme = StageTheme.for_stage(current_stage)
615-	return _stage_theme
616-
617-
618-func _instantiate_layout(layout: Dictionary) -> void:
619-	_clear_current_rooms()
620-	_used_unique_rooms.clear()
621-	_map_cells.clear()
622-	_stage_cleared = false
623-	_current_room = Vector2i.ZERO
```

### 🤖 Assistant: *Found the exact bug — `generate_new_stage…*

`21:32:00`

<details>
<summary>Thinking...</summary>

> Confirmed: generate_stage() never clears _tutorial_ui, so after the tutorial ends and advances to stage 1, that UI element stays alive and leaks into every subsequent floor since the same function handles all later advances. I need to add the same cleanup logic there to fix it.
> 
> Rather than duplicating the same three-line cleanup block in both generate_new_stage() and generate_stage(), I'll factor it into a small shared helper like _teardown_tutorial_ui() and call it from both places, matching the codebase's style of small focused private helpers. Now let's write the edit.
</details>

> Found the exact bug — `generate_new_stage()` already frees `_tutorial_ui`, but `generate_stage(stage)` (the function actually used for the tutorial→floor-1 transition and every floor after) never does. Let me fix that with a shared helper.

#### 👀 Read `level_generator.gd`

`21:32:00`

*(lines 388–398)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
# --- Generierung ----------------------------------------------------

func generate_new_stage() -> void:
	if _tutorial_ui != null and is_instance_valid(_tutorial_ui):
		_tutorial_ui.queue_free()
		_tutorial_ui = null
		
	_current_layout = grid_generator.generate_layout(_run_seed, current_stage)
	_debug("[LevelGenerator] Layout generiert: %d Zellen (Etage %d)" % [_current_layout.size(), current_stage])
	_instantiate_layout(_current_layout)
```
</details>

#### ✏️  Edit `level_generator.gd`

`21:32:10`

```diff
@@ -1,8 +1,22 @@ func generate_new_stage() -> void:
-	if _tutorial_ui != null and is_instance_valid(_tutorial_ui):
-		_tutorial_ui.queue_free()
-		_tutorial_ui = null
-		
+	_teardown_tutorial_ui()
 	_current_layout = grid_generator.generate_layout(_run_seed, current_stage)
 	_debug("[LevelGenerator] Layout generiert: %d Zellen (Etage %d)" % [_current_layout.size(), current_stage])
 	_instantiate_layout(_current_layout)
+
+
+## Entfernt die Dash/Bomben+Charakter-Beschreibungskarten (siehe
+## scripts/ui/tutorial_character_intro.gd), falls sie noch haengen.
+## Rueckmeldung "Beschreibung soll NUR im Tutorial vorkommen, nicht mehr in
+## echten Leveln" (2026-08-13): generate_new_stage() rief das schon vorher
+## auf, aber der eigentliche Uebergang Tutorial -> Etage 1 laeuft NIE ueber
+## generate_new_stage() - stage_manager.gd::advance_stage() ruft nach dem
+## Tutorial (current_stage 0 -> 1) IMMER generate_stage() auf (siehe
+## Kopfkommentar bei generate_tutorial_stage()), und generate_stage() ist
+## danach auch fuer JEDEN weiteren Etagenwechsel zustaendig. Ohne diesen
+## Aufruf auch dort ueberlebte die Tutorial-UI also den ganzen Rest des
+## Runs.
+func _teardown_tutorial_ui() -> void:
+	if _tutorial_ui != null and is_instance_valid(_tutorial_ui):
+		_tutorial_ui.queue_free()
+	_tutorial_ui = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now add the same call to `generate_stage…*

`21:32:12`

> Now add the same call to `generate_stage()`:

#### 👀 Read `level_generator.gd`

`21:32:13`

*(lines 592–600)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
## also trotzdem vollstaendig reproduzierbar.
##
## Der Spielerzustand wird hier BEWUSST NICHT ANGEFASST. Items, PlayerStats
## und PartyManager sind Autoloads und ueberleben, weil kein Szenenwechsel
## stattfindet.
func generate_stage(stage: int) -> void:
	current_stage = maxi(stage, 1)
	_stage_theme = StageTheme.for_stage(current_stage)
```
</details>

*(lines 597–604)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
func generate_stage(stage: int) -> void:
	current_stage = maxi(stage, 1)
	_stage_theme = StageTheme.for_stage(current_stage)
	_stage_theme.floor_texture = StageTheme.floor_ceiling_texture()
	_debug("[LevelGenerator] Baue Etage %d (Thema: %s)" % [current_stage, _stage_theme.theme_name])
	_current_layout = grid_generator.generate_layout(_run_seed, current_stage)
	_instantiate_layout(_current_layout)
```
</details>

#### ✏️  Edit `level_generator.gd`

`21:32:21`

```diff
@@ -1,4 +1,5 @@ func generate_stage(stage: int) -> void:
+	_teardown_tutorial_ui()
 	current_stage = maxi(stage, 1)
 	_stage_theme = StageTheme.for_stage(current_stage)
 	_stage_theme.floor_texture = StageTheme.floor_ceiling_texture()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Let's check if there's a third stage-entry…*

`21:32:27`

<details>
<summary>Thinking...</summary>

> I should also check generate_next_stage_same_pattern() to see if it's another entry point that needs the same teardown logic, so let me look at its definition and callers.
</details>

> Let's check if there's a third stage-entry-point (`generate_next_stage_same_pattern`) that also needs this:

#### 🔎 Grep `func generate_next_stage_same_pattern|generate_next_stage_same_pattern\(\)` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`21:32:27`

Glob: `**/*.gd`

```
scenes\level_generation\level_generator.gd:577:func generate_next_stage_same_pattern() -> void:
scenes\level_generation\level_generator.gd:588:## Unterschied zu generate_next_stage_same_pattern(): dort wird dasselbe
```

### 💭 Thinking: *I don't see any other callers of `generate_next_stage_same_pattern…*

`21:32:35`

<details>
<summary>Thinking...</summary>

> I don't see any other callers of `generate_next_stage_same_pattern()` besides its own definition and a doc-comment mention—it looks like dead or unused code, possibly a leftover utility. I should check its body to see if it also needs the teardown call, in case it's still invoked somewhere later.
</details>

#### 👀 Read `level_generator.gd`

`21:32:35`

*(lines 575–589)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```


func generate_next_stage_same_pattern() -> void:
	current_stage += 1
	_instantiate_layout(_current_layout)


## ############################################################################
## PHASE 3.2 — ETAGENWECHSEL
## ############################################################################
## Baut eine KOMPLETT NEUE Etage: neues Layout, neues Thema, staerkere Gegner.
## Wird vom StageManager (stage_manager.gd) gerufen.
##
## Unterschied zu generate_next_stage_same_pattern(): dort wird dasselbe
```
</details>

### 💭 Thinking: *This function isn't called externally, but…*

`21:32:41`

<details>
<summary>Thinking...</summary>

> This function isn't called externally, but since it also transitions to a next stage, I should add the teardown there too for safety and consistency, even though it's a minimal-cost precaution.
</details>

#### ✏️  Edit `level_generator.gd`

`21:32:41`

```diff
@@ -1,3 +1,4 @@ func generate_next_stage_same_pattern() -> void:
+	_teardown_tutorial_ui()
 	current_stage += 1
 	_instantiate_layout(_current_layout)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking: *RunRestart already handles full scene reloads…*

`21:32:51`

<details>
<summary>Thinking...</summary>

> RunRestart already handles full scene reloads, which would naturally free _tutorial_ui since it lives under the CanvasLayer being destroyed, so no extra cleanup is needed there. I'm also verifying that _setup_tutorial_ui() is only ever called from generate_tutorial_stage().
> 
> This confirms the UI only gets created during the tutorial and is properly torn down whenever any subsequent stage-generation function runs, satisfying the "only in tutorial, no other level" requirement. I'm also checking that _teardown_tutorial_ui() is idempotent — it checks is_instance_valid before freeing and always nulls the variable, so repeated calls across later floors are safe no-ops. Now I want to do one final read-through of the surrounding code to sanity check the whole diff.
</details>

#### 👀 Read `level_generator.gd`

`21:32:51`

*(lines 388–413)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
# --- Generierung ----------------------------------------------------

func generate_new_stage() -> void:
	_teardown_tutorial_ui()
	_current_layout = grid_generator.generate_layout(_run_seed, current_stage)
	_debug("[LevelGenerator] Layout generiert: %d Zellen (Etage %d)" % [_current_layout.size(), current_stage])
	_instantiate_layout(_current_layout)


## Entfernt die Dash/Bomben+Charakter-Beschreibungskarten (siehe
## scripts/ui/tutorial_character_intro.gd), falls sie noch haengen.
## Rueckmeldung "Beschreibung soll NUR im Tutorial vorkommen, nicht mehr in
## echten Leveln" (2026-08-13): generate_new_stage() rief das schon vorher
## auf, aber der eigentliche Uebergang Tutorial -> Etage 1 laeuft NIE ueber
## generate_new_stage() - stage_manager.gd::advance_stage() ruft nach dem
## Tutorial (current_stage 0 -> 1) IMMER generate_stage() auf (siehe
## Kopfkommentar bei generate_tutorial_stage()), und generate_stage() ist
## danach auch fuer JEDEN weiteren Etagenwechsel zustaendig. Ohne diesen
## Aufruf auch dort ueberlebte die Tutorial-UI also den ganzen Rest des
## Runs.
func _teardown_tutorial_ui() -> void:
	if _tutorial_ui != null and is_instance_valid(_tutorial_ui):
		_tutorial_ui.queue_free()
	_tutorial_ui = null

```
</details>

### 🤖 Assistant: *This all checks out.*

`21:32:59`

> This all checks out. Summary of both fixes:
> 
> ## 1. Tutorial room harder (double enemy counts)
> [scripts/tutorial_content.gd](scripts/tutorial_content.gd) — `fixed_enemies_for()`: every enemy type's count doubled per room (e.g. Fight1: 1 Fighter/2 Scout → 2 Fighter/4 Scout), no new types or room added, exactly as asked.
> 
> ## 2. Tutorial description UI leaking into real levels
> Found the actual bug: `generate_new_stage()` already had cleanup code freeing `_tutorial_ui`, but that function is only used when starting a brand-new *non-tutorial* run. The tutorial→floor-1 transition (and every floor after) goes through `stage_manager.gd`'s `advance_stage()` → `generate_stage()`, which never had that cleanup — so the description cards silently survived into the real run forever.
> 
> Fixed in [scenes/level_generation/level_generator.gd](scenes/level_generation/level_generator.gd) by factoring the cleanup into a shared `_teardown_tutorial_ui()` helper and calling it from all three stage-entry points (`generate_new_stage()`, `generate_stage()`, and `generate_next_stage_same_pattern()` for safety). Since `_setup_tutorial_ui()` is only ever called from `generate_tutorial_stage()`, the cards now exist exclusively during the tutorial and get torn down the moment any real stage generates — including right when the tutorial's boss room advances you to Floor 1.
> 
> Please reload and verify: tutorial room should feel noticeably busier, and the description cards should vanish for good once you leave the tutorial.

## 🤷 User: *das gilt auch für die anderen room wie wenn…*

`21:41:11`

das gilt auch für die anderen room wie wenn ich von tutorial direkt in vfx, sandbox,hub, item, boss oder tresor teleportiere. und kannst du die enemy global mehr hp geben? also das gilt jetzt für jeden gegner, mach die bitte 30% mehr hp und deren attackspeed auch 10% schneller. vergiss das nicht in obsidian vault zu aktualisieren

### 💭 Thinking: *The user also wants the same cleanup applied…*

`21:41:27`

<details>
<summary>Thinking...</summary>

> The user also wants the same cleanup applied when teleporting from the tutorial into other debug room like VFX, sandbox, hub, item, boss, or treasure — likely handled through the debug teleporter script.
> 
> Some of these (VfxTestRoom, EnemySandboxRoom, HubRoom, ItemTestRoom) might trigger a full scene change, which would naturally clear the tutorial UI without needing a fix. But boss and treasure room are probably just teleport pads within the same level scene, meaning the tutorial UI wouldn't get cleared automatically there. I need to check debug_teleporter.gd to see exactly how these teleports work.
</details>

#### 👀 Read `debug_teleporter.gd`

`21:41:27`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\debug_teleporter.gd</code></summary>

```
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
</details>

### 💭 Thinking: *The teleporter pads were replaced with an…*

`21:41:34`

<details>
<summary>Thinking...</summary>

> The teleporter pads were replaced with an admin panel in pause_menu.gd. I should check its `_build_admin_panel()` function for the teleport options like VFX, Sandbox, Hub, Items, Boss, and Treasure.
</details>

#### 🔎 Grep `_build_admin_panel|VfxTestRoom|EnemySandboxRoom|HubRoom|ItemTestRoom|Boss|Tresor|Treasure|teleport|change_scene` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd`

`21:41:34`

```
81:	_build_admin_panel()
325:	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
377:# ADMIN-Panel — Teleportation zu Debug-Räumen (ersetzt die physischen Pads)
379:func _build_admin_panel() -> void:
404:	back_btn.pressed.connect(_admin_teleport_to_start)
407:	# Tresorraum
408:	var treasure_btn := _make_admin_btn("Tresor")
409:	treasure_btn.pressed.connect(func() -> void: _admin_teleport_to_room_type(RoomData.RoomType.TREASURE))
410:	row1.add_child(treasure_btn)
412:	# Bossraum
413:	var boss_btn := _make_admin_btn("Boss")
414:	boss_btn.pressed.connect(func() -> void: _admin_teleport_to_room_type(RoomData.RoomType.BOSS))
415:	row1.add_child(boss_btn)
424:	item_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: ItemTestRoom.teleport_player_in()))
429:	sandbox_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: EnemySandboxRoom.teleport_player_in()))
434:	hub_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: HubRoom.teleport_player_in()))
439:	vfx_btn.pressed.connect(func() -> void: _admin_pocket(func() -> void: VfxTestRoom.teleport_player_in()))
451:## Teleportiert den Spieler zum Startraum zurück (erster START-Raum im Layout).
452:func _admin_teleport_to_start() -> void:
453:	_admin_teleport_to_room_type(RoomData.RoomType.START)
457:## teleportiert den aktiven Spieler dorthin. Schliesst danach das Pause-Menue.
458:func _admin_teleport_to_room_type(room_type: int) -> void:
477:## Ruft einen Pocket-Dimension-Teleport-Callable auf und schliesst das Pause-Menue.
```

### 💭 Thinking: *Confirmed that "Tresor" and "Boss" teleports…*

`21:41:46`

<details>
<summary>Thinking...</summary>

> Confirmed that "Tresor" and "Boss" teleports move the player within the same level layout rather than reloading the scene, so the tutorial UI would stay intact if present. Since the scene itself doesn't change, using these teleports during the tutorial stage seems harmless.
> 
> But "VFX, Sandbox, Hub, Items" are different — they're pocket dimensions created via `_admin_pocket()`, likely separate scenes or subscenes for testing. I want to check whether `_admin_pocket()` and the `teleport_player_in()` functions on VfxTestRoom, EnemySandboxRoom, HubRoom, and ItemTestRoom do a full scene change or just overlay a new room instance without reloading, similar to how the sandbox room is described as debug-only and reached via teleporter.
</details>

#### 👀 Read `pause_menu.gd`

`21:41:46`

*(lines 455–495)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd</code></summary>

```

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
```
</details>

### 💭 Thinking: *Confirmed that "Boss" and "Tresor" teleports…*

`21:41:55`

<details>
<summary>Thinking...</summary>

> Confirmed that "Boss" and "Tresor" teleports just move the player within the existing layout, with no scene reload or regeneration call, so my earlier fix adding teardown to those generation functions doesn't cover this case at all. Now I need to check what happens for the VFX/Sandbox/Hub/Items pocket dimension teleports instead.
</details>

#### 🔎 Grep `func teleport_player_in|change_scene|add_child|current_scene` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx_test_room.gd`

`21:41:55`

```
35:func teleport_player_in() -> void:
98:	get_tree().current_scene.add_child(_root)
132:			_root.add_child(vfx_instance)
136:			_root.add_child(holder)
138:			holder.add_child(vfx_instance)
146:		_root.add_child(label)
165:	_root.add_child(mesh)
170:	_root.add_child(body)
175:	body.add_child(col)
192:	_root.add_child(mesh)
197:	_root.add_child(body)
202:	body.add_child(col)
210:	_root.add_child(light)
221:	area.add_child(col)
232:	area.add_child(csg)
240:	area.add_child(label)
242:	_root.add_child(area)
```

### 💭 Thinking: *Confirmed there's no scene replacement happening…*

`21:42:27`

<details>
<summary>Thinking...</summary>

> Confirmed there's no scene replacement happening — it just adds a pocket dimension node under the current scene, so the tutorial UI living in the shared CanvasLayer stays untouched when teleporting anywhere. That means the real fix is to tear down the tutorial UI whenever any admin teleport fires while the tutorial is active.
> 
> The cleanest place to do this is in pause_menu.gd's teleport handlers, calling into LevelGenerator's teardown method. Since the codebase already reaches into LevelGenerator's underscore-prefixed "private" members directly from pause_menu.gd elsewhere, it's consistent to just call the existing teardown method directly rather than adding a new public wrapper.
> 
> I'll add the teardown call at the top of `_admin_teleport_to_room_type()`, since it's shared by both Boss and Tresor teleports, calling it unconditionally since it should be harmless when not in tutorial mode.
> 
> I should also add it to `_admin_pocket()` before the pocket teleport happens, and confirm `_admin_teleport_to_start()` is already covered since it routes through the shared function. Re-reading the user's request, they explicitly confirmed this should apply to all six destinations—vfx, sandbox, hub, item, boss, and tresor—whenever teleporting from tutorial via the admin panel, so the tutorial UI should disappear in every one of these cases.
> 
> The simplest fix is to find the single chokepoint that fires for all admin teleports rather than patching each button individually. Looking at the wiring, there are really two entry points: `_admin_move_player_to_room()` for the room-type path and `_admin_pocket()` for the pocket-dimension path, so I'll add the teardown call to both of those rather than every button handler.
> 
> I'm planning a small helper function, `_teardown_tutorial_ui_if_active()`, in pause_menu.gd that locates the level generator and tears down the tutorial UI if it's currently active.
> 
> Now for the second request: giving all enemy globally 30% more HP and 10% faster attack speed. The right place for this is the `EnemyDensity` autoload, since it already handles per-stage HP/damage scaling and both enemy systems (EnemyAI-based and CustomEnemyBase-based) presumably consult it, so adding a base multiplier there should apply uniformly across every enemy type.
> 
> I need to read enemy_density.gd to see exactly how scaling is structured before applying a 1.3x HP multiplier and figuring out how to represent "10% faster" attacks — likely by reducing attack interval/cooldown by roughly 1/1.1, or boosting an existing attack speed multiplier if one exists.
</details>

#### 💻 Bash: *Graphify orientation on enemy density/scaling system*

`21:42:27`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify query "enemy_density.gd HP damage scaling per stage global multiplier attack speed cooldown" --budget 3000 2>&1 | head -80
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Traversal: BFS depth=2 | Start: ['Die confused-Synergie steckt in StatusStun.damage_multiplier_against.', 'Speedrun ranking und gameplay verbesserungen', 'Gegner-Scaling und Raumgröße anpassen', 'parse_gd_cooldowns()', 'Damage over Time (2)', 'User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought'] | 205 nodes found



[!] TRUNCATED: showing 40 of 205 nodes (~3000-token budget). The answer may be among the 165 cut nodes — raise the token budget (CLI: --budget) or narrow the query (e.g. context_filter=['call'], or get_node for a specific symbol).



NODE Die confused-Synergie steckt in StatusStun.damage_multiplier_against. [src=04_Chat_Prompts/2026-08-12_slash-command-graphify-2.md loc=L6298 community=2026-08-12_slash-command-graphify-2.md]

NODE Speedrun ranking und gameplay verbesserungen [src=04_Chat_Prompts/2026-07-26_speedrun-ranking-und-gameplay-verbesserungen.md loc= community=Fighter]

NODE Gegner-Scaling und Raumgröße anpassen [src=04_Chat_Prompts/2026-07-25_gegner-scaling-und-raumgroesse-anpassen.md loc= community=Fighter]

NODE parse_gd_cooldowns() [src=generate_vault.py loc=L1283 community=generate_vault.py]

NODE Damage over Time (2) [src=01_Game_Design/Status_Effects/_MOC_Status_Effects.md loc=L7 community=MOC — Status-Effekte nach Klasse]

NODE User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L6 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE 2026-08-12_slash-command-graphify-2.md [src=04_Chat_Prompts/2026-08-12_slash-command-graphify-2.md loc=L1 community=2026-08-12_slash-command-graphify-2.md]

NODE generate_vault.py [src=generate_vault.py loc=L1 community=generate_vault.py]

NODE MOC — Status-Effekte nach Klasse [src=01_Game_Design/Status_Effects/_MOC_Status_Effects.md loc=L5 community=MOC — Status-Effekte nach Klasse]

NODE Fighter [src=04_Chat_Prompts/2026-07-23_heavy-enemies-nicht-pushbar-machen.md loc= community=Fighter]

NODE Colossus [src=04_Chat_Prompts/2026-07-23_log-datei-ueberpruefung.md loc= community=Fighter]

NODE parse_characters() [src=generate_vault.py loc=L1292 community=generate_vault.py]

NODE Stinger [src=04_Chat_Prompts/2026-07-24_character-spezifische-szenen-und-abilities.md loc= community=Fighter]

NODE 2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L39 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1005 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1013 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1017 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1024 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1028 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1036 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1040 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1055 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1066 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1075 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1081 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1093 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1101 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1109 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1113 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1177 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L118 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L126 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1272 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1287 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1299 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L130 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1310 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1318 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

NODE Assistant [src=04_Chat_Prompts/2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md loc=L1336 community=User Raw Claude Dangerously Skip Permissions Claude Dangerously Skip Permissions 1 Thought]

... (truncated — 165 more nodes cut by ~3000-token budget. Narrow with context_filter=['call'] or use get_node for a specific symbol)
```

### 💭 Thinking: *That query wasn't useful, just chat noise…*

`21:42:36`

<details>
<summary>Thinking...</summary>

> That query wasn't useful, just chat noise. I've satisfied the graphify orientation requirement and CLAUDE.md permits falling back to direct reads when queries don't surface enough context, so I'll just read enemy_density.gd directly now.
</details>

#### 👀 Read `enemy_density.gd`

`21:42:36`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_density.gd</code></summary>

```

extends Node

# ============================================================================
# EnemyDensity — Autoload: vervielfacht die Gegner-Spawnpunkte JEDES Raums.
# Muss unter Project Settings -> Autoload als "EnemyDensity" stehen.
# ============================================================================
#
# ############################################################################
# WARUM "MEHR GEGNER" NICHT UEBER DAS THREAT-BUDGET ALLEIN GEHT
# ############################################################################
# Es gab ZWEI Deckel gleichzeitig, und nur einer davon war das Budget:
#
#   1. BUDGET — level_generation_test.tscn ueberschreibt
#      combat_threat_budget = 16 und threat_hard_cap = 28. Die 64 im
#      Script von level_generator.gd sind dadurch komplett wirkungslos;
#      wer nur den Script-Default hochdreht, aendert gar nichts.
#
#   2. SPAWNPUNKTE — room_instance._roll_enemy_mix() kappt hart:
#
#          while budget > 0 and result.size() < enemy_spawn_points.size()
#
#      Die Anzahl der Marker3D unter "EnemySpawnPoints" in der Raum-Szene
#      IST damit die echte Obergrenze. Ein Raum mit 12 Markern spawnt nie
#      mehr als 12 Gegner — egal wie gross das Budget ist. Genau das war im
#      Log zu sehen: "Gegner entfernt - noch 11 aktiv" abwaerts, bei einem
#      Budget, das rechnerisch ein Vielfaches hergegeben haette.
#
# Deckel 1 wird in der Szene angehoben. Deckel 2 loest dieses Autoload.
#
# ############################################################################
# WARUM ALS AUTOLOAD STATT ALS AENDERUNG AN room_instance.gd
# ############################################################################
# Die Alternative waere, in 12 Raum-Szenen jeweils zwei Dutzend Marker von
# Hand zu setzen — und danach bei jedem neuen Raum wieder. Oder
# room_instance.gd (1800 Zeilen) umzubauen.
#
# Stattdessen wird hier von aussen die Liste ergaenzt, auf der die
# vorhandene Logik ohnehin schon arbeitet: fuer jeden bestehenden Marker
# entstehen extra_points_per_marker weitere, ringfoermig darum herum. Der
# Spawn-Code merkt keinen Unterschied — er sieht nur eine laengere Liste.
# Dasselbe Muster wie Loot, Treasure und RoomGuard.
#
# ############################################################################
# TIMING — WARUM DAS RECHTZEITIG PASSIERT
# ############################################################################
# LevelGenerator ruft prepare_enemies() direkt nach dem Instanziieren auf.
# Dort wird die Liste aber nur auf "ist sie leer?" geprueft; die eigentliche
# Auswahl (_roll_enemy_mix) und das Spawnen laufen erst, wenn der Spieler
# den Raum BETRITT. Unsere Marker muessen also lediglich vor dem Betreten
# des Raums stehen — ein deferred Aufruf plus eine Physik-Frame reicht mit
# grossem Abstand.
#
# ############################################################################
# DETERMINISMUS
# ############################################################################
# Kein RandomNumberGenerator: die Zusatzpunkte werden rein geometrisch aus
# Index und Winkel berechnet. Zwei Runs mit demselben Seed bekommen damit
# exakt dieselben Marker in exakt derselben Reihenfolge — sonst waeren die
# verifizierbaren Speedrun-Seeds (siehe det_rng.gd / run_record.gd) beim
# ersten Gegner hinfaellig.

## Wie viele ZUSAETZLICHE Punkte pro vorhandenem Marker entstehen.
## 2 = dreifache Gesamtzahl (Original + 2). Das ist die angeforderte
## "mindestens 3x mehr Gegner"-Vorgabe.
@export var extra_points_per_marker: int = 2

## Radius des ersten Rings um den Original-Marker. Jeder weitere Ring liegt
## um ring_step weiter aussen.
##
## 4.5 ist bewusst groesser als min_spawn_spacing des Stingers (3.0) und
## kleiner als das des Fighters (6.0): Stinger duerfen sich dicht draengen,
## Fighter verteilen sich ueber _take_spawn_point() dann automatisch auf
## weiter auseinanderliegende Punkte.
@export var ring_radius: float = 4.5
@export var ring_step: float = 3.0

## Wie weit ein Zusatzpunkt maximal vom Raumrand entfernt bleiben muss.
## Verhindert Marker in oder hinter der Wand.
@export var wall_margin: float = 3.0

## Aus dieser Hoehe UEBER dem Marker wird nach Boden gesucht.
##
## Nicht von der Raumdecke aus: dann trifft der Strahl zuerst die Decke.
## Das ist derselbe Fehler, der beim Sockel-Raycast in treasure_manager.gd
## schon einmal aufgetreten ist.
@export var ground_probe_up: float = 3.0
@export var ground_probe_down: float = 40.0

## Zusatzpunkte, die in einer Limonaden-Lache landen wuerden, werden
## verworfen. Ein Gegner, der beim Spawn sofort Schaden nimmt und
## wegrutscht, sieht nach Fehler aus, nicht nach Absicht.
@export var avoid_hazards: bool = true
@export var hazard_margin: float = 1.5

@export var debug_logging: bool = false

var _processed: Dictionary = {}


func _debug(msg: String) -> void:
	if debug_logging:
		print("[EnemyDensity] %s" % msg)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_debug("Autoload aktiv.")
	get_tree().node_added.connect(_on_node_added)
	_scan_existing.call_deferred()


func _scan_existing() -> void:
	var root: Node = get_tree().root
	if root == null:
		return
	_scan_recursive(root)


func _scan_recursive(node: Node) -> void:
	_on_node_added(node)
	for child: Node in node.get_children():
		_scan_recursive(child)


func _on_node_added(node: Node) -> void:
	if not (node is RoomInstance):
		return
	if _processed.has(node.get_instance_id()):
		return
	_densify_deferred.call_deferred(node as RoomInstance)


## Eine Physik-Frame warten: room_footprint, die Welt-Transform und die
## bereits am Boden ausgerichteten Original-Marker stehen erst danach.
func _densify_deferred(room: RoomInstance) -> void:
	if not is_instance_valid(room):
		return
	await get_tree().physics_frame
	if not is_instance_valid(room) or not room.is_inside_tree():
		return
	_densify(room)


func _densify(room: RoomInstance) -> void:
	var id: int = room.get_instance_id()
	if _processed.has(id):
		return
	_processed[id] = true
	room.tree_exited.connect(func() -> void: _processed.erase(id))

	if extra_points_per_marker <= 0:
		return

	var originals: Array[Marker3D] = room.enemy_spawn_points.duplicate()
	if originals.is_empty():
		_debug("Raum %s hat keine Spawnpunkte - uebersprungen." % room.grid_position)
		return

	var parent: Node = room.get_node_or_null("EnemySpawnPoints")
	if parent == null:
		parent = room

	var added: int = 0

	for marker_index: int in range(originals.size()):
		var source: Marker3D = originals[marker_index]
		if not is_instance_valid(source):
			continue

		for extra_index: int in range(extra_points_per_marker):
			var candidate: Vector3 = _ring_position(source.global_position, marker_index, extra_index)

			if not _is_inside_room(room, candidate):
				continue

			var grounded: Vector3 = _snap_to_ground(room, candidate)
			if grounded == Vector3.INF:
				continue

			if avoid_hazards and _is_in_hazard(grounded):
				continue

			var extra := Marker3D.new()
			extra.name = "EnemySpawnExtra_%d_%d" % [marker_index, extra_index]
			parent.add_child(extra)
			extra.global_position = grounded
			extra.global_rotation = Vector3(0.0, source.global_rotation.y, 0.0)

			room.enemy_spawn_points.append(extra)
			added += 1

	_debug("Raum %s: %d Original-Punkte + %d Zusatzpunkte = %d." % [
		room.grid_position, originals.size(), added, room.enemy_spawn_points.size()
	])


## Rein geometrisch, ohne Zufall — siehe Determinismus-Block im Dateikopf.
## Der Versatz aus marker_index sorgt dafuer, dass benachbarte Original-
## Marker ihre Ringe nicht deckungsgleich uebereinanderlegen.
func _ring_position(origin: Vector3, marker_index: int, extra_index: int) -> Vector3:
	var ring: int = extra_index / 3
	var slot: int = extra_index % 3
	var radius: float = ring_radius + float(ring) * ring_step
	var angle: float = TAU * (float(slot) / 3.0) + float(marker_index) * 0.7
	return origin + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)


## Liegt der Punkt noch mit Sicherheitsabstand innerhalb des Grundrisses?
## Gerechnet wird im LOKALEN Raumkoordinatensystem, weil room_footprint
## genau so definiert ist — global waere die Rechnung bei gedrehten oder
## skalierten Raeumen falsch.
func _is_inside_room(room: RoomInstance, world_pos: Vector3) -> bool:
	var local: Vector3 = room.to_local(world_pos)
	var half_x: float = room.room_footprint.x * 0.5 - wall_margin
	var half_z: float = room.room_footprint.y * 0.5 - wall_margin
	if half_x <= 0.0 or half_z <= 0.0:
		return false
	return absf(local.x) <= half_x and absf(local.z) <= half_z


## Setzt den Punkt auf den tatsaechlichen Boden. Ohne das haengen Marker in
## Raeumen mit Rampe oder abgesenktem Bodenstueck in der Luft, und die
## Gegner fallen beim Spawn durch die Geometrie — derselbe Fehler, den
## room_instance._snap_markers_to_ground() fuer die Original-Marker loest.
##
## Rueckgabe Vector3.INF = kein Boden gefunden, Punkt verwerfen.
func _snap_to_ground(room: RoomInstance, world_pos: Vector3) -> Vector3:
	var world: World3D = room.get_world_3d()
	if world == null:
		return world_pos

	var from: Vector3 = world_pos + Vector3(0.0, ground_probe_up, 0.0)
	var to: Vector3 = world_pos + Vector3(0.0, -ground_probe_down, 0.0)

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 1

	var hit: Dictionary = world.direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return Vector3.INF

	var point: Vector3 = hit["position"]
	point.y += 0.1
	return point


## Ueber die Gruppe "lava_hazards", in die sich jede LavaHazard-Instanz in
## ihrem _ready() eintraegt. Geprueft wird die XZ-Ausdehnung im lokalen
## System der Lache, damit gedrehte Pfuetzen korrekt behandelt werden.
func _is_in_hazard(world_pos: Vector3) -> bool:
	for node: Node in get_tree().get_nodes_in_group("lava_hazards"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var hazard: Node3D = node as Node3D
		var size: Variant = hazard.get("size")
		if not (size is Vector3):
			continue

		var local: Vector3 = hazard.to_local(world_pos)
		var half_x: float = (size as Vector3).x * 0.5 + hazard_margin
		var half_z: float = (size as Vector3).z * 0.5 + hazard_margin
		if absf(local.x) <= half_x and absf(local.z) <= half_z:
			return true
	return false

```
</details>

### 💭 Thinking: *Interesting — `enemy_density.gd` actually…*

`21:42:46`

<details>
<summary>Thinking...</summary>

> Interesting — `enemy_density.gd` actually handles spawn point density, not HP/damage scaling like CLAUDE.md's table claims. The documentation here is stale, so I need to trust the actual code over the written description.
> 
> So I should search for where real HP/damage/attack-speed scaling lives — grepping for "max_health" base values, per-enemy attack cooldown properties, and any global difficulty or hp_multiplier concept that might drive stage-based scaling.
</details>

#### 🔎 Grep `hp_multiplier|damage_multiplier|difficulty_scal|stage_multiplier|health_scale` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`21:42:46`

```
Found 8 files
scripts\characters\combat_giselle.gd
scripts\characters\combat_winter.gd
scripts\items\item_behaviours.gd
scripts\combat_base.gd
scripts\characters\combat_karina.gd
scripts\health.gd
scripts\core\player_stats.gd
scripts\status_effects\stun.gd
```

### 💭 Thinking: *I should check health.gd to see if there…*

`21:42:52`

<details>
<summary>Thinking...</summary>

> I should check health.gd to see if there's a global multiplier pattern, like base_health times a multiplier, applied to enemies.
</details>

#### 👀 Read `health.gd`

`21:42:52`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\health.gd</code></summary>

```
extends Node
class_name Health

# --- Signals: andere Nodes (UI, Sound, VFX) koennen darauf reagieren, ---
# --- ohne dass diese Komponente wissen muss, WER zuhoert. ---
signal health_changed(current: float, max: float)
signal died

## NEU: feuert NUR bei tatsaechlich angekommenem Schaden (nach Invuln- und
## Multiplikator-Filter). Items wie "Mamas Kochloeffel" oder ein
## Trefferfeedback-System haengen sich hier dran, statt health_changed
## abzuhoeren — das feuert auch beim Heilen und bei jedem Regen-Tick.
signal damage_taken(amount: float, source: Node3D)

## NEU: Start/Ende der Unverwundbarkeit, z.B. fuer ein Blink-VFX am Modell.
signal invulnerability_changed(active: bool)

@export var max_health: float = 100.0

## Ausfuehrliche Konsolenausgaben zu Damage-Kalkulation, Invuln-/Tod-Faellen
## und Heilung - wie ueberall sonst im Projekt per Instanz zuschaltbar statt
## global, damit z.B. nur der Spieler oder nur ein einzelner Gegnertyp im
## Sandbox-Test geloggt wird (siehe enemy_ai.gd/bomb.gd fuer dasselbe Muster).
@export var debug_logging: bool = false

# --- Regeneration ---
@export var regen_enabled: bool = true
@export var regen_rate: float = 5.0       # HP pro Sekunde, sobald Regen aktiv ist
@export var regen_delay: float = 3.0      # Sekunden Wartezeit nach dem letzten Treffer

# ============================================================================
# UNVERWUNDBARKEIT
# ============================================================================
# Wird ueber set_invulnerable(dauer) gesetzt und laeuft hier selbst ab. Das
# gehoert bewusst in die Health-Komponente und nicht in den Aufrufer: sonst
# muesste JEDE Schadensquelle (Hitbox, Lava, Bombe, Dash) den Zustand
# einzeln pruefen, und die erste vergessene Stelle macht den Effekt wertlos.
#
# _invuln_timer < 0.0 bedeutet "unbegrenzt" (z.B. waehrend einer Cutscene) —
# in dem Fall raeumt nur clear_invulnerable() wieder auf.
var _invuln_timer: float = 0.0
var _invuln_permanent: bool = false

## Globaler Multiplikator auf ANKOMMENDEN Schaden. 1.0 = normal,
## 0.25 = 75 % Reduktion (siehe Item "Saeurefeste Stiefel"). Wird von
## PlayerStats gesetzt, nicht von Hand.
var incoming_damage_multiplier: float = 1.0

var current_health: float
var _time_since_damage: float = 0.0

# Merkt sich, WER/WAS zuletzt Schaden verursacht hat — z.B. fuer
# richtungsabhaengige Todes-Animationen (faellt weg vom Angreifer).
var last_damage_source: Node3D = null


func _ready() -> void:
	current_health = max_health


func _process(delta: float) -> void:
	if _invuln_timer > 0.0:
		_invuln_timer -= delta
		if _invuln_timer <= 0.0:
			_invuln_timer = 0.0
			if not _invuln_permanent:
				invulnerability_changed.emit(false)

	if not regen_enabled or not is_alive():
		return

	_time_since_damage += delta

	if _time_since_damage >= regen_delay and current_health < max_health:
		heal(regen_rate * delta)


## Verlaengert eine laufende Unverwundbarkeit, statt sie zu ueberschreiben:
## zwei Effekte kurz hintereinander sollen sich nicht gegenseitig kuerzen.
func set_invulnerable(duration: float) -> void:
	var was_active: bool = is_invulnerable()
	_invuln_timer = maxf(_invuln_timer, duration)
	if not was_active:
		invulnerability_changed.emit(true)


func set_invulnerable_permanent(enabled: bool) -> void:
	var was_active: bool = is_invulnerable()
	_invuln_permanent = enabled
	if is_invulnerable() != was_active:
		invulnerability_changed.emit(is_invulnerable())


func clear_invulnerable() -> void:
	var was_active: bool = is_invulnerable()
	_invuln_timer = 0.0
	_invuln_permanent = false
	if was_active:
		invulnerability_changed.emit(false)


func is_invulnerable() -> bool:
	return _invuln_permanent or _invuln_timer > 0.0


func _debug(msg: String) -> void:
	if debug_logging:
		print("Health DEBUG [%s]: %s" % [get_parent().name if get_parent() else "?", msg])


func take_damage(amount: float, source: Node3D = null) -> void:
	var source_name: String = source.name if source else "?"

	if current_health <= 0.0:
		_debug("take_damage(%.1f von %s) ignoriert - bereits tot." % [amount, source_name])
		return  # bereits tot, ignoriere weitere Treffer

	if is_invulnerable():
		_debug("take_damage(%.1f von %s) ignoriert - unverwundbar (permanent=%s, timer=%.2f)." % [amount, source_name, _invuln_permanent, _invuln_timer])
		return

	var multiplier: float = maxf(incoming_damage_multiplier, 0.0)
	# Saeure legt die Ruestung bloss: waehrend "acid" aktiv ist, kommt JEDE
	# Schadensquelle mit +20% an (siehe StatusAcid.VULNERABILITY_MULTIPLIER).
	# get_parent() statt eines gespeicherten Owner-Felds, weil Health IMMER
	# als direktes Kind des Akteurs haengt (Spieler wie Gegner).
	var acid_active: bool = StatusAcid.active(get_parent())
	if acid_active:
		multiplier *= StatusAcid.VULNERABILITY_MULTIPLIER

	var effective: float = amount * multiplier
	_debug("Damage-Kalkulation - roh=%.1f, incoming_mult=%.2f, acid_vuln=%s, effektiv=%.1f, quelle=%s, hp_vorher=%.1f/%.1f" % [amount, incoming_damage_multiplier, acid_active, effective, source_name, current_health, max_health])
	if effective <= 0.0:
		_debug("Treffer ohne Wirkung (effektiver Schaden <= 0).")
		return

	current_health = max(current_health - effective, 0.0)
	_time_since_damage = 0.0  # Regen-Timer zuruecksetzen bei jedem Treffer
	last_damage_source = source
	_debug("hp_nachher=%.1f/%.1f (%.0f%%)" % [current_health, max_health, get_health_percent() * 100.0])
	health_changed.emit(current_health, max_health)
	damage_taken.emit(effective, source)

	if current_health <= 0.0:
		_debug("GESTORBEN durch %s." % source_name)
		died.emit()


func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_health = min(current_health + amount, max_health)
	_debug("heal(%.1f) -> hp=%.1f/%.1f" % [amount, current_health, max_health])
	health_changed.emit(current_health, max_health)


## Hebt die Obergrenze an und nimmt den Zuwachs optional gleich als Heilung
## mit. Ohne das zweite Argument steigt nur das Maximum — der Balken wird
## also laenger, aber nicht voller.
func set_max_health(value: float, heal_difference: bool = true) -> void:
	var new_max: float = maxf(value, 1.0)
	var difference: float = new_max - max_health
	max_health = new_max

	if heal_difference and difference > 0.0:
		current_health += difference

	current_health = clampf(current_health, 0.0, max_health)
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return current_health > 0.0


func get_health_percent() -> float:
	if max_health <= 0.0:
		return 0.0
	return clampf(current_health / max_health, 0.0, 1.0)

```
</details>

### 💭 Thinking: *I'm noting that Health.max_health is set…*

`21:43:25`

<details>
<summary>Thinking...</summary>

> I'm noting that Health.max_health is set per-component with no global HP multiplier for enemy, and incoming_damage_multiplier is specifically for the player's incoming damage (set by PlayerStats, likely for item reducing damage taken), not for scaling damage dealt.
> 
> Since there's no existing global scaling hook, I'm thinking the cleanest approach for "30% more HP, 10% faster attack speed" is to find each enemy's baseline stats and apply the multiplier directly. Values are set in multiple places: EnemyAI-driven enemy (Fighter/Stinger/Colossus) likely pull HP and attack cooldown from the es_*.tres EnemySpawnEntry resources, while the six CustomEnemyBase enemy (mortar_bot, acid_sprinkler, magnet_core, dive_bomber, shield_drone, plasma_beam_bot) set max_health and fire intervals as plain script variables in their _configure() methods. Since the user wants this applied globally without touching individual balance values directly, I need a strategy that scales all of these consistently.
> 
> Editing dozens of scattered numbers across resources and scripts would be error-prone and hard to maintain, especially for future enemy, so a shared multiplier applied at a common code path is better. For HP, the shared Health component used by both enemy and players is the natural hook, but since CLAUDE.md notes both share the same damage-taking interface, I'd need to gate any change by group membership (the "enemies" group) so the player's health isn't affected too.
> 
> I'm thinking a clean approach is checking in Health's ready function whether the parent belongs to the "enemies" group and multiplying max_health accordingly — a single control point that applies uniformly to every enemy type without touching individual balance values, satisfying the requirement that the buff applies to every enemy now and giving an easy single place to tune later.
> 
> Attack speed is trickier since there's no shared timer component analogous to Health — each enemy type has its own cooldown/interval logic (fire_interval, attack cooldowns in enemy_ai.gd for Fighter/Stinger/Colossus, plus separate fire_interval variables in CustomEnemyBase enemies). I want to check enemy_ai.gd's cooldown implementation to see if there's any shared mechanism I can hook into.
> 
> Since Fighter/Stinger/Colossus are configured through EnemySpawnEntry .tres resources and custom_enemy_base.gd doesn't have a generic naming convention for timing variables (fire_interval, TURN_SPEED, attack_cooldown all differ), there's no clean single hook point like with Health. The pragmatic path is to individually adjust each enemy's attack-interval field by roughly 0.9091 (10% faster) across each of the ~9 enemy types, touching scripts and possibly .tres resources where Fighter/Stinger/Colossus configs live.
> 
> I need to check enemy_ai.gd's attack state logic alongside the es_fighter/es_stinger/es_colossus .tres files, then go through mortar_bot.gd, acid_sprinkler.gd, dive_bomber.gd, shield_drone.gd, plasma_beam_bot.gd, and magnet_core.gd to find each one's attack timing variable. Given the scope, I'm considering using a background Explore agent to gather all these locations efficiently rather than checking each file one by one.
</details>

#### 🔎 Grep `cooldown|interval|attack_speed|ATTACK_COOLDOWN|Timer` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd`

`21:43:25`

```
39:@export var attack_cooldown: float = 1.0
51:# wird der Angriff sauber abgebrochen (Telegraph aus, kurzer Cooldown,
55:# Cooldown nach einem abgebrochenen Angriff — kurz, damit der Gegner sofort
58:@export var attack_abort_cooldown: float = 0.3
150:## Gleiche Drosselungs-Idee wie unstuck_check_interval oben.
151:@export var separation_update_interval: float = 0.15
179:var _focus_lost_timer: float = 0.0
183:# Cooldown, zurueck ins Verfolgen. Wird NICHT aufgerufen, wenn der Gegner
187:	_attack_timer = maxf(attack_abort_cooldown, 0.0)
264:@export var unstuck_check_interval: float = 0.4
266:var _unstuck_timer: float = 0.0
267:var _unstuck_check_timer: float = 0.0
269:var _unstuck_cooldown: float = 0.0
329:@export var nav_target_update_interval: float = 0.2
345:# Cooldown damit der Slide-Impuls nicht jeden Frame ueberschrieben wird
347:var _slide_cooldown: float = 0.0
349:# Siehe separation_update_interval oben - haelt den zuletzt berechneten
352:var _separation_timer: float = 0.0
378:var _stagger_reset_timer: Timer
384:	if _stagger_reset_timer:
385:		_stagger_reset_timer.start(STAGGER_WINDOW)
398:	if _stagger_reset_timer:
399:		_stagger_reset_timer.stop()
432:func apply_status_effect(id: String, duration: float, magnitude: float = 1.0, source: Node = null, tick_interval: float = 0.0) -> void:
433:	status_effects.apply_effect(id, duration, magnitude, source, tick_interval)
740:var _attack_timer: float = 0.0
760:var _nav_update_timer: float = 0.0
962:			_stagger_reset_timer = Timer.new()
963:			_stagger_reset_timer.one_shot = true
964:			_stagger_reset_timer.timeout.connect(_on_stagger_window_expired)
965:			add_child(_stagger_reset_timer)
1461:	_attack_timer = max(_attack_timer - delta, 0.0)
1462:	_slide_cooldown = max(_slide_cooldown - delta, 0.0)
1463:	_separation_timer = max(_separation_timer - delta, 0.0)
1481:	if _focus_lost_timer > 0.0:
1509:				elif _attack_timer <= 0.0 and not _is_attacking and _is_facing_player() and not is_attack_locked():
1553:# einen einmaligen Impuls weg — mit Cooldown, damit move_and_slide()
1559:	# Cooldown aktiv: Impuls wurde bereits gesetzt, abwarten.
1560:	if _slide_cooldown > 0.0:
1597:	_slide_cooldown = 0.4
1636:## Gedrosselter Zugriff - siehe separation_update_interval. Der Timer wird
1641:	if _separation_timer > 0.0:
1643:	_separation_timer = separation_update_interval
1669:## Laeuft in unstuck_check_interval-Schritten (nicht jeden Frame — ein
1677:	if _unstuck_cooldown > 0.0:
1678:		_unstuck_cooldown -= delta
1681:	_unstuck_check_timer -= delta
1682:	if _unstuck_check_timer > 0.0:
1684:	_unstuck_check_timer = maxf(unstuck_check_interval, 0.05)
1694:		and _focus_lost_timer <= 0.0
1698:		_unstuck_timer = 0.0
1704:		_unstuck_timer = 0.0
1707:	_unstuck_timer += unstuck_check_interval
1708:	if _unstuck_timer >= unstuck_stationary_time:
1755:	_unstuck_timer = 0.0
1757:	_unstuck_cooldown = 1.0
1787:		_nav_update_timer -= delta
1788:		if _nav_update_timer <= 0.0:
1789:			_nav_update_timer = max(nav_target_update_interval, 0.05)
1855:	if _focus_lost_timer > 0.0:
1856:		_focus_lost_timer = maxf(_focus_lost_timer - delta, 0.0)
1873:	_focus_lost_timer = randf_range(focus_loss_duration_min, maxf(focus_loss_duration_max, focus_loss_duration_min))
1877:	_debug("Fokus verloren fuer %.2fs." % _focus_lost_timer)
2072:	# trifft. Der Offset wird deshalb nur alle CONFUSED_REROLL_INTERVAL
2076:		_confused_timer -= delta
2077:		if _confused_timer <= 0.0:
2078:			_confused_timer = CONFUSED_REROLL_INTERVAL
2086:		_confused_timer = 0.0
2093:const CONFUSED_REROLL_INTERVAL: float = 0.5
2095:var _confused_timer: float = 0.0
2105:	_attack_timer = attack_cooldown
2109:		await get_tree().create_timer(pre_attack_delay).timeout
2133:		await get_tree().create_timer(attack_windup_time).timeout
2169:		await get_tree().create_timer(maxf(attack_strike_time, 0.05)).timeout
2174:		await get_tree().create_timer(0.2).timeout
2180:		await get_tree().create_timer(maxf(attack_strike_time, 0.05)).timeout
```

### 💭 Thinking: *I found the attack_cooldown export var in…*

`21:43:36`

<details>
<summary>Thinking...</summary>

> I found the attack_cooldown export var in enemy_ai.gd, which serves as the shared attack-speed default for the EnemyAI family. Now I want to check whether each enemy type overrides this via .tres spawn resources or through separate scene instances with different exported values.
</details>

#### 🔎 Grep `attack_cooldown|max_health` in `C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies`

`21:43:36`

```
No matches found
```

### 💭 Thinking: *Those .tres files likely define spawn threat…*

`21:43:45`

<details>
<summary>Thinking...</summary>

> Those .tres files likely define spawn threat cost rather than actual combat stats, so the real per-enemy values like attack_cooldown and max_health must live in the enemy scene files themselves or be set per enemy_type in enemy_ai.gd. I should check enemy_ai.gd for an EnemyType enum and how it configures each type.
</details>

#### 🔎 Grep `enemy_type|EnemyType|match enemy_type|FIGHTER|STINGER|COLOSSUS` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd`

`21:43:45`

```
No matches found
```

### 💭 Thinking: *No enum-based branching confirms the per…*

`21:43:52`

<details>
<summary>Thinking...</summary>

> No enum-based branching confirms the per-type stat differences live in the scene files themselves—fighter.tscn, stinger.tscn, colossus.tscn—as exported property overrides on the EnemyAI script and the Health node's max_health. I should go find those scenes.
</details>

#### 📂 Glob `scenes/enemies/*.tscn`

`21:43:52`

```
scenes\enemies\acid_sprinkler.tscn
scenes\enemies\dive_bomber.tscn
scenes\enemies\magnet_core.tscn
scenes\enemies\mortar_bot.tscn
scenes\enemies\plasma_beam_bot.tscn
scenes\enemies\shield_drone.tscn
scenes\enemies\dummy.tscn
```

### 💭 Thinking: *I notice there's no fighter.tscn, stinger…*

`21:44:03`

<details>
<summary>Thinking...</summary>

> I notice there's no fighter.tscn, stinger.tscn, or colossus.tscn in the enemy folder—only the six CustomEnemyBase enemy plus dummy.tscn have scene files. This lines up with CLAUDE.md mentioning these use an imported robot mesh, so they're likely instantiated purely through GDScript rather than a dedicated scene file.
> 
> Actually, tracing through tutorial_content.gd, I see the "Fighter" factory just preloads dummy.tscn as a placeholder stand-in, and similarly Stinger uses a scout dummy scene—so these tutorial references aren't the real enemy at all, just dummy substitutes for teaching purposes. That's a tangent though, not relevant to the HP/attack-speed scaling work. The actual Fighter/Stinger/Colossus enemy must spawn through the level generator's threat-budget system via enemy_table entries, so I should search the project for those scene paths directly.
</details>

#### 📂 Glob `**/*fighter*.tscn`

`21:44:03`

```
No files found
```

### 💭 Thinking: *There's no dedicated fighter.tscn anywhere…*

`21:44:12`

<details>
<summary>Thinking...</summary>

> There's no dedicated fighter.tscn anywhere, so Fighter/Stinger/Colossus are likely built from one shared scene using enemy_ai.gd, differentiated through exported property overrides set via EnemySpawnEntry resources referenced in the level generator's tables. I should broaden my search in case a single EnemyAI-based scene exists under a different filename.
</details>

#### 🔎 Grep `enemy_ai.gd` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`21:44:12`

Glob: `**/*.tscn`

```
Found 3 files
scenes\tank_dummy.tscn
scenes\scout_dummy.tscn
scenes\enemies\dummy.tscn
```

### 💭 Thinking: *I suspect dummy.tscn, scout_dummy.tscn, and…*

`21:44:21`

<details>
<summary>Thinking...</summary>

> I suspect dummy.tscn, scout_dummy.tscn, and tank_dummy.tscn are actually the real Fighter/Stinger/Colossus enemy prefabs, just kept under legacy placeholder names from early development. I want to open these files to verify their structure matches the EnemyAI family described in CLAUDE.md.
</details>

#### 👀 Read `dummy.tscn`

`21:44:21`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\enemies\dummy.tscn</code></summary>

```

[gd_scene format=3 uid="uid://dt3tk05ggmgk0"]

[ext_resource type="Shader" uid="uid://bl0t62j8xq1d4" path="res://shaders/psx.gdshader" id="1_k5f3b"]
[ext_resource type="Script" uid="uid://bqsncuqrnam0r" path="res://scripts/enemies/enemy_ai.gd" id="1_w4gkx"]
[ext_resource type="Script" uid="uid://cl5g4gx25yqm" path="res://scripts/health.gd" id="2_k5f3b"]
[ext_resource type="Script" uid="uid://v72lkilmlqmb" path="res://scripts/primary_hitbox.gd" id="4_fva3d"]
[ext_resource type="PackedScene" uid="uid://jlssmdypv6ce" path="res://scenes/ui/damage_number.tscn" id="5_dmgnum"]
[ext_resource type="PackedScene" uid="uid://h3hsb6rg5w2j" path="res://KayKit_Skeletons_1.1_FREE/characters/gltf/Skeleton_Warrior.glb" id="6_robot"]

[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_6igkw"]
radius = 1.5
height = 6.0

[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_sl5qy"]
radius = 1.65
height = 6.53

[sub_resource type="ShaderMaterial" id="ShaderMaterial_4eyt2"]
render_priority = 0
shader = ExtResource("1_k5f3b")
shader_parameter/albedo_color = Color(0.7316159, 0, 0.20945221, 1)
shader_parameter/snap_resolution = 24.102
shader_parameter/vertex_jitter_strength = 0.729
shader_parameter/alpha_multiplier = 1.0
shader_parameter/flash_color = Color(1, 0, 0, 1)
shader_parameter/flash_strength = 0.0

[sub_resource type="CapsuleMesh" id="CapsuleMesh_sl5qy"]
material = SubResource("ShaderMaterial_4eyt2")
radius = 0.815
height = 5.0261035

[sub_resource type="ShaderMaterial" id="ShaderMaterial_w4gkx"]
render_priority = 0
shader = ExtResource("1_k5f3b")
shader_parameter/albedo_color = Color(1, 0, 0, 1)
shader_parameter/snap_resolution = 32.0
shader_parameter/vertex_jitter_strength = 0.5
shader_parameter/alpha_multiplier = 1.0
shader_parameter/flash_color = Color(1, 0, 0, 1)
shader_parameter/flash_strength = 0.0

[sub_resource type="TorusMesh" id="TorusMesh_6igkw"]
material = SubResource("ShaderMaterial_w4gkx")
inner_radius = 5.9
outer_radius = 6.0

[sub_resource type="ShaderMaterial" id="ShaderMaterial_v72lb"]
render_priority = 0
shader = ExtResource("1_k5f3b")
shader_parameter/albedo_color = Color(1, 0.15686275, 0.1254902, 1)
shader_parameter/snap_resolution = 32.0
shader_parameter/vertex_jitter_strength = 0.5
shader_parameter/alpha_multiplier = 1.0
shader_parameter/flash_color = Color(1, 0, 0, 1)
shader_parameter/flash_strength = 0.0

[sub_resource type="CylinderMesh" id="CylinderMesh_fva3d"]
material = SubResource("ShaderMaterial_v72lb")
top_radius = 6.0
bottom_radius = 6.0
height = 0.001

[node name="Dummy" type="CharacterBody3D" unique_id=786565251]
collision_layer = 4
floor_snap_length = 0.4
# War versehentlich 3,3,3 (volle Rueckmeldungs-Vorgabe "3x groesser") - bei
# 6 Units Rohhoehe waeren das 18 Units, hoeher als die Decke eines normalen
# 14 Units hohen Kampfraums (siehe rd_combat_*.tres). 1.85 laesst den Fighter
# spuerbar groesser wirken (6 -> 11.1 Units) und behaelt trotzdem ~2.9 Units
# Deckenabstand.
scale = Vector3(1.85, 1.85, 1.85)
script = ExtResource("1_w4gkx")
model_yaw_offset_deg = 0.0
model_auto_ground = true
move_speed = 8.0
detection_range = 90.0
attack_cooldown = 1.8
attack_windup_time = 0.8
pre_attack_delay = 0.5
display_name = "Fighter"
is_heavy = true
reticle_height_offset = 7.0
reticle_forward_offset = 2.5
reticle_scale = 1.2
camera_lock_multiplier = 0.7
separation_radius = 5.0
separation_strength = 4.0
min_alpha_at_zero_hp = 0.2
hit_flash_duration = 0.3
hit_color_flash_strength = 0.8
hit_color_flash_duration = 0.5
telegraph_ground_clearance = 0.05
telegraph_ground_raycast_range = 25.0
jump_height = 2.6
obstacle_check_distance = 2.2
obstacle_check_low_height = 0.4
ledge_check_forward_distance = 2.0
ledge_check_drop_distance = 4.0
can_jump_across_ledges = true
jump_across_max_gap = 5.0
ledge_check_radius_margin = 0.8
movement_acceleration = 26.0
max_safe_drop_height = 5.0
ledge_drop_probe_distance = 18.0
ledge_drop_player_below_margin = 1.2
player_head_slide_impulse = 14.0
player_head_slide_min_height_above_player = 0.4
knockback_friction = 12.0
model_tint = Color(0.5, 0.425, 0.39, 1)

[node name="CollisionShape3D" type="CollisionShape3D" parent="." unique_id=623834254]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3, 0)
shape = SubResource("CapsuleShape3D_6igkw")

[node name="CharacterModel" parent="." unique_id=2020016892 instance=ExtResource("6_robot")]
transform = Transform3D(2.4, 0, 0, 0, 2.4, 0, 0, 0, 2.4, 0, 0, 0)

[node name="Health" type="Node" parent="." unique_id=496713544]
script = ExtResource("2_k5f3b")
regen_enabled = false

[node name="AttackHitbox" type="Area3D" parent="." unique_id=1434330377]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 8.216951)
collision_layer = 0
script = ExtResource("4_fva3d")
damage = 30.0
knockback_force = 5.0
damage_number_scene = ExtResource("5_dmgnum")

[node name="CollisionShape3D" type="CollisionShape3D" parent="AttackHitbox" unique_id=556284364]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.6, -4.4091864)
shape = SubResource("CapsuleShape3D_sl5qy")

[node name="Visual" type="MeshInstance3D" parent="AttackHitbox" unique_id=1173160389]
transform = Transform3D(1.8915654, 0, 0, 0, 1, 0, 0, 0, 2.3874803, 0, 2.4, -4.004089)
mesh = SubResource("CapsuleMesh_sl5qy")

[node name="TelegraphOuterRing" type="MeshInstance3D" parent="AttackHitbox" unique_id=1368129936]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, -8.249018)
mesh = SubResource("TorusMesh_6igkw")

[node name="TelegraphInner" type="MeshInstance3D" parent="AttackHitbox" unique_id=1874015288]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.05, -8.234204)
mesh = SubResource("CylinderMesh_fva3d")

[node name="NavigationAgent3D" type="NavigationAgent3D" parent="." unique_id=1336547930]
path_desired_distance = 1.5
target_desired_distance = 3.0
path_height_offset = 0.3
height = 11.1
radius = 2.775



```
</details>

### 💭 Thinking: *So dummy.tscn is actually the Fighter enemy…*

`21:44:32`

<details>
<summary>Thinking...</summary>

> So dummy.tscn is actually the Fighter enemy despite its legacy file name, and since it has no max_health override, it inherits the 100.0 default from health.gd's script. The attack_cooldown of 1.8 is set directly in the scene though.
> 
> Since Fighter relies on the shared default rather than an explicit override, I should check whether scout_dummy.tscn (Stinger) and tank_dummy.tscn (Colossus) do the same or set their own values.
</details>

#### 🔎 Grep `max_health|attack_cooldown|display_name` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\scout_dummy.tscn`

`21:44:32`

```
77:attack_cooldown = 1.4
80:display_name = "Stinger"
107:max_health = 25.0
```

```
82:attack_cooldown = 1.5
86:display_name = "Colossus"
148:max_health = 400.0
```

### 💭 Thinking: *Now I have the concrete stats: Fighter has…*

`21:44:59`

<details>
<summary>Thinking...</summary>

> Now I have the concrete stats: Fighter has 100 health and 1.8s attack cooldown, Stinger has 25 health and 1.4s cooldown, Colossus has 400 health and 1.5s cooldown. Next I need to check the six CustomEnemyBase enemy for their equivalent values.
> 
> Mortar Bot has 90 health and a 3.6s fire interval, Acid Sprinkler has 70 health and a 2.6s fire interval — I still need to check Dive Bomber, Shield Drone, Plasma Beam Bot, and Magnet Core.
> 
> I'm realizing there's a complication: Fighter doesn't override max_health in its scene, so it inherits the default of 100 from Health.gd. If I change that default, it could affect every Health node that doesn't override it — including the player's own Health component. I need to check whether the player relies on that same default before making any changes.
> 
> Touching the shared script default is too risky since it could leak into the player's health. Instead, I should set Fighter's dummy scene to explicitly override max_health to 130 (a 1.3x scale), leaving the shared default untouched.
> 
> Given the codebase lacks one central hook point, the safest and most future-proof approach is to apply the multiplier at runtime based on group membership — in Health._ready(), checking if the parent is in the "enemies" group and scaling max_health by 1.3 before setting current_health. Since all enemy already join that group per CLAUDE.md, this cleanly scopes the boost to enemy only, including future ones, without touching the player.
> 
> For attack speed, there's no single shared timer component, but EnemyAI-based enemy (Fighter, Stinger, Colossus) share one script with an attack_cooldown export, so scaling it by 1/1.1 once in enemy_ai.gd's _ready() covers all three uniformly and any future EnemyAI-based enemy too — just one line change rather than editing each scene.
> 
> Now I need to check whether the six CustomEnemyBase enemy have an equivalent shared lifecycle method where I could apply a similar generic scaling to their fire intervals, or whether each one declares its own independent fire_interval property.
</details>

#### 🔎 Grep `var fire_interval|var attack_interval|var shoot_interval|var beam_interval|func _configure|max_health =` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies`

`21:44:59`

Glob: `{dive_bomber,shield_drone,plasma_beam_bot,magnet_core}.gd`

```
scripts\enemies\shield_drone.gd:47:func _configure() -> void:
scripts\enemies\shield_drone.gd:49:	max_health = 45.0
scripts\enemies\plasma_beam_bot.gd:46:func _configure() -> void:
scripts\enemies\plasma_beam_bot.gd:48:	max_health = 65.0
scripts\enemies\dive_bomber.gd:68:func _configure() -> void:
scripts\enemies\dive_bomber.gd:70:	max_health = 55.0
scripts\enemies\magnet_core.gd:44:func _configure() -> void:
scripts\enemies\magnet_core.gd:46:	max_health = 160.0
```

### 💭 Thinking: *I'm checking whether max_health is declared…*

`21:45:11`

<details>
<summary>Thinking...</summary>

> I'm checking whether max_health is declared as a shared base field in custom_enemy_base.gd, and confirming where _build_health() uses it to construct the Health node—this would give a clean single hook point for the whole CustomEnemyBase family, alongside the group-based Health._ready() approach.
> 
> Actually, the group-based Health._ready() approach already covers HP uniformly for both EnemyAI and CustomEnemyBase families since Health.gd is the shared component regardless of which system constructs it, so I don't need to touch max_health individually at all.
> 
> For attack speed though, there's no common field across both systems—EnemyAI uses attack_cooldown while CustomEnemyBase enemy use fire_interval, but I've only confirmed that for mortar_bot and acid_sprinkler. I need to check dive_bomber, shield_drone, plasma_beam_bot, and magnet_core to see if they use the same naming or something different like a continuous beam mechanic.
</details>

#### 🔎 Grep `var fire_interval|var .*interval|var .*cooldown|var .*_rate` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\dive_bomber.gd`

`21:45:11`

```
31:var dash_interval: float = 3.4
```

#### 🔎 Grep `var .*interval|var .*cooldown|var .*_rate|var .*_time"` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\shield_drone.gd`

`21:45:15`

```
No matches found
```

### 💭 Thinking: *I don't see a timing variable in shield_drone…*

`21:45:22`

<details>
<summary>Thinking...</summary>

> I don't see a timing variable in shield_drone.gd, so I should read through the full file to understand its attack mechanic, since CLAUDE.md mentions turret/flyer archetypes.
</details>

#### 👀 Read `shield_drone.gd`

`21:45:22`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\shield_drone.gd</code></summary>

```
extends CustomEnemyBase
class_name ShieldDrone

# ============================================================================
# Schild-Drohne — fliegender Support-Gegner.
# ============================================================================
# Greift den Spieler nie direkt an. Schwebt ueber dem Schlachtfeld und
# verbindet sich per Strahl mit bis zu MAX_SHIELDED anderen Gegnern aus der
# Gruppe "enemies" (nicht sich selbst). Jeder Verbundene bekommt den
# "shield"-Status-Effekt (siehe scripts/status_effects/shield.gd): +25 %
# Maximal-HP, ein etwas groesseres Modell und eine blau schwankende Aura -
# die eigentliche Wirkung sitzt in custom_enemy_base.gd/enemy_ai.gd
# (_apply_shield_visual/_remove_shield_visual), je nachdem was fuer ein
# Gegnertyp verbunden ist.
#
# Fliegt ausserhalb der Nahkampf-Reichweite und muss fuer einen Raum-Clear
# NICHT getoetet werden (siehe _despawn_if_room_clear() unten) - sie ist
# reiner Support, kein Ziel im eigentlichen Sinn. Wird der Raum trotzdem
# leergeraeumt (alle "echten" Gegner tot), verschwindet sie von selbst.

## War 1.5 - Rueckmeldung "jeder Gegner ausser Magnet soll 3x groesser sein"
## (1.5 * 3 = 4.5).
const VISUAL_SCALE: float = 4.5
const MAX_SHIELDED: int = 3
const RESCAN_INTERVAL: float = 1.0
const SHIELD_REFRESH_INTERVAL: float = 0.5
## Deutlich laenger als SHIELD_REFRESH_INTERVAL: faellt die Drohne kurz aus
## der Reichweite oder haengt ein Frame, soll der Schild NICHT sofort
## abreissen - siehe shield.gd fuer das Refresh-Prinzip.
const SHIELD_DURATION: float = 1.4
const CLEAR_CHECK_INTERVAL: float = 1.0

var hover_height: float = 9.0
var hover_radius: float = 3.0
var hover_speed: float = 0.5
var link_range: float = 22.0

var _anchor: Vector3 = Vector3.ZERO
var _angle: float = 0.0
var _rescan_timer: float = 0.0
var _shield_tick_timer: float = 0.0
var _clear_check_timer: float = 0.0
var _allies: Array[Node3D] = []
var _beams: Dictionary = {}  # instance_id (int) -> Dictionary (siehe _create_beam_visual)


func _configure() -> void:
	display_name = "Schild-Drohne"
	max_health = 45.0


func _build() -> void:
	_build_visual()
	visual_root.scale = Vector3.ONE * VISUAL_SCALE
	_add_box_collision(Vector3(1.2, 1.0, 1.2) * VISUAL_SCALE)
	_angle = randf() * TAU


func _build_visual() -> void:
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.9
	disc_mesh.bottom_radius = 0.9
	disc_mesh.height = 0.25
	var disc := MeshInstance3D.new()
	disc.mesh = disc_mesh
	disc.material_override = _make_unshaded_material(Color(0.3, 0.85, 1.0), 1.4)
	visual_root.add_child(disc)

	var light := OmniLight3D.new()
	light.light_color = Color(0.3, 0.85, 1.0)
	light.light_energy = 1.0
	light.omni_range = 5.0
	light.shadow_enabled = false
	visual_root.add_child(light)


func _physics_process(delta: float) -> void:
	# Anker erst HIER (nicht in _build()) einlesen: die aufrufende Stelle
	# (enemy_sandbox_room.gd) setzt global_transform ERST NACH add_child(),
	# also nach _ready()/_build() - zu dem Zeitpunkt stuende hier noch (0,0,0).
	if _anchor == Vector3.ZERO:
		_anchor = global_position

	_angle += hover_speed * delta
	var offset := Vector3(cos(_angle), sin(_angle * 1.7) * 0.3, sin(_angle)) * hover_radius
	global_position = _anchor + Vector3.UP * hover_height + offset

	_rescan_timer -= delta
	if _rescan_timer <= 0.0:
		_rescan_timer = RESCAN_INTERVAL
		_rescan_allies()

	_update_beams(delta)

	_shield_tick_timer -= delta
	if _shield_tick_timer <= 0.0:
		_shield_tick_timer = SHIELD_REFRESH_INTERVAL
		_refresh_shields()

	_clear_check_timer -= delta
	if _clear_check_timer <= 0.0:
		_clear_check_timer = CLEAR_CHECK_INTERVAL
		_despawn_if_room_clear()


func _rescan_allies() -> void:
	# Bereits verbundene, noch gueltige Allies zuerst behalten - sonst
	# springt der Strahl bei jedem Rescan auf ein neues Ziel, nur weil kurz
	# ein naeher liegender Gegner vorbeigelaufen ist.
	var kept: Array[Node3D] = []
	for ally: Node3D in _allies:
		if is_instance_valid(ally) and _is_valid_ally(ally) and global_position.distance_to(ally.global_position) <= link_range:
			kept.append(ally)

	if kept.size() < MAX_SHIELDED:
		var candidates: Array[Node3D] = []
		for node: Node in get_tree().get_nodes_in_group("enemies"):
			if not (node is Node3D) or node in kept or not _is_valid_ally(node as Node3D):
				continue
			var dist: float = global_position.distance_to((node as Node3D).global_position)
			if dist <= link_range:
				candidates.append(node as Node3D)
		candidates.sort_custom(func(a: Node3D, b: Node3D) -> bool:
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		for c: Node3D in candidates:
			if kept.size() >= MAX_SHIELDED:
				break
			kept.append(c)

	_allies = kept
	_sync_beams()


func _is_valid_ally(node: Node3D) -> bool:
	if node == self or not is_instance_valid(node):
		return false
	var candidate_health := node.find_child("Health", true, false) as Health
	return candidate_health != null and candidate_health.is_alive()


func _sync_beams() -> void:
	var wanted_ids: Dictionary = {}
	for ally: Node3D in _allies:
		wanted_ids[ally.get_instance_id()] = true

	for id: int in _beams.keys().duplicate():
		if not wanted_ids.has(id):
			_free_beam_visual(_beams[id])
			_beams.erase(id)

	for ally: Node3D in _allies:
		var id: int = ally.get_instance_id()
		if not _beams.has(id):
			_beams[id] = _create_beam_visual(Color(0.3, 0.85, 1.0))


func _update_beams(delta: float) -> void:
	for ally: Node3D in _allies:
		if not is_instance_valid(ally):
			continue
		var id: int = ally.get_instance_id()
		if not _beams.has(id):
			continue
		_update_beam_visual(_beams[id], global_position, ally.global_position + Vector3.UP, delta)


func _refresh_shields() -> void:
	for ally: Node3D in _allies:
		if not is_instance_valid(ally):
			continue
		StatusShield.apply(ally, SHIELD_DURATION, self)


## Support-Flieger muessen fuer den Raum-Clear nicht sterben (siehe
## Kopfkommentar) - sobald ausser fliegenden Support-Typen (sich selbst
## eingeschlossen) niemand mehr im EIGENEN Raum lebt (siehe
## _room_scoped_enemies() in custom_enemy_base.gd), verschwindet die Drohne
## von selbst.
func _despawn_if_room_clear() -> void:
	for node: Node in _room_scoped_enemies():
		if not is_instance_valid(node):
			continue
		if node == self or not (node is Node3D):
			continue
		if node is ShieldDrone or node is PlasmaBeamBot:
			continue
		return
	despawn()


func _cleanup_effects() -> void:
	for beam: Dictionary in _beams.values():
		_free_beam_visual(beam)
	_beams.clear()

```
</details>

### 💭 Thinking: *ShieldDrone has no attack at all, it's purely…*

`21:45:59`

<details>
<summary>Thinking...</summary>

> ShieldDrone has no attack at all, it's purely a support unit that buffs allies, so attack speed doesn't apply to it. This confirms there's no single generic attack-cadence field shared across enemy types — each one's timing concept is bespoke, which means a blanket "scale every attack timer by 1/1.1" approach can't be cleanly automated through one shared property.
> 
> So the pragmatic path is: handle HP generically through the shared Health script with an enemies-group check, since that's a single universal change. For attack speed, I need to go enemy-by-enemy, identifying each type's actual cadence value (cooldowns, dash frequency, etc.) and scaling it down by roughly 0.909, covering the nine enemy types that actually attack while excluding ShieldDrone and checking whether MagnetCore's ability even counts as a discrete attack.
> 
> I'm working out the scaled cooldown values for Fighter, Stinger, Colossus, MortarBot, AcidSprinkler, and DiveBomber, then still need to check PlasmaBeamBot and MagnetCore's timing mechanics before deciding how to apply the changes across the scene and script files.
> 
> Actually, editing three separate .tscn files by hand for attack_cooldown is risky given the earlier comment mistake, so it's much cleaner to apply the 1.1x speed multiplier programmatically in enemy_ai.gd's _ready() function instead — dividing attack_cooldown by 1.1 there automatically scales Fighter, Stinger, and Colossus uniformly with a single safe code edit rather than three fragile scene edits.
> 
> For the CustomEnemyBase family though, each subclass uses its own differently-named timing variable with no shared field in the base class, so I'm considering using GDScript's dynamic property check (`"fire_interval" in self`) to conditionally adjust whichever interval variable each subclass actually has.  But since different enemy like plasma_beam_bot or magnet_core might use entirely different property names, and this codebase clearly favors explicit, well-commented code over clever generic mechanisms, I'm leaning toward a safer, more idiomatic approach instead.
> 
> For the CustomEnemyBase family, I'll explicitly multiply each subclass's own timing variable directly within its own `_configure()`, mirroring how `max_health` is already set there—individual, clearly-commented edits across the roughly five relevant files (mortar_bot, acid_sprinkler, dive_bomber, plasma_beam_bot, magnet_core), skipping shield_drone since it has no attack.
> 
> For the EnemyAI family (Fighter/Stinger/Colossus), I'll apply the multiplier once in the shared `enemy_ai.gd` code rather than editing three separate scene files, since that single choke point covers all current and future EnemyAI-based enemies.
> 
> Reconsidering consistency: since Health.gd is truly shared across every enemy, that's the right place for the HP scaling, while EnemyAI's shared script is the right place to scale attack_cooldown in `_ready()`. For CustomEnemyBase, per-file edits remain the safest approach since each enemy uses different field names for its attack timing, so next I want to check plasma_beam_bot.gd and magnet_core.gd to find their actual attack cadence variables.
</details>

#### 👀 Read `plasma_beam_bot.gd`

`21:45:59`

*(lines 1–61)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\plasma_beam_bot.gd</code></summary>

```
extends CustomEnemyBase
class_name PlasmaBeamBot

# ============================================================================
# Plasmastrahl-Bot — fliegender Gegner.
# ============================================================================
# Fliegt langsam ueber dem Schlachtfeld (ueber Bodenhindernissen hinweg),
# laedt sichtbar auf und zieht danach einen durchgehenden Laser ueber den
# Boden: eine gerade Linie, die waehrend BEAM_DURATION von einem Start- zu
# einem Endpunkt "wandert" und dabei genau die Stelle kreuzt, an der der
# Spieler beim Feuern stand - wer nicht seitlich ausweicht, steht laenger
# im Feuer und sammelt burn-Ticks.

## War 1.5 - Rueckmeldung "jeder Gegner ausser Magnet soll 3x groesser sein"
## (1.5 * 3 = 4.5).
const VISUAL_SCALE: float = 4.5
const BURN_TICK_INTERVAL: float = 0.4
const BURN_DAMAGE_PER_TICK: float = 5.0
const BURN_DURATION: float = 2.5
const CLEAR_CHECK_INTERVAL: float = 1.0
const BEAM_COLOR: Color = Color(0.9, 0.2, 1.0)

var hover_height: float = 8.0
var drift_speed: float = 2.0
var charge_time: float = 1.1
var beam_duration: float = 1.4
var beam_width: float = 2.0
var sweep_length: float = 14.0
var cooldown_time: float = 3.2
var detect_range: float = 40.0

enum State { DRIFT, CHARGE, FIRE, COOLDOWN }

var _state: State = State.DRIFT
var _timer: float = 0.0
var _clear_check_timer: float = 0.0
var _charge_light: OmniLight3D = null
var _ground_beam: Dictionary = {}
var _vertical_beam: Dictionary = {}
var _beam_start: Vector3 = Vector3.ZERO
var _beam_end: Vector3 = Vector3.ZERO
var _beam_elapsed: float = 0.0
var _beam_tick_timer: float = 0.0


func _configure() -> void:
	display_name = "Plasmastrahl-Bot"
	max_health = 65.0


func _build() -> void:
	_build_visual()
	visual_root.scale = Vector3.ONE * VISUAL_SCALE
	_add_box_collision(Vector3(1.4, 1.2, 1.4) * VISUAL_SCALE)
	_timer = cooldown_time * randf_range(0.3, 0.8)


func _build_visual() -> void:
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.3, 0.5, 1.3)
```
</details>

### 💭 Thinking: *PlasmaBeamBot's cooldown_time of 3.2 seconds…*

`21:46:06`

<details>
<summary>Thinking...</summary>

> PlasmaBeamBot's cooldown_time of 3.2 seconds between its DRIFT and CHARGE cycles tells me how often it fires, essentially its attack speed. Next I'm moving on to look at magnet_core.gd.
</details>

#### 👀 Read `magnet_core.gd`

`21:46:06`

*(lines 1–61)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\magnet_core.gd</code></summary>

```
extends CustomEnemyBase
class_name MagnetCore

# ============================================================================
# Magnet-Kern — stationaerer Gegner. Schiesst nicht, zieht stattdessen den
# Spieler und freiliegende Drops kontinuierlich zu sich heran. Kommt der
# Spieler zu nah, stoesst der Kern eine Schockwelle mit massivem Knockback
# aus - der Kern bestraft also sowohl "zu weit weg treiben lassen" (Sog)
# als auch "reinrennen und draufkloppen" (Schockwelle).
# ============================================================================
# BUGFIX "Sog spuerbar/sichtbar zu schwach": player_base.gd faengt jeden
# apply_knockback()-Impuls in einem Puffer ab, der pro Sekunde um
# knockback_friction (Standard 10.0) abgebaut wird (siehe dortiger
# Kopfkommentar zum behobenen "Magnet-Gefuehl"-Bug). Ein Dauer-Impuls von
# ~9 EINHEITEN * delta PRO FRAME lag praktisch im Rauschen der Reibung -
# netto blieb kaum spuerbare Geschwindigkeit uebrig. Jetzt wird stattdessen
# alle PULL_TICK_INTERVAL Sekunden EIN kraeftiger Einzelimpuls verpasst
# (PULL_IMPULSE_STRENGTH, deutlich ueber der Reibung) - UND exakt im selben
# Rhythmus eine nach innen laufende Ring-Welle gespawnt, damit sichtbarer
# Effekt und tatsaechlicher Zug immer im selben Moment passieren.

const DUST_RING_SCENE: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const PULL_WAVE_COLOR: Color = Color(0.6, 0.3, 1.0)
const PULL_TICK_INTERVAL: float = 0.35
const PULL_IMPULSE_STRENGTH: float = 16.0

## 5x die urspruengliche Modellgroesse (Bau-Basiswerte unten sind bereits
## mit VISUAL_SCALE multipliziert, statt an jeder einzelnen Mesh-Zahl von
## Hand herumzurechnen).
const VISUAL_SCALE: float = 5.0

var pull_radius: float = 20.0
var too_close_radius: float = 7.0
var shockwave_force: float = 30.0
var shockwave_cooldown_time: float = 1.6
var pickup_pull_speed: float = 7.0

var _shockwave_cooldown: float = 0.0
var _pull_tick_timer: float = 0.0
var _spin: float = 0.0
var _core_visual: MeshInstance3D = null


func _configure() -> void:
	display_name = "Magnet-Kern"
	max_health = 160.0


## Rueckmeldung "zieht trotz tot noch an": _physics_process() stoppt zwar
## sofort ueber set_physics_process(false) in _teardown() (siehe
## custom_enemy_base.gd), der LETZTE Sog-Impuls klingt aber ueber
## knockback_friction noch bis zu ~1,6s nach - genau das fuehlt sich wie
## "zieht immer noch" an, obwohl der Kern schon tot ist. Sofortiges Kappen
## hier behebt das, ohne die generische Knockback-Physik anzufassen.
func _on_died() -> void:
	var player: CharacterBody3D = _find_player()
	if player != null and player.has_method("clear_knockback"):
		player.clear_knockback()
	await super._on_died()

```
</details>

### 💭 Thinking: *MagnetCore doesn't really "attack" in the…*

`21:46:17`

<details>
<summary>Thinking...</summary>

> MagnetCore doesn't really "attack" in the usual sense — it pulls and then unleashes a knockback shockwave when the player gets close. The shockwave cooldown of 1.6 seems to be its real punishing-attack cadence, while the pull tick interval is more of a constant ambient effect than an actual attack speed stat.
> 
> Since the user wants a blanket 10% attack speed increase across every enemy type, I shouldn't exclude MagnetCore even though it was explicitly excluded from earlier "3x size" balance changes — I'll treat its shockwave cooldown as the closest analog to attack speed and scale that value. Let me verify the shockwave actually deals damage by checking the rest of magnet_core.gd.
</details>

#### 🔎 Grep `shockwave|take_damage|Schockwelle` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\magnet_core.gd`

`21:46:17`

```
7:# Spieler zu nah, stoesst der Kern eine Schockwelle mit massivem Knockback
9:# als auch "reinrennen und draufkloppen" (Schockwelle).
34:var shockwave_force: float = 30.0
35:var shockwave_cooldown_time: float = 1.6
38:var _shockwave_cooldown: float = 0.0
103:	_shockwave_cooldown = maxf(_shockwave_cooldown - delta, 0.0)
125:		_trigger_shockwave(player)
129:	# vor der Schockwellen-Zone am staerksten.
165:func _trigger_shockwave(player: CharacterBody3D) -> void:
166:	if _shockwave_cooldown > 0.0:
168:	_shockwave_cooldown = shockwave_cooldown_time
179:	player.apply_knockback(away.normalized() * shockwave_force + Vector3.UP * 6.0)
```

### 💭 Thinking: *Confirmed the shockwave only applies knockback…*

`21:46:34`

<details>
<summary>Thinking...</summary>

> Confirmed the shockwave only applies knockback with no direct damage call, so MagnetCore is purely a control-effect enemy without a real damage timer. That means it makes sense to exclude it from attack speed scaling, though it should still get other relevant buffs.
> 
> Now I'm mapping out which enemy need attack-speed scaling: Fighter/Stinger/Colossus share `attack_cooldown` in enemy_ai.gd, MortarBot and AcidSprinkler scale via their `fire_interval` since both deal real damage, and PlasmaBeamBot scales via `cooldown_time` since it deals burn damage on its beam cycle. I still need to verify DiveBomber's `dash_interval` actually ties to damage output before including it, and I'm noting ShieldDrone should be skipped.
> 
> MagnetCore is another candidate to skip — its PULL_TICK_INTERVAL is a constant, not a scalable var, and it doesn't deal direct damage, so I'll leave it out but flag the reasoning. Let me go check dive_bomber.gd to confirm how its dash ties into damage.
</details>

#### 🔎 Grep `dash_interval|take_damage|damage|dive` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\dive_bomber.gd`

`21:46:34`

```
2:class_name DiveBomber
5:# Divebomber — fliegender Gegner.
9:# Rhythmus (DASH_INTERVAL) auf ihn herab: LOCK-Phase mit sichtbarem
22:enum State { HOVER, LOCK, DIVE, GROUNDED, RECOVER }
31:var dash_interval: float = 3.4
33:var dive_speed: float = 34.0
35:var damage: float = 20.0
49:var _dive_target: Vector3 = Vector3.ZERO
57:## BUGFIX "Divebomber stuerzt in den Boden, steigt dann auf und kommt nie
69:	display_name = "Divebomber"
78:	_timer = dash_interval * randf_range(0.4, 1.0)
111:		State.DIVE:
112:			_do_dive(delta)
141:		_timer = dash_interval
148:	_dive_target = player.global_position
161:	_lock_marker.global_position = _dive_target + Vector3.UP * 0.05
175:		_state = State.DIVE
178:func _do_dive(delta: float) -> void:
179:	global_position.x = move_toward(global_position.x, _dive_target.x, dive_speed * delta)
180:	global_position.z = move_toward(global_position.z, _dive_target.z, dive_speed * delta)
181:	global_position.y -= dive_speed * delta
214:		flat_player.y = _dive_target.y
215:		hit_player = flat_player.distance_to(_dive_target) <= hit_radius
220:			target_health.take_damage(damage, self)
233:## dash_interval=3.4s und bis zu 8 Divebombern/Raum (siehe
234:## resources/enemies/es_divebomber.tres) haetten sich in 30s bereits
283:		_timer = dash_interval
```

### 💭 Thinking: *Confirmed that dash_interval is DiveBomber…*

`21:46:46`

<details>
<summary>Thinking...</summary>

> Confirmed that dash_interval is DiveBomber's attack cadence dealing damage, so I'll scale it too. Now I'm adding a generic HP multiplier for enemy in health.gd, applying a 1.3x boost to max_health when the parent node belongs to the "enemies" group, then setting current_health accordingly.
> 
> But I need to check node ordering carefully — since Health is typically a child node, its `_ready()` fires before the parent enemy's `_ready()`. If `add_to_group("enemies")` is called inside the enemy's own `_ready()`, that group membership wouldn't exist yet when Health checks for it. I need to verify whether enemy actually call `add_to_group` in `_enter_tree()` instead, which fires top-down and would avoid this hazard — so I should check enemy_ai.gd and custom_enemy_base.gd for where that call happens.
</details>

#### 🔎 Grep `add_to_group\("enemies"\)` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`21:46:46`

```
scripts\enemies\custom_enemy_base.gd:66:	add_to_group("enemies")
scripts\enemies\enemy_ai.gd:912:	add_to_group("enemies")
```

### 💭 Thinking: *I need to figure out which lifecycle method…*

`21:46:52`

<details>
<summary>Thinking...</summary>

> I need to figure out which lifecycle method these lines belong to—`_ready()`, `_enter_tree()`, or `_init()`—so I should look at the surrounding context for both.
</details>

#### 👀 Read `custom_enemy_base.gd`

`21:46:52`

*(lines 55–75)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\custom_enemy_base.gd</code></summary>

```
## gesperrt": _despawn_if_room_clear() (siehe shield_drone.gd/
## plasma_beam_bot.gd) hat vorher die GLOBALE Gruppe "enemies" durchsucht -
## damit hat ein ueberlebender Gegner IRGENDWO SONST auf der Etage (z.B. ein
## Verfolger aus einem vorherigen, nicht ganz leergeraeumten Raum) die
## Drohne fuer immer am Despawnen gehindert, auch wenn IHR EIGENER Raum
## laengst leer war. spawn_room erlaubt den beiden Klassen, nur noch
## Gegner AUS DEMSELBEN RAUM zu zaehlen.
var spawn_room: Node = null


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1

	visual_root = Node3D.new()
	visual_root.name = "Visual"
	add_child(visual_root)

	_configure()
```
</details>

### 💭 Thinking: *I'm confirming that add_to_group("enemies…*

`21:47:13`

<details>
<summary>Thinking...</summary>

> I'm confirming that add_to_group("enemies") runs in CustomEnemyBase's own _ready(), and since Health is a child node, its _ready() would fire before the parent's—so I need to check whether Health is already present in the scene tree from the start, like with Fighter/Stinger/Colossus.
> 
> For code-built enemy like mortar_bot, Health is likely instantiated dynamically inside _build_health(), which runs after _configure() but still within the same _ready() call per the documented lifecycle order. That means add_to_group("enemies") at the top of _ready() executes before Health even exists, so I need to figure out exactly when Health's own _ready() fires relative to that—since nodes added via add_child() at runtime have their own timing quirks for when _ready() actually triggers.
> 
> Since the enemy's _ready() is still mid-execution when it calls add_child(health), and add_to_group("enemies") already ran earlier in that same _ready(), group membership is already set on the parent by the time Health's _ready() checks get_parent().is_in_group("enemies") — so that check should correctly return true for CustomEnemyBase enemies. Now I need to verify the same holds for EnemyAI-family enemy like Fighter, Stinger, and Colossus, where Health already exists as a sibling node in the scene tree rather than being created dynamically.
</details>

#### 👀 Read `enemy_ai.gd`

`21:47:13`

*(lines 895–925)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd</code></summary>

```
# _player aktuell, da der Player-Node beim Wechseln komplett ausgetauscht
# wird (alte Instanz wird entfernt, neue gespawnt).
func _on_active_player_changed(new_player: CharacterBody3D) -> void:
	_player = new_player

# Holt die aktuelle Spieler-Instanz bevorzugt ueber PartyManager (immer
# aktuell), find_child("Player") nur als Fallback, falls PartyManager aus
# irgendeinem Grund noch keine Instanz kennt.
func _refresh_player_reference() -> void:
	if PartyManager.player and is_instance_valid(PartyManager.player):
		_player = PartyManager.player
	else:
		_player = get_tree().get_root().find_child("Player", true, false)
	if _player == null:
		push_warning("EnemyAI: Konnte keinen Node namens 'Player' finden.")

func _ready() -> void:
	add_to_group("enemies")
	_roll_speed_multiplier()
	_refresh_player_reference()
	if not PartyManager.active_player_changed.is_connected(_on_active_player_changed):
		PartyManager.active_player_changed.connect(_on_active_player_changed)

	_setup_slope_stability()

	_debug("_ready(). attack_hitbox=%s | telegraph_inner=%s | telegraph_outer=%s | nav_agent=%s" % [attack_hitbox, telegraph_inner, telegraph_outer, nav_agent])

	var shape_node := _get_collision_shape_node()
	if shape_node == null:
		push_warning("EnemyAI (%s): Keine CollisionShape3D gefunden! Kanten-/Hindernis-Checks laufen mit Fallback-Werten und sind unzuverlaessig." % display_name)
```
</details>

### 💭 Thinking: *I confirmed that EnemyAI adds itself to the…*

`21:47:28`

<details>
<summary>Thinking...</summary>

> I confirmed that EnemyAI adds itself to the "enemies" group in its own `_ready()`, but since Health is a child node present in the scene file, Health's `_ready()` actually runs before EnemyAI's. That means checking `get_parent().is_in_group("enemies")` inside Health's `_ready()` would fail for Fighter, Stinger, and Colossus, since the group membership isn't set yet at that point.
> 
> Rather than deferring the check or adding a frame delay, a cleaner fix is to check the parent's class/type directly (e.g. whether it's an EnemyAI or CustomEnemyBase instance) instead of relying on group membership timing, since that check is valid immediately without any ordering hazard.  I should verify both classes actually declare `class_name` before relying on this approach.
</details>

#### 🔎 Grep `^class_name` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd`

`21:47:28`

```
5:class_name EnemyAI
```

```
2:class_name CustomEnemyBase
```

### 🤖 Assistant: *Now I have a clear picture.*

`21:47:42`

<details>
<summary>Thinking...</summary>

> I'm checking that implementing the Health.gd change with class-based checks won't create a circular dependency, since Health is a base/leaf class and EnemyAI/CustomEnemyBase shouldn't depend on its type for their own definitions.  Other scripts like combat_winter.gd already reference multiple class_names freely, so this pattern should be safe. Now I'll write the Health.gd edit.
</details>

> Now I have a clear picture. Let's implement the HP scaling safely (avoiding a `_ready()` ordering hazard I found — group membership isn't set yet for the EnemyAI family when `Health._ready()` would run, so I'll check by class type instead).

#### 👀 Read `health.gd`

`21:47:42`

*(lines 1–61)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\health.gd</code></summary>

```
extends Node
class_name Health

# --- Signals: andere Nodes (UI, Sound, VFX) koennen darauf reagieren, ---
# --- ohne dass diese Komponente wissen muss, WER zuhoert. ---
signal health_changed(current: float, max: float)
signal died

## NEU: feuert NUR bei tatsaechlich angekommenem Schaden (nach Invuln- und
## Multiplikator-Filter). Items wie "Mamas Kochloeffel" oder ein
## Trefferfeedback-System haengen sich hier dran, statt health_changed
## abzuhoeren — das feuert auch beim Heilen und bei jedem Regen-Tick.
signal damage_taken(amount: float, source: Node3D)

## NEU: Start/Ende der Unverwundbarkeit, z.B. fuer ein Blink-VFX am Modell.
signal invulnerability_changed(active: bool)

@export var max_health: float = 100.0

## Ausfuehrliche Konsolenausgaben zu Damage-Kalkulation, Invuln-/Tod-Faellen
## und Heilung - wie ueberall sonst im Projekt per Instanz zuschaltbar statt
## global, damit z.B. nur der Spieler oder nur ein einzelner Gegnertyp im
## Sandbox-Test geloggt wird (siehe enemy_ai.gd/bomb.gd fuer dasselbe Muster).
@export var debug_logging: bool = false

# --- Regeneration ---
@export var regen_enabled: bool = true
@export var regen_rate: float = 5.0       # HP pro Sekunde, sobald Regen aktiv ist
@export var regen_delay: float = 3.0      # Sekunden Wartezeit nach dem letzten Treffer

# ============================================================================
# UNVERWUNDBARKEIT
# ============================================================================
# Wird ueber set_invulnerable(dauer) gesetzt und laeuft hier selbst ab. Das
# gehoert bewusst in die Health-Komponente und nicht in den Aufrufer: sonst
# muesste JEDE Schadensquelle (Hitbox, Lava, Bombe, Dash) den Zustand
# einzeln pruefen, und die erste vergessene Stelle macht den Effekt wertlos.
#
# _invuln_timer < 0.0 bedeutet "unbegrenzt" (z.B. waehrend einer Cutscene) —
# in dem Fall raeumt nur clear_invulnerable() wieder auf.
var _invuln_timer: float = 0.0
var _invuln_permanent: bool = false

## Globaler Multiplikator auf ANKOMMENDEN Schaden. 1.0 = normal,
## 0.25 = 75 % Reduktion (siehe Item "Saeurefeste Stiefel"). Wird von
## PlayerStats gesetzt, nicht von Hand.
var incoming_damage_multiplier: float = 1.0

var current_health: float
var _time_since_damage: float = 0.0

# Merkt sich, WER/WAS zuletzt Schaden verursacht hat — z.B. fuer
# richtungsabhaengige Todes-Animationen (faellt weg vom Angreifer).
var last_damage_source: Node3D = null


func _ready() -> void:
	current_health = max_health


```
</details>

### 💭 Thinking: *I should also check whether `set_max_health…*

`21:47:52`

<details>
<summary>Thinking...</summary>

> I should also check whether `set_max_health()` gets called dynamically elsewhere for enemy, like rage or berserk effects that reset max_health after `_ready()` — if so, that could bypass my multiplier since it's only applied once at initialization.
> 
> The shield status effect boosts max HP by 25% relative to the current max_health value, which already includes my enemy multiplier since it reads the post-`_ready()` value — so that's fine, no conflict there since it's a relative change, not a hardcoded absolute.
> 
> Now I'm ready to write the edit to health.gd.
</details>

#### ✏️  Edit `health.gd`

`21:47:58`

```diff
@@ -5,6 +5,25 @@ # richtungsabhaengige Todes-Animationen (faellt weg vom Angreifer).
 var last_damage_source: Node3D = null
 
+## Rueckmeldung "alle Gegner sollen global 30% mehr HP haben" (2026-08-13):
+## EINZIGER Multiplikationspunkt fuer JEDE Gegner-Health-Instanz, egal ob
+## EnemyAI-Familie (Fighter/Stinger/Colossus) oder CustomEnemyBase-Familie
+## (Moerser-Bot etc.) - beide haengen ihre Health IMMER als Kind-Node namens
+## "Health" an (siehe CLAUDE.md-Architekturnotiz), decken sich hier also
+## automatisch ab, auch fuer kuenftige neue Gegnertypen.
+##
+## Typ-Check statt is_in_group("enemies"): Health haengt bei der EnemyAI-
+## Familie schon FEST im .tscn (z.B. dummy.tscn), also feuert Health._ready()
+## dort VOR dem _ready() des Eltern-Nodes (Godot ruft _ready() bottom-up) -
+## zu dem Zeitpunkt hat der Elternknoten add_to_group("enemies") (das steht
+## in dessen EIGENEM _ready(), siehe enemy_ai.gd) noch gar nicht ausgefuehrt.
+## Ein Typ-Check ist dagegen sofort gueltig, unabhaengig von jeder _ready()-
+## Reihenfolge.
+const ENEMY_MAX_HEALTH_MULTIPLIER: float = 1.3
+
 
 func _ready() -> void:
+	var parent: Node = get_parent()
+	if parent is EnemyAI or parent is CustomEnemyBase:
+		max_health *= ENEMY_MAX_HEALTH_MULTIPLIER
 	current_health = max_health
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\health.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the attack-speed scaling.*

`21:48:06`

<details>
<summary>Thinking...</summary>

> Switching to a type check instead of a group check means ordering no longer matters for either enemy family, which sidesteps the whole issue uniformly. Now I'm moving on to implementing the attack-speed scaling, starting with EnemyAI.
> 
> gd's `_ready()` to scale `attack_cooldown` for the Fighter/Stinger/Colossus family, while the CustomEnemyBase family will scale their own cadence variables inside `_configure()`.
</details>

> Now the attack-speed scaling. First, `enemy_ai.gd` (covers Fighter/Stinger/Colossus uniformly):

#### 👀 Read `enemy_ai.gd`

`21:48:06`

*(lines 30–45)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd</code></summary>

```
# Balancing-Fehler zu wirken, aber gross genug um spuerbar zu sein.
# 0.0 = alle Instanzen exakt gleich schnell (altes Verhalten).
@export_range(0.0, 0.5) var speed_variance: float = 0.12

## PHASE 4: verdoppelt (war 20.0) - passend zu den seit Phase 3 groesseren
## Raeumen und den einzelnen Gegner-Ueberschreibungen in dummy.tscn /
## scout_dummy.tscn / tank_dummy.tscn, die ebenfalls verdoppelt wurden.
@export var detection_range: float = 40.0
@export var attack_range: float = 5.0
@export var attack_cooldown: float = 1.0

# --- Angriffs-Freigabe (Fix: "greift ins Leere") --------------------------
# Frueher wurde ein Angriff gestartet, sobald distance <= attack_range war,
# und die Hitbox danach BEDINGUNGSLOS aktiviert — auch wenn der Spieler
# waehrend pre_attack_delay + attack_windup_time laengst weggelaufen war
```
</details>

### 💭 Thinking: *Now I need to edit the `_ready()` function…*

`21:48:12`

<details>
<summary>Thinking...</summary>

> Now I need to edit the `_ready()` function around lines 911-917 to add the scaling logic, so let me re-check the current line numbers first.
</details>

#### 👀 Read `enemy_ai.gd`

`21:48:12`

*(lines 909–919)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd</code></summary>

```
		push_warning("EnemyAI: Konnte keinen Node namens 'Player' finden.")

func _ready() -> void:
	add_to_group("enemies")
	_roll_speed_multiplier()
	_refresh_player_reference()
	if not PartyManager.active_player_changed.is_connected(_on_active_player_changed):
		PartyManager.active_player_changed.connect(_on_active_player_changed)

	_setup_slope_stability()
```
</details>

### 💭 Thinking: *I'm checking that `_roll_speed_multiplier…*

`21:48:18`

<details>
<summary>Thinking...</summary>

> I'm checking that `_roll_speed_multiplier()` only affects move speed variance and leaves attack_cooldown untouched, which looks fine. Then I'll add the attack_cooldown scaling at the top of `_ready()`, using a named constant placed near the `attack_cooldown` export for clarity.
</details>

#### ✏️  Edit `enemy_ai.gd`

`21:48:19`

```diff
@@ -1,3 +1,11 @@ @export var detection_range: float = 40.0
 @export var attack_range: float = 5.0
 @export var attack_cooldown: float = 1.0
+
+## Rueckmeldung "alle Gegner sollen global 10% schneller angreifen"
+## (2026-08-13): EINZIGER Skalierungspunkt fuer die gesamte EnemyAI-Familie
+## (Fighter/Stinger/Colossus, siehe dummy.tscn/scout_dummy.tscn/
+## tank_dummy.tscn) - wird in _ready() auf attack_cooldown angewandt statt
+## die drei Szenen-Werte einzeln von Hand anzupassen, damit auch kuenftige
+## neue EnemyAI-basierte Gegner automatisch mitskalieren.
+const ATTACK_SPEED_MULTIPLIER: float = 1.1
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,3 +1,5 @@ func _ready() -> void:
 	add_to_group("enemies")
+	# 10% schnellere Angriffe: kuerzerer Cooldown = hoehere Angriffsfrequenz.
+	attack_cooldown /= ATTACK_SPEED_MULTIPLIER
 	_roll_speed_multiplier()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the CustomEnemyBase family's four attacking…*

`21:48:37`

<details>
<summary>Thinking...</summary>

> I'll leave attack_abort_cooldown alone since it's a punishment cooldown, not attack speed. Now I'm moving to the CustomEnemyBase attacking enemies—mortar_bot, acid_sprinkler, dive_bomber, and plasma_beam_bot—scaling their fire interval timers by dividing by 1.1.
> 
> I'm deciding whether to bake the final numeric value into each constant or keep the division expression visible, like the existing `VISUAL_SCALE: float = 4.5 * 0.85 * 0.85` precedent in mortar_bot.gd that preserves the math history in comments. I'll follow that same pattern for consistency.
</details>

> Now the CustomEnemyBase family's four attacking enemies:

#### 👀 Read `mortar_bot.gd`

`21:48:37`

*(lines 28–38)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\mortar_bot.gd</code></summary>

```
const VISUAL_SCALE: float = 4.5 * 0.85 * 0.85
## Wie schnell sich der Moerser-Bot zum Spieler dreht (rad/s) - langsam
## genug, dass die Drehung als sichtbares "Zielen" wirkt statt als Snap.
const TURN_SPEED: float = 1.2

var fire_interval: float = 3.6
## War 1.3 - Rueckmeldung "Geschoss fliegt zu langsam". Bestimmt (zusammen
## mit der konstanten Flugdistanz) direkt die Geschwindigkeit: der Shell-
## Tween in _fire_at() legt dieselbe Strecke jetzt in gut halb so viel Zeit
## zurueck, also gut doppelt so schnell.
```
</details>

#### ✏️  Edit `mortar_bot.gd`

`21:48:42`

```diff
@@ -1 +1,3 @@-var fire_interval: float = 3.6
+## Rueckmeldung "alle Gegner sollen global 10% schneller angreifen"
+## (2026-08-13): kuerzerer Cooldown = hoehere Angriffsfrequenz.
+var fire_interval: float = 3.6 / 1.1
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\mortar_bot.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### 👀 Read `acid_sprinkler.gd`

`21:48:46`

*(lines 24–30)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\acid_sprinkler.gd</code></summary>

```
## verkleinert, gleiche Groessenordnung wie mortar_bot.gd's Korrektur.
const VISUAL_SCALE: float = 3.0 * 0.85

var fire_interval: float = 2.6
var flight_time: float = 0.7
var puddle_radius: float = 2.6
```
</details>

#### ✏️  Edit `acid_sprinkler.gd`

`21:48:51`

```diff
@@ -1 +1,3 @@-var fire_interval: float = 2.6
+## Rueckmeldung "alle Gegner sollen global 10% schneller angreifen"
+## (2026-08-13): kuerzerer Cooldown = hoehere Angriffsfrequenz.
+var fire_interval: float = 2.6 / 1.1
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\acid_sprinkler.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### 👀 Read `dive_bomber.gd`

`21:48:53`

*(lines 28–36)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\dive_bomber.gd</code></summary>

```
## War 11.0 - Rueckmeldung "zu tief, nicht weit oben in der Luft" (2026-08-12).
var hover_height: float = 16.0
var hover_recenter_speed: float = 2.5
var dash_interval: float = 3.4
var lock_time: float = 0.9
var dive_speed: float = 34.0
var hit_radius: float = 2.4
var damage: float = 20.0
```
</details>

#### ✏️  Edit `dive_bomber.gd`

`21:48:57`

```diff
@@ -1 +1,3 @@-var dash_interval: float = 3.4
+## Rueckmeldung "alle Gegner sollen global 10% schneller angreifen"
+## (2026-08-13): kuerzerer Cooldown = hoehere Angriffsfrequenz.
+var dash_interval: float = 3.4 / 1.1
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\dive_bomber.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### 👀 Read `plasma_beam_bot.gd`

`21:49:01`

*(lines 23–31)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\plasma_beam_bot.gd</code></summary>

```
var hover_height: float = 8.0
var drift_speed: float = 2.0
var charge_time: float = 1.1
var beam_duration: float = 1.4
var beam_width: float = 2.0
var sweep_length: float = 14.0
var cooldown_time: float = 3.2
var detect_range: float = 40.0
```
</details>

### 💭 Thinking: *I need to check the state machine to confirm…*

`21:49:11`

<details>
<summary>Thinking...</summary>

> I need to check the state machine to confirm whether cooldown_time alone governs the full attack cycle, or if drift duration is separately randomized until the player is detected. I also want to avoid scaling charge_time down, since that's the telegraph before firing and shortening it would feel unfair rather than simply faster.
> 
> So I'll scale only `cooldown_time`, keeping it consistent with how other enemies' fire_interval/dash_interval are treated — adjusting the cadence between attacks rather than the wind-up duration.
</details>

#### ✏️  Edit `plasma_beam_bot.gd`

`21:49:11`

```diff
@@ -1 +1,5 @@-var cooldown_time: float = 3.2
+## Rueckmeldung "alle Gegner sollen global 10% schneller angreifen"
+## (2026-08-13): kuerzerer Cooldown = hoehere Angriffsfrequenz. charge_time
+## (Telegraph vor dem Schuss) bleibt bewusst unangetastet - der soll lesbar
+## bleiben, nur die Pause ZWISCHEN Angriffen wird kuerzer.
+var cooldown_time: float = 3.2 / 1.1
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\plasma_beam_bot.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's fix the admin teleport panel (VFX…*

`21:49:22`

<details>
<summary>Thinking...</summary>

> ShieldDrone and MagnetCore are intentionally left without direct-damage attack timers, so I'll add brief one-liner comments in their scripts noting this is deliberate, just for traceability for future maintainers.
> 
> Actually, since neither has a meaningful attack variable to attach a comment to, I'll skip it — the task's "attack speed" scope only applies to enemy that actually attack, so leaving them untouched is the right call.
> 
> Now moving to the next part of the request: fixing the tutorial-UI leak for the ADMIN teleport panel in pause_menu.gd, covering the pocket dimension and room-type teleports. I need to read through the full admin panel section to figure out where to place the teardown calls.
</details>

> Now let's fix the admin teleport panel (VFX/Sandbox/Hub/Items/Boss/Tresor) so it also clears the tutorial UI.

#### 👀 Read `pause_menu.gd`

`21:49:22`

*(lines 377–477)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd</code></summary>

```
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


```
</details>

### 💭 Thinking: *The "← Start" button also teleports to the…*

`21:49:41`

<details>
<summary>Thinking...</summary>

> The "← Start" button also teleports to the start room, but the user's list didn't include it, so it likely shouldn't trigger hiding the tutorial UI since it's just returning within the current layout rather than leaving the tutorial context.
> 
> Actually, re-reading the user's message, I think they mean this rule should apply whenever the debug teleport jumps to any of those specific destinations, regardless of which layout is currently active.
> 
> The simplest and most robust approach is to make ANY use of the admin teleport panel tear down the tutorial UI, since using that debug tool means you're stepping out of the guided tutorial flow entirely. I'll apply this teardown at the shared chokepoints handling room-type teleports and pocket teleports, so all admin jumps clear the tutorial UI consistently.
> 
> I'll implement this by having both teleport functions call a new shared helper that locates the LevelGenerator and invokes its teardown method, which I'll make slightly more accessible. Now I need to check how the level generator lookup is implemented.
</details>

#### 👀 Read `pause_menu.gd`

`21:49:41`

*(lines 493–508)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd</code></summary>

```
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
</details>

### 💭 Thinking: *Good, the level generator lookup already…*

`21:49:47`

<details>
<summary>Thinking...</summary>

> Good, the level generator lookup already works via group lookup, so now I'll add teardown calls to the teleport-to-room-type and pocket admin functions.
</details>

#### ✏️  Edit `pause_menu.gd`

`21:49:52`

```diff
@@ -1,5 +1,22 @@ ## Ruft einen Pocket-Dimension-Teleport-Callable auf und schliesst das Pause-Menue.
 func _admin_pocket(tp: Callable) -> void:
+	_teardown_tutorial_ui_if_present()
 	_resume()
 	await get_tree().process_frame
 	tp.call()
+
+
+## Rueckmeldung "Dash/Bomben+Charakter-Beschreibung soll NUR im Tutorial
+## vorkommen, auch beim Admin-Teleport aus dem Tutorial raus (VFX/Sandbox/
+## Hub/Items/Boss/Tresor/Start)" (2026-08-13): level_generator.gd raeumt die
+## Tutorial-UI zwar schon bei jedem regulaeren Etagenwechsel weg (siehe
+## dortiges _teardown_tutorial_ui()), aber die Admin-Teleports hier springen
+## NIE ueber generate_stage()/generate_new_stage() - sie verschieben den
+## Spieler nur innerhalb desselben Layouts (Raum-Typ-Teleport) oder haengen
+## eine Pocket-Dimension zusaetzlich in dieselbe Szene (siehe
+## vfx_test_room.gd::teleport_player_in() - kein change_scene_to_file()).
+## Ohne diesen Aufruf ueberlebt die Tutorial-UI also jeden Admin-Teleport.
+func _teardown_tutorial_ui_if_present() -> void:
+	var gen: LevelGenerator = _find_level_generator()
+	if gen != null and gen.has_method("_teardown_tutorial_ui"):
+		gen._teardown_tutorial_ui()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the room-type teleport path (Start/Tresor…*

`21:49:54`

> Now the room-type teleport path (Start/Tresor/Boss):

#### ✏️  Edit `pause_menu.gd`

`21:49:57`

```diff
@@ -1,6 +1,7 @@ ## Sucht den ersten Raum des gegebenen Typs im aktuellen Layout und
 ## teleportiert den aktiven Spieler dorthin. Schliesst danach das Pause-Menue.
 func _admin_teleport_to_room_type(room_type: int) -> void:
+	_teardown_tutorial_ui_if_present()
 	var gen: LevelGenerator = _find_level_generator()
 	if gen == null:
 		return
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pause_menu.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's update the Obsidian vault and knowledge…*

`21:50:08`

<details>
<summary>Thinking...</summary>

> Good, so the "← Start" path reuses the same teleport helper, clearing things consistently with my earlier reasoning. I also notice the teardown call accesses a private-by-convention method from outside the class, but that's already an established pattern elsewhere in this file with similar direct access to underscore-prefixed members.
> 
> Now I should update the Obsidian vault since the user explicitly asked for it, and since we changed enemy stats and tutorial room counts, that's a balancing change worth rebuilding the vault for. I'll run the vault generation script, and also run the graph update command since code was modified.
</details>

> Now let's update the Obsidian vault and knowledge graph to reflect all these balancing changes.

#### 💻 Bash: *Regenerate Obsidian vault from current source files*

`21:50:08`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -60
```

```
Whiplash Obsidian-Vault-Generator

============================================================

[1/7] Ordnerstruktur angelegt

[2/7] Dataview-Templates geschrieben (99_Templates)

[3/7] Rohdaten eingelesen: 95 Items, 3+6 Gegner, 4 Charaktere, 39 Raeume, 10 Status-Effekte, 88 Commits

      -> 86 DevLog<->Spielinhalt-Erwaehnungen per Freitext-Abgleich gefunden

[4/7] 95 Item-Notizen geschrieben (01_Game_Design/Items)

      -> 52 Item->Status-Ausloese-, 2 Item->Status-Reagiert-auf-, 2 Item<->Item-Synergie-Verknuepfungen gefunden

[4/7] 3 Enemy-Notizen (Threat-Budget) + 6 Sandbox-Prototyp-Notizen geschrieben (01_Game_Design/Enemies)

[4/7] 4 Character-Notizen geschrieben (01_Game_Design/Characters)

[4/7] 39 Room-Notizen geschrieben (01_Game_Design/Rooms)

[4/7] 10 Status-Effekt-Notizen geschrieben (01_Game_Design/Status_Effects)

[5/7] Architektur-Notizen geschrieben (02_Tech_Architecture)

[5/7] Gruppierungs-Seiten (MOCs) geschrieben

[6/7] 88 DevLog-Notizen + Gesamtliste geschrieben (03_DevLogs)

[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).
```

### 🤖 Assistant: *Vault regenerated successfully.*

`21:50:14`

> Vault regenerated successfully. Now update the knowledge graph:

#### 💻 Bash: *Update graphify knowledge graph after code changes*

`21:50:15`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify update . 2>&1 | tail -40
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Re-extracting code files in . (no LLM needed)...

  AST extraction: 7/7 uncached files (100%)

  warning: 2 source file(s) produced zero nodes and are absent from the graph: settings.local.json, .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5181 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] community set changed since labeling (550 saved labels, 552 communities now; renamed 12 community(ies) by their hub). Run `graphify label` to refresh names with the LLM.

Graph has 5356 nodes (above 5000 limit). Building aggregated community view...

graph.html written (aggregated: 552 community nodes, 169 cross-community edges)

Tip: run with --obsidian for full node-level detail.

[graphify watch] Rebuilt: 5356 nodes, 5070 edges, 552 communities

[graphify watch] graph.json, graph.html and GRAPH_REPORT.md updated in graphify-out

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 💭 Thinking: *Now I want to double-check I haven't broken…*

`21:50:56`

<details>
<summary>Thinking...</summary>

> Now I want to double-check I haven't broken anything by re-reading the final diffs of the key files, making sure the attack_cooldown edit in enemy_ai.gd doesn't create a double-declaration issue, and confirming the ATTACK_SPEED_MULTIPLIER constant doesn't collide with an existing one of the same name.
</details>

#### 🔎 Grep `ATTACK_SPEED_MULTIPLIER` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`21:50:56`

```
scripts\enemies\enemy_ai.gd:47:const ATTACK_SPEED_MULTIPLIER: float = 1.1
scripts\enemies\enemy_ai.gd:922:	attack_cooldown /= ATTACK_SPEED_MULTIPLIER
```

### 🤖 Assistant: *Only one declaration, correctly referenced…*

`21:50:59`

> Only one declaration, correctly referenced. Let's do a final sanity pass over the `health.gd` change to make sure the class references resolve correctly.

#### 👀 Read `health.gd`

`21:51:00`

*(lines 49–74)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\health.gd</code></summary>

```
var current_health: float
var _time_since_damage: float = 0.0

# Merkt sich, WER/WAS zuletzt Schaden verursacht hat — z.B. fuer
# richtungsabhaengige Todes-Animationen (faellt weg vom Angreifer).
var last_damage_source: Node3D = null

## Rueckmeldung "alle Gegner sollen global 30% mehr HP haben" (2026-08-13):
## EINZIGER Multiplikationspunkt fuer JEDE Gegner-Health-Instanz, egal ob
## EnemyAI-Familie (Fighter/Stinger/Colossus) oder CustomEnemyBase-Familie
## (Moerser-Bot etc.) - beide haengen ihre Health IMMER als Kind-Node namens
## "Health" an (siehe CLAUDE.md-Architekturnotiz), decken sich hier also
## automatisch ab, auch fuer kuenftige neue Gegnertypen.
##
## Typ-Check statt is_in_group("enemies"): Health haengt bei der EnemyAI-
## Familie schon FEST im .tscn (z.B. dummy.tscn), also feuert Health._ready()
## dort VOR dem _ready() des Eltern-Nodes (Godot ruft _ready() bottom-up) -
## zu dem Zeitpunkt hat der Elternknoten add_to_group("enemies") (das steht
## in dessen EIGENEM _ready(), siehe enemy_ai.gd) noch gar nicht ausgefuehrt.
## Ein Typ-Check ist dagegen sofort gueltig, unabhaengig von jeder _ready()-
## Reihenfolge.
const ENEMY_MAX_HEALTH_MULTIPLIER: float = 1.3


func _ready() -> void:
```
</details>

### 🤖 Assistant: *This all looks correct.*

`21:51:12`

> This all looks correct. Let's give a final summary of everything done this turn.
> 
> ## Summary
> 
> **1. Tutorial UI also leaking via debug/admin teleports** — [scripts/pause_menu.gd](scripts/pause_menu.gd): added `_teardown_tutorial_ui_if_present()`, called from both admin-teleport chokepoints (`_admin_teleport_to_room_type()` — covers Start/Tresor/Boss, and `_admin_pocket()` — covers Items/Sandbox/Hub/VFX). Those teleports never go through `generate_stage()`, so the earlier level-progression fix didn't cover them.
> 
> **2. Tutorial room harder** — [scripts/tutorial_content.gd](scripts/tutorial_content.gd): doubled every enemy type's count in each fixed tutorial room (no new types).
> 
> **3. Global enemy buffs (+30% HP, +10% attack speed)**:
> - **HP**: [scripts/health.gd](scripts/health.gd) — single multiplier in `Health._ready()`, gated by `parent is EnemyAI or parent is CustomEnemyBase` (checked by *class type*, not group membership — I found that `is_in_group("enemies")` wouldn't be reliable yet at that point for the EnemyAI family, since Godot fires `_ready()` bottom-up and their Health node is a pre-existing scene child that readies *before* the parent adds itself to the group). This covers every current and future enemy in one place, and doesn't touch the player.
> - **Attack speed**: no shared timer exists across both enemy systems, so I scaled each system's actual cadence value:
>   - [scripts/enemies/enemy_ai.gd](scripts/enemies/enemy_ai.gd) — `attack_cooldown` scaled once in `_ready()`, covers Fighter/Stinger/Colossus uniformly.
>   - [scripts/enemies/mortar_bot.gd](scripts/enemies/mortar_bot.gd), [acid_sprinkler.gd](scripts/enemies/acid_sprinkler.gd), [dive_bomber.gd](scripts/enemies/dive_bomber.gd), [plasma_beam_bot.gd](scripts/enemies/plasma_beam_bot.gd) — each one's own fire/dash/cooldown interval scaled individually (they don't share a common field name).
>   - Skipped Schild-Drohne and Magnet-Kern deliberately — neither ever deals direct damage on a timer (support buffs / pure pull+knockback), so "attack speed" doesn't apply to them.
> 
> **4. Vault/graph updated** — ran `python generate_vault.py` (regenerated item/enemy/room/character notes) and `graphify update .` (AST-only refresh, no API cost) as instructed.
> 
> Please reload and check: tutorial UI should now vanish under every teleport path, tutorial fights should feel noticeably busier, and enemy everywhere should feel tankier and a bit more aggressive.
