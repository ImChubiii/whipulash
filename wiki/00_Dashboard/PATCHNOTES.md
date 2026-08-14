---
tags: [patch-notes, devlog]
---

# Patch Notes — Lemonade

> *Entwicklungs-History des Spiels, für Spieler aufbereitet*
>
> Jeder Tag wird von Hand zusammengefasst (Devlogs + Chat-Protokolle als Quelle) statt automatisch aus rohen Commit-Messages generiert. `generate_patchnotes.py` pflegt nur noch das Skelett (Datums-Header + Verlinkungen) und lässt den redaktionellen Text unangetastet — siehe Kopfkommentar dort. Tage ohne handgeschriebenen Text bekommen automatisch einen mit *„automatisch, noch nicht redigiert“* markierten Platzhalter aus echten DevLog-Commits (oder, falls keine existieren, aus Chat-Titeln) statt des alten reinen Hinweistexts.

## 14.08.2026

**Fokus:** Dokumentations-System fertiggestellt (Chat-Tagging, Patchnotes-Workflow, Doku-Guide)

### Zusammenfassung
Kein Gameplay-Tag, sondern der Abschluss der Vault-Dokumentationsarbeit: alle 04_Chat_Prompts/-Dateien bekamen einheitliche Thema-/KI-Quellen-Tags, PATCHNOTES.md wurde auf echte handgeschriebene Tages-Zusammenfassungen umgestellt, und ein neuer Dokumentations-Guide (00_Dashboard/01_Dokumentations_Guide.md) erklärt das gesamte System. Dabei kam heraus, dass parallel zu dieser Arbeit auch eine Antigravity-Session eigene Anläufe an einem Patchnotes-Skript (`generate_patchnotes_v2/v3/v4.py`) unternommen hatte — die sind nie im Repo gelandet, aber genau diese Session hat als Nebenprodukt den Hinweis geliefert, dass auch ein Export-Werkzeug für Antigravity-Chats fehlte. Das wurde ergänzt (`98_Scripts/export_antigravity.py`), zusammen mit einem Nachtrag aller bis dahin fehlenden Antigravity- und Claude-CLI-Chatprotokolle.

### Wichtigste Änderungen
- Alle Chat-Prompt-Dateien einheitlich getaggt (Thema + KI-Quelle: Gemini/Claude/Claude CLI/Antigravity)
- `PATCHNOTES.md` komplett auf handgeschriebene Tages-Zusammenfassungen umgestellt, Skript pflegt nur noch Skelett + Verlinkungen
- Neuer Dokumentations-Guide für den gesamten Vault (`00_Dashboard/01_Dokumentations_Guide.md`)
- `98_Scripts/export_antigravity.py` (neu) und `98_Scripts/resolve_claude_ki_art.py` als dauerhafte Werkzeuge ergänzt
- 16 bis dahin fehlende Chat-Protokolle nachgetragen (12 Antigravity-, 4 Claude-CLI-Sessions)
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-14_patchnotes-skript-weiterentwicklung-und-doku-guide-feedback]]

---

## 13.08.2026

**Fokus:** KayKit-Charakter-Reskin für Gegner & Animations-Retargeting

### Zusammenfassung
Die drei Standard-Gegnertypen (Fighter, Colossus, Stinger) liefen bisher alle auf einem einzigen, generischen Lowpoly-Roboter-Modell — heute wurden sie stattdessen auf echte KayKit-Skelette (Warrior/Minion/Rogue) umgestellt. Das dafür nötige Animations-System wurde grundlegend überarbeitet: Animationen werden jetzt dynamisch auf das jeweilige Ziel-Skelett retargeted, statt starr von einem einzigen Rig-Typ auszugehen. Auch die Bodenausrichtung der Gegner wurde präziser gemacht (echte Fußknochen statt "tiefster Knochen der Hierarchie"), damit Modell und Animation nicht mehr auseinanderlaufen. Die bisherige Zickzack-Ausweichbewegung der Gegner-KI ist komplett entfernt worden. Daneben gab es zwei weitere Runden Feinschliff: das Tutorial wurde spürbar schwerer (doppelte Gegnerzahl pro Raum, plus ein Leck behoben, durch das die Tutorial-UI bei Admin-Teleports sichtbar blieb) und Gegner wurden global kampfstärker (+30 % HP, +10 % Angriffstempo). Ein hartnäckiger Bug, bei dem Scout/Fighter manchmal in der Level-Geometrie feststeckten, wurde systemisch für alle 39 Raum-Vorlagen auf einmal behoben.

### Wichtigste Änderungen
- KayKit-Skelett-Reskin für Fighter/Colossus/Stinger (Warrior/Minion/Rogue), inkl. Boden-/Größen-Feintuning
- `animation_manager.gd` baut nötigenfalls selbst einen AnimationPlayer und retargeted Animationen dynamisch aufs Ziel-Skelett
- Gegner werden jetzt anhand der Fußknochen geerdet statt anhand des tiefsten Hierarchie-Knochens
- Zickzack-Ausweichbewegung der Gegner-KI vollständig entfernt
- VFX-Anpassungen für Ningning, Winter-Animations-Retargeting-Fix + neuer Mündungsfeuer-Effekt
- Tutorial-Kampfräume: doppelt so viele Gegner pro Raum
- Tutorial-UI verschwindet jetzt auch bei jedem Admin-/Debug-Teleport korrekt (vorher blieb sie bei bestimmten Sprüngen fälschlich sichtbar)
- Globale Gegner-Buffs: +30 % HP (ein zentraler Multiplikator für alle Gegnertypen), +10 % Angriffstempo (pro Gegner-System einzeln skaliert)
- Spawn-Marker, die versehentlich in Level-Geometrie (Säulen/Wände) lagen, werden jetzt per Physik-Check automatisch übersprungen — behebt "Scout/Fighter stecken fest" systemisch für alle 39 Raum-Vorlagen
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-13_charakter-beschreibung-wechselt-mit-aktivem-charakter]]
> - [[2026-08-13_godot-projekt-aufgabenliste]]
> - [[2026-08-13_ningning-dash-beschreibung-als-block]]
> - [[2026-08-13_prompt-fuer-boden-textur-und-model-ausrichtung]]
> - [[2026-08-13_prompt-fuer-karina-item-fix-formulieren]]
> - [[2026-08-13_scout-und-fighter-animationen-und-modelle-beheben]]
> - [[2026-08-13_test-vfx-ordner-ingame-anzeigen]]
> - [[2026-08-13_tutorial-prompt-formulieren]]
> - [[2026-08-13_weitere-anpassungen-ui-aenderungen-und-bugfixes]]
> - [[2026-08-13_wo-sind-die-patchnotes-bei-obsidian]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-08-13_5da0d91_feat_kaykit-skeleton-reskin_fuer_fightercolossusst]]
> - [[2026-08-13_bf2b451_update_vfx_for_ningning_fix_winter_animation_retar]]

---

## 12.08.2026

**Fokus:** Nahkampf-Feinschliff (Crits, Säure, Schatzräume) + große Wiki-Überarbeitung

