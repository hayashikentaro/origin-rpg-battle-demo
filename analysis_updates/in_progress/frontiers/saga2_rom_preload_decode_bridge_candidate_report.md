# saga2 rom preload decode bridge candidate

## What became visible

the first plausible decode bridge from preload-side metadata to actual graphics handling is now visible around:

- `00:338D`
- `00:363F`

## Upstream setup

existing disassembly already shows the header parser writing:

- `C452`
- `C453`
- `C454`
- `C455`
- `C459`
- `C45A`

from the variable map header region.

for the first proof case (`header 63B1`), this is the same family that carries:

- `bit7_has_gfx_preload_C452 = 1`
- `gfx_preload = [37]`
- object stream start `63C0`

## Decoder-side candidate

the strongest candidate bridge currently visible is:

- `338D: LD A,($C452)`
- branch on preload-present flag
- `3394: CALL $363F`

inside `363F`:

- `LD A,($C459)` / `LD A,($C45A)` restores the object-stream pointer
- `LD DE,$8100`
- `LD A,$07`
- `RST $28`

then the routine continues with additional banked reads:

- `A=$04` via `RST $28` on one branch
- `A=$03` via `RST $28` on the other branch

and ends each object-sized step with:

- `CALL $00AC`

## Current safest reading

this is not yet a proven sprite extractor, but it is the first strong candidate for:

- preload-present object graphics setup
- object-stream-driven banked graphics fetch
- transfer into a tile-like destination beginning at `$8100`

## Why this matters

the first proof target is no longer only the byte `07:63BE = 0x25`.
we now also have a plausible consumer-side bridge:

- preload/header state -> `C452..C45A`
- object stream pointer -> `363F`
- banked reads -> `$8100`

## Practical next step

the next ROM-side proof should answer:

**does `363F` consume the object stream under the preload-present path in a way that turns `gfx_preload = [37]` into actual tile payload at or near `$8100`?**
