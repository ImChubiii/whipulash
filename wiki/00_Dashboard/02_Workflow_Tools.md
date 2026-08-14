---
tags: [workflow, gedanken, tools]
---

# App Nutzung & Ablauf (Workflow)

> *Wie arbeiten Claude, Antigravity, Godot und Obsidian zusammen? Ein kleiner Leitfaden für unseren KI-unterstützten Workflow.*

## 1. Antigravity & Obsidian (Planung & Wiki)
- **Zweck:** Architektur, Gamedesign, Brainstorming und Dokumentation.
- **Wie es funktioniert:**
  - Antigravity hat direkten Lese-Zugriff auf das gesamte Obsidian-Vault (`[LOCAL_PATH]\Documents\GitHub\whiplash`).
  - Hier planen wir neue Gegner, Items und Mechaniken.
  - Antigravity erstellt für dich Pläne (`implementation_plan.md`) und verlinkt alles sauber im Fandom-Wiki-Stil.

## 2. Claude CLI / Warp (Der Coder)
- **Zweck:** Die eigentliche Programmierung in Godot (GDScript, Szenen anlegen).
- **Wie es funktioniert:**
  - Sobald ein Plan in Antigravity abgesegnet ist, übernimmst du (oder Claude) die Umsetzung im Code.
  - Claude ist sehr gut darin, komplexe GDScript-Logik zu schreiben und Projekt-Dateien (`.tscn`) zu analysieren.

## 3. Godot Engine (Die Ausführung)
- **Zweck:** Das Spiel zusammenbauen und testen.
- **Wie es funktioniert:**
  - Hier drückst du Play.
  - Bei Fehlern oder Bugs (z.B. rote Errors in der Konsole) kopierst du den Error-Log und gibst ihn an Claude (für Code-Bugs) oder Antigravity (für Logik-Lücken im Konzept) weiter.

---

## Der Loop in Kurzform
1. **Idee haben** $\rightarrow$ *In Obsidian aufschreiben oder Antigravity fragen.*
2. **Konzept ausarbeiten** $\rightarrow$ *Antigravity schreibt ein Wiki-Dokument oder einen Bauplan.*
3. **Code schreiben** $\rightarrow$ *Claude CLI in Warp setzen den Plan in `.gd`-Skripte um.*
4. **Testen** $\rightarrow$ *Godot Play-Button drücken.*
5. **Debuggen** $\rightarrow$ *Logs auswerten und Fehler an KI verfüttern.*

## Verwandte Seiten
- [[HOME]]
- [[_Raum_Balancing_Brainstorming]]