### Zusammenfassung
Ein Tag mit zwei sehr unterschiedlichen Schwerpunkten. Auf der Gameplay-Seite kamen kritische Treffer (1,5-facher Schaden mit Hit-Stop-Effekt), ein neues Verletzlichkeits-Verhalten für Säure (+20 % erlittener Schaden aus allen Quellen) sowie Blutzoll-Räume (kosten HP statt eines Gratis-Items) und eine gewichtete, synergiebasierte Item-Auswahl in Schatzräumen dazu. Parallel wurde die Minimap von einem schematischen 2D-Grid auf eine echte 3D-Draufsicht mit Raumzustands-Färbung und Spezialraum-Icons umgestellt, mehrere Charaktere bekamen Kampf-Feintuning, und ein großer Teil des Tages floss in eine umfassende Überarbeitung des gesamten Game-Design-Wikis (deutsches Fandom-Format, neue Blueprint-Dokumente, Umlaut-Bereinigung, eigene Graph-View-Farben) sowie das erstmalige Einchecken der kompletten Chat-Prompt- und Notizen-Historie ins Repository. Am späteren Abend kam noch eine Balancing-Runde am Threat-Budget-System dazu (fast alle Gegnerkosten neu justiert, damit teurere Elite-Gegner nicht mehr im selben Preissegment wie Standard-Gegner landen), dazu ein Fix für eine Abgrund-Falle, durch die Gegner unsichtbar unter dem sichtbaren Boden landen konnten.

### Wichtigste Änderungen
- Kritische Treffer (1,5x Schaden + Hit-Stop-VFX), größere Schadenszahlen für Crits
- Säure verursacht jetzt zusätzlich Verletzlichkeit (+20 % erlittener Schaden aus allen Quellen)
- Blutzoll-Räume (Opfer-Pedestal kostet HP) und gewichtete, synergiebasierte Item-Auswahl in Schatzräumen
- Minimap: 2D-Grid-Overlay entfernt, echte 3D-Draufsicht mit Raumzustands-Färbung + Spezialraum-Icons
- Giselle/Karina/Winter: Kamera-Shift beim Zielen, neue Lifesteal-Passive, Luftangriff-Hitbox-Fix, Enemy-ESP-Hitboxen
- Automatisches Q/E-Slot-Swapping beim Aufheben am Schatzsockel
- Niedrige-HP-Vignette abgeschwächt (78 % → 45 % max. Deckkraft) für bessere Übersicht im Kampf
- Komplette Überarbeitung des Game-Design-Wikis ins deutsche Fandom-Format, Chat-Prompt-/Notizen-Archiv erstmals versioniert
- Gegner-Kosten (Threat-Budget) neu balanciert: Divebomber 2→3, Schild-Drohne 4→6, Säure-Sprinkler 5→7, Mörser-Bot 6→8, Plasmastrahl-Bot 10→12, Colossus 10→15 (Elite-Gegner waren vorher genauso teuer wie normale)
- Abgrund-Falle behoben: Gegner konnten durch ein schmales Zeitfenster im Void-Kill-Bereich hindurchtunneln und unsichtbar/unerreichbar auf dem Boden darunter landen — Kill-Zone auf fast die gesamte Schachttiefe verbreitert
- Gemeldeter Bug "Schaden beim Aufsammeln normaler Items" untersucht (Ursache nicht reproduziert, alle drei Verdachtsmomente geprüft) — `treasure_manager.gd` gehärtet und mit Debug-Logging versehen, um die Ursache beim nächsten Auftreten zu fassen
- Weitere gemeldete, an dem Abend besprochene Bugs (Giselles Uzi-Partikel ragen in die Kamera, Divebomber-Flughöhe, ein Absturz beim Charakterwechsel während eines gehaltenen Angriffs)
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-12_balanciere-gegner-kosten-fuer-spielmechanik]]
> - [[2026-08-12_bitte-analysiere-alle-ordner-und-bewerte-wie-relevant]]
> - [[2026-08-12_bitte-fge-alle-chats-in-mein-obsidian-ein]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-1]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-10]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-11]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-12]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-3]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-4]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-5]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-6]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-7]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-8]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-9]]
> - [[2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade]]
> - [[2026-08-12_greeting]]
> - [[2026-08-12_kannst-du-mein-obsidian-sehen]]
> - [[2026-08-12_md]]
> - [[2026-08-12_naechste-optimierungsprozesse-fuer-das-spiel]]
> - [[2026-08-12_persoenliche-daten-im-projekt-pruefen]]
> - [[2026-08-12_privates-github-repo-einrichten]]
> - [[2026-08-12_schau-dir-den-letzten-commit-an-und-den]]
> - [[2026-08-12_slash-command-graphify-1]]
> - [[2026-08-12_slash-command-graphify-2]]
> - [[2026-08-12_slash-command-graphify-3]]
> - [[2026-08-12_slash-command-graphify-4]]
> - [[2026-08-12_slash-command-graphify-args-raw---obsidian---obsidian-dir-brain]]
> - [[2026-08-12_slash-command-graphify]]
> - [[2026-08-12_user-raw-barrelbroken-von-den-fpsdungeonextras-lschen-das]]
> - [[2026-08-12_user-raw-bitte-berprfe-und-repariere-das-ganze-1]]
> - [[2026-08-12_user-raw-bitte-berprfe-und-repariere-das-ganze]]
> - [[2026-08-12_user-raw-bitte-entferne-diese-folgenden-dateien-1]]
> - [[2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought]]
> - [[2026-08-12_user-raw-ich-muss-meine-situation-erklren-mein]]
> - [[2026-08-12_user-raw-irgendwie-komme-ich-nicht-aus-dem]]
> - [[2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems]]
> - [[2026-08-12_user-raw-raum-ideen-balancing-entwurf-brainstorming-sammlung-fr-neue]]
> - [[2026-08-12_user-raw-uggestions-unless-specifically-asked-uggestions-unless-1]]
> - [[2026-08-12_user-raw-uggestions-unless-specifically-asked-uggestions-unless]]
> - [[2026-08-12_user-raw-where-are-the-forks-where-are]]
> - [[2026-08-12_was-fehlt-mir-in-meinem-spiel-skip-to]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-08-12_0201145_docs_correct_sequential_numbering_for_schulhof_ite]]
> - [[2026-08-12_0484ccd_featfix_umfangreiches_gameplay-_ui-_balancing-over]]
> - [[2026-08-12_3bce52a_chore_remove_obsidian_and_graphify-out_from_gitign]]
> - [[2026-08-12_45f01d1_docs_fix_corrupted_game_design_blueprint_and_appen]]
> - [[2026-08-12_5f8cd6d_feat_combat_mechanics_weighted_item_drops_and_ui_t]]
> - [[2026-08-12_7e2352c_docs_add_dash_damage_visual_feedback_concept_to_bl]]
> - [[2026-08-12_892303c_docs_add_crit_damage_visual_feedback_concept_to_bl]]
> - [[2026-08-12_a929cc8_docs_fix_encoding_of_newly_added_schulhof_items_in]]
> - [[2026-08-12_acbe958_docswiki_overhaul_of_game_design_docs_item_balance]]
> - [[2026-08-12_c19780a_docswiki_overhaul_of_game_design_docs_item_balance]]
> - [[2026-08-12_d92384f_docs_fully_restore_05_gedanken_contents_and_re-app]]
> - [[2026-08-12_e219233_feat_combat_mechanics_weighted_item_drops_and_ui_t]]
> - [[2026-08-12_e458c87_docs_add_concrete_godot_implementation_hints_for_c]]
> - [[2026-08-12_ea4bcd0_chore_encrypt_personal_notes_and_prompts]]
> - [[2026-08-12_ed60512_docs_restore_and_track_04_chat_prompts_and_05_geda]]
> - [[2026-08-12_ef1f5c2_docs_adjust_item_table_formatting_for_item_db_comp]]
> - [[2026-08-12_f23c551_feat_combat_mechanics_weighted_item_drops_and_ui_t]]
> - [[2026-08-12_fb88478_chore_add_obsidian_workspaces_and_os_temp_files_to]]

