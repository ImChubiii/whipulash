---
commit: "e21923346cd27839b75c19c66a5808c3090c9045"
short_hash: "e219233"
date: 2026-08-12
author: "ImChubiii"
subject: "﻿feat: combat mechanics, weighted item drops and UI tweaks"
tags: [devlog]
---

# 2026-08-12 — ﻿feat: combat mechanics, weighted item drops and UI tweaks

- hitbox.gd: Implement critical hits with 1.5x multiplier and hit stop VFX
- acid.gd: Acid status effect now increases damage taken by 20%
- treasure_manager.gd: Add weighted item selection based on synergies
- treasure_manager.gd: Implement sacrifice pedestals for blood toll rooms
- damage_number.gd: Scale up crit numbers, unify dash damage color
- low_hp_vignette.gd: Reduce max opacity from 78% to 45% for visibility

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Status-Effekte:** [[acid]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `e219233` |
| Autor | ImChubiii |
| Datum | 2026-08-12 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-12_e219233_feat_combat_mechanics_weighted_item_drops_and_ui_t]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
