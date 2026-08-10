#!/usr/bin/env python3
"""
generate_vault.py — baut ein vollstaendiges Obsidian-Vault fuer das Godot-
Projekt "Whiplash" im aktuellen Verzeichnis auf.

Datenquelle ist NICHT die rohe _project_export.txt (deren TEIL 3 ohnehin nur
ein Text-Dump derselben Dateien ist, die im Projekt bereits auf der Platte
liegen), sondern die echten Projektdateien selbst:

    scripts/items/item_catalog.gd        -> 01_Game_Design/Items
    resources/enemies/es_*.tres          -> 01_Game_Design/Enemies
    scenes/{enemies,scout_dummy,tank_dummy}.tscn (Balancing-Werte)
    resources/rooms/rd_*.tres            -> 01_Game_Design/Rooms
    scripts/status_effects/*.gd          -> 01_Game_Design/Status_Effects
    git log                              -> 03_DevLogs

Das ist zugleich vollstaendiger (68 Items statt der zehn im Auftrag
namentlich genannten) und robuster als ein Regex-Sweep ueber den Export-Text.
Die Commit-Beschreibungen aus TEIL 1 fliessen als Fliesstext in die
Architektur-Notizen und DevLogs ein.

Aufruf:
    python generate_vault.py

Das Skript ist idempotent: erneutes Ausfuehren ueberschreibt vorhandene
generierte Dateien mit dem aktuellen Stand der Projektdateien.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent

# ============================================================================
# Kleine Helfer
# ============================================================================

def write_md(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def slugify(text: str) -> str:
    text = text.strip().lower()
    text = re.sub(r"[^a-z0-9äöüß_\- ]", "", text)
    text = text.replace("ä", "ae").replace("ö", "oe").replace("ü", "ue").replace("ß", "ss")
    text = re.sub(r"[\s_]+", "_", text)
    return text.strip("_")


def yaml_escape(value: str) -> str:
    value = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{value}"'


def yaml_list(items: list[str]) -> str:
    if not items:
        return "[]"
    return "[" + ", ".join(yaml_escape(i) for i in items) + "]"


# ============================================================================
# 1) ORDNERSTRUKTUR
# ============================================================================

FOLDERS = [
    "00_Dashboard",
    "01_Game_Design/Items",
    "01_Game_Design/Enemies",
    "01_Game_Design/Rooms",
    "01_Game_Design/Status_Effects",
    "02_Tech_Architecture",
    "03_DevLogs",
    "99_Templates",
    "98_Scripts",
]


def ensure_folders() -> None:
    for folder in FOLDERS:
        (PROJECT_ROOT / folder).mkdir(parents=True, exist_ok=True)


# ============================================================================
# 2) DATAVIEW-TEMPLATES (99_Templates)
# ============================================================================

TPL_ITEM = """---
id: ""
name: ""
subtitle: ""
kind: ""            # PASSIVE | ACTIVE
category: ""        # MELEE | MOVEMENT | DEFENSE | UTILITY
rarity: COMMON       # COMMON | UNCOMMON | RARE | EPIC | LEGENDARY
cooldown_seconds: 0.0
charge_rooms: 0
nr: ""
table_ref: ""
status_effects: []
tags: [item]
---

# {{name}}

> {{subtitle}}

## Effekt

{{description}}

## Status-Effekte

-

## Synergien

-

## Quelle

`scripts/items/item_catalog.gd`
"""

TPL_ENEMY = """---
id: ""
display_name: ""
threat_cost: 0
base_hp: 0
move_speed: 0.0
speed_variance: 0.0
attack_damage: 0.0
attack_cooldown: 0.0
detection_range: 0.0
is_heavy: false
is_large_enemy: false
tags: [enemy]
---

# {{display_name}}

## Mechanik

-

## Balancing

| Wert | Betrag |
|---|---|
| Threat-Cost | {{threat_cost}} |
| HP | {{base_hp}} |
| Move-Speed | {{move_speed}} |
| Speed-Variance | {{speed_variance}} |

## Quelle

`scripts/enemies/enemy_ai.gd`
"""

TPL_ROOM = """---
id: ""
room_type: ""        # COMBAT | TREASURE | BOSS | CORRIDOR | SHOP | START
footprint_cells: "1x1"
available_exits: []
spawn_weight: 1.0
min_stage: 0
unique_per_run: false
scene_path: ""
tags: [room]
---

# {{id}}

## Layout-Notizen

-

## Quelle

`resources/rooms/rd_{{id}}.tres`
"""

TPL_STATUS_EFFECT = """---
id: ""
duration: 0.0
tick_interval: 0.0
damage_per_tick: 0.0
synergies: []
triggered_by_items: []
tags: [status-effect]
---

# {{id}}

## Wirkung

-

## Synergien

-

## Ausgeloest von (Items)

-

## Quelle

`scripts/status_effects/{{id}}.gd`
"""


def write_templates() -> None:
    write_md(PROJECT_ROOT / "99_Templates/tpl_Item.md", TPL_ITEM)
    write_md(PROJECT_ROOT / "99_Templates/tpl_Enemy.md", TPL_ENEMY)
    write_md(PROJECT_ROOT / "99_Templates/tpl_Room.md", TPL_ROOM)
    write_md(PROJECT_ROOT / "99_Templates/tpl_StatusEffect.md", TPL_STATUS_EFFECT)


# ============================================================================
# 3) ITEMS — geparst aus scripts/items/item_catalog.gd
# ============================================================================

ITEM_CONST_RE = re.compile(r'const\s+(ID_\w+)\s*:\s*String\s*=\s*"([^"]*)"')

ITEM_CREATE_RE = re.compile(
    r'var\s+(\w+)\s*:=\s*ItemData\.create\(\s*'
    r'(ID_\w+)\s*,\s*'
    r'"((?:[^"\\]|\\.)*)"\s*,\s*'
    r'"((?:[^"\\]|\\.)*)"\s*,\s*'
    r'"((?:[^"\\]|\\.)*)"\s*,\s*'
    r'ItemData\.Kind\.(\w+)\s*,\s*ItemData\.Category\.(\w+)\s*,\s*ItemData\.Rarity\.(\w+)'
    r'(?:\s*,\s*(\d+)\s*,\s*"([^"]*)")?'
    r'\s*\)',
    re.DOTALL,
)


def parse_items() -> list[dict]:
    src = (PROJECT_ROOT / "scripts/items/item_catalog.gd").read_text(encoding="utf-8")
    const_map = dict(ITEM_CONST_RE.findall(src))

    items = []
    for m in ITEM_CREATE_RE.finditer(src):
        var_name = m.group(1)
        id_const = m.group(2)
        name, subtitle, description = m.group(3), m.group(4), m.group(5)
        kind, category, rarity = m.group(6), m.group(7), m.group(8)
        nr, table_ref = m.group(9), m.group(10)

        # Block zwischen Ende dieses create()-Aufrufs und dem passenden
        # items.append(var_name) durchsuchen: dort stehen cooldown_seconds /
        # charge_rooms / stat_modifiers, die create() selbst nicht setzt.
        append_marker = f"items.append({var_name})"
        append_pos = src.find(append_marker, m.end())
        block = src[m.end():append_pos] if append_pos != -1 else ""

        cooldown_m = re.search(rf'{var_name}\.cooldown_seconds\s*=\s*([\d.]+)', block)
        charge_m = re.search(rf'{var_name}\.charge_rooms\s*=\s*(\d+)', block)
        has_stat_mods = f"{var_name}.stat_modifiers" in block

        items.append({
            "var": var_name,
            "id": const_map.get(id_const, id_const.replace("ID_", "").lower()),
            "name": name.replace("\\'", "'"),
            "subtitle": subtitle.replace("\\'", "'"),
            "description": description.replace("\\'", "'"),
            "kind": kind,
            "category": category,
            "rarity": rarity,
            "nr": nr or "",
            "table_ref": table_ref or "",
            "cooldown_seconds": float(cooldown_m.group(1)) if cooldown_m else 0.0,
            "charge_rooms": int(charge_m.group(1)) if charge_m else 0,
            "has_stat_modifiers": has_stat_mods,
        })
    return items


def write_item_notes(items: list[dict], item_status_links: dict[str, list[str]]) -> None:
    out_dir = PROJECT_ROOT / "01_Game_Design/Items"
    for it in items:
        linked_effects = item_status_links.get(it["id"], [])
        effects_section = (
            "\n".join(f"- [[{eid}]]" for eid in linked_effects) if linked_effects else "- —"
        )
        body = f"""---
