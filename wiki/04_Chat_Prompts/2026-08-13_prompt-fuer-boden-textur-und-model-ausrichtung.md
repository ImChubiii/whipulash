---
title: "Prompt für Boden-Textur und Model-Ausrichtung"
date: 2026-08-13
tags: [chatlog, prompt-log, whiplash, lemonade, thema/shader, thema/tooling, ki/antigravity]
ki_art: "antigravity"
---
# Prompt für Boden-Textur und Model-Ausrichtung

[Antigravity Session](file:///C:/Users/thvnh/.gemini/antigravity/brain/bbaff2bd-dd41-44ac-8439-238ebacf81e9/.system_generated/logs/transcript_full.jsonl)

## User

bitte mach ein prompt 

floor texture chess dunkler machen
model schaut statisch nach vorne was gut ist aber sollte bei angriff auf ein gegner zu dem gegner hindrehen

## Assistant

Hier ist ein ausformulierter Prompt, den du kopieren und für eine KI (wie Claude, ChatGPT oder GitHub Copilot) verwenden kannst. Ich habe ihn auf Englisch verfasst, da KI-Modelle beim Programmieren damit oft die besten Ergebnisse liefern, aber auch eine deutsche Version beigefügt.

### Option 1: Englischer Prompt (Empfohlen für beste Code-Ergebnisse)

```text
Please update the game logic and materials with the following changes:

1. **Floor Texture**: Make the color/brightness of the chessboard floor texture darker.
2. **Model Rotation Logic**: Currently, the character model looks statically forward, which is good and should remain the default behavior. However, please change the attack logic so that when the character attacks an enemy, the model smoothly rotates to face the targeted enemy. After the attack, it should return to its default forward-facing state.
```

### Option 2: Deutscher Prompt

```text
Bitte passe die Spiellogik und das Material wie folgt an:

1. **Boden-Textur**: Mache die Schachbrett-Textur des Bodens dunkler.
2. **Rotation des Models**: Aktuell schaut das Model statisch nach vorne. Das ist grundsätzlich gut und soll als Standardverhalten beibehalten werden. Bitte füge jedoch die Logik hinzu, dass sich das Model bei einem Angriff auf einen Gegner zu diesem Gegner hindreht. 
```

**Tipp:** Wenn du den Prompt verwendest, ist es oft hilfreich, den Namen der Skripte (z. B. `PlayerController.cs` oder `Enemy.js`) mit anzugeben oder den Code-Ausschnitt, der die aktuelle Rotation steuert, direkt mit in den Chat zu kopieren! Sag Bescheid, wenn ich dir direkt hier bei dem Code helfen soll.

## User

mein code ist bisher sehr unsauber und mit vielen notizen und fixes, kannst du ein prompt machen der beschreibt wie alles repariert und sauber gemachjt werden soll? und am besten auch irgendwie dsa die performance besser ist.

## Assistant

Hier ist ein strukturierter Prompt, den du nutzen kannst, um deinen Code von einer KI aufräumen und optimieren zu lassen. Auch hier gebe ich dir wieder eine englische und eine deutsche Version.

### Option 1: Englischer Prompt (Empfohlen für beste Ergebnisse)

```text
Here is my current code. It works, but it has become very messy over time. It contains a lot of quick fixes, debug notes, and unoptimized logic. 

Please act as a Senior Developer and refactor this code to make it clean, professional, and highly performant. 

Please apply the following improvements:
1. **Clean Code & Refactoring**: Reorganize the structure so it's easy to read and maintain. Apply meaningful naming conventions for variables and methods.
2. **Remove Clutter**: Delete obsolete notes, out-commented code blocks, and redundant debug statements. Keep only essential, helpful comments that explain *why* something is done.
3. **Resolve Quick Fixes**: Replace temporary "hacky" fixes with proper, robust solutions.
4. **Performance Optimization**: Optimize the logic for better performance. For example, avoid expensive operations in update loops, cache component references, and use efficient data structures.
5. **Keep Functionality**: Ensure that the core behavior of the code remains exactly the same as before.

Please provide the fully refactored code and a brief summary of the most important changes you made.

[INSERT YOUR CODE HERE]
```

### Option 2: Deutscher Prompt

```text
Hier ist mein aktueller Code. Er funktioniert, ist aber mit der Zeit sehr unsauber geworden. Er enthält viele schnelle Fixes, unnötige Notizen und unoptimierte Logik.

Bitte handle wie ein Senior Entwickler und refactore diesen Code, um ihn sauber, professionell und performant zu machen.

Bitte setze folgende Verbesserungen um:
1. **Clean Code & Refactoring**: Strukturiere den Code so, dass er leicht lesbar und wartbar ist. Verwende aussagekräftige Namen für Variablen und Methoden.
2. **Aufräumen**: Entferne veraltete Notizen, auskommentierten Code und unnötige Debug-Logs. Behalte nur die Kommentare, die wirklich wichtig sind und erklären, *warum* etwas passiert.
3. **Fixes reparieren**: Ersetze temporäre "Hacks" oder Notlösungen durch saubere, stabile Programmierpraktiken.
4. **Performance-Optimierung**: Optimiere die Logik für eine bessere Leistung. Vermeide z. B. rechenintensive Abfragen in Update-Schleifen, speichere Referenzen zwischen (Caching) und nutze effiziente Methoden.
5. **Funktionalität beibehalten**: Stelle sicher, dass sich das Kernverhalten des Codes im Spiel/Programm absolut nicht verändert.

Bitte gib mir den komplett überarbeiteten Code zurück sowie eine kurze Zusammenfassung der wichtigsten Änderungen.

[FÜGE HIER DEINEN CODE EIN]
```

**Zusatz-Tipp:** Wenn dein Code über mehrere Dateien verteilt ist, gib der KI am besten Datei für Datei, oder erkläre kurz den Zusammenhang zwischen den Skripten (z. B. "Das Skript X wird von Skript Y aufgerufen"). Das hilft der KI, die Performance über das gesamte Projekt hinweg besser zu verstehen!

## User

bitte schreib das so das es sehr wichtig ist und am besten am ganzen projekt stattfindet, auch die ordnerstrukturen und dateien richtig einordnen wenn es noch nicht gemacht wurde

## Assistant

Hier ist der angepasste Prompt. Er macht deutlich, dass es sich um eine **kritische und umfassende Überarbeitung des gesamten Projekts** handelt und fordert die KI auf, auch die Ordnerstruktur und Datei-Organisation in die Hand zu nehmen.

### Option 1: Englischer Prompt (Empfohlen)

```text
CRITICAL TASK: I need a complete, project-wide overhaul and refactoring of my current project. Over time, the codebase has become extremely messy, unoptimized, and filled with temporary fixes and unstructured files. 

Please act as a Lead Software Architect. Your task is to analyze, clean up, and optimize the ENTIRE project architecture, codebase, and file structure. This is highly important.

Please execute the following comprehensive plan:

1. **Project & Folder Structure**: Reorganize the entire directory structure. Create logical folders (e.g., Scripts, Materials, Textures, Prefabs/Components) and tell me exactly which files should be moved where to establish a professional, scalable architecture.
2. **Deep Code Refactoring**: Rewrite and restructure the code across all files. Apply strict Clean Code principles, design patterns where appropriate, and consistent naming conventions.
3. **Remove All Clutter**: Ruthlessly delete all temporary fixes, commented-out dead code, obsolete notes, and redundant debug logs. Leave only high-level architectural comments.
4. **Maximum Performance Optimization**: Analyze the interaction between different scripts and optimize the overall performance. Eliminate expensive operations in loops, implement proper caching, and use efficient data structures globally.
5. **Robust Architecture**: Replace "hacky" workarounds with solid, best-practice solutions without changing the core functionality of the application.

**How we will work:**
First, provide a clear, hierarchical overview of the NEW recommended folder structure. 
Then, go through the major files/systems one by one and provide the fully refactored, optimized code for each.

Here are the files in my current project:
[LIST YOUR FILES / PASTE YOUR CODE HERE]
```

### Option 2: Deutscher Prompt

```text
KRITISCHE AUFGABE: Ich benötige eine komplette, projektweite Überarbeitung und ein Refactoring meines aktuellen Projekts. Die Codebasis und die Dateien sind mit der Zeit extrem unstrukturiert, unoptimiert und voller Notlösungen geworden.

Bitte handle wie ein Lead Software Architect. Deine Aufgabe ist es, die GESAMTE Projektarchitektur, den Code und die Ordnerstruktur zu analysieren, aufzuräumen und zu optimieren. Das hat höchste Priorität.

Bitte setze diesen umfassenden Plan um:

1. **Projekt- & Ordnerstruktur**: Organisiere die gesamte Dateistruktur neu. Erstelle sinnvolle Ordner (z. B. Scripts, Materials, Textures, Prefabs/Components) und sag mir genau, welche Datei wohin verschoben werden muss, um eine professionelle und skalierbare Architektur zu schaffen.
2. **Tiefgreifendes Code-Refactoring**: Überarbeite und restrukturiere den Code in allen Dateien. Wende strikte Clean-Code-Prinzipien, sinnvolle Design Patterns und einheitliche Benennungen an.
3. **Komplettes Aufräumen**: Lösche rigoros alle temporären Fixes, auskommentierten toten Code, veraltete Notizen und überflüssige Debug-Logs. Behalte nur Kommentare bei, die wichtige Architektur-Entscheidungen erklären.
4. **Maximale Performance-Optimierung**: Optimiere die Leistung über das gesamte Projekt hinweg. Vermeide teure Berechnungen in Update-Schleifen, setze Caching ein und nutze global effiziente Datenstrukturen.
5. **Stabile Architektur**: Ersetze alle "Hacks" und schnellen Notlösungen durch solide, beständige Best-Practice-Methoden, ohne die eigentliche Funktionalität des Programms zu verändern.

**Unser Vorgehen:**
Gib mir bitte ZUERST eine übersichtliche Baumstruktur der NEUEN, empfohlenen Ordner- und Dateistruktur.
Gehe danach die wichtigsten Dateien und Systeme nacheinander durch und gib mir den komplett überarbeiteten, sauberen Code für jede Datei.

Hier sind die Dateien meines aktuellen Projekts:
[LISTE DEINE DATEIEN AUF / FÜGE DEINEN CODE EIN]
```

**Wie du das am besten nutzt:**
Wenn das Projekt sehr groß ist, ist es oft schwer, alles auf einmal in den Chat zu kopieren. Du kannst der KI am Ende des Prompts auch sagen: 
*"Ich werde dir jetzt nach und nach meine Dateien schicken. Antworte auf jede Datei zunächst nur mit 'Verstanden', bis ich 'Fertig' sage. Beginne erst danach mit der Analyse und der neuen Ordnerstruktur!"*

## User

nächster prompt

character modell soll leicht in die richtung tilgen wenn man dahin geht also w drücken tilgt den spieler ganz leicht nach vorne usw. bei loslassen wird es wieder resettet

## Assistant

Hier ist der nächste Prompt für dein Movement-Feature. Ich habe hinzugefügt, dass die Bewegung **weich (smooth)** ablaufen soll (mit Lerp oder Interpolation), da ein plötzliches "Einrasten" in die Neigung bei 3D-Modellen meistens sehr unnatürlich aussieht.

### Option 1: Englischer Prompt (Empfohlen)

```text
Please add a dynamic tilt/lean effect to the character movement logic. 

The behavior should be as follows:
1. **Directional Tilt**: When the player moves, the character model should slightly tilt into the direction of movement. For example, holding 'W' should tilt the model slightly forward, holding 'A' tilts it slightly to the left, etc.
2. **Smooth Interpolation**: The transition into the tilt must be smooth (e.g., using Lerp or Slerp) so it feels natural and not snappy.
3. **Reset on Release**: When the movement keys are released and the player comes to a stop, the character model must smoothly rotate back to its upright default position (0 tilt).

Please provide the updated script that handles this logic. Keep the tilt angle configurable via a variable so I can adjust the strength of the lean in the inspector/settings.
```

### Option 2: Deutscher Prompt

```text
Bitte füge der Bewegungslogik des Charakters einen dynamischen Neigungs-Effekt (Tilt/Lean) hinzu.

Das Verhalten soll wie folgt sein:
1. **Neigung in Bewegungsrichtung**: Wenn sich der Spieler bewegt, soll sich das Charakter-Model leicht in die jeweilige Bewegungsrichtung neigen. Zum Beispiel: 'W' drücken neigt das Model leicht nach vorne, 'A' drückt neigt es leicht nach links usw.
2. **Weicher Übergang (Smoothness)**: Die Neigung darf nicht abrupt passieren, sondern muss fließend sein (z. B. über Lerp oder Slerp berechnet), damit es natürlich aussieht.
3. **Reset beim Loslassen**: Sobald die Bewegungstasten losgelassen werden, muss sich das Model wieder weich und fließend in die aufrechte Standardposition (0 Neigung) zurückdrehen.

Bitte gib mir das angepasste Skript. Mache den maximalen Neigungswinkel am besten als Variable konfigurierbar, damit ich die Stärke des Effekts im Inspector/in den Settings selbst anpassen kann.
``` 

**Tipp für die Umsetzung:** Wenn du das Skript von der KI bekommst, achte darauf, dass die Neigung (Tilt) am besten nur auf das **visuelle 3D-Modell** (das Child-Objekt) angewendet wird und nicht auf den Haupt-Player-Controller (die Capsule/den Rigidbody), da sonst deine Physik oder Kollisionen verrücktspielen könnten!

## User

nächster prompt 

vorne und hinten ist gut aber nach rechts sieht aus wie wenn der nach links machen würde und nach links wie nach rechts. also bitte einmal switchen bitte, kannst du noch ein ganz ganz leichten kamera tilg machen wie bei den model tilg? aber nur sehr leicht

## Assistant

Hier ist der nächste Prompt. Er behebt das Problem mit den vertauschten Achsen und fügt den neuen, subtilen Kamera-Neigungseffekt hinzu.

### Option 1: Englischer Prompt (Empfohlen)

```text
The character tilt logic works, but there is an issue: the forward and backward tilt is correct, but the left and right tilts are inverted (when moving right, it tilts left, and vice versa). Please invert the left/right axis logic so it leans in the correct direction.

Additionally, I would like to add a similar, but very subtle, tilt effect to the Camera. 
When the player moves, the camera should also slightly tilt (roll) into the direction of movement. 
1. Make sure this camera tilt is very subtle so it doesn't cause motion sickness.
2. Like the model, it needs to smoothly transition (Lerp) into the tilt and smoothly reset back to 0 when the movement stops.
3. Please provide variables to configure the camera tilt intensity separately from the model tilt intensity.

Please provide the updated code to handle both the corrected model tilt and the new camera tilt.
```

### Option 2: Deutscher Prompt

```text
Das Neigen des Charakters funktioniert schon gut, aber es gibt ein Problem: Die Neigung nach vorne und hinten stimmt, aber links und rechts sind vertauscht (wenn ich nach rechts laufe, neigt er sich nach links und umgekehrt). Bitte tausche die Logik für die Links/Rechts-Achse einmal um, damit die Richtung stimmt.

Zusätzlich möchte ich einen ähnlichen, aber sehr leichten Neigungseffekt für die Kamera hinzufügen.
Wenn sich der Spieler bewegt, soll sich die Kamera ebenfalls ganz leicht in die Bewegungsrichtung neigen (Kamera-Roll).
1. Stelle sicher, dass die Kamera-Neigung nur sehr subtil ist, damit sie nicht störend wirkt.
2. Genau wie beim Model muss der Übergang weich sein (Lerp) und sich beim Loslassen der Tasten wieder weich auf 0 zurücksetzen.
3. Bitte füge eigene Variablen für die Kamera-Neigung hinzu, damit ich die Stärke unabhängig von der Model-Neigung einstellen kann.

Bitte gib mir den aktualisierten Code für das korrigierte Model-Tilt und das neue Kamera-Tilt.
```

## User

beim benutzen der abilities wird motion blur deckkraft hoch gemacht, das soll so nicht sein außer bei karina. kannst du die secondary rmb von ningning noch größer machen und 3d mäßig also 2 asset die dann in 90 grad sind so wenn du checkst

## Assistant

Hier ist der nächste Prompt für dich. Den Teil mit dem "3D-mäßig in 90 Grad" habe ich für die KI etwas technischer formuliert (man nennt diesen Trick in der Spieleentwicklung "Cross-Quad" oder "Billboard-Cross"). So weiß die KI sofort ganz genau, was gemeint ist!

### Option 1: Englischer Prompt (Empfohlen)

```text
I have two issues with the current abilities that need to be fixed:

1. **Motion Blur Logic**: Currently, using any ability increases the motion blur intensity/opacity. This is incorrect. The motion blur effect should ONLY trigger when the character "Karina" uses her ability. For all other character, the motion blur should remain unchanged. Please update the logic to check the character type before applying the blur.

2. **Ningning's Secondary Ability (RMB)**: I need to update the visual for Ningning's right-mouse-button ability. 
   - First, make the overall scale/size of the projectile or effect larger.
   - Second, make it look 3D using a "Cross-Quad" approach. Instead of a single flat 2D sprite, please use two identical planes/assets intersecting each other at a 90-degree angle (like a cross or an X). 

Please provide the updated scripts or instructions on how to set this up correctly in the engine.
```

### Option 2: Deutscher Prompt

```text
Ich habe zwei Probleme mit den aktuellen Fähigkeiten, die behoben werden müssen:

1. **Motion Blur Logik**: Aktuell wird beim Benutzen von Fähigkeiten die Deckkraft/Intensität des Motion Blurs hochgesetzt. Das soll nicht so sein. Der Motion Blur Effekt darf NUR aktiviert werden, wenn der Charakter "Karina" ihre Fähigkeit nutzt. Bei allen anderen Charakteren soll der Blur unverändert bleiben. Bitte passe die Logik an, sodass vorher geprüft wird, welcher Charakter aktiv ist.

2. **Ningnings Secondary Ability (RMB)**: Die Visuals von Ningnings Rechtsklick-Fähigkeit müssen angepasst werden.
   - Erstens: Mache die Fähigkeit/das Projektil insgesamt größer.
   - Zweitens: Es soll dreidimensionaler wirken. Nutze dafür die "Cross-Quad"-Methode: Anstatt einer einzelnen flachen 2D-Ebene (Sprite), verwende bitte 2 Assets/Planes, die im 90-Grad-Winkel ineinandergesteckt sind (wie ein Kreuz oder ein X).

Bitte gib mir das angepasste Skript und eine kurze Anleitung, wie ich die gekreuzten Assets in der Engine richtig einstelle.
```

## User

Was genau soll an der Engine eingestellt werden?

> 1. Godot-Projekteinstellungen
     z.B. Rendering (Mobile-Renderer, PSX-Look), Physik (Jolt), Input Map, Display/Fenster-Einstellungen in project.godot
  2. Export-/Build-Einstellungen
     export_presets.cfg, Windows-Desktop-Export, o.ä.
  3. Etwas anderes
     Beschreibe kurz, worum es geht - z.B. ein bestimmtes System/Script mit "Engine" im Namen, oder etwas Konkretes, das gerade nicht richtig funktioniert.
> 4. Type something.

## Assistant

Ah, ich sehe, du benutzt Godot (oder einen KI-Assistenten, der speziell auf Godot ausgelegt ist)! 

Wenn dieses Menü aufpoppt, wähle am besten **"3. Etwas anderes"** oder **"4. Type something"** und antworte der KI folgendes:

> "Es geht um die Node-Struktur in der Szene für Ningnings Secondary Ability (das Projektil). Ich brauche eine Erklärung, wie ich die zwei gekreuzten Assets (z.B. zwei Sprite3D Nodes oder MeshInstance3D) im Scene Tree anordne und im Inspector um 90 Grad zueinander drehe, damit sie diesen 3D-Kreuz-Effekt bilden."

**Hintergrund:**
Der Teil mit "in der Engine einstellen" aus meinem Prompt bezog sich nicht auf die generellen Projekt-Einstellungen (wie Rendering oder Physik), sondern ganz simpel darauf, wie du die Nodes im Editor für diese spezielle Fähigkeit anordnest. Du brauchst in deiner Projektil-Szene einfach zwei `Sprite3D` (oder `MeshInstance3D` mit einer Plane), wovon du eines auf der Y-Achse um 90 Grad drehst, damit sie ein "X" bilden. Die KI soll dir nur kurz erklären, wie der Scene Tree dafür aussehen muss.

## User

bitte visuell rmb von ningning weiter nach vorne machen, ist zurzeit zu sehr im character drinne und
  passe die hitbox dann damit an. und mehr damage, rmb 50 dmg

## Assistant

Hier ist der nächste Prompt, den du kopieren kannst, um diese Änderungen an Ningnings Fähigkeit umzusetzen:

### Option 1: Englischer Prompt (Empfohlen)

```text
Please make the following adjustments to Ningning's secondary ability (RMB):

1. **Spawn Position**: Visually, the ability spawns too far inside the character model. Please offset the spawn position further forward (in the direction the character is facing) so it appears clearly in front of the character.
2. **Hitbox Adjustment**: Adjust the hitbox (CollisionShape) position so that it perfectly aligns with the new, shifted visual position.
3. **Damage Increase**: Increase the damage of this RMB ability to 50.

Please provide the updated code for the spawn logic and the damage values, and let me know if I need to adjust the position offset in the Scene/Inspector as well.
```

### Option 2: Deutscher Prompt

```text
Bitte nimm die folgenden Anpassungen an Ningnings Rechtsklick-Fähigkeit (RMB) vor:

1. **Spawn-Position**: Visuell spawnt die Fähigkeit aktuell zu weit im Charakter-Model drinnen. Bitte verschiebe die Spawn-Position weiter nach vorne (in Blickrichtung), damit der Effekt klar vor dem Charakter entsteht.
2. **Hitbox anpassen**: Passe die Position der Hitbox (CollisionShape) entsprechend an, sodass sie exakt mit der neuen visuellen Position übereinstimmt.
3. **Schaden erhöhen**: Erhöhe den Schaden dieser RMB-Fähigkeit auf 50.

Bitte gib mir den aktualisierten Code für die Spawn-Logik und den Schadenwert. Sag mir außerdem kurz Bescheid, falls ich den Positions-Offset (die Entfernung nach vorne) auch noch manuell im Inspector/Scene-Tree eintragen muss.
```

## User

ne das ist visuell gerade hinter ningning und das sikk bisschen tiefer sein.

## Assistant

Alles klar, verstanden! Dann müssen wir den Z-Offset (Vorne/Hinten) und den Y-Offset (Höhe) anpassen, damit das Projektil nicht mehr hinter ihr spawnt und etwas tiefer liegt.

Hier ist der korrigierte Prompt:

### Option 1: Englischer Prompt (Empfohlen)

```text
Please make the following adjustments to Ningning's secondary ability (RMB):

1. **Fix Spawn Position (Forward & Lower)**: Visually, the ability is currently spawning behind Ningning. Please offset the spawn position forward so it spawns in front of her. Also, lower the spawn height slightly so it sits a bit closer to the ground.
2. **Hitbox Adjustment**: Adjust the hitbox (CollisionShape) position so that it perfectly aligns with this new, corrected visual position (forward and lower).
3. **Damage Increase**: Increase the damage of this RMB ability to 50.

Please provide the updated code for the spawn logic, taking the forward and downward offsets into account. Let me know if I need to adjust these offsets directly in the Inspector.
```

### Option 2: Deutscher Prompt

```text
Bitte nimm die folgenden Anpassungen an Ningnings Rechtsklick-Fähigkeit (RMB) vor:

1. **Spawn-Position korrigieren (Weiter vor & tiefer)**: Visuell spawnt die Fähigkeit aktuell hinter Ningning. Bitte verschiebe die Spawn-Position nach vorne, damit sie vor ihr entsteht. Setze die Position außerdem ein Stück tiefer, sodass der Effekt weiter unten ist.
2. **Hitbox anpassen**: Passe die Position der Hitbox (CollisionShape) entsprechend an, sodass sie exakt mit dieser neuen visuellen Position (weiter vorne und tiefer) übereinstimmt.
3. **Schaden erhöhen**: Erhöhe den Schaden dieser RMB-Fähigkeit auf 50.

Bitte gib mir den aktualisierten Code für die Spawn-Logik, der die Verschiebungen nach vorne und unten berücksichtigt. Sag mir außerdem Bescheid, falls ich diese Werte als Offset im Inspector eintragen muss.
```

## User

und kannst du fragen warum alles immer umgedreht ist wenn man irgendwas macht? also zb chartacter models import sind dann in verkehrter richtung, wenn man irgendwas nach "vorne" macht ist es in echt nach hinten

## Assistant

Das ist ein sehr bekanntes Problem in der Spieleentwicklung! Das liegt meistens an den **unterschiedlichen Koordinatensystemen** der Programme. 
Zum Beispiel nutzt Blender ein System, bei dem "+Y" nach oben zeigt (oder +Z, je nach Einstellung) und "-Y" nach vorne, während Godot oder Unity oft "+Z" oder "-Z" als "Vorne" definieren (Right-Handed vs. Left-Handed Coordinate Systems). Wenn das beim Exportieren nicht angeglichen wird, ist in der Engine alles um 180 Grad gedreht.

Hier ist der angepasste Prompt, der die Änderungen von eben enthält **und** die KI bittet, das Problem mit den verdrehten Achsen endgültig zu lösen:

### Option 1: Englischer Prompt (Empfohlen)

```text
Please make the following adjustments to Ningning's secondary ability (RMB):
1. **Fix Spawn Position (Forward & Lower)**: Visually, the ability is currently spawning behind Ningning. Please offset the spawn position forward so it spawns in front of her. Also, lower the spawn height slightly so it sits a bit closer to the ground.
2. **Hitbox Adjustment**: Adjust the hitbox (CollisionShape) position so that it perfectly aligns with this new, corrected visual position.
3. **Damage Increase**: Increase the damage of this RMB ability to 50.

**Important Question regarding Global Axis Inversion:**
I have noticed a persistent issue in my project: everything seems to be inverted. When I import character models, they face the wrong way. When I code something to move "forward", it actually moves "backward" in the game world. 
Why is this happening, and how can I fix this globally once and for all? Is there a specific export setting from my 3D software (like Blender) I should use, or a wrapper-node setup I need to apply to all my character so that the engine's "forward" aligns with the models' "forward"?
```

### Option 2: Deutscher Prompt

```text
Bitte nimm die folgenden Anpassungen an Ningnings Rechtsklick-Fähigkeit (RMB) vor:
1. **Spawn-Position korrigieren (Weiter vor & tiefer)**: Visuell spawnt die Fähigkeit aktuell hinter Ningning. Bitte verschiebe die Spawn-Position nach vorne, damit sie vor ihr entsteht. Setze die Position außerdem ein Stück tiefer, sodass der Effekt weiter unten ist.
2. **Hitbox anpassen**: Passe die Position der Hitbox (CollisionShape) entsprechend an, sodass sie exakt mit dieser neuen visuellen Position übereinstimmt.
3. **Schaden erhöhen**: Erhöhe den Schaden dieser RMB-Fähigkeit auf 50.

**Wichtige Frage zu verdrehten Achsen im Projekt:**
Mir ist ein ständiges Problem in meinem Projekt aufgefallen: Alles scheint spiegelverkehrt oder um 180 Grad gedreht zu sein. Wenn ich Charakter-Modelle importiere, schauen sie in die falsche Richtung. Wenn ich per Code etwas nach "vorne" bewege, bewegt es sich im Spiel nach "hinten". 
Woran liegt das und wie kann ich das global und endgültig beheben? Gibt es bestimmte Export-Einstellungen für mein 3D-Programm (z. B. Blender), die ich nutzen muss, oder sollte ich ein spezielles Node-Setup (Root-Wrapper) für meine Charaktere verwenden, damit das "Vorne" der Engine mit dem "Vorne" der Modelle übereinstimmt?
```
