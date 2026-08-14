---
script_path: scripts/game_juice.gd
autoload_name: Juice
tags: [architecture, autoload]
---

# game_juice.gd

Autoload (`Juice`). Buendelt Hit-Stop/Freeze-Frames und leitet Kamera-Shake
an den Spieler weiter — die beiden billigsten, wirksamsten "Game Feel"-
Verstaerker fuer schwere Treffer: kein zusaetzliches VFX, keine Animation,
kein Sound noetig, nur ein kurzer Zeit-Ruck.

## Hit-Stop ueber `Engine.time_scale`

Bei einem Treffer wird `Engine.time_scale` fuer 0.03–0.08s fast auf 0
gezogen (`FROZEN_TIME_SCALE = 0.02`, bewusst NICHT exakt 0.0 — bei echter 0.0
stehen auch alle Partikel und Tweens komplett still, was den Frame "tot"
wirken laesst statt wie ein bewusster Effekt). Drei Voreinstellungen decken
die Wuchtklassen ab: `DURATION_LIGHT = 0.03s` (`hit_stop_light()`, u.a.
kritische Treffer in `primary_hitbox.gd`), `DURATION_HEAVY = 0.06s`
(`hit_stop_heavy()`), `DURATION_EXPLOSION = 0.08s` (`hit_stop_explosion()`).

## Zwei bewusst geloeste Fallstricke

1. **Der eigene Countdown darf nicht zeitskaliert laufen.** Waere der
   Rueckstell-Timer selbst von `time_scale` betroffen, wuerde er bei
   `time_scale = 0.02` ebenfalls fast einfrieren und das Spiel bliebe
   praktisch fuer immer im Hit-Stop stecken. Deshalb zaehlt `_process()`
   NICHT ueber `delta` (das mit `time_scale` schrumpft), sondern ueber
   echte Systemzeit (`Time.get_ticks_usec()`, `_last_ticks`). Der erste
   Frame nach Start wird zusaetzlich auf `real_delta <= 0.1` gedeckelt, damit
   ein Ladehaenger den Countdown nicht in einem Rutsch durchrauscht.
2. **Ueberlappende Treffer stapeln sich nicht.** Trifft waehrend eines
   laufenden Hit-Stops ein zweiter Treffer ein, wird die Dauer NICHT addiert
   (sonst wuerde eine schnelle Combo — laut Kommentar in `item_behaviours.gd`
   bei Karina bis zu 10x/Sekunde — das Spiel sekundenlang einfrieren),
   sondern nur um die HALBE neue Dauer verlaengert (`duration * 0.5`) und
   hart bei `max_hit_stop_duration = 0.12s` gedeckelt.

`process_mode = Node.PROCESS_MODE_ALWAYS` sorgt dafuer, dass das Autoload
selbst weiterlaeuft, auch wenn der Rest des Baums pausiert oder
zeitskaliert ist.

## Pause- und Restart-Interaktion

Ein laufender Hit-Stop wird bei `get_tree().paused` NICHT gestartet
(`hit_stop()` prueft `paused` und bricht fruehzeitig ab) — sonst wuerde ein
Treffer kurz vor dem Pausieren beim Entpausieren einen falschen
`time_scale` hinterlassen. `cancel()` raeumt sofort auf (setzt `time_scale`
auf den vor dem Hit-Stop gespeicherten Wert `_scale_before` zurueck) und wird
gebraucht, wann immer die Szene unabhaengig vom eigenen Countdown wechselt:
`run_restart.gd` ruft es vor jedem `reload_current_scene()` auf, `pause_menu.gd`
dokumentiert im eigenen Kopfkommentar einen historischen Bug, bei dem ein
fehlender `Juice.cancel()`-Aufruf einen laufenden Hit-Stop ueberleben liess.

## Shake-Weiterleitung

`shake(amount)` kennt den Spieler nicht direkt — Bomben, Explosionen und
Umgebungsereignisse muessten ihn sonst erst suchen. Stattdessen laeuft es
ueber die Gruppe `"player"` (dieselbe Gruppe, die auch `SettingsManager`
verwendet) und ruft, falls vorhanden, `shake_camera()` auf jedem Mitglied
auf. `impact(shake_amount, stop_duration)` ist die Kombi fuer schwere
Treffer: erst `hit_stop()`, dann `shake()`.

## `hit_stop_enabled`

Global abschaltbar — vorgesehen fuer Barrierefreiheit oder
Speedrun-Puristen, denen Freeze-Frames die Eingabe-Reaktionszeit verzerren
wuerden.

## Verwendung im Projekt

`primary_hitbox.gd` loest bei jedem Spieler-Treffer `hit_stop_light()` aus;
`combat_ningning.gd`/`combat_giselle.gd` rufen `impact()` fuer ihre
Signature-Treffer; `bomb.gd` nutzt `hit_stop(DURATION_EXPLOSION)` +
starken Shake bei der Detonation; `mortar_bot.gd`/`dive_bomber.gd`/
`magnet_core.gd` ([[custom_enemy_base]]-Subklassen) schuetteln die Kamera bei
Einschlag; `item_behaviours.gd` ist mit Abstand der groesste Aufrufer (Dutzende
`Juice.shake()`/`Juice.hit_stop()`-Stellen fuer Item-Effekte); auch
`character_pedestal.gd`/`treasure_pedestal.gd` nutzen einen leichten
Hit-Stop+Shake als Auswahl-Feedback.

## Verwandt

- [[vfx_manager]] — beide Autoloads werden meist aus denselben Treffer-/
  Impact-Stellen heraus gemeinsam ausgeloest (VFX fuer das Auge, Hit-Stop/
  Shake fuer das Gefuehl), sind aber vollkommen unabhaengig voneinander.
- [[combat_base]] — Dash-Treffer und Combo-System liegen in der Naehe der
  Stellen, die `Juice` ausloesen (u.a. ueber `primary_hitbox.gd`).
- [[custom_enemy_base]] — mehrere der sechs neuen Gegnertypen nutzen
  `Juice.shake()` bei ihrem Angriffs-/Einschlagsverhalten.

## Erwaehnt in DevLogs

- [[2026-07-26_161c399_feat_stat-system_loot-drops_bomben_items_und_game_]]
- [[2026-07-26_ec9ce70_feat_stat-system_loot-drops_bomben_items_und_game_]]
- [[2026-08-01_5d2ca05_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
- [[2026-08-01_3bbac00_fixrestartdoorsitemsrooms_neustart-kette_tuer-inte]]
- [[2026-08-12_f23c551_feat_combat_mechanics_weighted_item_drops_and_ui_t]]