id: {yaml_escape(it['id'])}
name: {yaml_escape(it['name'])}
subtitle: {yaml_escape(it['subtitle'])}
kind: {it['kind']}
category: {it['category']}
rarity: {it['rarity']}
cooldown_seconds: {it['cooldown_seconds']}
charge_rooms: {it['charge_rooms']}
nr: {yaml_escape(it['nr'])}
table_ref: {yaml_escape(it['table_ref'])}
has_stat_modifiers: {str(it['has_stat_modifiers']).lower()}
status_effects: {yaml_list(linked_effects)}
tags: [item, "item/{it['kind'].lower()}", "rarity/{it['rarity'].lower()}"]
---

# {it['name']}

> *{it['subtitle']}*

## Effekt

{it['description']}

## Status-Effekte

Verifiziert aus `item_behaviours.gd` (Aufrufe wie `StatusX.apply()` /
`StatusEffectBase.apply_raw()` im Code-Pfad dieses Items):

{effects_section}

## Metadaten

| Feld | Wert |
|---|---|
| ID | `{it['id']}` |
| Kind | {it['kind']} |
| Kategorie | {it['category']} |
| Rarity | {it['rarity']} |
| Cooldown | {(str(it['cooldown_seconds']) + ' s') if it['cooldown_seconds'] else '—'} |
| Charge (Raeume) | {it['charge_rooms'] if it['charge_rooms'] else '—'} |
| Design-Doc-Ref | {it['table_ref'] or '—'} |

## Quelle

