---
tags: [moc, dashboard]
---

# Whiplash — Entwickler-Dashboard

> Für das Spieler-Wiki: **[[HOME|→ Zur Hauptseite des Wikis]]**

---

## Entwickler-Übersicht

Dieses Dashboard ist für die Entwicklung gedacht. Das Spieler-Wiki ist unter [[HOME]] erreichbar.

## Inhalts-Verzeichnis

### Spieler-Wiki
- [[HOME|Startseite]] — Spieler-Wiki-Hauptseite
- [[_MOC_Characters|Charaktere]] — Alle 4 spielbaren Charaktere
- [[_MOC_Enemies|Gegner]] — Alle Gegner mit Tipps
- [[_MOC_Items|Items]] — Alle 84 Items
- [[_MOC_Rooms|Räume]] — Alle 35 Raum-Vorlagen
- [[_MOC_Status_Effects|Status-Effekte]] — Alle 10 Effekte

### Technische Dokumentation
- [[party_manager]] — Party-System
- [[level_generator]] — Level-Generator
- [[player_base]] — Spieler-Basis
- [[status_effect_manager]] — Status-Effekt-Manager
- [[custom_enemy_base]] — Gegner-Basis (Sandbox-Prototypen)
- [[enemy_sandbox_room]] — Debug-Spawnraum

### DevLogs
- [[_MOC_DevLogs|Alle DevLogs]] — Vollständige Commit-Liste

---

*Automatisch generiert von `generate_vault.py` — bei Änderungen erneut ausführen.*


## Items

```dataview
TABLE kind AS "Kind", category AS "Kategorie", rarity AS "Rarity", cooldown_seconds AS "Cooldown (s)", charge_rooms AS "Charge (Räume)"
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

Siehe auch [[_MOC_Items]] für feste Wikilink-Verzeichnisse nach Kategorie/
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

Siehe auch [[_MOC_Enemies]] für die vollständige Rollen-Gruppierung.

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

Siehe auch [[_MOC_Status_Effects]] für die Gruppierung nach DoT/Crowd-Control/
Buff/generisches Debuff.

## DevLogs (jüngste zuerst)

```dataview
TABLE subject AS "Commit", author AS "Autor"
FROM "03_DevLogs"
WHERE file.name != "_MOC_DevLogs"
SORT date DESC
LIMIT 20
```

Nur die juengsten 20 — [[_MOC_DevLogs]] listet wirklich **alle** 78
Commits, nach Monat gruppiert.
