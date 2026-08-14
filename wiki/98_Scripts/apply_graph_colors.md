---
tags: [workflow, script, dataview]
---

# Graph Farben Anwenden

> *Dieser kleine Script-Helfer wendet sofort die bunten Farben (Rot für Gegner, Blau für Charaktere etc.) auf deinen Graph View an, ohne dass du Obsidian neu starten musst. Das erfordert das Plugin "Dataview" (falls du es installiert hast).*

Lade diese Datei einfach, und der Code unten führt sich selbst aus und aktualisiert den Graph!

```dataviewjs
const graph = app.internalPlugins.plugins.graph
const settings = await graph.loadData()

settings.colorGroups = [
  {
    "query": "path:01_Game_Design/Enemies",
    "color": { "a": 1, "rgb": 15087942 }
  },
  {
    "query": "path:01_Game_Design/Characters",
    "color": { "a": 1, "rgb": 5032432 }
  },
  {
    "query": "path:01_Game_Design/Items",
    "color": { "a": 1, "rgb": 16556817 }
  },
  {
    "query": "path:01_Game_Design/Rooms",
    "color": { "a": 1, "rgb": 448160 }
  },
  {
    "query": "path:01_Game_Design/Status_Effects",
    "color": { "a": 1, "rgb": 11868062 }
  },
  {
    "query": "path:05_Gedanken",
    "color": { "a": 1, "rgb": 16758183 }
  },
  {
    "query": "file:_MOC",
    "color": { "a": 1, "rgb": 16777215 }
  }
]

await graph.saveData(settings)
await graph.disable()
await graph.enable()
```

## Verwandte Seiten
- [[HOME]]
- [[02_Workflow_Tools]]
