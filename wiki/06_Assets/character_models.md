---
tags: [asset, asset/character]
---

# Charakter-Modelle

> *Die 3D-Rigs der spielbaren Charaktere — aktuell als Powerpuff Girls Prototypen.*

## Übersicht

Das Spiel nutzt aktuell Powerpuff Girls Charaktermodelle als Prototypen für die 4 spielbaren Charaktere. Jedes Modell kommt mit einem **Rig** (animiert) und einer **Textur-PNG**.

| Datei | Größe | Verknüpft mit |
|---|---|---|
| `blossom_rig_the_powerpuff_girls.glb` | 3.8 MB | Charakter-Prototyp (geriggt) |
| `bubbles_rig_the_powerpuff_girls.glb` | 1.0 MB | Charakter-Prototyp (geriggt) |
| `buttercup_the_powerpuff_girls.glb` | 0.7 MB | Charakter-Prototyp |
| `brick_the_rowdyruff_boys.glb` | 1.6 MB | Gegner-/Charakter-Prototyp |
| `lowpoly_robots.glb` | 1.4 MB | [[enemy_models\|Gegner-Modelle]] |

## Charakter-Texturen

![[blossom_the_powerpuff_girls_0.png]]

*Textur-Atlas der Powerpuff Girls Modelle (geteilt zwischen Blossom, Bubbles, Buttercup)*

## Technische Details

- **Format**: `.glb` (GLTF Binary) — direkt in Godot 4 importierbar
- **Rig**: Humanoides Skelett für Lauf-, Dash- und Angriffs-Animationen
- **Textur**: Geteilt — alle 3 PPG-Charaktere nutzen denselben Textur-Atlas
- **Import-Einstellungen**: `.glb.import` Dateien steuern Godot-Importer

## Verwendung in Godot

```
scenes/characters/
├── ningning.tscn   → blossom_rig / bubbles_rig
├── giselle.tscn    → buttercup / blossom_rig
├── karina.tscn     → [Prototyp]
└── winter.tscn     → [Prototyp]
```

## Verwandt

[[_MOC_Characters\|Alle Charaktere]] . [[enemy_models\|Gegner-Modelle]] . [[_MOC_Assets\|Alle Assets]]
