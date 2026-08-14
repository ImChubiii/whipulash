---
script_path: scripts/level/stage_manager.gd
autoload_name: Stages
tags: [architecture, autoload]
---

# stage_manager.gd

Autoload (`Stages`). Baut beim Betreten der `GoalZone` die naechste Etage:
neues Layout, neues Thema, staerkere Gegner. Der entscheidende Punkt ist,
was dabei NICHT passiert: es gibt kein `reload_current_scene()`. Das ist der
direkte Gegensatz zu [[run_restart]] (`RunRestart`), dem einzigen Autoload,
der tatsaechlich neu laedt und den ganzen Run wegwirft. Wer versehentlich
den `RunRestart`-Pfad fuer einen Etagenwechsel nimmt, schickt den Spieler
mit leerem Inventar in Etage 2; wer umgekehrt `stage_manager.gd`s
Teil-Reset fuer einen echten Neustart haelt, laesst Items/Gegnerreste aus
der letzten Etage im neuen Run stehen.

## Was den Wechsel ueberlebt und was nicht

`_do_advance()` raeumt bewusst nur, was an die ALTE Etage gebunden ist:

- Persistiert unveraendert: `Items`, [[party_manager]] (Party-Zusammensetzung,
  HP, aktive Slots), `PlayerStats`, der Spieler-Node selbst (`_find_player()`
  sucht ueber die Gruppe `"player"`, nicht per Namenspfad — `PartyManager`
  tauscht die Instanz bei Charakterwechsel aus, ein Namensfund waere danach
  eine tote Referenz).
- Wird geleert: der `StatusEffectManager`-Kindknoten des aktuellen Spielers
  (`clear_all()`) — ein Brand aus Etage 1 soll nicht in Etage 2 weiterticken,
  waehrend HP, Items und Stats ausdruecklich bestehen bleiben.
- Wird entfernt: alles in den Gruppen `"pickups"`, `"hazard"`,
  `"projectiles"`, `"floor_debris"` — haengt an Raeumen, die gleich
  verschwinden.
- Wird neu gebaut: die Raeume selbst, ueber `gen.generate_stage(to_stage)`
  auf dem im Baum gefundenen `LevelGenerator` (Gruppe `"level_generator"`).

## Ablauf von `advance_stage()` / `_do_advance()`

`advance_stage()` wird von `goal_zone.gd` aufgerufen und ist idempotent
waehrend eines laufenden Wechsels: ist `_busy` bereits `true`, gibt die
Funktion sofort `true` zurueck, ohne einen zweiten Wechsel anzustossen.
`false` kommt nur zurueck, wenn kein `LevelGenerator` gefunden wurde oder
`final_stage` bereits erreicht ist — die GoalZone zeigt dann den WinScreen
statt eines weiteren Etagenwechsels.

1. Schwarzblende einblenden (`_build_fade_overlay()` + `_fade()`, per Code
   gebaut statt als eigene `.tscn`, damit der Etagenwechsel keine
   zusaetzliche Szenen-Abhaengigkeit braucht).
2. Status-Effekte des Spielers leeren, alte Etagen-Objekte aus den vier
   Gruppen entfernen (siehe oben).
3. `generate_stage(to_stage)` auf dem LevelGenerator aufrufen.
4. Einen `process_frame` UND einen `physics_frame` abwarten — Raeume sind
   laut Kommentar erst nach dem naechsten Physik-Frame vollstaendig im Baum
   (Kollisionen, Areas), ohne diese Wartezeit koennte `_move_player_to_start()`
   den Spieler in einen Raum setzen, dessen Kollisionsformen noch fehlen.
5. `_apply_environment()`: Nebel/Umgebungslicht der `WorldEnvironment`-Node(s)
   aus dem neuen `StageTheme` setzen — die `Environment`-Resource wird dabei
   **dupliziert**, weil sie zwischen Szenen geteilt sein kann und eine
   geaenderte Nebelfarbe sonst im Hauptmenue nachwirken wuerde.
6. `_move_player_to_start()`: `global_position` wird direkt gesetzt und bei
   einem `CharacterBody3D` zusaetzlich `velocity = Vector3.ZERO`. Ohne das
   Nullen wuerde Restgeschwindigkeit den Spieler im naechsten Frame durch
   die frisch gebaute Wand schieben.
7. Schwarzblende wieder ausblenden, Overlay freigeben, `_busy = false`,
   `stage_ready`-Signal emittieren.

`process_mode` steht auf `PROCESS_MODE_ALWAYS`: der Etagenwechsel-Tween muss
auch dann durchlaufen, wenn ein Pause-Menu waehrend des Uebergangs den Baum
pausiert — sonst friert der Tween ein und der Spieler bleibt im
Schwarzbild haengen.

## `final_stage` als Speedrun-Deckel

`final_stage` (`@export`, Default 5, `0` = endlos) existiert, weil die
Speedrun-Bestenliste einen definierten Endpunkt braucht — ohne festen
Endpunkt ist keine Lauf-Zeit mit einer anderen vergleichbar.
`scripts/main_menu.gd` setzt `Stages.final_stage` je nach Speedrun-Modus zur
Laufzeit um (`SPEEDRUN_FINAL_STAGE` vs. `NORMAL_FINAL_STAGE`), bewusst nicht
aus einer Konfigurationsdatei gelesen. `scripts/save_game_manager.gd` liest
umgekehrt `Stages.get_current_stage()` fuer den Spielstand.

## Signale und Autoload-Registrierung

`stage_advancing(from_stage, to_stage)` feuert vor dem Aufraeumen,
`stage_ready(stage, theme_name)` nach dem Ausblenden — `victory_trophy.gd`
haengt sich u.a. an `advance_stage()`s Rueckgabewert, um bei Erreichen der
letzten Etage stattdessen die Sieg-Trophaee zu zeigen. Fehlt die
Autoload-Registrierung (`res://scripts/level/stage_manager.gd` als `Stages`),
faellt `goal_zone.gd` beim Aufruf auf den alten WinScreen zurueck — sichtbar
im Log als `"[StageManager] Autoload 'Stages' nicht gefunden"`.

## Verwandt

- [[run_restart]] — der andere Weg, Levelinhalt auszutauschen; dort reloadet
  die Szene komplett und wirft bewusst alles weg, was hier bewusst erhalten
  bleibt.
- [[party_manager]] — liefert Spieler-Node und Party-Zustand, der den
  Etagenwechsel unveraendert ueberlebt; dokumentiert auch den
  `player == null`-vs-`is_instance_valid()`-Bug, der beim Vergleich der
  beiden Reset-Pfade relevant wird.
- [[level_generator]] — `generate_stage(to_stage)` und `get_start_room_spawn()`
  sind die eigentliche Raum-Neubau-Logik, die `stage_manager.gd` nur orchestriert.

## Erwaehnt in DevLogs

- [[2026-08-04_ec5e457_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef]]
- [[2026-08-04_7940cf9_featitemsstatuslevelgenrooms_phase_3-5_-_status-ef]]
