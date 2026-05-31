# SaGa2 ROM Music First Chunk Report

Date: 2026-05-06

## Summary

The first `0x9F`-terminated chunk at the `$7AEE` music anchor is now narrow enough to treat as a **local phrase/event fragment**, not just arbitrary bytes.

Current safest reading:

> one longer composite phrase chunk followed by short motif-like chunks

## First chunk

From the extracted manifest:

```text
segment 0
04 41 42 01 02 1f 03 23 1f 41 42 1f 43 63 9f
```

Ignoring the current tentative delimiter `0x9F`, the core bytes are:

```text
04 41 42 01 02 1f 03 23 1f 41 42 1f 43 63
```

## Repetition context

Nearby shorter chunks repeat many of the same motifs:

- `02 00 20`
- `04 40 60`
- `03 1f 01 02 03 23`
- `02 41 42 43 63`

And global byte frequency in the extracted `0x80`-byte window shows:

- `0x1F` appears very often
- `0x9F` appears very often
- `0x01/0x02/0x03/0x04`
- `0x41/0x42`
- `0x43/0x63`
- `0x00/0x20`
- `0x40/0x60`

This is strong local evidence for a motif/event surface rather than random packed state.

## Current safest structural reading

The first chunk is most naturally read as:

- opening class/count byte: `04`
- repeated compact motif groups:
  - `41 42`
  - `01 02`
  - `03 23`
  - `41 42`
  - `43 63`
- punctuated by `1F`

Without overclaiming exact semantics, the safest local interpretation is:

- `1F` behaves like an internal separator/control marker
- the paired values (`41 42`, `43 63`, `00 20`, `40 60`) behave like compact musical/event motifs
- leading low bytes (`02/03/04/06`) plausibly classify or count the following motif group

## What this proves

This is enough to strengthen the earlier classification:

- `$7AEE` is not best treated as a direct pointer surface
- it is not just a one-byte key surface either
- it behaves like a compact command/event stream with short recurring phrase fragments

## What it does not yet prove

This does not yet prove:

- exact note encoding
- exact duration semantics
- exact meaning of `1F`
- exact meaning of `0x9F`

## Best current wording

Current safest wording is:

> the first `$7AEE` chunk already looks like a compact phrase/event fragment with recurring motif pairs and an internal separator-like byte, which strongly supports the “compact command stream fragment” classification.

## Practical next target

The next strongest target is:

> determine whether `0x1F` is the primary intra-chunk separator/control byte, while `0x9F` is the outer chunk terminator.
