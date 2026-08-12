---
id: "lemonade"
display_name: "Lemonade"
class_name: "LavaHazard"
tags: [hazard, "hazard/environment"]
---

# Limonade (Umgebungs-Hazard)

> *Aetzende Limonade auf dem Boden — wer drin steht, verliert schnell HP und steckt fest.*

## Was ist das?
Kurze spielerfreundliche Erklaerung: 2 Modi existieren (POOL = echte Grube mit Auftrieb, SURFACE = flache Pfütze auf Boden). Beide machen Schaden und verlangsamen.

## Werte
| Feld | Wert |
|---|---|
| Schaden/Tick | 15 |
| Tick alle | 0.5 s |
| Erster Treffer nach | 0.3 s |
| Verlangsamung | 45% (nur SURFACE-Modus) |

## POOL vs. SURFACE
- **POOL**: Echte Gruben, in die man hineinfaellt. Du nimmst Schaden, treibst aber dank Auftrieb nach oben.
- **SURFACE**: Flache Pfützen auf dem Boden. Kein Einsinken, aber sofortiger Schaden beim Durchwaten und zusätzliche Verlangsamung.

## Tipps
- **[[acid_boots|Saeurefeste Stiefel]]**: Reduziert Schaden um 75% und hebt die Verlangsamung komplett auf!
- **Gegner in Pfützen locken**: Gegner haben keine Hazard-Resistenz — sie nehmen vollen Schaden und werden auch verlangsamt.

## Vorkommt in
- [[combat_lemonade_01|Saeurebecken]] — SURFACE-Modus
- [[combat_lemonade_02|Limonaden-Grube]] — SURFACE-Modus
- [[corridor_abyss_01]] / [[corridor_abyss_02]] / [[corridor_abyss_03]] — POOL-Modus

## Verwandt
- [[acid_boots|Saeurefeste Stiefel]] — bester Konter
- [[acid|Säure-Status-Effekt]] — aehnlicher Effekt durch Items
- [[stiletto_heels|Mamas Stoeckelschuhe]] — erzeugen eigene Limonade-Pfützen
- [[battery_pack|Ausgelaufene Flachbatterie]] — explodiert bei Kontakt mit Säure
- [[_MOC_Rooms|Alle Räume]]
