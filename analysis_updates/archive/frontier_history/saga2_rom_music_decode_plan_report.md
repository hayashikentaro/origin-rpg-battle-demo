# SaGa2 ROM Music Decode Plan Report

Date: 2026-05-06

## Summary

The music-resource plan can now be compressed into one proof path:

1. fix `$7AEE` as first anchor
2. classify first meaningful output
3. keep decoding local and single-case
4. avoid broad generalization until one chunk is better explained
5. only then widen to multi-song / multi-resource extraction

## Current fixed points

- anchor path:
  - opcode `$32/$47`
  - `HL = $7AEE`
  - `A = $0F`
  - `CALL $00D2`
  - save to `saved_bg_music`
- extraction tool:
  - `/Users/hayashikentarou/Documents/New project 4/tools/extract_rom_music_anchor.py`
- proof output:
  - `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/music_anchor_7aee/music_anchor.bin`
  - `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/music_anchor_7aee/music_anchor.json`

## Current best reading

The first meaningful output is currently best read as:

- **compact command stream fragment**

not as:

- direct pointer surface
- or mere song-key indirection only

## What “do all” means at this stage

At the current evidence level, “do all” does **not** mean full music extraction yet.

It means:

1. fix the first proof anchor
2. classify its first visible shape
3. define the next decode target
4. set the stop line before over-generalizing

That is now done.

## Stop line

Do not yet claim:

- final song format
- channel map
- exact note/event grammar
- full BGM/SFX table

until at least one local chunk in `$7AEE` is better decoded than simple `0x9F` segmentation.

## Next precise target

The next precise target is:

> determine whether one `0x9F`-terminated chunk from `$7AEE` behaves like a stable music phrase/event fragment.

## Best current wording

Current safest wording is:

> the first music proof case is anchored and extracted; the next work is local chunk semantics, not broad soundtrack extraction.
