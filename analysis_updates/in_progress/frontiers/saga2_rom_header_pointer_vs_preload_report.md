# SaGa2 ROM Header Pointer vs Preload Report

Date: 2026-05-06

## Summary

Current strongest reading is that the header parser cleanly separates:

- pointer-building for the action table / object stream
- preload metadata presence

This matters for image extraction because it means preload selector byte `07:63BE = 0x25` should currently be treated as **parallel metadata**, not as a byte that directly participates in the `C459/C45A` object-stream pointer calculation.

## Header parser evidence

From `1CC9-1D09`:

```text
1CC9: LD A,(DE)
1CCC: AND $0F
1CCE: LD ($C451),A
1CD1: LD A,$80
1CD3: AND C
1CD4: LD ($C452),A      ; preload-present flag
1CD7: LD A,$40
1CD9: AND C
1CDA: LD ($C453),A
...
1CF5: LD A,(DE)
1CF6: LD L,A            ; action_count
...
1CF8: LD A,E
1CF9: LD ($C457),A      ; action table pointer low
1CFC: LD A,D
1CFD: LD ($C458),A      ; action table pointer high
1D00: LD H,$00
1D02: ADD HL,HL
1D03: ADD HL,DE         ; action_count * 2 + current DE
1D05: LD ($C459),A      ; object stream pointer low
1D09: LD ($C45A),A      ; object stream pointer high
```

The important split is:

- `C452` is produced from packed header flags
- `C459/C45A` is produced from `action_count * 2 + DE`

So the current strongest reading is that `C459/C45A` is driven by:

- the already-positioned post-header `DE`
- the action table length

and **not** by interpreting preload selector value `0x25` as part of the pointer arithmetic itself.

## Match with map-system report

`saga2_map_system_pass12_correction_report.md` states:

- if header flag bit7 set: graphics preload list
- then object stream

Combined with the parser above, the current safest interpretation is:

1. header flags record whether a preload list exists (`C452`)
2. action table/object stream pointers are still computed structurally
3. preload payload selection remains a separate metadata concern

## Why this helps the current proof target

This removes one false lead:

- we do **not** currently need to explain `0x25` as part of the object-stream pointer math

Instead, the unresolved gap remains:

> how `0x25` participates in the pre-copy selector stage that chooses the source-side graphics payload later staged by `363F -> 00AC`

## Best current wording

Current safest wording is:

> `C459/C45A` is structural object-stream pointer state, while preload selector `0x25` remains parallel graphics metadata gated by `C452`.

## Practical next target

The next narrow target is therefore unchanged but sharper:

> find where preload metadata value `0x25`, after being admitted by `C452`, is reduced into the exact source-side payload that the `$8100-$86FF` copy bridge consumes.
