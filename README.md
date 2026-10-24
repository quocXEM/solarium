# Solarium

International physics-merge casual. Drop luminous orbs into glass. Merge equals into brighter forms. Overflow — one more drop.

**Retention:** short runs · score chase · discovery album (11 tiers).

## Play

Godot **4.7+** → open this folder → **F5**.  
Drag to aim · release to drop. Esc = pause.

## Studio layout

| Path | Role |
|---|---|
| `scenes/` | boot, menu, game, settings, album |
| `scripts/core` | Loc, Save, Settings, SceneRouter |
| `scripts/game` | Orbs, physics merge |
| `docs/` | DESIGN · UI · MOBILE · STUDIO · PRIVACY |
| `tools/smoke_test.gd` | Headless QA |

## Platforms

Portrait **1080×1920** · renderer mobile · Android / iOS ready.  
See `docs/MOBILE.md`.

```bash
Godot --path . --headless -s res://tools/smoke_test.gd
```

## License

MIT · Fonts: Cormorant Garamond (OFL) — see `LICENSE`.
