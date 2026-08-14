---
commit: "0887d72e86919fd7d5269f4356062bc700b1fac4"
short_hash: "0887d72"
date: 2026-07-23
author: "ImChubiii"
subject: "feat(hud): add full party HUD with abilities, minimap and character switching"
tags: [devlog]
---

# 2026-07-23 — feat(hud): add full party HUD with abilities, minimap and character switching

- Add AbilitySet resource for per-character icons, cooldowns, and stats
- Add PartyManager autoload: 4-member party, HP mirroring for inactive
  members, character switching via input actions 1-4
- Extend Combat with Q/E ability slots (cooldowns, signals, generic
  get_cooldown_percent/remaining API for slot 0-4)
- Add PartySlot UI: portrait + HP bar with color gradient, active
  character scales up and reveals name
- Add AbilitySlot UI: radial cooldown overlay, countdown label,
  ready-flash animation
- Add Minimap: top-down orthographic SubViewport camera following
  player, zone name via Area3D "zone" group, live X/Y coordinates
- Consolidate hud.tscn into a single reusable scene, replacing
  duplicated HUD nodes across 5 level scenes
- Fix: rename PartySlot.get_index() to get_party_index() to avoid
  signature clash with inherited Node.get_index(bool)

New files: scripts/{ability_set,party_manager,ability_slot,party_slot,
minimap,zone_marker,party_setup}.gd, scenes/{hud,party_slot,
ability_slot}.tscn, resources/char_1-4.tres

Modified: scripts/combat.gd, scripts/hud.gd

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `0887d72` |
| Autor | ImChubiii |
| Datum | 2026-07-23 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
