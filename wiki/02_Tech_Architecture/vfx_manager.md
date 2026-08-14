---
script_path: scripts/vfx_manager.gd
autoload_name: VFX
tags: [architecture, autoload]
---

# vfx_manager.gd

Autoload (`VFX`). Zentraler One-Shot-Spawner fuer alle Partikel-/Treffer-Effekte
im Spiel — Treffer-Funken, Muendungsblitze, Explosionen, Staubringe. Es gibt
absichtlich keine Konvention, bei der ein Effekt-Node am Ausloeser (Hitbox,
Gegner, Bombe) haengt.

## Warum zentral statt als Kind-Node

Hitboxen deaktivieren sich 0.15s nach dem Schlag, Gegner rufen bei Tod
`queue_free()`. Ein Partikel-Emitter als Kind eines dieser Nodes wuerde
mitten im Abspielen mit verschwinden. `spawn()`/`spawn_dual_tinted()` haengen
die Effekt-Instanz stattdessen immer in `current_scene` (oder einen expliziten
`parent`), spielen sie ab und raeumen sich per selbst geplantem Timer
(`_schedule_cleanup()`) wieder ab — unabhaengig vom Lebenszyklus des
Ausloesers.

Die Lebensdauer fuer diesen Cleanup wird nicht geraten, sondern aus der
tatsaechlich laengsten `lifetime / speed_scale` aller `GPUParticles3D`/
`CPUParticles3D`-Kinder der Szene ermittelt (`_restart_emitters()`), zzgl.
`CLEANUP_MARGIN = 0.5s` Sicherheitszuschlag. Enthaelt eine VFX-Szene gar
keinen Partikel-Node, greift `FALLBACK_LIFETIME = 2.0s` als Notbremse statt
eines sofortigen `queue_free()`.

## Zweifarbiges Einfaerben (`spawn_dual_tinted`)

Treffer-Funken sollen in den beiden Attack-Farben (`attack_color`/
`attack_color_secondary`) des jeweils aktiven Charakters erscheinen, ohne fuer
jede Farbkombination eine eigene VFX-Szene anzulegen. Der Trick: bei
`GPUParticles3D` bekommt `draw_pass_1` `color_a`, `draw_pass_2` (falls die
Szene einen hat, siehe `hit_spark_primary.tscn`) `color_b`. Godot wuerfelt bei
mehreren Draw-Passes pro Partikel aus, welcher gezeichnet wird — genau der
eingebaute Mechanismus, den auch mehrfarbiges Feuer nutzt, und laut
Kopfkommentar zuverlaessiger als ein Farbverlauf ueber
`ParticleProcessMaterial.color_ramp` mit Vertex-Color-Passthrough.
`CPUParticles3D` kennt keine mehreren Draw-Passes und faerbt sich deshalb
einfarbig mit `color_a`.

**Warum vor dem Einfaerben `duplicate()`:** Sub-Resource-Materialien einer
`.tscn` gehoeren zur `PackedScene`, nicht zur Instanz — Godot teilt sie
standardmaessig zwischen allen `scene.instantiate()`-Aufrufen (derselbe
Fallstrick, den `lemonade.gd._make_resources_unique()` im Projekt schon
einmal beheben musste). Ohne `duplicate()` auf `process_material`,
`draw_pass_1` und `draw_pass_2` wuerde das Einfaerben EINES Treffer-Funkens
rueckwirkend jeden anderen, gerade noch aktiven Funken mitumfaerben — bei
mehreren Charakteren mit unterschiedlichen Attack-Farben waere das sofort
sichtbar falsch.

Die Faerbung passiert bewusst VOR dem `_restart_emitters()`-Aufruf: das
Draw-Pass-Material muss vor dem ersten gerenderten Frame feststehen, sonst
startet der Effekt kurz in der alten (weissen) Farbe.

## `_aim()` und der Gimbal-Sonderfall

`look_at()` wirft einen Fehler, wenn die Blickrichtung exakt parallel zum
Up-Vektor liegt — passiert bei einem Treffer senkrecht von oben oder unten
(z.B. Divebomber-Einschlag). `_aim()` kippt in diesem Fall den Up-Vektor auf
`Vector3.FORWARD` statt `Vector3.UP`.

## Verwendung im Projekt

Praktisch jeder Treffer-/Impact-Pfad ruft `VFX.spawn()` oder
`VFX.spawn_dual_tinted()`: `primary_hitbox.gd` (Schwung- und Impact-VFX,
inkl. `attacker_colors`-Zweifarbigkeit), die vier `combat_<char>.gd`-Skripte
(Muendungsblitze, Treffer-Funken), [[custom_enemy_base]] und `enemy_ai.gd`
(Treffer-VFX beim Tod bzw. Angriffs-Hitbox), `dive_bomber.gd`/`mortar_bot.gd`/
`magnet_core.gd` (Einschlag-Staubringe), `status_effect_base.gd` (jeder
Status-Effekt entscheidet nur, WELCHE Szene, nicht WIE sie gespawnt/
aufgeraeumt wird) sowie `item_behaviours.gd` und Hazards wie `lemonade.gd`
(Korrosions-VFX) und `destructible_prop.gd` (Truemmer).

Die zweifarbige Charakter-Unterscheidung in `spawn_dual_tinted()` wurde
gezielt fuer das Ghost-Trail-/Treffer-VFX-Feature eingefuehrt (Ningning
blau/weiss, Giselle rot/orange, Karina rot/pink, Winter gruen/weiss) — siehe
DevLog unten.

## Verwandt

- [[custom_enemy_base]] — Treffer-VFX beim `_teardown()`-Pfad der sechs neuen
  Gegnertypen.
- [[status_effect_manager]] — `status_effect_base.gd` ruft `VFX.spawn()` fuer
  jede Effekt-VFX-Entscheidung auf, die Laufzeit-Logik bleibt aber dort.
- [[combat_base]] — Dash-VFX (`dash_vfx`/`dash_hit_vfx`) laufen ueber
  `VFX.spawn()`.
- [[game_juice]] — beide Autoloads werden aus denselben Treffer-/
  Impact-Stellen heraus meist gemeinsam ausgeloest (VFX fuer das Auge,
  Hit-Stop/Shake fuer das Gefuehl), sind aber vollkommen unabhaengig
  voneinander.

## Erwaehnt in DevLogs

- [[2026-08-10_4b3999e_featvfxuiitemslevelgen_ghost-trail-system_main-men]]
- [[2026-08-10_baeb020_featvfxuiitemslevelgen_ghost-trail-system_main-men]]
