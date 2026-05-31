# SaGa2 ROM Block Preview Validation Report

Date: 2026-05-06

## Summary

The first proof extraction now produces not only one staged tilesheet, but also **six block-level previews** that are easier to compare against nearby object-facing ids.

This makes the current ROM work more practical:

- staging proof is done
- validation surface is visible
- remaining gap stays on selector-side exact decode

## Output set

Proof output directory:

- `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/map0_preload37/`

Files:

- staged bytes:
  - `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/map0_preload37/stage.bin`
- manifest:
  - `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/map0_preload37/manifest.json`
- full staged tilesheet:
  - `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/map0_preload37/tiles.png`
- per-block previews:
  - `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/map0_preload37/blocks/`

## Current block set

The six current block previews correspond to:

1. object byte `00` -> transformed `40` -> bank `03`, source `0x4000`
2. object byte `0F` -> transformed `4F` -> bank `03`, source `0x4F00`
3. object byte `43` -> transformed `83` -> bank `04`, source `0x4300`
4. object byte `06` -> transformed `46` -> bank `03`, source `0x4600`
5. object byte `F8` -> transformed `38` -> bank `03`, source `0x3800`
6. object byte `91` -> transformed `D1` -> bank `04`, source `0x5100`

Each block preview is emitted as a `32x32` 2bpp sheet (16 tiles = one `0x100` block).

## Why this is useful

This means the first proof case can now be validated at two levels:

1. structural level
   - six `0x100` blocks staged into `$8100-$86FF`

2. visual level
   - each staged block can be inspected independently against nearby object-facing ids

So the next selector-side work does not need to argue from raw bytes alone.

## Best current wording

Current safest wording is:

> the first proof case now has a block-level visual validation surface, while the remaining undecided issue is still the selector-side meaning of preload entry `0x25`.