---

## 11.08.2026

**Fokus:** Charakter-Kampf-Kits final ausformuliert, Raum-Clear-Logik poliert

### Zusammenfassung
Alle vier Charaktere bekamen ihre endgültig ausformulierten Kampf-Kits statt Platzhalter-Fähigkeiten, begleitet von diversen kleineren Bugfixes. Zusätzlich wurde die Logik, die erkennt, wann ein Raum wirklich "gecleart" ist, finalisiert und die Gegner-Visuals bekamen einen Feinschliff. Der restliche Tag floss in Dokumentationspflege — die Raum- und Gegner-Wiki-Seiten wurden an den neuen Sandbox-Status der sechs Prototyp-Gegner angepasst.

### Wichtigste Änderungen
- Charakterspezifische Kampf-Kits für alle vier Helden final ausformuliert, samt Bugfixes
- Raum-Clear-Erkennung finalisiert, Gegner-Visuals poliert
- Gegner-/Raum-Dokumentation an den Sandbox-Status neuer Prototyp-Gegner angepasst
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-11_charakter-angriffe-rework-ausformulierung-1]]
> - [[2026-08-11_charakter-angriffe-rework-ausformulierung]]
> - [[2026-08-11_gameplay-leveldesign-berarbeitung-1]]
> - [[2026-08-11_gameplay-leveldesign-berarbeitung]]
> - [[2026-08-11_gegner-und-spawn-raten-bersicht-1]]
> - [[2026-08-11_gegner-und-spawn-raten-bersicht]]
> - [[2026-08-11_greeting]]
> - [[2026-08-11_implement-various-game-improvements-and-bug-fixes]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-08-11_0680bbe_fix_finalize_room_clearance_logic_and_polish_enemy]]
> - [[2026-08-11_0bd63e1_feat_character-specific_combat_kits_for_all_4_hero]]
> - [[2026-08-11_4879445_update_documentation_and_ignore_aider_files]]
> - [[2026-08-11_5177896_feat_character-specific_combat_kits_for_all_4_hero]]
> - [[2026-08-11_69742bf_update_room_and_enemy_documentation_to_reflect_san]]
> - [[2026-08-11_bf671c8_fix_finalize_room_clearance_logic_and_polish_enemy]]
> - [[2026-08-11_e142e9f_update_documentation_and_ignore_aider_files]]
> - [[2026-08-11_ea0fce8_update_room_and_enemy_documentation_to_reflect_san]]

---

## 10.08.2026

**Fokus:** Ghost-Trail-VFX, Hauptmenü-Rework, Vault-Migration ins Repo

### Zusammenfassung
Ein großer Feature- und Aufräum-Tag. Jeder Charakter bekam einen zweifarbigen Ghost-Trail-Effekt (Lauf- und Angriffs-Trail) sowie größere, charakterfarbige Treffer-Partikel, das Hauptmenü wurde komplett neu gebaut (3D-SubViewport-Hintergrund, Live-Charaktervorschau, neues Layout), und ein neuer Admin-Item-Testraum erlaubt es seitdem, jedes Item isoliert über einen Teleporter zu testen. Daneben wurden Hitboxen mehrerer Hazards (Turrets, Auge, Köder, Nanoschwarm) verkleinert und Lockdown trifft jetzt korrekt die sichtbare Telegraph-Position statt den aktuellen Spielerstandort. Der zweite Schwerpunkt des Tages war strukturell: Der Obsidian-Vault lag bisher nur lose in einem Warp-Worktree-Ordner und wurde erstmals richtig ins Haupt-Repository aufgenommen, inklusive einer vollständigen DevLog-Liste, sechs neu erfassten Sandbox-Gegnertypen und automatisch aus dem Code extrahierten Item-Synergien im Wiki.

### Wichtigste Änderungen
- Zweifarbiger Ghost-Trail pro Charakter (Lauf- + Angriffs-Trail) und größere, charakterfarbige Treffer-Partikel
- Komplett neues Hauptmenü mit 3D-Hintergrund und Live-Charaktervorschau
- Neuer Admin-Item-Testraum (alle Items, nur per Teleporter erreichbar)
- Hitboxen von Turret/Auge/Köder/Nanoschwarm verkleinert; Lockdown trifft jetzt die Telegraph-Position statt den Spielerstandort
- Obsidian-Vault vollständig ins Haupt-Repository aufgenommen (vorher nur lose in einem Worktree-Ordner)
- Sechs Sandbox-Gegnertypen, Status-Effekt "Schild" und codeverifizierte Item-Synergien neu im Wiki erfasst
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-10_installation-von-claude-cli-tools]]
> - [[2026-08-10_obsidian-wiki-fr-spieleentwicklung]]
> - [[2026-08-10_ui-verbesserung-fr-spielmen]]
> - [[2026-08-10_valorant-fhigkeiten-technische-implementierung]]
> - [[2026-08-10_vault-und-graphify-spielentwicklung-verstehen]]
> - [[2026-08-10_warp-worktree-vs-haupt-repository-wahl]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-08-10_02e6496_merge_branch_main_of_httpsgithubcomimchubiiiwhipul]]
> - [[2026-08-10_068148f_merge_branch_main_of_httpsgithubcomimchubiiiwhipul]]
> - [[2026-08-10_43a0d80_chore_obsidian_und_graphify-cache_ignorieren]]
> - [[2026-08-10_43a32e9_verkleinere_hitboxenmeshes_bei_turret_auge_koeder_]]
> - [[2026-08-10_467caba_merge_warp_code_und_loese_konflikte]]
> - [[2026-08-10_4b3999e_featvfxuiitemslevelgen_ghost-trail-system_main-men]]
> - [[2026-08-10_59d71ec_merge_warp_code_und_loese_konflikte]]
> - [[2026-08-10_5a37c20_obsidian-vault_ins_repo_aufnehmen]]
> - [[2026-08-10_5d04371_wiki_sechs_neue_sandbox-gegner_item-item-synergien]]
> - [[2026-08-10_72accca_wiki_vollstaendige_devlog-liste_freitext-verknuepf]]
> - [[2026-08-10_741d3f0_wiki_vollstaendige_devlog-liste_freitext-verknuepf]]
> - [[2026-08-10_90e61b8_chore_obsidian_und_graphify-cache_ignorieren]]
> - [[2026-08-10_baeb020_featvfxuiitemslevelgen_ghost-trail-system_main-men]]
> - [[2026-08-10_bcd3e81_wiki_sechs_neue_sandbox-gegner_item-item-synergien]]
> - [[2026-08-10_be0f304_obsidian-vault_ins_repo_aufnehmen]]
> - [[2026-08-10_f4f2185_verkleinere_hitboxenmeshes_bei_turret_auge_koeder_]]

---

## 08.08.2026

### Zusammenfassung
Reiner Recherche-Tag ohne Code-Änderungen: Klärung, was `.gitignore` eigentlich macht und warum es für das Projekt wichtig ist.
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-08_was-ist-gitignore-und-warum]]

