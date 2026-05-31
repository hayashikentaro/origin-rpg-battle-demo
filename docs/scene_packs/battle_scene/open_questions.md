# Battle Scene Open Questions

## Highest Priority

- Decide which, if any, local `build/rom_extracts/` outputs should be promoted to small committed fixtures.
- Add committed scenario fixtures once concrete runtime values are known.
- Prove visible command label to selected `CFF0` join.
- Resolve normal attack entry and the `S31 -> 0C:50CC` route.

## Graphics

- Confirm final monster graphics metadata fields.
- Capture or model concrete `D936/D939` values for chosen battle cases.
- Separate static BG tilemap rendering from OAM/effect animation.

## Text / Window

- Complete battle message stream ownership.
- Finish low control-byte semantics for `00:070C`.
- Keep dakuten/handakuten composition aligned with ROM tables.

## Runtime State

- Determine how `$C2A0` is produced in battle contexts.
- Model seed05 entry value for deterministic replay.
- Confirm whether phase0A `CF94/CF95` writes can feed later S00 routes.
- Fill `scenario_state_format.md` fields from either a live capture or a fuller no-emulator state model.

## Repository Organization

- Move or mirror scene-relevant current knowledge into scene packs.
- Keep broad historical logs under `analysis_updates/archive/`.
- Avoid making future sessions read `analysis_updates/archive/frontier_history/` unless a scene pack points to a specific file.
