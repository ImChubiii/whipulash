---
commit: "f23c551ac6c8c8b3f3c0fbadef8f6dc44edbbdb1"
short_hash: "f23c551"
date: 2026-08-12
author: "ImChubiii"
subject: "﻿feat: combat mechanics, weighted item drops, and UI tweaks"
tags: [devlog]
---

# 2026-08-12 — ﻿feat: combat mechanics, weighted item drops, and UI tweaks

1. Kritische Treffer (Critical Hits) implementiert
- Logik (hitbox.gd): Spieler-Angriffe koennen nun kritisch treffen (Multiplikator 1,5x). Dabei gibt es auch einen kleinen visuellen Stopp-Effekt (Juice.hit_stop_light()).
- UI (damage_number.gd): Schadenszahlen von kritischen Treffern ploppen nun 1,5-mal so gross auf wie normale Schadenszahlen, damit sie besser ins Auge fallen.

2. Anpassungen bei "Dash"-Schadenszahlen
- UI (damage_number.gd): Dash-Schaden sieht jetzt optisch exakt wie normaler Treffer-Schaden aus (nutzt Kind.NORMAL statt Kind.DASH), so wie es im Game-Design-Blueprint vorgesehen war.

3. Neues Saeure-Verhalten (Acid)
- Statuseffekt (acid.gd): Saeure verursacht jetzt einen "Verletzlichkeit"-Effekt. Ein von Saeure betroffenes Ziel nimmt nun aus allen Quellen 20 % mehr Schaden (VULNERABILITY_MULTIPLIER = 1.2).

4. Schatzraeume & Item-Generierung
- Blutzoll-Raeume (treasure_manager.gd): Es gibt nun "Sacrifice"-Raeume (Opfer-Raeume). In diesen spawnt ein SacrificePedestal, welches den Spieler beim Aufsammeln des Items Lebenspunkte (HP) kostet, statt des normalen Gratis-Sockels.
- Gewichtete Item-Auswahl (treasure_manager.gd): Items werden nicht mehr rein zufaellig ausgewaehlt. Stattdessen gibt es ein Wahrscheinlichkeitssystem, das Synergien mit bereits gesammelten Items sowie einen Meta-Fortschritt-Bonus (SaveGame.get_item_weight_bonus()) beruecksichtigt.

5. UI-Verbesserungen (Vignette)
- Low-HP-Warnung (low_hp_vignette.gd): Die rote Bildschirmumrandung bei wenig Leben wurde stark abgeschwaecht (maximale Deckkraft von 78 % auf 45 % reduziert), da sie vorher im Kampf zu viel vom Sichtfeld verdeckt hat.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Status-Effekte:** [[acid]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `f23c551` |
| Autor | ImChubiii |
| Datum | 2026-08-12 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-12_f23c551_feat_combat_mechanics_weighted_item_drops_and_ui_t]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
