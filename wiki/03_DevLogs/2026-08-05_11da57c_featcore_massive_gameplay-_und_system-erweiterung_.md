---
commit: "11da57c571c5e63c3507ca25d6d48cd79edc9997"
short_hash: "11da57c"
date: 2026-08-05
author: "ImChubiii"
subject: "feat(core): Massive Gameplay- und System-Erweiterung (Phase 3-5)"
tags: [devlog]
---

# 2026-08-05 — feat(core): Massive Gameplay- und System-Erweiterung (Phase 3-5)

Dieses Update bündelt die vollständige Implementierung der Design-Dokument-Phasen 3 bis 5. Es führt tiefgreifende Änderungen an der Level-Struktur, dem Kampfsystem und der Progression ein[cite: 1].

Items & Status-Effekte:
- 47 neue Items (inkl. 33 "Ultimate"-Items) mit einzigartigen Synergien implementiert[cite: 1].
- Neues Status-Effekt-System (Brennen, Verlangsamung, Stille, Betäubung, Bezauberung, etc.) hinzugefügt[cite: 1].
- Aktive Fähigkeiten auf ein neues Zwei-Slot-System (Q/E) umgestellt[cite: 1].

Level-Generierung & Umgebung:
- Multi-Zellen-Räume (z.B. 1x2, 2x2) im Grid-Generator aktiviert[cite: 1].
- Thematische Etagen-Progression (Farbwelten wie Kellergewölbe, Tiefkühlhaus) eingeführt[cite: 1].
- 12 neue Raum-Szenen und modulare Gefahren (Lava-Auftrieb, Turrets, Fallgruben) integriert[cite: 1].

KI, Combat & Party:
- Neues "Threat-Budget"-System für dynamische Gegner-Spawns anstelle von festen Limits[cite: 1].
- Last-Stand-System für das Party-Setup integriert (Wechsel bei Tod, kombiniert mit 20% HP-Cap-Strafe)[cite: 1].
- Stun-Lock-Schutz durch Diminishing Returns und Immunitätsfenster eingebaut[cite: 1].

UI & Systeme:
- Komplett neues, prozedurales Hauptmenü und überarbeitetes HUD (Combo-Zähler, Speedrun-Timer)[cite: 1].
- Neue Minimap-Funktionen (Sichtbarkeit von Raumtypen, Türverbindungen und Großkarten-Ansicht)[cite: 1].
- Zentrales Settings-Menü für rebindable Keybinds, FOV-Slider und Audio-Optionen ergänzt[cite: 1].

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

*(keine automatisch erkannten Erwaehnungen)*

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `11da57c` |
| Autor | ImChubiii |
| Datum | 2026-08-05 |
