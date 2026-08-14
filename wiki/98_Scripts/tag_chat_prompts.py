"""
tag_chat_prompts.py — einmalig ausführbar (oder erneut, wenn neue
Chat-Prompt-Dateien in 04_Chat_Prompts/ dazukommen).

Wendet zwei zusaetzliche Einordnungen auf jede Datei in 04_Chat_Prompts/ an:
  1. thema/*-Tags (inhaltliche Kategorie, von Hand vergeben nach Lektuere von
     Titel/Inhalt — siehe THEMA_MAP unten).
  2. ki/*-Tag + ki_art-Feld (KI-Quelle, MECHANISCH erkannt anhand fixer
     Marker im Dateiinhalt selbst — siehe detect_ki_art()):
       - "[Source File](....claude/projects/...)"          -> claude cli
       - "[Conversation Link](https://claude.ai/chat/...)"  -> claude
       - "[Antigravity Session](....gemini/antigravity/...)" -> antigravity
       - Rollen-Header "## Gemini"                          -> gemini
       - Rollen-Header "## Assistant" (ohne alle drei obigen Marker,
         Altbestand aus der Zeit vor export_antigravity.py)  -> antigravity
       - keine erfasste Antwort/kein Marker                 -> unbekannt

Bestehende Tags (chatlog, prompt-log, whiplash, lemonade, legacy, ...)
bleiben unangetastet - dieses Skript haengt nur an.

WICHTIG fuer erneute Laeufe: eine Datei, deren ki_art bereits auf einen
ECHTEN Wert aufgeloest wurde (z.B. per resolve_claude_ki_art.py anhand
eines externen Claude.ai-Exports, ohne dass im Dateiinhalt selbst ein
Marker steht), darf bei einem erneuten Lauf NICHT wieder auf "wird
nachgetragen" zurueckfallen, nur weil detect_ki_art() diesmal nichts
findet - siehe update_frontmatter(): ein bereits aufgeloester Wert bleibt
stehen, wenn die mechanische Erkennung keinen widersprechenden Marker
liefert. Nur ein tatsaechlich GEFUNDENER Marker darf einen bestehenden
Wert ueberschreiben.
"""
import os
import re

PROMPTS_DIR = os.path.join(os.path.dirname(__file__), "..", "04_Chat_Prompts")

KI_ART_TAG_SLUG = {
    "claude cli": "claude-cli",
    "claude": "claude",
    "gemini": "gemini",
    "antigravity": "antigravity",
}


def detect_ki_art(content: str) -> str | None:
    if re.search(r"^\[Source File\].*\.claude/projects/", content, re.MULTILINE):
        return "claude cli"
    if re.search(r"^\[Conversation Link\]\(https://claude\.ai/chat/", content, re.MULTILINE):
        return "claude"
    if re.search(r"^\[Antigravity Session\]\(file:///.*\.gemini/antigravity/", content, re.MULTILINE):
        return "antigravity"
    if re.search(r"^## Gemini$", content, re.MULTILINE):
        return "gemini"
    if re.search(r"^## Assistant$", content, re.MULTILINE):
        return "antigravity"
    return None


