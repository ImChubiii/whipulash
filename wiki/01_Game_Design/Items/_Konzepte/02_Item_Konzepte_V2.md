---
tags: [design-brainstorming, items]
---

# Item-Konzepte V2

### Duellanten (Duelists)

**Jett**

- **Aufwind:** Ein schneller Dash (ähnlich deinem aktuellen Ausweichschritt), der dem Spieler vorübergehend i-frames (Unverwundbarkeit) gibt und ihn Kollisionen mit Hazards (wie `pit_floor`) ignorieren lässt und den Gegnern Knockback gibt und sie damaged. **Detail für Claude:** Cooldown: 8s. Mechanik: Nutze die Dash-Logik aus `combat_base.gd`. Spawne beim Auslösen eine `Area3D` um den Spieler, die für 0.3s aktiv bleibt. Rufe für jeden Gegner in der Area die bestehende Hit-Logik auf (z.B. 20 Schaden) und appliziere einen `knockback_force` von 25.
    
- **Klingensturm:** Es gibt keine Kopfschüsse. Spawnt 5 Homing-Projektile (ähnlich deinem `homing_bolt.gd`), die bei Angriff automatisch das nächste Ziel in der Nähe (über die `enemies`-Gruppe) suchen. Tötungen setzen den Ladungszähler des Items zurück. **Detail für Claude:** Cooldown: 60s (Ultimate). Mechanik: Die 5 Projektile kreisen visuell um den Spieler. Bei Linksklick feuert exakt 1 Projektil mit einem Delay von 0.15s zwischen Schüssen. Binde ein Signal an `enemy_died` – wenn das feuert, setze die Projektil-Variable sofort wieder auf 5.
    

**Phoenix**

- **Flashbang / Blaze (Feuerwand):** Instanziert eine statische Wand aus `Area3D`-Kollidern vor dem Spieler. Gegner, die sie berühren, erhalten deinen existierenden `burn.gd`-Status. Der Spieler selbst heilt über `health.gd`. **Detail für Claude:** Cooldown: 15s. Mechanik: Spawne eine Kette von 5 `Area3D`-Instanzen linear in Blickrichtung mit je 0.1s Verzögerung. Die Wand bleibt exakt 8s bestehen. Gegner darin erhalten alle 0.5s einen Schadens-Tick.
    
- **Heiße Hände:** Nutzt exakt deine `lemonade.gd`-Logik (Lava-Hazard), spawnt aber ein temporäres Flächen-Objekt, das Feuerschaden austeilt statt Lavaschaden. **Detail für Claude:** Cooldown: 12s. Mechanik: Ein Projektil fliegt für 0.8s parabolisch. Bei Bodenkontakt instanziert es eine Fläche mit Radius 5.0, die 4s lebt. Tickt alle 0.5s über `status = burn`.
    
- **Replikation:** Speichert bei Aktivierung die Startposition (`global_position`) und die aktuellen Lebenspunkte. Wenn der Charakter stirbt, greift die Fähigkeit ein, bevor dein normales "Last-Stand / Party Revive"-System den Charakter wechselt, und portet ihn stattdessen geheilt zurück. **Detail für Claude:** Cooldown: 80s. Mechanik: Platziert einen visuellen Marker. Der Buff läuft für 10s. Fällt `health.gd` in dieser Zeit auf 0, unterbricht das Skript den Tod, setzt HP auf 100, löscht alle aktiven DOTs (`StatusEffectManager`) und ändert die Position hart auf den Marker.
    

**Raze**

- **Sprengbot:** Ein eigener `CharacterBody3D`, der an Wänden (NavMesh) abprallt. Erkennt er einen Gegner, setzt er sein `_current_target` auf ihn, erhöht die Geschwindigkeit und erzeugt bei Kontakt eine Explosion (nutze die Logik aus `bomb.gd`). **Detail für Claude:** Cooldown: 14s. Mechanik: Lebensdauer 10s. Nutzt Raycasts nach vorne. Bei Gegnersicht: Speed x2. Bei `body_entered` explodiert er nach 0.1s (Radius 6.0, 40 Schaden).
    
- **Farbgrenaten:** Erweitert dein existierendes `bomb.gd`-System. Beim Auslösen der ersten Explosion werden 4 kleinere Bomben-Instanzen mit zufälligen Flugparabeln gespawnt. **Detail für Claude:** Cooldown: 16s. Mechanik: Erste Bombe hat eine Zündschnur von 2.0s. Das `explode()`-Event instanziert die 4 Mini-Bomben, gibt ihnen Random-Velocity-Vektoren (Streuung) und eine fixe Zündschnur von 0.8s.
    
