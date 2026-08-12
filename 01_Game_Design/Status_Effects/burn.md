---
id: "burn"
duration: 3.0
tick_interval: 0.75
damage_per_tick: 6.0
is_damage_over_time: true
heavy_duration: ""
synergies: ["detonate", "thermal_shock"]
triggered_by_items: ["hairspray", "copper_wire", "storm_lighter", "spicy_ramen", "incendiary", "blaze", "hot_hands"]
tags: [status-effect, type/dot]
---

# burn

> *Der Gegner steht lichterloh in Flammen und erleidet schweren Brandschaden über Zeit.*

## Werte
| Feld | Wert |
|---|---|
| Dauer | 3.0 s |
| Typ | DOT |
| Tick-Intervall | 0.75 s |
| Schaden pro Tick | 6.0 |
| Damage over Time | Ja |
| Heavy-Dauer | — |

## Wirkung
Burn fügt dem Ziel über eine Dauer von 3,0 Sekunden alle 0,75 Sekunden 6,0 Feuerschaden zu. Währen des Effekts leuchtet der betroffene Gegner kräftig rot-orange. Der verbleibende Brandschaden kann durch Detonationen sofort explosionsartig ausgelöst oder durch Kälteeffekte für einen Thermoschock verbraucht werden.

## Ausgeloest von
- [[hairspray]]
- [[copper_wire]]
- [[storm_lighter]]
- [[spicy_ramen]]
- [[incendiary]]
- [[blaze]]
- [[hot_hands]]

## Synergiert mit
- [[chili_oil]] (löst zusätzliche Angriffe gegen bereits brennende Gegner aus)
- `detonate` (verdoppelt den verbleibenden Brandschaden sofort als Detonations-Schaden)
- Kälte-Effekten für `thermal_shock` (Thermal-Schock-Explosion)
- [[vulnerable]] (verstärkt jeden Schadens-Tick erheblich)

## Alle Status-Effekte
- [[acid]] — Säure-Schaden über Zeit (DOT)
- [[burn]] — Feuer-Schaden über Zeit (DOT)
- [[charm]] — Gegner kämpfen für den Spieler (Spezial)
- [[confused]] — Zufällige Angriffsrichtung (Crowd Control)
- [[rooted]] — Bewegungsunfähig (Crowd Control)
- [[shield]] — Schutzschild für Einheiten (Buff)
- [[silenced]] — Angriffe & Spezialfähigkeiten blockiert (Crowd Control)
- [[slow]] — Verlangsamte Bewegung (Crowd Control)
- [[stun]] — Vollständige Handlungsunfähigkeit (Crowd Control)
- [[vulnerable]] — Erhöht erlittenen Schaden (Debuff)
