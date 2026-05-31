# SaGa2 ROM First Proof Extraction Report

Date: 2026-05-06

## Summary

The first ROM-backed extraction proof now runs end-to-end as a reproducible local tool:

- input:
  - map `0`
  - header `63B1`
  - preload entry `07:63BE = 0x25`
- path model:
  - `338D` preload-present gate
  - `363F -> 00AC` staging bridge
- output:
  - staged bytes
  - manifest
  - 2bpp tilesheet preview

## Tool

Local extractor:

- `/Users/hayashikentarou/Documents/New project 4/tools/extract_rom_preload_stage.py`

Default ROM input:

- `/Users/hayashikentarou/Documents/saga-analyze/rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`

## Generated proof outputs

Generated files:

- `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/map0_preload37/stage.bin`
- `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/map0_preload37/manifest.json`
- `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/map0_preload37/tiles.png`

## Current extracted staging result

The proof extractor currently stages:

- destination range: `$8100-$86FF`
- byte count: `1536`
- tile count: `96`

Block sources:

1. bank `03`, source `0x4000` -> dest `0x8100`
2. bank `03`, source `0x4F00` -> dest `0x8200`
3. bank `04`, source `0x4300` -> dest `0x8300`
4. bank `03`, source `0x4600` -> dest `0x8400`
5. bank `03`, source `0x3800` -> dest `0x8500`
6. bank `04`, source `0x5100` -> dest `0x8600`

These are derived by applying the current `363F` local rule to the opening object-stream bytes after preload-list tail `25 FF`.

## What this proves

This proves a practical, reproducible first extraction path:

- the first proof case can be staged from the ROM now
- the `363F -> 00AC` bridge is strong enough to generate a concrete tilesheet
- the current blocker is no longer "can we get image-like bytes at all?"

## What it does not yet prove

This does not yet prove:

- exact semantic naming of preload selector `0x25`
- whether the staged tilesheet is the final intended character-image grouping
- how to generalize cleanly across all preload entries/maps

## Best next target

The next strongest target remains:

> identify the first selector-stage output after preload entry `0x25` so the selector model can move from table/reduced ranking to a stronger exact decode claim