`scripts/items/item_catalog.gd` (Konstante `ID_{it['id'].upper()}`, Variable `{it['var']}`)
"""
        write_md(out_dir / f"{it['id']}.md", body)


# ============================================================================
# 3b) ITEM <-> STATUS-EFFECT VERKNUEPFUNG — geparst aus item_behaviours.gd
# ============================================================================
# Codebasierte (nicht geratene) Verlinkung: ein Item wird nur dann mit einem
# Statuseffekt verlinkt, wenn im tatsaechlichen Verhaltenscode ein Aufruf wie
# StatusBurn.apply(...) / StatusEffectBase.apply_raw(target, "vulnerable", ...)
# in einem Codeblock steht, der nachweislich zu diesem Item gehoert.

KNOWN_STATUS_IDS = {
    "acid", "burn", "charm", "confused", "rooted", "silenced", "slow", "stun", "vulnerable",
}

FUNC_BODY_RE = re.compile(r'^func\s+(\w+)\s*\([^)]*\)[^:]*:\n(.*?)(?=^func\s|\Z)', re.DOTALL | re.MULTILINE)
STATUS_CLASS_CALL_RE = re.compile(
    r'Status(Acid|Burn|Charm|Confused|Rooted|Silenced|Slow|Stun)\.\w+\('
)
APPLY_RAW_LITERAL_RE = re.compile(r'apply_raw\(\s*\w+\s*,\s*"(\w+)"')
DISPATCH_RE = re.compile(r'ItemCatalog\.(ID_\w+):\s*\n\s*(_\w+)\(')
HAS_ITEM_RE = re.compile(r'_has\(\s*ItemCatalog\.(ID_\w+)\s*\)')

FUZZY_PREFIXES = ("_apply_", "_use_", "_tick_", "_trigger_", "_spawn_")


def _status_ids_in_text(text: str) -> set[str]:
    ids = set()
    for m in STATUS_CLASS_CALL_RE.finditer(text):
        ids.add(m.group(1).lower())
    for m in APPLY_RAW_LITERAL_RE.finditer(text):
        if m.group(1) in KNOWN_STATUS_IDS:
            ids.add(m.group(1))
    return ids


def _resolve_call_chain(seed_text: str, func_bodies: dict[str, str], max_depth: int = 4) -> str:
    """Loest Funktionsaufrufe innerhalb von seed_text rekursiv auf (bis
    max_depth), damit z.B. `if _has(ID_CHEWING_GUM): _spawn_gum_trail(player)`
    auch den Status-Effekt-Aufruf findet, der erst zwei Funktionsebenen
    tiefer in `_spawn_gum_blob()` steht (`StatusAcid.extend_for_gum(...)`)."""
    visited: set[str] = set()
    collected = [seed_text]
    frontier = [seed_text]
    for _ in range(max_depth):
        next_frontier = []
        for text in frontier:
            for name in re.findall(r'\b(\w+)\(', text):
                if name in func_bodies and name not in visited:
                    visited.add(name)
                    body = func_bodies[name]
                    collected.append(body)
                    next_frontier.append(body)
        if not next_frontier:
            break
        frontier = next_frontier
    return "\n".join(collected)


def _extract_has_blocks(src: str, const_name: str) -> list[str]:
    """Extrahiert den eingerueckten Codeblock nach jedem
    `_has(ItemCatalog.ID_X)` (if/elif) per Einrueckungstiefe."""
    lines = src.split("\n")
    blocks = []
    for i, line in enumerate(lines):
        if re.search(rf'_has\(\s*ItemCatalog\.{re.escape(const_name)}\s*\)', line):
            indent = len(line) - len(line.lstrip())
            body = []
            for l in lines[i + 1:]:
                if l.strip() == "":
                    body.append(l)
                    continue
                if len(l) - len(l.lstrip()) <= indent:
                    break
                body.append(l)
            blocks.append("\n".join(body))
    return blocks


def _strip_gd_comments(text: str) -> str:
    """Entfernt `# ...`-Kommentare zeilenweise (stringbewusst), BEVOR nach
    Funktionsaufrufen gesucht wird. Ohne das haelt `_resolve_call_chain()``
    jede in einem Kommentar ERWAEHNTE Funktion (z.B. "## wird aus
    _on_player_hit_enemy() aufgerufen") faelschlich fuer einen echten Aufruf
    und zieht darueber die riesige, fuer alle Items gemeinsame Hook-Funktion
    in die Aufloesung hinein."""
    out_lines = []
    for line in text.split("\n"):
        in_str = False
        cut_at = None
        for i, ch in enumerate(line):
            if ch == '"' and (i == 0 or line[i - 1] != "\\"):
                in_str = not in_str
            elif ch == "#" and not in_str:
                cut_at = i
                break
        out_lines.append(line[:cut_at] if cut_at is not None else line)
    return "\n".join(out_lines)


def parse_item_status_links(items: list[dict]) -> dict[str, list[str]]:
    behaviours_path = PROJECT_ROOT / "scripts/items/item_behaviours.gd"
    if not behaviours_path.exists():
        return {}
    src = _strip_gd_comments(behaviours_path.read_text(encoding="utf-8"))

    func_bodies = {m.group(1): m.group(2) for m in FUNC_BODY_RE.finditer(src)}
    dispatch_map = dict(DISPATCH_RE.findall(src))  # ID_CONST -> _use_x function name

    const_to_id = {}
    for it in items:
        const_name = f"ID_{it['id'].upper()}"
        const_to_id[const_name] = it["id"]

    result: dict[str, set[str]] = {it["id"]: set() for it in items}

    for it in items:
        const_name = f"ID_{it['id'].upper()}"
        normalized_id = it["id"].replace("_", "")
        aggregate_texts = []

        # 1) Aktiv-Items: direkte Dispatch-Tabelle (match item.id: ID_X: _use_x()),
        #    Funktionsaufrufe darin rekursiv aufgeloest.
        if const_name in dispatch_map:
            fn = dispatch_map[const_name]
            if fn in func_bodies:
                aggregate_texts.append(_resolve_call_chain(func_bodies[fn], func_bodies))

        # 2) Inline-Bloecke: alles, was direkt unter `if _has(ItemCatalog.ID_X)`
        #    haengt, inkl. rekursiv aufgeloester Funktionsaufrufe darin (deckt
        #    Ketten wie _spawn_gum_trail() -> _spawn_gum_blob() -> StatusAcid ab).
        for block in _extract_has_blocks(src, const_name):
            aggregate_texts.append(_resolve_call_chain(block, func_bodies))

        # 3) Namens-Heuristik: dedizierte _apply_x/_use_x/_tick_x/... Funktionen,
        #    deren Namenssuffix eindeutig zur Item-ID passt (inkl. Aufloesung).
        for fn_name, body in func_bodies.items():
            if not fn_name.startswith(FUZZY_PREFIXES):
                continue
            suffix = fn_name
            for prefix in FUZZY_PREFIXES:
                if suffix.startswith(prefix):
                    suffix = suffix[len(prefix):]
                    break
            normalized_suffix = suffix.replace("_", "")
            if len(normalized_suffix) < 4:
                continue
            if normalized_suffix == normalized_id or (
                len(normalized_suffix) >= 5
                and (normalized_suffix in normalized_id or normalized_id in normalized_suffix)
            ):
                aggregate_texts.append(_resolve_call_chain(body, func_bodies))

        found = _status_ids_in_text("\n".join(aggregate_texts))
        result[it["id"]] |= found

    return {k: sorted(v) for k, v in result.items() if v}


# ============================================================================
# 4) ENEMIES — geparst aus resources/enemies/es_*.tres + den drei
#    Gegner-Szenen (dummy.tscn, scout_dummy.tscn, tank_dummy.tscn)
# ============================================================================

ENEMY_SCENES = {
    "Fighter": "scenes/enemies/dummy.tscn",
    "Stinger": "scenes/scout_dummy.tscn",
    "Colossus": "scenes/tank_dummy.tscn",
}
ENEMY_SPAWN_ENTRIES = {
    "Fighter": "resources/enemies/es_fighter.tres",
    "Stinger": "resources/enemies/es_stinger.tres",
    "Colossus": "resources/enemies/es_colossus.tres",
}

# Handgepflegte Mechanik-Absaetze — aus den Commit-Beschreibungen in TEIL 1
# der _project_export.txt (Zigzag/Lean-Telegraphing, Unstuck, Buoyancy,
# Stun-Lock-Schutz), weil diese Verhaltensbeschreibung als Freitext in keiner
# .tres/.tscn-Property steckt.
ENEMY_MECHANICS = {
    "Fighter": (
        "Traeger Nahkaempfer mit hoher Reichweite (`is_heavy = true`, "
        "Knockback-resistent). Nutzt Sprung- und Ledge-Checks, um Huerden im "
        "Level zu ueberwinden (`can_jump_across_ledges`)."
    ),
    "Stinger": (
        "Schneller Flankierer mit Zigzag-Verfolgung (`zigzag_enabled = true`, "
        "`zigzag_angle_degrees = 58`): naehert sich in weich interpolierten "
        "Schlangenlinien statt geradem Kurs an, inklusive sichtbarem "
        "Lean-Telegraphing beim Kurvenwechsel statt hartem Snap. "
        "`focus_loss_enabled` laesst ihn gelegentlich das Ziel kurz verlieren "
        "und umherwandern, bevor er erneut andockt."
    ),
    "Colossus": (
        "Boss-Klasse Schwergewicht (`is_large_enemy = true`, `is_heavy = true`, "
        "kein Sprung). Besitzt Lava-Buoyancy ueber `set_buoyancy()`: statt im "
        "Lavabecken komplett zu versinken, bobbt er auf ca. 2/3 seiner "
        "Koerperhoehe. Alle Gegnertypen teilen ausserdem eine "
        "Auto-Unstuck-Routine (`unstuck_enabled`), die nach "
        "`unstuck_stationary_time` Sekunden ohne Fortschritt einen Impuls "
        "nach oben/seitlich ausloest."
    ),
}

STUN_LOCK_NOTE = (
    "**Stun-Lock-Schutz (global, [[player_base]]):** zweistufig. 1) "
    "Diminishing Returns — jeder weitere Stun innerhalb des Ketten-Zeitfensters "
    "wirkt nur noch `stun_diminish_factor` so lang wie der vorherige. 2) "
    "Immunitaetsfenster — nach `stun_max_chain` Stuns in Folge greift eine "
    "kurze Stun-Immunitaet, bevor die Kette von vorn beginnt."
)

# enemy_ai.gd: DOT_EFFECT_IDS = ["poison", "bleed", "burn", "acid"] — von diesen
# vier existieren nur "burn" und "acid" als eigene status_effects/*.gd-Datei;
# poison/bleed sind (noch) nicht implementiert und werden bewusst nicht verlinkt.
ENEMY_DOT_STATUS_IDS = {"burn", "acid"}
# enemy_ai.gd::is_attack_locked() -> has_effect("stun") or has_effect("silenced")
ENEMY_ATTACK_LOCK_STATUS_IDS = {"stun", "silenced"}
# resources/enemies/es_colossus.tres: min_room_height = 20.0 — laut Kommentar
# in enemy_spawn_entry.gd ausdruecklich fuer die 24 Units hohe Boss-Arena gedacht.
COLOSSUS_ROOM_NOTE = (
    "- [[boss_01]] — `min_room_height = 20.0` in `es_colossus.tres` ist laut "
    "Kommentar in `enemy_spawn_entry.gd` bewusst auf die 24 Units hohe "
    "Boss-Arena zugeschnitten; kein anderer Raumtyp ist hoch genug."
)


def parse_tres_kv(text: str) -> dict[str, str]:
    kv = {}
    for line in text.splitlines():
        m = re.match(r'^(\w+)\s*=\s*(.+)$', line.strip())
        if m:
            kv[m.group(1)] = m.group(2)
    return kv


def parse_tscn_root_node(text: str) -> dict[str, str]:
    """Liest die Properties des ERSTEN [node ...]-Blocks (die Wurzel des
    CharacterBody3D mit enemy_ai.gd), bis der naechste [node/sub_resource-
    Block beginnt."""
    lines = text.splitlines()
    start = None
    for i, line in enumerate(lines):
        if line.startswith("[node name="):
            start = i + 1
            break
    if start is None:
        return {}
    kv = {}
    for line in lines[start:]:
        if line.startswith("["):
            break
        m = re.match(r'^(\w+)\s*=\s*(.+)$', line.strip())
        if m:
            kv[m.group(1)] = m.group(2)
    return kv


def parse_enemies() -> list[dict]:
    enemies = []
    for display_name, scene_rel in ENEMY_SCENES.items():
        scene_text = (PROJECT_ROOT / scene_rel).read_text(encoding="utf-8")
        root = parse_tscn_root_node(scene_text)

        health_m = re.search(r'\[node name="Health"[^\]]*\][^\[]*', scene_text)
        max_health = 30.0  # Health.gd-Default, falls max_health nicht ueberschrieben wird
        if health_m:
            hp_m = re.search(r'max_health\s*=\s*([\d.]+)', health_m.group(0))
            if hp_m:
                max_health = float(hp_m.group(1))

        hitbox_m = re.search(r'\[node name="AttackHitbox"[^\]]*\][^\[]*', scene_text)
        attack_damage = 0.0
        if hitbox_m:
            dmg_m = re.search(r'damage\s*=\s*([\d.]+)', hitbox_m.group(0))
            if dmg_m:
                attack_damage = float(dmg_m.group(1))

        spawn_entry_rel = ENEMY_SPAWN_ENTRIES.get(display_name)
        spawn_kv = {}
        if spawn_entry_rel and (PROJECT_ROOT / spawn_entry_rel).exists():
            spawn_kv = parse_tres_kv((PROJECT_ROOT / spawn_entry_rel).read_text(encoding="utf-8"))

        enemies.append({
            "display_name": display_name,
            "scene": scene_rel,
            "move_speed": float(root.get("move_speed", "0.0")),
            "speed_variance": float(root.get("speed_variance", "0.0")),
            "detection_range": float(root.get("detection_range", "0.0")),
            "attack_cooldown": float(root.get("attack_cooldown", "0.0")),
            "attack_damage": attack_damage,
            "base_hp": max_health,
            "is_heavy": root.get("is_heavy", "false") == "true",
            "is_large_enemy": root.get("is_large_enemy", "false") == "true",
            "zigzag_enabled": root.get("zigzag_enabled", "false") == "true",
            "threat_cost": int(float(spawn_kv.get("threat_cost", "1"))),
            "weight": float(spawn_kv.get("weight", "1.0")),
            "max_per_room": int(float(spawn_kv.get("max_per_room", "99"))),
            "min_room_height": float(spawn_kv.get("min_room_height", "0.0")),
            "guaranteed_count": int(float(spawn_kv.get("guaranteed_count", "0"))),
            "min_spawn_spacing": float(spawn_kv.get("min_spawn_spacing", "0.0")),
        })
    return enemies


def write_enemy_notes(enemies: list[dict]) -> None:
    out_dir = PROJECT_ROOT / "01_Game_Design/Enemies"
    for e in enemies:
        body = f"""---
id: {yaml_escape(slugify(e['display_name']))}
display_name: {yaml_escape(e['display_name'])}
threat_cost: {e['threat_cost']}
base_hp: {e['base_hp']}
move_speed: {e['move_speed']}
speed_variance: {e['speed_variance']}
attack_damage: {e['attack_damage']}
attack_cooldown: {e['attack_cooldown']}
detection_range: {e['detection_range']}
is_heavy: {str(e['is_heavy']).lower()}
is_large_enemy: {str(e['is_large_enemy']).lower()}
zigzag_enabled: {str(e['zigzag_enabled']).lower()}
weight: {e['weight']}
max_per_room: {e['max_per_room']}
guaranteed_count: {e['guaranteed_count']}
tags: [enemy]
---

# {e['display_name']}

## Mechanik

{ENEMY_MECHANICS.get(e['display_name'], '-')}

{STUN_LOCK_NOTE}

## Balancing (Threat-Budget-System)

| Wert | Betrag |
|---|---|
| Threat-Cost | {e['threat_cost']} |
| Basis-HP | {e['base_hp']} |
| Move-Speed | {e['move_speed']} (Varianz {e['speed_variance']}) |
| Angriffsschaden | {e['attack_damage']} |
| Angriffs-Cooldown | {e['attack_cooldown']} s |
| Erkennungsreichweite | {e['detection_range']} |
| Ziehgewicht | {e['weight']} |
| Max. pro Raum | {e['max_per_room']} |
| Garantierte Anzahl | {e['guaranteed_count']} |
| Mindest-Raumhoehe | {e['min_room_height']} |

Statt fester Spawn-Listen zieht der `LevelGenerator` Gegner ueber ein
**Threat-Budget** pro Raum: viele billige Stinger ODER wenige teure Fighter/
Colossi ergeben vergleichbare Schwierigkeit bei abwechslungsreicher
Zusammensetzung. Siehe [[level_generator]].

## Status-Effekt-Interaktion (enemy_ai.gd, gilt fuer alle Gegner)

{chr(10).join(f"- [[{sid}]] — Damage-over-Time (`DOT_EFFECT_IDS`)" for sid in sorted(ENEMY_DOT_STATUS_IDS))}
{chr(10).join(f"- [[{sid}]] — sperrt Angriffe (`is_attack_locked()`)" for sid in sorted(ENEMY_ATTACK_LOCK_STATUS_IDS))}
- [[rooted]] — sperrt bewusst NUR die Bewegung, nicht den Angriff (Abgrenzung zu `stun`)

{COLOSSUS_ROOM_NOTE if e['display_name'] == 'Colossus' else ''}

## Quelle

`{e['scene']}` (Root-Node-Properties), `{ENEMY_SPAWN_ENTRIES.get(e['display_name'], '')}`
"""
        write_md(out_dir / f"{slugify(e['display_name'])}.md", body)


# ============================================================================
# 5) ROOMS — geparst aus resources/rooms/rd_*.tres
# ============================================================================

ROOM_TYPE_NAMES = {
    "0": "COMBAT",
    "1": "TREASURE",
    "2": "BOSS",
    "3": "CORRIDOR",
    "4": "SHOP",
    "5": "START",
}

EXIT_FLAGS = [(1, "Norden"), (2, "Sueden"), (4, "Osten"), (8, "Westen")]


def exits_from_mask(mask: int) -> list[str]:
    return [name for flag, name in EXIT_FLAGS if mask & flag]


def find_room_scene(room_id: str) -> str:
    matches = list((PROJECT_ROOT / "scenes/rooms").rglob(f"room_{room_id}.tscn"))
    if matches:
        return str(matches[0].relative_to(PROJECT_ROOT)).replace("\\", "/")
    # room_start_01.tres liegt direkt unter scenes/rooms/, ohne Unterordner
    direct = PROJECT_ROOT / "scenes/rooms" / f"room_{room_id}.tscn"
    if direct.exists():
        return str(direct.relative_to(PROJECT_ROOT)).replace("\\", "/")
    return ""


def parse_rooms() -> list[dict]:
    rooms = []
    for tres_path in sorted((PROJECT_ROOT / "resources/rooms").glob("rd_*.tres")):
        room_id = tres_path.stem[len("rd_"):]
        kv = parse_tres_kv(tres_path.read_text(encoding="utf-8"))

        footprint = "1x1"
        fp_m = re.search(r'Vector2i\((\d+),\s*(\d+)\)', kv.get("footprint_cells", ""))
        if fp_m:
            footprint = f"{fp_m.group(1)}x{fp_m.group(2)}"

        room_type_code = kv.get("room_type", "0")
        rooms.append({
            "id": room_id,
            "room_type": ROOM_TYPE_NAMES.get(room_type_code, room_type_code),
            "footprint_cells": footprint,
            "available_exits": exits_from_mask(int(kv.get("available_exits", "15"))),
            "spawn_weight": float(kv.get("spawn_weight", "1.0")),
            "min_stage": int(float(kv.get("min_stage", "0"))),
            "unique_per_run": kv.get("unique_per_run", "false") == "true",
            "scene_path": find_room_scene(room_id),
        })
    return rooms


def write_room_notes(rooms: list[dict]) -> None:
    out_dir = PROJECT_ROOT / "01_Game_Design/Rooms"
    for r in rooms:
        body = f"""---
id: {yaml_escape(r['id'])}
room_type: {r['room_type']}
footprint_cells: {yaml_escape(r['footprint_cells'])}
available_exits: {yaml_list(r['available_exits'])}
spawn_weight: {r['spawn_weight']}
min_stage: {r['min_stage']}
unique_per_run: {str(r['unique_per_run']).lower()}
scene_path: {yaml_escape(r['scene_path'])}
tags: [room, "room/{r['room_type'].lower()}"]
---

# {r['id']}

## Layout

| Feld | Wert |
|---|---|
| Typ | {r['room_type']} |
| Grundflaeche | {r['footprint_cells']} Rasterzellen |
| Tueren | {', '.join(r['available_exits']) or '—'} |
| Ziehgewicht | {r['spawn_weight']} |
| Min. Etage | {r['min_stage']} |
| Einmalig pro Run | {'Ja' if r['unique_per_run'] else 'Nein'} |

{"Multi-Zellen-Raum: hat nur die Ausgaenge seiner Ankerzelle (RoomInstance._doors_by_dir bleibt unveraendert). Grundflaeche in Welt-Einheiten = footprint_cells * 48." if r['footprint_cells'] != '1x1' else ''}

## Quelle

`resources/rooms/rd_{r['id']}.tres`{f" → `{r['scene_path']}`" if r['scene_path'] else ''}
"""
        write_md(out_dir / f"{r['id']}.md", body)


# ============================================================================
# 6) STATUS-EFFEKTE — geparst aus scripts/status_effects/*.gd
# ============================================================================

STATUS_EFFECT_FILES = [
    "acid", "burn", "charm", "confused", "rooted", "silenced", "slow", "stun",
]

BANNER_RE = re.compile(
    r'#\s*={20,}\s*\n#\s*([^\n]+?)\s*\n#\s*={20,}',
)
CONST_LINE_RE = re.compile(r'const\s+(\w+)\s*:\s*\w+\s*=\s*([^\n]+)')


def parse_status_effects() -> list[dict]:
    effects = []
    for name in STATUS_EFFECT_FILES:
        path = PROJECT_ROOT / f"scripts/status_effects/{name}.gd"
        text = path.read_text(encoding="utf-8")

        banner_m = BANNER_RE.search(text)
        synopsis = banner_m.group(1).strip() if banner_m else ""

        consts = {k: v.strip() for k, v in CONST_LINE_RE.findall(text)}

        def num(key: str, default: float = 0.0) -> float:
            try:
                return float(consts.get(key, default))
            except ValueError:
                return default

        # Synergie-Funktionen: alle static func ausser apply/apply_heavy/
        # active/clear zaehlen als Synergie-Hooks (z.B. detonate,
        # thermal_shock, extend_for_gum).
        synergy_fns = [
            fn for fn in re.findall(r'static func (\w+)\(', text)
            if fn not in ("apply", "apply_heavy", "active", "clear")
        ]

        effects.append({
            "id": name,
            "synopsis": synopsis,
            "duration": num("DEFAULT_DURATION"),
            "tick_interval": num("DEFAULT_TICK_INTERVAL"),
            "damage_per_tick": num("DEFAULT_DAMAGE_PER_TICK"),
            "heavy_duration": consts.get("HEAVY_DURATION", ""),
            "synergy_fns": synergy_fns,
            "is_dot": "DEFAULT_DAMAGE_PER_TICK" in consts,
        })

    # "vulnerable" ist bewusst KEIN eigenes status_effects/*.gd — es laeuft
    # generisch ueber StatusEffectBase.apply_raw() und wird ausschliesslich
    # von Items ausgeloest (Schlangenbiss, Alarm-Bot). Siehe
    # item_behaviours.gd Kommentar bei ID_SNAKE_BITE / ID_ALARMBOT.
    effects.append({
        "id": "vulnerable",
        "synopsis": (
            "VULNERABLE — generischer Status ohne eigene Datei. Erhoeht den "
            "Schaden, den das Ziel durch NACHFOLGENDE Treffer erleidet, um "
            "einen Item-spezifischen Bonusfaktor."
        ),
        "duration": 0.0,
        "tick_interval": 0.0,
        "damage_per_tick": 0.0,
        "heavy_duration": "",
        "synergy_fns": [],
        "is_dot": False,
        "generic": True,
    })
    return effects


def write_status_effect_notes(effects: list[dict], status_item_links: dict[str, list[str]],
                               enemy_dot_ids: set[str], enemy_lock_ids: set[str]) -> None:
    out_dir = PROJECT_ROOT / "01_Game_Design/Status_Effects"
    for fx in effects:
        is_generic = fx.get("generic", False)
        source_line = (
            "`scripts/items/item_behaviours.gd` (`StatusEffectBase.apply_raw(target, \"vulnerable\", ...)`, "
            "z.B. Schlangenbiss +49 %/3.75s, Alarm-Bot +140 %/5s)"
            if is_generic else f"`scripts/status_effects/{fx['id']}.gd`"
        )

        triggering_items = status_item_links.get(fx["id"], [])
        items_section = (
            "\n".join(f"- [[{iid}]]" for iid in triggering_items) if triggering_items else "- —"
        )

        enemy_notes = []
        if fx["id"] in enemy_dot_ids:
            enemy_notes.append(
                "- Zaehlt in `enemy_ai.gd` als `DOT_EFFECT_IDS`-Eintrag: tickt automatisch "
                "Schaden auf **alle** Gegner ([[fighter]], [[stinger]], [[colossus]])."
            )
        if fx["id"] in enemy_lock_ids:
            enemy_notes.append(
                "- Sperrt in `enemy_ai.gd::is_attack_locked()` den Angriff **aller** Gegner "
                "([[fighter]], [[stinger]], [[colossus]])."
            )
        if fx["id"] == "rooted":
            enemy_notes.append(
                "- Bewusst NICHT in `is_attack_locked()`: `rooted` sperrt nur die Bewegung, "
                "nicht den Angriff — Abgrenzung zu `stun`."
            )
        enemies_section = "\n".join(enemy_notes) if enemy_notes else "- —"

        body = f"""---
id: {yaml_escape(fx['id'])}
duration: {fx['duration']}
tick_interval: {fx['tick_interval']}
damage_per_tick: {fx['damage_per_tick']}
is_damage_over_time: {str(fx['is_dot']).lower()}
heavy_duration: {yaml_escape(str(fx['heavy_duration']))}
synergies: {yaml_list(fx['synergy_fns'])}
triggered_by_items: {yaml_list(triggering_items)}
tags: [status-effect]
---

# {fx['id']}

{fx['synopsis']}

## Werte

| Feld | Wert |
|---|---|
| Dauer (Standard) | {fx['duration']} s |
| Tick-Intervall | {(str(fx['tick_interval']) + ' s') if fx['tick_interval'] else '—'} |
| Schaden/Tick | {fx['damage_per_tick'] or '—'} |
| Heavy-Variante | {fx['heavy_duration'] or '—'} |

## Synergien

{chr(10).join(f"- `{fn}()`" for fn in fx['synergy_fns']) if fx['synergy_fns'] else '- —'}

## Ausgeloest von (Items)

{items_section}

## Gegner-Interaktion

{enemies_section}

## Laufzeit

Verwaltet ueber `StatusEffectManager` (`scripts/status_effects/status_effect_manager.gd`).
`apply_effect()` verlaengert NICHT automatisch — es nimmt das Maximum aus
altem und neuem Wert. Fuer echte Verlaengerung: `extend_effect()` /
`extend_all()`.

## Quelle

{source_line}
"""
        write_md(out_dir / f"{fx['id']}.md", body)


