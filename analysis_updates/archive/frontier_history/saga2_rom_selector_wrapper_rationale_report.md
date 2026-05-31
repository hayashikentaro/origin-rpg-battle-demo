# SaGa2 ROM Selector Wrapper Rationale Report

Date: 2026-05-06

## Summary

Current safest selector ranking stays:

1. table selector
2. reduced selector
3. direct selector

This report fixes the wrapper-level rationale for that ordering.

## Wrapper structure already favors indirection

From the existing bank-switch helper analysis:

- `RST $28` is the thin swap entry
- `00D2` is a 1-byte banked read helper
- `00B5 / 00BC / 00C3 / 00CA` are typed banked bulk read/copy wrappers

In particular:

```text
00CA: RST $28 ; PUSH AF ; CALL $00AC ; ...
```

and inside the preload copy path:

```text
364A: LD A,$07
364C: RST $28
...
3666: LD A,$04
3668: RST $28
...
366C: LD A,$03
366E: RST $28
3672: CALL $00AC
```

So the current path is already visibly built from:

- bank-switch wrappers
- staged banked reads
- a later banked bulk copy

This is structurally more compatible with indirection than with a naive one-byte direct image selector.

## Why table-first remains safest

The wrapper stack suggests the path expects:

- one compact upstream selector
- one or more banked lookups
- later normalization/family routing
- then the final bulk copy

That is exactly the shape of a **table-mediated selector**.

## Why direct remains weakest

A direct-selector model would fit best if the path looked like:

- `0x25` directly chooses one source class/address
- minimal or no intermediate normalization
- copy starts immediately from that final source

But current local structure instead shows:

- repeated bank switching
- intermediate byte handling at `3652+`
- later family/path split before the bulk copy

So direct remains the weakest fit.

## Best current wording

Current safest wording is:

> the wrapper stack around `RST $28` and `00AC` makes the preload path structurally indirection-friendly, which is why table selector remains the strongest current model for preload entry `0x25`.

## Practical consequence

This means the next decisive observation should still target:

> the first selector-stage output after `0x25`

not the final staged image bytes themselves.
