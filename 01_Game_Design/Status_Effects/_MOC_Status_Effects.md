---
tags: [moc, status-effect]
---

# MOC — Status-Effekte in Lemonade

> *Übersicht über alle 10 Status-Effekte des Spiels Lemonade, geordnet nach Wirkungsweise, Typ, Dauer und ihren Synergie-Kombinationen.*

## Übersicht aller Status-Effekte

| Name | Typ | Dauer | Kurzbeschreibung |
|---|---|---|---|
| [[acid]] | DOT | 3.0 s | Ätzender Säure-Schaden über Zeit (4.0 Dmg / 0.5s) |
| [[burn]] | DOT | 3.0 s | Feuriger Brandschaden über Zeit (6.0 Dmg / 0.75s) |
| [[charm]] | Spezial | 4.0 s | Bezaubert Gegner, sodass sie Verbündete angreifen |
| [[confused]] | Crowd Control | 2.0 s / 4.0 s | Angriffsrichtung weicht um 75° bis 140° zufällig ab |
| [[rooted]] | Crowd Control | 1.5 s | Bewegungsunfähig am Boden festgenagelt (Angriff erlaubt) |
| [[shield]] | Buff | 1.0 s | Schutzschild (+25 % Max HP) von Drohnen auf Gegner |
| [[silenced]] | Crowd Control | 1.0 s | Spezialangriffe und Angriffs-Telegraphs werden blockiert |
| [[slow]] | Crowd Control | 1.5 s / 2.0 s | Bewegungsgeschwindigkeit um 25 % bis 40 % reduziert |
| [[stun]] | Crowd Control | 2.0 s | Vollständige Handlungs- und Bewegungsunfähigkeit |
| [[vulnerable]] | Debuff | item-spezifisch | Erhöht den erlittenen Schaden nachfolgender Treffer |

## Das Synergie-System

Das Status-Effekt-System in *Lemonade* erlaubt vielfältige Kombinationen zwischen Effekten, Waffen und gegnerischen Fähigkeiten:

1. **Laufzeit-Verwaltung (`StatusEffectManager`)**: Standardmäßig nimmt das erneute Auftragen eines Effekts das Maximum aus alter und neuer Restdauer (`apply_effect()`). Spezielle Verlängerungen (wie `extend_effect()`) ermöglichen das gezielte Aufrechterhalten von Effekten.
2. **Kaugummi-Verlängerung (`extend_for_gum`)**: Säure-Effekte ([[acid]]) werden durch Kaugummi-Mechanismen um zusätzliche 50 % Wirkungsdauer verlängert.
3. **Detonation & Thermoschock (`detonate` / `thermal_shock`)**: Brennende Gegner ([[burn]]) erleiden durch Explosiv-Effekte sofort ihren verbleibenden Brandschaden in doppelter Höhe oder können durch Kälte-Effekte für eine Thermoschock-Explosion verbraucht werden.
4. **Schadensboni & Stun-Kombis**: Verwirrte Gegner ([[confused]]) erleiden 25 % Bonusschaden durch Stun-Angriffe. Gegen betäubte Ziele ([[stun]]) richten Items wie das Megaphone (3.0x Schaden) oder das Modem 56k (1.75x Krit) gewaltigen Zusatzschaden an.
5. **Debuff-Verstärkung**: [[vulnerable]] verstärkt nachfolgenden Schaden (z. B. +49 % durch Schlangenbiss oder +140 % durch den Alarm-Bot) und potenziert somit den Schaden aller laufenden DOTs ([[acid]], [[burn]]) sowie direkter Treffer.

## Kategorisierung nach Typ

### Damage over Time (2)
- [[acid]]
- [[burn]]

### Crowd Control (5)
- [[stun]]
- [[confused]]
- [[rooted]]
- [[silenced]]
- [[slow]]

### Spezial / Buff / Debuff (3)
- [[charm]]
- [[shield]]
- [[vulnerable]]