---

## 05.08.2026

**Fokus:** Massives Feature-Update — 47 neue Items, Status-Effekte, Level-Progression

### Zusammenfassung
Der bisher größte Einzel-Patch: 47 neue Items (davon 33 mächtige "Ultimate"-Gegenstände) mit eigenen Synergien, ein vollständiges Status-Effekt-System (Brennen, Verlangsamung, Säure, Verwirrt, Stumm, Betäubt, plus neu Bezauberung und Verletzlichkeit) sowie thematische Etagen-Progression mit wechselnden Farbwelten (Kellergewölbe, Tiefkühlhaus, Sandgrube, Fleischfabrik, Neon-Keller) und 12 neuen Raum-Varianten. Das Kampfsystem bekam ein Last-Stand-System (die Party übernimmt automatisch den nächsten Charakter statt sofort zu verlieren) und einen Stun-Lock-Schutz mit Diminishing Returns. Gegner treiben jetzt physikalisch auf Lava statt einfach zu versinken, bewegen sich mit weichem Zickzack-Movement und können sich selbst freistuckeln. Dazu kam ein komplett neues, prozedurales Hauptmenü und ein zentrales Settings-Menü für Keybinds, FOV und Audio.

### Wichtigste Änderungen
- 47 neue Items (33 "Ultimate"-Gegenstände) mit eigenen Synergien
- Vollständiges Status-Effekt-System inkl. neuer Effekte Bezauberung und Verletzlichkeit
- Etagen-Progression mit fünf thematischen Farbwelten + 12 neue Raum-Varianten
- Last-Stand-System (automatischer Charakterwechsel bei Tod statt sofortigem Game Over) mit 20 % HP-Cap-Strafe
- Stun-Lock-Schutz (Diminishing Returns + Immunitätsfenster)
- Gegner treiben jetzt in Lava statt zu versinken, weiches Zickzack-Movement, Auto-Unstuck
- Komplett neues prozedurales Hauptmenü, zentrales Settings-Menü (Keybinds, FOV, Audio)
- Schatzräume haben nun 35 % Chance, direkt neben dem Startraum zu spawnen
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-05_git-commits-mit-claude-und-github-cli-1]]
> - [[2026-08-05_git-commits-mit-claude-und-github-cli]]
> - [[2026-08-05_implement-godot-game-fixes-and-features-overview-the]]
> - [[2026-08-05_spiel-feature-umsetzung-statusbericht]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-08-05_11da57c_featcore_massive_gameplay-_und_system-erweiterung_]]
> - [[2026-08-05_603fc49_feat_massive_gameplay-erweiterung_47_neue_items_ma]]
> - [[2026-08-05_8187415_merge_pull_request_2_from_imchubiiimetate-pinnacle]]
> - [[2026-08-05_a84aef5_merge_pull_request_2_from_imchubiiimetate-pinnacle]]
> - [[2026-08-05_b9765f6_merge_pull_request_1_from_imchubiiimetate-pinnacle]]
> - [[2026-08-05_dabbb5d_featcore_massive_gameplay-_und_system-erweiterung_]]
> - [[2026-08-05_e5b4cf6_feat_massive_gameplay-erweiterung_47_neue_items_ma]]
> - [[2026-08-05_fe47020_merge_pull_request_1_from_imchubiiimetate-pinnacle]]

---

## 04.08.2026

**Fokus:** Status-Effekte, Multi-Zellen-Räume, Party-Revive, Debug-Teleporter

### Zusammenfassung
Umsetzung der Design-Dokument-Phasen 3 bis 5 in einem Zug: sieben Status-Effekte (Festgewurzelt, Brennen, Verlangsamung, Säure, Verwirrt, Stumm, Betäubt) mit eigener VFX- und Tick-Logik, Multi-Zellen-Räume (2x1, 1x2, 2x2) im Grid-Generator sowie ein neues Debug-Teleporter-System für den direkten Sprung zu Tresor- oder Bossraum. Die Party bekam ein erstes Last-Stand/Revive-System, die Boss-Lebensanzeige wurde von einem gemeinsamen Balken auf individuelle Balken pro Boss-Einheit umgebaut, und Boss-/Tresortüren lassen sich seitdem nicht mehr während eines laufenden Kampfs hacken. Dazu kamen einige neue Items (u.a. das Ouija-Board mit zielsuchenden Rachegeistern) und diverse Bugfixes an Despawn-Verhalten in engen Korridoren sowie an Status-Effekt-Handling bei Gegnern.

### Wichtigste Änderungen
- Sieben Status-Effekte mit eigener VFX-/Tick-Logik als Fundament für spätere Item-Synergien
- Multi-Zellen-Räume (2x1, 1x2, 2x2) im Level-Generator aktiviert
- Debug-Teleporter-System für direkten Sprung zu Tresor-/Bossraum
- Party-Last-Stand/Revive: automatischer Charakterwechsel bei Tod statt sofortigem Game Over
- Boss-Lebensanzeige auf individuelle Balken pro Boss-Einheit umgebaut, bis zu 3 Bosse korrekt synchronisiert
- Boss-/Tresortüren nicht mehr während laufendem Kampf hackbar
- Neues Item Ouija-Board (zielsuchende Rachegeister) sowie mehrere Item-Reworks
- Gegner-Despawn-Bug in engen Korridoren behoben
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-04_anweisungs-update-fr-godot-assistent-1]]
> - [[2026-08-04_anweisungs-update-fr-godot-assistent]]
> - [[2026-08-04_casual-greeting]]
> - [[2026-08-04_claude-cli-und-git-worktrees-erklrt-1]]
> - [[2026-08-04_claude-cli-und-git-worktrees-erklrt]]
> - [[2026-08-04_debug-teleporter-und-spiel-updates-1]]
> - [[2026-08-04_debug-teleporter-und-spiel-updates]]
> - [[2026-08-04_game-dev-prompt-item-bug-fixes-1]]
> - [[2026-08-04_game-dev-prompt-item-bug-fixes]]
> - [[2026-08-04_gdscript-projekt-analysiert-root-causes-identifiziert]]
> - [[2026-08-04_godot-levelgenerator-raum-pool-erweitern-1]]
> - [[2026-08-04_godot-levelgenerator-raum-pool-erweitern]]
> - [[2026-08-04_godot-projekt-setup-und-szenen-optimierung]]
> - [[2026-08-04_graphify-installation-und-einrichtung-1]]
> - [[2026-08-04_graphify-installation-und-einrichtung]]
> - [[2026-08-04_greeting]]
> - [[2026-08-04_hilfe-bei-spielproblemen-rume-laden-nicht-1]]
> - [[2026-08-04_hilfe-bei-spielproblemen-rume-laden-nicht]]
> - [[2026-08-04_install-custom-statusline-script]]
> - [[2026-08-04_item--vfx-dokumentation-fr-spiel]]
> - [[2026-08-04_item-logik-und-verbesserungsvorschlge]]
> - [[2026-08-04_jq-fehlt-graphify-fehler-beheben]]
> - [[2026-08-04_katalog-export-und-produktionsplanung]]
> - [[2026-08-04_ki-kann-godot-nicht-visuell-testen]]
> - [[2026-08-04_management-export-skript-vereint-git-und-powershell]]
> - [[2026-08-04_neue-item-ideen-fr-spiel]]
> - [[2026-08-04_python-skript-zur-obsidian-vault-generierung]]
> - [[2026-08-04_tabelle-mit-fortlaufender-nummerierung]]
> - [[2026-08-04_valorant-abilities-game-adaptation]]
> - [[2026-08-04_valorant-agenten-fhigkeiten-bersicht]]
> - [[2026-08-04_valorant-fhigkeiten-fr-spielekonzepte]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-08-04_199136e_featdebug_ui_combat_teleporter-system_boss-hp-mult]]
> - [[2026-08-04_5d63fe2_featitemscombatlevelgenui_ouija-board_item-reworks]]
> - [[2026-08-04_678339b_featdebug_ui_combat_teleporter-system_boss-hp-mult]]
> - [[2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef]]
> - [[2026-08-04_7e551ae_add_run_management_exportbat_and_remove_legacy_exp]]
> - [[2026-08-04_9e59d70_add_run_management_exportbat_and_remove_legacy_exp]]
> - [[2026-08-04_c28ab95_featitems_ai_ui_levelgen_party-revive_item-reworks]]
> - [[2026-08-04_c63b397_featitems_ai_ui_levelgen_party-revive_item-reworks]]
> - [[2026-08-04_e9b2b1f_featitemscombatlevelgenui_ouija-board_item-reworks]]
> - [[2026-08-04_ec5e457_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef]]