- **Volles Rohr:** Ein schnelles, lineares Projektil, das Geometrie ignoriert, bis es trifft. Erzeugt am Trefferpunkt eine massive `Area3D`-Schadenszone mit starkem Knockback (Umgehung der normalen Reibung). **Detail für Claude:** Cooldown: 70s. Mechanik: 1.2s Ausrüst-Verzögerung vor dem Schuss. Das Projektil fliegt extrem schnell (Speed 30). Bei Kollision entsteht eine `Area3D` (Radius 14.0, 100 Schaden, Knockback-Impuls 40).
    

**Reyna**

- **Leergeborener Blick:** Im Top-Down blockt das die Sicht des Spielers nicht. Spawnt ein schwebendes Objekt. Es appliziert periodisch den Status `confused` auf alle `enemy_ai.gd`-Instanzen im Raum (`room_instance.gd`), was ihr Targeting stört. **Detail für Claude:** Cooldown: 15s. Mechanik: Objekt schwebt 3 Meter über dem Boden. Lebt für 3s. Sendet jede volle Sekunde (3 Ticks insgesamt) einen Area-Cast. Getroffene Gegner erhalten `confused` für 1.5s.
    
- **Verzehren:** Getötete Gegner droppen temporäre "Seelen"-Pickups (wie deine Münzen in `pickup.gd`). Der Magnetradius aus `player_stats.gd` x 3 also 3 fache radius zieht sie an und sie heilen den Spieler über `health.heal()`. **Detail für Claude:** Cooldown: Passiv/0s. Mechanik: `enemy_died` spawnt das Pickup (Lebensdauer 3s). Drückt der Spieler den Skill, wird `player_stats.magnet_radius` temporär mit 3 multipliziert. Kugel fliegt zum Spieler und heilt 40 HP über 2s verteilt (DOT-Heal).
    
- **Kaiserin:** Unsichtbarkeit ist im Singleplayer oft nutzlos. Ein zeitlich begrenzter Buff über `add_timed_modifier`, der Movement-Speed und Angriffsgeschwindigkeit in `player_stats.gd` drastisch erhöht. **Detail für Claude:** Cooldown: 60s. Mechanik: Dauer ist 15s. Setzt Speed +25%, AtkSpeed +50%. Jeder Kill (`enemy_died`) verlängert den laufenden Timer um weitere 5s.
    

**Yoru**

- **Fälschung:** Spawnt einen Dummy (`dummy.tscn`). Setzt temporär das Ziel (`_current_target`) aller Gegner im Raum auf diesen Dummy, damit sie ihn angreifen. Nimmt der Dummy Schaden, explodiert er und stunnt die Angreifer. **Detail für Claude:** Cooldown: 12s. Mechanik: Dummy läuft stur geradeaus (Speed 8). Lebt 5s. Wenn HP = 0, spawnt er sofort eine `Area3D` (Radius 6.0) und verteilt `stun` (Dauer 2s) an alle darin.
    
- **Torüberquerung:** Setzt einen statischen `Node3D`-Marker auf den Boden. Bei erneuter Aktivierung des Items wird die `global_position` des Spielers auf den Marker gesetzt. **Detail für Claude:** Cooldown: 20s nach Teleport. Mechanik: Erster Tastendruck spawnt Marker (lebt 20s). Zweiter Tastendruck zerstört Marker, teleportiert Spieler und ruft in `game_juice.gd` einen minimalen Hit-Stop ab, damit der Sprung Wucht hat.
    

### Initiatoren (Initiators)

**Sova**

- **Schockpfeil:** Ein Projektil, das bei `body_entered` an statischen Wänden seinen Bewegungsvektor reflektiert. Nach Gegnerkontakt entsteht ein Flächenschaden mit Distanz-Abfall. **Detail für Claude:** Cooldown: 10s. Mechanik: Reflektiert maximal 2 Mal. Beim 3. Wandkontakt oder beim 1. Gegnerkontakt zerschellt das Projektil. Area-Radius 8.0, 30 Zentrum-Schaden, am Rand weniger (Distance-Lerp).
    
