---
commit: "5d04371c6c3dd33c0b4584dd932c42f3f9275973"
short_hash: "5d04371"
date: 2026-08-10
author: "ImChubiii"
subject: "Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten"
tags: [devlog]
---

# 2026-08-10 — Wiki: sechs neue Sandbox-Gegner, Item<->Item-Synergien, MOC-Gruppierungsseiten

generate_vault.py erweitert statt die Notizen nur von Hand nachzupflegen:

- Sechs neue, bisher unerfasste Gegnertypen (Mörser-Bot, Säure-Sprinkler,
  Magnet-Kern, Divebomber, Schild-Drohne, Plasmastrahl-Bot) aus den reinen
  Code-Dateien unter scripts/enemies/ geparst (kein .tres/.tscn vorhanden,
  daher eigener Parser gegenueber Modul-Scope-var-Deklarationen). Klar als
  "Sandbox-Prototyp" (nur EnemySandboxRoom) von den drei Threat-Budget-
  Gegnern (Fighter/Stinger/Colossus) unterschieden.
- Neuer Status-Effekt "shield" (scripts/status_effects/shield.gd) samt
  generischer "Zusatzwerte"-Tabelle für Nicht-Standard-Konstanten.
- Item<->Item-Synergien und die Umkehr-Richtung "reagiert auf Status, ohne
  ihn auszuloesen" jetzt codeverifiziert aus item_behaviours.gd extrahiert
  (vorher leeres "Synergien"-Feld in jeder Notiz).
- Zwei neue Architektur-Notizen (custom_enemy_base.gd, enemy_sandbox_room.gd)
  für den zweiten, parallelen Gegner-Unterbau.
- Statische MOC-Gruppierungsseiten (Items nach Kategorie/Rarity/Kind, Gegner
  nach Tier/Rolle, Räume nach Typ, Status-Effekte nach Klasse) - lesbar auch
  ohne Dataview-Plugin.
- Bugfix: Banner-Kommentar-Regex für Statuseffekt-Synopsen unterstuetzte nur
  einzeilige Beschreibungen; shield.gd ist zweizeilig.

## Erwaehnte Entitaeten

Automatisch per Freitext-Abgleich mit Item-/Gegner-/Raum-/Status-Effekt-/
Architektur-Namen erkannt — kann vereinzelt falsch-positiv sein, siehe
Kopfkommentar bei `build_entity_index()` in `generate_vault.py`.

**Gegner:** [[colossus]], [[divebomber]], [[fighter]], [[magnet-kern]], [[moerser-bot]], [[plasmastrahl-bot]], [[saeure-sprinkler]], [[schild-drohne]], [[stinger]]

**Status-Effekte:** [[shield]]

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `5d04371` |
| Autor | ImChubiii |
| Datum | 2026-08-10 |
