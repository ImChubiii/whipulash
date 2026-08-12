---
id: "acid"
duration: 3.0
tick_interval: 0.5
damage_per_tick: 4.0
is_damage_over_time: true
heavy_duration: ""
synergies: ["extend_for_gum"]
triggered_by_items: ["holy_oil", "stiletto_heels", "chili_oil", "hand_vacuum", "seize", "snake_bite"]
tags: [status-effect, type/dot]
---

# acid

> *Der Gegner wird von ätzender Säure überzogen und erleidet kontinuierlich Schaden über Zeit.*

## Werte
| Feld | Wert |
|---|---|
| Dauer | 3.0 s |
| Typ | DOT |
| Tick-Intervall | 0.5 s |
| Schaden pro Tick | 4.0 |
| Damage over Time | Ja |
| Heavy-Dauer | — |

## Wirkung
Acid verursacht über eine Dauer von 3,0 Sekunden alle 0,5 Sekunden 4,0 Schaden am betroffenen Ziel. Betroffene Gegner werden visuell durch eine gelblich-grüne Säureauflage eingefärbt. Erneutes Auftragen verlängert den Effekt auf das Maximum der Restdauer, während Kaugummi-Effekte die Wirkungsdauer zusätzlich um 50 % verlängern können.

## Ausgeloest von
- [[holy_oil]]
- [[stiletto_heels]]
- [[chili_oil]]
- [[hand_vacuum]]
- [[seize]]
- [[snake_bite]]

## Synergiert mit
- [[chewing_gum]] / Kaugummi-Items (verlängert Säuredauer um 50 % via `extend_for_gum`)
- [[slow]] (hält Gegner länger in Säurepfützen fest)
- [[vulnerable]] (erhöht den Schaden jedes einzelnen Säure-Ticks)

## Alle Status-Effekte
- [[acid]] — Säure-Schaden über Zeit (DOT)
- [[burn]] — Feuer-Schaden über Zeit (DOT)
- [[charm]] — Gegner kämpfen für den Spieler (Spezial)
- [[confused]] — Zulfällige Angriffsrichtung (Crowd Control)
- [[rooted]] — Bewegungsunfähig (Crowd Control)
- [[shield]] — Schutzschild für Einheiten (Buff)
- [[silenced]] — Angriffe & Spezialfähigkeiten blockiert (Crowd Control)
- [[slow]] — Verlangsamte Bewegung (Crowd Control)
- [[stun]] — Vollständige Handlungsunfähigkeit (Crowd Control)
- [[vulnerable]] — Erhöht erlittenen Schaden (Debuff)
