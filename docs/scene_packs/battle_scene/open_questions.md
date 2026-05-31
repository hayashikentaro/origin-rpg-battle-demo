# Battle Scene Open Questions

## Highest Priority

- Separate committed/canonical artifacts from local generated artifacts under `build/`.
- Decide whether `build/rom_extracts/` should be committed, regenerated, or moved under a clearer artifact namespace.
- Define a scenario-state file format for no-emulator battle replay.
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

## Repository Organization

- Move or mirror scene-relevant current knowledge into scene packs.
- Keep broad historical logs under `analysis_updates/archive/`.
- Avoid making future sessions read `analysis_updates/in_progress/frontiers/` unless a scene pack points to a specific file.
