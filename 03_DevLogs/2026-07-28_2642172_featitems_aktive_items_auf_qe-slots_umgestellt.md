---
commit: "2642172d2bb42b47853d2e0fb1678d6d22ba94e2"
short_hash: "2642172"
date: 2026-07-28
author: "ImChubiii"
subject: "feat(items): aktive Items auf Q/E-Slots umgestellt"
tags: [devlog]
---

# 2026-07-28 — feat(items): aktive Items auf Q/E-Slots umgestellt

Ersetzt die bisher leeren Charakter-Fähigkeiten auf Q/E durch zwei
unabhängige aktive Item-Slots. Vorher gab es genau ein aktives Item
(Taste C), Q und E waren pro Charakter nur Platzhalter (Kamera-Shake +
Print).

Neues Verhalten:
- Erstes aufgesammeltes aktives Item -> Slot Q, zweites -> Slot E.
  Ein drittes bleibt im Inventar, wird aber nicht automatisch
  ausgerüstet (kein Item-Picker in dieser Phase, nur Q<->E-Tausch).
- Ladung wird pro Item-ID gespeichert statt pro Slot, damit ein Tausch
  im Pause-Screen nie Ladefortschritt verliert.
- Q/E haben keinen zeitbasierten Cooldown mehr; das bestehende
  Cooldown-Overlay im HUD zeigt jetzt die Raum-Ladung des jeweiligen
  Items an (hud.gd musste dafür nicht angefasst werden).
- Neues Pause-Screen-Widget (ActiveItemSwapPanel) zum Tauschen von
  Q und E.
- Alte Taste C und die vier Charakter-Platzhalter-Fähigkeiten entfernt.

Geänderte/neue Dateien:
- scripts/items/item_manager.gd: 2-Slot-System (active_items,
  Ladung als Dictionary, swap_active_slots(), use_active_item(slot))
- scripts/combat_base.gd: Q/E lösen direkt Items.use_active_item()
  aus, Cooldown-Getter lesen Item-Ladung statt Zeit-Timer
- scripts/characters/combat_{giselle,karina,ningning,winter}.gd:
  Platzhalter-Fähigkeiten entfernt
- scripts/items/item_description_hud.gd: Ein Slot -> zwei Slots
  (Q/E) im Bottom-HUD
- scripts/items/active_item_swap_panel.gd: neu
- scripts/pause_menu.gd: Swap-Panel eingehängt
- scripts/ability_slot.gd: Ladungsanzeige ohne unnötige Nachkommastelle

Fixes im Rahmen dieser Umstellung:
- "Invalid access to property or key 'ACTIVE_SLOT_COUNT' on a base
  object of type 'Nil'": zwei Ursachen. Erstens nutzte neuer Code an
  zwei Stellen den globalen "Items"-Bezeichner statt des im gesamten
  Projekt etablierten get_node_or_null("/root/Items") - behoben in
  combat_base.gd und active_item_swap_panel.gd über eine gecachte
  _items()-Hilfsfunktion. Zweitens griff item_description_hud.gd in
  _ready() über _build_active_slot() auf _items zu, BEVOR es im
  selben _ready() zugewiesen wurde - Zuweisung an den Anfang gezogen,
  zusätzlich defensive Null-Guards in _build_active_slot()/_slot_of().

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `2642172` |
| Autor | ImChubiii |
| Datum | 2026-07-28 |
