# SaGa2 ROM Music Composite Chunk Decomposition Report

Date: 2026-05-08

## Summary

Current strongest local decomposition rule is:

- chunks containing `1F 1F` can already be treated as **strong composite-chain candidates**
- chunks containing only single `1F` remain **weaker phrase-fragment candidates**

This is enough to move one step beyond atom recurrence without overclaiming full music grammar.

## Strongest case: segment 15

Current segment `15` core:

```text
03 01 02 03 23 1f 1f 41 42 43 63 1f 1f 00 20
```

Under the current `1F 1F` split rule, it decomposes into:

```text
03 01 02 03 23
1f 1f
41 42 43 63
1f 1f
00 20
```

This is the strongest current evidence that `1F 1F` can act as a true composite-chain linker rather than a mere byte coincidence.

## Comparison with weaker cases

### Segment 13

```text
02 03 23 1f 00 20 1f 43 63 1f 40 60 00 20
```

This still uses only single `1F`, so current safest reading is:

- phrase/event fragment
- but not yet a strongly decomposable atom-chain under the same rule

### Segment 17

```text
04 01 02 1f 03 23 1f 41 42 1f 43 63
```

Likewise:

- structurally phrase-like
- but only weakly decomposable at current evidence level

## Strongest implication

This now supports a two-tier decomposition model:

1. **strong composite-chain tier**
   - uses `1F 1F`
   - example: segment `15`

2. **weak phrase-fragment tier**
   - uses only single `1F`
   - examples: segments `13`, `17`, and the first long chunk

## Best current wording

Current safest wording is:

> `1F 1F` already looks strong enough to serve as a composite-chain linker, while single `1F` is still better treated as weaker intra-fragment punctuation/control.

## Practical next target

The next strongest local question is:

> can `03 01 02 03 23`, `41 42 43 63`, and `00 20` each be promoted from chunk fragments to reusable sub-atoms inside the strong `1F 1F` chain of segment `15`?
