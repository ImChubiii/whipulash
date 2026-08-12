---
id: "confused"
duration: 2.0
tick_interval: 0.0
damage_per_tick: 0.0
is_damage_over_time: false
heavy_duration: "4.0"
synergies: ["max_angle_rad"]
triggered_by_items: ["disco_ball", "roller_skates", "walkman", "leer", "fakeout", "prowler", "paranoia"]
tags: [status-effect, type/cc]
---

# confused

> *Der Gegner gerät ins Taumeln und schlägt in eine völlig falsche Richtung.*

## Werte
| Feld | Wert |
|---|---|
| Dauer | 2.0 s |
| Typ | Crowd Control |
| Tick-Intervall | — |
| Schaden pro Tick | — |
| Damage over Time | Nein |
| Heavy-Dauer | 4.0 s |

## Wirkung
Confused lenkt die Angriffsrichtung des Gegners zufällig um bis zu 75° ab (in der Heavy-Variante um bis zu 140° über 4,0 Sekunden). Optisch zieht die verwirrte Einheit einen leuchtenden Regenbogen-Schimmer hinter sich her. Zusätzlich erleiden verwirrte Gegner 25 % Bonusschaden durch Stun-Kombinationen.

## Ausgeloest von
- [[disco_ball]]
- [[roller_skates]]
- [[walkman]]
- [[leer]]
- [[fakeout]]
- [[prowler]]
- [[paranoia]]

## Synergiert mit
- [[stun]] (nutzt den verknüpften `STUN_DAMAGE_BONUS` von +25 %)
- Ausweich- & Mobilitäts-Items, da Schläge ins Leere gehen

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
