---
script_path: scripts/enemy_sandbox_room.gd
autoload_name: EnemySandboxRoom
tags: [architecture, debug-tool]
---

# enemy_sandbox_room.gd

Admin/Debug-Autoload: ein isolierter Raum, in dem jeder Gegnertyp — die drei
Level-Generator-Gegner ([[fighter]]/[[stinger]]/[[colossus]], per
`scene.instantiate()`) UND die sechs [[custom_enemy_base]]-Prototypen (per
`ClassName.new()`, da sie keine `.tscn` haben) — frei und beliebig oft ueber
Interact-Bodenplatten gespawnt werden kann. Kein Teil des normalen Spiels;
Zugang ueber den "Sandbox"-Button im Admin-Panel des Pause-Menues
(`pause_menu.gd`, `_build_admin_panel()` → `EnemySandboxRoom.teleport_player_in()`).
Die urspruenglichen physischen Teleporter-Pads (`[[debug_teleporter]]`) wurden
entfernt; das Script bleibt nur noch als leeres Autoload registriert.

**Das ist Stand jetzt der EINZIGE Ort, an dem die sechs neuen Gegnertypen
ueberhaupt spawnen** — sie stecken in keiner `resources/enemies/es_*.tres`-
Spawn-Tabelle und sind damit nicht Teil des [[level_generator]]-Threat-Budgets.

## Baumuster

Lazy-Bau beim ersten Betreten, Stilllegung (`PROCESS_MODE_DISABLED`) bei
Abwesenheit, Rueckweg-Pad — identisch zu `item_test_room.gd`. Zwei Reihen
Spawn-Pads: Reihe 0 die drei normalen Level-Gegner, Reihe 1 (weiter hinten,
damit ein kreisender Divebomber/Plasmastrahl-Bot nicht sofort ueber der
vorderen Reihe haengt) die sechs neuen Typen.

Gespawnte Gegner haengen direkt unter der aktuellen Szene (wie normale
Level-Gegner in `room_instance.gd`), nicht unter der Sandbox-Root — ihre
`_physics_process()`-Ketten laufen dadurch nur, waehrend sie existieren.
Die "GEGNER LOESCHEN"-Plattform und das Verlassen des Raums entfernen alle
noch lebenden Sandbox-Gegner per Zwangsentfernung (ruft explizit
`_cleanup_effects()` auf, siehe [[custom_enemy_base]] — `Health.died` feuert
bei `queue_free()` NICHT).

## Verwandt

- [[custom_enemy_base]] — Basisklasse aller sechs neuen Typen.
- [[level_generator]] — die "richtige" Spawn-Instanz, in die diese Typen
  noch integriert werden muessen.

## Erwaehnt in DevLogs

- —

## 🧠 Semantische Verbindungen (Graphify)
- **calls**: [[enemy_sandbox_room]] (Confidence: 1.0)
- **referenced_by (implements)**: [[divebomber]] (Confidence: 1.0)
- **referenced_by (implements)**: [[magnet-kern]] (Confidence: 1.0)
- **referenced_by (implements)**: [[moerser-bot]] (Confidence: 1.0)
- **referenced_by (implements)**: [[plasmastrahl-bot]] (Confidence: 1.0)
- **referenced_by (implements)**: [[saeure-sprinkler]] (Confidence: 1.0)
- **referenced_by (implements)**: [[schild-drohne]] (Confidence: 1.0)
