# Battle Scene Generated Artifacts

## Status

mixed

## Committed Artifacts

- `../../binary_analysis/saga2_rom_binary_analysis_package.md`
- `../../../build/binary_analysis/saga2_rom_binary_analysis_package.json`
- `../../../build/binary_analysis/saga2_rom_full.hex.txt`

## Untracked / Local Artifacts Seen In This Workspace

These are useful but should be reviewed before committing:

- `../../../build/rom_extracts/map0_preload37/`
- `../../../build/rom_extracts/music_anchor_7aee/`

## Tools

- `../../../tools/build_binary_analysis_package.py`
- `../../../tools/extract_rom_preload_stage.py`
- `../../../tools/extract_rom_music_anchor.py`

## Notes

- `build/binary_analysis/` currently contains committed analysis artifacts.
- `build/rom_extracts/` currently appears to contain local extraction products; decide whether they are canonical artifacts before relying on them from scene packs.
- Avoid committing ROM files. Store derived analysis packages, manifests, and small previews instead.