- **Zorn des Jägers:** Ein gewaltiger, raumweiter Angriff. Zieht einen sehr breiten und langen Box-Shape-Raycast in Blickrichtung des Spielers, der Wände durchdringt und massiven Schaden verursacht. **Detail für Claude:** Cooldown: 70s. Mechanik: Spieler erhält Status `rooted` für bis zu 6s. Spieler kann 3 Mal klicken. Jeder Klick startet 1.2s Telegraph-VFX (Laser-Linie), dann feuert ein BoxShape (Breite 4.0, Länge 50.0) das 80 Schaden austeilt.
    

**Breach**

- **Nachbeben:** Da deine Räume grid-basiert sind, sind Raycasts durch Wände sehr fehleranfällig. Ein Angriff, der mit Verzögerung eine massive, zylinderförmige Schadens-Area exakt vor dem Spieler generiert. **Detail für Claude:** Cooldown: 14s. Mechanik: 2.5s optische Aufladezeit am Boden. Dann spawnt Zylinder-Hitbox (Radius 4.0). Tickt 3 Mal blitzschnell (alle 0.2s) für jeweils 25 Schaden.
    
- **Verwerfung:** Erzeugt eine langgezogene `Area3D` auf dem Boden in Blickrichtung. Appliziert deinen existierenden `stun.gd`-Status auf alle Gegner (deine eingebauten Diminishing Returns verhindern hier bereits Dauer-Stuns!). **Detail für Claude:** Cooldown: 15s. Mechanik: Taste halten vergrößert die Area-Länge (bis max 25.0 Meter). Loslassen friert die Area ein. 0.6s Verzögerung, dann erhalten alle darin 3s lang `stun.gd`.
    
- **Donnerrolli:** Spawnt kaskadierend mehrere BoxShapes hintereinander in einer Linie. Appliziert extremen Knockback und `stun`. **Detail für Claude:** Cooldown: 80s. Mechanik: 8 unsichtbare Kasten-Kollider (Breite 12.0) wandern vorwärts, jeder spawnt 0.2s nach dem vorherigen. Feinde erhalten vertikalen Impuls (Y-Achse +20) und 4s `stun.gd`.
    

**Fade**

- **Ergreifen:** Ein zielsuchendes Boden-Projektil (ähnlich `revenge_ghost.gd`). Setzt bei Kontakt den `confused` Status. **Detail für Claude:** Cooldown: 12s. Mechanik: Gleitet 3s lang über den Boden (Speed 14) und steuert automatisch das nächste `_current_target` an. Bei Kollision: 2.5s `confused`.
    
- **Fesseln:** Wirft ein Projektil, das am Boden eine Area erzeugt. Appliziert deinen `rooted.gd`-Status auf Gegner, sodass sie sich nicht bewegen können (aber noch angreifen dürfen). **Detail für Claude:** Cooldown: 14s. Mechanik: Bodenkontakt spawnt Area (Radius 6.0) für 4.5s. Jeder Feind verliert sofort 20 HP und erhält `rooted.gd`, solange er in der Zone gefangen ist.
    
- **Dämmerung:** Eine riesige Flächenwelle, die durch das Level gleitet. Setzt den Status `silenced` und einen kleinen DOT (Damage over Time, z.B. Säure) auf alle getroffenen Feinde. **Detail für Claude:** Cooldown: 70s. Mechanik: Flache BoxShape (Breite 40.0) bewegt sich 4s lang linear vorwärts. Alle getroffenen Gegner erhalten `silenced` für 8s und `acid.gd` (DOT).
    

### Taktiker (Controllers)

**Brimstone**

- **Stim-Bake:** Spawnt ein Gerät, das eine kreisförmige `Area3D` am Boden erzeugt. Spieler darin erhalten Buffs auf das Tempo über `player_stats.gd`. **Detail für Claude:** Cooldown: 15s. Mechanik: Gerät liegt für 10s. Area-Radius 8.0. Buff (über `add_timed_modifier`) gibt 12s lang Feuerrate +15% und Speed +10%.
    
- **Brandgranate:** Nutzt exakt die `bomb.gd` Mechanik für den Wurf, spawnt am Aufprallort aber deine `lemonade.gd`-Pfütze mit `burn.gd`-Schaden. **Detail für Claude:** Cooldown: 18s. Mechanik: Wurf mit Parabel. Zerschellt am Boden, Pfütze lebt 7s. Tickt alle 0.5s mit 15 Schaden pro Tick (`burn.gd`).
    
- **Satellitenangriff:** Der Spieler wählt über die existierende Orthografische Großkarte (`minimap_rooms.gd`) eine Position. Dort spawnt ein großer Zylinder-Collider, der massiven Flächenschaden austeilt. **Detail für Claude:** Cooldown: 80s. Mechanik: Klick auf Karte setzt Marker. Warn-Hologramm für 2.5s. Dann schaltet sich der Schadens-Zylinder (Radius 12.0) für 4s scharf. Tickt extrem schnell (alle 0.1s für 5 Schaden).
    