# ============================================================================
# 7) ARCHITEKTUR-NOTIZEN (02_Tech_Architecture)
# ============================================================================

ARCH_NOTES = {
    "party_manager": """---
script_path: scripts/party_manager.gd
autoload_name: PartyManager
tags: [architecture, autoload]
---

# party_manager.gd

Autoload (`PartyManager`). Verwaltet bis zu 4 `CharacterData` in der Party.
Es existiert IMMER genau EIN aktiver `CharacterBody3D` im Level — beim
Wechsel wird die aktuelle Instanz entfernt und die neue an derselben Stelle
neu instanziert (Position, Kamera-Ausrichtung und HP werden uebernommen).

## Last-Stand-System

Stirbt der aktive Charakter und lebt noch mindestens ein weiteres
Party-Mitglied, uebernimmt dieses automatisch. Als Strafe wird die HP der
**gesamten restlichen Party** auf `LAST_STAND_HP_FRACTION` (0.20 = 20 %)
ihrer jeweiligen Maximal-HP gedeckelt — nicht nur die des Nachrueckers. Das
`party_wiped`-Signal (und damit der Death-Screen) feuert erst, wenn die
gesamte Party down ist.

Der Nachruecker bekommt kurz Schonzeit (`SWITCH_INVULN_DURATION = 2.0s`):
ohne das koennte derselbe Hitbox-Treffer, der den vorigen Charakter
umgebracht hat, im selben Frame auch den frisch eingewechselten erwischen.

## Switch-Cooldown

Wechselt man von einem Charakter WEG, bekommt GENAU DIESER (nicht der neu
aktivierte) einen Cooldown von `SWITCH_COOLDOWN_DURATION = 10.0s`, bevor man
wieder zu ihm wechseln kann.

## Bekannter Bug (behoben): "Restart-Button und [R] gehen nicht"

**Root Cause:** Das Autoload ueberlebt `get_tree().reload_current_scene()`.
Die Szene darunter wird komplett abgebaut — inklusive der Spieler-Instanz,
auf die `player` zeigt. Ein freigegebenes Object wird in GDScript aber
NICHT automatisch auf `null` gesetzt: die Variable haelt weiter den alten
Zeiger. Damit ist `player == null` → `false`, aber `is_instance_valid(player)`
→ `false` — ein Widerspruch, an dem der komplette Spawn-Pfad haengenblieb
(`register_spawn_point()`, `setup_party()`, `_spawn_active_character()`
pruefen alle auf `player == null`).

Nach jedem Neustart hielt `PartyManager` also eine "Leiche", hielt sich fuer
bereits bespielt und spawnte keinen neuen Charakter — sichtbar als "Bild baut
sich neu auf, aber man kann sich nicht bewegen".

**Fix:** Jede Lebend-Pruefung laeuft jetzt ueber `has_player()` bzw.
`is_instance_valid()`. `notify_scene_reset()` raeumt vor einem Szenenwechsel
bewusst auf (aufgerufen aus `run_restart.gd`, dem einzigen Neustart-Pfad).

## Verwandt

- [[status_effect_manager]] — Statuseffekte des Spielers werden bei
  Etagenwechsel geleert (siehe [[level_generator]]), nicht beim
  Last-Stand-Wechsel.
- [[player_base]] — `apply_stun`, Kamera- und Stun-Immunitaets-Logik der
  aktiven Instanz.
""",
    "level_generator": """---
script_path: scenes/level_generation/level_generator.gd
tags: [architecture, levelgen]
---

# level_generator.gd

Zentrale Klasse der prozeduralen Level-Generierung. Baut ein Etagen-Layout
aus `RoomData`-Vorlagen, platziert Gegner ueber ein **Threat-Budget**-System
(siehe `_table_for_type()` / `_budget_for_type()` / `_pick_room()`) und
verwaltet Minimap-Fog-of-War, Bosstueren und Etagenwechsel.

## Threat-Budget statt fester Spawn-Listen

Jeder Kampfraum bekommt ein Punktebudget; jeder Gegnertyp kostet Punkte
(`EnemySpawnEntry.threat_cost`, siehe [[fighter]], [[stinger]],
[[colossus]]). Ein Raum kann dadurch entweder viele billige Stinger ODER
wenige teure Fighter enthalten — die Schwierigkeit bleibt vergleichbar, die
Zusammensetzung variiert.

## Multi-Zellen-Raeume (Phase 3.1)

Raeume koennen mehr als eine Rasterzelle belegen (`footprint_cells`, z.B.
`2x1`, `1x2`, `2x2` — siehe [[combat_arena_01]], [[combat_wide_01]],
[[combat_tall_01]]). Die Grundflaechen werden NACHGELAGERT vergeben
(`_assign_footprints`), nicht waehrend des Baumwachstums — ein 2x2-Raum
haette waehrend des Wachstums vier Frontier-Positionen auf einmal
verbraucht und die Verzweigung zerstoert. Ein Multi-Zellen-Raum hat dadurch
GENAU DIE Ausgaenge seiner Ankerzelle (hoechstens einen je Himmelsrichtung);
`RoomInstance._doors_by_dir` bleibt unveraendert nutzbar.

Wichtig: der Generator kann eine Tuer verschieben (`set_exit_offset()`),
aber NICHT die Wandluecke — die steht als fester `Transform3D` in der
`.tscn`. Deshalb platzieren Multi-Zellen-Szenen Tuer, ExitPoint und
Wandluecke selbst auf der Ankerachse, statt `set_exit_offset()` automatisch
aufzurufen.

## Etagen-Progression

`generate_stage()` / `get_stage_theme()`: der Seed geht mit der
Etagennummer in die Layout-Ableitung ein (`"layout:<stage>"`), jede Etage
bekommt so ein eigenes, reproduzierbares Muster. Es gibt bewusst KEIN
`reload_current_scene()` beim Etagenwechsel — Items, PartyManager,
PlayerStats und der Spieler-Node ueberleben, nur die Raeume werden
getauscht. Geleert werden ausschliesslich Statuseffekte, Drops, Hazards und
Projektile der alten Etage.

## Bekannte Bugfixes (Auszug)

- **"1x2-Raum zeigt sich als 1x1 auf Minimap/ingame"**
- **"Stufe vor der Tuer / Rampe endet auf falscher Hoehe"**
- **"Boss-Tuer ist manchmal nicht rot"**
- **"Im Bossraum eingesperrt"**
- **"Hacking waehrend des Kampfs moeglich"** — Tresor-/Boss-Tueren pruefen
  jetzt `treasure_door_cleared()` bzw. den Raumzustand, bevor sie sich
  hacken lassen.
- **"Trophaee liegt unter dem Boden"**

## Verwandt

- [[stage_theme]] (falls vorhanden) — Farbwelt pro Etage.
- Alle Notizen unter `01_Game_Design/Rooms/`.
""",
    "player_base": """---
script_path: scripts/player_base.gd
tags: [architecture, player]
---

# player_base.gd

Basisklasse der spielbaren Charaktere. Kamera-Rig (Feder/Probe-Kollision,
Dash-FOV/-Drill-Effekte), Statuseffekt-Anbindung, Stun-Handling, Void-Death
und Ragdoll-Tod.

## Stun-Lock-Schutz

Zweistufig, analog den meisten Action-Spielen:

1. **Diminishing Returns:** jeder weitere Stun innerhalb des
   Ketten-Zeitfensters wirkt nur noch `stun_diminish_factor` so lang wie der
   vorherige.
2. **Immunitaet:** nach `stun_max_chain` Stuns in Folge greift ein kurzes
   Immunitaetsfenster (`_begin_stun_immunity()`), bevor die Kette von vorn
   beginnt.

Siehe `apply_stun()`, `is_stun_immune()`, `_tick_stun_guard()`.

## Statuseffekt-Anbindung

`apply_status_effect()` / `has_status_effect()` / `_on_status_effect_ticked()`
/ `_on_status_effect_expired()` binden den Spieler an denselben
`StatusEffectManager` wie Gegner an — siehe [[status_effect_manager]].

## Bekannte Bugfixes (Auszug)

- **"Beim Dash zoomt die Kamera in den Spieler rein"**
- **"Die Kamera geht beim Dashen durch Waende"**
- **"Leiche blockiert Kamera und Spieler"** — Ragdoll-Leichen werden nach
  dem Tod aus kamerarelevanten Kollisionsebenen entfernt.

## Void-Death-System

`_update_void_death()` / `_die_from_void_fall()`: der Spieler stirbt beim
Fall in tiefe Abgruende, statt endlos zu fallen.

## Verwandt

- [[party_manager]] — Switch-Invulnerabilitaet beim Last-Stand-Wechsel.
- [[status_effect_manager]] — zentrale Tick-/Verlaengerungs-Logik.
""",
    "status_effect_manager": """---
script_path: scripts/status_effects/status_effect_manager.gd
tags: [architecture, status-effects]
---

# status_effect_manager.gd

Laufzeit-Komponente pro Entity (Spieler wie Gegner) fuer alle aktiven
Statuseffekte. Die einzelnen Effekt-Dateien (`scripts/status_effects/*.gd`,
siehe `01_Game_Design/Status_Effects/`) enthalten NUR ihre Balancing-Zahlen
und VFX-Entscheidung — die Laufzeit (Timer, Tick, Cleanup) sitzt zentral
hier. Diese Trennung existiert, weil sieben Effekte denselben
Lookup/Apply/VFX-Block sonst wortgleich dupliziert haetten.

## Zentrale Funktionen

- `apply_effect(id, duration, magnitude, source, tick_interval)` — **nimmt
  bei einem bereits aktiven Effekt das MAXIMUM aus altem und neuem Wert.**
  Fuer Verlaengerungen ungeeignet: eine Pfeffermuehle mit +3s waere bei
  einem noch 4s laufenden Effekt wirkungslos geblieben.
- `extend_effect(id, extra_seconds)` / `extend_all(extra_seconds, ids)` —
  die tatsaechliche Verlaengerung.
- `get_effect_tick_interval(id)`, `snapshot_dots()` — fuer Synergie-Rechnungen
  wie `StatusBurn.thermal_shock()` (Gefrierbeutel: kompletter Restschaden auf
  einmal).
- `DOT_IDS` — zentrale Liste der Damage-over-Time-Effekte (`poison`, `bleed`,
  `burn`, `acid`). `enemy_ai.gd` muss eine neue ID hier eintragen, sonst
  tickt sie ins Leere.

## Root-Cause-Fixes bei Einfuehrung

- **Dauer-Tint verschwand beim ersten Treffer:** `psx.gdshader` hat GENAU
  EIN Paar `flash_color`/`flash_strength`. Der Hit-Flash-Tween in
  `enemy_ai.gd` fuhr es hoch und wieder auf 0 — jede dauerhafte
  Effekt-Einfaerbung wurde beim naechsten Schlag geloescht. Fix:
  `status_effect_visuals.gd` schreibt den Tint jeden Frame neu; der
  Hit-Flash ueberschreibt nur kurz.
- **Stun-Interrupt haette Gegner dauerhaft gelaehmt:** `_do_attack()` ist
  eine Coroutine ueber mehrere `await`-Punkte. Ein reines `return` beim
  Interrupt haette `_is_attacking` dauerhaft auf `true` stehen lassen.
  Fix: Interrupt-Ausstiege rufen jetzt `_abort_attack()`, das Flag,
  Telegraph und Armpose aufraeumt und den Gegner auf `CHASE` zuruecksetzt.

## Verwandt

- [[player_base]] — Spieler-seitige Anbindung.
- Alle Notizen unter `01_Game_Design/Status_Effects/`.
""",
}