---

## 03.08.2026

### Zusammenfassung
Reiner Tooling-Tag ohne Gameplay-Änderungen: Klärung, wie sich Godot-Projektdateien sauber erstellen und exportieren lassen.
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-03_godot-projektdateien-erstellen-und-exportieren-2]]
> - [[2026-08-03_godot-projektdateien-erstellen-und-exportieren]]

---

## 01.08.2026

**Fokus:** Neustart-Kette repariert, Item-Rarity-System, Bomben-VFX

### Zusammenfassung
Der Neustart-Button und die [R]-Taste taten bis heute schlicht nichts — Ursache war ein klassisches GDScript-Footgun: `party_manager.gd` prüfte nach einem Szenen-Reload weiter auf `player == null`, was bei einer bereits freigegebenen (aber nicht auf null gesetzten) Instanz fälschlich `false` blieb. Der komplette Spawn-Pfad hing an genau dieser Prüfung. Der Fix führte zu einem einzigen, zentralen Neustart-Autoload (`RunRestart`), das von allen vier Auslösern (Taste, Pause-, Death-, Win-Screen) genutzt wird. Daneben bekamen Items ein fünfstufiges Seltenheitssystem mit farbcodierten Sockeln, Bomben einen größeren Explosionsradius mit fliegenden Trümmerteilen, und ein interaktives Tutorial-Hologramm erklärt seitdem am Startpunkt die Grundlagen. Ein zuvor verworfenes Motion-Blur-Feature wurde nach mehreren gescheiterten Anläufen (fehlende Screen-Textur unter Forward Mobile) endgültig entfernt.

### Wichtigste Änderungen
- Neustart-Bug behoben: zentrales `RunRestart`-Autoload für Taste/Pause-/Death-/Win-Screen
- Fünfstufiges Item-Seltenheitssystem (Gewöhnlich bis Legendär) mit farbcodierten Sockeln
- Interaktives Tutorial-Hologramm am Startpunkt eines Runs
- Bomben: größerer Explosionsradius, fliegende Trümmerteile, Brandflecken
- Erhöhte Gegnerdichte in Arenaräumen, beschleunigter Schadenseintritt in Lava
- Tür-Interaktionsbereich an Türhöhen angepasst (kein Sprung mehr nötig)
- Motion-Blur-Feature nach mehreren gescheiterten Technik-Ansätzen endgültig verworfen
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-08-01_einheiten-fehler-in-rampen-korridoren-beheben]]
> - [[2026-08-01_erfolgreich-implementierte-massnahmen]]
> - [[2026-08-01_game-balance-adjustments-and-file-setup]]
> - [[2026-08-01_implementierte-und-offene-punkte]]
> - [[2026-08-01_item-use-und-dash-steuerung-angepasst]]
> - [[2026-08-01_shader-einstellungen-im-inspektor-anpassen]]
> - [[2026-08-01_spielanleitung-ablauf-steuerung]]
> - [[2026-08-01_spielanleitung-ablauf-und-steuerung]]
> - [[2026-08-01_spielanleitung-als-hologramm]]
> - [[2026-08-01_spieleanleitung-als-pdf-bersicht]]
> - [[2026-08-01_tastenzuweisung-fr-item-use-und-dash]]
> - [[2026-08-01_tutorial-screen-design-simplification]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-08-01_336b15e_fix_kamera-drill_zurueckgesetzt_motion-blur-featur]]
> - [[2026-08-01_3bbac00_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
> - [[2026-08-01_5d2ca05_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
> - [[2026-08-01_93c1622_fix_tutorial_scren]]
> - [[2026-08-01_c555d99_fix_kamera-drill_zurueckgesetzt_motion-blur-featur]]
> - [[2026-08-01_e50066f_fix_tutorial_scren]]

---

## 28.07.2026

**Fokus:** Q/E-Item-Slots, 3D-Gegnermodelle, Projektstruktur-Aufräumen

### Zusammenfassung
Die bisher leeren Charakter-Fähigkeiten auf Q/E wurden durch zwei unabhängige aktive Item-Slots ersetzt — das erste aufgesammelte aktive Item geht auf Q, das zweite auf E, Ladung wird pro Item statt pro Slot gespeichert, damit ein Tausch im Pausemenü nie Fortschritt verliert. Gegner bekamen echte animierte Lowpoly-Robotermodelle statt Platzhaltergeometrie, inklusive eines prozeduralen Angriffs-Schwungs per Bone-Manipulation. Der gesamte Projektbaum wurde zudem von einer flachen in eine geordnete Ordnerstruktur (`scripts/{core,enemy,hazards,level,ui}`, `scenes/`, `assets/`) migriert, samt Anpassung aller `res://`-Pfade.

### Wichtigste Änderungen
- Aktive Items auf zwei unabhängige Q/E-Slots umgestellt, Ladung pro Item statt pro Slot
- Neues Pause-Screen-Widget zum Tauschen von Q und E
- Animierte 3D-Robotermodelle für Gegner samt prozeduralem Angriffs-Schwung
- Projektstruktur komplett neu geordnet (scripts/scenes/assets in Unterordner), alle Pfade aktualisiert
- Fenster-Position/-Größe wird beim allerersten Start nicht mehr fälschlich auf (0,0) gesetzt
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-28_bomben-physik-und-item-verhalten-debugging]]
> - [[2026-07-28_item-effekte-zentralisieren-und-kategorisieren]]
> - [[2026-07-28_melee-items-mit-effekten-und-gameplay-feedback]]
> - [[2026-07-28_melee-items-mit-godot-effekten]]
> - [[2026-07-28_null-instance-rotation-error-in-player-base]]
> - [[2026-07-28_projekt-startet-nicht]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-07-28_0743a3e_refactor_reorganize_project_structure_and_normaliz]]
> - [[2026-07-28_17b4f89_featenemy_integrate_3d_robot_models_and_procedural]]
> - [[2026-07-28_1f5b78d_fix_windowed_position_persistence_on_first_run]]
> - [[2026-07-28_2642172_featitems_aktive_items_auf_qe-slots_umgestellt]]
> - [[2026-07-28_499c162_refactor_reorganize_project_structure_and_normaliz]]
> - [[2026-07-28_976bf0c_hud_fix]]
> - [[2026-07-28_ae734fd_fix_windowed_position_persistence_on_first_run]]
> - [[2026-07-28_b6f176f_add_particles]]
> - [[2026-07-28_c2ad883_hud_fix]]
> - [[2026-07-28_cdefce2_featenemy_integrate_3d_robot_models_and_procedural]]
> - [[2026-07-28_ea34fe3_featitems_aktive_items_auf_qe-slots_umgestellt]]
> - [[2026-07-28_f8773ab_add_particles]]

---

## 27.07.2026

**Fokus:** Schatzraum-Sockel, HUD-Refactor, Item-Balancing

### Zusammenfassung
Der Item-Katalog stand seit Tagen komplett fertig da (Effekte, Stat-Integration), wurde aber nirgends im Spiel tatsächlich gespawnt — heute kam mit dem Schatzraum-Sockel-System endlich die fehlende Verbindung dazu. Ein neues `Treasure`-Autoload erkennt Schatzräume automatisch (über Gruppe, Szenenpfad oder Grid-Zelle) und platziert dort genau ein Item auf einem selbstgebauten Sockel (Säule, Lichtsäule, Bodenring, schwebendes Item) — deterministisch aus Run-Seed und Rasterposition gewählt, ohne Duplikate im selben Lauf. Dazu kam ein umfassender HUD-Refactor (weg vom separaten Autoload-Overlay, rein in die normale HUD-Szene) sowie Balancing an Bomben und Basisschaden.

### Wichtigste Änderungen
- Schatzraum-Sockel-System: Items spawnen jetzt tatsächlich im Spiel, ein Item pro Schatzraum, deterministisch gewählt
- HUD komplett aus dem separaten Autoload-Overlay in die normale HUD-Szene überführt
- Bomben-Balancing und Anpassung des Basisschadens
- Mehrere unabhängige Bugfixes aus dem Testen der obigen Änderungen
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-27_3d-roboter-modelle-in-godot-4-gegner-szenen-integrieren]]
> - [[2026-07-27_game-dev-log-bug-fixes-hud-balancing-1]]
> - [[2026-07-27_game-dev-log-bug-fixes-hud-balancing]]
> - [[2026-07-27_godot-3d-modelle-und-animationen-importieren-1]]
> - [[2026-07-27_godot-3d-modelle-und-animationen-importieren]]
> - [[2026-07-27_projektanweisung-fr-godot-entwickler]]
> - [[2026-07-27_treasure-room-items-und-bomb-mechaniken]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-07-27_0c0e515_feat_treasure_room_items_hud_overhaul_balancing_mu]]
> - [[2026-07-27_f88829f_feat_treasure_room_items_hud_overhaul_balancing_mu]]

