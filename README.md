# SaGa2 Analysis Workspace

This repository is a working analysis and porting-spec workspace for SaGa2 reverse engineering.

It keeps implementation-facing facts, small generated analysis artifacts, and replay helpers close together while avoiding large local extraction outputs and unrelated application prototypes.

## Read First

1. `docs/scene_packs/README.md`
2. `docs/scene_packs/battle_scene/README.md`
3. `docs/artifact_boundaries.md`
4. `analysis_updates/README.md`
5. `AGENTS.md`

## Main Areas

- `analysis_updates/`: confirmed, in-progress, and archived reverse-engineering notes.
- `docs/scene_packs/`: small scene-specific entrypoints for future GPT/Codex sessions.
- `docs/binary_analysis/`: compact ROM binary analysis summaries.
- `build/binary_analysis/`: committed derived ROM analysis artifacts used by tools.
- `core/`: TypeScript implementation-facing logic.
- `tools/`: extraction, validation, and scenario evaluation helpers.
- `assets/fonts/`: small font assets useful for text/window verification.

## Local Inputs

The original ROM is not committed. Tools that need it accept `--rom` or `SAGA2_ROM_PATH`.

Example:

```bash
SAGA2_ROM_PATH="/path/to/SaGa 2 - Hihou Densetsu (J) (V1.1).gb" \
python3 -B tools/extract_rom_preload_stage.py
```

## Common Checks

```bash
python3 -B tools/update_directory_indexes.py --check
python3 -B tools/validate_battle_scenarios.py
python3 -B tools/evaluate_battle_scenario.py --limit 4
```

## App Prototype Staging

Unrelated Godot/C# application prototype files have been moved out of this repository to:

```txt
/Users/hayashikentarou/Projects/origin-rpg-battle-demo-app-staging
```

That staging directory is intended as the starting point for a separate repository.
