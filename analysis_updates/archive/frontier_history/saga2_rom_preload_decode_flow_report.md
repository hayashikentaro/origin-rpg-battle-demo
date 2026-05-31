# saga2 rom preload decode flow

## Current strongest decode flow

for the first proof case, the strongest current candidate flow is:

1. header parser populates `C452..C45A`
2. `338D` checks `C452`
3. preload-present path calls `363F`
4. `363F` restores object-stream pointer from `C459/C45A`
5. `363F` seeds destination with `DE = $8100`
6. `RST $28` is used for banked reads with:
   - `A = $07`
   - then branch-dependent `A = $04` or `A = $03`
7. `CALL $00AC` finalizes one object-sized transfer step

## Why `$8100` matters

`$8100` is the first concrete tile-like destination currently visible in the path.

this makes the current proof target sharper:

- not just "graphics are loaded somewhere"
- but "the preload-present object path appears to move banked payload toward `$8100`"

## Why `00AC` matters

existing handler summaries already show:

- `00AC`
- then `0089`

as a rendering/banked-copy style helper chain.

this makes `363F -> 00AC` the strongest current candidate for:

- converting preload/object metadata
- into a concrete copied graphics payload

## Current safest conclusion

we still do not have the exact tile decode, but the current bridge is now specific enough to say:

**the first proof target is a preload-present object-stream graphics copy path ending in object-sized transfer toward `$8100`.**

## Practical next proof

the next proof should answer one narrow question:

**what exact bytes does the `363F` path copy toward `$8100` for the first proof case with `07:63BE = 0x25`?**
