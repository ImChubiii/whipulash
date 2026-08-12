---
commit: "5f8cd6d9eddc1b51fdb4836c26f2e236782778e0"
short_hash: "5f8cd6d"
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
| Commit | `5f8cd6d` |
| Autor | ImChubiii |
| Datum | 2026-08-12 |