# Dateiname -> Liste von thema/*-Werten (ohne Praefix), von Hand vergeben
# nach Lektuere von Titel + (bei uneindeutigem Titel) Inhaltsanfang.
THEMA_MAP = {
    "2026-07-17_low-poly-games-on-steam.md": ["design-brainstorming"],
    "2026-07-17_third-person-dungeon-crawler-mit-ps1-grafik.md": ["meta", "design-brainstorming"],
    "2026-07-18_valorant-aehnliche-bewegungsmechanik-in-godot.md": ["character", "design-brainstorming"],
    "2026-07-19_debugging-reticle-offset-rendering-issue.md": ["bugfix", "ui"],
    "2026-07-19_godot-scanline-shader-correction.md": ["shader", "vfx"],
    "2026-07-20_spielearchitektur-ecs-und-modifier-system.md": ["meta", "refactor"],
    "2026-07-21_gegner-ki-fehler-beheben-und-physik-anpassen.md": ["enemy", "bugfix"],
    "2026-07-21_gegner-ki-verbessern-beim-klettern.md": ["enemy", "feature"],
    "2026-07-21_godot-mit-github-verbinden-drei-wege-1.md": ["tooling", "git-workflow"],
    "2026-07-21_godot-mit-github-verbinden-drei-wege.md": ["tooling", "git-workflow"],
    "2026-07-21_ki-verfolgung-mit-navigationagent3d-verbessern.md": ["enemy", "feature"],
    "2026-07-21_lava-auftrieb-und-tauchtiefe-regulieren.md": ["level-design", "balancing"],
    "2026-07-22_effizientere-methoden-zum-erstellen-von-maps.md": ["tooling", "level-design"],
    "2026-07-22_gegner-bleiben-an-kanten-stecken.md": ["enemy", "bugfix"],
    "2026-07-22_menu-blur-hintergrund-problem.md": ["ui", "bugfix"],
    "2026-07-22_naechste-ziele-definieren.md": ["meta"],
    "2026-07-22_settings-struktur-mit-separatem-keybinds-tab.md": ["ui", "feature"],
    "2026-07-23_gdscript-und-tscn-dateien-anfordern.md": ["tooling"],
    "2026-07-23_godot-skript-fehler-area3d-vs-collisionshape3d-1.md": ["bugfix", "refactor"],
    "2026-07-23_godot-skript-fehler-area3d-vs-collisionshape3d.md": ["bugfix", "refactor"],
    "2026-07-23_heavy-enemies-nicht-pushbar-machen.md": ["enemy", "balancing"],
    "2026-07-23_hud-ui-mit-character-anzeige-und-ability-icons.md": ["ui", "character"],
    "2026-07-23_hud-ui-mit-charakteruebersicht-und-faehigkeiten.md": ["ui", "character"],
    "2026-07-23_lemonade-als-gridmap-asset-mit-effekten.md": ["level-design", "vfx"],
    "2026-07-23_log-datei-ueberpruefung.md": ["bugfix", "tooling"],
    "2026-07-23_pause-menu-bugs-in-level-02.md": ["ui", "bugfix"],
    "2026-07-24_character-spezifische-szenen-und-abilities.md": ["character", "combat"],
    "2026-07-24_roguelike-style-room-design-variation.md": ["level-design", "room-generation"],
    "2026-07-24_spielmechaniken-und-ui-anpassungen-fuer-godot-projekt.md": ["feature", "ui"],
    "2026-07-25_game-design-uiux-prompt-revision-1.md": ["ui", "design-brainstorming"],
    "2026-07-25_game-design-uiux-prompt-revision.md": ["ui", "design-brainstorming"],
    "2026-07-25_gegner-scaling-und-raumgroesse-anpassen.md": ["enemy", "balancing"],
    "2026-07-25_godot-level-generator-room-instantiation.md": ["room-generation", "feature"],
    "2026-07-25_level-design-und-gameplay-verbesserungen.md": ["level-design", "feature"],
    "2026-07-26_binding-of-isaac-room-drop-mechanics-1.md": ["item", "room-generation", "design-brainstorming"],
    "2026-07-26_binding-of-isaac-room-drop-mechanics.md": ["item", "room-generation", "design-brainstorming"],
    "2026-07-26_claude-nutzung-guthaben-statt-abbuchung-1.md": ["meta", "tooling"],
    "2026-07-26_claude-nutzung-guthaben-statt-abbuchung.md": ["meta", "tooling"],
    "2026-07-26_commit-analyse.md": ["meta", "tooling"],
    "2026-07-26_dateien-chronologisch-ersetzen-und-einfuegen.md": ["tooling"],
    "2026-07-26_enemy-behavior-no-fleeing-code-1.md": ["enemy", "bugfix"],
    "2026-07-26_enemy-behavior-no-fleeing-code.md": ["enemy", "bugfix"],
    "2026-07-26_game-design-dokument-aufbereitung-1.md": ["meta", "design-brainstorming"],
    "2026-07-26_game-design-dokument-aufbereitung.md": ["meta", "design-brainstorming"],
    "2026-07-26_isaac-style-game-item-ideas.md": ["item", "design-brainstorming"],
    "2026-07-26_partikel-fuer-kampfeffekte-hinzufuegen.md": ["vfx", "combat"],
    "2026-07-26_projekt-bugs-analysiert-und-behoben.md": ["bugfix"],
    "2026-07-26_speedrun-ranking-und-gameplay-verbesserungen.md": ["feature", "ui"],
    "2026-07-26_spielmechanik-und-level-design-verbesserungen.md": ["feature", "level-design"],
    "2026-07-26_stat-system-als-grundlage-fuer-loot-mechaniken.md": ["item", "feature"],
    "2026-07-26_verifikationslauf-und-offene-dungeon-skalierungen.md": ["level-design", "balancing"],
    "2026-07-27_3d-roboter-modelle-in-godot-4-gegner-szenen-integrieren.md": ["enemy", "feature"],
    "2026-07-27_game-dev-log-bug-fixes-hud-balancing-1.md": ["bugfix", "ui", "balancing"],
    "2026-07-27_game-dev-log-bug-fixes-hud-balancing.md": ["bugfix", "ui", "balancing"],
    "2026-07-27_godot-3d-modelle-und-animationen-importieren-1.md": ["tooling", "feature"],
    "2026-07-27_godot-3d-modelle-und-animationen-importieren.md": ["tooling", "feature"],
    "2026-07-27_projektanweisung-fr-godot-entwickler.md": ["meta"],
    "2026-07-27_treasure-room-items-und-bomb-mechaniken.md": ["item", "room-generation"],
    "2026-07-28_bomben-physik-und-item-verhalten-debugging.md": ["item", "bugfix"],
    "2026-07-28_item-effekte-zentralisieren-und-kategorisieren.md": ["item", "refactor"],
    "2026-07-28_melee-items-mit-effekten-und-gameplay-feedback.md": ["item", "combat", "vfx"],
    "2026-07-28_melee-items-mit-godot-effekten.md": ["item", "vfx"],
    "2026-07-28_null-instance-rotation-error-in-player-base.md": ["character", "bugfix"],
    "2026-07-28_projekt-startet-nicht.md": ["bugfix", "tooling"],
    "2026-08-01_einheiten-fehler-in-rampen-korridoren-beheben.md": ["level-design", "bugfix"],
    "2026-08-01_erfolgreich-implementierte-massnahmen.md": ["meta"],
    "2026-08-01_game-balance-adjustments-and-file-setup.md": ["balancing"],
    "2026-08-01_implementierte-und-offene-punkte.md": ["meta"],
    "2026-08-01_item-use-und-dash-steuerung-angepasst.md": ["item", "character"],
    "2026-08-01_shader-einstellungen-im-inspektor-anpassen.md": ["shader", "vfx"],
    "2026-08-01_spielanleitung-ablauf-steuerung.md": ["ui", "feature"],
    "2026-08-01_spielanleitung-ablauf-und-steuerung.md": ["ui", "feature"],
    "2026-08-01_spielanleitung-als-hologramm.md": ["ui", "vfx", "feature"],
    "2026-08-01_spieleanleitung-als-pdf-bersicht.md": ["ui", "meta"],
    "2026-08-01_tastenzuweisung-fr-item-use-und-dash.md": ["ui", "item"],
    "2026-08-01_tutorial-screen-design-simplification.md": ["ui", "feature"],
    "2026-08-03_godot-projektdateien-erstellen-und-exportieren-2.md": ["tooling"],
    "2026-08-03_godot-projektdateien-erstellen-und-exportieren.md": ["tooling"],
    "2026-08-04_anweisungs-update-fr-godot-assistent-1.md": ["meta", "tooling"],
    "2026-08-04_anweisungs-update-fr-godot-assistent.md": ["meta", "tooling"],
    "2026-08-04_casual-greeting.md": ["meta"],
    "2026-08-04_claude-cli-und-git-worktrees-erklrt-1.md": ["tooling", "git-workflow"],
    "2026-08-04_claude-cli-und-git-worktrees-erklrt.md": ["tooling", "git-workflow"],
    "2026-08-04_debug-teleporter-und-spiel-updates-1.md": ["tooling", "feature"],
    "2026-08-04_debug-teleporter-und-spiel-updates.md": ["tooling", "feature"],
    "2026-08-04_game-dev-prompt-item-bug-fixes-1.md": ["item", "bugfix"],
    "2026-08-04_game-dev-prompt-item-bug-fixes.md": ["item", "bugfix"],
    "2026-08-04_gdscript-projekt-analysiert-root-causes-identifiziert.md": ["bugfix", "refactor"],
    "2026-08-04_godot-levelgenerator-raum-pool-erweitern-1.md": ["room-generation", "feature"],
    "2026-08-04_godot-levelgenerator-raum-pool-erweitern.md": ["room-generation", "feature"],
    "2026-08-04_graphify-installation-und-einrichtung-1.md": ["tooling"],
    "2026-08-04_graphify-installation-und-einrichtung.md": ["tooling"],
    "2026-08-04_greeting.md": ["meta"],
    "2026-08-04_hilfe-bei-spielproblemen-rume-laden-nicht-1.md": ["bugfix", "room-generation"],
    "2026-08-04_hilfe-bei-spielproblemen-rume-laden-nicht.md": ["bugfix", "room-generation"],
    "2026-08-04_item--vfx-dokumentation-fr-spiel.md": ["item", "vfx", "meta"],
    "2026-08-04_item-logik-und-verbesserungsvorschlge.md": ["item", "feature"],
    "2026-08-04_jq-fehlt-graphify-fehler-beheben.md": ["tooling", "bugfix"],
    "2026-08-04_katalog-export-und-produktionsplanung.md": ["meta", "item"],
    "2026-08-04_ki-kann-godot-nicht-visuell-testen.md": ["meta", "tooling"],
    "2026-08-04_management-export-skript-vereint-git-und-powershell.md": ["tooling", "git-workflow"],
    "2026-08-04_neue-item-ideen-fr-spiel.md": ["item", "design-brainstorming"],
    "2026-08-04_python-skript-zur-obsidian-vault-generierung.md": ["tooling"],
    "2026-08-04_tabelle-mit-fortlaufender-nummerierung.md": ["meta", "tooling"],
    "2026-08-04_valorant-abilities-game-adaptation.md": ["character", "design-brainstorming"],
    "2026-08-04_valorant-agenten-fhigkeiten-bersicht.md": ["character", "design-brainstorming"],
    "2026-08-04_valorant-fhigkeiten-fr-spielekonzepte.md": ["character", "design-brainstorming"],
    "2026-08-05_git-commits-mit-claude-und-github-cli-1.md": ["tooling", "git-workflow"],
    "2026-08-05_git-commits-mit-claude-und-github-cli.md": ["tooling", "git-workflow"],
    "2026-08-05_implement-godot-game-fixes-and-features-overview-the.md": ["feature", "bugfix"],
    "2026-08-05_spiel-feature-umsetzung-statusbericht.md": ["meta", "feature"],
    "2026-08-08_was-ist-gitignore-und-warum.md": ["tooling", "git-workflow"],
    "2026-08-10_installation-von-claude-cli-tools.md": ["tooling"],
    "2026-08-10_obsidian-wiki-fr-spieleentwicklung.md": ["tooling", "meta"],
    "2026-08-10_ui-verbesserung-fr-spielmen.md": ["ui"],
    "2026-08-10_valorant-fhigkeiten-technische-implementierung.md": ["character", "combat"],
    "2026-08-10_vault-und-graphify-spielentwicklung-verstehen.md": ["tooling", "meta"],
    "2026-08-10_warp-worktree-vs-haupt-repository-wahl.md": ["tooling", "git-workflow"],
    "2026-08-11_charakter-angriffe-rework-ausformulierung-1.md": ["character", "combat", "balancing"],
    "2026-08-11_charakter-angriffe-rework-ausformulierung.md": ["character", "combat", "balancing"],
    "2026-08-11_gameplay-leveldesign-berarbeitung-1.md": ["level-design", "feature"],
    "2026-08-11_gameplay-leveldesign-berarbeitung.md": ["level-design", "feature"],
    "2026-08-11_gegner-und-spawn-raten-bersicht-1.md": ["enemy", "balancing"],
    "2026-08-11_gegner-und-spawn-raten-bersicht.md": ["enemy", "balancing"],
    "2026-08-11_implement-various-game-improvements-and-bug-fixes.md": ["feature", "bugfix"],
    "2026-08-12_bitte-analysiere-alle-ordner-und-bewerte-wie-relevant.md": ["tooling", "meta"],
    "2026-08-12_bitte-fge-alle-chats-in-mein-obsidian-ein.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-1.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-10.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-11.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-12.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-2.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-3.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-4.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-5.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-6.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-7.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-8.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade-9.md": ["tooling", "meta"],
    "2026-08-12_du-bist-ein-wiki-autor-fuer-das-spiel-lemonade.md": ["tooling", "meta"],
    "2026-08-12_kannst-du-mein-obsidian-sehen.md": ["tooling", "meta"],
    "2026-08-12_md.md": ["tooling"],
    "2026-08-12_schau-dir-den-letzten-commit-an-und-den.md": ["tooling", "git-workflow", "meta"],
    "2026-08-12_slash-command-graphify-1.md": ["tooling"],
    "2026-08-12_slash-command-graphify-2.md": ["tooling"],
    "2026-08-12_slash-command-graphify-3.md": ["tooling"],
    "2026-08-12_slash-command-graphify-4.md": ["tooling"],
    "2026-08-12_slash-command-graphify-args-raw---obsidian---obsidian-dir-brain.md": ["tooling"],
    "2026-08-12_slash-command-graphify.md": ["tooling"],
    "2026-08-12_user-raw-barrelbroken-von-den-fpsdungeonextras-lschen-das.md": ["refactor", "tooling"],
    "2026-08-12_user-raw-bitte-berprfe-und-repariere-das-ganze-1.md": ["bugfix", "tooling"],
    "2026-08-12_user-raw-bitte-berprfe-und-repariere-das-ganze.md": ["bugfix", "tooling"],
    "2026-08-12_user-raw-bitte-entferne-diese-folgenden-dateien-1.md": ["refactor", "tooling"],
    "2026-08-12_user-raw-claude---dangerously-skip-permissions-claude---dangerously-skip-permissions-1-thought.md": ["tooling"],
    "2026-08-12_user-raw-ich-muss-meine-situation-erklren-mein.md": ["tooling", "git-workflow", "meta"],
    "2026-08-12_user-raw-irgendwie-komme-ich-nicht-aus-dem.md": ["bugfix", "ui"],
    "2026-08-12_user-raw-lisieren-lisieren-1-thought-2-systems.md": ["meta"],
    "2026-08-12_user-raw-raum-ideen-balancing-entwurf-brainstorming-sammlung-fr-neue.md": ["room-generation", "design-brainstorming", "balancing"],
    "2026-08-12_user-raw-uggestions-unless-specifically-asked-uggestions-unless-1.md": ["meta"],
    "2026-08-12_user-raw-uggestions-unless-specifically-asked-uggestions-unless.md": ["meta"],
    "2026-08-12_user-raw-where-are-the-forks-where-are.md": ["tooling", "meta"],
    "2026-08-12_was-fehlt-mir-in-meinem-spiel-skip-to.md": ["meta", "design-brainstorming"],
    "2026-08-04_godot-projekt-setup-und-szenen-optimierung.md": ["tooling", "meta"],
    "2026-08-11_greeting.md": ["meta"],
    "2026-08-12_greeting.md": ["meta"],
    "2026-08-04_install-custom-statusline-script.md": ["tooling", "meta"],
    "2026-08-12_balanciere-gegner-kosten-fuer-spielmechanik.md": ["enemy", "balancing"],
    "2026-08-13_scout-und-fighter-animationen-und-modelle-beheben.md": ["enemy", "bugfix", "vfx"],
    "2026-08-13_weitere-anpassungen-ui-aenderungen-und-bugfixes.md": ["ui", "balancing", "feature"],
    "2026-08-13_tutorial-prompt-formulieren.md": ["tooling", "meta"],
    "2026-08-13_test-vfx-ordner-ingame-anzeigen.md": ["vfx", "tooling"],
    "2026-08-13_godot-projekt-aufgabenliste.md": ["meta", "feature"],
    "2026-08-12_privates-github-repo-einrichten.md": ["git-workflow", "tooling"],
    "2026-08-13_prompt-fuer-karina-item-fix-formulieren.md": ["item", "character", "tooling"],
    "2026-08-13_ningning-dash-beschreibung-als-block.md": ["character", "ui"],
    "2026-08-13_prompt-fuer-boden-textur-und-model-ausrichtung.md": ["shader", "tooling"],
    "2026-08-13_wo-sind-die-patchnotes-bei-obsidian.md": ["meta", "tooling"],
    "2026-08-12_naechste-optimierungsprozesse-fuer-das-spiel.md": ["meta", "design-brainstorming", "feature"],
    "2026-08-13_charakter-beschreibung-wechselt-mit-aktivem-charakter.md": ["ui", "character", "feature"],
    "2026-08-14_patchnotes-skript-weiterentwicklung-und-doku-guide-feedback.md": ["tooling", "meta"],
    "2026-08-12_persoenliche-daten-im-projekt-pruefen.md": ["meta", "tooling"],
}


