---
commit: "b39a97d8a6629df150f28acdbaabdcb465dc5c76"
short_hash: "b39a97d"
date: 2026-07-24
author: "ImChubiii"
subject: "refactor(player): split player system into per-character scenes with shared base classes"
tags: [devlog]
---

# 2026-07-24 — refactor(player): split player system into per-character scenes with shared base classes

Rename generic Player to character-specific scenes (Ningning/Giselle/Karina/Winter),
each with its own Combat script and abilities instead of a shared data-driven
AbilitySet. Introduces PlayerBase/CombatBase for shared logic, CharacterData
to replace AbilitySet, and instance-swap character switching via PartyManager.

- Add PlayerBase (scripts/player_base.gd) and CombatBase (scripts/combat_base.gd)
  with shared movement/camera/combat logic; character subclasses override
  ability behavior and cooldowns via _init()
- Add scenes/characters/char_{ningning,giselle,karina,winter}.tscn +
  matching scripts/characters/{char,combat}_*.gd
- Replace scripts/ability_set.gd with scripts/character_data.gd
  (metadata only, no cooldowns; adds player_scene reference)
- Rewrite PartyManager: spawns/despawns the active character instance on
  switch instead of swapping data on a shared node; adds 10s switch
  cooldown on the character left behind; disables collision/processing on
  the outgoing instance before queue_free() to prevent physics push on
  rapid switching
- Add PlayerSpawnPoint (scripts/player_spawn_point.gd) to replace hardcoded
  Player instances in level scenes
- Update HUD/PartySlot to react to PartyManager.active_player_changed
  instead of resolving Player once; add switch-cooldown overlay to
  PartySlot UI (mirrors AbilitySlot cooldown visuals); party names now
  shown for inactive slots too
- Fix stale Player references in enemy_ai.gd, target_reticle.gd,
  death_screen.gd by subscribing to active_player_changed instead of a
  one-time find_child("Player") lookup
- Update all 7 level scenes and party_setup.gd/party_slot.gd for the new
  CharacterData/PlayerSpawnPoint architecture

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `b39a97d` |
| Autor | ImChubiii |
| Datum | 2026-07-24 |
