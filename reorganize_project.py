#!/usr/bin/env python3
"""
reorganize_project.py
======================

Verschiebt Dateien innerhalb eines Godot-4-Projekts in eine neue
Ordnerstruktur und aktualisiert dabei ALLE res://-Referenzen
(in .gd, .tscn, .tres, .import, .godot, .gdshader, .cfg, .uid-Dateien),
damit nichts im Projekt kaputt geht.

WICHTIG — BITTE VOR DER NUTZUNG LESEN:
---------------------------------------
1. Dieses Skript läuft NUR auf deinem lokalen Rechner, im Godot-Projekt-
   ordner (dort, wo project.godot liegt). Es hat KEINE Verbindung zu
   dieser Chat-Session.
2. Schliesse Godot, BEVOR du das Skript mit --apply ausführst. Godot hält
   sonst Datei-Handles offen und kann eigene .import-Neuberechnungen dazwischen-
   funken.
3. Committe deinen aktuellen Stand vorher in Git (oder mach ein Backup).
   Dieses Skript ist vorsichtig, aber "vorsichtig" ist kein Ersatz für
   "rückgängig machbar".
4. Führe IMMER zuerst den Dry-Run aus (Standard, ganz ohne --apply).
   Er verändert nichts, sondern zeigt dir genau:
       - welche Dateien verschoben würden
       - in welchen anderen Dateien welche Referenzen angepasst würden
   Lies das durch, bevor du --apply anhängst.
5. Öffne Godot danach neu und schau in die Konsole / den "Orphan"-Dialog,
   ob irgendwo eine kaputte res://-Referenz übrig geblieben ist. Das
   Skript versucht ALLE Text-Referenzen zu finden, aber es kennt nicht
   jeden Sonderfall (z. B. dynamisch aus Strings zusammengebaute Pfade
   im Code — sowas kann es nicht erkennen, weil es kein GDScript ausführt).

VERWENDUNG:
-----------
    # 1. Trockenlauf (Standard) — zeigt nur an, ändert nichts:
    python reorganize_project.py /pfad/zu/deinem/godot/projekt

    # 2. Wirklich ausführen:
    python reorganize_project.py /pfad/zu/deinem/godot/projekt --apply

    # 3. Nur ein bestimmtes Move-Set (z. B. nur "items") anwenden:
    python reorganize_project.py /pfad/zu/deinem/godot/projekt --apply --only items

Die zu verschiebenden Dateien stehen unten in MOVE_GROUPS. Passe die Liste
gern an, bevor du --apply nutzt — das ist bewusst als einfache Python-Liste
gehalten, nicht als Config-Datei, damit du direkt siehst und anpassen kannst,
was passiert.
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from dataclasses import dataclass, field
from pathlib import Path


# ============================================================================
# 1. WAS WOHIN VERSCHOBEN WERDEN SOLL
# ============================================================================
# Pfade sind relativ zum Projekt-Root, IMMER mit "/" (so wie Godot es intern
# auch für res:// nutzt, unabhängig vom Betriebssystem).
#
# Gruppiert nach "--only"-Namen, damit du z. B. nur die Item-Reorg machen
# kannst, ohne den Rest anzufassen.

MOVE_GROUPS: dict[str, list[tuple[str, str]]] = {
    "items": [
        ("scripts/item_catalog.gd",        "scripts/items/item_catalog.gd"),
        ("scripts/item_data.gd",           "scripts/items/item_data.gd"),
        ("scripts/item_manager.gd",        "scripts/items/item_manager.gd"),
        # Bewusst BEIDE Dateien unverändert mitverschoben, siehe Hinweis oben —
        # welche davon "die richtige" ist, entscheidet ihr manuell, nicht dieses Skript.
        ("scripts/item_behaviours.gd",     "scripts/items/item_behaviours.gd"),
        ("scripts/item_behaviours_1.gd",   "scripts/items/item_behaviours_1.gd"),
        ("scripts/item_description_hud.gd","scripts/items/item_description_hud.gd"),
        ("scripts/item_summary_list.gd",   "scripts/items/item_summary_list.gd"),
    ],
    "status_effects": [
        ("scripts/status_effect_manager.gd", "scripts/status_effects/status_effect_manager.gd"),
        ("scripts/status_vfx.gd",            "scripts/status_effects/status_vfx.gd"),
        ("scenes/vfx/bleed_vfx.tscn",        "scenes/vfx/status/bleed_vfx.tscn"),
    ],
    # Beispiel für spätere Erweiterung — einfach eine neue Gruppe ergänzen:
    # "loot": [
    #     ("scripts/loot_manager.gd", "scripts/loot/loot_manager.gd"),
    # ],
}

# Dateiendungen, die nach res://-Referenzen durchsucht werden.
TEXT_EXTENSIONS = {
    ".gd", ".tscn", ".tres", ".godot", ".cfg",
    ".gdshader", ".import", ".uid", ".gdshaderinc",
}

# Sidecar-Endungen: liegen neben einer Asset-Datei und MÜSSEN mitwandern,
# wenn die Hauptdatei verschoben wird (z. B. bild.png -> bild.png.import).
SIDECAR_SUFFIXES = [".import", ".uid"]


@dataclass
class Move:
    old_rel: str
    new_rel: str
    old_abs: Path = field(init=False)
    new_abs: Path = field(init=False)


@dataclass
class ReferenceHit:
    file: Path
    line_no: int
    line_text: str
    old_ref: str
    new_ref: str


# ============================================================================
# 2. HILFSFUNKTIONEN
# ============================================================================

def build_moves(root: Path, pairs: list[tuple[str, str]]) -> list[Move]:
    moves: list[Move] = []
    for old_rel, new_rel in pairs:
        m = Move(old_rel=old_rel, new_rel=new_rel)
        m.old_abs = root / old_rel
        m.new_abs = root / new_rel
        moves.append(m)
    return moves


def sidecar_paths(abs_path: Path) -> list[Path]:
    """Gibt zusätzliche Dateien zurück, die zusammen mit abs_path existieren
    könnten (z. B. foo.png.import, foo.tres.uid) und mitverschoben werden müssen."""
    result = []
    for suffix in SIDECAR_SUFFIXES:
        candidate = Path(str(abs_path) + suffix)
        if candidate.exists():
            result.append(candidate)
    return result


def iter_text_files(root: Path):
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix.lower() in TEXT_EXTENSIONS:
            yield path


def find_references(root: Path, old_rel: str) -> list[ReferenceHit]:
    """Sucht in allen relevanten Textdateien nach res://<old_rel> als
    exaktem Pfad (in Anführungszeichen, wie es .gd/.tscn/.import immer
    schreiben), nicht als Teilstring irgendeines längeren Pfades."""
    old_ref = f"res://{old_rel}"
    pattern = re.compile(re.escape(old_ref) + r'(?=["\'\s)]|$)')
    hits: list[ReferenceHit] = []

    for file in iter_text_files(root):
        try:
            text = file.read_text(encoding="utf-8")
        except (UnicodeDecodeError, PermissionError):
            continue
        if old_ref not in text:
            continue
        for line_no, line in enumerate(text.splitlines(), start=1):
            if pattern.search(line):
                hits.append(ReferenceHit(
                    file=file, line_no=line_no, line_text=line.strip(),
                    old_ref=old_ref, new_ref="",
                ))
    return hits


def replace_references(root: Path, old_rel: str, new_rel: str) -> int:
    """Ersetzt res://<old_rel> durch res://<new_rel> in allen Textdateien.
    Gibt die Anzahl geänderter Dateien zurück."""
    old_ref = f"res://{old_rel}"
    new_ref = f"res://{new_rel}"
    pattern = re.compile(re.escape(old_ref) + r'(?=["\'\s)]|$)')
    changed = 0

    for file in iter_text_files(root):
        try:
            text = file.read_text(encoding="utf-8")
        except (UnicodeDecodeError, PermissionError):
            continue
        if old_ref not in text:
            continue
        new_text, n = pattern.subn(new_ref, text)
        if n > 0:
            file.write_text(new_text, encoding="utf-8")
            changed += 1
    return changed


# ============================================================================
# 3. HAUPTLOGIK
# ============================================================================

def run(root: Path, groups: list[str], apply: bool) -> None:
    if not (root / "project.godot").exists():
        print(f"FEHLER: {root} enthält keine project.godot — falscher Ordner?")
        sys.exit(1)

    all_pairs: list[tuple[str, str]] = []
    for g in groups:
        if g not in MOVE_GROUPS:
            print(f"FEHLER: Unbekannte Gruppe '{g}'. Verfügbar: {list(MOVE_GROUPS)}")
            sys.exit(1)
        all_pairs.extend(MOVE_GROUPS[g])

    moves = build_moves(root, all_pairs)

    print(f"{'=== DRY-RUN (nichts wird verändert) ===' if not apply else '=== APPLY ==='}")
    print(f"Projekt-Root: {root}")
    print(f"Gruppen: {groups}\n")

    missing = [m for m in moves if not m.old_abs.exists()]
    for m in missing:
        print(f"  ÜBERSPRINGE (Datei nicht gefunden): {m.old_rel}")
    moves = [m for m in moves if m.old_abs.exists()]

    total_ref_files: set[Path] = set()

    for m in moves:
        sidecars = sidecar_paths(m.old_abs)
        print(f"\n[MOVE] {m.old_rel}\n    -> {m.new_rel}")
        if sidecars:
            for s in sidecars:
                print(f"    (+ Sidecar: {s.name})")

        hits = find_references(root, m.old_rel)
        # Referenz aus der zu verschiebenden Datei selbst (z. B. self-preload) mitzählen ist ok.
        if hits:
            files_touched = sorted({h.file for h in hits})
            total_ref_files.update(files_touched)
            print(f"    Referenzen gefunden in {len(files_touched)} Datei(en):")
            for h in hits[:20]:
                rel = h.file.relative_to(root)
                print(f"      - {rel}:{h.line_no}: {h.line_text[:100]}")
            if len(hits) > 20:
                print(f"      ... und {len(hits) - 20} weitere Treffer")
        else:
            print("    (keine Text-Referenzen gefunden — evtl. wird die Datei nirgends per Pfad geladen)")

    if not apply:
        print("\n--- Dry-Run Ende ---")
        print(f"Betroffene Dateien mit Referenzen insgesamt: {len(total_ref_files)}")
        print("Nichts wurde verändert. Wenn das Ergebnis passt: erneut mit --apply ausführen.")
        return

    print("\n--- Führe Verschiebung + Referenz-Updates aus ---")
    for m in moves:
        m.new_abs.parent.mkdir(parents=True, exist_ok=True)
        if m.new_abs.exists():
            print(f"  WARNUNG: Ziel existiert bereits, überspringe: {m.new_rel}")
            continue

        # Sidecars (foo.png.import, foo.tres.uid, ...) VOR dem Move der
        # Hauptdatei ermitteln, damit die alten Pfade noch existieren.
        pending_sidecars = [
            (old_s, Path(str(m.new_abs) + old_s.name[len(m.old_abs.name):]))
            for old_s in sidecar_paths(m.old_abs)
        ]

        shutil.move(str(m.old_abs), str(m.new_abs))
        print(f"  verschoben: {m.old_rel} -> {m.new_rel}")

        for old_sidecar, new_sidecar in pending_sidecars:
            shutil.move(str(old_sidecar), str(new_sidecar))
            print(f"    Sidecar verschoben: {old_sidecar.name} -> {new_sidecar.relative_to(root)}")

        n_changed = replace_references(root, m.old_rel, m.new_rel)
        print(f"    Referenzen aktualisiert in {n_changed} Datei(en)")

    print("\nFERTIG. Bitte jetzt Godot öffnen, Projekt neu importieren lassen")
    print("und die Konsole/den 'Orphan Resources'-Dialog auf verbleibende")
    print("Fehler prüfen (Editor > Projekt > Werkzeuge > Verwaiste Ressourcen).")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("project_root", type=Path, help="Pfad zum Godot-Projektordner (enthält project.godot)")
    parser.add_argument("--apply", action="store_true", help="Änderungen wirklich ausführen (sonst nur Dry-Run)")
    parser.add_argument(
        "--only", nargs="*", default=list(MOVE_GROUPS.keys()),
        help=f"Nur diese Move-Gruppen anwenden. Verfügbar: {list(MOVE_GROUPS.keys())}",
    )
    args = parser.parse_args()

    root = args.project_root.resolve()
    run(root, args.only, args.apply)


if __name__ == "__main__":
    main()
