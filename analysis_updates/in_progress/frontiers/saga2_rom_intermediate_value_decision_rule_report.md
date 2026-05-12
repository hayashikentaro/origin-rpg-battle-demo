# SaGa2 ROM Intermediate Value Decision Rule Report

Date: 2026-05-06

## Summary

The next ROM-side observation should be interpreted with a simple rule:

> classify the selector model by the shape of the **first looked-up intermediate value** downstream of preload entry `0x25`

This lets the remaining gap stay narrow and avoids overcommitting to final image identity too early.

## Decision rule

### 1. Table selector wins strongly if

The first downstream value is:

- fetched from a banked source path
- compact rather than final-image-sized
- then used by later normalization / family branching before block copy

Best wording:

> `0x25` is a table-mediated preload selector.

### 2. Reduced selector gains weight if

The first downstream value is:

- not a clear fetched compact key
- immediately collapsed into a family/range class
- mainly used to choose a later path such as the `A=$04 / A=$03` split

Best wording:

> `0x25` is a reduced family selector.

### 3. Direct selector strengthens if

The first downstream value is:

- already effectively the final source class/address
- not meaningfully normalized before copy
- and does not show a clear intermediate compact-key stage

Best wording:

> `0x25` behaves as a direct payload selector.

## Why this rule fits the current evidence

Current strongest evidence already shows:

- a concrete preload-list entry (`0x25`)
- a separate pre-copy selector stage
- a later normalization / family split
- a later block-copy bridge into `$8100-$86FF`

So the first decisive update does not need full payload extraction.

It only needs the earliest selector-stage output after `0x25`.

## Best current stance

Until that output is seen, current safest ranking remains:

1. table selector
2. reduced selector
3. direct selector

## Practical next question

The next ROM question is therefore:

> is the first downstream output after `0x25` a fetched compact key, a reduced family code, or already a direct source-class value?
