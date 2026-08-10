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
- Game Design
  - Items (84)
  - Enemies (3)
  - Rooms (26)
  - Status Effects (9)
- Tech Architecture
  - [[party_manager]]
  - [[level_generator]]
  - [[player_base]]
  - [[status_effect_manager]]
- DevLogs (66 Commits)
- [[#Prompt-Log|Prompt-Log]] (54 Chats, eigene Claude-Nachrichten)
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

## Prompt-Log

Eigene Claude-Nachrichten aus dem Chat-Export, chronologisch als ein Note pro
Unterhaltung. Jede Nachricht mit erkennbarem Bezug wurde per `**Bezug:**`
zu Items/Gegnern/Räumen/Status-Effekten/Tech-Architecture/DevLogs verlinkt
(automatisches Keyword-/Fuzzy-Matching, nicht 1:1 exakt — Links auf den
jeweiligen Notes zeigen unter "Linked Mentions" alle zugehörigen Prompts).

```dataview
TABLE date AS "Datum"
FROM "04_Chat_Prompts"
SORT date DESC
```
