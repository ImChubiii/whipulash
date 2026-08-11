---
id: "lemonade"
display_name: "Lemonade"
class_name: "LavaHazard"
tags: [hazard, "hazard/environment"]
---

# Lemonade

> Saure Limonade als Umgebungs-Hazard — im Code weiterhin `LavaHazard`
> genannt (historischer Name, das Script wurde von echter Lava auf die
> Limonaden-Optik umgestellt, siehe `scripts/hazards/lemonade.gd`
> Kopfkommentar).

## Mechanik

Zwei Modi, je nach Raum:

- **POOL** — echte Grube: der Boden ist unter der Lache ausgespart, man
  faellt rein, treibt auf (Auftrieb) und nimmt Schaden. So in `level_01`
  gebaut und die Basis fuer [[pit_floor|PitFloor]]s automatische
  `extra_pits`-Ableitung (`auto_pits_from_lava`).
- **SURFACE** — flache Pfuetze auf durchgehendem Boden: kein Einsinken,
  aber Durchwaten zaehlt sofort als "drin" (Schaden + Verlangsamung, kein
  Auftrieb). Liegt z. B. in `room_combat_02/04/05/06` vor.

Eintrittsschaden haengt am UEBERGANG "eben noch trocken, jetzt nass", nicht
am Betreten des Trigger-Volumens — sonst kaeme der erste Treffer bei einem
Sprung von oben erst nach einer vollen `tick_interval`-Sekunde. Danach
tickt der Schaden regelmaessig weiter, im SURFACE-Modus zusaetzlich mit
Verlangsamung (`slow`-Statuseffekt, wird jeden Frame aufgefrischt).

`PlayerStats.STAT_HAZARD_RESIST` mindert sowohl Schaden als auch
Verlangsamung — Gegner haben keinen solchen Stat und bekommen immer den
vollen Effekt ab (Absicht: die saeurefesten Stiefel sollen Gegner nicht
mitschuetzen, wenn man sie in eine Pfuetze lockt).

## Balancing (roh aus `scripts/hazards/lemonade.gd`)

| Wert | Betrag |
|---|---|
| Schaden pro Tick | 15 |
| Tick-Intervall (s) | 0.5 |
| Erster Tick nach Eintritt (s) | 0.3 |
| Verlangsamung im SURFACE-Modus | 45% |
| Resist-Schwelle fuer Slow-Immunitaet | 0.3 |
| Auftriebs-Steiggeschwindigkeit (POOL) | 2.5 |

## Verwendet von

- Als Raum-Hazard direkt in Combat-/Corridor-Templates (`room_combat_02/04/
  05/06`) und in den Parkour-Korridoren [[corridor_abyss_01]],
  [[corridor_abyss_02]], [[corridor_abyss_03]] — dort per
  [[pit_floor|PitFloor]] automatisch zu POOL-Gruben umgebaut.
- [[combat_lemonade_01]] / [[combat_lemonade_02]] — SURFACE-Instanzen mit
  `size.y` auf volle Raumhoehe gestreckt statt einer flachen Pfuetze:
  duenne, bodentiefe Saeulen zwischen Pfeilern, die wie fliessende Lemonade
  wirken sollen ("Wasserfall"-Optik). Jede Saeule hat ein begleitendes
  `NavigationObstacle3D`, damit Gegner nicht hindurchpathen.
- [[saeure-sprinkler|Saeure-Sprinkler]] nutzt dasselbe Area3D-Prinzip fuer
  seine geworfenen Saeure-Pfuetzen (siehe `item_behaviours.gd`).
- Items wie "Mamas Stoeckelschuhe" ([[acid_boots]]) legen eigene
  Lemonade-Pfuetzen und nutzen `ignore_group`, damit der Werfer sich nicht
  selbst zerlegt.

## Quelle

`scripts/hazards/lemonade.gd` (`class_name LavaHazard`)