def update_frontmatter(path: str) -> bool:
    filename = os.path.basename(path)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    ki_art = detect_ki_art(content)
    thema_list = THEMA_MAP.get(filename, [])
    if not thema_list:
        print(f"WARNUNG: kein Thema fuer {filename} hinterlegt - ueberspringe Thema-Tags.")

    fm_match = re.match(r"^---\n(.*?)\n---\n", content, re.DOTALL)
    if not fm_match:
        print(f"WARNUNG: kein Frontmatter in {filename} gefunden - uebersprungen.")
        return False
    frontmatter = fm_match.group(1)

    tags_match = re.search(r"^tags:\s*\[(.*?)\]\s*$", frontmatter, re.MULTILINE)
    if not tags_match:
        print(f"WARNUNG: keine tags:-Zeile in {filename} gefunden - uebersprungen.")
        return False

    existing_tags_raw = tags_match.group(1)
    existing_tags = [t.strip() for t in existing_tags_raw.split(",") if t.strip()]

    new_tags = list(existing_tags)
    for thema in thema_list:
        tag = f"thema/{thema}"
        if tag not in new_tags:
            new_tags.append(tag)

    if ki_art is not None:
        ki_tag = f"ki/{KI_ART_TAG_SLUG[ki_art]}"
        if ki_tag not in new_tags:
            new_tags.append(ki_tag)

    new_tags_line = "tags: [" + ", ".join(new_tags) + "]"
    new_frontmatter = frontmatter[:tags_match.start()] + new_tags_line + frontmatter[tags_match.end():]

    # ki_art-Feld: eigenes lesbares Feld zusaetzlich zum ki/*-Tag (Tags
    # koennen "wird nachgetragen" nicht abbilden, Leerzeichen nicht erlaubt).
    #
    # Ein tatsaechlich gefundener Marker (ki_art is not None) gewinnt immer.
    # Findet detect_ki_art() diesmal NICHTS, wird ein bereits aufgeloester
    # Bestandswert (z.B. per resolve_claude_ki_art.py gesetzt, ohne eigenen
    # Marker im Dateiinhalt) beibehalten statt auf "wird nachgetragen"
    # zurueckgesetzt zu werden - siehe Kopfkommentar.
    existing_ki_art_match = re.search(r'^ki_art:\s*"?([^"\n]*)"?\s*$', frontmatter, re.MULTILINE)
    existing_ki_art_value = existing_ki_art_match.group(1).strip() if existing_ki_art_match else None

    if ki_art is not None:
        ki_art_value = ki_art
    elif existing_ki_art_value and existing_ki_art_value != "wird nachgetragen":
        ki_art_value = existing_ki_art_value
    else:
        ki_art_value = "wird nachgetragen"

    if re.search(r"^ki_art:", new_frontmatter, re.MULTILINE):
        new_frontmatter = re.sub(
            r"^ki_art:.*$", f'ki_art: "{ki_art_value}"', new_frontmatter, flags=re.MULTILINE
        )
    else:
        new_frontmatter = new_frontmatter + f'\nki_art: "{ki_art_value}"'

    new_content = content[:fm_match.start(1)] + new_frontmatter + content[fm_match.end(1):]

    if new_content != content:
        with open(path, "w", encoding="utf-8") as f:
            f.write(new_content)
        return True
    return False


def main():
    changed = 0
    total = 0
    for filename in sorted(os.listdir(PROMPTS_DIR)):
        if not filename.endswith(".md"):
            continue
        total += 1
        path = os.path.join(PROMPTS_DIR, filename)
        if update_frontmatter(path):
            changed += 1
    print(f"Fertig: {changed}/{total} Dateien aktualisiert.")


if __name__ == "__main__":
    main()
