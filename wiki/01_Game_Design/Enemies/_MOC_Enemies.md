---
tags: [moc, enemy]
---

# MOC — Gegner nach Gruppierung

Zwei unabhaengige Gegner-Systeme im Projekt, siehe [[level_generator]] und
[[custom_enemy_base]]/[[enemy_sandbox_room]] fuer die architektonische
Begruendung der Trennung.

Threat-Budget = in LevelGenerator-Tabellen, zaehlt zum Raum-Clear. Sandbox =
nur ueber [[enemy_sandbox_room]] spawnbar, noch nicht integriert.

### Threat-Budget (3)

- [[fighter|Fighter]]
- [[stinger|Stinger]]
- [[colossus|Colossus]]


### Sandbox-Prototypen (6)

- [[moerser-bot|Moerser-Bot]]
- [[saeure-sprinkler|Saeure-Sprinkler]]
- [[magnet-kern|Magnet-Kern]]
- [[divebomber|Divebomber]]
- [[schild-drohne|Schild-Drohne]]
- [[plasmastrahl-bot|Plasmastrahl-Bot]]


## Sandbox-Prototypen nach Rolle

### Flieger · Fernkampf (Flaechenlaser), kein Pflicht-Kill (1)

- [[plasmastrahl-bot|Plasmastrahl-Bot]]

### Flieger · Nahkampf-Sturzangriff (Rhythmus-Timing) (1)

- [[divebomber|Divebomber]]

### Flieger · Support, kein Pflicht-Kill (Schild-Buff) (1)

- [[schild-drohne|Schild-Drohne]]

### Stationaer · Fernkampf (Gebiets-DoT ueber Pfuetzen) (1)

- [[saeure-sprinkler|Saeure-Sprinkler]]

### Stationaer · Fernkampf (Wurfparabel, Flaechenschaden) (1)

- [[moerser-bot|Moerser-Bot]]

### Stationaer · Kontrolle (Sog + Abstossungs-Schockwelle) (1)

- [[magnet-kern|Magnet-Kern]]

## 🧠 Semantische Verbindungen (Graphify)
- **referenced_by (references)**: [[00_Master_Wiki]] (Confidence: 1.0)
