# saga2 rom character image entry

## What exists now

- ROM file exists at:
  - `/Users/hayashikentarou/Documents/saga-analyze/rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- object/NPC stream parse already exists at:
  - `/Users/hayashikentarou/Documents/saga-analyze/reports/saga2_npc_object_stream_pass12.csv`
- integrated map/object parse already exists at:
  - `/Users/hayashikentarou/Documents/saga-analyze/reports/saga2_maps_pass18_report.md`

## What can already be read from ROM-side analysis

- per-object `b0_gfx_or_type`
- `b0_low5`
- object record addresses such as `07:4807`, `07:480D`, ...
- map/header fields including `gfx_preload_count`

this means the current analysis is already good enough to identify **candidate character graphic ids** in object streams.

## What is still missing for actual images

the repo does not yet contain a verified path from:

- `b0_gfx_or_type` / preload ids

to:

- exact ROM graphics bank
- exact 2bpp tile address/layout
- final decoded sprite sheet / PNG

## Current blocker

the blocker is no longer "where is the ROM?".
the blocker is:

**missing gfx-id -> tile-data decode path**

## Safest current output

right now we can safely say:

- ROM-backed character graphic ids are visible
- actual character images are not yet extracted
- next work should build the gfx-id -> tile-data decode bridge

## Practical next step

build an extractor that starts from:

1. `saga2_npc_object_stream_pass12.csv`
2. candidate `b0_gfx_or_type` values
3. ROM file

and then proves the corresponding graphics bank/tile decode path before attempting PNG output
