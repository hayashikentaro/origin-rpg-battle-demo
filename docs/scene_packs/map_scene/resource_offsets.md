# Map Scene Resource Offsets

## Status

in_progress

## Current Map / Preload Anchors

- `07:63C0`: map0 object/preload stream opening used by the current preload proof case.
- `03:4000`: first map preload block source in the current proof extraction.
- `04:xxxx`: alternate preload block bank selected by transformed object-byte high bit in the current proof extraction.
- `$8100`: staging destination base in the current first proof extraction tool.

## Current Preload Working Model

For the current map0 proof case:

```txt
object_byte = *(07:63C0 + index)
transformed = object_byte + 0x40
if transformed & 0x80:
  source_bank = 0x04
  source_high = (transformed & 0x7F) | 0x40
else:
  source_bank = 0x03
  source_high = transformed
source_addr = source_high << 8
copy 0x100 bytes to staged VRAM-like output
```

This is a proof-case extraction model, not a complete map renderer.

## Tool

```bash
SAGA2_ROM_PATH="/path/to/SaGa 2 - Hihou Densetsu (J) (V1.1).gb" \
python3 -B tools/extract_rom_preload_stage.py
```

## Historical References

- `../../../analysis_updates/archive/frontier_history/saga2_rom_first_proof_extraction_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_rom_block_preview_validation_report.md`
- `../../../analysis_updates/archive/frontier_history/saga2_rom_preload_decode_flow_report.md`
