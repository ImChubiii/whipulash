---
id: "divebomber"
display_name: "Divebomber"
class_name: "DiveBomber"
tier: sandbox
role: "Flieger · Nahkampf-Sturzangriff (Rhythmus-Timing)"
base_hp: 55.0
status_effects: []
tags: [enemy, "enemy/sandbox"]
---

# Divebomber

> Flieger · Nahkampf-Sturzangriff (Rhythmus-Timing)

**Sandbox-Prototyp:** spawnt Stand jetzt ausschliesslich im
[[enemy_sandbox_room]] (Debug-Teleporter), noch nicht Teil der
[[level_generator]]-Threat-Budget-Tabellen — zaehlt also noch nicht zum
Raum-Clear und hat keinen `threat_cost`. Baut wie alle sechs neuen Typen auf
[[custom_enemy_base]] statt auf `enemy_ai.gd` auf.

## Mechanik

Schwebt ausserhalb der Nahkampfreichweite (leichtes Auf/Ab, KEIN Kreisen) und stuerzt im festen Rhythmus (`dash_interval`) herab: LOCK-Phase mit sichtbarem Lean- und Ring-Telegraph auf die zu diesem Zeitpunkt FESTGELEGTE Zielposition, dann senkrechter Sturz. Der Einschlag passiert immer (Treffer oder nicht) und hinterlaesst liegenbleibende Gesteinstruemmer; der Bomber selbst ist danach IMMER `grounded_stun_time` (5s) bewegungsunfaehig, unabhaengig davon, ob der Sturz traf.

## Balancing (roh aus `scripts/enemies/dive_bomber.gd`)

| Wert | Betrag |
|---|---|
| Basis-HP | 55 |
| Schwebehoehe | 11 |
| Rezentrier-Geschwindigkeit | 2.5 |
| Sturz-Rhythmus (s) | 3.4 |
| Lock-Telegraph-Dauer (s) | 0.9 |
| Sturzgeschwindigkeit | 34 |
| Trefferradius | 2.4 |
| Schaden | 20 |
| Selbst-Stun nach Einschlag (s) | 5 |
| Aufstiegsgeschwindigkeit | 10 |
| Erkennungsreichweite | 40 |

## Status-Effekte (ausgeloest)

- — (reiner Schaden/Knockback, kein Status-Effekt)

## Quelle

`scripts/enemies/dive_bomber.gd` (Modul-Scope-`var`-Deklarationen, `_configure()`)
