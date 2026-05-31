# Music Audio Artifacts

## Status

working_model

## Local Artifacts

The current music anchor extraction writes under:

- `build/rom_extracts/music_anchor_7aee/`

Expected local outputs:

- `music_anchor.bin`
- `music_anchor.json`

These are ignored by default and should stay local until the anchor is decoded into a small durable manifest.

## Promotion Decision

Do not commit raw music anchor bytes yet.

Promote only after the output becomes one of:

- a decoded command-boundary manifest
- a compact table of stable music atoms
- a small fixture linked from an active audio question

## Regeneration

```bash
SAGA2_ROM_PATH="/path/to/SaGa 2 - Hihou Densetsu (J) (V1.1).gb" \
python3 -B tools/extract_rom_music_anchor.py
```

## Last Tool Check

- Verified locally after the extractor was changed to use `SAGA2_ROM_PATH` and relative output.
- Generated outputs remain ignored under `build/rom_extracts/`.
