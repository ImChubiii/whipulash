---
script_path: scripts/room_commit_guard.gd
autoload_name: RoomGuard
tags: [architecture, autoload]
---

# room_commit_guard.gd

Autoload (`RoomGuard`). Schliesst eine Exploit-Luecke, durch die man
Kampfraeume betreten und wieder verlassen kann, ohne dass Gegner spawnen
oder Tueren verriegeln.

## Der Exploit: Wand-Hug am `EntryTrigger` vorbei

`room_instance.gd` loest den Kampf ueber einen `EntryTrigger` aus, dessen
Box von JEDER Seite um `entry_trigger_depth` eingerueckt ist
(`size_x = room_footprint.x - entry_trigger_depth * 2.0`). In einem
48×48-Raum bleibt dadurch ringsum ein ca. 9 m breiter Streifen, in dem der
Trigger gar nicht existiert. Da die Tueren mittig in den Waenden sitzen,
konnte man durch eine Tuer hereinkommen, an der Wand entlang zur naechsten
Tuer laufen und den Raum verlassen, ohne den Kern je zu beruehren — keine
Gegner, keine verriegelten Tueren, kein Kampf.

Die Einrueckung selbst ist kein Bug, sondern Absicht ("Anti-Baiting"): man
soll kurz in einen Raum hineinschauen duerfen, ohne sofort einen Kampf
auszuloesen. Den `EntryTrigger` einfach auf Raumgroesse aufzublasen wuerde
genau das zerstoeren.

## Die Loesung: zweite, unabhaengige Stufe mit zwei Ausloesern

`RoomGuard` haengt jedem Raum eine zusaetzliche `Area3D` (`CommitTrigger`)
ueber den vollen Grundriss und startet den Kampf, sobald EINE von zwei
Bedingungen erfuellt ist:

1. **Verweildauer** (`commit_dwell_time`, Default 0.35s) — der Spieler
   steht/kaempft/schaut sich laenger am Stueck in der **Innenzone** um.
2. **Zurueckgelegte Strecke** (`commit_travel_factor`, Anteil der kuerzeren
   Weltkante) — der Spieler hat innerhalb des Grundrisses genug Meter
   zurueckgelegt. Das ist der eigentliche Wand-Hug-Fall: von einer Tuer zur
   naechsten sind es quer durch den Raum immer mehr Meter als der
   Schwellwert, unabhaengig vom Lauftempo.

Eine reine Verweildauer waere ueber die Bewegungsgeschwindigkeit angreifbar
(ein Dash quer durch den Raum dauert deutlich unter einer Sekunde, und je
hoeher die Bewegungs-Stats im Run werden, desto zuverlaessiger ginge der
Trick wieder auf). Die Streckenbedingung ist gegen Tempo immun — wer
schneller ist, loest frueher statt spaeter aus. Kurzes Reinschauen und
Zurueckgehen bleibt weiterhin erlaubt, weil dabei weder genug Zeit noch
genug Strecke zusammenkommt.

## Warum die Commit-Area auf vollem Grundriss bleibt (`edge_inset = 0.0`)

Anders als der `EntryTrigger` deckt die `CommitTrigger`-Area bewusst den
kompletten Grundriss inklusive Randstreifen ab: die Streckenbedingung MUSS
genau den Randstreifen mitmessen koennen, sonst waere der Wand-Hug-Pfad
wieder ausserhalb der Ueberwachung. `commit_inner_zone_factor` (0.28)
ist die eigentliche Anti-Bait-Grenze und wirkt nur auf die Verweildauer,
nicht auf die Area-Groesse selbst.

## Zwei behobene, in den Kommentaren dokumentierte Bugs

- **"Feature tat gar nichts"**: die urspruengliche Fassung von `_attach()`
  brach nach `area.collision_mask = 0b101` mitten im Aufbau ab — kein
  `CollisionShape3D`, kein `add_child()`, kein Eintrag in `_watched`, kein
  Tick. GDScript parst das fehlerfrei (eine Funktion darf ueberall enden),
  es gab also weder Fehlermeldung noch Absturz, nur ein Autoload, das pro
  Raum eine Area erzeugte, sofort verwarf und danach nie wieder etwas tat.
  Der Wand-Hug war dadurch nie wirklich geschlossen.
