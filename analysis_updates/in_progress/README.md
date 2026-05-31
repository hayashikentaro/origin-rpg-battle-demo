# In-Progress SaGa2 Analysis

This directory is for active unresolved questions, not broad historical search logs.

Read scene packs first when the question is scene-specific:

- `../../docs/scene_packs/battle_scene/README.md`
- `../../docs/scene_packs/map_scene/README.md`
- `../../docs/scene_packs/monster_graphics/README.md`
- `../../docs/scene_packs/music_audio/README.md`
- `../../docs/scene_packs/text_system/README.md`

## Current Open Questions

- Acquire and analyze direct body of `5F22`.
- Compare direct body of `5F22` with `5E77`.
- Confirm whether `5F22` is merely global setup or participates in hidden/shared state initialization.
- Reconnect `6157` as downstream apply/staging after `611C`.
- Continue search for `C2F6` producer / writer path.
- Keep normal attack entry gap separate from confirmed battle-loop model until resolved.
- Fill battle scenario fixtures with concrete runtime state when available.

## Active Topic Directories

- `c2xx/` - C2xx producer/writer and hidden/shared state questions.
- `gaps/` - current missing links and unresolved boundaries.
- `loop_boundary/` - 5F22, 5E77, 611C, and 6157 loop-boundary questions.
- `normal_attack/` - normal attack entry gap.
- `rng_open_questions/` - RNG questions that are not confirmed implementation truth.

## Historical Frontier Logs

The former broad `frontiers/` directory has moved to:

- `../archive/frontier_history/`

Do not read those files by default. Use them only when a scene pack, active topic file, or confirmed summary links to a specific report.
