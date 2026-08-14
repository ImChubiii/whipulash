---
script_path: scripts/items/item_manager.gd
autoload_name: Items
tags: [architecture, autoload]
---

# item_manager.gd

Autoload (`Items`). Laufzeit-Inventar, Waehrungen (Muenzen/Bomben) und der
zentrale Event-Verteiler fuer alle Item-Effekte eines Runs. Kennt selbst
**keine** Item-Regeln — genau wie `status_effect_manager.gd` keine
Spielregeln kennt, nur Zustand und Timing. `item_behaviours.gd` (als Kind-
Node `ItemBehaviours` in `_spawn_behaviours()` erzeugt) haengt sich an die
Signale unten und implementiert alles mit Bedingung/Timer/Statuseffekt/VFX;
Items, die nur einen reinen Stat-Bonus geben, brauchen dort gar keinen Code
— `_apply_item_stats()` meldet `item.stat_modifiers` direkt an `PlayerStats`.

## Warum Autoload statt Spieler-Komponente

`PartyManager` tauscht bei **jedem** Charakterwechsel die komplette
`CharacterBody3D`-Instanz aus (neue Instanz an derselben Position/Kamera/HP,
siehe [[party_manager]]). Ein Inventar, das als Kind-Node am Spieler haengt,
waere nach dem ersten Wechsel weg. Items gehoeren dem RUN, nicht der Figur —
deshalb lebt `inventory`, `active_items`, `coins`, `bombs` etc. hier im
Autoload und ueberlebt jeden Charakterwechsel unveraendert.

## Wiederanbindung bei Charakterwechsel (`bind_player()`)

`_connect_party_manager()` verbindet sich per `call_deferred()` mit
`PartyManager.active_player_changed` — bewusst verzoegert, weil die
Initialisierungsreihenfolge zweier Autoloads in Godot nicht garantiert ist.
Ist der Spieler beim Start dieses Autoloads schon gespawnt (`PartyManager`
kam zuerst dran), wird `bind_player()` sofort einmal mit dem existierenden
`player`-Getter nachgeholt (mit `is_instance_valid()`-Check vorab, siehe
Kommentar zu `item_behaviours.gd::_player()` fuer die Begruendung — ein
freigegebenes `Object` wird in GDScript nicht automatisch `null`, dasselbe
Muster wie beim in `party_manager.md` dokumentierten Restart-Bug).

`bind_player()` selbst macht bei jedem Wechsel vier Dinge:

1. **Hitboxen umhaengen**: `_disconnect_hitboxes()` leert nur das Tracking-
   Array (die alte Instanz wird ohnehin von `PartyManager` freigegeben,
   Godot loest deren Verbindungen selbst), `_connect_hitboxes()` verbindet
   `PrimaryHitbox`/`SecondaryHitbox` der **neuen** Instanz an
   `_on_hitbox_hit()` — jeweils mit einer pro Hitbox gebundenen `Callable`
   (`.bind(hitbox)`), damit `player_hit_enemy` weiss, welche Hitbox traf
   (Primary vs. Secondary entscheidet ueber die Hit-Stop-Staerke in
   `game_juice.gd`).
2. **`PlayerStats`/`BombCarrier` re-attachen**: beide werden per
   `get_node_or_null()` gesucht und bei Fehlen frisch erzeugt und als Kind
   der neuen Spieler-Instanz angehaengt. Dadurch muss KEINE der vier
   Charakter-Szenen (`char_*.tscn`) diese Nodes selbst mitbringen — kein
   vergessener Slot, der Wochen spaeter als Bug zurueckkommt.
3. **`_reapply_all_item_stats()`**: die Stat-Boni haengen an der ALTEN
   `PlayerStats`-Instanz und muessen komplett neu aufgetragen werden.
4. **`_enforce_character_exclusive_items()`**: Karinas "Reflexe"
   (`ItemCatalog.ID_KARINA_LIFESTEAL`) ist eine unsichtbare, charakter-
   gebundene Passive (siehe `char_karina.gd`), die nur existieren darf,
   waehrend Karina aktiv ist. Da das Inventar dem Run gehoert, wuerde sie
   ohne diese Pruefung nach dem ersten Karina-Spawn fuer den Rest des Runs
   auch bei den anderen drei Charakteren haengen bleiben. Die Pruefung
   laeuft bei **jedem** Wechsel (nicht nur beim Verlassen von Karina), damit
   auch ein uebersprungener/fehlgeschlagener Grant nie zu einem falsch-
   negativen Zustand fuehrt.

Am Ende feuert `player_ready`, an dem sich u.a. HUD-Teile neu aufbauen.

## Q/E-Slots: zwei unabhaengige aktive Items

