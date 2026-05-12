# SaGa2 ROM Pre-Copy Selector Stage Report

Date: 2026-05-06

## Summary

Current strongest reading is that the remaining gap for character-image extraction sits **before** the solid copy bridge at `363F -> 00AC`.

The practical split is now:

- `338D` = preload-present gate into graphics/object staging
- `363F -> 00AC` = destination-side copy bridge into `$8100-$86FF`

So the next missing proof is best described as:

> the pre-copy selector stage that turns preload metadata into the exact source `HL` payload later copied by `363F`

## `338D` gate

From `saga2_action_word_consumer_snippets_pass14.md`:

```text
338A: 11 00 c6 LD DE,$C600
338D: fa 52 c4 LD A,($C452)
3390: b7       OR A
3391: ca 3d 34 JP Z,$343D
3394: cd 3f 36 CALL $363F
3397: 11 00 c6 LD DE,$C600
339A: 2a       LD A,(HL+)
339B: fe ff    CP $FF
339D: ca 3d 34 JP Z,$343D
33A0: fe 80    CP $80
...
```

This confirms:

- `C452` is the graphics-preload-present flag
- `338D` is the narrow gate that decides whether the preload-backed object/graphics path is used
- `CALL $363F` happens before the subsequent object-stream flavored reads continue at `339A+`

## Header-side state that feeds the gate

From `saga2_map_system_pass12_correction_report.md`:

- packed header flags bit7 -> `C452`, graphics preload list present
- object/NPC stream pointer -> `C459/C45A`

From earlier reports for the first proof case:

- map `0`
- header `63B1`
- object stream `63C0`
- preload selector byte at `07:63BE` = `0x25` (decimal `37`)

So the first proof case already gives us:

- preload-present state in `C452`
- object-stream pointer in `C459/C45A`
- concrete preload selector byte in the same header

## What `363F` already solves

The previous bridge report fixed the destination side:

- restore `HL` from `C459/C45A`
- seed `DE = $8100`
- choose banked source path with `RST $28`
- copy six `0x100`-byte blocks at most through `CALL $00AC`

So `363F -> 00AC` already explains:

- where staged bytes land
- how much is copied per block
- total envelope size (`0x600` bytes, up to 96 tiles)

## What remains unresolved

The unresolved point is now strictly narrower:

- not whether the preload path stages graphics
- not whether `$8100-$86FF` is the destination envelope
- but **how preload selector `0x25` determines the exact source-side payload that the copy bridge consumes**

In other words, the unresolved bridge is:

```text
07:63BE = 0x25
    -> preload-present gate at 338D
    -> exact source-side selector/materialization
    -> 363F/00AC copy into $8100-$86FF
```

## Best current wording

Current safest wording is:

> `338D` is the preload-present entry gate, while the still-missing proof is the pre-copy selector stage that maps header preload byte `0x25` onto the exact source `HL` payload later staged by `363F -> 00AC`.

## Practical next target

The most practical next proof target is now:

> identify whether `0x25` is consumed directly, table-decoded, or reduced into a narrower bank/source selector before `363F` begins its `0x100`-byte copy blocks.

That is the narrowest remaining gap before actual 2bpp image extraction can begin.
