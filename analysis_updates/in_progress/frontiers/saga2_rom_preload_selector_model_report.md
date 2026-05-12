# SaGa2 ROM Preload Selector Model Report

Date: 2026-05-06

## Summary

Current safest selector model is now:

```text
concrete preload-list entry byte
  -> pre-copy selector stage
  -> source-side graphics payload choice
  -> 363F/00AC block staging into $8100-$86FF
```

For the first proof case, the local bytes support treating `0x25` as a **list element value**, not as part of pointer arithmetic and not as part of the object stream itself.

## First proof case boundary

Relevant bytes:

```text
0x1E3BE: 25 ff 00 0f 43 06 f8 91
0x1E3BF: ff 00 0f 43 06 f8 91 18
0x1E3C0: 00 0f 43 06 f8 91 18 0b
```

Current strongest boundary reading:

- `0x25` = concrete preload-list entry
- `0xFF` = preload-list terminator
- `0x00 0x0F 0x43 0x06 ...` = object-stream opening bytes

So `0x25` is currently best understood as:

- neither object-stream payload
- nor object-stream pointer input
- but a standalone selector-like metadata element immediately upstream of the object stream

## Why direct-vs-table remains open

What remains unresolved is not whether `0x25` is a selector-like value, but **how** it selects.

Current possibilities still open:

1. direct selector  
   `0x25` directly indexes/chooses a source-side bank or payload class

2. table selector  
   `0x25` first looks up another compact value, then that value chooses the payload

3. reduced selector  
   `0x25` is first reduced by range/family logic before final source `HL` choice

## Current safest ranking

At this stage, the current safest ranking is:

1. **table selector**
2. **reduced selector**
3. **direct selector**

Reason:

- the copy bridge itself already performs multiple banked reads (`A=$07`, then `A=$04` or `A=$03`)
- this makes a compact source-side decode step more plausible than a naive one-byte direct payload mapping
- we still do not have local proof of the exact intermediate table/reduction

## Best current wording

Current safest wording is:

> `0x25` is best treated as a concrete preload-list selector element whose exact source-payload mapping is still unresolved, with table-mediated selection currently the strongest hypothesis.

## Practical next target

The narrowest next proof target is therefore:

> determine whether preload entry `0x25` is consumed as a table key, a reduced family code, or a direct payload selector before `363F -> 00AC` begins block staging.