- **"Raum verriegelt schon im Tuerrahmen"**: die Verweildauer lief anfangs
  ab dem ersten Frame im Grundriss statt erst in der Innenzone. Der
  Grundriss beginnt exakt an der Wandinnenseite, also im Tuerrahmen —
  0.35s Stehenbleiben beim Hineinschauen reichten damit schon zum
  Verriegeln. Fix: `dwell` laeuft jetzt nur, solange
  `absf(local.x) <= inner_half.x and absf(local.z) <= inner_half.y`
  erfuellt ist; verlaesst der Spieler die Area komplett, fallen sowohl
  `dwell` als auch `travel` auf 0 zurueck (kein Zusammensparen ueber
  mehrere kurze Besuche).

## Weltkoordinaten vs. lokale Koordinaten — eine dritte behobene Falle

`commit_travel_min` (7 m) war urspruenglich ein fester Meterwert, verglichen
mit `global_position`-Deltas — also Weltmetern. Der `LevelGenerator`
skaliert Raeume aber mit `room_scale` (2,2,2): aus 48 m Grundriss werden
96 m Weltkante, und 7 m waren darin nur ~7 % der Raumbreite — praktisch die
Tuerschwelle. `_attach()` leitet den Schwellwert deshalb jetzt explizit aus
`room.global_transform.basis.get_scale()` und `room.room_footprint` ab
(`world_x`/`world_z`), waehrend die Innenzonen-Pruefung bewusst in LOKALEN
Koordinaten (`room.to_local()`) laeuft, weil die von `room_scale`
unabhaengig sind.

## Warum als eigenstaendiger Autoload statt in `room_instance.gd`

Dieselbe Begruendung wie bei `Loot` und `Treasure`: `room_instance.gd` hat
rund 1800 Zeilen und sehr viel Zustand. Ein zusaetzliches Ueberwachungs-
volumen mit eigenem Timer laesst sich vollstaendig von aussen anhaengen —
und wenn sich das Feature nicht bewaehrt, entfernt man einen
Autoload-Eintrag statt einen Merge-Konflikt in der grossen Datei
aufzuloesen.

## Warum `_commit()` `_has_entered` direkt per `set()` setzt

`_commit()` ruft nicht nur `room.on_player_entered()` auf, sondern setzt
zusaetzlich `room.set("_has_entered", true)`. Grund: `room_instance.gd`s
`_physics_process()` schaltet erst bei `_has_entered == true` auf die
Ausbruch-Ueberwachung (`_check_escape()`) um. Ohne das Flag wuerde ein per
Guard erzwungener Kampf nie zuruecksetzen, wenn der Spieler den
verriegelten Raum trotzdem verlaesst — der Raum bliebe dauerhaft in einem
halb toten Zustand haengen. Der fuehrende Unterstrich bei `_has_entered`
ist in GDScript reine Namenskonvention, kein Zugriffsschutz — `set()` ist
hier also kein Trick, sondern der normale Weg, ein Feld auf einem fremden
Node zu setzen.

## Robustheit ueber `has_method()`/`get()` statt direkter Feldzugriffe

`_room_is_settled()` und `_commit()` fragen `is_cleared()`,
`_enemies_spawned`, `_requires_clear` und `on_player_entered()` ueber
`has_method()` bzw. `get()` ab statt ueber direkte Feldzugriffe. `get()`
liefert bei fehlendem Feld `null` statt eines Fehlers — das Script bleibt
dadurch auch mit einer aelteren oder abweichenden `RoomInstance`-Version
lauffaehig, statt bei fehlendem Feld zu crashen. Ebenso wird die
`CommitTrigger`-Area explizit mit `collision_layer = 0` /
`collision_mask = 0b101` konfiguriert — identisch zu `EntryTrigger` und
`PresenceArea` in `room_instance.gd`. Weicht das ab, findet die Area den
Spieler nicht, und das aeussert sich wieder nicht als Fehler, sondern nur
als stillschweigend wirkungsloses Feature (dieselbe Fehlerklasse wie der
urspruengliche `_attach()`-Bug oben).

## Verwandt

- [[loot_manager]] — beide Autoloads haengen sich unabhaengig ueber
  `SceneTree.node_added` an `RoomInstance`-Nodes; `RoomGuard` sichert den
  Anfang des Raum-Lebenszyklus (Kampf-Ausloesung) ab, `Loot` reagiert auf
  dessen Ende (`room_cleared`).
- [[level_generator]] — liefert `room_scale`/`room_footprint`, aus denen
  `RoomGuard` die Weltmasse fuer die Streckenbedingung ableitet.

## Erwaehnt in DevLogs

- [[2026-07-27_0c0e515_feat_treasure_room_items_hud_overhaul_balancing_mu]]
- [[2026-07-27_f88829f_feat_treasure_room_items_hud_overhaul_balancing_mu]]
- [[2026-08-01_3bbac00_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
- [[2026-08-01_5d2ca05_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
