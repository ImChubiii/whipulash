---
tags: [design-brainstorming, room, balancing]
---

# Raum-Ideen & Balancing (Entwurf)

> *Brainstorming-Sammlung für neue Raum-Konzepte und Balancing-Stellschrauben basierend auf bestehenden Mechaniken und Assets.*

## Raum-Design Ideen

### 2. Der Schalter-Puzzle-Kampf (Switch Arena)
- **Konzept:** Ein Raum (`combat_switch_01`), bei dem der Ausgang nicht automatisch nach dem Tod aller Gegner aufgeht.
- **Mechanik:** Die Tür ist an Bodenschalter (`Switch_Floor` oder `Lever_Floor`) gekoppelt. Während unendlich viele billige Gegner (Stinger) spawnen, muss der Spieler rennend 3 Schalter aktivieren, um den Raum abzuschließen.
- **Spielgefühl:** Bricht das "Töte einfach alles"-Muster auf und fokussiert stark auf Movement.
- **Für Claude:** Implementiere ein Skript `room_switch_arena.gd`, das von `combat_base.gd` erbt. Überschreibe `_on_enemy_killed()`, damit die Türen geschlossen bleiben. Verbinde das `toggled`-Signal der Schalter mit einem internen Counter. Wenn `counter == 3`, rufe `open_doors()` auf.

### 3. Der riskante Gitterrost (Abyss Maze)
- **Konzept:** Ein Kampf-Raum (`combat_abyss_grid`), der fast nur aus Abgrund besteht. Kleine 2x2 Plattformen sind durch extrem dünne Stege verbunden.
- **Mechanik:** Gegner zwingen den Spieler zu Positionswechseln. Erfordert perfekte Nutzung des Dashs (Shift), ohne hinunterzufallen.
- **Spielgefühl:** Testet Movement/Dash extrem. Sehr gut für schnelle Charaktere (Karina), aber extrem riskant.
- **Für Claude:** Nutze in der `.tscn` eine `GridMap` mit sehr großen Lücken (Abyss). Stelle sicher, dass `NavigationRegion3D` nur die Stege und Plattformen backt, damit das Pathfinding der Gegner funktioniert. Setze Fall-Trigger-Boxen (`Area3D`), die den Spieler beim Herunterfallen an den Startpunkt zurücksetzen und Schaden zufügen.

### 4. Die Brücke der Verzweiflung (Chokepoint)
- **Konzept:** Raum geformt wie eine Sanduhr (`combat_chokepoint_01`). Zwei Areale, verbunden durch eine enge Brücke.
- **Mechanik:** Spieler auf der einen Seite, ein Colossus + Fighter auf der anderen. Alle müssen über die schmale Brücke.
- **Spielgefühl:** Charaktere mit Flächenschaden (AoE) oder Durchschlag (Winter/Giselle) glänzen hier extrem.
- **Für Claude:** Platziere `EnemySpawnPoint` Nodes gezielt nur auf der gegenüberliegenden Seite der Brücke. Keine speziellen Skripte nötig, das Level-Layout in der Szene (`GridMap`) reicht aus.

### 5. Blutzoll (Sacrifice Room / Risk-Reward)
- **Konzept:** Alternative zur normalen Schatzkammer (`treasure_sacrifice_01`).
- **Mechanik:** Ein Item auf einem Podest (`Pedestal`). Um es zu nehmen, muss man z.B. absichtlich einen Schalter drücken, der 25% Max-HP kostet.
- **Spielgefühl:** Klassische Roguelike Risk/Reward-Entscheidung.
- **Für Claude:** Erstelle `sacrifice_pedestal.gd`. Ein `Area3D` registriert die Interaktion (E-Taste). Bei Aktivierung: `PlayerStats.take_damage(PlayerStats.max_hp * 0.25)` und anschließend `spawn_item()`.

---

## Balancing-Stellschrauben

### 1. Giselle (Die Sniper-Anomalie)
- **Ist-Zustand:** Sniper-Rolle, aber 130 HP (höchste im Spiel) und langsam (14.0 Speed).
- **Vorschlag:** Sniper sollten "Glass Cannons" sein. HP auf ca. 85-90 reduzieren, dafür Speed leicht erhöhen (16.0). So spielt sie sich agiler auf Distanz, stirbt aber schneller, wenn Gegner zu nah kommen.
- **Für Claude:** Passe die Werte direkt in `giselle.tres` (Resource) oder im `_ready()` von `giselle.gd` an (`max_hp = 90`, `move_speed = 16.0`).

