# SaGa2 ROM `363F -> 00AC` Copy Bridge Report

Date: 2026-05-06

## Summary

Current strongest reading is that `363F` is not yet the final selector decoder, but it **is** the first solid copy bridge into a graphics staging area:

- restore object stream pointer from `C459/C45A`
- seed destination at `DE = $8100`
- choose a banked source path via `RST $28`
- copy fixed-size blocks with `CALL $00AC`

This narrows the remaining proof target:

> prove which exact source payload `07:63BE = 0x25` selects before the block copies begin

The destination-side behavior is now largely explained.

## Concrete instruction chain

From `saga2_action_word_consumer_snippets_pass14.md`:

```text
363F: fa 59 c4 LD A,($C459)
3642: 6f       LD L,A
3643: fa 5a c4 LD A,($C45A)
3646: 67       LD H,A
3647: 11 00 81 LD DE,$8100
364A: 3e 07    LD A,$07
364C: ef       RST $28
364D: 7a       LD A,D
364E: fe 87    CP $87
3650: 28 28    JR Z,$+40
3652: 2a       LD A,(HL+)
3653: fe ff    CP $FF
3655: 28 23    JR Z,$+35
3657: e5       PUSH HL
3658: d5       PUSH DE
3659: 2e 00    LD L,$00
365B: c6 40    ADD A,$40
365D: cb 7f    BIT 7,A
365F: 28 0a    JR Z,$+10
3661: e6 7f    AND $7F
3663: f6 40    OR $40
3665: 67       LD H,A
3666: 3e 04    LD A,$04
3668: ef       RST $28
3669: 18 04    JR $+4
366B: 67       LD H,A
366C: 3e 03    LD A,$03
366E: ef       RST $28
366F: 01 00 01 LD BC,$0100
3672: cd ac 00 CALL $00AC
3675: d1       POP DE
3676: e1       POP HL
3677: 14       INC D
3678: 18 d0    JR $-48
367A: c9       RET
```

From `saga2_usage_handler_names_pass28.md`:

```text
0089: LD A,(HL+) / LD (DE),A / INC DE / DEC BC / loop
00AC: CALL $168D
00AF: CALL $0089
00B2: JP $16AA
```

## What `00AC` proves

`00AC` is a wrapper around `0089`, and `0089` is a plain `BC`-byte copy loop from `HL` to `DE`.

At `366F`, the caller sets:

- `BC = $0100`

So each successful pass through `3672` copies exactly:

- `0x100` bytes
- `256` bytes
- `16` Game Boy 2bpp tiles (`16 bytes/tile`)

## Destination range implied by the loop

`DE` is initialized once:

- `DE = $8100`

The loop exits when:

- `D == $87`

Since `D` starts at `$81` and increments once per successful block copy, the copied ranges are:

- `$8100-$81FF`
- `$8200-$82FF`
- `$8300-$83FF`
- `$8400-$84FF`
- `$8500-$85FF`
- `$8600-$86FF`

and then the loop stops before `$8700`.

So the current strongest implied preload transfer is:

- total bytes: `6 * 0x100 = 0x600`
- total tiles: `0x600 / 0x10 = 0x60 = 96 tiles`

## Strongest current conclusion

`363F -> 00AC` is the first solid **destination-side** graphics copy bridge for preload-backed map graphics.

Current safest wording:

> It stages up to `0x600` bytes into `$8100-$86FF` as six `0x100`-byte copy blocks.

## What remains unproved

This does **not** yet prove:

- how preload selector byte `07:63BE = 0x25` determines the exact source `HL`
- whether the full six-block envelope is always used by case `37`
- how the staged payload maps onto nearby object `gfx_or_type` values

## Best next proof target

The next proof target is no longer "does this path copy graphics at all?"

It is:

> which exact source payload does preload selector `0x25` choose before the `0x100`-byte block copies begin?

That is now the narrowest missing bridge between:

- metadata anchor: `07:63BE = 0x25`
- copy bridge: `363F -> 00AC`
- possible 2bpp decode target: staged bytes at `$8100-$86FF`