---

## 26.07.2026

**Fokus:** Stat-System, Loot-Drops, Tür-/Raumgeometrie-Fixes, Dash-Schaden

### Zusammenfassung
Ein inhaltlich sehr dichter Tag. Ein neues Stat-System (Schaden, Tempo, Angriffstempo, Glück, Magnetradius, Rüstung, Hazard-Widerstand) legt sich additiv+multiplikativ auf die Basiswerte jedes Charakters, ohne dass Charakter- oder Raumszenen angefasst werden mussten. Dazu kamen Loot-Drops bei Raum-Clear, ein modularisiertes Settings-Menü mit eigener Minimap-Sektion, und eine ganze Reihe fundamentaler Level-Generator-Fixes: Boss- und Tresorräume liegen jetzt garantiert in echten Sackgassen (statt nur bevorzugt), ungenutzte Türöffnungen werden zugemauert statt als ewig verriegeltes Türblatt stehenzubleiben, und Gegnerstärke skaliert jetzt tatsächlich mit der Etage statt nur mit der Anzahl. Combat bekam eine ganze Reihe Gegner-KI-Fixes (Geschwindigkeits-Varianz gegen "Zug"-Formationen, korrigierte Angriffsreichweiten, richtiger Facing-Check) sowie einen Stun-Lock-Schutz gegen Gegner-Ketten-Tode. Zum Abschluss kam Dash-Schaden (nur bei echtem Durchqueren eines Gegners, nicht beim bloßen Antippen) und ein FOV-Regler dazu.

### Wichtigste Änderungen
- Neues Stat-System (Schaden/Tempo/Glück/Magnetradius/Rüstung/Hazard-Widerstand) rein additiv angebunden
- Loot-Drops bei Raum-Clear eingeführt
- Boss-/Tresorräume liegen jetzt garantiert in echten Sackgassen; ungenutzte Türöffnungen werden zugemauert
- Gegnerstärke skaliert jetzt mit der Etage, nicht mehr nur mit der Anzahl
- Gegner-KI-Fixes: Geschwindigkeits-Varianz, korrigierte Angriffsreichweiten, richtiger Facing-Check
- Stun-Lock-Schutz gegen Gegner-Ketten-Tode (Diminishing Returns + garantierte Immunität)
- Dash verursacht jetzt Schaden — aber nur beim tatsächlichen Durchqueren eines Gegners
- Neuer FOV-Regler im Video-Tab
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-26_binding-of-isaac-room-drop-mechanics-1]]
> - [[2026-07-26_binding-of-isaac-room-drop-mechanics]]
> - [[2026-07-26_claude-nutzung-guthaben-statt-abbuchung-1]]
> - [[2026-07-26_claude-nutzung-guthaben-statt-abbuchung]]
> - [[2026-07-26_commit-analyse]]
> - [[2026-07-26_dateien-chronologisch-ersetzen-und-einfuegen]]
> - [[2026-07-26_enemy-behavior-no-fleeing-code-1]]
> - [[2026-07-26_enemy-behavior-no-fleeing-code]]
> - [[2026-07-26_game-design-dokument-aufbereitung-1]]
> - [[2026-07-26_game-design-dokument-aufbereitung]]
> - [[2026-07-26_isaac-style-game-item-ideas]]
> - [[2026-07-26_partikel-fuer-kampfeffekte-hinzufuegen]]
> - [[2026-07-26_projekt-bugs-analysiert-und-behoben]]
> - [[2026-07-26_speedrun-ranking-und-gameplay-verbesserungen]]
> - [[2026-07-26_spielmechanik-und-level-design-verbesserungen]]
> - [[2026-07-26_stat-system-als-grundlage-fuer-loot-mechaniken]]
> - [[2026-07-26_verifikationslauf-und-offene-dungeon-skalierungen]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-07-26_0144b33_expand_readme_with_game_details_and_controls]]
> - [[2026-07-26_058b54e_featsettings_minimap_modulare_settings-gruppen_min]]
> - [[2026-07-26_161c399_feat_stat-system_loot-drops_bomben_items_und_game_]]
> - [[2026-07-26_1b638b9_add_commit_export_batch_and_generated_log]]
> - [[2026-07-26_2ddf360_fixlevelgenaicamera_tueren_raumgeometrie_gegnerver]]
> - [[2026-07-26_4a6c9c9_add_commit_export_batch_and_generated_log]]
> - [[2026-07-26_61765de_feat_combat-tuning_hud-overhaul_anti-baiting_sieg-]]
> - [[2026-07-26_843fa45_feat_dash-schaden_fov-regler_und_rampen-lava-fixes]]
> - [[2026-07-26_95fdcfd_add_whiplash_game_export_files]]
> - [[2026-07-26_a9c7565_add_whiplash_game_export_files]]
> - [[2026-07-26_b73510d_expand_readme_with_game_details_and_controls]]
> - [[2026-07-26_ec9ce70_feat_stat-system_loot-drops_bomben_items_und_game_]]
> - [[2026-07-26_fc23274_feat_dash-schaden_fov-regler_und_rampen-lava-fixes]]