### 2. Differenzierung: Feuer (Burn) vs. Säure (Acid)
- **Ist-Zustand:** Beide sind reine DoTs (Schaden über Zeit). Spielerisch kaum Unterschied.
- **Vorschlag:**
  - **Burn:** Viel Schaden in kurzer Zeit (aggressiv). Gegner explodieren eventuell bei Tod.
  - **Acid:** Wenig Schaden, aber reduziert Rüstung (Gegner wird *vulnerable*). Alle anderen Angriffe machen +20% Schaden.
- **Für Claude:** Ändere `status_effect_manager.gd`. Für Burn: Kürzere `tick_rate` und höheren `damage_per_tick`. Für Acid: Setze im Gegner-Skript einen Multiplikator `damage_taken_multiplier = 1.2`, solange Acid aktiv ist.

### 3. Colossus & Knockback-Resistenz
- **Ist-Zustand:** 400 HP und völlig immun gegen Knockback. Extrem hart für Nahkämpfer (Ningning).
- **Vorschlag:** Statt kompletter Immunität ein "Stagger"-System: Nach 5 schnellen Treffern bricht seine Haltung und er weicht kurz zurück oder wird gestunnt. Belohnt aggressives, risikofolles Nahkampf-Kombospiel.
- **Für Claude:** Füge in `colossus.gd` einen `stagger_counter` ein. Bei jedem `take_damage()` erhöhe ihn. Nutze einen `Timer`, der den Counter zurücksetzt, wenn nicht schnell genug nachgeschlagen wird. Bei `stagger_counter >= 5` löse `apply_knockback()` und `stun(2.0)` aus.

### 4. Item-Synergie Wahrscheinlichkeiten (84 Items)
- **Ist-Zustand:** Bei 84 Items ist es pures RNG, zwei passgenaue Synergie-Items zu finden.
- **Vorschlag:** Tag-Gewichtung im Code. Wer ein Item mit `#applies/burn` aufhebt, bekommt im Hintergrund eine +15% Chance, weitere Feuer-Items in Schatzkammern zu finden. Erlaubt gezieltes Build-Crafting.
- **Für Claude:** Erweitere `ItemManager.gd` um ein Weighting-System. Wenn der Spieler ein Item aufhebt, iteriere über dessen Synergie-Tags und erhöhe temporär das `spawn_weight` aller Items im globalen Pool, die denselben Tag haben.

### 5. Threat-Budget vs. AoE im Lategame
- **Ist-Zustand:** Wenn das Budget steigt, spawnen im Lategame extrem viele "billige" Fighter. Lategame-AoE-Waffen zerstören diese zu schnell.
- **Vorschlag:** Das Threat-Budget sollte in höheren Etagen gezwungen werden, Elite-Gegner (Colossus, Schild-Drohnen) zu priorisieren, statt einfach nur 30 Fighter zu spawnen.
- **Für Claude:** Im `level_generator.gd` oder `spawn_manager.gd`: Passe die Logik für `allocate_threat()` an. Bei `current_stage > 3` zwinge die Auswahl-Schleife, zuerst Elite-Gegner (hoher Threat-Cost) zu kaufen, bevor das Rest-Budget mit Fightern gefüllt wird.

# Neue Ideen
### 2. Zerstörbare Umgebungen & Deckung
Du hast viele Requisiten im Dungeon Kit (`table_2x2`, `pillar`, `wood_beam`).
- **Idee:** Mach diese Objekte zerstörbar. Wenn der **Colossus** (dein schwerer Tank-Gegner) auf dich zustürmt und du ausweichst (`Dash`), kracht er in die Steinsäule. Die Säule zerbricht in PSX-typische Low-Poly-Stücke und der Colossus ist für 2 Sekunden gestunnt.
- **Warum?** Es lässt die Welt physischer wirken und nutzt die Umgebung als Waffe.
- **Für Claude:** Ändere Requisiten von `StaticBody3D` auf `RigidBody3D` oder erstelle ein dediziertes `DestructibleProp.gd`. Das Skript hat `take_damage()` oder reagiert auf `body_entered` vom Colossus-Dash. Bei Zerstörung: Spawne Partikel (`GPUParticles3D`) und `queue_free()`.

