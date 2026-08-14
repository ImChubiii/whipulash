"""
export_antigravity.py — liest Antigravity-Brain-Sessions
(~/.gemini/antigravity/brain/<uuid>/.system_generated/logs/transcript_full.jsonl)
und wandelt sie in das 04_Chat_Prompts/-Markdown-Format um.

Ersetzt scratch_recover.py (hardcodierte Ein-Datei-Notloesung fuer genau
EINEN Session-Pfad und genau EINE Zieldatei) durch ein generisches,
wiederverwendbares Werkzeug fuer ALLE Sessions.

Format der transcript_full.jsonl: eine Zeile = ein JSON-Objekt mit "type".
Relevante Typen fuer den Chat-Inhalt:
  - USER_INPUT: "content" enthaelt den rohen Prompt, eingebettet in
    <USER_REQUEST>...</USER_REQUEST> (+ <ADDITIONAL_METADATA>/
    <USER_SETTINGS_CHANGE>-Rauschen drumherum, wird abgeschnitten).
  - PLANNER_RESPONSE: "content" ist die sichtbare Antwort, "thinking" das
    (hier bewusst weggelassene) Denk-Feld.
Alle anderen Typen (CODE_ACTION, RUN_COMMAND, VIEW_FILE, ...) sind
Tool-Aufrufe/Metadaten und werden fuer den Chatlog-Export ignoriert - wer
sie braucht, findet sie im Rohformat direkt in der .jsonl.

Verwendung:
    python wiki/98_Scripts/export_antigravity.py --list
        Listet alle Brain-Sessions mit Datum (lokal, +2h/CEST-Annahme aus
        UTC), Nachrichtenzahl und erster Nutzer-Anfrage - zum Abgleich
        gegen bereits vorhandene Dateien in 04_Chat_Prompts/.

    python wiki/98_Scripts/export_antigravity.py --export <kurze-oder-volle-uuid> -o <pfad.md>
        Schreibt die vollstaendige Session als reinen Markdown-Koerper
        (ohne Frontmatter) - Frontmatter (Titel/Datum/Tags/ki_art) kommt
        von Hand dazu, siehe wiki/00_Dashboard/01_Dokumentations_Guide.md
        Abschnitt 1.
"""
import argparse
import glob
import json
import os
import re
from datetime import datetime, timedelta, timezone

BRAIN_DIR = os.path.expanduser(r"~\.gemini\antigravity\brain")

# Antigravity schreibt UTC in "created_at", die Antigravity-eigenen
# Zusammenfassungen im Transcript selbst rechnen konsequent +2h (CEST,
# Europe/Berlin im August) - siehe <ADDITIONAL_METADATA> im ersten
# USER_INPUT jeder Session ("The current local time is: ...+02:00").
LOCAL_OFFSET = timedelta(hours=2)


def local_date(created_at: str) -> str:
    dt = datetime.fromisoformat(created_at.replace("Z", "+00:00"))
    return (dt + LOCAL_OFFSET).strftime("%Y-%m-%d")


def clean_user_content(raw: str) -> str:
    m = re.search(r"<USER_REQUEST>\s*(.*?)\s*</USER_REQUEST>", raw, re.DOTALL)
    return m.group(1).strip() if m else raw.strip()


def transcript_path(session_uuid: str) -> str:
    return os.path.join(BRAIN_DIR, session_uuid, ".system_generated", "logs", "transcript_full.jsonl")


def find_session(short_or_full_uuid: str) -> str:
    if os.path.exists(transcript_path(short_or_full_uuid)):
        return short_or_full_uuid
    matches = [
        os.path.basename(d) for d in glob.glob(os.path.join(BRAIN_DIR, "*"))
        if os.path.basename(d).startswith(short_or_full_uuid)
    ]
    if len(matches) == 1:
        return matches[0]
    if not matches:
        raise SystemExit(f"Keine Session gefunden fuer '{short_or_full_uuid}'.")
    raise SystemExit(f"Mehrdeutig: '{short_or_full_uuid}' passt auf {matches}")


def iter_entries(session_uuid: str):
    path = transcript_path(session_uuid)
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def list_sessions() -> None:
    rows = []
    for session_dir in sorted(glob.glob(os.path.join(BRAIN_DIR, "*"))):
        uuid = os.path.basename(session_dir)
        if not os.path.exists(transcript_path(uuid)):
            continue
        first_input = None
        first_created = None
        n_user = 0
        n_responses = 0
        for obj in iter_entries(uuid):
            t = obj.get("type")
            if t == "USER_INPUT":
                n_user += 1
                if first_input is None:
                    first_input = clean_user_content(obj.get("content", ""))
                    first_created = obj.get("created_at")
            elif t == "PLANNER_RESPONSE":
                n_responses += 1
        if first_created is None:
            continue
        rows.append((local_date(first_created), uuid, n_user, n_responses, (first_input or "")[:90].replace("\n", " ")))

    for date, uuid, n_user, n_resp, preview in sorted(rows):
        print(f"{date} | {uuid} | user={n_user} resp={n_resp} | {preview}")


def export_session(session_uuid: str, out_path: str) -> None:
    session_uuid = find_session(session_uuid)
    # Eindeutiger Marker fuer detect_ki_art() in tag_chat_prompts.py - ohne
    # ihn faellt eine Antigravity-Datei nur auf die generische "## Assistant
    # ohne anderen Marker"-Fallback-Regel zurueck, was bei zukuenftigen neuen
    # KI-Quellen mit demselben Rollen-Header irgendwann mehrdeutig werden
    # koennte.
    source_link = f"[Antigravity Session](file:///{transcript_path(session_uuid).replace(os.sep, '/')})"
    lines = [source_link + "\n"]
    for obj in iter_entries(session_uuid):
        t = obj.get("type")
        if t == "USER_INPUT":
            content = clean_user_content(obj.get("content", ""))
            if not content:
                continue
            lines.append("## User\n")
            lines.append(content + "\n")
        elif t == "PLANNER_RESPONSE":
            content = (obj.get("content") or "").strip()
            if not content:
                continue
            lines.append("## Assistant\n")
            lines.append(content + "\n")

    body = "\n".join(lines).strip() + "\n"
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(body)
    n_rounds = sum(1 for l in lines if l.startswith("## User"))
    print(f"Exportiert: {out_path} ({n_rounds} Runden)")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--list", action="store_true", help="Alle Sessions mit Datum/Umfang/erster Anfrage auflisten")
    parser.add_argument("--export", metavar="UUID", help="Eine Session als Markdown-Koerper exportieren")
    parser.add_argument("-o", "--output", metavar="PATH", help="Zielpfad fuer --export")
    args = parser.parse_args()

    if args.list:
        list_sessions()
    elif args.export:
        if not args.output:
            raise SystemExit("--export benoetigt -o/--output")
        export_session(args.export, args.output)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
