# SaGa2 ROM Preload List Single-Entry Report

Date: 2026-05-06

## Summary

For the first proof case, the strongest current reading is that preload selector `0x25` is not just abstract header metadata but a **single concrete preload-list entry immediately followed by the `FF` terminator**.

This sharpens the unresolved bridge:

> we no longer need to ask whether `0x25` is "somewhere in header metadata"; we now ask how this single preload-list element is turned into a source-side graphics payload selector

## First proof case bytes

Current case:

- map `0`
- header `63B1`
- object stream `63C0`
- preload-present flag set
- preload selector byte at `07:63BE` = `0x25`

Bytes immediately before object stream start:

```text
07:63B8 .. 07:63C3
01 05 A9 00 02 05 25 FF 00 0F 43 06
```

With current structural reading:

- `... 25 FF` = end of graphics preload list
- `00 0F 43 06 ...` = start of object stream records

## Why this matters

The map-system correction report already stated:

```text
if header flag bit7 set:
  graphics preload list
  ... bytes ...
  FF

then object stream:
```

The first proof case now matches that structure directly.

So the current strongest local reading is:

- preload list exists because `C452` is set
- list has at least one visible entry
- for this case, the last visible preload entry is `0x25`
- the list terminates at `FF`
- the object stream begins immediately after

## Strongest concrete conclusion

Current safest wording is:

> In the first proof case, `07:63BE = 0x25` behaves like a concrete single preload-list element immediately preceding the `FF` list terminator and the start of the object stream.

This is stronger than merely calling it "header metadata".

## What is still unknown

This still does **not** prove:

- whether `0x25` is the only preload entry semantically used by the map
- how `0x25` maps to a graphics bank / source `HL`
- whether the mapping is direct, table-based, or reduced before the `363F -> 00AC` copy bridge

## Best next target

The next narrow target is now:

> determine how a concrete preload-list entry like `0x25`, sitting just before the `FF` terminator, is consumed by the pre-copy selector stage and converted into the source payload later staged into `$8100-$86FF`
