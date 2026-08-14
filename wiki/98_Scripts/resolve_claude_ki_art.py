"""
resolve_claude_ki_art.py — einmalig ausführbar.

Loest ki_art: "wird nachgetragen" zu ki_art: "claude" auf, fuer alle
Chat-Prompt-Dateien, die sich per Claude.ai-Datenexport (conversations.json)
eindeutig einer echten Claude.ai-Webchat-Session zuordnen lassen - erkannt
per exaktem/enthaltenem normalisiertem Titel-Abgleich auf dasselbe Datum
zwischen Datei-Slug und Conversation-Namen (siehe Zuordnungstabelle unten,
von Hand verifiziert bei Titel-Kollisionen mit Nachrichten-/Zeilenzahl).

MAPPING ist bewusst als fester Dict im Skript hinterlegt statt live aus dem
Export nachgerechnet: der Export selbst (conversations.json, ~68 MB) liegt
ausserhalb des Repos in ~/Downloads und soll hier nicht referenziert werden
muessen, um das Skript spaeter erneut laufen zu lassen.
"""
import os
import re

PROMPTS_DIR = os.path.join(os.path.dirname(__file__), "..", "04_Chat_Prompts")

CLAUDE_MATCHED_FILES = [
    "2026-07-17_low-poly-games-on-steam.md",
    "2026-07-17_third-person-dungeon-crawler-mit-ps1-grafik.md",
    "2026-07-18_valorant-aehnliche-bewegungsmechanik-in-godot.md",
    "2026-07-19_debugging-reticle-offset-rendering-issue.md",
    "2026-07-19_godot-scanline-shader-correction.md",
    "2026-07-21_gegner-ki-fehler-beheben-und-physik-anpassen.md",
    "2026-07-21_gegner-ki-verbessern-beim-klettern.md",
    "2026-07-21_ki-verfolgung-mit-navigationagent3d-verbessern.md",
    "2026-07-21_lava-auftrieb-und-tauchtiefe-regulieren.md",
    "2026-07-22_effizientere-methoden-zum-erstellen-von-maps.md",
    "2026-07-22_gegner-bleiben-an-kanten-stecken.md",
    "2026-07-22_menu-blur-hintergrund-problem.md",
    "2026-07-22_naechste-ziele-definieren.md",
    "2026-07-22_settings-struktur-mit-separatem-keybinds-tab.md",
    "2026-07-23_gdscript-und-tscn-dateien-anfordern.md",
    "2026-07-23_heavy-enemies-nicht-pushbar-machen.md",
    "2026-07-23_hud-ui-mit-character-anzeige-und-ability-icons.md",
    "2026-07-23_hud-ui-mit-charakteruebersicht-und-faehigkeiten.md",
    "2026-07-23_lemonade-als-gridmap-asset-mit-effekten.md",
    "2026-07-23_log-datei-ueberpruefung.md",
    "2026-07-23_pause-menu-bugs-in-level-02.md",
    "2026-07-24_character-spezifische-szenen-und-abilities.md",
    "2026-07-24_roguelike-style-room-design-variation.md",
    "2026-07-24_spielmechaniken-und-ui-anpassungen-fuer-godot-projekt.md",
    "2026-07-25_gegner-scaling-und-raumgroesse-anpassen.md",
    "2026-07-25_godot-level-generator-room-instantiation.md",
    "2026-07-25_level-design-und-gameplay-verbesserungen.md",
    "2026-07-26_commit-analyse.md",
    "2026-07-26_dateien-chronologisch-ersetzen-und-einfuegen.md",
    "2026-07-26_partikel-fuer-kampfeffekte-hinzufuegen.md",
    "2026-07-26_projekt-bugs-analysiert-und-behoben.md",
    "2026-07-26_speedrun-ranking-und-gameplay-verbesserungen.md",
    "2026-07-26_spielmechanik-und-level-design-verbesserungen.md",
    "2026-07-26_stat-system-als-grundlage-fuer-loot-mechaniken.md",
    "2026-07-26_verifikationslauf-und-offene-dungeon-skalierungen.md",
    "2026-07-27_3d-roboter-modelle-in-godot-4-gegner-szenen-integrieren.md",
    "2026-07-27_treasure-room-items-und-bomb-mechaniken.md",
    "2026-07-28_bomben-physik-und-item-verhalten-debugging.md",
    "2026-07-28_item-effekte-zentralisieren-und-kategorisieren.md",
    "2026-07-28_melee-items-mit-effekten-und-gameplay-feedback.md",
    "2026-07-28_null-instance-rotation-error-in-player-base.md",
    "2026-07-28_projekt-startet-nicht.md",
    "2026-08-01_einheiten-fehler-in-rampen-korridoren-beheben.md",
    "2026-08-01_erfolgreich-implementierte-massnahmen.md",
    "2026-08-01_game-balance-adjustments-and-file-setup.md",
    "2026-08-01_shader-einstellungen-im-inspektor-anpassen.md",
    "2026-08-03_godot-projektdateien-erstellen-und-exportieren.md",
    "2026-08-03_godot-projektdateien-erstellen-und-exportieren-2.md",
    "2026-08-04_casual-greeting.md",
    "2026-08-04_gdscript-projekt-analysiert-root-causes-identifiziert.md",
    "2026-08-04_greeting.md",
    "2026-08-04_katalog-export-und-produktionsplanung.md",
]


def update_file(filename: str) -> bool:
    path = os.path.join(PROMPTS_DIR, filename)
    if not os.path.exists(path):
        print(f"WARNUNG: {filename} existiert nicht.")
        return False

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    fm_match = re.match(r"^---\n(.*?)\n---\n", content, re.DOTALL)
    if not fm_match:
        print(f"WARNUNG: kein Frontmatter in {filename}.")
        return False
    frontmatter = fm_match.group(1)

    new_frontmatter = re.sub(
        r'^ki_art:.*$', 'ki_art: "claude"', frontmatter, flags=re.MULTILINE
    )

    tags_match = re.search(r"^tags:\s*\[(.*?)\]\s*$", new_frontmatter, re.MULTILINE)
    if tags_match:
        existing_tags = [t.strip() for t in tags_match.group(1).split(",") if t.strip()]
        if "ki/claude" not in existing_tags:
            existing_tags.append("ki/claude")
        new_tags_line = "tags: [" + ", ".join(existing_tags) + "]"
        new_frontmatter = new_frontmatter[:tags_match.start()] + new_tags_line + new_frontmatter[tags_match.end():]

    new_content = content[:fm_match.start(1)] + new_frontmatter + content[fm_match.end(1):]
    if new_content == content:
        return False

    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)
    return True


def main():
    changed = 0
    for filename in CLAUDE_MATCHED_FILES:
        if update_file(filename):
            changed += 1
    print(f"Fertig: {changed}/{len(CLAUDE_MATCHED_FILES)} Dateien auf ki_art=claude aktualisiert.")


if __name__ == "__main__":
    main()