**Omen**

- **Paranoia:** Ein massiver, unsichtbarer Kollisions-Kasten, der geradeaus durch alle Raum-Wände fliegt und allen Gegnern `confused` verpasst. **Detail für Claude:** Cooldown: 15s. Mechanik: Box (Breite 8.0) fliegt linear vorwärts (Speed 25), Kollisions-Maske ignoriert Welt, checkt nur Feinde. Getroffene erhalten sofort 2.5s `confused`.
    

**Viper**

- **Schlangenbiss:** Spawnt eine Boden-Area (`pit_floor`), die den existierenden `acid.gd`-Status verteilt und eingehenden Schaden für die betroffenen Gegner erhöht. **Detail für Claude:** Cooldown: 12s. Mechanik: Projektil zerbricht am Boden. Area lebt 6s. Appliziert `acid.gd` und überschreibt `health.incoming_damage_multiplier` auf 2.0 für Feinde darin.
    

### Wächter (Sentinels)

**Sage**

- **Barrieren-Kugel:** Instanziert mehrere massive `StaticBody3D`-Eisblöcke (mit eigenem Health-Skript). Wichtig: Sie müssen das NavMesh via `NavigationObstacle3D` blockieren, damit die KI korrekt um sie herumläuft! **Detail für Claude:** Cooldown: 35s. Mechanik: Spawnt 4 Blöcke linear. Jeder Block hat `health.gd` (400 HP). Nach exakt 30s rufen noch stehende Blöcke automatisch `queue_free()` auf.
    
- **Verlangsamungs-Kugel:** Spawnt eine Area, die den `slow.gd`-Status auf Gegner (und Spieler!) überträgt, solange sie darin stehen. **Detail für Claude:** Cooldown: 12s. Mechanik: Kugel platzt am Boden. Area (Radius 7.0) lebt für 7s. Checkt jeden Physik-Frame auf Körper und wendet `slow.gd` an.
    
- **Heilungskugel:** Heilt den Spieler sofort über `health.heal()`. **Detail für Claude:** Cooldown: 40s. Mechanik: Appliziert einen Heal-over-Time. Heilt insgesamt 60 HP verteilt über 5s (12 HP/s). Nimmt der Spieler Schaden, pausiert der Heal für 2s.
    

**Killjoy**

- **Nanoschwarm:** Platziert ein unsichtbares Objekt am Boden. Wird es durch erneuten Tastendruck getriggert, aktiviert sich eine `Area3D`, die Schadens-Ticks verursacht. **Detail für Claude:** Cooldown: 20s (startet erst nach Detonation). Mechanik: Objekt wartet endlos auf Input. Bei Trigger: Radius 5.0 wird scharf für 4.5s. Verteilt alle 0.25s 10 Schaden.
    
- **Alarmbot:** Platziert eine Detektions-Area. Tritt ein Feind hinein, spawnt ein zielsuchender Bot, der zum Gegner sprintet, explodiert und Schaden macht. **Detail für Claude:** Cooldown: 20s. Mechanik: Radius 6.0. Bei Eintritt eines Feindes: 0.5s Windup, Bot sprintet (Speed 12) zum Feind. Explosion (`bomb.gd` Logik, Radius 4.0, 20 Schaden + `incoming_damage_multiplier` = 2.0).
    
- **Geschützturm:** Instanziert dein bestehendes modulares Turret-System (`turret.gd` und `turret_projectile.gd`), dreht aber die Zielerfassung um, sodass es Feinde anstatt den Spieler angreift. **Detail für Claude:** Cooldown: 45s. Mechanik: Turret hat 125 HP. Sichtkegel 180 Grad. Feuert alle 0.4s ein Projektil (6 Schaden). Zerstört sich selbst nach 30s.
    
- **Abriegelung:** Spawnt ein verwundbares Gerät. Nach Ablauf eines Timers iteriert das Skript über `get_tree().get_nodes_in_group("enemies")` und drückt allen auf der Map einen schweren `stun` rein. **Detail für Claude:** Cooldown: 100s. Mechanik: Gerät hat 200 HP. Sichtbarer Kuppel-Effekt wächst. Läuft das Gerät 13s ohne zerstört zu werden durch, wird `apply_stun(8.0)` auf alle Feinde im Raum aufgerufen.
