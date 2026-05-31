# Battle Scene Graphics

## Status

working_model

## Current Model

The battle scene uses static enemy background/tilemap rendering first, then later visual/effect helpers for animation or staging.

Current anchors:

- `0F:5D20-5D56`: display setup candidate.
- `0F:5DC9-5E65`: static enemy BG tilemap drawing.
- `0F:5DE1`: static monster BG rectangle writer.
- `0F:5E4D`: computes tilemap destination from `D936/D939`.
- `0D:525B-52DF`: prepares enemy graphics metadata.
- `0D:5302-533D`: graphics source pointer math.
- `04:4700`: copied to VRAM `$9700` by battle display setup candidate.

## Known Derived Artifacts

- `build/rom_extracts/map0_preload37/` is a map preload proof extraction, not a battle-scene proof.
- `build/binary_analysis/saga2_rom_binary_analysis_package.json` includes common offsets and selected dumps.

## Implementation Relevance

- Treat static monster rendering separately from later OAM/effect animation.
- Do not infer repeated enemy count from repeated graphics. Current working model says counted enemy members are battle state; static graphics draw one rectangle per present enemy group.

## Open Graphics Questions

- Final battle monster source metadata names.
- Exact runtime values for `D936/D939` in a chosen battle.
- Full effect/OAM path after static background draw.
- Exact relationship between party-side attack animation and the static battle BG setup.

## Historical References

- `../../../analysis_updates/archive/frontier_history/saga2_rom_gfx_preload_bridge_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_rom_image_first_proof_case_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_battle_runtime_entry_report.md`
