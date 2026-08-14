---
commit: "c28ab95290bd157c42c176c9a079a6fdc376896c"
short_hash: "c28ab95"
date: 2026-08-04
author: "ImChubiii"
subject: "feat(items, ai, ui, levelgen): Party-Revive, Item-Reworks, Boss-HP-Split & Lava-Buoyancy"
tags: [devlog]
---

# 2026-08-04 — feat(items, ai, ui, levelgen): Party-Revive, Item-Reworks, Boss-HP-Split & Lava-Buoyancy

Umfangreiches Update für Items, Gegner-KI, Level-Generierung und HUD-Feedback.

PARTY & GAMEPLAY
-----------------
* Character Revive / Last-Stand: PartyManager wechselt bei Tod automatisch
  zum nächsten lebenden Charakter. Das "party_wiped" Signal (und damit der
  Death-Screen) feuert erst, wenn die gesamte Party down ist.
* Restart Hold-Timer: Dynamisch angepasst (initial 1.0s, danach 0.5s für
  jeden weiteren sofortigen Restart).

ITEMS & PASSIVES
-----------------
* Ouija Board: Item registriert. Neues Skript `revenge_ghost.gd` für zielsuchende
  Geister, die Gegner hinter dem Spieler oder außerhalb der Melee-Reichweite angreifen.
* Cursed Die: `pickup.gd` tritt nun der "pickups" Gruppe bei. Fallback für
  die fehlende `spawn_random_drop()` Funktion implementiert.
* Roof Nail: Unterbricht nun Telegraphen und blockiert Knockback.
* Stiletto Heels: Löst jetzt bei jedem dritten Schritt eine Stun-Schockwelle aus.
* Rice Pudding: Shield besitzt nun eine dauerhafte visuelle Aura. Der Status
  wurde gegen fehlerhafte Zuweisungen bei Charakterwechseln gehärtet.

ENEMIES & AI
-----------------
* Lava Buoyancy: `set_buoyancy()` zu EnemyAI hinzugefügt. Gegner in Lava
  bobben nun auf ca. 2/3 ihrer Körperhöhe, anstatt komplett zu versinken.
* Zigzag-Movement: Interpoliert die Kurvenwinkel jetzt weich, statt hart
  zu snappen. Sichtbares Lean-Telegraphing hinzugefügt.
* Unstuck-Routine: Automatische Positions- und Ground-Checks für die KI ergänzt.

LEVEL GENERATION & DOORS
-------------------------
* Teleporter: Das Autoload verbindet sich jetzt robust über `SceneTree.node_added`
  mit jedem neuen LevelGenerator, statt nach einem Restart zu verschwinden.
* Door-Hacking: Guard in `door.gd` und Bedingung in `level_generator.gd`
  (`treasure_door_cleared()`) verhindern das Hacken von Türen während eines
  aktiven Kampfes.
* Treasure Rooms: Besitzen nun eine 35% Chance, direkt an den Startraum anzugrenzen.

UI & HUD
-----------------
* Boss HP: Die geteilte Leiste wurde in 3 unabhängige Leisten (pro Boss) aufgeteilt.
* Item-Damage-Numbers: Passiver/Item-Schaden (Dash, Kicks, Geister, etc.)
  wird nun in einer eigenen Magenta-Farbe ("ITEM") dargestellt.
* Low-HP Vignette: HUD zeigt bei ≤20% HP eine pulsierende, dunkelrote Vignette.
* Item Card: Layout-Fix (doppelten `SIZE_EXPAND_FILL` Spacer entfernt).
  Die Karte zeigt nun zusätzlich eine [ID: ID_...] Zeile an.
* Tutorial Hologramm: Kann durch Drücken von [F] in der Nähe vergrößert
  werden. Veraltete Prompts (pre-Q/E) aufgeräumt.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Items:** [[cursed_die]], [[ouija_board]], [[rice_pudding]], [[roof_nail]], [[stiletto_heels]]

**Status-Effekte:** [[shield]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `c28ab95` |
| Autor | ImChubiii |
| Datum | 2026-08-04 |

## 🧠 Semantische Verbindungen (Graphify)
- **contains**: [[2026-08-04_c28ab95_featitems_ai_ui_levelgen_party-revive_item-reworks]] (Confidence: 1.0)
- **references**: [[_MOC_DevLogs]] (Confidence: 1.0)
