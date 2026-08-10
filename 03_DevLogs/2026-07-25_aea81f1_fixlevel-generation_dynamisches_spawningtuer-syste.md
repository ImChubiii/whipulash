---
commit: "aea81f1a2e1983a5a759890a783fe228ef71abdb"
short_hash: "aea81f1"
date: 2026-07-25
author: "ImChubiii"
subject: "fix(level-generation): dynamisches Spawning/Tür-System für Grid-Level repariert"
tags: [devlog]
---

# 2026-07-25 — fix(level-generation): dynamisches Spawning/Tür-System für Grid-Level repariert

Behebt eine Kette von Bugs im neuen Isaac-artigen Grid-Level-System, die
verhinderten, dass der Player überhaupt spawnt bzw. sich frei bewegen kann.

- LevelGenerator: generate_new_stage() wird jetzt per call_deferred()
  aus _ready() ausgelöst statt synchron. Vorher schlug add_child() für
  jeden Raum fehl ("Parent node is busy setting up children"), weil
  current_scene während der initialen Ready-Kaskade noch blockiert war.

- LevelGenerator: room_scale-Property ergänzt. Skaliert RoomRoot beim
  Instanziieren uniform hoch (statt alle 9 Room-Templates einzeln
  umbauen zu müssen), world_pos wird entsprechend mit cell_size *
  room_scale berechnet, damit sich skalierte Räume nicht überlappen.

- PartyManager: _spawn_active_character() wird aus register_spawn_point()
  und setup_party() jetzt ebenfalls per call_deferred() aufgerufen.
  Gleicher Root-Cause wie oben, eine Ebene tiefer - PlayerSpawnPoint
  ruft register_spawn_point() synchron aus der Ready-Kaskade des
  jeweiligen RoomRoot auf, add_child() darauf schlug im selben Fenster
  fehl. switch_to() bleibt bewusst synchron (läuft zur Laufzeit, kein
  busy-Parent). Guard gegen doppeltes Spawnen durch die Verzögerung
  ergänzt.

- PlayerSpawnPoint: Player wird jetzt an get_tree().current_scene
  gehängt statt an get_parent() (= RoomRoot). Verhindert, dass der
  Player die room_scale-Skalierung des Raums erbt und beim Regenerieren
  eines Layouts (RoomRoot.queue_free()) mit gelöscht wird.

- RoomInstance: Gegner-Spawning von "sofort bei Raum-Instanziierung"
  auf "beim ersten Betreten durch den Player" umgestellt
  (prepare_enemies() merkt nur noch Typ/Anzahl vor, ein programmatisch
  erzeugter EntryTrigger (Area3D) löst _spawn_prepared_enemies() erst
  beim tatsächlichen Reinlaufen aus). Gegner hängen an current_scene
  statt RoomRoot (gleicher Skalierungs-/Cleanup-Grund wie beim Player,
  RoomInstance._exit_tree() räumt sie beim Despawn des Raums nach).

- RoomInstance: Tür-Deadlock behoben. _lock_exits(true) lief bisher
  bereits in _ready() für JEDEN Raum, unabhängig davon ob er Gegner
  hat - Entriegelung passierte nur in _on_enemy_died(), der aber nie
  erreicht wurde, weil Gegner erst beim Betreten spawnen sollten und
  der Raum dafür schon permanent versiegelt war. Neues Verhalten:
  Türen starten offen, sperren sich erst in on_player_entered() (nur
  bei Räumen mit EnemySpawnPoints) und öffnen sich wieder sobald alle
  gespawnten Gegner tot sind.

Betroffene Dateien:
- scenes/level_generation/level_generator.gd
- scenes/level_generation/room_instance.gd
- scripts/party_manager.gd
- scripts/player_spawn_point.gd

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `aea81f1` |
| Autor | ImChubiii |
| Datum | 2026-07-25 |
