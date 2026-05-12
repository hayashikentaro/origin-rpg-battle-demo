# SaGa2 ROM Selector Ranking Rationale Report

Date: 2026-05-06

## Summary

Current selector ranking remains:

1. **table selector**
2. **reduced selector**
3. **direct selector**

This report fixes the local rationale for that ranking.

## Local evidence from the copy bridge

From `363F`:

```text
364A: 3e 07    LD A,$07
364C: ef       RST $28
...
3652: 2a       LD A,(HL+)
3653: fe ff    CP $FF
...
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
```

The strongest practical reading is:

- the path already performs a staged decode
- the first banked read (`A=$07`) does not immediately become the copied payload
- instead it yields a byte that is then normalized and split into one of two later banked source paths (`A=$04` or `A=$03`)

That makes the source-side selection look **multi-step**, not naive/direct.

## Why direct selector ranks last

If `0x25` were already a direct payload selector in the strongest sense, we would expect the narrowest unresolved question to be mostly "which payload block does 0x25 point at?"

But current local evidence instead shows:

- pre-copy staging logic
- an intermediate fetched byte at `3652`
- normalization / family logic at `3659-3665`
- a second bank choice (`A=$04` vs `A=$03`)

So a one-byte direct payload interpretation is currently the weakest fit.

## Why table selector ranks first

The strongest current fit is:

- preload entry `0x25` identifies a compact source-side key
- that key yields an intermediate byte/value through a banked lookup
- that intermediate value determines the later source family/path used for the actual block copies

This is best described as a **table selector** model.

## Why reduced selector stays second

A reduced-selector model is still plausible because:

- the intermediate byte is clearly normalized
- there is visible family-level branching before block copies begin

But current evidence still suggests at least one concrete looked-up intermediate value, so a purely reduced/family-only model is slightly weaker than table-first.

## Best current wording

Current safest wording is:

> `0x25` most likely acts as a table-mediated preload selector whose looked-up intermediate value is then normalized into the source-side family/path used by the `$8100-$86FF` staging bridge.

## Practical next target

The next narrow proof target is therefore:

> identify the first intermediate value downstream of preload entry `0x25` and show whether it is obtained by table lookup, by immediate reduction, or by direct payload addressing.
