# Monster Graphics Resource Offsets

## Status

working_model

## Battle Display Anchors

- `0F:5D20-5D56`: battle display setup candidate.
- `0F:5DC9-5E65`: static enemy BG tilemap drawing.
- `0F:5DE1`: static monster BG rectangle writer.
- `0F:5E4D`: tilemap destination computation from `D936/D939`.
- `0D:525B-52DF`: enemy graphics metadata preparation.
- `0D:5302-533D`: graphics source pointer math.
- `04:4700`: source copied to VRAM `$9700` by the battle display setup candidate.

## Current Interpretation

- Static monster rendering should be treated separately from effect/OAM animation.
- Repeated enemy count is battle state, not repeated graphics data.
- `D936/D939` are still runtime values that must be captured or modeled per selected battle case.

## Historical References

- `../../../analysis_updates/archive/frontier_history/saga2_rom_gfx_preload_bridge_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_rom_image_first_proof_case_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_battle_runtime_entry_report.md`
