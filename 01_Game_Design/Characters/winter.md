---
id: "winter"
display_name: "Winter"
alternative_names: []
name_primary: "Magnetic Plasma"
alternative_names_primary: []
name_secondary: "Heavy Laser Stream"
alternative_names_secondary: []
speed: 19.0
max_health: 80.0
primary_cooldown: 0.4
secondary_cooldown: 0.0
tags: [character]
---

# Winter

## Basiswerte

| Wert | Betrag |
|---|---|
| Move-Speed | 19.0 |
| Max. HP | 80.0 |
| Primary-Basis-Cooldown | 0.4 s |
| Secondary-Basis-Cooldown | 0.0 s |

## Mechanik

**Magnetic Plasma (Primary):** feuert weich zielsuchende Plasma-Bolts (`scripts/vfx/homing_bolt.gd`, Ziel ueber `EnemyQuery.nearest_enemy()`) mit niedrigem Basisschaden. Jeder Treffer zieht den getroffenen Gegner per Einzelimpuls (`apply_knockback()`, gleiches Prinzip wie `magnet_core.gd`, nur schwaecher) Richtung Einschlag - stoert Movement, ohne ihn komplett heranzuziehen. **Heavy Laser Stream (Secondary):** kontinuierlicher Hitscan-Tick-Strahl (`scripts/vfx/beam_visual.gd`) waehrend RMB gehalten wird, ersetzt den klassischen Cooldown komplett durch eine Energiezelle (max. 10s Dauerfeuer, laedt in 5s wieder auf, wenn nicht gefeuert wird - Teilladung ist sofort wieder nutzbar, kein Mindest-Schwellenwert).

## Balancing

| Wert | Betrag |
|---|---|
| Magnetic Plasma - Schaden | 12 |
| Magnetic Plasma - Reichweite | 22 m |
| Magnetic Plasma - Zug-Impuls | 10.0 |
| Heavy Laser Stream - Schaden/Tick | 4 (alle 0.1 s, 40 DPS) |
| Heavy Laser Stream - Reichweite | 25 m |
| Heavy Laser Stream - Max. Batterie | 10 s Dauerfeuer |
| Heavy Laser Stream - Aufladezeit | 5 s (volle Batterie) |

## Verwandt

- [[combat_base]] — Basisklasse, stellt Cooldown-/Combo-/Hit-Lock-/Dash-
  System bereit; `scripts/characters/combat_winter.gd` ueberschreibt nur Primary/Secondary.
  Utility (Dash) und die zwei aktiven Item-Slots (Q/E) bleiben fuer alle vier
  Charaktere geteilt und unveraendert.
- [[player_base]] — Schwester-Komponente ("Combat" vs. player_base direkt am
  Charakter), definiert Move-Speed/HP-Basiswerte in `scenes/characters/char_winter.tscn`.
- [[magnet-kern]] — gleiches Einzelimpuls-statt-Dauerzug-Prinzip fuer den Magnetic-Plasma-Zug (`apply_knockback()`), nur schwaecher dosiert.

Siehe [[_MOC_Characters]] fuer den vollstaendigen Ueberblick aller vier
Charaktere.

## Erwaehnt in DevLogs

- [[2026-08-10_baeb020_featvfxuiitemslevelgen_ghost-trail-system_main-men|2026-08-10 — feat(vfx,ui,items,levelgen): Ghost-Trail-System, Main-Menu-Rework, Item-Testraum & Bugfixes]]
- [[2026-07-28_2642172_featitems_aktive_items_auf_qe-slots_umgestellt|2026-07-28 — feat(items): aktive Items auf Q/E-Slots umgestellt]]
- [[2026-07-24_d86f02e_refactorplayer_split_player_system_into_per-charac|2026-07-24 — refactor(player): split player system into per-character scenes with shared base classes]]
- [[2026-07-24_b39a97d_refactorplayer_split_player_system_into_per-charac|2026-07-24 — refactor(player): split player system into per-character scenes with shared base classes]]

## Quelle

`scenes/characters/char_winter.tscn`, `resources/char_4.tres`, `scripts/characters/combat_winter.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **inherits**: [[player_base]] (Confidence: 1.0)
