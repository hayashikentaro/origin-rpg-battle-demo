# saga2 rom image first case bytes

## First proof case in bytes

current safest first proof case:

- map `0`
- header `63B1`
- object stream `63C0`
- `gfx_preload = [37]`

## ROM offsets

for bank `07`:

- header `63B1` -> ROM offset `0x1E3B1`
- object stream `63C0` -> ROM offset `0x1E3C0`

## Header bytes

header bytes from `07:63B1`:

```text
c0 5d 19 c5 7f 0d 03 01 05 a9 00 02 05 25 ff 00
0f 43 06 f8 91 18 0b 04 c6 5e f0 11 11 44 c6 03
```

current parsed reading already matches this as:

- flag byte `C5`
- extra pair `7F 0D`
- action count `03`
- `gfx_preload_count = 1`
- `gfx_preload = [37]`
- object stream starts at `63C0`

## Object stream opening bytes

object stream bytes from `07:63C0`:

```text
00 0f 43 06 f8 91
18 0b 04 c6 5e f0
11 11 44 c6 03 f1
80 60
22 c1 43 f9 80 61
24 c2 46 f9 80 62
```

first visible object gfx ids are therefore:

- `00`
- `18`
- `11`
- control record `80 60`
- `22`
- `24`

## Why this matters

the first extractor can now begin from a concrete ROM-level starter:

- one known preload id: `37`
- one known header byte region
- one known object stream immediately following it

this is enough to start proving a preload-id -> graphics-payload bridge without guessing the starter address.