### 3. "The Lemonade Flood" (Bosskampf-Mechanik)
Du hast die Limonaden-Hazards (Schaden + Slow).
- **Idee:** Ein Bosskampf, der nicht nur aus "Ausweichen und Schießen" besteht. Der Boss flutet nach und nach den Raum mit Limonade. Der Spieler muss auf die `table`- oder `pillar`-Assets springen, um nicht zu sterben.
- **Warum?** Das zwingt den Spieler zu Vertikalität und Plattform-Sprüngen während des Kampfes. Die _Säurefesten Stiefel_ wären in diesem Bosskampf plötzlich das absolut wertvollste Item des Runs!
- **Für Claude:** Nutze ein großes, halbtransparentes, gelb-grünes Mesh (`MeshInstance3D`) mit einem Water-Shader. Ein `Tween` oder eine `_process`-Logik bewegt das Mesh langsam auf der Y-Achse nach oben. Ein daran gekoppeltes `Area3D` fügt Spielern, die das Wasser berühren, Schaden zu.

### 4. Geheimräume (Der klassische Roguelite-Faktor)
Dein Level-Generator baut die Räume aus einem Raster (Grid) zusammen.
- **Idee:** Generiere manchmal einen Raum, der auf der Minimap _nicht_ sichtbar ist. Die Wand dorthin (z. B. eine `Wall_Flat`) hat Risse. Wenn der Spieler ein Item hat, das Explosionen erzeugt (wie `Spicy Ramen` oder `Broken Toaster`), kann er die Wand aufsprengen und eine versteckte Schatzkammer finden.
- **Warum?** Secrets sind das Herzblut von Roguelites (wie in _The Binding of Isaac_). Es bringt die Spieler dazu, die Umgebung genau zu beobachten.
- **Für Claude:** In `level_generator.gd` eine Chance von 15% einbauen, einen `secret_room` neben einen normalen Raum zu setzen. Die verbindende Tür wird durch eine zerstörbare Wand ausgetauscht. Der Raum wird aus der Minimap-Logik ausgeschlossen, bis er betreten wird.

### 5. Hit-Stop & PSX "Juice"
Da das Spiel einen PSX-Retro-Look hat und schnelles Action-Gameplay bietet:
- **Idee:** Füge extremen "Hit-Stop" (Frame-Freeze) hinzu. Wenn Karina (der Assassin) einen kritischen Treffer landet oder einen Gegner tötet, friert das Spiel für 0.05 Sekunden komplett ein. Dazu ein fetter, klobiger Blut-Pixel-Partikeleffekt und leichtes Screen-Shake (Kamera-Wackeln).
- **Warum?** Combat in PSX-Spielen lebt von der Wuchtigkeit. Da die Modelle Low-Poly sind, muss das visuelle Feedback (wie sich ein Treffer _anfühlt_) die meiste Arbeit machen.
- **Für Claude:** Erstelle eine Autoload-Klasse `HitStopManager.gd`. Methode `freeze(duration: float)`: Setze `Engine.time_scale = 0.0`, starte einen unskalierten Timer und setze nach Ablauf `Engine.time_scale = 1.0` zurück. Kamera-Shake kann über ein separates Event ausgelöst werden.

### 6. Meta-Progression (Was passiert nach dem Tod?)
Du hast einen `START`-Raum.
- **Idee:** Was bringt man aus einem toten Run mit zurück? Führe "Drops" (oder eine andere Währung) ein. Wenn man stirbt, erwacht man in einem Hub-Raum (der Lobby). Dort kann man die drops dann für Item spawn wahrscheinlichkeiten einsetzen (cap bei 40%)
- **Für Claude:** Erstelle `SaveGameManager.gd` um Meta-Currency (`drops`) persistent in einer `.save` oder `user://` Datei zu speichern. In der Hub-Szene ein Menü/Shop-NPC einrichten, das die Basis-Drop-Gewichte in `ItemManager.gd` basierend auf den gekauften Upgrades modifiziert.

### Zusätzliche Items (Schulhof-Thema)