---

## 25.07.2026

**Fokus:** Threat-Budget-Gegnerspawns, Lava-Hazards, Grid-Level-Fixes

### Zusammenfassung
Der Gegner-Spawn wechselte von festen Min/Max-Zahlen auf ein Threat-Budget-System: jeder Gegnertyp kostet Budget-Punkte, ein Raum kann so entweder viele billige oder wenige teure Gegner enthalten, statt dass ein Fighter einfach auf einem Stinger stapelt. Dazu kamen Lava-Hazards mit Navigations-Aussparung (Gegner laufen jetzt um Lava herum statt hindurch) und neue Raum-Varianten mit Treppen/Plattformen. Der zweite Schwerpunkt war ein Bugfix-Marathon am neuen Isaac-artigen Grid-Level-System: Räume wurden teils gar nicht generiert, weil `add_child()` während der initialen Ready-Kaskade fehlschlug ("Parent node is busy") — die Lösung war, Raum-Generierung und Spieler-Spawn konsequent per `call_deferred()` zu entkoppeln.

### Wichtigste Änderungen
- Gegner-Spawns laufen jetzt über ein Threat-Budget statt fester Min/Max-Zahlen
- Lava-Hazards mit Navigations-Aussparung, damit Gegner um sie herumlaufen
- Grid-Level-Generierung: kritischer Deferred-Call-Fix behebt fehlschlagende Raum-Erzeugung beim Start
- Minimap zeigt jetzt ein schematisches Raum-Grid-Overlay mit Raumtyp, Clear-Status und Türverbindungen
- Spieler-Blickrichtungspfeil auf der Minimap ergänzt
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-25_game-design-uiux-prompt-revision-1]]
> - [[2026-07-25_game-design-uiux-prompt-revision]]
> - [[2026-07-25_gegner-scaling-und-raumgroesse-anpassen]]
> - [[2026-07-25_godot-level-generator-room-instantiation]]
> - [[2026-07-25_level-design-und-gameplay-verbesserungen]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-07-25_170eb45_featlevel-gen_threat-budget_enemy_mix_lava_hazards]]
> - [[2026-07-25_44c639b_fixlevel-generation_dynamisches_spawningtuer-syste]]
> - [[2026-07-25_66b3f05_featlevel-gen_threat-budget_enemy_mix_lava_hazards]]
> - [[2026-07-25_70c307e_featminimap_add_player_direction_arrow]]
> - [[2026-07-25_905d144_feat_level-generation-polish_minimap-overhaul_haza]]
> - [[2026-07-25_aea81f1_fixlevel-generation_dynamisches_spawningtuer-syste]]
> - [[2026-07-25_f8455e0_merge_branch_main_of_httpsgithubcomimchubiiiwhipul]]

---

## 24.07.2026

**Fokus:** Charaktersystem in eigenständige Klassen aufgeteilt

### Zusammenfassung
Der bisher generische `Player` wurde durch vier eigenständige Charakterszenen (Ningning, Giselle, Karina, Winter) ersetzt, jede mit eigenem Combat-Skript statt eines gemeinsamen, datengetriebenen AbilitySet — Grundlage für die später folgenden individuellen Kampf-Kits. `PlayerBase`/`CombatBase` tragen seitdem die gemeinsame Bewegungs-/Kamera-/Kampflogik, `PartyManager` spawnt und entfernt beim Charakterwechsel die aktive Instanz jetzt tatsächlich neu (statt nur Daten auf einem gemeinsamen Node zu tauschen), inklusive 10-Sekunden-Cooldown auf zurückgelassene Charaktere. Dazu kam ein überarbeitetes Knockback-System und eine Blickrichtungs-Kalibrierung für die Minimap.

### Wichtigste Änderungen
- Vier eigenständige Charakterszenen (Ningning/Giselle/Karina/Winter) mit eigenem Combat-Skript statt gemeinsamem AbilitySet
- Charakterwechsel spawnt/entfernt jetzt tatsächlich die Spieler-Instanz, inkl. 10s Wechsel-Cooldown
- Knockback-Mechanismus überarbeitet
- Minimap-Richtungspfeil kalibriert
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-24_character-spezifische-szenen-und-abilities]]
> - [[2026-07-24_roguelike-style-room-design-variation]]
> - [[2026-07-24_spielmechaniken-und-ui-anpassungen-fuer-godot-projekt]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-07-24_0f73f4c_feat_minimap-kalibrierung_hud-overlay-fixes_knockb]]
> - [[2026-07-24_772c314_feat_minimap-kalibrierung_hud-overlay-fixes_knockb]]
> - [[2026-07-24_b39a97d_refactorplayer_split_player_system_into_per-charac]]
> - [[2026-07-24_d86f02e_refactorplayer_split_player_system_into_per-charac]]

---

## 23.07.2026

**Fokus:** Vollständiges Party-HUD, Settings-Menü mit Tabs & Barrierefreiheit

### Zusammenfassung
Das HUD bekam sein bis heute grundlegendes Gerüst: eine 4-Personen-Party mit HP-Spiegelung für inaktive Mitglieder, Charakterwechsel über die Tasten 1-4, Q/E-Fähigkeits-Slots mit radialem Cooldown-Overlay, und eine Minimap mit Zonennamen und Live-Koordinaten. Das Settings-Menü wurde in ein Tab-System (Allgemein/Video/Audio/Steuerung) umgebaut, inklusive schattenbasierter Farbenblind-Korrektur (Protanopie, Deuteranopie, Tritanopie), Anzeigemodus-Auswahl und einem gemeinsamen Blur-Overlay für Pause-/Death-/Win-Screen.

### Wichtigste Änderungen
- Vollständiges Party-HUD: 4-Personen-Party, HP-Spiegelung, Charakterwechsel über 1-4
- Q/E-Fähigkeits-Slots mit radialem Cooldown-Overlay
- Minimap mit Zonenname und Live-Koordinaten
- Settings-Menü in Tabs (Allgemein/Video/Audio/Steuerung) umgebaut
- Farbenblind-Modus (Protanopie/Deuteranopie/Tritanopie), V-Sync/FPS-Limit, HUD-Sichtbarkeits-Schalter
- Gemeinsames Blur-Overlay für Pause-, Death- und Win-Screen
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-23_gdscript-und-tscn-dateien-anfordern]]
> - [[2026-07-23_godot-skript-fehler-area3d-vs-collisionshape3d-1]]
> - [[2026-07-23_godot-skript-fehler-area3d-vs-collisionshape3d]]
> - [[2026-07-23_heavy-enemies-nicht-pushbar-machen]]
> - [[2026-07-23_hud-ui-mit-character-anzeige-und-ability-icons]]
> - [[2026-07-23_hud-ui-mit-charakteruebersicht-und-faehigkeiten]]
> - [[2026-07-23_lemonade-als-gridmap-asset-mit-effekten]]
> - [[2026-07-23_log-datei-ueberpruefung]]
> - [[2026-07-23_pause-menu-bugs-in-level-02]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-07-23_0887d72_feathud_add_full_party_hud_with_abilities_minimap_]]
> - [[2026-07-23_15c8712_feathud_add_full_party_hud_with_abilities_minimap_]]
> - [[2026-07-23_606156f_add_map]]
> - [[2026-07-23_9305498_fix_reassign_area3d_script_to_correct_parent_node]]
> - [[2026-07-23_b0d96b3_add_map]]
> - [[2026-07-23_d76e823_refactor_settings_menu_with_tabs_accessibility]]
> - [[2026-07-23_d7e8cf7_fix_reassign_area3d_script_to_correct_parent_node]]
> - [[2026-07-23_d9bde60_updated_export]]
> - [[2026-07-23_de06b3d_updated_export]]
> - [[2026-07-23_f874fed_refactor_settings_menu_with_tabs_accessibility]]

