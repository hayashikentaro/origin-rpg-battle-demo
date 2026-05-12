# saga2 rom gfx preload bridge

## What was confirmed

- the ROM file is available:
  - `/Users/hayashikentarou/Documents/saga-analyze/rom/SaGa 2 - Hihou Densetsu (J) (V1.1).gb`
- map/object integration is already available through:
  - `/Users/hayashikentarou/Documents/saga-analyze/reports/saga2_maps_pass18_sample.json`
  - `/Users/hayashikentarou/Documents/saga-analyze/reports/saga2_npc_object_stream_pass12.csv`

## Bridge that now exists

we can already observe, on the same parsed map records:

- header-level `gfx_preload_count`
- header-level `gfx_preload`
- per-object `gfx_or_type`

for example, sample maps with `bit7_has_gfx_preload_C452` set show:

- map `0`, header `63B1`, `gfx_preload = [37]`
- first object gfx ids include:
  - `0`
  - `24`
  - `17`
  - `34`
  - `36`
  - `14`
  - `7`

## What this means

the missing path is no longer map/object discovery.
the missing path is the decode bridge from:

- preload ids and/or object `gfx_or_type`

to:

- actual graphics bank
- exact 2bpp tile layout
- rendered PNG output

## Current safest conclusion

we now have a practical **metadata bridge** for character-image extraction, but not yet a **tile-data decode bridge**.

## Practical next step

the next extractor should start from:

1. maps with non-empty `gfx_preload`
2. their first few object `gfx_or_type` values
3. ROM bank reads around the implied graphics preload path

and prove one object id -> one tile block decode path before attempting broad image export.
