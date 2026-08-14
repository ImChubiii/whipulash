---
title: "Tutorial-Prompt formulieren"
date: 2026-08-13
tags: [chatlog, prompt-log, whiplash, lemonade, thema/tooling, thema/meta, ki/antigravity]
ki_art: "antigravity"
---
# Tutorial-Prompt formulieren

[Antigravity Session](file:///C:/Users/thvnh/.gemini/antigravity/brain/21a2cfcf-c2ac-4134-a568-f539522503b9/.system_generated/logs/transcript_full.jsonl)

## User

bitte ein prompt formulieren:

bitte mach ein tutorial den man abschließen msus, das tutorial sollte auch beim main menü sein und als teleporter sein im ersten level. das tutorial soll wiefolgt sein: erstmal nur ningning ohne andere character, die geht dann vom corridor in den ersten raum wo gegner sind und dann in den nächsten raum. nächster raum ist dann ein treasure room wo man giselle freischaltet, dadnn wieder fight room mit giselle, dann treasure room wo man karina freischaltet dann fight dann winter damit man jeden character kennenlernt, und dann zuletzt nach dem fight ein treasure room mit item und dann fight, dann ein treasure room wo man in die erste ebene kommt. die fighträume sind so 

1. fight room sind nur fighter und scouts
2. sind mörser und säure mörser und diver 
3. sind scouts und shields
4. plasma shooter und 2 fighter 

also nochmal alles zusammen 
lobby > fight > unlock giselle > fight > unlock karina > fight > unlock winter > fight > random item > letzter fight wo man den schwarzen win trophe freischaltet für die 1. ebene

bitte mach auch so wie eine item description aber permanent mit der character description in kurz also zb 
["ningning ist closerange kämpferin die mit schlägen und explosionen kämpft](lobby > fight) > ["giselle hat 2 waffen die auto aim, etc](unlock giselle > fight) > unlock karina > fight > unlock winter > fight > random item > letzter fight wo man den schwarzen win trophe freischaltet für die 1. ebene


bitte alles als prompt machen damit ich das claude geben kann

## Assistant

Hier ist ein strukturierter und detaillierter Prompt, den du direkt kopieren und an Claude schicken kannst:

***

**Bitte kopiere den folgenden Text und sende ihn an Claude:**

```text
Bitte erstelle ein Tutorial-Level für mein Spiel, das der Spieler abschließen muss. Der Zugang zum Tutorial soll über einen Teleporter im Main Menü erfolgen. Das Tutorial dient dazu, alle spielbaren Charaktere und ihre Mechaniken kennenzulernen. 

Bitte implementiere den folgenden strikten Ablauf für das Tutorial-Level. Jedes Mal, wenn ein neuer Charakter freigeschaltet wird, soll eine permanente kurze Charakterbeschreibung (ähnlich einer Item-Description) auf dem Bildschirm angezeigt werden.

Hier ist der genaue Raum-für-Raum Ablauf:

1. **Start (Corridor)**:
   - Der Spieler startet ausschließlich mit dem Charakter **Ningning**.
   - *UI-Beschreibung permanent sichtbar*: "Ningning ist eine Close-Range-Kämpferin, die mit Schlägen und Explosionen kämpft."
   - Der Spieler geht vom Korridor in den ersten Raum.

2. **Raum 1 (Fight Room)**:
   - Gegner: Nur Fighter und Scouts.
   - Nach dem Sieg geht es in den nächsten Raum.

3. **Raum 2 (Treasure Room - Unlock Giselle)**:
   - Der Spieler schaltet **Giselle** frei.
   - *UI-Beschreibung permanent sichtbar ergänzt*: "Giselle hat 2 Waffen mit Auto-Aim."

4. **Raum 3 (Fight Room)**:
   - Gegner: Mörser, Säure-Mörser und Diver.
   - Der Spieler nutzt hier Giselle.

5. **Raum 4 (Treasure Room - Unlock Karina)**:
   - Der Spieler schaltet **Karina** frei.
   - *UI-Beschreibung permanent sichtbar ergänzt*: [Bitte füge hier eine kurze, passende Beschreibung für Karinas Spielstil/Waffen ein, z.B. "Karina nutzt schnelle Nahkampfangriffe..."].

6. **Raum 5 (Fight Room)**:
   - Gegner: Scouts und Shields.
   - Der Spieler nutzt hier Karina.

7. **Raum 6 (Treasure Room - Unlock Winter)**:
   - Der Spieler schaltet **Winter** frei.
   - *UI-Beschreibung permanent sichtbar ergänzt*: [Bitte füge hier eine kurze, passende Beschreibung für Winters Spielstil/Waffen ein].

8. **Raum 7 (Fight Room)**:
   - Gegner: Plasma Shooter und 2 Fighter.
   - Der Spieler nutzt hier Winter.

9. **Raum 8 (Treasure Room - Item)**:
   - Der Spieler findet ein zufälliges Item (Random Item).

10. **Raum 9 (Final Fight & Ebene 1 Zugang)**:
    - Letzter Kampf des Tutorials.
    - Belohnung nach dem Sieg: Der Spieler erhält die "Schwarze Win-Trophy".
    - Funktion der Trophy: Schaltet den Zugang zur regulären 1. Ebene des Spiels frei.

Zusammenfassung des Flows:
Lobby/Main Menü (Teleporter) > Start mit Ningning > Fight 1 > Unlock Giselle > Fight 2 > Unlock Karina > Fight 3 > Unlock Winter > Fight 4 > Random Item > Letzter Fight > Schwarze Win-Trophy für Ebene 1.

Bitte schreibe den Code / die Logik für dieses Tutorial-Level, inklusive der Raum-Übergänge, der spezifischen Gegner-Spawns pro Raum und dem UI-System für die permanenten Charakter-Beschreibungen.
```

*** 

**Hinweis:** Ich habe bei Karina und Winter Platzhalter `[Bitte füge hier...]` für die Beschreibungen eingefügt, da du diese nicht spezifisch erwähnt hattest. Claude wird sich anhand dieses Prompts entweder etwas Passendes ausdenken oder du kannst den Text vor dem Absenden noch mit deinen eigenen Beschreibungen für Karina und Winter anpassen!

## User

schreib ein neuen prompt 

ne das gefällt mir garnicht, es soll lieber wie normale level generator aufgebaut sein. nur neue räume die extra so sind wie gezeigt. character unlock solllte in einem treasure room stattfinden und statt ein item ist da ein character.

## Assistant

Hier ist ein neuer Prompt für Claude, der sich darauf konzentriert, dein **bestehendes Level-Generator-System** zu nutzen und dieses nur für das Tutorial anzupassen:

***

**Bitte kopiere den folgenden Text und sende ihn an Claude:**

```text
Ich möchte ein Tutorial-Level für mein Spiel erstellen. Statt das Tutorial komplett neu und statisch zu scripten, möchte ich, dass es auf meinem **normalen Level-Generator** aufbaut. Der Level-Generator soll für den Tutorial-Run lediglich eine feste Abfolge von bestimmten, vordefinierten Räumen generieren.

Der Zugang zum Tutorial soll über einen Teleporter im Main Menü erfolgen.

**Das wichtigste neue Feature:**
Wir brauchen eine spezielle Variante des "Treasure Rooms". Statt einem normalen Item soll dort ein **Charakter zum Freischalten** gespawnt werden.

**Der genaue Raum-Ablauf, den der Generator für das Tutorial erstellen soll:**

1. **Start (Corridor)**:
   - Der Spieler startet ausschließlich mit **Ningning**.
   - *Permanentes UI-Element*: Eine kurze Item-ähnliche Beschreibung ist ab jetzt auf dem Bildschirm: "Ningning: Close-Range-Kämpferin (Schläge & Explosionen)."

2. **Raum 1 (Fight Room)**:
   - Der Generator soll hier nur Fighter und Scouts spawnen.

3. **Raum 2 (Special Treasure Room - Character Unlock)**:
   - Statt eines Items spawnt hier der Charakter **Giselle**.
   - *Permanentes UI-Element ergänzt*: "Giselle: 2 Waffen mit Auto-Aim."

4. **Raum 3 (Fight Room)**:
   - Der Generator spawnt hier Mörser, Säure-Mörser und Diver.

5. **Raum 4 (Special Treasure Room - Character Unlock)**:
   - Statt eines Items spawnt hier der Charakter **Karina**.
   - *Permanentes UI-Element ergänzt*: [Hier Beschreibung für Karina eintragen].

6. **Raum 5 (Fight Room)**:
   - Der Generator spawnt hier Scouts und Shields.

7. **Raum 6 (Special Treasure Room - Character Unlock)**:
   - Statt eines Items spawnt hier der Charakter **Winter**.
   - *Permanentes UI-Element ergänzt*: [Hier Beschreibung für Winter eintragen].

8. **Raum 7 (Fight Room)**:
   - Der Generator spawnt hier Plasma Shooter und 2 Fighter.

9. **Raum 8 (Normaler Treasure Room)**:
   - Ein ganz normaler Treasure Room, in dem ein **Random Item** generiert wird.

10. **Raum 9 (Final Fight Room)**:
    - Der letzte Kampf.
    - Nach dem Sieg droppt die **Schwarze Win-Trophy**. Wenn der Spieler diese einsammelt, wird die reguläre 1. Ebene des Spiels freigeschaltet.

**Aufgabe:**
Bitte passe das bestehende Level-Generation-Skript so an, dass man ihm eine Art "Tutorial-Modus" übergeben kann, der genau diesen Flow (Rooms 1 bis 9) generiert. Implementiere außerdem die Logik für den speziellen "Character Unlock"-Treasure-Room und das UI-System, das die Charakter-Beschreibungen permanent als Liste auf dem Bildschirm anzeigt, sobald sie eingesammelt werden.
```

***

**Tipp:** Wenn du den Prompt absendest, denk daran, bei Karina und Winter noch kurz dazuzuschreiben, wie sie kämpfen (in den eckigen Klammern), damit Claude die UI-Texte direkt perfekt einbauen kann!

## User

erstelle ein prompt bitte item wie bomben coins und heal sind zu weit im boden also 1/3 des models ist im boden 

character description soll untger der minimap sein und auch dranhängen dynamisch nicht fester punkt, falls spieler andere minimap size haben

räume können in verschiedene richtung gehen aber imemr konsekutiv also nach einander. das heißt das treasure room 2 türewn hat zb weil es erstmal von fightroom in den nächsten geht, 

treasure room sollten auch grau angezeigt werden bis man darein geht (das gilt immer nicht nur für tutorial)

treasure room und boss room icons fehlen auf der map

## Assistant

Hier ist der aktualisierte und erweiterte Prompt für Claude, der deine neuen Anforderungen, Bugfixes und das Map-System integriert:

***

**Bitte kopiere den folgenden Text und sende ihn an Claude:**

```text
Ich brauche Hilfe bei der Erweiterung meines Level-Generators sowie bei einigen Bugfixes bezüglich Items, UI und dem Minimap-System.

Bitte bearbeite die folgenden 5 Punkte:

### 1. Bugfix: Items clippen in den Boden
Items wie Bomben, Coins und Heal-Drops stecken zu weit im Boden (ca. 1/3 des 3D-Modells ist unter der Erde). 
- **Aufgabe:** Bitte passe die Spawn-Logik oder den Y-Offset (bzw. den Collider/Pivot) so an, dass diese Pickups korrekt auf dem Boden liegen und nicht mehr darin versinken.

### 2. UI-Anpassung: Dynamische Charakter-Beschreibung
Im Tutorial (und generell) blenden wir eine permanente Charakter-Beschreibung ein (z.B. "Ningning: Close-Range...").
- **Aufgabe:** Dieses UI-Element darf keine feste Bildschirmposition haben. Es muss stattdessen dynamisch direkt **unter die Minimap** gehängt werden (verankert an der Minimap). Wenn der Spieler die Größe der Minimap ändert, muss das UI-Element automatisch mitrutschen, damit es immer passend darunter hängt.

### 3. Minimap-Logik: Icons und Fog of War
- **Aufgabe A (Icons):** Auf der Minimap fehlen derzeit die Icons für den "Treasure Room" und den "Boss Room". Bitte füge Logik hinzu, um diese spezifischen Icons auf der Map anzuzeigen.
- **Aufgabe B (Farbe):** Treasure Rooms (generell im ganzen Spiel, nicht nur im Tutorial) sollen auf der Minimap als unentdeckt (grau) angezeigt werden, bis der Spieler den Raum tatsächlich betritt. 

### 4. Tutorial-Level: Generator-Logik & Raum-Verbindungen
Ich möchte ein Tutorial-Level erstellen, das über einen Teleporter im Main Menü erreichbar ist. Es soll auf dem **normalen Level-Generator** aufbauen, aber eine feste Abfolge von generierten Räumen haben. 
- **Wichtig für den Generator:** Die Räume können in verschiedene Richtungen generiert werden (nicht nur in einer geraden Linie), aber sie müssen zwingend **konsekutiv (nacheinander)** folgen. Das bedeutet insbesondere, dass die Treasure Rooms im Tutorial **2 Türen** haben müssen (einen Eingang vom vorherigen Fight Room und einen Ausgang zum nächsten Fight Room), damit der Weg weitergeht.

### 5. Der genaue Tutorial-Flow (Generator-Vorgaben)
Bitte implementiere einen speziellen "Tutorial-Seed/Modus" für den Generator mit folgendem genauen Ablauf:

1. **Start (Corridor)**: Spieler startet mit **Ningning**. UI unter Minimap: "Ningning: Close-Range-Kämpferin (Schläge & Explosionen)."
2. **Raum 1 (Fight Room)**: Spawnt nur Fighter und Scouts.
3. **Raum 2 (Special Treasure Room - Unlock Giselle)**: 2 Türen. Statt eines Items spawnt der Charakter **Giselle** zum Freischalten. UI-Update: + "Giselle: 2 Waffen mit Auto-Aim."
4. **Raum 3 (Fight Room)**: Spawnt Mörser, Säure-Mörser und Diver.
5. **Raum 4 (Special Treasure Room - Unlock Karina)**: 2 Türen. Statt eines Items spawnt der Charakter **Karina** zum Freischalten. UI-Update: + [Beschreibung Karina].
6. **Raum 5 (Fight Room)**: Spawnt Scouts und Shields.
7. **Raum 6 (Special Treasure Room - Unlock Winter)**: 2 Türen. Statt eines Items spawnt der Charakter **Winter** zum Freischalten. UI-Update: + [Beschreibung Winter].
8. **Raum 7 (Fight Room)**: Spawnt Plasma Shooter und 2 Fighter.
9. **Raum 8 (Normaler Treasure Room)**: 2 Türen. Spawnt ein normales **Random Item**.
10. **Raum 9 (Final Fight Room)**: Der letzte Kampf. Als Belohnung droppt die **Schwarze Win-Trophy**. Diese schaltet den Zugang zur regulären 1. Ebene frei.

Bitte erstelle oder überarbeite die relevanten Skripte (Item-Spawn, UI-Anchoring, Minimap-Manager, LevelGenerator), um all diese Anforderungen umzusetzen.
```

## User

erstelle ein prompt der das erklärt 





tutorial text besser machen mit you have to click rmb usw 
default kartenzoom 1.60

cooldown hud unten rechts kann größer 

mörser und säure kanonen können bisschen kleiner 

bitte im tutorial description auch erklären das man mit shift über obstacles dashen kann

enemy esp bei winter und giselle ist gut aber manchmal entstehen beim selben gegner mehrere esps, wahrscheinlich durch jeden einzelnen schuss, mach das es nur ein esp ist und das das esp verschwindet wenn der gegner tot ist.

man sollte nur einen gegner anschießen also mach am besten so das es nur ein esp gibt der von gegner zu gegner springt je nach dem welchen man anvisiert hat.

## Assistant

Hier ist der neue Prompt, der alle deine Anpassungen, UI-Änderungen und den Bugfix für das ESP-System zusammenfasst:

***

**Bitte kopiere den folgenden Text und sende ihn an Claude:**

```text
Ich habe noch ein paar weitere Anpassungen, UI-Änderungen und Bugfixes für das Spiel, die umgesetzt werden müssen:

### 1. Tutorial-Texte & Erklärungen verbessern
Die Texte im Tutorial sollen detaillierter werden und dem Spieler die genaue Steuerung erklären. 
- **Aufgabe:** Bitte überarbeite die permanenten UI-Texte im Tutorial. Sie sollen Tasten-Inputs erwähnen (z.B. "Drücke RMB [Rechte Maustaste] für...", "LMB für..."). 
- **Dash-Mechanik:** Füge in der Tutorial-Beschreibung unbedingt hinzu, dass der Spieler mit der **Shift-Taste über Hindernisse dashen** kann.

### 2. UI & Kamera-Anpassungen
- **Minimap Zoom:** Bitte setze den Default-Wert für den Kartenzoom auf **1.60**.
- **Cooldown HUD:** Das Cooldown-UI unten rechts auf dem Bildschirm ist zu klein. Bitte vergrößere das HUD-Element (Scale/Size anpassen).

### 3. Gegner-Skalierung
- **Aufgabe:** Die Gegner "Mörser" und "Säure-Kanonen" sind zu groß. Bitte verkleinere das 3D-Modell (Scale) dieser beiden Gegner-Typen ein bisschen, damit sie besser ins Spiel passen.

### 4. Bugfix & Überarbeitung: Enemy ESP (Winter & Giselle)
Es gibt aktuell Probleme mit dem ESP-Indikator (Enemy Target/Highlight) bei den Charakteren Winter und Giselle.
- **Bug 1 (Mehrfaches ESP):** Wenn ein Gegner mehrfach getroffen wird (z.B. durch jeden einzelnen Schuss), entstehen teilweise mehrere ESP-Indikatoren auf demselben Gegner. 
- **Bug 2 (ESP bleibt):** Das ESP verschwindet nicht immer, wenn der Gegner stirbt.
- **Neue ESP-Logik (Singuläres Target):** Ich möchte das System vereinfachen. Es soll zu jedem Zeitpunkt im Spiel **nur exakt einen aktiven ESP-Indikator** geben. Dieser eine Indikator soll dynamisch von Gegner zu Gegner springen, je nachdem, welchen Gegner der Spieler gerade anvisiert hat bzw. auf welchen er schießt. Wenn der anvisierte Gegner stirbt, muss das ESP sofort verschwinden, bis ein neuer Gegner anvisiert wird.

Bitte zeige mir, welche Skripte für diese Änderungen angepasst werden müssen (vor allem das ESP-Targeting-Skript, Enemy-Prefabs und das UI/Tutorial-Manager-Skript) und stelle den entsprechenden Code bereit.
```

## User

gib mir das aktuelle character description wieder

## Assistant

Hier sind die aktuellen Charakter-Beschreibungen für das Tutorial, aktualisiert mit den neuen Anforderungen (Steuerung, Tasten-Erklärungen und Dash-Mechanik):

**1. Ningning (Start-Charakter)**
> *"Ningning ist eine Close-Range-Kämpferin. Nutze **LMB** (Linke Maustaste) für Nahkampfschläge und **RMB** (Rechte Maustaste) für Explosionen. Drücke **Shift**, um mit einem Dash über Hindernisse und Abgründe zu springen!"*

**2. Giselle (Nach dem 1. Treasure Room)**
> *"Giselle kämpft auf Distanz. Halte **LMB** gedrückt, um mit ihren 2 Waffen zu feuern (inklusive Auto-Aim). Nutze **RMB** für ihre Spezialfähigkeit. Vergiss nicht: Mit **Shift** kannst du über Hindernisse dashen!"*

**3. Karina (Nach dem 2. Treasure Room)**
> *"Karina ist eine [Füge hier ihren Kampfstil ein]. Drücke **LMB** für ihren Standard-Angriff und **RMB**, um [Füge hier ihre Spezialfähigkeit ein]. Nutze **Shift**, um schnell Angriffen oder Hindernissen auszuweichen."*

**4. Winter (Nach dem 3. Treasure Room)**
> *"Winter nutzt [Füge hier ihre Waffe ein]. Greife mit **LMB** an und blocke/ziele mit **RMB**. Auch sie kann mit **Shift** über Hindernisse dashen, um sich in Sicherheit zu bringen."*

Du kannst diese Texte entweder direkt so übernehmen und die Platzhalter bei Karina und Winter ausfüllen, oder sie als Inspiration für deinen Code nutzen!
