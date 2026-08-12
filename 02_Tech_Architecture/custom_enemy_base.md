---
script_path: scripts/enemies/custom_enemy_base.gd
tags: [architecture, enemy]
---

# custom_enemy_base.gd

Zweiter, unabhaengiger Gegner-Unterbau neben `enemy_ai.gd`. Bewusst NICHT von
`EnemyAI` geerbt: `EnemyAI` ist fest auf das Chase-Attack-State-Machine-Muster
mit importiertem Roboter-Mesh zugeschnitten (siehe dessen Kopfkommentar) — die
sechs neuen Typen ([[moerser-bot]], [[saeure-sprinkler]], [[magnet-kern]],
[[divebomber]], [[schild-drohne]], [[plasmastrahl-bot]]) brauchen davon
nichts: sie stehen fest (Turret-Typen) oder fliegen eigene Muster, haben
keine Laufanimation und bauen sich komplett aus Primitiv-Meshes auf — im
selben Stil wie die Hazards `cannon.gd`/`turret.gd`.

## Was trotzdem geteilt werden MUSS

Damit diese Gegner mit dem Rest des Spiels kompatibel sind:

- Gruppe `"enemies"` — Items (`_enemies_near`), Bomben-Explosionen und
  Homing-Bolts finden ihre Ziele ausschliesslich darueber.
- `collision_layer = 4` — exakt die Ebene, die `PrimaryHitbox.collision_mask`
  abhorcht; ohne sie liefe der Spieler-Nahkampf durch diese Gegner hindurch.
- Ein Kind-Node namens `"Health"` vom Typ `Health` — `primary_hitbox.gd` und
  `TurretProjectile` suchen ausschliesslich per `find_child("Health", ...)`.

## Lebenszyklus

`_ready()` ruft der Reihe nach `_configure()` (Subklasse setzt `display_name`/
`max_health`), `_build_health()`, `_build_status_effects()` (verdrahtet
[[status_effect_manager]] — ohne ihn liefe JEDER Status-Effekt lautlos ins
Leere, siehe `StatusEffectBase.apply_raw()`) und `_build()` (Subklasse baut
Mesh/Collision/Timer).

Tod laeuft ueber `_on_died()` -> `_teardown(true)` (mit Treffer-VFX);
Verschwinden ohne Kampf (Support-Typen wie [[schild-drohne]]/
[[plasmastrahl-bot]], siehe deren `_despawn_if_room_clear()`) ueber
`despawn()` -> `_teardown(false)`. Beide raeumen Kollision, Statuseffekte und
Subklassen-Sondereffekte auf (`_cleanup_effects()` — WICHTIG: wird auch von
aussen ueber `enemy_sandbox_room.gd::_clear_enemies()` als Zwangsentfernung
aufgerufen, bei der `Health.died` NICHT feuert; ohne den expliziten Aufruf
blieben Beams/Telegraphs bis zu ihrem eigenen Timeout einsam in der Luft
haengen).

## Schild-Buff (`shield`-Status)

`_on_status_effect_applied()`/`_on_status_effect_expired()` reagieren generisch
auf `id == "shield"`: +25 % Maximal-HP, groesseres Modell, blau schwankende
Aura. Identische Werte/Logik wie in `enemy_ai.gd` fuer Fighter/Stinger/
Colossus — beide lesen dieselben `StatusShield`-Konstanten. Siehe [[shield]].

## Geteilte Bau-Helfer

`_make_unshaded_material()`, `_add_box_collision()`, `_project_to_ground()`
(Raycast senkrecht nach unten — Einschlaege/Pfuetzen sollen auf dem Boden
liegen, nicht auf roher Spieler-Y-Hoehe bei einem Sprung) sowie
`_create_beam_visual()`/`_update_beam_visual()`/`_free_beam_visual()` fuer
lesbare Energiestrahlen (Kern + Glow + laufender Puls) — genutzt von
[[schild-drohne]] und [[plasmastrahl-bot]].

## Verwandt

- [[enemy_sandbox_room]] — einziger aktueller Spawn-Ort aller sechs Typen.
- [[level_generator]] — Threat-Budget-Tabellen, in denen diese sechs Typen
  noch NICHT eingetragen sind.
- [[status_effect_manager]], [[shield]].

## Erwaehnt in DevLogs

- —
