#!/usr/bin/env python3
"""
Godot Projekt-Reorganisierung
Verschiebt Dateien in saubere Ordner und korrigiert ALLE res:// Pfade.
"""

import shutil
import sys
from pathlib import Path

# =============================================================================
# KONFIGURATION: Was wohin soll
# =============================================================================
MOVES = {
    # --- Skripte (Root & scenes/ -> scripts/) ---
    "lemonade.gd":                          "scripts/hazards/lemonade.gd",
    "player_stats.gd":                      "scripts/core/player_stats.gd",
    "scenes/area_3d.gd":                    "scripts/level/area_3d.gd",
    "scenes/damage_number.gd":              "scripts/ui/damage_number.gd",
    "scenes/enemy_ai.gd":                   "scripts/enemies/enemy_ai.gd",
    "scenes/enemy_spawner.gd":              "scripts/enemies/enemy_spawner.gd",
    "scenes/goal_zone.gd":                  "scripts/level/goal_zone.gd",
    "scenes/health_bar_3d.gd":              "scripts/ui/health_bar_3d.gd",

    # --- Szenen (Root & scenes/ -> besser sortiert) ---
    "lemonade.tscn":                        "scenes/hazards/lemonade.tscn",
    "scenes/damage_number.tscn":            "scenes/ui/damage_number.tscn",
    "scenes/dummy.tscn":                    "scenes/enemies/dummy.tscn",
    "scenes/floor.tscn":                    "scenes/environment/floor.tscn",
    "scenes/ability_slot.tscn":             "scenes/ui/ability_slot.tscn",
    "scenes/hud.tscn":                      "scenes/ui/hud.tscn",

    # --- Assets: Models ---
    "assets/blossom_the_powerpuff_girls.glb":       "assets/characters/blossom_the_powerpuff_girls.glb",
    "assets/lowpoly_robots.glb":                    "assets/characters/lowpoly_robots.glb",

    # --- Assets: Environment Ordner ---
    "assets/dungeon_kit":                           "assets/environments/dungeon_kit",
    "assets/dungeon kit v2":                        "assets/environments/dungeon_kit_v2",

    # --- Assets: Einzelne Texturen ---
    "assets/blossom_the_powerpuff_girls_0.png":     "assets/textures/characters/blossom_the_powerpuff_girls_0.png",
    "assets/lowpoly_robots_0.png":                  "assets/textures/characters/lowpoly_robots_0.png",
    "assets/image-removebg-preview (9).png":        "assets/textures/ui/image-removebg-preview (9).png",
    "assets/image-removebg-preview (10).png":       "assets/textures/ui/image-removebg-preview (10).png",
    "assets/image-removebg-preview (11).png":       "assets/textures/ui/image-removebg-preview (11).png",

    # --- Root-UI/Export-Assets ---
    "image-removebg-preview (13).png":              "assets/ui/image-removebg-preview (13).png",
    "index.apple-touch-icon.png":                   "assets/ui/web/index.apple-touch-icon.png",
    "index.icon.png":                               "assets/ui/web/index.icon.png",
    "index.png":                                    "assets/ui/web/index.png",
    "Lemonade.apple-touch-icon.png":                "assets/ui/web/Lemonade.apple-touch-icon.png",
    "Lemonade.icon.png":                            "assets/ui/web/Lemonade.icon.png",
    "Lemonade.png":                                 "assets/ui/web/Lemonade.png",
    "icon.svg":                                     "assets/ui/icon.svg",
}

TEXT_EXTENSIONS = {".gd", ".tscn", ".tres", ".cfg", ".import", ".md", ".txt"}
IGNORED_DIRS = {".git", "builds", "exports", ".vscode", "__pycache__"}


def get_project_dir():
    cwd = Path.cwd()
    if (cwd / "project.godot").exists():
        print(f"✅ Projekt gefunden: {cwd}")
        return cwd
    
    print("❌ Kein project.godot im aktuellen Ordner gefunden.")
    while True:
        try:
            path_str = input("Gib den vollstaendigen Pfad zum Projektordner ein: ").strip().strip('"')
            p = Path(path_str)
            if (p / "project.godot").exists():
                print(f"✅ Projekt gefunden: {p}")
                return p
            print("⚠️  Hier liegt kein project.godot. Versuche es erneut.")
        except KeyboardInterrupt:
            sys.exit(0)


