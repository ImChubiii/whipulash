#!/usr/bin/env python3
"""
wiki_sync.py — Vorlage fuer inkrementelle Synchronisation des Obsidian-Vaults
mit den Godot-Projektdateien.

Im Gegensatz zu generate_vault.py (einmaliger Voll-Rebuild) ist dieses
Skript als WARTUNGS-Werkzeug gedacht: nur die YAML-Frontmatter bestehender
Notizen aktualisieren, ohne Freitext-Abschnitte (Mechanik-Notizen,
Synergien, eigene Ergaenzungen) zu ueberschreiben.

Aktueller Stand: Items und Rooms sind voll funktionsfaehig (reine
YAML-Aktualisierung per Regex-Block-Ersetzung). Enemies und Status-Effekte
sind als TODO markiert, weil ihre Quellen (.tscn-Root-Node-Properties bzw.
GDScript-Konstanten) volatiler sind - dort lohnt sich eher ein Blick in
generate_vault.py und ein gezielter Voll-Rebuild dieser Kategorie.

Aufruf:
    python 98_Scripts/wiki_sync.py            # Dry-Run, zeigt nur Diffs
    python 98_Scripts/wiki_sync.py --apply     # schreibt tatsaechlich
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
APPLY = "--apply" in sys.argv

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


def read_frontmatter(note_path: Path) -> tuple[str, str]:
    """Gibt (frontmatter_block_ohne_dashes, rest_des_dokuments) zurueck."""
    text = note_path.read_text(encoding="utf-8")
    m = FRONTMATTER_RE.match(text)
    if not m:
        return "", text
    return m.group(1), text[m.end():]


def replace_frontmatter_field(frontmatter: str, key: str, value: str) -> str:
    pattern = re.compile(rf"^{key}:.*$", re.MULTILINE)
    line = f"{key}: {value}"
    if pattern.search(frontmatter):
        return pattern.sub(line, frontmatter)
    return frontmatter + f"\n{line}"


def sync_items() -> int:
    """Liest scripts/items/item_catalog.gd erneut und aktualisiert
    cooldown_seconds/charge_rooms/rarity in bestehenden Item-Notizen, ohne
    die restliche Notiz anzufassen. Neue Items werden NICHT automatisch
    angelegt - dafuer generate_vault.py erneut laufen lassen."""
    catalog = PROJECT_ROOT / "scripts/items/item_catalog.gd"
    items_dir = PROJECT_ROOT / "01_Game_Design/Items"
    if not catalog.exists() or not items_dir.exists():
        return 0

    src = catalog.read_text(encoding="utf-8")
    const_map = dict(re.findall(r'const\s+(ID_\w+)\s*:\s*String\s*=\s*"([^"]*)"', src))
    changed = 0

    for note_path in items_dir.glob("*.md"):
        item_id = note_path.stem
        const_name = next((k for k, v in const_map.items() if v == item_id), None)
        if const_name is None:
            continue

        m = re.search(
            rf'{const_name}\s*,\s*"[^"]*"\s*,\s*"[^"]*"\s*,\s*"[^"]*"\s*,\s*'
            rf'ItemData\.Kind\.(\w+)\s*,\s*ItemData\.Category\.(\w+)\s*,\s*'
            rf'ItemData\.Rarity\.(\w+)',
            src,
        )
        if not m:
            continue

        frontmatter, rest = read_frontmatter(note_path)
        new_fm = frontmatter
        new_fm = replace_frontmatter_field(new_fm, "kind", m.group(1))
        new_fm = replace_frontmatter_field(new_fm, "category", m.group(2))
        new_fm = replace_frontmatter_field(new_fm, "rarity", m.group(3))

        if new_fm != frontmatter:
            changed += 1
            print(f"[items] {item_id}: Frontmatter aktualisiert")
            if APPLY:
                note_path.write_text(f"---\n{new_fm}\n---\n{rest}", encoding="utf-8")

    return changed


def sync_rooms() -> int:
    """Liest resources/rooms/rd_*.tres erneut und aktualisiert spawn_weight/
    min_stage/unique_per_run in bestehenden Room-Notizen."""
    rooms_res_dir = PROJECT_ROOT / "resources/rooms"
    rooms_notes_dir = PROJECT_ROOT / "01_Game_Design/Rooms"
    if not rooms_res_dir.exists() or not rooms_notes_dir.exists():
        return 0

    changed = 0
    for tres_path in rooms_res_dir.glob("rd_*.tres"):
        room_id = tres_path.stem[len("rd_"):]
        note_path = rooms_notes_dir / f"{room_id}.md"
        if not note_path.exists():
            continue

        text = tres_path.read_text(encoding="utf-8")
        kv = dict(re.findall(r"^(\w+)\s*=\s*(.+)$", text, re.MULTILINE))

        frontmatter, rest = read_frontmatter(note_path)
        new_fm = frontmatter
        if "spawn_weight" in kv:
            new_fm = replace_frontmatter_field(new_fm, "spawn_weight", kv["spawn_weight"])
        if "min_stage" in kv:
            new_fm = replace_frontmatter_field(new_fm, "min_stage", kv["min_stage"])
        if "unique_per_run" in kv:
            new_fm = replace_frontmatter_field(new_fm, "unique_per_run", kv["unique_per_run"])

        if new_fm != frontmatter:
            changed += 1
            print(f"[rooms] {room_id}: Frontmatter aktualisiert")
            if APPLY:
                note_path.write_text(f"---\n{new_fm}\n---\n{rest}", encoding="utf-8")

    return changed


def sync_enemies() -> int:
    # TODO: .tscn-Root-Node-Properties der drei Dummy-Szenen erneut lesen
    # (siehe generate_vault.py parse_enemies()) und base_hp/move_speed/
    # attack_damage in 01_Game_Design/Enemies/*.md aktualisieren.
    print("[enemies] TODO: noch nicht implementiert - siehe generate_vault.py:parse_enemies()")
    return 0


def sync_status_effects() -> int:
    # TODO: scripts/status_effects/*.gd erneut parsen (DEFAULT_DURATION /
    # DEFAULT_TICK_INTERVAL / DEFAULT_DAMAGE_PER_TICK) und in
    # 01_Game_Design/Status_Effects/*.md aktualisieren.
    print("[status_effects] TODO: noch nicht implementiert - siehe generate_vault.py:parse_status_effects()")
    return 0


def main() -> None:
    mode = "APPLY" if APPLY else "DRY-RUN (kein --apply)"
    print(f"wiki_sync.py — {mode}\n")

    total = 0
    total += sync_items()
    total += sync_rooms()
    sync_enemies()
    sync_status_effects()

    print(f"\n{total} Notiz(en) {'aktualisiert' if APPLY else 'wuerden aktualisiert (Dry-Run)'}.")
    if not APPLY and total:
        print("Erneut mit --apply aufrufen, um die Aenderungen zu schreiben.")


if __name__ == "__main__":
    main()
