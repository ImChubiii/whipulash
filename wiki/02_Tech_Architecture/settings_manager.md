---
script_path: scripts/settings_manager.gd
autoload_name: SettingsManager
tags: [architecture, autoload]
---

# settings_manager.gd

Autoload (`SettingsManager`). Haelt **alle** persistenten Einstellungen
(Controls, Audio, Video, HUD/General, Minimap, Accessibility, Keybinds) als
einfache Member-Variablen und spiegelt sie in `user://settings.cfg`
(`ConfigFile`). Kein Resource, kein `.tres` — bewusst ein einzelnes flaches
Autoload, damit UI (`scenes/settings_menu.gd`) und Verbraucher (`hud.gd`,
`minimap.gd`, `player_base.gd`, ...) denselben Wert lesen, ohne Redundanz
zwischen Menue-State und Spiel-State.

## Push statt Pull

Jeder Setter (`set_sensitivity`, `set_fov`, `set_volume`, `set_display_mode`,
...) macht drei Dinge in fester Reihenfolge: Wert setzen → sofort auf die
Engine/den passenden Consumer anwenden (`_apply_*`) → passendes Signal
feuern → `save_settings()`. Die Anwendung passiert also aktiv im Setter, nicht
nur reaktiv ueber Signale — das deckt den Fall ab, dass beim Aufruf noch gar
kein Listener existiert (z.B. `_apply_all()` in `_ready()`, bevor irgendeine
UI ueberhaupt existiert).

Fuer Werte, die auf der aktiven Spieler-Instanz landen muessen (Sensitivity,
FOV), gibt es trotzdem *zusaetzlich* Push-Funktionen
(`_apply_sensitivity_to_player`, `_apply_fov_to_player`), die ueber
`get_tree().get_nodes_in_group("player")` gehen — bewusst **nicht** per
`find_child("Player")`, weil `PartyManager` die Spieler-Instanz bei jedem
Charakterwechsel komplett austauscht; ein namentlich gefundener Node waere
danach ungueltig. Die Gruppe steht als literaler String `"player"`, nicht als
`PartyManager.PLAYER_GROUP`-Konstante — die Autoload-Initialisierungsreihenfolge
ist in Godot nicht garantiert, ein Zugriff auf ein anderes Autoload waehrend
`_ready()` koennte ins Leere laufen.

## Sammelsignal `minimap_setting_changed`

Die acht Minimap-Werte (Zoom, UI-Scale, Opacity, Grid-Placement, Rotation,
drei Sichtbarkeits-Flags) feuern **nicht** je ein eigenes Signal, sondern
alle denselben Sammelruf `minimap_setting_changed`. `minimap.gd` reagiert
darauf mit einem vollstaendigen `_apply_minimap_settings()`, das immer *alle*
Werte neu liest. Das verhindert, dass ein neuer Minimap-Regler ergaenzt wird,
aber vergessen geht, ihn zu verdrahten — er kommt automatisch mit, sobald er
in `_apply_minimap_settings()` gelesen wird. `run_timer.gd` und
`tutorial_character_intro.gd` haengen sich an dasselbe Signal, um ihr
HUD-Docking an `minimap_ui_scale` nachzuziehen.

## Reset ist pro Seite, nicht global

`reset_general_settings()` / `reset_video_settings()` / `reset_audio_settings()`
/ `reset_controls_settings()` existieren einzeln, weil ein globaler
"Reset to Default"-Knopf im Einstellungsmenue gefaehrlich waere: wer nur die
Tastenbelegung zuruecksetzen will, wuerde sonst nebenbei auch Lautstaerke und
Aufloesung verlieren. Der Menue-Button ruft entsprechend nur die Reset-Funktion
der aktuell offenen Seite auf. `reset_all_to_defaults()` bleibt als API
bestehen, wird aber von der UI aktuell nicht mehr aufgerufen. Jede
Reset-Funktion setzt zuerst *alle* betroffenen Werte und feuert danach ihre
Signale genau einmal (statt pro Wert) — sichtbar z.B. an
`_reset_minimap_values()`, das reine Wertzuweisung ohne Signale ist und erst
von `reset_minimap_settings()`/`reset_general_settings()` umschlossen wird.

## Bug (behoben): Fenster springt beim ersten Start auf (0,0)