def write_architecture_notes() -> None:
    out_dir = PROJECT_ROOT / "02_Tech_Architecture"
    for name, content in ARCH_NOTES.items():
        write_md(out_dir / f"{name}.md", content)


# ============================================================================
# 8) DEVLOGS — aus `git log`
# ============================================================================

def parse_git_log() -> list[dict]:
    fmt = "%H%x01%ad%x01%an%x01%s%x01%b%x02"
    try:
        raw = subprocess.check_output(
            ["git", "log", f"--pretty=format:{fmt}", "--date=short"],
            cwd=PROJECT_ROOT, text=True, encoding="utf-8", errors="replace",
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return []

    commits = []
    for entry in raw.split("\x02"):
        entry = entry.strip("\n")
        if not entry.strip():
            continue
        parts = entry.split("\x01")
        if len(parts) < 5:
            continue
        commit_hash, date, author, subject, body = parts[0], parts[1], parts[2], parts[3], parts[4]
        commits.append({
            "hash": commit_hash,
            "short_hash": commit_hash[:7],
            "date": date,
            "author": author,
            "subject": subject.strip(),
            "body": body.strip(),
        })
    return commits


def write_devlogs(commits: list[dict]) -> None:
    out_dir = PROJECT_ROOT / "03_DevLogs"
    for c in commits:
        fname = f"{c['date']}_{c['short_hash']}_{slugify(c['subject'])[:50]}.md"
        body_md = c["body"] if c["body"] else "*(kein erweiterter Commit-Body)*"
        note = f"""---
commit: {yaml_escape(c['hash'])}
short_hash: {yaml_escape(c['short_hash'])}
date: {c['date']}
author: {yaml_escape(c['author'])}
subject: {yaml_escape(c['subject'])}
tags: [devlog]
---

# {c['date']} — {c['subject']}

{body_md}

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `{c['short_hash']}` |
| Autor | {c['author']} |
| Datum | {c['date']} |
"""
        write_md(out_dir / fname, note)


# ============================================================================
# 9) MASTER-DASHBOARD (00_Dashboard)
# ============================================================================

def write_dashboard(items: list[dict], enemies: list[dict], rooms: list[dict],
                     effects: list[dict], commits: list[dict]) -> None:
    content = f"""---
tags: [moc, dashboard]
---

# Whiplash — Master Wiki

Automatisch generiert von `generate_vault.py` aus den echten Projektdateien
(nicht aus `_project_export.txt` selbst — siehe Skript-Docstring). Erneut
ausfuehren, sobald sich Items/Gegner/Raeume/Statuseffekte im Code aendern,
oder `98_Scripts/wiki_sync.py` fuer inkrementelle Updates verwenden.

## Map of Contents

- [[00_Master_Wiki|Dashboard]] (diese Seite)
- Game Design
  - Items ({len(items)})
  - Enemies ({len(enemies)})
  - Rooms ({len(rooms)})
  - Status Effects ({len(effects)})
- Tech Architecture
  - [[party_manager]]
  - [[level_generator]]
  - [[player_base]]
  - [[status_effect_manager]]
- DevLogs ({len(commits)} Commits)
- Templates: [[tpl_Item]] · [[tpl_Enemy]] · [[tpl_Room]] · [[tpl_StatusEffect]]

## Items

```dataview
TABLE kind AS "Kind", category AS "Kategorie", rarity AS "Rarity", cooldown_seconds AS "Cooldown (s)", charge_rooms AS "Charge (Raeume)"
FROM "01_Game_Design/Items"
SORT rarity DESC, name ASC
```

### Items nach Rarity

```dataview
TABLE length(rows) AS "Anzahl"
FROM "01_Game_Design/Items"
GROUP BY rarity
SORT rarity DESC
```

## Enemies

```dataview
TABLE threat_cost AS "Threat-Cost", base_hp AS "HP", move_speed AS "Speed", speed_variance AS "Speed-Varianz"
FROM "01_Game_Design/Enemies"
SORT threat_cost ASC
```

## Rooms

```dataview
TABLE room_type AS "Typ", footprint_cells AS "Footprint", spawn_weight AS "Gewicht", min_stage AS "Min. Etage"
FROM "01_Game_Design/Rooms"
SORT room_type ASC, id ASC
```

### Räume nach Typ

```dataview
TABLE length(rows) AS "Anzahl"
FROM "01_Game_Design/Rooms"
GROUP BY room_type
```

## Status Effects

```dataview
TABLE duration AS "Dauer (s)", tick_interval AS "Tick (s)", damage_per_tick AS "Schaden/Tick", is_damage_over_time AS "DoT?"
FROM "01_Game_Design/Status_Effects"
SORT id ASC
```

## DevLogs (jüngste zuerst)

```dataview
TABLE subject AS "Commit", author AS "Autor"
FROM "03_DevLogs"
SORT date DESC
LIMIT 20
```
"""
    write_md(PROJECT_ROOT / "00_Dashboard/00_Master_Wiki.md", content)


# ============================================================================
# 10) 98_Scripts/wiki_sync.py — Vorlage fuer zukuenftige inkrementelle Syncs
# ============================================================================

WIKI_SYNC_TEMPLATE = '''#!/usr/bin/env python3
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

FRONTMATTER_RE = re.compile(r"^---\\n(.*?)\\n---\\n", re.DOTALL)


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
    return frontmatter + f"\\n{line}"


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
    const_map = dict(re.findall(r'const\\s+(ID_\\w+)\\s*:\\s*String\\s*=\\s*"([^"]*)"', src))
    changed = 0

    for note_path in items_dir.glob("*.md"):
        item_id = note_path.stem
        const_name = next((k for k, v in const_map.items() if v == item_id), None)
        if const_name is None:
            continue

        m = re.search(
            rf'{const_name}\\s*,\\s*"[^"]*"\\s*,\\s*"[^"]*"\\s*,\\s*"[^"]*"\\s*,\\s*'
            rf'ItemData\\.Kind\\.(\\w+)\\s*,\\s*ItemData\\.Category\\.(\\w+)\\s*,\\s*'
            rf'ItemData\\.Rarity\\.(\\w+)',
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
                note_path.write_text(f"---\\n{new_fm}\\n---\\n{rest}", encoding="utf-8")

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
        kv = dict(re.findall(r"^(\\w+)\\s*=\\s*(.+)$", text, re.MULTILINE))

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
                note_path.write_text(f"---\\n{new_fm}\\n---\\n{rest}", encoding="utf-8")

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
    print(f"wiki_sync.py — {mode}\\n")

    total = 0
    total += sync_items()
    total += sync_rooms()
    sync_enemies()
    sync_status_effects()

    print(f"\\n{total} Notiz(en) {'aktualisiert' if APPLY else 'wuerden aktualisiert (Dry-Run)'}.")
    if not APPLY and total:
        print("Erneut mit --apply aufrufen, um die Aenderungen zu schreiben.")


if __name__ == "__main__":
    main()
'''


def write_wiki_sync() -> None:
    (PROJECT_ROOT / "98_Scripts/wiki_sync.py").write_text(WIKI_SYNC_TEMPLATE, encoding="utf-8")


# ============================================================================
# MAIN
# ============================================================================

def main() -> None:
    print("Whiplash Obsidian-Vault-Generator")
    print("=" * 60)

    ensure_folders()
    print("[1/6] Ordnerstruktur angelegt")

    write_templates()
    print("[2/6] Dataview-Templates geschrieben (99_Templates)")

    items = parse_items()
    item_status_links = parse_item_status_links(items)
    write_item_notes(items, item_status_links)
    print(f"[3/6] {len(items)} Item-Notizen geschrieben (01_Game_Design/Items)")
    print(f"      -> {sum(len(v) for v in item_status_links.values())} Item<->Status-Effekt-Verknuepfungen gefunden")

    enemies = parse_enemies()
    write_enemy_notes(enemies)
    print(f"[3/6] {len(enemies)} Enemy-Notizen geschrieben (01_Game_Design/Enemies)")

    rooms = parse_rooms()
    write_room_notes(rooms)
    print(f"[3/6] {len(rooms)} Room-Notizen geschrieben (01_Game_Design/Rooms)")

    effects = parse_status_effects()
    status_item_links: dict[str, list[str]] = {}
    for item_id, status_ids in item_status_links.items():
        for sid in status_ids:
            status_item_links.setdefault(sid, []).append(item_id)
    write_status_effect_notes(effects, status_item_links, ENEMY_DOT_STATUS_IDS, ENEMY_ATTACK_LOCK_STATUS_IDS)
    print(f"[3/6] {len(effects)} Status-Effekt-Notizen geschrieben (01_Game_Design/Status_Effects)")

    write_architecture_notes()
    print("[4/6] Architektur-Notizen geschrieben (02_Tech_Architecture)")

    commits = parse_git_log()
    write_devlogs(commits)
    print(f"[5/6] {len(commits)} DevLog-Notizen geschrieben (03_DevLogs)")

    write_dashboard(items, enemies, rooms, effects, commits)
    print("[6/6] Master-Dashboard geschrieben (00_Dashboard)")

    write_wiki_sync()
    print("      wiki_sync.py-Vorlage geschrieben (98_Scripts)")

    print("=" * 60)
    print("Fertig. Vault liegt direkt im Projektverzeichnis - Obsidian kann")
    print("diesen Ordner als Vault oeffnen (bzw. ist bereits als Vault")
    print("konfiguriert, siehe vorhandener .obsidian/-Ordner).")


if __name__ == "__main__":
    main()
