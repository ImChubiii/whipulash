---
tags: [moc, dashboard]
---

# Whiplash — Master Wiki

Automatisch generiert von `generate_vault.py` aus den echten Projektdateien
(nicht aus `_project_export.txt` selbst — siehe Skript-Docstring). Erneut
ausfuehren, sobald sich Items/Gegner/Raeume/Statuseffekte im Code aendern,
oder `98_Scripts/wiki_sync.py` fuer inkrementelle Updates verwenden.

## Map of Contents

- [[00_Master_Wiki|Dashboard]] (diese Seite)
- [[01_Dokumentations_Guide|Doku-Guide]] — erklaert jede Datei-Art im Vault (Chat-Prompts, DevLogs, Patchnotes, ...), woher sie kommt und wie sie gepflegt wird
- Game Design
  - Items (95) — [[_MOC_Items|nach Kategorie/Rarity/Kind]]
  - Enemies (3 Threat-Budget + 6 Sandbox-Prototypen)
    — [[_MOC_Enemies|nach Tier/Rolle]]
  - Rooms (39) — [[_MOC_Rooms|nach Typ]]
  - Status Effects (10) — [[_MOC_Status_Effects|nach Klasse]]
- Tech Architecture
  - [[party_manager]]
  - [[level_generator]]
  - [[player_base]]
  - [[status_effect_manager]]
  - [[custom_enemy_base]] — Unterbau der sechs Sandbox-Prototypen
  - [[enemy_sandbox_room]] — Debug-Spawnraum fuer alle Gegnertypen
- DevLogs (88 Commits) — [[_MOC_DevLogs|vollstaendige Liste]]
- Templates: [[tpl_Item]] · [[tpl_Enemy]] · [[tpl_Room]] · [[tpl_StatusEffect]]

Jede Item-/Gegner-/Raum-/Status-Effekt-/Architektur-Notiz hat unten einen
Abschnitt **"Erwaehnt in DevLogs"** — per Freitext-Abgleich aus den
Commit-Nachrichten erkannt (siehe `build_entity_index()` in
`generate_vault.py`). Jede DevLog-Notiz hat umgekehrt einen Abschnitt
**"Erwaehnte Entitaeten"**.

## Items

```dataview
TABLE kind AS "Kind", category AS "Kategorie", rarity AS "Rarity", cooldown_seconds AS "Cooldown (s)", charge_rooms AS "Charge (Raeume)"
FROM "01_Game_Design/Items"
WHERE file.name != "_MOC_Items"
SORT rarity DESC, name ASC
```

### Items nach Rarity

```dataview
TABLE length(rows) AS "Anzahl"
FROM "01_Game_Design/Items"
WHERE file.name != "_MOC_Items"
GROUP BY rarity
SORT rarity DESC
```

Siehe auch [[_MOC_Items]] fuer feste Wikilink-Verzeichnisse nach Kategorie/
Rarity/Kind (funktioniert auch ohne Dataview-Plugin).

## Enemies

### Threat-Budget (Level-Generator, `enemy_ai.gd`)

```dataview
TABLE threat_cost AS "Threat-Cost", base_hp AS "HP", move_speed AS "Speed", speed_variance AS "Speed-Varianz"
FROM "01_Game_Design/Enemies"
WHERE tier = "levelgen" OR !tier
SORT threat_cost ASC
```

### Sandbox-Prototypen (`custom_enemy_base.gd`, noch nicht im Threat-Budget)

```dataview
TABLE role AS "Rolle", base_hp AS "HP"
FROM "01_Game_Design/Enemies"
WHERE tier = "sandbox"
SORT display_name ASC
```

Siehe auch [[_MOC_Enemies]] fuer die vollstaendige Rollen-Gruppierung.

## Rooms

```dataview
TABLE room_type AS "Typ", footprint_cells AS "Footprint", spawn_weight AS "Gewicht", min_stage AS "Min. Etage"
FROM "01_Game_Design/Rooms"
WHERE file.name != "_MOC_Rooms"
SORT room_type ASC, id ASC
```

### Räume nach Typ

```dataview
TABLE length(rows) AS "Anzahl"
FROM "01_Game_Design/Rooms"
WHERE file.name != "_MOC_Rooms"
GROUP BY room_type
```

Siehe auch [[_MOC_Rooms]].

## Status Effects

```dataview
TABLE duration AS "Dauer (s)", tick_interval AS "Tick (s)", damage_per_tick AS "Schaden/Tick", is_damage_over_time AS "DoT?"
FROM "01_Game_Design/Status_Effects"
WHERE file.name != "_MOC_Status_Effects"
SORT id ASC
```

Siehe auch [[_MOC_Status_Effects]] fuer die Gruppierung nach DoT/Crowd-Control/
Buff/generisches Debuff.

## DevLogs (jüngste zuerst)

```dataview
TABLE subject AS "Commit", author AS "Autor"
FROM "03_DevLogs"
WHERE file.name != "_MOC_DevLogs"
SORT date DESC
LIMIT 20
```

Nur die juengsten 20 — [[_MOC_DevLogs]] listet wirklich **alle** 88
Commits, nach Monat gruppiert.

## 🧠 Semantische Verbindungen (Graphify)
- **references**: [[_MOC_Enemies]] (Confidence: 1.0)
- **references**: [[_MOC_Items]] (Confidence: 1.0)
- **references**: [[_MOC_Rooms]] (Confidence: 1.0)
