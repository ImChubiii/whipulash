---
script_path: scripts/party_manager.gd
autoload_name: PartyManager
tags: [architecture, autoload]
---

# party_manager.gd

Autoload (`PartyManager`). Verwaltet bis zu 4 `CharacterData` in der Party.
Es existiert IMMER genau EIN aktiver `CharacterBody3D` im Level — beim
Wechsel wird die aktuelle Instanz entfernt und die neue an derselben Stelle
neu instanziert (Position, Kamera-Ausrichtung und HP werden uebernommen).

## Last-Stand-System

Stirbt der aktive Charakter und lebt noch mindestens ein weiteres
Party-Mitglied, uebernimmt dieses automatisch. Als Strafe wird die HP der
**gesamten restlichen Party** auf `LAST_STAND_HP_FRACTION` (0.20 = 20 %)
ihrer jeweiligen Maximal-HP gedeckelt — nicht nur die des Nachrueckers. Das
`party_wiped`-Signal (und damit der Death-Screen) feuert erst, wenn die
gesamte Party down ist.

Der Nachruecker bekommt kurz Schonzeit (`SWITCH_INVULN_DURATION = 2.0s`):
ohne das koennte derselbe Hitbox-Treffer, der den vorigen Charakter
umgebracht hat, im selben Frame auch den frisch eingewechselten erwischen.

## Switch-Cooldown

Wechselt man von einem Charakter WEG, bekommt GENAU DIESER (nicht der neu
aktivierte) einen Cooldown von `SWITCH_COOLDOWN_DURATION = 10.0s`, bevor man
wieder zu ihm wechseln kann.

## Bekannter Bug (behoben): "Restart-Button und [R] gehen nicht"

**Root Cause:** Das Autoload ueberlebt `get_tree().reload_current_scene()`.
Die Szene darunter wird komplett abgebaut — inklusive der Spieler-Instanz,
auf die `player` zeigt. Ein freigegebenes Object wird in GDScript aber
NICHT automatisch auf `null` gesetzt: die Variable haelt weiter den alten
Zeiger. Damit ist `player == null` → `false`, aber `is_instance_valid(player)`
→ `false` — ein Widerspruch, an dem der komplette Spawn-Pfad haengenblieb
(`register_spawn_point()`, `setup_party()`, `_spawn_active_character()`
pruefen alle auf `player == null`).

Nach jedem Neustart hielt `PartyManager` also eine "Leiche", hielt sich fuer
bereits bespielt und spawnte keinen neuen Charakter — sichtbar als "Bild baut
sich neu auf, aber man kann sich nicht bewegen".

**Fix:** Jede Lebend-Pruefung laeuft jetzt ueber `has_player()` bzw.
`is_instance_valid()`. `notify_scene_reset()` raeumt vor einem Szenenwechsel
bewusst auf (aufgerufen aus `run_restart.gd`, dem einzigen Neustart-Pfad).

## Verwandt

- [[status_effect_manager]] — Statuseffekte des Spielers werden bei
  Etagenwechsel geleert (siehe [[level_generator]]), nicht beim
  Last-Stand-Wechsel.
- [[player_base]] — `apply_stun`, Kamera- und Stun-Immunitaets-Logik der
  aktiven Instanz.
