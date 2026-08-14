---
commit: "0484ccd2447bc593ccced4d279e300175d6e3a26"
short_hash: "0484ccd"
date: 2026-08-12
author: "ImChubiii"
subject: "feat/fix: Umfangreiches Gameplay-, UI- & Balancing-Overhaul"
tags: [devlog]
---

# 2026-08-12 — feat/fix: Umfangreiches Gameplay-, UI- & Balancing-Overhaul

- Minimap: 2D-Grid entfernt, echte 3D-Draufsicht mit Raumzustands-Faerbung und Spezialraum-Icons implementiert
- Giselle: Kamera-Shift (Over-the-shoulder) beim Zielen, Uzi-Feuerrate & Partikel-Richtung korrigiert, Aim-Assist erhoeht
- Karina: Luftangriff-Hitbox gefixt, neue Lifesteal-Passive (via Item-System) hinzugefuegt
- Winter & Giselle: Enemy ESP-Hitboxen fuer Faehigkeiten integriert
- Items: Automatisches Q/E-Slot-Swapping beim Aufheben am Schatzsockel eingebaut
- Level-Gen: Threat-Budget skaliert nun mit der Raumgroesse, alle Raum-Spawn-Weights auf 1.0 vereinheitlicht
- Loot: Drop-Wahrscheinlichkeit und Skalierung der 3D-Pickups (Coins, Heal, Bomben) erhoeht
- Gegner: Detection Range (Kanonen) und Projektil-Geschwindigkeit (Moerser) gebufft, Raum/Moerser-Scale angepasst
- Boss/Hazards: Lava-Mechaniken (Schaden/Gegner-Interaktion) im Boss-Raum ueberarbeitet
- Grafik: Tiling/Stretching-Bug bei 1x2-Raeumen im PSX-Shader behoben

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.



## Metadaten

| Feld | Wert |
|---|---|
| Commit | `0484ccd` |
| Autor | ImChubiii |
| Datum | 2026-08-12 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-12_0484ccd_featfix_umfangreiches_gameplay-_ui-_balancing-over]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
