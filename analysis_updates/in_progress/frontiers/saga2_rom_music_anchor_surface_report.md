# SaGa2 ROM Music Anchor Surface Report

Date: 2026-05-06

## Summary

The first ROM-backed music resource surface is now extracted reproducibly from the `saved_bg_music` path.

Current first anchor:

- script opcodes:
  - `$32` `PLAY_MUSIC_OR_SOUND`
  - `$47` `PLAY_DASH_OR_RESTORE_BGM`
- shared code path:
  - `HL = $7AEE`
  - `A = $0F`
  - `CALL $00D2`
  - result stored to `saved_bg_music`

This makes `$7AEE` the current safest **first music resource anchor**.

## Tool

Extractor:

- `/Users/hayashikentarou/Documents/New project 4/tools/extract_rom_music_anchor.py`

Generated outputs:

- `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/music_anchor_7aee/music_anchor.bin`
- `/Users/hayashikentarou/Documents/New project 4/build/rom_extracts/music_anchor_7aee/music_anchor.json`

## Current extracted surface

Current extracted window:

- ROM start: `0x7AEE`
- ROM end: `0x7B6D`
- length: `0x80` bytes

The extractor also emits a light segmentation using `0x9F` as a current practical delimiter candidate.

This does **not** prove that `0x9F` is the final track/event terminator semantics.
It only gives a stable first parsing surface.

## Why this is useful

This means music extraction now has a proof surface analogous to the graphics proof case:

- concrete code anchor
- concrete ROM byte window
- reproducible local extraction tool
- lightweight segment view for next decode work

## What it does not yet prove

This does not yet prove:

- exact song table semantics
- channel layout
- note/event encoding
- whether `$7AEE` is a direct song table or an intermediate selector cluster

## Best current wording

Current safest wording is:

> `$7AEE` is the first ROM-backed music resource surface visible from the `saved_bg_music` path, but it is still an anchor surface rather than a decoded song format.

## Practical next target

The next strongest target is:

> determine whether the first meaningful output from the `$7AEE` cluster is a song key, a compact command stream fragment, or a direct pointer into deeper music data.
