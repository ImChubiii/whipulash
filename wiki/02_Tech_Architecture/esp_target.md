---
script_path: scripts/vfx/esp_target.gd
autoload_name: EspTarget
tags: [architecture, autoload]
---

# esp_target.gd

Autoload (`EspTarget`). Projektweiter Singular-Indikator ("ESP"-Kasten +
Label3D-Raute) fuer das aktuell anvisierte Ziel von Winters und Giselles
Auto-Target-Faehigkeiten.

## Warum ein einzelner Autoload statt Zustand pro Waffe

Rueckmeldung (2026-08-13): "ESP bei Winter/Giselle: manchmal mehrere Kaesten
auf demselben Gegner, verschwindet nicht immer beim Tod." Vorher hielt jedes
Waffensystem seinen eigenen `Label3D` + `EnemyEspBox` — `combat_giselle.gd`
fuer Uzi- und Sniper-ESP getrennt, `combat_winter.gd` fuer Laser-ESP und
zusaetzlich einen ESP-Kasten pro Plasma-Bolt. Zwei gleichzeitig aktive Waffen
(z.B. Winters gehaltener Laser plus ihr Plasma-Primary) oder mehrere schnelle
Treffer auf denselben Gegner konnten dadurch mehrere Kaesten gleichzeitig
erzeugen. Ein Kasten verschwand zudem nur, wenn genau die Waffe, die ihn
erzeugt hatte, den Tod selbst bemerkte — teils erst beim naechsten Schuss,
nicht sofort.

Dieses Autoload ersetzt den verteilten Zustand durch genau ein `Label3D` +
eine `EnemyEspBox` im ganzen Spiel. Jedes Waffensystem meldet per
`acquire(target, color)` sein gerade anvisiertes Ziel; der zuletzt
aufgerufene Aufruf "gewinnt" den Indikator. `_process()` prueft **jeden
Frame** die Lebendigkeit des aktuellen Ziels — unabhaengig davon, welche
Waffe gerade feuert. Das ist der eigentliche Fix fuer "verschwindet nicht
immer beim Tod": die Pruefung haengt nicht mehr am Feuer-Rhythmus einer
einzelnen Waffe.

## API-Vertrag

- `acquire(target, color)` — baut nur neu, wenn sich das Ziel tatsaechlich
  aendert. Ein Aufruf mit demselben Ziel in jedem Frame (z.B. Winters
  gehaltener Laser) rebuilded also nichts, nur `_reposition()` haelt die
  Position aktuell.
- `release(target)` — raeumt nur auf, wenn `target` auch tatsaechlich das
  gerade angezeigte Ziel ist. Ein Waffensystem ohne eigenes Ziel mehr (z.B.
  losgelassene Maustaste) kann so nie versehentlich den Indikator eines
  anderen, noch aktiven Waffensystems mitreissen.
- `flash(target)` — kurzer Aufleucht-Puls bei einem tatsaechlichen Treffer;
  no-op, falls `target` gerade nicht der angezeigte Indikator ist (z.B.
  Winters Plasma trifft ein Zweitziel ohne eigenen Kasten).

Lebendigkeits-Check (`_is_alive`) laeuft ueber `find_child("Health", true,
false)` — derselbe Health-Kindnoten-Vertrag, den auch Hitboxen und Items
voraussetzen (siehe Projekt-Architektur: Gruppe `"enemies"`, Layer 4,
Kind-Node `"Health"`).

## Verwandt

- [[combat_base]] — Basis der Charakter-Kampf-Systeme, deren Auto-Target-
  Faehigkeiten (Winter, Giselle) diesen Indikator ansteuern.

## Erwaehnt in DevLogs

- [[2026-08-12_0484ccd_featfix_umfangreiches_gameplay-_ui-_balancing-over]]
