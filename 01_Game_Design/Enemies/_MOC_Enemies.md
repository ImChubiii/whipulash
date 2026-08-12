---
tags: [moc, enemies]
---

# MOC — Gegner nach Gruppierung

> *Die Übersicht aller Feinde in Lemonade, vom simplen Schwarmgegner bis zum vernichtenden Boss.*

## Das Threat-Budget System & Wahrscheinlichkeiten
In Lemonade gibt es keine starren Spawn-Listen! Der [[level_generator]] nutzt stattdessen ein dynamisches **Threat-Budget** pro Raum. Ein Raum hat beispielsweise ein Budget von 10 Punkten: Das System kann nun entweder **10 billige Stinger** spawnen ODER **1 massiven Colossus**. Dadurch ist jeder Durchlauf abwechslungsreich und fair balanciert.

> **💡 Spawn-Wahrscheinlichkeiten (`weight`):**
> Neben den Kosten hat jeder Gegner auch ein `weight`. Wenn der Generator auswählt, welcher Gegner spawnt, nimmt er dieses Gewicht.
> Beispiel: Stinger (`weight: 3.0`) tauchen **3-mal häufiger** auf als ein Colossus (`weight: 1.0`), sofern das Threat-Budget für den Gegner reicht.

*Hinweis: Gegner aus dem Sandbox-Tier haben noch keine Threat-Cost und tauchen vorerst nur im Debug-Raum auf!*

## Alle Gegner auf einen Blick

| Gegner | Threat | Gewicht | HP | Typ | Gefahr |
|---|---|---|---|---|---|
| **Threat-Tier** | | | | | |
| [[stinger\|Stinger]] | 1 | 3.0 | 25.0 | Nahkampf/Flankierer | ⭐ Niedrig |
| [[fighter\|Fighter]] | 3 | 2.0 | 30.0 | Nahkämpfer | ⭐⭐⭐ Mittel |
| [[colossus\|Colossus]] | 10 | 1.0 | 400.0 | Nahkampf (Boss) | ⭐⭐⭐⭐⭐ Sehr Hoch |
| **Sandbox-Tier** | | | | |
| [[moerser-bot\|Mörser-Bot]] | - | 90.0 | Stationaer/Fernkampf | ⭐⭐⭐ Mittel |
| [[saeure-sprinkler\|Säure-Sprinkler]] | - | 70.0 | Stationaer/Gebiets-DoT | ⭐⭐⭐ Mittel |
| [[magnet-kern\|Magnet-Kern]] | - | 160.0 | Stationaer/Kontrolle | ⭐⭐⭐⭐ Hoch |
| [[divebomber\|Divebomber]] | - | 55.0 | Flieger/Nahkampf | ⭐⭐⭐ Mittel |
| [[schild-drohne\|Schild-Drohne]] | - | 45.0 | Flieger/Support | ⭐ Niedrig |
| [[plasmastrahl-bot\|Plasmastrahl-Bot]] | - | 65.0 | Flieger/Fernkampf | ⭐⭐⭐⭐ Hoch |

## Schnellnavigation nach Rolle

### Stationaere Gefahren (Taktik: Fernkampf)
- [[moerser-bot\|Mörser-Bot]] (Flaechenschaden per Wurfparabel)
- [[saeure-sprinkler\|Säure-Sprinkler]] (Aetzende Pfützen blockieren Wege)
- [[magnet-kern\|Magnet-Kern]] (Zieht an, schleudert brutal zurueck)

### Flieger & Support (Taktik: Priorisieren oder Ignorieren)
- [[divebomber\|Divebomber]] (Rhythmischer Sturzangriff)
- [[plasmastrahl-bot\|Plasmastrahl-Bot]] (Brennender Bodenlaser, flieht bei Raum-Clear)
- [[schild-drohne\|Schild-Drohne]] (Pumpt Gegner mit Schilden voll, flieht bei Raum-Clear)

### Nahkampf & Tanks (Taktik: Distanz halten)
- [[stinger\|Stinger]] (Zigzag-Massen)
- [[fighter\|Fighter]] (Robust mit Reichweite)
- [[colossus\|Colossus]] (Langsamer HP-Gigant)
