# saga2 rom image extractor first anchor

## Candidate anchors

the first extractor can start from two candidate metadata anchors:

1. header-level `gfx_preload`
2. object-level `gfx_or_type`

## Current safest ranking

the safest first anchor is:

1. `gfx_preload`
2. `gfx_or_type`

## Why `gfx_preload` comes first

- it already appears as an explicit header-level graphics-oriented field
- it is narrower than the full object stream
- it looks closer to "what graphics should be available on this map" than `gfx_or_type` alone
- it offers a smaller first search surface for bank/tile decode

## Why `gfx_or_type` is still important

- it is the practical consumer-side id we ultimately want to render
- it gives the object-facing graphic ids that should later map into decoded tile blocks
- it is the best second anchor for validating that the preload-side decode is correct

## Practical extractor order

the safest first extractor order is:

1. pick a map with non-empty `gfx_preload`
2. prove what ROM-side graphics payload that preload id selects
3. decode one candidate tile block
4. then test whether nearby object `gfx_or_type` values reuse that decoded payload as expected

## One-line conclusion

**use `gfx_preload` as the first ROM image anchor, and `gfx_or_type` as the first validation anchor.**