Frueher gab es genau ein aktives Item (Taste C), Q/E waren leere
Charakter-Faehigkeits-Platzhalter. Seit Phase 5 sind Q und E selbst die
beiden Slots (`ACTIVE_SLOT_COUNT = 2`, `active_items: Array[ItemData] =
[null, null]`):

- Slot 0 (Q) wird vom **ersten** aufgesammelten aktiven Item belegt
  (`_equip_active_item()`, first-come-first-served ueber die Slot-Schleife),
  Slot 1 (E) vom zweiten.
- Ein **drittes** aktives Item landet zwar im normalen `inventory` (zaehlt
  fuer Item-Liste/Stats/Synergie), wird aber NICHT automatisch ausgeruestet
  — es gibt bewusst keinen dritten Slot. `active_item_swap_panel.gd` bietet
  im Pause-Screen deshalb nur "Q und E tauschen" statt eines vollen
  Item-Pickers.
- **Sonderfall Schatzraum-Sockel**: `pickup_active_item()` (aufgerufen von
  `treasure_pedestal.gd`) verhaelt sich bei einem dritten aktiven Item
  anders als `add_item()` — statt es unausgeruestet ins Inventar zu legen,
  wird das aktuelle Q-Item entfernt und als `"displaced"` zurueckgegeben,
  damit der Aufrufer es zurueck auf den Sockel legen kann (echter Swap statt
  "wozu nehme ich das mit, wenn es eh nichts tut").
- `ACTIVE_SLOT_COUNT` zu erhoehen reicht NICHT aus: `active_item_swap_panel.gd`
  und `item_description_hud.gd` gehen beide fest von genau zwei Slots aus
  (siehe Kommentar auf der Konstante).

### Ladung als Dictionary pro Item-ID, nicht pro Slot

`_active_charges` und `_active_cooldowns` sind nach `item.id` geschluesselt,
nicht nach Slot-Index. Ladung haengt am ITEM (verschiedene Items brauchen
unterschiedlich viele Raeume/Sekunden), nicht am Slot — waere sie stattdessen
pro Slot-Index gespeichert, muesste `swap_active_slots()` entweder die
Ladung aktiv mittauschen (Fehlerquelle) oder sie ginge beim Tausch still
verloren. Mit dem Dictionary ist ein Tausch nur noch "welcher Slot-Index
zeigt auf welche ID" — die Ladung selbst wird nie angefasst. Ein Item, das
gerade in keinem Slot steckt (verdraengt durch den Sockel-Sonderfall), behaelt
seinen `_active_charges`-Eintrag trotzdem, falls es spaeter erneut
eingewechselt wird.

### Zwei getrennte Bereitschafts-Mechaniken

Phase 4 fuehrte sekundenbasierte Cooldowns (`_active_cooldowns`, ueber
`_process(delta)` heruntergezaehlt) ein, zusaetzlich zur alten
raumbasierten Ladung (`_active_charges`, aufgeladen ueber
`notify_room_cleared()`). `item.uses_time_cooldown()` entscheidet pro Item,
welche der beiden Mechaniken gilt — bewusst in zwei getrennten Dictionaries
statt einem gemischten, weil beide unterschiedliche Einheiten UND
unterschiedliche Nullpunkte ("bereit") haben: ein gemischtes Dictionary
haette bei jeder Abfrage zuerst den Item-Typ nachschlagen muessen, um den
Wert ueberhaupt zu verstehen. `is_active_slot_ready()`,
`get_active_charge_percent()`/`get_active_charge_remaining()` (fuers HUD-
Cooldown-Overlay) und `force_recharge_active()` (Nonnen-Kutte-Item)
verzweigen alle nach demselben Muster ueber `uses_time_cooldown()`.
`_process()` laeuft bewusst als Dauerschleife ueber hoechstens zwei Eintraege
statt eines Timer-Node pro Item — ein Timer haette bei jedem Slot-Tausch neu
verdrahtet werden muessen.

Die einzige Ausnahme von beiden Mechaniken ist das Schulbibliotheks-Buch
("1x pro Etage"): weder Zeit noch Raumzahl, laeuft ueber eine eigene Sperre
in `item_behaviours.gd` und bekommt entsprechend weder `cooldown_seconds`
noch `charge_rooms`.

## Warum `_remove_from_inventory()` alle Stat-Modifier verwirft und neu aufbaut

`_apply_item_stats()` registriert Stat-Boni bei `PlayerStats` unter einer
`source_id` der Form `"item:%s#%d"` — der Index ist Teil des Schluessels,
damit ein zweites Exemplar desselben Items den Modifier-Eintrag des ersten
nicht ueberschreibt. Eine Entfernung aus der Mitte von `inventory` wuerde
alle nachfolgenden Indizes verschieben und deren Modifier unter der ALTEN
`source_id` verwaist zuruecklassen (`PlayerStats._modifiers` bereinigt sich
nicht automatisch). Statt jeden verschobenen Index einzeln nachzuziehen,
wirft `_remove_from_inventory()` per `stats.clear_all()` +
`_reapply_all_item_stats()` einfach alle Modifier weg und baut sie aus dem
jetzt korrekten Inventar neu auf — derselbe Ablauf wie `reset_run()`.

