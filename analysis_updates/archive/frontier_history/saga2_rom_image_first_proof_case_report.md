# saga2 rom image first proof case

## Recommended first proof case

the safest first proof case for ROM-backed character image extraction is:

- map `0`
- header `63B1`
- `gfx_preload = [37]`

map `3` reuses the same header, so it is effectively the same starter case.

## Why this case is best

- non-empty `gfx_preload`
- already present in the sample integration data
- object stream is directly visible
- many nearby object `gfx_or_type` values are available for later validation

## Immediate object-side context

for header `63B1`, the first visible object gfx ids include:

- `00`
- `18`
- `11`
- `22`
- `24`
- `0E`
- `07`
- `5F`

and the object stream starts at:

- `07:63C0`

## What this case should prove

the first extractor does not need to solve every sprite.
it only needs to prove:

1. what `gfx_preload = [37]` selects on the ROM side
2. which graphics bank/tile payload that implies
3. whether at least one nearby object `gfx_or_type` can be explained by that decoded payload

## Safe output

current safest first proof target is:

**header `63B1` with preload `37`, then validate against the first nearby object gfx ids.**
