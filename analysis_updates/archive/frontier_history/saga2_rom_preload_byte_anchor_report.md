# saga2 rom preload byte anchor

## First concrete preload byte

for the current first proof case:

- map `0`
- header `63B1`
- object stream `63C0`
- `gfx_preload = [37]`

the concrete preload byte is visible in the header bytes as:

```text
07:63B1  c0 5d 19 c5 7f 0d 03 01 05 a9 00 02 05 25 ff ...
                                           ^^
```

that is:

- ROM address `07:63BE`
- ROM offset `0x1E3BE`
- byte value `0x25` = decimal `37`

## Why this matters

the starter case is no longer just "a map with preload metadata".
it is now:

- one concrete header
- one concrete preload byte
- one concrete object stream immediately after it

## Safe reading

the current safest reading is that `0x25` is the first explicit ROM-side graphics payload selector we can point to for character-image extraction work.

it is not yet the decoded tile payload itself, but it is now a direct byte-level anchor.

## Practical next step

the next extractor/probe should begin from:

- header byte `07:63BE = 0x25`

and answer:

- what decode path turns this selector into a graphics bank/tile payload?
