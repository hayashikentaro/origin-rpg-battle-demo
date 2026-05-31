# Music Audio Resource Offsets

## Status

in_progress

## Current Music Anchor

- `0x7AEE`: local music anchor extraction range.
- Default extraction length: `0x80` bytes.
- Current report wording ties this to an `opcode $47 / $32` path that uses `HL=$7AEE` before `CALL $00D2` and a saved BGM write.

## Current Interpretation

- `0x7AEE` is useful as an audio-resource investigation anchor.
- It is not yet confirmed as a complete BGM table boundary.
- Raw extracted bytes should remain local unless converted into a small decoded manifest.

## Tool

```bash
SAGA2_ROM_PATH="/path/to/SaGa 2 - Hihou Densetsu (J) (V1.1).gb" \
python3 -B tools/extract_rom_music_anchor.py
```

## Historical References

- `../../../analysis_updates/archive/frontier_history/saga2_rom_music_anchor_surface_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_rom_music_decode_plan_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_rom_music_stable_atom_candidates_report.md`
