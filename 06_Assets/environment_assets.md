---
tags: [asset, asset/environment]
---

# Umgebungs-Assets (Dungeon Kit)

> *Die Bausteine für die prozeduralen Level und handgebauten Räume.*

## Übersicht

Die Umgebung nutzt modulare Kits (hauptsächlich KayKit Dungeon Pack). Diese `.obj` Modelle bilden die Architektur der Dungeons.

### Struktur (Dungeon Kit)
- **Wände & Böden**: `wall_flat.obj`, `tile_flat.obj`, `door_frame.obj`
- **Säulen**: `pillar.obj`, `pillar_thicc.obj` (z.B. in [[corridor_pillars_01\|Säulenpassagen]])
- **Dekoration & Props**: `lantern.obj`, `torch.obj`, `table_2x2.obj`
- **Hazards & Items**: `poison.obj` (Basis für [[lemonade\|Limonade]]), `heart.obj`, `key.obj`
- **Waffen-Props**: `axe.obj`, `hammer.obj`, `sword.obj`, `shield.obj`

### Dungeon Kit v2
- **Gekrümmte Wände/Böden**: `Wall_Curved.obj`, `Floor_Curved.obj`
- **Treppen & Rampen**: `Steps.obj`, `Ramp.obj`
- **Türen & Tore**: `Gateway_Small.obj`, `Wall_Cell_Door.obj`
- **Mechanismen**: `Switch_Floor.obj`, `Lever_Floor.obj`

## Raum-Design

Beim Bauen der Räume (z.B. `combat_01`) werden diese Bausteine über GridMaps in Godot zusammengesetzt.
Die Props in den Ecken der Räume (Tische, Laternen, Säulen) geben den Räumen ihr Aussehen und dienen als Deckung im Kampf.

## Verwandt

[[_MOC_Rooms\|Alle Räume]] . [[textures\|Texturen]] . [[_MOC_Assets\|Alle Assets]]
