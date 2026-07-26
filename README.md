# whiplash

# Lemonade

Ein schnelles Action-Spiel im PSX-Look: du kämpfst dich mit einem Team aus vier
Charakteren durch einen Dungeon, der bei jedem Durchlauf neu gewürfelt wird —
gegen die Uhr und gegen alles, was zwischen dir und dem Boss steht.

---

## Worum es geht

Jeder Run beginnt im selben Startraum und endet, wenn der Boss der Etage liegt.
Dazwischen liegt ein Grundriss, den das Spiel aus einem Zufalls-Seed baut:
Kampfarenen, schmale Verbindungsgänge, ein Tresorraum und die Bossarena.

Betrittst du einen Kampfraum, fallen die Türen zu und bleiben zu, bis der letzte
Gegner liegt. Boss- und Tresortüren sind zusätzlich verriegelt und müssen erst
freigeschaltet werden. Der Weg dorthin ist also nie derselbe, das Prinzip aber
immer: rein, aufräumen, weiter.

Die Uhr läuft dabei mit. Lemonade ist auf schnelle, wiederholbare Durchläufe
ausgelegt — nicht auf Erkundung.

---

## Features

**Kampf**
- Vier spielbare Charaktere mit jeweils eigenem Moveset, im laufenden Kampf
  wechselbar
- Primär- und Sekundärangriff, Dash, zwei Fähigkeiten
- Combo-System mit Kamera-Feedback, Knockback, Betäubung und Statuseffekten
- Lock-On auf einzelne Ziele

**Gegner**
- Mehrere Typen vom flinken Späher bis zum schwerfälligen Koloss
- Gegner besetzen einen Raum nach einem Bedrohungsbudget statt nach fester
  Anzahl — viele billige oder wenige teure, das Spiel entscheidet
- Späher laufen im Zickzack und verlieren gelegentlich den Fokus, wodurch eine
  Horde nicht als geschlossener Block auftritt
- Lebenspunkte und Schaden wachsen mit der Etage

**Level**
- Prozedural erzeugte Etagen aus handgebauten Raum-Vorlagen
- Höhenversätze werden über Rampen in den Verbindungsgängen aufgelöst
- Umgebungsgefahren: ätzende Limonadenbecken, in die man wirklich hineinfällt
- Ungenutzte Durchgänge werden zugemauert, jeder Raum sieht also aus, wie er
  sich verhält

**Orientierung**
- Minimap als Draufsicht plus schematische Raumübersicht
- Große Karte zum Verschieben und Zoomen
- Nebel des Krieges: nur besuchte Räume und ihre direkten Nachbarn
- Türzustände sind auf beiden Karten ablesbar

**Runs & Bestzeiten**
- Speedrun-Timer
- Jeder Run hat einen kurzen, teilbaren Seed-Code — derselbe Code erzeugt
  denselben Dungeon
- Optionale Steam-Bestenlisten (Gesamt und Tages-Seed)

**Präsentation**
- PSX-Ästhetik: Vertex-Snapping, niedrig aufgelöste Texturen, CRT-Nachbearbeitung
- Optionen für Bild, Ton, Steuerung und Barrierefreiheit

---

## Steuerung

| Aktion | Standard |
|---|---|
| Bewegen | `W` `A` `S` `D` |
| Springen | `Leertaste` |
| Dash | `Shift` |
| Primärangriff | Linke Maustaste |
| Sekundärangriff | Rechte Maustaste |
| Fähigkeit 1 | `Q` |
| Fähigkeit 2 | `E` |
| Charakter wechseln | `1` – `4` |
| Interagieren / Hacken | `F` |
| Große Karte | `M` |
| Pause & Optionen | `Esc` |
| Etage neu starten | `R` |