def main():
    project_dir = get_project_dir()

    # -------------------------------------------------------------------------
    # Schritt 1: Verschieben
    # -------------------------------------------------------------------------
    print("\n📁 Verschiebe Dateien & Ordner...")
    moves_executed = []

    for old_rel, new_rel in MOVES.items():
        old_path = project_dir / old_rel
        new_path = project_dir / new_rel

        if not old_path.exists():
            print(f"  ⚠️  Nicht gefunden: {old_rel}")
            continue

        new_path.parent.mkdir(parents=True, exist_ok=True)

        if new_path.exists():
            if new_path.is_dir():
                shutil.rmtree(new_path)
            else:
                new_path.unlink()

        shutil.move(str(old_path), str(new_path))
        moves_executed.append((old_rel, new_rel))
        print(f"  ✅ {old_rel}  →  {new_rel}")

    # -------------------------------------------------------------------------
    # Schritt 2: res:// Pfade in allen Textdateien ersetzen
    # -------------------------------------------------------------------------
    print("\n📝 Aktualisiere Verweise in .gd, .tscn, .tres, .import, .cfg ...")

    replacements = []
    for old_rel, new_rel in moves_executed:
        old_rel = old_rel.replace("\\", "/")
        new_rel = new_rel.replace("\\", "/")
        replacements.append((f"res://{old_rel}", f"res://{new_rel}"))

    # Längste zuerst (verhindert Teilstring-Fehler)
    replacements.sort(key=lambda x: len(x[0]), reverse=True)

    scanned = 0
    changed = 0

    for ext in TEXT_EXTENSIONS:
        for file_path in project_dir.rglob(f"*{ext}"):
            rel_parts = file_path.relative_to(project_dir).parts
            if any(part in IGNORED_DIRS for part in rel_parts):
                continue

            try:
                text = file_path.read_text(encoding="utf-8")
            except Exception as e:
                continue

            new_text = text
            for old, new in replacements:
                new_text = new_text.replace(old, new)

            if new_text != text:
                file_path.write_text(new_text, encoding="utf-8")
                changed += 1
            scanned += 1

    print(f"  📊 {scanned} Dateien gescannt, {changed} angepasst.")

    # -------------------------------------------------------------------------
    # Schritt 3: Leere Ordner aufräumen
    # -------------------------------------------------------------------------
    print("\n🧹 Räume leere Ordner auf...")
    deleted = 0
    for subdir in sorted(project_dir.rglob("*"), key=lambda p: len(p.parts), reverse=True):
        if subdir.is_dir() and subdir != project_dir:
            if any(part in IGNORED_DIRS for part in subdir.relative_to(project_dir).parts):
                continue
            try:
                subdir.rmdir()
                deleted += 1
            except OSError:
                pass
    print(f"  🗑️  {deleted} leere Ordner entfernt.")

    # -------------------------------------------------------------------------
    # Fertig
    # -------------------------------------------------------------------------
    print("\n" + "="*60)
    print("✅ FERTIG!")
    print("="*60)
    print("""
WICHTIG – Nächste Schritte:
  1. Godot muss komplett GESCHLOSSEN sein.
  2. Lösche den Ordner '.godot/' in deinem Projektverzeichnis.
     (Das ist der Import-Cache. Er wird neu aufgebaut.)
  3. Starte Godot neu und öffne das Projekt.
  4. Warte, bis der Import abgeschlossen ist (Fortschrittsbalken unten).
  5. Prüfe die Fehlerkonsole (Fehler sollten keine auftauchen).

Falls doch ein Pfad falsch ist:
  - Das Skript hat KEIN Backup erstellt. Nutze für die Zukunft Git!
  - Szenen-Dateien (.tscn) kannst du mit einem Texteditor öffnen
    und manuell korrigieren – sie sind lesbar.
    """)


if __name__ == "__main__":
    main()