---

## 22.07.2026

**Fokus:** NavMesh-Pathfinding für Gegner, erstes Settings-Menü

### Zusammenfassung
Gegner bekamen echtes NavigationAgent3D-Pathfinding mit intelligentem Abstiegs-Verhalten an Kanten statt simplem direktem Verfolgen, dafür wurden alle Level auf `NavigationRegion3D` umgestellt. Parallel entstand das allererste Settings-Menü (Sensitivität, Lautstärke, Vollbild, frei belegbare Tasten) als eigenes Autoload mit persistenter Speicherung über eine ConfigFile.

### Wichtigste Änderungen
- NavigationAgent3D-Pathfinding für Gegner mit intelligentem Kanten-Verhalten
- Erstes Settings-Menü: Sensitivität, Lautstärke, Vollbild, frei belegbare Tasten
- Persistente Einstellungs-Speicherung über ConfigFile
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-22_effizientere-methoden-zum-erstellen-von-maps]]
> - [[2026-07-22_gegner-bleiben-an-kanten-stecken]]
> - [[2026-07-22_menu-blur-hintergrund-problem]]
> - [[2026-07-22_naechste-ziele-definieren]]
> - [[2026-07-22_settings-struktur-mit-separatem-keybinds-tab]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-07-22_0bbeb99_fix_settings_tabs]]
> - [[2026-07-22_3b06fb5_fix_settings_tabs]]
> - [[2026-07-22_802fffe_add_navmesh_pathfinding_and_fix_physics_bugs]]
> - [[2026-07-22_9e71cfc_featui_add_settings_menu_with_sensitivity_volume_f]]
> - [[2026-07-22_b53088c_featui_add_settings_menu_with_sensitivity_volume_f]]
> - [[2026-07-22_d744e07_add_navmesh_pathfinding_and_fix_physics_bugs]]
> - [[2026-07-22_d9052ed_gridmap_asset_hinzugefuegt]]
> - [[2026-07-22_fd0eb9f_gridmap_asset_hinzugefuegt]]

---

## 21.07.2026

**Fokus:** Gegner-Bewegungsfreeze behoben, Lava-Auftriebsphysik

### Zusammenfassung
Ein kritischer Bug ließ Gegner einfrieren: die Berechnung der Fußposition zählte den Kapsel-Radius doppelt, was dauerhaft falsche "Kante voraus"-Erkennungen auslöste. Nach dem Fix kam dynamische, körpergrößen-skalierte Kantenerkennung mit seitlichen Prüfpunkten dazu. Für Lava/Wasser-Bereiche entstand eine erste Auftriebsphysik: der Spieler sinkt bis zu einer einstellbaren Tiefe ein, bobbt dort sanft statt weiter aufzusteigen, und taucht nur bei aktiv gehaltener Leertaste über die gedeckelte Tiefe hinaus.

### Wichtigste Änderungen
- Kritischer Fix: Gegner-Bewegungsfreeze durch doppelt gezählten Kapsel-Radius behoben
- Dynamische, körpergrößen-skalierte Kantenerkennung mit seitlichen Prüfpunkten
- Erste Lava-/Wasser-Auftriebsphysik mit Tiefenbegrenzung und sanfter Bob-Animation
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-21_gegner-ki-fehler-beheben-und-physik-anpassen]]
> - [[2026-07-21_gegner-ki-verbessern-beim-klettern]]
> - [[2026-07-21_godot-mit-github-verbinden-drei-wege-1]]
> - [[2026-07-21_godot-mit-github-verbinden-drei-wege]]
> - [[2026-07-21_ki-verfolgung-mit-navigationagent3d-verbessern]]
> - [[2026-07-21_lava-auftrieb-und-tauchtiefe-regulieren]]
> [!INFO]- Verlinkungen (DevLogs)
> - [[2026-07-21_0d3ad30_fix_enemy_movement_freeze_and_enhance_ledge_detect]]
> - [[2026-07-21_2135fc5_fix_enemy_movement_freeze_and_enhance_ledge_detect]]
> - [[2026-07-21_25431a4_bereinigung]]
> - [[2026-07-21_3b6606e_d]]
> - [[2026-07-21_47222b1_initial_cleanup]]
> - [[2026-07-21_4d89da8_test]]
> - [[2026-07-21_4f3425d_fix_player_launching_out_of_buoyancy_zones]]
> - [[2026-07-21_9b46c89_test]]
> - [[2026-07-21_aa290a7_bereinigung]]
> - [[2026-07-21_b403b2c_fix_player_launching_out_of_buoyancy_zones]]
> - [[2026-07-21_d66210d_initial_commit]]

---

## 20.07.2026

### Zusammenfassung
Reiner Konzept-Tag ohne Code-Änderungen: Diskussion einer möglichen Spielearchitektur auf Basis eines ECS-Musters und eines generischen Modifier-Systems für Item-/Status-Effekte.
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-20_spielearchitektur-ecs-und-modifier-system]]

---

## 19.07.2026

### Zusammenfassung
Reiner Debugging-Tag ohne festgehaltene Commits: ein Rendering-Versatz beim Fadenkreuz wurde untersucht, dazu eine Korrektur an einem Scanline-Post-Processing-Shader.
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-19_debugging-reticle-offset-rendering-issue]]
> - [[2026-07-19_godot-scanline-shader-correction]]

---

## 18.07.2026

### Zusammenfassung
Reiner Konzept-Tag: erste Überlegungen zu einer Valorant-ähnlichen Bewegungsmechanik (Gravitation, Sprung, Sensitivität) als Grundlage für das spätere Movement-Gefühl.
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-18_valorant-aehnliche-bewegungsmechanik-in-godot]]

---

## 17.07.2026

### Zusammenfassung
Der Starttag des Projekts: Recherche zu erfolgreichen Low-Poly-Spielen auf Steam als Stilreferenz, sowie das ursprüngliche Grundkonzept — ein Third-Person-Dungeon-Crawler mit PS1-Grafik, aus dem sich das heutige Lemonade/Whiplash entwickelt hat.
> [!INFO]- Verlinkungen (Chat-Protokolle)
> - [[2026-07-17_low-poly-games-on-steam]]
> - [[2026-07-17_third-person-dungeon-crawler-mit-ps1-grafik]]

---

## Schnellnavigation
[[HOME|Startseite]] . [[_MOC_Characters|Charaktere]] . [[_MOC_Items|Items]] . [[_MOC_Enemies|Gegner]]