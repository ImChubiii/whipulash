---
commit: "499c162d3e5af9bf47951810fe5aeca65eadaf21"
short_hash: "499c162"
date: 2026-07-28
author: "ImChubiii"
subject: "refactor: reorganize project structure and normalize res:// paths"
tags: [devlog]
---

# 2026-07-28 — refactor: reorganize project structure and normalize res:// paths

- Move scripts from root and scenes/ into scripts/{core,enemies,hazards,level,ui}
- Move scenes into scenes/{enemies,environment,hazards,ui}
- Move assets into assets/{characters,environments,textures,ui}
- Update all res:// references in .gd, .tscn, .tres, .cfg and .import files
- Remove empty directories after migration
- Add reorganize.py helper script for future structure changes

## Metadaten

| Feld | Wert |
|---|---|
| Commit | `499c162` |
| Autor | ImChubiii |
| Datum | 2026-07-28 |