## `_inventory_counts`: O(1) statt linearer Suche

`has_item()`/`count_item()` lesen aus `_inventory_counts` (id -> Anzahl)
statt `inventory` linear zu durchsuchen. Begruendung im Code: beide werden
von `item_behaviours.gd` potenziell mehrfach pro Sekunde aus
`_physics_process()` und mehreren Hit-/Damage-Handlern gegen ein spaetes
Run-Inventar mit 20-40+ Eintraegen aufgerufen. Muss bei jeder Aenderung an
`inventory` (`add_item()`, `_remove_from_inventory()`, `reset_run()`,
`clear_inventory()`) synchron mitgepflegt werden, sonst laeuft er auseinander
— es gibt keine automatische Ableitung aus `inventory`.

## `silent`-Flag bei `add_item()`

`silent = true` unterdrueckt NUR `item_added` (das Signal, an dem die
"Item gefunden"-Popup-Karte in `item_description_hud.gd` haengt) — gedacht
fuer fest verdrahtete, unsichtbare Charakter-Passiven wie Karinas Reflexe,
die nie "gefunden" werden sollen. `inventory_changed` bleibt bewusst IMMER
an, sonst wuerden Inventarlisten-UI und Stat-Neuberechnung nach einem
stillen Grant nicht mitziehen.

## Synergie-Gewichte (`get_synergy_weight()`)

`_register_synergy_tags()` erhoeht bei jedem aufgesammelten Item mit
`synergy_tags` additiv `SYNERGY_WEIGHT_PER_TAG` (0.15) pro Tag in
`_synergy_tag_bonus`. `get_synergy_weight()` wird von
`TreasureManager._pick_item()` beim Wuerfeln der Schatzraum-Items gelesen —
`item_manager.gd` kennt selbst keine Drop-Logik, liefert nur die kumulierten
Gewichte.

## `reset_run()` vs. `clear_inventory()`

Beide leeren Inventar, aktive Slots, Ladungen und Cooldowns und rufen
`stats.clear_all()` + `stats.apply()`. Der Unterschied: `reset_run()` setzt
zusaetzlich `coins`/`bombs` auf die Startwerte zurueck (kompletter Rundenneustart,
aufgerufen vom Run-Reset-Pfad), `clear_inventory()` laesst Waehrungen
unangetastet — gedacht fuer die Loesch-Plattform im Item-Testraum
(`scripts/item_test_room.gd`): Items durchtesten, per Knopfdruck bei null
anfangen, ohne den ganzen Run neu zu starten.

## Eingabe-Actions selbst registriert

`_ensure_actions()` registriert die `"bomb"`-Action (Taste X) selbst in
`_ready()`, bewusst hier statt in `settings_manager.gd` — das Feature soll
sich installieren lassen, ohne eine bestehende Datei anzufassen. Die frueher
eigene `"use_item"`-Action (Taste C) ist mit der Q/E-Umstellung entfallen;
aktive Items werden ueber die in `settings_manager.gd` bereits registrierten,
rebindbaren Actions `"ability_primary"`/`"ability_secondary"` ausgeloest —
`item_manager.gd` fasst Input selbst ueberhaupt nicht mehr an (siehe
`combat_base.gd::_do_ability_q()`/`_do_ability_e()`, die `Items.use_active_item()`
aufrufen).

## Verwandt

- [[party_manager]] — Quelle von `active_player_changed`; der komplette
  Re-Attach-Mechanismus in `bind_player()` existiert nur wegen des dort
  dokumentierten Instanz-Austauschs.
- [[combat_base]] — loest `Items.use_active_item(0/1)` ueber Q/E aus und
  liest `is_active_slot_ready()`/`get_active_charge_percent()` fuers
  Cooldown-Overlay.
- [[status_effect_manager]] — mehrere Item-Effekte (Bluten, Statuseffekte)
  aus `item_behaviours.gd` laufen ueber dessen `apply_effect()`/`extend_effect()`
  statt eigener Item-Timer.

## Erwaehnt in DevLogs

- [[2026-07-26_161c399_feat_stat-system_loot-drops_bomben_items_und_game_]]
- [[2026-07-28_2642172_featitems_aktive_items_auf_qe-slots_umgestellt]]
- [[2026-07-28_ea34fe3_featitems_aktive_items_auf_qe-slots_umgestellt]]
