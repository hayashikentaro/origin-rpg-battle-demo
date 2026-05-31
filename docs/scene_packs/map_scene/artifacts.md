# Map Scene Artifacts

## Status

working_model

## Local Artifacts

The current map preload proof extraction writes under:

- `build/rom_extracts/map0_preload37/`

Expected local outputs:

- `stage.bin`
- `manifest.json`
- `tiles.png`
- `blocks/*.png`

These are ignored by default and should stay local unless a small, reviewed subset is promoted.

## Promotion Decision

Do not commit current generated PNG or `.bin` outputs yet.

Promote only a compact manifest or fixture after it answers a specific map question, such as:

- a verified object stream entry
- a minimal source block address list
- a decoded map preload selector table

## Regeneration

```bash
SAGA2_ROM_PATH="/path/to/SaGa 2 - Hihou Densetsu (J) (V1.1).gb" \
python3 -B tools/extract_rom_preload_stage.py
```

## Last Tool Check

- Verified locally after the extractor was changed to use `SAGA2_ROM_PATH` and relative output.
- Generated outputs remain ignored under `build/rom_extracts/`.
