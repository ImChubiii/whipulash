---
id: "ningning"
display_name: "Ningning"
alternative_names: []
name_primary: "Quick Jab"
alternative_names_primary: []
name_secondary: "Heavy Haymaker"
alternative_names_secondary: []
speed: 19.5
max_health: 125.0
primary_cooldown: 0.18
secondary_cooldown: 3.0
tags: [character]
---

# Ningning

## Basiswerte

| Wert                     | Betrag |
| ------------------------ | ------ |
| Move-Speed               | 19.5   |
| Max. HP                  | 125.0  |
| Primary-Basis-Cooldown   | 0.18 s |
| Secondary-Basis-Cooldown | 3.0 s  |

## Mechanik

**Quick Jab (Primary):** sehr schneller, schwacher Nahkampf-Schlag mit minimalem Cooldown - haelt Gegner im Stunlock, unveraendertes Standardverhalten aus `combat_base.gd::_perform_primary()` (kurzer Hitbox-Puls). **Heavy Haymaker (Secondary):** wuchtiger Schlag mit sichtbarem Windup-Telegraph vor der Hitbox-Aktivierung, groessere Hitbox/Reichweite, Knockback, deutlich laengerer Cooldown - Combo-Finisher.

## Balancing

| Wert | Betrag |
|---|---|
| Quick Jab - Schaden | 10 |
| Quick Jab - Cooldown | 0.18 s (Combo-Reduktion bis 50%) |
| Heavy Haymaker - Schaden | 30 |
| Heavy Haymaker - Knockback | 12 |
| Heavy Haymaker - Windup | 0.35 s |
| Heavy Haymaker - Cooldown | 3.0 s |

## Verwandt

- [[combat_base]] — Basisklasse, stellt Cooldown-/Combo-/Hit-Lock-/Dash-
  System bereit; `scripts/characters/combat_ningning.gd` ueberschreibt nur Primary/Secondary.
  Utility (Dash) und die zwei aktiven Item-Slots (Q/E) bleiben fuer alle vier
  Charaktere geteilt und unveraendert.
- [[player_base]] — Schwester-Komponente ("Combat" vs. player_base direkt am
  Charakter), definiert Move-Speed/HP-Basiswerte in `scenes/characters/char_ningning.tscn`.


Siehe [[_MOC_Characters]] fuer den vollstaendigen Ueberblick aller vier
Charaktere.

## Erwaehnt in DevLogs

- [[2026-08-10_4b3999e_featvfxuiitemslevelgen_ghost-trail-system_main-men|2026-08-10 — feat(vfx,ui,items,levelgen): Ghost-Trail-System, Main-Menu-Rework, Item-Testraum & Bugfixes]]
- [[2026-07-28_ea34fe3_featitems_aktive_items_auf_qe-slots_umgestellt|2026-07-28 — feat(items): aktive Items auf Q/E-Slots umgestellt]]
- [[2026-07-24_d86f02e_refactorplayer_split_player_system_into_per-charac|2026-07-24 — refactor(player): split player system into per-character scenes with shared base classes]]
- [[2026-07-24_b39a97d_refactorplayer_split_player_system_into_per-charac|2026-07-24 — refactor(player): split player system into per-character scenes with shared base classes]]

## Quelle

`scenes/characters/char_ningning.tscn`, `resources/char_1.tres`, `scripts/characters/combat_ningning.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **inherits**: [[player_base]] (Confidence: 1.0)