`_windowed_position` hat als Klassen-Default `Vector2i.ZERO`. Frueher wurde
beim Wechsel in den Windowed-Modus ungeprueft `window_set_position()` mit
diesem Wert aufgerufen — bei einem allerersten Programmstart (noch keine
gespeicherte Position) zog das Fenster auf absolute Desktop-Koordinate (0,0),
was bei Multi-Monitor-Setups je nach Anordnung oft nicht auf dem
Hauptbildschirm liegt. Fix: das Flag `_has_valid_windowed_position` wird erst
`true`, wenn entweder aus der Config geladen (`load_settings()`) oder beim
Verlassen des Windowed-Modus aktiv gesichert (`set_display_mode()`).
`_apply_display_mode()` ruft `window_set_position()` nur noch, wenn dieses
Flag gesetzt ist — sonst bleibt das Fenster dort stehen, wo Godots eigene
Projekteinstellung ("Initial Position Type = Center Primary Screen") es schon
korrekt platziert hat. Das Flag selbst wird mitgespeichert
(`has_valid_windowed_position` in der `[display]`-Section), damit alte
`settings.cfg`-Dateien ohne diesen Key beim Laden korrekt als "noch nie
gesichert" erkannt werden.

## Clamp beim Laden, nicht nur im Setter

`fov`, `minimap_zoom`, `minimap_ui_scale` und `minimap_opacity` werden in
`load_settings()` genauso geclampt wie in ihren Settern. Grund: eine von Hand
editierte oder aus einer alten Version stammende `settings.cfg` mit z.B.
`fov = 5` oder `zoom = 0` wuerde sonst die Kamera unbrauchbar machen bzw. die
Minimap-Kamera auf Groesse 0 stellen (komplett schwarze Karte) — beides ohne
jeden Fehler im Log, weil der Wert syntaktisch gueltig ist.

## Migrationen in `load_settings()`

`load_settings()` traegt stillschweigend drei Altlasten mit:
`[display] fullscreen: bool` → `display_mode`-Enum (alte Bool-Fullscreen-Configs),
`[general] minimap_rotate_with_player` → `[minimap] rotate_with_player` (Sektion
verschoben), und `[minimap] bg_opacity` → `[minimap] opacity` (fruehere Version
hatte getrennte Deckkraft fuer Hintergrund und Rahmen, jetzt ein einzelner
Wert — der alte Hintergrundwert wird uebernommen, weil der damalige
Gesamt-Regler meist auf 1.0 stand und als neuer Default nutzlos gewesen waere).
Entfallene Schluessel wie das fruehere `minimap_grid_scale`/`big_map_zoom`
werden einfach nicht mehr gelesen; sie verschwinden beim naechsten
`save_settings()` automatisch, weil die Config komplett neu geschrieben wird.

## Rebindbare Actions

`REBINDABLE_ACTIONS` (Dictionary Action → Anzeigename) und `DEFAULT_KEYBINDS`
(die verbindliche Standardbelegung, unabhaengig von `project.godot`) leben
beide hier. `_ensure_actions_exist()` legt in `_ready()` fehlende Actions im
`InputMap` mit ihrer Default-Belegung neu an — relevant, falls eine neue
Action hinzugefuegt wird, aber alte Spielstaende/Godot-Projekteinstellungen
sie noch nicht kennen. `build_default_event()` nutzt bewusst
`physical_keycode` statt `keycode`, damit WASD auf AZERTY/QWERTZ-Layouts an
der gleichen physischen Taste bleibt. Eine Kopplung, die nirgends erzwungen
wird: `treasure_pedestal.gd` hat "interact" = F hart im Kommentar
dokumentiert, weil das UI-Prompt-Icon nicht dynamisch aus `DEFAULT_KEYBINDS`
gelesen wird — eine Aenderung der Default-Belegung hier muesste dort von Hand
nachgezogen werden.

## Modulare HUD-Elemente

`hud_visible` (Master-Schalter) und `hud_elements` (Dictionary pro Element,
z.B. `HUD_ELEMENT_MINIMAP`) sind UND-verknuepft — siehe `hud.gd`.
`is_hud_element_visible()` prueft *nur* den Einzelschalter ohne den Master;
Consumer wie `stats_panel.gd` und `item_description_hud.gd` verknuepfen beide
Werte selbst. `HUD_ELEMENT_STATS`/`HUD_ELEMENT_ITEMS` muessen exakt mit den
`HUD_ELEMENT`-Konstanten in `stats_panel.gd` bzw. `item_description_hud.gd`
uebereinstimmen — ein Tippfehler faellt nicht als Fehler auf, sondern nur
dadurch, dass der Schalter im Menue kommentarlos nichts bewirkt.

## Verwandt

- [[player_base]] — empfaengt Sensitivity/FOV per Push ueber die Gruppe
  `"player"`, liest `screen_shake_enabled` direkt beim Kamera-Feedback.

## Erwaehnt in DevLogs

- [[2026-07-28_ae734fd_fix_windowed_position_persistence_on_first_run]]
- [[2026-07-26_058b54e_featsettings_minimap_modulare_settings-gruppen_min]]
- [[2026-07-23_f874fed_refactor_settings_menu_with_tabs_accessibility]]
- [[2026-07-22_b53088c_featui_add_settings_menu_with_sensitivity_volume_f]]