| **Nr.** | **Entity ID** | **ITEM ID** | **Typ** | **Rarity** | **Name** | **Mechanik** | **VFX (Finales Konzept)** | **Statuseffekt & Synergien** |
| ------- | ------------- | ----------------- | ---------- | ---------- | ---------------------- | --------------------------------------------------------------------- | ------------------------------------------ | -------------------------------- |
| 84 | 2.39 | pocket_calculator | 2 (Passiv) | Common | Taschenrechner | +3% Crit Chance | Kleine grüne Zahlen ploppen beim Crit auf | Synergie mit Crit-Builds |
| 85 | 2.40 | jump_rope | 2 (Passiv) | Common | Springseil | -5% Dash Cooldown | Weißer Schweif beim Dashen | Synergie mit Movement-Items |
| 86 | 2.41 | set_square | 2 (Passiv) | Uncommon | Geodreieck | +15% Projektil-Hitbox | Schüsse haben ein leicht eckiges Glow-Feld | Perfekt für Giselle (Sniper) |
| 87 | 2.42 | chalk_eraser | 2 (Passiv) | Uncommon | Tafel-Schwamm | Reduziert Dauer von gegnerischen DoTs (Burn/Acid) um 50% | Kreidestaub-Partikel beim Treffer | Kontert Säure-Sprinkler |
| 88 | 2.43 | empty_energy_can | 2 (Passiv) | Common | Leere Energy-Dose | +20% Move-Speed für 1.5s nach dem Dashen | Grüne Blitze um die Füße | Synergie mit Springseil |
| 89 | 2.44 | old_compass | 2 (Passiv) | Uncommon | Alter Zirkel | +25% Nahkampf-Reichweite | Halbkreis-Wisch-Effekt beim Schlagen | Stark auf Nahkämpfern (Ningning) |
| 90 | 2.45 | tangled_yoyo | 2 (Passiv) | Uncommon | Verheddertes Jo-Jo | +30% Schaden auf maximaler Schuss-Reichweite | Einschlag wird größer je weiter weg | Synergie mit Giselle |
| 91 | 2.46 | broken_pencil | 2 (Passiv) | Uncommon | Zerbrochener Bleistift | +15% Base Damage, aber 10% Chance Drops bei Gegentreffer zu verlieren | Graue Holz-Splitter bei Schüssen | Risk/Reward Mechanik |
| 92 | 2.47 | paintbox | 2 (Passiv) | Common | Tuschkasten | Schüsse leuchten in zufälligen Farben, +5 Max HP | Bunte Projektil-Trails (RGB) | Kosmetisch & leichter Sustain |
| 93 | 2.48 | forgotten_gym_bag | 2 (Passiv) | Uncommon | Vergessener Turnbeutel | 100% Immun gegen Slow-Effekte (z.B. Limonade) | Kurze Mief-Wolke beim Betreten von Säure | Kontert Limonaden-Räume |

### 7. Kritische Treffer (Crit-Feedback)
- **Idee:** Einführung von Crit-Damage. Wenn ein kritischer Treffer erzielt wird, poppen die Schadenszahlen auf.
- **Visuals:** Die Zahlen für kritische Treffer sollen etwas größer als normal sein und eine auffällige rote Umrandung (Outline) erhalten, damit sie sich sofort von normalem Schaden abheben.
- **Für Claude:** In `DamageNumber.tscn` (Label3D oder Control-Node) eine Eigenschaft `is_crit` abfragen. Wenn wahr, skaliere den Text (`scale = Vector3(1.5, 1.5, 1.5)`) und setze die `outline_color` auf Rot und die `outline_size` hoch. Nutze einen Tween für ein aggressives Pop-Up-Verhalten.

### 8. Dash-Schaden (Damage Numbers)
- **Idee:** Wenn Gegner durch den Dash (Ausweichrolle) Schaden nehmen (z.B. durch Items), poppen Schadenszahlen auf.
- **Visuals:** Der Dash-Schaden soll exakt so aussehen wie ganz normale Schadenszahlen. Es gibt optisch **keinen Unterschied** zu normalen Angriffen (im Gegensatz zum roten Crit-Schaden).
- **Für Claude:** Achte in `player_dash.gd` darauf, dass bei Schadensberechnung an Gegnern die selbe Routine `SpawnManager.spawn_damage_number(amount, false)` wie beim normalen Waffenschaden (`combat.gd`) aufgerufen wird. Parameter `is_crit` bleibt `false`.
