---
id: "karina"
display_name: "Karina"
alternative_names: []
name_primary: "Acid Rush Mode"
alternative_names_primary: []
name_secondary: "Phantom Execute"
alternative_names_secondary: []
speed: 20.0
max_health: 70.0
primary_cooldown: 0.0
secondary_cooldown: 0.0
tags: [character]
---

# Karina

## Basiswerte

| Wert | Betrag |
|---|---|
| Move-Speed | 20.0 |
| Max. HP | 70.0 |
| Primary-Basis-Cooldown | 0.0 s |
| Secondary-Basis-Cooldown | 0.0 s |

## Mechanik

**Acid Rush Mode (Primary):** KEIN klassischer Schlag - Primary IST die Stance. Gehalten: +Move-Speed (ueber `PlayerStats.add_modifier()`, nicht direkt geschrieben), alle Gegner in der Praesenz-Aura bekommen per `EnemyQuery.enemies_within()` wiederholt den [[acid]]-Statuseffekt aufgefrischt. `_primary_timer` wird zweckentfremdet: zaehlt waehrend der Stance die Restzeit runter, danach die kurze Wiedereintritts-Sperre - der bestehende Cooldown-Ring im HUD zeigt dadurch beides ohne HUD-Aenderung. **Phantom Execute (Secondary):** Toggle statt Halten - aktiviert Unsichtbarkeit (`GeometryInstance3D.transparency`) und volle Unverwundbarkeit (`Health.set_invulnerable_permanent()`). Beruehrte Gegner werden per Instanz-ID markiert; Deaktivierung (manuell oder nach Ablauf) detoniert alle markierten Gegner gleichzeitig - der Cooldown startet ERST nach dieser Detonation, nicht beim Aktivieren.

## Balancing

| Wert | Betrag |
|---|---|
| Acid Rush - Speed-Bonus | +20% |
| Acid Rush - Aura-Radius | 3 m |
| Acid Rush - Schaden/Tick | 15 (alle 0.4 s) |
| Acid Rush - Max. Dauer | 10 s |
| Acid Rush - Wiedereintritts-Sperre | 1.0 s |
| Phantom Execute - Max. Dauer | 5 s |
| Phantom Execute - Beruehrungsradius | 1.6 m |
| Phantom Execute - Detonationsschaden (Verbindungsdamage) | 100 (an ALLEN markierten Gegnern) |
| Phantom Execute - Entladungs-Explosion | 140 (4x Groesse, beim Verlassen der Tarnung) |
| Phantom Execute - Cooldown | 5.0 s (startet nach Detonation) |
| Phantom Execute - Wirkung | toetet [[fighter]] (100 HP) und [[stinger]] (25 HP), laesst [[colossus]] (400 HP) bei 45% HP |

## Verwandt

- [[combat_base]] — Basisklasse, stellt Cooldown-/Combo-/Hit-Lock-/Dash-
  System bereit; `scripts/characters/combat_karina.gd` ueberschreibt nur Primary/Secondary.
  Utility (Dash) und die zwei aktiven Item-Slots (Q/E) bleiben fuer alle vier
  Charaktere geteilt und unveraendert.
- [[player_base]] — Schwester-Komponente ("Combat" vs. player_base direkt am
  Charakter), definiert Move-Speed/HP-Basiswerte in `scenes/characters/char_karina.tscn`.
- [[acid]] — Statuseffekt hinter Acid Rush Mode, geteilt mit [[lemonade]] und [[saeure-sprinkler]].
- [[fighter]], [[stinger]], [[colossus]] — HP-Referenzen fuer die Phantom-Execute-Balancing (siehe oben).

Siehe [[_MOC_Characters]] fuer den vollstaendigen Ueberblick aller vier
Charaktere.

## Erwaehnt in DevLogs

- [[2026-08-14_e766d00_feat_umfangreiches_update_-_gameplay_ui_level-gene|2026-08-14 — feat: Umfangreiches Update - Gameplay, UI, Level-Generation und VFX]]
- [[2026-08-12_0484ccd_featfix_umfangreiches_gameplay-_ui-_balancing-over|2026-08-12 — feat/fix: Umfangreiches Gameplay-, UI- & Balancing-Overhaul]]
- [[2026-08-10_4b3999e_featvfxuiitemslevelgen_ghost-trail-system_main-men|2026-08-10 — feat(vfx,ui,items,levelgen): Ghost-Trail-System, Main-Menu-Rework, Item-Testraum & Bugfixes]]
- [[2026-07-28_ea34fe3_featitems_aktive_items_auf_qe-slots_umgestellt|2026-07-28 — feat(items): aktive Items auf Q/E-Slots umgestellt]]
- [[2026-07-24_d86f02e_refactorplayer_split_player_system_into_per-charac|2026-07-24 — refactor(player): split player system into per-character scenes with shared base classes]]

## Quelle

`scenes/characters/char_karina.tscn`, `resources/char_3.tres`, `scripts/characters/combat_karina.gd`

## 🧠 Semantische Verbindungen (Graphify)
- **inherits**: [[player_base]] (Confidence: 1.0)
