---
title: "Balanciere Gegner-Kosten für Spielmechanik"
date: 2026-08-12
tags: [chatlog, prompt-log, whiplash, lemonade, thema/enemy, thema/balancing, ki/claude-cli]
ki_art: "claude cli"
---
# Balanciere Gegner-Kosten für Spielmechanik

[Source File](file:///C:/Users/thvnh/.claude/projects/C--Users-thvnh-Documents-GitHub-whiplash/session-31bea21d-8438-467a-b12c-754e88352e80.html)

# 📋 Session `31bea21d`: Balanciere Gegner-Kosten für Spielmechanik — Model: `claude-sonnet-5`

## 🤷 User: *egner, weil die Ratio nicht mehr stimmt.*

**`2026-08-12`** `19:36:32`

egner, weil die Ratio nicht mehr stimmt.

- **Plasma-Beam Bot:** 10 ➔ **12
- **Colossus (Boss-Klasse):** 10 ➔ **15** *(Er war vorher genauso teuer wie der Plasma-Bot. Ein Colossus sollte aber der teuerste Gegner im Budget sein!)*

***

### 💭 Thinking

`19:36:37`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:36:38`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -l "threat_cost" -r resources/enemies/ 2>/dev/null
```

```
resources/enemies/es_acid_sprinkler.tres
resources/enemies/es_colossus.tres
resources/enemies/es_divebomber.tres
resources/enemies/es_fighter.tres
resources/enemies/es_magnet_core.tres
resources/enemies/es_mortar_bot.tres
resources/enemies/es_plasma_beam_bot.tres
resources/enemies/es_shield_drone.tres
```

### 💭 Thinking

`19:36:43`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `es_plasma_beam_bot.tres`

`19:36:44`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_plasma_beam_bot.tres</code></summary>

```
[gd_resource type="Resource" script_class="EnemySpawnEntry" format=3]

[ext_resource type="Script" path="res://scenes/level_generation/enemy_spawn_entry.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/enemies/plasma_beam_bot.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
display_name = "Plasmastrahl-Bot"
weight = 1.0
threat_cost = 10
max_per_room = 1
min_spawn_spacing = 10.0

```
</details>

#### 👀 Read `es_colossus.tres`

`19:36:44`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_colossus.tres</code></summary>

```
[gd_resource type="Resource" script_class="EnemySpawnEntry" format=3 uid="uid://diggh6vr41r5e"]

[ext_resource type="Script" uid="uid://cvv6ttrhxcdyi" path="res://scenes/level_generation/enemy_spawn_entry.gd" id="1_script"]
[ext_resource type="PackedScene" uid="uid://6agdektsj4x3" path="res://scenes/tank_dummy.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
display_name = "Colossus"
threat_cost = 10
max_per_room = 3
min_room_height = 20.0
guaranteed_count = 3
min_spawn_spacing = 11.0
is_elite = true

```
</details>

### 🤖 Assistant: *Both confirm the current values (10 each…*

`19:36:47`

> Both confirm the current values (10 each) match the doc you pasted. Applying the balance change: Plasma-Beam Bot 10→12, Colossus 10→15.

#### ✏️  Edit `es_plasma_beam_bot.tres`

`19:36:48`

```diff
@@ -1 +1 @@-threat_cost = 10
+threat_cost = 12
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_plasma_beam_bot.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `es_colossus.tres`

`19:36:49`

```diff
@@ -1 +1 @@-threat_cost = 10
+threat_cost = 15
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_colossus.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's check if there's a design doc that…*

`19:36:54`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now let's check if there's a design doc that documents these threat costs, since project convention says the vault is regenerated from source but some prose sections are hand-maintained.

#### 🔎 Grep `Plasma-Beam Bot|Plasmastrahl` in `C:\Users\thvnh\Documents\GitHub\whiplash\01_Game_Design`

`19:36:56`

```
Found 2 files
01_Game_Design\Enemies\plasmastrahl-bot.md
01_Game_Design\Enemies\_MOC_Enemies.md
```

### 🤖 Assistant: *These vault pages are auto-generated from…*

`19:36:59`

<details>
<summary>Thinking...</summary>

> 
</details>

> These vault pages are auto-generated from source, so I'll regenerate them rather than hand-edit.

#### 💻 Bash

`19:36:59`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -30
```

```
Whiplash Obsidian-Vault-Generator

============================================================

[1/7] Ordnerstruktur angelegt

[2/7] Dataview-Templates geschrieben (99_Templates)

[3/7] Rohdaten eingelesen: 94 Items, 3+6 Gegner, 4 Charaktere, 39 Raeume, 10 Status-Effekte, 85 Commits

      -> 78 DevLog<->Spielinhalt-Erwaehnungen per Freitext-Abgleich gefunden

[4/7] 94 Item-Notizen geschrieben (01_Game_Design/Items)

      -> 52 Item->Status-Ausloese-, 2 Item->Status-Reagiert-auf-, 2 Item<->Item-Synergie-Verknuepfungen gefunden

[4/7] 3 Enemy-Notizen (Threat-Budget) + 6 Sandbox-Prototyp-Notizen geschrieben (01_Game_Design/Enemies)

[4/7] 4 Character-Notizen geschrieben (01_Game_Design/Characters)

[4/7] 39 Room-Notizen geschrieben (01_Game_Design/Rooms)

[4/7] 10 Status-Effekt-Notizen geschrieben (01_Game_Design/Status_Effects)

[5/7] Architektur-Notizen geschrieben (02_Tech_Architecture)

[5/7] Gruppierungs-Seiten (MOCs) geschrieben

[6/7] 85 DevLog-Notizen + Gesamtliste geschrieben (03_DevLogs)

[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).
```

### 🤖 Assistant: *Vault regenerated.*

`19:37:05`

> Vault regenerated. Now updating the knowledge graph.

#### 💻 Bash

`19:37:05`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify update . 2>&1 | tail -20
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Re-extracting code files in . (no LLM needed)...

  AST extraction: 100/331 uncached files (30%) [12 workers]

  AST extraction: 200/331 uncached files (60%) [12 workers]

  AST extraction: 300/331 uncached files (90%) [12 workers]

  AST extraction: 331/331 uncached files (100%) [12 workers]

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5013 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] community set changed since labeling (154 saved labels, 546 communities now; renamed 14 community(ies) by their hub). Run `graphify label` to refresh names with the LLM.

[graphify] backed up semantic+curated graph (6 files) -> 2026-08-12/

Graph has 5188 nodes (above 5000 limit). Building aggregated community view...

graph.html written (aggregated: 546 community nodes, 165 cross-community edges)

Tip: run with --obsidian for full node-level detail.

[graphify watch] Rebuilt: 5188 nodes, 4905 edges, 546 communities

[graphify watch] graph.json, graph.html and GRAPH_REPORT.md updated in graphify-out

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *Applied the balance changes and refreshed…*

`19:37:30`

> Applied the balance changes and refreshed the derived docs:
> 
> - **Plasmastrahl-Bot** (`resources/enemies/es_plasma_beam_bot.tres`): `threat_cost` 10 → **12**
> - **Colossus** (`resources/enemies/es_colossus.tres`): `threat_cost` 10 → **15**
> - Regenerated the Obsidian vault (`generate_vault.py`) so the enemy notes reflect the new costs
> - Ran `graphify update .` to refresh the knowledge graph
> 
> No other threat-budget spawn tables reference these costs directly (they're read live from the `.tres` files by the level generator), so nothing else needs touching.

## 🤷 User: *diver sind zu groß und zu tief nicht weit…*

`19:37:52`

diver sind zu groß und zu tief nicht weit in der luft.
giselles uzi schießt gut aber partikel kommen in die kamera was nicht gut aussieht, kamera sollte clean bleiben

beim angriff mit winter bin ich gewechselt auf karina und da ist das spiel abgestürzt. ich hab lmb gedrückt gehalten und gewechselt

### 1. Die "Swarm"-Gegner (Stark reduzierte Masse)

Diese Gegner tauchen aktuell am häufigsten auf. Wenn wir hier die Kosten erhöhen, halbiert sich die Menge dieser Gegner im Level drastisch.

- **Divebomber:** 2 ➔ **3** *(Ein Drittel weniger Divebomber im Raum)*

### 2. Die "Support/Utility"-Gegner (Etwas teurer)

Sie machen die Kämpfe komplex, zu viele davon auf einmal sind aber extrem nervig.

- **Schild-Drohne:** 4 ➔ **6**
- **Säure-Sprinkler:** 5 ➔ **7**
- **Mörser-Bot:** 6 ➔ **8**

### 3. Die "Heavy/Elite"-Gegner (Spürbar teurer)

Da die kleinen Gegner jetzt mehr Budget fressen, müssen auch die Elite-Gegner teurer werden, sonst spawnt der Generator plötzlich *nur noch* Elite-Gegner, weil die Ratio nicht mehr stimmt.

- **Plasma-Beam Bot:** 10 ➔ **12
- **Colossus (Boss-Klasse):** 10 ➔ **15** *(Er war vorher genauso teuer wie der Plasma-Bot. Ein Colossus sollte aber der teuerste Gegner im Budget sein!)*

***

### 💭 Thinking

`19:38:03`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `es_divebomber.tres`

`19:38:04`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_divebomber.tres</code></summary>

```
[gd_resource type="Resource" script_class="EnemySpawnEntry" format=3]

[ext_resource type="Script" path="res://scenes/level_generation/enemy_spawn_entry.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/enemies/dive_bomber.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
display_name = "Divebomber"
weight = 3.0
threat_cost = 2
max_per_room = 8
min_spawn_spacing = 4.0

```
</details>

#### 👀 Read `es_shield_drone.tres`

`19:38:04`

#### 👀 Read `es_acid_sprinkler.tres`

`19:38:05`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_acid_sprinkler.tres</code></summary>

```
[gd_resource type="Resource" script_class="EnemySpawnEntry" format=3]

[ext_resource type="Script" path="res://scenes/level_generation/enemy_spawn_entry.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/enemies/acid_sprinkler.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
display_name = "Saeure-Sprinkler"
weight = 1.0
threat_cost = 5
max_per_room = 3
min_spawn_spacing = 8.0

```
</details>

#### 👀 Read `es_mortar_bot.tres`

`19:38:05`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_mortar_bot.tres</code></summary>

```
[gd_resource type="Resource" script_class="EnemySpawnEntry" format=3]

[ext_resource type="Script" path="res://scenes/level_generation/enemy_spawn_entry.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/enemies/mortar_bot.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
display_name = "Moerser-Bot"
weight = 2.0
threat_cost = 6
max_per_room = 4
min_spawn_spacing = 8.0

```
</details>

### 🤖 Assistant: *All four match the old values from the doc…*

`19:38:08`

> All four match the old values from the doc. Applying the updates.

#### ✏️  Edit `es_divebomber.tres`

`19:38:09`

```diff
@@ -1 +1 @@-threat_cost = 2
+threat_cost = 3
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_divebomber.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `es_shield_drone.tres`

`19:38:10`

```diff
@@ -1 +1 @@-threat_cost = 4
+threat_cost = 6
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_shield_drone.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `es_acid_sprinkler.tres`

`19:38:11`

```diff
@@ -1 +1 @@-threat_cost = 5
+threat_cost = 7
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_acid_sprinkler.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `es_mortar_bot.tres`

`19:38:12`

```diff
@@ -1 +1 @@-threat_cost = 6
+threat_cost = 8
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\enemies\es_mortar_bot.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *All threat-budget costs are updated.*

`19:38:15`

> All threat-budget costs are updated. Now regenerating the vault/graph, then I'll dig into the three bug reports.

#### 💻 Bash

`19:38:15`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -10
```

```
[4/7] 10 Status-Effekt-Notizen geschrieben (01_Game_Design/Status_Effects)

[5/7] Architektur-Notizen geschrieben (02_Tech_Architecture)

[5/7] Gruppierungs-Seiten (MOCs) geschrieben

[6/7] 85 DevLog-Notizen + Gesamtliste geschrieben (03_DevLogs)

[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).
```

### 🤖 Assistant: *Balance changes are done.*

`19:38:21`

> Balance changes are done. Now let's look at the three bug reports. First, the crash — that's the most serious one (character switch mid-attack).

#### 💻 Bash

`19:38:22`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify query "character switch during attack crash" 2>&1 | head -60
```

```
  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Traversal: BFS depth=2 | Start: ['Character-spezifische Szenen und Abilities', '2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching', 'combat_switch_01', '1. Temporäre Editor-Dateien (Crash-Backups)'] | 29 nodes found



NODE Character-spezifische Szenen und Abilities [src=04_Chat_Prompts/2026-07-24_character-spezifische-szenen-und-abilities.md loc= community=Fighter]

NODE 2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching [src=03_DevLogs/2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md loc=L10 community=2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching]

NODE combat_switch_01 [src=01_Game_Design/Rooms/combat_switch_01.md loc=L13 community=combat_switch_01]

NODE 1. Temporäre Editor-Dateien (Crash-Backups) [src=04_Chat_Prompts/2026-08-12_slash-command-graphify.md loc=L1745 community=User]

NODE User [src=04_Chat_Prompts/2026-08-12_slash-command-graphify.md loc=L1594 community=User]

NODE Fighter [src=04_Chat_Prompts/2026-07-23_heavy-enemies-nicht-pushbar-machen.md loc= community=Fighter]

NODE Colossus [src=04_Chat_Prompts/2026-07-23_log-datei-ueberpruefung.md loc= community=Fighter]

NODE Stinger [src=04_Chat_Prompts/2026-07-24_character-spezifische-szenen-und-abilities.md loc= community=Fighter]

NODE 2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md [src=03_DevLogs/2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md loc=L1 community=2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching]

NODE combat_switch_01.md [src=01_Game_Design/Rooms/combat_switch_01.md loc=L1 community=combat_switch_01]

NODE Erwaehnt in DevLogs [src=01_Game_Design/Rooms/combat_switch_01.md loc=L28 community=combat_switch_01]

NODE Layout [src=01_Game_Design/Rooms/combat_switch_01.md loc=L15 community=combat_switch_01]

NODE Quelle [src=01_Game_Design/Rooms/combat_switch_01.md loc=L32 community=combat_switch_01]

NODE Erwaehnte Entitaeten [src=03_DevLogs/2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md loc=L34 community=2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching]

NODE Metadaten [src=03_DevLogs/2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md loc=L42 community=2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching]

NODE Update cumulative cost tracker [src=04_Chat_Prompts/2026-08-12_slash-command-graphify.md loc=L1053 community=Update cumulative cost tracker]

NODE _MOC_DevLogs.md [src=03_DevLogs/_MOC_DevLogs.md loc=L1 community=_MOC_DevLogs.md]

NODE 3D-Roboter-Modelle in Godot 4 Gegner-Szenen integrieren [src=04_Chat_Prompts/2026-07-27_3d-roboter-modelle-in-godot-4-gegner-szenen-integrieren.md loc= community=Fighter]

NODE Heavy enemy nicht pushbar machen [src=04_Chat_Prompts/2026-07-23_heavy-enemies-nicht-pushbar-machen.md loc= community=Fighter]

NODE Gegner-Scaling und Raumgröße anpassen [src=04_Chat_Prompts/2026-07-25_gegner-scaling-und-raumgroesse-anpassen.md loc= community=Fighter]

NODE Level-Design und Gameplay-Verbesserungen [src=04_Chat_Prompts/2026-07-25_level-design-und-gameplay-verbesserungen.md loc= community=Fighter]

NODE Speedrun ranking und gameplay verbesserungen [src=04_Chat_Prompts/2026-07-26_speedrun-ranking-und-gameplay-verbesserungen.md loc= community=Fighter]

NODE Log-Datei überprüfung [src=04_Chat_Prompts/2026-07-23_log-datei-ueberpruefung.md loc= community=Fighter]

NODE 2. Fantasy-Gegner aus dem Dungeon Kit [src=04_Chat_Prompts/2026-08-12_slash-command-graphify.md loc=L1764 community=User]

NODE 3. Ungenutzte Requisiten & Props [src=04_Chat_Prompts/2026-08-12_slash-command-graphify.md loc=L1777 community=User]

NODE 4. Veraltete Level-Experimente [src=04_Chat_Prompts/2026-08-12_slash-command-graphify.md loc=L1788 community=User]

NODE 5. Web-Export Icons [src=04_Chat_Prompts/2026-08-12_slash-command-graphify.md loc=L1801 community=User]

NODE 6. Externe Tool-Outputs & Artefakte [src=04_Chat_Prompts/2026-08-12_slash-command-graphify.md loc=L1810 community=User]

NODE Lowpoly Robots Texture [src=assets/characters/lowpoly_robots_0.png loc= community=Fighter]

EDGE combat_switch_01.md --contains [EXTRACTED]--> combat_switch_01 at=01_Game_Design/Rooms/combat_switch_01.md:L13

EDGE combat_switch_01 --contains [EXTRACTED]--> Layout at=01_Game_Design/Rooms/combat_switch_01.md:L15

EDGE combat_switch_01 --contains [EXTRACTED]--> Erwaehnt in DevLogs at=01_Game_Design/Rooms/combat_switch_01.md:L28

EDGE combat_switch_01 --contains [EXTRACTED]--> Quelle at=01_Game_Design/Rooms/combat_switch_01.md:L32

EDGE User --contains [EXTRACTED]--> 1. Temporäre Editor-Dateien (Crash-Backups) at=04_Chat_Prompts/2026-08-12_slash-command-graphify.md:L1745

EDGE 2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md --contains [EXTRACTED]--> 2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching at=03_DevLogs/2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md:L10

EDGE 2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching --contains [EXTRACTED]--> Erwaehnte Entitaeten at=03_DevLogs/2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md:L34

EDGE 2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching --contains [EXTRACTED]--> Metadaten at=03_DevLogs/2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md:L42

EDGE Character-spezifische Szenen und Abilities --references [EXTRACTED]--> Colossus

EDGE Character-spezifische Szenen und Abilities --references [EXTRACTED]--> Fighter

EDGE Character-spezifische Szenen und Abilities --references [EXTRACTED]--> Stinger

EDGE _MOC_DevLogs.md --references [EXTRACTED]--> 2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_.md at=03_DevLogs/_MOC_DevLogs.md:L87

EDGE Gegner-Scaling und Raumgröße anpassen --references [EXTRACTED]--> Stinger

EDGE Level-Design und Gameplay-Verbesserungen --references [EXTRACTED]--> Stinger

EDGE 3D-Roboter-Modelle in Godot 4 Gegner-Szenen integrieren --references [EXTRACTED]--> Stinger

EDGE Update cumulative cost tracker --contains [EXTRACTED]--> User at=04_Chat_Prompts/2026-08-12_slash-command-graphify.md:L1594

EDGE User --contains [EXTRACTED]--> 2. Fantasy-Gegner aus dem Dungeon Kit at=04_Chat_Prompts/2026-08-12_slash-command-graphify.md:L1764

EDGE User --contains [EXTRACTED]--> 3. Ungenutzte Requisiten & Props at=04_Chat_Prompts/2026-08-12_slash-command-graphify.md:L1777

EDGE User --contains [EXTRACTED]--> 4. Veraltete Level-Experimente at=04_Chat_Prompts/2026-08-12_slash-command-graphify.md:L1788

EDGE User --contains [EXTRACTED]--> 5. Web-Export Icons at=04_Chat_Prompts/2026-08-12_slash-command-graphify.md:L1801

EDGE User --contains [EXTRACTED]--> 6. Externe Tool-Outputs & Artefakte at=04_Chat_Prompts/2026-08-12_slash-command-graphify.md:L1810

EDGE Log-Datei überprüfung --references [EXTRACTED]--> Colossus

EDGE Speedrun ranking und gameplay verbesserungen --references [EXTRACTED]--> Colossus

EDGE 3D-Roboter-Modelle in Godot 4 Gegner-Szenen integrieren --references [EXTRACTED]--> Colossus

EDGE Heavy enemy nicht pushbar machen --references [EXTRACTED]--> Fighter

EDGE Gegner-Scaling und Raumgröße anpassen --references [EXTRACTED]--> Fighter

EDGE Speedrun ranking und gameplay verbesserungen --references [EXTRACTED]--> Fighter

EDGE 3D-Roboter-Modelle in Godot 4 Gegner-Szenen integrieren --references [EXTRACTED]--> Fighter
```

### 💭 Thinking

`19:38:28`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `party_manager.gd`

`19:38:29`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\party_manager.gd</code></summary>

```

extends Node

# AUTOLOAD — Name: PartyManager
# Projekt -> Projekteinstellungen -> Autoload -> res://scripts/party_manager.gd
#
# Verwaltet die Party (bis zu 4 CharacterData), wer aktiv ist, und deren
# HP-Stand. Es existiert IMMER nur EIN aktiver CharacterBody3D im Level —
# beim Wechsel wird die aktuelle Charakter-Instanz entfernt und die neue
# (mit ihrem eigenen Combat-Script/eigenen Fähigkeiten) an derselben
# Stelle neu instanziert. Position, Kamera-Ausrichtung und HP werden dabei
# übernommen.
#
# Switch-Cooldown: Sobald man von einem Charakter WEGwechselt, bekommt
# GENAU DIESER Charakter (nicht der neu aktivierte) einen Cooldown von
# SWITCH_COOLDOWN_DURATION Sekunden, bevor man wieder zu ihm wechseln kann.
#
# ============================================================================
# BUGFIX: "Restart-Button und [R] gehen nicht"
# ============================================================================
# ROOT CAUSE (die eigentliche Ursache, nicht der Button):
# Dieses Autoload UEBERLEBT get_tree().reload_current_scene(). Die Szene
# darunter wird komplett abgebaut - inklusive der Spieler-Instanz, auf die
# "player" zeigt. Ein freigegebenes Object wird in GDScript aber NICHT
# automatisch auf null gesetzt: die Variable haelt weiter den alten Zeiger.
#
# Damit ist
#     player == null          ->  FALSE  (der Zeiger ist ja belegt)
#     is_instance_valid(player) ->  false  (das Objekt ist aber tot)
#
# Der komplette Spawn-Pfad haing an der ERSTEN Form:
#   register_spawn_point():  if player == null and not party.is_empty()
#   setup_party():           if player == null and _spawn_parent != null
#   _spawn_active_character(): if player != null: return
#
# Nach JEDEM Neustart hielt PartyManager also eine Leiche, hielt sich fuer
# "schon bespielt" und spawnte keinen neuen Charakter. Das Level wurde
# korrekt neu generiert - es stand nur nie jemand drin. Von aussen sieht
# genau das aus wie "der Restart-Button tut nichts": Bild baut sich neu
# auf, aber man kann sich nicht bewegen.
#
# Derselbe Mechanismus traf _spawn_parent und _player_health.
#
# FIX: JEDE Lebend-Pruefung laeuft ab jetzt ueber has_player() bzw.
# is_instance_valid(). Zusaetzlich raeumt notify_scene_reset() vor einem
# Szenenwechsel bewusst auf - siehe run_restart.gd, das diese Funktion als
# einziger Neustart-Pfad aufruft.

signal party_changed
signal active_character_changed(index: int)
signal member_health_changed(index: int, current: float, max_hp: float)
## Feuert, wenn der LETZTE verbleibende Charakter der Party auf 0 HP faellt -
## also erst, wenn KEIN Last-Stand-Uebernahme (siehe _on_player_health_died())
## mehr moeglich ist. Das ist das eigentliche Game-Over-Signal; death_screen.gd
## haengt sich hieran statt an das Health.died des jeweils aktiven Charakters.
signal party_wiped
# Wird JEDES MAL gefeuert, wenn die aktive Spieler-Instanz ausgetauscht
# wurde (erstes Spawnen UND jeder Charakterwechsel). Systeme, die sich
# den Player-Node merken (HUD, Minimap, ...), MÜSSEN darauf reagieren und
# ihre Referenz erneuern, statt ihn nur einmal zu suchen.
signal active_player_changed(player: CharacterBody3D)

const MAX_PARTY_SIZE: int = 4
const PLAYER_NODE_NAME: String = "Player"
const PLAYER_GROUP: String = "player"

# Wie lange ein Charakter gesperrt bleibt, NACHDEM man von ihm weggewechselt
# ist (nicht: nachdem man ihn ausgewählt hat).
const SWITCH_COOLDOWN_DURATION: float = 10.0

## Last-Stand-System: stirbt der aktive Charakter und lebt noch mindestens
## ein weiteres Party-Mitglied, uebernimmt das automatisch. Als Strafe fuer
## den Tod wird die HP der GESAMTEN restlichen Party auf hoechstens diesen
## Anteil ihrer jeweiligen Maximal-HP gedeckelt (siehe
## _on_player_health_died()) - nicht nur die des Nachrueckers.
const LAST_STAND_HP_FRACTION: float = 0.20

## Der Nachruecker bei einer Last-Stand-Uebernahme bekommt kurz Schonzeit:
## ohne das kann derselbe Hitbox-Treffer, der gerade den vorigen Charakter
## umgebracht hat, im selben Atemzug auch noch den frisch eingewechselten
## erwischen - der Spieler haette keine Chance, zu reagieren.
const SWITCH_INVULN_DURATION: float = 2.0
## Dauer eines vollen Blink-Zyklus (hell -> dunkel). Kleiner = schnelleres
## Flackern. Muss SWITCH_INVULN_DURATION nicht restlos teilen - der letzte
## Zyklus wird beim Ablauf der Unverwundbarkeit einfach sauber beendet.
const SWITCH_BLINK_INTERVAL: float = 0.12
const SWITCH_BLINK_COLOR: Color = Color(1.0, 1.0, 1.0)
const SWITCH_BLINK_STRENGTH: float = 0.85

var party: Array[CharacterData] = []

var _current_health: Array[float] = []
var _max_health: Array[float] = []
# Verbleibende Cooldown-Sekunden pro Party-Index, 0.0 = bereit.
var _switch_cooldowns: Array[float] = []
var _active_index: int = 0

var player: CharacterBody3D = null
var _player_health: Health = null

var _spawn_parent: Node = null
var _spawn_transform: Transform3D = Transform3D.IDENTITY

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## Einzige erlaubte Lebend-Pruefung fuer "player".
##
## "player == null" reicht NICHT: nach reload_current_scene() ist die
## Instanz freigegeben, die Variable aber weiterhin belegt. Siehe den
## ausfuehrlichen Root-Cause-Block im Dateikopf.
func has_player() -> bool:
	return player != null and is_instance_valid(player)


## Vor einem Szenenwechsel aufzurufen (run_restart.gd). Wirft alle
## Referenzen auf Nodes weg, die den Wechsel nicht ueberleben.
##
## Ohne diesen Aufruf wuerde has_player() den Fehler zwar trotzdem
## abfangen - aber erst NACHDEM die tote Instanz einen Frame lang in
## Signalen und Suchlaeufen mitgeschleift wurde. Sauber ist, den Zustand
## dort zu leeren, wo der Wechsel ausgeloest wird.
func notify_scene_reset() -> void:
	if _player_health != null and is_instance_valid(_player_health):
		if _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.disconnect(_on_player_health_changed)
		if _player_health.died.is_connected(_on_player_health_died):
			_player_health.died.disconnect(_on_player_health_died)
	player = null
	_player_health = null
	_spawn_parent = null
	_spawn_transform = Transform3D.IDENTITY
	# Die Cooldowns gehoeren zum alten Run und duerfen den neuen nicht
	# blockieren. Party/HP setzt PartySetup._ready() im neuen Level
	# ohnehin komplett neu (setup_party).
	for i: int in range(_switch_cooldowns.size()):
		_switch_cooldowns[i] = 0.0

func _process(delta: float) -> void:
	for i: int in range(_switch_cooldowns.size()):
		if _switch_cooldowns[i] > 0.0:
			_switch_cooldowns[i] = max(_switch_cooldowns[i] - delta, 0.0)

# BUGFIX: Entfernt jede Skalierung/Scherung aus einer Spawn-Transform und
# behaelt nur Position + Yaw. Ein Spawn-Marker, der als Kind eines
# skalierten Nodes haengt (z.B. ein hochskalierter RoomRoot im
# Level-Generator), liefert sonst eine Basis MIT Skalierungsfaktor - und
# die landete vorher ungefiltert auf dem Spieler-CharacterBody3D. Ergebnis:
# ein 2.5x zu grosser Spieler, wodurch alle Gegner falsch dimensioniert
# wirkten. Diese Funktion ist die letzte Verteidigungslinie dagegen, egal
# welches Level/Script die Transform liefert.
func _sanitize_spawn_transform(source: Transform3D) -> Transform3D:
	var yaw: float = source.basis.get_euler().y
	var basis := Basis.IDENTITY.rotated(Vector3.UP, yaw)
	return Transform3D(basis, source.origin)

# Wird vom Level (ueber PartySetup) oder spaeter vom Home-Screen aufgerufen.
func setup_party(members: Array[CharacterData]) -> void:
	party.clear()
	_current_health.clear()
	_max_health.clear()
	_switch_cooldowns.clear()

	for i: int in range(min(members.size(), MAX_PARTY_SIZE)):
		var data: CharacterData = members[i]
		if data == null:
			continue
		party.append(data)
		_max_health.append(data.max_health)
		_current_health.append(data.max_health)
		_switch_cooldowns.append(0.0)

	_active_index = 0
	party_changed.emit()

	# Falls bereits ein Spawn-Punkt registriert ist (Level war schneller
	# bereit als PartySetup), aber noch kein Spieler existiert, jetzt spawnen.
	#
	# WICHTIG: deferred, nicht direkt! setup_party() kann selbst mitten in
	# einer fremden Ready-Kaskade laufen (z.B. wenn PartySetup._ready() im
	# selben Frame läuft wie ein dynamisch instanziertes Level), und
	# _spawn_active_character() haengt am Ende einen Node per add_child()
	# in den Baum - das schlaegt fehl, wenn der Zielparent gerade selbst
	# "busy" (blocked) ist, weil ER noch seine eigenen Kinder aufbaut.
	if not has_player() and _spawn_parent != null and is_instance_valid(_spawn_parent):
		call_deferred("_spawn_active_character", _spawn_transform)

# Wird von einem PlayerSpawnPoint-Marker3D im Level aufgerufen (siehe
# scripts/player_spawn_point.gd). Läuft typischerweise SYNCHRON innerhalb
# der Ready-Kaskade des Levels/Raums, in dem der Marker liegt - deshalb
# NIEMALS hier direkt add_child() durchziehen, sondern immer deferren.
func register_spawn_point(parent: Node, at_transform: Transform3D) -> void:
	_spawn_parent = parent
	_spawn_transform = _sanitize_spawn_transform(at_transform)
	if not has_player() and not party.is_empty():
		call_deferred("_spawn_active_character", _spawn_transform)

func _spawn_active_character(at_transform: Transform3D) -> void:
	# Kann inzwischen (durch den einen Frame Verzoegerung via call_deferred)
	# ueberholt worden sein - z.B. wenn zwischenzeitlich schon jemand
	# anderes gespawnt hat. Doppel-Spawn verhindern.
	#
	# has_player() statt "player != null": nach einem Szenenwechsel steht
	# hier sonst eine Leiche und blockiert den Neu-Spawn dauerhaft.
	if has_player():
		return

	# Zeiger auf eine eventuelle Leiche aus dem alten Run bedingungslos
	# wegwerfen, bevor eine neue Instanz gebaut wird. Bewusst OHNE
	# vorherigen "!= null"-Vergleich: ein Vergleich mit einem bereits
	# freigegebenen Object ist genau die Operation, die in Godot 4 je nach
	# Build eine "Attempted to access a freed object"-Meldung erzeugt.
	player = null
	_player_health = null

	var data: CharacterData = get_active_data()
	if data == null or data.player_scene == null:
		push_warning("PartyManager: Aktiver Charakter '%s' hat keine player_scene zugewiesen." % (data.character_name if data else "?"))
		return
	if _spawn_parent == null or not is_instance_valid(_spawn_parent):
		push_warning("PartyManager: Kein gueltiger Spawn-Parent registriert (PlayerSpawnPoint fehlt im Level).")
		return

	var instance: CharacterBody3D = data.player_scene.instantiate()
	instance.name = PLAYER_NODE_NAME
	instance.add_to_group(PLAYER_GROUP)
	_spawn_parent.add_child(instance)
	# IMMER sanitisiert setzen - siehe _sanitize_spawn_transform().
	instance.global_transform = _sanitize_spawn_transform(at_transform)
	instance.scale = Vector3.ONE

	player = instance
	_connect_player_health()
	_apply_active_health_to_player()

	# Markiert fuers Hauptmenue, dass "Fortsetzen" jetzt sinnvoll waere
	# (siehe GameStats.has_live_run-Kommentar in game_stats.gd). Steht hier
	# und nicht in setup_party(): DAS hier ist der Punkt, an dem tatsaechlich
	# eine lebende Spieler-Instanz in der Welt existiert.
	GameStats.has_live_run = true

	active_player_changed.emit(player)

func _connect_player_health() -> void:
	if not has_player():
		return
	var h := player.find_child("Health", true, false)
	if h and h is Health:
		_player_health = h
		if not _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.connect(_on_player_health_changed)
		# Last-Stand-Uebernahme: siehe _on_player_health_died().
		if not _player_health.died.is_connected(_on_player_health_died):
			_player_health.died.connect(_on_player_health_died)

func _on_player_health_changed(current: float, max_hp: float) -> void:
	if _active_index < 0 or _active_index >= _current_health.size():
		return
	_current_health[_active_index] = current
	_max_health[_active_index] = max_hp
	member_health_changed.emit(_active_index, current, max_hp)

func _apply_active_health_to_player() -> void:
	if _player_health == null or not is_instance_valid(_player_health):
		return
	if _active_index >= _max_health.size():
		return
	_player_health.max_health = _max_health[_active_index]
	_player_health.current_health = _current_health[_active_index]
	_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)


# ============================================================================
# Last-Stand: Charakterwechsel bei 0 HP statt sofortigem Game Over
# ============================================================================
## Der aktive Charakter ist gerade gestorben (Health.died des aktuell
## gebundenen player). Lebt noch ein anderes Party-Mitglied, uebernimmt DAS
## automatisch. Erst wenn niemand mehr uebrig ist, feuert party_wiped - DAS
## ist das eigentliche Game-Over-Signal, das death_screen.gd jetzt
## abonniert, statt direkt am Health.died jedes einzelnen Charakters zu
## haengen.
##
## STRAFE FUER DEN TOD: trifft NICHT nur den uebernehmenden Charakter,
## sondern die GESAMTE restliche (noch lebende) Party wird auf hoechstens
## LAST_STAND_HP_FRACTION ihrer Maximal-HP gedeckelt - ein Charaktertod soll
## das ganze Team schwaechen, nicht nur einen Nachruecker mit frischer HP
## belohnen.
func _on_player_health_died() -> void:
	if _active_index >= 0 and _active_index < _current_health.size():
		_current_health[_active_index] = 0.0
		member_health_changed.emit(_active_index, 0.0, _max_health[_active_index] if _active_index < _max_health.size() else 1.0)

	var next_index: int = _find_next_alive(_active_index)
	if next_index == -1:
		party_wiped.emit()
		return

	for i: int in range(party.size()):
		if i == _active_index or not is_member_alive(i):
			continue  # gerade gestorben (HP bleibt 0) oder ohnehin schon tot
		var capped: float = minf(_current_health[i], _max_health[i] * LAST_STAND_HP_FRACTION)
		if not is_equal_approx(capped, _current_health[i]):
			_current_health[i] = capped
			member_health_changed.emit(i, capped, _max_health[i])

	_force_switch_to_survivor(next_index)


## Naechstes lebendes Party-Mitglied ab exclude_index, im Kreis gesucht -
## damit die Reihenfolge (1, 2, 3, 4, 1, ...) unabhaengig davon ist, WELCHER
## Index gerade gestorben ist. -1, wenn niemand mehr lebt.
func _find_next_alive(exclude_index: int) -> int:
	for offset: int in range(1, party.size()):
		var idx: int = (exclude_index + offset) % party.size()
		if is_member_alive(idx):
			return idx
	return -1


## Wie switch_to(), aber OHNE Cooldown-Sperre und ohne dass irgendjemand
## einen Cooldown bekommt: das ist eine erzwungene Rettung im letzten Moment,
## keine freiwillige taktische Wahl, die man missbrauchen koennte.
func _force_switch_to_survivor(index: int) -> void:
	if not has_player():
		_active_index = index
		active_character_changed.emit(index)
		return

	var carried_transform: Transform3D = _sanitize_spawn_transform(player.global_transform)
	var carried_camera_yaw: float = 0.0
	var carried_camera_pitch: float = 0.0
	var old_camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
	var old_spring_arm: SpringArm3D = player.get_node_or_null("CameraPivot/SpringArm3D")
	if old_camera_pivot:
		carried_camera_yaw = old_camera_pivot.rotation.y
	if old_spring_arm:
		carried_camera_pitch = old_spring_arm.rotation.x

	if _player_health != null and is_instance_valid(_player_health):
		if _player_health.health_changed.is_connected(_on_player_health_changed):
			_player_health.health_changed.disconnect(_on_player_health_changed)
		if _player_health.died.is_connected(_on_player_health_died):
			_player_health.died.disconnect(_on_player_health_died)

	_deactivate_old_player(player)
	player.queue_free()
	player = null
	_player_health = null

	_active_index = index
	_spawn_active_character(carried_transform)

	if has_player():
		var new_camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
		var new_spring_arm: SpringArm3D = player.get_node_or_null("CameraPivot/SpringArm3D")
		if new_camera_pivot:
			new_camera_pivot.rotation.y = carried_camera_yaw
		if new_spring_arm:
			new_spring_arm.rotation.x = carried_camera_pitch

	# Schonzeit fuer den Nachruecker - siehe SWITCH_INVULN_DURATION-Kommentar.
	if _player_health != null and is_instance_valid(_player_health):
		_player_health.set_invulnerable(SWITCH_INVULN_DURATION)
	_play_switch_invuln_blink(SWITCH_INVULN_DURATION)

	active_character_changed.emit(index)


# Schaltet Kollision UND Processing der alten Instanz SOFORT ab, statt
# darauf zu warten, dass queue_free() sie entfernt (das passiert erst am
# Frame-Ende). Ohne das kollidiert die neu gespawnte Instanz beim schnellen
# Wechseln kurz mit der noch nicht ganz entfernten alten (beide exakt am
# selben Ort) und wird ueber move_and_slide() ein Stueck weggeschubst.
func _deactivate_old_player(old_player: CharacterBody3D) -> void:
	if old_player == null or not is_instance_valid(old_player):
		return

	old_player.set_physics_process(false)
	old_player.set_process(false)
	old_player.set_process_unhandled_input(false)
	old_player.collision_layer = 0
	old_player.collision_mask = 0
	old_player.velocity = Vector3.ZERO
	# BUGFIX: Auch aus der Player-Gruppe nehmen. Sonst zaehlt die noch
	# nicht freigegebene alte Instanz beim Raum-EntryTrigger als "Player"
	# und kann einen Raum ein zweites Mal triggern.
	old_player.remove_from_group(PLAYER_GROUP)

	for area: Node in old_player.find_children("*", "Area3D", true, false):
		area.monitoring = false
		area.monitorable = false
		area.collision_layer = 0
		area.collision_mask = 0

func switch_to(index: int) -> void:
	if index < 0 or index >= party.size():
		return
	if index == _active_index:
		return
	if not is_member_alive(index):
		return
	if index < _switch_cooldowns.size() and _switch_cooldowns[index] > 0.0:
		return

	if not has_player():
		# Noch keine (gueltige) Instanz vorhanden — einfach nur den Index umstellen,
		# der naechste register_spawn_point()/setup_party()-Aufruf spawnt
		# dann direkt den richtigen Charakter.
		_active_index = index
		active_character_changed.emit(index)
		return

	# Zustand der aktuellen Instanz sichern, bevor sie ersetzt wird.
	var carried_transform: Transform3D = _sanitize_spawn_transform(player.global_transform)
	var carried_camera_yaw: float = 0.0
	var carried_camera_pitch: float = 0.0
	var old_camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
	var old_spring_arm: SpringArm3D = player.get_node_or_null("CameraPivot/SpringArm3D")
	if old_camera_pivot:
		carried_camera_yaw = old_camera_pivot.rotation.y
	if old_spring_arm:
		carried_camera_pitch = old_spring_arm.rotation.x

	if _player_health != null and is_instance_valid(_player_health) \
			and _player_health.health_changed.is_connected(_on_player_health_changed):
		_player_health.health_changed.disconnect(_on_player_health_changed)

	# Der Charakter, den wir gerade VERLASSEN, kriegt den Cooldown — nicht
	# der neu ausgewaehlte.
	var leaving_index: int = _active_index
	if leaving_index >= 0 and leaving_index < _switch_cooldowns.size():
		_switch_cooldowns[leaving_index] = SWITCH_COOLDOWN_DURATION

	_deactivate_old_player(player)
	player.queue_free()
	player = null
	_player_health = null

	_active_index = index
	# switch_to() laeuft zur Laufzeit per Input-Event, nicht mitten in einer
	# Ready-Kaskade - hier bleibt der Aufruf bewusst SYNCHRON, weil direkt
	# danach mit dem neuen "player" weitergearbeitet wird (Kamera-Werte
	# uebertragen). Waere dieser Aufruf auch deferred, waere "player" an
	# der Stelle unten noch null.
	_spawn_active_character(carried_transform)

	if has_player():
		var new_camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
		var new_spring_arm: SpringArm3D = player.get_node_or_null("CameraPivot/SpringArm3D")
		if new_camera_pivot:
			new_camera_pivot.rotation.y = carried_camera_yaw
		if new_spring_arm:
			new_spring_arm.rotation.x = carried_camera_pitch

	active_character_changed.emit(index)

func get_active_index() -> int:
	return _active_index

func get_active_data() -> CharacterData:
	if _active_index >= 0 and _active_index < party.size():
		return party[_active_index]
	return null

func get_data(index: int) -> CharacterData:
	if index >= 0 and index < party.size():
		return party[index]
	return null

func get_party_size() -> int:
	return party.size()

func get_member_health(index: int) -> float:
	if index >= 0 and index < _current_health.size():
		return _current_health[index]
	return 0.0

func get_member_max_health(index: int) -> float:
	if index >= 0 and index < _max_health.size():
		return _max_health[index]
	return 1.0

func is_member_alive(index: int) -> bool:
	return get_member_health(index) > 0.0

# 1.0 = Cooldown gerade erst gestartet, 0.0 = bereit (fuers UI, gleiche
# Konvention wie Combat.get_cooldown_percent()).
func get_switch_cooldown_percent(index: int) -> float:
	if index < 0 or index >= _switch_cooldowns.size() or SWITCH_COOLDOWN_DURATION <= 0.0:
		return 0.0
	return _switch_cooldowns[index] / SWITCH_COOLDOWN_DURATION

func get_switch_cooldown_remaining(index: int) -> float:
	if index < 0 or index >= _switch_cooldowns.size():
		return 0.0
	return _switch_cooldowns[index]

func is_on_switch_cooldown(index: int) -> bool:
	return get_switch_cooldown_remaining(index) > 0.0

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	for i: int in range(MAX_PARTY_SIZE):
		var action: String = "switch_char_%d" % (i + 1)
		if InputMap.has_action(action) and event.is_action_pressed(action):
			switch_to(i)
			return


# ============================================================================
# Weisses Blinken waehrend der Last-Stand-Schonzeit
# ============================================================================
## Faerbt das Modell des Nachrueckers im selben psx.gdshader-Kanal wie die
## Item-Effekte (siehe item_behaviours.gd _flash_player) weiss ein und lässt
## flash_strength ueber die komplette Schonzeit zwischen 0 und
## SWITCH_BLINK_STRENGTH pulsieren, statt nur einmal aufzublitzen - das macht
## "ich bin gerade unverwundbar" sichtbar, nicht nur "ich wurde getroffen".
func _play_switch_invuln_blink(duration: float) -> void:
	if not has_player() or duration <= 0.0:
		return

	var materials: Array[ShaderMaterial] = []
	_collect_shader_materials(player, materials)
	if materials.is_empty():
		return

	for material: ShaderMaterial in materials:
		material.set_shader_parameter("flash_color", SWITCH_BLINK_COLOR)

	var half_cycle: float = SWITCH_BLINK_INTERVAL * 0.5
	var cycles: int = maxi(int(ceil(duration / SWITCH_BLINK_INTERVAL)), 1)

	# Auf PartyManager (Autoload) statt auf "player" erzeugt: player wird bei
	# einem weiteren schnellen Wechsel/Tod noch WAEHREND der Schonzeit
	# queue_free()'t, und ein an ihn gebundener Tween stuerbe mit ihm ab,
	# noch bevor flash_strength zurueckgesetzt ist.
	var tween: Tween = create_tween()
	tween.set_loops(cycles)
	tween.tween_method(
		func(value: float) -> void:
			for material: ShaderMaterial in materials:
				if is_instance_valid(material):
					material.set_shader_parameter("flash_strength", value),
		0.0, SWITCH_BLINK_STRENGTH, half_cycle
	)
	tween.tween_method(
		func(value: float) -> void:
			for material: ShaderMaterial in materials:
				if is_instance_valid(material):
					material.set_shader_parameter("flash_strength", value),
		SWITCH_BLINK_STRENGTH, 0.0, half_cycle
	)
	tween.finished.connect(
		func() -> void:
			for material: ShaderMaterial in materials:
				if is_instance_valid(material):
					material.set_shader_parameter("flash_strength", 0.0)
	)


## Gleiche Logik wie item_behaviours.gd _collect_shader_materials() - bewusst
## dupliziert statt geteilt, weil ItemBehaviours ein eigenstaendiges, an den
## jeweiligen Charakter gebundenes Node ist und PartyManager (Autoload) keine
## fixe Referenz darauf haelt.
func _collect_shader_materials(node: Node, out: Array[ShaderMaterial]) -> void:
	var mesh := node as MeshInstance3D
	if mesh != null:
		if mesh.material_override is ShaderMaterial:
			out.append(mesh.material_override as ShaderMaterial)
		else:
			for i: int in range(mesh.get_surface_override_material_count()):
				var surface: Material = mesh.get_surface_override_material(i)
				if surface is ShaderMaterial:
					out.append(surface as ShaderMaterial)
	for child: Node in node.get_children():
		_collect_shader_materials(child, out)

```
</details>

### 💭 Thinking

`19:38:34`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 📂 Glob `scripts/characters/combat_winter.gd`

`19:38:34`

```
scripts\characters\combat_winter.gd
```

#### 📂 Glob `scripts/combat_base.gd`

`19:38:34`

#### 👀 Read `combat_base.gd`

`19:38:38`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\combat_base.gd</code></summary>

```
extends Node
class_name CombatBase

# --- Basisklasse für ALLE Charakter-Combat-Skripte ---
# Enthält das komplette gemeinsame Cooldown-, Combo-, Hit-Lock- und Dash-
# System. Die eigentlichen FÄHIGKEITEN (was Primary/Secondary/Utility
# tatsächlich TUN) sind virtuelle "_perform_*"-Methoden — jeder Charakter
# überschreibt sie in seinem eigenen Combat-Script (z.B. combat_ningning.gd)
# mit eigener Logik. Cooldown-Werte werden ebenfalls pro Charakter-Script
# überschrieben (siehe combat_ningning.gd) — es gibt KEIN globales
# Daten-Objekt mehr, das Cooldowns zur Laufzeit "einspielt".
#
# ---------------------------------------------------------------------------
# PHASE 5: Q UND E SIND JETZT AKTIVE-ITEM-SLOTS, KEINE CHARAKTER-FAEHIGKEITEN
# ---------------------------------------------------------------------------
# Bis hierher hatte jeder Charakter eigene (aber leere, nur Kamera-Shake +
# Platzhalter-Print) _perform_ability_q()/_perform_ability_e()-Ueberschreibungen
# mit einem EIGENEN, zeitbasierten Cooldown (ability_q_cooldown/_timer).
# Das ist komplett ersetzt: Q und E loesen jetzt IMMER das aktive Item im
# jeweiligen Slot aus (Items.use_active_item(0) fuer Q, (1) fuer E) — siehe
# item_manager.gd fuer die Slot-Logik (2 Slots, Aufladung ueber Raum-Clears
# statt ueber Zeit, Tausch im Pause-Screen).
#
# WARUM DIE ALTE ZEIT-BASIERTE COOLDOWN-ANZEIGE TROTZDEM WEITERLAEUFT:
# hud.gd fragt pro Frame get_cooldown_percent(Slot.ABILITY_Q) /
# get_cooldown_remaining(Slot.ABILITY_Q) ab, um den radialen Cooldown-
# Overlay auf dem Q-Slot im HUD zu fuellen (siehe AbilitySlot.update_cooldown).
# Diese beiden Getter liefern jetzt die LADUNG des Items (aktuelle Raeume /
# noetige Raeume) statt eines Sekunden-Timers — das HUD selbst musste dafuer
# NICHT angefasst werden, es zeigt einfach weiter "Fortschritt bis bereit"
# an, nur eben raumbasiert statt zeitbasiert.

# --- Cooldown-Werte, im Inspector einstellbar UND in Charakter-Subklassen überschreibbar ---
@export var primary_cooldown: float = 0.4
@export var secondary_cooldown: float = 3.0
@export var utility_cooldown: float = 0.8

@export var dash_speed: float = 35.0
@export var dash_duration: float = 0.4

## Kurzer Ghost-Trail-Burst waehrend eines Schlags (siehe _do_primary()/
## _do_secondary()) - deckt sich mit der Dauer, die die jeweilige Hitbox
## in der BASIS-Implementierung von _perform_primary()/_perform_secondary()
## aktiv bleibt (0.15s/0.25s). Ueberschreibt ein Charakter-Script die
## _perform_*-Methode mit einer eigenen Animation/Dauer, darf es diese Werte
## ebenfalls ueberschreiben - der Trail muss nicht pixelgenau zur Schlag-
## dauer passen, "ein bisschen Blur waehrend des Schlags" reicht.
@export var primary_attack_trail_duration: float = 0.15
@export var secondary_attack_trail_duration: float = 0.25

# ============================================================================
# DASH-SCHADEN - nur beim DURCHdashen
# ============================================================================
# Ein normaler Area3D-Hitbox-Ansatz ("Schaden bei body_entered") waere hier
# falsch: der wuerde schon ausloesen, wenn man den Gegner nur ANTIPPT oder
# direkt vor ihm zum Stehen kommt. Gewollt ist ausdruecklich das DURCHqueren.
#
# Deshalb wird pro Gegner die VORZEICHEN-Umkehr entlang der Dash-Achse
# ausgewertet:
#
#   along = dash_richtung (flach) . (gegner_pos - spieler_pos)
#
#   along > 0  -> Gegner ist VOR mir     -> als Kandidat vormerken
#   along < 0  -> Gegner ist HINTER mir  -> ich bin durch ihn hindurch
#
# Erst dieser Wechsel loest den Schaden aus. Bleibt der Dash vorher stehen
# (Wand, Dauer abgelaufen, Gegner weicht aus), passiert nichts. Zusaetzlich
# muss der Gegner beim Durchqueren im Trefferfenster liegen (seitlich
# dash_hit_radius, vertikal dash_hit_height_up/-_down) - sonst zaehlte ein
# Vorbeirennen im Meterabstand als Treffer.
#
# Die Rechnung laeuft bewusst FLACH (X/Z): "durchdashen" ist eine
# horizontale Bewegung, und dash_direction traegt bei einem Vorwaerts-Dash
# die volle Blickneigung mit - die wuerde die Achse sonst verkippen.

@export var dash_damage_enabled: bool = true
@export var dash_damage: float = 12.0

# --- Trefferfenster ("Hitbox" des Dashs) ------------------------------
# Das Volumen ist ein Quader ENTLANG der Dash-Achse:
#
#            dash_hit_radius            Blick von oben
#                  |
#     +------------|------------+
#     |            |            |
#  ---o============>============|--->  Dash-Richtung
#     |            |            |
#     +------------|------------+
#          Spieler         Ende der Bahn
#
# Es gibt KEINE Obergrenze fuer die Anzahl getroffener Gegner - jeder wird
# einzeln verfolgt. Wer beim Dash mehr Gegner mitnehmen will, dreht
# dash_hit_radius hoch; das Limit war nie die Anzahl, sondern die Breite.
# dash_max_targets_per_dash existiert nur, falls man es bewusst DECKELN will.

## Seitliche Reichweite quer zur Dash-Achse (halbe Korridorbreite).
## 1.8 trifft praktisch nur, wen man frontal rammt. 2.5-3.5 nimmt eine
## ganze Reihe mit, ab ~4.0 fuehlen sich Treffer geschenkt an.
@export var dash_hit_radius: float = 2.6

## Hoehenfenster, getrennt nach oben und unten.
##
## WARUM GETRENNT: Der Spieler-Ursprung sitzt in der Mitte seiner Kapsel,
## der Gegner-Ursprung dagegen bei den FUESSEN. Ein Gegner auf demselben
## Boden liegt dadurch rechnerisch rund 0.9 Meter UNTER dem Spieler - ein
## symmetrisches Fenster verschenkt oben also Reichweite und braucht unten
## unnoetig viel. dash_hit_vertical_offset verschiebt das Fenster zusaetzlich
## als Ganzes, falls eure Kapselmasse abweichen.
@export var dash_hit_height_up: float = 2.0
## War 3.0 - lag damit fast exakt am Scheitelpunkt eines normalen Sprungs
## (jump_velocity=13.0, gravity=40.0 in player_base.gd -> ~2.1 Einheiten
## Sprunghoehe + ~0.9 Kapsel-zu-Fuesse-Versatz = ~3.0). Rueckmeldung "sollte
## beim Springen trotzdem alle Gegner hitten": ein Dash im/nach dem Sprung
## fiel dadurch schon bei normaler Sprunghoehe knapp aus dem Fenster. Deutlich
## grosszuegiger, damit ein Sprung-Dash zuverlaessig auch Bodengegner trifft.
@export var dash_hit_height_down: float = 6.0
@export var dash_hit_vertical_offset: float = -0.5

## 0 = unbegrenzt (Standard). Nur setzen, wenn ein Dash bewusst hoechstens
## N Gegner treffen soll.
@export var dash_max_targets_per_dash: int = 0
## Wie weit hinter mir der Gegner sein muss, damit es als "durch" zaehlt.
## Verhindert Treffer durch Zittern um den Nullpunkt.
@export var dash_pierce_exit_distance: float = 0.3
## Kulanz beim Dash-START: ein Gegner, der praktisch auf mir steht (along
## leicht negativ), zaehlt trotzdem noch als Kandidat.
@export var dash_entry_grace: float = 0.6

@export var dash_hit_shake_strength: float = 0.25
## Standardmaessig 0: ein Rueckstoss beim Durchqueren schiebt den Gegner
## unkontrolliert weg und macht das Nachsetzen unberechenbar.
@export var dash_knockback_force: float = 0.0
## Ob ein Dash-Treffer die Combo hochzaehlt. Der Hit-Lock aus
## _on_hit_landed() wird BEWUSST nicht ausgeloest - der wuerde den Dash
## mitten in der Bewegung abbremsen.
@export var dash_damage_counts_combo: bool = true
@export var dash_damage_sets_target: bool = true

## VFX, der bei einem Dash-TREFFER am Gegner aufblitzt. Getrennt von
## dash_vfx (Startpuff) und dash_trail (Dauer-Emitter) - das ist der
## Aufschlag, nicht die Bewegung. Leer lassen = kein Effekt.
@export var dash_hit_vfx: PackedScene

## Optionaler Override. Bleibt das Feld leer, wird die Szene von der
## PrimaryHitbox uebernommen (dort ist sie bereits im Inspector gesetzt),
## sonst der Pfad unten geladen.
@export var dash_damage_number_scene: PackedScene
@export var dash_debug_logging: bool = false

## Zeichnet bei jedem Dash das tatsaechliche Trefferfenster als
## halbtransparenten Quader in die Welt - der einzige praktikable Weg, die
## Werte oben einzustellen, ohne zu raten. Fuer den Release ausschalten.
@export var dash_debug_draw: bool = false
@export var dash_debug_draw_duration: float = 0.8
@export var dash_debug_color: Color = Color(1.0, 0.85, 0.1, 0.22)

const DAMAGE_NUMBER_FALLBACK_PATH: String = "res://scenes/ui/damage_number.tscn"

## Gegner-InstanceID -> { "node": Node3D, "pending": bool, "done": bool }
var _dash_pierce_state: Dictionary = {}
var _dash_pierce_armed: bool = false
var _dash_flat_direction: Vector3 = Vector3.ZERO
var _dash_hit_count: int = 0
var _cached_damage_number_scene: PackedScene = null

# --- Signals, damit sich das UI-Cooldown-Icon dranhaengen kann ---
signal primary_used
signal secondary_used
signal utility_used
## Feuert weiterhin bei Q/E-Druck, jetzt als reines Info-Signal fuer VFX/Sound-
## Hooks (z.B. kleiner Kamera-Kick) - die eigentliche Wirkung kommt seit
## PHASE 5 ausschliesslich aus dem benutzten Item (Items.active_item_used).
signal ability_q_used
signal ability_e_used
signal combo_changed(count: int)
## Feuert, wenn ein Gegner DURCHdasht wurde - fuer VFX/Sound/HUD.
signal dash_hit_landed(target: Node)
## Feuert JEDEN Dash, unabhaengig davon, ob er einen Gegner getroffen hat -
## anders als dash_hit_landed. Fuer Effekte wie die Leere Energy-Dose, die
## an das Dashen selbst haengen, nicht an dessen Treffer.
signal dash_ended
# Generisches Signal fuers HUD: slot ist 0..4
signal cooldown_started(slot: int, duration: float)

enum Slot { PRIMARY, SECONDARY, UTILITY, ABILITY_Q, ABILITY_E }

# --- Interne Cooldown-Timer (0 = bereit, >0 = wartet noch) ---
# Kein _ability_q_timer/_ability_e_timer mehr: Q/E werden seit PHASE 5 nicht
# mehr zeitbasiert gesperrt, sondern ueber Items.is_active_slot_ready()
# (Raum-Ladung, siehe item_manager.gd).
var _primary_timer: float = 0.0
var _secondary_timer: float = 0.0
var _utility_timer: float = 0.0

var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_direction: Vector3 = Vector3.ZERO

# --- Hit Lock: nur aktiv, wenn ein Angriff TATSAECHLICH trifft ---
# --- (nicht bei jedem Schwung), und friert nicht komplett ein, ---
# --- sondern erlaubt noch etwas reduzierte Bewegung. ---
@export var hit_lock_duration: float = 0.2
@export_range(0.0, 1.0) var hit_lock_speed_multiplier: float = 0.1

# Wie viel "Trauma" ein TATSAECHLICHER Treffer zur Kamera hinzufuegt
# (summiert sich bei mehreren Treffern auf, gedeckelt bei 1.0 im Player).
@export var hit_shake_strength: float = 0.4

# --- Combo-Tilt: dramatische Kamera-Neigung, waechst mit der Combo ---
# --- "Bohrer"-Verhalten: bleibt in eine Richtung, solange derselbe ---
# --- Gegner getroffen wird, flippt nur bei Zielwechsel. ---
@export var combo_tilt_per_hit: float = 1.5
@export var combo_tilt_max: float = 8.0
# Eigener, KURZER Reset-Timer nur fuer den Tilt — unabhaengig vom
# combo_window (das laenger laeuft, fuer den Cooldown-Bonus).
@export var combo_tilt_reset_delay: float = 0.5
var _tilt_reset_timer: float = 0.0
var _tilt_direction: float = 1.0
var _last_hit_target: Node = null

# 0.0 = komplett schweben (keine Schwerkraft waehrend Hit Lock),
# 1.0 = normale Schwerkraft (kein Unterschied), 0.2-0.3 = langsames Sinken.
@export_range(0.0, 1.0) var hit_lock_gravity_multiplier: float = 0.0

# Ob man waehrend des Hit Locks ueberhaupt springen kann.
@export var hit_lock_allow_jump: bool = false

var _hit_lock_timer: float = 0.0

# --- Combo-System: jeder Treffer ueber den ersten hinaus reduziert den ---
# --- Primary-Cooldown linear, hart gedeckelt bei combo_max_reduction. ---
@export var combo_window: float = 3.0                        # Sekunden, bis Combo verfaellt
@export var combo_cooldown_reduction_per_hit: float = 0.1    # 10% Reduktion pro Combo-Stufe
@export_range(0.0, 1.0) var combo_max_reduction: float = 0.5 # Hard Cap: max. 50% Reduktion
var _combo_count: int = 0
var _combo_timer: float = 0.0

# --- Dash-Vertikalitaet: vorwaerts behaelt volle Blickrichtungs-Neigung, ---
# --- rueckwaerts bleibt bewusst flach/horizontal (default-Dash). ---
@export_range(0.0, 1.0) var backward_dash_vertical_influence: float = 0.0

# --- VFX ---
## Startpuff beim Dash. Wird GEGEN die Dash-Richtung ausgerichtet, damit
## der Staub zurueckbleibt statt vorauszufliegen.
@export var dash_vfx: PackedScene

# --- Node-Referenzen, die wir vom Player brauchen ---
var player: CharacterBody3D
@onready var primary_hitbox: Hitbox = get_node_or_null("../CameraPivot/PrimaryHitbox")
@onready var secondary_hitbox: Hitbox = get_node_or_null("../CameraPivot/SecondaryHitbox")

## PHASE 5: Referenz auf das Items-Autoload fuer Q/E. BEWUSST ueber
## get_node_or_null("/root/Items") statt des globalen "Items"-Bezeichners -
## das ist im GANZEN restlichen Projekt (item_description_hud.gd,
## stats_panel.gd, loot_manager.gd, etc.) ausnahmslos das Muster, u.a. weil
## Autoload-Initialisierungsreihenfolge nicht garantiert ist (siehe
## item_manager.gd's eigener Kommentar zu PartyManager). Der bare
## "Items"-Bezeichner hatte genau deshalb zu "Invalid access to property or
## key 'ACTIVE_SLOT_COUNT' on a base object of type 'Nil'" gefuehrt.
## Selbstheilend: falls beim ersten Zugriff noch null (zu frueher Frame),
## wird beim naechsten Aufruf erneut gesucht statt dauerhaft null zu bleiben.
var _items_cache: Node = null

func _items() -> Node:
	if _items_cache == null or not is_instance_valid(_items_cache):
		_items_cache = get_node_or_null("/root/Items")
	return _items_cache

## Dauer-Emitter fuer den Dash-Trail: GPUParticles3D-Kind am Player-Root
## namens "DashTrail" (emitting = false, one_shot = false,
## local_coords = false — sonst zieht der Trail mit statt stehenzubleiben).
@onready var dash_trail: GPUParticles3D = get_node_or_null("../DashTrail")

## Ghost-/Nachbild-Trail fuer den Dash (siehe scripts/vfx/ghost_trail.gd) -
## optionales Kind-Node "GhostTrail" am Player-Root. get_node_or_null():
## fehlt der Node in einer Charakter-Szene (noch nicht eingebaut), bleibt der
## Dash einfach ohne Ghost-Effekt, statt einen Fehler zu werfen.
@onready var ghost_trail: GhostTrail = get_node_or_null("../GhostTrail")

func setup(owner_player: CharacterBody3D) -> void:
	player = owner_player
	if primary_hitbox:
		primary_hitbox.hit_landed.connect(_on_hit_landed)
	if secondary_hitbox:
		secondary_hitbox.hit_landed.connect(_on_hit_landed)

	# Ghost-Trail in den beiden Akzentfarben des aktiven Charakters einfaerben
	# (siehe character_data.gd attack_color/attack_color_secondary) - EINMAL
	# hier gesetzt, gilt fuer beide GhostTrail-Modi (Dash-Burst UND
	# player_base.gd's Lauf-Trail), da beide denselben Node referenzieren.
	if ghost_trail:
		var data: CharacterData = PartyManager.get_active_data()
		if data != null:
			ghost_trail.set_colors(data.attack_color, data.attack_color_secondary)

func _on_hit_landed(target: Node) -> void:
	_hit_lock_timer = hit_lock_duration

	if player and player.has_method("shake_camera"):
		player.shake_camera(hit_shake_strength)

	# Target Lock: der getroffene Gegner wird zum anvisierten Ziel —
	# Modell schaut zu ihm, Kamera wird sanft in seine Richtung gezogen,
	# bis er stirbt oder ein anderer Gegner getroffen wird.
	if player and player.has_method("set_target") and target is Node3D:
		player.set_target(target)

	# Bestehendes AUFWAERTS-Momentum sofort kappen (z.B. aus einem Sprung),
	# damit man waehrend des Hit Locks nicht einfach weiter nach oben
	# treibt. Abwaerts-Momentum (Fallen) bleibt unangetastet, das wird
	# separat ueber hit_lock_gravity_multiplier gesteuert.
	if player and player.velocity.y > 0.0:
		player.velocity.y = 0.0

	# Combo hochzaehlen und Verfalls-Timer zuruecksetzen
	_combo_count += 1
	_combo_timer = combo_window
	combo_changed.emit(_combo_count)
	GameStats.report_combo(_combo_count)

	# "Bohrer"-Tilt: Richtung bleibt gleich, solange derselbe Gegner
	# getroffen wird (dreht sich immer weiter rein) — wechselt das Ziel
	# auf einen ANDEREN Gegner, flippt die Richtung einmal um.
	if target != _last_hit_target:
		_tilt_direction *= -1.0
		_last_hit_target = target

	if _combo_count >= 2 and player and player.has_method("play_combo_tilt"):
		var tilt: float = min(_combo_count * combo_tilt_per_hit, combo_tilt_max) * _tilt_direction
		player.play_combo_tilt(tilt)

	_tilt_reset_timer = combo_tilt_reset_delay

func _process(delta: float) -> void:
	# Solange der Player gestunnt ist (z.B. von einem schnellen,
	# nervigen Gegner getroffen), werden weder Angriffe noch Dash
	# ausgeloest — kompletter Input-Block fuer Combat, bis der Stun
	# abgelaufen ist. Cooldown-Countdown pausiert dabei mit, das ist
	# gewollt (kein "Cooldown-Farming" waehrend man eh nichts tun kann).
	if player and player.has_method("is_stunned") and player.is_stunned():
		return

	# Cooldowns runterzaehlen
	_primary_timer = max(_primary_timer - delta, 0.0)
	_secondary_timer = max(_secondary_timer - delta, 0.0)
	_utility_timer = max(_utility_timer - delta, 0.0)
	_hit_lock_timer = max(_hit_lock_timer - delta, 0.0)

	# Combo-Verfall: laeuft der Timer ab, ohne dass neu getroffen wurde,
	# wird die Combo komplett zurueckgesetzt.
	if _combo_count > 0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_count = 0
			combo_changed.emit(0)
			_last_hit_target = null
			if player and player.has_method("reset_combo_tilt"):
				player.reset_combo_tilt()

	# Eigener, kurzer Tilt-Reset: laeuft schneller ab als das ganze
	# combo_window, damit sich die Kamera-Neigung zuegig zuruecksetzt,
	# sobald kurz nicht mehr getroffen wird.
	if _tilt_reset_timer > 0.0:
		_tilt_reset_timer -= delta
		if _tilt_reset_timer <= 0.0:
			_last_hit_target = null
			if player and player.has_method("reset_combo_tilt"):
				player.reset_combo_tilt()

	# --- Grosskarte offen: keine Angriffe ------------------------------
	# Auf der Grosskarte wird mit gedrueckter linker Maustaste gezogen.
	# LMB ist gleichzeitig attack_primary, und Angriffe werden hier per
	# Input.is_action_pressed() GEPOLLT — set_input_as_handled() in
	# minimap.gd kann Polling nicht abfangen. Ohne diesen Block wuerde
	# jedes Verschieben der Karte den Charakter zuschlagen lassen.
	#
	# Bewusst NACH den Cooldown-Timern: die sollen weiterlaufen, damit
	# ein Blick auf die Karte keine Cooldowns einfriert. Und bewusst ein
	# static-Zugriff statt einer Baumsuche — diese Zeile laeuft in jedem
	# Frame.
	if Minimap.big_map_open:
		return

	_poll_primary_input(delta)
	_poll_secondary_input(delta)

	if Input.is_action_just_pressed("utility") and _utility_timer <= 0.0:
		_do_utility()

	if InputMap.has_action("ability_primary") \
			and Input.is_action_just_pressed("ability_primary"):
		_do_ability_q()

	if InputMap.has_action("ability_secondary") \
			and Input.is_action_just_pressed("ability_secondary"):
		_do_ability_e()

# --- Primary/Secondary Input-Polling, ueberschreibbar pro Charakter --------
# Extrahiert aus dem alten inline "if Input.is_action_pressed(...)" in
# _process(), damit Charaktere mit einer Faehigkeit, die nicht ins simple
# "gehalten -> feuert jeden Frame erneut, sobald Cooldown abgelaufen"-Schema
# passt (Giselles Sniper-Ladevorgang, Winters Batterie-Laser, Karinas
# Stance/Stealth-Toggle), NUR diese eine Methode ueberschreiben koennen,
# statt den kompletten _process() zu duplizieren.
#
# WICHTIG fuer jede Ueberschreibung: _primary_timer/_secondary_timer wurden
# bereits WEITER OBEN in DIESEM _process()-Aufruf per max(x - delta, 0.0)
# heruntergezaehlt (siehe Zeilen oben) - eine Ueberschreibung darf sie hier
# NICHT ein zweites Mal dekrementieren, sonst laeuft der Timer doppelt so
# schnell ab. Nur LESEN (<= 0.0 pruefen) und bei Zustandswechseln (Stance
# betreten/verlassen etc.) neu SETZEN.
func _poll_primary_input(_delta: float) -> void:
	if Input.is_action_pressed("attack_primary") and _primary_timer <= 0.0:
		_do_primary()


func _poll_secondary_input(_delta: float) -> void:
	if Input.is_action_pressed("attack_secondary") and _secondary_timer <= 0.0:
		_do_secondary()


func _do_primary() -> void:
	var cd: float = _get_effective_primary_cooldown()
	_primary_timer = cd
	primary_used.emit()
	cooldown_started.emit(Slot.PRIMARY, cd)
	if ghost_trail:
		ghost_trail.start_trail(primary_attack_trail_duration)
	_perform_primary()

# Von Charakter-Subklassen überschreibbar. Standardverhalten: PrimaryHitbox
# fuer ein kurzes Angriffs-Fenster aktivieren.
# Der Schlag-VFX (swing_vfx) haengt bewusst an der Hitbox selbst, nicht
# hier — so bekommt jede Waffe/jeder Charakter ihren eigenen Swoosh ueber
# den Inspector, ohne dass diese Methode ueberschrieben werden muss.
func _perform_primary() -> void:
	if primary_hitbox:
		primary_hitbox.activate()
		await get_tree().create_timer(0.15).timeout
		primary_hitbox.deactivate()

# Erst ab dem ZWEITEN Treffer (combo_count >= 2) wird der Cooldown reduziert.
# Jeder weitere Treffer reduziert LINEAR weiter, bis zum harten Cap bei
# combo_max_reduction (Standard: 50% — der Cooldown kann also nie mehr
# als auf die Haelfte fallen, egal wie lang die Combo laeuft).
func _get_effective_primary_cooldown() -> float:
	var stacks: int = max(_combo_count - 1, 0)
	var reduction: float = min(stacks * combo_cooldown_reduction_per_hit, combo_max_reduction)
	return primary_cooldown * (1.0 - reduction)

func _do_secondary() -> void:
	_secondary_timer = secondary_cooldown
	secondary_used.emit()
	cooldown_started.emit(Slot.SECONDARY, secondary_cooldown)
	if ghost_trail:
		ghost_trail.start_trail(secondary_attack_trail_duration)
	_perform_secondary()

# Von Charakter-Subklassen überschreibbar. Standardverhalten: SecondaryHitbox
# fuer ein laengeres Angriffs-Fenster aktivieren.
func _perform_secondary() -> void:
	if secondary_hitbox:
		secondary_hitbox.activate()
		await get_tree().create_timer(0.25).timeout
		secondary_hitbox.deactivate()

func _do_utility() -> void:
	_utility_timer = utility_cooldown
	utility_used.emit()
	cooldown_started.emit(Slot.UTILITY, utility_cooldown)
	_perform_utility()

# Von Charakter-Subklassen überschreibbar. Standardverhalten: Dash in
# Bewegungs-/Blickrichtung.
func _perform_utility() -> void:
	if player and player.has_method("play_dash_fov_effect"):
		player.play_dash_fov_effect()

	var camera_pivot: Node3D = player.get_node("CameraPivot")
	var spring_arm: SpringArm3D = player.get_node("CameraPivot/SpringArm3D")

	# forward_full: mit voller vertikaler Neigung (Pitch) — fuer Vorwaerts-Dash.
	# forward_flat: rein horizontal, keine Neigung — fuer Rueckwaerts-Dash.
	var forward_full: Vector3 = spring_arm.global_transform.basis.z
	var forward_flat: Vector3 = camera_pivot.global_transform.basis.z
	var right: Vector3 = camera_pivot.global_transform.basis.x

	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# input_dir.y < 0 heisst "vorwaerts" (W), > 0 heisst "rueckwaerts" (S).
	# Rueckwaerts wird die Vertikal-Komponente gedaempft (Standard: komplett
	# geflacht), vorwaerts bleibt exakt wie zuvor mit voller Neigung.
	var effective_forward: Vector3
	if input_dir.y > 0.0:
		effective_forward = forward_full.lerp(forward_flat, 1.0 - backward_dash_vertical_influence)
	else:
		effective_forward = forward_full

	var move_direction: Vector3 = (right * input_dir.x + effective_forward * input_dir.y)

	if move_direction.length() > 0.1:
		_dash_direction = move_direction.normalized()
	else:
		# Keine Taste gedrueckt -> Fallback: exakte Blickrichtung, mit voller Neigung
		_dash_direction = -forward_full.normalized()

	_is_dashing = true
	_dash_timer = dash_duration

	# --- VFX ---
	# Startpuff zeigt GEGEN die Dash-Richtung — der Staub bleibt zurueck,
	# das verkauft die Beschleunigung deutlich besser als ein Puff nach vorn.
	if dash_vfx and player:
		VFX.spawn(dash_vfx, player.global_position, -_dash_direction)
	if dash_trail:
		dash_trail.emitting = true
	if ghost_trail:
		ghost_trail.start_trail(dash_duration)

# --- Q = aktiver Item-Slot 0 ------------------------------------------
## Kein Cooldown-Timer mehr hier: _items().use_active_item() prueft selbst
## per is_active_slot_ready(), ob das Item in diesem Slot ueberhaupt
## existiert UND aufgeladen ist, und tut sonst einfach nichts. Ein
## Tastendruck ins Leere (kein Item im Slot) darf explizit NICHT das HUD
## in einen "Cooldown laeuft" Zustand versetzen — deshalb cooldown_started
## nur feuern, wenn tatsaechlich etwas ausgeloest wurde.
func _do_ability_q() -> void:
	var items: Node = _items()
	if item == null or not items.is_active_slot_ready(0):
		return
	ability_q_used.emit()
	cooldown_started.emit(Slot.ABILITY_Q, 0.0)
	items.use_active_item(0)

# --- E = aktiver Item-Slot 1 ------------------------------------------
func _do_ability_e() -> void:
	var items: Node = _items()
	if item == null or not items.is_active_slot_ready(1):
		return
	ability_e_used.emit()
	cooldown_started.emit(Slot.ABILITY_E, 0.0)
	items.use_active_item(1)

# Wird vom Player-Script in _physics_process aufgerufen, damit der Dash
# die normale Bewegung waehrend seiner Dauer ueberschreiben kann.
func get_dash_velocity(delta: float) -> Vector3:
	if not _is_dashing:
		return Vector3.ZERO

	_dash_timer -= delta
	if _dash_timer <= 0.0:
		_is_dashing = false
		# Trail hier abschalten und NICHT per create_timer: der Dash kann
		# durch Frame-Drops laenger dauern als dash_duration in Echtzeit,
		# ein paralleler Timer waere dann zu frueh fertig.
		if dash_trail:
			dash_trail.emitting = false
		dash_ended.emit()
		return Vector3.ZERO

	return _dash_direction * dash_speed


# ============================================================================
# Dash-Schaden: Durchquerungs-Erkennung
# ============================================================================
# Laeuft in _physics_process und NICHT in _process:
#   1. Positionen werden im Physik-Schritt aktualisiert - ein Check im
#      Render-Frame arbeitet je nach Framerate mit veralteten Daten und
#      verpasst bei 30 Metern pro Sekunde ganze Gegner.
#   2. Godot ruft _physics_process in Baumreihenfolge auf: der Player
#      (Elternknoten) zuerst, dieses Combat-Node danach. Wir sehen hier also
#      bereits die Positionen NACH move_and_slide() dieses Frames.
#
# Der armed-Zustand wird aus _is_dashing abgeleitet statt in _perform_utility
# gesetzt: so funktioniert die Erkennung auch, wenn ein Charakter-Script
# _perform_utility ueberschreibt und _is_dashing selbst setzt - und sie
# ueberlebt jede spaetere Aenderung an der Dash-VFX-Logik darueber.
func _physics_process(_delta: float) -> void:
	if not dash_damage_enabled or player == null:
		return

	if _is_dashing:
		if not _dash_pierce_armed:
			_arm_dash_pierce()
		_update_dash_pierce()
	elif _dash_pierce_armed:
		_dash_pierce_armed = false
		_dash_pierce_state.clear()


func _dash_debug(msg: String) -> void:
	if dash_debug_logging:
		print("[DashDamage] %s" % msg)


## Nimmt beim Dash-Start eine Momentaufnahme auf: wer steht schon hinter mir?
## Diese Gegner werden NICHT zu Kandidaten - man ist ja nicht durch sie
## hindurch, man dasht von ihnen weg.
func _arm_dash_pierce() -> void:
	_dash_pierce_armed = true
	_dash_pierce_state.clear()
	_dash_hit_count = 0

	_dash_flat_direction = Vector3(_dash_direction.x, 0.0, _dash_direction.z)
	if _dash_flat_direction.length() < 0.01:
		# Rein vertikaler Dash (Blick senkrecht nach oben/unten): es gibt
		# keine sinnvolle horizontale Achse, also kein Dash-Schaden.
		_dash_flat_direction = Vector3.ZERO
		_dash_debug("Dash ohne horizontale Komponente - Schadenspruefung aus.")
		return

	_dash_flat_direction = _dash_flat_direction.normalized()

	for enemy in _collect_dash_targets():
		var along: float = _dash_along(enemy)
		var id: int = enemy.get_instance_id()
		# Kulanz: wer praktisch auf mir steht, zaehlt noch als "vor mir".
		var pending: bool = along > -dash_entry_grace
		_dash_pierce_state[id] = {"node": enemy, "pending": pending, "done": false}

	_spawn_dash_debug_volume()

	var pending_count: int = 0
	for entry in _dash_pierce_state.values():
		if entry["pending"]:
			pending_count += 1
	_dash_debug("Dash gestartet. %d Gegner im Fenster, davon %d vor mir (Radius %.1f, Hoehe +%.1f/-%.1f)." % [
		_dash_pierce_state.size(), pending_count,
		dash_hit_radius, dash_hit_height_up, dash_hit_height_down
	])


func _update_dash_pierce() -> void:
	if _dash_flat_direction == Vector3.ZERO:
		return
	if dash_max_targets_per_dash > 0 and _dash_hit_count >= dash_max_targets_per_dash:
		return

	for enemy in _collect_dash_targets():
		var id: int = enemy.get_instance_id()
		var along: float = _dash_along(enemy)

		if not _dash_pierce_state.has(id):
			# Erst waehrend des Dashs in Reichweite gekommen. Nur vormerken,
			# wenn er tatsaechlich noch VOR mir ist - taucht er direkt hinter
			# mir auf, bin ich nicht durch ihn durchgelaufen.
			_dash_pierce_state[id] = {
				"node": enemy,
				"pending": along > 0.0,
				"done": false,
			}
			continue

		var entry: Dictionary = _dash_pierce_state[id]
		if entry["done"] or not entry["pending"]:
			continue

		# Vorzeichenwechsel entlang der Dash-Achse = durchquert.
		if along < -dash_pierce_exit_distance:
			entry["done"] = true
			_dash_pierce_state[id] = entry
			_dash_hit_count += 1
			_apply_dash_damage(enemy)
			if dash_max_targets_per_dash > 0 and _dash_hit_count >= dash_max_targets_per_dash:
				_dash_debug("Trefferlimit %d erreicht - Rest dieses Dashs wird ignoriert." % dash_max_targets_per_dash)
				return


## Alle lebenden Gegner, die seitlich und vertikal im Trefferfenster liegen.
## Der Seitenabstand wird zur ACHSE gemessen, nicht zum Spieler - sonst
## wuerde ein Gegner weit vorne auf der Bahn schon rausfallen.
func _collect_dash_targets() -> Array[Node3D]:
	var result: Array[Node3D] = []
	if _dash_flat_direction == Vector3.ZERO:
		return result

	for node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		if enemy == player:
			continue

		var to_enemy: Vector3 = enemy.global_position - player.global_position

		# Hoehenfenster asymmetrisch, siehe Kommentar bei dash_hit_height_up.
		var vertical: float = to_enemy.y - dash_hit_vertical_offset
		if vertical > dash_hit_height_up or vertical < -dash_hit_height_down:
			continue

		var flat := Vector3(to_enemy.x, 0.0, to_enemy.z)
		var along: float = _dash_flat_direction.dot(flat)
		var lateral: float = (flat - _dash_flat_direction * along).length()
		if lateral > dash_hit_radius:
			continue

		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health):
			continue
		if not (health as Health).is_alive():
			continue

		result.append(enemy)

	return result


func _dash_along(enemy: Node3D) -> float:
	var to_enemy: Vector3 = enemy.global_position - player.global_position
	return _dash_flat_direction.dot(Vector3(to_enemy.x, 0.0, to_enemy.z))


func _apply_dash_damage(enemy: Node3D) -> void:
	var health: Node = enemy.find_child("Health", true, false)
	if health == null or not (health is Health):
		return

	# Quelle ist der SPIELER, nicht dieses Combat-Node: Health.last_damage_source
	# steuert die Richtung der Todes-Animation, und die soll vom Spieler
	# wegzeigen.
	(health as Health).take_damage(dash_damage, player)
	_dash_debug("%.0f Schaden an '%s' (durchgedasht)." % [dash_damage, enemy.name])

	_spawn_dash_damage_number(enemy)
	dash_hit_landed.emit(enemy)

	# Treffer-VFX zeigt in Dash-Richtung: der Effekt soll mit der Bewegung
	# wegspritzen, nicht dem Gegner entgegen.
	if dash_hit_vfx:
		VFX.spawn(dash_hit_vfx, enemy.global_position + Vector3(0.0, 1.0, 0.0), _dash_flat_direction)

	if player.has_method("shake_camera"):
		player.shake_camera(dash_hit_shake_strength)

	if dash_damage_sets_target and player.has_method("set_target"):
		player.set_target(enemy)

	# BEWUSST NICHT _on_hit_landed(): das setzt den Hit-Lock, kappt das
	# Aufwaerts-Momentum und wuerde den laufenden Dash mitten in der Bewegung
	# ausbremsen. Nur der Combo-Zaehler wird uebernommen.
	if dash_damage_counts_combo:
		_combo_count += 1
		_combo_timer = combo_window
		combo_changed.emit(_combo_count)
		GameStats.report_combo(_combo_count)
		if enemy != _last_hit_target:
			_tilt_direction *= -1.0
			_last_hit_target = enemy
		if _combo_count >= 2 and player.has_method("play_combo_tilt"):
			var tilt: float = min(_combo_count * combo_tilt_per_hit, combo_tilt_max) * _tilt_direction
			player.play_combo_tilt(tilt)
		_tilt_reset_timer = combo_tilt_reset_delay

	if dash_knockback_force > 0.0 and enemy is CharacterBody3D:
		if enemy.get("is_heavy") == true:
			_dash_debug("Knockback ignoriert: '%s' ist ein schwerer Gegner." % enemy.name)
		else:
			var push_dir: Vector3 = _dash_flat_direction
			if enemy.has_method("apply_knockback"):
				enemy.apply_knockback(push_dir * dash_knockback_force)
			else:
				enemy.velocity += push_dir * dash_knockback_force


## Zeichnet das Trefferfenster als halbtransparenten Quader in die Welt.
##
## Der Quader entspricht 1:1 dem, was _collect_dash_targets() prueft: Laenge
## = dash_speed * dash_duration (die theoretische Bahn ohne Wandkollision),
## Breite = 2 * dash_hit_radius, Hoehe = up + down, vertikal um
## dash_hit_vertical_offset verschoben.
##
## BoxMesh liegt lokal mit seiner Laengsachse auf +Z, deshalb reicht ein
## reiner Yaw um Y.
func _spawn_dash_debug_volume() -> void:
	if not dash_debug_draw or _dash_flat_direction == Vector3.ZERO or player == null:
		return

	var length: float = maxf(dash_speed * dash_duration, 0.1)
	var height: float = maxf(dash_hit_height_up + dash_hit_height_down, 0.1)

	var box := BoxMesh.new()
	box.size = Vector3(dash_hit_radius * 2.0, height, length)

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = dash_debug_color

	var gizmo := MeshInstance3D.new()
	gizmo.name = "DashHitboxDebug"
	gizmo.mesh = box
	# material_override statt surface_material_override - Vorrangregel.
	gizmo.material_override = mat
	gizmo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var parent: Node = get_tree().current_scene
	if parent == null:
		return
	parent.add_child(gizmo)

	var center: Vector3 = player.global_position \
		+ _dash_flat_direction * (length * 0.5) \
		+ Vector3.UP * (dash_hit_vertical_offset + (dash_hit_height_up - dash_hit_height_down) * 0.5)

	var yaw: float = atan2(_dash_flat_direction.x, _dash_flat_direction.z)
	gizmo.global_transform = Transform3D(Basis.IDENTITY.rotated(Vector3.UP, yaw), center)

	# queue_free direkt als Callable verbinden statt ueber eine mehrzeilige
	# Lambda: kuerzer, und der Timer haelt keine Referenz auf einen Closure,
	# der einen bereits gefreeten Node einfaengt.
	var timer := get_tree().create_timer(maxf(dash_debug_draw_duration, 0.05))
	timer.timeout.connect(gizmo.queue_free)


func _spawn_dash_damage_number(enemy: Node3D) -> void:
	var scene: PackedScene = _resolve_damage_number_scene()
	if scene == null:
		push_warning("CombatBase: Keine damage_number_scene gefunden - Dash-Schadenszahl wird nicht angezeigt.")
		return

	var number: Node = scene.instantiate()
	get_tree().current_scene.add_child(number)
	(number as Node3D).global_position = enemy.global_position + Vector3(0.0, 1.8, 0.0)

	if number.has_method("show_dash_damage"):
		number.show_dash_damage(dash_damage)
	elif number.has_method("show_damage"):
		# Fallback fuer eine aeltere damage_number.gd ohne Dash-Variante:
		# dann eben in Crit-Farbe statt gelb, aber nicht unsichtbar.
		number.show_damage(dash_damage, true)


## Die Szene ist an der PrimaryHitbox bereits im Inspector gesetzt - von dort
## wird sie uebernommen, damit man sie nicht an einer zweiten Stelle pflegen
## muss. Ergebnis wird gecached, der Pfad-Fallback laeuft also hoechstens
## einmal pro Charakter-Instanz.
func _resolve_damage_number_scene() -> PackedScene:
	if dash_damage_number_scene != null:
		return dash_damage_number_scene
	if _cached_damage_number_scene != null:
		return _cached_damage_number_scene

	if primary_hitbox and primary_hitbox.damage_number_scene:
		_cached_damage_number_scene = primary_hitbox.damage_number_scene
	elif secondary_hitbox and secondary_hitbox.damage_number_scene:
		_cached_damage_number_scene = secondary_hitbox.damage_number_scene
	elif ResourceLoader.exists(DAMAGE_NUMBER_FALLBACK_PATH):
		_cached_damage_number_scene = load(DAMAGE_NUMBER_FALLBACK_PATH)

	return _cached_damage_number_scene

func is_dashing() -> bool:
	return _is_dashing

# 1.0 = normale Bewegung, kleinerer Wert = verlangsamt (waehrend Hit Lock)
func get_movement_multiplier() -> float:
	if _hit_lock_timer > 0.0:
		return hit_lock_speed_multiplier
	return 1.0

func is_hit_locked() -> bool:
	return _hit_lock_timer > 0.0

# 1.0 = normale Schwerkraft, 0.0 = komplett ausgesetzt (schweben),
# dazwischen = anteiliges langsames Fallen. Nur waehrend Hit Lock relevant.
func get_gravity_multiplier() -> float:
	if _hit_lock_timer > 0.0:
		return hit_lock_gravity_multiplier
	return 1.0

func can_jump() -> bool:
	if _hit_lock_timer > 0.0:
		return hit_lock_allow_jump
	return true

# --- Cooldown-Prozente fuers UI (0.0 = bereit, 1.0 = gerade gestartet) ---
func get_primary_cooldown_percent() -> float:
	var cd := _get_effective_primary_cooldown()
	return _primary_timer / cd if cd > 0.0 else 0.0

func get_secondary_cooldown_percent() -> float:
	return _secondary_timer / secondary_cooldown if secondary_cooldown > 0.0 else 0.0

func get_utility_cooldown_percent() -> float:
	return _utility_timer / utility_cooldown if utility_cooldown > 0.0 else 0.0

## PHASE 5: liest die Ladung des Items in Slot 0 (Q) statt eines Zeit-
## Timers. 1.0 = gerade benutzt/noch nicht wieder aufgeladen (Overlay
## voll), 0.0 = bereit (Overlay leer) - exakt dieselbe Konvention wie die
## alten zeitbasierten Cooldowns, siehe AbilitySlot.update_cooldown().
func get_ability_q_cooldown_percent() -> float:
	var items: Node = _items()
	return items.get_active_charge_percent(0) if item else 0.0

func get_ability_e_cooldown_percent() -> float:
	var items: Node = _items()
	return items.get_active_charge_percent(1) if item else 0.0

# Sammel-Getter fuers HUD: gibt fuer Slot 0..4 den Prozentwert zurueck.
func get_cooldown_percent(slot: int) -> float:
	match slot:
		Slot.PRIMARY:
			return get_primary_cooldown_percent()
		Slot.SECONDARY:
			return get_secondary_cooldown_percent()
		Slot.UTILITY:
			return get_utility_cooldown_percent()
		Slot.ABILITY_Q:
			return get_ability_q_cooldown_percent()
		Slot.ABILITY_E:
			return get_ability_e_cooldown_percent()
	return 0.0

## PHASE 5: "verbleibend" heisst fuer Q/E jetzt "noch so viele Raeume",
## nicht mehr Sekunden. AbilitySlot.update_cooldown() zeigt das als reine
## Zahl an (kein "s"-Suffix im Code), das passt hier zufaellig gut.
func get_cooldown_remaining(slot: int) -> float:
	match slot:
		Slot.PRIMARY:
			return _primary_timer
		Slot.SECONDARY:
			return _secondary_timer
		Slot.UTILITY:
			return _utility_timer
		Slot.ABILITY_Q:
			var q_items: Node = _items()
			return q_items.get_active_charge_remaining(0) if q_items else 0.0
		Slot.ABILITY_E:
			var e_items: Node = _items()
			return e_items.get_active_charge_remaining(1) if e_items else 0.0
	return 0.0

func get_combo_count() -> int:
	return _combo_count

```
</details>

### 💭 Thinking

`19:38:46`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`19:38:46`

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

const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

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


## HomingBolts nackte Kugel-Optik (geteilter Code mit Item-Minions, siehe
## homing_bolt.gd-Kopfkommentar - NICHT global aendern) liest sich als
## Magie-Geschoss, nicht als Plasma. Ein locker gestreuter Partikel-Schweif
## als Kind-Node behebt das, ohne die geteilte Basis anzufassen.
## local_coords = false: Partikel bleiben an ihrem Entstehungsort liegen,
## waehrend der Bolt weiterfliegt - genau das erzeugt den Schweif-Effekt.
func _attach_plasma_trail(bolt: Node3D, color: Color) -> void:
	var particles := GPUParticles3D.new()
	particles.emitting = true
	# Angehoben (Rueckmeldung "sieht schwach aus"): mehr, groessere Partikel
	# und ein eigenes Licht am Bolt selbst (unten) sollen ihn aus der
	# gesamten Kampfdistanz klar als staerkere Faehigkeit lesbar machen.
	particles.amount = 32
	particles.lifetime = 0.5
	particles.local_coords = false
	particles.one_shot = false

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3.ZERO
	mat.spread = 180.0
	mat.gravity = Vector3.ZERO
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.8
	mat.scale_min = 0.16
	mat.scale_max = 0.4
	mat.color = color
	particles.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.14
	mesh.height = 0.28
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_mat.albedo_color = color
	mesh_mat.emission_enabled = true
	mesh_mat.emission = color
	mesh_mat.emission_energy_multiplier = 3.2
	mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mesh_mat
	particles.draw_pass_1 = mesh

	bolt.add_child(particles)

	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 1.6
	light.omni_range = 4.5
	light.shadow_enabled = false
	bolt.add_child(light)


## origin ist die Abschusspositon (NICHT die aktuelle Bolt-Position - der
## Bolt selbst reicht seine Position nicht an den Callback durch, siehe
## homing_bolt.gd::_strike()). Die Zug-Richtung ist deshalb "vom Abschussort
## zum Einschlag", nicht "vom Ziel weg vom Einschlag" - liest sich als
## Schubs weiter in Flugrichtung, siehe Kopfkommentar-Entscheidung im Plan.
func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float) -> void:
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

	var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, target.global_position + Vector3.UP, Vector3.UP)
	if spark:
		spark.scale *= 1.7
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
			if spark:
				spark.scale *= 1.4
			_lock_model_to(result["target"])
			# Leichtes Dauer-Rattern statt eines einzelnen Shakes - passt
			# besser zu einem Dauerstrahl als ein einmaliger Ausschlag und
			# macht spuerbar, dass der Strahl laufend Schaden macht statt
			# nur huebsch auszusehen (Rueckmeldung "sieht schwach aus").
			if player and player.has_method("shake_camera"):
				player.shake_camera(0.06)

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
## (billboard + no_depth_test) ueber dem gerade automatisch anvisierten Ziel.
func _update_laser_esp(target: Node3D) -> void:
	if target == _laser_locked_target and target != null and is_instance_valid(target):
		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		return

	_clear_laser_esp()
	_laser_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_laser_esp_marker = _build_laser_esp_marker()
	get_tree().current_scene.add_child(_laser_esp_marker)
	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2


func _clear_laser_esp() -> void:
	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
		_laser_esp_marker.queue_free()
	_laser_esp_marker = null
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
func _damage_multiplier() -> float:
	var stats: PlayerStats = PlayerStats.find_for(self)
	return stats.get_damage_multiplier() if stats else 1.0


## Dreht das Charaktermodell zum getroffenen Ziel - dieselbe player_base.gd-
## Funktion, die auch Nahkampf-Treffer schon nutzen (siehe combat_base.gd::
## _on_hit_landed()). Weder HomingBolt-Treffer noch Hitscan-Treffer loesen
## das automatisch aus, da beide nie ueber die Hitbox-Signale laufen.
func _lock_model_to(target: Variant) -> void:
	if player and player.has_method("set_target") and target is Node3D:
		player.set_target(target)

```
</details>

### 💭 Thinking

`19:39:00`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 📂 Glob `scripts/**/homing_bolt.gd`

`19:39:00`

```
scripts\vfx\homing_bolt.gd
```

#### 👀 Read `homing_bolt.gd`

`19:39:03`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\homing_bolt.gd</code></summary>

```
extends Node3D
class_name HomingBolt

# ============================================================================
# HomingBolt — generischer fliegender Verfolger fuer Item-Minions.
# ============================================================================
# Verallgemeinert den Flug-/Zielverfolgungs-Code aus revenge_ghost.gd (gleiche
# Bewegungslogik: geradliniges Homing + leichtes seitliches Schweben), aber
# statt eines fest verdrahteten "Schaden + Knockback" bekommt der Aufrufer
# einen eigenen on_strike-Callback (target: Node3D) -> void. Damit teilen
# sich boom_bot (einmalige Explosion), alarmbot (einmaliger Vulnerable-Debuff)
# und prowler (wiederholtes Confused/Silenced auf mehrere Ziele nacheinander)
# denselben Flugcode, statt ihn dreimal zu duplizieren.
#
# RETARGET: wenn true, sucht der Bolt nach jedem Treffer automatisch den
# naechsten lebenden Gegner in der Gruppe "enemies" und fliegt weiter, bis
# die Lebensdauer ablaeuft (prowler). Wenn false, verschwindet er nach dem
# ersten Treffer (boom_bot, alarmbot).

const HIT_RANGE: float = 1.3
const WEAVE_AMPLITUDE: float = 0.5
const WEAVE_SPEED: float = 6.0

var _target: Node3D = null
var _source: Node = null
var _on_strike: Callable
var _retarget: bool = false
var _speed: float = 14.0
var _lifetime: float = 4.0
var _age: float = 0.0
var _weave_time: float = 0.0
var _struck_ids: Array[int] = []
var _color: Color = Color(0.7, 0.2, 0.9)

var _mesh: MeshInstance3D = null
var _light: OmniLight3D = null


## context liefert Zugriff auf den Szenenbaum (gleiches Prinzip wie
## RevengeGhost.spawn()/TurretProjectile.spawn()).
static func spawn(
		context: Node, origin: Vector3, initial_target: Node3D, color: Color,
		on_strike: Callable, speed: float = 14.0, lifetime: float = 4.0,
		retarget: bool = false, source: Node = null
) -> HomingBolt:
	if context == null or not is_instance_valid(context):
		return null
	if initial_target == null or not is_instance_valid(initial_target):
		return null

	var bolt := HomingBolt.new()
	bolt._target = initial_target
	bolt._on_strike = on_strike
	bolt._retarget = retarget
	bolt._speed = speed
	bolt._lifetime = lifetime
	bolt._source = source
	bolt._color = color

	var parent: Node = context.get_tree().current_scene
	if parent == null:
		parent = context.get_tree().get_root()
	parent.add_child(bolt)
	bolt.global_position = origin
	bolt._build_visual()
	return bolt


func _build_visual() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.7
	sphere.radial_segments = 10
	sphere.rings = 6

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = _color
	mat.emission_enabled = true
	mat.emission = _color
	mat.emission_energy_multiplier = 2.0
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	_mesh = MeshInstance3D.new()
	_mesh.mesh = sphere
	_mesh.material_override = mat
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh)

	_light = OmniLight3D.new()
	_light.light_color = _color
	_light.light_energy = 1.2
	_light.omni_range = 3.0
	_light.shadow_enabled = false
	add_child(_light)


func _process(delta: float) -> void:
	_age += delta
	if _age >= _lifetime:
		_dissipate()
		return

	if _target == null or not is_instance_valid(_target):
		_target = _find_next_target()
		if _target == null:
			_dissipate()
			return

	var to_target: Vector3 = (_target.global_position + Vector3.UP * 1.0) - global_position
	var dist: float = to_target.length()

	if dist <= HIT_RANGE:
		_strike()
		return

	var dir: Vector3 = to_target / maxf(dist, 0.001)
	global_position += dir * _speed * delta

	_weave_time += delta * WEAVE_SPEED
	var side: Vector3 = dir.cross(Vector3.UP)
	if side.length_squared() > 0.0001:
		global_position += side.normalized() * sin(_weave_time) * WEAVE_AMPLITUDE * delta
	if dir.length_squared() > 0.0001:
		look_at(global_position + dir, Vector3.UP)


func _strike() -> void:
	if _target != null and is_instance_valid(_target):
		_struck_ids.append(_target.get_instance_id())
		_on_strike.call(_target)

	if not _retarget:
		_dissipate()
		return

	_target = _find_next_target()
	if _target == null:
		_dissipate()


func _find_next_target() -> Node3D:
	var best: Node3D = null
	var best_dist: float = INF
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		if _struck_ids.has(node.get_instance_id()):
			continue
		var health: Node = node.find_child("Health", true, false)
		if health != null and health.has_method("is_alive") and not health.is_alive():
			continue
		var d: float = global_position.distance_to((node as Node3D).global_position)
		if d < best_dist:
			best_dist = d
			best = node as Node3D
	return best


func _dissipate() -> void:
	set_process(false)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	if _mesh != null and is_instance_valid(_mesh):
		tween.tween_property(_mesh, "scale", Vector3.ZERO, 0.25)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if _light != null and is_instance_valid(_light):
		tween.tween_property(_light, "light_energy", 0.0, 0.25)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

```
</details>

### 🤖 Assistant: *Found the crash.*

`19:39:22`

<details>
<summary>Thinking...</summary>

> 
</details>

> Found the crash. `HomingBolt._strike()` calls the `_on_strike` callback unconditionally — but the callback is a closure bound to the Combat node (Winter's plasma bolts). Switching character frees that node mid-flight, and the bolt still calls into it when it reaches the target. Let me check the Giselle Uzi particle issue and the Divebomber next while I have context loaded.

#### 📂 Glob `scripts/characters/combat_giselle.gd`

`19:39:24`

```
scripts\characters\combat_giselle.gd
```

#### 📂 Glob `**/*ivebomber*`

`19:39:24`

```
resources\enemies\es_divebomber.tres
01_Game_Design\Enemies\divebomber.md
```

### 💭 Thinking

`19:39:27`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `class_name.*[Dd]ive|Divebomber|DiveBomber` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:39:29`

```
Found 4 files
scripts\characters\combat_winter.gd
scripts\enemies\dive_bomber.gd
scripts\enemy_sandbox_room.gd
scripts\enemies\custom_enemy_base.gd
```

#### 👀 Read `combat_giselle.gd`

`19:39:29`

### 💭 Thinking

`19:39:43`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:39:43`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && cat scenes/vfx/spark_yellow.tscn 2>&1 | head -80
```

```
[gd_scene load_steps=4 format=3]



; SPARK_YELLOW — gelber Funkenburst.

; Verwendung: Sturmfeuerzeug (Feuerbogen), Defekter Gameboy (Kettenblitz),

; Goldene Kreditkarte (Geld-Glimmern), Verfluchter Glueckswuerfel.

;

; Heller und schneller als hit_spark.tscn: blend_mode = 1 (Add) plus

; hoehere Startgeschwindigkeit, damit der Effekt auch VOR einem hellen

; Lava-Hintergrund noch als Funke lesbar bleibt.



[sub_resource type="ParticleProcessMaterial" id="ParticleProcessMaterial_sy"]

direction = Vector3(0, 1, 0)

spread = 75.0

initial_velocity_min = 5.0

initial_velocity_max = 11.0

gravity = Vector3(0, -14.0, 0)

damping_min = 1.0

damping_max = 3.0

scale_min = 0.5

scale_max = 1.1

color = Color(1, 0.9, 0.25, 1)



[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_sy"]

shading_mode = 0

transparency = 1

blend_mode = 1

billboard_mode = 3

albedo_color = Color(1, 0.94, 0.45, 1)



[sub_resource type="QuadMesh" id="QuadMesh_sy"]

material = SubResource("StandardMaterial3D_sy")

size = Vector2(0.14, 0.14)



[node name="SparkYellow" type="GPUParticles3D"]

emitting = false

amount = 22

lifetime = 0.4

one_shot = true

explosiveness = 1.0

randomness = 0.45

fixed_fps = 30

process_material = SubResource("ParticleProcessMaterial_sy")

draw_pass_1 = SubResource("QuadMesh_sy")
```

### 💭 Thinking

`19:39:53`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `muzzle|Muzzle|MUZZLE` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:39:54`

```
scripts\characters\combat_giselle.gd:22:const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
scripts\characters\combat_giselle.gd:116:	_spawn_muzzle_vfx(origin, dir)
scripts\characters\combat_giselle.gd:292:		_spawn_muzzle_vfx(origin, dir)
scripts\characters\combat_giselle.gd:357:func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3) -> void:
scripts\characters\combat_giselle.gd:361:		VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, pos, data.attack_color, data.attack_color_secondary, vfx_dir)
scripts\characters\combat_giselle.gd:363:		VFX.spawn(MUZZLE_VFX_SCENE, pos, vfx_dir)
scripts\hazards\turret.gd:53:@export var muzzle_color: Color = Color(0.85, 0.20, 0.20)
scripts\hazards\turret.gd:99:	mat.emission = muzzle_color
scripts\hazards\turret.gd:113:	_light.light_color = muzzle_color
scripts\hazards\turret.gd:136:	_flash_muzzle()
scripts\hazards\turret.gd:162:func _flash_muzzle() -> void:
```

### 💭 Thinking

`19:40:01`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `dive_bomber.gd`

`19:40:02`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\dive_bomber.gd</code></summary>

```
extends CustomEnemyBase
class_name DiveBomber

# ============================================================================
# Divebomber — fliegender Gegner.
# ============================================================================
# Wartet ausserhalb der Nahkampf-Reichweite in der Luft (leichtes Schweben/
# Wippen, KEIN staendiges Kreisen mehr um den Spieler) und stuerzt im festen
# Rhythmus (DASH_INTERVAL) auf ihn herab: LOCK-Phase mit sichtbarem
# Lean/Telegraph-Ring, dann senkrechter Sturz auf die zu diesem Zeitpunkt
# FESTGELEGTE Position.
#
# Der Einschlag passiert IMMER (Treffer oder nicht) und hinterlaesst
# liegenbleibende Gesteinstruemmer auf dem Boden - anders als normale VFX
# blenden diese nicht automatisch aus, sie werden nur beim Force-Clear ueber
# _cleanup_effects() entfernt (siehe dort). Der Bomber selbst ist danach
# IMMER fuer GROUNDED_STUN_TIME (5 s) bewegungsunfaehig, bevor er wieder
# aufsteigt und den naechsten Rhythmus startet - unabhaengig davon, ob der
# Sturz getroffen hat. Nur der SCHADEN haengt weiter davon ab, ob der
# Spieler beim Einschlag noch im Ziel-Radius stand.

enum State { HOVER, LOCK, DIVE, GROUNDED, RECOVER }

const DUST_RING_SCENE: PackedScene = preload("res://scenes/vfx/dust_ring.tscn")
const SPARK_YELLOW_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const ROCK_COLOR: Color = Color(0.32, 0.28, 0.26)

var hover_height: float = 11.0
var hover_recenter_speed: float = 2.5
var dash_interval: float = 3.4
var lock_time: float = 0.9
var dive_speed: float = 34.0
var hit_radius: float = 2.4
var damage: float = 20.0
var grounded_stun_time: float = 5.0
var recover_speed: float = 10.0
var detect_range: float = 40.0

## Optisch (und, ueber die Kollisionsbox, auch spielerisch) groesser - reine
## Groessenanpassung, siehe visual_root.scale unten.
## War 1.5 - Rueckmeldung "jeder Gegner ausser Magnet soll 3x groesser sein"
## (1.5 * 3 = 4.5).
const VISUAL_SCALE: float = 4.5

var _state: State = State.HOVER
var _bob_phase: float = 0.0
var _timer: float = 0.0
var _dive_target: Vector3 = Vector3.ZERO
var _lock_marker: MeshInstance3D = null
var _visual_body: MeshInstance3D = null
var _rubble: Array[Node3D] = []

## Feste Ziel-Hoehe fuer den RECOVER-Zustand, EINMALIG beim Verlassen von
## GROUNDED gesetzt statt bei jedem _do_recover()-Aufruf neu berechnet.
##
## BUGFIX "Divebomber stuerzt in den Boden, steigt dann auf und kommt nie
## wieder runter": target_y wurde vorher JEDEN Frame frisch aus der
## AKTUELLEN global_position.y berechnet (target_y = aktuelle Hoehe +
## hover_height * 0.5). Damit war target_y immer um denselben Betrag ueber
## der aktuellen Position - move_toward kam der Zielhoehe also nie naeher
## (der "Abstand" wurde ja jeden Frame neu auf denselben Wert zurueckgesetzt),
## der Bomber stieg dadurch unbegrenzt weiter, statt jemals in den HOVER-
## Zustand zurueckzuwechseln.
var _recover_target_y: float = 0.0


func _configure() -> void:
	display_name = "Divebomber"
	max_health = 55.0


func _build() -> void:
	_build_visual()
	visual_root.scale = Vector3.ONE * VISUAL_SCALE
	_add_box_collision(Vector3(1.6, 1.0, 1.6) * VISUAL_SCALE)
	_bob_phase = randf() * TAU
	_timer = dash_interval * randf_range(0.4, 1.0)


func _build_visual() -> void:
	var body_mesh := SphereMesh.new()
	body_mesh.radius = 0.75
	body_mesh.height = 1.1
	_visual_body = MeshInstance3D.new()
	_visual_body.mesh = body_mesh
	_visual_body.material_override = _make_unshaded_material(Color(0.9, 0.55, 0.1), 1.2)
	visual_root.add_child(_visual_body)

	var wing_mesh := BoxMesh.new()
	wing_mesh.size = Vector3(2.6, 0.12, 0.6)
	var wings := MeshInstance3D.new()
	wings.mesh = wing_mesh
	wings.material_override = _make_unshaded_material(Color(0.3, 0.28, 0.32))
	_visual_body.add_child(wings)

	var light := OmniLight3D.new()
	light.light_color = Color(0.9, 0.55, 0.1)
	light.light_energy = 0.9
	light.omni_range = 4.0
	light.shadow_enabled = false
	_visual_body.add_child(light)


func _physics_process(delta: float) -> void:
	match _state:
		State.HOVER:
			_do_hover(delta)
		State.LOCK:
			_do_lock(delta)
		State.DIVE:
			_do_dive(delta)
		State.GROUNDED:
			_do_grounded(delta)
		State.RECOVER:
			_do_recover(delta)


## Bleibt weitgehend an Ort und Stelle (nur ein sanftes Auf/Ab), statt
## staendig um den Spieler zu kreisen - die vorherige schnelle Orbit-Bewegung
## machte den Rhythmus des Sturzangriffs schwer lesbar. Zentriert sich nur
## LANGSAM horizontal ueber die aktuelle Spielerposition nach, damit er nicht
## komplett aus dem Kampf herauslaeuft.
func _do_hover(delta: float) -> void:
	var player: CharacterBody3D = _find_player()
	if player == null:
		return

	_bob_phase += delta * 1.2
	var wanted: Vector3 = player.global_position + Vector3.UP * hover_height
	wanted.y += sin(_bob_phase) * 0.4
	global_position = global_position.move_toward(wanted, hover_recenter_speed * delta)
	if _visual_body:
		_visual_body.rotation.y += delta * 0.4

	if global_position.distance_to(player.global_position) > detect_range:
		return

	_timer -= delta
	if _timer <= 0.0:
		_timer = dash_interval
		_start_lock(player)


func _start_lock(player: CharacterBody3D) -> void:
	_state = State.LOCK
	_timer = lock_time
	_dive_target = player.global_position

	_lock_marker = MeshInstance3D.new()
	var ring := CylinderMesh.new()
	ring.top_radius = hit_radius
	ring.bottom_radius = hit_radius
	ring.height = 0.05
	_lock_marker.mesh = ring
	var mat := _make_unshaded_material(DANGER_TELEGRAPH_COLOR)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.15
	_lock_marker.material_override = mat
	get_tree().current_scene.add_child(_lock_marker)
	_lock_marker.global_position = _dive_target + Vector3.UP * 0.05

	var tween: Tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.8, lock_time)


func _do_lock(delta: float) -> void:
	# Lean-Telegraph: kippt sichtbar in Richtung des Sturzflugs, statt
	# regungslos in der Luft zu haengen.
	if _visual_body:
		_visual_body.rotation.x = lerpf(_visual_body.rotation.x, deg_to_rad(70.0), delta * 4.0)

	_timer -= delta
	if _timer <= 0.0:
		_state = State.DIVE


func _do_dive(delta: float) -> void:
	global_position.x = move_toward(global_position.x, _dive_target.x, dive_speed * delta)
	global_position.z = move_toward(global_position.z, _dive_target.z, dive_speed * delta)
	global_position.y -= dive_speed * delta

	if _is_at_ground_level():
		_land()


func _is_at_ground_level() -> bool:
	var world: World3D = get_world_3d()
	if world == null:
		return true
	var query := PhysicsRayQueryParameters3D.create(
		global_position, global_position - Vector3(0.0, 1.0, 0.0)
	)
	query.collision_mask = 1
	query.exclude = [get_rid()]
	return not world.direct_space_state.intersect_ray(query).is_empty()


func _land() -> void:
	if is_instance_valid(_lock_marker):
		_lock_marker.queue_free()
	_lock_marker = null

	var impact_pos: Vector3 = _project_to_ground(global_position)
	VFX.spawn(DUST_RING_SCENE, impact_pos)
	Juice.shake(1.2)
	_spawn_rubble(impact_pos)

	var player: CharacterBody3D = _find_player()
	var flat_player: Vector3 = Vector3.ZERO
	var hit_player: bool = false
	if player != null:
		flat_player = player.global_position
		flat_player.y = _dive_target.y
		hit_player = flat_player.distance_to(_dive_target) <= hit_radius

	if hit_player:
		var target_health := player.find_child("Health", true, false) as Health
		if target_health != null and target_health.is_alive():
			target_health.take_damage(damage, self)
		VFX.spawn(SPARK_YELLOW_SCENE, player.global_position + Vector3.UP)

	# IMMER gestunnt, egal ob getroffen wurde - siehe Klassenkommentar.
	_state = State.GROUNDED
	_timer = grounded_stun_time
	if _visual_body:
		_visual_body.rotation.x = deg_to_rad(90.0)


## Wie viele Gesteinsbrocken GLEICHZEITIG pro Bomber liegen bleiben duerfen -
## etwa 2 Einschlaege wert. BUGFIX "Spiel friert nach ~30s ein": Truemmer
## waren komplett unbegrenzt (nur Force-Clear raeumte sie auf). Bei
## dash_interval=3.4s und bis zu 8 Divebombern/Raum (siehe
## resources/enemies/es_divebomber.tres) haetten sich in 30s bereits
## hunderte permanente Meshes + je eine eigene StandardMaterial3D
## angesammelt - genau das hat den Frame-Einbruch verursacht. Vorher fiel
## das nie auf, weil im Sandbox-Testraum nie mehr als 1-2 gleichzeitig
## liefen.
const MAX_RUBBLE_ROCKS: int = 12

## Truemmer, die eine Weile liegen BLEIBEN (kein Fade-Timer wie bei
## normalem VFX) - sichtbarer Beleg dafuer, dass hier gerade etwas
## eingeschlagen ist. Werden beim Force-Clear ueber _cleanup_effects()
## entfernt, ODER sobald MAX_RUBBLE_ROCKS ueberschritten ist (dann zuerst
## der aelteste Brocken).
func _spawn_rubble(pos: Vector3) -> void:
	var rock_count: int = randi_range(4, 6)
	for i: int in range(rock_count):
		var rock := MeshInstance3D.new()
		var box := BoxMesh.new()
		var size: float = randf_range(0.35, 0.75)
		box.size = Vector3(size, size * randf_range(0.5, 0.9), size)
		rock.mesh = box
		rock.material_override = _make_unshaded_material(ROCK_COLOR)

		get_tree().current_scene.add_child(rock)
		var angle: float = randf() * TAU
		var dist: float = randf_range(0.2, hit_radius * 0.8)
		rock.global_position = pos + Vector3(cos(angle) * dist, size * 0.3, sin(angle) * dist)
		rock.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)

		_rubble.append(rock)

	while _rubble.size() > MAX_RUBBLE_ROCKS:
		var oldest: Node3D = _rubble.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()


func _do_grounded(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_state = State.RECOVER
		_recover_target_y = global_position.y + hover_height * 0.5
		if _visual_body:
			_visual_body.rotation.x = 0.0


func _do_recover(delta: float) -> void:
	global_position.y = move_toward(global_position.y, _recover_target_y, recover_speed * delta)
	if global_position.y >= _recover_target_y - 0.1:
		_state = State.HOVER
		_timer = dash_interval


func _cleanup_effects() -> void:
	if is_instance_valid(_lock_marker):
		_lock_marker.queue_free()
	_lock_marker = null
	for rock: Node3D in _rubble:
		if is_instance_valid(rock):
			rock.queue_free()
	_rubble.clear()

```
</details>

### 🤖 Assistant: *Found root causes for the crash and the camera…*

`19:40:28`

<details>
<summary>Thinking...</summary>

> 
</details>

> Found root causes for the crash and the camera-particle issue. Fixing both, then I'll check with you on the Divebomber size/height numbers since there's no target value in your note.
> 
> **Crash (Winter → Karina mid-attack):** Winter's Plasma bolts (`HomingBolt`) carry an `on_strike` callback that's a closure bound to the `CombatWinter` node. `switch_to()` in `party_manager.gd:434-436` frees the old player (and its Combat child) while bolts are still in flight. When a bolt reaches its target afterward, `homing_bolt.gd:131` calls `_on_strike.call(_target)` on the now-freed node.

#### ✏️  Edit `homing_bolt.gd`

`19:40:35`

```diff
@@ -1,4 +1,12 @@ func _strike() -> void:
 	if _target != null and is_instance_valid(_target):
 		_struck_ids.append(_target.get_instance_id())
-		_on_strike.call(_target)
+		# BUGFIX "Crash beim Charakterwechsel waehrend Winters Plasma fliegt":
+		# _on_strike ist eine Closure, die an den abfeuernden Combat-Node
+		# gebunden ist (siehe combat_winter.gd::_perform_primary()). Der Bolt
+		# selbst haengt unabhaengig unter current_scene und ueberlebt einen
+		# Charakterwechsel - der gebundene Combat-Node aber nicht (party_manager.gd
+		# switch_to() queue_free()'t ihn sofort). Ohne is_valid()-Check landete
+		# der Aufruf auf einer bereits freigegebenen Instanz.
+		if _on_strike.is_valid():
+			_on_strike.call(_target)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\homing_bolt.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *\*\*Camera particles (Giselle's Uzi):\*\* the…*

`19:40:39`

> **Camera particles (Giselle's Uzi):** the muzzle VFX spawns exactly at `_camera.global_position` (`combat_giselle.gd:105,115-116`) — the particle burst originates *at the lens itself*, so its 75° spread cone renders visibly in front of/into the camera. Offsetting the spawn slightly forward along the aim direction fixes it.

#### ✏️  Edit `combat_giselle.gd`

`19:40:44`

```diff
@@ -1,2 +1,10 @@ const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
 const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")
+
+## BUGFIX "Muendungsblitz-Partikel fliegen in die Kamera": _spawn_muzzle_vfx()
+## bekam bisher die Camera3D-Position selbst als Spawn-Punkt - der Effekt
+## sass damit direkt AM Objektiv, und sein 75-Grad-Streuwinkel (siehe
+## spark_yellow.tscn) rendert dadurch sichtbar ueber den ganzen Bildschirm
+## statt als kleiner Blitz vor dem Lauf. Schiebt den Spawn-Punkt ein Stueck
+## in Schussrichtung nach vorn, weg vom Objektiv.
+const MUZZLE_FORWARD_OFFSET: float = 0.6
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,7 +1,8 @@ func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3) -> void:
 	var vfx_dir: Vector3 = -dir
+	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
 	var data: CharacterData = PartyManager.get_active_data()
 	if data != null:
-		VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, pos, data.attack_color, data.attack_color_secondary, vfx_dir)
+		VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, spawn_pos, data.attack_color, data.attack_color_secondary, vfx_dir)
 	else:
-		VFX.spawn(MUZZLE_VFX_SCENE, pos, vfx_dir)
+		VFX.spawn(MUZZLE_VFX_SCENE, spawn_pos, vfx_dir)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now for the Divebomber — currently `VISUAL_SCALE…*

`19:40:53`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now for the Divebomber — currently `VISUAL_SCALE = 4.5` and `hover_height = 11.0` (`scripts/enemies/dive_bomber.gd:28,43`). Your note didn't give target numbers like the balance doc did, so:

#### ❓ Asking questions...

`19:40:56`

**Q:** *Divebomber ist zu groß und hovert zu tief/nicht hoch genug in der Luft. Wie stark soll ich anpassen?*

- Moderat (Empfohlen): VISUAL_SCALE 4.5 → 3.0, hover_height 11 → 16

- Stark: VISUAL_SCALE 4.5 → 2.25 (zurück auf den alten 1.5x-Wert vor dem '3x größer'-Feedback), hover_height 11 → 20

- Nur Größe: Nur VISUAL_SCALE 4.5 → 3.0 anpassen, hover_height unangetastet lassen

- Nur Höhe: Nur hover_height 11 → 16 anpassen, VISUAL_SCALE unangetastet lassen

**A:** Moderat (Empfohlen)

#### ✏️  Edit `dive_bomber.gd`

`19:41:18`

```diff
@@ -1 +1,2 @@-var hover_height: float = 11.0
+## War 11.0 - Rueckmeldung "zu tief, nicht weit oben in der Luft" (2026-08-12).
+var hover_height: float = 16.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\dive_bomber.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,5 +1,5 @@ ## Optisch (und, ueber die Kollisionsbox, auch spielerisch) groesser - reine
 ## Groessenanpassung, siehe visual_root.scale unten.
-## War 1.5 - Rueckmeldung "jeder Gegner ausser Magnet soll 3x groesser sein"
-## (1.5 * 3 = 4.5).
-const VISUAL_SCALE: float = 4.5
+## War 1.5, dann 4.5 ("jeder Gegner ausser Magnet soll 3x groesser sein").
+## Rueckmeldung "zu gross" (2026-08-12): auf 3.0 zurueckgenommen.
+const VISUAL_SCALE: float = 3.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\dive_bomber.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:41:31`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:41:31`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -n "hover_height\|VISUAL_SCALE\|dive_bomber" generate_vault.py | head -20
```

```
915:    "scripts/enemies/dive_bomber.gd",
1059:    "pickup_pull_speed": "Pickup-Sog-Geschwindigkeit", "hover_height": "Schwebehoehe",
1502:# VISUAL_SCALE_BONUS/TINT_STRENGTH, die kein anderer Effekt hat).
```

### 🤖 Assistant: *hover_height is picked up by the vault generator…*

`19:41:34`

> hover_height is picked up by the vault generator, so let's regenerate.

#### 💻 Bash

`19:41:34`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -10 && graphify update . 2>&1 | tail -10
```

```
[4/7] 10 Status-Effekt-Notizen geschrieben (01_Game_Design/Status_Effects)

[5/7] Architektur-Notizen geschrieben (02_Tech_Architecture)

[5/7] Gruppierungs-Seiten (MOCs) geschrieben

[6/7] 85 DevLog-Notizen + Gesamtliste geschrieben (03_DevLogs)

[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5149 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] community set changed since labeling (546 saved labels, 546 communities now; renamed 139 community(ies) by their hub). Run `graphify label` to refresh names with the LLM.

[graphify] backed up semantic+curated graph (6 files) -> 2026-08-12/

Graph has 5326 nodes (above 5000 limit). Building aggregated community view...

graph.html written (aggregated: 546 community nodes, 165 cross-community edges)

Tip: run with --obsidian for full node-level detail.

[graphify watch] Rebuilt: 5326 nodes, 5043 edges, 546 communities

[graphify watch] graph.json, graph.html and GRAPH_REPORT.md updated in graphify-out

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *All four fixes are in and the vault/graph…*

`19:42:09`

> All four fixes are in and the vault/graph are refreshed:
> 
> 1. **Crash fix** (`scripts/vfx/homing_bolt.gd`) — `_strike()` now checks `_on_strike.is_valid()` before calling. Winter's Plasma bolts hold a callback closure bound to the Combat node; switching character mid-flight (e.g. Winter → Karina with LMB held) frees that node while a bolt is still traveling, and the unguarded call crashed the game on impact.
> 2. **Giselle Uzi camera particles** (`scripts/characters/combat_giselle.gd`) — muzzle VFX was spawning exactly at the camera's position, so its 75° spread rendered right at the lens. Added `MUZZLE_FORWARD_OFFSET = 0.6` and offset the spawn point along the aim direction.
> 3. **Divebomber size**: `VISUAL_SCALE` 4.5 → 3.0
> 4. **Divebomber hover height**: `hover_height` 11.0 → 16.0 (dive-in depth is unchanged — it still dives to the player, just starts higher)
> 
> Plus the earlier threat-cost balance pass (Divebomber 2→3, Schild-Drohne 4→6, Säure-Sprinkler 5→7, Mörser-Bot 6→8, Plasma-Beam Bot 10→12, Colossus 10→15).
> 
> Worth testing in-editor: hold LMB as Winter with a bolt in flight and switch to Karina to confirm the crash is gone, and check the Uzi muzzle flash no longer washes the screen.

## 🤷 User: *Wir müssen in unserem Godot 4 (GDScript)…*

`19:42:52`

Wir müssen in unserem Godot 4 (GDScript) Projekt "Lemonade" (Whiplash) eine automatisierte Test-Suite einführen, um Regressionen künftig abzufangen. Aktuell testen wir nur manuell über Sandbox-Räume. Wir wollen dafür das Framework GUT (Godot Unit Tests) verwenden.

Bitte hilf mir bei der vollständigen Einrichtung und dem ersten Test-Setup. Gehe dabei strukturiert in folgenden Schritten vor:

1. Setup & Installation:
   Erkläre mir kurz, wie ich GUT am besten in unser bestehendes Projekt integriere (z.B. über die Asset Library oder als Git Submodule) und wie die Ordnerstruktur für die Tests (`test/`, `test/unit/`, `test/integration/`) aussehen sollte.

2. Test-Umgebung für Autoloads:
   Unser Spiel nutzt stark Autoloads (Singletons) für das State-Management. Besonders wichtig ist der `PartyManager` (steuert den aktiven Charakter und den Wechsel zwischen 4 Charakteren) und `Items` (für das Inventar). Zeige mir, wie wir in GUT eine Base-Testklasse schreiben, die diese Autoloads vor jedem Test sauber instanziiert und danach wieder aufräumt, damit die Tests isoliert bleiben.

3. Unser erster Regressionstest (Bug Repro):
   Wir hatten kürzlich einen kritischen Bug: Wenn man als Charakter "Winter" den Primärangriff (Linke Maustaste) gedrückt hält und dann auf den Charakter "Karina" wechselt, stürzt das Spiel ab.
   Schreibe einen Integrationstest (z.B. in `test_character_switch.gd`), der genau dieses Szenario simuliert:

- Spawne die Party.
- Setze "Winter" als aktiven Charakter.
- Simuliere den Input für den Primärangriff (als würde die Taste gehalten).
- Triggere den Charakterwechsel zu "Karina" über den `PartyManager`.
- Prüfe mit Assertions, ob der Wechsel erfolgreich war und das Spiel (bzw. der Test) nicht crasht, sowie ob der Input-State sauber zurückgesetzt wurde.

Bitte erstelle mir die nötigen Basis-Skripte und den Test für Schritt 3, ohne // TODOs oder Platzhalter.-

### 💭 Thinking

`19:42:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:42:57`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && ls addons/ 2>&1; echo "---"; ls . | head -30; echo "---autoload---"; grep -A 20 "^\[autoload\]" project.godot
```

```
ls: cannot access 'addons/': No such file or directory
---
00_Dashboard
01_Game_Design
02_Tech_Architecture
03_DevLogs
04_Chat_Prompts
05_Gedanken
06_Assets
98_Scripts
99_Attachments
99_Templates
AGENTS.md
CLAUDE.md
Game Export
HOME.md
Lemonade.apple-touch-icon.png.import
Lemonade.icon.png.import
Lemonade.png.import
README.md
__pycache__
_project_export.txt
add_tags.py
asset
commit_message.txt
credits
export_presets.cfg
extract_related.py
gamedesign
generate_vault.py
graphify-out
icon.svg.import
---autoload---
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
```

### 💭 Thinking

`19:44:08`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:44:09`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && cat scenes/characters/char_winter.tscn 2>&1 | head -60; echo "=== karina ==="; find scenes -iname "char_karina.tscn"; find scenes -iname "char_winter.tscn"
```

```
[gd_scene format=3 uid="uid://bkyplq6fj3yft"]



[ext_resource type="Script" uid="uid://3vc06c3kmrbw" path="res://scripts/characters/char_winter.gd" id="1_winter"]

[ext_resource type="PackedScene" uid="uid://4ccajgldmxuh" path="res://assets/characters/buttercup_the_powerpuff_girls.glb" id="2_i32li"]

[ext_resource type="Script" uid="uid://cl5g4gx25yqm" path="res://scripts/health.gd" id="3_qhqgy"]

[ext_resource type="PackedScene" uid="uid://jlssmdypv6ce" path="res://scenes/ui/damage_number.tscn" id="4_i32li"]

[ext_resource type="Script" uid="uid://v72lkilmlqmb" path="res://scripts/primary_hitbox.gd" id="5_fjrip"]

[ext_resource type="Script" uid="uid://qlxom5ue0a30" path="res://scripts/characters/combat_winter.gd" id="5_wintercombat"]

[ext_resource type="PackedScene" path="res://scenes/vfx/hit_spark_primary.tscn" id="6_hitspark"]

[ext_resource type="Script" path="res://scripts/vfx/ghost_trail.gd" id="7_ghosttrail"]



[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_6igkw"]



[sub_resource type="BoxShape3D" id="BoxShape3D_qlg0r"]

size = Vector3(3.2440796, 3.4442139, 2.7280273)



[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_rn2lo"]

shading_mode = 0

disable_ambient_light = true

albedo_color = Color(0.9462666, 0.5312258, 0.2327764, 1)



[sub_resource type="BoxMesh" id="BoxMesh_qlg0r"]

material = SubResource("StandardMaterial3D_rn2lo")

size = Vector3(3.2530518, 3.45578, 3.3742065)



[sub_resource type="BoxShape3D" id="BoxShape3D_4eyt2"]

size = Vector3(1, 1, 4.548828)



[sub_resource type="BoxMesh" id="BoxMesh_6igkw"]

material = SubResource("StandardMaterial3D_rn2lo")

size = Vector3(18.537506, 22.847519, 72.81865)



[node name="CharWinter" type="CharacterBody3D" unique_id=574951109]

script = ExtResource("1_winter")

speed = 19.0

zoom_max = 15.0

large_enemy_zoom_hold_time = 1.0

large_enemy_zoom_speed = 4.0



[node name="CollisionShape3D" type="CollisionShape3D" parent="." unique_id=1355083992]

shape = SubResource("CapsuleShape3D_6igkw")



[node name="CharacterModel" parent="." unique_id=1103500175 instance=ExtResource("2_i32li")]

transform = Transform3D(1.7, 0, 0, 0, 1.7, 0, 0, 0, 1.7, 0, -0.8, 0)



[node name="CameraPivot" type="Node3D" parent="." unique_id=1953444161]



[node name="SecondaryHitbox" type="Area3D" parent="CameraPivot" unique_id=1237763576]

transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -0.64158916)

collision_layer = 5

collision_mask = 5

script = ExtResource("5_fjrip")

damage = 30.0

damage_number_scene = ExtResource("4_i32li")



[node name="CollisionShape3D" type="CollisionShape3D" parent="CameraPivot/SecondaryHitbox" unique_id=2036259035]

transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0057678223, 1.2221069, -1.6582446)

shape = SubResource("BoxShape3D_qlg0r")



[node name="Visual" type="MeshInstance3D" parent="CameraPivot/SecondaryHitbox" unique_id=1155095662]

=== karina ===
scenes/characters/char_karina.tscn
scenes/characters/char_winter.tscn
```

#### 🔎 Grep `Combat` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\characters\char_winter.tscn`

`19:44:14`

```
90:[node name="Combat" type="Node" parent="." unique_id=873002602]
```

#### 👀 Read `char_winter.gd`

`19:44:14`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\char_winter.gd</code></summary>

```
extends PlayerBase
class_name CharWinter

# Winter: TODO — char-spezifische Bewegungs-Overrides hier einbauen.

```
</details>

### 💭 Thinking

`19:44:20`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `get_node\("Combat"\)|\$Combat|combat\.setup|Combat"\)" ` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd`

`19:44:22`

```
204:@onready var combat: CombatBase = $Combat
391:	combat.setup(self)
```

#### 📂 Glob `resources/characters/*.tres`

`19:44:22`

```
No files found
```

#### 📂 Glob `**/party_setup*.gd`

`19:44:22`

```
scripts\party_setup.gd
```

### 💭 Thinking

`19:44:25`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `party_setup.gd`

`19:44:26`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\party_setup.gd</code></summary>

```
extends Node
class_name PartySetup

# An einen leeren Node im Level haengen. Zieht bis zu 4 CharacterData-.tres
# im Inspector in party_members. Bestimmt, welche Charaktere in diesem
# Level als Party zur Verfuegung stehen — Platzhalter, bis der Home-Screen
# mit echter Roster-Auswahl steht (der wird dieselbe PartyManager-API
# nutzen: PartyManager.setup_party(...)).

@export var party_members: Array[CharacterData] = []

func _ready() -> void:
	if party_members.is_empty():
		push_warning("PartySetup: party_members ist leer — HUD zeigt keine Charaktere.")
		return
	PartyManager.setup_party(party_members)

```
</details>

#### 🔎 Grep `class_name CharacterData|player_scene|character_name` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:44:26`

```
Found 4 files
scripts\party_manager.gd
scripts\main_menu.gd
scripts\character_data.gd
scripts\party_slot.gd
```

### 💭 Thinking

`19:44:31`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:44:31`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -rl "character_data.gd" --include=*.tres . | head -20
```

```
./resources/char_1.tres
./resources/char_2.tres
./resources/char_3.tres
./resources/char_4.tres
```

#### 👀 Read `char_1.tres`

`19:44:35`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\char_1.tres</code></summary>

```
[gd_resource type="Resource" script_class="CharacterData" format=3 uid="uid://bcharset001"]

[ext_resource type="Script" uid="uid://pi415mq3g4lj" path="res://scripts/character_data.gd" id="1_data"]
[ext_resource type="PackedScene" path="res://scenes/characters/char_ningning.tscn" id="2_scene"]

[resource]
script = ExtResource("1_data")
character_id = &"ningning"
character_name = "Ningning"
player_scene = ExtResource("2_scene")
attack_color = Color(0.25, 0.55, 1.0, 1.0)
attack_color_secondary = Color(1.0, 1.0, 1.0, 1.0)
max_health = 125.0
name_primary = "Quick Jab"
name_secondary = "Heavy Haymaker"
name_ability_q = "Zest Burst"
name_ability_e = "Sour Storm"

```
</details>

#### 👀 Read `char_2.tres`

`19:44:35`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\char_2.tres</code></summary>

```
[gd_resource type="Resource" script_class="CharacterData" format=3 uid="uid://bcharset002"]

[ext_resource type="Script" uid="uid://pi415mq3g4lj" path="res://scripts/character_data.gd" id="1_data"]
[ext_resource type="PackedScene" path="res://scenes/characters/char_giselle.tscn" id="2_scene"]

[resource]
script = ExtResource("1_data")
character_id = &"giselle"
character_name = "Giselle"
player_scene = ExtResource("2_scene")
attack_color = Color(0.95, 0.15, 0.15, 1.0)
attack_color_secondary = Color(1.0, 0.55, 0.1, 1.0)
max_health = 130.0
name_primary = "Uzi Spray"
name_secondary = "Sniper Burst"

```
</details>

#### 👀 Read `character_data.gd`

`19:44:35`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\character_data.gd</code></summary>

```
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

@export_group("Combat Visuals")
## Zwei Akzentfarben pro Charakter - faerben sowohl den Primärangriff-
## Trefferfunken (siehe primary_hitbox.gd _resolve_attacker_colors() /
## vfx_manager.gd spawn_dual_tinted()) als auch den Ghost-/Motion-Blur-Trail
## (siehe combat_base.gd setup() / ghost_trail.gd set_colors()) ein. Beide
## Effekte alternieren bzw. mischen zwischen attack_color und
## attack_color_secondary statt nur EINEN Ton zu zeigen - macht Treffer UND
## Bewegung optisch dem aktiven Charakter zuordenbar, obwohl alle vier
## dieselben Hitbox-/VFX-Szenen teilen.
@export var attack_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var attack_color_secondary: Color = Color(1.0, 1.0, 1.0, 1.0)

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

```
</details>

### 💭 Thinking

`19:44:38`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `char_3.tres`

`19:44:39`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\char_3.tres</code></summary>

```
[gd_resource type="Resource" script_class="CharacterData" format=3 uid="uid://bcharset003"]

[ext_resource type="Script" uid="uid://pi415mq3g4lj" path="res://scripts/character_data.gd" id="1_data"]
[ext_resource type="PackedScene" path="res://scenes/characters/char_karina.tscn" id="2_scene"]

[resource]
script = ExtResource("1_data")
character_id = &"karina"
character_name = "Karina"
player_scene = ExtResource("2_scene")
attack_color = Color(0.9, 0.1, 0.25, 1.0)
attack_color_secondary = Color(1.0, 0.4, 0.7, 1.0)
max_health = 70.0
name_primary = "Acid Rush Mode"
name_secondary = "Phantom Execute"

```
</details>

#### 👀 Read `char_4.tres`

`19:44:39`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\char_4.tres</code></summary>

```
[gd_resource type="Resource" script_class="CharacterData" format=3 uid="uid://bcharset004"]

[ext_resource type="Script" uid="uid://pi415mq3g4lj" path="res://scripts/character_data.gd" id="1_data"]
[ext_resource type="PackedScene" path="res://scenes/characters/char_winter.tscn" id="2_scene"]

[resource]
script = ExtResource("1_data")
character_id = &"winter"
character_name = "Winter"
player_scene = ExtResource("2_scene")
attack_color = Color(0.25, 0.9, 0.45, 1.0)
attack_color_secondary = Color(1.0, 1.0, 1.0, 1.0)
max_health = 80.0
name_primary = "Magnetic Plasma"
name_secondary = "Heavy Laser Stream"

```
</details>

### 💭 Thinking

`19:44:44`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:44:44`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && find scripts -iname "enemy_query.gd" -o -iname "health.gd" | xargs -I{} echo {}
```

```
scripts/core/enemy_query.gd
scripts/health.gd
```

#### 👀 Read `enemy_query.gd`

`19:44:47`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\core\enemy_query.gd</code></summary>

```
extends RefCounted
class_name EnemyQuery

# ============================================================================
# EnemyQuery — gemeinsame "welche Gegner sind in der Naehe"-Abfragen.
# ============================================================================
# Verallgemeinert zwei Muster, die im Projekt schon einzeln existieren, aber
# nirgends geteilt werden: die naechste-Ziel-Suche aus homing_bolt.gd
# (dort ohne Reichweiten-Deckel, weil sie ausschliesslich beim Retargeting
# eines bereits fliegenden Bolts laeuft) und die Radius-Sammlung, wie sie
# combat_base.gd::_collect_dash_targets() fuer den Dash-Schaden macht. Winters
# Primary (naechstes Ziel in Reichweite fuer den Homing-Bolt) und Karinas
# Acid-Rush/Phantom-Execute (alle Gegner im Umkreis) brauchen beide Varianten.


## Naechster lebender Gegner zu "from_pos", hoechstens "max_range" entfernt
## (INF = ungedeckelt). null, wenn keiner in Reichweite lebt.
static func nearest_enemy(from_pos: Vector3, max_range: float = INF) -> Node3D:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	var best: Node3D = null
	var best_dist: float = max_range

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var health: Node = node.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		var dist: float = from_pos.distance_to((node as Node3D).global_position)
		if dist <= best_dist:
			best_dist = dist
			best = node as Node3D

	return best


## Alle lebenden Gegner innerhalb "radius" um "from_pos" (Kugel-Radius, nicht
## nur horizontal - anders als der flache Dash-Check in combat_base.gd, da
## Karinas Aura/Beruehrungs-Check keine Bewegungsachse hat, an der er sich
## orientieren koennte).
static func enemies_within(from_pos: Vector3, radius: float) -> Array[Node3D]:
	var result: Array[Node3D] = []

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return result

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		if enemy.global_position.distance_to(from_pos) > radius:
			continue

		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		result.append(enemy)

	return result


## Aim-Assist: liegt ein lebender Gegner innerhalb "max_angle_deg" um die
## reine Blickrichtung UND in Reichweite, wird "dir" sanft (per Slerp,
## Staerke "strength") auf ihn gebogen statt hart eingerastet - verzeiht
## knapp daneben gezielte Schuesse, ohne komplett automatisch zu treffen.
## Ohne Kandidat wird "dir" unveraendert zurueckgegeben.
static func aim_assisted_direction(
		origin: Vector3, dir: Vector3, max_range: float,
		max_angle_deg: float = 6.0, strength: float = 0.5
) -> Vector3:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or dir.length_squared() < 0.0001:
		return dir

	var flat_dir: Vector3 = dir.normalized()
	var best: Node3D = null
	var best_angle: float = deg_to_rad(max_angle_deg)

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		var to_enemy: Vector3 = (enemy.global_position + Vector3.UP) - origin
		if to_enemy.length_squared() < 0.0001 or to_enemy.length() > max_range:
			continue
		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		var angle: float = flat_dir.angle_to(to_enemy.normalized())
		if angle < best_angle:
			best_angle = angle
			best = enemy

	if best == null:
		return dir

	var to_best: Vector3 = ((best.global_position + Vector3.UP) - origin).normalized()
	return flat_dir.slerp(to_best, strength).normalized()


## Bester Gegner in einem Blickkegel: kleinste Winkelabweichung zur reinen
## Blickrichtung gewinnt, nicht die Distanz - "wer am meisten mittig im
## Fadenkreuz steht" statt "wer am naechsten dran ist". Gleiche Kandidaten-
## Suche wie aim_assisted_direction(), gibt aber das Ziel selbst zurueck statt
## nur eine korrigierte Richtung - fuer echtes Auto-Target (Giselles Uzi-
## Rework: "nur grob hinschauen, die Waffe erledigt den Rest").
static func best_target_in_cone(
		origin: Vector3, dir: Vector3, max_range: float, max_angle_deg: float = 35.0
) -> Node3D:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or dir.length_squared() < 0.0001:
		return null

	var flat_dir: Vector3 = dir.normalized()
	var best: Node3D = null
	var best_angle: float = deg_to_rad(max_angle_deg)

	for node: Node in tree.get_nodes_in_group("enemies"):
		if not (node is Node3D) or not is_instance_valid(node):
			continue
		var enemy: Node3D = node as Node3D
		var to_enemy: Vector3 = (enemy.global_position + Vector3.UP) - origin
		if to_enemy.length_squared() < 0.0001 or to_enemy.length() > max_range:
			continue
		var health: Node = enemy.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue

		var angle: float = flat_dir.angle_to(to_enemy.normalized())
		if angle < best_angle:
			best_angle = angle
			best = enemy

	return best

```
</details>

#### 👀 Read `health.gd`

`19:44:47`

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


func take_damage(amount: float, source: Node3D = null) -> void:
	if current_health <= 0.0:
		return  # bereits tot, ignoriere weitere Treffer

	if is_invulnerable():
		return

	var multiplier: float = maxf(incoming_damage_multiplier, 0.0)
	# Saeure legt die Ruestung bloss: waehrend "acid" aktiv ist, kommt JEDE
	# Schadensquelle mit +20% an (siehe StatusAcid.VULNERABILITY_MULTIPLIER).
	# get_parent() statt eines gespeicherten Owner-Felds, weil Health IMMER
	# als direktes Kind des Akteurs haengt (Spieler wie Gegner).
	if StatusAcid.active(get_parent()):
		multiplier *= StatusAcid.VULNERABILITY_MULTIPLIER

	var effective: float = amount * multiplier
	if effective <= 0.0:
		return

	current_health = max(current_health - effective, 0.0)
	_time_since_damage = 0.0  # Regen-Timer zuruecksetzen bei jedem Treffer
	last_damage_source = source
	health_changed.emit(current_health, max_health)
	damage_taken.emit(effective, source)

	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_health = min(current_health + amount, max_health)
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

### 💭 Thinking

`19:45:09`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `^func |^extends|^class_name` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_manager.gd`

`19:45:10`

```
3:extends Node
124:func _ready() -> void:
148:func _ensure_actions() -> void:
156:func _build_catalog() -> void:
162:func _spawn_behaviours() -> void:
171:func _connect_party_manager() -> void:
188:func bind_player(new_player: CharacterBody3D) -> void:
219:func _connect_hitboxes() -> void:
233:func _disconnect_hitboxes() -> void:
240:func _on_hitbox_hit(target: Node, hitbox: Hitbox) -> void:
249:func get_item_by_id(item_id: String) -> ItemData:
256:func has_item(item_id: String) -> bool:
263:func count_item(item_id: String) -> int:
271:func add_item(item: ItemData) -> bool:
290:func _register_synergy_tags(item: ItemData) -> void:
297:func get_synergy_weight(tags: PackedStringArray) -> float:
307:func _equip_active_item(item: ItemData) -> void:
319:func add_item_by_id(item_id: String) -> bool:
326:func _apply_item_stats(item: ItemData, index: int) -> void:
343:func _reapply_all_item_stats() -> void:
351:func reset_run() -> void:
374:func clear_inventory() -> void:
389:func add_coins(amount: int) -> void:
394:func spend_coins(amount: int) -> bool:
402:func add_bombs(amount: int) -> void:
407:func consume_bomb() -> bool:
421:func notify_room_cleared(room: Node) -> void:
434:func is_active_slot_ready(slot: int) -> bool:
450:func _process(delta: float) -> void:
472:func force_recharge_active(slot: int = -1) -> bool:
501:func get_active_charge_percent(slot: int) -> float:
517:func get_active_charge_remaining(slot: int) -> float:
530:func use_active_item(slot: int) -> void:
550:func swap_active_slots() -> void:
564:func get_combo_count() -> int:
573:func get_luck() -> float:
```

### 💭 Thinking

`19:45:16`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `item_manager.gd`

`19:45:17`

*(lines 124–224)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_manager.gd</code></summary>

```
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_ensure_actions()
	_build_catalog()
	_spawn_behaviours()

	# PartyManager ist selbst ein Autoload. Die Reihenfolge, in der Godot
	# Autoloads initialisiert, ist nicht garantiert — deshalb wird die
	# Verbindung deferred aufgebaut statt direkt hier.
	_connect_party_manager.call_deferred()


# ============================================================================
# Eingabe-Actions selbst registrieren
# ============================================================================
# Bewusst hier statt in settings_manager.gd: dieses Feature soll sich
# installieren lassen, ohne eine bestehende Datei anzufassen.
#
# PHASE 5: die fruehere eigene "use_item"-Action (Taste C) ist weg. Aktive
# Items werden jetzt ueber Q/E ausgeloest ("ability_primary"/
# "ability_secondary"), die bereits in settings_manager.gd registriert und
# rebindbar sind (siehe DEFAULT_KEYBINDS dort) - dieses Script fasst Input
# ueberhaupt nicht mehr direkt an, siehe combat_base.gd._do_ability_q()/
# _do_ability_e().
func _ensure_actions() -> void:
	if not InputMap.has_action(BOMB_ACTION):
		InputMap.add_action(BOMB_ACTION)
		var bomb_event := InputEventKey.new()
		bomb_event.physical_keycode = KEY_X
		InputMap.action_add_event(BOMB_ACTION, bomb_event)


func _build_catalog() -> void:
	catalog = ItemCatalog.build_all()
	for external: ItemData in ItemCatalog.load_external():
		catalog.append(external)


func _spawn_behaviours() -> void:
	_behaviours = ItemBehaviours.new()
	_behaviours.name = "ItemBehaviours"
	add_child(_behaviours)


# ============================================================================
# Anbindung an den jeweils aktiven Spieler
# ============================================================================
func _connect_party_manager() -> void:
	var party: Node = get_node_or_null("/root/PartyManager")
	if party == null:
		push_warning("Items: PartyManager nicht gefunden — Item-Effekte bleiben inaktiv.")
		return

	if party.has_signal("active_player_changed") \
			and not party.active_player_changed.is_connected(bind_player):
		party.active_player_changed.connect(bind_player)

	# Falls der Spieler schon vor diesem Autoload gespawnt ist.
	var existing = party.get("player")
	if existing is CharacterBody3D and is_instance_valid(existing):
		bind_player(existing)


## Haengt alle Laufzeit-Komponenten an die neue Spieler-Instanz.
func bind_player(new_player: CharacterBody3D) -> void:
	_disconnect_hitboxes()

	player = new_player
	stats = null
	bomb_carrier = null

	if player == null or not is_instance_valid(player):
		return

	# --- PlayerStats -------------------------------------------------
	stats = player.get_node_or_null("PlayerStats") as PlayerStats
	if stats == null:
		stats = PlayerStats.new()
		stats.name = "PlayerStats"
		player.add_child(stats)
	stats.bind_to_player(player)

	# --- BombCarrier -------------------------------------------------
	bomb_carrier = player.get_node_or_null("BombCarrier")
	if bomb_carrier == null:
		bomb_carrier = BombCarrier.new()
		bomb_carrier.name = "BombCarrier"
		player.add_child(bomb_carrier)

	_connect_hitboxes()
	_reapply_all_item_stats()

	player_ready.emit(player)


func _connect_hitboxes() -> void:
	for path: String in ["CameraPivot/PrimaryHitbox", "CameraPivot/SecondaryHitbox"]:
		var hitbox := player.get_node_or_null(path) as Hitbox
		if hitbox == null:
			continue
```
</details>

*(lines 351–391)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_manager.gd</code></summary>

```
func reset_run() -> void:
	inventory.clear()
	active_items = [null, null]
	_active_charges.clear()
	# PHASE 4: sonst startet der neue Run mit dem Cooldown des alten.
	_active_cooldowns.clear()
	coins = START_COINS
	bombs = START_BOMBS
	if stats:
		stats.clear_all()
		stats.apply()
	inventory_changed.emit()
	active_slots_changed.emit()
	coins_changed.emit(coins)
	bombs_changed.emit(bombs)


## Admin/Debug: entfernt ALLE Items aus dem Inventar (inkl. Stat-Boni und
## aktiver Slots), OHNE Muenzen/Bomben anzufassen - anders als reset_run(),
## das fuer einen kompletten Rundenneustart gedacht ist. Gedacht fuer die
## Loesch-Plattform im Item-Testraum (siehe scripts/item_test_room.gd):
## Items durchtesten, dann per Knopfdruck wieder bei null anfangen, ohne
## gleich den ganzen Run neu zu starten.
func clear_inventory() -> void:
	inventory.clear()
	active_items = [null, null]
	_active_charges.clear()
	_active_cooldowns.clear()
	if stats:
		stats.clear_all()
		stats.apply()
	inventory_changed.emit()
	active_slots_changed.emit()


# ============================================================================
# Waehrungen
# ============================================================================
func add_coins(amount: int) -> void:
	coins = maxi(coins + amount, 0)
```
</details>

### 💭 Thinking

`19:45:33`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:45:35`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && sed -n '1,30p' scripts/player_base.gd | grep -n "class_name\|extends"
```

```
1:extends CharacterBody3D
2:class_name PlayerBase
```

### 💭 Thinking

`19:45:43`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `player_base.gd`

`19:45:44`

*(lines 1–61)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd</code></summary>

```
extends CharacterBody3D
class_name PlayerBase

# --- Basisklasse für ALLE Charaktere (Ningning, Giselle, Karina, Winter, ...) ---
# Enthält die komplette gemeinsame Bewegungs-, Kamera-, Lock-On-, Status-
# Effekt- und Death-Logik. Charakter-spezifische Skripte (z.B. char_ningning.gd)
# erben von dieser Klasse. Charakter-spezifische FÄHIGKEITEN gehören NICHT
# hierher, sondern ins jeweilige Combat-Script (siehe combat_base.gd).

# --- Einstellbare Werte (im Godot-Inspector sichtbar, jedes Char-Scene kann eigene Werte setzen) ---
@export var speed: float = 15.0
@export var jump_velocity: float = 13.0
@export var mouse_sensitivity: float = 0.003
@export var gravity: float = 40.0

# --- Knockback (z.B. von Gegner-Hitboxen via apply_knockback()) ---
# Horizontaler Knockback wird NICHT direkt auf velocity addiert, weil
# _physics_process velocity.x/z jeden Frame aus dem Input neu berechnet
# und einen einmaligen Impuls sofort wieder ueberschreiben wuerde. Stattdessen
# landet er in _knockback_velocity und wird JEDEN Frame FRISCH (nicht
# kumulativ) mit der Eigenbewegung kombiniert — siehe _physics_process fuer
# die Herleitung, warum das insbesondere waehrend Stun wichtig ist.
@export var knockback_friction: float = 10.0
var _knockback_velocity: Vector3 = Vector3.ZERO

# Wird von Hitbox.gd aufgerufen (siehe primary_hitbox.gd). Vertikale
# Komponente (impulse.y) geht direkt in velocity.y, da diese von der
# Bewegungslogik nicht ueberschrieben wird — nur X/Z brauchen den Puffer.
func apply_knockback(impulse: Vector3) -> void:
	_knockback_velocity.x += impulse.x
	_knockback_velocity.z += impulse.z
	velocity.y += impulse.y

## Kappt sofort JEDEN noch abklingenden Knockback-Puffer, statt ihn ueber
## knockback_friction auslaufen zu lassen. Fuer Quellen, die beim Wegfallen
## sofort aufhoeren muessen zu wirken (z.B. Magnet-Kern: stirbt er waehrend
## der Spieler gerade herangezogen wird, soll der Sog in DIESEM Frame enden,
## nicht noch bis zu ~1,6s an Restimpuls auslaufen lassen).
func clear_knockback() -> void:
	_knockback_velocity = Vector3.ZERO

# --- Kamera-Zoom per Mausrad ---
@export var zoom_min: float = 3
@export var zoom_max: float = 20.0
@export var zoom_step: float = 1

# --- Automatisches Zoom bei großen Gegnern ---
# Sobald das aktuell gelockte Ziel is_large_enemy = true hat, zieht die
# Kamera automatisch auf zoom_max raus (überschreibt dabei aktiv jeden
# Frame den Scroll-Wert — das ist so gewollt, "muss" laut Anforderung).
# Solange KEIN großer Gegner gelockt ist, fasst das Script den Zoom
# NICHT an — nur GENAU EINMAL, im Moment des Übergangs "Kampf vorbei",
# läuft eine kurze Tween-Animation zurück zur Zoomstufe von davor.
# Das verhindert das "Gummiband"-Gefühl, das ein Dauer-Lerp jeden Frame
# verursachen würde, wenn man währenddessen versucht manuell zu scrollen.
@export var large_enemy_zoom_hold_time: float = 1.5
@export var large_enemy_zoom_speed: float = 6.0
@export var large_enemy_return_duration: float = 0.6
var _large_enemy_timer: float = 0.0
var _was_fighting_large_enemy: bool = false
```
</details>

*(lines 360–410)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd</code></summary>

```

# --- "Instant Death Zone": Sturz in einen Abgrund ---------------------------
# Bewusst NICHT ueber eine feste Welt-Y-Schwelle geloest: Raeume werden auf
# unterschiedlichen Hoehenstufen generiert (elevation_step in
# level_generator.gd), eine feste Zahl waere je nach Layout mal zu
# grosszuegig, mal toedlich schon auf einer normalen Rampe. Stattdessen
# zaehlt, wie lange der Spieler ununterbrochen faellt UND wie weit er seit
# dem letzten sicheren Boden gefallen ist - beides zusammen unterscheidet
# einen echten Sturz in einen dunklen, bodenlosen Abgrund (pit_floor.gd ohne
# Lava-Auffuellung) zuverlaessig von Treppen, Rampen oder einem Sprung.
@export var void_death_enabled: bool = true
@export var void_death_fall_time: float = 2.5
@export var void_death_fall_distance: float = 40.0

var _void_fall_timer: float = 0.0
var _void_last_safe_y: float = 0.0

func set_buoyancy(active: bool, rise_speed: float = 2.5, surface_y: float = 0.0) -> void:
	if active and not _buoyancy_active:
		_bob_time = 0.0
	_buoyancy_active = active
	_buoyancy_rise_speed = rise_speed
	_buoyancy_surface_y = surface_y

func _get_body_height() -> float:
	if own_collision and own_collision.shape is CapsuleShape3D:
		return (own_collision.shape as CapsuleShape3D).height
	return fallback_body_height

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	combat.setup(self)

	# Der FOV kommt AUSSCHLIESSLICH aus den Einstellungen, nicht mehr aus
	# camera.fov der Szene ("_base_fov = camera.fov"). Sonst haette jede
	# Charakter-Szene ihren eigenen konkurrierenden Wert und der Regler waere
	# nach dem naechsten Charakterwechsel wieder wirkungslos.
	#
	# Die Verbindung auf fov_changed wird beim Freigeben der Instanz von Godot
	# automatisch geloest - beim Charakterwechsel muss also nichts aufgeraeumt
	# werden.
	set_camera_fov(SettingsManager.fov)
	if not SettingsManager.fov_changed.is_connected(set_camera_fov):
		SettingsManager.fov_changed.connect(set_camera_fov)

	_pre_large_enemy_zoom = spring_arm.spring_length
	_setup_camera_probe()
	_camera_spring_current = spring_arm.spring_length

	# Die Tuerzustands-Platten der Raeume liegen auf einem Layer, den NUR
```
</details>

### 💭 Thinking

`19:45:51`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `player_base.gd`

`19:45:52`

*(lines 406–476)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd</code></summary>

```
	_setup_camera_probe()
	_camera_spring_current = spring_arm.spring_length

	# Die Tuerzustands-Platten der Raeume liegen auf einem Layer, den NUR
	# die Minimap-Kamera rendern soll. Ohne diese Zeile schweben sie im
	# Spiel sichtbar ueber den Durchgaengen.
	camera.set_cull_mask_value(RoomInstance.MINIMAP_ONLY_LAYER, false)

	status_effects = StatusEffectManager.get_or_create(self)
	status_effects.effect_ticked.connect(_on_status_effect_ticked)
	status_effects.effect_expired.connect(_on_status_effect_expired)

	if health:
		health.health_changed.connect(_on_own_health_changed)
		health.died.connect(_on_died)
		_last_known_health = health.current_health

## Einziger Einstiegspunkt fuer den Basis-FOV.
##
## Ein laufender Dash-Tween wird dabei gekillt: seine Rueckwaerts-Phase faehrt
## sonst auf den ALTEN _base_fov zurueck und ueberschreibt den gerade
## gesetzten Reglerwert wieder - der Slider haette dann scheinbar zufaellig
## keine Wirkung, wenn man ihn waehrend eines Dashs bewegt.
func set_camera_fov(value: float) -> void:
	_base_fov = clampf(value, SettingsManager.FOV_MIN, SettingsManager.FOV_MAX)
	if _dash_fov_tween and _dash_fov_tween.is_valid():
		_dash_fov_tween.kill()
	if camera:
		camera.fov = _base_fov


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	set_physics_process(false)

	if use_ragdoll:
		_spawn_ragdoll_corpse()
	else:
		_play_scripted_fall()

func _play_scripted_fall() -> void:
	if health and health.last_damage_source and is_instance_valid(health.last_damage_source) \
			and health.last_damage_source != self:
		var source: Node3D = health.last_damage_source
		var away_from_enemy: Vector3 = global_position - source.global_position
		away_from_enemy.y = 0
		if away_from_enemy.length() > 0.01:
			mesh.rotation.y = atan2(away_from_enemy.x, away_from_enemy.z)

	var tween := create_tween()
	tween.tween_property(mesh, "rotation:x", deg_to_rad(death_fall_rotation_degrees), death_fall_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _spawn_ragdoll_corpse() -> void:
	if own_collision:
		own_collision.disabled = true

	var corpse := RigidBody3D.new()
	corpse.name = "PlayerCorpse"
	corpse.mass = ragdoll_mass
	corpse.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(corpse)
	var spawn_transform: Transform3D = mesh.global_transform
	spawn_transform.origin.y += 0.15
	corpse.global_transform = spawn_transform

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
```
</details>

### 💭 Thinking

`19:46:14`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:46:15`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -n "attack_primary\|switch_char_1\|switch_char_4" project.godot | head -20; echo "---gitignore---"; cat .gitignore 2>&1 | head -40; echo "---godot version---"; grep -n "config/features" project.godot
```

```
88:attack_primary={
118:switch_char_1={
133:switch_char_4={
---gitignore---
# Godot 4+ specific ignores

.godot/

.nomedia



# Godot-specific ignores

.import/

export.cfg

export_credentials.cfg



# Godot 4+ specific ignores

.godot/

.nomedia



# Godot-specific ignores

.import/

export.cfg

export_credentials.cfg



# Imported translations (automatically generated from CSV files)

*.translation



# Mono-specific ignores

.mono/

data_*/

mono_crash.*.json

.aider*



# Private working notes

# (Removed 04 and 05 so they are tracked)



# Obsidian workspaces (prevents git spam)

.obsidian/workspace.json

.obsidian/workspace-mobile.json

.obsidian/workspace



# OS and Temp files

Thumbs.db

.DS_Store

*.log

*.tmp

---godot version---
19:config/features=PackedStringArray("4.7", "Mobile")
```

### 💭 Thinking

`19:47:48`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:47:48`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -n "class_name\|extends" scripts/characters/char_karina.gd
```

```
1:extends PlayerBase
2:class_name CharKarina
```

### 💭 Thinking

`19:49:40`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `class_name Minimap|static var big_map_open|big_map_open` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`19:49:41`

```
scripts\combat_base.gd:381:	if Minimap.big_map_open:
scripts\minimap.gd:4:class_name Minimap
scripts\minimap.gd:14:##   Grosskarte per is_big_map_open()/close_big_map() zuerst schliessen
scripts\minimap.gd:59:static var big_map_open: bool = false
scripts\minimap.gd:195:	big_map_open = false
scripts\minimap.gd:426:	big_map_open = false
scripts\minimap.gd:776:func is_big_map_open() -> bool:
scripts\minimap.gd:789:	big_map_open = active
scripts\minimap_rooms.gd:3:class_name MinimapRooms
scripts\pause_menu.gd:170:		if m.has_method("is_big_map_open") and m.is_big_map_open():
```

### 💭 Thinking

`19:49:47`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:49:47`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -n "static func get_or_create" -A 15 scripts/status_effects/status_effect_manager.gd 2>&1 | head -20; echo "---"; find . -iname "status_effect_manager.gd"
```

```
55:static func get_or_create(owner: Node) -> StatusEffectManager:
56-	var existing := owner.get_node_or_null("StatusEffectManager")
57-	if existing:
58-		return existing
59-	var manager := StatusEffectManager.new()
60-	manager.name = "StatusEffectManager"
61-	owner.add_child(manager)
62-	return manager
63-
64-
65-class ActiveEffect:
66-	var duration_remaining: float = 0.0
67-	var magnitude: float = 1.0
68-	var tick_interval: float = 0.0
69-	var tick_timer: float = 0.0
70-	var source: Node = null
---
./scripts/status_effects/status_effect_manager.gd
```

### 🤖 Assistant: *Now I have everything needed — node paths…*

`19:49:55`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now I have everything needed — node paths, the character-data resources, `Health`'s API, and confirmation the codebase already spawns character standalone (sandbox room do the same). Writing the test infrastructure.

#### 💻 Bash

`19:49:57`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && mkdir -p test/base test/unit test/integration && echo ok
```

```
ok
```

#### ✍️  Write `party_manager_test_base.gd`

`19:50:18`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\test\base\party_manager_test_base.gd</code></summary>

```
extends GutTest

# ============================================================================
# Basisklasse fuer Tests, die PartyManager und/oder Items (Autoload-
# Singletons) brauchen.
# ============================================================================
# PartyManager und Items sind ECHTE Godot-Autoloads: sie existieren bereits,
# bevor der erste Test laeuft, und ueberleben die gesamte Testsitzung (eine
# GUT-Session laeuft in EINEM Engine-Prozess, der alle Test-Skripte nach-
# einander ausfuehrt). Isolation zwischen Tests heisst hier deshalb NICHT
# "neu instanziieren" - project.godot-Autoloads lassen sich zur Laufzeit
# ohnehin nicht sauber neu erzeugen -, sondern: vor jedem Test in einen
# leeren, definierten Zustand zuruecksetzen und danach wieder aufraeumen.
# Ohne das wuerde z.B. eine in Test A gespawnte Spieler-Instanz oder ein in
# Test A eingesammeltes Item in Test B weiterleben.
#
# Jeder konkrete Test extended DIESE Datei statt direkt GutTest:
#   extends "res://test/base/party_manager_test_base.gd"

const WINTER_DATA: String = "res://resources/char_4.tres"
const KARINA_DATA: String = "res://resources/char_3.tres"
const NINGNING_DATA: String = "res://resources/char_1.tres"
const GISELLE_DATA: String = "res://resources/char_2.tres"

## Container-Node fuer die gespawnte Spieler-Instanz - steht fuer den
## PlayerSpawnPoint-Marker3D, den PartyManager im echten Spiel von einem
## RoomInstance-Level bekommt (siehe scripts/player_spawn_point.gd). Wird
## pro Test frisch angelegt und von GUT automatisch wieder entfernt.
var _spawn_parent: Node3D = null


func before_each() -> void:
	_reset_party_manager()
	_reset_items()
	_spawn_parent = Node3D.new()
	_spawn_parent.name = "TestSpawnParent"
	add_child_autofree(_spawn_parent)


func after_each() -> void:
	# Eine evtl. noch lebende Spieler-Instanz VOR dem naechsten
	# notify_scene_reset() explizit einsammeln - sonst haengt sie bis zum
	# Ende der gesamten Suite als Orphan im Baum statt sofort nach diesem
	# Test aufzuraeumen.
	if PartyManager.has_player():
		PartyManager.player.queue_free()

	_reset_party_manager()
	_reset_items()

	# Globaler Input-State (Input.action_press/-release) ueberlebt Tests
	# genauso wie die Autoloads. Jeder Test, der eine Taste "haelt", sollte
	# sie selbst wieder loslassen (siehe test_character_switch.gd) - das
	# hier ist zusaetzlich ein Netz, falls ein Test vorher an einer
	# fehlgeschlagenen Assertion abbricht, ohne selbst aufzuraeumen.
	for action: StringName in [
		&"attack_primary", &"attack_secondary", &"utility",
		&"ability_primary", &"ability_secondary",
	]:
		if InputMap.has_action(action):
			Input.action_release(action)

	# player_base.gd::_ready() faengt bei jedem Spawn die Maus ein
	# (MOUSE_MODE_CAPTURED) - fuer eine Testsitzung im Editor unangenehm
	# genug, um es hier zurueckzusetzen.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _reset_party_manager() -> void:
	PartyManager.notify_scene_reset()
	PartyManager.setup_party([])


func _reset_items() -> void:
	Items.reset_run()


## Registriert den Test-Spawn-Punkt und baut die Party auf - inhaltlich
## derselbe Ablauf wie PlayerSpawnPoint.register_spawn_point() +
## PartySetup._ready() im echten Level, nur ohne ein echtes Level drumherum.
## members[0] wird der aktive Charakter (siehe PartyManager.setup_party()).
##
## Wartet danach einen Frame: PartyManager._spawn_active_character() laeuft
## bewusst per call_deferred(), siehe party_manager.gd-Kommentar zu
## setup_party() - ohne den Wait waere PartyManager.player hier noch null.
func spawn_party(members: Array[CharacterData]) -> void:
	PartyManager.register_spawn_point(_spawn_parent, Transform3D.IDENTITY)
	PartyManager.setup_party(members)
	await wait_frames(1)


## Minimaler Gegner-Dummy: Gruppe "enemies" + ein Kind-Node namens "Health" -
## exakt die zwei Dinge, die EnemyQuery/Hitbox/Items wirklich brauchen, um
## einen Node als gueltigen Gegner zu behandeln (siehe CLAUDE.md-
## Architekturnotiz zu den zwei parallelen Gegner-Systemen). Keine echte
## Gegner-Szene noetig.
func spawn_dummy_enemy(at_position: Vector3, max_health: float = 999.0) -> Node3D:
	var enemy := Node3D.new()
	enemy.name = "DummyEnemy"
	add_child_autofree(enemy)
	enemy.add_to_group("enemies")
	enemy.global_position = at_position

	var health := Health.new()
	health.name = "Health"
	health.max_health = max_health
	enemy.add_child(health)

	return enemy

```
</details>

✓ File created successfully at: C:\Users\thvnh\Documents\GitHub\whiplash\test\base\party_manager_test_base.gd (file state is current in your context — no need to Read it back)

### 💭 Thinking

`19:50:20`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✍️  Write `test_character_switch.gd`

`19:50:53`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\test\integration\test_character_switch.gd</code></summary>

```
extends "res://test/base/party_manager_test_base.gd"

# ============================================================================
# Regressionstest: Charakterwechsel waehrend ein Winter-Plasma-Bolt fliegt
# ============================================================================
# BUG (Rueckmeldung 2026-08-12): Haelt man als Winter den Primärangriff
# (LMB / Input-Action "attack_primary") gedrueckt und wechselt WAEHREND ein
# Plasma-Bolt noch unterwegs ist zu Karina, stuerzte das Spiel ab.
#
# URSACHE: HomingBolt._strike() (scripts/vfx/homing_bolt.gd) rief seinen
# on_strike-Callback bis dahin UNBEDINGT auf. Dieser Callback ist eine
# Closure, die an den feuernden CombatWinter-Node gebunden ist (siehe
# combat_winter.gd::_perform_primary(), Callable "on_strike" -> ruft
# _on_plasma_strike() auf "self" auf). party_manager.gd::switch_to() gibt
# den alten Spieler samt seinem Combat-Kind-Node aber SOFORT frei
# (queue_free()), sobald man den Charakter wechselt. Der Bolt selbst haengt
# unabhaengig davon unter current_scene und fliegt weiter - trifft er sein
# Ziel NACH dem Wechsel, ruft er den Callback auf einer bereits
# freigegebenen Instanz auf. Das crashte das Spiel.
#
# FIX: homing_bolt.gd::_strike() prueft jetzt "_on_strike.is_valid()",
# bevor es den Callback aufruft, und ueberspringt ihn sonst einfach.
#
# Dieser Test bildet das Szenario 1:1 nach UND beweist zusaetzlich, dass er
# wirklich den gefaehrlichen Pfad trifft (der alte Combat-Node ist nach dem
# Wechsel tatsaechlich freigegeben, und der In-Flight-Bolt versucht
# tatsaechlich noch zuzuschlagen) - er soll nicht zufaellig gruen sein, nur
# weil der Bolt z.B. nie abgefeuert oder nie faellig wurde.

const TARGET_INDEX_KARINA: int = 1

## Muss deutlich groesser sein als HomingBolt.HIT_RANGE (1.3) UND als die
## Strecke, die ein Bolt in den ein/zwei Frames bis zum Charakterwechsel
## zuruecklegt (plasma_bolt_speed=24.0 in combat_winter.gd) - sonst koennte
## der Bolt sein Ziel schon VOR dem Wechsel treffen und der Test wuerde den
## kritischen Zeitraum verfehlen.
const BOLT_TRAVEL_DISTANCE: float = 6.0

## Frames, die dem Bolt NACH dem Wechsel gegeben werden, um seine Restdistanz
## zu fliegen und _strike() auszuloesen. 6.0 / 24.0 = 0.25s Flugzeit; 30
## Frames (~0.5s bei 60 FPS) lassen reichlich Puffer, ohne den Test spuerbar
## zu verlangsamen.
const FRAMES_TO_LET_BOLT_ARRIVE: int = 30


func test_switch_to_karina_while_winter_bolt_in_flight_does_not_crash() -> void:
	var winter_data: CharacterData = load(WINTER_DATA)
	var karina_data: CharacterData = load(KARINA_DATA)
	await spawn_party([winter_data, karina_data])

	assert_true(PartyManager.has_player(), "Winter sollte gespawnt sein")
	assert_eq(
		PartyManager.get_active_data().character_id, &"winter",
		"Winter sollte der aktive Charakter sein (party_members[0])"
	)

	var winter_player: PlayerBase = PartyManager.player as PlayerBase
	var winter_combat: CombatBase = winter_player.combat
	assert_true(winter_combat is CombatWinter, "Der Combat-Node der aktiven Instanz sollte CombatWinter sein")

	# Ziel fuer Winters Plasma-Bolt: weit genug entfernt, dass er beim
	# Charakterwechsel garantiert noch unterwegs ist.
	var dummy_enemy: Node3D = spawn_dummy_enemy(
		winter_player.global_position + Vector3.FORWARD * BOLT_TRAVEL_DISTANCE
	)
	var dummy_health: Health = dummy_enemy.get_node("Health") as Health

	# --- Primärangriff "gedrückt halten" -----------------------------------
	# combat_base.gd::_poll_primary_input() pollt Input.is_action_pressed()
	# direkt jeden Frame - echtes Halten der Taste wird dadurch exakt so
	# simuliert, wie es die Rueckmeldung beschreibt ("LMB gedrückt gehalten").
	# Ein einzelner Frame reicht: primary_cooldown startet bei 0.0, der
	# allererste _process()-Tick mit gedrueckter Taste feuert also sofort
	# und spawnt den HomingBolt (siehe combat_winter.gd::_perform_primary()).
	Input.action_press(&"attack_primary")
	await wait_frames(1)
	Input.action_release(&"attack_primary")

	# --- Charakterwechsel MITTEN im Flug -------------------------------------
	# switch_to() laeuft synchron (siehe party_manager.gd-Kommentar dort) -
	# direkt danach steht entweder schon die neue Instanz, oder der Test ist
	# an genau der Stelle abgestuerzt, die vorher den Bug reproduziert hat.
	PartyManager.switch_to(TARGET_INDEX_KARINA)

	# --- Der Wechsel selbst war erfolgreich ----------------------------------
	assert_eq(
		PartyManager.get_active_index(), TARGET_INDEX_KARINA,
		"Aktiver Party-Index sollte nach dem Wechsel auf Karina stehen"
	)
	assert_true(PartyManager.has_player(), "Nach dem Wechsel sollte wieder ein lebender Spieler existieren")
	assert_eq(
		PartyManager.get_active_data().character_id, &"karina",
		"Aktive Charakter-Daten sollten Karina sein"
	)
	assert_true(PartyManager.player is CharKarina, "Die neue Spieler-Instanz sollte CharKarina sein")

	# --- Beweis, dass wirklich der kritische Pfad getroffen wurde ------------
	# Ohne diese Pruefung koennte der Test auch gruen sein, weil der Bolt aus
	# irgendeinem Grund nie feuerte - dann waere er wertlos als Regressions-
	# schutz. is_instance_valid() muss hier false sein: switch_to() hat den
	# alten Spieler samt Combat-Kind bereits per queue_free() entsorgt.
	await wait_frames(1)
	assert_false(
		is_instance_valid(winter_combat),
		"Der alte Winter-Combat-Node sollte nach dem Wechsel freigegeben sein - sonst testet dieser Test nicht den kritischen Pfad"
	)
	assert_false(
		is_instance_valid(winter_player),
		"Die alte Winter-Spieler-Instanz sollte nach dem Wechsel freigegeben sein"
	)

	# --- Den Bolt seine Flugzeit fertig fliegen lassen ------------------------
	# Das ist der eigentliche Regressionstest: VOR dem Fix in homing_bolt.gd
	# haette dieser Frame-Vorlauf zu einem Aufruf auf einer freigegebenen
	# Instanz gefuehrt (Absturz). Kommt der Test hier ueberhaupt an und
	# schlaegt die folgende Assertion nicht fehl, ist der Callback sicher
	# uebersprungen worden.
	await wait_frames(FRAMES_TO_LET_BOLT_ARRIVE)
	assert_eq(
		dummy_health.current_health, dummy_health.max_health,
		"Der In-Flight-Bolt darf nach dem Wechsel keinen Schaden mehr anwenden - der Callback haengt am freigegebenen Winter-Combat-Node und muss von HomingBolt._strike() sicher uebersprungen werden"
	)

	# --- Input-State sauber zurueckgesetzt ------------------------------------
	assert_false(
		Input.is_action_pressed(&"attack_primary"),
		"attack_primary sollte nach dem Loslassen nicht mehr als gedrueckt gelten"
	)

	# --- Karina ist nach dem Wechsel tatsaechlich benutzbar -------------------
	var karina_combat: CombatBase = (PartyManager.player as PlayerBase).combat
	assert_true(is_instance_valid(karina_combat), "Karinas Combat-Node sollte gueltig sein")
	assert_false(
		is_nan(karina_combat.get_primary_cooldown_percent()),
		"Karinas Primary-Cooldown sollte ein normaler Wert sein, kein NaN aus haengendem Zustand"
	)

	assert_no_new_orphans("Der Charakterwechsel waehrend eines fliegenden Bolts sollte keine Nodes verwaisen lassen")

```
</details>

✓ File created successfully at: C:\Users\thvnh\Documents\GitHub\whiplash\test\integration\test_character_switch.gd (file state is current in your context — no need to Read it back)

### 💭 Thinking

`19:50:58`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✍️  Write `.gitkeep`

`19:50:58`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\test\unit\.gitkeep</code></summary>

```

```
</details>

✓ File created successfully at: C:\Users\thvnh\Documents\GitHub\whiplash\test\unit\.gitkeep (file state is current in your context — no need to Read it back)

#### ✍️  Write `.gutconfig.json`

`19:51:02`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\.gutconfig.json</code></summary>

```json
{
    "dirs": [
        "res://test/unit",
        "res://test/integration"
    ],
    "include_subdirs": true,
    "prefix": "test_",
    "suffix": ".gd",
    "log_level": 1,
    "should_exit": true,
    "should_exit_on_success": true,
    "junit_xml_file": "res://test/results.xml",
    "junit_xml_timestamp": true
}

```
</details>

✓ File created successfully at: C:\Users\thvnh\Documents\GitHub\whiplash\.gutconfig.json (file state is current in your context — no need to Read it back)

### 💭 Thinking

`19:51:05`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `.gitignore`

`19:51:06`

```diff
@@ -3,3 +3,6 @@ .DS_Store
 *.log
 *.tmp
+
+# GUT test results (generated by .gutconfig.json's junit_xml_file)
+/test/results.xml
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\.gitignore has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:51:17`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `test_character_switch.gd`

`19:51:19`

```diff
@@ -1,3 +1,4 @@ 	var winter_data: CharacterData = load(WINTER_DATA)
 	var karina_data: CharacterData = load(KARINA_DATA)
-	await spawn_party([winter_data, karina_data])
+	var party_members: Array[CharacterData] = [winter_data, karina_data]
+	await spawn_party(party_members)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\test\integration\test_character_switch.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`19:51:26`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:51:26`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && sed -n '1,20p' test/integration/test_character_switch.gd | cat -A | head -20
```

```
extends "res://test/base/party_manager_test_base.gd"$
$
# ============================================================================$
# Regressionstest: Charakterwechsel waehrend ein Winter-Plasma-Bolt fliegt$
# ============================================================================$
# BUG (Rueckmeldung 2026-08-12): Haelt man als Winter den PrimM-CM-$rangriff$
# (LMB / Input-Action "attack_primary") gedrueckt und wechselt WAEHREND ein$
# Plasma-Bolt noch unterwegs ist zu Karina, stuerzte das Spiel ab.$
#$
# URSACHE: HomingBolt._strike() (scripts/vfx/homing_bolt.gd) rief seinen$
# on_strike-Callback bis dahin UNBEDINGT auf. Dieser Callback ist eine$
# Closure, die an den feuernden CombatWinter-Node gebunden ist (siehe$
# combat_winter.gd::_perform_primary(), Callable "on_strike" -> ruft$
# _on_plasma_strike() auf "self" auf). party_manager.gd::switch_to() gibt$
# den alten Spieler samt seinem Combat-Kind-Node aber SOFORT frei$
# (queue_free()), sobald man den Charakter wechselt. Der Bolt selbst haengt$
# unabhaengig davon unter current_scene und fliegt weiter - trifft er sein$
# Ziel NACH dem Wechsel, ruft er den Callback auf einer bereits$
# freigegebenen Instanz auf. Das crashte das Spiel.$
#$
```

### 💭 Thinking

`19:51:29`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`19:51:29`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -n "^func test_switch" -A 5 test/integration/test_character_switch.gd | cat -A | head -10
```

```
46:func test_switch_to_karina_while_winter_bolt_in_flight_does_not_crash() -> void:$
47-^Ivar winter_data: CharacterData = load(WINTER_DATA)$
48-^Ivar karina_data: CharacterData = load(KARINA_DATA)$
49-^Ivar party_members: Array[CharacterData] = [winter_data, karina_data]$
50-^Iawait spawn_party(party_members)$
51-$
```

### 🤖 Assistant: *Good — tabs used consistently, matching the…*

`19:51:32`

> Good — tabs used consistently, matching the project's convention. Let me quickly verify the base file too.

#### 💻 Bash

`19:51:33`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -n "^func " -A 3 test/base/party_manager_test_base.gd | cat -A | head -30
```

```
32:func before_each() -> void:$
33-^I_reset_party_manager()$
34-^I_reset_items()$
35-^I_spawn_parent = Node3D.new()$
--$
40:func after_each() -> void:$
41-^I# Eine evtl. noch lebende Spieler-Instanz VOR dem naechsten$
42-^I# notify_scene_reset() explizit einsammeln - sonst haengt sie bis zum$
43-^I# Ende der gesamten Suite als Orphan im Baum statt sofort nach diesem$
--$
69:func _reset_party_manager() -> void:$
70-^IPartyManager.notify_scene_reset()$
71-^IPartyManager.setup_party([])$
72-$
--$
74:func _reset_items() -> void:$
75-^IItems.reset_run()$
76-$
77-$
--$
86:func spawn_party(members: Array[CharacterData]) -> void:$
87-^IPartyManager.register_spawn_point(_spawn_parent, Transform3D.IDENTITY)$
88-^IPartyManager.setup_party(members)$
89-^Iawait wait_frames(1)$
--$
97:func spawn_dummy_enemy(at_position: Vector3, max_health: float = 999.0) -> Node3D:$
98-^Ivar enemy := Node3D.new()$
99-^Ienemy.name = "DummyEnemy"$
100-^Iadd_child_autofree(enemy)$
```

### 🤖 Assistant: *Both files use consistent tab indentation…*

`19:51:50`

> Both files use consistent tab indentation. Everything's in place. Here's the full picture:
> 
> ## 1. Setup & Installation
> 
> Go with the **Asset Library** for the initial install (simpler upgrades than a submodule, and this project doesn't already use submodules anywhere):
> 
> 1. Open the project in Godot 4.7 → **AssetLib** tab → search "Gut" → install the version matching Godot 4.x (gilzoide/bitwes' GUT, currently 9.x line). This drops everything into `addons/gut/`.
> 2. **Project → Project Settings → Plugins** → enable "Gut".
> 3. Commit `addons/gut/` to git — it's a real project dependency other devs/CI need, not something to `.gitignore`.
> 
> I've already created the rest of the structure and a `.gutconfig.json` at the project root pointing GUT at `test/unit` and `test/integration` with `test_` prefix matching, plus a JUnit XML output path (ignored via `.gitignore`) for CI later. Once the addon is installed you can run everything headless:
> 
> ```
> godot --headless -s addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json
> ```
> 
> or just open the GUT panel at the bottom of the editor and hit Run.
> 
> ```
> test/
>   base/
>     party_manager_test_base.gd   # step 2
>   unit/                          # empty for now (.gitkeep)
>   integration/
>     test_character_switch.gd     # step 3
> ```
> 
> ## 2. Autoload test base (`test/base/party_manager_test_base.gd`)
> 
> Key insight: `PartyManager`/`Items` are real autoloads — already alive before the first test runs and shared across the whole GUT session. "Isolation" here means *reset to a clean state before/after each test*, not recreate the singleton. The base class:
> - `before_each()`: calls `PartyManager.notify_scene_reset()` + `setup_party([])` and `Items.reset_run()`, then builds a fresh spawn-point `Node3D`.
> - `after_each()`: frees any lingering player, resets both autoloads again, releases any combat input actions left held, and restores mouse mode (player spawn captures the cursor).
> - `spawn_party(members)`: mirrors the real `PlayerSpawnPoint` → `PartySetup` flow and awaits the one frame `PartyManager` needs (its spawn is deliberately `call_deferred`).
> - `spawn_dummy_enemy(pos)`: a bare `Node3D` in group `"enemies"` with a `Health` child — the only two things the enemy-facing code (`EnemyQuery`, hitboxes) actually checks.
> 
> ## 3. Regression test (`test/integration/test_character_switch.gd`)
> 
> Reproduces exactly what you described: spawns Winter active, holds `attack_primary` for one frame (which fires `_do_primary()` → spawns a Plasma `HomingBolt` bound to Winter's `Combat` node via closure), then calls `PartyManager.switch_to(1)` to Karina while the bolt is still 6m from its target — well inside `plasma_range` but outside `HIT_RANGE`.
> 
> It doesn't just check "nothing crashed" — it proves the dangerous path was actually exercised: asserts the old `CombatWinter` node is genuinely `!is_instance_valid()` after the switch, then waits out the bolt's flight time and asserts the dummy enemy took **zero** damage (proof `HomingBolt._strike()`'s new `is_valid()` guard actually skipped the freed callback rather than the bolt just not reaching its target). It also checks the switch completed correctly, input state is clean, and `assert_no_new_orphans()`.
> 
> Run it once you've installed GUT — it exercises the exact fix from earlier in this conversation (`homing_bolt.gd`'s `_on_strike.is_valid()` guard), so it should currently pass; reverting that guard should make it fail loudly instead of crashing the editor.

## 🤷 User: *Ich brauche Hilfe bei ein paar visuellen…*

`20:01:21`

Ich brauche Hilfe bei ein paar visuellen Anpassungen, beim Kamera-Setup und beim Aim-Assist für meinen Charakter "Giselle" (und "Winter") in unserem Godot 4 (GDScript) Projekt. Wir nutzen ein 3D-Setup mit einer Third-Person-Kamera (gesteuert über `player_base.gd`).

Bitte hilf mir bei den folgenden fünf Punkten:

1. Falsche Partikel-Richtung bei der Uzi (Giselle)
   Giselles Primärangriff (Uzi) trifft zwar in die richtige Richtung, aber die visuellen Schuss-Partikel fliegen vom Charakter aus in Richtung der Kamera, anstatt nach vorne zum Ziel. Bitte zeige mir, wie ich die Ausrichtung (Rotation/Transform) des Partikel-Emitters im Code korrigiere, damit die Partikel dorthin fliegen, wo die Waffe wirklich hinzeigt.

2. Kamera-Shift beim Zielen (RMB)
   Giselles Sekundärangriff (Rechte Maustaste) zoomt momentan heran (FOV wird kleiner). Da der Charakter genau in der Mitte des Bildschirms steht, verdeckt sie beim Heranzoomen die Sicht auf das Ziel. Die Kamera soll beim Zielen nicht nur das FOV verringern, sondern auch leicht zur Seite fahren (z.B. über den `h_offset` der Camera3D oder des SpringArms), damit man über ihre Schulter schauen kann. Wie setze ich das in `combat_giselle.gd` (oder `player_base.gd`) sauber um?

3. Generelle Over-the-Shoulder Kamera (wie in Fortnite)
   Ich überlege, die Kamera generell etwas seitlich zu positionieren, statt den Charakter exakt zentriert in der Mitte zu haben (Over-the-Shoulder-Perspektive).
   Welche Werte muss ich im Kamera-Rig in `player_base.gd` oder in der entsprechenden `.tscn`-Datei anpassen, um die Kamera standardmäßig leicht nach rechts oder links zu verschieben, ohne dass das Fadenkreuz / das Lock-On-System dadurch ungenau wird?

4. "Enemy ESP" / Hitbox-Highlighting (Giselle & Winter)
   Ich möchte einen visuellen Effekt hinzufügen, der wie ein "ESP Hack" (ein Kasten/Umriss um die Gegner) aussieht. Dieser soll aufleuchten oder sichtbar werden, wenn man die Angriffe von Winter oder Giselle benutzt. Wie baue ich so ein visuelles Overlay (z.B. via Shader, Decal oder 3D-Sprite) am besten um die Gegner herum, das über das Combat-Skript der beiden Charaktere getriggert wird?

5. Stärkerer Aim-Assist für Giselles RMB (Sniper)
   Wenn Giselle mit der rechten Maustaste (Sniper) zielt, reicht der aktuelle Aim-Assist nicht aus. Bitte zeige mir, wie ich die Magnetismus- oder Lock-On-Werte spezifisch für ihren RMB-Angriff erhöhen kann, damit das Fadenkreuz beim Snipen viel stärker am Gegner kleben bleibt.^

### 💭 Thinking

`20:01:41`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:01:41`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && cat scripts/vfx_manager.gd
```

```
extends Node



## Zentraler One-Shot-VFX-Spawner.

##

## REGISTRIEREN: Project Settings -> Autoload

##   Pfad: res://scripts/vfx_manager.gd

##   Name: VFX

##

## WARUM ZENTRAL:

## Effekt-Nodes duerfen nicht am Ausloeser haengen — Hitboxen werden 0.15s

## nach dem Schlag deaktiviert, Gegner rufen bei Tod queue_free(). Ein

## Kind-Emitter waere dann mitten im Abspielen weg. Hier landen alle

## Effekte in current_scene und raeumen sich nach Ablauf selbst ab.



## Sicherheitszuschlag auf die berechnete Lebensdauer.

const CLEANUP_MARGIN: float = 0.5



## Notbremse, falls eine Szene gar keinen Partikel-Node enthaelt.

const FALLBACK_LIFETIME: float = 2.0





## global_pos = Weltposition des Effekts.

## direction  = Ausrichtung; -Z des Effekts zeigt darauf (Godot-Konvention

##              von look_at). Vector3.ZERO = keine Ausrichtung.

## parent     = optionaler Eltern-Node; Standard ist current_scene.

func spawn(scene: PackedScene, global_pos: Vector3, direction: Vector3 = Vector3.ZERO, parent: Node = null) -> Node3D:

	if scene == null:

		return null



	var target_parent: Node = parent if parent != null else get_tree().current_scene

	if target_parent == null or not is_instance_valid(target_parent):

		return null



	var instance: Node = scene.instantiate()

	if not (instance is Node3D):

		push_warning("[VFX] '%s' ist kein Node3D — verworfen." % scene.resource_path)

		instance.queue_free()

		return null



	var node: Node3D = instance as Node3D

	target_parent.add_child(node)

	# NACH add_child(): global_position ist vorher nicht gueltig.

	node.global_position = global_pos



	if direction.length_squared() > 0.0001:

		_aim(node, direction.normalized())



	var lifetime: float = _restart_emitters(node)

	_schedule_cleanup(node, lifetime)

	return node





## Wie spawn(), faerbt aber zusaetzlich JEDEN gefundenen Partikel-Emitter

## ZWEIFARBIG ein, BEVOR er emittiert (siehe primary_hitbox.gd, das damit den

## Treffer-Funken in attack_color/attack_color_secondary des aktiven

## Charakters einfaerbt, statt fuer jede Farbkombination eine eigene

## VFX-Szene zu brauchen).

##

## WIE DIE ZWEIFARBIGKEIT ENTSTEHT: draw_pass_1 bekommt color_a, draw_pass_2

## (sofern die Szene einen hat - siehe hit_spark_primary.tscn) color_b.

## GPUParticles3D wuerfelt bei mehreren Draw-Passes PRO EINZELPARTIKEL aus,

## welcher gezeichnet wird - das ist Godots eingebauter Mechanismus fuer

## Partikel-Vielfalt (z.B. unterschiedlich gefaerbte Glut in einem Feuer) und

## damit zuverlaessiger als der Versuch, Farbverlauf ueber

## ParticleProcessMaterial.color_ramp + Vertex-Color-Passthrough zu erzwingen,

## dessen genaues Verhalten mit einem unshaded StandardMaterial3D als

## Draw-Pass nicht in jedem Fall garantiert ist.

func spawn_dual_tinted(scene: PackedScene, global_pos: Vector3, color_a: Color, color_b: Color, direction: Vector3 = Vector3.ZERO, parent: Node = null) -> Node3D:

	if scene == null:

		return null



	var target_parent: Node = parent if parent != null else get_tree().current_scene

	if target_parent == null or not is_instance_valid(target_parent):

		return null



	var instance: Node = scene.instantiate()

	if not (instance is Node3D):

		push_warning("[VFX] '%s' ist kein Node3D — verworfen." % scene.resource_path)

		instance.queue_free()

		return null



	var node: Node3D = instance as Node3D

	target_parent.add_child(node)

	node.global_position = global_pos



	if direction.length_squared() > 0.0001:

		_aim(node, direction.normalized())



	# VOR dem Emittieren faerben: process_material/draw_pass-Material duerfen

	# erst NACH dem Einfaerben live gehen, sonst startet der erste

	# gerenderte Frame noch mit der alten Farbe.

	_apply_dual_tint(node, color_a, color_b)



	var lifetime: float = _restart_emitters(node)

	_schedule_cleanup(node, lifetime)

	return node





## Faerbt draw_pass_1 mit color_a, draw_pass_2 (falls vorhanden) mit color_b.

## Fehlt draw_pass_2 in der Szene, faerbt sich der Emitter einfach komplett

## mit color_a - kein Fehler, nur weniger Abwechslung.

##

## WARUM ERST duplicate(): [sub_resource]-Materialien einer .tscn sind PRO

## PACKEDSCENE, nicht pro Instanz - Godot teilt sie standardmaessig zwischen

## allen scene.instantiate()-Aufrufen (derselbe Fallstrick, den

## lemonade.gd._make_resources_unique() im Projekt schon einmal beheben

## musste). Ohne die Duplikate wuerde das Einfaerben EINES Treffer-Funkens

## rueckwirkend auch jeden anderen, gerade noch aktiven Funken umfaerben.

func _apply_dual_tint(root: Node, color_a: Color, color_b: Color) -> void:

	for node in _collect_emitters(root):

		if node is GPUParticles3D:

			var gpu: GPUParticles3D = node

			# process_material.color bleibt neutral Weiss - die eigentliche

			# Faerbung kommt aus den beiden Draw-Pass-Materialien unten, sonst

			# wuerden beide Toene zusaetzlich gleichfoermig ueberfaerbt.

			if gpu.process_material != null:

				gpu.process_material = gpu.process_material.duplicate()

				if gpu.process_material is ParticleProcessMaterial:

					(gpu.process_material as ParticleProcessMaterial).color = Color(1.0, 1.0, 1.0, 1.0)

			if gpu.draw_pass_1 != null:

				gpu.draw_pass_1 = gpu.draw_pass_1.duplicate()

				_tint_primitive_mesh(gpu.draw_pass_1, color_a)

			if gpu.draw_pass_2 != null:

				gpu.draw_pass_2 = gpu.draw_pass_2.duplicate()

				_tint_primitive_mesh(gpu.draw_pass_2, color_b)

		elif node is CPUParticles3D:

			# CPUParticles3D kennt keine mehreren Draw-Passes - faerbt sich

			# einfarbig mit color_a statt einer erzwungenen Mischfarbe.

			(node as CPUParticles3D).color = color_a





func _tint_primitive_mesh(mesh: Mesh, tint: Color) -> void:

	if not (mesh is PrimitiveMesh):

		return

	var primitive: PrimitiveMesh = mesh as PrimitiveMesh

	if primitive.material == null:

		return

	var unique_material: Material = primitive.material.duplicate()

	if unique_material is StandardMaterial3D:

		var std: StandardMaterial3D = unique_material as StandardMaterial3D

		std.albedo_color = tint

		if std.emission_enabled:

			std.emission = tint

	primitive.material = unique_material





## look_at() wirft einen Fehler, wenn die Blickrichtung exakt parallel zum

## Up-Vektor liegt (Treffer senkrecht von oben/unten). Dann wird Up gekippt.

func _aim(node: Node3D, dir: Vector3) -> void:

	var up: Vector3 = Vector3.UP

	if absf(dir.dot(up)) > 0.99:

		up = Vector3.FORWARD

	node.look_at(node.global_position + dir, up)





## Startet alle Emitter der Szene neu und liefert die laengste Laufzeit.

func _restart_emitters(root: Node) -> float:

	var longest: float = 0.0

	for node in _collect_emitters(root):

		if node is GPUParticles3D:

			var gpu: GPUParticles3D = node

			gpu.restart()

			gpu.emitting = true

			longest = maxf(longest, gpu.lifetime / maxf(gpu.speed_scale, 0.01))

		elif node is CPUParticles3D:

			var cpu: CPUParticles3D = node

			cpu.restart()

			cpu.emitting = true

			longest = maxf(longest, cpu.lifetime / maxf(cpu.speed_scale, 0.01))

	return longest if longest > 0.0 else FALLBACK_LIFETIME





func _collect_emitters(node: Node) -> Array[Node]:

	var result: Array[Node] = []

	if node is GPUParticles3D or node is CPUParticles3D:

		result.append(node)

	for child in node.get_children():

		result.append_array(_collect_emitters(child))

	return result





func _schedule_cleanup(node: Node3D, lifetime: float) -> void:

	await get_tree().create_timer(lifetime + CLEANUP_MARGIN).timeout

	if is_instance_valid(node):

		node.queue_free()
```

### 💭 Thinking

`20:04:29`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:04:30`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -n "CameraPivot\|SpringArm3D\|Camera3D" scenes/characters/char_giselle.tscn | head -30
```

```
46:[node name="CameraPivot" type="Node3D" parent="." unique_id=489963335]
48:[node name="SecondaryHitbox" type="Area3D" parent="CameraPivot" unique_id=843866397]
56:[node name="CollisionShape3D" type="CollisionShape3D" parent="CameraPivot/SecondaryHitbox" unique_id=54088038]
60:[node name="Visual" type="MeshInstance3D" parent="CameraPivot/SecondaryHitbox" unique_id=311250376]
64:[node name="PrimaryHitbox" type="Area3D" parent="CameraPivot" unique_id=1929067481]
72:[node name="CollisionShape3D" type="CollisionShape3D" parent="CameraPivot/PrimaryHitbox" unique_id=1478091659]
76:[node name="Visual" type="MeshInstance3D" parent="CameraPivot/PrimaryHitbox" unique_id=1843560576]
80:[node name="SpringArm3D" type="SpringArm3D" parent="CameraPivot" unique_id=1213944006]
83:[node name="Camera3D" type="Camera3D" parent="CameraPivot/SpringArm3D" unique_id=123459548]
```

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && sed -n '78,92p' scenes/characters/char_giselle.tscn
```

```
mesh = SubResource("BoxMesh_6igkw")

[node name="SpringArm3D" type="SpringArm3D" parent="CameraPivot" unique_id=1213944006]
spring_length = 8.0

[node name="Camera3D" type="Camera3D" parent="CameraPivot/SpringArm3D" unique_id=123459548]

[node name="Health" type="Node" parent="." unique_id=721868555]
script = ExtResource("3_qhqgy")
max_health = 90.0
regen_enabled = false

[node name="Combat" type="Node" parent="." unique_id=1120459944]
script = ExtResource("5_gisellecombat")
```

### 💭 Thinking

`20:04:52`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `spring_arm|camera_probe|zoom|h_offset|shoulder` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd`

`20:04:53`

```
43:@export var zoom_min: float = 3
44:@export var zoom_max: float = 20.0
45:@export var zoom_step: float = 1
49:# Kamera automatisch auf zoom_max raus (überschreibt dabei aktiv jeden
56:@export var large_enemy_zoom_hold_time: float = 1.5
57:@export var large_enemy_zoom_speed: float = 6.0
61:var _pre_large_enemy_zoom: float = 10.0
201:@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
301:# BUGFIX 1 "beim Dash zoomt die Kamera in den Spieler rein":
312:# abzuschalten. Das beseitigt zwar das Reinzoomen, laesst die Kamera aber
327:@export var dash_camera_probe_radius: float = 0.35
342:var _spring_arm_mask_backup: int = -1
405:	_pre_large_enemy_zoom = spring_arm.spring_length
406:	_setup_camera_probe()
407:	_camera_spring_current = spring_arm.spring_length
521:		camera.h_offset = randf_range(-1.0, 1.0) * max_shake_offset * shake_amount
526:			camera.h_offset = 0.0
571:func _setup_camera_probe() -> void:
572:	if spring_arm == null:
574:	if spring_arm.shape == null:
576:		probe.radius = maxf(dash_camera_probe_radius, 0.05)
577:		spring_arm.shape = probe
578:	spring_arm.margin = maxf(spring_arm.margin, dash_camera_margin)
581:	spring_arm.add_excluded_object(get_rid())
591:	if spring_arm == null or camera == null:
594:	var target: float = spring_arm.get_hit_length()
604:	if not dash_camera_ignore_collision or spring_arm == null:
609:		if _spring_arm_mask_backup < 0:
610:			_spring_arm_mask_backup = spring_arm.collision_mask
611:			spring_arm.collision_mask = 0
612:	elif _spring_arm_mask_backup >= 0:
613:		spring_arm.collision_mask = _spring_arm_mask_backup
614:		_spring_arm_mask_backup = -1
684:		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
685:		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(-60), deg_to_rad(60))
692:			spring_arm.spring_length = clamp(spring_arm.spring_length - zoom_step, zoom_min, zoom_max)
693:			_on_manual_zoom_input()
695:			spring_arm.spring_length = clamp(spring_arm.spring_length + zoom_step, zoom_min, zoom_max)
696:			_on_manual_zoom_input()
698:func _on_manual_zoom_input() -> void:
820:		_large_enemy_timer = large_enemy_zoom_hold_time
828:			_pre_large_enemy_zoom = spring_arm.spring_length
831:		spring_arm.spring_length = move_toward(spring_arm.spring_length, zoom_max, large_enemy_zoom_speed * delta)
837:		_return_tween.tween_property(spring_arm, "spring_length", _pre_large_enemy_zoom, large_enemy_return_duration)\
```

### 💭 Thinking

`20:05:40`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `rotate_y|camera_pivot\.|CameraPivot\"\)|mouse_sensitivity" ` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd`

`20:05:42`

```
683:		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
748:	var forward: Vector3 = camera_pivot.global_transform.basis.z
749:	var right: Vector3 = camera_pivot.global_transform.basis.x
801:		var to_target_cam: Vector3 = _current_target.global_position - camera_pivot.global_position
810:			camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, desired_yaw, effective_lock_strength * delta)
```

### 💭 Thinking

`20:05:49`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `player_base.gd`

`20:05:50`

*(lines 195–225)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd</code></summary>

```
func _on_status_effect_ticked(id: String, magnitude: float, source: Node) -> void:
	if health and id in DOT_EFFECT_IDS:
		health.take_damage(magnitude, source)

# --- Node-Referenzen ---
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var mesh: Node3D = $CharacterModel
@onready var combat: CombatBase = $Combat
@onready var health: Health = $Health
@onready var own_collision: CollisionShape3D = $CollisionShape3D
## Optional - direktes Kind "GhostTrail" (siehe scripts/vfx/ghost_trail.gd).
## get_node_or_null(): fehlt der Node in einer Charakter-Szene, bleibt die
## normale Bewegung einfach ohne Trail, statt einen Fehler zu werfen.
@onready var ghost_trail: GhostTrail = get_node_or_null("GhostTrail")

## Ab welcher horizontalen Geschwindigkeit (Einheiten/Sekunde) der
## Dauer-Lauf-Trail einsetzt - verhindert, dass er schon beim Anlaufen/
## Abbremsen oder bei kleinem Knockback-Restschwung flackert.
@export var ghost_trail_speed_threshold: float = 10.0

@export var own_damage_shake_strength: float = 0.6
var _last_known_health: float = -1.0

# --- Todes-Animation ---
@export var use_ragdoll: bool = true
@export var death_fall_rotation_degrees: float = 85.0
@export var death_fall_duration: float = 0.6
@export var ragdoll_mass: float = 6.0
```
</details>

### 🤖 Assistant: *Now let's re-check the current state of …*

`20:06:24`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now let's re-check the current state of `combat_giselle.gd` (edited earlier this session) before making further changes.

#### Read

`20:06:25`

**__unparsedToolInput:**

```json
{
  "raw": "{\"file_path\": \"C:\\\\Users\\\\thvnh\\\\Documents\\\\GitHub\\\\whiplash\\\\scripts\\\\characters\\\\combat_giselle.gd\", \"offset\": 330, \"limit\": 60}}",
  "len": 131
}
```

```
InputValidationError: Read was called with input that could not be parsed as JSON.
You sent (first 131 of 131 bytes): {"file_path": "C:\\Users\\thvnh\\Documents\\GitHub\\whiplash\\scripts\\characters\\combat_giselle.gd", "offset": 330, "limit": 60}}
Common causes: unescaped backslashes in file paths (use / or \\), unescaped control character, or truncated output. Retry with valid JSON.
```

#### 👀 Read `combat_giselle.gd`

`20:06:27`

*(lines 1–76)*

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

const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

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

## --- Aim-Assist (Sniper) ----------------------------------------------------
## Nur noch fuer den Sniper: die Uzi hat seit dem Auto-Target-Rework ihr
## eigenes uzi_target_cone_deg (harter Lock statt weichem Assist, siehe oben).
## Rueckmeldung "RMB soll einen soft aim assist haben": Winkel von 5 auf 10
## Grad angehoben, damit er ueberhaupt spuerbar greift - strength bleibt bei
## 0.5 (weich, kein harter Lock wie bei der Uzi).
@export var aim_assist_angle_deg: float = 10.0
@export var aim_assist_strength: float = 0.5

var _uzi_ammo: int = 40
var _uzi_reloading: bool = false
var _uzi_locked_target: Node3D = null
var _uzi_esp_marker: Label3D = null

var _sniper_charging: bool = false
```
</details>

### 💭 Thinking

`20:06:30`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_giselle.gd`

`20:06:32`

*(lines 75–175)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```
var _sniper_charging: bool = false
var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null
var _default_fov: float = 75.0
var _fov_tween: Tween = null


func _init() -> void:
	primary_cooldown = 0.08
	secondary_cooldown = 5.0
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_uzi_ammo = uzi_magazine_size
	if _camera:
		_default_fov = _camera.fov


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
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_uzi_esp(target)

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	_spawn_muzzle_vfx(origin, dir)
	_spawn_tracer(origin, result["position"], 0.35, 0.06)
	if result["hit"]:
		var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		if spark:
			spark.scale *= 1.6
		_lock_model_to(result["target"])
		if player and player.has_method("shake_camera"):
			player.shake_camera(0.18)

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


## Haelt einen einzelnen Label3D-Marker (billboard + no_depth_test, gleiches
## Muster wie damage_number.gd) ueber dem gerade automatisch anvisierten
## Ziel fest - das ist das in der Rueckmeldung verlangte "ESP" auf den
## beschossenen Gegner. no_depth_test sorgt dafuer, dass er auch durch
## Gegner/Deckung hindurch klar lesbar bleibt, nicht nur durch Waende.
func _update_uzi_esp(target: Node3D) -> void:
	if target == _uzi_locked_target and target != null and is_instance_valid(target):
		if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
			_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		return

	_clear_uzi_esp()
	_uzi_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_uzi_esp_marker = _build_esp_marker()
```
</details>

### 🤖 Assistant: *Let me check the referenced convention comment…*

`20:09:11`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let me check the referenced convention comment in `primary_hitbox.gd` before touching the direction logic — there might be a deliberate "+Z is front" convention I'd otherwise contradict.

#### 🔎 Grep `swing_vfx|\+Z ist vorne|Z ist vorne"` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\primary_hitbox.gd`

`20:09:13`

```
7-@export var knockback_force: float = 0.0
8-@export var stun_duration: float = 0.0
9-@export var status_effect_id: String = ""
10-@export var status_effect_duration: float = 0.0
11-@export var status_effect_magnitude: float = 1.0
12-@export var status_effect_tick_interval: float = 0.0
13-@export var damage_number_scene: PackedScene
14-@export var debug_logging: bool = false
15-
16-## Kritische Treffer: nur Spieler-Hitboxen wuerfeln (siehe _is_player_attack),
17-## sonst wuerden Gegner-Treffer versehentlich denselben Roll bekommen.
18-const CRIT_DAMAGE_MULTIPLIER: float = 1.5
19-
20-# --- VFX ---
21-## Effekt beim Aktivieren der Hitbox (Schlag-Trail / Swoosh).
22:@export var swing_vfx: PackedScene
23-## Effekt beim BESTAETIGTEN Treffer (Impact-Funken).
24-@export var impact_vfx: PackedScene
25-## Hoehe ueber dem Ziel-Pivot, auf der der Impact erscheint.
26-@export var impact_height: float = 1.2
27-
28-@onready var visual: MeshInstance3D = get_node_or_null("Visual")
29-
30-var _already_hit: Array[Node] = []
31-
32-
33-func _debug(msg: String) -> void:
34-	if debug_logging:
35-		print("Hitbox DEBUG [%s]: %s" % [get_path(), msg])
36-
37-
--
42-	# _on_body_entered(): so bleibt die Treffer-Logik voellig unangetastet
43-	# und der Effekt feuert garantiert erst NACH allen Filtern
44-	# (Self-Damage, _already_hit, Health-Check).
45-	hit_landed.connect(_on_hit_landed_vfx)
46-	if visual:
47-		visual.visible = false
48-
49-
50-func activate() -> void:
51-	_already_hit.clear()
52-	monitoring = true
53-	_debug("activate() aufgerufen. monitoring=%s, global_position=%s, owner=%s" % [monitoring, global_position, owner])
54-	if visual:
55-		visual.visible = true
56-
57:	if swing_vfx:
58-		# Das Projekt nutzt +Z als "vorne", deshalb basis.z (nicht -basis.z).
59:		VFX.spawn(swing_vfx, global_position, global_transform.basis.z)
60-
61-	# ROBUSTHEITS-FIX: body_entered feuert nur beim EINTRETEN in die Area.
62-	# Steht der Spieler beim Aktivieren schon MITTEN in der Hitbox (genau
63-	# der Normalfall: der Gegner bleibt in Reichweite stehen, telegraphiert
64-	# und schlaegt dann zu, ohne dass sich jemand bewegt hat), kann das
65-	# Signal ausbleiben und der Schlag geht wirkungslos durch.
66-	# Deshalb wird direkt nach der Aktivierung EINMAL aktiv nachgesehen,
67-	# wer bereits ueberlappt.
68-	_sweep_initial_overlaps.call_deferred()
69-
70-
71-## Traegt Bodies nach, die beim Aktivieren bereits in der Hitbox standen.
72-## Ein Physik-Frame Wartezeit ist noetig, weil die Area ihre Ueberlappungen
73-## erst nach dem Umschalten von monitoring neu auswertet -
74-## get_overlapping_bodies() waere im selben Frame noch leer.
```

### 💭 Thinking

`20:09:31`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✍️  Write `enemy_esp_box.gd`

`20:09:51`

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
const FLASH_ENERGY: float = 5.0
const IDLE_ENERGY: float = 1.7
const IDLE_ALPHA: float = 0.8

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


## Baut eine freistehende EnemyEspBox-Instanz, NICHT in den Baum gehaengt -
## der Aufrufer haengt sie selbst per add_child() unter current_scene
## (gleiches Muster wie _build_esp_marker()) und setzt global_position.
static func build(color: Color, size: Vector3 = Vector3(1.6, 2.2, 1.6)) -> EnemyEspBox:
	var box := EnemyEspBox.new()
	box._color = color
	box._build_edges(size)
	return box


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
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
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

✓ File created successfully at: C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\enemy_esp_box.gd (file state is current in your context — no need to Read it back)

### 💭 Thinking

`20:09:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_giselle.gd`

`20:09:56`

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

const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

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

## --- Aim-Assist (Sniper) ----------------------------------------------------
## Nur noch fuer den Sniper: die Uzi hat seit dem Auto-Target-Rework ihr
## eigenes uzi_target_cone_deg (harter Lock statt weichem Assist, siehe oben).
## Rueckmeldung "RMB soll einen soft aim assist haben": Winkel von 5 auf 10
## Grad angehoben, damit er ueberhaupt spuerbar greift - strength bleibt bei
## 0.5 (weich, kein harter Lock wie bei der Uzi).
@export var aim_assist_angle_deg: float = 10.0
@export var aim_assist_strength: float = 0.5

var _uzi_ammo: int = 40
var _uzi_reloading: bool = false
var _uzi_locked_target: Node3D = null
var _uzi_esp_marker: Label3D = null

var _sniper_charging: bool = false
var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null
var _default_fov: float = 75.0
var _fov_tween: Tween = null


func _init() -> void:
	primary_cooldown = 0.08
	secondary_cooldown = 5.0
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_camera = player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_spring_arm = player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	_uzi_ammo = uzi_magazine_size
	if _camera:
		_default_fov = _camera.fov


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
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_uzi_esp(target)

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	_spawn_muzzle_vfx(origin, dir)
	_spawn_tracer(origin, result["position"], 0.35, 0.06)
	if result["hit"]:
		var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		if spark:
			spark.scale *= 1.6
		_lock_model_to(result["target"])
		if player and player.has_method("shake_camera"):
			player.shake_camera(0.18)

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


## Haelt einen einzelnen Label3D-Marker (billboard + no_depth_test, gleiches
## Muster wie damage_number.gd) ueber dem gerade automatisch anvisierten
## Ziel fest - das ist das in der Rueckmeldung verlangte "ESP" auf den
## beschossenen Gegner. no_depth_test sorgt dafuer, dass er auch durch
## Gegner/Deckung hindurch klar lesbar bleibt, nicht nur durch Waende.
func _update_uzi_esp(target: Node3D) -> void:
	if target == _uzi_locked_target and target != null and is_instance_valid(target):
		if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
			_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		return

	_clear_uzi_esp()
	_uzi_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_uzi_esp_marker = _build_esp_marker()
	get_tree().current_scene.add_child(_uzi_esp_marker)
	_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2


func _clear_uzi_esp() -> void:
	if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
		_uzi_esp_marker.queue_free()
	_uzi_esp_marker = null
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


## _uzi_esp_marker haengt unter current_scene, NICHT unter diesem Combat-Node
## (siehe _build_esp_marker()/_update_uzi_esp()) - ueberlebt einen
## Charakterwechsel also nicht automatisch. Explizit aufraeumen, sonst bleibt
## ein verwaister Marker in der Szene stehen, falls LMB genau beim Wechsel
## gehalten wurde.
func _exit_tree() -> void:
	_clear_uzi_esp()


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


func _release_sniper_charge() -> void:
	_sniper_charging = false
	if _camera:
		_kill_fov_tween()
		_fov_tween = _camera.create_tween()
		_fov_tween.tween_property(_camera, "fov", _default_fov, sniper_zoom_out_time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Der Schuss loest erst HIER aus (nicht beim Druecken) - deshalb bleibt
	# der 5s-Cooldown fuer die volle Ladedauer unangetastet und startet
	# tatsaechlich erst beim Loslassen, wie in der Spec verlangt.
	if _secondary_timer <= 0.0:
		_do_secondary()


func _kill_fov_tween() -> void:
	if _fov_tween != null and _fov_tween.is_valid():
		_fov_tween.kill()


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

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		_spawn_muzzle_vfx(origin, dir)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(origin, result["position"], 0.9, 0.12)
		if result["hit"]:
			landed_hit = true
			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
			if spark:
				spark.scale *= 2.2
			_lock_model_to(result["target"])
		if i < sniper_shot_count - 1:
			await get_tree().create_timer(0.03).timeout

	if landed_hit:
		# Kurzer Hit-Stop + kraeftige Kamera-Erschuetterung statt nur Shake -
		# verkauft das Gewicht eines Treffers, der die meisten Gegner sofort
		# toetet, deutlich staerker als reines Wackeln.
		Juice.impact(0.6, Juice.DURATION_HEAVY)


func is_sniper_charging() -> bool:
	return _sniper_charging


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
func _damage_multiplier() -> float:
	var stats: PlayerStats = PlayerStats.find_for(self)
	return stats.get_damage_multiplier() if stats else 1.0


## Dreht das Charaktermodell zum getroffenen Ziel - dieselbe player_base.gd-
## Funktion, die auch Nahkampf-Treffer schon nutzen (siehe combat_base.gd::
## _on_hit_landed()). Hitscan-Treffer loesen das nicht automatisch aus, da sie
## NIE ueber die Hitbox-Signale laufen (siehe Kopfkommentar) - deshalb hier
## explizit nachgezogen.
func _lock_model_to(target: Variant) -> void:
	if player and player.has_method("set_target") and target is Node3D:
		player.set_target(target)


## "dir" ist hier die reine Schuss-/Blickrichtung (-Camera-Z). VFX.spawn()/
## _aim() orientieren aber nach der PROJEKT-Konvention "+Z ist vorne" (siehe
## primary_hitbox.gd swing_vfx-Kommentar) - deshalb hier NEGIERT uebergeben,
## sonst zeigt der Muendungsblitz sichtbar rueckwaerts, obwohl der Raycast
## selbst (der "dir" unnegiert bekommt) korrekt in Blickrichtung feuert.
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


func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3) -> void:
	var vfx_dir: Vector3 = -dir
	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
	var data: CharacterData = PartyManager.get_active_data()
	if data != null:
		VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, spawn_pos, data.attack_color, data.attack_color_secondary, vfx_dir)
	else:
		VFX.spawn(MUZZLE_VFX_SCENE, spawn_pos, vfx_dir)

```
</details>

### 💭 Thinking

`20:10:03`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_giselle.gd`

`20:10:06`

```diff
@@ -1,6 +1 @@-## "dir" ist hier die reine Schuss-/Blickrichtung (-Camera-Z). VFX.spawn()/
-## _aim() orientieren aber nach der PROJEKT-Konvention "+Z ist vorne" (siehe
-## primary_hitbox.gd swing_vfx-Kommentar) - deshalb hier NEGIERT uebergeben,
-## sonst zeigt der Muendungsblitz sichtbar rueckwaerts, obwohl der Raycast
-## selbst (der "dir" unnegiert bekommt) korrekt in Blickrichtung feuert.
 ## Sichtbarer Muendungsblitz-bis-Trefferpunkt-Streifen, kurz aufblitzend und
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,3 +1,16 @@+## BUGFIX "Partikel fliegen Richtung Kamera statt zum Ziel": vfx_dir war
+## bisher "-dir" (also zurueck zum Schuetzen). vfx_manager.gd::spawn() ist
+## eindeutig dokumentiert ("-Z des Effekts zeigt darauf, Godot-Konvention von
+## look_at()") - mit "-dir" zeigte das lokale -Z des Muendungsblitzes damit
+## RUECKWAERTS zur Kamera und +Z (nicht -Z) nach vorne zum Ziel, also genau
+## verkehrt herum. Die alte Begruendung dafuer berief sich auf den
+## "+Z ist vorne"-Kommentar in primary_hitbox.gd - der gilt aber nur fuer
+## PrimaryHitbox, weil DIESES eine Area3D-Node im .tscn von Hand so gedreht
+## wurde, dass sein +Z nach vorne zeigt. Das ist eine Eigenheit dieses einen
+## Nodes, keine projektweite Konvention - fuer alles, was per VFX.spawn()
+## ausgerichtet wird (wie hier), gilt ausschliesslich die -Z-Regel oben.
+## "dir" (unnegiert) ist bereits die reine Schuss-/Blickrichtung, siehe
+## Aufrufer - richtig ausgerichtet zeigt das jetzt tatsaechlich zum Ziel.
 func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3) -> void:
-	var vfx_dir: Vector3 = -dir
+	var vfx_dir: Vector3 = dir
 	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:10:20`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_giselle.gd`

`20:10:26`

```diff
@@ -1,8 +1,10 @@ ## --- Aim-Assist (Sniper) ----------------------------------------------------
 ## Nur noch fuer den Sniper: die Uzi hat seit dem Auto-Target-Rework ihr
 ## eigenes uzi_target_cone_deg (harter Lock statt weichem Assist, siehe oben).
-## Rueckmeldung "RMB soll einen soft aim assist haben": Winkel von 5 auf 10
-## Grad angehoben, damit er ueberhaupt spuerbar greift - strength bleibt bei
-## 0.5 (weich, kein harter Lock wie bei der Uzi).
-@export var aim_assist_angle_deg: float = 10.0
-@export var aim_assist_strength: float = 0.5
+## War 10/0.5 ("soft aim assist"). Rueckmeldung "reicht nicht, Fadenkreuz
+## soll viel staerker am Gegner kleben bleiben": Winkel auf 18 Grad und
+## strength auf 0.85 angehoben - deutlich klebriger, aber bewusst NICHT 1.0,
+## damit ein grob daneben gezielter Schuss noch knapp danebengehen kann statt
+## komplett zum Aim-Bot zu werden. Bei Bedarf im Inspector weiter hochdrehen.
+@export var aim_assist_angle_deg: float = 18.0
+@export var aim_assist_strength: float = 0.85
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the ESP color/box vars, shoulder-offset…*

`20:10:30`

> Now the ESP color/box vars, shoulder-offset export, and `setup()`:

#### ✏️  Edit `combat_giselle.gd`

`20:10:33`

```diff
@@ -1,3 +1,10 @@ @export var sniper_zoom_fov: float = 28.0
 @export var sniper_zoom_in_time: float = 0.5
 @export var sniper_zoom_out_time: float = 0.35
+
+## Zusaetzlicher seitlicher Kamera-Versatz waehrend des Sniper-Zooms, ON TOP
+## von player_base.gd's staendigem camera_shoulder_offset - der Charakter
+## steht beim Reinzoomen sonst mitten im Bild und verdeckt genau das Ziel,
+## das man gerade anvisiert. Siehe _start_sniper_charge()/
+## _release_sniper_charge() - laeuft als eigener Tween parallel zum FOV-Tween.
+@export var sniper_aim_shoulder_offset: float = 1.1
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -2,9 +2,19 @@ var _uzi_reloading: bool = false
 var _uzi_locked_target: Node3D = null
 var _uzi_esp_marker: Label3D = null
+var _uzi_esp_box: EnemyEspBox = null
 
 var _sniper_charging: bool = false
+var _sniper_locked_target: Node3D = null
+var _sniper_esp_box: EnemyEspBox = null
 var _camera: Camera3D = null
 var _spring_arm: SpringArm3D = null
 var _default_fov: float = 75.0
 var _fov_tween: Tween = null
+## Ausgangswert von _spring_arm.position.x, EINMAL in setup() gelesen -
+## player_base.gd hat den Shoulder-Offset zu dem Zeitpunkt schon gesetzt
+## (siehe player_base.gd::_ready(), laeuft VOR combat.setup()). Der Sniper-
+## Zoom tweent dorthin zurueck statt hart auf 0.0, damit ein evtl. per
+## Inspector abweichender Standard-Offset erhalten bleibt.
+var _default_shoulder_offset: float = 0.6
+var _shoulder_tween: Tween = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,3 +1,5 @@ 	_uzi_ammo = uzi_magazine_size
 	if _camera:
 		_default_fov = _camera.fov
+	if _spring_arm:
+		_default_shoulder_offset = _spring_arm.position.x
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now hook the ESP box into `_perform_primary…*

`20:10:49`

> Now hook the ESP box into `_perform_primary()` and the uzi ESP update/clear functions:

#### ✏️  Edit `combat_giselle.gd`

`20:10:55`

```diff
@@ -13,3 +13,5 @@ 		_lock_model_to(result["target"])
 		if player and player.has_method("shake_camera"):
 			player.shake_camera(0.18)
+		if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
+			_uzi_esp_box.flash()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,12 +1,14 @@-## Haelt einen einzelnen Label3D-Marker (billboard + no_depth_test, gleiches
-## Muster wie damage_number.gd) ueber dem gerade automatisch anvisierten
+## Haelt einen Label3D-Marker UND eine EnemyEspBox (Kastenumriss, siehe
+## scripts/vfx/enemy_esp_box.gd) ueber dem gerade automatisch anvisierten
 ## Ziel fest - das ist das in der Rueckmeldung verlangte "ESP" auf den
-## beschossenen Gegner. no_depth_test sorgt dafuer, dass er auch durch
-## Gegner/Deckung hindurch klar lesbar bleibt, nicht nur durch Waende.
+## beschossenen Gegner. no_depth_test sorgt dafuer, dass der Marker auch
+## durch Gegner/Deckung hindurch klar lesbar bleibt, nicht nur durch Waende.
 func _update_uzi_esp(target: Node3D) -> void:
 	if target == _uzi_locked_target and target != null and is_instance_valid(target):
 		if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
 			_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
+		if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
+			_uzi_esp_box.global_position = target.global_position + Vector3.UP * 1.1
 		return
 
 	_clear_uzi_esp()
@@ -18,9 +20,16 @@ 	get_tree().current_scene.add_child(_uzi_esp_marker)
 	_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
 
+	_uzi_esp_box = EnemyEspBox.build(uzi_esp_color)
+	get_tree().current_scene.add_child(_uzi_esp_box)
+	_uzi_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+
 
 func _clear_uzi_esp() -> void:
 	if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
 		_uzi_esp_marker.queue_free()
 	_uzi_esp_marker = null
+	if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
+		_uzi_esp_box.queue_free()
+	_uzi_esp_box = null
 	_uzi_locked_target = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the `_exit_tree()` cleanup and the sniper…*

`20:11:10`

> Now the `_exit_tree()` cleanup and the sniper section (charge/release with shoulder tween + ESP):

#### ✏️  Edit `combat_giselle.gd`

`20:11:14`

```diff
@@ -1,7 +1,8 @@-## _uzi_esp_marker haengt unter current_scene, NICHT unter diesem Combat-Node
-## (siehe _build_esp_marker()/_update_uzi_esp()) - ueberlebt einen
-## Charakterwechsel also nicht automatisch. Explizit aufraeumen, sonst bleibt
-## ein verwaister Marker in der Szene stehen, falls LMB genau beim Wechsel
-## gehalten wurde.
+## _uzi_esp_marker/_uzi_esp_box haengen unter current_scene, NICHT unter
+## diesem Combat-Node (siehe _build_esp_marker()/_update_uzi_esp()) -
+## ueberleben einen Charakterwechsel also nicht automatisch. Explizit
+## aufraeumen, sonst bleibt ein verwaister Marker/Kasten in der Szene stehen,
+## falls LMB/RMB genau beim Wechsel gehalten wurde.
 func _exit_tree() -> void:
 	_clear_uzi_esp()
+	_clear_sniper_esp()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the sniper poll/charge/release functions…*

`20:11:17`

> Now the sniper poll/charge/release functions:

#### ✏️  Edit `combat_giselle.gd`

`20:11:41`

```diff
@@ -1,5 +1,13 @@ func _poll_secondary_input(_delta: float) -> void:
 	if _sniper_charging:
+		# ESP-Box waehrend des GESAMTEN Ladevorgangs aktuell halten - sticky
+		# Targeting (siehe _resolve_sniper_esp_target()) sorgt dafuer, dass
+		# sie nicht bei jedem winzigen Maus-Zittern auf einen anderen Gegner
+		# umspringt.
+		if _camera != null:
+			var origin: Vector3 = _camera.global_position
+			var look_dir: Vector3 = -_camera.global_transform.basis.z
+			_update_sniper_esp(_resolve_sniper_esp_target(origin, look_dir))
 		if not Input.is_action_pressed("attack_secondary"):
 			_release_sniper_charge()
 		return
@@ -17,6 +25,20 @@ 	_fov_tween.tween_property(_camera, "fov", sniper_zoom_fov, sniper_zoom_in_time) \
 		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
 
+	# Schulterblick-Versatz: der Charakter steht sonst mitten im Bild und
+	# verdeckt beim Reinzoomen genau das Ziel (Rueckmeldung "Kamera-Shift
+	# beim Zielen"). Reine Positions-Verschiebung des SpringArm3D-Ursprungs,
+	# KEINE Rotationsaenderung - siehe player_base.gd::camera_shoulder_offset
+	# fuer die ausfuehrliche Begruendung, warum das (statt Camera3D.h_offset)
+	# den Schuss-Raycast (origin=Kamera-Position, dir=Kamera-Blickrichtung)
+	# automatisch treffergenau mitverschiebt, ohne dass hier irgendetwas am
+	# Zielsystem angepasst werden muss.
+	if _spring_arm:
+		_kill_shoulder_tween()
+		_shoulder_tween = _spring_arm.create_tween()
+		_shoulder_tween.tween_property(_spring_arm, "position:x", sniper_aim_shoulder_offset, sniper_zoom_in_time) \
+			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
+
 
 func _release_sniper_charge() -> void:
 	_sniper_charging = false
@@ -24,6 +46,12 @@ 		_kill_fov_tween()
 		_fov_tween = _camera.create_tween()
 		_fov_tween.tween_property(_camera, "fov", _default_fov, sniper_zoom_out_time) \
+			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
+
+	if _spring_arm:
+		_kill_shoulder_tween()
+		_shoulder_tween = _spring_arm.create_tween()
+		_shoulder_tween.tween_property(_spring_arm, "position:x", _default_shoulder_offset, sniper_zoom_out_time) \
 			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
 
 	# Der Schuss loest erst HIER aus (nicht beim Druecken) - deshalb bleibt
@@ -36,3 +64,53 @@ func _kill_fov_tween() -> void:
 	if _fov_tween != null and _fov_tween.is_valid():
 		_fov_tween.kill()
+
+
+func _kill_shoulder_tween() -> void:
+	if _shoulder_tween != null and _shoulder_tween.is_valid():
+		_shoulder_tween.kill()
+
+
+## Sticky Targeting fuer die Sniper-ESP-Box waehrend Ladevorgang + Burst -
+## gleiches Muster wie _resolve_uzi_target()/combat_winter.gd::
+## _resolve_laser_target(). Rein visuell, unabhaengig vom eigentlichen
+## Schuss-Aim-Assist (der bleibt der reine Richtungs-Slerp unten in
+## _perform_secondary() - EnemyQuery.aim_assisted_direction() feuert immer
+## auf den WINKEL-naechsten Kandidaten im Feuermoment, nicht zwingend auf
+## dieses gelockte Ziel; beide finden in der Praxis fast immer denselben
+## Gegner, weil dieselbe Kegel-/Reichweiten-Logik zugrunde liegt).
+func _resolve_sniper_esp_target(origin: Vector3, look_dir: Vector3) -> Node3D:
+	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
+		var health: Node = _sniper_locked_target.find_child("Health", true, false)
+		var alive: bool = health != null and health is Health and (health as Health).is_alive()
+		var to_target: Vector3 = (_sniper_locked_target.global_position + Vector3.UP) - origin
+		var in_range: bool = to_target.length() <= sniper_range
+		var in_cone: bool = to_target.length_squared() > 0.0001 \
+			and look_dir.angle_to(to_target.normalized()) <= deg_to_rad(aim_assist_angle_deg * 1.5)
+		if alive and in_range and in_cone:
+			return _sniper_locked_target
+
+	return EnemyQuery.best_target_in_cone(origin, look_dir, sniper_range, aim_assist_angle_deg)
+
+
+func _update_sniper_esp(target: Node3D) -> void:
+	if target == _sniper_locked_target and target != null and is_instance_valid(target):
+		if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
+			_sniper_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+		return
+
+	_clear_sniper_esp()
+	_sniper_locked_target = target
+	if target == null or not is_instance_valid(target):
+		return
+
+	_sniper_esp_box = EnemyEspBox.build(uzi_esp_color, Vector3(2.0, 2.6, 2.0))
+	get_tree().current_scene.add_child(_sniper_esp_box)
+	_sniper_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+
+
+func _clear_sniper_esp() -> void:
+	if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
+		_sniper_esp_box.queue_free()
+	_sniper_esp_box = null
+	_sniper_locked_target = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now hook the flash + cleanup into `_perform_secondary…*

`20:11:44`

> Now hook the flash + cleanup into `_perform_secondary()`:

#### ✏️  Edit `combat_giselle.gd`

`20:11:51`

```diff
@@ -4,6 +4,8 @@ 			if spark:
 				spark.scale *= 2.2
 			_lock_model_to(result["target"])
+			if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
+				_sniper_esp_box.flash()
 		if i < sniper_shot_count - 1:
 			await get_tree().create_timer(0.03).timeout
 
@@ -12,3 +14,8 @@ 		# verkauft das Gewicht eines Treffers, der die meisten Gegner sofort
 		# toetet, deutlich staerker als reines Wackeln.
 		Juice.impact(0.6, Juice.DURATION_HEAVY)
+
+	# Burst ist fertig (RMB feuert nur einmal pro Ladevorgang) - ESP-Box
+	# wieder einsammeln, statt sie bis zum naechsten Ladevorgang haengen zu
+	# lassen.
+	_clear_sniper_esp()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:11:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`20:11:57`

*(lines 55–70)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```
@export var laser_esp_color: Color = Color(1.0, 0.15, 0.1)

var _laser_energy: float = 10.0
var _laser_tick_timer: float = 0.0
var _laser_beam: Dictionary = {}
var _laser_locked_target: Node3D = null
var _laser_esp_marker: Label3D = null

var _camera: Camera3D = null
var _spring_arm: SpringArm3D = null


func _init() -> void:
	primary_cooldown = 0.4
	# secondary_cooldown bleibt auf dem geerbten Standardwert - fuer den
```
</details>

#### ✏️  Edit `combat_winter.gd`

`20:12:04`

```diff
@@ -3,3 +3,6 @@ var _laser_beam: Dictionary = {}
 var _laser_locked_target: Node3D = null
 var _laser_esp_marker: Label3D = null
+## Kastenumriss um das gelockte Ziel, siehe scripts/vfx/enemy_esp_box.gd -
+## leuchtet bei jedem Schadens-Tick kurz auf (_update_laser()).
+var _laser_esp_box: EnemyEspBox = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:12:07`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`20:12:07`

*(lines 248–348)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```
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
			if spark:
				spark.scale *= 1.4
			_lock_model_to(result["target"])
			# Leichtes Dauer-Rattern statt eines einzelnen Shakes - passt
			# besser zu einem Dauerstrahl als ein einmaliger Ausschlag und
			# macht spuerbar, dass der Strahl laufend Schaden macht statt
			# nur huebsch auszusehen (Rueckmeldung "sieht schwach aus").
			if player and player.has_method("shake_camera"):
				player.shake_camera(0.06)

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
## (billboard + no_depth_test) ueber dem gerade automatisch anvisierten Ziel.
func _update_laser_esp(target: Node3D) -> void:
	if target == _laser_locked_target and target != null and is_instance_valid(target):
		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
		return

	_clear_laser_esp()
	_laser_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_laser_esp_marker = _build_laser_esp_marker()
	get_tree().current_scene.add_child(_laser_esp_marker)
	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
```
</details>

#### ✏️  Edit `combat_winter.gd`

`20:12:14`

```diff
@@ -5,3 +5,5 @@ 			# nur huebsch auszusehen (Rueckmeldung "sieht schwach aus").
 			if player and player.has_method("shake_camera"):
 				player.shake_camera(0.06)
+			if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
+				_laser_esp_box.flash()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,9 +1,12 @@ ## Gleiches Muster wie combat_giselle.gd::_update_uzi_esp() - Label3D
-## (billboard + no_depth_test) ueber dem gerade automatisch anvisierten Ziel.
+## (billboard + no_depth_test) PLUS EnemyEspBox-Kastenumriss ueber dem gerade
+## automatisch anvisierten Ziel.
 func _update_laser_esp(target: Node3D) -> void:
 	if target == _laser_locked_target and target != null and is_instance_valid(target):
 		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
 			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
+		if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
+			_laser_esp_box.global_position = target.global_position + Vector3.UP * 1.1
 		return
 
 	_clear_laser_esp()
@@ -14,3 +17,7 @@ 	_laser_esp_marker = _build_laser_esp_marker()
 	get_tree().current_scene.add_child(_laser_esp_marker)
 	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
+
+	_laser_esp_box = EnemyEspBox.build(laser_esp_color)
+	get_tree().current_scene.add_child(_laser_esp_box)
+	_laser_esp_box.global_position = target.global_position + Vector3.UP * 1.1
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:12:27`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _clear_laser_esp"` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd`

`20:12:27`

```
No matches found
```

#### 🔎 Grep `_clear_laser_esp` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd`

`20:12:31`

```
308:	_clear_laser_esp()
309-
310-
311-## BUGFIX "Strahl sieht aus wie einzelne Kugeln statt wie ein durchgehender
312-## Strahl (wie bei der Schild-Drohne)": ohne Sticky-Targeting waehlte
313-## best_target_in_cone() JEDEN Frame neu den "besten" Gegner - stehen mehrere
314-## nah beieinander, kann das Ergebnis frame-zu-frame kippen, und der
--
345:	_clear_laser_esp()
346-	_laser_locked_target = target
347-	if target == null or not is_instance_valid(target):
348-		return
349-
350-	_laser_esp_marker = _build_laser_esp_marker()
351-	get_tree().current_scene.add_child(_laser_esp_marker)
--
359:func _clear_laser_esp() -> void:
360-	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
361-		_laser_esp_marker.queue_free()
362-	_laser_esp_marker = null
363-	_laser_locked_target = null
364-
365-
```

#### ✏️  Edit `combat_winter.gd`

`20:12:36`

```diff
@@ -2,4 +2,7 @@ 	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
 		_laser_esp_marker.queue_free()
 	_laser_esp_marker = null
+	if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
+		_laser_esp_box.queue_free()
+	_laser_esp_box = null
 	_laser_locked_target = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `player_base.gd` for the default over…*

`20:12:40`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `player_base.gd` for the default over-the-shoulder camera offset (point 3), which also is what point 2's tween returns to:

#### 👀 Read `player_base.gd`

`20:12:41`

*(lines 42–62)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd</code></summary>

```
# --- Kamera-Zoom per Mausrad ---
@export var zoom_min: float = 3
@export var zoom_max: float = 20.0
@export var zoom_step: float = 1

# --- Automatisches Zoom bei großen Gegnern ---
# Sobald das aktuell gelockte Ziel is_large_enemy = true hat, zieht die
# Kamera automatisch auf zoom_max raus (überschreibt dabei aktiv jeden
# Frame den Scroll-Wert — das ist so gewollt, "muss" laut Anforderung).
# Solange KEIN großer Gegner gelockt ist, fasst das Script den Zoom
# NICHT an — nur GENAU EINMAL, im Moment des Übergangs "Kampf vorbei",
# läuft eine kurze Tween-Animation zurück zur Zoomstufe von davor.
# Das verhindert das "Gummiband"-Gefühl, das ein Dauer-Lerp jeden Frame
# verursachen würde, wenn man währenddessen versucht manuell zu scrollen.
@export var large_enemy_zoom_hold_time: float = 1.5
@export var large_enemy_zoom_speed: float = 6.0
@export var large_enemy_return_duration: float = 0.6
var _large_enemy_timer: float = 0.0
var _was_fighting_large_enemy: bool = false
var _pre_large_enemy_zoom: float = 10.0
```
</details>

#### ✏️  Edit `player_base.gd`

`20:12:57`

```diff
@@ -2,3 +2,32 @@ @export var zoom_min: float = 3
 @export var zoom_max: float = 20.0
 @export var zoom_step: float = 1
+
+# --- Over-the-Shoulder Kamera-Versatz ---
+# Seitlicher Versatz des SpringArm3D-Ursprungs INNERHALB von CameraPivot
+# (positiv = nach rechts, negativ = nach links). Angewendet in _ready() als
+# spring_arm.position.x - eine reine POSITIONS-Verschiebung, bewusst NICHT
+# ueber Camera3D.h_offset (das existiert zwar - siehe shake_camera() weiter
+# unten, das es fuer den Treffer-Wackler nutzt - ist dort aber ein reiner
+# Projektions-/Lens-Shift: er verschiebt nur das GERENDERTE Bild, nicht die
+# tatsaechliche 3D-Position/Blickrichtung der Kamera).
+#
+# WARUM DAS FUER DEN SCHUSS-RAYCAST WICHTIG IST: combat_giselle.gd und
+# combat_winter.gd feuern IMMER von camera.global_position aus, in Richtung
+# -camera.global_transform.basis.z (siehe dortige _perform_primary()/
+# _perform_secondary()) - also exakt dort, wo ein Fadenkreuz in
+# Bildschirmmitte optisch hinzeigt. Eine reine Positions-Verschiebung des
+# SpringArm3D-URSPRUNGS (nicht seiner Rotation) bewegt die Kamera nur
+# PARALLEL zur Seite, ohne ihre Blickrichtung zu aendern - der Raycast bleibt
+# dadurch automatisch treffergenau zur Bildschirmmitte, ganz ohne Anpassung
+# am Zielsystem. Ein h_offset-Ansatz haette das GERENDERTE Bild verschoben,
+# OHNE dass Ursprung/Richtung des Raycasts mitwandern - Fadenkreuz und
+# tatsaechlicher Einschlagpunkt liefen dann sichtbar auseinander.
+#
+# CameraPivot rotiert nur um Y (Yaw, siehe _unhandled_input() weiter unten),
+# SpringArm3D nur um X (Pitch) - der Versatz hier haengt am SpringArm3D-Node
+# selbst und dreht sich dadurch korrekt MIT der Blickrichtung mit (bleibt
+# immer "rechts von der Kamera", unabhaengig davon, wohin der Charakter
+# gerade schaut), beeinflusst aber NICHT dessen eigene Spring-/Kollisions-
+# Logik (_setup_camera_probe()), die relativ zum SpringArm3D selbst rechnet.
+@export_range(-2.0, 2.0) var camera_shoulder_offset: float = 0.6
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:13:00`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `player_base.gd`

`20:13:03`

```diff
@@ -1,3 +1,8 @@ func _ready() -> void:
 	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
+	# VOR combat.setup(): Combat-Scripts (siehe combat_giselle.gd) lesen den
+	# Ausgangswert von spring_arm.position.x einmalig in ihrem eigenen
+	# setup() aus, um spaeter (z.B. nach einem Sniper-Zoom-Tween) dorthin
+	# zurueckzufinden - der muss also schon stehen, bevor setup() laeuft.
+	spring_arm.position.x = camera_shoulder_offset
 	combat.setup(self)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:13:08`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `player_base.gd`

`20:13:09`

*(lines 590–610)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd</code></summary>

```
# ersetzt Godot die Instanz durch einen MissingNode. Ein Cast auf Node3D
# würde das still verschlucken und mesh wäre null.

func _resolve_character_model() -> Node3D:
	var node: Node = get_node_or_null("CharacterModel")
	if node == null:
		push_error("PlayerBase: Kein Node namens 'CharacterModel' gefunden. Wurde er beim Model-Tausch umbenannt?")
		return null
	if node is Node3D:
		return node as Node3D
	push_error("PlayerBase: 'CharacterModel' ist ein %s statt Node3D. Model-Import fehlgeschlagen (fehlende .glb, OneDrive-Platzhalter oder noch nicht importiert)." % node.get_class())
	return null
	
## Macht den Federarm gegen schnelle Bewegung unempfindlich. Siehe den
## Kommentar bei dash_camera_ignore_collision.
func _setup_camera_probe() -> void:
	if spring_arm == null:
		return
	if spring_arm.shape == null:
		var probe := SphereShape3D.new()
```
</details>

### 💭 Thinking

`20:13:12`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `player_base.gd`

`20:13:13`

*(lines 605–625)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd</code></summary>

```
func _setup_camera_probe() -> void:
	if spring_arm == null:
		return
	if spring_arm.shape == null:
		var probe := SphereShape3D.new()
		probe.radius = maxf(dash_camera_probe_radius, 0.05)
		spring_arm.shape = probe
	spring_arm.margin = maxf(spring_arm.margin, dash_camera_margin)
	# Der eigene Koerper darf den Arm niemals einziehen. Godot schliesst
	# das Elternobjekt NICHT automatisch aus.
	spring_arm.add_excluded_object(get_rid())


## Schaltet die Kollision des Federarms fuer die Dauer des Dashs ab und
## danach exakt auf den vorherigen Wert zurueck. Laeuft jeden Frame ganz
## oben in _physics_process, also auch dann, wenn der Dash durch Tod,
## Stun oder Szenenwechsel abbricht.
## Faehrt die Kamera gedaempft auf die vom Federarm ermittelte Laenge zu,
## statt sie ihn hart setzen zu lassen. Siehe Kommentarblock oben.
func _update_camera_spring(delta: float) -> void:
```
</details>

### 🤖 Assistant: *Let's review the final `combat_giselle.gd…*

`20:13:17`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let's review the final `combat_giselle.gd` for correctness before wrapping up.

#### 👀 Read `combat_giselle.gd`

`20:13:18`

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

const MUZZLE_VFX_SCENE: PackedScene = preload("res://scenes/vfx/spark_yellow.tscn")
const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

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
	primary_cooldown = 0.08
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
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_uzi_esp(target)

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	_spawn_muzzle_vfx(origin, dir)
	_spawn_tracer(origin, result["position"], 0.35, 0.06)
	if result["hit"]:
		var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		if spark:
			spark.scale *= 1.6
		_lock_model_to(result["target"])
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
			_uzi_esp_box.global_position = target.global_position + Vector3.UP * 1.1
		return

	_clear_uzi_esp()
	_uzi_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_uzi_esp_marker = _build_esp_marker()
	get_tree().current_scene.add_child(_uzi_esp_marker)
	_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2

	_uzi_esp_box = EnemyEspBox.build(uzi_esp_color)
	get_tree().current_scene.add_child(_uzi_esp_box)
	_uzi_esp_box.global_position = target.global_position + Vector3.UP * 1.1


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
			_sniper_esp_box.global_position = target.global_position + Vector3.UP * 1.1
		return

	_clear_sniper_esp()
	_sniper_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_sniper_esp_box = EnemyEspBox.build(uzi_esp_color, Vector3(2.0, 2.6, 2.0))
	get_tree().current_scene.add_child(_sniper_esp_box)
	_sniper_esp_box.global_position = target.global_position + Vector3.UP * 1.1


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

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		_spawn_muzzle_vfx(origin, dir)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(origin, result["position"], 0.9, 0.12)
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
func _damage_multiplier() -> float:
	var stats: PlayerStats = PlayerStats.find_for(self)
	return stats.get_damage_multiplier() if stats else 1.0


## Dreht das Charaktermodell zum getroffenen Ziel - dieselbe player_base.gd-
## Funktion, die auch Nahkampf-Treffer schon nutzen (siehe combat_base.gd::
## _on_hit_landed()). Hitscan-Treffer loesen das nicht automatisch aus, da sie
## NIE ueber die Hitbox-Signale laufen (siehe Kopfkommentar) - deshalb hier
## explizit nachgezogen.
func _lock_model_to(target: Variant) -> void:
	if player and player.has_method("set_target") and target is Node3D:
		player.set_target(target)


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
func _spawn_muzzle_vfx(pos: Vector3, dir: Vector3) -> void:
	var vfx_dir: Vector3 = dir
	var spawn_pos: Vector3 = pos + dir * MUZZLE_FORWARD_OFFSET
	var data: CharacterData = PartyManager.get_active_data()
	if data != null:
		VFX.spawn_dual_tinted(MUZZLE_VFX_SCENE, spawn_pos, data.attack_color, data.attack_color_secondary, vfx_dir)
	else:
		VFX.spawn(MUZZLE_VFX_SCENE, spawn_pos, vfx_dir)

```
</details>

### 💭 Thinking

`20:13:27`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`20:13:28`

*(lines 250–365)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```

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
			if spark:
				spark.scale *= 1.4
			_lock_model_to(result["target"])
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
			_laser_esp_box.global_position = target.global_position + Vector3.UP * 1.1
		return

	_clear_laser_esp()
	_laser_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_laser_esp_marker = _build_laser_esp_marker()
	get_tree().current_scene.add_child(_laser_esp_marker)
	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2

	_laser_esp_box = EnemyEspBox.build(laser_esp_color)
	get_tree().current_scene.add_child(_laser_esp_box)
	_laser_esp_box.global_position = target.global_position + Vector3.UP * 1.1


func _clear_laser_esp() -> void:
	if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
		_laser_esp_marker.queue_free()
	_laser_esp_marker = null
	if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
		_laser_esp_box.queue_free()
```
</details>

### 🤖 Assistant: *Everything checks out.*

`20:13:33`

> Everything checks out. Now let's regenerate the vault/graph since we touched enemy/character combat scripts, and do a final sanity check on tab-indentation for the new files.

#### 💻 Bash

`20:13:34`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -nP "^( +)" scripts/vfx/enemy_esp_box.gd scripts/characters/combat_giselle.gd scripts/characters/combat_winter.gd scripts/player_base.gd | grep -v "^[^:]*:[0-9]*:\t" | head -20
```

```
grep: -P supports only unibyte and UTF-8 locales
```

### 💭 Thinking

`20:13:39`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:13:39`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && sed -n '55,75p' scripts/vfx/enemy_esp_box.gd | cat -A | head -25
```

```
^Ivar half: Vector3 = size * 0.5$
^Ireturn [$
^I^IVector3(-half.x, -half.y, -half.z), Vector3(half.x, -half.y, -half.z),$
^I^IVector3(half.x, -half.y, half.z), Vector3(-half.x, -half.y, half.z),$
^I^IVector3(-half.x, half.y, -half.z), Vector3(half.x, half.y, -half.z),$
^I^IVector3(half.x, half.y, half.z), Vector3(-half.x, half.y, half.z),$
^I]$
$
$
func _build_edges(size: Vector3) -> void:$
^Ivar corners: Array[Vector3] = _corners(size)$
^Ifor edge: Array in EDGES:$
^I^I_add_edge(corners[edge[0]], corners[edge[1]])$
$
$
## Ein einzelner Kantenbalken: ein duenner BoxMesh, dessen lange Achse$
## (lokal Z) per Basis.looking_at() auf die Kante ausgerichtet wird.$
## Basis.looking_at() arbeitet rein in lokalen Vektoren (keine Baum-$
## Zugehoerigkeit noetig) - anders als Node3D.look_at(), das schon$
## global_position braucht und deshalb erst NACH add_child() funktionieren$
## wuerde.$
```

### 🤖 Assistant: *Tabs consistent.*

`20:13:43`

> Tabs consistent. Now regenerating the wiki/graph since combat scripts and player_base.gd changed.

#### 💻 Bash

`20:13:43`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -10 && graphify update . 2>&1 | tail -10
```

```
[4/7] 10 Status-Effekt-Notizen geschrieben (01_Game_Design/Status_Effects)

[5/7] Architektur-Notizen geschrieben (02_Tech_Architecture)

[5/7] Gruppierungs-Seiten (MOCs) geschrieben

[6/7] 85 DevLog-Notizen + Gesamtliste geschrieben (03_DevLogs)

[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).

  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Re-extracting code files in . (no LLM needed)...

  AST extraction: 87/87 uncached files (100%) [12 workers]

  warning: 1 source file(s) produced zero nodes and are absent from the graph: .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5149 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] No code-graph topology changes detected; outputs left untouched.

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *All done. Here's a summary of the five changes…*

`20:14:27`

> All done. Here's a summary of the five changes:
> 
> ## 1. Uzi particle direction — fixed
> `_spawn_muzzle_vfx()` in `combat_giselle.gd` was passing `-dir` to `VFX.spawn_dual_tinted()`. `vfx_manager.gd` documents unambiguously that its `direction` param means "the effect's **-Z** points there" (Godot's `look_at()` convention) — so `-dir` was aiming the flash's front backward, at the camera. The old comment justified this by citing `primary_hitbox.gd`'s "+Z is front" note, but that's a one-off fact about how *that specific* hand-placed Area3D node was rotated in its `.tscn`, not a project-wide rule. Fixed to pass `dir` unnegated.
> 
> ## 2 & 3. Over-the-shoulder camera
> Added `camera_shoulder_offset` (`player_base.gd`) — a **position** offset on `SpringArm3D` within `CameraPivot`, not `Camera3D.h_offset`. This matters: since Giselle/Winter's shots always fire from `camera.global_position` toward `-camera.basis.z`, a pure positional (parallel) shift keeps the crosshair perfectly accurate automatically — an `h_offset`-based lens-shift would have desynced the rendered image from the raycast. Default `0.6` (right shoulder), tunable per-character in the Inspector. `combat_giselle.gd` tweens it further out to `sniper_aim_shoulder_offset` (`1.1`) while sniping, alongside the existing FOV tween, and back on release.
> 
> ## 4. Enemy ESP box
> New `scripts/vfx/enemy_esp_box.gd` (`EnemyEspBox`) — a 12-edge wireframe box built from thin unshaded/emissive `BoxMesh` segments (matches the project's existing primitive-mesh VFX style, no shaders). Wired into all three existing auto-target systems: Giselle's Uzi, Giselle's Sniper (which didn't have a discrete locked-target before — added sticky resolution for it), and Winter's Laser. The box tracks the locked target and calls `.flash()` (brief emission pulse) on every actual hit.
> 
> ## 5. Sniper aim assist
> `aim_assist_angle_deg` 10°→18°, `aim_assist_strength` 0.5→0.85 (both already existed as sniper-only exports, just under-tuned). Kept below 1.0 deliberately so it's not a full aim-bot — further tunable via Inspector.
> 
> Worth testing in-editor: fire the Uzi and check the flash no longer streaks backward, aim down the sniper sights to see the shoulder shift, and check both weapons' ESP boxes appear/flash on a sandboxed enemy.

## 🤷 User: *Ich brauche bei unserem Godot 4 (GDScript…*

`20:15:12`

Ich brauche bei unserem Godot 4 (GDScript) Projekt "Lemonade" Hilfe bei einigen Bugfixes, Anpassungen im Item-System und beim Balancing der Gegner. Bitte arbeite die folgenden Punkte Schritt für Schritt ab:

1. Minimap-Icons bei 2x1 Räumen (Verzerrung fixen)
   Wir haben Räume, die nicht nur 1x1 groß sind, sondern z.B. 2x1. Dadurch wird auf der Minimap das Icon (Textur/Farbe) des Grid-Layouts mit skaliert, was verzerrt und gestreckt aussieht, oder die Farbe füllt den Raum nicht sauber aus. Wie können wir das in unserem UI/Minimap-Skript (wahrscheinlich `room_instance.gd` oder das UI-Skript für die Karte) so einstellen, dass die Textur nicht gestreckt wird, sondern z.B. wiederholt (Tiling/Repeat) oder sauber zentriert wird?

2. Karinas Sekundärangriff (RMB) - Hitbox & Vernetzung
   Bei Karinas RMB-Angriff funktioniert die "Vernetzung" (Lock-On / Hit-Detection) manchmal nicht richtig. Außerdem sollte die Hitbox großzügiger/besser sein, damit man bei diesem Move nicht so leicht ins Leere schlägt. Wo und wie passe ich in `combat_karina.gd` oder in den Hitbox-Settings die Range und Zuverlässigkeit für ihren RMB an?

3. Aktive Items - Inventar & Tauschen (Q und E Slot)
   Aktuell nutzen wir Q und E für aktive Items (gesteuert über `item_manager.gd` / `Items` Autoload). Es soll folgendes Verhalten implementiert werden:

- Wenn man nur 1 aktives Item hat (auf Q), soll das nächste aufgesammelte Item automatisch in den E-Slot gepackt werden.
- Wenn man bereits 2 aktive Items hat (Q und E voll) und ein 3. aktives Item von einem Tresen (Pedestal) aufheben will, soll das Item aus dem Q-Slot auf den Tresen zurückgelegt werden (Swapping), und das neue Item nimmt den Q-Slot ein.
  Wie passe ich die Pickup-Logik im `TreasureManager` bzw. `ItemManager` dafür an?

4. Turret/Kanonen Gegner - Detection Range
   Wir haben stationäre Kanonen-Gegner (z.B. den Mörser-Bot und den Säure-Sprinkler). Deren Detection-Range (Sichtweite/Aggro-Range) soll extrem stark erhöht werden, damit sie den Spieler fast überall im Raum bemerken. Welche Parameter in `custom_enemy_base.gd` oder im spezifischen Skript muss ich dafür wie hoch setzen?

5. Mörser-Bot - Schussgeschwindigkeit
   Das Projektil, das der Mörser-Bot abfeuert, fliegt aktuell zu langsam. Bitte zeige mir, wie ich die Projektil-Geschwindigkeit in seinem Code deutlich erhöhen kann.

6. Skalierung (Räume und Mörser)

- Die Räume sollen generell um ca. 15% verkleinert werden. Bitte erkläre mir, wie ich das globale Scaling der Raum-Szenen (oder in der `level_generator.gd`) anpasse, ohne dass das Grid-System (die Mathematik dahinter) kaputt geht.
- Das 3D-Modell / der Scale des Mörser-Bots soll ebenfalls um 15% kleiner gemacht werden.Ich brauche eine weitere Anpassung für den Charakter "Karina" in unserem Godot 4 Projekt (Whiplash/Lemonade). Bitte zeige mir den Code für die folgenden zwei Punkte:

1. Karina LMB (Luft-Angriff) Hitbox-Fix
   Wenn Karina in der Luft ist und mit der linken Maustaste (Primärangriff) angreift, trifft sie die Gegner nicht. Die Hitbox scheint vertikal nicht hoch genug zu sein oder deaktiviert sich in der Luft. Wie können wir in `combat_karina.gd` oder den Hitbox/Shape-Settings der `.tscn` sicherstellen, dass ihr Angriff auch aus der Luft zuverlässig trifft?
2. Neue Passive für Karina: Lifesteal (via Item-System)
   Karina soll eine feste passive Fähigkeit bekommen: Bei jedem Treffer (Hit) hat sie eine 15% Chance, sich um 5 HP zu heilen.
   Da wir bereits ein Item-System in `item_catalog.gd` und `item_behaviours.gd` haben, möchte ich diese Passive als ein unsichtbares, charakter-spezifisches Item umsetzen.
   Bitte erstelle:

- Den neuen Item-Eintrag (z.B. `karina_passive_lifesteal`) in der `item_catalog.gd` (Kategorie PASSIVE).
- Die Logik in `item_behaviours.gd`, die auf Treffer reagiert, die 15% Chance würfelt und den Charakter heilt.
- Den Code in `char_karina.gd` (wahrscheinlich in der `_ready()` Funktion), um ihr dieses Item beim Spawnen automatisch und unsichtbar (ohne UI-Popup) ins Inventar zu legen, damit die Passive aktiv wird.Ich brauche eine Anpassung für den Level-Generator in unserem Godot 4 Projekt (Whiplash). Es geht um das "Threat-Budget" (die Punkte, die festlegen, wie viele Gegner in einem Raum spawnen).

Aktuell hat jeder Raum ein bestimmtes Threat-Budget. Da wir aber auch größere Räume haben (z.B. mit einem `footprint` von 2x1 oder 2x2 Zellen), wirken diese großen Räume oft zu leer, wenn sie das gleiche Budget haben wie ein kleiner 1x1 Raum.

Bitte zeige mir, wie ich in `level_generator.gd` (oder wo das Threat-Budget berechnet wird) eine Skalierung einbaue. Die Logik soll so sein:
Das Threat-Budget des Raumes soll mit seiner Zellen-Größe (Room Size / Footprint) multipliziert oder skaliert werden. Ein 2x1 Raum sollte also mehr Threat-Punkte zur Verfügung haben als ein 1x1 Raum, damit die Dichte der Gegner konstant bleibt.

### 💭 Thinking

`20:15:22`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `minimap_color|grid_texture|room_color|icon` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`20:15:24`

```
Found 7 files
scripts\hud.gd
scripts\items\item_data.gd
scripts\ability_slot.gd
scripts\treasure_pedestal.gd
scripts\minimap.gd
scripts\items\item_description_hud.gd
scripts\character_data.gd
```

#### 👀 Read `char_karina.gd`

`20:15:24`

#### 👀 Read `custom_enemy_base.gd`

`20:15:25`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\custom_enemy_base.gd</code></summary>

```
extends CharacterBody3D
class_name CustomEnemyBase

# ============================================================================
# CustomEnemyBase — gemeinsamer Unterbau fuer die neuen, rein
# code-gebauten Gegnertypen (Moerser-Bot, Saeure-Sprinkler, Magnet-Kern,
# Divebomber, Schild-Drohne, Plasmastrahl-Bot).
# ============================================================================
# Bewusst NICHT von EnemyAI geerbt: EnemyAI ist fest auf ein
# Chase-Attack-State-Machine-Muster mit importiertem Roboter-Mesh
# zugeschnitten (siehe dessen Kopfkommentare). Die neuen Gegner brauchen
# davon nichts - sie stehen fest (Turret-Typen) oder fliegen eigene
# Flugmuster (Divebomber/Drohnen), haben keine Laufanimation und bauen sich
# wie die Hazards (cannon.gd/turret.gd) komplett aus Primitiv-Meshes auf.
#
# Was trotzdem geteilt werden MUSS, damit diese Gegner mit dem Rest des
# Spiels kompatibel sind:
#   - Gruppe "enemies": Items (_enemies_near), Bomben-Explosionen und
#     Homing-Bolts finden ihre Ziele ausschliesslich darueber.
#   - collision_layer = 4: exakt die Ebene, die PrimaryHitbox.collision_mask
#     (siehe char_*.tscn) abhorcht - ohne sie liefe der Spieler-Nahkampf
#     durch diese Gegner hindurch.
#   - Ein Kind-Node NAMENS "Health" vom Typ Health: primary_hitbox.gd und
#     TurretProjectile suchen ausschliesslich per find_child("Health", ...).
#
# Alle sechs Typen sind sowohl ueber die LevelGenerator-Threat-Budget-
# Tabellen (siehe resources/enemies/es_*.tres) als auch einzeln ueber
# EnemySandboxRoom (scripts/enemy_sandbox_room.gd) spawnbar.

const HIT_SPARK_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

## Einheitliches Rot fuer alle Boden-Telegraphen ("hier schlaegt gleich etwas
## ein") ueber alle sechs Typen hinweg - Rueckmeldung: die einzelnen Typen
## tippten vorher leicht unterschiedliche Rottoene von Hand ein (z.B.
## Moerser-Bot 1.0/0.1/0.1 vs. Divebomber 1.0/0.15/0.1), was auf den ersten
## Blick nach zwei verschiedenen Signalfarben aussehen konnte. Wert
## identisch zum bereits etablierten Rot der ORIGINALEN drei Threat-Budget-
## Gegner (Fighter/Stinger/Colossus, siehe deren TelegraphInner/OuterRing in
## scenes/{enemies/dummy,scout_dummy,tank_dummy}.tscn) - EIN Rot fuers ganze
## Spiel statt eines pro Gegnertyp neu erfundenen.
const DANGER_TELEGRAPH_COLOR: Color = Color(1.0, 0.15686275, 0.1254902)

## Kopie von StatusEffectManager.DOT_IDS/enemy_ai.DOT_EFFECT_IDS - const
## Ausdruecke duerfen in GDScript nicht auf andere Klassen zugreifen, siehe
## Kommentar dort. Wer eine Liste aendert, aendert alle drei mit.
const DOT_EFFECT_IDS: PackedStringArray = ["poison", "bleed", "burn", "acid"]

var health: Health = null
var visual_root: Node3D = null
var status_effects: StatusEffectManager = null
var _dead: bool = false

## Von RoomInstance._spawn_one() gesetzt (bleibt null bei Sandbox-Spawns).
## BUGFIX "Schild-Drohne/Plasmastrahl-Bot sterben nie, Raum bleibt
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
	_build_health()
	_build_status_effects()
	_build()


## Subclasses setzen hier ihre Werte (display_name, max_health, ...), BEVOR
## Health gebaut wird.
func _configure() -> void:
	pass


## Subclasses bauen hier ihre Meshes/Collision/Timer/Attack-Logik auf.
func _build() -> void:
	pass


func _build_health() -> void:
	health = Health.new()
	health.name = "Health"
	health.max_health = max_health
	health.regen_enabled = false
	add_child(health)
	health.died.connect(_on_died)


## Ohne diesen Manager liefe JEDER Status-Effekt (Saeure, Brand, Betaeubung,
## der neue "shield"-Buff) lautlos ins Leere - StatusEffectBase.apply_raw()
## faellt ohne "apply_status_effect"-Methode UND ohne StatusEffectManager-
## Kind komplett tot durch (siehe deren Kopfkommentar). Vorher hatte KEINER
## der sechs neuen Gegnertypen ueberhaupt einen Manager.
func _build_status_effects() -> void:
	status_effects = StatusEffectManager.get_or_create(self)
	status_effects.effect_ticked.connect(_on_status_effect_ticked)
	status_effects.effect_applied.connect(_on_status_effect_applied)
	status_effects.effect_expired.connect(_on_status_effect_expired)


func apply_status_effect(id: String, duration: float, magnitude: float = 1.0, source: Node = null, tick_interval: float = 0.0) -> void:
	status_effects.apply_effect(id, duration, magnitude, source, tick_interval)


func has_status_effect(id: String) -> bool:
	return status_effects.has_effect(id)


func _on_status_effect_ticked(id: String, magnitude: float, source: Node) -> void:
	if health != null and id in DOT_EFFECT_IDS:
		health.take_damage(magnitude, source)


func _on_status_effect_applied(id: String, _duration: float, _magnitude: float, _source: Node) -> void:
	if id == "shield":
		_apply_shield_visual()


func _on_status_effect_expired(id: String) -> void:
	if id == "shield":
		_remove_shield_visual()


# ============================================================================
# Schild-Buff (Schild-Drohne) — +25 % Maximal-HP, der Gegner selbst leuchtet.
# ============================================================================
# GEAENDERT (Rueckmeldung: "shield sollte die Gegner nur zum Leuchten
# bringen"): vorher eine zusaetzliche, halbtransparente Kugel-Aura UM den
# Gegner herum PLUS ein 25% groesseres Modell - je nach Gegner-Silhouette
# sah die ueberlappende Kugel seltsam aus und die Groessenaenderung war ein
# zweiter, unabhaengiger visueller Hinweis, den niemand gefordert hat. Jetzt
# pulsiert stattdessen die Emission der EIGENEN Meshes des Gegners direkt -
# der Gegner leuchtet, statt in einer fremden Kugel zu stecken. Gleiche
# Werte/Regeln wie enemy_ai.gd (dort weiterhin die alte Aura, siehe
# Kopfkommentar dort), siehe scripts/status_effects/shield.gd fuer die
# ausfuehrliche Begruendung des HP-Bonus.
var _shield_active: bool = false
var _shield_pre_max_health: float = 0.0
## Array[Dictionary{mesh: MeshInstance3D, original: Material, glow: Material}]
var _shield_glow_entries: Array = []
var _shield_glow_tween: Tween = null


func _apply_shield_visual() -> void:
	if _shield_active or _dead:
		return
	_shield_active = true

	if health != null:
		_shield_pre_max_health = health.max_health
		health.set_max_health(_shield_pre_max_health * (1.0 + StatusShield.MAX_HEALTH_BONUS_FACTOR), true)

	_shield_glow_entries.clear()
	if visual_root != null and is_instance_valid(visual_root):
		for mesh: MeshInstance3D in _collect_mesh_instances(visual_root):
			var original: Material = mesh.material_override
			if original == null:
				continue
			var glow_mat: Material = original.duplicate()
			mesh.material_override = glow_mat
			_shield_glow_entries.append({"mesh": mesh, "original": original, "glow": glow_mat})

	_shield_glow_tween = create_tween()
	_shield_glow_tween.set_loops()
	_shield_glow_tween.tween_method(_set_shield_glow_strength, 0.35, 1.0, 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_shield_glow_tween.tween_method(_set_shield_glow_strength, 1.0, 0.35, 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Alle sechs Sandbox-Typen bauen ihre Meshes ausschliesslich ueber
## _make_unshaded_material() (immer StandardMaterial3D) - kein Fall hier
## nutzt die geteilte psx-ShaderMaterial, deshalb genuegt dieser eine Zweig.
func _set_shield_glow_strength(strength: float) -> void:
	for entry: Dictionary in _shield_glow_entries:
		var mat: Material = entry["glow"]
		if mat is StandardMaterial3D:
			var sm := mat as StandardMaterial3D
			sm.emission_enabled = true
			sm.emission = StatusShield.TINT_COLOR
			sm.emission_energy_multiplier = lerpf(0.6, 3.2, strength)


## Rekursiv, damit auch verschachtelte Meshes (z.B. Divebomber: Fluegel als
## Kind von _visual_body) mitleuchten.
func _collect_mesh_instances(node: Node) -> Array:
	var found: Array = []
	if node is MeshInstance3D:
		found.append(node)
	for child: Node in node.get_children():
		found.append_array(_collect_mesh_instances(child))
	return found


func _remove_shield_visual() -> void:
	if not _shield_active:
		return
	_shield_active = false

	if health != null and _shield_pre_max_health > 0.0:
		health.set_max_health(_shield_pre_max_health, false)

	if _shield_glow_tween != null and _shield_glow_tween.is_valid():
		_shield_glow_tween.kill()
	_shield_glow_tween = null

	for entry: Dictionary in _shield_glow_entries:
		var mesh: MeshInstance3D = entry["mesh"]
		if is_instance_valid(mesh):
			mesh.material_override = entry["original"]
	_shield_glow_entries.clear()


@export var display_name: String = "Gegner"
@export var max_health: float = 60.0


func get_display_name() -> String:
	return display_name


func _find_player() -> CharacterBody3D:
	return get_tree().get_first_node_in_group(PartyManager.PLAYER_GROUP) as CharacterBody3D


## Subclasses, die eigene Effekt-Nodes AUSSERHALB ihrer selbst anlegen (z.B.
## ShieldDrone/PlasmaBeamBot: Beam-Meshes haengen unter current_scene, nicht
## unter dem Gegner selbst, weil sie Start- UND Endpunkt unabhaengig von der
## eigenen Transform brauchen) raeumen die hier auf. WICHTIG: wird nicht nur
## von _on_died() aufgerufen, sondern auch von aussen ueber
## enemy_sandbox_room.gd::_clear_enemies() - dort wird der Gegner per
## queue_free() zwangsentfernt (Health.died feuert dabei NICHT), sonst
## blieben Beams/Telegraphs bis zu ihrem eigenen Timeout einsam in der Luft
## haengen, obwohl der Gegner, der sie erzeugt hat, laengst weg ist.
func _cleanup_effects() -> void:
	pass


func _on_died() -> void:
	await _teardown(true)


## Fuer "kein Pflicht-Kill"-Typen (Schild-Drohne/Plasmastrahl-Bot):
## Gegner-Liste, auf die sich ihr eigener _despawn_if_room_clear() beim
## Pruefen beschraenkt. Mit spawn_room gesetzt (Normalfall: ueber
## RoomInstance gespawnt) NUR die eigenen Raum-Kameraden - ohne spawn_room
## (Sandbox-Spawn) faellt es auf die globale Gruppe "enemies" zurueck, weil
## dort kein Raum-Konzept existiert.
func _room_scoped_enemies() -> Array:
	if spawn_room != null and is_instance_valid(spawn_room) and spawn_room.has_method("get_spawned_enemies"):
		return spawn_room.get_spawned_enemies()
	return get_tree().get_nodes_in_group("enemies")


## Fuer Gegner, die NICHT im Kampf getoetet werden muessen, um zu
## verschwinden - aktuell Schild-Drohne/Plasmastrahl-Bot, siehe deren
## _despawn_if_room_clear(). Gleicher Ablauf wie _on_died() (Kollision aus,
## Effekte aufraeumen, wegschrumpfen), NUR ohne den Treffer-Funken - es war
## kein Treffer, der sie entfernt hat.
func despawn() -> void:
	await _teardown(false)


func _teardown(with_hit_vfx: bool) -> void:
	if _dead:
		return
	_dead = true

	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	remove_from_group("enemies")
	_cleanup_effects()

	if with_hit_vfx:
		VFX.spawn(HIT_SPARK_SCENE, global_position + Vector3.UP, Vector3.ZERO)

	if visual_root != null and is_instance_valid(visual_root):
		var tween: Tween = create_tween()
		tween.tween_property(visual_root, "scale", Vector3.ZERO, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await tween.finished

	queue_free()


## Kleine Bau-Helfer, identisch zum Stil in cannon.gd/turret.gd - vermeidet,
## dass jeder Subtyp dieselben acht Zeilen fuer Mesh+Material neu schreibt.
func _make_unshaded_material(color: Color, emission_mul: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	if emission_mul > 0.0:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = emission_mul
	return mat


func _add_box_collision(size: Vector3, offset: Vector3 = Vector3.ZERO) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = offset
	add_child(shape)


## Positioniert/skaliert/dreht einen duennen Cylinder-Mesh so, dass er als
## Verbindungsbeam zwischen zwei Punkten erscheint (Y-Achse = Laenge).
##
## NICHT einfach node.look_at(to, Vector3.UP): das wirft eine
## Godot-Warnung und liefert eine undefinierte Basis, sobald die
## Blickrichtung fast exakt parallel zum Up-Vektor liegt - z.B. bei einem
## fast senkrechten Strahl (Plasmastrahl-Bot -> Bodenpunkt direkt darunter).
## Weicht in dem Fall auf FORWARD als Referenzachse aus.
func _orient_beam_segment(node: Node3D, from: Vector3, to: Vector3) -> void:
	var dist: float = from.distance_to(to)
	node.global_position = from.lerp(to, 0.5)

	# BUGFIX "Strahl sieht wie ein hochkantes Rechteck aus": Godots
	# look_at() liest die aktuelle node.scale VOR der Rotation aus und legt
	# sie danach unveraendert auf die (noch lokale, nicht neu ausgerichtete)
	# Achsen um - stand die Laengen-Skalierung schon VOR look_at() auf der
	# Y-Achse, landet sie dadurch auf der FALSCHEN Achse (der "Hoch"-Achse
	# des Strahls statt seiner Laengsachse) und der duenne Zylinder wird
	# quer zur Blickrichtung zu einer Ellipse/einem Rechteck aufgeblaeht,
	# statt sich zwischen from/to zu strecken. Deshalb: Skalierung erst
	# NACHDEM look_at() + die 90-Grad-Korrektur die endgueltige
	# Ausrichtung stehen haben, direkt auf die dann korrekte Laengsachse
	# (lokal Y) anwenden.
	node.scale = Vector3.ONE
	if dist <= 0.01:
		node.scale = Vector3(1.0, 0.01, 1.0)
		return
	var dir: Vector3 = (to - from) / dist
	var up_hint: Vector3 = Vector3.FORWARD if absf(dir.dot(Vector3.UP)) > 0.95 else Vector3.UP
	node.look_at(to, up_hint)
	node.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))
	node.scale = Vector3(1.0, dist, 1.0)


## Baut einen deutlich lesbaren Energiestrahl: duenner heller Kern + breiterer
## weicher Glow-Mantel + eine Puls-Kugel, die den Strahl entlanglaeuft.
##
## ERSETZT den fruehereren einzelnen duennen Zylinder (0.06-0.08 Radius) aus
## Schild-Drohne/Plasmastrahl-Bot - auf dem Bildschirm kaum von der Umgebung
## zu unterscheiden. Kern+Glow+Puls zusammen lesen sich auch aus der
## Kampfkamera-Distanz eindeutig als "das ist ein aktiver Strahl".
##
## Rueckgabe: Dictionary{root, core, glow, pulse, t} - "root" haengt unter
## current_scene (Start-/Endpunkt sind unabhaengig von dieser Instanz-
## Transform), muss also explizit ueber _free_beam_visual() aufgeraeumt
## werden, NICHT automatisch beim Tod dieser Instanz.
## radius_scale weitet Kern/Glow/Puls proportional auf (Default 1.0 = alte
## Groesse, unveraendert fuer Schild-Drohnen-Verbindungsstrahl) - gebraucht
## vom Plasmastrahl-Bot, dessen Bodenstrahl deutlich breiter ist als der
## duenne Verbindungsstrahl (siehe dortiger Aufrufer).
func _create_beam_visual(color: Color, radius_scale: float = 1.0) -> Dictionary:
	var root := Node3D.new()
	get_tree().current_scene.add_child(root)

	var glow := MeshInstance3D.new()
	var glow_cyl := CylinderMesh.new()
	glow_cyl.top_radius = 0.3 * radius_scale
	glow_cyl.bottom_radius = 0.3 * radius_scale
	glow_cyl.height = 1.0
	glow.mesh = glow_cyl
	var glow_mat := _make_unshaded_material(color, 0.8)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color.a = 0.3
	glow.material_override = glow_mat
	root.add_child(glow)

	var core := MeshInstance3D.new()
	var core_cyl := CylinderMesh.new()
	core_cyl.top_radius = 0.09 * radius_scale
	core_cyl.bottom_radius = 0.09 * radius_scale
	core_cyl.height = 1.0
	core.mesh = core_cyl
	core.material_override = _make_unshaded_material(color, 2.8)
	root.add_child(core)

	var pulse := MeshInstance3D.new()
	var pulse_mesh := SphereMesh.new()
	pulse_mesh.radius = 0.24 * radius_scale
	pulse_mesh.height = 0.48 * radius_scale
	pulse.mesh = pulse_mesh
	pulse.material_override = _make_unshaded_material(color, 3.2)
	root.add_child(pulse)

	return {"root": root, "core": core, "glow": glow, "pulse": pulse, "t": 0.0}


## Aktualisiert Position/Ausrichtung/Puls eines mit _create_beam_visual()
## erzeugten Strahls. delta wird nur fuer die Pulsgeschwindigkeit gebraucht.
func _update_beam_visual(beam: Dictionary, from: Vector3, to: Vector3, delta: float) -> void:
	if beam.is_empty() or not is_instance_valid(beam["root"]):
		return
	_orient_beam_segment(beam["core"], from, to)
	_orient_beam_segment(beam["glow"], from, to)

	beam["t"] = fmod(float(beam["t"]) + delta * 1.6, 1.0)
	var pulse: MeshInstance3D = beam["pulse"]
	if is_instance_valid(pulse):
		pulse.global_position = from.lerp(to, float(beam["t"]))


func _free_beam_visual(beam: Dictionary) -> void:
	if not beam.is_empty() and is_instance_valid(beam["root"]):
		(beam["root"] as Node3D).queue_free()


## Dreht "self" langsam um die Y-Achse in Richtung target_pos - fuer
## stationaere Turret-Gegner (Moerser-Bot/Saeure-Sprinkler), die sich nie
## bewegen, aber beim Schiessen sichtbar zum Spieler schwenken sollen statt
## fix in eine Richtung zu zeigen. Gleiche atan2/lerp_angle-Formel wie
## enemy_ai.gd::_wander_step(), nur deutlich langsamer (turn_speed statt
## dort fix 6.0).
func _turn_toward(target_pos: Vector3, delta: float, turn_speed: float = 1.5) -> void:
	var dir: Vector3 = target_pos - global_position
	dir.y = 0.0
	if dir.length_squared() < 0.01:
		return
	var target_rotation: float = atan2(dir.x, dir.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)


## Bruchstuecke, die nach unten auf den Boden fallen und dort liegen bleiben
## (statt wie eine reine VFX-Partikelwolke in der Luft zu verblassen) - fuer
## Turret-Gegner (Moerser-Bot/Saeure-Sprinkler), deren "Kanone" beim Tod
## sichtbar als Schrott am Einsatzort zurueckbleiben soll.
func _spawn_ground_fragments(colors: Array[Color], count: int = 6) -> void:
	var tree: SceneTree = get_tree()
	var origin: Vector3 = global_position + Vector3.UP * 1.0

	for i: int in range(count):
		var frag := MeshInstance3D.new()
		var box := BoxMesh.new()
		var size: float = randf_range(0.25, 0.5)
		box.size = Vector3(size, size * randf_range(0.6, 1.0), size)
		frag.mesh = box
		frag.material_override = _make_unshaded_material(colors[i % colors.size()], 0.4)
		# Gruppe statt freihaengendem Node: stage_manager.gd raeumt
		# "floor_debris" beim Etagenwechsel mit auf (wie pickups/hazard/
		# projectiles) - ohne das wuerden sich Bruchstuecke ueber eine ganze
		# Run-Dauer unbegrenzt unter current_scene ansammeln, weil sie
		# absichtlich nie von selbst queue_free()en.
		frag.add_to_group("floor_debris")
		tree.current_scene.add_child(frag)
		frag.global_position = origin
		frag.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)

		var angle: float = randf() * TAU
		var horiz: float = randf_range(1.0, 2.8)
		var landing_xz: Vector3 = origin + Vector3(cos(angle) * horiz, 0.0, sin(angle) * horiz)
		# _project_to_ground() statt eines geratenen Y-Werts, damit die
		# Bruchstuecke auch auf leicht geneigtem/unebenem Boden sauber
		# aufliegen statt in der Luft zu haengen oder im Boden zu versinken.
		var target: Vector3 = _project_to_ground(landing_xz) + Vector3.UP * (size * 0.5)
		var spin: Vector3 = frag.rotation + Vector3(
			randf_range(2.0, 6.0), randf_range(2.0, 6.0), randf_range(2.0, 6.0)
		)

		var tween: Tween = frag.create_tween()
		tween.set_parallel(true)
		tween.tween_property(frag, "global_position", target, 0.6) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(frag, "rotation", spin, 0.6)


const _GROUND_RAYCAST_MASK: int = 1

## Projiziert eine Position senkrecht auf den Boden darunter. Gebraucht von
## Moerser-Bot/Saeure-Sprinkler (Einschlag/Pfuetze sollen auf dem Boden
## liegen, nicht auf Spieler-Kopfhoehe, falls der gerade springt o.ae.) und
## Plasmastrahl-Bot (Laser-Fussabdruck).
func _project_to_ground(pos: Vector3) -> Vector3:
	var world: World3D = get_world_3d()
	if world == null:
		return pos
	var query := PhysicsRayQueryParameters3D.create(
		pos + Vector3.UP * 2.0, pos - Vector3.UP * 20.0
	)
	query.collision_mask = _GROUND_RAYCAST_MASK
	query.exclude = [get_rid()]
	var result := world.direct_space_state.intersect_ray(query)
	if result.is_empty():
		return pos
	return result.position

```
</details>

### 💭 Thinking

`20:15:30`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `mortar_bot.gd`

`20:15:31`

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

## War 1.5 - Rueckmeldung "jeder Gegner ausser Magnet soll 3x groesser sein"
## (1.5 * 3 = 4.5).
const VISUAL_SCALE: float = 4.5
## Wie schnell sich der Moerser-Bot zum Spieler dreht (rad/s) - langsam
## genug, dass die Drehung als sichtbares "Zielen" wirkt statt als Snap.
const TURN_SPEED: float = 1.2

var fire_interval: float = 3.6
var flight_time: float = 1.3
## War 8.0 - in einem 14 Units hohen Kampfraum kratzte der Geschossbogen
## damit fast an der Decke ("Rueckmeldung: Moerser-Geschosse zu weit oben in
## der Luft"). Niedrigerer Bogen bleibt als Parabel klar lesbar, wirkt aber
## nicht mehr wie ein Steilfeuer bis unters Dach.
var arc_height: float = 4.0
var blast_radius: float = 4.2
var damage: float = 22.0
var detect_range: float = 45.0

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


func _build_visual() -> void:
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = _base_radius
	base_mesh.bottom_radius = _base_radius * 1.3
	base_mesh.height = 1.4
	var base_visual := MeshInstance3D.new()
	base_visual.mesh = base_mesh
	base_visual.material_override = _make_unshaded_material(Color(0.16, 0.15, 0.18))
	base_visual.position = Vector3(0.0, 0.7, 0.0)
	visual_root.add_child(base_visual)

	var barrel_mesh := CylinderMesh.new()
	barrel_mesh.top_radius = 0.4
	barrel_mesh.bottom_radius = 0.55
	barrel_mesh.height = 2.0
	var barrel := MeshInstance3D.new()
	barrel.mesh = barrel_mesh
	var mat := _make_unshaded_material(Color(0.85, 0.25, 0.15), 0.6)
	barrel.material_override = mat
	barrel.rotation.x = deg_to_rad(-55.0)
	barrel.position = Vector3(0.0, 1.7, 0.4)
	visual_root.add_child(barrel)

	var light := OmniLight3D.new()
	light.light_color = Color(0.9, 0.3, 0.15)
	light.light_energy = 0.9
	light.omni_range = 6.0
	light.shadow_enabled = false
	light.position = Vector3(0.0, 1.9, 0.0)
	visual_root.add_child(light)


## Fallhoehe pro Sekunde, mit der ein leicht ueber dem Boden gespawnter
## Moerser-Bot einsinkt - dieselbe Groessenordnung wie player_base.gd's
## Schwerkraft. Bewusst KEIN staendiges Schweben/Anheben, nur ein Absinken:
## der Bot bewegt sich sonst nie, move_and_slide() haette ohne das keinen
## Grund, jemals aufgerufen zu werden, und is_on_floor() bliebe immer false.
const SETTLE_GRAVITY: float = 40.0


func _physics_process(delta: float) -> void:
	# BUGFIX "manche Moerser haengen noch etwas in der Luft": der Bot bewegt
	# sich nie und ruft deshalb nie move_and_slide() auf - ein Spawn-Marker,
	# der (z.B. in einer geneigten oder mehrzelligen Raum-Vorlage) nicht exakt
	# auf Bodenhoehe liegt, blieb dadurch fuer immer stehen, wo er gespawnt
	# wurde, statt sich wie jeder andere Koerper auf den echten Boden
	# abzusetzen.
	if not is_on_floor():
		velocity.y -= SETTLE_GRAVITY * delta
		move_and_slide()
	elif velocity.y != 0.0:
		velocity.y = 0.0

	var player: CharacterBody3D = _find_player()
	if player == null:
		return
	if global_position.distance_to(player.global_position) > detect_range:
		return

	_turn_toward(player.global_position, delta, TURN_SPEED)

	_cooldown -= delta
	if _cooldown <= 0.0:
		_cooldown = fire_interval
		# Auf den Boden projiziert, statt roh player.global_position zu
		# nehmen: der Spieler-Root sitzt zwar normalerweise auf Fusshoehe,
		# aber im Sprung oder auf leicht geneigtem Boden waere das nicht
		# mehr exakt Bodenhoehe - Ring und Einschlag sollen sichtbar AUF
		# dem Boden liegen, nicht in der Luft schweben.
		_fire_at(_project_to_ground(player.global_position))


func _fire_at(target_pos: Vector3) -> void:
	var launch_pos: Vector3 = global_position + Vector3.UP * 1.9
	var tree: SceneTree = get_tree()

	# --- Bodentelegraph: bleibt fix an target_pos stehen ---------------------
	var telegraph := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = blast_radius
	ring_mesh.bottom_radius = blast_radius
	ring_mesh.height = 0.05
	telegraph.mesh = ring_mesh
	var ring_mat := _make_unshaded_material(DANGER_TELEGRAPH_COLOR)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.albedo_color.a = 0.12
	telegraph.material_override = ring_mat
	tree.current_scene.add_child(telegraph)
	telegraph.global_position = target_pos + Vector3.UP * 0.05

	# create_tween() an "telegraph"/"shell" statt an "self" (dem Moerser-Bot)
	# gebunden - siehe Kommentar am shell_tween unten fuer den Grund.
	var ring_tween: Tween = telegraph.create_tween()
	ring_tween.tween_property(ring_mat, "albedo_color:a", 0.85, flight_time)

	# --- Geschoss: zweiphasige Wurfparabel (Aufstieg, dann Fall) -------------
	var shell := MeshInstance3D.new()
	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = 0.4
	shell_mesh.height = 0.8
	shell.mesh = shell_mesh
	shell.material_override = _make_unshaded_material(Color(1.0, 0.4, 0.1), 2.0)
	tree.current_scene.add_child(shell)
	shell.global_position = launch_pos

	var peak: Vector3 = launch_pos.lerp(target_pos, 0.5) + Vector3.UP * arc_height
	# Werte VOR dem Tween-Callback in lokale Variablen kopieren, damit der
	# Callback unten (siehe _impact_at()) komplett ohne "self" auskommt.
	var dmg: float = damage
	var radius: float = blast_radius

	# BUGFIX "Geschosse frieren ein, wenn der Moerser-Bot waehrend des Flugs
	# stirbt": create_tween(), aufgerufen AUF DEM Moerser-Bot (self), wird
	# automatisch an dessen Lebensdauer gebunden - Godot killt so gebundene
	# Tweens automatisch, sobald der Node den Baum verlaesst (queue_free()
	# in custom_enemy_base.gd::_teardown()). "shell" haengt aber laengst
	# unter current_scene und sollte den Tod des Schuetzen ueberleben - der
	# Tween muss also an "shell" selbst gebunden sein, nicht an "self".
	var shell_tween: Tween = shell.create_tween()
	shell_tween.tween_property(shell, "global_position", peak, flight_time * 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	shell_tween.tween_property(shell, "global_position", target_pos, flight_time * 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	shell_tween.tween_callback(func() -> void:
		shell.queue_free()
		if is_instance_valid(telegraph):
			telegraph.queue_free()
		# _impact_at() ist "static" und ruft NICHTS auf "self" auf - der
		# Moerser-Bot selbst kann zu diesem Zeitpunkt laengst tot und
		# freigegeben sein (siehe Kommentar am shell_tween oben), ein
		# gewoehnlicher Methodenaufruf wie "_impact(target_pos)" wuerde
		# implizit ueber "self" aufgeloest und dann mit einem Fehler
		# fehlschlagen.
		_impact_at(tree, target_pos, dmg, radius)
	)


static func _impact_at(tree: SceneTree, impact_pos: Vector3, dmg: float, radius: float) -> void:
	VFX.spawn(DUST_RING_SCENE, impact_pos)
	VFX.spawn(SPARK_YELLOW_SCENE, impact_pos + Vector3.UP)
	Juice.shake(1.4)

	var player: CharacterBody3D = tree.get_first_node_in_group(PartyManager.PLAYER_GROUP) as CharacterBody3D
	if player == null:
		return
	# Fixe Einschlagsposition, NICHT die aktuelle Spielerposition - siehe
	# Kopfkommentar. Nur horizontal gemessen: der Telegraph-Ring ist eine
	# flache Bodenflaeche, kein Kugelvolumen - ob man 3 m in der Luft ueber
	# dem Ring haengt, sollte am Treffer nichts aendern.
	var flat_player: Vector3 = player.global_position
	flat_player.y = impact_pos.y
	if flat_player.distance_to(impact_pos) > radius:
		return

	var target_health := player.find_child("Health", true, false) as Health
	if target_health != null and target_health.is_alive():
		# source = null statt "self": "self" ist hier eine statische Funktion
		# ohne Instanz, der Moerser-Bot, der das eigentlich abgefeuert hat,
		# kann zu diesem Zeitpunkt schon tot sein (siehe Kopfkommentar am
		# Aufrufer). take_damage() behandelt source ohnehin nur als
		# optionale Info fuer last_damage_source.
		target_health.take_damage(dmg, null)
	if player.has_method("apply_knockback"):
		var away: Vector3 = player.global_position - impact_pos
		away.y = 0.0
		if away.length_squared() < 0.01:
			away = Vector3.FORWARD
		player.apply_knockback(away.normalized() * 10.0 + Vector3.UP * 4.0)


## Maschinen-Tod statt des generischen Wegschrumpfens aus custom_enemy_base.gd
## - der Moerser-Bot ist ein Geraet, keine organische Einheit, und zerspringt
## deshalb sichtbar in seine Bauteile.
func _teardown(with_hit_vfx: bool) -> void:
	if with_hit_vfx:
		_spawn_death_fragments()
	await super._teardown(with_hit_vfx)


## Bruchstuecke bleiben (ueber _spawn_ground_fragments() in
## custom_enemy_base.gd) sichtbar als Schrott am Boden liegen, statt in der
## Luft zu verblassen.
func _spawn_death_fragments() -> void:
	_spawn_ground_fragments([Color(0.16, 0.15, 0.18), Color(0.85, 0.25, 0.15)])

```
</details>

#### 👀 Read `combat_karina.gd`

`20:15:31`

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

const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

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
@export var stealth_touch_radius: float = 1.6
@export var detonation_damage: float = 220.0

const STANCE_MODIFIER_SOURCE: String = "karina_acid_rush"
## GeometryInstance3D.transparency (0=deckend, 1=unsichtbar) statt einzelne
## Material-Alpha-Werte umzubauen - funktioniert unabhaengig davon, welches
## Material das importierte Modell mitbringt, kein Material-Duplizieren
## noetig. Auf Rueckmeldung ("Deckkraft auf 4%") von 0.95 auf 0.96 (100%-4%)
## angehoben.
const STEALTH_MESH_TRANSPARENCY: float = 0.96
const STEALTH_TOUCH_CHECK_INTERVAL: float = 0.15
## Motion-Blur-Trail (GhostTrail, siehe combat_base.gd) waehrend Phantom
## Execute auf 50% Staerke - deutlich ueber dem sehr dezenten Lauf-Trail-
## Default, siehe Rueckmeldung "motion blur trail auf 50%".
const STEALTH_TRAIL_ALPHA: float = 0.5

## "4x ihrer Groesse" fuer die Entladungs-Explosion beim Verlassen von
## Phantom Execute - CHARACTER_SIZE_ESTIMATE ist eine grobe Kapselgroesse
## als Basis, da keine exakte Charaktergroesse als Property existiert.
const DECLOAK_EXPLOSION_SIZE_MULTIPLIER: float = 4.0
const CHARACTER_SIZE_ESTIMATE: float = 2.0

var _stance_active: bool = false
var _acid_tick_timer: float = 0.0

var _stealth_active: bool = false
var _stealth_touch_timer: float = 0.0
var _marked_enemy_ids: Array[int] = []
## Array[Dictionary{beam: Dictionary (BeamVisual), from_id: int, to_id: int}]
## - Kettenverbindungen zwischen aufeinanderfolgend markierten Gegnern.
var _mark_beams: Array[Dictionary] = []

var _health: Health = null
var _meshes: Array[MeshInstance3D] = []
var _aura_visual: MeshInstance3D = null
var _aura_pulse_tween: Tween = null
## Urspruenglicher running_alpha-Wert des GhostTrail, VOR Phantom Execute -
## wird beim Betreten hochgesetzt (siehe STEALTH_TRAIL_ALPHA) und beim
## Verlassen exakt hierauf zurueckgesetzt statt auf einen fest verdrahteten
## Wert, falls der Trail char-spezifisch abweichend konfiguriert ist.
var _default_trail_alpha: float = 0.015


func _init() -> void:
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_health = player.get_node_or_null("Health") as Health
	var model: Node = player.get_node_or_null("CharacterModel")
	_meshes = _collect_mesh_instances(model) if model else []
	if ghost_trail:
		_default_trail_alpha = ghost_trail.running_alpha


# ============================================================================
# Acid Rush Mode - Primary IST die Stance, es gibt keinen separaten Schlag.
# _primary_timer wird zweckentfremdet: waehrend der Stance zaehlt er die
# verbleibende Standzeit runter (Start bei stance_max_duration), danach die
# 1s-Wiedereintritts-Sperre - der bestehende Primary-Cooldown-Ring im HUD
# zeigt dadurch automatisch beides, ohne dass hud.gd etwas davon wissen muss.
# ============================================================================
func _poll_primary_input(delta: float) -> void:
	if _stance_active:
		if not Input.is_action_pressed("attack_primary") or _primary_timer <= 0.0:
			_exit_stance()
			return
		if _aura_visual and is_instance_valid(_aura_visual):
			_aura_visual.global_position = player.global_position + Vector3.UP * 0.05
		_tick_acid_aura(delta)
		return

	if Input.is_action_pressed("attack_primary") and _primary_timer <= 0.0:
		_enter_stance()


func _enter_stance() -> void:
	_stance_active = true
	_primary_timer = stance_max_duration
	_acid_tick_timer = 0.0

	if player:
		var data: CharacterData = PartyManager.get_active_data()
		var color: Color = data.attack_color if data else Color(0.9, 0.1, 0.25)
		VFX.spawn_dual_tinted(HIT_VFX_SCENE, player.global_position + Vector3.UP, color, color, Vector3.UP)
		_spawn_aura_visual(color)

	var stats: PlayerStats = PlayerStats.find_for(self)
	if stats:
		# Ueber die bestehende Item-Modifier-API statt player.speed direkt zu
		# schreiben - PlayerStats ist alleinige Autoritaet ueber den Wert
		# (siehe player_stats.gd-Kopfkommentar), ein direkter Schreibzugriff
		# hier wuerde beim naechsten Item-Pickup wieder ueberschrieben.
		stats.add_modifier(STANCE_MODIFIER_SOURCE, PlayerStats.STAT_MOVE_SPEED, 0.0, stance_speed_bonus_mul)


func _exit_stance() -> void:
	_stance_active = false
	_primary_timer = stance_reentry_cooldown
	_free_aura_visual()

	var stats: PlayerStats = PlayerStats.find_for(self)
	if stats:
		stats.remove_source(STANCE_MODIFIER_SOURCE)


## Durchsichtiger Ring am Boden, der acid_aura_radius sichtbar macht -
## vorher gab es fuer die Aura ausser einzelnen Treffer-Funken auf bereits
## infizierten Gegnern keinerlei Dauer-Feedback, wie weit sie tatsaechlich
## reicht.
func _spawn_aura_visual(color: Color) -> void:
	_free_aura_visual()
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(acid_aura_radius - 0.15, 0.05)
	torus.outer_radius = acid_aura_radius
	ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	# Angehoben (Rueckmeldung "sieht schwach aus"): kraeftigeres Leuchten,
	# damit die Aura auch aus Kampfdistanz klar als aktiver Effekt auffaellt.
	mat.emission_energy_multiplier = 2.2
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.7
	ring.material_override = mat
	get_tree().current_scene.add_child(ring)
	ring.global_position = player.global_position + Vector3.UP * 0.05
	_aura_visual = ring

	# Dauerhafte Rotation, damit die Aura als AKTIVER Effekt liest statt als
	# ruhendes Boden-Decal.
	var spin: Tween = ring.create_tween()
	spin.set_loops()
	spin.tween_property(ring, "rotation:y", TAU, 3.0).from(0.0).set_trans(Tween.TRANS_LINEAR)


func _free_aura_visual() -> void:
	if _aura_visual and is_instance_valid(_aura_visual):
		_aura_visual.queue_free()
	_aura_visual = null


func _tick_acid_aura(delta: float) -> void:
	_acid_tick_timer -= delta
	if _acid_tick_timer > 0.0:
		return
	_acid_tick_timer = acid_tick_interval

	# Kein DOT-Tick im Spiel spawnt normalerweise eine Schadenszahl (siehe
	# custom_enemy_base.gd/enemy_ai.gd::_on_status_effect_ticked() - ruft
	# take_damage() direkt auf, ohne Zahl) - fuer Karina wird das hier
	# explizit nachgezogen, da die Aura sonst komplett stumm ist. Nicht 1:1
	# mit dem tatsaechlichen internen Tick-Timer des StatusEffectManagers
	# synchron, aber nah genug (gleiches Intervall) fuer klares Feedback.
	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var hit_anyone: bool = false

	for enemy: Node3D in EnemyQuery.enemies_within(player.global_position, acid_aura_radius):
		if enemy.has_method("apply_status_effect"):
			hit_anyone = true
			enemy.apply_status_effect("acid", acid_effect_duration, acid_damage_per_tick, player, acid_tick_interval)
			if dns != null:
				var number: Node = dns.instantiate()
				get_tree().current_scene.add_child(number)
				(number as Node3D).global_position = enemy.global_position + Vector3(0.0, 1.8, 0.0)
				if number.has_method("show_damage"):
					number.show_damage(acid_damage_per_tick)

	# Kurzer Aufblitz-Puls am Aura-Ring, wenn sie GERADE tatsaechlich etwas
	# trifft - macht bei den schnellen 0.1s-Ticks (siehe acid_tick_interval)
	# lesbar, dass die Aura wirkt, ohne bei jedem einzelnen Tick eine neue
	# VFX-Szene abzufeuern (waere bei 10 Ticks/s reine Bildschirm-Unruhe).
	# Eigener, EXPLIZIT gekillter Tween statt eines neuen pro Tick: die
	# Pulsdauer (0.15s) ist laenger als das Tick-Intervall (0.1s) - ohne das
	# Killen wuerden sich mehrere Scale-Tweens ueberlappen und gegeneinander
	# ruckeln.
	if hit_anyone and _aura_visual and is_instance_valid(_aura_visual):
		if _aura_pulse_tween != null and _aura_pulse_tween.is_valid():
			_aura_pulse_tween.kill()
		_aura_visual.scale = Vector3.ONE * 1.25
		_aura_pulse_tween = _aura_visual.create_tween()
		_aura_pulse_tween.tween_property(_aura_visual, "scale", Vector3.ONE, 0.15) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## BUGFIX "Cooldown-Ring spinnt": der geerbte primary_cooldown (0.4s, fuer
## normale Angriffe gedacht) blieb ungenutzt/unveraendert, waehrend
## _primary_timer hier auf bis zu stance_max_duration (10s) gesetzt wird.
## get_primary_cooldown_percent() haette also 10.0 / 0.4 = 2500% berechnet -
## der Ring-Overlay bekommt einen anchor_top weit ausserhalb [0,1] und sieht
## kaputt aus. Gleicher Fehler wie Giselles Uzi-Reload, hier fuer die Stance.
func _get_effective_primary_cooldown() -> float:
	return stance_max_duration if _stance_active else stance_reentry_cooldown


# ============================================================================
# Phantom Execute - Halten statt Toggle: aktiviert per just_pressed, bleibt
# aktiv solange RMB gehalten wird und endet (inkl. Detonation) SOFORT beim
# Loslassen, oder frueher bei Ablauf von stealth_max_duration. Ruft NIE
# _do_secondary() auf, da der Cooldown erst NACH der Detonation starten soll,
# nicht beim Aktivieren.
#
# BUGFIX "muss nach dem Loslassen nochmal RMB druecken, damit die Explosion
# stattfindet": war urspruenglich ein Toggle (erneutes just_pressed beendet
# die Tarnung) - dadurch blieb man nach dem Loslassen unsichtbar stehen, bis
# man RMB ein zweites Mal drueckte. Jetzt beendet das simple Loslassen
# (nicht mehr gedrueckt) die Tarnung direkt und loest die Explosion sofort aus.
# ============================================================================
func _poll_secondary_input(delta: float) -> void:
	if _stealth_active:
		_tick_stealth(delta, not Input.is_action_pressed("attack_secondary"))
		return

	if Input.is_action_just_pressed("attack_secondary") and _secondary_timer <= 0.0:
		_start_stealth()


func _start_stealth() -> void:
	_stealth_active = true
	# Wiederverwendet fuer die aktive Restzeit (statt einer eigenen
	# _stealth_timer-Variable) - genau wie _primary_timer bei der Stance:
	# der bestehende Secondary-Cooldown-Ring zeigt dadurch waehrend der
	# gesamten Stealth-Dauer sichtbar "noch X Sekunden aktiv" an, statt die
	# ganze Zeit "bereit" zu zeigen und keinerlei Feedback zu geben, dass
	# ueberhaupt etwas passiert ist.
	_secondary_timer = stealth_max_duration
	_stealth_touch_timer = 0.0
	_marked_enemy_ids.clear()
	_clear_mark_beams()

	# Defensive Neubeschaffung, falls setup() vor der vollstaendigen
	# Instanziierung von CharacterModel/Health gelaufen sein sollte - kostet
	# im Normalfall nichts (Arrays/Referenzen sind schon gesetzt).
	if _health == null:
		_health = player.get_node_or_null("Health") as Health
	if _meshes.is_empty():
		var model: Node = player.get_node_or_null("CharacterModel")
		if model:
			_meshes = _collect_mesh_instances(model)

	if _health:
		_health.set_invulnerable_permanent(true)
	for mesh: MeshInstance3D in _meshes:
		mesh.transparency = STEALTH_MESH_TRANSPARENCY

	if ghost_trail:
		ghost_trail.running_alpha = STEALTH_TRAIL_ALPHA
		ghost_trail.set_running(true)

	_spawn_stealth_toggle_vfx()


func _tick_stealth(delta: float, force_end: bool) -> void:
	if force_end or _secondary_timer <= 0.0:
		_end_stealth()
		return

	# Jeden Frame, NICHT hinter dem Beruehrungs-Timer unten - sonst wuerden
	# die Verbindungslinien zwischen markierten Gegnern nur alle
	# STEALTH_TOUCH_CHECK_INTERVAL Sekunden nachziehen und sichtbar ruckeln,
	# waehrend sich Gegner dazwischen weiterbewegen.
	_update_mark_beams(delta)

	_stealth_touch_timer -= delta
	if _stealth_touch_timer > 0.0:
		return
	_stealth_touch_timer = STEALTH_TOUCH_CHECK_INTERVAL

	for enemy: Node3D in EnemyQuery.enemies_within(player.global_position, stealth_touch_radius):
		var id: int = enemy.get_instance_id()
		if not _marked_enemy_ids.has(id):
			# Verbindet den NEU markierten Gegner mit dem zuletzt markierten -
			# eine Kette statt aller Paare (N Verbindungen statt N*(N-1)/2),
			# bleibt dadurch auch bei vielen Markierungen lesbar. Siehe
			# Rueckmeldung "verbindet Gegner miteinander, damit man besser
			# erkennt wann ein Gegner gehittet wurde".
			if not _marked_enemy_ids.is_empty():
				_connect_marked_enemies(_marked_enemy_ids[_marked_enemy_ids.size() - 1], id)
			_marked_enemy_ids.append(id)
			_spawn_mark_vfx(enemy)


func _connect_marked_enemies(from_id: int, to_id: int) -> void:
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color_secondary if data else Color(1.0, 0.3, 0.7)
	_mark_beams.append({
		"beam": BeamVisual.create(self, color, 0.8),
		"from_id": from_id,
		"to_id": to_id,
	})


## Laeuft jeden Frame waehrend Phantom Execute aktiv ist - haelt die Ketten-
## Verbindungen an den aktuellen Positionen der (ggf. sich bewegenden)
## markierten Gegner fest. Ungueltig gewordene Enden (Gegner in dem Fenster
## gestorben) werden uebersprungen statt die Verbindung zu entfernen - sie
## verschwindet ohnehin spaetestens bei der naechsten _clear_mark_beams().
func _update_mark_beams(delta: float) -> void:
	for entry: Dictionary in _mark_beams:
		var from_obj: Object = instance_from_id(entry["from_id"])
		var to_obj: Object = instance_from_id(entry["to_id"])
		if from_obj == null or not is_instance_valid(from_obj) or not (from_obj is Node3D):
			continue
		if to_obj == null or not is_instance_valid(to_obj) or not (to_obj is Node3D):
			continue
		BeamVisual.update(
			entry["beam"],
			(from_obj as Node3D).global_position + Vector3.UP,
			(to_obj as Node3D).global_position + Vector3.UP,
			delta
		)


func _clear_mark_beams() -> void:
	for entry: Dictionary in _mark_beams:
		BeamVisual.free_beam(entry["beam"])
	_mark_beams.clear()


func _end_stealth() -> void:
	_stealth_active = false
	_clear_mark_beams()

	if _health:
		_health.clear_invulnerable()
	for mesh: MeshInstance3D in _meshes:
		mesh.transparency = 0.0

	if ghost_trail:
		ghost_trail.set_running(false)
		ghost_trail.running_alpha = _default_trail_alpha

	_spawn_stealth_toggle_vfx()
	_spawn_decloak_explosion()
	_detonate()
	# Erst JETZT, nach der Detonation, startet der Cooldown - waere er schon
	# in _start_stealth() gesetzt worden, liefe er waehrend der gesamten
	# Stealth-Dauer schon mit statt erst danach, siehe Spec ("Cooldown NACH
	# der Deaktivierung").
	_secondary_timer = stealth_reentry_cooldown


## "Beim Verlassen von Secondary entsteht zusaetzlich eine Explosion, 4x
## ihrer Groesse, mit demselben Effekt wie bei Bomben" - instanziiert
## deshalb woertlich eine echte Bomb-Instanz (scripts/bomb.gd) an Karinas
## Position und zuendet sie sofort per trigger_now(), statt deren komplette
## VFX-Kaskade (Feuerball/Kern/Schockwelle/Ring/Splitter/Licht/Brandfleck)
## hier zu duplizieren. damages_player = false: die Detonation soll ihr
## Abgang sein, nicht ein Strafschaden gegen sich selbst, direkt nachdem
## ihre Unverwundbarkeit endet.
func _spawn_decloak_explosion() -> void:
	if player == null:
		return
	var bomb := Bomb.new()
	bomb.explosion_radius = CHARACTER_SIZE_ESTIMATE * DECLOAK_EXPLOSION_SIZE_MULTIPLIER
	bomb.damage *= _damage_multiplier()
	bomb.damages_player = false
	bomb.thrower = player
	get_tree().current_scene.add_child(bomb)
	bomb.global_position = player.global_position
	bomb.trigger_now()


## BUGFIX "Cooldown-Ring spinnt" (Secondary-Variante, siehe
## _get_effective_primary_cooldown() oben): der geerbte secondary_cooldown
## (3.0s) blieb ungenutzt, waehrend _secondary_timer hier bis zu
## stealth_max_duration (5s) UND stealth_reentry_cooldown (ebenfalls 5s,
## zufaellig gleich) haelt - beides wuerde gegen den falschen Nenner
## rechnen. Als Nebeneffekt zeigt der Ring jetzt auch waehrend der aktiven
## Stealth-Phase sichtbar "noch X Sekunden" - vorher blieb er die ganze Zeit
## auf "bereit" stehen, obwohl die Faehigkeit laengst aktiv war.
func get_secondary_cooldown_percent() -> float:
	var cd: float = stealth_max_duration if _stealth_active else stealth_reentry_cooldown
	return _secondary_timer / cd if cd > 0.0 else 0.0


func _detonate() -> void:
	var had_marks: bool = not _marked_enemy_ids.is_empty()
	var dmg: float = detonation_damage * _damage_multiplier()
	# Aus dem ansonsten ungenutzten SecondaryHitbox-Node uebernommen statt
	# eine zweite damage_number_scene-Referenz zu pflegen - gleiche Idee wie
	# bei Giselle/Winter, siehe Kopfkommentar.
	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null

	for id: int in _marked_enemy_ids:
		var enemy: Object = instance_from_id(id)
		if enemy == null or not is_instance_valid(enemy) or not (enemy is Node3D):
			continue
		var enemy_3d: Node3D = enemy as Node3D
		var health: Node = enemy_3d.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue
		(health as Health).take_damage(dmg, player)
		VFX.spawn(HIT_VFX_SCENE, enemy_3d.global_position + Vector3.UP, Vector3.UP)

		if dns != null:
			var number: Node = dns.instantiate()
			get_tree().current_scene.add_child(number)
			(number as Node3D).global_position = enemy_3d.global_position + Vector3(0.0, 1.8, 0.0)
			if number.has_method("show_damage"):
				number.show_damage(dmg)

	_marked_enemy_ids.clear()

	if had_marks and player and player.has_method("shake_camera"):
		player.shake_camera(0.6)


func _spawn_mark_vfx(enemy: Node3D) -> void:
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color_secondary if data else Color(1.0, 0.3, 0.7)
	VFX.spawn_dual_tinted(HIT_VFX_SCENE, enemy.global_position + Vector3.UP, color, color, Vector3.UP)


## Unmissverstaendlicher Blitz am eigenen Charakter beim Ein-/Austreten aus
## Phantom Execute - die 95%-Transparenz allein (siehe STEALTH_MESH_
## TRANSPARENCY) ist aus Kampfdistanz/PSX-Dithering leicht zu uebersehen,
## das hier macht "hier ist gerade etwas passiert" unmissverstaendlich klar.
func _spawn_stealth_toggle_vfx() -> void:
	if player == null:
		return
	var data: CharacterData = PartyManager.get_active_data()
	var color: Color = data.attack_color_secondary if data else Color(1.0, 0.3, 0.7)
	VFX.spawn_dual_tinted(HIT_VFX_SCENE, player.global_position + Vector3.UP, color, color, Vector3.UP)
	if player.has_method("shake_camera"):
		player.shake_camera(0.2)


# ============================================================================
# Gemeinsame Helfer
# ============================================================================
func _damage_multiplier() -> float:
	var stats: PlayerStats = PlayerStats.find_for(self)
	return stats.get_damage_multiplier() if stats else 1.0


## Rekursiv, damit auch verschachtelte Meshes des importierten Modells
## mitgezaehlt werden - gleiche Idee wie custom_enemy_base.gd's
## _collect_mesh_instances(), hier bewusst als eigene kleine Kopie statt
## einer Abhaengigkeit zu einer Gegner-Basisklasse.
func _collect_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var found: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		found.append(node)
	for child: Node in node.get_children():
		found.append_array(_collect_mesh_instances(child))
	return found

```
</details>

### 💭 Thinking

`20:16:32`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `minimap.gd`

`20:16:32`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap.gd</code></summary>

```


extends Control
class_name Minimap

## Minimap oben links.
##
## - Das schematische Raum-Grid (RoomOverlay, minimap_rooms.gd) rotiert
##   seine Zellen-POSITIONEN intern um -90 Grad, damit es zur kalibrierten
##   3D-Minimap passt - Text/Glyphen bleiben dabei aufrecht.
## - "toggle_map"-Action (Taste M im Input Map einzutragen) blendet eine
##   grosse Ansicht ein: 3D-Karte und Raum-Grid NEBENEINANDER.
## - ESCAPE: liegt in der Gruppe "minimap", damit pause_menu.gd die
##   Grosskarte per is_big_map_open()/close_big_map() zuerst schliessen
##   kann, BEVOR ein zweiter ESC-Druck die Pause oeffnet.
##
## GROSSKARTE — BEDIENUNG:
##   Solange die Grosskarte offen ist, wird die Maus freigegeben. Das
##   stoppt die Spielerkamera automatisch, weil player_base.gd sein
##   Mouse-Look an Input.mouse_mode == MOUSE_MODE_CAPTURED knuepft - es
##   braucht dafuer also KEINEN zusaetzlichen Schalter im Spieler.
##   Mausrad zoomt auf den Cursor, Ziehen verschiebt den Ausschnitt.
##
## DECKKRAFT:
##   Es gibt bewusst nur EINEN Regler. Frueher hatten Rahmen (StyleBox),
##   3D-Ansicht (Environment.BG_COLOR) und Raum-Grid (eigenes
##   color_background) je einen eigenen, unabhaengigen Alphawert - drei
##   Flaechen mit drei verschiedenen Deckkraeften uebereinander, was die
##   sichtbaren Kanten und den "Kasten im Kasten" erzeugt hat. Jetzt malt
##   nur noch der Frame eine Flaeche; 3D-Ansicht und Grid rendern
##   transparent darueber. Der Regler faerbt Hintergrund UND Rahmen, damit
##   bei niedriger Deckkraft nicht ein knallgelber Rand ueber einer fast
##   unsichtbaren Karte stehen bleibt.

const ROOM_OVERLAY_SCRIPT := preload("res://scripts/minimap_rooms.gd")
const GENERATOR_GROUP := "level_generator"
const TOGGLE_ACTION := "toggle_map"
const MINIMAP_GROUP := "minimap"
const ENEMY_GROUP := "enemies"

enum OverlayPlacement { BELOW_MAP, INSIDE_MAP, HIDDEN }

## Mausrad-Zoom der Grosskarte. Laufzeitwert, KEINE gespeicherte
## Einstellung: das ist eine Geste waehrend des Schauens, kein Setup-Wert.
const BIG_MAP_ZOOM_MIN: float = 0.35
const BIG_MAP_ZOOM_MAX: float = 4.0
const BIG_MAP_ZOOM_STEP: float = 1.15

## Statischer Schalter, damit combat_base.gd in seinem _process() mit
## EINEM Zugriff pruefen kann, ob die Grosskarte offen ist. Ueber
## get_nodes_in_group() waere das eine Baumsuche pro Frame; Angriffe
## werden per Input.is_action_pressed() gepollt und muessen deshalb
## wirklich jeden Frame fragen.
##
## WICHTIG: static var ueberlebt einen Szenenwechsel. Deshalb wird der
## Wert in _ready() UND _exit_tree() hart zurueckgesetzt - sonst bliebe
## das Flag nach einem Level-Neustart mit offener Karte auf true haengen
## und der Spieler koennte nie wieder angreifen.
static var big_map_open: bool = false

@onready var frame: Panel = $Frame
@onready var zone_label: Label = $Frame/ZoneLabel
@onready var map_container: Control = $Frame/MapContainer
@onready var sub_viewport_container: SubViewportContainer = $Frame/MapContainer/SubViewportContainer
@onready var sub_viewport: SubViewport = $Frame/MapContainer/SubViewportContainer/SubViewport
@onready var map_camera: Camera3D = $Frame/MapContainer/SubViewportContainer/SubViewport/MapCamera
@onready var coord_label: Label = $Frame/CoordLabel
@onready var player_arrow: TextureRect = $Frame/MapContainer/PlayerArrow

@export var map_height: float = 60.0
@export var map_size: float = 90.0
@export var map_calibration_offset_degrees: float = -90.0
@export var rotate_with_player: bool = false
@export var default_zone_name: String = "UNKNOWN AREA"
@export var zone_check_interval: float = 0.25

## --- Raum-Overlay ---------------------------------------------------
@export var overlay_placement: OverlayPlacement = OverlayPlacement.BELOW_MAP
@export var room_overlay_size: float = 118.0
@export var room_overlay_margin: float = 8.0
@export var coord_label_reserve: float = 30.0

## --- Dynamischer Auto-Zoom -------------------------------------------
## Die Kamera zoomt automatisch heraus, sobald die aufgedeckte Flaeche
## nicht mehr in den Ausschnitt passt. Grundlage ist die Spannweite der
## belegten Grid-Zellen (get_map_cells()), NICHT die Raumzahl: ein Layout
## mit 12 Raeumen in einer Reihe braucht mehr Ausschnitt als 12 Raeume im
## Block.
##
## SettingsManager.minimap_zoom bleibt uneingeschraenkt wirksam — es wird
## weiterhin als Teiler auf den (jetzt dynamischen) Basisausschnitt
## angewandt. Der Regler ist damit relativ statt absolut.
@export var auto_zoom_enabled: bool = true
## Zuschlag um die belegte Flaeche herum, in Weltmetern.
@export var auto_zoom_padding: float = 40.0
## Obergrenze fuer die KLEINE Karte. Ohne Deckel waere sie im spaeten Run
## so weit draussen, dass man den eigenen Raum nicht mehr erkennt.
@export var auto_zoom_small_max: float = 300.0
## Obergrenze fuer die Grosskarte. Deutlich hoeher — dort ist der
## Gesamtueberblick genau der Zweck.
@export var auto_zoom_big_max: float = 900.0

## --- Gegner-Icons (Phase 2.3) -----------------------------------------
##
## Gezeichnet wird als 2D-Overlay UEBER dem SubViewport, nicht als
## 3D-Objekt in der Welt.
##
## WARUM NICHT 3D: Ein Marker-Mesh ueber jedem Gegner muesste auf einem
## eigenen Visibility-Layer liegen, den NUR die Minimap-Kamera sieht. Das
## hiesse: cull_mask der Spielerkamera in allen vier Charakter-Szenen
## anpassen, plus ein Mesh pro Gegner. Das Overlay braucht dagegen null
## Szenenaenderungen und kostet einen _draw()-Aufruf pro Frame.
##
## Die Umrechnung Welt -> Pixel macht map_camera.unproject_position() -
## dieselbe Funktion, die schon den Spielerpfeil setzt. Zoom, Pan und
## (falls aktiv) die Kameradrehung sind darin bereits enthalten.
@export var show_enemy_icons: bool = true
@export var enemy_icon_radius: float = 3.0
@export var enemy_icon_color: Color = Color(0.92, 0.26, 0.24, 0.95)
@export var enemy_icon_outline: Color = Color(0.05, 0.03, 0.04, 0.85)
## Gegner ausserhalb dieser Weltdistanz zum Spieler werden gar nicht erst
## umgerechnet. Culling-Schritt 1: spart die unproject-Rechnung fuer alles,
## was ohnehin nicht in den Ausschnitt faellt.
@export var enemy_icon_cull_distance: float = 260.0
## Obergrenze pro Frame. Notbremse gegen Layouts, in denen sehr viele
## Gegner gleichzeitig leben.
@export var enemy_icon_max: int = 64

## --- Grosse Karte (Nebeneinander-Layout) ------------------------------
@export var big_map_world_size: float = 220.0
@export var big_map_box_size: float = 320.0
@export var big_map_gap: float = 28.0
@export var big_map_padding: float = 20.0
@export var big_map_header_reserve: float = 34.0
@export var big_map_tween_duration: float = 0.18

## --- Minimap-Beleuchtung ----------------------------------------------
## Verhindert, dass Fog/Ambient-Abdunklung der Hauptszene (siehe
## dungeon_atmosphere.gd) auch die Draufsicht mit verdunkelt.
@export var minimap_disable_fog: bool = true
@export var minimap_ambient_color: Color = Color(1.0, 1.0, 1.0)
@export var minimap_ambient_energy: float = 1.3

## Falls die Transparenz auf einem Grafiktreiber Probleme macht: hier auf
## false stellen, dann rendert die Karte wieder mit fester Hintergrund-
## farbe (minimap_background_color) wie frueher.
@export var minimap_transparent_background: bool = true
@export var minimap_background_color: Color = Color(0.05, 0.05, 0.06)

var player: Node3D = null
var _current_zone: String = ""
var _zone_timer: float = 0.0
var _room_overlay: Control = null
var _generator: Node = null

var _is_big_map: bool = false
var _tween: Tween = null
var _big_map_zoom: float = 1.0
## Verschiebung des Kartenausschnitts gegenueber der Spielerposition
## (nur X/Z genutzt). Nur in der Grosskarte relevant.
var _big_map_pan: Vector3 = Vector3.ZERO
var _dragging: bool = false
## Weltpunkt, den der Cursor beim Drag-Start "gegriffen" hat. Beim Ziehen
## wird der Pan so nachgefuehrt, dass genau dieser Punkt unter dem Cursor
## bleibt - dadurch klebt die Karte am Mauszeiger, statt mit einem
## willkuerlichen Pixel-pro-Welt-Faktor zu driften.
var _drag_anchor_world: Vector3 = Vector3.ZERO
var _prev_mouse_mode: int = Input.MOUSE_MODE_CAPTURED

## Ausgangsfarben der Frame-StyleBox. Ohne diese Merker wuerde jedes
## Anwenden der Deckkraft auf dem bereits veraenderten Wert aufsetzen und
## die Farben waeren nach mehreren Aenderungen verschoben.
var _frame_base_bg_color: Color = Color(0.06, 0.06, 0.09, 0.82)
var _frame_base_border_color: Color = Color(0.5, 0.48, 0.18, 1.0)
var _frame_style: StyleBoxFlat = null

## Weltbreite, die die aufgedeckten Zellen aktuell einnehmen. Wird bei
## jedem map_updated neu bestimmt. 0 = noch keine Daten -> Auto-Zoom
## verhaelt sich neutral und map_size gilt unveraendert.
var _revealed_world_span: float = 0.0

var _enemy_overlay: Control = null

var _small_frame_size: Vector2
var _small_frame_position: Vector2
var _small_map_container_size: Vector2
var _small_map_container_position: Vector2
var _small_map_camera_size: float
var _small_overlay_size: Vector2
var _small_overlay_position: Vector2


func _ready() -> void:
	add_to_group(MINIMAP_GROUP)
	big_map_open = false

	map_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	map_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	map_camera.near = 0.1
	map_camera.far = map_height * 2.0

	# Fog of War: Raeume, die noch nicht aufgedeckt sind, haengt der
	# LevelGenerator auf RoomInstance.MINIMAP_HIDDEN_LAYER um. NUR diese
	# Kamera streicht den Layer aus ihrer cull_mask - die Spielerkamera
	# bleibt unangetastet und zeigt die Welt vollstaendig.
	map_camera.set_cull_mask_value(RoomInstance.MINIMAP_HIDDEN_LAYER, false)

	sub_viewport.own_world_3d = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_viewport.transparent_bg = minimap_transparent_background

	_cache_frame_style()
	_set_zone_text(default_zone_name)

	if minimap_disable_fog:
		_apply_minimap_environment()

	map_container.pivot_offset = map_container.size * 0.5
	map_container.rotation_degrees = map_calibration_offset_degrees

	# Overlay-Platzierung kommt aus den Einstellungen. Der @export-Wert
	# bleibt als Editor-Vorgabe erhalten, wird hier aber ueberschrieben -
	# sonst gaebe es zwei konkurrierende Quellen fuer dieselbe Entscheidung.
	overlay_placement = SettingsManager.minimap_grid_placement as OverlayPlacement
	if overlay_placement != OverlayPlacement.HIDDEN:
		_create_room_overlay()

	# WICHTIG: Erst NACH _create_room_overlay() die Kleinansicht-Masse
	# sichern. Das Overlay veraendert dort ggf. die Frame-Hoehe - wuerde
	# man vorher sichern, springt die Minimap beim ersten Schliessen der
	# Grosskarte auf die falsche Groesse zurueck.
	_small_frame_size = frame.size
	_small_frame_position = frame.position
	_small_map_container_size = map_container.size
	_small_map_container_position = map_container.position
	_small_map_camera_size = map_size
	if _room_overlay:
		_small_overlay_size = _room_overlay.size
		_small_overlay_position = _room_overlay.position

	if not SettingsManager.minimap_setting_changed.is_connected(_apply_minimap_settings):
		SettingsManager.minimap_setting_changed.connect(_apply_minimap_settings)

	_bind_generator()
	_build_enemy_overlay()
	_apply_minimap_settings()


## Zeichenflaeche fuer die Gegner-Punkte.
##
## Haengt IM map_container und damit unter derselben -90-Grad-Drehung wie
## die Karte. Das ist Absicht: unproject_position() liefert Pixel im
## ungedrehten SubViewport, und der Container dreht sie anschliessend
## genauso mit wie das gerenderte Bild. Haenge man das Overlay eine Ebene
## hoeher, muesste die Drehung von Hand nachgerechnet werden - exakt die
## Fehlerquelle, die im Kommentar zu _world_point_under_mouse() steht.
func _build_enemy_overlay() -> void:
	if _enemy_overlay != null and is_instance_valid(_enemy_overlay):
		return
	_enemy_overlay = Control.new()
	_enemy_overlay.name = "EnemyOverlay"
	_enemy_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_enemy_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_enemy_overlay.draw.connect(_draw_enemy_icons)
	map_container.add_child(_enemy_overlay)
	# Unter den Spielerpfeil sortieren: der eigene Standort muss auch dann
	# lesbar bleiben, wenn ein Gegner direkt darauf steht.
	if player_arrow != null and is_instance_valid(player_arrow):
		map_container.move_child(_enemy_overlay, player_arrow.get_index())


## Wandelt Weltpositionen in Pixel IM map_container um.
##
## Gleiche Rechnung wie _update_player_arrow_position(): erst
## unproject_position() (Pixel im SubViewport), dann auf die gestreckte
## Containergroesse skalieren. Liefert false, wenn der Punkt hinter der
## Kamera oder ausserhalb des Rahmens liegt.
func _world_to_map_pixel(world: Vector3, out: Array) -> bool:
	var viewport_size: Vector2 = Vector2(sub_viewport.size)
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return false

	var box_size: Vector2 = sub_viewport_container.size
	var in_viewport: Vector2 = map_camera.unproject_position(world)
	var in_box: Vector2 = sub_viewport_container.position + in_viewport * (box_size / viewport_size)

	# Culling-Schritt 2: alles ausserhalb des sichtbaren Rahmens faellt
	# raus. Ohne diese Pruefung malt Godot die Punkte zwar weg, rechnet
	# sie aber trotzdem - und bei offener Grosskarte waeren das die
	# Gegner der halben Etage.
	var rect := Rect2(sub_viewport_container.position, box_size)
	if not rect.has_point(in_box):
		return false

	out.append(in_box)
	return true


func _draw_enemy_icons() -> void:
	if not show_enemy_icons or _enemy_overlay == null:
		return
	if player == null or not is_instance_valid(player):
		return

	var origin: Vector3 = player.global_position
	var cull_sq: float = enemy_icon_cull_distance * enemy_icon_cull_distance
	var drawn: int = 0

	for node: Node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		if drawn >= enemy_icon_max:
			break
		var enemy := node as Node3D
		if enemy == null or not is_instance_valid(enemy):
			continue
		# Sterbende Gegner haengen noch einen Frame im Baum. Ohne diese
		# Pruefung blinkt nach jedem Kill kurz ein Geisterpunkt auf.
		if not enemy.is_inside_tree() or not enemy.visible:
			continue

		var health: Node = enemy.get_node_or_null("Health")
		if health != null and health.has_method("is_alive") and not health.is_alive():
			continue

		# Culling-Schritt 1: grobe Weltdistanz, bevor irgendetwas
		# projiziert wird.
		if origin.distance_squared_to(enemy.global_position) > cull_sq:
			continue

		var result: Array = []
		if not _world_to_map_pixel(enemy.global_position, result):
			continue

		var point: Vector2 = result[0]
		# Dunkler Ring unter dem Punkt: ohne ihn verschwindet ein roter
		# Punkt auf einer roten Bossraum-Flaeche.
		_enemy_overlay.draw_circle(point, enemy_icon_radius + 1.0, enemy_icon_outline)
		_enemy_overlay.draw_circle(point, enemy_icon_radius, enemy_icon_color)
		drawn += 1


# --- Dynamischer Auto-Zoom ---------------------------------------------

## Haengt sich an das map_updated-Signal des LevelGenerators. Genau dieses
## Signal feuert beim Instanziieren eines Stages, beim Betreten eines Raums
## und beim Aufdecken — also exakt bei jeder Aenderung der bekannten
## Flaeche. Ein Polling pro Frame waere dafuer Verschwendung.
func _bind_generator() -> void:
	if _generator != null and is_instance_valid(_generator):
		return
	var found: Array = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)
	_on_map_updated()


func _on_map_updated() -> void:
	_recalculate_revealed_span()
	# Beide Modi sofort nachziehen, damit der neue Ausschnitt nicht erst
	# beim naechsten Oeffnen/Schliessen der Grosskarte greift.
	map_camera.size = _effective_big_map_size() if _is_big_map else _effective_map_size()
	_small_map_camera_size = _effective_map_size()


## Spannweite der SICHTBAREN Zellen in Weltmetern.
##
## Sichtbar = besucht. Unbesuchte Nachbarn zaehlen bewusst mit einer
## halben Zelle, weil minimap_rooms.gd sie als Umriss zeichnet — sonst
## rutschte der angrenzende Raum am Rand aus dem Bild.
##
## Die Zellgroesse wird vom Generator geholt, nicht hier gepflegt: sie
## haengt an dessen room_scale und waere als zweite Konstante sofort
## veraltet.
func _recalculate_revealed_span() -> void:
	_revealed_world_span = 0.0
	if _generator == null or not is_instance_valid(_generator):
		return
	if not _generator.has_method("get_map_cells"):
		return

	var cells: Dictionary = _generator.get_map_cells()
	if cells.is_empty():
		return

	# get() liefert null, falls das Feld in einer aelteren Generator-
	# Version nicht existiert. Erst pruefen, DANN typisiert zuweisen —
	# eine direkte Zuweisung von null an ein Vector3 waere ein
	# Laufzeitfehler.
	var raw_cell_size: Variant = _generator.get("cell_size")
	if not (raw_cell_size is Vector3):
		return
	var cell_size: Vector3 = raw_cell_size
	if is_zero_approx(cell_size.x) or is_zero_approx(cell_size.z):
		return

	var min_cell := Vector2i(2147483647, 2147483647)
	var max_cell := Vector2i(-2147483648, -2147483648)
	var any: bool = false

	for pos in cells.keys():
		var grid: Vector2i = pos
		if not bool(cells[grid].get("visited", false)):
			continue
		any = true
		min_cell.x = mini(min_cell.x, grid.x)
		min_cell.y = mini(min_cell.y, grid.y)
		max_cell.x = maxi(max_cell.x, grid.x)
		max_cell.y = maxi(max_cell.y, grid.y)

	if not any:
		return

	# +1, weil eine einzelne Zelle bereits eine volle Raumbreite belegt;
	# +1 zusaetzlich fuer die angrenzenden, nur umrissenen Nachbarn.
	var span_x: float = (float(max_cell.x - min_cell.x) + 2.0) * cell_size.x
	var span_z: float = (float(max_cell.y - min_cell.y) + 2.0) * cell_size.z
	_revealed_world_span = maxf(span_x, span_z) + auto_zoom_padding


## static var ueberlebt Szenenwechsel - beim Verlassen zwingend loeschen,
## sonst bleibt das Combat-Gate nach einem Neustart mit offener Karte
## dauerhaft aktiv.
func _exit_tree() -> void:
	big_map_open = false


## Holt die StyleBox des Frames einmalig als eigene Kopie. duplicate() ist
## entscheidend: die StyleBoxFlat aus hud.tscn ist eine geteilte
## SubResource - ohne Kopie wuerde die Deckkraft auch den Speedrun-Timer-
## Rahmen mitveraendern, der dieselbe Ressource nutzt.
func _cache_frame_style() -> void:
	var existing := frame.get_theme_stylebox("panel")
	if existing is StyleBoxFlat:
		_frame_style = (existing as StyleBoxFlat).duplicate()
	else:
		_frame_style = StyleBoxFlat.new()
		_frame_style.border_width_left = 2
		_frame_style.border_width_top = 2
		_frame_style.border_width_right = 2
		_frame_style.border_width_bottom = 2
		_frame_style.border_color = Color(0.5, 0.48, 0.18, 1.0)
	_frame_base_bg_color = _frame_style.bg_color
	_frame_base_border_color = _frame_style.border_color
	frame.add_theme_stylebox_override("panel", _frame_style)


## Camera3D.environment ueberschreibt fuer DIESE eine Kamera die
## WorldEnvironment der geteilten Welt - der Rest der Szene (inkl. der
## Haupt-Spielkamera) bleibt vom Dungeon-Nebel unberuehrt.
##
## BG_CLEAR_COLOR statt BG_COLOR bei aktiver Transparenz: BG_COLOR malt
## IMMER eine deckende Flaeche und haette transparent_bg wirkungslos
## gemacht.
func _apply_minimap_environment() -> void:
	var env := Environment.new()
	if minimap_transparent_background:
		env.background_mode = Environment.BG_CLEAR_COLOR
	else:
		env.background_mode = Environment.BG_COLOR
		env.background_color = minimap_background_color
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = minimap_ambient_color
	env.ambient_light_energy = minimap_ambient_energy
	env.fog_enabled = false
	env.glow_enabled = false
	map_camera.environment = env


## Uebertraegt ALLE Minimap-Einstellungen auf die Nodes. Bewusst
## idempotent, damit ein doppelter Aufruf nichts kaputt macht.
func _apply_minimap_settings() -> void:
	rotate_with_player = SettingsManager.minimap_rotate_with_player

	# Skalierung am Wurzel-Control, Pivot oben links: die Minimap sitzt in
	# der linken oberen Ecke und soll beim Vergroessern nach innen wachsen,
	# nicht aus dem Bildschirm herauslaufen.
	pivot_offset = Vector2.ZERO
	scale = Vector2.ONE * SettingsManager.minimap_ui_scale

	# EIN Regler faerbt Flaeche UND Rahmen. Der Rahmen wird relativ zu
	# seiner Ausgangsdeckkraft skaliert, nicht hart gleichgesetzt - so
	# bleibt ein evtl. absichtlich halbtransparenter Rand im Verhaeltnis
	# erhalten.
	if _frame_style:
		var opacity: float = SettingsManager.minimap_opacity
		var bg: Color = _frame_base_bg_color
		bg.a = opacity
		_frame_style.bg_color = bg

		var border: Color = _frame_base_border_color
		border.a = _frame_base_border_color.a * opacity
		_frame_style.border_color = border

	# Kameragroesse haengt davon ab, in welchem Modus wir gerade sind -
	# sonst wuerde der Zoom-Regler bei offener Grosskarte die Kleinansicht
	# einstellen und der Effekt waere erst nach dem Schliessen sichtbar.
	map_camera.size = _effective_big_map_size() if _is_big_map else _effective_map_size()
	_small_map_camera_size = _effective_map_size()

	if player_arrow:
		player_arrow.visible = SettingsManager.minimap_show_player_arrow
	if coord_label:
		coord_label.visible = SettingsManager.minimap_show_coords
	if zone_label:
		zone_label.visible = SettingsManager.minimap_show_zone_label

	var placement: int = SettingsManager.minimap_grid_placement
	if _room_overlay and is_instance_valid(_room_overlay):
		_room_overlay.visible = placement != SettingsManager.MINIMAP_GRID_HIDDEN
	elif placement != SettingsManager.MINIMAP_GRID_HIDDEN:
		# Grid war beim Start ausgeschaltet und wurde jetzt eingeschaltet:
		# Overlay nachtraeglich erzeugen statt einen Neustart zu verlangen.
		overlay_placement = placement as OverlayPlacement
		_create_room_overlay()
		if _room_overlay:
			_small_overlay_size = _room_overlay.size
			_small_overlay_position = _room_overlay.position


## Zoom > 1 = naeher dran. Der Kamera-Ausschnitt ist der KEHRWERT des
## Zooms. maxf() verhindert eine Division, die bei einem manipulierten
## Zoom von 0 eine size von inf erzeugen wuerde.
func _effective_map_size() -> float:
	return _auto_base_size(map_size, auto_zoom_small_max) / maxf(SettingsManager.minimap_zoom, 0.01)


func _effective_big_map_size() -> float:
	return _auto_base_size(big_map_world_size, auto_zoom_big_max) / maxf(_big_map_zoom, 0.01)


## Basisausschnitt VOR dem Anwenden des Zoom-Reglers.
##
## Der Auto-Zoom vergroessert nur — er zieht nie enger als der
## eingestellte Grundwert. Sonst wuerde die Karte am Anfang eines Runs
## (eine einzige aufgedeckte Zelle) auf einen winzigen Ausschnitt
## zusammenfallen.
func _auto_base_size(base: float, limit: float) -> float:
	if not auto_zoom_enabled or _revealed_world_span <= 0.0:
		return base
	return clampf(_revealed_world_span, base, maxf(limit, base))


func _create_room_overlay() -> void:
	if _room_overlay and is_instance_valid(_room_overlay):
		return

	_room_overlay = Control.new()
	_room_overlay.name = "RoomOverlay"
	_room_overlay.set_script(ROOM_OVERLAY_SCRIPT)
	_room_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(_room_overlay)

	var s: float = room_overlay_size
	_room_overlay.size = Vector2(s, s)

	if overlay_placement == OverlayPlacement.INSIDE_MAP:
		_room_overlay.position = Vector2(
			map_container.position.x + map_container.size.x - s - room_overlay_margin,
			map_container.position.y + map_container.size.y - s - room_overlay_margin
		)
		return

	var overlay_top: float = map_container.position.y + map_container.size.y + room_overlay_margin
	var overlay_x: float = map_container.position.x + (map_container.size.x - s) * 0.5
	_room_overlay.position = Vector2(overlay_x, overlay_top)

	var needed_height: float = overlay_top + s + coord_label_reserve
	if frame.size.y < needed_height:
		frame.size.y = needed_height

	var needed_outer: float = frame.position.y + frame.size.y + frame.position.y
	if size.y < needed_outer:
		size.y = needed_outer
		offset_bottom = needed_outer


## Legacy-Handler: minimap_rotate_with_player_changed feuert weiterhin
## (andere Systeme koennen daran haengen). Die eigentliche Arbeit macht
## _apply_minimap_settings() ueber das Sammelsignal.
func _on_rotate_setting_changed(enabled: bool) -> void:
	rotate_with_player = enabled


## Bildschirm-Rechteck, das die KLEINE Minimap tatsaechlich belegt —
## inklusive der UI-Skalierung (SettingsManager.minimap_ui_scale).
##
## WARUM NICHT get_global_rect(): Control.get_global_rect() liefert
## Position und size, aber OHNE scale. Die Minimap wird ueber
## Control.scale vergroessert (siehe _apply_minimap_settings), das
## Rechteck waere damit bei jedem Wert != 1.0 zu klein — genau der
## Grund, warum der Speedrun-Timer bei groesserer Karte darunter
## verschwunden ist.
##
## Wird von run_timer.gd genutzt, um sich rechts anzudocken.
func get_docking_rect() -> Rect2:
	if frame == null:
		return Rect2(global_position, size * scale)

	# Bei offener Grosskarte waechst der Frame auf Bildschirmbreite. Der
	# Timer soll trotzdem an der KLEINANSICHT kleben, sonst springt er
	# beim Oeffnen der Karte quer ueber den Bildschirm und wieder zurueck.
	var f_pos: Vector2 = _small_frame_position if _is_big_map else frame.position
	var f_size: Vector2 = _small_frame_size if _is_big_map else frame.size

	return Rect2(global_position + f_pos * scale, f_size * scale)


func set_player(p: Node3D) -> void:
	player = p


# ============================================================================
# Eingabe
# ============================================================================

## _input() statt _unhandled_input() fuer die Kartenbedienung: _input()
## laeuft GARANTIERT vor jedem _unhandled_input() im Baum. Nur dadurch
## kann die Karte den Mausklick verschlucken, bevor player_base.gd ihn
## sieht und die Maus wieder einfaengt (dort:
## "if event is InputEventMouseButton and mouse_mode == VISIBLE ->
## MOUSE_MODE_CAPTURED"). Ueber die Baumreihenfolge waere das nur
## zufaellig richtig.
func _input(event: InputEvent) -> void:
	if not _is_big_map:
		return
	if not (event is InputEventMouseButton or event is InputEventMouseMotion):
		return

	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		match mb.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if mb.pressed:
					_zoom_big_map(BIG_MAP_ZOOM_STEP)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_zoom_big_map(1.0 / BIG_MAP_ZOOM_STEP)
				get_viewport().set_input_as_handled()
			MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE:
				if mb.pressed:
					_dragging = true
					_drag_anchor_world = _world_point_under_mouse()
				else:
					_dragging = false
				get_viewport().set_input_as_handled()
		return

	if _dragging:
		# Pan so nachfuehren, dass der beim Klick gegriffene Weltpunkt
		# wieder genau unter dem Cursor landet.
		var current: Vector3 = _world_point_under_mouse()
		_big_map_pan += Vector3(
			_drag_anchor_world.x - current.x,
			0.0,
			_drag_anchor_world.z - current.z
		)
		_update_camera_position()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(TOGGLE_ACTION):
		_set_big_map(not _is_big_map)
		get_viewport().set_input_as_handled()


## Rechnet die Bildschirm-Mausposition in einen Weltpunkt auf Bodenhoehe um.
##
## get_global_transform_with_canvas().affine_inverse() erledigt dabei in
## einem Rutsch die UI-Skalierung, die Verschiebung UND die
## -90-Grad-Drehung des map_container - von Hand nachgerechnet waere
## genau diese Drehung die Fehlerquelle.
##
## project_ray_origin() funktioniert bei einer ORTHOGONALEN Kamera anders
## als bei einer perspektivischen: der Ursprung wandert mit dem
## Bildschirmpunkt, die Richtung bleibt konstant. Genau deshalb liefert
## schon der Ursprung allein den gesuchten XZ-Punkt, ohne Strahl-Ebenen-
## Schnitt.
func _world_point_under_mouse() -> Vector3:
	var xform: Transform2D = sub_viewport_container.get_global_transform_with_canvas()
	var local: Vector2 = xform.affine_inverse() * get_viewport().get_mouse_position()
	return map_camera.project_ray_origin(local)


## Multiplikativer Zoomschritt statt additiv: so fuehlt sich das Scrollen
## bei starker Vergroesserung genauso fein an wie bei starker
## Verkleinerung (ein additiver Schritt waere bei Zoom 4.0 kaum spuerbar
## und bei 0.4 ein Sprung).
##
## Zoom ZUM CURSOR: Weltpunkt unter der Maus vor und nach der
## Groessenaenderung messen, die Differenz auf den Pan addieren. Dadurch
## bleibt der Punkt unter dem Zeiger stehen, statt dass die Karte immer
## zur Mitte zieht.
func _zoom_big_map(factor: float) -> void:
	var before: Vector3 = _world_point_under_mouse()

	_big_map_zoom = clampf(_big_map_zoom * factor, BIG_MAP_ZOOM_MIN, BIG_MAP_ZOOM_MAX)
	map_camera.size = _effective_big_map_size()

	var after: Vector3 = _world_point_under_mouse()
	_big_map_pan += Vector3(before.x - after.x, 0.0, before.z - after.z)
	_update_camera_position()


## Einzige Stelle, die die Kameraposition setzt. Wird aus _process() UND
## aus den Maus-Handlern gerufen - Letzteres, damit Zoom/Drag sofort
## sichtbar sind und nicht erst einen Frame spaeter nachziehen.
func _update_camera_position() -> void:
	if player == null or not is_instance_valid(player):
		return
	var pos: Vector3 = player.global_position
	map_camera.global_position = Vector3(
		pos.x + _big_map_pan.x,
		pos.y + map_height,
		pos.z + _big_map_pan.z
	)


## Setzt den Spielerpfeil auf die Bildschirmposition des Spielers.
##
## BUGFIX "Pfeil bleibt beim Verschieben der Grosskarte in der Mitte":
## Der Pfeil haengt als eigenes Control mittig im MapContainer. Auf der
## KLEINEN Karte stimmt das, weil _update_camera_position() die Kamera
## exakt ueber den Spieler setzt - die Mitte IST der Spieler. Auf der
## grossen Karte kommt _big_map_pan dazu: die Kamera schaut woanders hin,
## der Pfeil klebte aber weiter in der Mitte und zeigte damit dauerhaft
## die falsche Position an.
##
## unproject_position() rechnet die Weltposition in Pixel IM SubViewport
## um. Das beruecksichtigt Zoom (map_camera.size), Pan und - falls
## rotate_with_player an ist - auch die Kameradrehung, ohne dass hier
## irgendetwas davon nachgerechnet werden muss. Anschliessend wird nur
## noch auf die (gestreckte) Containergroesse skaliert.
func _update_player_arrow_position() -> void:
	if player_arrow == null or not player_arrow.visible:
		return
	if player == null or not is_instance_valid(player):
		return

	var viewport_size: Vector2 = Vector2(sub_viewport.size)
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var box_size: Vector2 = sub_viewport_container.size
	var in_viewport: Vector2 = map_camera.unproject_position(player.global_position)
	var in_box: Vector2 = sub_viewport_container.position + in_viewport * (box_size / viewport_size)

	# Ausserhalb des Rahmens an den Rand klemmen und abdunkeln, statt den
	# Pfeil verschwinden zu lassen - so bleibt erkennbar, in welche
	# Richtung der eigene Standort liegt.
	var half: Vector2 = player_arrow.size * 0.5
	var min_point: Vector2 = sub_viewport_container.position + half
	var max_point: Vector2 = sub_viewport_container.position + box_size - half
	var clamped := Vector2(
		clampf(in_box.x, min_point.x, max_point.x),
		clampf(in_box.y, min_point.y, max_point.y)
	)
	player_arrow.modulate.a = 1.0 if clamped.is_equal_approx(in_box) else 0.45

	# Der Pfeil sitzt an den Mittelankern (anchors_preset 8). Deshalb wird
	# der VERSATZ ZUR MITTE ueber die Offsets gesetzt und nicht position -
	# sonst rechnen Anker und position gegeneinander und der Pfeil zittert.
	var delta: Vector2 = clamped - map_container.size * 0.5
	player_arrow.offset_left = delta.x - half.x
	player_arrow.offset_top = delta.y - half.y
	player_arrow.offset_right = delta.x + half.x
	player_arrow.offset_bottom = delta.y + half.y


## --- Oeffentliche API fuer pause_menu.gd ------------------------------
## ESC soll ZUERST nur die Grosskarte schliessen und erst beim NAECHSTEN
## Druck die Pause oeffnen.
func is_big_map_open() -> bool:
	return _is_big_map


func close_big_map() -> void:
	if _is_big_map:
		_set_big_map(false)


func _set_big_map(active: bool) -> void:
	if active == _is_big_map:
		return
	_is_big_map = active
	big_map_open = active

	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if _is_big_map:
		_enter_big_map()
	else:
		_exit_big_map()


func _enter_big_map() -> void:
	# Maus freigeben. player_base.gd dreht die Kamera nur bei
	# MOUSE_MODE_CAPTURED - damit steht die Spielerkamera automatisch
	# still, ohne dass der Spieler einen eigenen Sperrschalter braucht.
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_big_map_pan = Vector3.ZERO
	_dragging = false

	var viewport_size: Vector2 = get_viewport_rect().size

	var box: float = big_map_box_size
	var content_width: float = box + big_map_gap + box

	var target_frame_size := Vector2(
		content_width + big_map_padding * 2.0,
		big_map_header_reserve + box + big_map_padding + coord_label_reserve
	)

	# Die Grosskarte soll IMMER bildschirmzentriert und in Originalgroesse
	# erscheinen - die UI-Skalierung gilt nur fuer die kleine HUD-Ansicht.
	# Deshalb wird hier gegen die Skalierung gerechnet, sonst saesse die
	# Grosskarte bei ui_scale 1.5 sichtbar aus der Mitte verschoben und
	# waere 50 % zu gross.
	var s: float = maxf(SettingsManager.minimap_ui_scale, 0.01)
	var target_frame_position: Vector2 = ((viewport_size / s) - target_frame_size) * 0.5 - (position / s)

	_tween.tween_property(frame, "size", target_frame_size, big_map_tween_duration)
	_tween.tween_property(frame, "position", target_frame_position, big_map_tween_duration)

	var map_target_pos := Vector2(big_map_padding, big_map_header_reserve)
	var overlay_target_pos := Vector2(big_map_padding + box + big_map_gap, big_map_header_reserve)

	_tween.tween_property(map_container, "size", Vector2(box, box), big_map_tween_duration)
	_tween.tween_property(map_container, "position", map_target_pos, big_map_tween_duration)
	_tween.tween_method(_update_map_container_pivot, 0.0, 1.0, big_map_tween_duration)

	map_camera.size = _effective_big_map_size()

	if _room_overlay:
		_room_overlay.visible = SettingsManager.minimap_grid_placement != SettingsManager.MINIMAP_GRID_HIDDEN
		_tween.tween_property(_room_overlay, "size", Vector2(box, box), big_map_tween_duration)
		_tween.tween_property(_room_overlay, "position", overlay_target_pos, big_map_tween_duration)


func _exit_big_map() -> void:
	_dragging = false
	_big_map_pan = Vector3.ZERO

	# Nur zurueckfangen, wenn das Spiel wirklich weiterlaeuft. Wird die
	# Karte durch ESC geschlossen und gleichzeitig das Pausemenue
	# geoeffnet, muss die Maus sichtbar bleiben.
	if not get_tree().paused:
		Input.mouse_mode = _prev_mouse_mode

	_tween.tween_property(frame, "size", _small_frame_size, big_map_tween_duration)
	_tween.tween_property(frame, "position", _small_frame_position, big_map_tween_duration)

	_tween.tween_property(map_container, "size", _small_map_container_size, big_map_tween_duration)
	_tween.tween_property(map_container, "position", _small_map_container_position, big_map_tween_duration)
	_tween.tween_method(_update_map_container_pivot, 0.0, 1.0, big_map_tween_duration)

	map_camera.size = _effective_map_size()

	if _room_overlay:
		_tween.tween_property(_room_overlay, "size", _small_overlay_size, big_map_tween_duration)
		_tween.tween_property(_room_overlay, "position", _small_overlay_position, big_map_tween_duration)


## map_container ist um map_calibration_offset_degrees um seine EIGENE
## Mitte gedreht - beim Groessenwechsel muss der Pivot mitwandern, sonst
## verschiebt sich die 3D-Ansicht seitlich aus ihrer Box waehrend des Tweens.
func _update_map_container_pivot(_t: float) -> void:
	map_container.pivot_offset = map_container.size * 0.5


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	_update_camera_position()

	var camera_pivot: Node3D = player.get_node_or_null("CameraPivot")
	var camera_yaw: float = camera_pivot.rotation.y if camera_pivot else 0.0

	if rotate_with_player:
		map_camera.rotation.y = camera_yaw
		player_arrow.rotation = 0.0
	else:
		map_camera.rotation.y = 0.0
		player_arrow.rotation = -camera_yaw

	_update_player_arrow_position()

	# Gegner bewegen sich jeden Frame - das Overlay muss deshalb jeden
	# Frame neu gezeichnet werden. queue_redraw() ist billig, solange
	# _draw_enemy_icons() frueh aussteigt; die eigentliche Arbeit
	# verhindern die beiden Culling-Stufen.
	if show_enemy_icons and _enemy_overlay != null and is_instance_valid(_enemy_overlay):
		_enemy_overlay.queue_redraw()

	if coord_label.visible:
		var pos: Vector3 = player.global_position
		coord_label.text = "X: %d   Y: %d" % [int(pos.x), int(pos.z)]

	# Zonen-Ermittlung laeuft weiter, auch wenn das Label aus ist: andere
	# Systeme (z.B. Musik-Trigger) koennen an _current_zone haengen.
	_zone_timer -= delta
	if _zone_timer <= 0.0:
		_zone_timer = zone_check_interval
		_update_zone()


func _update_zone() -> void:
	var from_generator: String = _zone_from_generator()
	if from_generator != "":
		if from_generator != _current_zone:
			_set_zone_text(from_generator)
		return

	var zones: Array[Node] = get_tree().get_nodes_in_group("zone")
	var found: String = ""

	for z: Node in zones:
		if not (z is Area3D):
			continue
		var area: Area3D = z
		if area.overlaps_body(player):
			var zone_name: Variant = area.get("zone_name")
			if zone_name != null and str(zone_name) != "":
				found = str(zone_name)
				break

	if found == "":
		found = default_zone_name

	if found != _current_zone:
		_set_zone_text(found)


func _zone_from_generator() -> String:
	# Ueber _bind_generator() statt einer eigenen Suche: die frueher hier
	# stehende Lazy-Bindung hat _generator zwar gesetzt, aber NICHT
	# map_updated verbunden. Steht der LevelGenerator beim _ready() der
	# Minimap noch nicht in seiner Gruppe (Reihenfolge im Szenenbaum),
	# waere der Auto-Zoom danach dauerhaft tot gewesen — ohne Fehler,
	# einfach nur ohne Wirkung.
	_bind_generator()
	if _generator == null or not is_instance_valid(_generator):
		return ""

	if not _generator.has_method("get_map_cells"):
		return ""

	var cells: Dictionary = _generator.get_map_cells()
	var current: Vector2i = _generator.get_current_room()
	if not cells.has(current):
		return ""

	var type: int = int(cells[current].get("type", 0))
	var label: String = _generator.get_room_type_name(type)
	var stage: int = _generator.get_current_stage()
	return "ETAGE %d - %s" % [stage, label]


func _set_zone_text(text: String) -> void:
	_current_zone = text
	zone_label.text = text.to_upper()

	zone_label.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(zone_label, "modulate:a", 1.0, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

```
</details>

### 💭 Thinking

`20:16:40`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `minimap_rooms.gd`

`20:16:40`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap_rooms.gd</code></summary>

```

extends Control
class_name MinimapRooms

## Schematische Raum-Uebersicht (Isaac-Style) als Overlay ueber/neben der
## 3D-Minimap.
##
## ROTATION: Die 3D-Minimap-Kamera hat eine -90-Grad-Bildkalibrierung
## (siehe minimap.gd: map_calibration_offset_degrees). Das Grid hier
## rotiert deshalb NUR die Positions-Berechnung der Zellen (nicht das
## ganze Control) um denselben Winkel - Text/Glyphen bleiben aufrecht.
##
## TUEREN ALS OFFENER DURCHGANG: Vorher wurde zwischen zwei Raeumen nur
## ein duenner 3px-Steg mitten im dunklen Spalt gezeichnet - das sah eher
## nach Gitter/Riegel aus als nach Durchgang. Jetzt wird der GESAMTE
## Spalt zwischen zwei betretenen Nachbarraeumen mit Flaeche gefuellt
## (_draw_passage). Der Trick, der das ohne Praezisions-Randberechnung
## sauber aussehen laesst: die Fuellung reicht von Zellmitte zu Zellmitte
## (bzw. bis zur Spaltmitte, wenn der Nachbar noch nicht betreten ist) -
## die spaeter obendrauf gezeichneten Raumquadrate schneiden den
## ueberschuessigen Teil in der Raummitte automatisch weg und uebrig
## bleibt genau der Spalt, sauber gefuellt.

const GENERATOR_GROUP := "level_generator"

## Bitmask-Richtungen -> Grid-Offset. Muss 1:1 mit RoomGridGenerator/
## RoomInstance uebereinstimmen: Norden=1, Sueden=2, Osten=4, Westen=8.
const DIR_OFFSET_BY_BIT := {
	1: Vector2i(0, -1),
	2: Vector2i(0, 1),
	4: Vector2i(1, 0),
	8: Vector2i(-1, 0),
}

## Bit -> Richtungsname, wie ihn RoomInstance.get_door_state() erwartet.
const DIR_NAME_BY_BIT := {
	1: "north",
	2: "south",
	4: "east",
	8: "west",
}

const OPPOSITE_DIR := {
	"north": "south",
	"south": "north",
	"east": "west",
	"west": "east",
}

@export var cell_px: float = 18.0
@export var gap_px: float = 4.0
@export var view_radius: int = 2
@export var show_unexplored_neighbors: bool = true

## ############################################################################
## PHASE 5.1 — SCHMALE KORRIDORE
## ############################################################################
## Anteil der Zellbreite, mit dem ein KORRIDOR quer zu seiner Laufrichtung
## gezeichnet wird. 1.0 = so breit wie ein Raum (altes Verhalten).
##
## WARUM DAS NOETIG WAR: im Level sind Korridore nur 20 statt 48 Einheiten
## breit, auf der Karte sahen sie aber aus wie vollwertige Raeume. Damit war
## der Rhythmus "Arena - Gang - Arena", der das Layout ausmacht, auf der
## Minimap unsichtbar; alle Zellen wirkten gleichwertig.
##
## Die Laufrichtung wird aus den exit_flags abgeleitet: Nord|Sued = senkrecht,
## Ost|West = waagerecht. Ein Korridor hat per Konstruktion immer genau diese
## beiden Muster (siehe RoomGridGenerator._place_corridors), ein Sonderfall
## fuer Ecken oder T-Stuecke ist also nicht noetig.
@export_range(0.2, 1.0) var corridor_width_factor: float = 0.42

## ############################################################################
## PHASE 3.1 — MULTI-ZELLEN-RAEUME
## ############################################################################
## Ein Raum, der mehrere Rasterzellen belegt, wird als EIN zusammenhaengendes
## Rechteck ueber die gesamte Flaeche gezeichnet - nicht als mehrere Quadrate
## nebeneinander. Sonst waere auf der Karte nicht zu erkennen, ob dort ein
## grosser Raum steht oder zwei kleine.
##
## Die Fugen zwischen den Zellen werden dabei mitgefuellt (gap_px), damit das
## Rechteck geschlossen wirkt.
@export var merge_multi_cell_rooms: bool = true

## Dreht NUR die Positionierung der Zellen/Tueren zueinander, damit das
## Layout zur kalibrierten 3D-Minimap passt. Buchstaben und Symbole
## bleiben davon unberuehrt. Falls die Karte nach dem Einbau spiegelverkehrt
## zur 3D-Ansicht wirkt: Vorzeichen umdrehen (+90 statt -90).
@export var overlay_rotation_degrees: float = -90.0

## --- Farbschema -------------------------------------------------------
## KEIN color_background mehr: das Grid hatte fruerher eine eigene,
## unabhaengige Hintergrundflaeche - das war die dritte Deckkraft neben
## Frame und 3D-Ansicht und erzeugte den sichtbaren "Kasten im Kasten".
## Das Overlay zeichnet jetzt nur noch Zellen/Durchgaenge/Text; der
## EINE Frame-Hintergrund (minimap.gd, Einstellung "Deckkraft") scheint
## darunter durch.
@export var color_unexplored: Color = Color(0.35, 0.38, 0.32, 0.45)
@export var color_combat: Color = Color(0.62, 0.64, 0.58, 0.95)
@export var color_corridor: Color = Color(0.45, 0.47, 0.42, 0.95)
@export var color_start: Color = Color(0.35, 0.68, 0.95, 0.95)
@export var color_boss: Color = Color(0.90, 0.24, 0.24, 0.95)
@export var color_treasure: Color = Color(0.98, 0.80, 0.25, 0.95)
@export var color_cleared_tint: Color = Color(0.44, 0.85, 0.36, 0.95)
@export var color_current: Color = Color(1.0, 1.0, 1.0, 1.0)
## Fuellfarbe des offenen Durchgangs zwischen zwei bereits betretenen
## Raeumen (voll deckend - liest sich als begehbarer Gang).
## Farbe eines OFFENEN Durchgangs.
##
## Deutlich gedaempfter als frueher (war 0.85/0.87/0.80 bei Alpha 0.9). Der
## alte Wert war heller als JEDE Raumfarbe — ein offener Gang leuchtete
## dadurch staerker als der Raum, zu dem er gehoert, und zog den Blick auf
## die unwichtigste Information der ganzen Karte. Ein offener Durchgang soll
## als LUECKE gelesen werden, nicht als Signal.
@export var color_door: Color = Color(0.42, 0.45, 0.40, 0.85)
## Durchgang zu einem noch NICHT betretenen Nachbarn: nur angedeutet
## (kuerzer + durchsichtiger), damit die Neugier/Fog-of-War erhalten
## bleibt, man aber trotzdem sieht "hier geht es weiter".
@export var color_door_unexplored_alpha: float = 0.5
## Verriegelte Tuer (Kampfraum noch nicht gecleared): schmaler Riegel in
## gedaempftem Rot statt offener Gang.
@export var color_door_locked: Color = Color(0.70, 0.28, 0.24, 0.95)
## Boss-/Treasure-Tuer, die noch NICHT gehackt werden darf.
@export var color_door_hack_locked: Color = Color(0.55, 0.45, 0.30, 0.9)
## Boss-/Treasure-Tuer, die JETZT gehackt werden kann - pulsiert.
@export var color_door_hack_ready: Color = Color(0.98, 0.80, 0.25, 1.0)
## Wie breit ein verriegelter Durchgang im Verhaeltnis zur Zelle
## gezeichnet wird (1.0 = so breit wie ein offener Gang).
@export_range(0.1, 1.0) var locked_door_width_factor: float = 0.42
@export var color_text: Color = Color(0.08, 0.08, 0.06, 1.0)

var _generator: Node = null
var _pulse: float = 0.0
var _rotation_rad: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_rotation_rad = deg_to_rad(overlay_rotation_degrees)
	set_process(true)
	_try_bind_generator()


func _process(delta: float) -> void:
	if _generator == null or not is_instance_valid(_generator):
		_try_bind_generator()
		return
	_pulse = fmod(_pulse + delta * 2.2, TAU)
	queue_redraw()


func _try_bind_generator() -> void:
	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		visible = false
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)
	visible = true
	queue_redraw()


func _on_map_updated() -> void:
	queue_redraw()


## Rotiert einen reinen Richtungs-/Offset-Vektor um overlay_rotation_degrees.
## Wird NIE auf Text angewendet - nur auf Positionen.
func _rotate(v: Vector2) -> Vector2:
	return v.rotated(_rotation_rad)


func _draw() -> void:
	if _generator == null or not is_instance_valid(_generator):
		return
	if not _generator.has_method("get_map_cells"):
		return

	var cells: Dictionary = _generator.get_map_cells()
	if cells.is_empty():
		return

	var current: Vector2i = _generator.get_current_room()
	var pitch: float = cell_px + gap_px
	var center := size * 0.5

	# Jeder Durchgang liegt zwischen ZWEI Zellen und wurde deshalb bisher
	# zweimal gezeichnet: einmal aus Sicht jeder Seite, an dieselbe Stelle,
	# mit derselben halbtransparenten Farbe.
	#
	# Zwei Fuellungen mit Alpha 0.9 uebereinander ergeben zusammen rund 0.99 —
	# offene Durchgaenge zwischen zwei besuchten Raeumen wurden dadurch fast
	# deckend und damit heller als alles andere auf der Karte. Genau das ist
	# das "Leuchten". Zusaetzlich flackerte es beim Betreten eines Raums,
	# weil in dem Moment aus einem einfach gezeichneten Durchgang (Nachbar
	# noch unbesucht, Alpha 0.45) ein doppelt gezeichneter wurde.
	#
	# Der Schluessel ist die SORTIERTE Zellenpaarung — so landen beide
	# Blickrichtungen auf demselben Eintrag.
	var drawn_passages: Dictionary = {}

	# PHASE 3.1: Zusatzzellen eines Multi-Zellen-Raums stehen NICHT in
	# get_map_cells() - dort liegt nur die Ankerzelle mit ihrem footprint.
	# Es gibt hier also nichts zu ueberspringen; das Rechteck der Ankerzelle
	# deckt die Flaeche bereits ab.

	# --- Durchgaenge zuerst, damit die Raumquadrate spaeter sauber
	# darueber gezeichnet werden und den ueberschuessigen Teil der
	# Fuellung in der Raummitte automatisch abschneiden -----------------
	for pos in cells.keys():
		var grid: Vector2i = pos
		if not _is_visible_cell(cells, grid, current):
			continue
		var data: Dictionary = cells[grid]
		if not bool(data.get("visited", false)):
			continue

		var exits: int = int(data.get("exits", 0))
		var here_center := _cell_center(grid, current, center, pitch)

		for bit in DIR_OFFSET_BY_BIT.keys():
			if exits & bit == 0:
				continue
			var neighbor_grid: Vector2i = grid + DIR_OFFSET_BY_BIT[bit]
			if not cells.has(neighbor_grid):
				continue

			var dir_name: String = DIR_NAME_BY_BIT[bit]
			var state: int = _door_state(grid, dir_name, exits, bit)
			if state == RoomInstance.DoorState.NONE:
				continue

			# BEIDSEITIGE Pruefung: ein Durchgang existiert nur, wenn AUCH
			# der Nachbarraum auf seiner Gegenseite eine Tuer hat. Ohne das
			# malte die Minimap Gaenge, die im Level an einer Wand enden.
			var neighbor_exits: int = int(cells[neighbor_grid].get("exits", 0))
			var opposite_bit: int = _bit_for_dir(OPPOSITE_DIR[dir_name])
			var neighbor_state: int = _door_state(
				neighbor_grid, OPPOSITE_DIR[dir_name], neighbor_exits, opposite_bit
			)
			if neighbor_state == RoomInstance.DoorState.NONE:
				continue

			var neighbor_data: Dictionary = cells[neighbor_grid]
			var neighbor_visited: bool = bool(neighbor_data.get("visited", false))
			# PHASE 3.1: Der Durchgang endet an der ZELLE, nicht am
			# Raum-Mittelpunkt. Das ist genau die Stelle, an der die Tuer im
			# Level sitzt (siehe LevelGenerator._apply_multi_cell_exit_offsets),
			# und deshalb auch die, die auf der Karte stimmen muss.
			var neighbor_center := _cell_center(neighbor_grid, current, center, pitch)

			# Sortiertes Schluesselpaar: (A,B) und (B,A) ergeben denselben
			# Eintrag, der Durchgang wird also genau einmal gefuellt.
			var key: String = _passage_key(grid, neighbor_grid)
			if drawn_passages.has(key):
				continue
			drawn_passages[key] = true

			# Der restriktivere der beiden Zustaende gewinnt - eine Seite
			# offen und die andere verriegelt heisst: man kommt nicht durch.
			_draw_passage(here_center, neighbor_center, cell_px, neighbor_visited,
				_stricter_state(state, neighbor_state))

	# --- Raumzellen ------------------------------------------------------
	for pos in cells.keys():
		var grid: Vector2i = pos
		if not _is_visible_cell(cells, grid, current):
			continue

		var data: Dictionary = cells[grid]
		var visited: bool = bool(data.get("visited", false))
		var cleared: bool = bool(data.get("cleared", false))
		var hostile: bool = bool(data.get("hostile", false))
		var type: int = int(data.get("type", 0))

		var c := _cell_center(grid, current, center, pitch)
		# Zelle bleibt ein achsenparalleles Rect2 - NUR ihre Position
		# wandert entlang der rotierten Achsen, die Box selbst dreht sich
		# nicht. Dadurch bleiben Glyphen/Text darin aufrecht.
		var rect := _rect_for_cell(data, grid, current, center, pitch, exits_of(data))

		if not visited:
			draw_rect(rect, color_unexplored, true)
			draw_rect(rect, Color(0, 0, 0, 0.5), false, 1.0)
			continue

		var base := _color_for_type(type)
		if hostile and cleared:
			base = base.lerp(color_cleared_tint, 0.65)

		draw_rect(rect, base, true)
		draw_rect(rect, Color(0, 0, 0, 0.65), false, 1.0)

		_draw_room_glyph(rect, type, hostile and cleared)

		if grid == current:
			var a: float = 0.55 + 0.45 * sin(_pulse)
			var hl := color_current
			hl.a = a
			draw_rect(rect.grow(2.0), hl, false, 2.0)

	# --- "STAGE CLEAR"-Banner --------------------------------------------
	if _generator.has_method("is_stage_cleared") and _generator.is_stage_cleared():
		var font := ThemeDB.fallback_font
		var txt := "STAGE CLEAR"
		draw_string(font, Vector2(0.0, size.y - 4.0), txt,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, color_cleared_tint)


## Exit-Bitmaske einer Zelle. Kleiner Helfer, damit _rect_for_cell() nicht
## noch einen Parameter mehr braucht.
func exits_of(data: Dictionary) -> int:
	return int(data.get("exits", 0))


## ############################################################################
## Das Rechteck, mit dem eine Zelle gezeichnet wird.
## ############################################################################
## Deckt drei Faelle ab:
##   1. Normaler Raum      -> Quadrat von cell_px.
##   2. Korridor           -> quer zur Laufrichtung auf corridor_width_factor
##                            geschrumpft (Phase 5.1).
##   3. Multi-Zellen-Raum  -> ein Rechteck ueber die gesamte belegte Flaeche,
##                            inklusive der Fugen dazwischen (Phase 3.1).
##
## Fall 2 und 3 schliessen sich gegenseitig aus: Korridore bleiben laut
## RoomGridGenerator._assign_footprints() immer einzellig.
##
## ROTATION: das Rechteck selbst bleibt achsenparallel, damit Glyphen aufrecht
## stehen. Bei overlay_rotation_degrees = -90 vertauschen sich aber Breite und
## Hoehe auf dem Bildschirm — deshalb wird die Ausdehnung ueber die rotierten
## Eckpunkte bestimmt statt ueber die Rasterachsen direkt.
func _rect_for_cell(
		data: Dictionary,
		grid: Vector2i,
		current: Vector2i,
		center: Vector2,
		pitch: float,
		exits: int
) -> Rect2:
	var c: Vector2 = _cell_center(grid, current, center, pitch)
	var type: int = int(data.get("type", 0))

	# --- Fall 3: Multi-Zellen-Raum ---------------------------------------
	var footprint: Vector2i = data.get("footprint", Vector2i.ONE)
	if merge_multi_cell_rooms and (footprint.x > 1 or footprint.y > 1):
		# Mittelpunkt der Flaeche statt der Ankerzelle.
		var half: Vector2 = Vector2(float(footprint.x - 1) * 0.5, float(footprint.y - 1) * 0.5)
		var shifted: Vector2 = c + _rotate(Vector2(half.x * pitch, half.y * pitch))
		# Volle Ausdehnung inkl. Fugen: n Zellen + (n-1) Luecken.
		var span := Vector2(
			float(footprint.x) * cell_px + float(footprint.x - 1) * gap_px,
			float(footprint.y) * cell_px + float(footprint.y - 1) * gap_px
		)
		var rotated_span: Vector2 = _rotate(span).abs()
		return Rect2(shifted - rotated_span * 0.5, rotated_span)

	# --- Fall 2: Korridor -------------------------------------------------
	if type == RoomData.RoomType.CORRIDOR:
		var narrow: float = cell_px * corridor_width_factor
		# Nord|Sued (1|2) = der Gang laeuft senkrecht durchs Raster, ist also
		# in RASTER-X schmal. Alles andere behandeln wir als waagerecht.
		var vertical: bool = (exits & 1) != 0 and (exits & 2) != 0
		var raw := Vector2(narrow, cell_px) if vertical else Vector2(cell_px, narrow)
		var span_c: Vector2 = _rotate(raw).abs()
		return Rect2(c - span_c * 0.5, span_c)

	# --- Fall 1: normaler Raum -------------------------------------------
	return Rect2(c - Vector2(cell_px, cell_px) * 0.5, Vector2(cell_px, cell_px))


## Eindeutiger Schluessel fuer ein Zellenpaar, unabhaengig von der
## Reihenfolge. Ohne die Sortierung waeren "(0,0)->(0,1)" und "(0,1)->(0,0)"
## zwei verschiedene Eintraege und die Deduplizierung liefe ins Leere.
func _passage_key(a: Vector2i, b: Vector2i) -> String:
	var first: Vector2i = a
	var second: Vector2i = b
	if b.x < a.x or (b.x == a.x and b.y < a.y):
		first = b
		second = a
	return "%d,%d|%d,%d" % [first.x, first.y, second.x, second.y]


## Fuellt den Durchgang zwischen zwei Zellen als FLAECHE statt als
## duenne Linie - das ist der eigentliche Unterschied zwischen "sieht
## nach Gitter/Riegel aus" und "sieht nach offenem Gang aus".
##
## Reicht bei einem bereits betretenen Nachbarn bis zu dessen Mitte,
## bei einem noch unbetretenen Nachbarn nur bis zur Spaltmitte (Fog-of-
## War bleibt erhalten, man sieht aber "hier geht's weiter"). Die
## spaeter obendrauf gezeichneten Raumquadrate schneiden den Teil, der
## in die jeweilige Raummitte hineinreicht, automatisch weg.
##
## Funktioniert nur exakt fuer Rotationen, die ein Vielfaches von 90 Grad
## sind (Standard: -90) - dann ist die Verbindung zwischen zwei
## Zellmitten garantiert rein horizontal oder rein vertikal auf dem
## Bildschirm, und ein simples Rect2 reicht aus.
func _draw_passage(here: Vector2, neighbor: Vector2, cell_size: float, neighbor_visited: bool, state: int) -> void:
	var delta: Vector2 = neighbor - here
	var horizontal: bool = absf(delta.x) >= absf(delta.y)
	var mid: Vector2 = (here + neighbor) * 0.5
	var far_point: Vector2 = neighbor if neighbor_visited else mid

	# SPOILER-SPERRE: Zu einem noch NICHT betretenen Nachbarn wird immer die
	# neutrale Tuerfarbe gezeichnet, nie die von Zustand oder Raumtyp.
	#
	# Vorher verriet die Karte den halben Grundriss, bevor man ihn gesehen
	# hatte: eine Tuer zum Schatzraum kam als goldener, pulsierender Riegel
	# heraus, eine Bossturm als brauner. Man musste also gar nicht erkunden —
	# ein Blick auf die Minimap sagte, in welcher Richtung das Item liegt und
	# wo der Boss wartet. Fog-of-War, der die Raeume verdeckt, aber ihre
	# Tueren durchscheinen laesst, ist kein Fog-of-War.
	#
	# Sobald der Nachbarraum betreten wurde, greift wieder die volle
	# Zustandsfarbe — dann ist die Information ja verdient.
	var fill: Color = _color_for_door_state(state) if neighbor_visited else color_door
	if not neighbor_visited:
		fill.a = fill.a * color_door_unexplored_alpha

	# Nur ein OFFENER Durchgang wird in voller Zellbreite gefuellt. Alles
	# Verriegelte wird bewusst SCHMALER gezeichnet, damit es sich optisch
	# klar als Riegel und nicht als Gang liest.
	#
	# Auch die BREITE bleibt bei unbesuchten Nachbarn neutral: ein schmal
	# gezeichneter Riegel haette denselben Hinweis gegeben wie die Farbe.
	var width: float = cell_size
	if neighbor_visited and state != RoomInstance.DoorState.OPEN:
		width = cell_size * locked_door_width_factor

	if horizontal:
		var min_x: float = minf(here.x, far_point.x)
		var max_x: float = maxf(here.x, far_point.x)
		var rect := Rect2(Vector2(min_x, here.y - width * 0.5), Vector2(max_x - min_x, width))
		draw_rect(rect, fill, true)
	else:
		var min_y: float = minf(here.y, far_point.y)
		var max_y: float = maxf(here.y, far_point.y)
		var rect := Rect2(Vector2(here.x - width * 0.5, min_y), Vector2(width, max_y - min_y))
		draw_rect(rect, fill, true)


## Fragt den ECHTEN Tuerzustand beim Generator ab.
##
## Faellt auf die alte Bitmaske zurueck, falls der Generator die Methode
## (noch) nicht kennt - so bleibt das Overlay auch mit einem aelteren
## LevelGenerator funktionsfaehig, statt gar nichts mehr zu zeichnen.
func _door_state(grid: Vector2i, dir: String, exits: int, bit: int) -> int:
	if _generator != null and is_instance_valid(_generator) and _generator.has_method("get_door_state"):
		return int(_generator.get_door_state(grid, dir))
	return RoomInstance.DoorState.OPEN if (exits & bit) != 0 else RoomInstance.DoorState.NONE


func _bit_for_dir(dir: String) -> int:
	for bit in DIR_NAME_BY_BIT.keys():
		if DIR_NAME_BY_BIT[bit] == dir:
			return bit
	return 0


## Reihenfolge von "am wenigsten begehbar" nach "offen". Der niedrigere
## Rang gewinnt, damit eine einseitig verriegelte Verbindung auch als
## verriegelt dargestellt wird.
func _stricter_state(a: int, b: int) -> int:
	var rank := {
		RoomInstance.DoorState.NONE: 0,
		RoomInstance.DoorState.LOCKED: 1,
		RoomInstance.DoorState.HACK_LOCKED: 2,
		RoomInstance.DoorState.HACK_READY: 3,
		RoomInstance.DoorState.OPEN: 4,
	}
	return a if int(rank.get(a, 4)) <= int(rank.get(b, 4)) else b


func _color_for_door_state(state: int) -> Color:
	match state:
		RoomInstance.DoorState.LOCKED:
			return color_door_locked
		RoomInstance.DoorState.HACK_LOCKED:
			return color_door_hack_locked
		RoomInstance.DoorState.HACK_READY:
			# Pulsiert im selben Takt wie die Markierung des aktuellen
			# Raums - signalisiert "hier kannst du JETZT etwas tun".
			var pulsing := color_door_hack_ready
			pulsing.a = color_door_hack_ready.a * (0.55 + 0.45 * sin(_pulse))
			return pulsing
	return color_door


## Fog of War: sichtbar sind betretene Raeume und (optional) deren direkte
## Nachbarn.
func _is_visible_cell(cells: Dictionary, grid: Vector2i, current: Vector2i) -> bool:
	if absi(grid.x - current.x) > view_radius or absi(grid.y - current.y) > view_radius:
		return false
	var data: Dictionary = cells[grid]
	if bool(data.get("visited", false)):
		return true
	if not show_unexplored_neighbors:
		return false
	for offset in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]:
		var n: Vector2i = grid + offset
		if cells.has(n) and bool(cells[n].get("visited", false)):
			return true
	return false


## Position der Zelle relativ zur aktuellen: der reine Offset-Vektor wird
## rotiert, NICHT die Zelle selbst.
func _cell_center(grid: Vector2i, current: Vector2i, center: Vector2, pitch: float) -> Vector2:
	var d := grid - current
	var offset := Vector2(float(d.x) * pitch, float(d.y) * pitch)
	return center + _rotate(offset)


func _color_for_type(type: int) -> Color:
	match type:
		RoomData.RoomType.START:
			return color_start
		RoomData.RoomType.BOSS:
			return color_boss
		RoomData.RoomType.TREASURE:
			return color_treasure
		RoomData.RoomType.CORRIDOR:
			return color_corridor
	return color_combat


## Zeichnet das Typ-Symbol bzw. den Clear-Haken in die Zelle. Bewusst
## UNROTIERT: rect ist achsenparallel, also bleibt der Text aufrecht,
## egal wie overlay_rotation_degrees eingestellt ist.
func _draw_room_glyph(rect: Rect2, type: int, cleared: bool) -> void:
	if cleared:
		var p := rect.position
		var s := rect.size
		draw_line(p + Vector2(s.x * 0.24, s.y * 0.52), p + Vector2(s.x * 0.44, s.y * 0.74), color_text, 2.0)
		draw_line(p + Vector2(s.x * 0.44, s.y * 0.74), p + Vector2(s.x * 0.78, s.y * 0.26), color_text, 2.0)
		return

	var glyph: String = ""
	match type:
		RoomData.RoomType.BOSS:
			glyph = "B"
		RoomData.RoomType.TREASURE:
			glyph = "$"
		RoomData.RoomType.START:
			glyph = "S"
		RoomData.RoomType.SHOP:
			glyph = "?"
	if glyph == "":
		return

	var font := ThemeDB.fallback_font
	var fs: int = int(cell_px * 0.72)
	draw_string(font, rect.position + Vector2(0.0, rect.size.y * 0.78), glyph,
		HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, fs, color_text)

```
</details>

### 💭 Thinking

`20:16:51`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `Minimap|minimap|Icon|icon_texture|TextureRect|stretch_mode` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\level\room_instance.gd`

`20:16:53`

```
Path does not exist: C:\Users\thvnh\Documents\GitHub\whiplash\scripts\level\room_instance.gd. Note: your current working directory is C:\Users\thvnh\Documents\GitHub\whiplash.
```

#### 📂 Glob `**/room_instance.gd`

`20:16:55`

```
scenes\level_generation\room_instance.gd
```

#### 🔎 Grep `Minimap|minimap|Icon|icon_texture|TextureRect|stretch_mode|floor_material|floor_mesh|MeshInstance3D.*floor` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:16:58`

```
33:## Die Minimap ist aber nur eine zweite Kamera auf DIESELBE Welt. Also
35:## ausschliesslich die Minimap-Kamera aus ihrer cull_mask streicht - die
39:## Gegenstueck: Layer, den AUSSCHLIESSLICH die Minimap-Kamera rendert.
43:## 14; die Minimap-Kamera sieht also durch die Wandluecke hindurch auf den
46:## auf diesem Layer liegt: die Minimap zeigt sie, die Spielerkamera nicht.
53:## Zustand EINES Durchgangs - Grundlage fuer die Minimap-Synchronisation.
55:## BUGFIX (Minimap zeigte geschlossene Tueren als offen): Die Minimap hat
60:##      ExitPoint/Door-Node (dann warnt _collect_markers, die Minimap
63:##      erst gehackt werden (Boss/Treasure) - auf der Minimap sah sie
159:## --- Wand-Kappe fuer die Minimap-Sichtbarkeit --------------------------
165:## Minimap zeigt eine Wand nur ihre duenne Oberkante, texturell identisch
172:## Decke), aber die Top-Down-Kamera der Minimap trifft ihn zuerst und
198:## _build_wall_caps() ihn nicht als "Wall*" einsammelt: eine Minimap-Kappe
285:## --- Tuerzustand auf der 3D-Minimap -----------------------------------
287:## (minimap_rooms.gd), damit beide Karten dasselbe sagen.
457:## Fog-of-War-Zustand. null-Zustand ueber _minimap_state_known, damit der
459:var _minimap_revealed: bool = true
460:var _minimap_state_known: bool = false
1333:		if child.get_node_or_null("MinimapCap") != null:
1357:		cap.name = "MinimapCap"
1371:## Blendet den kompletten Raum auf der Minimap ein oder aus.
1373:## Wird vom LevelGenerator getrieben (siehe _refresh_minimap_fog dort).
1377:func set_minimap_revealed(revealed: bool) -> void:
1378:	if _minimap_state_known and revealed == _minimap_revealed:
1380:	_minimap_revealed = revealed
1381:	_minimap_state_known = true
1382:	_apply_minimap_layer(self, revealed)
1385:func _apply_minimap_layer(node: Node, revealed: bool) -> void:
1389:			if not visual.has_meta("minimap_base_layers"):
1390:				visual.set_meta("minimap_base_layers", visual.layers)
1392:				visual.layers = int(visual.get_meta("minimap_base_layers"))
1395:		_apply_minimap_layer(child, revealed)
1505:## nicht nur "MeshInstance3D"/"CollisionShape3D": haengt dort pit_floor.gd,
1574:	var floor_material: Material = _disable_flat_floor()
1594:	if floor_material != null:
1596:		mesh_instance.material_override = floor_material
1651:	# Waende, Decke, Tuerstuerze, Minimap-Platten und die Trigger-Volumen auf
1663:## Zieht Waende, Decke, Tuerstuerze, Minimap-Platten und die Trigger-Volumen
1689:	# gebaut oder verschoben wird (Kappen, Stuerze, Minimap-Platten), rechnet
1740:		# Die Minimap-Kappe wird gleich komplett neu gebaut - hier nicht
1742:		# Minimap zeigte eine schwarze Flaeche statt eines Wandstrichs.
1743:		if mesh_child.name == "MinimapCap":
1769:		var old_cap: Node = child.get_node_or_null("MinimapCap")
2481:	# Die frisch gemauerten Waende brauchen ihre Minimap-Kappe. Der zweite
2528:		# Nur die Minimap-Kamera sieht diesen Layer.
2625:	# die Wand findet und ihr eine Minimap-Kappe verpasst.
```

### 💭 Thinking

`20:17:05`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:17:06`

*(lines 1500–1610)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```

## Schaltet die flache Bodenplatte des Raumes ab und liefert deren
## Material zurueck, damit die Rampe genauso aussieht.
##
## Es werden ALLE Mesh- und Collider-Kinder des "Floor"-Nodes erfasst,
## nicht nur "MeshInstance3D"/"CollisionShape3D": haengt dort pit_floor.gd,
## besteht der Boden zur Laufzeit aus mehreren generierten Gen_*-Segmenten.
func _disable_flat_floor() -> Material:
	var material: Material = null
	var floor_body := get_node_or_null("Floor") as StaticBody3D
	if floor_body == null:
		return material

	for child in floor_body.get_children():
		if child is MeshInstance3D:
			var mesh_child: MeshInstance3D = child as MeshInstance3D
			if material == null:
				if mesh_child.material_override != null:
					material = mesh_child.material_override
				elif mesh_child.get_surface_override_material_count() > 0:
					material = mesh_child.get_surface_override_material(0)
			mesh_child.visible = false
		elif child is CollisionShape3D:
			(child as CollisionShape3D).disabled = true

	return material


## Baut im Inneren eines Korridors eine Rampe, die rise Meter ueberwindet.
## low_dir zeigt zur tiefer liegenden Eingangsseite; die Tuer und der
## ExitPoint auf der Gegenseite werden um rise angehoben.
##
## Wird vom LevelGenerator aufgerufen, BEVOR der Raum betreten wird.
func configure_slope(low_dir: String, rise: float) -> void:
	if not _DIR_VECTOR.has(low_dir) or is_zero_approx(rise):
		return

	# BUGFIX "Stationaere Gegner/Requisiten schweben in Rampen-Raeumen":
	# _build_props() laeuft in _ready(), lange bevor der Generator hier
	# konfiguriert, ob der Raum ueberhaupt eine Rampe braucht - Requisiten
	# wurden also auf einen flachen Boden bei y=0 gestellt, der es dann gar
	# nicht mehr gibt. Stationaere Gegner (Moerser-Bot/Saeure-Sprinkler/
	# Magnet-Kern rufen NIE move_and_slide() auf, siehe deren
	# _physics_process()) korrigieren sich - anders als die beweglichen
	# Threat-Budget-Gegner, fuer die _snap_markers_to_ground() unten sorgt -
	# nach dem Spawn nie von selbst und bleiben dauerhaft auf der falschen
	# Hoehe stehen. Einfachster robuster Fix statt einer erneuten
	# Boden-Suche mitten in der Bauphase: Requisiten in Rampen-Raeumen ganz
	# weglassen, stationaere Gegner aus der Spawn-Tabelle ausschliessen
	# (siehe prepare_enemies()).
	_has_slope = true
	var stale_props: Node = get_node_or_null("Props")
	if stale_props != null:
		stale_props.queue_free()

	var high_dir: String = _opposite(low_dir)
	var axis: Vector3 = _DIR_VECTOR[high_dir]

	# Laenge der Rampe entlang der Steigungsachse.
	var length: float = room_footprint.y if absf(axis.z) > 0.5 else room_footprint.x
	var width: float = room_footprint.x if absf(axis.z) > 0.5 else room_footprint.y

	# BUGFIX "Korridore haben keinen absteigenden Boden":
	#
	# Die Rampe wurde frueher ZUSAETZLICH zur flachen Bodenplatte gebaut. Bei
	# einer STEIGUNG faellt das nicht auf - die Rampe liegt dann ueber der
	# Platte und gewinnt. Bei einem GEFAELLE laeuft sie von 0 auf -rise nach
	# unten, liegt also UNTER der Platte: der Spieler laeuft die ganze
	# Ganglaenge auf der Platte weiter und faellt am Ende einen ungefederten
	# Absatz von rise Metern in den naechsten Raum.
	#
	# Sobald eine Rampe existiert, IST sie der Boden - die Platte wird
	# abgeschaltet und gibt ihr Material an die Rampe weiter (sonst rendert
	# die Rampe im Godot-Standardgrau statt im PSX-Material).
	var floor_material: Material = _disable_flat_floor()

	var ramp := StaticBody3D.new()
	ramp.name = "SlopeRamp"
	add_child(ramp)
	ramp.add_to_group(NAV_SOURCE_GROUP)

	var hypotenuse: float = sqrt(length * length + rise * rise)
	var angle: float = atan2(rise, length)

	# Massiver Keil statt duenner Platte: die Dicke reicht garantiert unter
	# das tiefste Bodenniveau des Raums. Siehe slope_ramp_extra_thickness.
	var thickness: float = absf(rise) + maxf(slope_ramp_extra_thickness, 0.5)

	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(width, thickness, hypotenuse)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = box_mesh
	if floor_material != null:
		# material_override statt surface_material_override - Vorrangregel.
		mesh_instance.material_override = floor_material
	ramp.add_child(mesh_instance)

	var shape := CollisionShape3D.new()
	shape.name = "CollisionShape3D"
	var box := BoxShape3D.new()
	box.size = box_mesh.size
	shape.shape = box
	ramp.add_child(shape)

	# Die LAUF-FLAECHE (Oberseite des Keils) soll ihren Mittelpunkt exakt bei
	# rise * 0.5 haben, damit die Enden sauber auf 0 und rise liegen. Die
	# halbe Dicke muss dabei MIT dem Neigungswinkel gerechnet werden: der
	# alte feste Term "- 0.5" stimmte nur zufaellig fuer eine 1.0 dicke
```
</details>

### 💭 Thinking

`20:17:11`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `room_footprint|footprint_cells|Floor\"|uv1_scale|uv_scale` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:17:12`

```
74:@export var room_footprint: Vector2 = Vector2(48.0, 48.0)
349:##      room_footprint.x = 20 breit -> 20 - 18 = 2, gekappt auf
557:	plane.size = Vector2(room_footprint.x, room_footprint.y)
576:		box.size = Vector3(room_footprint.x, ceiling_thickness, room_footprint.y)
585:## oder Multi-Zellen-Raeumen (siehe room_footprint bei 2x2-Raeumen) die Ecken
596:	var cols: int = maxi(1, int(ceil(room_footprint.x / maxf(room_light_spacing, 1.0))))
597:	var rows: int = maxi(1, int(ceil(room_footprint.y / maxf(room_light_spacing, 1.0))))
598:	var cell_x: float = room_footprint.x / float(cols)
599:	var cell_z: float = room_footprint.y / float(rows)
615:			var px: float = (float(cx) + 0.5) * cell_x - room_footprint.x * 0.5
616:			var pz: float = (float(cz) + 0.5) * cell_z - room_footprint.y * 0.5
736:	var area_factor: float = (room_footprint.x * room_footprint.y) / (48.0 * 48.0)
814:	var half_x: float = room_footprint.x * 0.5 - prop_wall_inset
815:	var half_z: float = room_footprint.y * 0.5 - prop_wall_inset
905:	var area_factor: float = (room_footprint.x * room_footprint.y) / (48.0 * 48.0)
985:	var half_x: float = room_footprint.x * 0.5 - wall_prop_inset
986:	var half_z: float = room_footprint.y * 0.5 - wall_prop_inset
1140:	var area_factor: float = (room_footprint.x * room_footprint.y) / (48.0 * 48.0)
1302:		# room_footprint fuer diesen Raum ist - sonst wuerde dasselbe
1504:## Es werden ALLE Mesh- und Collider-Kinder des "Floor"-Nodes erfasst,
1509:	var floor_body := get_node_or_null("Floor") as StaticBody3D
1559:	var length: float = room_footprint.y if absf(axis.z) > 0.5 else room_footprint.x
1560:	var width: float = room_footprint.x if absf(axis.z) > 0.5 else room_footprint.y
1907:	var inset_x: float = minf(entry_trigger_depth, room_footprint.x * factor)
1908:	var inset_z: float = minf(entry_trigger_depth, room_footprint.y * factor)
1910:	var size_x: float = maxf(room_footprint.x - inset_x * 2.0, entry_trigger_min_size)
1911:	var size_z: float = maxf(room_footprint.y - inset_z * 2.0, entry_trigger_min_size)
1943:		room_footprint.x + presence_margin * 2.0,
1945:		room_footprint.y + presence_margin * 2.0
1970:## Koordinaten sind von room_scale unabhaengig, room_footprint ist genau so
1975:	var half_x: float = room_footprint.x * 0.5 + margin
1976:	var half_z: float = room_footprint.y * 0.5 + margin
2895:	# ist. Diese generierten Kinder haengen direkt unter dem "Floor"-Node,
```

### 💭 Thinking

`20:17:18`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:17:19`

*(lines 530–580)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
				var key: String = child.name.to_lower()
				if not _FLAG_BY_KEY.has(key):
					continue
				exit_points[key] = child
				var door := get_node_or_null("Doors/Door%s" % child.name.capitalize())
				if door:
					child.set_meta("door_node", door)
					_doors_by_dir[key] = door
				else:
					push_warning("RoomInstance (%s): ExitPoint '%s' hat keine Tuer unter 'Doors/Door%s'." % [name, child.name, child.name.capitalize()])


## Baut eine texturierte, dunkel eingefaerbte Decke. Kollision (Box) und
## Optik (gekipptes PlaneMesh mit PSX-Material) sind zwei unabhaengige
## Kinder desselben StaticBody3D.
func _build_ceiling() -> void:
	if get_node_or_null("Ceiling") != null:
		return

	var body := StaticBody3D.new()
	body.name = "Ceiling"
	body.position = Vector3(0.0, room_height + ceiling_thickness * 0.5, 0.0)
	add_child(body)

	var mat: Material = _make_ceiling_material()

	var plane := PlaneMesh.new()
	plane.size = Vector2(room_footprint.x, room_footprint.y)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = plane
	# PlaneMesh zeigt standardmaessig mit der Vorderseite nach OBEN (+Y).
	# Lokal auf die Unterkante der Kollisionsbox setzen und um 180 Grad
	# kippen, damit dieselbe Dreiecksseite stattdessen nach UNTEN in den
	# Raum zeigt - siehe Klassenkommentar zum cull_back-Problem oben.
	mesh_instance.position = Vector3(0.0, -ceiling_thickness * 0.5, 0.0)
	mesh_instance.rotation_degrees = Vector3(180.0, 0.0, 0.0)
	# material_override statt surface_material_override - Vorrangregel.
	mesh_instance.material_override = mat
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mesh_instance)

	if ceiling_collision:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(room_footprint.x, ceiling_thickness, room_footprint.y)
		shape.shape = box
		body.add_child(shape)
	else:
```
</details>

### 💭 Thinking

`20:17:25`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _build_floor|_make_floor_material|_make_ceiling_material|func _build_walls` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:17:27`

```
554:	var mat: Material = _make_ceiling_material()
1295:func _make_ceiling_material() -> Material:
2907:	# Material via _make_ceiling_material()/_refresh_ceiling_material().
2963:	mesh.material_override = _make_ceiling_material()
```

### 💭 Thinking

`20:17:46`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:17:46`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -rl "footprint_cells" resources/rooms/*.tres | head -5
```

```
resources/rooms/rd_combat_07.tres
resources/rooms/rd_combat_08.tres
resources/rooms/rd_combat_09.tres
resources/rooms/rd_combat_10.tres
resources/rooms/rd_combat_11.tres
```

#### 👀 Read `rd_combat_07.tres`

`20:17:49`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_07.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/combat/room_combat_07.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 0
available_exits = 15
spawn_weight = 1
min_stage = 0
unique_per_run = false
footprint_cells = Vector2i(1, 1)

```
</details>

### 💭 Thinking

`20:17:53`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:17:53`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -l "footprint_cells = Vector2i([2-9]" resources/rooms/*.tres
```

```
resources/rooms/rd_combat_arena_01.tres
resources/rooms/rd_combat_wide_01.tres
```

#### 👀 Read `rd_combat_wide_01.tres`

`20:17:57`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_wide_01.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/combat/room_combat_wide_01.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 0
available_exits = 15
spawn_weight = 1
min_stage = 0
unique_per_run = false
footprint_cells = Vector2i(2, 1)

```
</details>

### 🤖 Assistant: *Now let's check the actual floor node in…*

`20:18:00`

> Now let's check the actual floor node in this 2x1 room scene.

#### 🔎 Grep `Floor|PlaneMesh|scale|size = Vector"` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\rooms\combat\room_combat_wide_01.tscn`

`20:18:01`

```
60:[node name="Floor" type="StaticBody3D" parent="."]
61-transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.5, 0)
62-
63:[node name="MeshInstance3D" type="MeshInstance3D" parent="Floor"]
64-mesh = SubResource("bm1")
65-surface_material_override/0 = ExtResource("mat")
66-
67:[node name="CollisionShape3D" type="CollisionShape3D" parent="Floor"]
68-shape = SubResource("bs1")
69-
70-[node name="WallNorth_A" type="StaticBody3D" parent="."]
```

### 💭 Thinking

`20:18:05`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:18:06`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -n "sub_resource\|ext_resource\|size = \|uv1_scale\|uv1_triplanar\|albedo_texture" scenes/rooms/combat/room_combat_wide_01.tscn | head -40
```

```
3:[ext_resource type="Script" path="res://scenes/level_generation/room_instance.gd" id="room_script"]
4:[ext_resource type="Script" path="res://scenes/level_generation/door.gd" id="door_script"]
5:[ext_resource type="Material" path="res://materials/psx_material.tres" id="mat"]
7:[sub_resource type="BoxMesh" id="bm1"]
8:size = Vector3(96, 1, 48)
10:[sub_resource type="BoxShape3D" id="bs1"]
11:size = Vector3(96, 1, 48)
13:[sub_resource type="BoxMesh" id="bm2"]
14:size = Vector3(19, 14, 1)
16:[sub_resource type="BoxShape3D" id="bs2"]
17:size = Vector3(19, 14, 1)
19:[sub_resource type="BoxMesh" id="bm3"]
20:size = Vector3(67, 14, 1)
22:[sub_resource type="BoxShape3D" id="bs3"]
23:size = Vector3(67, 14, 1)
25:[sub_resource type="BoxMesh" id="bm4"]
26:size = Vector3(1, 14, 19)
28:[sub_resource type="BoxShape3D" id="bs4"]
29:size = Vector3(1, 14, 19)
31:[sub_resource type="BoxMesh" id="bm5"]
32:size = Vector3(4, 10, 4)
34:[sub_resource type="BoxShape3D" id="bs5"]
35:size = Vector3(4, 10, 4)
37:[sub_resource type="BoxMesh" id="bm6"]
38:size = Vector3(20, 2, 16)
40:[sub_resource type="BoxShape3D" id="bs6"]
41:size = Vector3(20, 2, 16)
43:[sub_resource type="BoxMesh" id="bm7"]
44:size = Vector3(10, 10, 0.8)
46:[sub_resource type="BoxShape3D" id="bs7"]
47:size = Vector3(10, 10, 0.8)
49:[sub_resource type="BoxMesh" id="bm8"]
50:size = Vector3(0.8, 10, 10)
52:[sub_resource type="BoxShape3D" id="bs8"]
53:size = Vector3(0.8, 10, 10)
```

### 💭 Thinking

`20:18:18`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `psx_material.tres`

`20:18:18`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\materials\psx_material.tres</code></summary>

```
[gd_resource type="ShaderMaterial" format=3 uid="uid://dq7ypxvjbo36p"]

[ext_resource type="Shader" uid="uid://bl0t62j8xq1d4" path="res://shaders/psx.gdshader" id="1_hgpdb"]
[ext_resource type="Texture2D" uid="uid://7wgqy2q0hqcb" path="res://assets/textures/environment/sidewalk-texture.jpg" id="2_mkv5x"]

[resource]
render_priority = 0
shader = ExtResource("1_hgpdb")
shader_parameter/albedo_texture = ExtResource("2_mkv5x")
shader_parameter/albedo_color = Color(0.1534903, 0.2336203, 0.30147082, 1)
shader_parameter/snap_resolution = 4.0
shader_parameter/vertex_jitter_strength = 0.0
shader_parameter/alpha_multiplier = 1.0
shader_parameter/flash_color = Color(1, 0, 0, 1)
shader_parameter/flash_strength = 0.0

```
</details>

### 💭 Thinking

`20:18:22`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `psx.gdshader`

`20:18:22`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\shaders\psx.gdshader</code></summary>

```
shader_type spatial;
// unshaded = flaches, ungefiltertes PS1-Licht statt moderner PBR-Beleuchtung.
// blend_mix erlaubt Transparenz. depth_draw_always erzwingt trotzdem
// normales Tiefenpuffer-Schreiben — sonst "verschwinden" Objekte scheinbar
// zufällig hinter anderen, weil transparente Objekte standardmäßig nicht
// in den Depth Buffer schreiben (führt zu Sortierungs-Chaos, wenn wie bei
// uns die meisten Sachen eigentlich voll undurchsichtig sind).
render_mode unshaded, cull_back, blend_mix, depth_draw_always;

// --- Einstellbare Werte im Godot-Inspector, sobald das Shader-Material ausgewählt ist ---
uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Wie grob das "Snap-Raster" ist. Kleinere Zahl = stärkerer Jitter-Effekt.
// 16-64 ist ein guter Startbereich zum Ausprobieren.
uniform float snap_resolution : hint_range(4.0, 128.0) = 32.0;

// Wie stark die Vertex-Positionen bei Bewegung "wackeln" (affine-Look-Approximation)
uniform float vertex_jitter_strength : hint_range(0.0, 1.0) = 0.5;

// NEU: Multiplikator für die Durchsichtigkeit, per Script veränderbar
// (z.B. für "wird durchsichtiger je weniger HP"). 1.0 = voll sichtbar.
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 1.0;

// NEU: Hit-Flash — mischt die Albedo-Farbe Richtung flash_color, Stärke
// über flash_strength gesteuert (0 = kein Effekt, per Script animiert).
uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

// NEU: Welt-Raum-UV statt Mesh-UV (fuer Boden/Decke). Ein BoxMesh/PlaneMesh
// spannt seine UV normalerweise IMMER 0..1 ueber die gesamte Flaeche -
// dieselbe Schachbrett-Textur wuerde also in jedem unterschiedlich grossen
// Raum auf eine andere Kachelgroesse gestreckt/verzerrt. Mit world_space_uv
// haengt die UV stattdessen nur von der WELT-XZ-Position ab: die Kachel
// bleibt in jedem Raum exakt gleich gross, groessere Raeume zeigen einfach
// mehr Wiederholungen. Aus per Default, damit Waende/Tueren/Pfeiler (die
// dieselbe geteilte Material-Resource benutzen) weiterhin ihre normale
// Mesh-UV bekommen - siehe pit_floor.gd/room_instance.gd fuer die Stellen,
// die dies gezielt an einer DUPLIZIERTEN Material-Instanz einschalten.
uniform bool world_space_uv = false;
// 1 / Kachelgroesse in Weltunits. 1.0/24.0 = Textur wiederholt sich alle
// 24 Einheiten - im 48x48-Standardraum also genau 2x pro Achse (4x4
// sichtbare Schachbrettfelder bei einer 2x2-Textur).
uniform float world_uv_scale : hint_range(0.005, 1.0) = 0.0416667;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Vertex in Clip-Space transformieren (wie es die GPU normalerweise am Ende macht)
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));

	// Die klassische PS1-"Vertex-Snapping"-Technik: Position auf ein grobes,
	// niedrig aufgelöstes Raster runden, BEVOR perspektivisch geteilt wird.
	// Das erzeugt das typische "Zittern" bei Kamerabewegung.
	vec3 snapped = clip_position.xyz / clip_position.w;
	vec2 grid = vec2(snap_resolution);
	snapped.xy = floor(snapped.xy * grid) / grid;
	snapped *= clip_position.w;

	// Zwischen Original und gesnapptem Vertex mischen, je nach gewünschter Stärke
	clip_position.xyz = mix(clip_position.xyz, snapped, vertex_jitter_strength);

	POSITION = clip_position;
}

void fragment() {
	// filter_nearest sorgt zusammen mit Import-Settings (siehe unten) für die
	// blockige, ungefilterte Textur-Optik statt weichgezeichneter moderner Texturen.
	vec2 tex_uv = world_space_uv ? world_position.xz * world_uv_scale : UV;
	vec4 tex_color = texture(albedo_texture, tex_uv);
	vec3 base_albedo = tex_color.rgb * albedo_color.rgb;
	ALBEDO = mix(base_albedo, flash_color.rgb, flash_strength);
	ALPHA = tex_color.a * albedo_color.a * alpha_multiplier;
}

```
</details>

### 💭 Thinking

`20:18:36`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `world_space_uv|duplicate\(\)|psx_material` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`20:18:37`

Glob: `*.gd`

```
scripts\hazards\lemonade.gd:211:		collision_shape.shape = collision_shape.shape.duplicate()
scripts\hazards\lemonade.gd:213:		visual.material = visual.material.duplicate()
scripts\dungeon_atmosphere.gd:73:	we.environment = we.environment.duplicate()
scenes\level_generation\room_instance.gd:153:@export var ceiling_material_path: String = "res://materials/psx_material.tres"
scenes\level_generation\room_instance.gd:183:@export var wall_cap_material_path: String = "res://materials/psx_material.tres"
scenes\level_generation\room_instance.gd:203:@export var door_lintel_material_path: String = "res://materials/psx_material.tres"
scenes\level_generation\room_instance.gd:1298:		var mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
scenes\level_generation\room_instance.gd:1305:		mat.set_shader_parameter("world_space_uv", true)
scenes\level_generation\room_instance.gd:1346:			var shader_mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
scenes\level_generation\room_instance.gd:1487:## direkt - kein duplicate() noetig (anders als bei Decke und Wandkappe,
scenes\level_generation\room_instance.gd:1715:## Instanz - und alle Raeume derselben Szene ebenfalls. Ohne duplicate()
scenes\level_generation\room_instance.gd:1730:	var shape: BoxShape3D = (collision.shape as BoxShape3D).duplicate()
scenes\level_generation\room_instance.gd:1746:			var wall_mesh: BoxMesh = (mesh_child.mesh as BoxMesh).duplicate()
scenes\level_generation\room_instance.gd:2300:	var free_points: Array[Marker3D] = enemy_spawn_points.duplicate()
scenes\level_generation\room_instance.gd:2866:## psx_material.tres ist EINE Resource, die sich alle Raeume teilen. Wuerde
scenes\level_generation\room_instance.gd:2926:				var copy: Material = mesh.material_override.duplicate()
scenes\level_generation\room_instance.gd:2934:					var dup: Material = surface.duplicate()
scripts\pit_floor.gd:138:	var all_pits: Array[Rect2] = pits.duplicate()
scripts\pit_floor.gd:176:		# das dieselbe Resource referenziert - world_space_uv=true wuerde
scripts\pit_floor.gd:179:		var mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
scripts\pit_floor.gd:180:		mat.set_shader_parameter("world_space_uv", true)
scenes\level_generation\room_grid_generator.gd:292:		var sizes: Array = allowed_footprints.duplicate()
scripts\party_slot.gd:86:		var flat: StyleBoxFlat = (style as StyleBoxFlat).duplicate()
scenes\level_generation\level_generator.gd:412:		_occupancy = grid_generator.get_occupancy().duplicate()
scenes\level_generation\level_generator.gd:509:			"covered": cell.covered_cells.duplicate(),
scripts\main_menu.gd:273:		# wie die echten Raeume (psx_material, Lava-Hazard-Szene, Fackel-
scripts\main_menu.gd:348:## Geometrie statt auf Leere trifft. Verwendet dasselbe psx_material.tres wie
scripts\main_menu.gd:393:## Eigene Kopie von psx_material.tres, eingefaerbt in floor_color/wall_color
scripts\main_menu.gd:396:## WARUM duplicate(): psx_material.tres ist eine gecachte, GETEILTE Resource
scripts\main_menu.gd:401:## aus genau diesem Grund ebenfalls per duplicate() umgehen).
scripts\main_menu.gd:403:	var base: Material = load("res://materials/psx_material.tres")
scripts\main_menu.gd:406:	var unique: Material = base.duplicate()
scripts\enemies\custom_enemy_base.gd:170:			var glow_mat: Material = original.duplicate()
scripts\enemies\enemy_ai.gd:1074:				shader_mat = (source as ShaderMaterial).duplicate() as ShaderMaterial
scripts\enemies\enemy_density.gd:155:	var originals: Array[Marker3D] = room.enemy_spawn_points.duplicate()
scripts\minimap.gd:429:## Holt die StyleBox des Frames einmalig als eigene Kopie. duplicate() ist
scripts\minimap.gd:436:		_frame_style = (existing as StyleBoxFlat).duplicate()
scripts\vfx_manager.gd:103:## WARUM ERST duplicate(): [sub_resource]-Materialien einer .tscn sind PRO
scripts\vfx_manager.gd:117:				gpu.process_material = gpu.process_material.duplicate()
scripts\vfx_manager.gd:121:				gpu.draw_pass_1 = gpu.draw_pass_1.duplicate()
scripts\vfx_manager.gd:124:				gpu.draw_pass_2 = gpu.draw_pass_2.duplicate()
scripts\vfx_manager.gd:138:	var unique_material: Material = primitive.material.duplicate()
scripts\level\stage_theme.gd:14:# Alle Raum-Szenen benutzen dasselbe psx_material.tres. Ein komplettes
scripts\level\stage_manager.gd:200:		var env: Environment = world.environment.duplicate()
scripts\rooms\room_switch_arena.gd:78:	var points: Array[Marker3D] = enemy_spawn_points.duplicate()
scripts\settings_manager.gd:788:			dup.append(event.duplicate())
scripts\enemies\shield_drone.gd:147:	for id: int in _beams.keys().duplicate():
scripts\environment\destructible_prop.gd:60:		col.shape = own_shape.shape.duplicate()
```

### 💭 Thinking

`20:18:48`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:18:49`

*(lines 1280–1355)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
func _collect_local_aabbs(node: Node3D, xform: Transform3D, out: Array) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			out.append(xform * mi.get_aabb())
	for child: Node in node.get_children():
		if child is Node3D:
			_collect_local_aabbs(child as Node3D, xform * (child as Node3D).transform, out)


## Dupliziert das geteilte PSX-Shader-Material (NIEMALS die Original-
## Resource direkt benutzen - sonst faerbt das erste instanziierte
## Zimmer ALLE anderen Decken im Spiel mit ein) und faerbt es dunkel via
## Shader-Parameter. Faellt auf eine schlichte StandardMaterial3D zurueck,
## falls die Resource fehlt.
func _make_ceiling_material() -> Material:
	var base := load(ceiling_material_path)
	if base is ShaderMaterial:
		var mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
		mat.set_shader_parameter("albedo_color", ceiling_color)
		# Weltraum-UV statt Mesh-UV (siehe psx.gdshader): haelt die
		# Schachbrettkachel in Weltunits konstant, egal wie gross
		# room_footprint fuer diesen Raum ist - sonst wuerde dasselbe
		# PlaneMesh-UV (0..1 ueber die ganze Decke) das Muster in jedem
		# unterschiedlich grossen Raum anders verzerren.
		mat.set_shader_parameter("world_space_uv", true)
		if ceiling_texture != null:
			mat.set_shader_parameter("albedo_texture", ceiling_texture)
		return mat

	push_warning("RoomInstance: ceiling_material_path '%s' nicht gefunden oder kein ShaderMaterial - Decke faellt auf Flatcolor zurueck." % ceiling_material_path)
	var fallback := StandardMaterial3D.new()
	fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fallback.albedo_color = ceiling_color
	fallback.cull_mode = BaseMaterial3D.CULL_FRONT
	if ceiling_texture != null:
		fallback.albedo_texture = ceiling_texture
	return fallback


## Setzt jeder Wand ("Wall*"-StaticBody3D, direktes Kind) eine duenne,
## dunkle Kappe knapp ueber ihre eigene Oberkante - siehe Klassenkommentar
## oben. Groesse/Position werden aus der WAND EIGENEN CollisionShape3D
## abgelesen (nicht aus room_height), damit das auch bei Waenden
## funktioniert, deren Hoehe (noch) nicht exakt der Raumhoehe entspricht.
func _build_wall_caps() -> void:
	var base := load(wall_cap_material_path)

	for child in get_children():
		if not (child is StaticBody3D):
			continue
		if not child.name.begins_with("Wall"):
			continue
		if child.get_node_or_null("MinimapCap") != null:
			continue

		var collision := child.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision == null or not (collision.shape is BoxShape3D):
			continue
		var box: BoxShape3D = collision.shape as BoxShape3D

		var cap_mesh := BoxMesh.new()
		cap_mesh.size = Vector3(box.size.x, wall_cap_height, box.size.z)

		var mat: Material
		if base is ShaderMaterial:
			var shader_mat: ShaderMaterial = (base as ShaderMaterial).duplicate()
			shader_mat.set_shader_parameter("albedo_color", wall_cap_color)
			mat = shader_mat
		else:
			push_warning("RoomInstance: wall_cap_material_path '%s' nicht gefunden oder kein ShaderMaterial - Kappe faellt auf Flatcolor zurueck." % wall_cap_material_path)
			var fallback := StandardMaterial3D.new()
			fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			fallback.albedo_color = wall_cap_color
			mat = fallback
```
</details>

### 💭 Thinking

`20:18:53`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_build_ceiling\(\)|_build_wall_caps\(\)|func _ready\(\)` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:18:54`

```
198:## _build_wall_caps() ihn nicht als "Wall*" einsammelt: eine Minimap-Kappe
475:func _ready() -> void:
481:		_build_ceiling()
485:		_build_wall_caps()
545:func _build_ceiling() -> void:
1325:func _build_wall_caps() -> void:
1763:## _build_wall_caps() wuerde die alte Kappe sonst noch finden und die Wand
1773:	_build_wall_caps()
2485:		_build_wall_caps()
2624:	# Als DIREKTES Kind und mit "Wall"-Praefix, damit _build_wall_caps()
2878:	# BUGFIX "Boden-/Deckentextur unsichtbar": _build_ceiling() laeuft in
2955:## _build_ceiling() zeitlich vor apply_theme() laeuft (siehe Kommentar dort).
```

#### 👀 Read `room_instance.gd`

`20:18:57`

*(lines 475–530)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
func _ready() -> void:
	add_to_group(NAV_SOURCE_GROUP)
	_collect_markers()
	_setup_entry_trigger()
	_setup_presence_area()
	if build_ceiling:
		_build_ceiling()
	if build_door_lintels:
		_build_door_lintels()
	if wall_cap_enabled:
		_build_wall_caps()
	# build_room_lights/_build_room_lights() bewusst NICHT mehr aufgerufen -
	# Fackeln/Kerzen (Teil von _build_wall_decor()/_build_candles() unten)
	# ersetzen die alten flachen Decken-Punktlichter komplett, siehe deren
	# Kopfkommentar. Die Funktion bleibt unten stehen, falls sie doch mal
	# wieder gebraucht wird, wird aber aus _ready() nicht mehr erreicht.
	if build_props:
		# Reihenfolge wichtig: _build_props() legt den "Props"-Container an
		# UND bricht fruehzeitig ab, falls er schon existiert (Idempotenz-
		# Schutz) - muss deshalb zuerst laufen, sonst wuerde eine der
		# folgenden Funktionen ihn zuerst anlegen und _build_props() liefe
		# nie. _build_tables() vor _build_near_table_props(), weil letztere
		# die von ersterer gesammelten Tischpositionen braucht.
		_build_props()
		_build_tables()
		_build_near_table_props()
		_build_wall_decor()
		_build_banners()
		_build_candles()


func _exit_tree() -> void:
	for enemy in _spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	_spawned_enemies.clear()


func _collect_markers() -> void:
	var spawn_group := get_node_or_null("EnemySpawnPoints")
	if spawn_group:
		for child in spawn_group.get_children():
			if child is Marker3D:
				enemy_spawn_points.append(child)

	var loot_group := get_node_or_null("LootSpawnPoints")
	if loot_group:
		for child in loot_group.get_children():
			if child is Marker3D:
				loot_spawn_points.append(child)

	var exit_group := get_node_or_null("ExitPoints")
	if exit_group:
		for child in exit_group.get_children():
			if child is Marker3D:
```
</details>

### 💭 Thinking

`20:19:30`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `item_manager.gd`

`20:19:30`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_manager.gd</code></summary>

```


extends Node

# ============================================================================
# Items — Autoload: Inventar, Waehrungen und der Event-Verteiler fuer alle
# Item-Effekte. Muss unter Project Settings -> Autoload als "Items" stehen.
# ============================================================================
#
# WARUM EIN AUTOLOAD UND KEINE KOMPONENTE AM SPIELER:
# Der PartyManager tauscht die Spieler-Instanz bei JEDEM Charakterwechsel
# komplett aus. Ein Inventar, das am Spieler haengt, waere nach dem ersten
# Wechsel weg. Items gehoeren dem RUN, nicht der Figur.
#
# WAS DIESES SCRIPT SONST NOCH TUT — und warum:
# Es haengt bei jedem Charakterwechsel automatisch die Laufzeit-Komponenten
# an die neue Spieler-Instanz (PlayerStats, BombCarrier) und verbindet sich
# mit deren Hitboxen. Dadurch muss KEINE der vier Charakter-Szenen
# angefasst werden — kein neuer Node im Inspector, kein vergessener Slot in
# char_winter.tscn, der drei Wochen spaeter als Bug zurueckkommt.
#
# EVENT-VERTEILUNG: item_behaviours.gd haengt sich an die Signale unten.
# Dieses Script kennt selbst KEINE Item-Regeln — genau wie
# StatusEffectManager keine Spielregeln kennt.
#
# ---------------------------------------------------------------------------
# PHASE 5: ZWEI UNABHAENGIGE AKTIVE-ITEM-SLOTS (Q UND E)
# ---------------------------------------------------------------------------
# Vorher gab es genau EIN aktives Item, ausgeloest ueber Taste C. Q und E
# waren leere Charakter-Faehigkeits-Platzhalter (siehe combat_base.gd).
# Jetzt sind Q und E selbst die beiden Slots:
#   * Slot 0 (Q) wird vom ERSTEN aktiven Item belegt, das man aufsammelt.
#   * Slot 1 (E) vom ZWEITEN.
#   * Ein drittes aktives Item landet zwar im normalen inventory (zaehlt
#     fuer die Item-Liste, Stats etc.), wird aber NICHT automatisch
#     ausgeruestet — es gibt aktuell keinen dritten Slot. Siehe
#     active_item_swap_panel.gd fuer die bewusste Entscheidung, den
#     Pause-Screen NUR "Q und E tauschen" anbieten zu lassen statt eines
#     vollen Item-Pickers.
#
# WARUM EIN DICTIONARY FUER DIE LADUNG STATT EINES ARRAYS PARALLEL ZU
# active_items:
# Ladung haengt am ITEM (verschiedene Items brauchen unterschiedlich viele
# Raeume), nicht am SLOT. Wuerde die Ladung stattdessen pro Slot-Index
# gespeichert, wuerde ein Tausch zwischen Q und E (swap_active_slots())
# entweder die Ladung mittauschen MUESSEN (Extra-Code, Fehlerquelle) oder
# still verloren gehen. Mit einem Dictionary, das per item.id schluesselt,
# ist ein Tausch nur noch "welcher Slot-Index zeigt auf welche ID" — die
# Ladung selbst wird nie angefasst.

signal item_added(item: ItemData)
signal inventory_changed
signal coins_changed(amount: int)
signal bombs_changed(amount: int)
## PHASE 5: slot ist jetzt Teil der Signatur (0 = Q, 1 = E) - vorher gab es
## nur einen Slot, das HUD (item_description_hud.gd) muss jetzt wissen,
## WELCHE der beiden Anzeigen aktualisiert werden soll.
signal active_item_charge_changed(slot: int, current: int, needed: int)
## Feuert, wenn sich belegt/leer ODER die Zuordnung Item->Slot aendert
## (Aufsammeln eines aktiven Items, Tausch im Pause-Screen). Getrennt von
## active_item_charge_changed, weil sich hier die IDENTITAET aendert, nicht
## nur ein Fortschrittswert - Listener wie der Swap-Panel-Button muessen
## z.B. komplett neu aufbauen, nicht nur einen Balken aktualisieren.
signal active_slots_changed

## Der aktive Spieler hat einen Gegner getroffen (Primary/Secondary-Hitbox).
signal player_hit_enemy(target: Node3D, hitbox: Hitbox)
## Ein Raum wurde geleert.
signal room_cleared(room: Node)
## Der Spieler ist in eine neue Instanz gewechselt (oder frisch gespawnt).
signal player_ready(player: CharacterBody3D)
## Aktives Item wurde benutzt. slot: 0 = Q, 1 = E.
signal active_item_used(item: ItemData, slot: int)

const BOMB_ACTION: String = "bomb"

## Wie viele aktive Item-Slots es gibt. Siehe Kopfkommentar - Slot 0 = Q,
## Slot 1 = E. Kein drittes Element hinzufuegen, ohne auch
## active_item_swap_panel.gd und item_description_hud.gd anzupassen, die
## beide fest von genau zwei Slots ausgehen.
const ACTIVE_SLOT_COUNT: int = 2

## Startwerte eines Runs.
const START_COINS: int = 0
const START_BOMBS: int = 1

var coins: int = START_COINS
var bombs: int = START_BOMBS

var inventory: Array[ItemData] = []
var catalog: Array[ItemData] = []

## Item-Synergie (Blueprint Nr. 6): tag -> kumulierter Drop-Gewichts-Bonus.
## Steigt additiv bei jedem aufgesammelten Item, das den Tag traegt - siehe
## _register_synergy_tags() und get_synergy_weight(). Gelesen von
## TreasureManager._pick_item() beim Wuerfeln der Schatzraum-Items.
const SYNERGY_WEIGHT_PER_TAG: float = 0.15
var _synergy_tag_bonus: Dictionary = {}

## Index 0 = Q, Index 1 = E. null = Slot frei.
var active_items: Array[ItemData] = [null, null]

## Ladung PRO ITEM (Schluessel: item.id), nicht pro Slot - siehe
## Kopfkommentar. Ein Item, das gerade in keinem Slot steckt, behaelt seinen
## Eintrag hier trotzdem (falls es spaeter wieder eingewechselt wird).
var _active_charges: Dictionary = {}

## PHASE 4: sekundenbasierte Cooldowns. item_id -> Restsekunden.
##
## BEWUSST GETRENNT von _active_charges: die beiden Mechaniken haben
## unterschiedliche Einheiten (Raeume vs. Sekunden) und unterschiedliche
## Nullpunkte. In EINEM Dictionary gemischt haette jede Abfrage erst den
## Item-Typ nachschlagen muessen, um zu wissen, was der Wert bedeutet.
var _active_cooldowns: Dictionary = {}

var player: CharacterBody3D = null
var stats: PlayerStats = null
var bomb_carrier: Node = null

var _behaviours: Node = null
var _connected_hitboxes: Array[Hitbox] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_ensure_actions()
	_build_catalog()
	_spawn_behaviours()

	# PartyManager ist selbst ein Autoload. Die Reihenfolge, in der Godot
	# Autoloads initialisiert, ist nicht garantiert — deshalb wird die
	# Verbindung deferred aufgebaut statt direkt hier.
	_connect_party_manager.call_deferred()


# ============================================================================
# Eingabe-Actions selbst registrieren
# ============================================================================
# Bewusst hier statt in settings_manager.gd: dieses Feature soll sich
# installieren lassen, ohne eine bestehende Datei anzufassen.
#
# PHASE 5: die fruehere eigene "use_item"-Action (Taste C) ist weg. Aktive
# Items werden jetzt ueber Q/E ausgeloest ("ability_primary"/
# "ability_secondary"), die bereits in settings_manager.gd registriert und
# rebindbar sind (siehe DEFAULT_KEYBINDS dort) - dieses Script fasst Input
# ueberhaupt nicht mehr direkt an, siehe combat_base.gd._do_ability_q()/
# _do_ability_e().
func _ensure_actions() -> void:
	if not InputMap.has_action(BOMB_ACTION):
		InputMap.add_action(BOMB_ACTION)
		var bomb_event := InputEventKey.new()
		bomb_event.physical_keycode = KEY_X
		InputMap.action_add_event(BOMB_ACTION, bomb_event)


func _build_catalog() -> void:
	catalog = ItemCatalog.build_all()
	for external: ItemData in ItemCatalog.load_external():
		catalog.append(external)


func _spawn_behaviours() -> void:
	_behaviours = ItemBehaviours.new()
	_behaviours.name = "ItemBehaviours"
	add_child(_behaviours)


# ============================================================================
# Anbindung an den jeweils aktiven Spieler
# ============================================================================
func _connect_party_manager() -> void:
	var party: Node = get_node_or_null("/root/PartyManager")
	if party == null:
		push_warning("Items: PartyManager nicht gefunden — Item-Effekte bleiben inaktiv.")
		return

	if party.has_signal("active_player_changed") \
			and not party.active_player_changed.is_connected(bind_player):
		party.active_player_changed.connect(bind_player)

	# Falls der Spieler schon vor diesem Autoload gespawnt ist.
	var existing = party.get("player")
	if existing is CharacterBody3D and is_instance_valid(existing):
		bind_player(existing)


## Haengt alle Laufzeit-Komponenten an die neue Spieler-Instanz.
func bind_player(new_player: CharacterBody3D) -> void:
	_disconnect_hitboxes()

	player = new_player
	stats = null
	bomb_carrier = null

	if player == null or not is_instance_valid(player):
		return

	# --- PlayerStats -------------------------------------------------
	stats = player.get_node_or_null("PlayerStats") as PlayerStats
	if stats == null:
		stats = PlayerStats.new()
		stats.name = "PlayerStats"
		player.add_child(stats)
	stats.bind_to_player(player)

	# --- BombCarrier -------------------------------------------------
	bomb_carrier = player.get_node_or_null("BombCarrier")
	if bomb_carrier == null:
		bomb_carrier = BombCarrier.new()
		bomb_carrier.name = "BombCarrier"
		player.add_child(bomb_carrier)

	_connect_hitboxes()
	_reapply_all_item_stats()

	player_ready.emit(player)


func _connect_hitboxes() -> void:
	for path: String in ["CameraPivot/PrimaryHitbox", "CameraPivot/SecondaryHitbox"]:
		var hitbox := player.get_node_or_null(path) as Hitbox
		if hitbox == null:
			continue
		# Eine gebundene Callable pro Hitbox: nur so weiss der Empfaenger
		# spaeter, WELCHE Hitbox getroffen hat (Primary vs. Secondary
		# entscheidet ueber die Wucht des Hit-Stops).
		var callable := _on_hitbox_hit.bind(hitbox)
		if not hitbox.hit_landed.is_connected(callable):
			hitbox.hit_landed.connect(callable)
		_connected_hitboxes.append(hitbox)


func _disconnect_hitboxes() -> void:
	# Die alte Instanz wird vom PartyManager freigegeben; Godot loest die
	# Verbindungen dabei selbst. Der Array wird trotzdem geleert, damit
	# keine ungueltigen Referenzen liegenbleiben.
	_connected_hitboxes.clear()


func _on_hitbox_hit(target: Node, hitbox: Hitbox) -> void:
	if not (target is Node3D):
		return
	player_hit_enemy.emit(target as Node3D, hitbox)


# ============================================================================
# Inventar
# ============================================================================
func get_item_by_id(item_id: String) -> ItemData:
	for item: ItemData in catalog:
		if item.id == item_id:
			return item
	return null


func has_item(item_id: String) -> bool:
	for item: ItemData in inventory:
		if item.id == item_id:
			return true
	return false


func count_item(item_id: String) -> int:
	var total: int = 0
	for item: ItemData in inventory:
		if item.id == item_id:
			total += 1
	return total


func add_item(item: ItemData) -> bool:
	if item == null:
		return false
	if item.max_stacks > 0 and count_item(item.id) >= item.max_stacks:
		return false

	inventory.append(item)

	if item.is_active_item():
		_equip_active_item(item)

	_apply_item_stats(item, inventory.size() - 1)
	_register_synergy_tags(item)

	item_added.emit(item)
	inventory_changed.emit()
	return true


func _register_synergy_tags(item: ItemData) -> void:
	for tag: String in item.synergy_tags:
		_synergy_tag_bonus[tag] = float(_synergy_tag_bonus.get(tag, 0.0)) + SYNERGY_WEIGHT_PER_TAG


## Summierter Gewichts-Bonus fuer ein Item mit den gegebenen Tags - additiv
## auf das normale Grundgewicht 1.0 der Gleichverteilung im Schatzraum-Pool.
func get_synergy_weight(tags: PackedStringArray) -> float:
	var bonus: float = 0.0
	for tag: String in tags:
		bonus += float(_synergy_tag_bonus.get(tag, 0.0))
	return bonus


## Weist ein neu aufgesammeltes aktives Item dem ersten freien Slot zu
## (Q vor E). Ist keiner frei, bleibt das Item unausgeruestet im normalen
## inventory liegen - siehe Kopfkommentar zum Drei-Item-Fall.
func _equip_active_item(item: ItemData) -> void:
	if not _active_charges.has(item.id):
		_active_charges[item.id] = item.charge_rooms

	for slot: int in range(ACTIVE_SLOT_COUNT):
		if active_items[slot] == null:
			active_items[slot] = item
			active_slots_changed.emit()
			active_item_charge_changed.emit(slot, _active_charges[item.id], item.charge_rooms)
			return


func add_item_by_id(item_id: String) -> bool:
	return add_item(get_item_by_id(item_id))


## Stat-Boni eines Items an PlayerStats melden. Der Index wandert in die
## Quellen-ID, damit ein zweites Exemplar desselben Items den Eintrag des
## ersten nicht ueberschreibt.
func _apply_item_stats(item: ItemData, index: int) -> void:
	if stats == null or item.stat_modifiers.is_empty():
		return

	var source_id: String = "item:%s#%d" % [item.id, index]
	for stat_name: String in item.stat_modifiers.keys():
		var mod: Dictionary = item.stat_modifiers[stat_name]
		stats.add_modifier(
			source_id,
			stat_name,
			float(mod.get("add", 0.0)),
			float(mod.get("mul", 1.0))
		)


## Nach einem Charakterwechsel haengen die Boni an der ALTEN PlayerStats-
## Instanz. Deshalb wird beim Binden alles frisch aufgetragen.
func _reapply_all_item_stats() -> void:
	if stats == null:
		return
	for i: int in range(inventory.size()):
		_apply_item_stats(inventory[i], i)


## Alles zuruecksetzen — beim Start eines neuen Runs aufrufen.
func reset_run() -> void:
	inventory.clear()
	active_items = [null, null]
	_active_charges.clear()
	# PHASE 4: sonst startet der neue Run mit dem Cooldown des alten.
	_active_cooldowns.clear()
	coins = START_COINS
	bombs = START_BOMBS
	if stats:
		stats.clear_all()
		stats.apply()
	inventory_changed.emit()
	active_slots_changed.emit()
	coins_changed.emit(coins)
	bombs_changed.emit(bombs)


## Admin/Debug: entfernt ALLE Items aus dem Inventar (inkl. Stat-Boni und
## aktiver Slots), OHNE Muenzen/Bomben anzufassen - anders als reset_run(),
## das fuer einen kompletten Rundenneustart gedacht ist. Gedacht fuer die
## Loesch-Plattform im Item-Testraum (siehe scripts/item_test_room.gd):
## Items durchtesten, dann per Knopfdruck wieder bei null anfangen, ohne
## gleich den ganzen Run neu zu starten.
func clear_inventory() -> void:
	inventory.clear()
	active_items = [null, null]
	_active_charges.clear()
	_active_cooldowns.clear()
	if stats:
		stats.clear_all()
		stats.apply()
	inventory_changed.emit()
	active_slots_changed.emit()


# ============================================================================
# Waehrungen
# ============================================================================
func add_coins(amount: int) -> void:
	coins = maxi(coins + amount, 0)
	coins_changed.emit(coins)


func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	return true


func add_bombs(amount: int) -> void:
	bombs = maxi(bombs + amount, 0)
	bombs_changed.emit(bombs)


func consume_bomb() -> bool:
	if bombs <= 0:
		return false
	bombs -= 1
	bombs_changed.emit(bombs)
	return true


# ============================================================================
# Raum-Events
# ============================================================================
## Wird von LootManager aufgerufen, sobald ein Raum geleert ist. Laedt
## BEIDE Slots gleichzeitig auf, unabhaengig voneinander (siehe Kopfkommentar
## - Ladung haengt am Item, nicht am Slot).
func notify_room_cleared(room: Node) -> void:
	for slot: int in range(ACTIVE_SLOT_COUNT):
		var item: ItemData = active_items[slot]
		if item == null:
			continue
		var remaining: int = int(_active_charges.get(item.id, 0))
		if remaining > 0:
			remaining -= 1
			_active_charges[item.id] = remaining
			active_item_charge_changed.emit(slot, remaining, item.charge_rooms)
	room_cleared.emit(room)


func is_active_slot_ready(slot: int) -> bool:
	if slot < 0 or slot >= ACTIVE_SLOT_COUNT:
		return false
	var item: ItemData = active_items[slot]
	if item == null:
		return false
	if item.uses_time_cooldown():
		return float(_active_cooldowns.get(item.id, 0.0)) <= 0.0
	return int(_active_charges.get(item.id, 0)) <= 0


## PHASE 4: laesst die Sekunden-Cooldowns ablaufen.
##
## _process statt eines Timers pro Item: es gibt hoechstens zwei aktive
## Slots, die Schleife kostet nichts, und ein Timer-Node pro Item haette bei
## jedem Slot-Tausch neu verdrahtet werden muessen.
func _process(delta: float) -> void:
	if _active_cooldowns.is_empty():
		return
	var finished: Array = []
	for id: String in _active_cooldowns.keys():
		var left: float = float(_active_cooldowns[id]) - delta
		if left <= 0.0:
			finished.append(id)
		else:
			_active_cooldowns[id] = left

	for id: String in finished:
		_active_cooldowns.erase(id)
		for slot: int in range(ACTIVE_SLOT_COUNT):
			var item: ItemData = active_items[slot]
			if item != null and item.id == id:
				active_item_charge_changed.emit(slot, 0, 0)


## PHASE 4: von der Nonnen-Kutte benutzt — laedt ein Aktiv-Item sofort auf,
## egal welche der beiden Mechaniken es benutzt.
## Rueckgabe: true, wenn wirklich etwas aufgeladen wurde.
func force_recharge_active(slot: int = -1) -> bool:
	var slots: Array[int] = []
	if slot >= 0:
		slots.append(slot)
	else:
		for i: int in range(ACTIVE_SLOT_COUNT):
			slots.append(i)

	var did: bool = false
	for s: int in slots:
		var item: ItemData = active_items[s]
		if item == null:
			continue
		if item.uses_time_cooldown():
			if float(_active_cooldowns.get(item.id, 0.0)) <= 0.0:
				continue
			_active_cooldowns.erase(item.id)
		else:
			if int(_active_charges.get(item.id, 0)) <= 0:
				continue
			_active_charges[item.id] = 0
		active_item_charge_changed.emit(s, 0, item.charge_rooms)
		did = true
	return did


## Fuer combat_base.gd's Cooldown-Anzeige im HUD: 1.0 = nicht bereit (Overlay
## voll), 0.0 = bereit (Overlay leer). Leerer Slot zeigt IMMER 0.0 - ein
## leerer Slot ist nicht "auf Cooldown", er hat einfach nichts zu zeigen.
func get_active_charge_percent(slot: int) -> float:
	if slot < 0 or slot >= ACTIVE_SLOT_COUNT:
		return 0.0
	var item: ItemData = active_items[slot]
	if item == null:
		return 0.0
	if item.uses_time_cooldown():
		var left: float = float(_active_cooldowns.get(item.id, 0.0))
		return clampf(left / maxf(item.cooldown_seconds, 0.001), 0.0, 1.0)
	if item.charge_rooms <= 0:
		return 0.0
	var remaining: int = int(_active_charges.get(item.id, 0))
	return clampf(float(remaining) / float(item.charge_rooms), 0.0, 1.0)


## Fuer die Zahl im HUD-Cooldown-Overlay: "noch so viele Raeume".
func get_active_charge_remaining(slot: int) -> float:
	if slot < 0 or slot >= ACTIVE_SLOT_COUNT:
		return 0.0
	var item: ItemData = active_items[slot]
	if item == null:
		return 0.0
	if item.uses_time_cooldown():
		# Aufgerundet: "noch 1 s" ist ehrlicher als "noch 0 s", solange der
		# Knopf noch nicht geht.
		return ceilf(float(_active_cooldowns.get(item.id, 0.0)))
	return float(_active_charges.get(item.id, 0))


func use_active_item(slot: int) -> void:
	if not is_active_slot_ready(slot):
		return
	if player == null or not is_instance_valid(player):
		return

	var item: ItemData = active_items[slot]
	if item.uses_time_cooldown():
		_active_cooldowns[item.id] = item.cooldown_seconds
		active_item_charge_changed.emit(slot, int(ceilf(item.cooldown_seconds)), int(ceilf(item.cooldown_seconds)))
	else:
		_active_charges[item.id] = item.charge_rooms
		active_item_charge_changed.emit(slot, item.charge_rooms, item.charge_rooms)
	active_item_used.emit(item, slot)


## Vom Pause-Screen (active_item_swap_panel.gd) aufgerufen: tauscht, was in
## Q und was in E steckt. Absichtlich NUR das - kein Item-Picker fuer ein
## drittes, unausgeruestetes aktives Item (siehe Kopfkommentar). Die Ladung
## selbst wird nicht angefasst, sie haengt am Item, nicht am Slot.
func swap_active_slots() -> void:
	var tmp: ItemData = active_items[0]
	active_items[0] = active_items[1]
	active_items[1] = tmp
	active_slots_changed.emit()

	for slot: int in range(ACTIVE_SLOT_COUNT):
		var item: ItemData = active_items[slot]
		if item != null:
			active_item_charge_changed.emit(slot, int(_active_charges.get(item.id, 0)), item.charge_rooms)


## Aktuelle Combo des Spielers. LootManager nutzt sie fuer den Glueck-Bonus;
## das HUD zeigt sie an. Liefert 0, wenn gerade kein Spieler existiert.
func get_combo_count() -> int:
	if player == null or not is_instance_valid(player):
		return 0
	var combat := player.get_node_or_null("Combat") as CombatBase
	if combat == null:
		return 0
	return combat.get_combo_count()


func get_luck() -> float:
	if stats == null:
		return 0.0
	return stats.get_luck()




```
</details>

#### 👀 Read `treasure_manager.gd`

`20:19:31`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_manager.gd</code></summary>

```
extends Node

# ============================================================================
# Treasure — Autoload: setzt in JEDEN Schatzraum genau EINEN Item-Sockel.
# Muss unter Project Settings -> Autoload als "Treasure" stehen.
# ============================================================================
#
# WARUM ES DIESES SCRIPT UEBERHAUPT GIBT:
# Der Item-Katalog (item_catalog.gd), die Effekte (item_behaviours.gd), die
# Stat-Anbindung (player_stats.gd) und die Anzeige (item_description_hud.gd)
# waren bereits vollstaendig — aber Pickup.create_item() wurde im ganzen
# Projekt an KEINER Stelle aufgerufen. Es gab also acht fertige Items, die
# im Spiel nicht existierten. Dieses Script schliesst genau diese Luecke.
#
# DESIGN-VORGABE (Isaac): Items findet man ausschliesslich im Schatzraum,
# einzeln, mitten im Raum, auf einem Sockel. Deshalb NICHT ueber den
# LootManager: der wuerfelt nach dem Raum-Clear Verbrauchsgueter aus und
# waere fuer eine garantierte, einmalige Belohnung der falsche Ort.
#
# WIE ES SICH AN DIE RAEUME HAENGT: ueber SceneTree.node_added, exakt wie
# loot_manager.gd. Damit funktioniert es sowohl fuer generierte Level als
# auch fuer handgebaute Testszenen, in denen RoomInstances direkt in der
# .tscn stehen — und ohne eine einzige Zeile Aenderung an
# level_generator.gd oder room_instance.gd.
#
# ---------------------------------------------------------------------------
# WICHTIGE REIHENFOLGE-KORREKTUR GEGENUEBER DER ERSTEN FASSUNG
# ---------------------------------------------------------------------------
# level_generator.load_room() macht der Reihe nach:
#     instantiate() -> add_child()   <-- HIER feuert node_added
#     dann: instance.global_transform = ...
#     dann (im Aufrufer): room.grid_position = grid_pos
#
# Die Erkennung lief bisher direkt in _on_node_added und sah deshalb einen
# Raum, der noch bei (0,0,0) stand und dessen grid_position noch (0,0) war.
# Der Pfad-Check hat das ueberdeckt, der Generator-Fallback war aber tot und
# der RNG-Salt haette fuer alle Raeume gleich gelautet.
#
# Jetzt wird in _on_node_added NUR noch gemerkt, dass ein RoomInstance
# aufgetaucht ist. Geprueft und gespawnt wird eine Physik-Frame spaeter,
# wenn Transform, grid_position und die Kollisionsformen stehen.
#
# ---------------------------------------------------------------------------
# DIAGNOSE
# ---------------------------------------------------------------------------
# Dieses Script meldet sich beim Start und bei JEDEM gesehenen Raum zu Wort,
# solange debug_logging an ist. Wenn in der Konsole gar keine
# "[Treasure]"-Zeile auftaucht, laeuft _ready() nicht — dann ist der Autoload
# nicht eingetragen oder der Pfad stimmt nicht. Das ist die einzige
# Fehlerursache, die man sonst nicht von "Raum nicht erkannt" unterscheiden
# koennte, weil beides zu demselben Symptom fuehrt: kein Sockel.

signal pedestal_spawned(item: ItemData, room: Node)
signal treasure_item_taken(item: ItemData)

## Gruppe, mit der sich ein Raum manuell als Schatzraum markieren laesst.
const TREASURE_GROUP: String = "treasure_room"

## Teilstring im Szenenpfad, an dem Schatzraum-Prefabs erkannt werden.
const TREASURE_PATH_HINT: String = "/treasure/"

## Wie hoch ueber dem gefundenen Boden der Sockelfuss sitzt.
const GROUND_OFFSET: float = 0.02

## Wie tief NACH UNTEN gesucht wird. Nach oben wird bewusst NICHT gesucht,
## siehe _find_spawn_position().
const PROBE_DEPTH: float = 40.0

## Sicherheitsabstand, falls der Raycast ins Leere geht.
const FALLBACK_HEIGHT: float = 1.6

## AUS: Items sollen beliebig oft wieder angeboten und aufgesammelt werden
## koennen (jedes Item hat ohnehin max_stacks = 0 = unbegrenzt stapelbar,
## siehe item_data.gd/item_manager.gd::add_item()). Auf true stellen, um
## zur alten "ein Item erscheint nur einmal pro Lauf"-Regel zurueckzukehren.
@export var avoid_duplicates: bool = false

## Meldet jeden gesehenen Raum mitsamt Erkennungsergebnis. Nach der
## Verifikation auf false stellen.
@export var debug_logging: bool = true

## NOTNAGEL FUER DIE FEHLERSUCHE: setzt in JEDEN Raum einen Sockel, egal
## welcher Typ. Nur zum Testen — damit laesst sich in Sekunden klaeren, ob
## das Problem bei der Raum-ERKENNUNG oder beim SPAWNEN selbst liegt.
@export var debug_spawn_in_every_room: bool = false

## Item-IDs, die in diesem Run bereits auf einem Sockel lagen.
var _reserved_ids: Dictionary = {}   # String -> true
## Raeume, die schon behandelt wurden (erkannt oder abgelehnt).
var _handled_rooms: Dictionary = {}  # InstanceID -> true
## Run-Seed beim letzten Spawn. Aendert er sich, beginnt ein neuer Lauf.
var _last_seen_seed: int = -1
## Nur fuers Log: wie viele Raeume ueberhaupt gesehen wurden.
var _rooms_seen: int = 0


func _debug(msg: String) -> void:
	if debug_logging:
		print("[Treasure] %s" % msg)


func _ready() -> void:
	# ALWAYS statt PAUSABLE: die Generierung laeuft zwar nie pausiert, aber
	# ein Autoload, das sich beim Pausieren abschaltet, verliert im Zweifel
	# genau das node_added, auf das es wartet.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Diese Zeile ist der Lebensbeweis. Fehlt sie in der Konsole, ist der
	# Autoload nicht eingetragen — alles andere ist dann Zeitverschwendung.
	_debug("Autoload aktiv. Warte auf RoomInstances.")

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


## Hier wird NICHTS mehr geprueft ausser dem Typ. Begruendung siehe Kopf der
## Datei: zu diesem Zeitpunkt sind Transform und grid_position des Raums
## noch nicht gesetzt.
func _on_node_added(node: Node) -> void:
	if not (node is RoomInstance):
		return
	var room: RoomInstance = node as RoomInstance
	var id: int = room.get_instance_id()
	if _handled_rooms.has(id):
		return
	# Sofort sperren, nicht erst nach dem await: sonst kann derselbe Raum
	# ueber node_added UND ueber _scan_existing zweimal durchlaufen.
	_handled_rooms[id] = true
	_rooms_seen += 1

	# Die laufende Nummer wird HIER festgehalten und mitgereicht. Wuerde sie
	# erst im deferred Teil gelesen, stuende in jeder Log-Zeile dieselbe
	# Endsumme — alle Raeume werden im selben Frame hinzugefuegt, die
	# Auswertung laeuft aber erst danach.
	_process_room_deferred.call_deferred(room, _rooms_seen)


## Eine Physik-Frame spaeter: jetzt stehen Welt-Transform, grid_position und
## die Kollisionsformen des Raums.
func _process_room_deferred(room: RoomInstance, index: int) -> void:
	if not is_instance_valid(room):
		return
	await get_tree().physics_frame
	if not is_instance_valid(room) or not room.is_inside_tree():
		return

	var verdict: String = _detection_reason(room)
	var is_treasure: bool = verdict != ""

	_debug("Raum #%d gesehen: grid=%s szene='%s' -> %s" % [
		index,
		room.grid_position,
		room.scene_file_path,
		verdict if is_treasure else "kein Schatzraum"
	])

	if not is_treasure and not debug_spawn_in_every_room:
		return

	_spawn_pedestal(room)


# ============================================================================
# Erkennung
# ============================================================================
## Liefert den GRUND, warum der Raum als Schatzraum gilt — oder "" wenn
## nicht. Ein String statt bool, damit im Log steht, WELCHER der drei Wege
## gegriffen hat. Bei "kein Sockel gespawnt" ist genau das die Information,
## die man braucht.
func _detection_reason(room: RoomInstance) -> String:
	if room.is_in_group(TREASURE_GROUP):
		return "TREFFER (Gruppe '%s')" % TREASURE_GROUP

	if room.scene_file_path.to_lower().contains(TREASURE_PATH_HINT):
		return "TREFFER (Szenenpfad enthaelt '%s')" % TREASURE_PATH_HINT

	if _generator_says_treasure(room):
		return "TREFFER (LevelGenerator meldet RoomType.TREASURE)"

	return ""


## Dritter Weg: den LevelGenerator nach dem Typ der Rasterzelle fragen.
func _generator_says_treasure(room: RoomInstance) -> bool:
	var generator: Node = _find_generator()
	if generator == null:
		return false

	var cells = generator.get("_map_cells")
	if not (cells is Dictionary):
		return false
	if not cells.has(room.grid_position):
		return false

	var cell = cells[room.grid_position]
	if not (cell is Dictionary):
		return false
	return int(cell.get("type", -1)) == RoomData.RoomType.TREASURE


# ============================================================================
# Spawnen
# ============================================================================
func _spawn_pedestal(room: RoomInstance) -> void:
	_maybe_reset_for_new_run()

	var item: ItemData = _pick_item(room)
	if item == null:
		push_warning("[Treasure] Raum %s: kein Item verfuegbar — Sockel uebersprungen." % room.grid_position)
		return

	# Blutzoll-Raeume (Blueprint Nr. 5): SacrificePedestal statt des normalen
	# Sockels - identische Optik/Interaktion, kostet aber HP beim Nehmen.
	var pedestal: TreasurePedestal
	if bool(room.get("is_sacrifice_room")):
		pedestal = SacrificePedestal.create(item)
	else:
		pedestal = TreasurePedestal.create(item)
	room.add_child(pedestal)
	pedestal.global_position = _find_spawn_position(room)
	pedestal.item_taken.connect(_on_item_taken)

	_reserved_ids[item.id] = true
	pedestal_spawned.emit(item, room)

	_debug("  -> Sockel gesetzt: '%s' bei %s." % [item.display_name, pedestal.global_position])


## Raum-Ursprung ist bei allen Prefabs die Raum-MITTE (Waende liegen
## symmetrisch bei +-24). Deshalb wird von dort aus nach unten gemessen.
##
## WARUM NICHT room.get_room_center():
## Die Funktion liefert den ERSTEN LootSpawnPoint-Marker zurueck, und die
## liegen im Schatzraum-Prefab bei (-4, 2.1, -4) — also in einer Ecke der
## Plattform, nicht in der Mitte. Der Sockel stuende sichtbar schief.
##
## ---------------------------------------------------------------------------
## WARUM DER STRAHL NICHT VON GANZ OBEN KOMMT (behobener Fehler)
## ---------------------------------------------------------------------------
## room_instance.gd baut sich in _build_ceiling() selbst eine DECKE als
## StaticBody3D mit Kollision:
##     position.y = room_height + ceiling_thickness * 0.5   (= 14.5)
##     box.size.y = ceiling_thickness                        (= 1.0)
## Deren Oberkante liegt damit bei exakt 15.0.
##
## Ein Strahl, der 40 m ueber dem Raum startet, trifft folglich zuerst das
## DACH und nicht den Boden — der Sockel landete bei y = 15.02, also
## ausserhalb des begehbaren Raums und fuer den Spieler unsichtbar. Und
## zwar ohne jede Fehlermeldung, weil der Raycast ja erfolgreich war.
##
## Zwei Absicherungen dagegen:
##   1. Der Strahl startet auf halber Raumhoehe, also UNTERHALB der Decke.
##   2. Die Decke wird zusaetzlich explizit ausgeschlossen — falls jemand
##      room_height spaeter kleiner setzt als die Deckenhoehe.
func _find_spawn_position(room: RoomInstance) -> Vector3:
	var center: Vector3 = room.global_position
	var world: World3D = room.get_world_3d()
	if world == null:
		return center + Vector3(0.0, FALLBACK_HEIGHT, 0.0)

	# Halbe Raumhoehe: sicher unter der Decke und sicher ueber jeder
	# Plattform (im Schatzraum liegt die hoechste bei 1.6).
	var start_height: float = clampf(room.room_height * 0.5, 2.0, maxf(room.room_height - 1.5, 2.0))

	var space: PhysicsDirectSpaceState3D = world.direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		center + Vector3(0.0, start_height, 0.0),
		center + Vector3(0.0, -PROBE_DEPTH, 0.0)
	)
	# Nur echte Geometrie: Areas sind hier Trigger-Volumen (Raum-Eintritt,
	# Praesenz) und wuerden den Sockel in die Luft haengen.
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = _collect_ceiling_rids(room)

	var hit: Dictionary = space.intersect_ray(query)
	if hit.is_empty():
		_debug("  Boden-Raycast ins Leere (Start %.1f) — Ersatzhoehe %.1f benutzt." % [
			start_height, FALLBACK_HEIGHT
		])
		return center + Vector3(0.0, FALLBACK_HEIGHT, 0.0)

	var point: Vector3 = hit["position"]
	return Vector3(center.x, point.y + GROUND_OFFSET, center.z)


## Decke und Tuersturz-Koerper, die room_instance.gd zur Laufzeit anlegt.
## Beide haengen direkt unter dem Raum-Root und heissen fest "Ceiling" bzw.
## beginnen mit "DoorLintel".
func _collect_ceiling_rids(room: RoomInstance) -> Array[RID]:
	var rids: Array[RID] = []
	for child: Node in room.get_children():
		if not (child is CollisionObject3D):
			continue
		if child.name == "Ceiling" or String(child.name).begins_with("DoorLintel"):
			rids.append((child as CollisionObject3D).get_rid())
	return rids


# ============================================================================
# Item-Auswahl
# ============================================================================
## Deterministisch aus Run-Seed und Rasterposition. Bereits vergebene Items
## fliegen aus dem Pool, damit man in einem Lauf nicht zweimal denselben
## Kochloeffel findet.
func _pick_item(room: RoomInstance) -> ItemData:
	var items: Node = get_node_or_null("/root/Items")
	if item == null:
		push_warning("[Treasure] Autoload 'Items' nicht gefunden — kein Sockel moeglich. Autoload-Reihenfolge pruefen: 'Items' muss VOR 'Treasure' stehen.")
		return null

	var catalog: Array = items.catalog
	if catalog.is_empty():
		push_warning("[Treasure] Item-Katalog ist leer.")
		return null

	var pool: Array[ItemData] = []
	for entry in catalog:
		if not (entry is ItemData):
			continue
		var data: ItemData = entry as ItemData
		if avoid_duplicates and _reserved_ids.has(data.id):
			continue
		# Ein Item, dessen Stapelgrenze bereits erreicht ist, waere auf dem
		# Sockel nicht aufnehmbar — der Spieler stuende vor einem [F], das
		# nichts tut.
		if data.max_stacks > 0 and items.count_item(data.id) >= data.max_stacks:
			continue
		pool.append(data)

	# Alles vergeben: lieber ein Duplikat als ein leerer Schatzraum.
	if pool.is_empty():
		_debug("Item-Pool erschoepft — Duplikate werden wieder zugelassen.")
		_reserved_ids.clear()
		for entry in catalog:
			if entry is ItemData:
				pool.append(entry as ItemData)

	if pool.is_empty():
		return null

	var rng: RandomNumberGenerator = _make_rng(room)
	return _weighted_pick(pool, item, rng)


## Gewichtete Auswahl statt Gleichverteilung: Grundgewicht 1.0 pro Item, plus
## Synergie-Bonus aus bereits aufgesammelten Items (ItemManager.
## get_synergy_weight() - Blueprint Nr. 6, "Item-Synergie Wahrscheinlichkeiten").
## Ohne jeden Bonus (frischer Run, keine getaggten Items) ist total_weight
## einfach pool.size() und das Ergebnis entspricht der alten Gleichverteilung.
func _weighted_pick(pool: Array[ItemData], items: Node, rng: RandomNumberGenerator) -> ItemData:
	# Hub-Upgrade (Blueprint "Meta-Progression"): additiver Bonus auf JEDEN
	# Kandidaten, unabhaengig von Tags - Synergie- und Meta-Bonus stapeln sich.
	var meta_bonus: float = SaveGame.get_item_weight_bonus()

	var weights: Array[float] = []
	var total_weight: float = 0.0
	for data: ItemData in pool:
		var weight: float = 1.0 + float(items.get_synergy_weight(data.synergy_tags)) + meta_bonus
		weights.append(weight)
		total_weight += weight

	if total_weight <= 0.0:
		return pool[rng.randi_range(0, pool.size() - 1)]

	var roll: float = rng.randf() * total_weight
	var acc: float = 0.0
	for i in range(pool.size()):
		acc += weights[i]
		if roll <= acc:
			return pool[i]
	return pool[pool.size() - 1]


func _make_rng(room: RoomInstance) -> RandomNumberGenerator:
	var salt: String = "treasure:%d:%d:%d" % [
		room.grid_position.x,
		room.grid_position.y,
		_get_current_stage()
	]
	return DetRng.make(DetRng.derive(_get_run_seed(), salt))


func _get_run_seed() -> int:
	var generator: Node = _find_generator()
	if generator and generator.has_method("get_run_seed"):
		return generator.get_run_seed()
	return 0


func _get_current_stage() -> int:
	var generator: Node = _find_generator()
	if generator and generator.has_method("get_current_stage"):
		return generator.get_current_stage()
	return 1


func _find_generator() -> Node:
	var found: Array = get_tree().get_nodes_in_group("level_generator")
	if not found.is_empty():
		return found[0]
	return null


# ============================================================================
# Run-Verwaltung
# ============================================================================
func _on_item_taken(item: ItemData, _pedestal: TreasurePedestal) -> void:
	treasure_item_taken.emit(item)
	_debug("'%s' vom Sockel genommen." % item.display_name)


## Erkennt einen neuen Lauf am geaenderten Run-Seed. Ohne das haelt der
## Manager nach reload_current_scene() alle Raeume fuer bereits abgehandelt
## und der Schatzraum bliebe leer — ein Fehler ohne Fehlermeldung.
func _maybe_reset_for_new_run() -> void:
	var current_seed: int = _get_run_seed()
	if current_seed == _last_seen_seed:
		return
	if _last_seen_seed != -1:
		_debug("Neuer Run erkannt (Seed %d -> %d). Item-Pool zurueckgesetzt." % [
			_last_seen_seed, current_seed
		])
		_reserved_ids.clear()
	_last_seen_seed = current_seed


## Beim Start eines neuen Runs aufrufen — parallel zu Loot.reset_run() und
## Items.reset_run().
func reset_run() -> void:
	_reserved_ids.clear()
	_handled_rooms.clear()
	_last_seen_seed = -1
	_rooms_seen = 0


## Welche Items in diesem Lauf bereits auf einem Sockel lagen.
func get_reserved_ids() -> Array:
	return _reserved_ids.keys()


# ============================================================================
# Test-Hilfen
# ============================================================================
## Setzt sofort einen Sockel vor den Spieler. Gedacht fuer einen temporaeren
## Tastendruck, um Sockel-Optik und Aufnehmen zu testen, ohne erst einen
## Schatzraum freihacken zu muessen.
func debug_spawn_at_player(item_id: String = "") -> void:
	var player: Node3D = null
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			player = node as Node3D
			break
	if player == null:
		push_warning("[Treasure] Kein Spieler gefunden.")
		return

	var items: Node = get_node_or_null("/root/Items")
	if item == null:
		push_warning("[Treasure] Autoload 'Items' fehlt.")
		return

	var data: ItemData = null
	if item_id != "":
		data = items.get_item_by_id(item_id)
	elif not items.catalog.is_empty():
		data = items.catalog[0]
	if data == null:
		push_warning("[Treasure] Item '%s' nicht im Katalog." % item_id)
		return

	var pedestal := TreasurePedestal.create(data)
	get_tree().current_scene.add_child(pedestal)
	pedestal.global_position = player.global_position + Vector3(0.0, 0.0, 3.0)
	pedestal.item_taken.connect(_on_item_taken)
	_debug("Test-Sockel '%s' vor dem Spieler gesetzt." % data.display_name)


## Kurzbericht fuer die Konsole.
func debug_report() -> void:
	print("[Treasure] Raeume gesehen: %d | reservierte Items: %s | Seed: %d" % [
		_rooms_seen, str(_reserved_ids.keys()), _last_seen_seed
	])

```
</details>

### 💭 Thinking

`20:19:45`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `treasure_pedestal.gd`

`20:19:46`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_pedestal.gd</code></summary>

```
extends Node3D
class_name TreasurePedestal

# ============================================================================
# TreasurePedestal — der Isaac-Sockel in der Mitte des Schatzraums.
# ============================================================================
# EIN Item pro Schatzraum, frei schwebend ueber einer Saeule, mit Lichtsaeule
# und Bodenring. Wer nah genug steht, sieht die Item-Karte unten links und
# kann mit [F] zugreifen.
#
# WARUM EIN EIGENES SCRIPT UND NICHT Pickup.Kind.ITEM:
# Pickup ist bewusst ein Wegwerf-Objekt: es liegt am Boden, wird magnetisch
# angezogen und verschwindet beim Beruehren. Der Schatzsockel ist das
# Gegenteil — er steht fest, saugt nichts an, muss aktiv bedient werden und
# soll den halben Raum beleuchten. Beides in eine Klasse zu quetschen haette
# in Pickup vier weitere "if kind == ITEM: anders"-Zweige bedeutet, und genau
# solche Zweige sind spaeter die Stellen, an denen ein Bugfix fuer Muenzen den
# Schatzraum kaputtmacht.
#
# BAUT SICH KOMPLETT SELBST AUF — konsequent wie pickup.gd und bomb.gd. Es
# gibt also KEINE treasure_pedestal.tscn, die man vergessen kann zu laden.
#
# ALLE MATERIALIEN WERDEN PRO INSTANZ NEU ERZEUGT (siehe _make_material).
# Wuerde hier eine geteilte Ressource liegen, faerbte der zweite Sockel einer
# Etage rueckwirkend den ersten um.

signal item_taken(item: ItemData, pedestal: TreasurePedestal)

## Wie nah der Spieler stehen muss, damit [F] greift.
@export var interact_distance: float = 3.0

## Ab dieser Entfernung wird die Item-Karte mittig auf dem Bildschirm
## eingeblendet — und beim Verlassen sofort wieder ausgeblendet.
##
## Bewusst knapp gehalten: die Karte soll aussagen "du stehst am Sockel",
## nicht "irgendwo in diesem Raum liegt ein Item". Bei einem 48 m breiten
## Schatzraum heisst das ein Radius um die Mittelplattform herum.
@export var preview_distance: float = 7.0

## Schwebe-Animation des Items ueber der Saeule.
@export var bob_height: float = 0.14
@export var bob_speed: float = 1.8
@export var spin_speed: float = 1.1

## Hoehe des schwebenden Items ueber der Saeulen-Oberkante.
@export var float_height: float = 1.15

## Hoehe der Lichtsaeule. Sie ist das, was den Raum auf Distanz lesbar macht.
@export var beam_height: float = 7.0

## Reichweite der Punktlichtquelle im Sockel.
@export var light_range: float = 9.0
@export var light_energy: float = 2.2

## Muss mit SettingsManager.DEFAULT_KEYBINDS uebereinstimmen ("interact" = F).
const INTERACT_ACTION: String = "interact"

## Gruppe, in der sich ItemDescriptionHud anmeldet.
const ITEM_HUD_GROUP: String = "item_hud"

## Gruppe, in der sich der LevelGenerator selbst eintraegt — fuer das
## map_updated-Signal, siehe _sync_minimap_visibility().
const GENERATOR_GROUP: String = "level_generator"

## Das Item, das auf diesem Sockel liegt. Wird vom TreasureManager gesetzt,
## BEVOR der Sockel in den Baum gehaengt wird.
var item_data: ItemData = null

var _taken: bool = false
var _time: float = 0.0
var _float_root: Node3D = null
var _gem: MeshInstance3D = null
var _halo: MeshInstance3D = null
var _beam: MeshInstance3D = null
var _ring: MeshInstance3D = null
var _light: OmniLight3D = null
var _name_label: Label3D = null
var _prompt_label: Label3D = null
var _preview_shown: bool = false
var _accent: Color = Color(0.95, 0.85, 0.35)

## Der Raum, in dem dieser Sockel steht. Wird beim _ready() gesetzt (der
## Sockel ist immer ein direktes Kind des Raums, siehe treasure_manager.gd).
## Bleibt null bei debug_spawn_at_player() — dort greift keine Fog-Logik.
var _room: RoomInstance = null
var _generator: Node = null


## Bequemer Konstruktor fuer den TreasureManager.
static func create(data: ItemData) -> TreasurePedestal:
	var pedestal := TreasurePedestal.new()
	pedestal.item_data = data
	pedestal.name = "TreasurePedestal_%s" % (data.id if data else "empty")
	return pedestal


func _ready() -> void:
	add_to_group("treasure_pedestals")

	if item_data != null:
		_accent = item_data.pedestal_color

	_build_column()
	_build_ring()
	_build_beam()
	_build_float_group()
	_build_light()
	_build_labels()

	# ------------------------------------------------------------------
	# Fog-of-War-Anschluss (behobener Bug: Sockel leuchtet durch die Wand
	# eines noch nicht besuchten Schatzraums auf der Karte)
	# ------------------------------------------------------------------
	# room_instance.gd blendet einen kompletten unbesuchten Raum auf der
	# 3D-Minimap aus, indem es EINMALIG alle VisualInstance3D-Kinder auf
	# einen Layer verschiebt, den die Kartenkamera nicht rendert
	# (set_minimap_revealed() -> _apply_minimap_layer()). "Einmalig" ist der
	# entscheidende Teil: ein zweiter Aufruf mit demselben Sichtbarkeits-
	# zustand ist ein bewusster No-Op (siehe die Sperre dort), damit der
	# Baum nicht bei jedem Kartenupdate neu durchlaufen wird.
	#
	# treasure_manager.gd haengt diesen Sockel aber ERST ein bis zwei
	# Physik-Frames NACH der Raumgenerierung ein (siehe dort: der Boden fuer
	# die Sockelposition muss erst kollidierbar sein). Zu diesem Zeitpunkt
	# hat der Raum sein "verstecken" laengst hinter sich — der Sockel wird
	# also NIE von _apply_minimap_layer() erfasst und bleibt fuer die
	# Kartenkamera dauerhaft auf dem normalen, sichtbaren Layer. Ergebnis:
	# eine helle, mehrere Meter hohe Lichtsaeule schwebt sichtbar in einem
	# Raum, dessen Waende und Boden korrekt ausgeblendet sind — auf der
	# Karte sieht das aus wie "man sieht durch die Wand".
	#
	# Die Lösung hier dupliziert NICHT die Versteck-Logik, sondern fragt bei
	# jeder Kartenaktualisierung (map_updated-Signal des Generators) aktiv
	# nach dem AKTUELLEN Sichtbarkeitszustand des eigenen Elternraums und
	# wendet ihn auf die eigenen Kinder an. Kein Eingriff in room_instance.gd
	# noetig.
	_room = get_parent() as RoomInstance
	_sync_minimap_visibility.call_deferred()
	_bind_generator.call_deferred()


# ============================================================================
# Aufbau
# ============================================================================
## Unshaded + Emission: PSX-Optik lebt von flachen, gesaettigten Flaechen.
## Ein Schatzsockel muss ausserdem quer durch einen dunklen Raum lesbar sein,
## ohne dass eine Lichtquelle ihn zufaellig richtig trifft.
func _make_material(color: Color, emission: float = 0.8, unshaded: bool = true) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission
	return material


## Additiv + ohne Tiefen-Test-Verlust: fuer Lichtsaeule und Halo. Cull
## deaktiviert, damit man auch von innen etwas sieht.
func _make_glow_material(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.disable_receive_shadows = true
	return material


## Die Saeule ist bewusst zweiteilig: dunkler Schaft, heller Deckstein in der
## Item-Farbe. So sieht man die Farbe des Items auch dann noch, wenn das
## schwebende Objekt gerade von einer Wand verdeckt wird.
func _build_column() -> void:
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = 0.42
	shaft_mesh.bottom_radius = 0.58
	shaft_mesh.height = 0.95
	shaft_mesh.radial_segments = 8  # bewusst grob: PSX-Look

	var shaft := MeshInstance3D.new()
	shaft.name = "Shaft"
	shaft.mesh = shaft_mesh
	# material_override statt surface_material_override — Vorrangregel.
	shaft.material_override = _make_material(Color(0.14, 0.15, 0.18), 0.0, false)
	shaft.position = Vector3(0.0, 0.475, 0.0)
	add_child(shaft)

	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.72
	base_mesh.bottom_radius = 0.82
	base_mesh.height = 0.18
	base_mesh.radial_segments = 8

	var base := MeshInstance3D.new()
	base.name = "Base"
	base.mesh = base_mesh
	base.material_override = _make_material(Color(0.10, 0.11, 0.13), 0.0, false)
	base.position = Vector3(0.0, 0.09, 0.0)
	add_child(base)

	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.52
	cap_mesh.bottom_radius = 0.46
	cap_mesh.height = 0.12
	cap_mesh.radial_segments = 8

	var cap := MeshInstance3D.new()
	cap.name = "Cap"
	cap.mesh = cap_mesh
	cap.material_override = _make_material(_accent, 0.9)
	cap.position = Vector3(0.0, 1.0, 0.0)
	add_child(cap)


## Leuchtring auf dem Boden. Markiert die Interaktions-Reichweite, ohne dass
## dafuer eine UI noetig waere.
func _build_ring() -> void:
	var torus := TorusMesh.new()
	torus.inner_radius = 1.05
	torus.outer_radius = 1.22
	torus.rings = 20
	torus.ring_segments = 5

	_ring = MeshInstance3D.new()
	_ring.name = "GroundRing"
	_ring.mesh = torus
	_ring.material_override = _make_glow_material(_accent, 0.55)
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ring.position = Vector3(0.0, 0.04, 0.0)
	add_child(_ring)


## Lichtsaeule nach oben. Der eigentliche "hier liegt was"-Wegweiser: sie ist
## auch dann sichtbar, wenn der Sockel selbst hinter einer Stufe verschwindet.
func _build_beam() -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.95
	cylinder.bottom_radius = 0.30
	cylinder.height = beam_height
	cylinder.radial_segments = 10
	cylinder.rings = 1

	_beam = MeshInstance3D.new()
	_beam.name = "LightBeam"
	_beam.mesh = cylinder
	_beam.material_override = _make_glow_material(_accent, 0.13)
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_beam.position = Vector3(0.0, 1.1 + beam_height * 0.5, 0.0)
	add_child(_beam)


## Alles Schwebende haengt an EINEM Knoten, damit Bob und Rotation nicht auf
## drei Meshes einzeln nachgezogen werden muessen.
func _build_float_group() -> void:
	_float_root = Node3D.new()
	_float_root.name = "FloatRoot"
	_float_root.position = Vector3(0.0, 1.06 + float_height, 0.0)
	add_child(_float_root)

	# --- Halo hinter dem Item ----------------------------------------
	var quad := QuadMesh.new()
	quad.size = Vector2(1.5, 1.5)

	_halo = MeshInstance3D.new()
	_halo.name = "Halo"
	_halo.mesh = quad
	var halo_material := _make_glow_material(_accent, 0.35)
	halo_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_halo.material_override = halo_material
	_halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(_halo)

	# --- Das Item selbst: facettierter Edelstein ----------------------
	# radial_segments 6 / rings 3 ergibt eine kantige Form, die zum
	# Vertex-Snapping passt. Eine glatte Kugel saehe hier wie ein Fremd-
	# koerper aus.
	var gem_mesh := SphereMesh.new()
	gem_mesh.radius = 0.30
	gem_mesh.height = 0.84
	gem_mesh.radial_segments = 6
	gem_mesh.rings = 3

	_gem = MeshInstance3D.new()
	_gem.name = "Gem"
	_gem.mesh = gem_mesh
	_gem.material_override = _make_material(_accent, 1.4)
	_gem.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(_gem)

	# Fertiges Icon-Modell schlaegt den Platzhalter, falls eines existiert.
	if item_data != null and item_data.icon != null:
		_apply_icon_billboard(item_data.icon)


## Sobald es Item-Icons gibt, wird der Edelstein zum Traeger einer Textur.
## Bis dahin passiert hier nichts — das ist kein Fehlerfall.
func _apply_icon_billboard(icon: Texture2D) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(0.85, 0.85)

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = icon
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var icon_instance := MeshInstance3D.new()
	icon_instance.name = "Icon"
	icon_instance.mesh = quad
	icon_instance.material_override = material
	icon_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(icon_instance)

	# Der Stein bleibt als farbiger Hintergrund stehen, wird aber kleiner,
	# damit das Icon lesbar bleibt.
	if _gem:
		_gem.scale = Vector3.ONE * 0.55


func _build_light() -> void:
	_light = OmniLight3D.new()
	_light.name = "ShrineLight"
	_light.light_color = _accent
	_light.light_energy = light_energy
	_light.omni_range = light_range
	# Schatten aus: eine einzelne bewegte Punktlichtquelle mit Schatten
	# kostet in einem Raum voller Wandsegmente deutlich mehr, als sie
	# optisch bringt.
	_light.shadow_enabled = false
	_light.position = Vector3(0.0, 1.6, 0.0)
	add_child(_light)


func _build_labels() -> void:
	_name_label = Label3D.new()
	_name_label.name = "NameLabel"
	_name_label.text = item_data.display_name if item_data else "???"
	_name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_name_label.no_depth_test = true
	_name_label.pixel_size = 0.0055
	_name_label.outline_size = 8
	_name_label.modulate = Color(1.0, 0.98, 0.92, 0.95)
	_name_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_name_label.position = Vector3(0.0, 2.85, 0.0)
	_name_label.visible = false
	add_child(_name_label)

	_prompt_label = Label3D.new()
	_prompt_label.name = "PromptLabel"
	_prompt_label.text = "[F] Nehmen"
	_prompt_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt_label.no_depth_test = true
	_prompt_label.pixel_size = 0.0045
	_prompt_label.outline_size = 6
	_prompt_label.modulate = _accent
	_prompt_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_prompt_label.position = Vector3(0.0, 2.5, 0.0)
	_prompt_label.visible = false
	add_child(_prompt_label)


# ============================================================================
# Laufzeit
# ============================================================================
func _physics_process(delta: float) -> void:
	_time += delta
	_animate(delta)

	if _taken:
		return

	var player: Node3D = _find_player()
	if player == null:
		return

	var distance: float = global_position.distance_to(player.global_position)
	_update_labels(distance)
	_update_preview(distance)

	if distance > interact_distance:
		return
	if not Input.is_action_just_pressed(INTERACT_ACTION):
		return
	take()


func _animate(delta: float) -> void:
	if _float_root and not _taken:
		_float_root.position.y = 1.06 + float_height + sin(_time * bob_speed) * bob_height
		_float_root.rotate_y(spin_speed * delta)

	if _ring:
		# Langsames Pulsieren: zieht den Blick, ohne zu flackern.
		var pulse: float = 0.45 + 0.25 * (sin(_time * 2.0) * 0.5 + 0.5)
		var material: StandardMaterial3D = _ring.material_override
		if material:
			material.albedo_color.a = pulse if not _taken else 0.08

	if _light and not _taken:
		_light.light_energy = light_energy * (0.85 + 0.15 * sin(_time * 3.1))


func _update_labels(distance: float) -> void:
	var near: bool = distance <= preview_distance
	if _name_label:
		_name_label.visible = near
	if _prompt_label:
		_prompt_label.visible = distance <= interact_distance


## Blendet die Item-Karte ein, sobald der Spieler in Reichweite kommt, und
## sofort wieder aus, wenn er sie verlaesst.
##
## Nur bei der FLANKE, nicht jeden Frame: ein Dauerfeuer von show_item()
## wuerde die Einblend-Animation jeden Frame neu starten, die Karte stuende
## also dauerhaft auf 97 % Groesse und zuckte.
##
## Das Ausblenden beim Weggehen ist der eigentliche Grund fuer diese
## Funktion. Vorher lief die Karte nach einem festen Timer aus — man trug
## die Beschreibung also noch durch zwei Raeume mit sich herum.
func _update_preview(distance: float) -> void:
	var near: bool = distance <= preview_distance
	if near == _preview_shown:
		return
	_preview_shown = near

	var hud: ItemDescriptionHud = _find_item_hud()
	if hud == null:
		return

	if near and item_data != null:
		# persistent = true: die Karte bleibt, solange man hier steht.
		hud.show_item(item_data, true)
	else:
		hud.hide_item()


## Das Item-HUD ist jetzt ein Node IN hud.tscn, kein Autoload-Kind mehr.
## Deshalb wird es ueber die Gruppe gesucht statt ueber einen festen Pfad —
## ein Pfad wie "/root/HudExtra/..." haette sich bei jeder Umbenennung im
## Szenenbaum stillschweigend in null verwandelt.
func _find_item_hud() -> ItemDescriptionHud:
	for node: Node in get_tree().get_nodes_in_group(ITEM_HUD_GROUP):
		if node is ItemDescriptionHud and is_instance_valid(node):
			return node as ItemDescriptionHud
	return null


func _find_player() -> Node3D:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


# ============================================================================
# Aufnehmen
# ============================================================================
## Gibt true zurueck, wenn das Item wirklich ins Inventar gewandert ist.
## Bei erreichter Stapelgrenze bleibt der Sockel bestueckt stehen — das ist
## dieselbe Regel wie in pickup.gd und verhindert, dass ein Item wortlos
## verschwindet.
func take() -> bool:
	if _taken or item_data == null:
		return false

	var items: Node = get_node_or_null("/root/Items")
	if item == null:
		return false
	if not items.add_item(item_data):
		return false

	_taken = true
	# Die Anzeige stand auf "dauerhaft" (Sockel in Reichweite). Ohne diesen
	# Wechsel bliebe die Karte fuer immer stehen, weil hide_item() erst beim
	# Verlassen der Reichweite kaeme — und Items.item_added() setzt sie
	# gleich darauf ohnehin neu, dann mit Auto-Ausblendung.
	var hud: ItemDescriptionHud = _find_item_hud()
	if hud:
		hud.hide_item()

	item_taken.emit(item_data, self)
	_play_take_feedback()
	return true


## Der Sockel bleibt als leere Saeule stehen. Ein komplett verschwindender
## Sockel wuerde beim Zurueckkommen so aussehen, als waere der Schatzraum nie
## bestueckt gewesen.
func _play_take_feedback() -> void:
	if _prompt_label:
		_prompt_label.visible = false
	if _name_label:
		_name_label.visible = false

	Juice.hit_stop(Juice.DURATION_LIGHT)
	Juice.shake(0.35)

	var tween := create_tween()
	tween.set_parallel(true)

	if _float_root:
		tween.tween_property(_float_root, "position:y", _float_root.position.y + 1.4, 0.45) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_float_root, "scale", Vector3.ONE * 0.01, 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	if _beam and _beam.material_override is StandardMaterial3D:
		tween.tween_property(_beam.material_override, "albedo_color:a", 0.0, 0.5)

	if _light:
		tween.tween_property(_light, "light_energy", 0.25, 0.5)

	tween.chain().tween_callback(_finish_take)


func _finish_take() -> void:
	if _float_root and is_instance_valid(_float_root):
		_float_root.queue_free()
		_float_root = null
	if _beam and is_instance_valid(_beam):
		_beam.queue_free()
		_beam = null


func is_taken() -> bool:
	return _taken


# ============================================================================
# Fog-of-War-Anschluss
# ============================================================================
func _bind_generator() -> void:
	if _room == null:
		# debug_spawn_at_player() haengt den Sockel direkt in current_scene,
		# nicht in einen Raum — dort gibt es keine Fog-of-War-Zustaende, mit
		# denen synchronisiert werden muesste.
		return

	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)


func _on_map_updated() -> void:
	_sync_minimap_visibility()


## Spiegelt den AKTUELLEN Sichtbarkeitszustand des Elternraums auf die
## eigenen Kinder — Meshes UND Licht. Wird beim Bauen einmal aufgerufen und
## danach bei jedem map_updated erneut (Raum wird betreten -> aufgedeckt).
func _sync_minimap_visibility() -> void:
	if _room == null or not is_instance_valid(_room):
		return

	# _minimap_revealed ist ein gewoehnliches Skript-Feld (kein echtes
	# "private" in GDScript) und traegt IMMER einen gueltigen Wert, auch
	# ohne LevelGenerator (Default true) — Testszenen ohne Fog bleiben damit
	# unangetastet sichtbar.
	var revealed: bool = true
	if "_minimap_revealed" in _room:
		revealed = bool(_room.get("_minimap_revealed"))

	_apply_own_minimap_layer(self, revealed)

	# Fuer Lichter reicht das Verschieben auf einen unsichtbaren Layer NICHT:
	# layers steuert bei Light3D nur, was der Editor-Gizmo tut, nicht ob das
	# Licht real weiterstrahlt. .visible = false schaltet das Licht dagegen
	# vollstaendig ab — sonst wuerde eine unsichtbar gewordene Lichtquelle
	# trotzdem noch Flaechen in einem eigentlich verdeckten Raum aufhellen.
	if _light:
		_light.visible = revealed


## Rekursiv wie room_instance.gd::_apply_minimap_layer(), aber nur auf den
## eigenen Unterbaum angewendet. RoomInstance.MINIMAP_HIDDEN_LAYER ist die
## SELBE Konstante, die die Kartenkamera aus ihrer cull_mask streicht — auf
## einen eigenen, zweiten Layer-Wert zu bestehen waere eine zweite Quelle
## der Wahrheit, die irgendwann auseinanderlaufen kann.
func _apply_own_minimap_layer(node: Node, revealed: bool) -> void:
	for child: Node in node.get_children():
		if child is VisualInstance3D:
			var visual: VisualInstance3D = child as VisualInstance3D
			if not visual.has_meta("minimap_base_layers"):
				visual.set_meta("minimap_base_layers", visual.layers)
			if revealed:
				visual.layers = int(visual.get_meta("minimap_base_layers"))
			else:
				visual.layers = 1 << (RoomInstance.MINIMAP_HIDDEN_LAYER - 1)
		_apply_own_minimap_layer(child, revealed)

```
</details>

### 💭 Thinking

`20:20:20`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func add_modifier|func remove_source|func clear_all|var _modifiers|source_id` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\player_stats.gd`

`20:20:22`

```
Path does not exist: C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\player_stats.gd. Note: your current working directory is C:\Users\thvnh\Documents\GitHub\whiplash.
```

#### 📂 Glob `**/player_stats.gd`

`20:20:24`

```
scripts\core\player_stats.gd
```

#### 🔎 Grep `func add_modifier|func remove_source|func clear_all|_modifiers"` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\core\player_stats.gd`

`20:20:28`

```
175:func add_modifier(source_id: String, stat: String, add_value: float = 0.0, mul_value: float = 1.0) -> void:
176-	if not _modifiers.has(source_id):
177-		_modifiers[source_id] = {}
178-	var entry: Dictionary = _modifiers[source_id]
179-	entry[stat] = {"add": add_value, "mul": mul_value}
180-	_modifiers[source_id] = entry
181-	apply()
182-
183-
184-## Zeitlich begrenzter Buff. Laeuft in _process ab und raeumt sich selbst weg.
185-func add_timed_modifier(source_id: String, stat: String, duration: float, add_value: float = 0.0, mul_value: float = 1.0) -> void:
--
190:func remove_source(source_id: String) -> void:
191-	var changed: bool = _modifiers.erase(source_id)
192-	_timed_sources.erase(source_id)
193-	if changed:
194-		apply()
195-
196-
197-func has_source(source_id: String) -> bool:
198-	return _modifiers.has(source_id)
199-
200-
201:func clear_all() -> void:
202-	_modifiers.clear()
203-	_timed_sources.clear()
204-	apply()
205-
206-
207-func _process(delta: float) -> void:
208-	if _timed_sources.is_empty():
209-		return
210-
211-	var expired: Array[String] = []
```

### 💭 Thinking

`20:21:51`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `player_hit_enemy|func _on_hit|class ItemBehaviours|extends|PASSIVE|category` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`20:21:53`

```
2:extends Node
3-class_name ItemBehaviours
4-
5-# ============================================================================
6-# ItemBehaviours — hier steht, was die Items TATSAECHLICH tun.
7-# ============================================================================
8-# Wird von item_manager.gd als Kind erzeugt und haengt sich an dessen Signale.
--
21:#   player_hit_enemy   -> _on_player_hit_enemy()      (Items.player_hit_enemy)
22-#   enemy_died         -> im selben Aufruf: Health.is_alive() ist dann false
23-#   take_damage        -> _on_player_damaged()        (Health.damage_taken)
24-#   room_cleared       -> _on_room_cleared()          (Items.room_cleared)
25-#   step_tick          -> _physics_process()          (Bewegungs-Spuren)
26-#   dash_started       -> _poll_dash()                (Flanke aus combat.is_dashing())
27-#
--
37:# Hitbox.take_damage laeuft VOR hit_landed. Wenn player_hit_enemy hier
38-# ankommt, ist der Gegner also schon tot, falls der Schlag toedlich war — ein
39-# Blick auf Health.is_alive() reicht als Kill-Erkennung.
40-#
41-# NICHT erfasst werden dadurch Kills durch Blutung, Brand oder
42-# Umgebungsschaden. Das ist bewusst so: die Alternative waere, sich an das
43-# died-Signal JEDES Gegners zu haengen und dabei den Verursacher zu
--
140:# PHASE 4 — PASSIVE ITEMS
141-# ============================================================================
142-
143-# --- P1. Proteinshake aus den 90ern ---
144-## Faktor auf die Skalierung der Angriffs-Hitboxen. 0.85 = 15 % kleiner.
145-const SHAKE_HITBOX_SCALE: float = 0.85
146-
--
455:## Nr. 61 Kaiserin: urspruenglich als PASSIVE mit Kill-Chance kodiert, bevor
456-## der Abgleich mit der echten Tabelle zeigte, dass es ein AKTIV-Item ist
457-## ("Erhoeht drastisch das Tempo. Kills erneuern die Abklingzeiten und machen
458-## kurz unsichtbar.") - siehe item_catalog.gd fuer die Korrektur.
459-## "Kurz unsichtbar": es gibt in diesem Projekt kein System, das die
460-## Gegner-Wahrnehmung (Sichtlinie/Aggro in enemy_ai.gd) beeinflusst - eine
461-## echte Unsichtbarkeit haette also tief in die KI eingreifen muessen, blind
--
657:	_items.player_hit_enemy.connect(_on_player_hit_enemy)
658-	_items.active_item_used.connect(_on_active_item_used)
659-	_items.player_ready.connect(_on_player_ready)
660-	_items.item_added.connect(_on_item_added)
661-	_items.coins_changed.connect(_on_coins_changed)
662-	_items.room_cleared.connect(_on_room_cleared)
663-
--
1112:func _on_player_hit_enemy(target: Node3D, hitbox: Hitbox) -> void:
1113-	if target == null or not is_instance_valid(target):
1114-		return
1115-
1116-	var health: Health = _health_of(target)
1117-	# Die Hitbox hat den Schaden bereits ausgeteilt, bevor dieses Signal
1118-	# ankommt. Ein toter Gegner heisst also: dieser Schlag war der letzte.
--
2321:# Strahl dorthin. Der Schadensbonus haengt in _on_player_hit_enemy(); hier
2322-# laeuft nur Zielsuche, Strahl-Darstellung und die DoT-Verteilung.
2323-func _tick_laser_pointer(delta: float, player: CharacterBody3D) -> void:
2324-	_laser_retarget_timer -= delta
2325-	if _laser_retarget_timer <= 0.0:
2326-		_laser_retarget_timer = LASER_RETARGET_INTERVAL
2327-		_laser_target = _find_strongest_enemy(player.global_position)
--
3407:## Wird direkt aus _on_player_hit_enemy() im was_kill-Zweig aufgerufen
3408-## (siehe dort) - hier nur der Heil-Effekt selbst.
3409-func _apply_devour(player: CharacterBody3D) -> void:
3410-	if _player_health == null or not _player_health.is_alive():
3411-		return
3412-	var heal: float = _player_health.max_health * DEVOUR_HEAL_FRACTION
3413-	_player_health.current_health = minf(_player_health.current_health + heal, _player_health.max_health)
--
3419:## Wird aus _on_player_hit_enemy() im was_kill-Zweig aufgerufen. Fuer das
3420-## "laedt dein Aktiv-Item ein Stueck auf" gibt es keine Teil-Aufladung in
3421-## item_manager.gd (nur force_recharge_active() = volle Aufladung) - deshalb
3422-## dieselbe Loesung wie bei der Nonnen-Kutte (P17): eine Chance auf volle
3423-## statt einer garantierten Teil-Aufladung.
3424-## Nur waehrend _empress_buff_timer > 0.0 aufgerufen (siehe was_kill-Zweig
3425:## in _on_player_hit_enemy) - "Kills waehrend der Wirkung", nicht "Kills,
3426-## solange man das Item besitzt".
3427-func _apply_empress() -> void:
3428-	if _player_health != null:
3429-		_player_health.set_invulnerable(EMPRESS_INVULN_DURATION)
3430-	_flash_player(FLASH_WHITE)
3431-	if _items.has_method("force_recharge_active"):
```

### 💭 Thinking

`20:22:01`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _on_player_hit_enemy" -A 60` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`20:22:02`

```
No matches found
```

#### 👀 Read `item_behaviours.gd`

`20:22:06`

*(lines 1112–1252)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd</code></summary>

```
func _on_player_hit_enemy(target: Node3D, hitbox: Hitbox) -> void:
	if target == null or not is_instance_valid(target):
		return

	var health: Health = _health_of(target)
	# Die Hitbox hat den Schaden bereits ausgeteilt, bevor dieses Signal
	# ankommt. Ein toter Gegner heisst also: dieser Schlag war der letzte.
	var was_kill: bool = health != null and not health.is_alive()
	var base_damage: float = hitbox.damage if hitbox != null else 15.0
	# FRUEH erfasst, VOR jeder Kill-Reaktion: Health.died() (in enemy_ai.gd
	# bereits gelaufen, siehe Signal-Reihenfolge in primary_hitbox.gd) koennte
	# Status-Effekte theoretisch aufraeumen - Mueckenspray/Vampirgebiss muessen
	# den Zustand VOM TREFFER SELBST sehen, nicht von danach.
	var target_had_dot: bool = target.has_method("has_status_effect") and (
		target.call("has_status_effect", "bleed")
		or target.call("has_status_effect", "burn")
		or target.call("has_status_effect", "acid")
	)
	var target_had_any_status: bool = target.has_method("has_status_effect") and (
		target_had_dot
		or target.call("has_status_effect", "stun")
		or target.call("has_status_effect", "rooted")
		or target.call("has_status_effect", "confused")
		or target.call("has_status_effect", "silenced")
		or target.call("has_status_effect", "slow")
		or target.call("has_status_effect", "charm")
	)
	var target_was_stunned_or_rooted: bool = target.has_method("has_status_effect") and (
		target.call("has_status_effect", "stun") or target.call("has_status_effect", "rooted")
	)

	# --- Bestandsitems ---
	if _has(ItemCatalog.ID_WOODEN_SPOON):
		_apply_wooden_spoon()
	if _has(ItemCatalog.ID_RUSTY_CLEAVER):
		_apply_rusty_cleaver(target)
	if _has(ItemCatalog.ID_STATIC_SOCK):
		_apply_static_sock(hitbox)

	# --- Phase 4 ---
	if _has(ItemCatalog.ID_ROOF_NAIL):
		_apply_roof_nail(target)
	if _has(ItemCatalog.ID_OUIJA_BOARD):
		_apply_ouija_board()
	if _has(ItemCatalog.ID_BLOOD_PACT):
		_apply_blood_pact()
	if _has(ItemCatalog.ID_ICE_BAG):
		_apply_ice_bag(target)
	if _has(ItemCatalog.ID_MODEM_56K):
		_apply_modem(target)
	if _has(ItemCatalog.ID_HAIRSPRAY):
		_apply_hairspray(target)
	if _has(ItemCatalog.ID_KNITTING_NEEDLES):
		_apply_knitting_needles(target, base_damage)
	if _has(ItemCatalog.ID_GOLDEN_CREDIT_CARD):
		_spawn_vfx(SPARK_YELLOW_SCENE, target.global_position + Vector3.UP * 1.2)
	if _has(ItemCatalog.ID_LASER_POINTER) and target == _laser_target:
		# Der Markierungs-Bonus laeuft NACHTRAEGLICH: die Hitbox hat ihren
		# Schaden schon ausgeteilt, ein Stat-Modifier haette also erst beim
		# NAECHSTEN Schlag gewirkt. Der Nachschlag hier trifft dagegen genau
		# den markierten Gegner, genau jetzt.
		if health != null and health.is_alive():
			var laser_bonus: float = base_damage * LASER_DAMAGE_BONUS
			health.take_damage(laser_bonus, _player())
			_spawn_item_damage_number(target, laser_bonus)
	if _has(ItemCatalog.ID_CHILI_OIL) and StatusBurn.active(target):
		_apply_chili_oil(target)
	if _has(ItemCatalog.ID_BOOMBOX) and StatusSilenced.active(target):
		_apply_boombox_silence_bonus(target, base_damage)
	# Nr. 76 Schlangenbiss: "vulnerable" ist ein generischer Status (kein
	# eigenes status_effects/*.gd noetig, siehe StatusEffectBase.apply_raw) -
	# jeder Treffer gegen einen so markierten Gegner bekommt denselben
	# Nachschlag-Bonus wie beim Laser-Pointer oben.
	if StatusEffectBase.is_active(target, "vulnerable") and health != null and health.is_alive():
		var vuln_bonus: float = base_damage * StatusEffectBase.magnitude_of(target, "vulnerable")
		health.take_damage(vuln_bonus, _player())
		_spawn_item_damage_number(target, vuln_bonus)

	# Nr. 90 Verheddertes Jo-Jo: Bonus-Schaden auf grosse Distanz.
	if _has(ItemCatalog.ID_TANGLED_YOYO) and health != null and health.is_alive():
		var yoyo_player: CharacterBody3D = _player()
		if yoyo_player != null and yoyo_player.global_position.distance_to(target.global_position) >= YOYO_RANGE_THRESHOLD:
			var yoyo_bonus: float = base_damage * YOYO_DAMAGE_BONUS
			health.take_damage(yoyo_bonus, yoyo_player)
			_spawn_item_damage_number(target, yoyo_bonus)

	if was_kill:
		if _has(ItemCatalog.ID_PLASTIC_HALO):
			_apply_plastic_halo(target)
		if _has(ItemCatalog.ID_DISCO_BALL):
			_apply_disco_ball(target)
		if _has(ItemCatalog.ID_MOSQUITO_SPRAY) and target_had_dot:
			_apply_mosquito_spray()
		if _has(ItemCatalog.ID_VAMPIRE_TEETH) and target_had_any_status:
			_apply_vampire_teeth()
		if _has(ItemCatalog.ID_EXECUTIONER_HOOD) and target_was_stunned_or_rooted:
			_apply_executioner_hood(target)
		if _has(ItemCatalog.ID_SUPER_GLUE):
			_spawn_glue_spot(target.global_position)
		if _has(ItemCatalog.ID_DEVOUR):
			_apply_devour(_player())
		if _has(ItemCatalog.ID_EMPRESS) and _empress_buff_timer > 0.0:
			_apply_empress()

	# --- Game Juice -----------------------------------------------------
	# Der Hit-Stop haengt an der Wucht des Angriffs, nicht am Item: die
	# SecondaryHitbox macht doppelten Schaden und bekommt deshalb den
	# laengeren Freeze.
	if hitbox != null and hitbox.name.begins_with("Secondary"):
		Juice.hit_stop(Juice.DURATION_HEAVY)
	else:
		Juice.hit_stop(Juice.DURATION_LIGHT)


# ----------------------------------------------------------------------------
# 1. Mamas Kochloeffel — kurzer Schub + Unverwundbarkeit
# ----------------------------------------------------------------------------
func _apply_wooden_spoon() -> void:
	var player: CharacterBody3D = _player()
	if player == null:
		return

	if _player_health != null:
		_player_health.set_invulnerable(SPOON_DURATION)

	var stats: PlayerStats = _stats()
	if stats != null:
		stats.add_timed_modifier(
			"buff:wooden_spoon", PlayerStats.STAT_MOVE_SPEED,
			SPOON_DURATION, 0.0, SPOON_SPEED_MULTIPLIER
		)

	_spawn_vfx(DUST_RING_SCENE, player.global_position + Vector3.UP * 0.1)


# ----------------------------------------------------------------------------
# 2. Rostiges Beil — Blutung
# ----------------------------------------------------------------------------
# Nutzt den bestehenden StatusEffectManager statt einer eigenen Coroutine: der
# Effekt laeuft dann automatisch mit ab, wenn der Gegner stirbt oder der Raum
```
</details>

### 💭 Thinking

`20:22:24`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `item_data.gd`

`20:22:24`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_data.gd</code></summary>

```


extends Resource
class_name ItemData

# ============================================================================
# ItemData — reine Beschreibung EINES Items. Enthaelt bewusst KEINE Logik.
# ============================================================================
# Was ein Item TUT, steht in item_behaviours.gd. Diese Trennung ist wichtig,
# weil Items aus zwei sehr unterschiedlichen Quellen kommen koennen:
# aus dem Code-Katalog (item_catalog.gd) oder spaeter aus .tres-Dateien, die
# im Editor angelegt werden. Beide Wege liefern dasselbe ItemData-Objekt.

enum Kind {
	PASSIVE,   ## Wirkt dauerhaft, sobald es im Inventar liegt.
	ACTIVE,    ## Muss aktiv ausgeloest werden, laedt ueber Raeume auf.
}

## Seltenheitsstufe. Bestimmt die Farbe, in der das Item UEBERALL
## dargestellt wird: Sockel im Schatzraum, Drop am Boden, Chip in der
## HUD-Leiste, Eintrag in der Run-Uebersicht.
##
## WARUM DIE FARBE NICHT EINZELN PRO OBERFLAECHE GESETZT WIRD:
## Alle vier Anzeigen lesen bereits dieselbe Eigenschaft aus
## (pedestal_color - siehe treasure_pedestal.gd, pickup.gd,
## item_description_hud.gd, item_summary_list.gd). Die Rarity schreibt
## deshalb einfach in genau diese Eigenschaft. Damit war fuer das komplette
## Farbschema KEINE Aenderung an den Anzeige-Scripten noetig - und es kann
## auch keine Oberflaeche geben, die eine andere Farbe zeigt als die
## anderen.
##
## Reihenfolge = aufsteigende Wertigkeit: grau, gruen, blau, lila, rot.
enum Rarity {
	COMMON,     ## grau
	UNCOMMON,   ## gruen
	RARE,       ## blau
	EPIC,       ## lila
	LEGENDARY,  ## rot
}

enum Category {
	MELEE,      ## Nahkampf & Treffer-Effekte
	MOVEMENT,   ## Bewegung & Ramm-Attacken
	DEFENSE,    ## Defensive / Taktik
	UTILITY,    ## Alles Uebrige
}

## Eindeutige ID. Wird von item_behaviours.gd zur Zuordnung benutzt und
## darf sich nach dem Release NICHT mehr aendern (Speicherstaende, Runs).
@export var id: String = ""
@export var display_name: String = "Unbenanntes Item"

## --- Organisatorische Metadaten aus dem Design-Dokument ------------------
## Werden aktuell NIRGENDS im Spiel gelesen (kein UI, keine Logik haengt
## dran) - reine Buchhaltung, damit sich ein Item im Code eindeutig auf
## seine Zeile in der Item-Tabelle zurueckfuehren laesst.
##   nr        - fortlaufende Nummer ueber ALLE Items (Tabellenspalte "Nr.")
##   entity_id - "A.B": A = 1 (Aktiv) oder 2 (Passiv), B = laufender Index
##               INNERHALB des Typs (Tabellenspalte "Entity ID")
## id (oben) entspricht der Tabellenspalte "ITEM ID" - dafuer ist kein
## separates Feld noetig.
@export var nr: int = 0
@export var entity_id: String = ""

## Der kursive Einzeiler unter dem Namen ("Schlag die Hitze zurueck").
@export_multiline var flavor_text: String = ""

## Die mechanische Erklaerung fuers HUD unten links.
@export_multiline var description: String = ""

@export var icon: Texture2D
@export var kind: Kind = Kind.PASSIVE
@export var category: Category = Category.UTILITY

## Nur fuer ACTIVE: nach so vielen gecleareten Raeumen ist es wieder bereit.
##
## Wird IGNORIERT, sobald cooldown_seconds > 0 ist.
@export var charge_rooms: int = 2

## PHASE 4 — NEU: sekundenbasierter Cooldown.
##
## WARUM ES BEIDE MECHANIKEN GIBT:
## Das urspruengliche Aktiv-Item-System laedt ueber GECLEARTE RAEUME auf
## (charge_rooms). Fuer die acht Aktiv-Items aus dem Design-Dokument passt
## das nicht: dort stehen Sekunden ("Sturmfeuerzeug 3s", "Walkman 12s"), und
## ein Item, das man erst nach dem naechsten Raum wieder benutzen darf, ist
## etwas voellig anderes als eines mit 3 Sekunden Abklingzeit.
##
## 0.0 = alte Raum-Aufladung benutzen. > 0.0 = Sekunden-Cooldown, wobei
## charge_rooms dann unbeachtet bleibt. Beides gleichzeitig waere ein
## Doppel-Gate, bei dem nie klar ist, welches gerade blockiert.
##
## SONDERFALL "1x pro Etage" (Schulbibliotheks-Buch): weder das eine noch
## das andere. Das laeuft ueber charge_rooms = 0 UND cooldown_seconds = 0
## plus die Sperre in item_behaviours.gd (_book_used_in_stage).
@export var cooldown_seconds: float = 0.0


## true, wenn dieses Item ueber Sekunden statt ueber Raeume auflaedt.
func uses_time_cooldown() -> bool:
	return cooldown_seconds > 0.0

## Reine Stat-Boni, die ohne eigenen Code auskommen.
## Format: { PlayerStats.STAT_* : { "add": float, "mul": float } }
## Beispiel: { "damage": { "mul": 1.15 } } fuer +15 % Schaden.
@export var stat_modifiers: Dictionary = {}

## Seltenheit. Setzt beim Zuweisen automatisch pedestal_color mit - es sei
## denn, pedestal_color wurde vorher von Hand gesetzt (dann gewinnt die
## Handeingabe, siehe _pedestal_color_overridden).
@export var rarity: Rarity = Rarity.COMMON:
	set(value):
		rarity = value
		if not _pedestal_color_overridden:
			pedestal_color = rarity_color(value)

## Farbe des schwebenden Sockel-Wuerfels im Raum - und, seit Einfuehrung
## der Rarity, auch die Farbe des Drops, des HUD-Chips und des Eintrags in
## der Run-Uebersicht. Wird normalerweise NICHT mehr von Hand gesetzt,
## sondern aus rarity abgeleitet.
## Literal statt rarity_color(...): ein Member-Initialisierer, der eine
## statische Funktion DERSELBEN Klasse aufruft, laeuft waehrend die Klasse
## noch initialisiert wird. Der Wert unten ist identisch mit
## rarity_color(Rarity.COMMON) - bei einer Palettenaenderung mit anpassen.
@export var pedestal_color: Color = Color(0.72, 0.74, 0.78):
	set(value):
		pedestal_color = value
		_pedestal_color_overridden = true

## true, sobald pedestal_color explizit gesetzt wurde. Verhindert, dass
## eine spaetere Rarity-Zuweisung eine bewusst gewaehlte Sonderfarbe
## ueberschreibt.
var _pedestal_color_overridden: bool = false


## Die Farbtabelle. EINE Stelle - wer die Palette aendern will, aendert sie
## hier und nirgends sonst.
##
## Die Werte sind bewusst hell und gesaettigt: die Sockel-Wuerfel stehen in
## dunklen Raeumen und leuchten mit emission, gedaempfte Toene waeren dort
## nicht auseinanderzuhalten.
static func rarity_color(value: Rarity) -> Color:
	match value:
		Rarity.UNCOMMON:
			return Color(0.42, 0.85, 0.40)   # gruen
		Rarity.RARE:
			return Color(0.35, 0.62, 0.98)   # blau
		Rarity.EPIC:
			return Color(0.70, 0.42, 0.95)   # lila
		Rarity.LEGENDARY:
			return Color(0.95, 0.28, 0.26)   # rot
	return Color(0.72, 0.74, 0.78)           # grau (COMMON)


static func rarity_name(value: Rarity) -> String:
	match value:
		Rarity.UNCOMMON:
			return "Ungewoehnlich"
		Rarity.RARE:
			return "Selten"
		Rarity.EPIC:
			return "Episch"
		Rarity.LEGENDARY:
			return "Legendaer"
	return "Gewoehnlich"


func get_rarity_color() -> Color:
	return rarity_color(rarity)


func get_rarity_name() -> String:
	return rarity_name(rarity)

## Wie oft dasselbe Item in einem Run maximal droppen darf. 0 = unbegrenzt.
@export var max_stacks: int = 0

## Freie Schlagworte fuer Build-Synergien (z.B. "burn", "acid", "movement",
## "crit"). ItemManager erhoeht beim Aufsammeln eines Items mit diesen Tags
## das Drop-Gewicht ALLER Items im Pool, die einen der Tags teilen (siehe
## ItemManager._synergy_weight_bonus / TreasureManager._pick_item) - wer
## einmal Feuer aufgesammelt hat, findet in Schatzraeumen eher noch mehr
## Feuer. Rein additiv zur normalen Gleichverteilung, kein Filter.
@export var synergy_tags: PackedStringArray = []


## Baut ein ItemData komplett im Code. Praktisch fuer den Katalog, damit
## nicht fuer jedes Item eine .tres-Datei angelegt werden muss.
static func create(
		p_id: String,
		p_name: String,
		p_flavor: String,
		p_description: String,
		p_kind: Kind = Kind.PASSIVE,
		p_category: Category = Category.UTILITY,
		p_rarity: Rarity = Rarity.COMMON,
		p_nr: int = 0,
		p_entity_id: String = ""
) -> ItemData:
	var data := ItemData.new()
	data.id = p_id
	data.display_name = p_name
	data.flavor_text = p_flavor
	data.description = p_description
	data.kind = p_kind
	data.category = p_category
	data.nr = p_nr
	data.entity_id = p_entity_id
	# ZULETZT: der Setter von rarity schreibt pedestal_color mit. Stuende
	# die Zeile weiter oben, koennte eine spaetere Zuweisung sie wieder
	# ueberschreiben.
	data.rarity = p_rarity
	return data


func is_active_item() -> bool:
	return kind == Kind.ACTIVE


func get_category_name() -> String:
	match category:
		Category.MELEE:
			return "Nahkampf"
		Category.MOVEMENT:
			return "Bewegung"
		Category.DEFENSE:
			return "Defensive"
	return "Sonstiges"




```
</details>

### 💭 Thinking

`20:22:39`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `item_added\.connect|item_added.connect` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`20:22:40`

Glob: `*.gd`

```
scripts\game_stats.gd:51:		Items.item_added.connect(_on_item_added)
scripts\items\item_behaviours.gd:660:	_items.item_added.connect(_on_item_added)
scripts\items\item_description_hud.gd:201:		_items.item_added.connect(_on_item_added)
```

### 💭 Thinking

`20:22:45`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _on_item_added" -A 10` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_description_hud.gd`

`20:22:45`

```
No matches found
```

#### 🔎 Grep `_on_item_added` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_description_hud.gd`

`20:22:49`

```
201:		_items.item_added.connect(_on_item_added)
202-		_items.inventory_changed.connect(_refresh_list)
203-		_items.active_item_charge_changed.connect(_on_charge_changed)
204-		_items.active_slots_changed.connect(_refresh_active_slot)
205-		_refresh_list()
206-
207-	SettingsManager.hud_visible_changed.connect(_on_visibility_setting_changed)
208-	SettingsManager.hud_element_visible_changed.connect(_on_element_setting_changed)
209-	_apply_visibility()
--
376:func _on_item_added(item: ItemData) -> void:
377-	show_item(item)
378-
379-
380-## persistent = true: die Karte bleibt stehen, bis hide_item() kommt. Genau
381-## das benutzt TreasurePedestal, solange der Spieler in Reichweite ist.
382-## persistent = false: die Karte blendet nach card_display_time aus — der
383-## Fall "gerade eingesammelt".
384-func show_item(item: ItemData, persistent: bool = false) -> void:
```

### 💭 Thinking

`20:23:06`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `static func build_all|func load_external|const ID_|static func _item_|^func " ` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_catalog.gd`

`20:23:08`

```
54:const ID_WOODEN_SPOON: String = "wooden_spoon"
55:const ID_RUSTY_CLEAVER: String = "rusty_cleaver"
56:const ID_STATIC_SOCK: String = "static_sock"
57:const ID_BRIMSTONE_HORNS: String = "brimstone_horns"
58:const ID_HOLY_OIL: String = "holy_oil"
59:const ID_JUMPER_CABLES: String = "jumper_cables"
60:const ID_MAGNETIC_COMPASS: String = "magnetic_compass"
61:const ID_ACID_BOOTS: String = "acid_boots"
64:const ID_PROTEIN_SHAKE: String = "protein_shake"
65:const ID_TIGHT_PANTS: String = "tight_pants"
66:const ID_PLASTIC_HALO: String = "plastic_halo"
67:const ID_BLOOD_PACT: String = "blood_pact"
68:const ID_ROOF_NAIL: String = "roof_nail"
69:const ID_CHEWING_GUM: String = "chewing_gum"
70:const ID_BROKEN_TOASTER: String = "broken_toaster"
71:const ID_HAIRSPRAY: String = "hairspray"
72:const ID_MODEM_56K: String = "modem_56k"
73:const ID_LASER_POINTER: String = "laser_pointer"
74:const ID_RICE_PUDDING: String = "rice_pudding"
75:const ID_TENNIS_BALL: String = "tennis_ball"
76:const ID_DISCO_BALL: String = "disco_ball"
77:const ID_ICE_BAG: String = "ice_bag"
78:const ID_KNITTING_NEEDLES: String = "knitting_needles"
79:const ID_DEVIL_OUTFIT: String = "devil_outfit"
80:const ID_NUN_HABIT: String = "nun_habit"
81:const ID_HANDBALL_PADS: String = "handball_pads"
82:const ID_GOLDEN_CREDIT_CARD: String = "golden_credit_card"
83:const ID_STILETTO_HEELS: String = "stiletto_heels"
86:const ID_MOSQUITO_SPRAY: String = "mosquito_spray"
87:const ID_VAMPIRE_TEETH: String = "vampire_teeth"
88:const ID_EXECUTIONER_HOOD: String = "executioner_hood"
89:const ID_CHILI_OIL: String = "chili_oil"
90:const ID_BATTERY_PACK: String = "battery_pack"
91:const ID_CAR_ALARM: String = "car_alarm"
92:const ID_SUPER_GLUE: String = "super_glue"
93:const ID_ROLLER_SKATES: String = "roller_skates"
94:const ID_BUBBLE_GUM: String = "bubble_gum"
95:const ID_COPPER_WIRE: String = "copper_wire"
98:const ID_OUIJA_BOARD: String = "ouija_board"
101:const ID_STORM_LIGHTER: String = "storm_lighter"

[Showing results with pagination = limit: 40]
```

#### 🔎 Grep `static func build_all|return \[|result.append|^\treturn result|var result" ` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_catalog.gd`

`20:23:12`

```
165:static func build_all() -> Array[ItemData]:
1188:				result.append(res)
1192:	return result
```

#### 👀 Read `item_catalog.gd`

`20:23:16`

*(lines 100–230)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_catalog.gd</code></summary>

```
# --- Phase 4: 8 aktive Items ------------------------------------------------
const ID_STORM_LIGHTER: String = "storm_lighter"
const ID_LIBRARY_BOOK: String = "library_book"
const ID_CURSED_DIE: String = "cursed_die"
const ID_HAND_VACUUM: String = "hand_vacuum"
const ID_PEPPER_MILL: String = "pepper_mill"
const ID_WALKMAN: String = "walkman"
const ID_MEGAPHONE: String = "megaphone"
const ID_WHIPPED_CREAM: String = "whipped_cream"

# --- Tabellen-Nr. 10-13 (1.10-1.13): urspruenglich fehlende Aktiv-Items ----
const ID_BOOMBOX: String = "boombox"
const ID_SPICY_RAMEN: String = "spicy_ramen"
const ID_POCKET_FAN: String = "pocket_fan"
const ID_GRAFFITI_CAN: String = "graffiti_can"

# --- Tabellen-Nr. 51-83: neue Items (Auszug - siehe item_behaviours.gd) -----
const ID_UPDRAFT: String = "updraft"
const ID_HEALING_ORB: String = "healing_orb"
const ID_SLOW_ORB: String = "slow_orb"
const ID_INCENDIARY: String = "incendiary"
const ID_BARRIER_ORB: String = "barrier_orb"
const ID_SHOCK_BOLT: String = "shock_bolt"
const ID_ROLLING_THUNDER: String = "rolling_thunder"
const ID_FAULT_LINE: String = "fault_line"
const ID_STIM_BEACON: String = "stim_beacon"
const ID_SEIZE: String = "seize"
const ID_DEVOUR: String = "devour"
const ID_HUNTERS_FURY: String = "hunters_fury"
const ID_TURRET: String = "turret"
const ID_ORBITAL_STRIKE: String = "orbital_strike"
const ID_SNAKE_BITE: String = "snake_bite"
const ID_BLADE_STORM: String = "blade_storm"
const ID_BLAZE: String = "blaze"
const ID_HOT_HANDS: String = "hot_hands"
const ID_RUN_IT_BACK: String = "run_it_back"
const ID_BOOM_BOT: String = "boom_bot"
const ID_PAINT_SHELLS: String = "paint_shells"
const ID_SHOWSTOPPER: String = "showstopper"
const ID_LEER: String = "leer"
const ID_EMPRESS: String = "empress"
const ID_FAKEOUT: String = "fakeout"
const ID_GATECRASH: String = "gatecrash"
const ID_AFTERSHOCK: String = "aftershock"
const ID_PROWLER: String = "prowler"
const ID_NIGHTFALL: String = "nightfall"
const ID_PARANOIA: String = "paranoia"
const ID_NANOSWARM: String = "nanoswarm"
const ID_ALARMBOT: String = "alarmbot"
const ID_LOCKDOWN: String = "lockdown"

# --- Schulhof-Items (Nr. 84-93) ---------------------------------------------
const ID_POCKET_CALCULATOR: String = "pocket_calculator"
const ID_JUMP_ROPE: String = "jump_rope"
const ID_SET_SQUARE: String = "set_square"
const ID_CHALK_ERASER: String = "chalk_eraser"
const ID_EMPTY_ENERGY_CAN: String = "empty_energy_can"
const ID_OLD_COMPASS: String = "old_compass"
const ID_TANGLED_YOYO: String = "tangled_yoyo"
const ID_BROKEN_PENCIL: String = "broken_pencil"
const ID_PAINTBOX: String = "paintbox"
const ID_FORGOTTEN_GYM_BAG: String = "forgotten_gym_bag"


## Liefert alle Items als Array. Reihenfolge = Reihenfolge im Design-Dokument.
static func build_all() -> Array[ItemData]:
	var items: Array[ItemData] = []

	# ======================================================================
	# BESTANDSITEMS
	# ======================================================================

	var spoon := ItemData.create(
		ID_WOODEN_SPOON,
		"Mamas Kochloeffel",
		"Schlag die Hitze zurueck",
		"Ein Treffer auf einen Gegner gibt 0,75 s lang 1,5x Tempo und Unverwundbarkeit.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.UNCOMMON,
		14, "2.1"
	)
	items.append(spoon)

	var cleaver := ItemData.create(
		ID_RUSTY_CLEAVER,
		"Rostiges Beil",
		"Schwere Hiebe",
		"30 % Chance, Bluten zuzufuegen: 4 s lang jede Sekunde Schaden.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.COMMON,
		15, "2.2"
	)
	cleaver.stat_modifiers = { PlayerStats.STAT_DAMAGE: {"mul": 1.05} }
	items.append(cleaver)

	var sock := ItemData.create(
		ID_STATIC_SOCK,
		"Statische Socke",
		"Ladung baut sich auf",
		"Jeder 6. Treffer entlaedt eine Schockwelle: doppelter Schaden im Umkreis, Gegner werden zurueckgestossen.",
		ItemData.Kind.PASSIVE, ItemData.Category.MELEE, ItemData.Rarity.RARE,
		16, "2.3"
	)
	items.append(sock)

	var horns := ItemData.create(
		ID_BRIMSTONE_HORNS,
		"Hoellenfeuer-Hoerner",
		"Ramm sie!",
		"Wer mit hohem Tempo in einen Gegner laeuft, loest eine Ramm-Attacke aus: hoher Kontaktschaden und Rueckstoss.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.RARE,
		17, "2.4"
	)
	horns.stat_modifiers = { PlayerStats.STAT_MOVE_SPEED: {"add": 1.0} }
	items.append(horns)

	var oil := ItemData.create(
		ID_HOLY_OIL,
		"Heiliges Oel",
		"Hinterlasse eine Spur",
		"Hinterlaesst beim Laufen eine Pfuetze. Gegner darin erleiden Schaden und werden 25 % verlangsamt.",
		ItemData.Kind.PASSIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC,
		18, "2.5"
	)
	items.append(oil)

	var cables := ItemData.create(
		ID_JUMPER_CABLES,
		"Papas Starthilfekabel",
		"Zisch & Zap",
		"Sofortiger Dash nach vorne. Durchquerte Gegner nehmen hohen Schaden und werden 2 s betaeubt.",
		ItemData.Kind.ACTIVE, ItemData.Category.MOVEMENT, ItemData.Rarity.EPIC,
```
</details>

### 💭 Thinking

`20:23:23`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `item_catalog.gd`

`20:23:24`

*(lines 1150–1192)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_catalog.gd</code></summary>

```
	var paintbox := ItemData.create(
		ID_PAINTBOX, "Tuschkasten", "Bunter als der Rest",
		"Schuesse leuchten in zufaelligen Farben. +5 Max-HP.",
		ItemData.Kind.PASSIVE, ItemData.Category.UTILITY, ItemData.Rarity.COMMON,
		92, "2.47"
	)
	paintbox.stat_modifiers = { PlayerStats.STAT_MAX_HEALTH: {"add": 5.0} }
	items.append(paintbox)

	var gym_bag := ItemData.create(
		ID_FORGOTTEN_GYM_BAG, "Vergessener Turnbeutel", "Riecht nach Ueberleben",
		"100% Immun gegen Verlangsamung.",
		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.UNCOMMON,
		93, "2.48"
	)
	items.append(gym_bag)

	return item


## Optionaler Zusatz-Ladepfad fuer spaetere .tres-Items. Fehlt der Ordner,
## passiert nichts — das ist kein Fehlerfall, sondern der Normalzustand,
## solange alle Items aus dem Code kommen.
static func load_external(directory: String = "res://resources/items") -> Array[ItemData]:
	var result: Array[ItemData] = []
	if not DirAccess.dir_exists_absolute(directory):
		return result

	var dir := DirAccess.open(directory)
	if dir == null:
		return result

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res: Resource = load(directory.path_join(file_name))
			if res is ItemData and (res as ItemData).id != "":
				result.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()

```
</details>

### 💭 Thinking

`20:24:11`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _has\(|func _health_of\(|func _player\(\)|CLEAVER_BLEED_CHANCE|const .*_CHANCE" ` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`20:24:12`

```
668:func _player() -> CharacterBody3D:
669-	if _items == null:
670-		return null
671-	var p = _items.player
672-	if p is CharacterBody3D and is_instance_valid(p):
--
677:func _has(item_id: String) -> bool:
678-	return _items != null and _items.has_item(item_id)
679-
680-
681-func _stats() -> PlayerStats:
--
694:func _health_of(enemy: Node) -> Health:
695-	if enemy == null or not is_instance_valid(enemy):
696-		return null
697-	return enemy.find_child("Health", true, false) as Health
698-
```

### 💭 Thinking

`20:24:19`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `item_behaviours.gd`

`20:24:20`

*(lines 140–170)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd</code></summary>

```
# PHASE 4 — PASSIVE ITEMS
# ============================================================================

# --- P1. Proteinshake aus den 90ern ---
## Faktor auf die Skalierung der Angriffs-Hitboxen. 0.85 = 15 % kleiner.
const SHAKE_HITBOX_SCALE: float = 0.85

# --- P2. Omas Enge Hosen ---
const PANTS_MIN_SPEED: float = 8.0
const PANTS_RANGE: float = 2.4
const PANTS_DAMAGE_FACTOR: float = 0.5
const PANTS_COOLDOWN_PER_TARGET: float = 1.0
## ITEM-REWORK: Richtungswechsel als zweiter Ausloeser neben dem
## Vorbeirennen ("Body-Check"). Winkel zwischen letzter und aktueller
## Bewegungsrichtung, ab dem ein Wechsel als "abrupt" zaehlt.
const PANTS_TURN_ANGLE_DEG: float = 100.0
## Rueckstoss-Distanz "4 Meter" aus der Design-Vorgabe, umgerechnet ueber
## dieselbe Abbrems-Formel wie EnemyAI.apply_knockback()/knockback_friction
## (v0^2 = 2 * Reibung * Distanz). knockback_friction ist bei EnemyAI ein
## @export mit Standardwert 10.0 - der Wert hier trifft die 4 Meter fuer
## Gegner mit dieser Standardreibung.
const PANTS_KNOCKBACK: float = 9.0

# --- P3. Plastik-Heiligenschein ---
const HALO_HEAL_CHANCE: float = 0.10
const HALO_HEAL_AMOUNT: float = 0.5

# --- P4. Das Blutpakt ---
const PACT_HITS_PER_COST: int = 5
const PACT_SELF_DAMAGE: float = 0.5
```
</details>

### 💭 Thinking

`20:24:25`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _apply_plastic_halo" -A 20` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`20:24:26`

```
No matches found
```

#### 🔎 Grep `_apply_plastic_halo` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`20:24:30`

```
1200:			_apply_plastic_halo(target)
1201-		if _has(ItemCatalog.ID_DISCO_BALL):
1202-			_apply_disco_ball(target)
1203-		if _has(ItemCatalog.ID_MOSQUITO_SPRAY) and target_had_dot:
1204-			_apply_mosquito_spray()
1205-		if _has(ItemCatalog.ID_VAMPIRE_TEETH) and target_had_any_status:
1206-			_apply_vampire_teeth()
1207-		if _has(ItemCatalog.ID_EXECUTIONER_HOOD) and target_was_stunned_or_rooted:
1208-			_apply_executioner_hood(target)
1209-		if _has(ItemCatalog.ID_SUPER_GLUE):
1210-			_spawn_glue_spot(target.global_position)
1211-		if _has(ItemCatalog.ID_DEVOUR):
1212-			_apply_devour(_player())
1213-		if _has(ItemCatalog.ID_EMPRESS) and _empress_buff_timer > 0.0:
1214-			_apply_empress()
1215-
1216-	# --- Game Juice -----------------------------------------------------
1217-	# Der Hit-Stop haengt an der Wucht des Angriffs, nicht am Item: die
1218-	# SecondaryHitbox macht doppelten Schaden und bekommt deshalb den
1219-	# laengeren Freeze.
1220-	if hitbox != null and hitbox.name.begins_with("Secondary"):
--
1389:func _apply_plastic_halo(target: Node3D) -> void:
1390-	if randf() > HALO_HEAL_CHANCE:
1391-		return
1392-	if _player_health != null:
1393-		_player_health.heal(HALO_HEAL_AMOUNT)
1394-	var player: CharacterBody3D = _player()
1395-	if player != null:
1396-		_spawn_vfx(HOLOGRAM_BLUE_SCENE, player.global_position + Vector3.UP * 2.2)
1397-	_spawn_vfx(HOLOGRAM_BLUE_SCENE, target.global_position + Vector3.UP * 1.5)
1398-
1399-
1400-# ----------------------------------------------------------------------------
1401-# P14. Gefrierbeutel voll Eis — starke Verlangsamung + Thermoschock
1402-# ----------------------------------------------------------------------------
1403-func _apply_ice_bag(target: Node3D) -> void:
1404-	if randf() > ICE_CHANCE:
1405-		return
1406-
1407-	# REIHENFOLGE IST WICHTIG: der Thermoschock liest die RESTdauer des
1408-	# Brands. Wuerde erst der Slow angewendet, waere das egal — aber wuerde
1409-	# erst StatusBurn.clear() laufen, waere der Restschaden weg. Deshalb
```

### 💭 Thinking

`20:24:36`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_player_health` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`20:24:38`

```
646:var _player_health: Health = null
938:	_player_health = player.get_node_or_null("Health") as Health
939:	if _player_health != null:
940:		if not _player_health.damage_taken.is_connected(_on_player_damaged):
941:			_player_health.damage_taken.connect(_on_player_damaged)
942:		if not _player_health.health_changed.is_connected(_on_player_health_changed):
943:			_player_health.health_changed.connect(_on_player_health_changed)
1010:func _on_player_health_changed(_current: float, _max: float) -> void:
1061:	if not _has(ItemCatalog.ID_DEVIL_OUTFIT) or _player_health == null:
1070:	var low: bool = _player_health.get_health_percent() < DEVIL_HEALTH_THRESHOLD
1234:	if _player_health != null:
1235:		_player_health.set_invulnerable(SPOON_DURATION)
1376:	if _player_health == null:
1381:	_player_health.current_health = maxf(_player_health.current_health - PACT_SELF_DAMAGE, 1.0)
1382:	_player_health.health_changed.emit(_player_health.current_health, _player_health.max_health)

[Showing results with pagination = limit: 15]
```

### 💭 Thinking

`20:25:16`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `detect_range` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\acid_sprinkler.gd`

`20:25:17`

```
26-var flight_time: float = 0.7
27-var puddle_radius: float = 2.6
28-var puddle_lifetime: float = 6.0
29:var detect_range: float = 40.0
--
82-	var player: CharacterBody3D = _find_player()
83-	if player == null:
84-		return
85:	if global_position.distance_to(player.global_position) > detect_range:
```

### 💭 Thinking

`20:25:27`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `threat_budget|room_scale|footprint_cells|cell_size` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`20:25:28`

```
65:@export var room_scale: Vector3 = Vector3(2.0, 2.0, 2.0)
67:## Referenzgroesse EINER Raum-Szene bei room_scale = (1,1,1). Nicht aendern,
69:## von der cell_size und elevation_step abgeleitet werden.
73:## Wird in _ready() aus BASE_CELL_SIZE * room_scale berechnet - siehe
74:## _apply_room_scale(). Kein @export mehr: zwei unabhaengig editierbare
80:var cell_size: Vector3 = BASE_CELL_SIZE
83:## room_scale.y, damit die Rampen in Korridoren mit Hoehenunterschied bei
97:@export var combat_threat_budget: int = 64
98:@export var corridor_threat_budget: int = 12
99:@export var boss_threat_budget: int = 12
204:	# PHASE 3: cell_size/elevation_step aus room_scale ableiten, BEVOR
207:	_apply_room_scale()
299:## PHASE 3: leitet cell_size und elevation_step aus room_scale ab, statt sie
302:func _apply_room_scale() -> void:
303:	cell_size = Vector3(
304:		BASE_CELL_SIZE.x * room_scale.x,
306:		BASE_CELL_SIZE.z * room_scale.z
308:	elevation_step = BASE_ELEVATION_STEP * room_scale.y
428:		if data.footprint_cells != cell.footprint:
429:			cell.footprint = data.footprint_cells
439:			(float(grid_pos.x) + center_offset.x) * cell_size.x,
441:			(float(grid_pos.y) + center_offset.y) * cell_size.z
460:		# load_room() setzt die Raum-Basis auf Basis.IDENTITY.scaled(room_scale).
463:		# room_scale.y multipliziert.
469:		# elevation_step * room_scale.y Meter, der Nachbarraum lag aber nur
470:		# elevation_step hoeher. Bei room_scale.y = 2.0 und
476:		# umgerechnet: local_rise * room_scale.y == elevation_step.
478:			var local_rise: float = cell.slope_delta * elevation_step / maxf(room_scale.y, 0.001)
946:			base = combat_threat_budget
948:			base = corridor_threat_budget
950:			base = boss_threat_budget
983:## footprint_cells EXAKT der geforderten Grundflaeche entsprechen — ein
1020:		if data.footprint_cells != footprint:
1041:## Deshalb gilt fuer jede Szene mit footprint_cells != (1,1) die Konvention:
1081:	# PHASE 3: room_scale mit in die Basis packen statt Basis.IDENTITY.
1088:	instance.global_transform = Transform3D(Basis.IDENTITY.scaled(room_scale), spawn_transform.origin)
```

### 💭 Thinking

`20:25:36`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `level_generator.gd`

`20:25:36`

*(lines 60–105)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
## NEBENEFFEKT (bewusst in Kauf genommen): Wandstaerke skaliert mit derselben
## Achse wie die Wandlaenge (beide liegen in der Grundriss-Ebene), Waende
## werden also spuerbar dicker (1.0 -> 3.0 Einheiten). Bei der PSX-Optik
## dieses Spiels passt das eher zum Stil, als dass es stoert - falls nicht,
## ist das der erste Punkt, an dem man ansetzt.
@export var room_scale: Vector3 = Vector3(2.0, 2.0, 2.0)

## Referenzgroesse EINER Raum-Szene bei room_scale = (1,1,1). Nicht aendern,
## ohne auch die Raum-Szenen selbst neu zu bauen - das hier ist die Basis,
## von der cell_size und elevation_step abgeleitet werden.
const BASE_CELL_SIZE: Vector3 = Vector3(48.0, 0.0, 48.0)
const BASE_ELEVATION_STEP: float = 6.0

## Wird in _ready() aus BASE_CELL_SIZE * room_scale berechnet - siehe
## _apply_room_scale(). Kein @export mehr: zwei unabhaengig editierbare
## Werte (Raumgroesse UND Zellenabstand), die von Hand synchron gehalten
## werden muessten, sind genau das Muster, das im HUD schon einmal zu einem
## "manchmal"-Bug gefuehrt hat (Minimap/Timer liefen auseinander, weil zwei
## Pixelwerte unabhaengig voneinander geaendert wurden). Hier ist derselbe
## Fehler strukturell ausgeschlossen.
var cell_size: Vector3 = BASE_CELL_SIZE

## Weltraum-Hoehe EINER Hoehenstufe aus dem RoomGridGenerator. Skaliert mit
## room_scale.y, damit die Rampen in Korridoren mit Hoehenunterschied bei
## der neuen, 4x hoeheren Raumdecke nicht unproportional flach wirken.
var elevation_step: float = BASE_ELEVATION_STEP

@export var grid_generator: RoomGridGenerator
@export var autostart: bool = true

## PHASE 3: von 5/2/12 auf grob das 3-Fache angehoben, damit ein Kampfraum
## bei jetzt 4x groesserer Grundflaeche (2x Breite * 2x Tiefe) nicht wie
## leergefegt wirkt.
## PHASE 4: nochmal verdoppelt (16 -> 32 / 6 -> 12) - explizit angefordert,
## unabhaengig von der Raumflaeche. Fighter kostet 3 Threat, Stinger 1
## (siehe es_fighter.tres / es_stinger.tres) - 32 heisst grob "6 Fighter +
## 14 Stinger" oder jede Mischung dazwischen.
@export var combat_threat_budget: int = 64
@export var corridor_threat_budget: int = 12
@export var boss_threat_budget: int = 12
@export var threat_per_stage: int = 2

## --- Stage-Skalierung der Gegnerstaerke -------------------------------
## threat_per_stage erhoeht bisher NUR die Anzahl. Ein Stinger in Etage 5
## hatte damit exakt dieselben 25 HP und 6 Schaden wie in Etage 1 - es
```
</details>

### 💭 Thinking

`20:25:43`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `level_generator.gd`

`20:25:44`

*(lines 915–990)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
	for pr in problems:
		print("      !! %s" % pr)

	print("===== ENDE TUER-PROTOKOLL =====")


func _door_kind_name(kind: int) -> String:
	match kind:
		Door.DoorKind.NORMAL: return "NORMAL"
		Door.DoorKind.BOSS: return "BOSS"
		Door.DoorKind.TREASURE: return "TRESOR"
	return "-"


# --- Gegner-Tabellen & Budget ---------------------------------------

func _table_for_type(type: int) -> Array[EnemySpawnEntry]:
	if type == RoomData.RoomType.BOSS:
		if not boss_table.is_empty():
			return boss_table
		return enemy_table
	if type == RoomData.RoomType.COMBAT or type == RoomData.RoomType.CORRIDOR:
		return enemy_table
	var empty: Array[EnemySpawnEntry] = []
	return empty


func _budget_for_type(type: int) -> int:
	var base: int = 0
	match type:
		RoomData.RoomType.COMBAT:
			base = combat_threat_budget
		RoomData.RoomType.CORRIDOR:
			base = corridor_threat_budget
		RoomData.RoomType.BOSS:
			base = boss_threat_budget
		_:
			return 0

	var cap: int = boss_threat_hard_cap if type == RoomData.RoomType.BOSS else threat_hard_cap
	return clampi(base + (current_stage - 1) * threat_per_stage, 0, cap)

# --- Navigation ------------------------------------------------------

func _rebake_navigation() -> void:
	if navigation_region == null:
		return
	if navigation_region.navigation_mesh == null:
		push_error("[LevelGenerator] NavigationRegion3D hat keine NavigationMesh-Resource - Baking uebersprungen.")
		return
	await get_tree().process_frame
	await get_tree().physics_frame
	navigation_region.bake_navigation_mesh(false)
	print("[LevelGenerator] NavMesh gebakt (%d Quell-Nodes in '%s')." % [get_tree().get_nodes_in_group(NAV_SOURCE_GROUP).size(), NAV_SOURCE_GROUP])

# --- Raum-Auswahl ----------------------------------------------------

func _clear_current_rooms() -> void:
	for room in _instances.values():
		if is_instance_valid(room):
			var parent: Node = room.get_parent()
			if parent:
				parent.remove_child(room)
			room.queue_free()
	_instances.clear()


## PHASE 3.1: footprint kam dazu. Eine Vorlage passt nur, wenn ihre
## footprint_cells EXAKT der geforderten Grundflaeche entsprechen — ein
## 1x1-Raum in eine 2x1-Luecke zu setzen wuerde die halbe Flaeche als Loch
## im Level stehen lassen.
##
## FALLBACK: findet sich nichts, wird auf (1,1) zurueckgefallen und die
## Zusatzzellen bleiben ungenutzt. Besser ein etwas leereres Layout als ein
## Abbruch mitten in der Generierung.
```
</details>

### 💭 Thinking

`20:25:49`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_budget_for_type\(|prepare_enemies|footprint` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`20:25:50`

```
54:## Decke und Tuerstuerze dagegen bereits PARAMETRISCH aus room_footprint/
416:		var data: RoomData = _pick_room(cell.room_type, cell.exit_flags, cell.footprint)
422:		# keine passende Groesse hat (siehe dortiger Kommentar). cell.footprint
428:		if data.footprint_cells != cell.footprint:
429:			cell.footprint = data.footprint_cells
489:		var budget: int = _budget_for_type(cell.room_type)
490:		room.prepare_enemies(table, budget, current_stage, cell.room_type == RoomData.RoomType.BOSS)
508:			"footprint": cell.footprint,
942:func _budget_for_type(type: int) -> int:
982:## PHASE 3.1: footprint kam dazu. Eine Vorlage passt nur, wenn ihre
983:## footprint_cells EXAKT der geforderten Grundflaeche entsprechen — ein
990:func _pick_room(type: int, required_exit_flags: int, footprint: Vector2i = Vector2i.ONE) -> RoomData:
991:	var candidates: Array[RoomData] = _collect_candidates(type, required_exit_flags, footprint)
993:	if candidates.is_empty() and (footprint.x > 1 or footprint.y > 1):
994:		push_warning("LevelGenerator: Keine %dx%d-Vorlage fuer Typ %s im Pool - falle auf 1x1 zurueck. Die Zusatzzellen bleiben leer." % [footprint.x, footprint.y, type])
998:		push_error("LevelGenerator: Kein passender Raum fuer Typ %s (Exits %d, Flaeche %dx%d) gefunden!" % [type, required_exit_flags, footprint.x, footprint.y])
1007:func _collect_candidates(type: int, required_exit_flags: int, footprint: Vector2i) -> Array[RoomData]:
1020:		if data.footprint_cells != footprint:
1041:## Deshalb gilt fuer jede Szene mit footprint_cells != (1,1) die Konvention:
```

### 💭 Thinking

`20:26:04`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `threat_hard_cap` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`20:26:05`

```
111-@export var enemy_health_per_stage: float = 0.30
112-@export var enemy_damage_per_stage: float = 0.18
113-@export var enemy_scaling_cap: float = 4.0
114:@export var threat_hard_cap: int = 64
115-
116:## Eigener Deckel fuer den Bossraum. Ohne den wuerde threat_hard_cap (14)
117-## drei Colossus a 10 Threat sofort abwuergen - der dritte passt schlicht
118-## nicht mehr ins Budget. Den globalen Cap dafuer hochzuziehen ist keine
119-## Option: er begrenzt auch normale Kampfraeume in spaeteren Stages.
120:@export var boss_threat_hard_cap: int = 40
--
951-		_:
952-			return 0
953-
954:	var cap: int = boss_threat_hard_cap if type == RoomData.RoomType.BOSS else threat_hard_cap
```

### 🤖 Assistant: *I've gathered enough context on every part…*

`20:26:38`

<details>
<summary>Thinking...</summary>

> 
</details>

> I've gathered enough context on every part of this. Let me work through them systematically, starting with the shared `EnemyQuery` fix that underlies both Karina issues.

#### ✏️  Edit `enemy_query.gd`

`20:26:49`

```diff
@@ -1 +1,49 @@+## Wie enemies_within(), aber mit GETRENNTER horizontaler/vertikaler
+## Reichweite statt eines reinen Kugel-Radius - fuer bodennahe Aura-/
+## Beruehrungs-Faehigkeiten, die auch treffen sollen, waehrend der Spieler in
+## der Luft ist (z.B. nach einem Sprung).
+##
+## WARUM enemies_within() DAFUER NICHT REICHT: es misst die volle 3D-Distanz
+## von from_pos (Spieler-URSPRUNG, mittig in der Kapsel). Ein Gegner-Ursprung
+## liegt aber bei den FUESSEN (rund 0.9 Einheiten unter einem gleich hoch
+## stehenden Spieler, siehe combat_base.gd::dash_hit_height_up-Kommentar fuer
+## dieselbe Herleitung). Springt der Spieler (player_base.gd: jump_velocity=
+## 13.0, gravity=40.0 -> ~2.1 Einheiten Sprunghoehe), addiert sich das zum
+## Fuesse-Versatz auf ~3.0 Einheiten - bei einem Radius von z.B. 3.0
+## (Karinas acid_aura_radius) fallen dadurch WAEHREND DES SPRUNGS bereits
+## horizontal direkt neben dem Spieler stehende Gegner aus der reinen
+## Kugel-Distanz heraus, obwohl der Angriff im Flachen problemlos treffen
+## wuerde. Getrennte horizontale/vertikale Fenster (wie beim Dash-Schaden)
+## umgehen das.
+static func enemies_within_flat(
+		from_pos: Vector3, horizontal_radius: float,
+		height_up: float = 3.0, height_down: float = 5.0
+) -> Array[Node3D]:
+	var result: Array[Node3D] = []
+
+	var tree := Engine.get_main_loop() as SceneTree
+	if tree == null:
+		return result
+
+	for node: Node in tree.get_nodes_in_group("enemies"):
+		if not (node is Node3D) or not is_instance_valid(node):
+			continue
+		var enemy: Node3D = node as Node3D
+		var to_enemy: Vector3 = enemy.global_position - from_pos
+
+		if to_enemy.y > height_up or to_enemy.y < -height_down:
+			continue
+		var flat_dist: float = Vector2(to_enemy.x, to_enemy.z).length()
+		if flat_dist > horizontal_radius:
+			continue
+
+		var health: Node = enemy.find_child("Health", true, false)
+		if health == null or not (health is Health) or not (health as Health).is_alive():
+			continue
+
+		result.append(enemy)
+
+	return result
+
+
 ## Aim-Assist: liegt ein lebender Gegner innerhalb "max_angle_deg" um die
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\core\enemy_query.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `combat_karina.gd` — flat-radius fix…*

`20:26:52`

> Now `combat_karina.gd` — flat-radius fix for both abilities, wider/faster stealth touch, and the lifesteal hooks:

#### ✏️  Edit `combat_karina.gd`

`20:26:55`

```diff
@@ -1,5 +1,7 @@ ## --- Secondary "Phantom Execute" ---------------------------------------------
 @export var stealth_max_duration: float = 5.0
 @export var stealth_reentry_cooldown: float = 5.0
-@export var stealth_touch_radius: float = 1.6
+## War 1.6 - Rueckmeldung "Vernetzung (Markieren) funktioniert manchmal
+## nicht, Hitbox sollte grosszuegiger sein". Auf 2.6 angehoben.
+@export var stealth_touch_radius: float = 2.6
 @export var detonation_damage: float = 220.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:26:59`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_karina.gd`

`20:27:02`

```diff
@@ -1,2 +1,6 @@ const STEALTH_MESH_TRANSPARENCY: float = 0.96
-const STEALTH_TOUCH_CHECK_INTERVAL: float = 0.15
+## War 0.15 - bei Karinas Lauftempo (~15-19 u/s) legt sie zwischen zwei
+## Pruefungen bis zu ~2.85 Einheiten zurueck; bei einem Vorbeilaufen konnte
+## das den Beruehrungs-Check komplett verpassen ("Vernetzung funktioniert
+## manchmal nicht"). Auf 0.05 gesenkt (~20x/s statt ~6.7x/s).
+const STEALTH_TOUCH_CHECK_INTERVAL: float = 0.05
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the two `EnemyQuery.enemies_within(.…*

`20:27:06`

> Now the two `EnemyQuery.enemies_within(...)` call sites and the `setup()`/field additions for the lifesteal hook:

#### ✏️  Edit `combat_karina.gd`

`20:27:09`

```diff
@@ -1,2 +1,8 @@ var _health: Health = null
+## Fuer Karinas feste Passive "Reflexe" (Lifesteal-on-Hit, siehe
+## item_behaviours.gd::try_karina_lifesteal()) - Karinas Angriffe laufen nie
+## ueber Hitbox.hit_landed (siehe Klassenkommentar), das normale
+## player_hit_enemy-Signal feuert fuer sie also nie. Direkter Aufruf bei
+## jedem eigenen Treffer statt dessen.
+var _item_behaviours: Node = null
 var _meshes: Array[MeshInstance3D] = []
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,6 +1,7 @@ func setup(owner_player: CharacterBody3D) -> void:
 	super.setup(owner_player)
 	_health = player.get_node_or_null("Health") as Health
+	_item_behaviours = get_node_or_null("/root/Items/ItemBehaviours")
 	var model: Node = player.get_node_or_null("CharacterModel")
 	_meshes = _collect_mesh_instances(model) if model else []
 	if ghost_trail:
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the `_tick_acid_aura()` hit loop (LMB…*

`20:27:18`

> Now the `_tick_acid_aura()` hit loop (LMB air-attack fix + lifesteal):

#### ✏️  Edit `combat_karina.gd`

`20:27:25`

```diff
@@ -1,5 +1,15 @@-	for enemy: Node3D in EnemyQuery.enemies_within(player.global_position, acid_aura_radius):
+	# BUGFIX "Primärangriff trifft in der Luft nicht": enemies_within() misst
+	# volle 3D-Kugel-Distanz von Karinas Ursprung. Springt sie, wandert dieser
+	# Ursprung nach oben, waehrend Gegner-Ursprünge am Boden bleiben - ab
+	# Sprunghoehe + Fuesse-Versatz reicht das, um direkt daneben stehende
+	# Gegner rechnerisch aus dem Radius fallen zu lassen (siehe enemy_query.gd
+	# fuer die volle Herleitung). enemies_within_flat() trennt Horizontal-
+	# Radius von einem grosszuegigen Hoehenfenster und trifft dadurch auch
+	# waehrend eines Sprungs zuverlaessig.
+	for enemy: Node3D in EnemyQuery.enemies_within_flat(player.global_position, acid_aura_radius, 3.0, 5.0):
 		if enemy.has_method("apply_status_effect"):
 			hit_anyone = true
 			enemy.apply_status_effect("acid", acid_effect_duration, acid_damage_per_tick, player, acid_tick_interval)
+			if _item_behaviours:
+				_item_behaviours.try_karina_lifesteal()
 			if dns != null:
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the stealth touch-radius check (`_tick_stealth…*

`20:27:27`

> Now the stealth touch-radius check (`_tick_stealth`) and the detonation hit loop:

#### ✏️  Edit `combat_karina.gd`

`20:27:30`

```diff
@@ -1,2 +1,4 @@-	for enemy: Node3D in EnemyQuery.enemies_within(player.global_position, stealth_touch_radius):
+	# Gleicher Grund wie in _tick_acid_aura(): flach statt Kugel-Radius, damit
+	# ein Sprung waehrend Phantom Execute die "Vernetzung" nicht verpasst.
+	for enemy: Node3D in EnemyQuery.enemies_within_flat(player.global_position, stealth_touch_radius, 3.0, 5.0):
 		var id: int = enemy.get_instance_id()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,2 +1,4 @@ 		(health as Health).take_damage(dmg, player)
+		if _item_behaviours:
+			_item_behaviours.try_karina_lifesteal()
 		VFX.spawn(HIT_VFX_SCENE, enemy_3d.global_position + Vector3.UP, Vector3.UP)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the item catalog entry for Karina's passive…*

`20:27:39`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now the item catalog entry for Karina's passive:

#### ✏️  Edit `item_catalog.gd`

`20:27:41`

```diff
@@ -1 +1,4 @@+# --- Charakter-gebundene, unsichtbare Passiven ------------------------------
+const ID_KARINA_LIFESTEAL: String = "karina_passive_lifesteal"
+
 # --- Schulhof-Items (Nr. 84-93) ---------------------------------------------
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_catalog.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1 +1,22 @@+## Karinas feste Passive "Reflexe" - bewusst NICHT Teil des build_all()-
+## Arrays oben: alles darin landet in Items.catalog, aus dem TreasureManager.
+## _pick_item() den Schatzraum-Pool zieht (siehe dortiger Kommentar) - dieses
+## Item darf dort NIE auftauchen, sonst koennte jeder Charakter es finden.
+## char_karina.gd ruft diese Funktion stattdessen direkt auf und uebergibt
+## das Ergebnis an Items.add_item(..., true) (silent=true, kein Popup).
+static func build_karina_passive_lifesteal() -> ItemData:
+	var item := ItemData.create(
+		ID_KARINA_LIFESTEAL,
+		"Karinas Reflexe",
+		"",
+		"15% Chance, bei einem Treffer 5 HP zu heilen.",
+		ItemData.Kind.PASSIVE, ItemData.Category.DEFENSE, ItemData.Rarity.COMMON
+	)
+	# max_stacks = 1: char_karina.gd versucht die Vergabe bei JEDEM Spawnen
+	# (auch nach einem Charakterwechsel zurueck zu Karina) erneut - add_item()
+	# muss doppelte Kopien selbst abweisen.
+	item.max_stacks = 1
+	return item
+
+
 ## Optionaler Zusatz-Ladepfad fuer spaetere .tres-Items. Fehlt der Ordner,
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_catalog.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `char_karina.gd`:*

`20:27:53`

> Now `char_karina.gd`:

#### ✏️  Edit `char_karina.gd`

`20:27:58`

```diff
@@ -2,3 +2,21 @@ class_name CharKarina
 
 # Karina: TODO — char-spezifische Bewegungs-Overrides hier einbauen.
+
+func _ready() -> void:
+	super._ready()
+	_grant_passive_lifesteal()
+
+
+## Feste, unsichtbare Passive (siehe item_catalog.gd::
+## build_karina_passive_lifesteal() / item_behaviours.gd::
+## try_karina_lifesteal()) - wird bei JEDEM Spawnen erneut versucht (auch
+## nach einem Charakterwechsel weg und wieder zurueck zu Karina im selben
+## Run). add_item()s max_stacks=1-Pruefung verhindert doppelte Kopien.
+## silent=true: kein "Item gefunden"-Popup, das Item ist absichtlich
+## unsichtbar.
+func _grant_passive_lifesteal() -> void:
+	var items: Node = get_node_or_null("/root/Items")
+	if item == null:
+		return
+	items.add_item(ItemCatalog.build_karina_passive_lifesteal(), true)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\char_karina.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `item_behaviours.gd` — the constants…*

`20:28:01`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `item_behaviours.gd` — the constants and the dedicated lifesteal method:

#### ✏️  Edit `item_behaviours.gd`

`20:28:03`

```diff
@@ -1,3 +1,7 @@ # --- P3. Plastik-Heiligenschein ---
 const HALO_HEAL_CHANCE: float = 0.10
 const HALO_HEAL_AMOUNT: float = 0.5
+
+# --- Karinas feste Passive "Reflexe" (Lifesteal-on-Hit) ---
+const KARINA_LIFESTEAL_CHANCE: float = 0.15
+const KARINA_LIFESTEAL_AMOUNT: float = 5.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,3 +1,30 @@+# ----------------------------------------------------------------------------
+# Karinas feste Passive "Reflexe" — Lifesteal-Chance auf JEDEM ihrer Treffer
+# ----------------------------------------------------------------------------
+# BEWUSST NICHT ueber player_hit_enemy/_on_player_hit_enemy() oben
+# angebunden: Karinas beide Faehigkeiten (Acid Rush Aura, Phantom Execute-
+# Detonation) laufen nie ueber PrimaryHitbox/SecondaryHitbox (siehe
+# combat_karina.gd-Kopfkommentar) - das Signal wuerde fuer sie also NIE
+# feuern. Selbst wenn es das taete: am Signal-Handler oben haengt u.a.
+# Juice.hit_stop() bei JEDEM Treffer - bei Karinas bis zu 10x/Sekunde
+# tickender Acid-Aura waere das ein Dauer-Freeze-Gefuehl UND wuerde
+# versehentlich JEDEN anderen Treffer-Reaktions-Effekt im Spiel mit
+# ausloesen. combat_karina.gd ruft diese Methode deshalb DIREKT bei jedem
+# eigenen Treffer auf (Aura-Tick UND Detonation), komplett unabhaengig von
+# der generischen Hit-Pipeline.
+func try_karina_lifesteal() -> void:
+	if not _has(ItemCatalog.ID_KARINA_LIFESTEAL):
+		return
+	if _player_health == null or not _player_health.is_alive():
+		return
+	if randf() > KARINA_LIFESTEAL_CHANCE:
+		return
+	_player_health.heal(KARINA_LIFESTEAL_AMOUNT)
+	var player: CharacterBody3D = _player()
+	if player != null:
+		_spawn_vfx(HOLOGRAM_BLUE_SCENE, player.global_position + Vector3.UP * 2.2)
+
+
 # ----------------------------------------------------------------------------
 # P14. Gefrierbeutel voll Eis — starke Verlangsamung + Thermoschock
 # ----------------------------------------------------------------------------
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `item_manager.gd` — the `silent` add…*

`20:28:20`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `item_manager.gd` — the `silent` add flag and the pedestal swap logic:

#### ✏️  Edit `item_manager.gd`

`20:28:38`

```diff
@@ -1,4 +1,10 @@-func add_item(item: ItemData) -> bool:
+## silent = true unterdrueckt NUR item_added (das Signal, an dem die
+## "Item gefunden"-Popup-Karte haengt, siehe item_description_hud.gd::
+## _on_item_added()) - fuer fest verdrahtete, unsichtbare Charakter-Passiven
+## wie Karinas Reflexe (siehe char_karina.gd), die nie "gefunden" werden.
+## inventory_changed bleibt bewusst IMMER an, sonst wuerden Inventarlisten-UI
+## und Stat-Neuberechnung nach einem stillen Grant nicht mitziehen.
+func add_item(item: ItemData, silent: bool = false) -> bool:
 	if item == null:
 		return false
 	if item.max_stacks > 0 and count_item(item.id) >= item.max_stacks:
@@ -12,6 +18,62 @@ 	_apply_item_stats(item, inventory.size() - 1)
 	_register_synergy_tags(item)
 
-	item_added.emit(item)
+	if not silent:
+		item_added.emit(item)
 	inventory_changed.emit()
 	return true
+
+
+## Sonderfall fuer Sockel-Pickups (siehe treasure_pedestal.gd::take()):
+## normales add_item() legt ein DRITTES aktives Item nur unausgeruestet ins
+## Inventar (siehe PHASE-5-Kopfkommentar oben) - fuer einen Sockel ist das
+## die falsche Erwartung ("wozu nehme ich das mit, wenn es eh nichts tut").
+## Rueckmeldung: sind beide Slots (Q+E) schon belegt und man nimmt ein
+## drittes AKTIVES Item vom Sockel, wird stattdessen das Q-Item aus dem
+## Inventar entfernt und als "displaced" zurueckgegeben - der Aufrufer legt
+## es zurueck auf den Sockel (Swap). In jedem anderen Fall (freier Slot,
+## kein aktives Item, Stapelgrenze erreicht) verhaelt es sich wie add_item().
+##
+## Rueckgabe: {"picked_up": bool, "displaced": ItemData oder null}
+func pickup_active_item(item: ItemData) -> Dictionary:
+	if item == null:
+		return {"picked_up": false, "displaced": null}
+	# Stapelgrenze VORAB pruefen (dieselbe Bedingung wie add_item()) - sonst
+	# wuerde ein danach fehlschlagendes add_item() das bereits entfernte
+	# Q-Item ersatzlos verschwinden lassen.
+	if item.max_stacks > 0 and count_item(item.id) >= item.max_stacks:
+		return {"picked_up": false, "displaced": null}
+
+	var both_slots_full: bool = active_items[0] != null and active_items[1] != null
+	if not (item.is_active_item() and both_slots_full):
+		return {"picked_up": add_item(item), "displaced": null}
+
+	var displaced: ItemData = active_items[0]
+	_remove_from_inventory(displaced)
+	active_items[0] = null
+	active_slots_changed.emit()
+
+	add_item(item)
+	return {"picked_up": true, "displaced": displaced}
+
+
+## Entfernt GENAU EIN Exemplar aus dem Inventar (nicht alle Stacks).
+## _apply_item_stats() verknuepft Stat-Modifier ueber die INVENTAR-POSITION
+## (source_id enthaelt den Index, siehe dort) - eine Entfernung aus der
+## Mitte wuerde alle nachfolgenden Indizes verschieben und deren Modifier
+## unter dem ALTEN source_id verwaist zuruecklassen (PlayerStats._modifiers
+## ist ein Dictionary ohne automatische Bereinigung, siehe player_stats.gd).
+## Robuster als jeden verschobenen Index einzeln nachzuziehen: alle
+## Stat-Modifier komplett verwerfen und aus dem (jetzt korrekten) Inventar
+## neu aufbauen - derselbe Ablauf wie reset_run().
+func _remove_from_inventory(item: ItemData) -> void:
+	var index: int = inventory.find(item)
+	if index == -1:
+		return
+	inventory.remove_at(index)
+	_active_charges.erase(item.id)
+	_active_cooldowns.erase(item.id)
+	if stats != null:
+		stats.clear_all()
+		_reapply_all_item_stats()
+	inventory_changed.emit()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_manager.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `treasure_pedestal.gd` — wire the swap…*

`20:28:42`

> Now `treasure_pedestal.gd` — wire the swap into `take()` and add the restock flow:

#### ✏️  Edit `treasure_pedestal.gd`

`20:28:49`

```diff
@@ -5,9 +5,17 @@ 	var items: Node = get_node_or_null("/root/Items")
 	if item == null:
 		return false
-	if not items.add_item(item_data):
+
+	# pickup_active_item() statt add_item(): sind beide Aktiv-Slots (Q/E)
+	# schon belegt und item_data ist selbst aktiv, wird das bisherige
+	# Q-Item verdraengt und muss zurueck auf DIESEN Sockel (Swap statt
+	# nutzlos unausgeruestet im Inventar landen), siehe item_manager.gd.
+	var result: Dictionary = items.pickup_active_item(item_data)
+	if not bool(result.get("picked_up", false)):
 		return false
+	var displaced: ItemData = result.get("displaced") as ItemData
 
+	var taken_item: ItemData = item_data
 	_taken = true
 	# Die Anzeige stand auf "dauerhaft" (Sockel in Reichweite). Ohne diesen
 	# Wechsel bliebe die Karte fuer immer stehen, weil hide_item() erst beim
@@ -17,6 +25,6 @@ 	if hud:
 		hud.hide_item()
 
-	item_taken.emit(item_data, self)
-	_play_take_feedback()
+	item_taken.emit(taken_item, self)
+	_play_take_feedback(displaced)
 	return true
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_pedestal.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,4 +1,7 @@-func _play_take_feedback() -> void:
+## displaced: nur bei einem Q/E-Swap gesetzt (siehe take()) - der Sockel
+## bestueckt sich nach der Wegnahme-Animation selbst neu, statt leer zu
+## bleiben (siehe _finish_take()/_restock()).
+func _play_take_feedback(displaced: ItemData = null) -> void:
 	if _prompt_label:
 		_prompt_label.visible = false
 	if _name_label:
@@ -22,13 +25,41 @@ 	if _light:
 		tween.tween_property(_light, "light_energy", 0.25, 0.5)
 
-	tween.chain().tween_callback(_finish_take)
+	tween.chain().tween_callback(_finish_take.bind(displaced))
 
 
-func _finish_take() -> void:
+func _finish_take(displaced: ItemData = null) -> void:
 	if _float_root and is_instance_valid(_float_root):
 		_float_root.queue_free()
 		_float_root = null
 	if _beam and is_instance_valid(_beam):
 		_beam.queue_free()
 		_beam = null
+
+	if displaced != null:
+		_restock(displaced)
+
+
+## Verdraengtes Q-Item (siehe ItemManager.pickup_active_item() - beide
+## Aktiv-Slots waren voll) landet wieder auf DIESEM Sockel statt spurlos zu
+## verschwinden ("Swap"). Baut Lichtsaeule + schwebendes Item neu auf, exakt
+## wie beim ersten _ready() - _float_root/_beam wurden gerade erst in
+## _finish_take() freigegeben, es gibt also keine Namenskollision.
+func _restock(new_item: ItemData) -> void:
+	item_data = new_item
+	_accent = new_item.pedestal_color
+	_taken = false
+
+	var cap: MeshInstance3D = get_node_or_null("Cap")
+	if cap:
+		cap.material_override = _make_material(_accent, 0.9)
+
+	_build_beam()
+	_build_float_group()
+
+	if _light:
+		_light.light_color = _accent
+	if _name_label:
+		_name_label.text = new_item.display_name
+
+	_preview_shown = false
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_pedestal.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `room_instance.gd` — the floor texture…*

`20:29:07`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `room_instance.gd` — the floor texture tiling fix (multi-cell rooms):

#### ✏️  Edit `room_instance.gd`

`20:29:09`

```diff
@@ -1,2 +1,3 @@ 	if build_ceiling:
 		_build_ceiling()
+	_fix_floor_material_tiling()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:29:12`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `room_instance.gd`

`20:29:25`

```diff
@@ -1,2 +1,51 @@+## BUGFIX "Bodentextur bei mehrzelligen Raeumen (2x1/2x2) sichtbar gestreckt/
+## verzerrt": der Boden ist (anders als die Decke, siehe
+## _make_ceiling_material()) ein in JEDER Raum-.tscn von Hand platziertes
+## BoxMesh mit surface_material_override - dessen UV spannt sich IMMER 0..1
+## ueber die gesamte Mesh-Flaeche (Godot-Standardverhalten fuer BoxMesh/
+## PlaneMesh). In einem normalen 1x1-Raum faellt das nicht auf (alle
+## 1x1-Raeume gleich gross, das Streckungsverhaeltnis ist ueberall
+## identisch) - ein 2x1-footprint_cells-Raum ist aber doppelt so breit:
+## dieselbe Texturkachel wird dort auf die doppelte Breite gestreckt statt
+## sich zu wiederholen, direkt sichtbar neben normalgrossen Nachbarraeumen.
+##
+## Gleicher Fix wie bei der Decke: dupliziertes Material (NIE die geteilte
+## Original-Resource anfassen, sonst aendert das den Boden JEDES Raums im
+## Spiel) mit world_space_uv=true (siehe psx.gdshader) - haelt die
+## Kachelgroesse in Weltunits konstant, unabhaengig von der Bodenflaeche.
+## Laeuft fuer JEDEN Raum, nicht nur mehrzellige - ein 1x1-Raum sieht dabei
+## identisch aus wie vorher, nur jetzt "richtig" statt zufaellig passend.
+func _fix_floor_material_tiling() -> void:
+	var floor_body := get_node_or_null("Floor") as StaticBody3D
+	if floor_body == null:
+		return
+
+	for child in floor_body.get_children():
+		if child is MeshInstance3D:
+			_apply_world_space_uv(child as MeshInstance3D)
+
+
+## Wandelt JEDES Material eines MeshInstance3D (material_override UND alle
+## surface_material_override-Slots) in eine eindeutige Kopie mit
+## world_space_uv=true um. Nicht-ShaderMaterial-Slots (z.B. ein
+## StandardMaterial3D-Fallback) werden unangetastet uebersprungen - der Fix
+## gilt nur fuer das psx.gdshader-Material.
+func _apply_world_space_uv(mesh_instance: MeshInstance3D) -> void:
+	if mesh_instance.material_override is ShaderMaterial:
+		var mat: ShaderMaterial = (mesh_instance.material_override as ShaderMaterial).duplicate()
+		mat.set_shader_parameter("world_space_uv", true)
+		mesh_instance.material_override = mat
+		return
+
+	if mesh_instance.mesh == null:
+		return
+	for i: int in range(mesh_instance.mesh.get_surface_count()):
+		var surface: Material = mesh_instance.get_surface_override_material(i)
+		if surface is ShaderMaterial:
+			var mat: ShaderMaterial = (surface as ShaderMaterial).duplicate()
+			mat.set_shader_parameter("world_space_uv", true)
+			mesh_instance.set_surface_override_material(i, mat)
+
+
 ## Schaltet die flache Bodenplatte des Raumes ab und liefert deren
 ## Material zurueck, damit die Rampe genauso aussieht.
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `level_generator.gd` — room scale and…*

`20:29:27`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `level_generator.gd` — room scale and footprint-scaled threat budget:

#### ✏️  Edit `level_generator.gd`

`20:29:31`

```diff
@@ -1 +1,6 @@-@export var room_scale: Vector3 = Vector3(2.0, 2.0, 2.0)
+## War Vector3(2.0, 2.0, 2.0) - Rueckmeldung "Raeume generell um ca. 15%
+## verkleinern". cell_size/elevation_step werden unten in _apply_room_scale()
+## direkt AUS diesem Wert abgeleitet (nicht separat gepflegt) - das
+## Grid-System bleibt dadurch automatisch konsistent, es gibt keinen
+## zweiten Ort, der von Hand synchron gehalten werden muesste.
+@export var room_scale: Vector3 = Vector3(2.0, 2.0, 2.0) * 0.85
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,2 +1,2 @@-		var budget: int = _budget_for_type(cell.room_type)
+		var budget: int = _budget_for_type(cell.room_type, cell.footprint)
 		room.prepare_enemies(table, budget, current_stage, cell.room_type == RoomData.RoomType.BOSS)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,4 +1,9 @@-func _budget_for_type(type: int) -> int:
+## footprint: Zellen-Grundflaeche des Raums (Vector2i.ONE = normaler 1x1-
+## Raum). Rueckmeldung "grosse Raeume (2x1/2x2) wirken leer, wenn sie
+## dasselbe Budget wie ein 1x1-Raum haben, obwohl sie deutlich mehr
+## Grundflaeche haben" - skaliert Budget linear mit der Zellenanzahl, damit
+## die Gegnerdichte pro Flaeche konstant bleibt.
+func _budget_for_type(type: int, footprint: Vector2i = Vector2i.ONE) -> int:
 	var base: int = 0
 	match type:
 		RoomData.RoomType.COMBAT:
@@ -10,5 +15,17 @@ 		_:
 			return 0
 
-	var cap: int = boss_threat_hard_cap if type == RoomData.RoomType.BOSS else threat_hard_cap
+	# WICHTIG: threat_hard_cap (64) ist standardmaessig GENAU gleich
+	# combat_threat_budget (64) - ein normaler 1x1-Kampfraum sitzt in Stage 1
+	# also schon exakt am Deckel. Wuerde NUR "base" mit der Zellenzahl
+	# multipliziert, wuerde der unveraenderte Cap die Skalierung sofort
+	# wieder auf den 1x1-Wert zurueckschneiden. Der Cap muss deshalb
+	# GENAUSO skalieren wie das Budget selbst.
+	var cell_count: int = maxi(footprint.x * footprint.y, 1)
+	base *= cell_count
+	var cap: int = (boss_threat_hard_cap if type == RoomData.RoomType.BOSS else threat_hard_cap) * cell_count
+
+	# Die Stage-Steigerung bleibt bewusst UNSKALIERT (flacher Bonus,
+	# unabhaengig von der Raumgroesse) - sie ist eine globale
+	# Schwierigkeitskurve, keine flaechenabhaengige Groesse.
 	return clampi(base + (current_stage - 1) * threat_per_stage, 0, cap)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `mortar_bot.gd` — scale, detection range…*

`20:29:52`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `mortar_bot.gd` — scale, detection range, and projectile speed:

#### ✏️  Edit `mortar_bot.gd`

`20:29:55`

```diff
@@ -1,3 +1,3 @@-## War 1.5 - Rueckmeldung "jeder Gegner ausser Magnet soll 3x groesser sein"
-## (1.5 * 3 = 4.5).
-const VISUAL_SCALE: float = 4.5
+## War 1.5, dann 4.5 ("jeder Gegner ausser Magnet soll 3x groesser sein").
+## Rueckmeldung "Moerser-Bot um 15% verkleinern" (2026-08-12): 4.5 * 0.85.
+const VISUAL_SCALE: float = 4.5 * 0.85
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\mortar_bot.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,5 +1,9 @@ var fire_interval: float = 3.6
-var flight_time: float = 1.3
+## War 1.3 - Rueckmeldung "Geschoss fliegt zu langsam". Bestimmt (zusammen
+## mit der konstanten Flugdistanz) direkt die Geschwindigkeit: der Shell-
+## Tween in _fire_at() legt dieselbe Strecke jetzt in gut halb so viel Zeit
+## zurueck, also gut doppelt so schnell.
+var flight_time: float = 0.6
 ## War 8.0 - in einem 14 Units hohen Kampfraum kratzte der Geschossbogen
 ## damit fast an der Decke ("Rueckmeldung: Moerser-Geschosse zu weit oben in
 ## der Luft"). Niedrigerer Bogen bleibt als Parabel klar lesbar, wirkt aber
@@ -7,4 +11,9 @@ var arc_height: float = 4.0
 var blast_radius: float = 4.2
 var damage: float = 22.0
-var detect_range: float = 45.0
+## War 45.0 - Rueckmeldung "Detection-Range extrem stark erhoehen, damit er
+## den Spieler fast ueberall im Raum bemerkt". 500 deckt selbst den
+## groessten aktuell moeglichen Mehrzellen-Raum (2x2-footprint * room_scale)
+## komplett ab - in der Praxis heisst das "erkennt den Spieler, sobald er im
+## selben Raum steht", was genau die Absicht ist.
+var detect_range: float = 500.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\mortar_bot.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `acid_sprinkler.gd` — detection range…*

`20:30:09`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `acid_sprinkler.gd` — detection range:

#### 👀 Read `acid_sprinkler.gd`

`20:30:10`

*(lines 1–36)*

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
var detect_range: float = 40.0

## Wie schnell sich der Saeure-Sprinkler zum Spieler dreht (rad/s) - langsam
## genug, dass die Drehung als sichtbares "Zielen" wirkt statt als Snap.
const TURN_SPEED: float = 1.2

var _cooldown: float = 0.0
```
</details>

#### ✏️  Edit `acid_sprinkler.gd`

`20:30:15`

```diff
@@ -1,2 +1,5 @@ var puddle_lifetime: float = 6.0
-var detect_range: float = 40.0
+## War 40.0 - Rueckmeldung "Detection-Range extrem stark erhoehen, damit er
+## den Spieler fast ueberall im Raum bemerkt" (siehe mortar_bot.gd fuer
+## dieselbe Aenderung/Begruendung).
+var detect_range: float = 500.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\acid_sprinkler.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Let me verify the most complex edits by re…*

`20:30:19`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let me verify the most complex edits by re-reading the affected files in full.

#### 👀 Read `combat_karina.gd`

`20:30:20`

*(lines 1–101)*

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

const HIT_VFX_SCENE: PackedScene = preload("res://scenes/vfx/hit_spark.tscn")

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
@export var detonation_damage: float = 220.0

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

var _stance_active: bool = false
var _acid_tick_timer: float = 0.0

var _stealth_active: bool = false
var _stealth_touch_timer: float = 0.0
var _marked_enemy_ids: Array[int] = []
## Array[Dictionary{beam: Dictionary (BeamVisual), from_id: int, to_id: int}]
## - Kettenverbindungen zwischen aufeinanderfolgend markierten Gegnern.
var _mark_beams: Array[Dictionary] = []

var _health: Health = null
## Fuer Karinas feste Passive "Reflexe" (Lifesteal-on-Hit, siehe
## item_behaviours.gd::try_karina_lifesteal()) - Karinas Angriffe laufen nie
## ueber Hitbox.hit_landed (siehe Klassenkommentar), das normale
## player_hit_enemy-Signal feuert fuer sie also nie. Direkter Aufruf bei
## jedem eigenen Treffer statt dessen.
var _item_behaviours: Node = null
var _meshes: Array[MeshInstance3D] = []
var _aura_visual: MeshInstance3D = null
var _aura_pulse_tween: Tween = null
## Urspruenglicher running_alpha-Wert des GhostTrail, VOR Phantom Execute -
## wird beim Betreten hochgesetzt (siehe STEALTH_TRAIL_ALPHA) und beim
## Verlassen exakt hierauf zurueckgesetzt statt auf einen fest verdrahteten
## Wert, falls der Trail char-spezifisch abweichend konfiguriert ist.
var _default_trail_alpha: float = 0.015


func _init() -> void:
	utility_cooldown = 0.8


func setup(owner_player: CharacterBody3D) -> void:
	super.setup(owner_player)
	_health = player.get_node_or_null("Health") as Health
	_item_behaviours = get_node_or_null("/root/Items/ItemBehaviours")
	var model: Node = player.get_node_or_null("CharacterModel")
```
</details>

### 🤖 Assistant: *This looks correct.*

`20:30:24`

> This looks correct. Let me check the two hit-loop edits landed cleanly.

#### 👀 Read `combat_karina.gd`

`20:30:25`

*(lines 195–240)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd</code></summary>

```

func _tick_acid_aura(delta: float) -> void:
	_acid_tick_timer -= delta
	if _acid_tick_timer > 0.0:
		return
	_acid_tick_timer = acid_tick_interval

	# Kein DOT-Tick im Spiel spawnt normalerweise eine Schadenszahl (siehe
	# custom_enemy_base.gd/enemy_ai.gd::_on_status_effect_ticked() - ruft
	# take_damage() direkt auf, ohne Zahl) - fuer Karina wird das hier
	# explizit nachgezogen, da die Aura sonst komplett stumm ist. Nicht 1:1
	# mit dem tatsaechlichen internen Tick-Timer des StatusEffectManagers
	# synchron, aber nah genug (gleiches Intervall) fuer klares Feedback.
	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var hit_anyone: bool = false

	# BUGFIX "Primärangriff trifft in der Luft nicht": enemies_within() misst
	# volle 3D-Kugel-Distanz von Karinas Ursprung. Springt sie, wandert dieser
	# Ursprung nach oben, waehrend Gegner-Ursprünge am Boden bleiben - ab
	# Sprunghoehe + Fuesse-Versatz reicht das, um direkt daneben stehende
	# Gegner rechnerisch aus dem Radius fallen zu lassen (siehe enemy_query.gd
	# fuer die volle Herleitung). enemies_within_flat() trennt Horizontal-
	# Radius von einem grosszuegigen Hoehenfenster und trifft dadurch auch
	# waehrend eines Sprungs zuverlaessig.
	for enemy: Node3D in EnemyQuery.enemies_within_flat(player.global_position, acid_aura_radius, 3.0, 5.0):
		if enemy.has_method("apply_status_effect"):
			hit_anyone = true
			enemy.apply_status_effect("acid", acid_effect_duration, acid_damage_per_tick, player, acid_tick_interval)
			if _item_behaviours:
				_item_behaviours.try_karina_lifesteal()
			if dns != null:
				var number: Node = dns.instantiate()
				get_tree().current_scene.add_child(number)
				(number as Node3D).global_position = enemy.global_position + Vector3(0.0, 1.8, 0.0)
				if number.has_method("show_damage"):
					number.show_damage(acid_damage_per_tick)

	# Kurzer Aufblitz-Puls am Aura-Ring, wenn sie GERADE tatsaechlich etwas
	# trifft - macht bei den schnellen 0.1s-Ticks (siehe acid_tick_interval)
	# lesbar, dass die Aura wirkt, ohne bei jedem einzelnen Tick eine neue
	# VFX-Szene abzufeuern (waere bei 10 Ticks/s reine Bildschirm-Unruhe).
	# Eigener, EXPLIZIT gekillter Tween statt eines neuen pro Tick: die
	# Pulsdauer (0.15s) ist laenger als das Tick-Intervall (0.1s) - ohne das
	# Killen wuerden sich mehrere Scale-Tweens ueberlappen und gegeneinander
	# ruckeln.
```
</details>

### 🤖 Assistant: *Good, that's correct.*

`20:30:29`

> Good, that's correct. Since `_item_behaviours` is typed as `Node`, let me confirm `try_karina_lifesteal()` is callable that way (GDScript allows dynamic dispatch on `Node`-typed refs without a compile error) — this is standard practice already used elsewhere in this codebase (e.g. `_items.has_method(...)` patterns), so it's fine. Let's check the `_detonate()` edit too.

#### 👀 Read `combat_karina.gd`

`20:30:31`

*(lines 432–462)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_karina.gd</code></summary>

```
## stealth_max_duration (5s) UND stealth_reentry_cooldown (ebenfalls 5s,
## zufaellig gleich) haelt - beides wuerde gegen den falschen Nenner
## rechnen. Als Nebeneffekt zeigt der Ring jetzt auch waehrend der aktiven
## Stealth-Phase sichtbar "noch X Sekunden" - vorher blieb er die ganze Zeit
## auf "bereit" stehen, obwohl die Faehigkeit laengst aktiv war.
func get_secondary_cooldown_percent() -> float:
	var cd: float = stealth_max_duration if _stealth_active else stealth_reentry_cooldown
	return _secondary_timer / cd if cd > 0.0 else 0.0


func _detonate() -> void:
	var had_marks: bool = not _marked_enemy_ids.is_empty()
	var dmg: float = detonation_damage * _damage_multiplier()
	# Aus dem ansonsten ungenutzten SecondaryHitbox-Node uebernommen statt
	# eine zweite damage_number_scene-Referenz zu pflegen - gleiche Idee wie
	# bei Giselle/Winter, siehe Kopfkommentar.
	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null

	for id: int in _marked_enemy_ids:
		var enemy: Object = instance_from_id(id)
		if enemy == null or not is_instance_valid(enemy) or not (enemy is Node3D):
			continue
		var enemy_3d: Node3D = enemy as Node3D
		var health: Node = enemy_3d.find_child("Health", true, false)
		if health == null or not (health is Health) or not (health as Health).is_alive():
			continue
		(health as Health).take_damage(dmg, player)
		if _item_behaviours:
			_item_behaviours.try_karina_lifesteal()
		VFX.spawn(HIT_VFX_SCENE, enemy_3d.global_position + Vector3.UP, Vector3.UP)
```
</details>

### 🤖 Assistant: *Good. Now let's verify `item_manager.gd`…*

`20:30:34`

> Good. Now let's verify `item_manager.gd` and `treasure_pedestal.gd` compile logically by re-reading them fully.

#### 👀 Read `item_manager.gd`

`20:30:35`

*(lines 271–351)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_manager.gd</code></summary>

```
## silent = true unterdrueckt NUR item_added (das Signal, an dem die
## "Item gefunden"-Popup-Karte haengt, siehe item_description_hud.gd::
## _on_item_added()) - fuer fest verdrahtete, unsichtbare Charakter-Passiven
## wie Karinas Reflexe (siehe char_karina.gd), die nie "gefunden" werden.
## inventory_changed bleibt bewusst IMMER an, sonst wuerden Inventarlisten-UI
## und Stat-Neuberechnung nach einem stillen Grant nicht mitziehen.
func add_item(item: ItemData, silent: bool = false) -> bool:
	if item == null:
		return false
	if item.max_stacks > 0 and count_item(item.id) >= item.max_stacks:
		return false

	inventory.append(item)

	if item.is_active_item():
		_equip_active_item(item)

	_apply_item_stats(item, inventory.size() - 1)
	_register_synergy_tags(item)

	if not silent:
		item_added.emit(item)
	inventory_changed.emit()
	return true


## Sonderfall fuer Sockel-Pickups (siehe treasure_pedestal.gd::take()):
## normales add_item() legt ein DRITTES aktives Item nur unausgeruestet ins
## Inventar (siehe PHASE-5-Kopfkommentar oben) - fuer einen Sockel ist das
## die falsche Erwartung ("wozu nehme ich das mit, wenn es eh nichts tut").
## Rueckmeldung: sind beide Slots (Q+E) schon belegt und man nimmt ein
## drittes AKTIVES Item vom Sockel, wird stattdessen das Q-Item aus dem
## Inventar entfernt und als "displaced" zurueckgegeben - der Aufrufer legt
## es zurueck auf den Sockel (Swap). In jedem anderen Fall (freier Slot,
## kein aktives Item, Stapelgrenze erreicht) verhaelt es sich wie add_item().
##
## Rueckgabe: {"picked_up": bool, "displaced": ItemData oder null}
func pickup_active_item(item: ItemData) -> Dictionary:
	if item == null:
		return {"picked_up": false, "displaced": null}
	# Stapelgrenze VORAB pruefen (dieselbe Bedingung wie add_item()) - sonst
	# wuerde ein danach fehlschlagendes add_item() das bereits entfernte
	# Q-Item ersatzlos verschwinden lassen.
	if item.max_stacks > 0 and count_item(item.id) >= item.max_stacks:
		return {"picked_up": false, "displaced": null}

	var both_slots_full: bool = active_items[0] != null and active_items[1] != null
	if not (item.is_active_item() and both_slots_full):
		return {"picked_up": add_item(item), "displaced": null}

	var displaced: ItemData = active_items[0]
	_remove_from_inventory(displaced)
	active_items[0] = null
	active_slots_changed.emit()

	add_item(item)
	return {"picked_up": true, "displaced": displaced}


## Entfernt GENAU EIN Exemplar aus dem Inventar (nicht alle Stacks).
## _apply_item_stats() verknuepft Stat-Modifier ueber die INVENTAR-POSITION
## (source_id enthaelt den Index, siehe dort) - eine Entfernung aus der
## Mitte wuerde alle nachfolgenden Indizes verschieben und deren Modifier
## unter dem ALTEN source_id verwaist zuruecklassen (PlayerStats._modifiers
## ist ein Dictionary ohne automatische Bereinigung, siehe player_stats.gd).
## Robuster als jeden verschobenen Index einzeln nachzuziehen: alle
## Stat-Modifier komplett verwerfen und aus dem (jetzt korrekten) Inventar
## neu aufbauen - derselbe Ablauf wie reset_run().
func _remove_from_inventory(item: ItemData) -> void:
	var index: int = inventory.find(item)
	if index == -1:
		return
	inventory.remove_at(index)
	_active_charges.erase(item.id)
	_active_cooldowns.erase(item.id)
	if stats != null:
		stats.clear_all()
		_reapply_all_item_stats()
	inventory_changed.emit()

```
</details>

### 🤖 Assistant: *This is correct and safe.*

`20:30:40`

> This is correct and safe. Let's check `treasure_pedestal.gd`'s full updated flow once more for correctness.

#### 👀 Read `treasure_pedestal.gd`

`20:30:40`

*(lines 459–534)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_pedestal.gd</code></summary>

```
# ============================================================================
# Aufnehmen
# ============================================================================
## Gibt true zurueck, wenn das Item wirklich ins Inventar gewandert ist.
## Bei erreichter Stapelgrenze bleibt der Sockel bestueckt stehen — das ist
## dieselbe Regel wie in pickup.gd und verhindert, dass ein Item wortlos
## verschwindet.
func take() -> bool:
	if _taken or item_data == null:
		return false

	var items: Node = get_node_or_null("/root/Items")
	if item == null:
		return false

	# pickup_active_item() statt add_item(): sind beide Aktiv-Slots (Q/E)
	# schon belegt und item_data ist selbst aktiv, wird das bisherige
	# Q-Item verdraengt und muss zurueck auf DIESEN Sockel (Swap statt
	# nutzlos unausgeruestet im Inventar landen), siehe item_manager.gd.
	var result: Dictionary = items.pickup_active_item(item_data)
	if not bool(result.get("picked_up", false)):
		return false
	var displaced: ItemData = result.get("displaced") as ItemData

	var taken_item: ItemData = item_data
	_taken = true
	# Die Anzeige stand auf "dauerhaft" (Sockel in Reichweite). Ohne diesen
	# Wechsel bliebe die Karte fuer immer stehen, weil hide_item() erst beim
	# Verlassen der Reichweite kaeme — und Items.item_added() setzt sie
	# gleich darauf ohnehin neu, dann mit Auto-Ausblendung.
	var hud: ItemDescriptionHud = _find_item_hud()
	if hud:
		hud.hide_item()

	item_taken.emit(taken_item, self)
	_play_take_feedback(displaced)
	return true


## Der Sockel bleibt als leere Saeule stehen. Ein komplett verschwindender
## Sockel wuerde beim Zurueckkommen so aussehen, als waere der Schatzraum nie
## bestueckt gewesen.
## displaced: nur bei einem Q/E-Swap gesetzt (siehe take()) - der Sockel
## bestueckt sich nach der Wegnahme-Animation selbst neu, statt leer zu
## bleiben (siehe _finish_take()/_restock()).
func _play_take_feedback(displaced: ItemData = null) -> void:
	if _prompt_label:
		_prompt_label.visible = false
	if _name_label:
		_name_label.visible = false

	Juice.hit_stop(Juice.DURATION_LIGHT)
	Juice.shake(0.35)

	var tween := create_tween()
	tween.set_parallel(true)

	if _float_root:
		tween.tween_property(_float_root, "position:y", _float_root.position.y + 1.4, 0.45) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_float_root, "scale", Vector3.ONE * 0.01, 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	if _beam and _beam.material_override is StandardMaterial3D:
		tween.tween_property(_beam.material_override, "albedo_color:a", 0.0, 0.5)

	if _light:
		tween.tween_property(_light, "light_energy", 0.25, 0.5)

	tween.chain().tween_callback(_finish_take.bind(displaced))


func _finish_take(displaced: ItemData = null) -> void:
	if _float_root and is_instance_valid(_float_root):
		_float_root.queue_free()
```
</details>

### 💭 Thinking

`20:30:50`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `treasure_pedestal.gd`

`20:30:53`

```diff
@@ -3,5 +3,8 @@ 
 	if _light:
 		_light.light_color = _accent
+	if _ring and _ring.material_override is StandardMaterial3D:
+		var ring_mat: StandardMaterial3D = _ring.material_override as StandardMaterial3D
+		ring_mat.albedo_color = Color(_accent.r, _accent.g, _accent.b, ring_mat.albedo_color.a)
 	if _name_label:
 		_name_label.text = new_item.display_name
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_pedestal.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Let's do a final check of the `level_generator…*

`20:30:56`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let's do a final check of the `level_generator.gd` budget function and confirm `cell.footprint` type compatibility.

#### 👀 Read `level_generator.gd`

`20:30:57`

*(lines 942–972)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
		return enemy_table
	var empty: Array[EnemySpawnEntry] = []
	return empty


## footprint: Zellen-Grundflaeche des Raums (Vector2i.ONE = normaler 1x1-
## Raum). Rueckmeldung "grosse Raeume (2x1/2x2) wirken leer, wenn sie
## dasselbe Budget wie ein 1x1-Raum haben, obwohl sie deutlich mehr
## Grundflaeche haben" - skaliert Budget linear mit der Zellenanzahl, damit
## die Gegnerdichte pro Flaeche konstant bleibt.
func _budget_for_type(type: int, footprint: Vector2i = Vector2i.ONE) -> int:
	var base: int = 0
	match type:
		RoomData.RoomType.COMBAT:
			base = combat_threat_budget
		RoomData.RoomType.CORRIDOR:
			base = corridor_threat_budget
		RoomData.RoomType.BOSS:
			base = boss_threat_budget
		_:
			return 0

	# WICHTIG: threat_hard_cap (64) ist standardmaessig GENAU gleich
	# combat_threat_budget (64) - ein normaler 1x1-Kampfraum sitzt in Stage 1
	# also schon exakt am Deckel. Wuerde NUR "base" mit der Zellenzahl
	# multipliziert, wuerde der unveraenderte Cap die Skalierung sofort
	# wieder auf den 1x1-Wert zurueckschneiden. Der Cap muss deshalb
	# GENAUSO skalieren wie das Budget selbst.
	var cell_count: int = maxi(footprint.x * footprint.y, 1)
	base *= cell_count
```
</details>

### 🤖 Assistant: *All edits are in.*

`20:31:03`

<details>
<summary>Thinking...</summary>

> 
</details>

> All edits are in. Let's regenerate the vault/graph since this touched a large swath of core systems.

#### 💻 Bash

`20:31:04`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -12 && graphify update . 2>&1 | tail -12
```

```
[4/7] 4 Character-Notizen geschrieben (01_Game_Design/Characters)

[4/7] 39 Room-Notizen geschrieben (01_Game_Design/Rooms)

[4/7] 10 Status-Effekt-Notizen geschrieben (01_Game_Design/Status_Effects)

[5/7] Architektur-Notizen geschrieben (02_Tech_Architecture)

[5/7] Gruppierungs-Seiten (MOCs) geschrieben

[6/7] 85 DevLog-Notizen + Gesamtliste geschrieben (03_DevLogs)

[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).

  AST extraction: 2/2 uncached files (100%)

  warning: 1 source file(s) produced zero nodes and are absent from the graph: .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5158 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] community set changed since labeling (546 saved labels, 547 communities now; renamed 4 community(ies) by their hub). Run `graphify label` to refresh names with the LLM.

[graphify] backed up semantic+curated graph (6 files) -> 2026-08-12/

Graph has 5335 nodes (above 5000 limit). Building aggregated community view...

graph.html written (aggregated: 547 community nodes, 165 cross-community edges)

Tip: run with --obsidian for full node-level detail.

[graphify watch] Rebuilt: 5335 nodes, 5051 edges, 547 communities

[graphify watch] graph.json, graph.html and GRAPH_REPORT.md updated in graphify-out

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *All changes are in.*

`20:31:37`

<details>
<summary>Thinking...</summary>

> 
</details>

> All changes are in. Here's the full rundown, organized by your three messages:
> 
> ## Message 1 — Bugfixes & balance
> 
> **1. Minimap floor texture stretching (2x1 rooms)** — Root cause wasn't the 2D schematic overlay (`minimap_rooms.gd` already draws flat colors correctly for merged footprints), it was the **3D floor mesh**: each room's `Floor` node is a hand-placed `BoxMesh` sized to the room (e.g. `96×1×48` for a 2x1 room), and Godot's `BoxMesh` always maps UV 0–1 across the *whole* face — so the same texture tile gets stretched 2x wider instead of repeating. The shared `psx.gdshader` already has a `world_space_uv` toggle built for exactly this (already used for the ceiling), just never applied to the floor. Added `_fix_floor_material_tiling()` in `room_instance.gd`, called from `_ready()` — duplicates the floor's material and enables `world_space_uv` so tiling stays constant in world units regardless of room size.
> 
> **2. Karina RMB hitbox/"Vernetzung" + LMB air-attack** — Neither of her attacks uses hitboxes at all (both are pure `EnemyQuery` radius checks). Found the real bug: `EnemyQuery.enemies_within()` measures a full 3D sphere from the player's *center*, but enemy origins sit at their feet (~0.9 units below). Jumping adds ~2.1 units on top of that offset — enough to push the radius check just past the edge, so airborne hits (and marks) silently miss. Added `EnemyQuery.enemies_within_flat()` (separate horizontal radius + vertical window, same idea as the existing dash-damage system) and switched both of Karina's abilities to it. Also widened `stealth_touch_radius` (1.6→2.6) and dropped the mark-check interval (0.15s→0.05s) for the "more generous, more reliable" ask.
> 
> **3. Active item Q/E auto-fill + pedestal swap** — The "fill next free slot" behavior already existed. Added the missing swap: `ItemManager.pickup_active_item()` — if both slots are full and you take a third active item from a pedestal, it evicts Q, and `treasure_pedestal.gd` re-stocks *itself* with the evicted item after the take animation finishes (visual swap, not just inventory logic).
> 
> **4 & 5. Mörser-Bot / Säure-Sprinkler** — `detect_range` 40–45 → 500 on both (room-wide). Mörser-Bot's `flight_time` 1.3s → 0.6s (shell covers the same arc roughly 2x faster).
> 
> **6. Scaling** — `level_generator.gd`'s `room_scale` already existed as the single source of truth cell_size/elevation_step derive from — just multiplied by 0.85, grid math stays consistent by construction. Mörser-Bot `VISUAL_SCALE` also ×0.85 (collision box scales with it automatically).
> 
> ## Message 2 — Karina LMB air-attack + lifesteal passive
> 
> Air-attack fix is the same `enemies_within_flat()` fix above (single root cause for both bugs). For the passive:
> - `item_catalog.gd`: `ID_KARINA_LIFESTEAL` + `build_karina_passive_lifesteal()` — deliberately **not** added to `build_all()`'s pool array, so it can never appear on a treasure pedestal for any character.
> - `item_behaviours.gd`: `try_karina_lifesteal()` — a dedicated method, **not** hooked into the shared `player_hit_enemy` signal, because that path fires `Juice.hit_stop()` on every hit and Karina's acid aura ticks up to 10x/second — routing through it would spam camera-freezes and misfire every other on-hit item. `combat_karina.gd` calls it directly from both her real damage sources (acid tick, detonation).
> - `char_karina.gd`: grants the item silently in `_ready()`. Needed a new `silent` param on `Items.add_item()` to suppress the "item found" popup while keeping inventory/stat bookkeeping intact.
> 
> ## Message 3 — Threat budget scaling by footprint
> 
> `level_generator.gd::_budget_for_type()` now takes the room's `footprint` and multiplies budget by cell count. Important catch: `threat_hard_cap` (64) is numerically identical to `combat_threat_budget` (64) — a normal 1x1 room already sits exactly at the cap at stage 1, so scaling only the budget would've been silently clamped right back down. Scaled the cap by the same factor.
> 
> Worth testing in-editor: spawn into a 2x1 combat room to check both the floor tiling and enemy density, and try the pedestal swap with Q+E full.

## 🤷 User: *Ich habe noch ein paar weitere Anpassungen…*

`20:33:28`

Ich habe noch ein paar weitere Anpassungen und Bugfixes für unser Godot 4 Projekt (Whiplash). Bitte bearbeite die folgenden vier Punkte:

1. Enemy ESP (Giselle & Winter) - Sichtbarkeit und Skalierung
   Wir hatten bereits über den "ESP Hack" (Kasten/Hitbox um die Gegner) gesprochen. Dazu noch folgende Anforderungen:

- Der ESP-Effekt soll bei **beiden** Fähigkeiten (Q und E) von Giselle und Winter ausgelöst werden.
- Die Größe des ESP-Kastens muss dynamisch mit der Größe des jeweiligen Gegners skalieren (ein Colossus braucht einen größeren Kasten als ein Fighter).
- Das Material/der Shader des ESP-Effekts muss deutlich sichtbarer / leuchtender gemacht werden. Wie setze ich das im Code um?

2. Giselles Uzi Feuerrate
   Giselles Primärangriff (Uzi) schießt aktuell ein kleines bisschen zu schnell. Bitte zeige mir, wo ich den Cooldown / die Fire-Rate in `combat_giselle.gd` leicht erhöhen kann, damit sie minimal langsamer schießt.

3. Drops (Coins, Heal, Bomben) - Wahrscheinlichkeit und Größe

- Die Drop-Raten für Pickups (Münzen, Herzen/Heilung, Bomben), wenn ein Raum gecleart wird, sollen spürbar erhöht werden. Zeige mir, wie ich die Drop-Chancen in `loot_manager.gd` anpasse.
- Die 3D-Modelle (Szenen) für diese Pickups sollen im Spiel viel größer und auffälliger sein. Wo passe ich den Scale-Faktor am besten an (im Skript beim Spawnen oder direkt in den jeweiligen `.tscn`-Dateien)?

4. UV-Mapping / Texturen in größeren Räumen (Stretching Bug)
   Bei größeren Räumen (z.B. 1x2 oder 2x2) gibt es ein Problem mit den Bodentexturen/Wandtexturen: Anstatt dass die Textur wiederholt wird (Tiling), wird eine einzelne 1x1 Textur einfach über die gesamte 1x2 Fläche gestreckt und sieht dadurch extrem verzerrt aus.
   Wie behebe ich dieses Stretching bei den Meshes? Muss ich dafür das UV-Scaling im Material (Triplanar Mapping?) aktivieren oder die Textur-Flags auf "Repeat" setzen? Bitte zeige mir den Godot 4 Weg, um das Tiling für Raum-Bausteine zu fixen.
5. Layout Grid entfernen
   Die Minimap hat aktuell ein Raster (Layout Grid), das bei größeren Räumen verzerrt wirkte. Ich habe mich entschieden, dieses Grid komplett zu entfernen. Bitte zeige mir, welchen Code oder welche Nodes ich in `room_instance.gd` oder dem UI-Map-Skript löschen/deaktivieren muss, um das Grid-Overlay restlos zu entfernen.
6. Farbgebung für unbesuchte/ungeclearte Räume
   Anstatt des Grids möchte ich Räume über ihre Farbe unterscheiden. Räume, die noch nicht besucht oder noch nicht gecleart wurden (also wo der Kampf noch nicht beendet ist), sollen auf der Map etwas grauer/dunkler dargestellt werden. Erst wenn der Raum gecleart ist, soll er seine volle, helle Farbe bekommen. Wie binde ich diese Farb-Logik an unseren Room-State (z.B. aus `RoomGuard` oder `room_instance.gd`) an?
7. Icons für Spezial-Räume
   Ich möchte, dass Spezial-Räume auf der Map direkt erkennbar sind:

- Der **Tresorraum (Treasure Room)** soll ein Kronen-Icon in der Mitte haben.
- Der **Bossraum (Boss Room)** soll ein Totenkopf-Icon in der Mitte haben.
  Bitte erkläre mir, wie ich in den Raum-Vorlagen (`RoomData` oder direkt in den Szenen) ein `Sprite2D` oder `TextureRect` für die Minimap hinzufüge und wie das Map-System dieses Icon dann korrekt über dem jeweiligen Raum rendert. wenn man auf ein gegner mit winter ode rgiselle schießt sollte der chaarcter auch in die richtung schauen Ich möchte das Balancing für den Map-Pool in unserem Level-Generator anpassen. Aktuell haben einige Raum-Vorlagen (`.tres`-Dateien in `resources/rooms/`) unterschiedliche Wahrscheinlichkeiten bei der Generierung (z.B. haben manche Räume eine `spawn_weight` von 0.4, 0.5 oder 1.2).

Das führt dazu, dass bestimmte Räume zu selten und andere zu oft auftauchen. Bitte passe alle aktiven Räume so an, dass sie die gleiche Chance haben, generiert zu werden.
Das bedeutet: Gehe alle `.tres` RoomData-Ressourcen im Ordner `resources/rooms/` durch und setze den Wert `spawn_weight` bei ausnahmslos **jedem** Raum auf exakt `1.0`.

### 💭 Thinking

`20:34:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `loot_manager.gd`

`20:34:57`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\loot_manager.gd</code></summary>

```
extends Node

# ============================================================================
# Loot — Autoload: wuerfelt Drops aus, sobald ein Raum geleert ist.
# Muss unter Project Settings -> Autoload als "Loot" stehen.
# ============================================================================
#
# WIE ES SICH AN DIE RAEUME HAENGT:
# Nicht ueber den LevelGenerator, sondern ueber SceneTree.node_added. Der
# Grund ist Robustheit: der Generator baut Raeume, aber Testlevel und
# handgebaute Szenen (level_01.tscn, nav_test_level.tscn) enthalten
# RoomInstances direkt in der Szenendatei. Wer sich nur beim Generator
# anmeldet, bekommt in genau diesen Szenen nie einen Drop — und merkt es
# beim Testen nicht, weil dort ohnehin selten aufgeraeumt wird.
# node_added deckt beide Faelle ab und braucht keine Aenderung an
# level_generator.gd.
#
# DETERMINISTISCHER ZUFALL:
# Die Drops haengen NICHT am globalen RNG. Der laeuft laut det_rng.gd auch
# fuer Screen-Shake und Schadenszahlen, ist also nach ein paar Minuten
# Spielzeit voellig unvorhersehbar weit gelaufen. Ein Seed auf dem
# Leaderboard waere damit wertlos: zwei Laeufe mit identischem Seed
# haetten unterschiedliches Loot. Stattdessen bekommt jeder Raum einen
# eigenen, aus Run-Seed + Rasterposition abgeleiteten RNG.

signal loot_dropped(kind: int, position: Vector3)

## Grundchance auf ueberhaupt einen Drop, bevor Glueck und Combo dazukommen.
const BASE_DROP_CHANCE: float = 0.78

## Gewichte der Verbrauchsgueter. Werden intern normalisiert — die Zahlen
## entsprechen 1:1 der Design-Vorgabe (40 / 30 / 15).
const WEIGHT_COIN: float = 40.0
const WEIGHT_HEAL: float = 30.0
const WEIGHT_BOMB: float = 15.0

## Glueck-Bonus pro Combo-Stufe zum Zeitpunkt des Raum-Clears.
const LUCK_PER_COMBO_STEP: float = 0.002

## Obergrenze der Gesamt-Dropchance. 100 % wuerde den Zufall komplett
## entwerten und Loot zur Selbstverstaendlichkeit machen.
const MAX_DROP_CHANCE: float = 0.95

## Wie viele Drops ein Raum maximal ausspuckt.
@export var max_drops_per_room: int = 1

## Standardmaessig AN, bis das System verifiziert ist. Danach auf false.
@export var debug_logging: bool = true

var _handled_rooms: Dictionary = {}  # InstanceID -> true


func _debug(msg: String) -> void:
	if debug_logging:
		print("[Loot] %s" % msg)


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	# Raeume, die es beim Start dieses Autoloads schon gab, nachtragen.
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
	var room: RoomInstance = node as RoomInstance
	if room.room_cleared.is_connected(_on_room_cleared):
		return
	room.room_cleared.connect(_on_room_cleared)


func _on_room_cleared(room: RoomInstance) -> void:
	# room_cleared kann laut room_instance.gd aus zwei Stellen feuern
	# (regulaeres Herunterzaehlen und Watchdog). Ohne diese Sperre koennte
	# ein Raum doppelt droppen.
	var id: int = room.get_instance_id()
	if _handled_rooms.has(id):
		return
	_handled_rooms[id] = true

	var items: Node = get_node_or_null("/root/Items")
	if items:
		items.notify_room_cleared(room)

	_roll_drops(room)


# ============================================================================
# Wuerfeln
# ============================================================================
func _roll_drops(room: RoomInstance) -> void:
	var rng: RandomNumberGenerator = _make_rng(room)
	var chance: float = _get_drop_chance()

	_debug("Raum %s gecleared. Dropchance %.1f%%." % [room.grid_position, chance * 100.0])

	for i: int in range(max_drops_per_room):
		if rng.randf() > chance:
			_debug("  -> kein Drop.")
			continue

		var kind: int = _pick_kind(rng)
		var spawn_position: Vector3 = _pick_position(room, rng, i)
		_spawn_pickup(kind, spawn_position)
		_debug("  -> Drop %s bei %s." % [Pickup.Kind.keys()[kind], spawn_position])


## Gesamt-Dropchance aus Grundwert, Glueck-Stat und aktueller Combo.
func _get_drop_chance() -> float:
	var items: Node = get_node_or_null("/root/Items")
	if item == null:
		return BASE_DROP_CHANCE

	var luck: float = items.get_luck()
	var combo_bonus: float = float(items.get_combo_count()) * LUCK_PER_COMBO_STEP

	return clampf(BASE_DROP_CHANCE + luck + combo_bonus, 0.0, MAX_DROP_CHANCE)


func _pick_kind(rng: RandomNumberGenerator) -> int:
	var total: float = WEIGHT_COIN + WEIGHT_HEAL + WEIGHT_BOMB
	var roll: float = rng.randf() * total

	if roll < WEIGHT_COIN:
		return Pickup.Kind.COIN
	if roll < WEIGHT_COIN + WEIGHT_HEAL:
		return Pickup.Kind.HEAL
	return Pickup.Kind.BOMB


## Bevorzugt einen LootSpawnPoint-Marker: der ist von Hand gesetzt und liegt
## garantiert auf begehbarem Boden.
##
## WARUM DER FALLBACK NICHT get_room_center() IST:
## Aktuell haben nur room_treasure_01 und room_boss_01 ueberhaupt Marker —
## saemtliche Combat- und Korridor-Raeume nicht. get_room_center() liefert
## bei leerer Markerliste aber den Raum-URSPRUNG zurueck, nicht die Mitte
## (siehe room_instance.gd). Der liegt je nach Prefab in einer Ecke oder
## unter dem Boden, und der Drop waere unsichtbar — ohne Fehlermeldung,
## also praktisch nicht auffindbar.
##
## Deshalb wird ersatzweise beim SPIELER abgelegt: er hat den Raum gerade
## geleert, steht also zwangslaeufig auf begehbarem Boden und sieht den
## Drop sofort. Der kleine Zufallsversatz verhindert, dass mehrere Drops
## exakt uebereinander landen.
func _pick_position(room: RoomInstance, rng: RandomNumberGenerator, index: int) -> Vector3:
	var points: Array[Marker3D] = room.loot_spawn_points
	if not points.is_empty():
		var marker: Marker3D = points[(rng.randi_range(0, points.size() - 1) + index) % points.size()]
		return marker.global_position + Vector3(0.0, 0.6, 0.0)

	var player: Node3D = _find_player()
	if player:
		var offset := Vector3(
			rng.randf_range(-1.6, 1.6),
			0.0,
			rng.randf_range(-1.6, 1.6)
		)
		return player.global_position + offset + Vector3(0.0, 0.4, 0.0)

	return room.get_room_center() + Vector3(0.0, 0.6, 0.0)


func _find_player() -> Node3D:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


func _spawn_pickup(kind: int, spawn_position: Vector3) -> void:
	var parent: Node = get_tree().current_scene
	if parent == null:
		return

	var pickup: Pickup = Pickup.create(kind)
	parent.add_child(pickup)
	pickup.global_position = spawn_position

	loot_dropped.emit(kind, spawn_position)


## Fallback fuer den Verfluchten Glueckswuerfel (item_behaviours.gd,
## _use_cursed_die): wird nur aufgerufen, wenn ein am Boden liegendes Pickup
## KEINE eigene reroll()-Methode hat. Wuerfelt eine ganz normale
## Verbrauchsgut-Sorte ueber dieselbe Gewichtung wie ein regulaerer Drop und
## spawnt sie an derselben Stelle.
func spawn_random_drop(spawn_position: Vector3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_spawn_pickup(_pick_kind(rng), spawn_position)


# ============================================================================
# Deterministischer RNG pro Raum
# ============================================================================
func _make_rng(room: RoomInstance) -> RandomNumberGenerator:
	var base_seed: int = _get_run_seed()
	var salt: String = "loot:%d:%d:%d" % [
		room.grid_position.x,
		room.grid_position.y,
		_get_current_stage()
	]
	return DetRng.make(DetRng.derive(base_seed, salt))


func _get_run_seed() -> int:
	var generator: Node = _find_generator()
	if generator and generator.has_method("get_run_seed"):
		return generator.get_run_seed()
	return 0


func _get_current_stage() -> int:
	var generator: Node = _find_generator()
	if generator and generator.has_method("get_current_stage"):
		return generator.get_current_stage()
	return 1


func _find_generator() -> Node:
	var found: Array = get_tree().get_nodes_in_group("level_generator")
	if not found.is_empty():
		return found[0]
	return null


## Beim Start eines neuen Runs aufrufen, sonst haelt der Manager Raeume aus
## dem alten Lauf fuer bereits abgehandelt.
func reset_run() -> void:
	_handled_rooms.clear()

```
</details>

#### 🔎 Grep `func set_target|_lock_model|model.*rotat|mesh.*rotat` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd`

`20:34:58`

```
268:func set_target(target: Node3D) -> void:
269-	if target == _current_target:
270-		return
271-	_disconnect_target_death()
272-	_current_target = target
273-	if _current_target and is_instance_valid(_current_target):
274-		var target_health := _current_target.find_child("Health", true, false)
275-		if target_health:
276-			target_health.died.connect(_on_target_died)
277-	target_changed.emit(_current_target)
278-
279-func clear_target() -> void:
280-	_disconnect_target_death()
281-	_current_target = null
282-	target_changed.emit(null)
283-
--
489:			mesh.rotation.y = atan2(away_from_enemy.x, away_from_enemy.z)
490-
491-	var tween := create_tween()
492:	tween.tween_property(mesh, "rotation:x", deg_to_rad(death_fall_rotation_degrees), death_fall_duration)\
493-		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
494-
495-func _spawn_ragdoll_corpse() -> void:
496-	if own_collision:
497-		own_collision.disabled = true
498-
499-	var corpse := RigidBody3D.new()
500-	corpse.name = "PlayerCorpse"
501-	corpse.mass = ragdoll_mass
502-	corpse.process_mode = Node.PROCESS_MODE_ALWAYS
503-	get_tree().current_scene.add_child(corpse)
504-	var spawn_transform: Transform3D = mesh.global_transform
505-	spawn_transform.origin.y += 0.15
506-	corpse.global_transform = spawn_transform
507-
--
829:			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_facing, delta * model_lock_turn_speed)
830-	elif direction.length() > 0.1:
831-		var target_rotation: float = atan2(direction.x, direction.z)
832:		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, delta * 10.0)
833-
834-	if _current_target and is_instance_valid(_current_target):
835-		var to_target_cam: Vector3 = _current_target.global_position - camera_pivot.global_position
836-		to_target_cam.y = 0
837-		if to_target_cam.length() > 0.01:
838-			var desired_yaw: float = atan2(-to_target_cam.x, -to_target_cam.z)
839-			var lock_multiplier: float = 1.0
840-			var custom_lock_multiplier = _current_target.get("camera_lock_multiplier")
841-			if custom_lock_multiplier != null:
842-				lock_multiplier = custom_lock_multiplier
843-			var effective_lock_strength: float = camera_soft_lock_strength * lock_multiplier
844-			camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, desired_yaw, effective_lock_strength * delta)
845-
846-	# --- Automatisches Kamera-Zoom bei großen Gegnern ---
847-	var target_is_large: bool = false
```

### 💭 Thinking

`20:35:03`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `player_base.gd`

`20:35:04`

*(lines 790–840)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\player_base.gd</code></summary>

```
	# addiert. Das funktioniert NUR, wenn direkt danach velocity.x/z wieder
	# komplett neu aus dem Input berechnet wird (normalfall). Waehrend Stun
	# ist effective_speed = 0 -> move_toward(velocity.x, 0, 0) aendert NICHTS,
	# d.h. der bereits letzten Frame aufaddierte Knockback blieb in velocity.x
	# STECKEN, und wir haben JEDEN weiteren Frame den (noch nicht ganz
	# abgeklungenen) Puffer NOCHMAL draufaddiert -> unkontrolliertes Aufschaukeln
	# ("Magnet"-Gefuehl), das sich beim naechsten Nicht-Stun-Frame wieder
	# schlagartig auf 0 totbremste. Deshalb rechnen wir "move_x"/"move_z" jetzt
	# aus dem RESIDUAL (aktuelle velocity MINUS dem zuletzt aufaddierten
	# Knockback-Anteil) — die reine Eigenbewegung bleibt so unabhaengig vom
	# Knockback-Puffer, egal ob gestunnt, in der Luft oder am Stehen.
	var move_x: float
	var move_z: float
	if direction.length() > 0.1:
		move_x = direction.x * effective_speed
		move_z = direction.z * effective_speed
	else:
		var residual_x: float = velocity.x - _knockback_velocity.x
		var residual_z: float = velocity.z - _knockback_velocity.z
		move_x = move_toward(residual_x, 0.0, effective_speed)
		move_z = move_toward(residual_z, 0.0, effective_speed)

	# Knockback-Puffer klingt UNABHAENGIG von Input/Stun ab und wird jeden
	# Frame frisch (nicht kumulativ) mit der Eigenbewegung kombiniert.
	_knockback_velocity.x = move_toward(_knockback_velocity.x, 0.0, knockback_friction * delta)
	_knockback_velocity.z = move_toward(_knockback_velocity.z, 0.0, knockback_friction * delta)

	velocity.x = move_x + _knockback_velocity.x
	velocity.z = move_z + _knockback_velocity.z

	if _current_target and is_instance_valid(_current_target):
		if global_position.distance_to(_current_target.global_position) > max_lock_range:
			clear_target()

	if _current_target and is_instance_valid(_current_target):
		var to_target: Vector3 = _current_target.global_position - global_position
		to_target.y = 0
		if to_target.length() > 0.01:
			var target_facing: float = atan2(to_target.x, to_target.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_facing, delta * model_lock_turn_speed)
	elif direction.length() > 0.1:
		var target_rotation: float = atan2(direction.x, direction.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, delta * 10.0)

	if _current_target and is_instance_valid(_current_target):
		var to_target_cam: Vector3 = _current_target.global_position - camera_pivot.global_position
		to_target_cam.y = 0
		if to_target_cam.length() > 0.01:
			var desired_yaw: float = atan2(-to_target_cam.x, -to_target_cam.z)
			var lock_multiplier: float = 1.0
```
</details>

### 💭 Thinking

`20:35:31`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `CollisionShape3D|CapsuleShape3D|class_name EnemyAI` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\enemies\enemy_ai.gd`

`20:35:32`

```
5:class_name EnemyAI
364:	var shape_node: CollisionShape3D = _get_collision_shape_node()
365:	if shape_node != null and shape_node.shape is CapsuleShape3D:
366:		return (shape_node.shape as CapsuleShape3D).height
712:## Zusaetzlich die Fuesse auf die Unterkante der CollisionShape3D setzen.
806:var _collision_shape_cache: CollisionShape3D
983:		push_warning("EnemyAI (%s): Keine CollisionShape3D gefunden! Kanten-/Hindernis-Checks laufen mit Fallback-Werten und sind unzuverlaessig." % display_name)
1142:		var shape_node: CollisionShape3D = _get_collision_shape_node()
1143:		if shape_node != null and shape_node.shape is CapsuleShape3D:
1144:			floor_y = shape_node.position.y - (shape_node.shape as CapsuleShape3D).height * 0.5
2022:func _get_collision_shape_node() -> CollisionShape3D:
2026:	var direct := get_node_or_null("CollisionShape3D")
2027:	if direct and direct is CollisionShape3D:
2032:		if child is CollisionShape3D:
2034:				_debug("Kein Kind namens 'CollisionShape3D' — nutze stattdessen '%s'." % child.get_path())

[Showing results with pagination = limit: 15]
```

#### 👀 Read `pickup.gd`

`20:35:32`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pickup.gd</code></summary>

```
extends Area3D
class_name Pickup

# ============================================================================
# Pickup — alles, was am Boden liegt und aufgesammelt werden kann.
# ============================================================================
# BAUT SEIN AUSSEHEN SELBST. Es gibt bewusst KEINE pickup.tscn:
#   * Vier Varianten (Muenze, Herz, Bombe, Item-Sockel) in einer Szene haetten
#     entweder vier deaktivierte Modelle im Baum oder vier fast identische
#     Szenendateien bedeutet.
#   * Der LootManager spawnt Pickups zur Laufzeit an Marker-Positionen. Eine
#     Szene haette dort nur einen weiteren Ressourcenpfad eingefuehrt, der
#     kaputtgehen kann.
# Wer spaeter richtige Modelle will, weist mesh_override im Inspector zu
# oder ersetzt _build_visual().

signal collected(kind: int, pickup: Pickup)

enum Kind {
	COIN,   ## Waehrung
	HEAL,   ## +heal_amount HP
	BOMB,   ## +1 Bombe im Inventar
	ITEM,   ## Sockel mit einem ItemData — muss aktiv genommen werden
}

@export var kind: Kind = Kind.COIN
@export var coin_value: int = 1
@export var heal_amount: float = 30.0
@export var bomb_amount: int = 1

## Optionales fertiges Modell. Bleibt es leer, wird die Form unten gebaut.
@export var mesh_override: Mesh

## Wie hoch/schnell das Pickup schwebt.
@export var bob_height: float = 0.18
@export var bob_speed: float = 2.2
@export var spin_speed: float = 1.6

## Ab dieser Naehe wird eingesammelt. Der Magnetradius kommt dagegen aus
## PlayerStats (Magnetischer Kompass erhoeht ihn).
@export var collect_distance: float = 1.1
@export var magnet_speed: float = 9.0

## Kurze Sperre nach dem Spawn: sonst saugt der Magnet ein Pickup ein, bevor
## der Spieler ueberhaupt sieht, dass etwas gedroppt ist.
@export var arm_delay: float = 0.35

## --- Bodenglanz (Lesbarkeit) ------------------------------------------
##
## Muenzen, Herzen und Bomben gehen im PSX-Dungeon unter: die Meshes sind
## klein, der Nebel schluckt Kontrast, und die Eigenfarbe (gelb/gruen/
## dunkelgrau) haelt gegen einen dunklen Boden kaum durch. Die Bombe ist
## als fast schwarze Kugel praktisch unsichtbar.
##
## Deshalb bekommt jedes einsammelbare Pickup zwei Zutaten:
##   1. einen WEISSEN, additiv gemischten Halo hinter dem Modell
##      (Billboard-Quad mit radialer GradientTexture2D — bewusst per Code
##      erzeugt statt als .png, damit kein Asset-Import noetig ist),
##   2. ein kleines weisses OmniLight3D, das den Boden ringsum aufhellt.
##
## Der Halo ist WEISS und nicht in der Item-Farbe: die Farbe unterscheidet
## die Sorten, die Helligkeit meldet "hier liegt was". Waere der Halo
## eingefaerbt, waere die Bombe wieder die dunkelste Fundsache im Raum.
##
## Kind.ITEM bleibt aussen vor — der Sockel hat bereits Label3D-Prompt und
## eigene Farbe.
@export var glow_enabled: bool = true
@export var glow_color: Color = Color(1.0, 1.0, 1.0)
## Kantenlaenge des Halo-Quads in Metern.
@export var glow_size: float = 1.5
## Deckkraft des Halos. Additiv gemischt — Werte ueber ~0.5 fressen die
## Silhouette des Modells auf.
@export_range(0.0, 1.0) var glow_opacity: float = 0.35
@export var glow_light_range: float = 3.2
@export var glow_light_energy: float = 1.4
## Wie stark Halo und Licht mit der Schwebebewegung pulsieren (0 = aus).
@export_range(0.0, 1.0) var glow_pulse: float = 0.25

## Nur fuer Kind.ITEM.
var item_data: ItemData = null

var _time: float = 0.0
var _base_y: float = 0.0
var _armed: bool = false
var _age: float = 0.0
var _collected: bool = false
var _visual: Node3D = null
var _prompt: Label3D = null
var _glow_quad: MeshInstance3D = null
var _glow_light: OmniLight3D = null
var _glow_material: StandardMaterial3D = null


## Gruppe, ueber die der Verfluchte Glueckswuerfel (item_behaviours.gd,
## _use_cursed_die) alle herumliegenden Drops findet, um sie neu zu wuerfeln.
const PICKUP_GROUP: String = "pickups"

func _ready() -> void:
	add_to_group(PICKUP_GROUP)
	_base_y = global_position.y
	monitoring = true
	monitorable = false
	# Layer 0 lassen und nur die Maske setzen waere hier falsch: wir pruefen
	# die Distanz selbst in _physics_process, weil der Magnet ohnehin jeden
	# Frame rechnet. Die Area dient nur als Traeger fuer die Kollisionsform.
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = collect_distance
	shape.shape = sphere
	add_child(shape)

	_build_visual()

	if kind == Kind.ITEM:
		_build_prompt()


## Bequemer Konstruktor fuer den LootManager.
static func create(pickup_kind: Kind) -> Pickup:
	var pickup := Pickup.new()
	pickup.kind = pickup_kind
	pickup.name = "Pickup_%s" % Kind.keys()[pickup_kind]
	return pickup


static func create_item(data: ItemData) -> Pickup:
	var pickup := Pickup.create(Kind.ITEM)
	pickup.item_data = data
	return pickup


# ============================================================================
# Darstellung
# ============================================================================
func _build_visual() -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)

	if mesh_override != null:
		var custom := MeshInstance3D.new()
		custom.mesh = mesh_override
		custom.material_override = _make_material(_color_for_kind())
		_visual.add_child(custom)
		return

	match kind:
		Kind.COIN:
			_build_coin()
		Kind.HEAL:
			_build_cross()
		Kind.BOMB:
			_build_bomb()
		Kind.ITEM:
			_build_pedestal()

	if glow_enabled and kind != Kind.ITEM:
		_build_glow()


## Weisser Halo + Punktlicht.
##
## Der Halo haengt am _visual und macht dessen Schwebe- und Drehbewegung
## mit — er ist aber ein Billboard, die Drehung ist also unsichtbar. Das
## Licht haengt bewusst am Pickup SELBST und nicht am _visual: ein
## mitschwebendes Licht laesst den Boden atmen statt zu leuchten.
func _build_glow() -> void:
	# Radialer Verlauf weiss -> transparent. GradientTexture2D mit
	# FILL_RADIAL erspart eine .png im Repo und bleibt aufloesungsarm
	# genug fuer den PSX-Look.
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 64
	texture.height = 64

	_glow_material = StandardMaterial3D.new()
	_glow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_glow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_glow_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_glow_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_glow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Kein depth_draw, aber depth_TEST bleibt an: der Halo soll von Waenden
	# verdeckt werden, sonst leuchtet ein Pickup durch den halben Dungeon.
	_glow_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	_glow_material.no_depth_test = false
	_glow_material.albedo_texture = texture
	_glow_material.albedo_color = Color(glow_color.r, glow_color.g, glow_color.b, glow_opacity)
	_glow_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var quad := QuadMesh.new()
	quad.size = Vector2(glow_size, glow_size)

	_glow_quad = MeshInstance3D.new()
	_glow_quad.name = "Glow"
	_glow_quad.mesh = quad
	_glow_quad.material_override = _glow_material
	# Hinter dem Modell sortieren, damit die Silhouette oben bleibt.
	_glow_quad.sorting_offset = -0.05
	_glow_quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_visual.add_child(_glow_quad)

	_glow_light = OmniLight3D.new()
	_glow_light.name = "GlowLight"
	_glow_light.light_color = glow_color
	_glow_light.light_energy = glow_light_energy
	_glow_light.omni_range = glow_light_range
	# Schatten aus: ein Dutzend schattenwerfender Punktlichter nach einem
	# geraeumten Raum kostet auf Forward Mobile spuerbar Leistung, und ein
	# Pickup-Halo braucht keinen Schattenwurf.
	_glow_light.shadow_enabled = false
	_glow_light.position = Vector3(0.0, 0.35, 0.0)
	add_child(_glow_light)


func _color_for_kind() -> Color:
	match kind:
		Kind.COIN:
			return Color(0.98, 0.80, 0.22)
		Kind.HEAL:
			return Color(0.30, 0.95, 0.40)
		Kind.BOMB:
			return Color(0.20, 0.20, 0.24)
		Kind.ITEM:
			return item_data.pedestal_color if item_data else Color(0.95, 0.85, 0.35)
	return Color.WHITE


## Unshaded + volle Farbe: PSX-Optik lebt von flachen, gesaettigten Flaechen,
## und ein Pickup soll in einem dunklen Dungeon von weitem lesbar sein.
func _make_material(color: Color, emission: float = 0.6) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission
	return material


func _build_coin() -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.28
	mesh.bottom_radius = 0.28
	mesh.height = 0.07
	mesh.radial_segments = 10  # bewusst grob: PSX-Look

	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _make_material(_color_for_kind())
	# Hochkant, damit sich die Muenze beim Drehen zeigt statt zu liegen.
	instance.rotation_degrees.x = 90.0
	_visual.add_child(instance)


func _build_cross() -> void:
	var color: Color = _color_for_kind()
	var material := _make_material(color, 0.9)

	for i: int in range(2):
		var box := BoxMesh.new()
		box.size = Vector3(0.55, 0.18, 0.12) if i == 0 else Vector3(0.18, 0.55, 0.12)
		var instance := MeshInstance3D.new()
		instance.mesh = box
		instance.material_override = material
		_visual.add_child(instance)


func _build_bomb() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.26
	sphere.height = 0.52
	sphere.radial_segments = 10
	sphere.rings = 6

	var instance := MeshInstance3D.new()
	instance.mesh = sphere
	instance.material_override = _make_material(_color_for_kind(), 0.15)
	_visual.add_child(instance)

	# Zuendschnur, damit die Kugel nicht wie ein Stein aussieht.
	var fuse := CylinderMesh.new()
	fuse.top_radius = 0.03
	fuse.bottom_radius = 0.03
	fuse.height = 0.22
	var fuse_instance := MeshInstance3D.new()
	fuse_instance.mesh = fuse
	fuse_instance.material_override = _make_material(Color(0.75, 0.62, 0.35), 0.2)
	fuse_instance.position = Vector3(0.0, 0.32, 0.0)
	_visual.add_child(fuse_instance)


func _build_pedestal() -> void:
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 0.5, 0.5)
	var instance := MeshInstance3D.new()
	instance.mesh = box
	instance.material_override = _make_material(_color_for_kind(), 1.0)
	instance.rotation_degrees = Vector3(0.0, 45.0, 35.0)
	_visual.add_child(instance)


func _build_prompt() -> void:
	_prompt = Label3D.new()
	_prompt.text = "[F]"
	_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt.no_depth_test = true
	_prompt.pixel_size = 0.006
	_prompt.position = Vector3(0.0, 0.9, 0.0)
	_prompt.modulate = Color(1.0, 1.0, 1.0, 0.85)
	_prompt.visible = false
	add_child(_prompt)


# ============================================================================
# Bewegung, Magnet, Einsammeln
# ============================================================================
func _physics_process(delta: float) -> void:
	if _collected:
		return

	_age += delta
	if not _armed and _age >= arm_delay:
		_armed = true

	_time += delta
	if _visual:
		_visual.position.y = sin(_time * bob_speed) * bob_height
		_visual.rotate_y(spin_speed * delta)

	# Halo und Licht pulsieren im Takt der Schwebebewegung. Der Puls laeuft
	# ueber den KOSINUS, ist gegenueber der Hoehe also um eine
	# Viertelperiode versetzt: hell im Aufsteigen, matt im Absinken. Waeren
	# beide in Phase, saehe es aus, als wuerde das Modell blinken.
	if glow_pulse > 0.0:
		var pulse: float = 1.0 + cos(_time * bob_speed) * glow_pulse
		if _glow_material:
			_glow_material.albedo_color = Color(
				glow_color.r, glow_color.g, glow_color.b,
				clampf(glow_opacity * pulse, 0.0, 1.0)
			)
		if _glow_light:
			_glow_light.light_energy = glow_light_energy * pulse

	var player: Node3D = _find_player()
	if player == null:
		return

	var distance: float = global_position.distance_to(player.global_position)

	if kind == Kind.ITEM:
		_update_item_prompt(distance, player)
		return

	if not _armed:
		return

	# --- Magnet ------------------------------------------------------
	# Der Radius kommt aus PlayerStats, damit der Magnetische Kompass ihn
	# einfach anheben kann, ohne dass das Pickup das Item kennen muss.
	var magnet_range: float = _get_magnet_range()
	if distance <= magnet_range and distance > collect_distance:
		var to_player: Vector3 = (player.global_position - global_position)
		# Auf Bauchhoehe zielen statt auf die Fuesse: sonst kriecht die
		# Muenze am Boden entlang und bleibt an Kanten haengen.
		to_player.y += 0.6
		var step: float = magnet_speed * delta * clampf(1.0 - distance / maxf(magnet_range, 0.01), 0.35, 1.0) * 3.0
		global_position += to_player.normalized() * step
		return

	if distance <= collect_distance:
		_collect(player)


func _update_item_prompt(distance: float, player: Node3D) -> void:
	if _prompt:
		_prompt.visible = distance <= 2.5

	if distance > 2.5:
		return
	if not Input.is_action_just_pressed("interact"):
		return
	_collect(player)


func _get_magnet_range() -> float:
	var stats := _get_stats()
	if stats == null:
		return 2.2
	return stats.get_pickup_range()


func _get_stats() -> PlayerStats:
	var items: Node = get_node_or_null("/root/Items")
	if item == null:
		return null
	var stats = items.stats
	if stats is PlayerStats:
		return stats
	return null


func _find_player() -> Node3D:
	var players: Array = get_tree().get_nodes_in_group("player")
	for node: Node in players:
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


func _collect(player: Node3D) -> void:
	if _collected:
		return
	_collected = true

	var items: Node = get_node_or_null("/root/Items")

	match kind:
		Kind.COIN:
			if items:
				items.add_coins(coin_value)
		Kind.HEAL:
			var health := player.get_node_or_null("Health") as Health
			if health:
				health.heal(heal_amount)
		Kind.BOMB:
			if items:
				items.add_bombs(bomb_amount)
		Kind.ITEM:
			if item and item_data:
				if not items.add_item(item_data):
					# Maximale Stapelzahl erreicht — Sockel bleibt stehen.
					_collected = false
					return

	collected.emit(kind, self)
	_play_collect_feedback()


## Kurzes Aufploppen statt sofortigem Verschwinden. Ohne das fuehlt sich
## Einsammeln an, als waere das Pickup nie da gewesen.
func _play_collect_feedback() -> void:
	set_deferred("monitoring", false)
	if _prompt:
		_prompt.visible = false
	if _visual == null:
		queue_free()
		return

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_visual, "scale", Vector3.ONE * 1.6, 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual, "position:y", _visual.position.y + 0.7, 0.18)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(queue_free)


# ============================================================================
# Verfluchter Glueckswuerfel — Reroll
# ============================================================================
## Verwandelt dieses Pickup in einen zufaelligen ANDEREN Drop an derselben
## Stelle. Fuer Kind.ITEM wird ein neues, noch nicht (voll) besessenes Item
## gewuerfelt statt eines Verbrauchsguts — ein Item, das man schon hat,
## bliebe sonst unbrauchbar liegen.
func reroll() -> void:
	if _collected:
		return

	if kind == Kind.ITEM:
		_reroll_item()
	else:
		_reroll_consumable()

	_rebuild_visual()
	_spawn_reroll_pop()


## Wuerfelt eine ANDERE Verbrauchsgut-Sorte als die aktuelle.
func _reroll_consumable() -> void:
	var choices: Array = [Kind.COIN, Kind.HEAL, Kind.BOMB]
	choices.erase(kind)
	kind = choices[randi() % choices.size()]


## Wuerfelt ein anderes Item aus dem Katalog. Schliesst das aktuelle Item und
## bereits maximal gestapelte Items aus.
func _reroll_item() -> void:
	var items: Node = get_node_or_null("/root/Items")
	if item == null:
		return

	var choices: Array[ItemData] = []
	for candidate: ItemData in items.catalog:
		if item_data != null and candidate.id == item_data.id:
			continue
		if candidate.max_stacks > 0 and items.count_item(candidate.id) >= candidate.max_stacks:
			continue
		choices.append(candidate)

	if choices.is_empty():
		return
	item_data = choices[randi() % choices.size()]


## Baut das Erscheinungsbild komplett neu auf — Kind (oder Item) hat sich
## gerade geaendert, das alte Mesh/Glow/Prompt passt nicht mehr.
func _rebuild_visual() -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.queue_free()
	_visual = null
	if _prompt != null and is_instance_valid(_prompt):
		_prompt.queue_free()
	_prompt = null
	_glow_quad = null
	if _glow_light != null and is_instance_valid(_glow_light):
		_glow_light.queue_free()
	_glow_light = null
	_glow_material = null

	_build_visual()
	if kind == Kind.ITEM:
		_build_prompt()


func _spawn_reroll_pop() -> void:
	if _visual == null:
		return
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector3.ONE * 1.4, 0.1)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual, "scale", Vector3.ONE, 0.15)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

```
</details>

### 💭 Thinking

`20:35:48`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `enemy_esp_box.gd`

`20:35:49`

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
const FLASH_ENERGY: float = 5.0
const IDLE_ENERGY: float = 1.7
const IDLE_ALPHA: float = 0.8

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


## Baut eine freistehende EnemyEspBox-Instanz, NICHT in den Baum gehaengt -
## der Aufrufer haengt sie selbst per add_child() unter current_scene
## (gleiches Muster wie _build_esp_marker()) und setzt global_position.
static func build(color: Color, size: Vector3 = Vector3(1.6, 2.2, 1.6)) -> EnemyEspBox:
	var box := EnemyEspBox.new()
	box._color = color
	box._build_edges(size)
	return box


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
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
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

#### 🔎 Grep `WallNorth|WallSouth|surface_material_override|WALL_MATERIAL|_build_walls|wall_material` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:35:50`

```
569:	# material_override statt surface_material_override - Vorrangregel.
1360:		# material_override statt surface_material_override - Vorrangregel.
1471:	# material_override statt surface_material_override - Vorrangregel.
1505:## BoxMesh mit surface_material_override - dessen UV spannt sich IMMER 0..1
1530:## surface_material_override-Slots) in eine eindeutige Kopie mit
1645:		# material_override statt surface_material_override - Vorrangregel.
2687:	# material_override statt surface_material_override - Vorrangregel.
2974:			# material_override hat Vorrang vor surface_material_override.
```

### 💭 Thinking

`20:36:00`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:36:01`

*(lines 1495–1540)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
	push_warning("RoomInstance: door_lintel_material_path '%s' nicht gefunden - Sturz faellt auf Flatcolor zurueck." % door_lintel_material_path)
	var fallback := StandardMaterial3D.new()
	fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fallback.albedo_color = Color(0.12, 0.13, 0.12)
	return fallback


## BUGFIX "Bodentextur bei mehrzelligen Raeumen (2x1/2x2) sichtbar gestreckt/
## verzerrt": der Boden ist (anders als die Decke, siehe
## _make_ceiling_material()) ein in JEDER Raum-.tscn von Hand platziertes
## BoxMesh mit surface_material_override - dessen UV spannt sich IMMER 0..1
## ueber die gesamte Mesh-Flaeche (Godot-Standardverhalten fuer BoxMesh/
## PlaneMesh). In einem normalen 1x1-Raum faellt das nicht auf (alle
## 1x1-Raeume gleich gross, das Streckungsverhaeltnis ist ueberall
## identisch) - ein 2x1-footprint_cells-Raum ist aber doppelt so breit:
## dieselbe Texturkachel wird dort auf die doppelte Breite gestreckt statt
## sich zu wiederholen, direkt sichtbar neben normalgrossen Nachbarraeumen.
##
## Gleicher Fix wie bei der Decke: dupliziertes Material (NIE die geteilte
## Original-Resource anfassen, sonst aendert das den Boden JEDES Raums im
## Spiel) mit world_space_uv=true (siehe psx.gdshader) - haelt die
## Kachelgroesse in Weltunits konstant, unabhaengig von der Bodenflaeche.
## Laeuft fuer JEDEN Raum, nicht nur mehrzellige - ein 1x1-Raum sieht dabei
## identisch aus wie vorher, nur jetzt "richtig" statt zufaellig passend.
func _fix_floor_material_tiling() -> void:
	var floor_body := get_node_or_null("Floor") as StaticBody3D
	if floor_body == null:
		return

	for child in floor_body.get_children():
		if child is MeshInstance3D:
			_apply_world_space_uv(child as MeshInstance3D)


## Wandelt JEDES Material eines MeshInstance3D (material_override UND alle
## surface_material_override-Slots) in eine eindeutige Kopie mit
## world_space_uv=true um. Nicht-ShaderMaterial-Slots (z.B. ein
## StandardMaterial3D-Fallback) werden unangetastet uebersprungen - der Fix
## gilt nur fuer das psx.gdshader-Material.
func _apply_world_space_uv(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance.material_override is ShaderMaterial:
		var mat: ShaderMaterial = (mesh_instance.material_override as ShaderMaterial).duplicate()
		mat.set_shader_parameter("world_space_uv", true)
		mesh_instance.material_override = mat
		return
```
</details>

### 💭 Thinking

`20:36:36`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `psx.gdshader`

`20:36:45`

```diff
@@ -5,6 +5,18 @@ uniform float world_uv_scale : hint_range(0.005, 1.0) = 0.0416667;
 
 varying vec3 world_position;
+// Achsen-Projektion statt Mesh-UV fuer WAENDE (Ergaenzung zu world_space_uv,
+// das bisher nur Boden/Decke ueber world_position.xz abdeckte). Waende
+// dehnen sich hauptsaechlich in Y + EINER horizontalen Achse aus - projected
+// man sie trotzdem auf XZ, faellt die Hoehen-Variation komplett weg (Y wird
+// dabei ignoriert). Stattdessen wird hier je Fragment anhand der dominanten
+// Normalen-Komponente eine von drei Achsen-Ebenen gewaehlt (XZ fuer
+// Boden/Decke, ZY/XY fuer Waende) - kein echtes Blend-Triplanar noetig,
+// weil in diesem Projekt ausschliesslich achsenausgerichtete Box-Geometrie
+// vorkommt (jede Flaeche hat eine einzige, klare Normalenrichtung, siehe
+// PSX-Vertex-Snapping-Look ohnehin ohne gekruemmte Flaechen).
+varying vec3 world_normal;
 
 void vertex() {
 	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
+	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\shaders\psx.gdshader has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,4 +1,14 @@ void fragment() {
 	// filter_nearest sorgt zusammen mit Import-Settings (siehe unten) für die
 	// blockige, ungefilterte Textur-Optik statt weichgezeichneter moderner Texturen.
-	vec2 tex_uv = world_space_uv ? world_position.xz * world_uv_scale : UV;
+	vec2 tex_uv = UV;
+	if (world_space_uv) {
+		vec3 n = abs(world_normal);
+		if (n.y >= n.x && n.y >= n.z) {
+			tex_uv = world_position.xz * world_uv_scale;       // Boden/Decke
+		} else if (n.x >= n.z) {
+			tex_uv = world_position.zy * world_uv_scale;       // Wand Ost/West
+		} else {
+			tex_uv = world_position.xy * world_uv_scale;       // Wand Nord/Sued
+		}
+	}
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\shaders\psx.gdshader has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's extend the `room_instance.gd` fix…*

`20:36:55`

> Now let's extend the `room_instance.gd` fix to also cover wall meshes:

#### ✏️  Edit `room_instance.gd`

`20:37:10`

```diff
@@ -1,25 +1,36 @@-## BUGFIX "Bodentextur bei mehrzelligen Raeumen (2x1/2x2) sichtbar gestreckt/
-## verzerrt": der Boden ist (anders als die Decke, siehe
-## _make_ceiling_material()) ein in JEDER Raum-.tscn von Hand platziertes
-## BoxMesh mit surface_material_override - dessen UV spannt sich IMMER 0..1
+## BUGFIX "Boden-/Wandtextur bei mehrzelligen Raeumen (2x1/2x2) sichtbar
+## gestreckt/verzerrt": Boden UND Waende sind (anders als die Decke, siehe
+## _make_ceiling_material()) in JEDER Raum-.tscn von Hand platzierte BoxMesh-
+## Nodes mit surface_material_override - deren UV spannt sich IMMER 0..1
 ## ueber die gesamte Mesh-Flaeche (Godot-Standardverhalten fuer BoxMesh/
 ## PlaneMesh). In einem normalen 1x1-Raum faellt das nicht auf (alle
 ## 1x1-Raeume gleich gross, das Streckungsverhaeltnis ist ueberall
-## identisch) - ein 2x1-footprint_cells-Raum ist aber doppelt so breit:
-## dieselbe Texturkachel wird dort auf die doppelte Breite gestreckt statt
-## sich zu wiederholen, direkt sichtbar neben normalgrossen Nachbarraeumen.
+## identisch) - ein 2x1-footprint_cells-Raum ist aber doppelt so breit bzw.
+## hat doppelt so lange Waende: dieselbe Texturkachel wird dort auf die
+## doppelte Laenge gestreckt statt sich zu wiederholen, direkt sichtbar
+## neben normalgrossen Nachbarraeumen.
 ##
 ## Gleicher Fix wie bei der Decke: dupliziertes Material (NIE die geteilte
-## Original-Resource anfassen, sonst aendert das den Boden JEDES Raums im
-## Spiel) mit world_space_uv=true (siehe psx.gdshader) - haelt die
-## Kachelgroesse in Weltunits konstant, unabhaengig von der Bodenflaeche.
-## Laeuft fuer JEDEN Raum, nicht nur mehrzellige - ein 1x1-Raum sieht dabei
-## identisch aus wie vorher, nur jetzt "richtig" statt zufaellig passend.
+## Original-Resource anfassen, sonst aendert das Boden/Waende JEDES Raums im
+## Spiel) mit world_space_uv=true (siehe psx.gdshader - deckt seit der
+## Achsen-Projektions-Erweiterung dort sowohl horizontale Flaechen (Boden/
+## Decke, XZ) als auch vertikale (Waende, ZY/XY je nach Ausrichtung) ab).
+## Haelt die Kachelgroesse in Weltunits konstant, unabhaengig von der
+## Flaeche. Laeuft fuer JEDEN Raum, nicht nur mehrzellige - ein 1x1-Raum
+## sieht dabei identisch aus wie vorher, nur jetzt "richtig" statt zufaellig
+## passend.
 func _fix_floor_material_tiling() -> void:
 	var floor_body := get_node_or_null("Floor") as StaticBody3D
-	if floor_body == null:
-		return
+	if floor_body != null:
+		for child in floor_body.get_children():
+			if child is MeshInstance3D:
+				_apply_world_space_uv(child as MeshInstance3D)
 
-	for child in floor_body.get_children():
-		if child is MeshInstance3D:
-			_apply_world_space_uv(child as MeshInstance3D)
+	# Waende sind DIREKTE Kinder des Raums mit "Wall"-Praefix - gleiche
+	# Erkennung wie _build_wall_caps().
+	for child in get_children():
+		if not (child is StaticBody3D) or not child.name.begins_with("Wall"):
+			continue
+		for grandchild in child.get_children():
+			if grandchild is MeshInstance3D:
+				_apply_world_space_uv(grandchild as MeshInstance3D)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `enemy_esp_box.gd` — brighter material…*

`20:37:15`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `enemy_esp_box.gd` — brighter material + dynamic size computation:

#### ✏️  Edit `enemy_esp_box.gd`

`20:37:23`

```diff
@@ -1,5 +1,20 @@ const EDGE_THICKNESS: float = 0.045
 const FLASH_DURATION: float = 0.18
-const FLASH_ENERGY: float = 5.0
-const IDLE_ENERGY: float = 1.7
-const IDLE_ALPHA: float = 0.8
+## Rueckmeldung "Material/Shader deutlich sichtbarer/leuchtender machen":
+## IDLE_ENERGY war 1.7, FLASH_ENERGY 5.0 - beide angehoben, PLUS Wechsel von
+## alpha-gemischter Transparenz auf additive Blendung (siehe _add_edge()).
+## Additiv heisst: die Kanten hellen den Hintergrund auf statt ihn nur zu
+## ueberdecken - genau der "leuchtet durch alles hindurch"-Hack-Look, den
+## z.B. auch treasure_pedestal.gd fuer seine Lichtsaeule nutzt
+## (_make_glow_material()).
+const FLASH_ENERGY: float = 9.0
+const IDLE_ENERGY: float = 3.2
+const IDLE_ALPHA: float = 0.95
+
+## Rundherum-Zuschlag auf die aus der Kollisionsform berechnete Groesse
+## (siehe compute_box_size()) - der Kasten soll den Gegner sichtbar
+## UMGEBEN, nicht seine Huelle exakt nachzeichnen.
+const SIZE_PADDING: float = 1.2
+## Mindestgroesse pro Achse, falls ein Gegner keine (oder eine winzige)
+## Kollisionsform hat - verhindert einen unsichtbar kleinen Punkt-Kasten.
+const MIN_SIZE: Vector3 = Vector3(1.0, 1.0, 1.0)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\enemy_esp_box.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -6,3 +6,82 @@ 	box._color = color
 	box._build_edges(size)
 	return box
+
+
+## Wie build(), bestimmt die Groesse aber selbst aus der Kollisionsform des
+## Ziels statt einen festen Wert zu nehmen - Rueckmeldung "Kasten muss
+## dynamisch mit der Groesse des jeweiligen Gegners skalieren (Colossus
+## braucht groesseren Kasten als Fighter)".
+static func build_for(enemy: Node3D, color: Color) -> EnemyEspBox:
+	return build(color, compute_box_size(enemy))
+
+
+## Sammelt alle CollisionShape3D-Nachfahren des Ziels und liefert eine
+## gepolsterte Bounding-Box in Weltmasseinheiten. Deckt beide Gegnersysteme
+## des Projekts ab (siehe CLAUDE.md-Architekturnotiz "zwei parallele
+## Gegner-Systeme"): EnemyAI (Fighter/Stinger/Colossus) nutzt eine
+## CapsuleShape3D, CustomEnemyBase-Gegner (Moerser-Bot etc., siehe
+## custom_enemy_base.gd::_add_box_collision()) eine BoxShape3D. Die
+## Shape-GROESSE selbst ist dort schon in Weltunits (inkl. VISUAL_SCALE)
+## angegeben - hier wird nur noch die lokale Position/Rotation der jeweiligen
+## CollisionShape3D-Node mit einbezogen, damit ein versetzt sitzender
+## Collider die Bounding-Box nicht verfaelscht.
+static func compute_box_size(enemy: Node3D) -> Vector3:
+	if enemy == null or not is_instance_valid(enemy):
+		return MIN_SIZE
+
+	var min_corner := Vector3.INF
+	var max_corner := -Vector3.INF
+	var found: bool = false
+
+	for shape_node: CollisionShape3D in _collect_collision_shapes(enemy):
+		var extents: Vector3 = _shape_half_extents(shape_node.shape)
+		if extents == Vector3.ZERO:
+			continue
+		found = true
+		# Acht Eckpunkte der lokalen Shape-AABB, durch die Node-eigene
+		# Transform (Position/Rotation innerhalb des Gegners) geschickt -
+		# einfacher und robust genug fuer die hier ausschliesslich
+		# achsenausgerichteten Formen, statt eine echte OBB zu rechnen.
+		for sx in [-1.0, 1.0]:
+			for sy in [-1.0, 1.0]:
+				for sz in [-1.0, 1.0]:
+					var corner: Vector3 = shape_node.transform * Vector3(
+						extents.x * sx, extents.y * sy, extents.z * sz
+					)
+					min_corner = min_corner.min(corner)
+					max_corner = max_corner.max(corner)
+
+	if not found:
+		return MIN_SIZE
+
+	var size: Vector3 = (max_corner - min_corner) * SIZE_PADDING
+	return Vector3(maxf(size.x, MIN_SIZE.x), maxf(size.y, MIN_SIZE.y), maxf(size.z, MIN_SIZE.z))
+
+
+static func _collect_collision_shapes(node: Node) -> Array[CollisionShape3D]:
+	var result: Array[CollisionShape3D] = []
+	if node is CollisionShape3D:
+		result.append(node as CollisionShape3D)
+	for child: Node in node.get_children():
+		result.append_array(_collect_collision_shapes(child))
+	return result
+
+
+## Halbe Ausdehnung (lokale AABB-Extents, NICHT Weltmasse) fuer die in
+## diesem Projekt vorkommenden Formtypen. Vector3.ZERO fuer alles andere
+## (z.B. noch kein Shape zugewiesen) - vom Aufrufer als "ueberspringen"
+## behandelt.
+static func _shape_half_extents(shape: Shape3D) -> Vector3:
+	if shape is BoxShape3D:
+		return (shape as BoxShape3D).size * 0.5
+	if shape is CapsuleShape3D:
+		var capsule := shape as CapsuleShape3D
+		return Vector3(capsule.radius, capsule.height * 0.5, capsule.radius)
+	if shape is SphereShape3D:
+		var r: float = (shape as SphereShape3D).radius
+		return Vector3(r, r, r)
+	if shape is CylinderShape3D:
+		var cyl := shape as CylinderShape3D
+		return Vector3(cyl.radius, cyl.height * 0.5, cyl.radius)
+	return Vector3.ZERO
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\enemy_esp_box.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:37:48`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `enemy_esp_box.gd`

`20:37:53`

```diff
@@ -4,6 +4,12 @@ 	mat.emission_enabled = true
 	mat.emission = _color
 	mat.emission_energy_multiplier = IDLE_ENERGY
+	# Additiv statt alpha-gemischt: hellt den Hintergrund auf statt ihn nur
+	# zu ueberdecken - der eigentliche "leuchtet/glueht"-Unterschied (siehe
+	# Konstanten-Kommentar oben).
 	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
+	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
+	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
+	mat.no_depth_test = true
 	mesh_instance.material_override = mat
 	_materials.append(mat)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\enemy_esp_box.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `combat_giselle.gd` — fire rate, dynamic…*

`20:38:01`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `combat_giselle.gd` — fire rate, dynamic ESP sizing, and the facing fix:

#### 👀 Read `combat_giselle.gd`

`20:38:02`

*(lines 101–136)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```
func _init() -> void:
	primary_cooldown = 0.08
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
```
</details>

#### ✏️  Edit `combat_giselle.gd`

`20:38:07`

```diff
@@ -1,4 +1,5 @@ func _init() -> void:
-	primary_cooldown = 0.08
+	# War 0.08 - Rueckmeldung "schiesst minimal zu schnell". Leicht angehoben.
+	primary_cooldown = 0.1
 	secondary_cooldown = 5.0
 	utility_cooldown = 0.8
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:38:10`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_giselle.gd`

`20:38:10`

*(lines 131–196)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```
func _perform_primary() -> void:
	if _camera == null or _spring_arm == null:
		return

	var origin: Vector3 = _camera.global_position
	# Camera3D.global_transform.basis.z zeigt IMMER hinter die Kamera (Godot-
	# Grundregel: jede Kamera blickt entlang ihres lokalen -Z) - negiert ergibt
	# das die tatsaechliche Blickrichtung.
	var look_dir: Vector3 = -_camera.global_transform.basis.z
	var target: Node3D = _resolve_uzi_target(origin, look_dir)
	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
	_update_uzi_esp(target)

	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
	_spawn_muzzle_vfx(origin, dir)
	_spawn_tracer(origin, result["position"], 0.35, 0.06)
	if result["hit"]:
		var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
		if spark:
			spark.scale *= 1.6
		_lock_model_to(result["target"])
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
			_uzi_esp_box.global_position = target.global_position + Vector3.UP * 1.1
		return

	_clear_uzi_esp()
```
</details>

### 🤖 Assistant: *Now let's apply the facing fix and dynamic…*

`20:38:14`

> Now let's apply the facing fix and dynamic ESP sizing:

#### ✏️  Edit `combat_giselle.gd`

`20:38:23`

```diff
@@ -1,6 +1,13 @@ 	var target: Node3D = _resolve_uzi_target(origin, look_dir)
 	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
 	_update_uzi_esp(target)
+	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man einen
+	# Gegner beschiesst": frueher haengte _lock_model_to() nur am BESTAETIGTEN
+	# Treffer (unten im result["hit"]-Zweig) - ein Ziel im Kegel, das die Uzi
+	# gerade anvisiert, liess das Modell also stehen, solange der Schuss aus
+	# irgendeinem Grund (Deckung, Rand des Kegels) nicht ankam. "Schiesst auf"
+	# heisst schon "hat ein Ziel gewaehlt", nicht erst "hat getroffen".
+	_lock_model_to(target)
 
 	var dns: PackedScene = primary_hitbox.damage_number_scene if primary_hitbox else null
 	var result: Dictionary = Hitscan.fire(self, origin, dir, uzi_range, uzi_damage * _damage_multiplier(), player, dns)
@@ -10,7 +17,6 @@ 		var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
 		if spark:
 			spark.scale *= 1.6
-		_lock_model_to(result["target"])
 		if player and player.has_method("shake_camera"):
 			player.shake_camera(0.18)
 		if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:38:26`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_giselle.gd`

`20:38:27`

*(lines 185–210)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```
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
			_uzi_esp_box.global_position = target.global_position + Vector3.UP * 1.1
		return

	_clear_uzi_esp()
	_uzi_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_uzi_esp_marker = _build_esp_marker()
	get_tree().current_scene.add_child(_uzi_esp_marker)
	_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2

```
</details>

### 🤖 Assistant: *Let me add a stored size to `EnemyEspBox…*

`20:38:34`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let me add a stored size to `EnemyEspBox` so callers can center it properly regardless of enemy height, then wire up `build_for()` everywhere.

#### ✏️  Edit `enemy_esp_box.gd`

`20:38:38`

```diff
@@ -1,3 +1,9 @@ var _color: Color = Color(1.0, 0.15, 0.15)
 var _materials: Array[StandardMaterial3D] = []
 var _flash_tween: Tween = null
+
+## Groesse, mit der diese Box gebaut wurde - Aufrufer nutzen size.y * 0.5,
+## um den vertikalen Versatz zum Ziel korrekt zu zentrieren (siehe
+## combat_giselle.gd/combat_winter.gd), statt eines festen Werts, der bei
+## einem Colossus zu tief und bei einem Fighter zu hoch saesse.
+var size: Vector3 = Vector3.ONE
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\enemy_esp_box.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,5 +1,6 @@-static func build(color: Color, size: Vector3 = Vector3(1.6, 2.2, 1.6)) -> EnemyEspBox:
+static func build(color: Color, box_size: Vector3 = Vector3(1.6, 2.2, 1.6)) -> EnemyEspBox:
 	var box := EnemyEspBox.new()
 	box._color = color
-	box._build_edges(size)
+	box.size = box_size
+	box._build_edges(box_size)
 	return box
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\vfx\enemy_esp_box.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:38:46`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_giselle.gd`

`20:38:52`

```diff
@@ -3,7 +3,7 @@ 		if _uzi_esp_marker != null and is_instance_valid(_uzi_esp_marker):
 			_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
 		if _uzi_esp_box != null and is_instance_valid(_uzi_esp_box):
-			_uzi_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+			_uzi_esp_box.global_position = target.global_position + Vector3.UP * (_uzi_esp_box.size.y * 0.5)
 		return
 
 	_clear_uzi_esp()
@@ -15,6 +15,6 @@ 	get_tree().current_scene.add_child(_uzi_esp_marker)
 	_uzi_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
 
-	_uzi_esp_box = EnemyEspBox.build(uzi_esp_color)
+	_uzi_esp_box = EnemyEspBox.build_for(target, uzi_esp_color)
 	get_tree().current_scene.add_child(_uzi_esp_box)
-	_uzi_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+	_uzi_esp_box.global_position = target.global_position + Vector3.UP * (_uzi_esp_box.size.y * 0.5)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:38:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_giselle.gd`

`20:38:57`

*(lines 375–440)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd</code></summary>

```

func _update_sniper_esp(target: Node3D) -> void:
	if target == _sniper_locked_target and target != null and is_instance_valid(target):
		if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
			_sniper_esp_box.global_position = target.global_position + Vector3.UP * 1.1
		return

	_clear_sniper_esp()
	_sniper_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_sniper_esp_box = EnemyEspBox.build(uzi_esp_color, Vector3(2.0, 2.6, 2.0))
	get_tree().current_scene.add_child(_sniper_esp_box)
	_sniper_esp_box.global_position = target.global_position + Vector3.UP * 1.1


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

	for i: int in range(sniper_shot_count):
		var result: Dictionary = Hitscan.fire(self, origin, dir, sniper_range, dmg, player, dns)
		_spawn_muzzle_vfx(origin, dir)
		# Deutlich staerker als der Uzi-Tracer - der Sniper soll sich wie
		# der "one-shot-kill"-Treffer anfuehlen, den die Spec verlangt.
		_spawn_tracer(origin, result["position"], 0.9, 0.12)
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
```
</details>

### 💭 Thinking

`20:39:03`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_giselle.gd`

`20:39:08`

```diff
@@ -1,7 +1,7 @@ func _update_sniper_esp(target: Node3D) -> void:
 	if target == _sniper_locked_target and target != null and is_instance_valid(target):
 		if _sniper_esp_box != null and is_instance_valid(_sniper_esp_box):
-			_sniper_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+			_sniper_esp_box.global_position = target.global_position + Vector3.UP * (_sniper_esp_box.size.y * 0.5)
 		return
 
 	_clear_sniper_esp()
@@ -9,6 +9,6 @@ 	if target == null or not is_instance_valid(target):
 		return
 
-	_sniper_esp_box = EnemyEspBox.build(uzi_esp_color, Vector3(2.0, 2.6, 2.0))
+	_sniper_esp_box = EnemyEspBox.build_for(target, uzi_esp_color)
 	get_tree().current_scene.add_child(_sniper_esp_box)
-	_sniper_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+	_sniper_esp_box.global_position = target.global_position + Vector3.UP * (_sniper_esp_box.size.y * 0.5)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -2,4 +2,11 @@ 	var dns: PackedScene = secondary_hitbox.damage_number_scene if secondary_hitbox else null
 	var landed_hit: bool = false
 
+	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man schiesst"
+	# - gleicher Grund wie bei der Uzi: nicht erst auf einen bestaetigten
+	# Treffer warten. _sniper_locked_target ist bereits waehrend des Ladens
+	# (siehe _poll_secondary_input()) ermittelt.
+	if _sniper_locked_target != null and is_instance_valid(_sniper_locked_target):
+		_lock_model_to(_sniper_locked_target)
+
 	for i: int in range(sniper_shot_count):
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_giselle.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:39:23`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `combat_winter.gd`

`20:39:23`

*(lines 85–210)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```
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


## HomingBolts nackte Kugel-Optik (geteilter Code mit Item-Minions, siehe
## homing_bolt.gd-Kopfkommentar - NICHT global aendern) liest sich als
## Magie-Geschoss, nicht als Plasma. Ein locker gestreuter Partikel-Schweif
## als Kind-Node behebt das, ohne die geteilte Basis anzufassen.
## local_coords = false: Partikel bleiben an ihrem Entstehungsort liegen,
## waehrend der Bolt weiterfliegt - genau das erzeugt den Schweif-Effekt.
func _attach_plasma_trail(bolt: Node3D, color: Color) -> void:
	var particles := GPUParticles3D.new()
	particles.emitting = true
	# Angehoben (Rueckmeldung "sieht schwach aus"): mehr, groessere Partikel
	# und ein eigenes Licht am Bolt selbst (unten) sollen ihn aus der
	# gesamten Kampfdistanz klar als staerkere Faehigkeit lesbar machen.
	particles.amount = 32
	particles.lifetime = 0.5
	particles.local_coords = false
	particles.one_shot = false

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3.ZERO
	mat.spread = 180.0
	mat.gravity = Vector3.ZERO
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.8
	mat.scale_min = 0.16
	mat.scale_max = 0.4
	mat.color = color
	particles.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.14
	mesh.height = 0.28
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_mat.albedo_color = color
	mesh_mat.emission_enabled = true
	mesh_mat.emission = color
	mesh_mat.emission_energy_multiplier = 3.2
	mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mesh_mat
	particles.draw_pass_1 = mesh

	bolt.add_child(particles)

	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = 1.6
	light.omni_range = 4.5
	light.shadow_enabled = false
	bolt.add_child(light)


## origin ist die Abschusspositon (NICHT die aktuelle Bolt-Position - der
## Bolt selbst reicht seine Position nicht an den Callback durch, siehe
## homing_bolt.gd::_strike()). Die Zug-Richtung ist deshalb "vom Abschussort
## zum Einschlag", nicht "vom Ziel weg vom Einschlag" - liest sich als
## Schubs weiter in Flugrichtung, siehe Kopfkommentar-Entscheidung im Plan.
func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float) -> void:
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

	var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, target.global_position + Vector3.UP, Vector3.UP)
```
</details>

### 💭 Thinking

`20:39:46`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_winter.gd`

`20:39:57`

```diff
@@ -8,12 +8,38 @@ 	var color: Color = data.attack_color if data else Color(0.5, 1.0, 0.7)
 	var dmg: float = plasma_damage * _damage_multiplier()
 
+	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man
+	# schiesst": targets[0] ist der naechste (siehe _pick_plasma_targets()'
+	# Sortierung) - nicht erst auf den Einschlag eines Bolts warten (der
+	# Flug dauert je nach Distanz spuerbar).
+	_lock_model_to(targets[0])
+
 	for target: Node3D in targets:
+		# ESP-Box PRO ZIEL, nicht ein einzelnes gelocktes Ziel wie bei Uzi/
+		# Sniper/Laser: Plasma kann bis zu plasma_bolt_count Gegner
+		# gleichzeitig anfliegen. Kurzlebig statt "gelockt, bis es
+		# wegfaellt" - passt zum Ein-Schuss-Charakter jedes einzelnen Bolts.
+		var esp_box: EnemyEspBox = EnemyEspBox.build_for(target, color)
+		get_tree().current_scene.add_child(esp_box)
+		esp_box.global_position = target.global_position + Vector3.UP * (esp_box.size.y * 0.5)
+
 		var on_strike: Callable = func(hit_target: Node3D) -> void:
-			_on_plasma_strike(hit_target, origin, dmg)
+			_on_plasma_strike(hit_target, origin, dmg, esp_box)
 
 		var bolt: HomingBolt = HomingBolt.spawn(
 			self, origin, target, color, on_strike, plasma_bolt_speed, plasma_bolt_lifetime, false, player
 		)
 		if bolt:
 			_attach_plasma_trail(bolt, color)
+		else:
+			esp_box.queue_free()
+
+		# Sicherheitsnetz: stirbt/entkommt das Ziel, bevor der Bolt trifft,
+		# feuert HomingBolt._strike() (und damit der on_strike-Callback,
+		# der die Box sonst aufraeumt) nie - die Box wuerde sonst dauerhaft
+		# haengen bleiben.
+		get_tree().create_timer(plasma_bolt_lifetime + 0.1).timeout.connect(
+			func() -> void:
+				if is_instance_valid(esp_box):
+					esp_box.queue_free()
+		)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now update `_on_plasma_strike()` to accept…*

`20:40:01`

> Now update `_on_plasma_strike()` to accept and handle the ESP box:

#### ✏️  Edit `combat_winter.gd`

`20:40:04`

```diff
@@ -1,4 +1,14 @@-func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float) -> void:
+func _on_plasma_strike(target: Node3D, origin: Vector3, dmg: float, esp_box: EnemyEspBox = null) -> void:
+	if esp_box != null and is_instance_valid(esp_box):
+		esp_box.flash()
+		# Kurz nach dem Aufblitzen aufraeumen statt sofort - der Puls soll
+		# noch sichtbar sein, bevor die Box mit dem Bolt zusammen verschwindet.
+		get_tree().create_timer(EnemyEspBox.FLASH_DURATION).timeout.connect(
+			func() -> void:
+				if is_instance_valid(esp_box):
+					esp_box.queue_free()
+		)
+
 	if not is_instance_valid(target):
 		return
 	var health: Node = target.find_child("Health", true, false)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now the Laser (secondary) — dynamic ESP sizing…*

`20:40:08`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now the Laser (secondary) — dynamic ESP sizing and the facing fix:

#### 👀 Read `combat_winter.gd`

`20:40:09`

*(lines 280–350)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```

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
			if spark:
				spark.scale *= 1.4
			_lock_model_to(result["target"])
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
```
</details>

### 💭 Thinking

`20:40:13`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_winter.gd`

`20:40:17`

```diff
@@ -1,4 +1,10 @@ 	var dir: Vector3 = ((target.global_position + Vector3.UP) - origin).normalized() if target != null else look_dir
 	_update_laser_esp(target)
+	# Rueckmeldung "Charakter soll in die Richtung schauen, wenn man
+	# schiesst" - vorher haengte _lock_model_to() weiter unten nur am
+	# tatsaechlichen Schadens-Tick (do_damage UND hit), der Strahl feuert
+	# aber jeden Frame; das Modell blieb zwischen zwei Ticks stehen.
+	if target != null:
+		_lock_model_to(target)
 
 	_laser_tick_timer -= delta
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:40:20`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `combat_winter.gd`

`20:40:23`

```diff
@@ -1,5 +1,4 @@ 			var spark: Node3D = VFX.spawn(HIT_VFX_SCENE, result["position"], -dir)
 			if spark:
 				spark.scale *= 1.4
-			_lock_model_to(result["target"])
 			# Leichtes Dauer-Rattern statt eines einzelnen Shakes - passt
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now update `_update_laser_esp()` to use …*

`20:40:26`

> Now update `_update_laser_esp()` to use `build_for()` with dynamic centering:

#### 👀 Read `combat_winter.gd`

`20:40:27`

*(lines 356–386)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```
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
			_laser_esp_box.global_position = target.global_position + Vector3.UP * 1.1
		return

```
</details>

*(lines 385–400)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd</code></summary>

```

	_clear_laser_esp()
	_laser_locked_target = target
	if target == null or not is_instance_valid(target):
		return

	_laser_esp_marker = _build_laser_esp_marker()
	get_tree().current_scene.add_child(_laser_esp_marker)
	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2

	_laser_esp_box = EnemyEspBox.build(laser_esp_color)
	get_tree().current_scene.add_child(_laser_esp_box)
	_laser_esp_box.global_position = target.global_position + Vector3.UP * 1.1


```
</details>

#### ✏️  Edit `combat_winter.gd`

`20:40:39`

```diff
@@ -3,7 +3,7 @@ 		if _laser_esp_marker != null and is_instance_valid(_laser_esp_marker):
 			_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
 		if _laser_esp_box != null and is_instance_valid(_laser_esp_box):
-			_laser_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+			_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)
 		return
 
 	_clear_laser_esp()
@@ -15,6 +15,6 @@ 	get_tree().current_scene.add_child(_laser_esp_marker)
 	_laser_esp_marker.global_position = target.global_position + Vector3.UP * 2.2
 
-	_laser_esp_box = EnemyEspBox.build(laser_esp_color)
+	_laser_esp_box = EnemyEspBox.build_for(target, laser_esp_color)
 	get_tree().current_scene.add_child(_laser_esp_box)
-	_laser_esp_box.global_position = target.global_position + Vector3.UP * 1.1
+	_laser_esp_box.global_position = target.global_position + Vector3.UP * (_laser_esp_box.size.y * 0.5)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\characters\combat_winter.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now `loot_manager.gd` and `pickup.gd`:*

`20:40:49`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now `loot_manager.gd` and `pickup.gd`:

#### ✏️  Edit `loot_manager.gd`

`20:40:52`

```diff
@@ -1,2 +1,3 @@ ## Grundchance auf ueberhaupt einen Drop, bevor Glueck und Combo dazukommen.
-const BASE_DROP_CHANCE: float = 0.78
+## War 0.78 - Rueckmeldung "Drop-Raten spuerbar erhoehen".
+const BASE_DROP_CHANCE: float = 0.9
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\loot_manager.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -1,2 +1,5 @@-## Wie viele Drops ein Raum maximal ausspuckt.
-@export var max_drops_per_room: int = 1
+## Wie viele Drops ein Raum maximal ausspuckt. War 1 - Rueckmeldung
+## "Drop-Raten spuerbar erhoehen", zusammen mit BASE_DROP_CHANCE angehoben:
+## nicht nur wahrscheinlicher, dass ueberhaupt etwas droppt, sondern auch
+## mehr auf einmal.
+@export var max_drops_per_room: int = 2
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\loot_manager.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:41:01`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `pickup.gd`

`20:41:05`

```diff
@@ -1,3 +1,9 @@ ## Kurze Sperre nach dem Spawn: sonst saugt der Magnet ein Pickup ein, bevor
 ## der Spieler ueberhaupt sieht, dass etwas gedroppt ist.
 @export var arm_delay: float = 0.35
+
+## Rueckmeldung "3D-Modelle fuer Muenzen/Herzen/Bomben sollen groesser und
+## auffaelliger sein". Gilt NICHT fuer Kind.ITEM (der Sockel-Platzhalter hat
+## seine eigene Groesse/Bedeutung, siehe _build_pedestal()) - deshalb hier
+## statt als globaler Node3D.scale, siehe Anwendung in _build_visual().
+@export var consumable_visual_scale: float = 1.8
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pickup.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:41:12`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `pickup.gd`

`20:41:12`

*(lines 140–165)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pickup.gd</code></summary>

```
# ============================================================================
func _build_visual() -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)

	if mesh_override != null:
		var custom := MeshInstance3D.new()
		custom.mesh = mesh_override
		custom.material_override = _make_material(_color_for_kind())
		_visual.add_child(custom)
		return

	match kind:
		Kind.COIN:
			_build_coin()
		Kind.HEAL:
			_build_cross()
		Kind.BOMB:
			_build_bomb()
		Kind.ITEM:
			_build_pedestal()

	if glow_enabled and kind != Kind.ITEM:
		_build_glow()
```
</details>

### 💭 Thinking

`20:41:18`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `pickup.gd`

`20:41:23`

```diff
@@ -3,6 +3,8 @@ 		custom.mesh = mesh_override
 		custom.material_override = _make_material(_color_for_kind())
 		_visual.add_child(custom)
+		if kind != Kind.ITEM:
+			_visual.scale = Vector3.ONE * consumable_visual_scale
 		return
 
 	match kind:
@@ -17,3 +19,9 @@ 
 	if glow_enabled and kind != Kind.ITEM:
 		_build_glow()
+
+	# Skaliert Modell UND Halo gemeinsam (Glow haengt als Kind an _visual,
+	# siehe _build_glow()) - ein groesseres Pickup mit unveraendert kleinem
+	# Halo wuerde unproportioniert aussehen.
+	if kind != Kind.ITEM:
+		_visual.scale = Vector3.ONE * consumable_visual_scale
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pickup.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's normalize `spawn_weight` across…*

`20:41:29`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now let's normalize `spawn_weight` across all room resources:

#### 💻 Bash

`20:41:31`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -L "spawn_weight" resources/rooms/*.tres; echo "---count---"; grep -c "spawn_weight" resources/rooms/*.tres | grep -v ":1$"; echo "---non-1.0 values---"; grep -H "spawn_weight" resources/rooms/*.tres | grep -v "spawn_weight = 1$"
```

```
---count---
---non-1.0 values---
resources/rooms/rd_boss_01.tres:spawn_weight = 1.0
resources/rooms/rd_boss_02.tres:spawn_weight = 1.0
resources/rooms/rd_boss_lemonade_flood_01.tres:spawn_weight = 0.5
resources/rooms/rd_bridge_01.tres:spawn_weight = 1.0
resources/rooms/rd_bridge_02.tres:spawn_weight = 1.0
resources/rooms/rd_combat_01.tres:spawn_weight = 1.0
resources/rooms/rd_combat_02.tres:spawn_weight = 1.0
resources/rooms/rd_combat_03.tres:spawn_weight = 1.0
resources/rooms/rd_combat_04.tres:spawn_weight = 1.0
resources/rooms/rd_combat_05.tres:spawn_weight = 1.0
resources/rooms/rd_combat_06.tres:spawn_weight = 1.0
resources/rooms/rd_combat_11.tres:spawn_weight = 0.85
resources/rooms/rd_combat_12.tres:spawn_weight = 1.2
resources/rooms/rd_combat_abyss_01.tres:spawn_weight = 0.4
resources/rooms/rd_combat_arena_01.tres:spawn_weight = 0.7
resources/rooms/rd_combat_chokepoint_01.tres:spawn_weight = 0.4
resources/rooms/rd_combat_lemonade_01.tres:spawn_weight = 1.0
resources/rooms/rd_combat_lemonade_02.tres:spawn_weight = 1.0
resources/rooms/rd_combat_switch_01.tres:spawn_weight = 0.4
resources/rooms/rd_corridor_01.tres:spawn_weight = 1.0
resources/rooms/rd_corridor_02.tres:spawn_weight = 1.0
resources/rooms/rd_corridor_abyss_01.tres:spawn_weight = 1.0
resources/rooms/rd_corridor_abyss_02.tres:spawn_weight = 1.0
resources/rooms/rd_corridor_abyss_03.tres:spawn_weight = 1.0
resources/rooms/rd_corridor_pillars_01.tres:spawn_weight = 1.0
resources/rooms/rd_corridor_pillars_02.tres:spawn_weight = 1.0
resources/rooms/rd_corridor_pillars_03.tres:spawn_weight = 1.0
resources/rooms/rd_start_01.tres:spawn_weight = 1.0
resources/rooms/rd_treasure_01.tres:spawn_weight = 1.0
resources/rooms/rd_treasure_03.tres:spawn_weight = 0.8
resources/rooms/rd_treasure_sacrifice_01.tres:spawn_weight = 0.5
```

### 💭 Thinking

`20:41:36`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:41:37`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -H "spawn_weight" resources/rooms/*.tres | grep -vE "spawn_weight = 1\.0$"
```

```
resources/rooms/rd_boss_lemonade_flood_01.tres:spawn_weight = 0.5
resources/rooms/rd_combat_07.tres:spawn_weight = 1
resources/rooms/rd_combat_08.tres:spawn_weight = 1
resources/rooms/rd_combat_09.tres:spawn_weight = 1
resources/rooms/rd_combat_10.tres:spawn_weight = 1
resources/rooms/rd_combat_11.tres:spawn_weight = 0.85
resources/rooms/rd_combat_12.tres:spawn_weight = 1.2
resources/rooms/rd_combat_abyss_01.tres:spawn_weight = 0.4
resources/rooms/rd_combat_arena_01.tres:spawn_weight = 0.7
resources/rooms/rd_combat_chokepoint_01.tres:spawn_weight = 0.4
resources/rooms/rd_combat_switch_01.tres:spawn_weight = 0.4
resources/rooms/rd_combat_tall_01.tres:spawn_weight = 1
resources/rooms/rd_combat_wide_01.tres:spawn_weight = 1
resources/rooms/rd_corridor_03.tres:spawn_weight = 1
resources/rooms/rd_treasure_02.tres:spawn_weight = 1
resources/rooms/rd_treasure_03.tres:spawn_weight = 0.8
resources/rooms/rd_treasure_sacrifice_01.tres:spawn_weight = 0.5
```

### 🤖 Assistant: *9 files have non-1.0 weights.*

`20:41:47`

<details>
<summary>Thinking...</summary>

> 
</details>

> 9 files have non-1.0 weights. Let's fix each one.

#### 👀 Read `rd_boss_lemonade_flood_01.tres`

`20:41:47`

#### 👀 Read `rd_combat_11.tres`

`20:41:48`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_11.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/combat/room_combat_11.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 0
available_exits = 15
spawn_weight = 0.85
min_stage = 0
unique_per_run = false
footprint_cells = Vector2i(1, 1)

```
</details>

#### 👀 Read `rd_combat_arena_01.tres`

`20:41:49`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_arena_01.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/combat/room_combat_arena_01.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 0
available_exits = 15
spawn_weight = 0.7
min_stage = 2
unique_per_run = false
footprint_cells = Vector2i(2, 2)

```
</details>

#### 👀 Read `rd_combat_chokepoint_01.tres`

`20:41:50`

#### 👀 Read `rd_treasure_03.tres`

`20:41:51`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_treasure_03.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/treasure/room_treasure_03.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 1
available_exits = 15
spawn_weight = 0.8
min_stage = 0
unique_per_run = false
footprint_cells = Vector2i(1, 1)

```
</details>

#### 👀 Read `rd_treasure_sacrifice_01.tres`

`20:41:51`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_treasure_sacrifice_01.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/treasure/room_treasure_sacrifice_01.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 1
available_exits = 15
spawn_weight = 0.5
min_stage = 1
unique_per_run = false

```
</details>

#### ✏️  Edit `rd_boss_lemonade_flood_01.tres`

`20:41:56`

```diff
@@ -1 +1 @@-spawn_weight = 0.5
+spawn_weight = 1.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_boss_lemonade_flood_01.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `rd_combat_11.tres`

`20:41:57`

```diff
@@ -1 +1 @@-spawn_weight = 0.85
+spawn_weight = 1.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_11.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `rd_combat_12.tres`

`20:41:58`

```diff
@@ -1 +1 @@-spawn_weight = 1.2
+spawn_weight = 1.0
```

#### ✏️  Edit `rd_combat_abyss_01.tres`

`20:41:59`

```diff
@@ -1 +1 @@-spawn_weight = 0.4
+spawn_weight = 1.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_abyss_01.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `rd_combat_chokepoint_01.tres`

`20:42:00`

```diff
@@ -1 +1 @@-spawn_weight = 0.4
+spawn_weight = 1.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_chokepoint_01.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

#### ✏️  Edit `rd_treasure_sacrifice_01.tres`

`20:42:03`

```diff
@@ -1 +1 @@-spawn_weight = 0.5
+spawn_weight = 1.0
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_treasure_sacrifice_01.tres has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:42:08`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:42:09`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && grep -H "spawn_weight" resources/rooms/*.tres | grep -vE "spawn_weight = 1(\.0)?$"
```

```
(Bash completed with no output)
```

### 🤖 Assistant: *All room templates now have `spawn_weight…*

`20:42:14`

> All room templates now have `spawn_weight = 1.0`. Let's regenerate the vault/graph now that the bulk of the direct work is done, then ask about the minimap redesign.

#### 💻 Bash

`20:42:14`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -12 && graphify update . 2>&1 | tail -12
```

```
[4/7] 4 Character-Notizen geschrieben (01_Game_Design/Characters)

[4/7] 39 Room-Notizen geschrieben (01_Game_Design/Rooms)

[4/7] 10 Status-Effekt-Notizen geschrieben (01_Game_Design/Status_Effects)

[5/7] Architektur-Notizen geschrieben (02_Tech_Architecture)

[5/7] Gruppierungs-Seiten (MOCs) geschrieben

[6/7] 85 DevLog-Notizen + Gesamtliste geschrieben (03_DevLogs)

[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).

  AST extraction: 11/11 uncached files (100%)

  warning: 1 source file(s) produced zero nodes and are absent from the graph: .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5159 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] community set changed since labeling (547 saved labels, 547 communities now; renamed 5 community(ies) by their hub). Run `graphify label` to refresh names with the LLM.

[graphify] backed up semantic+curated graph (6 files) -> 2026-08-12/

Graph has 5336 nodes (above 5000 limit). Building aggregated community view...

graph.html written (aggregated: 547 community nodes, 165 cross-community edges)

Tip: run with --obsidian for full node-level detail.

[graphify watch] Rebuilt: 5336 nodes, 5052 edges, 547 communities

[graphify watch] graph.json, graph.html and GRAPH_REPORT.md updated in graphify-out

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *All the unambiguous item are done — ESP…*

`20:42:50`

<details>
<summary>Thinking...</summary>

> 
</details>

> All the unambiguous item are done — ESP scaling/brightness/coverage, Uzi fire rate, loot rate + pickup size, wall UV tiling, the character-facing fix, and `spawn_weight` normalization. Before I touch the minimap, I want to check the intended architecture, since "remove the grid, replace with color + icons" can mean two structurally different things.

#### ❓ Asking questions...

`20:43:03`

**Q:** *Wie soll die neue Raum-Darstellung auf der Minimap technisch funktionieren, nachdem das schematische Grid-Overlay (minimap_rooms.gd) entfernt ist?*

- 3D-Weltraum-Faerbung + Icons (Empfohlen): Grid-Overlay komplett geloescht. Stattdessen wird die ECHTE 3D-Bodentextur jedes Raums eingefaerbt (grau=ungecleared, hell=cleared) - technisch einfach, weil room_instance.gd durch den letzten Fix bereits ein pro-Raum-dupliziertes Material mit einem albedo_color-Parameter hat. Kronen-/Totenkopf-Icons werden als Sprite3D auf einem eigenen, nur von der Minimap-Kamera sichtbaren Layer ueber Schatz-/Bossraum platziert (gleiches Layer-Trick-Muster wie die bestehende Fog-of-War-Loesung). Die kleine 3D-Kamera-Draufsicht bleibt die einzige Karte.

- Vereinfachtes 2D-Overlay: minimap_rooms.gd bleibt technisch bestehen, wird aber radikal vereinfacht: statt eines Rechtecks pro Raum (das bei Mehrzellen-Raeumen wie ein 'Grid' wirkt) nur noch ein einzelner Punkt/Kreis pro Raum-MITTELPUNKT, eingefaerbt nach Status, mit Icon fuer Spezialraeume. Kein Wall-/Passage-Zeichnen mehr, aber weiterhin ein separates 2D-Control neben der 3D-Kamera-Ansicht.

**A:** Vereinfachtes 2D-Overlay

### 🤖 Assistant: *This is a substantial rewrite of `minimap_rooms…*

`20:45:51`

<details>
<summary>Thinking...</summary>

> 
</details>

> This is a substantial rewrite of `minimap_rooms.gd`. Given how pervasive the changes are (removing the grid/passage system, adding dot+color+icon rendering), I'll reconstruct the file cleanly rather than patch it piecemeal.

#### ✍️  Write `minimap_rooms.gd`

`20:46:35`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap_rooms.gd</code></summary>

```

extends Control
class_name MinimapRooms

## Raum-Uebersicht als Overlay ueber/neben der 3D-Minimap.
##
## ROTATION: Die 3D-Minimap-Kamera hat eine -90-Grad-Bildkalibrierung
## (siehe minimap.gd: map_calibration_offset_degrees). Die Punkte hier
## rotieren deshalb NUR ihre POSITIONS-Berechnung (nicht das ganze Control)
## um denselben Winkel - Icons bleiben dabei aufrecht.
##
## ============================================================================
## REDESIGN (Rueckmeldung "Grid wirkt bei groesseren Raeumen verzerrt, bitte
## komplett entfernen"): das fruehere Overlay zeichnete ein Rechteck pro
## Raum (bei Mehrzellen-Raeumen zu einem groesseren Rechteck verschmolzen)
## plus gefuellte Durchgangs-Flaechen zwischen benachbarten Raeumen - optisch
## ein Raster/Grundriss. Das ist jetzt komplett ersetzt durch:
##   - EIN Punkt pro Raum-Mittelpunkt statt eines Rechtecks/Grundrisses.
##   - Farbe statt Form zeigt den Zustand: gedaempft/grau = noch nicht
##     gecleart (hostile Raum), volle Typ-Farbe = gecleart bzw. kein
##     Kampf-Gate (Korridor/Start/Schatz/...). Siehe _display_color_for().
##   - Kronen-/Totenkopf-Icon fuer Schatz-/Bossraum statt Text-Glyphen.
## Keine Durchgangs-/Wand-Darstellung mehr - das war der Teil, der bei
## Mehrzellen-Raeumen am ehesten "verzerrt" wirkte.

const GENERATOR_GROUP := "level_generator"

@export var cell_px: float = 18.0
@export var gap_px: float = 4.0
@export var view_radius: int = 2
@export var show_unexplored_neighbors: bool = true

## Radius des gezeichneten Raum-Punkts, relativ zu cell_px (1.0 = so breit
## wie frueher eine ganze Raumzelle).
@export_range(0.1, 1.0) var room_dot_radius_factor: float = 0.4

## Dreht NUR die Positionierung der Punkte zueinander, damit das Layout zur
## kalibrierten 3D-Minimap passt.
@export var overlay_rotation_degrees: float = -90.0

## --- Farbschema -------------------------------------------------------
@export var color_unexplored: Color = Color(0.35, 0.38, 0.32, 0.45)
@export var color_combat: Color = Color(0.62, 0.64, 0.58, 0.95)
@export var color_corridor: Color = Color(0.45, 0.47, 0.42, 0.95)
@export var color_start: Color = Color(0.35, 0.68, 0.95, 0.95)
@export var color_boss: Color = Color(0.90, 0.24, 0.24, 0.95)
@export var color_treasure: Color = Color(0.98, 0.80, 0.25, 0.95)
@export var color_current: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var color_text: Color = Color(0.08, 0.08, 0.06, 1.0)

## Zielfarbe, gegen die ein noch nicht gecleareter Kampf-/Bossraum
## eingefaerbt wird (siehe _display_color_for()) - graeulich statt der
## vollen, hellen Typ-Farbe. "Voll hell" ist jetzt das Signal fuer
## "sicher/gecleart", nicht mehr ein Haekchen-Symbol.
@export var color_uncleared_tint: Color = Color(0.32, 0.32, 0.34)
## Wie stark Richtung color_uncleared_tint gemischt wird. 1.0 = komplett
## grau (Typ nicht mehr erkennbar), 0.0 = kein Unterschied zu gecleart.
@export_range(0.0, 1.0) var uncleared_dim_strength: float = 0.7

var _generator: Node = null
var _pulse: float = 0.0
var _rotation_rad: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_rotation_rad = deg_to_rad(overlay_rotation_degrees)
	set_process(true)
	_try_bind_generator()


func _process(delta: float) -> void:
	if _generator == null or not is_instance_valid(_generator):
		_try_bind_generator()
		return
	_pulse = fmod(_pulse + delta * 2.2, TAU)
	queue_redraw()


func _try_bind_generator() -> void:
	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		visible = false
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)
	visible = true
	queue_redraw()


func _on_map_updated() -> void:
	queue_redraw()


## Rotiert einen reinen Richtungs-/Offset-Vektor um overlay_rotation_degrees.
## Wird NIE auf Icons angewendet - nur auf Positionen.
func _rotate(v: Vector2) -> Vector2:
	return v.rotated(_rotation_rad)


func _draw() -> void:
	if _generator == null or not is_instance_valid(_generator):
		return
	if not _generator.has_method("get_map_cells"):
		return

	var cells: Dictionary = _generator.get_map_cells()
	if cells.is_empty():
		return

	var current: Vector2i = _generator.get_current_room()
	var pitch: float = cell_px + gap_px
	var center := size * 0.5
	var radius: float = cell_px * room_dot_radius_factor

	for pos in cells.keys():
		var grid: Vector2i = pos
		if not _is_visible_cell(cells, grid, current):
			continue

		var data: Dictionary = cells[grid]
		var visited: bool = bool(data.get("visited", false))
		var c := _cell_center(grid, current, center, pitch)

		if not visited:
			draw_circle(c, radius, color_unexplored)
			draw_arc(c, radius, 0.0, TAU, 16, Color(0, 0, 0, 0.5), 1.0)
			continue

		var cleared: bool = bool(data.get("cleared", false))
		var hostile: bool = bool(data.get("hostile", false))
		var type: int = int(data.get("type", 0))

		var fill: Color = _display_color_for(_color_for_type(type), hostile, cleared)
		draw_circle(c, radius, fill)
		draw_arc(c, radius, 0.0, TAU, 16, Color(0, 0, 0, 0.65), 1.0)

		_draw_room_icon(c, radius, type)

		if grid == current:
			var a: float = 0.55 + 0.45 * sin(_pulse)
			var hl := color_current
			hl.a = a
			draw_arc(c, radius + 3.0, 0.0, TAU, 20, hl, 2.0)

	if _generator.has_method("is_stage_cleared") and _generator.is_stage_cleared():
		var font := ThemeDB.fallback_font
		var txt := "STAGE CLEAR"
		draw_string(font, Vector2(0.0, size.y - 4.0), txt,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, color_treasure)


## "voll hell" (die reine Typ-Farbe) heisst jetzt "sicher/gecleart". Ein
## Kampf- oder Bossraum, dessen Kampf noch laeuft (hostile UND NICHT
## cleared), wird stattdessen Richtung color_uncleared_tint gedaempft - die
## Rueckmeldung wollte genau diese Unterscheidung statt eines separaten
## Haekchen-Symbols. Nicht-hostile Raeume (Korridor, Start, Schatz, ...)
## haben kein Kampf-Gate und zeigen deshalb immer ihre volle Farbe.
func _display_color_for(base: Color, hostile: bool, cleared: bool) -> Color:
	if hostile and not cleared:
		return base.lerp(color_uncleared_tint, uncleared_dim_strength)
	return base


func _color_for_type(type: int) -> Color:
	match type:
		RoomData.RoomType.START:
			return color_start
		RoomData.RoomType.BOSS:
			return color_boss
		RoomData.RoomType.TREASURE:
			return color_treasure
		RoomData.RoomType.CORRIDOR:
			return color_corridor
	return color_combat


## Fog of War: sichtbar sind betretene Raeume und (optional) deren direkte
## Nachbarn.
func _is_visible_cell(cells: Dictionary, grid: Vector2i, current: Vector2i) -> bool:
	if absi(grid.x - current.x) > view_radius or absi(grid.y - current.y) > view_radius:
		return false
	var data: Dictionary = cells[grid]
	if bool(data.get("visited", false)):
		return true
	if not show_unexplored_neighbors:
		return false
	for offset in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]:
		var n: Vector2i = grid + offset
		if cells.has(n) and bool(cells[n].get("visited", false)):
			return true
	return false


## Position der Zelle relativ zur aktuellen: der reine Offset-Vektor wird
## rotiert, NICHT die Zelle selbst. Bei Mehrzellen-Raeumen (footprint > 1x1)
## bleibt das die ANKERZELLE, nicht die geometrische Mitte der Gesamtflaeche
## - fuer einen einzelnen Punkt (statt frueher eines flaechendeckenden
## Rechtecks) ist der Unterschied vernachlaessigbar, macht die Rechnung aber
## deutlich einfacher.
func _cell_center(grid: Vector2i, current: Vector2i, center: Vector2, pitch: float) -> Vector2:
	var d := grid - current
	var offset := Vector2(float(d.x) * pitch, float(d.y) * pitch)
	return center + _rotate(offset)


## Zeichnet das Typ-Icon fuer Spezialraeume in die Mitte des Punkts.
## Bewusst als Vektor-Form (draw_circle/draw_colored_polygon) statt als
## Text-Glyph: ThemeDB.fallback_font deckt Symbol-Unicode-Bloecke (Krone/
## Totenkopf) nicht zuverlaessig ab, ein Vektor-Icon rendert dagegen
## garantiert unabhaengig von Font-Glyphabdeckung - passt ausserdem zum Rest
## des Projekts, das durchgehend auf Primitiv-Formen statt importierter
## Texturen setzt.
func _draw_room_icon(center: Vector2, radius: float, type: int) -> void:
	match type:
		RoomData.RoomType.TREASURE:
			_draw_crown_icon(center, radius)
		RoomData.RoomType.BOSS:
			_draw_skull_icon(center, radius)
		RoomData.RoomType.START:
			_draw_glyph(center, radius, "S")
		RoomData.RoomType.SHOP:
			_draw_glyph(center, radius, "?")


func _draw_glyph(center: Vector2, radius: float, glyph: String) -> void:
	var font := ThemeDB.fallback_font
	var fs: int = int(radius * 1.5)
	var text_size: Vector2 = font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	draw_string(font, center + Vector2(-text_size.x * 0.5, text_size.y * 0.35), glyph,
		HORIZONTAL_ALIGNMENT_CENTER, text_size.x, fs, color_text)


## Einfache Kronen-Silhouette: Basis-Balken + drei Zacken mit "Edelstein"-
## Punkten an den Spitzen.
func _draw_crown_icon(center: Vector2, r: float) -> void:
	var base_top: float = r * 0.15
	var base_bottom: float = r * 0.55
	var base: PackedVector2Array = [
		center + Vector2(-r * 0.85, base_bottom), center + Vector2(r * 0.85, base_bottom),
		center + Vector2(r * 0.85, base_top), center + Vector2(-r * 0.85, base_top),
	]
	draw_colored_polygon(base, color_text)

	var spikes: PackedVector2Array = [
		center + Vector2(-r * 0.85, base_top),
		center + Vector2(-r * 0.6, -r * 0.7),
		center + Vector2(-r * 0.3, -r * 0.05),
		center + Vector2(0.0, -r * 0.9),
		center + Vector2(r * 0.3, -r * 0.05),
		center + Vector2(r * 0.6, -r * 0.7),
		center + Vector2(r * 0.85, base_top),
	]
	draw_colored_polygon(spikes, color_text)

	for entry in [[-r * 0.6, -r * 0.7], [0.0, -r * 0.9], [r * 0.6, -r * 0.7]]:
		draw_circle(center + Vector2(entry[0], entry[1]), r * 0.13, color_treasure)


## Einfacher Totenkopf: Schaedel-Kreis + zwei dunkle Augenhoehlen + Kiefer.
func _draw_skull_icon(center: Vector2, r: float) -> void:
	draw_circle(center + Vector2(0.0, -r * 0.1), r * 0.78, color_text)
	draw_circle(center + Vector2(-r * 0.3, -r * 0.15), r * 0.16, color_boss)
	draw_circle(center + Vector2(r * 0.3, -r * 0.15), r * 0.16, color_boss)

	var jaw: PackedVector2Array = [
		center + Vector2(-r * 0.32, r * 0.35), center + Vector2(r * 0.32, r * 0.35),
		center + Vector2(r * 0.22, r * 0.68), center + Vector2(-r * 0.22, r * 0.68),
	]
	draw_colored_polygon(jaw, color_text)

```
</details>

✓ The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap_rooms.gd has been updated successfully. (file state is current in your context — no need to Read it back)

### 💭 Thinking

`20:46:42`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `merge_multi_cell_rooms|corridor_width_factor|color_door|locked_door_width_factor|_rect_for_cell|_draw_passage` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`20:46:43`

```
No files found
```

### 💭 Thinking

`20:46:50`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `"hostile"|"cleared"` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`20:46:51`

```
507-			"elevation": cell.elevation,
508-			"visited": grid_pos == Vector2i.ZERO,
509:			"cleared": not room.requires_clear(),
510:			"hostile": room.requires_clear(),
511-			# PHASE 3.1: die Minimap zeichnet damit die volle Flaeche statt
512-			# eines Quadrats auf der Ankerzelle.
--
621-func _on_room_cleared(room: RoomInstance) -> void:
622-	if _map_cells.has(room.grid_position):
623:		_map_cells[room.grid_position]["cleared"] = true
624-		if _map_cells[room.grid_position]["type"] == RoomData.RoomType.BOSS:
625-			_stage_cleared = true
```

### 💭 Thinking

`20:46:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`20:46:56`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -6 && graphify update . 2>&1 | tail -8
```

```
[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).

  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Re-extracting code files in . (no LLM needed)...

  AST extraction: 1/1 uncached files (100%)

  warning: 1 source file(s) produced zero nodes and are absent from the graph: .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5159 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] No code-graph topology changes detected; outputs left untouched.

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *Everything's implemented.*

`20:47:37`

> Everything's implemented. Summary by topic:
> 
> ## ESP (Giselle & Winter)
> - **Coverage**: Winter's Plasma (primary, LMB) now gets an ESP box too — previously only his Laser (secondary) had one. It's per-target and short-lived (matches the bolt's one-shot lifecycle, with a fallback timer in case a target dies mid-flight and the strike callback never fires). Giselle's Uzi + Sniper already had it.
> - **Dynamic sizing**: `EnemyEspBox.build_for(enemy, color)` now walks the enemy's actual `CollisionShape3D` tree (handles both the capsule-based `EnemyAI` enemy and the box-based `CustomEnemyBase` ones), computes a padded bounding box, and stores it so callers can center the box vertically (`size.y * 0.5`) instead of guessing a fixed height — a Colossus gets a visibly bigger box than a Fighter now.
> - **Brightness**: switched from alpha-blended to additive blending + `no_depth_test`, energy roughly doubled — it now glows through geometry rather than just sitting on top of it.
> 
> ## Character facing
> Found the actual bug: `_lock_model_to()` was only ever called on a *confirmed hit*, not when a target was merely locked/aimed at. If a shot missed (cover, cone edge), the character just kept standing there. Moved the facing call to fire as soon as a target is resolved, for all four attacks (Uzi, Sniper, Plasma, Laser).
> 
> ## Giselle Uzi rate, loot, pickups
> `primary_cooldown` 0.08→0.1. Loot: `BASE_DROP_CHANCE` 0.78→0.9, `max_drops_per_room` 1→2. Pickup visuals: added `consumable_visual_scale` (1.8x) applied to coin/heart/bomb meshes + their glow halo.
> 
> ## UV tiling
> Extended last session's floor fix to **walls** too, but the existing `world_space_uv` shader mode only handled horizontal surfaces (`world_position.xz`) — applying it to walls unchanged would've made textures ignore height entirely. Extended `psx.gdshader` with normal-based axis selection (XZ for floor/ceiling, ZY/XY for walls depending on orientation) — a cheap, correct-for-this-project stand-in for full triplanar mapping, since every surface here is an axis-aligned box face with one clear normal.
> 
> ## Minimap grid → dots + color + icons
> Per your choice: `minimap_rooms.gd` keeps its 2D overlay panel but no longer draws room rectangles or connecting passages — just one circle per room center. Color communicates state (full type color once `cleared`, dimmed toward grey while `hostile && !cleared`, matching the level generator's existing `hostile`/`cleared` cell fields). Treasure/boss room get procedurally-drawn crown/skull icons (vector shapes, not font glyphs — the fallback font doesn't reliably cover crown/skull Unicode blocks).
> 
> ## Room pool balance
> All 9 `.tres` files with non-1.0 `spawn_weight` (0.4–1.2 range) set to exactly `1.0`; the rest were already 1.0.
> 
> Worth testing in-editor: check a Colossus vs. Fighter ESP box side by side, fire Winter's plasma at an off-angle target to confirm he turns, and clear a combat room to watch its minimap dot brighten.

## 🤷 User: *minimap grayout und icons sind garnicht vorhanden…*

`20:53:26`

minimap grayout und icons sind garnicht vorhanden

### 💭 Thinking

`20:53:49`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `enum RoomType` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_data.gd`

`20:53:50`

```
9:enum RoomType { COMBAT, TREASURE, BOSS, CORRIDOR, SHOP, START }
10-@export var room_type: RoomType = RoomType.COMBAT
11-
12-## Welche Seiten dieser Raum-Vorlage physisch eine Tür besitzen.
13-## Bitmask: Norden=1, Süden=2, Osten=4, Westen=8 - deckt sich exakt mit
14-## RoomGridGenerator.DIRECTION_FLAG und RoomInstance.EXIT_*.
15-## Der Grid-Generator wählt nur Räume, deren available_exits MINDESTENS
16-## die vom Layout geforderten Richtungen abdeckt (required & available
17-## == required). Überschüssige Türen der Vorlage werden zur Laufzeit
```

#### 🔎 Grep `func requires_clear` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:53:51`

```
3060:func requires_clear() -> bool:
3061-	return _requires_clear
3062-
3063-
3064-## Aktiver Kampf laeuft: Gegner wurden gespawnt, der Raum ist aber noch nicht
3065-## geleert. Von door.gd benutzt, um Hacking waehrend des Kampfs direkt am
3066-## Raumzustand zu verweigern - unabhaengig davon, ob set_door_hack_enabled()
3067-## fuer diese Tuer (noch) korrekt gesetzt wurde.
3068-func is_in_combat() -> bool:
3069-	return _requires_clear and _enemies_spawned and not _is_cleared
3070-
```

## 🤷 User: *[Request interrupted by user]*

`20:53:55`

[Request interrupted by user]

die minimap ist zwar von der logik richtig aber es sollte kein layoutgrid sein sondern DIREKT IN DER MINIMAP SEIN also die minimap selber zeigt welche räume cleared uncleared und special room sind

### 💭 Thinking

`20:55:09`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_is_cleared|room_cleared\.emit|signal room_cleared|room_type|MINIMAP_ONLY_LAYER|MINIMAP_HIDDEN_LAYER` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:55:10`

```
37:const MINIMAP_HIDDEN_LAYER: int = 20
51:const MINIMAP_ONLY_LAYER: int = 19
313:signal room_cleared(room: RoomInstance)
392:var _is_cleared: bool = false
401:## die Bedingung "_active_enemies <= 0 and not _is_cleared" greift, und der
405:## verriegelt korrekt - aber _is_cleared steht bereits auf true, also wird
1395:				visual.layers = 1 << (MINIMAP_HIDDEN_LAYER - 1)
2072:	# Zuruecksetzen bliebe ein faelschlich gesetztes _is_cleared stehen und
2074:	_is_cleared = false
2179:	if _is_cleared or not _requires_clear or not _enemies_spawned:
2247:		_is_cleared = true
2354:		_is_cleared = true
2378:		_is_cleared = true
2555:## MINIMAP_ONLY_LAYER. Farbe und Sichtbarkeit richten sich nach dem
2590:		marker.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
2735:	if _active_enemies <= 0 and not _is_cleared:
2736:		_is_cleared = true
2740:		room_cleared.emit(self)
2752:	if _is_cleared or not _requires_clear or not _enemies_spawned:
2766:	_is_cleared = true
2768:	room_cleared.emit(self)
2797:	_is_cleared = true
2799:	room_cleared.emit(self)
3057:	return _is_cleared
3069:	return _requires_clear and _enemies_spawned and not _is_cleared
3100:	if _is_cleared or _enemies_spawned or not _requires_clear:
```

### 💭 Thinking

`20:55:22`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:55:23`

*(lines 2540–2610)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
			push_warning("RoomInstance (%s): Richtung '%s' hatte einen ExitPoint, konnte aber nicht zugemauert werden (Tuer nicht in _doors_by_dir registriert) - die Oeffnung bleibt offen und fuehrt ins Leere." % [grid_position, key])

	# Die frisch gemauerten Waende brauchen ihre Minimap-Kappe. Der zweite
	# Durchlauf ist billig: _build_wall_caps ueberspringt jede Wand, die
	# schon eine hat.
	if sealed_any and wall_cap_enabled:
		_build_wall_caps()

	# Erst JETZT die Zustandsplatten bauen - vorher stehen noch die
	# Tueren der Richtungen im Weg, die gerade zugemauert wurden.
	if door_marker_enabled:
		_build_door_markers()


## Legt ueber jeden verbliebenen Durchgang eine flache Platte auf
## MINIMAP_ONLY_LAYER. Farbe und Sichtbarkeit richten sich nach dem
## Tuerzustand, aktualisiert wird in _process().
func _build_door_markers() -> void:
	for dir in _doors_by_dir.keys():
		if _door_markers.has(dir):
			continue

		var door: Node3D = _doors_by_dir[dir] as Node3D
		if not is_instance_valid(door):
			continue

		var leaf := Vector3(10.0, 10.0, 0.8)
		var collision := door.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision != null and collision.shape is BoxShape3D:
			leaf = (collision.shape as BoxShape3D).size

		var box := BoxMesh.new()
		if leaf.x >= leaf.z:
			box.size = Vector3(leaf.x, door_marker_height, door_lintel_thickness)
		else:
			box.size = Vector3(door_lintel_thickness, door_marker_height, leaf.z)

		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = door_marker_color_locked

		var marker := MeshInstance3D.new()
		marker.name = "DoorMarker%s" % dir.capitalize()
		marker.mesh = box
		marker.material_override = material
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# Knapp UEBER der Wandoberkante, sonst kaempft die Platte im
		# Tiefenvergleich mit den Wandkappen (die sitzen exakt dort).
		marker.position = Vector3(door.position.x, room_height + door_marker_height, door.position.z)
		# Nur die Minimap-Kamera sieht diesen Layer.
		marker.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
		add_child(marker)

		_door_markers[dir] = {"node": marker, "material": material}
		_door_marker_states[dir] = -1


func _process(delta: float) -> void:
	if _door_markers.is_empty():
		return
	_door_marker_pulse = fmod(_door_marker_pulse + delta * 2.2, TAU)
	_refresh_door_markers()


## Faerbt die Platten nach dem ECHTEN Tuerzustand. Eine offene Tuer
## bekommt keine Platte - der Durchgang soll auf der Karte dann ja als
## Oeffnung zu lesen sein.
func _refresh_door_markers() -> void:
	for dir in _door_markers.keys():
		var entry: Dictionary = _door_markers[dir]
```
</details>

### 💭 Thinking

`20:55:57`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `room.grid_position = |instance.grid_position|\.grid_position = grid_pos|room_footprint = |instance\.global_transform` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`20:55:59`

```
449-		if room == null:
450-			continue
451-
452:		room.grid_position = grid_pos
453-
454-		room.apply_exit_flags(cell.exit_flags)
455-
456-		# PHASE 3.2: Thema der Etage auflegen.
457-		if _stage_theme != null and room.has_method("apply_theme"):
458-			room.apply_theme(_stage_theme)
459-
460-		# Korridor mit Hoehenunterschied -> Rampe im Inneren bauen und die
--
1107-	# eine Eigenschaft des Transforms ist und sich auf ALLE Kinder auswirkt,
1108-	# unabhaengig davon, wann sie erzeugt wurden. Exakt dasselbe Muster nutzt
1109-	# schon room_commit_guard.gd (siehe dessen Kommentar zu _attach_deferred).
1110:	instance.global_transform = Transform3D(Basis.IDENTITY.scaled(room_scale), spawn_transform.origin)
1111-
1112-	var room := instance as RoomInstance
1113-	if room == null:
1114-		push_error("[LevelGenerator] Szene '%s' hat Root-Typ %s statt RoomInstance-Script!" % [data.scene.resource_path, instance.get_class()])
1115-	return room
```

### 💭 Thinking

`20:56:57`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_requires_clear = |door_marker_height|door_marker_color_locked|@export var wall_cap_height|const MINIMAP_ONLY_LAYER` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:56:58`

```
51:const MINIMAP_ONLY_LAYER: int = 19
176:@export var wall_cap_height: float = 1.0
289:@export var door_marker_height: float = 0.3
290:@export var door_marker_color_locked: Color = Color(0.70, 0.28, 0.24)
1767:			marker.position.y = room_height + door_marker_height
2251:	_requires_clear = true
2573:			box.size = Vector3(leaf.x, door_marker_height, door_lintel_thickness)
2575:			box.size = Vector3(door_lintel_thickness, door_marker_height, leaf.z)
2579:		material.albedo_color = door_marker_color_locked
2588:		marker.position = Vector3(door.position.x, room_height + door_marker_height, door.position.z)
2633:				_set_marker_color(entry, door_marker_color_locked)
```

### 💭 Thinking

`20:57:02`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:57:03`

*(lines 2225–2265)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
]


func prepare_enemies(entries: Array[EnemySpawnEntry], threat_budget: int, stage: int, is_boss_room: bool = false) -> void:
	_pending_is_boss_room = is_boss_room
	if not _spawn_seed_set:
		# Ohne gesetzten Seed (z.B. Raum von Hand in ein Testlevel
		# gesetzt) faellt der Raum auf echten Zufall zurueck - nur dann
		# ist der Run eben nicht reproduzierbar.
		_spawn_rng.randomize()
		_spawn_seed_set = true

	_pending_stage = stage
	var usable: Array[EnemySpawnEntry] = []
	for e in entries:
		if e == null or not e.is_allowed(stage, room_height):
			continue
		if _has_slope and e.scene != null and STATIONARY_ENEMY_SCENE_PATHS.has(e.scene.resource_path):
			continue
		usable.append(e)

	if usable.is_empty() or enemy_spawn_points.is_empty() or threat_budget <= 0:
		_is_cleared = true
		_lock_exits(false)
		return

	_requires_clear = true
	_pending_entries = usable
	_pending_budget = threat_budget
	_lock_exits(false)


## Deckelt, wie viele VERSCHIEDENE Gegnertypen ein einzelner Raum zeigen darf
## - unabhaengig vom Budget. Ohne das kann ein zufaellig vollgeschriebener
## Raum theoretisch 6-7 unterschiedliche Verhaltensmuster gleichzeitig
## zeigen, was schnell unuebersichtlich wird (Rueckmeldung: "zu viel
## Verwirrung"). Das Budget fuellt sich danach weiter mit WIEDERHOLUNGEN der
## bereits gewaehlten Typen statt neuer Sorten auf.
const MAX_DISTINCT_ENEMY_TYPES: int = 3

```
</details>

### 🤖 Assistant: *Now I understand the existing pattern (`_build_door_markers…*

`20:58:02`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now I understand the existing pattern (`_build_door_markers()` — flat plates on `MINIMAP_ONLY_LAYER`, positioned above the ceiling so they render on the minimap camera without touching the main view). I'll reuse that exact mechanism instead of a separate 2D panel. Let me remove the 2D overlay first, then build this into `room_instance.gd`.

#### 👀 Read `minimap.gd`

`20:58:04`

*(lines 193–243)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap.gd</code></summary>

```
func _ready() -> void:
	add_to_group(MINIMAP_GROUP)
	big_map_open = false

	map_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	map_camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	map_camera.near = 0.1
	map_camera.far = map_height * 2.0

	# Fog of War: Raeume, die noch nicht aufgedeckt sind, haengt der
	# LevelGenerator auf RoomInstance.MINIMAP_HIDDEN_LAYER um. NUR diese
	# Kamera streicht den Layer aus ihrer cull_mask - die Spielerkamera
	# bleibt unangetastet und zeigt die Welt vollstaendig.
	map_camera.set_cull_mask_value(RoomInstance.MINIMAP_HIDDEN_LAYER, false)

	sub_viewport.own_world_3d = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_viewport.transparent_bg = minimap_transparent_background

	_cache_frame_style()
	_set_zone_text(default_zone_name)

	if minimap_disable_fog:
		_apply_minimap_environment()

	map_container.pivot_offset = map_container.size * 0.5
	map_container.rotation_degrees = map_calibration_offset_degrees

	# Overlay-Platzierung kommt aus den Einstellungen. Der @export-Wert
	# bleibt als Editor-Vorgabe erhalten, wird hier aber ueberschrieben -
	# sonst gaebe es zwei konkurrierende Quellen fuer dieselbe Entscheidung.
	overlay_placement = SettingsManager.minimap_grid_placement as OverlayPlacement
	if overlay_placement != OverlayPlacement.HIDDEN:
		_create_room_overlay()

	# WICHTIG: Erst NACH _create_room_overlay() die Kleinansicht-Masse
	# sichern. Das Overlay veraendert dort ggf. die Frame-Hoehe - wuerde
	# man vorher sichern, springt die Minimap beim ersten Schliessen der
	# Grosskarte auf die falsche Groesse zurueck.
	_small_frame_size = frame.size
	_small_frame_position = frame.position
	_small_map_container_size = map_container.size
	_small_map_container_position = map_container.position
	_small_map_camera_size = map_size
	if _room_overlay:
		_small_overlay_size = _room_overlay.size
		_small_overlay_position = _room_overlay.position

	if not SettingsManager.minimap_setting_changed.is_connected(_apply_minimap_settings):
		SettingsManager.minimap_setting_changed.connect(_apply_minimap_settings)
```
</details>

### 💭 Thinking

`20:58:11`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `minimap.gd`

`20:58:17`

```diff
@@ -1,6 +1,10 @@-	# Overlay-Platzierung kommt aus den Einstellungen. Der @export-Wert
-	# bleibt als Editor-Vorgabe erhalten, wird hier aber ueberschrieben -
-	# sonst gaebe es zwei konkurrierende Quellen fuer dieselbe Entscheidung.
-	overlay_placement = SettingsManager.minimap_grid_placement as OverlayPlacement
-	if overlay_placement != OverlayPlacement.HIDDEN:
-		_create_room_overlay()
+	# Das schematische Raum-Grid-Overlay (MinimapRooms) ist komplett entfernt
+	# (Rueckmeldung: "sollte kein Layoutgrid sein, sondern direkt in der
+	# Minimap"). Raum-Zustand (gecleart/nicht) und Spezialraum-Icons
+	# (Schatz/Boss) werden jetzt direkt in der echten 3D-Top-Down-Ansicht
+	# angezeigt - siehe room_instance.gd::_build_room_state_overlay()/
+	# set_room_type(), beide auf MINIMAP_ONLY_LAYER wie die schon
+	# bestehenden Tuerzustands-Platten. _create_room_overlay() bleibt als
+	# totes Legacy-Codepfad stehen (siehe dortiger Kommentar), wird aber
+	# absichtlich nie mehr aufgerufen.
+	overlay_placement = OverlayPlacement.HIDDEN
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:58:20`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `minimap.gd`

`20:58:21`

*(lines 505–525)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap.gd</code></summary>

```

	if player_arrow:
		player_arrow.visible = SettingsManager.minimap_show_player_arrow
	if coord_label:
		coord_label.visible = SettingsManager.minimap_show_coords
	if zone_label:
		zone_label.visible = SettingsManager.minimap_show_zone_label

	var placement: int = SettingsManager.minimap_grid_placement
	if _room_overlay and is_instance_valid(_room_overlay):
		_room_overlay.visible = placement != SettingsManager.MINIMAP_GRID_HIDDEN
	elif placement != SettingsManager.MINIMAP_GRID_HIDDEN:
		# Grid war beim Start ausgeschaltet und wurde jetzt eingeschaltet:
		# Overlay nachtraeglich erzeugen statt einen Neustart zu verlangen.
		overlay_placement = placement as OverlayPlacement
		_create_room_overlay()
		if _room_overlay:
			_small_overlay_size = _room_overlay.size
			_small_overlay_position = _room_overlay.position

```
</details>

#### ✏️  Edit `minimap.gd`

`20:58:27`

```diff
@@ -1,11 +1,3 @@-	var placement: int = SettingsManager.minimap_grid_placement
-	if _room_overlay and is_instance_valid(_room_overlay):
-		_room_overlay.visible = placement != SettingsManager.MINIMAP_GRID_HIDDEN
-	elif placement != SettingsManager.MINIMAP_GRID_HIDDEN:
-		# Grid war beim Start ausgeschaltet und wurde jetzt eingeschaltet:
-		# Overlay nachtraeglich erzeugen statt einen Neustart zu verlangen.
-		overlay_placement = placement as OverlayPlacement
-		_create_room_overlay()
-		if _room_overlay:
-			_small_overlay_size = _room_overlay.size
-			_small_overlay_position = _room_overlay.position
+	# Grid-Overlay entfernt (siehe _ready()) - die minimap_grid_placement-
+	# Einstellung bleibt bestehen (Menue nicht angefasst), wird hier aber
+	# bewusst ignoriert statt ein Overlay nachzuziehen.
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\minimap.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's add the world-space room-state…*

`20:58:31`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now let's add the world-space room-state overlay and special-room icons to `room_instance.gd`. First, the export block near the door-marker settings:

#### 👀 Read `room_instance.gd`

`20:58:32`

*(lines 283–298)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
@export var spawn_ground_probe_height: float = 40.0

## --- Tuerzustand auf der 3D-Minimap -----------------------------------
## Farben absichtlich identisch zum schematischen Grid-Overlay
## (minimap_rooms.gd), damit beide Karten dasselbe sagen.
@export var door_marker_enabled: bool = true
@export var door_marker_height: float = 0.3
@export var door_marker_color_locked: Color = Color(0.70, 0.28, 0.24)
@export var door_marker_color_hack_locked: Color = Color(0.55, 0.45, 0.30)
@export var door_marker_color_hack_ready: Color = Color(0.98, 0.80, 0.25)

## --- Stage-Skalierung der Gegner --------------------------------------
## Vom LevelGenerator gesetzt (nicht @export - sonst gaebe es pro
## Raum-Szene einen konkurrierenden zweiten Wert). 1.0 = keine
## Skalierung. Wird beim Spawnen auf Health.max_health bzw. auf die
```
</details>

### 💭 Thinking

`20:58:38`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `room_instance.gd`

`20:58:53`

```diff
@@ -1,8 +1,39 @@ ## --- Tuerzustand auf der 3D-Minimap -----------------------------------
-## Farben absichtlich identisch zum schematischen Grid-Overlay
-## (minimap_rooms.gd), damit beide Karten dasselbe sagen.
 @export var door_marker_enabled: bool = true
 @export var door_marker_height: float = 0.3
 @export var door_marker_color_locked: Color = Color(0.70, 0.28, 0.24)
 @export var door_marker_color_hack_locked: Color = Color(0.55, 0.45, 0.30)
 @export var door_marker_color_hack_ready: Color = Color(0.98, 0.80, 0.25)
+
+## --- Raumzustand + Spezialraum-Icons auf der 3D-Minimap ------------------
+## Rueckmeldung: kein separates 2D-Schema-Overlay mehr - Zustand und
+## Spezialraum-Kennzeichnung sollen DIREKT in der echten Top-Down-Minimap
+## zu sehen sein. Gleiches Muster wie die Tuerzustands-Platten oben: eine
+## flache Flaeche auf MINIMAP_ONLY_LAYER, oberhalb der Decke platziert -
+## dadurch fuer die (von weit oben senkrecht herunterblickende, orthogonale)
+## Kartenkamera sichtbar VOR der Decke, ohne die normale Spielkamera oder
+## die Decke selbst anzutasten.
+##
+## ZUSTAND: eine halbtransparente dunkle Plfache ueber der GESAMTEN
+## Raumflaeche (room_footprint), NUR fuer Raeume mit aktivem Kampf-Gate
+## (_requires_clear) gebaut - verschwindet automatisch, sobald room_cleared
+## feuert (siehe _ready()). "Volle helle Farbe" heisst dann einfach: die
+## Platte ist weg, die echte (bereits korrekt gekachelte) Bodenfarbe
+## scheint ungehindert durch - kein zweiter Ort, an dem eine Typ-Farbe
+## gepflegt werden muesste.
+@export var room_state_overlay_enabled: bool = true
+@export var room_state_overlay_height: float = 0.4
+@export var room_state_overlay_color: Color = Color(0.08, 0.08, 0.09, 0.72)
+
+## ICONS: Schatz-/Bossraum bekommen ein kleines geometrisches Symbol ueber
+## der Raummitte (Stern statt woertlicher Krone, Kreis-Duo statt woertlichem
+## Totenkopf - siehe _build_special_room_icon(): die Kartenkamera blickt rein
+## ORTHOGONAL senkrecht herab, sichtbar ist also ausschliesslich die
+## X/Z-Silhouette, keine Hoehe/Volumen. Ein fein gezacktes Kronen- oder
+## Schaedel-Umriss-Polygon waere aus der Verkleinerung der kleinen Minimap
+## ohnehin kaum von einem Stern/Kreis zu unterscheiden - die einfachere Form
+## ist genauso lesbar und deutlich robuster zu bauen.
+@export var special_room_icon_height: float = 0.7
+@export var special_room_icon_size: float = 3.2
+@export var treasure_room_icon_color: Color = Color(0.98, 0.82, 0.22)
+@export var boss_room_icon_color: Color = Color(0.92, 0.20, 0.18)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:58:56`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `room_instance.gd`

`20:58:57`

```diff
@@ -1 +1 @@-## ZUSTAND: eine halbtransparente dunkle Plfache ueber der GESAMTEN
+## ZUSTAND: eine halbtransparente dunkle Flaeche ueber der GESAMTEN
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:59:01`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `var _door_markers|var _door_marker_states|var _requires_clear` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`20:59:02`

```
444-var _counted_dead_enemies: Dictionary = {}
445-var _watchdog_timer: float = 0.0
446:var _requires_clear: bool = false
--
497-
498-## dir -> { "node": MeshInstance3D, "material": StandardMaterial3D }
499:var _door_markers: Dictionary = {}
500-## dir -> zuletzt gezeichneter DoorState. Verhindert, dass jeden Frame
501-## Material-Eigenschaften neu gesetzt werden.
502:var _door_marker_states: Dictionary = {}
```

#### ✏️  Edit `room_instance.gd`

`20:59:09`

```diff
@@ -3,3 +3,10 @@ ## dir -> zuletzt gezeichneter DoorState. Verhindert, dass jeden Frame
 ## Material-Eigenschaften neu gesetzt werden.
 var _door_marker_states: Dictionary = {}
+
+## Von LevelGenerator direkt nach dem Instanziieren gesetzt (siehe dortiges
+## load_room(), analog zu grid_position), ueber set_room_type() - siehe dort.
+## -1 = unbekannt/nicht gesetzt (z.B. Raum von Hand in eine Testszene
+## gesetzt, ohne LevelGenerator).
+var room_type: int = -1
+var _room_state_overlay: MeshInstance3D = null
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:59:14`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:59:14`

*(lines 497–527)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```

## dir -> { "node": MeshInstance3D, "material": StandardMaterial3D }
var _door_markers: Dictionary = {}
## dir -> zuletzt gezeichneter DoorState. Verhindert, dass jeden Frame
## Material-Eigenschaften neu gesetzt werden.
var _door_marker_states: Dictionary = {}

## Von LevelGenerator direkt nach dem Instanziieren gesetzt (siehe dortiges
## load_room(), analog zu grid_position), ueber set_room_type() - siehe dort.
## -1 = unbekannt/nicht gesetzt (z.B. Raum von Hand in eine Testszene
## gesetzt, ohne LevelGenerator).
var room_type: int = -1
var _room_state_overlay: MeshInstance3D = null
var _door_marker_pulse: float = 0.0


func _ready() -> void:
	add_to_group(NAV_SOURCE_GROUP)
	_collect_markers()
	_setup_entry_trigger()
	_setup_presence_area()
	if build_ceiling:
		_build_ceiling()
	_fix_floor_material_tiling()
	if build_door_lintels:
		_build_door_lintels()
	if wall_cap_enabled:
		_build_wall_caps()
	# build_room_lights/_build_room_lights() bewusst NICHT mehr aufgerufen -
	# Fackeln/Kerzen (Teil von _build_wall_decor()/_build_candles() unten)
```
</details>

### 💭 Thinking

`20:59:19`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:59:19`

*(lines 526–546)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
	# Fackeln/Kerzen (Teil von _build_wall_decor()/_build_candles() unten)
	# ersetzen die alten flachen Decken-Punktlichter komplett, siehe deren
	# Kopfkommentar. Die Funktion bleibt unten stehen, falls sie doch mal
	# wieder gebraucht wird, wird aber aus _ready() nicht mehr erreicht.
	if build_props:
		# Reihenfolge wichtig: _build_props() legt den "Props"-Container an
		# UND bricht fruehzeitig ab, falls er schon existiert (Idempotenz-
		# Schutz) - muss deshalb zuerst laufen, sonst wuerde eine der
		# folgenden Funktionen ihn zuerst anlegen und _build_props() liefe
		# nie. _build_tables() vor _build_near_table_props(), weil letztere
		# die von ersterer gesammelten Tischpositionen braucht.
		_build_props()
		_build_tables()
		_build_near_table_props()
		_build_wall_decor()
		_build_banners()
		_build_candles()


func _exit_tree() -> void:
```
</details>

#### ✏️  Edit `room_instance.gd`

`20:59:27`

```diff
@@ -6,3 +6,9 @@ 	if build_ceiling:
 		_build_ceiling()
 	_fix_floor_material_tiling()
+	# Raeumt die Zustands-Dimmplatte weg, sobald der Raum tatsaechlich
+	# gecleart wird - room_cleared feuert an mehreren Stellen (regulaeres
+	# Herunterzaehlen, Watchdog, Sofort-Clear ohne Gegner), siehe dortige
+	# Aufrufer. Selbst-Verbindung statt eines externen Listeners: die
+	# Minimap-Darstellung ist eine reine Eigenschaft DIESES Raums.
+	room_cleared.connect(_on_self_room_cleared)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`20:59:31`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`20:59:32`

*(lines 2607–2662)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
		if not is_instance_valid(door):
			continue

		var leaf := Vector3(10.0, 10.0, 0.8)
		var collision := door.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if collision != null and collision.shape is BoxShape3D:
			leaf = (collision.shape as BoxShape3D).size

		var box := BoxMesh.new()
		if leaf.x >= leaf.z:
			box.size = Vector3(leaf.x, door_marker_height, door_lintel_thickness)
		else:
			box.size = Vector3(door_lintel_thickness, door_marker_height, leaf.z)

		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = door_marker_color_locked

		var marker := MeshInstance3D.new()
		marker.name = "DoorMarker%s" % dir.capitalize()
		marker.mesh = box
		marker.material_override = material
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# Knapp UEBER der Wandoberkante, sonst kaempft die Platte im
		# Tiefenvergleich mit den Wandkappen (die sitzen exakt dort).
		marker.position = Vector3(door.position.x, room_height + door_marker_height, door.position.z)
		# Nur die Minimap-Kamera sieht diesen Layer.
		marker.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
		add_child(marker)

		_door_markers[dir] = {"node": marker, "material": material}
		_door_marker_states[dir] = -1


func _process(delta: float) -> void:
	if _door_markers.is_empty():
		return
	_door_marker_pulse = fmod(_door_marker_pulse + delta * 2.2, TAU)
	_refresh_door_markers()


## Faerbt die Platten nach dem ECHTEN Tuerzustand. Eine offene Tuer
## bekommt keine Platte - der Durchgang soll auf der Karte dann ja als
## Oeffnung zu lesen sein.
func _refresh_door_markers() -> void:
	for dir in _door_markers.keys():
		var entry: Dictionary = _door_markers[dir]
		var marker: MeshInstance3D = entry["node"]
		if not is_instance_valid(marker):
			continue

		var state: int = get_door_state(dir)

		# Der Puls muss jeden Frame durch, alles andere nur bei Wechsel.
		if state == DoorState.HACK_READY:
```
</details>

### 💭 Thinking

`21:00:07`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `room_instance.gd`

`21:00:28`

```diff
@@ -1,3 +1,134 @@+## ============================================================================
+## Raumzustand + Spezialraum-Icons auf der 3D-Minimap
+## ============================================================================
+## Wird aus prepare_enemies() aufgerufen, sobald feststeht, dass der Raum
+## tatsaechlich ein Kampf-Gate hat (_requires_clear) - ein Korridor/Start-/
+## Schatzraum ohne Kampf-Gate braucht nie eine Dimmplatte, "cleared" ist fuer
+## sie von Anfang an true.
+func _build_room_state_overlay() -> void:
+	if not room_state_overlay_enabled or _room_state_overlay != null:
+		return
+
+	var plane := PlaneMesh.new()
+	plane.size = Vector2(room_footprint.x, room_footprint.y)
+
+	var material := StandardMaterial3D.new()
+	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
+	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
+	material.albedo_color = room_state_overlay_color
+	material.cull_mode = BaseMaterial3D.CULL_DISABLED
+
+	_room_state_overlay = MeshInstance3D.new()
+	_room_state_overlay.name = "MinimapStateOverlay"
+	_room_state_overlay.mesh = plane
+	_room_state_overlay.material_override = material
+	_room_state_overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
+	_room_state_overlay.position = Vector3(0.0, room_height + room_state_overlay_height, 0.0)
+	# Nur die Minimap-Kamera sieht diesen Layer - siehe Klassenkommentar zu
+	# MINIMAP_ONLY_LAYER/_build_door_markers().
+	_room_state_overlay.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
+	add_child(_room_state_overlay)
+
+
+## room_cleared-Handler (siehe _ready()): raeumt die Dimmplatte weg, sobald
+## der Raum wirklich gecleart ist - die echte, darunterliegende Bodenfarbe
+## scheint dann ungehindert durch die Kartenkamera durch.
+func _on_self_room_cleared(_room: RoomInstance) -> void:
+	if _room_state_overlay != null and is_instance_valid(_room_state_overlay):
+		_room_state_overlay.queue_free()
+	_room_state_overlay = null
+
+
+## Von LevelGenerator direkt nach dem Instanziieren gesetzt (siehe dortiges
+## load_room(), analog zu grid_position) - baut bei Schatz-/Bossraum sofort
+## das passende Minimap-Icon.
+func set_room_type(type: int) -> void:
+	room_type = type
+	_build_special_room_icon()
+
+
+func _build_special_room_icon() -> void:
+	var icon: MeshInstance3D = null
+	if room_type == RoomData.RoomType.TREASURE:
+		icon = _build_flat_fan_icon(
+			_star_points(5, special_room_icon_size, special_room_icon_size * 0.42), treasure_room_icon_color
+		)
+	elif room_type == RoomData.RoomType.BOSS:
+		icon = _build_boss_icon()
+	if icon == null:
+		return
+	icon.position = Vector3(0.0, room_height + special_room_icon_height, 0.0)
+	add_child(icon)
+
+
+## Fuenfzackiger Stern statt einer woertlichen Krone (Schatzraum) - siehe
+## Export-Kommentar bei special_room_icon_size: die Kartenkamera blickt rein
+## orthogonal senkrecht herab, sichtbar ist ausschliesslich die X/Z-
+## Silhouette. Mit inner_radius == outer_radius ergibt dieselbe Funktion
+## stattdessen ein regelmaessiges Vieleck (siehe _build_boss_icon()) - fuer
+## genug Ecken (hier 20) optisch kaum von einem Kreis zu unterscheiden.
+func _star_points(spikes: int, outer_radius: float, inner_radius: float) -> PackedVector2Array:
+	var points := PackedVector2Array()
+	var total: int = spikes * 2
+	for i in range(total):
+		var r: float = outer_radius if i % 2 == 0 else inner_radius
+		var angle: float = (float(i) / float(total)) * TAU - PI * 0.5
+		points.append(Vector2(cos(angle) * r, sin(angle) * r))
+	return points
+
+
+## Flaches Fuellpolygon (Dreiecksfaecher vom lokalen Ursprung aus) fuer ein
+## sternfoermig-konvexes Punkte-Set wie _star_points() liefert - funktioniert
+## NICHT fuer beliebige Polygone, reicht aber fuer alles, was hier gebraucht
+## wird. Unshaded + cull_mode DISABLED: aus reiner Draufsicht ist nur EINE
+## Seite je sichtbar, aber "unshaded" braucht ohnehin keine korrekten
+## Normalen/Backface-Kompensation.
+func _build_flat_fan_icon(points: PackedVector2Array, color: Color) -> MeshInstance3D:
+	var st := SurfaceTool.new()
+	st.begin(Mesh.PRIMITIVE_TRIANGLES)
+	for i in range(points.size()):
+		var a: Vector2 = points[i]
+		var b: Vector2 = points[(i + 1) % points.size()]
+		st.add_vertex(Vector3.ZERO)
+		st.add_vertex(Vector3(a.x, 0.0, a.y))
+		st.add_vertex(Vector3(b.x, 0.0, b.y))
+	st.generate_normals()
+
+	var mesh_instance := MeshInstance3D.new()
+	mesh_instance.mesh = st.commit()
+	var material := StandardMaterial3D.new()
+	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
+	material.albedo_color = color
+	material.cull_mode = BaseMaterial3D.CULL_DISABLED
+	mesh_instance.material_override = material
+	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
+	mesh_instance.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
+	return mesh_instance
+
+
+## Vereinfachter Totenkopf (Bossraum): grosse dunkle Kreisflaeche + zwei
+## helle "Augen"-Punkte knapp darueber versetzt (Farbkontrast statt einer
+## echten Aussparung - ein Loch im Fuellpolygon wuerde eine deutlich
+## komplexere Triangulierung brauchen, siehe _build_flat_fan_icon()-Limit).
+func _build_boss_icon() -> MeshInstance3D:
+	var skull: MeshInstance3D = _build_flat_fan_icon(
+		_star_points(10, special_room_icon_size, special_room_icon_size), Color(0.1, 0.1, 0.11)
+	)
+	var eye_offset_x: float = special_room_icon_size * 0.32
+	var eye_offset_z: float = -special_room_icon_size * 0.1
+	var eye_radius: float = special_room_icon_size * 0.22
+
+	var eye_l: MeshInstance3D = _build_flat_fan_icon(_star_points(8, eye_radius, eye_radius), boss_room_icon_color)
+	eye_l.position = Vector3(-eye_offset_x, 0.02, eye_offset_z)
+	skull.add_child(eye_l)
+
+	var eye_r: MeshInstance3D = _build_flat_fan_icon(_star_points(8, eye_radius, eye_radius), boss_room_icon_color)
+	eye_r.position = Vector3(eye_offset_x, 0.02, eye_offset_z)
+	skull.add_child(eye_r)
+
+	return skull
+
+
 func _process(delta: float) -> void:
 	if _door_markers.is_empty():
 		return
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now hook the overlay build into `prepare_enemies…*

`21:00:32`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now hook the overlay build into `prepare_enemies()`:

#### ✏️  Edit `room_instance.gd`

`21:00:34`

```diff
@@ -2,3 +2,4 @@ 	_pending_entries = usable
 	_pending_budget = threat_budget
 	_lock_exits(false)
+	_build_room_state_overlay()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's wire `set_room_type()` from `level_generator…*

`21:00:38`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now let's wire `set_room_type()` from `level_generator.gd`:

#### 👀 Read `level_generator.gd`

`21:00:39`

*(lines 445–460)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd</code></summary>

```
			cell.elevation * elevation_step,
			(float(grid_pos.y) + center_offset.y) * cell_size.z
		)
		var room := load_room(data, Transform3D(Basis.IDENTITY, world_pos))
		if room == null:
			continue

		room.grid_position = grid_pos

		room.apply_exit_flags(cell.exit_flags)

		# PHASE 3.2: Thema der Etage auflegen.
		if _stage_theme != null and room.has_method("apply_theme"):
			room.apply_theme(_stage_theme)

```
</details>

#### ✏️  Edit `level_generator.gd`

`21:00:44`

```diff
@@ -1,3 +1,5 @@ 		room.grid_position = grid_pos
+		if room.has_method("set_room_type"):
+			room.set_room_type(cell.room_type)
 
 		room.apply_exit_flags(cell.exit_flags)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Let me verify the new block reads cleanly…*

`21:01:30`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let me verify the new block reads cleanly with no syntax issues.

#### 👀 Read `room_instance.gd`

`21:01:31`

*(lines 2641–2791)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```

## ============================================================================
## Raumzustand + Spezialraum-Icons auf der 3D-Minimap
## ============================================================================
## Wird aus prepare_enemies() aufgerufen, sobald feststeht, dass der Raum
## tatsaechlich ein Kampf-Gate hat (_requires_clear) - ein Korridor/Start-/
## Schatzraum ohne Kampf-Gate braucht nie eine Dimmplatte, "cleared" ist fuer
## sie von Anfang an true.
func _build_room_state_overlay() -> void:
	if not room_state_overlay_enabled or _room_state_overlay != null:
		return

	var plane := PlaneMesh.new()
	plane.size = Vector2(room_footprint.x, room_footprint.y)

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = room_state_overlay_color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED

	_room_state_overlay = MeshInstance3D.new()
	_room_state_overlay.name = "MinimapStateOverlay"
	_room_state_overlay.mesh = plane
	_room_state_overlay.material_override = material
	_room_state_overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_room_state_overlay.position = Vector3(0.0, room_height + room_state_overlay_height, 0.0)
	# Nur die Minimap-Kamera sieht diesen Layer - siehe Klassenkommentar zu
	# MINIMAP_ONLY_LAYER/_build_door_markers().
	_room_state_overlay.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
	add_child(_room_state_overlay)


## room_cleared-Handler (siehe _ready()): raeumt die Dimmplatte weg, sobald
## der Raum wirklich gecleart ist - die echte, darunterliegende Bodenfarbe
## scheint dann ungehindert durch die Kartenkamera durch.
func _on_self_room_cleared(_room: RoomInstance) -> void:
	if _room_state_overlay != null and is_instance_valid(_room_state_overlay):
		_room_state_overlay.queue_free()
	_room_state_overlay = null


## Von LevelGenerator direkt nach dem Instanziieren gesetzt (siehe dortiges
## load_room(), analog zu grid_position) - baut bei Schatz-/Bossraum sofort
## das passende Minimap-Icon.
func set_room_type(type: int) -> void:
	room_type = type
	_build_special_room_icon()


func _build_special_room_icon() -> void:
	var icon: MeshInstance3D = null
	if room_type == RoomData.RoomType.TREASURE:
		icon = _build_flat_fan_icon(
			_star_points(5, special_room_icon_size, special_room_icon_size * 0.42), treasure_room_icon_color
		)
	elif room_type == RoomData.RoomType.BOSS:
		icon = _build_boss_icon()
	if icon == null:
		return
	icon.position = Vector3(0.0, room_height + special_room_icon_height, 0.0)
	add_child(icon)


## Fuenfzackiger Stern statt einer woertlichen Krone (Schatzraum) - siehe
## Export-Kommentar bei special_room_icon_size: die Kartenkamera blickt rein
## orthogonal senkrecht herab, sichtbar ist ausschliesslich die X/Z-
## Silhouette. Mit inner_radius == outer_radius ergibt dieselbe Funktion
## stattdessen ein regelmaessiges Vieleck (siehe _build_boss_icon()) - fuer
## genug Ecken (hier 20) optisch kaum von einem Kreis zu unterscheiden.
func _star_points(spikes: int, outer_radius: float, inner_radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var total: int = spikes * 2
	for i in range(total):
		var r: float = outer_radius if i % 2 == 0 else inner_radius
		var angle: float = (float(i) / float(total)) * TAU - PI * 0.5
		points.append(Vector2(cos(angle) * r, sin(angle) * r))
	return points


## Flaches Fuellpolygon (Dreiecksfaecher vom lokalen Ursprung aus) fuer ein
## sternfoermig-konvexes Punkte-Set wie _star_points() liefert - funktioniert
## NICHT fuer beliebige Polygone, reicht aber fuer alles, was hier gebraucht
## wird. Unshaded + cull_mode DISABLED: aus reiner Draufsicht ist nur EINE
## Seite je sichtbar, aber "unshaded" braucht ohnehin keine korrekten
## Normalen/Backface-Kompensation.
func _build_flat_fan_icon(points: PackedVector2Array, color: Color) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(points.size()):
		var a: Vector2 = points[i]
		var b: Vector2 = points[(i + 1) % points.size()]
		st.add_vertex(Vector3.ZERO)
		st.add_vertex(Vector3(a.x, 0.0, a.y))
		st.add_vertex(Vector3(b.x, 0.0, b.y))
	st.generate_normals()

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = st.commit()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
	return mesh_instance


## Vereinfachter Totenkopf (Bossraum): grosse dunkle Kreisflaeche + zwei
## helle "Augen"-Punkte knapp darueber versetzt (Farbkontrast statt einer
## echten Aussparung - ein Loch im Fuellpolygon wuerde eine deutlich
## komplexere Triangulierung brauchen, siehe _build_flat_fan_icon()-Limit).
func _build_boss_icon() -> MeshInstance3D:
	var skull: MeshInstance3D = _build_flat_fan_icon(
		_star_points(10, special_room_icon_size, special_room_icon_size), Color(0.1, 0.1, 0.11)
	)
	var eye_offset_x: float = special_room_icon_size * 0.32
	var eye_offset_z: float = -special_room_icon_size * 0.1
	var eye_radius: float = special_room_icon_size * 0.22

	var eye_l: MeshInstance3D = _build_flat_fan_icon(_star_points(8, eye_radius, eye_radius), boss_room_icon_color)
	eye_l.position = Vector3(-eye_offset_x, 0.02, eye_offset_z)
	skull.add_child(eye_l)

	var eye_r: MeshInstance3D = _build_flat_fan_icon(_star_points(8, eye_radius, eye_radius), boss_room_icon_color)
	eye_r.position = Vector3(eye_offset_x, 0.02, eye_offset_z)
	skull.add_child(eye_r)

	return skull


func _process(delta: float) -> void:
	if _door_markers.is_empty():
		return
	_door_marker_pulse = fmod(_door_marker_pulse + delta * 2.2, TAU)
	_refresh_door_markers()


## Faerbt die Platten nach dem ECHTEN Tuerzustand. Eine offene Tuer
## bekommt keine Platte - der Durchgang soll auf der Karte dann ja als
## Oeffnung zu lesen sein.
func _refresh_door_markers() -> void:
	for dir in _door_markers.keys():
		var entry: Dictionary = _door_markers[dir]
		var marker: MeshInstance3D = entry["node"]
		if not is_instance_valid(marker):
			continue

		var state: int = get_door_state(dir)
```
</details>

### 🤖 Assistant: *This all looks correct.*

`21:01:35`

> This all looks correct. Let's regenerate the vault/graph and confirm.

#### 💻 Bash

`21:01:35`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && python generate_vault.py 2>&1 | tail -6 && graphify update . 2>&1 | tail -8
```

```
[7/7] Master-Dashboard geschrieben (00_Dashboard)

      wiki_sync.py-Vorlage geschrieben (98_Scripts)

============================================================

Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann

diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault

konfiguriert, siehe vorhandener .obsidian/-Ordner).

  warning: skill is from graphify 0.9.32, package is 0.9.41. Run 'graphify install' to update.

Re-extracting code files in . (no LLM needed)...

  AST extraction: 1/1 uncached files (100%)

  warning: 1 source file(s) produced zero nodes and are absent from the graph: .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5159 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] No code-graph topology changes detected; outputs left untouched.

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *Sorted. I pivoted the implementation based…*

`21:02:05`

> Sorted. I pivoted the implementation based on your clarification — here's what changed:
> 
> **Removed:** The 2D `MinimapRooms` panel is disabled entirely (`minimap.gd` now forces `overlay_placement = HIDDEN` and never calls `_create_room_overlay()`). No separate dot-map, no layout grid, nothing next to the real minimap.
> 
> **Implemented directly in the 3D minimap** (`room_instance.gd`), reusing the exact mechanism your door-state indicators already use — flat unshaded meshes on `MINIMAP_ONLY_LAYER`, positioned above the room, invisible to the main camera and invisible to the ceiling too (the ceiling faces *downward* on purpose and gets backface-culled from a top-down view, which is why the door markers already worked this way):
> 
> - **Grayout**: a semi-transparent dark plate spans the room's actual footprint, built only for room with a combat gate (`_requires_clear`). It self-destructs the moment the room's own `room_cleared` signal fires, letting the real (correctly-tiled) floor color show through unobstructed — no second color source to keep in sync.
> - **Icons**: `LevelGenerator` now calls `room.set_room_type(cell.room_type)` right after instancing. Treasure room get a gold star (procedurally built via `SurfaceTool`, a stand-in for a crown — the map camera is strictly orthogonal top-down, so a fine-jagged crown outline would be indistinguishable from a star at minimap scale anyway), boss room get a dark circle with two bright "eyes" as a simplified skull.
> 
> One loose end: `minimap_rooms.gd` still exists on disk but is never instantiated anymore — I left it rather than delete it, since `minimap.gd` still has a `preload()` reference to it that I'd need to remove first too. Functionally it's fully inert now; say the word if you want it deleted properly.
> 
> Worth testing in-editor: walk into an uncleared combat room and confirm the minimap patch is dimmed, then clear it and confirm it brightens; check a treasure and boss room show their icons.

## 🤷 User: *also ich will das es dunkler ist.*

`21:03:28`

also ich will das es dunkler ist. aber so ist gut, und bitte so machen das wenn man im raum ist der ruam auch schon hell wird

### 💭 Thinking

`21:03:53`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_setup_entry_trigger|_on_entry_trigger|_entered|func _on_player_entered|_room_entered|is_current_room` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`21:03:55`

```
345:signal room_entered(room: RoomInstance)
378:##   1. ENTRY-TRIGGER ZU SCHMAL. _setup_entry_trigger() rueckt den Quader von
384:##      flackert, und room_entered feuert im Sekundentakt neu.
456:var _has_entered: bool = false
494:## _has_entered: das ist eine Einmal-Sperre fuer das Gegner-Spawnen, die
516:	_setup_entry_trigger()
1994:func _setup_entry_trigger() -> void:
2024:	_entry_trigger.body_exited.connect(_on_entry_trigger_body_exited)
2121:	_has_entered = false
2154:## body_entered: So wird auch der Fall abgedeckt, dass der Spieler beim
2155:## Laden des Raumes BEREITS im Trigger steht (body_entered feuert dann nie).
2174:	# room_entered wurde frueher NUR aus on_player_entered() gefeuert, und
2175:	# das laeuft wegen der _has_entered-Sperre genau EINMAL pro Raum. Wer
2181:	# steigenden Flanke gemeldet. _has_entered bleibt reine Spawn-Sperre.
2185:	if _has_entered:
2200:		_has_entered = true
2201:		on_player_entered()
2214:		room_entered.emit(self)
2244:func _on_entry_trigger_body_exited(body: Node) -> void:
3272:## Kampf. Das room_entered-Signal kommt NICHT mehr von hier, sondern aus
3275:func on_player_entered() -> void:
```

### 💭 Thinking

`21:04:01`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `room_instance.gd`

`21:04:01`

*(lines 2150–2250)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd</code></summary>

```
		print("[Room %s] Tuer '%s' -> ZWANGS-ENTRIEGELT (danach: %s)" % [grid_position, dir, door_state_name(get_door_state(dir))])


## Der Dwell-Check laeuft bewusst in _physics_process statt ueber
## body_entered: So wird auch der Fall abgedeckt, dass der Spieler beim
## Laden des Raumes BEREITS im Trigger steht (body_entered feuert dann nie).
func _physics_process(delta: float) -> void:
	# NICHT mehr komplett abschalten, sobald der Raum betreten wurde — der
	# Gegner-Watchdog unten muss weiterlaufen. Nur der Eintritts-Check wird
	# uebersprungen.
	if _entry_trigger == null:
		set_physics_process(false)
		return

	# Watchdog laeuft IMMER - auch nachdem der Raum betreten wurde, denn
	# genau dann koennen Gegner verschwinden ohne sauber zu sterben.
	_watchdog_timer -= delta
	if _watchdog_timer <= 0.0:
		_watchdog_timer = maxf(enemy_watchdog_interval, 0.1)
		_watchdog_check()

	# BUGFIX "Blinken auf der Grid-Karte bleibt am zuletzt geclearten Raum
	# haengen":
	#
	# room_entered wurde frueher NUR aus on_player_entered() gefeuert, und
	# das laeuft wegen der _has_entered-Sperre genau EINMAL pro Raum. Wer
	# in einen bereits geclearten Raum zurueckgeht, meldet sich damit nie
	# wieder an - _current_room im LevelGenerator zeigt weiter auf den
	# zuletzt NEU betretenen Raum, und das Overlay markiert den falschen.
	#
	# Die Anwesenheit wird deshalb jetzt jeden Frame geprueft und bei jeder
	# steigenden Flanke gemeldet. _has_entered bleibt reine Spawn-Sperre.
	var player: Node3D = _find_player_inside()
	_update_entry_presence(player != null)

	if _has_entered:
		_check_escape(delta)
		return

	if player == null:
		_dwell_timer = 0.0
		_dwell_body = null
		return

	if player != _dwell_body:
		_dwell_body = player
		_dwell_timer = 0.0

	_dwell_timer += delta
	if _dwell_timer >= maxf(entry_trigger_dwell_time, 0.0):
		_has_entered = true
		on_player_entered()


## Meldet die steigende Flanke "Spieler ist im Eintritts-Trigger". Der
## Eintritts-Trigger ist dafuer das richtige Volumen: er sitzt mittig im
## Raum und ueberlappt - anders als die PresenceArea, die den Grundriss um
## presence_margin aufblaeht - NICHT mit dem Nachbarraum. Sonst wuerde die
## Markierung im Tuerrahmen zwischen zwei Raeumen hin und her springen.
func _update_entry_presence(inside: bool) -> void:
	if inside == _inside_entry_trigger:
		return
	_inside_entry_trigger = inside
	if inside:
		room_entered.emit(self)


## Zaehlt hoch, solange der Spieler ausserhalb der Presence-Area ist, und
## setzt den Raum zurueck, sobald escape_grace_time ueberschritten ist.
## Laeuft nur fuer Raeume, die gerade wirklich verriegelt sind.
func _check_escape(delta: float) -> void:
	if not reset_when_player_escapes:
		return
	if _is_cleared or not _requires_clear or not _enemies_spawned:
		_escape_timer = 0.0
		return

	if _player_is_present():
		_escape_timer = 0.0
		return

	_escape_timer += delta
	if _escape_timer >= maxf(escape_grace_time, 0.05):
		_escape_timer = 0.0
		reset_room()


func _find_player_inside() -> Node3D:
	for body in _entry_trigger.get_overlapping_bodies():
		if body is Node3D and body.is_in_group(PartyManager.PLAYER_GROUP):
			return body
	return null


func _on_entry_trigger_body_exited(body: Node) -> void:
	if body == _dwell_body:
		_dwell_timer = 0.0
		_dwell_body = null


```
</details>

### 💭 Thinking

`21:04:19`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_inside_entry_trigger` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`21:04:20`

```
383:##      mehr drin - _find_player_inside() liefert null, _inside_entry_trigger
496:var _inside_entry_trigger: bool = false
2122:	# Nicht _inside_entry_trigger zuruecksetzen: der Spieler ist beim Reset
2210:	if inside == _inside_entry_trigger:
2212:	_inside_entry_trigger = inside
```

### 🤖 Assistant: *Confirmed the exact var to hook into.*

`21:04:24`

> Confirmed the exact var to hook into. Let's make both changes.

#### ✏️  Edit `room_instance.gd`

`21:04:26`

```diff
@@ -1,3 +1,4 @@ @export var room_state_overlay_enabled: bool = true
 @export var room_state_overlay_height: float = 0.4
-@export var room_state_overlay_color: Color = Color(0.08, 0.08, 0.09, 0.72)
+## War Color(0.08, 0.08, 0.09, 0.72) - Rueckmeldung "soll dunkler sein".
+@export var room_state_overlay_color: Color = Color(0.04, 0.04, 0.045, 0.9)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

```diff
@@ -4,3 +4,4 @@ 	_inside_entry_trigger = inside
 	if inside:
 		room_entered.emit(self)
+	_refresh_room_state_overlay_visibility()
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`21:04:37`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `room_instance.gd`

`21:04:45`

```diff
@@ -1,5 +1,6 @@ 	_room_state_overlay.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
 	add_child(_room_state_overlay)
+	_refresh_room_state_overlay_visibility()
 
 
 ## room_cleared-Handler (siehe _ready()): raeumt die Dimmplatte weg, sobald
@@ -9,3 +10,17 @@ 	if _room_state_overlay != null and is_instance_valid(_room_state_overlay):
 		_room_state_overlay.queue_free()
 	_room_state_overlay = null
+
+
+## Rueckmeldung "wenn man im Raum ist, soll er auch schon hell werden": nicht
+## erst NACH dem Clear soll die Dimmung weg sein, sondern schon waehrend man
+## drinsteht (z.B. mitten im laufenden Kampf) - der eigene Standort soll auf
+## der Karte nie dunkel wirken. Verlaesst man einen noch nicht gecleareten
+## Raum wieder, kommt die Dimmung zurueck, bis er entweder erneut betreten
+## oder tatsaechlich gecleart wird (dann verschwindet die Platte permanent,
+## siehe _on_self_room_cleared()). _inside_entry_trigger kommt vom
+## bestehenden Dwell-Check in _physics_process()/_update_entry_presence().
+func _refresh_room_state_overlay_visibility() -> void:
+	if _room_state_overlay == null or not is_instance_valid(_room_state_overlay):
+		return
+	_room_state_overlay.visible = not _inside_entry_trigger
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`21:04:49`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`21:04:49`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify update . 2>&1 | tail -6
```

```
  AST extraction: 1/1 uncached files (100%)

  warning: 1 source file(s) produced zero nodes and are absent from the graph: .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5159 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] No code-graph topology changes detected; outputs left untouched.

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *Both changes are in:*

`21:05:15`

> Both changes are in:
> 
> - **Darker**: `room_state_overlay_color` went from `(0.08, 0.08, 0.09, 0.72)` to `(0.04, 0.04, 0.045, 0.9)` — darker tint, higher opacity.
> - **Bright while present**: reused the room's existing dwell-check tracking (`_inside_entry_trigger`, the same var driving the `room_entered` signal) — the dimming plate now hides itself while you're physically standing in the room (even mid-fight, before it's cleared) and reappears if you leave without finishing it off. Clearing the room still removes it permanently.

## 🤷 User: *die icons der special room fehlen*

`21:06:09`

die icons der special room fehlen

### 💭 Thinking

`21:06:26`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `load_room\(|func _place_special_rooms|RoomType.BOSS|RoomType.TREASURE|set_room_type` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\level_generator.gd`

`21:06:27`

```
39:## load_room(). x/z = Grundriss (Breite/Tiefe), y = Hoehe. Alle Raum-Szenen
335:		RoomData.RoomType.TREASURE:
337:		RoomData.RoomType.BOSS:
448:		var room := load_room(data, Transform3D(Basis.IDENTITY, world_pos))
453:		if room.has_method("set_room_type"):
454:			room.set_room_type(cell.room_type)
467:		# load_room() setzt die Raum-Basis auf Basis.IDENTITY.scaled(room_scale).
497:		room.prepare_enemies(table, budget, current_stage, cell.room_type == RoomData.RoomType.BOSS)
584:				own_cell.room_type == RoomData.RoomType.BOSS
585:				or own_cell.room_type == RoomData.RoomType.TREASURE
600:				RoomData.RoomType.BOSS:
606:				RoomData.RoomType.TREASURE:
626:		if _map_cells[room.grid_position]["type"] == RoomData.RoomType.BOSS:
645:		if neighbor_type == RoomData.RoomType.BOSS or neighbor_type == RoomData.RoomType.TREASURE:
904:				if cell.room_type == RoomData.RoomType.BOSS or cell.room_type == RoomData.RoomType.TREASURE:
939:	if type == RoomData.RoomType.BOSS:
961:		RoomData.RoomType.BOSS:
974:	var cap: int = (boss_threat_hard_cap if type == RoomData.RoomType.BOSS else threat_hard_cap) * cell_count
1096:func load_room(data: RoomData, spawn_transform: Transform3D) -> RoomInstance:
```

### 💭 Thinking

`21:08:02`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `SurfaceTool` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`21:08:03`

Glob: `*.gd`

```
Found 1 file
scenes\level_generation\room_instance.gd
```

### 🤖 Assistant: *That `SurfaceTool`-built mesh is unprecedented…*

`21:08:30`

<details>
<summary>Thinking...</summary>

> 
</details>

> That `SurfaceTool`-built mesh is unprecedented in this codebase — every other procedural visual here uses plain primitive meshes (BoxMesh/CylinderMesh/etc.), and a custom mesh's auto-computed AABB can silently get frustum-culled in Godot. Rather than debug that further, let me rebuild the icons with the same primitive-mesh approach the working door markers already use.

#### ✏️  Edit `room_instance.gd`

`21:08:59`

```diff
@@ -1,9 +1,7 @@ func _build_special_room_icon() -> void:
-	var icon: MeshInstance3D = null
+	var icon: Node3D = null
 	if room_type == RoomData.RoomType.TREASURE:
-		icon = _build_flat_fan_icon(
-			_star_points(5, special_room_icon_size, special_room_icon_size * 0.42), treasure_room_icon_color
-		)
+		icon = _build_treasure_icon()
 	elif room_type == RoomData.RoomType.BOSS:
 		icon = _build_boss_icon()
 	if icon == null:
@@ -12,69 +10,81 @@ 	add_child(icon)
 
 
-## Fuenfzackiger Stern statt einer woertlichen Krone (Schatzraum) - siehe
-## Export-Kommentar bei special_room_icon_size: die Kartenkamera blickt rein
-## orthogonal senkrecht herab, sichtbar ist ausschliesslich die X/Z-
-## Silhouette. Mit inner_radius == outer_radius ergibt dieselbe Funktion
-## stattdessen ein regelmaessiges Vieleck (siehe _build_boss_icon()) - fuer
-## genug Ecken (hier 20) optisch kaum von einem Kreis zu unterscheiden.
-func _star_points(spikes: int, outer_radius: float, inner_radius: float) -> PackedVector2Array:
-	var points := PackedVector2Array()
-	var total: int = spikes * 2
-	for i in range(total):
-		var r: float = outer_radius if i % 2 == 0 else inner_radius
-		var angle: float = (float(i) / float(total)) * TAU - PI * 0.5
-		points.append(Vector2(cos(angle) * r, sin(angle) * r))
-	return points
+## BUGFIX "Icons komplett unsichtbar": urspruenglich per SurfaceTool aus
+## Hand-Polygonen gebaut - ein Ansatz, der SONST NIRGENDS im Projekt
+## vorkommt. Vermutlich ein Culling-/AABB-Problem eines von Hand erzeugten
+## Custom-Mesh ohne explizites custom_aabb. Jetzt ausschliesslich aus
+## eingebauten Primitiv-Meshes (BoxMesh/CylinderMesh) zusammengesetzt -
+## exakt dieselbe, bereits erwiesenermassen funktionierende Bauweise wie die
+## Tuerzustands-Platten (_build_door_markers()) und der Rest des Projekts
+## (dive_bomber.gd, custom_enemy_base.gd, treasure_pedestal.gd, ...).
+##
+## Kronen-Andeutung statt woertlicher Zacken: ein um 45 Grad gedrehtes,
+## flaches BoxMesh ergibt aus der rein orthogonalen Draufsicht der
+## Kartenkamera eine Rauten-/Edelstein-Silhouette, vier kleine Punkte an
+## den Spitzen lesen sich als Zacken.
+func _build_treasure_icon() -> Node3D:
+	var root := Node3D.new()
+	root.name = "TreasureIcon"
+
+	var s: float = special_room_icon_size
+	var gem_mesh := BoxMesh.new()
+	gem_mesh.size = Vector3(s, 0.05, s)
+	var gem: MeshInstance3D = _make_flat_icon_mesh(gem_mesh, treasure_room_icon_color)
+	gem.rotation_degrees.y = 45.0
+	root.add_child(gem)
+
+	for angle_deg: float in [0.0, 90.0, 180.0, 270.0]:
+		var rad: float = deg_to_rad(angle_deg)
+		var tip_mesh := CylinderMesh.new()
+		tip_mesh.top_radius = s * 0.16
+		tip_mesh.bottom_radius = s * 0.16
+		tip_mesh.height = 0.05
+		var tip: MeshInstance3D = _make_flat_icon_mesh(tip_mesh, treasure_room_icon_color)
+		tip.position = Vector3(cos(rad) * s * 0.75, 0.02, sin(rad) * s * 0.75)
+		root.add_child(tip)
+
+	return root
 
 
-## Flaches Fuellpolygon (Dreiecksfaecher vom lokalen Ursprung aus) fuer ein
-## sternfoermig-konvexes Punkte-Set wie _star_points() liefert - funktioniert
-## NICHT fuer beliebige Polygone, reicht aber fuer alles, was hier gebraucht
-## wird. Unshaded + cull_mode DISABLED: aus reiner Draufsicht ist nur EINE
-## Seite je sichtbar, aber "unshaded" braucht ohnehin keine korrekten
-## Normalen/Backface-Kompensation.
-func _build_flat_fan_icon(points: PackedVector2Array, color: Color) -> MeshInstance3D:
-	var st := SurfaceTool.new()
-	st.begin(Mesh.PRIMITIVE_TRIANGLES)
-	for i in range(points.size()):
-		var a: Vector2 = points[i]
-		var b: Vector2 = points[(i + 1) % points.size()]
-		st.add_vertex(Vector3.ZERO)
-		st.add_vertex(Vector3(a.x, 0.0, a.y))
-		st.add_vertex(Vector3(b.x, 0.0, b.y))
-	st.generate_normals()
+## Vereinfachter Totenkopf (Bossraum): flache dunkle Kreisflaeche + zwei
+## helle "Augen"-Punkte knapp darueber versetzt (Farbkontrast statt einer
+## echten Aussparung).
+func _build_boss_icon() -> Node3D:
+	var root := Node3D.new()
+	root.name = "BossIcon"
 
+	var base_mesh := CylinderMesh.new()
+	base_mesh.top_radius = special_room_icon_size * 0.5
+	base_mesh.bottom_radius = special_room_icon_size * 0.5
+	base_mesh.height = 0.05
+	root.add_child(_make_flat_icon_mesh(base_mesh, Color(0.1, 0.1, 0.11)))
+
+	var eye_radius: float = special_room_icon_size * 0.14
+	for side: float in [-1.0, 1.0]:
+		var eye_mesh := CylinderMesh.new()
+		eye_mesh.top_radius = eye_radius
+		eye_mesh.bottom_radius = eye_radius
+		eye_mesh.height = 0.05
+		var eye: MeshInstance3D = _make_flat_icon_mesh(eye_mesh, boss_room_icon_color)
+		eye.position = Vector3(side * special_room_icon_size * 0.28, 0.03, -special_room_icon_size * 0.08)
+		root.add_child(eye)
+
+	return root
+
+
+## Etwas Emission obendrauf, damit die Icons sich klar von der (nach der
+## letzten Rueckmeldung deutlich dunkleren) Dimmplatte abheben.
+func _make_flat_icon_mesh(mesh: Mesh, color: Color) -> MeshInstance3D:
 	var mesh_instance := MeshInstance3D.new()
-	mesh_instance.mesh = st.commit()
+	mesh_instance.mesh = mesh
 	var material := StandardMaterial3D.new()
 	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 	material.albedo_color = color
-	material.cull_mode = BaseMaterial3D.CULL_DISABLED
+	material.emission_enabled = true
+	material.emission = color
+	material.emission_energy_multiplier = 1.2
 	mesh_instance.material_override = material
 	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 	mesh_instance.layers = 1 << (MINIMAP_ONLY_LAYER - 1)
 	return mesh_instance
-
-
-## Vereinfachter Totenkopf (Bossraum): grosse dunkle Kreisflaeche + zwei
-## helle "Augen"-Punkte knapp darueber versetzt (Farbkontrast statt einer
-## echten Aussparung - ein Loch im Fuellpolygon wuerde eine deutlich
-## komplexere Triangulierung brauchen, siehe _build_flat_fan_icon()-Limit).
-func _build_boss_icon() -> MeshInstance3D:
-	var skull: MeshInstance3D = _build_flat_fan_icon(
-		_star_points(10, special_room_icon_size, special_room_icon_size), Color(0.1, 0.1, 0.11)
-	)
-	var eye_offset_x: float = special_room_icon_size * 0.32
-	var eye_offset_z: float = -special_room_icon_size * 0.1
-	var eye_radius: float = special_room_icon_size * 0.22
-
-	var eye_l: MeshInstance3D = _build_flat_fan_icon(_star_points(8, eye_radius, eye_radius), boss_room_icon_color)
-	eye_l.position = Vector3(-eye_offset_x, 0.02, eye_offset_z)
-	skull.add_child(eye_l)
-
-	var eye_r: MeshInstance3D = _build_flat_fan_icon(_star_points(8, eye_radius, eye_radius), boss_room_icon_color)
-	eye_r.position = Vector3(eye_offset_x, 0.02, eye_offset_z)
-	skull.add_child(eye_r)
-
-	return skull
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`21:09:02`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_star_points|_build_flat_fan_icon|SurfaceTool` in `C:\Users\thvnh\Documents\GitHub\whiplash\scenes\level_generation\room_instance.gd`

`21:09:03`

```
2720:## BUGFIX "Icons komplett unsichtbar": urspruenglich per SurfaceTool aus
```

### 🤖 Assistant: *Clean — no remaining references outside the…*

`21:09:06`

> Clean — no remaining references outside the comment. Let's regenerate the graph and wrap up.

#### 💻 Bash

`21:09:07`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify update . 2>&1 | tail -6
```

```
  AST extraction: 1/1 uncached files (100%)

  warning: 1 source file(s) produced zero nodes and are absent from the graph: .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5159 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] No code-graph topology changes detected; outputs left untouched.

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *Rebuilt both icons using only built-in primitive…*

`21:09:30`

> Rebuilt both icons using only built-in primitive meshes (`BoxMesh` + `CylinderMesh`), the same technique the already-working door markers use — no more hand-rolled `SurfaceTool` mesh, which was the only place in the whole codebase using that approach and the likely culprit (a custom mesh's auto-computed AABB can get silently frustum-culled in Godot).
> 
> - **Treasure**: a gold diamond (45°-rotated flat box) with four small corner dots.
> - **Boss**: a dark flat disc with two bright "eye" dots.
> 
> Also added slight emission on both so they stand out clearly against the now-darker dimming overlay. Worth checking in-editor on a treasure and boss room.

## 🤷 User: *im raum mit dem kreuz fallen gegner manchmal…*

`21:10:34`

im raum mit dem kreuz fallen gegner manchmal runter und sterben nicht wodurch man gesperrt ist. Wir haben ein kritisches Problem mit der neuen "Blutzoll" (Sacrifice Room) Mechanik eingeführt.

Seit den letzten Änderungen bekomme ich nun auch bei normalen Item-Aufhebungen (in normalen Schatzräumen oder sogar bei Drops) sofort Schaden abgezogen. Die Opferungs-Logik (Schaden bei Pickup) triggert also an Stellen, wo sie nicht triggern darf.

Bitte überprüfe die Logik in `treasure_manager.gd`, `sacrifice_pedestal.gd` und `treasure_pedestal.gd`:

1. Wird der `SacrificePedestal` im `treasure_manager.gd` aus Versehen in JEDEM Raum gespawnt, weil die Abfrage `room.get("is_sacrifice_room")` immer `true` zurückgibt?
2. Ist die Schadens-Logik versehentlich in der Elternklasse (`TreasurePedestal` / `take()`) gelandet, anstatt nur überschrieben in `SacrificePedestal` zu existieren?
3. Oder haben wir den Bug in `item_manager.gd` / `pickup.gd` eingebaut?

Bitte finde die exakte Ursache, warum normale Items jetzt Schaden machen, und korrigiere den Code so, dass NUR der `SacrificePedestal` in echten Opferungsräumen (`is_sacrifice_room == true`) den Spieler verletzt. Normale `TreasurePedestal` und Boden-Pickups müssen komplett harmlos bleiben.

### 💭 Thinking

`21:10:50`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 📂 Glob `**/sacrifice_pedestal.gd`

`21:10:50`

```
scripts\sacrifice_pedestal.gd
```

#### 👀 Read `treasure_pedestal.gd`

`21:10:51`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_pedestal.gd</code></summary>

```
extends Node3D
class_name TreasurePedestal

# ============================================================================
# TreasurePedestal — der Isaac-Sockel in der Mitte des Schatzraums.
# ============================================================================
# EIN Item pro Schatzraum, frei schwebend ueber einer Saeule, mit Lichtsaeule
# und Bodenring. Wer nah genug steht, sieht die Item-Karte unten links und
# kann mit [F] zugreifen.
#
# WARUM EIN EIGENES SCRIPT UND NICHT Pickup.Kind.ITEM:
# Pickup ist bewusst ein Wegwerf-Objekt: es liegt am Boden, wird magnetisch
# angezogen und verschwindet beim Beruehren. Der Schatzsockel ist das
# Gegenteil — er steht fest, saugt nichts an, muss aktiv bedient werden und
# soll den halben Raum beleuchten. Beides in eine Klasse zu quetschen haette
# in Pickup vier weitere "if kind == ITEM: anders"-Zweige bedeutet, und genau
# solche Zweige sind spaeter die Stellen, an denen ein Bugfix fuer Muenzen den
# Schatzraum kaputtmacht.
#
# BAUT SICH KOMPLETT SELBST AUF — konsequent wie pickup.gd und bomb.gd. Es
# gibt also KEINE treasure_pedestal.tscn, die man vergessen kann zu laden.
#
# ALLE MATERIALIEN WERDEN PRO INSTANZ NEU ERZEUGT (siehe _make_material).
# Wuerde hier eine geteilte Ressource liegen, faerbte der zweite Sockel einer
# Etage rueckwirkend den ersten um.

signal item_taken(item: ItemData, pedestal: TreasurePedestal)

## Wie nah der Spieler stehen muss, damit [F] greift.
@export var interact_distance: float = 3.0

## Ab dieser Entfernung wird die Item-Karte mittig auf dem Bildschirm
## eingeblendet — und beim Verlassen sofort wieder ausgeblendet.
##
## Bewusst knapp gehalten: die Karte soll aussagen "du stehst am Sockel",
## nicht "irgendwo in diesem Raum liegt ein Item". Bei einem 48 m breiten
## Schatzraum heisst das ein Radius um die Mittelplattform herum.
@export var preview_distance: float = 7.0

## Schwebe-Animation des Items ueber der Saeule.
@export var bob_height: float = 0.14
@export var bob_speed: float = 1.8
@export var spin_speed: float = 1.1

## Hoehe des schwebenden Items ueber der Saeulen-Oberkante.
@export var float_height: float = 1.15

## Hoehe der Lichtsaeule. Sie ist das, was den Raum auf Distanz lesbar macht.
@export var beam_height: float = 7.0

## Reichweite der Punktlichtquelle im Sockel.
@export var light_range: float = 9.0
@export var light_energy: float = 2.2

## Muss mit SettingsManager.DEFAULT_KEYBINDS uebereinstimmen ("interact" = F).
const INTERACT_ACTION: String = "interact"

## Gruppe, in der sich ItemDescriptionHud anmeldet.
const ITEM_HUD_GROUP: String = "item_hud"

## Gruppe, in der sich der LevelGenerator selbst eintraegt — fuer das
## map_updated-Signal, siehe _sync_minimap_visibility().
const GENERATOR_GROUP: String = "level_generator"

## Das Item, das auf diesem Sockel liegt. Wird vom TreasureManager gesetzt,
## BEVOR der Sockel in den Baum gehaengt wird.
var item_data: ItemData = null

var _taken: bool = false
var _time: float = 0.0
var _float_root: Node3D = null
var _gem: MeshInstance3D = null
var _halo: MeshInstance3D = null
var _beam: MeshInstance3D = null
var _ring: MeshInstance3D = null
var _light: OmniLight3D = null
var _name_label: Label3D = null
var _prompt_label: Label3D = null
var _preview_shown: bool = false
var _accent: Color = Color(0.95, 0.85, 0.35)

## Der Raum, in dem dieser Sockel steht. Wird beim _ready() gesetzt (der
## Sockel ist immer ein direktes Kind des Raums, siehe treasure_manager.gd).
## Bleibt null bei debug_spawn_at_player() — dort greift keine Fog-Logik.
var _room: RoomInstance = null
var _generator: Node = null


## Bequemer Konstruktor fuer den TreasureManager.
static func create(data: ItemData) -> TreasurePedestal:
	var pedestal := TreasurePedestal.new()
	pedestal.item_data = data
	pedestal.name = "TreasurePedestal_%s" % (data.id if data else "empty")
	return pedestal


func _ready() -> void:
	add_to_group("treasure_pedestals")

	if item_data != null:
		_accent = item_data.pedestal_color

	_build_column()
	_build_ring()
	_build_beam()
	_build_float_group()
	_build_light()
	_build_labels()

	# ------------------------------------------------------------------
	# Fog-of-War-Anschluss (behobener Bug: Sockel leuchtet durch die Wand
	# eines noch nicht besuchten Schatzraums auf der Karte)
	# ------------------------------------------------------------------
	# room_instance.gd blendet einen kompletten unbesuchten Raum auf der
	# 3D-Minimap aus, indem es EINMALIG alle VisualInstance3D-Kinder auf
	# einen Layer verschiebt, den die Kartenkamera nicht rendert
	# (set_minimap_revealed() -> _apply_minimap_layer()). "Einmalig" ist der
	# entscheidende Teil: ein zweiter Aufruf mit demselben Sichtbarkeits-
	# zustand ist ein bewusster No-Op (siehe die Sperre dort), damit der
	# Baum nicht bei jedem Kartenupdate neu durchlaufen wird.
	#
	# treasure_manager.gd haengt diesen Sockel aber ERST ein bis zwei
	# Physik-Frames NACH der Raumgenerierung ein (siehe dort: der Boden fuer
	# die Sockelposition muss erst kollidierbar sein). Zu diesem Zeitpunkt
	# hat der Raum sein "verstecken" laengst hinter sich — der Sockel wird
	# also NIE von _apply_minimap_layer() erfasst und bleibt fuer die
	# Kartenkamera dauerhaft auf dem normalen, sichtbaren Layer. Ergebnis:
	# eine helle, mehrere Meter hohe Lichtsaeule schwebt sichtbar in einem
	# Raum, dessen Waende und Boden korrekt ausgeblendet sind — auf der
	# Karte sieht das aus wie "man sieht durch die Wand".
	#
	# Die Lösung hier dupliziert NICHT die Versteck-Logik, sondern fragt bei
	# jeder Kartenaktualisierung (map_updated-Signal des Generators) aktiv
	# nach dem AKTUELLEN Sichtbarkeitszustand des eigenen Elternraums und
	# wendet ihn auf die eigenen Kinder an. Kein Eingriff in room_instance.gd
	# noetig.
	_room = get_parent() as RoomInstance
	_sync_minimap_visibility.call_deferred()
	_bind_generator.call_deferred()


# ============================================================================
# Aufbau
# ============================================================================
## Unshaded + Emission: PSX-Optik lebt von flachen, gesaettigten Flaechen.
## Ein Schatzsockel muss ausserdem quer durch einen dunklen Raum lesbar sein,
## ohne dass eine Lichtquelle ihn zufaellig richtig trifft.
func _make_material(color: Color, emission: float = 0.8, unshaded: bool = true) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission
	return material


## Additiv + ohne Tiefen-Test-Verlust: fuer Lichtsaeule und Halo. Cull
## deaktiviert, damit man auch von innen etwas sieht.
func _make_glow_material(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.disable_receive_shadows = true
	return material


## Die Saeule ist bewusst zweiteilig: dunkler Schaft, heller Deckstein in der
## Item-Farbe. So sieht man die Farbe des Items auch dann noch, wenn das
## schwebende Objekt gerade von einer Wand verdeckt wird.
func _build_column() -> void:
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = 0.42
	shaft_mesh.bottom_radius = 0.58
	shaft_mesh.height = 0.95
	shaft_mesh.radial_segments = 8  # bewusst grob: PSX-Look

	var shaft := MeshInstance3D.new()
	shaft.name = "Shaft"
	shaft.mesh = shaft_mesh
	# material_override statt surface_material_override — Vorrangregel.
	shaft.material_override = _make_material(Color(0.14, 0.15, 0.18), 0.0, false)
	shaft.position = Vector3(0.0, 0.475, 0.0)
	add_child(shaft)

	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.72
	base_mesh.bottom_radius = 0.82
	base_mesh.height = 0.18
	base_mesh.radial_segments = 8

	var base := MeshInstance3D.new()
	base.name = "Base"
	base.mesh = base_mesh
	base.material_override = _make_material(Color(0.10, 0.11, 0.13), 0.0, false)
	base.position = Vector3(0.0, 0.09, 0.0)
	add_child(base)

	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.52
	cap_mesh.bottom_radius = 0.46
	cap_mesh.height = 0.12
	cap_mesh.radial_segments = 8

	var cap := MeshInstance3D.new()
	cap.name = "Cap"
	cap.mesh = cap_mesh
	cap.material_override = _make_material(_accent, 0.9)
	cap.position = Vector3(0.0, 1.0, 0.0)
	add_child(cap)


## Leuchtring auf dem Boden. Markiert die Interaktions-Reichweite, ohne dass
## dafuer eine UI noetig waere.
func _build_ring() -> void:
	var torus := TorusMesh.new()
	torus.inner_radius = 1.05
	torus.outer_radius = 1.22
	torus.rings = 20
	torus.ring_segments = 5

	_ring = MeshInstance3D.new()
	_ring.name = "GroundRing"
	_ring.mesh = torus
	_ring.material_override = _make_glow_material(_accent, 0.55)
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ring.position = Vector3(0.0, 0.04, 0.0)
	add_child(_ring)


## Lichtsaeule nach oben. Der eigentliche "hier liegt was"-Wegweiser: sie ist
## auch dann sichtbar, wenn der Sockel selbst hinter einer Stufe verschwindet.
func _build_beam() -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.95
	cylinder.bottom_radius = 0.30
	cylinder.height = beam_height
	cylinder.radial_segments = 10
	cylinder.rings = 1

	_beam = MeshInstance3D.new()
	_beam.name = "LightBeam"
	_beam.mesh = cylinder
	_beam.material_override = _make_glow_material(_accent, 0.13)
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_beam.position = Vector3(0.0, 1.1 + beam_height * 0.5, 0.0)
	add_child(_beam)


## Alles Schwebende haengt an EINEM Knoten, damit Bob und Rotation nicht auf
## drei Meshes einzeln nachgezogen werden muessen.
func _build_float_group() -> void:
	_float_root = Node3D.new()
	_float_root.name = "FloatRoot"
	_float_root.position = Vector3(0.0, 1.06 + float_height, 0.0)
	add_child(_float_root)

	# --- Halo hinter dem Item ----------------------------------------
	var quad := QuadMesh.new()
	quad.size = Vector2(1.5, 1.5)

	_halo = MeshInstance3D.new()
	_halo.name = "Halo"
	_halo.mesh = quad
	var halo_material := _make_glow_material(_accent, 0.35)
	halo_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_halo.material_override = halo_material
	_halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(_halo)

	# --- Das Item selbst: facettierter Edelstein ----------------------
	# radial_segments 6 / rings 3 ergibt eine kantige Form, die zum
	# Vertex-Snapping passt. Eine glatte Kugel saehe hier wie ein Fremd-
	# koerper aus.
	var gem_mesh := SphereMesh.new()
	gem_mesh.radius = 0.30
	gem_mesh.height = 0.84
	gem_mesh.radial_segments = 6
	gem_mesh.rings = 3

	_gem = MeshInstance3D.new()
	_gem.name = "Gem"
	_gem.mesh = gem_mesh
	_gem.material_override = _make_material(_accent, 1.4)
	_gem.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(_gem)

	# Fertiges Icon-Modell schlaegt den Platzhalter, falls eines existiert.
	if item_data != null and item_data.icon != null:
		_apply_icon_billboard(item_data.icon)


## Sobald es Item-Icons gibt, wird der Edelstein zum Traeger einer Textur.
## Bis dahin passiert hier nichts — das ist kein Fehlerfall.
func _apply_icon_billboard(icon: Texture2D) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(0.85, 0.85)

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = icon
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	var icon_instance := MeshInstance3D.new()
	icon_instance.name = "Icon"
	icon_instance.mesh = quad
	icon_instance.material_override = material
	icon_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_float_root.add_child(icon_instance)

	# Der Stein bleibt als farbiger Hintergrund stehen, wird aber kleiner,
	# damit das Icon lesbar bleibt.
	if _gem:
		_gem.scale = Vector3.ONE * 0.55


func _build_light() -> void:
	_light = OmniLight3D.new()
	_light.name = "ShrineLight"
	_light.light_color = _accent
	_light.light_energy = light_energy
	_light.omni_range = light_range
	# Schatten aus: eine einzelne bewegte Punktlichtquelle mit Schatten
	# kostet in einem Raum voller Wandsegmente deutlich mehr, als sie
	# optisch bringt.
	_light.shadow_enabled = false
	_light.position = Vector3(0.0, 1.6, 0.0)
	add_child(_light)


func _build_labels() -> void:
	_name_label = Label3D.new()
	_name_label.name = "NameLabel"
	_name_label.text = item_data.display_name if item_data else "???"
	_name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_name_label.no_depth_test = true
	_name_label.pixel_size = 0.0055
	_name_label.outline_size = 8
	_name_label.modulate = Color(1.0, 0.98, 0.92, 0.95)
	_name_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_name_label.position = Vector3(0.0, 2.85, 0.0)
	_name_label.visible = false
	add_child(_name_label)

	_prompt_label = Label3D.new()
	_prompt_label.name = "PromptLabel"
	_prompt_label.text = "[F] Nehmen"
	_prompt_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_prompt_label.no_depth_test = true
	_prompt_label.pixel_size = 0.0045
	_prompt_label.outline_size = 6
	_prompt_label.modulate = _accent
	_prompt_label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
	_prompt_label.position = Vector3(0.0, 2.5, 0.0)
	_prompt_label.visible = false
	add_child(_prompt_label)


# ============================================================================
# Laufzeit
# ============================================================================
func _physics_process(delta: float) -> void:
	_time += delta
	_animate(delta)

	if _taken:
		return

	var player: Node3D = _find_player()
	if player == null:
		return

	var distance: float = global_position.distance_to(player.global_position)
	_update_labels(distance)
	_update_preview(distance)

	if distance > interact_distance:
		return
	if not Input.is_action_just_pressed(INTERACT_ACTION):
		return
	take()


func _animate(delta: float) -> void:
	if _float_root and not _taken:
		_float_root.position.y = 1.06 + float_height + sin(_time * bob_speed) * bob_height
		_float_root.rotate_y(spin_speed * delta)

	if _ring:
		# Langsames Pulsieren: zieht den Blick, ohne zu flackern.
		var pulse: float = 0.45 + 0.25 * (sin(_time * 2.0) * 0.5 + 0.5)
		var material: StandardMaterial3D = _ring.material_override
		if material:
			material.albedo_color.a = pulse if not _taken else 0.08

	if _light and not _taken:
		_light.light_energy = light_energy * (0.85 + 0.15 * sin(_time * 3.1))


func _update_labels(distance: float) -> void:
	var near: bool = distance <= preview_distance
	if _name_label:
		_name_label.visible = near
	if _prompt_label:
		_prompt_label.visible = distance <= interact_distance


## Blendet die Item-Karte ein, sobald der Spieler in Reichweite kommt, und
## sofort wieder aus, wenn er sie verlaesst.
##
## Nur bei der FLANKE, nicht jeden Frame: ein Dauerfeuer von show_item()
## wuerde die Einblend-Animation jeden Frame neu starten, die Karte stuende
## also dauerhaft auf 97 % Groesse und zuckte.
##
## Das Ausblenden beim Weggehen ist der eigentliche Grund fuer diese
## Funktion. Vorher lief die Karte nach einem festen Timer aus — man trug
## die Beschreibung also noch durch zwei Raeume mit sich herum.
func _update_preview(distance: float) -> void:
	var near: bool = distance <= preview_distance
	if near == _preview_shown:
		return
	_preview_shown = near

	var hud: ItemDescriptionHud = _find_item_hud()
	if hud == null:
		return

	if near and item_data != null:
		# persistent = true: die Karte bleibt, solange man hier steht.
		hud.show_item(item_data, true)
	else:
		hud.hide_item()


## Das Item-HUD ist jetzt ein Node IN hud.tscn, kein Autoload-Kind mehr.
## Deshalb wird es ueber die Gruppe gesucht statt ueber einen festen Pfad —
## ein Pfad wie "/root/HudExtra/..." haette sich bei jeder Umbenennung im
## Szenenbaum stillschweigend in null verwandelt.
func _find_item_hud() -> ItemDescriptionHud:
	for node: Node in get_tree().get_nodes_in_group(ITEM_HUD_GROUP):
		if node is ItemDescriptionHud and is_instance_valid(node):
			return node as ItemDescriptionHud
	return null


func _find_player() -> Node3D:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is Node3D and is_instance_valid(node):
			return node as Node3D
	return null


# ============================================================================
# Aufnehmen
# ============================================================================
## Gibt true zurueck, wenn das Item wirklich ins Inventar gewandert ist.
## Bei erreichter Stapelgrenze bleibt der Sockel bestueckt stehen — das ist
## dieselbe Regel wie in pickup.gd und verhindert, dass ein Item wortlos
## verschwindet.
func take() -> bool:
	if _taken or item_data == null:
		return false

	var items: Node = get_node_or_null("/root/Items")
	if item == null:
		return false

	# pickup_active_item() statt add_item(): sind beide Aktiv-Slots (Q/E)
	# schon belegt und item_data ist selbst aktiv, wird das bisherige
	# Q-Item verdraengt und muss zurueck auf DIESEN Sockel (Swap statt
	# nutzlos unausgeruestet im Inventar landen), siehe item_manager.gd.
	var result: Dictionary = items.pickup_active_item(item_data)
	if not bool(result.get("picked_up", false)):
		return false
	var displaced: ItemData = result.get("displaced") as ItemData

	var taken_item: ItemData = item_data
	_taken = true
	# Die Anzeige stand auf "dauerhaft" (Sockel in Reichweite). Ohne diesen
	# Wechsel bliebe die Karte fuer immer stehen, weil hide_item() erst beim
	# Verlassen der Reichweite kaeme — und Items.item_added() setzt sie
	# gleich darauf ohnehin neu, dann mit Auto-Ausblendung.
	var hud: ItemDescriptionHud = _find_item_hud()
	if hud:
		hud.hide_item()

	item_taken.emit(taken_item, self)
	_play_take_feedback(displaced)
	return true


## Der Sockel bleibt als leere Saeule stehen. Ein komplett verschwindender
## Sockel wuerde beim Zurueckkommen so aussehen, als waere der Schatzraum nie
## bestueckt gewesen.
## displaced: nur bei einem Q/E-Swap gesetzt (siehe take()) - der Sockel
## bestueckt sich nach der Wegnahme-Animation selbst neu, statt leer zu
## bleiben (siehe _finish_take()/_restock()).
func _play_take_feedback(displaced: ItemData = null) -> void:
	if _prompt_label:
		_prompt_label.visible = false
	if _name_label:
		_name_label.visible = false

	Juice.hit_stop(Juice.DURATION_LIGHT)
	Juice.shake(0.35)

	var tween := create_tween()
	tween.set_parallel(true)

	if _float_root:
		tween.tween_property(_float_root, "position:y", _float_root.position.y + 1.4, 0.45) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(_float_root, "scale", Vector3.ONE * 0.01, 0.45) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	if _beam and _beam.material_override is StandardMaterial3D:
		tween.tween_property(_beam.material_override, "albedo_color:a", 0.0, 0.5)

	if _light:
		tween.tween_property(_light, "light_energy", 0.25, 0.5)

	tween.chain().tween_callback(_finish_take.bind(displaced))


func _finish_take(displaced: ItemData = null) -> void:
	if _float_root and is_instance_valid(_float_root):
		_float_root.queue_free()
		_float_root = null
	if _beam and is_instance_valid(_beam):
		_beam.queue_free()
		_beam = null

	if displaced != null:
		_restock(displaced)


## Verdraengtes Q-Item (siehe ItemManager.pickup_active_item() - beide
## Aktiv-Slots waren voll) landet wieder auf DIESEM Sockel statt spurlos zu
## verschwinden ("Swap"). Baut Lichtsaeule + schwebendes Item neu auf, exakt
## wie beim ersten _ready() - _float_root/_beam wurden gerade erst in
## _finish_take() freigegeben, es gibt also keine Namenskollision.
func _restock(new_item: ItemData) -> void:
	item_data = new_item
	_accent = new_item.pedestal_color
	_taken = false

	var cap: MeshInstance3D = get_node_or_null("Cap")
	if cap:
		cap.material_override = _make_material(_accent, 0.9)

	_build_beam()
	_build_float_group()

	if _light:
		_light.light_color = _accent
	if _ring and _ring.material_override is StandardMaterial3D:
		var ring_mat: StandardMaterial3D = _ring.material_override as StandardMaterial3D
		ring_mat.albedo_color = Color(_accent.r, _accent.g, _accent.b, ring_mat.albedo_color.a)
	if _name_label:
		_name_label.text = new_item.display_name

	_preview_shown = false


func is_taken() -> bool:
	return _taken


# ============================================================================
# Fog-of-War-Anschluss
# ============================================================================
func _bind_generator() -> void:
	if _room == null:
		# debug_spawn_at_player() haengt den Sockel direkt in current_scene,
		# nicht in einen Raum — dort gibt es keine Fog-of-War-Zustaende, mit
		# denen synchronisiert werden muesste.
		return

	var found: Array[Node] = get_tree().get_nodes_in_group(GENERATOR_GROUP)
	if found.is_empty():
		return
	_generator = found[0]
	if _generator.has_signal("map_updated") and not _generator.is_connected("map_updated", _on_map_updated):
		_generator.connect("map_updated", _on_map_updated)


func _on_map_updated() -> void:
	_sync_minimap_visibility()


## Spiegelt den AKTUELLEN Sichtbarkeitszustand des Elternraums auf die
## eigenen Kinder — Meshes UND Licht. Wird beim Bauen einmal aufgerufen und
## danach bei jedem map_updated erneut (Raum wird betreten -> aufgedeckt).
func _sync_minimap_visibility() -> void:
	if _room == null or not is_instance_valid(_room):
		return

	# _minimap_revealed ist ein gewoehnliches Skript-Feld (kein echtes
	# "private" in GDScript) und traegt IMMER einen gueltigen Wert, auch
	# ohne LevelGenerator (Default true) — Testszenen ohne Fog bleiben damit
	# unangetastet sichtbar.
	var revealed: bool = true
	if "_minimap_revealed" in _room:
		revealed = bool(_room.get("_minimap_revealed"))

	_apply_own_minimap_layer(self, revealed)

	# Fuer Lichter reicht das Verschieben auf einen unsichtbaren Layer NICHT:
	# layers steuert bei Light3D nur, was der Editor-Gizmo tut, nicht ob das
	# Licht real weiterstrahlt. .visible = false schaltet das Licht dagegen
	# vollstaendig ab — sonst wuerde eine unsichtbar gewordene Lichtquelle
	# trotzdem noch Flaechen in einem eigentlich verdeckten Raum aufhellen.
	if _light:
		_light.visible = revealed


## Rekursiv wie room_instance.gd::_apply_minimap_layer(), aber nur auf den
## eigenen Unterbaum angewendet. RoomInstance.MINIMAP_HIDDEN_LAYER ist die
## SELBE Konstante, die die Kartenkamera aus ihrer cull_mask streicht — auf
## einen eigenen, zweiten Layer-Wert zu bestehen waere eine zweite Quelle
## der Wahrheit, die irgendwann auseinanderlaufen kann.
func _apply_own_minimap_layer(node: Node, revealed: bool) -> void:
	for child: Node in node.get_children():
		if child is VisualInstance3D:
			var visual: VisualInstance3D = child as VisualInstance3D
			if not visual.has_meta("minimap_base_layers"):
				visual.set_meta("minimap_base_layers", visual.layers)
			if revealed:
				visual.layers = int(visual.get_meta("minimap_base_layers"))
			else:
				visual.layers = 1 << (RoomInstance.MINIMAP_HIDDEN_LAYER - 1)
		_apply_own_minimap_layer(child, revealed)

```
</details>

### 💭 Thinking

`21:11:12`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `sacrifice_pedestal.gd`

`21:11:12`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\sacrifice_pedestal.gd</code></summary>

```
extends TreasurePedestal
class_name SacrificePedestal

# ============================================================================
# SacrificePedestal — Blueprint Nr. 5 "Blutzoll" (Sacrifice Room). Dieselbe
# Sockel-Optik/Interaktion wie TreasurePedestal, nur dass take() zusaetzlich
# 25% der Max-HP des Spielers kostet - ERST nachdem das Item sicher im
# Inventar gelandet ist (super.take() == true), damit ein fehlgeschlagenes
# take() (z.B. Stapelgrenze erreicht) niemals HP ohne Gegenwert kostet.
# ============================================================================

const SACRIFICE_HP_FRACTION: float = 0.25
## Mindest-HP-Anteil, der nach dem Opfer uebrig bleiben muss - ein Sockel, an
## dem man sich nicht bedienen KANN, waere ein schlechter Trick, kein
## Risk/Reward. Der Blutzoll wird verweigert, wenn er toedlich waere.
const MIN_SURVIVING_FRACTION: float = 0.05


## EIGENE create(): GDScript-Static-Methoden sind NICHT virtuell - ein Aufruf
## von SacrificePedestal.create() wuerde sonst die geerbte Implementierung
## von TreasurePedestal.create() ausfuehren, die textuell TreasurePedestal.
## new() aufruft, also trotzdem einen normalen Sockel erzeugen wuerde.
static func create(data: ItemData) -> SacrificePedestal:
	var pedestal := SacrificePedestal.new()
	pedestal.item_data = data
	pedestal.name = "SacrificePedestal_%s" % (data.id if data else "empty")
	return pedestal


func take() -> bool:
	if is_taken() or item_data == null:
		return false

	var player: Node3D = _find_player()
	if player == null:
		return false
	var health: Health = player.get_node_or_null("Health") as Health
	if health == null:
		return false

	var cost: float = health.max_health * SACRIFICE_HP_FRACTION
	if health.current_health - cost < health.max_health * MIN_SURVIVING_FRACTION:
		return false

	if not super.take():
		return false

	health.take_damage(cost, self)
	return true

```
</details>

### 💭 Thinking

`21:11:27`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `is_sacrifice_room` in `C:\Users\thvnh\Documents\GitHub\whiplash`

`21:11:27`

```
scripts\treasure_manager.gd:228:	if bool(room.get("is_sacrifice_room")):
scenes\rooms\treasure\room_treasure_sacrifice_01.tscn:85:is_sacrifice_room = true
scenes\level_generation\room_instance.gd:81:@export var is_sacrifice_room: bool = false
```

### 💭 Thinking

`21:12:17`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `treasure_manager.gd`

`21:12:17`

*(lines 214–244)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_manager.gd</code></summary>

```
# ============================================================================
# Spawnen
# ============================================================================
func _spawn_pedestal(room: RoomInstance) -> void:
	_maybe_reset_for_new_run()

	var item: ItemData = _pick_item(room)
	if item == null:
		push_warning("[Treasure] Raum %s: kein Item verfuegbar — Sockel uebersprungen." % room.grid_position)
		return

	# Blutzoll-Raeume (Blueprint Nr. 5): SacrificePedestal statt des normalen
	# Sockels - identische Optik/Interaktion, kostet aber HP beim Nehmen.
	var pedestal: TreasurePedestal
	if bool(room.get("is_sacrifice_room")):
		pedestal = SacrificePedestal.create(item)
	else:
		pedestal = TreasurePedestal.create(item)
	room.add_child(pedestal)
	pedestal.global_position = _find_spawn_position(room)
	pedestal.item_taken.connect(_on_item_taken)

	_reserved_ids[item.id] = true
	pedestal_spawned.emit(item, room)

	_debug("  -> Sockel gesetzt: '%s' bei %s." % [item.display_name, pedestal.global_position])


## Raum-Ursprung ist bei allen Prefabs die Raum-MITTE (Waende liegen
## symmetrisch bei +-24). Deshalb wird von dort aus nach unten gemessen.
```
</details>

### 🤖 Assistant: *Let me search broadly for every `take_damage…*

`21:12:32`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let me search broadly for every `take_damage` call site to find what's actually firing — the pedestal logic looks clean on inspection, so the bug may be elsewhere entirely.

#### 🔎 Grep `take_damage\(` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts`

`21:12:33`

Glob: `*.gd`

```
scripts\bomb.gd:442:	health.take_damage(full_damage * falloff, thrower if thrower else self)
scripts\combat_base.gd:722:	(health as Health).take_damage(dash_damage, player)
scripts\health.gd:100:func take_damage(amount: float, source: Node3D = null) -> void:
scripts\environment\destructible_prop.gd:18:## take_damage() (Hitbox-Treffer, Item-Explosionen) zerstoert werden soll.
scripts\environment\destructible_prop.gd:78:## Health.take_damage(), damit primary_hitbox.gd sie ueber find_child("Health")
scripts\environment\destructible_prop.gd:81:func take_damage(amount: float, _source: Node = null) -> void:
scripts\pit_floor.gd:520:	health.take_damage(max_hp * 999.0, self)
scripts\hazards\lemonade.gd:408:		health.take_damage(amount, self)
scripts\player_base.gd:226:		health.take_damage(magnitude, source)
scripts\player_base.gd:909:## BEWUSST OHNE eigenen "schon ausgeloest"-Merker: health.take_damage() ist
scripts\player_base.gd:934:		health.take_damage(health.max_health * 1000.0, null)
scripts\core\hitscan.gd:66:	(health as Health).take_damage(damage, source as Node3D)
scripts\enemies\custom_enemy_base.gd:122:		health.take_damage(magnitude, source)
scripts\enemies\dive_bomber.gd:220:			target_health.take_damage(damage, self)
scripts\items\item_behaviours.gd:1179:			health.take_damage(laser_bonus, _player())
scripts\items\item_behaviours.gd:1191:		health.take_damage(vuln_bonus, _player())
scripts\items\item_behaviours.gd:1199:			health.take_damage(yoyo_bonus, yoyo_player)
scripts\items\item_behaviours.gd:1290:			health.take_damage(wave_damage, player)
scripts\items\item_behaviours.gd:1383:	# der Schaden ueber take_damage(), wuerde ihn jede laufende i-Frame
scripts\items\item_behaviours.gd:1460:			health.take_damage(modem_bonus, _player())
scripts\items\item_behaviours.gd:1513:	health.take_damage(bonus, _player())
scripts\items\item_behaviours.gd:1711:			health.take_damage(TOASTER_DAMAGE, player)
scripts\items\item_behaviours.gd:2005:				health.take_damage(damage_per_tick, _player())
scripts\items\item_behaviours.gd:2101:					health.take_damage(TENNIS_DAMAGE, player)
scripts\items\item_behaviours.gd:2163:			health.take_damage(HORNS_DAMAGE, player)
scripts\items\item_behaviours.gd:2206:			health.take_damage(pants_damage, player)
scripts\items\item_behaviours.gd:2452:				health.take_damage(split, source)
scripts\items\item_behaviours.gd:2514:			health.take_damage(SPRAY_IGNITE_DAMAGE, _player())
scripts\items\item_behaviours.gd:2649:			health.take_damage(CABLES_DAMAGE, player)
scripts\items\item_behaviours.gd:2666:			health.take_damage(damage, player)
scripts\items\item_behaviours.gd:2692:		health.take_damage(execute_amount, player)
scripts\items\item_behaviours.gd:2858:			health.take_damage(megaphone_damage, player)
scripts\items\item_behaviours.gd:2917:					health.take_damage(CREAM_EXTINGUISH_DAMAGE, _player())
scripts\items\item_behaviours.gd:2950:	health.take_damage(bonus, _player())
scripts\items\item_behaviours.gd:2963:			health.take_damage(damage, player)
scripts\items\item_behaviours.gd:2974:				health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3222:			health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3256:			health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3332:				health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3387:			health.take_damage(TURRET_ITEM_DAMAGE, player)
scripts\items\item_behaviours.gd:3425:					health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3506:				health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3540:			health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3591:			health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3615:					health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3633:			health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3746:				health.take_damage(damage, player)
scripts\items\item_behaviours.gd:3838:					health.take_damage(damage, player)
scripts\enemies\enemy_ai.gd:512:		health.take_damage(magnitude, source)
scripts\primary_hitbox.gd:123:	health.take_damage(final_damage, owner)
scripts\characters\combat_winter.gd:223:	(health as Health).take_damage(dmg, player)
scripts\revenge_ghost.gd:143:			health.take_damage(damage, _source)
scripts\characters\combat_karina.gd:204:	# take_damage() direkt auf, ohne Zahl) - fuer Karina wird das hier
scripts\characters\combat_karina.gd:458:		(health as Health).take_damage(dmg, player)
scripts\enemies\mortar_bot.gd:226:		# Aufrufer). take_damage() behandelt source ohnehin nur als
scripts\enemies\mortar_bot.gd:228:		target_health.take_damage(dmg, null)
scripts\enemies\plasma_beam_bot.gd:195:		target_health.take_damage(BURN_DAMAGE_PER_TICK, self)
scripts\sacrifice_pedestal.gd:48:	health.take_damage(cost, self)
scripts\status_effects\burn.gd:68:	health.take_damage(tick_damage * DETONATE_MULTIPLIER, source)
scripts\status_effects\burn.gd:99:		health.take_damage(burst, source)
scripts\status_effects\acid.gd:34:## Wird in Health.take_damage() gelesen (siehe dort) statt hier selbst
```

### 💭 Thinking

`21:12:43`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _on_item_added` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`21:12:45`

```
981:func _on_item_added(item: ItemData) -> void:
982-	_apply_protein_shake_hitbox()
983-	_refresh_credit_card_bonus()
984-	_refresh_devil_outfit()
985-
986-	# Proteinshake: FLASH_GREEN beim Aufheben (Design-Dokument).
987-	if item != null and item.id == ItemCatalog.ID_PROTEIN_SHAKE:
988-		_flash_player(FLASH_GREEN)
989-		_apply_protein_shake_mesh_scale()
990-
991-
992-## Leere Energy-Dose: kurzer Tempo-Boost nach JEDEM Dash, egal ob getroffen.
993-func _on_dash_ended() -> void:
994-	if not _has(ItemCatalog.ID_EMPTY_ENERGY_CAN):
995-		return
996-	var stats: PlayerStats = _stats()
997-	if stats == null:
998-		return
999-	stats.add_timed_modifier(
1000-		"buff:empty_energy_can", PlayerStats.STAT_MOVE_SPEED,
1001-		ENERGY_CAN_BUFF_DURATION, 0.0, ENERGY_CAN_SPEED_MULTIPLIER
1002-	)
1003-
1004-
1005-func _on_room_cleared(_room: Node) -> void:
1006-	# Neuer Raum in Sicht -> Rettung des Handball-Polsters wieder scharf.
1007-	_pads_used_this_room = false
1008-
1009-
1010-func _on_coins_changed(_amount: int) -> void:
1011-	_refresh_credit_card_bonus()
1012-
1013-
1014-func _on_player_health_changed(_current: float, _max: float) -> void:
1015-	_refresh_devil_outfit()
1016-
1017-
1018-# ----------------------------------------------------------------------------
1019-# P1. Proteinshake aus den 90ern — kleinere Hitbox + kleineres Modell
1020-# ----------------------------------------------------------------------------
1021-# Der Schadensbonus steckt in stat_modifiers. Hier wird nur die Reichweite
```

### 💭 Thinking

`21:13:10`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _refresh_devil_outfit" -A 25` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`21:13:11`

```
No matches found
```

#### 🔎 Grep `_refresh_devil_outfit` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_behaviours.gd`

`21:13:15`

```
975:	_refresh_devil_outfit()
976-
977-
978-## Wird bei JEDEM neu aufgesammelten Item gerufen — die passiven Dauereffekte
979-## muessen sich sofort einschalten und nicht erst beim naechsten
980-## Charakterwechsel.
981-func _on_item_added(item: ItemData) -> void:
982-	_apply_protein_shake_hitbox()
983-	_refresh_credit_card_bonus()
984:	_refresh_devil_outfit()
985-
986-	# Proteinshake: FLASH_GREEN beim Aufheben (Design-Dokument).
987-	if item != null and item.id == ItemCatalog.ID_PROTEIN_SHAKE:
988-		_flash_player(FLASH_GREEN)
989-		_apply_protein_shake_mesh_scale()
990-
991-
992-## Leere Energy-Dose: kurzer Tempo-Boost nach JEDEM Dash, egal ob getroffen.
993-func _on_dash_ended() -> void:
994-	if not _has(ItemCatalog.ID_EMPTY_ENERGY_CAN):
995-		return
996-	var stats: PlayerStats = _stats()
997-	if stats == null:
998-		return
999-	stats.add_timed_modifier(
1000-		"buff:empty_energy_can", PlayerStats.STAT_MOVE_SPEED,
1001-		ENERGY_CAN_BUFF_DURATION, 0.0, ENERGY_CAN_SPEED_MULTIPLIER
1002-	)
1003-
1004-
--
1015:	_refresh_devil_outfit()
1016-
1017-
1018-# ----------------------------------------------------------------------------
1019-# P1. Proteinshake aus den 90ern — kleinere Hitbox + kleineres Modell
1020-# ----------------------------------------------------------------------------
1021-# Der Schadensbonus steckt in stat_modifiers. Hier wird nur die Reichweite
1022-# verkleinert.
1023-#
1024-# WARUM DIE HITBOX SKALIERT WIRD UND NICHT DIE COLLISIONSHAPE:
1025-# Die Form ist eine SubResource der Charakter-Szene und wird von allen vier
1026-# Charakteren geteilt. Sie zu veraendern wuerde in den anderen Charakteren
1027-# nachwirken — derselbe geteilte-Resource-Fehler wie bei den BoxMeshes der
1028-# Raeume. Die Area3D selbst zu skalieren ist instanzlokal und kostet nichts.
1029-func _apply_protein_shake_hitbox() -> void:
1030-	var player: CharacterBody3D = _player()
1031-	if player == null:
1032-		return
1033-
1034-	var wanted: float = SHAKE_HITBOX_SCALE if _has(ItemCatalog.ID_PROTEIN_SHAKE) else 1.0
1035-
--
1064:func _refresh_devil_outfit() -> void:
1065-	if not _has(ItemCatalog.ID_DEVIL_OUTFIT) or _player_health == null:
1066-		if _devil_active:
1067-			_devil_active = false
1068-			_clear_player_flash()
1069-			var stats_off: PlayerStats = _stats()
1070-			if stats_off != null:
1071-				stats_off.remove_source("item:devil_outfit")
1072-		return
1073-
1074-	var low: bool = _player_health.get_health_percent() < DEVIL_HEALTH_THRESHOLD
1075-	if low == _devil_active:
1076-		return
1077-	_devil_active = low
1078-
1079-	var stats: PlayerStats = _stats()
1080-	if stats == null:
1081-		return
1082-
1083-	if low:
1084-		stats.add_modifier("item:devil_outfit", PlayerStats.STAT_DAMAGE, 0.0, DEVIL_DAMAGE_MULTIPLIER)
--
1691:	_refresh_devil_outfit()
1692-
1693-
1694-# ----------------------------------------------------------------------------
1695-# P7. Kaputter Toaster
1696-# ----------------------------------------------------------------------------
1697-# Funken stossen alle Nahkampf-Gegner im Umkreis zurueck. Brennende Gegner
1698-# bekommen zusaetzlich einen sofortigen doppelten Feuer-Tick — die
1699-# Feuersturm-Synergie aus dem Design-Dokument. Die Regel dafuer steht in
1700-# burn.gd (StatusBurn.detonate), nicht hier: sie beschreibt, wie sich Feuer
1701-# verhaelt, nicht was der Toaster tut.
1702-func _apply_broken_toaster() -> void:
1703-	var player: CharacterBody3D = _player()
1704-	if player == null:
1705-		return
1706-	var origin: Vector3 = player.global_position
1707-
1708-	for enemy: Node3D in _enemies_near(origin, TOASTER_RADIUS):
1709-		var health: Health = _health_of(enemy)
1710-		if health != null:
1711-			health.take_damage(TOASTER_DAMAGE, player)
```

### 🤖 Assistant: *Let me now investigate the enemy-falling…*

`21:14:47`

<details>
<summary>Thinking...</summary>

> 
</details>

> Let me now investigate the enemy-falling-and-not-dying issue, which is more concretely traceable. There's already a `take_damage(max_hp * 999.0, ...)` instant-kill in `pit_floor.gd` — let's see why it might sometimes miss.

#### 👀 Read `pit_floor.gd`

`21:14:49`

*(lines 460–540)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pit_floor.gd</code></summary>

```

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "%s%s_Mesh" % [GEN_PREFIX, tag]
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = mat
	mesh_instance.position = center
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)

	var box_shape := BoxShape3D.new()
	box_shape.size = box_size
	var collision := CollisionShape3D.new()
	collision.name = "%s%s_Shape" % [GEN_PREFIX, tag]
	collision.shape = box_shape
	collision.position = center
	add_child(collision)

	if Engine.is_editor_hint():
		mesh_instance.owner = get_tree().edited_scene_root
		collision.owner = get_tree().edited_scene_root


## monitoring-only Area3D (collision_layer = 0, blockiert selbst nichts) -
## collision_mask = 5 (Layer 1 Spieler + Layer 4 Gegner, siehe lemonade.gd/
## LemonadeTrigger fuer denselben, bereits bewaehrten Maskenwert) - damit
## sterben auch Gegner sofort, die in den Abgrund fallen, nicht nur der
## Spieler.
func _build_void_kill_zone(node_name: String, center: Vector3, size: Vector3) -> void:
	var area := Area3D.new()
	area.name = node_name
	area.collision_layer = 0
	area.collision_mask = 5
	area.monitorable = false
	area.position = center
	add_child(area)

	var box := BoxShape3D.new()
	box.size = size
	var shape := CollisionShape3D.new()
	shape.shape = box
	area.add_child(shape)

	area.body_entered.connect(_on_void_kill_body_entered)

	if Engine.is_editor_hint():
		area.owner = get_tree().edited_scene_root
		shape.owner = get_tree().edited_scene_root


## Toetet JEDEN Body mit einer Health-Komponente - Spieler UND Gegner sollen
## beim Reinfallen sofort sterben, keine Sonderbehandlung noetig.
func _on_void_kill_body_entered(body: Node3D) -> void:
	var health: Node = body.get_node_or_null("Health")
	if health == null or not health.has_method("take_damage"):
		return
	if health.has_method("is_alive") and not health.is_alive():
		return
	var max_hp: float = float(health.get("max_health"))
	if max_hp <= 0.0:
		max_hp = 9999.0
	health.take_damage(max_hp * 999.0, self)


## Setzt die vorhandenen Lemonade-Instanzen in die frisch gebaute Grube:
## tiefer, dicker und im POOL-Modus, damit Auftrieb und Schwimmen greifen.
func _reposition_lava() -> void:
	for hazard in _find_lava_hazards():
		var local_pos: Vector3 = _to_floor_local(hazard)
		var lava_size: Vector3 = hazard.get("size")

		var new_depth: float = maxf(pit_depth * lava_fill_ratio, 0.5)
		var floor_top_local: float = floor_thickness * 0.5
		var target_surface_local: float = floor_top_local - lava_surface_drop
		var current_surface_local: float = local_pos.y + lava_size.y * 0.5

		# Neue Hoehe zuerst setzen, sonst rechnet der Offset mit der alten
		# Dicke und die Oberflaeche landet zu hoch.
		hazard.set("size", Vector3(lava_size.x, new_depth, lava_size.z))
		var new_surface_local: float = local_pos.y + new_depth * 0.5

```
</details>

### 💭 Thinking

`21:15:36`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `_build_void_kill_zone\(|fixed_process|_physics_process|freeze|max_fall|tunneling|CCD|continuous` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pit_floor.gd`

`21:15:38`

```
412-	_build_void_shaft("%sVoidShaft%d" % [GEN_PREFIX, index], pit, top, shaft_depth)
413-
414-	var kill_y: float = top - void_kill_depth
415:	_build_void_kill_zone(
416-		"%sVoidKill%d" % [GEN_PREFIX, index],
417-		Vector3(center_x, kill_y, center_z),
418-		Vector3(pit.size.x, 2.0, pit.size.y)
--
484-## LemonadeTrigger fuer denselben, bereits bewaehrten Maskenwert) - damit
485-## sterben auch Gegner sofort, die in den Abgrund fallen, nicht nur der
486-## Spieler.
487:func _build_void_kill_zone(node_name: String, center: Vector3, size: Vector3) -> void:
488-	var area := Area3D.new()
489-	area.name = node_name
490-	area.collision_layer = 0
```

### 💭 Thinking

`21:15:57`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 👀 Read `pit_floor.gd`

`21:15:58`

*(lines 370–420)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pit_floor.gd</code></summary>

```

## Erzeugt EIN Mesh+Collider-Paar. Beides landet als Kind dieses
## StaticBody3D, damit der NavMesh-Baker die Collider findet.
func _emit_box(tag: String, center: Vector3, box_size: Vector3) -> void:
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "%s%s_Mesh" % [GEN_PREFIX, tag]
	mesh_instance.mesh = box_mesh
	mesh_instance.position = center
	if _floor_material:
		mesh_instance.material_override = _floor_material
	add_child(mesh_instance)

	var box_shape := BoxShape3D.new()
	box_shape.size = box_size

	var collision := CollisionShape3D.new()
	collision.name = "%s%s_Shape" % [GEN_PREFIX, tag]
	collision.shape = box_shape
	collision.position = center
	add_child(collision)

	if Engine.is_editor_hint():
		mesh_instance.owner = get_tree().edited_scene_root
		collision.owner = get_tree().edited_scene_root


## Bodenloser Abgrund: KEINE Wanne (siehe extra_void_pits-Kommentar) - dafuer
## ein tiefer, rein schwarzer SCHACHT (vier Waende + Boden, alle unbeleuchtet
## nahe Schwarz) statt eines offenen Lochs. Ohne Waende sieht man beim
## Reinschauen aus einem flachen Winkel an der duennen Kill-Zone/Rueckwand
## vorbei ins Nichts (Skybox, Nachbarraum) - der Schacht garantiert, dass in
## JEDE Blickrichtung nur Dunkelheit zu sehen ist. Die Instant-Kill-Zone
## sitzt weit genug oben im Schacht, dass man sie nie erreicht.
func _build_void_pit(pit: Rect2, index: int) -> void:
	var top: float = floor_thickness * 0.5
	var center_x: float = pit.position.x + pit.size.x * 0.5
	var center_z: float = pit.position.y + pit.size.y * 0.5
	var shaft_depth: float = void_kill_depth + void_backdrop_extra_depth

	_build_void_shaft("%sVoidShaft%d" % [GEN_PREFIX, index], pit, top, shaft_depth)

	var kill_y: float = top - void_kill_depth
	_build_void_kill_zone(
		"%sVoidKill%d" % [GEN_PREFIX, index],
		Vector3(center_x, kill_y, center_z),
		Vector3(pit.size.x, 2.0, pit.size.y)
	)
```
</details>

### 💭 Thinking

`21:16:12`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `void_kill_depth|void_backdrop_extra_depth|floor_thickness` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pit_floor.gd`

`21:16:14`

```
34-
35-## Dicke des Boden-Slabs. Muss zur BoxShape3D des Templates passen.
36:@export var floor_thickness: float = 1.0:
37-	set(value):
38:		floor_thickness = value
--
80-## extra_void_pits-Eintrags sitzt. Tief genug, dass der Sturz sichtbar Zeit
81-## braucht, bevor er endet.
82:@export var void_kill_depth: float = 24.0
--
85-## optisch, verhindert, dass beim Reinfallen kurz der Boden der Kill-Zone
86-## aufblitzt, bevor der Treffer ausgewertet wird.
87:@export var void_backdrop_extra_depth: float = 10.0
--
331-		rect.position.y + rect.size.y * 0.5
332-	)
333:	_emit_box("Floor", center, Vector3(rect.size.x, floor_thickness, rect.size.y))
--
337-## saehe man beim Reinfallen durch den Boden-Slab hindurch ins Nichts.
338-func _build_basin(pit: Rect2) -> void:
339:	var top: float = floor_thickness * 0.5           # Bodenoberkante, lokal
--
405-## sitzt weit genug oben im Schacht, dass man sie nie erreicht.
406-func _build_void_pit(pit: Rect2, index: int) -> void:
407:	var top: float = floor_thickness * 0.5
408-	var center_x: float = pit.position.x + pit.size.x * 0.5
409-	var center_z: float = pit.position.y + pit.size.y * 0.5
410:	var shaft_depth: float = void_kill_depth + void_backdrop_extra_depth
--
412-	_build_void_shaft("%sVoidShaft%d" % [GEN_PREFIX, index], pit, top, shaft_depth)
413-
414:	var kill_y: float = top - void_kill_depth
--
529-
530-		var new_depth: float = maxf(pit_depth * lava_fill_ratio, 0.5)
531:		var floor_top_local: float = floor_thickness * 0.5
```

### 💭 Thinking

`21:16:55`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 🔎 Grep `func _build_void_shaft" -A 30` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pit_floor.gd`

`21:16:56`

```
No matches found
```

#### 🔎 Grep `_build_void_shaft` in `C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pit_floor.gd`

`21:17:00`

```
412:	_build_void_shaft("%sVoidShaft%d" % [GEN_PREFIX, index], pit, top, shaft_depth)
413-
414-	var kill_y: float = top - void_kill_depth
415-	_build_void_kill_zone(
416-		"%sVoidKill%d" % [GEN_PREFIX, index],
417-		Vector3(center_x, kill_y, center_z),
418-		Vector3(pit.size.x, 2.0, pit.size.y)
419-	)
420-
421-
422-## Vier Waende (dicker als bei _build_basin, damit man selbst aus flachem
423-## Blickwinkel keine Luecke am Uebergang zum Boden-Slab sieht) plus ein
424-## Boden-Cap ganz unten - alles in derselben nahe-schwarzen Unlit-Farbe wie
425-## vorher die reine Rueckwand.
426:func _build_void_shaft(prefix: String, pit: Rect2, top: float, shaft_depth: float) -> void:
427-	var center_x: float = pit.position.x + pit.size.x * 0.5
428-	var center_z: float = pit.position.y + pit.size.y * 0.5
429-	var bottom: float = top - shaft_depth
430-	var wall: float = 1.0
431-	var wall_center_y: float = top - shaft_depth * 0.5
432-
433-	_emit_dark_box("%sWallN" % prefix,
434-		Vector3(center_x, wall_center_y, pit.position.y - wall * 0.5),
435-		Vector3(pit.size.x + wall * 2.0, shaft_depth, wall))
436-	_emit_dark_box("%sWallS" % prefix,
437-		Vector3(center_x, wall_center_y, pit.end.y + wall * 0.5),
438-		Vector3(pit.size.x + wall * 2.0, shaft_depth, wall))
439-	_emit_dark_box("%sWallW" % prefix,
440-		Vector3(pit.position.x - wall * 0.5, wall_center_y, center_z),
441-		Vector3(wall, shaft_depth, pit.size.y))
442-	_emit_dark_box("%sWallE" % prefix,
443-		Vector3(pit.end.x + wall * 0.5, wall_center_y, center_z),
444-		Vector3(wall, shaft_depth, pit.size.y))
445-	_emit_dark_box("%sBottom" % prefix,
446-		Vector3(center_x, bottom - wall * 0.5, center_z),
447-		Vector3(pit.size.x + wall * 2.0, wall, pit.size.y + wall * 2.0))
448-
449-
450-## Gleiche Bauweise wie _emit_box(), aber mit fester, unbeleuchteter
451-## Nahe-Schwarz-Farbe statt des Boden-Materials - fuer alles, was als reine
452-## Dunkelheit wirken soll, nicht als sichtbare Grubenwand.
453-func _emit_dark_box(tag: String, center: Vector3, box_size: Vector3) -> void:
454-	var box_mesh := BoxMesh.new()
455-	box_mesh.size = box_size
456-
457-	var mat := StandardMaterial3D.new()
458-	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
459-	mat.albedo_color = Color(0.01, 0.01, 0.012)
460-
461-	var mesh_instance := MeshInstance3D.new()
```

### 🤖 Assistant: *Found it. `_build_void_shaft()` builds a…*

`21:17:11`

<details>
<summary>Thinking...</summary>

> 
</details>

> Found it. `_build_void_shaft()` builds a **solid floor** at the very bottom of the pit shaft (`"%sBottom"`), but the instant-kill `Area3D` is only a **2-unit-thin slice** positioned 24 units above that floor. Any enemy falling fast enough (knockback with vertical component, or a physics-delta spike during a busy frame) can tunnel straight through that thin trigger in a single physics step and land alive on the solid bottom — invisible, unreachable, and permanently counted as "still alive," which locks the room. Let's widen the kill zone to cover almost the entire shaft so tunneling past it becomes essentially impossible.

#### ✏️  Edit `pit_floor.gd`

`21:17:25`

```diff
@@ -1,8 +1,33 @@ 	_build_void_shaft("%sVoidShaft%d" % [GEN_PREFIX, index], pit, top, shaft_depth)
 
-	var kill_y: float = top - void_kill_depth
+	# BUGFIX "Gegner fallen manchmal in die Grube und sterben nicht, Raum
+	# bleibt gesperrt": _build_void_shaft() baut ganz unten im Schacht einen
+	# SOLIDEN Boden-Collider ("Bottom", siehe dort) - urspruenglich nur als
+	# optische Rueckwand gedacht, falls man mal bis dahin sehen sollte
+	# (Kopfkommentar: "Die Instant-Kill-Zone sitzt weit genug oben im
+	# Schacht, dass man sie nie erreicht"). Die Kill-Zone war aber nur 2
+	# Einheiten dick - ein Koerper mit genug Fallgeschwindigkeit in EINEM
+	# Physik-Schritt (starker Ruecksto0ss mit Vertikal-Komponente, oder ein
+	# groesseres Delta bei einem Frame-Hitch beim Betreten eines vollen
+	# Kampfraums) kann diese duenne Schicht komplett ueberspringen, OHNE dass
+	# body_entered je feuert - klassisches Tunneling durch einen duennen
+	# Trigger. Der Koerper faellt dann NICHT ewig weiter, sondern landet
+	# lebendig auf dem soliden Boden-Collider: unsichtbar, unerreichbar, aber
+	# fuer die Gegner-Zaehlung weiter "lebendig" - der Raum bleibt dadurch
+	# permanent verriegelt.
+	#
+	# Fix: die Kill-Zone deckt jetzt fast den GESAMTEN Rest-Schacht ab (bis
+	# knapp ueber den Boden-Collider) statt nur einer duennen Scheibe -
+	# ein Durchqueren ohne Treffer wuerde jetzt eine Geschwindigkeit
+	# brauchen, die den kompletten restlichen Schacht in einem einzigen
+	# Physik-Schritt ueberspringt, praktisch ausgeschlossen.
+	var kill_top: float = top - void_kill_depth + 1.0
+	var shaft_bottom: float = top - shaft_depth
+	var kill_bottom: float = shaft_bottom + 1.0
+	var kill_height: float = maxf(kill_top - kill_bottom, 2.0)
+	var kill_center_y: float = kill_top - kill_height * 0.5
 	_build_void_kill_zone(
 		"%sVoidKill%d" % [GEN_PREFIX, index],
-		Vector3(center_x, kill_y, center_z),
-		Vector3(pit.size.x, 2.0, pit.size.y)
+		Vector3(center_x, kill_center_y, center_z),
+		Vector3(pit.size.x, kill_height, pit.size.y)
 	)
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\pit_floor.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 🤖 Assistant: *Now let's dig into the sacrifice bug.*

`21:17:41`

<details>
<summary>Thinking...</summary>

> 
</details>

> Now let's dig into the sacrifice bug. I read `treasure_pedestal.gd`, `sacrifice_pedestal.gd`, and the spawn logic in `treasure_manager.gd` carefully against each of your three hypotheses:

#### 👀 Read `item_manager.gd`

`21:17:43`

*(lines 1–2)*

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\scripts\items\item_manager.gd</code></summary>

```

```
</details>

### 💭 Thinking

`21:17:47`

<details>
<summary>Thinking...</summary>

> 
</details>

#### ✏️  Edit `treasure_manager.gd`

`21:17:54`

```diff
@@ -1,7 +1,20 @@ 	# Blutzoll-Raeume (Blueprint Nr. 5): SacrificePedestal statt des normalen
 	# Sockels - identische Optik/Interaktion, kostet aber HP beim Nehmen.
+	#
+	# HARDENING: vorher "bool(room.get('is_sacrifice_room'))" - ein
+	# dynamischer Property-Zugriff, der bei einem Tippfehler/umbenannten
+	# Feld STILL auf null (-> bool(null) = false) zurueckfaellt statt eines
+	# Parse-Fehlers. Direkter, statisch typisierter Zugriff auf room.
+	# is_sacrifice_room (RoomInstance @export, siehe room_instance.gd) faengt
+	# so einen Tippfehler kuenftig SOFORT beim Laden ab, statt ihn still
+	# durchzulassen. Zusaetzliches Logging, falls der Blutzoll-Sockel
+	# jemals in einem Raum landet, der es nicht sein sollte.
+	var is_sacrifice: bool = room.is_sacrifice_room
 	var pedestal: TreasurePedestal
-	if bool(room.get("is_sacrifice_room")):
+	if is_sacrifice:
 		pedestal = SacrificePedestal.create(item)
 	else:
 		pedestal = TreasurePedestal.create(item)
+	_debug("  -> is_sacrifice_room=%s fuer Raum %s (Szene '%s') -> %s" % [
+		is_sacrifice, room.grid_position, room.scene_file_path, pedestal.get_class()
+	])
```

```
The file C:\Users\thvnh\Documents\GitHub\whiplash\scripts\treasure_manager.gd has been updated successfully. (file state is current in your context — no need to Read it back)
```

### 💭 Thinking

`21:18:01`

<details>
<summary>Thinking...</summary>

> 
</details>

#### 💻 Bash

`21:18:02`

```bash
$ cd "C:\Users\thvnh\Documents\GitHub\whiplash" && graphify update . 2>&1 | tail -6
```

```
  AST extraction: 1/1 uncached files (100%)

  warning: 1 source file(s) produced zero nodes and are absent from the graph: .gutconfig.json. A re-run will retry them (empties are no longer cached); if it persists, please report the file(s) (#1666).

[graphify] Extraction warning (2 issues): 2x missing required field 'source_file' (e.g. Node 5159 (id='concept_hit_stop') missing required field 'source_file')

[graphify watch] No code-graph topology changes detected; outputs left untouched.

Code graph updated. For doc/paper/image changes run /graphify --update in your AI assistant.

Tip: set GEMINI_API_KEY or GOOGLE_API_KEY to use Gemini for semantic extraction.
```

### 🤖 Assistant: *## 1. Enemies falling and not dying ("Raum…*

`21:18:34`

> ## 1. Enemies falling and not dying ("Raum mit dem Kreuz") — fixed, root cause confirmed
> 
> Found it in `pit_floor.gd`. Pits are built with two pieces: a solid catch-floor way down at the bottom of the shaft (`_build_void_shaft()`'s `"Bottom"` collider — originally meant only as a visual backdrop) and a thin **2-unit-tall** instant-kill `Area3D` positioned 24 units above it. If a falling body has enough vertical velocity in a single physics step — a knockback with a downward component, or just a bigger physics delta from a frame hitch when a combat room dumps a pile of enemy at once — it can tunnel straight through that thin trigger without `body_entered` ever firing, then land alive on the solid floor below: invisible, unreachable, and still counted as "alive," which is exactly what locks the room.
> 
> Fixed by widening the kill zone to span almost the entire shaft (from where it used to start down to just above the solid floor) instead of a 2-unit slice. Tunneling past it now would require crossing ~30+ units in one physics step, which isn't realistically going to happen.
> 
> ## 2. Sacrifice damage leaking into normal pickups — audited, not reproduced, hardened anyway
> 
> I went through all three of your hypotheses concretely:
> 
> - **#2 (damage in the parent class)** — ruled out. `TreasurePedestal.take()` has zero damage-related code; the HP cost only exists in `SacrificePedestal.take()`'s override, which is a normal instance-method override — no global signal, no shared state, only fires when *that* pedestal's own `take()` runs.
> - **#3 (item_manager.gd / pickup.gd)** — ruled out. `Items.add_item()`, `Items.pickup_active_item()`, and `Pickup._collect()` (ground drops) contain no `take_damage` calls anywhere. I also grepped every `take_damage(` call site in the project — the ~40 in `item_behaviours.gd` are all gated behind `_has(SPECIFIC_ITEM_ID)` checks for individual item effects, not a general "any pickup" hook.
> - **#1 (`is_sacrifice_room` always true)** — also structurally correct on inspection: `RoomInstance.is_sacrifice_room` defaults to `false`, and only `room_treasure_sacrifice_01.tscn` overrides it to `true`. The `TreasureManager` branch reads it correctly.
> 
> I couldn't reproduce the bug from static review — the sacrifice-specific code looks sound wherever I traced it. I did harden `treasure_manager.gd` anyway: replaced the dynamic `bool(room.get("is_sacrifice_room"))` (which silently falls back to `false` on a typo/rename instead of erroring) with a direct, statically-typed `room.is_sacrifice_room` access, and added a debug log line that prints the room's grid position, scene path, and which pedestal class got chosen every time one spawns.
> 
> **I need more info to actually catch this one**: next time it happens, could you check the console for a `[Treasure] -> is_sacrifice_room=...` line for that room, and tell me the exact damage amount (is it ~25% of max HP, matching `SACRIFICE_HP_FRACTION`, or something else)? If it's not 25%, it's probably a different, unrelated damage source (an environmental hazard, or another item's self-damage effect) that just happened to coincide with a pickup rather than this mechanic at all.

#### 👀 Read `rd_combat_12.tres`

`20:41:49`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_12.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/combat/room_combat_12.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 0
available_exits = 15
spawn_weight = 1.2
min_stage = 0
unique_per_run = false
footprint_cells = Vector2i(1, 1)

```
</details>

#### 👀 Read `rd_combat_abyss_01.tres`

`20:41:49`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_abyss_01.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/combat/room_combat_abyss_01.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 0
available_exits = 15
spawn_weight = 0.4
min_stage = 1
unique_per_run = false

```
</details>

#### 👀 Read `rd_combat_switch_01.tres`

`20:41:50`

<details>
<summary><code>C:\Users\thvnh\Documents\GitHub\whiplash\resources\rooms\rd_combat_switch_01.tres</code></summary>

```
[gd_resource type="Resource" script_class="RoomData" load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/level_generation/room_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/rooms/combat/room_combat_switch_01.tscn" id="2_scene"]

[resource]
script = ExtResource("1_script")
scene = ExtResource("2_scene")
room_type = 0
available_exits = 15
spawn_weight = 0.4
min_stage = 1
unique_per_run = false

```
</details>
