# Solarium — studio standards

## Product

International **physics-merge casual** (Suika-class retention) with luminous art direction.

| Pillar | Spec |
|---|---|
| Teach | Coach once → play |
| Session | 1–3 minutes, one more drop |
| Retention | Best score + discovery album (11 tiers) |
| Platform | Android / iOS portrait 1080×1920 |
| Locale | EN default, VI optional |
| Feel | Quiet chrome, loud merge |

## Project layout

```
scenes/     boot, menu, game, settings, album
scripts/    core, game, ui, fx
assets/     fonts (OFL), ui theme
docs/       DESIGN, UI, MOBILE, STUDIO, PRIVACY
tools/      smoke_test.gd
```

## Ship checklist

- [ ] Smoke test PASS
- [ ] Portrait only, safe area
- [ ] Mute + language in Settings
- [ ] No PII (see PRIVACY.md)
- [ ] Store screenshots: menu, mid-run, merge, album, overflow
