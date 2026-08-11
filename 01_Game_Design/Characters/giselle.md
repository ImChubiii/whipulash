---
id: "giselle"
display_name: "Giselle"
name_primary: "Uzi Spray"
name_secondary: "Sniper Burst"
speed: 14.0
max_health: 130.0
primary_cooldown: 0.08
secondary_cooldown: 5.0
tags: [character]
---

# Giselle

## Basiswerte

| Wert | Betrag |
|---|---|
| Move-Speed | 14.0 |
| Max. HP | 130.0 |
| Primary-Basis-Cooldown | 0.08 s |
| Secondary-Basis-Cooldown | 5.0 s |

## Mechanik

**Uzi Spray (Primary):** Hitscan-Dauerfeuer ohne jeglichen Streu-Winkel (`scripts/core/hitscan.gd`), haelt bei gehaltener LMB ueber den unveraenderten Halten-Loop aus `combat_base.gd`. 25-Schuss-Magazin, danach fester 1s-Reload (ueberschreibt `_primary_timer` statt eines eigenen Timers, siehe `_get_effective_primary_cooldown()`-Override). **Sniper Burst (Secondary):** komplett eigenes Press/Hold/Release-Handling (`_poll_secondary_input()`-Override) - RMB halten zoomt die Kamera-FOV runter (Zielfernrohr-Simulation, unabhaengig vom bestehenden SpringArm3D-Scroll-Zoom), Loslassen loest einen 3-Schuss-Burst aus UND erst dann den 5s-Cooldown.

## Balancing

| Wert | Betrag |
|---|---|
| Uzi Spray - Schaden/Schuss | 7 |
| Uzi Spray - Magazin | 25 Schuss |
| Uzi Spray - Reload | 1.0 s |
| Uzi Spray - Reichweite | 40 m |
| Sniper Burst - Schaden/Schuss | 100 (x3 = 300 Gesamt) |
| Sniper Burst - Zoom-FOV | 28 Grad |
| Sniper Burst - Cooldown | 5.0 s (startet bei Release) |
| Sniper Burst - Wirkung | one-shottet [[fighter]] (100 HP) und [[stinger]] (25 HP), laesst [[colossus]] (400 HP) bei 25% HP |

## Verwandt

- [[combat_base]] — Basisklasse, stellt Cooldown-/Combo-/Hit-Lock-/Dash-
  System bereit; `scripts/characters/combat_giselle.gd` ueberschreibt nur Primary/Secondary.
  Utility (Dash) und die zwei aktiven Item-Slots (Q/E) bleiben fuer alle vier
  Charaktere geteilt und unveraendert.
- [[player_base]] — Schwester-Komponente ("Combat" vs. player_base direkt am
  Charakter), definiert Move-Speed/HP-Basiswerte in `scenes/characters/char_giselle.tscn`.
- [[fighter]], [[stinger]], [[colossus]] — HP-Referenzen fuer die Sniper-Burst-Balancing (siehe oben).

Siehe [[_MOC_Characters]] fuer den vollstaendigen Ueberblick aller vier
Charaktere.

## Erwaehnt in DevLogs

- [[2026-08-10_baeb020_featvfxuiitemslevelgen_ghost-trail-system_main-men|2026-08-10 — feat(vfx,ui,items,levelgen): Ghost-Trail-System, Main-Menu-Rework, Item-Testraum & Bugfixes]]
- [[2026-07-28_2642172_featitems_aktive_items_auf_qe-slots_umgestellt|2026-07-28 — feat(items): aktive Items auf Q/E-Slots umgestellt]]
- [[2026-07-24_d86f02e_refactorplayer_split_player_system_into_per-charac|2026-07-24 — refactor(player): split player system into per-character scenes with shared base classes]]
- [[2026-07-24_b39a97d_refactorplayer_split_player_system_into_per-charac|2026-07-24 — refactor(player): split player system into per-character scenes with shared base classes]]

## Quelle

`scenes/characters/char_giselle.tscn`, `resources/char_2.tres`, `scripts/characters/combat_giselle.gd`
