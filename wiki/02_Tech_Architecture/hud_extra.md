---
script_path: scripts/hud_extra.gd
autoload_name: HudExtra
tags: [architecture, autoload]
---

# hud_extra.gd

Autoload (`HudExtra`). Baut heute nur noch einen einzigen `CanvasLayer` mit
dem `ResetOverlay` (Vollbild-Abblendung beim Halten von `[R]`).

## Was sich geaendert hat

Frueher baute dieses Autoload auch das Stats-Panel und die Item-Anzeige und
haengte sie in einen eigenen, laufzeit-konstruierten `CanvasLayer`. Beide
sitzen inzwischen als echte Nodes direkt in `hud.tscn`
(`BottomLeft/StatsPanel`, `BottomLeft/ItemBar`).

**Warum der Umzug richtig ist:** Zwei getrennte HUD-Systeme bedeuteten zwei
Layouts, zwei Sichtbarkeitslogiken und zwei Stellen, an denen man nach einem
verrutschten Element sucht. Ein Element, das aussieht und sich verhaelt wie
HUD, gehoert in die HUD-Szene — dort ist es im Editor sichtbar, verschiebbar,
und der Abstand zum Bildrand muss nicht als Konstante im Script gepflegt
werden.

**Preis des Umzugs (bewusst in Kauf genommen):** Szenen ohne `hud.tscn` —
also reine Testlevel — haben seitdem kein Stats-Panel und keine Item-Leiste
mehr. Genau dafuer existierte dieses Autoload urspruenglich. Wer beides im
Testlevel braucht, zieht `hud.tscn` dort einmal manuell als Kind-Szene hinein.

`treasure_pedestal.gd` sucht das Item-Beschreibungs-HUD entsprechend nicht
mehr ueber einen festen Autoload-Pfad, sondern ueber eine Gruppe
(`ITEM_HUD_GROUP`) — ein Pfad wie `/root/HudExtra/...` haette sich bei der
Umstellung stillschweigend in `null` verwandelt.

## Warum das Reset-Overlay hierbleibt

Das Reset-Overlay ist kein HUD-Element im engeren Sinn, sondern eine
Vollbild-Abdunklung, die beim Halten von `[R]` das komplette Spiel verdecken
muss — inklusive HUD, Pause-Menue und allem anderen. Dafuer braucht es einen
eigenen, sehr hohen `CanvasLayer` (`OVERLAY_LAYER = 128`, bewusst ueber
Pause-/Death-Screen, die typischerweise bei 100+ liegen) und
`PROCESS_MODE_ALWAYS`. In `hud.tscn` selbst wuerde es zwangslaeufig unter dem
HUD haengen und beim Ausblenden des HUD mitverschwinden.

## API

`set_overlay_enabled(enabled: bool)` schaltet Sichtbarkeit und Input-
Verarbeitung des Overlays gemeinsam ab/an — z.B. fuer Screenshots oder
Cutscenes, in denen ein versehentlich gehaltenes `[R]` nicht abdunkeln soll.

## Verwandt

- [[run_restart]] — der eigentliche Aufraeum-/Reload-Ablauf, den
  `reset_overlay.gd` nach Ablauf der Haltezeit anstoesst.

## Erwaehnt in DevLogs

- [[2026-07-26_161c399_feat_stat-system_loot-drops_bomben_items_und_game_]]
- [[2026-07-26_ec9ce70_feat_stat-system_loot-drops_bomben_items_und_game_]]
- [[2026-07-27_0c0e515_feat_treasure_room_items_hud_overhaul_balancing_mu]]
- [[2026-07-27_f88829f_feat_treasure_room_items_hud_overhaul_balancing_mu]]
