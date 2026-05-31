# SaGa2 ROM Music Chunk Comparison Report

Date: 2026-05-06

## Summary

Comparing the first long chunk with the short recurring chunks strengthens the current music read:

> the `$7AEE` surface consists of short recurring motif fragments plus occasional longer composite phrase chunks

## Short recurring chunks

Several chunks recur almost verbatim:

- `02 00 20`
- `04 40 60`
- `03 01 02`
- `04 41 42`
- `02 41 42 43 63`

These are strong candidates for small motif/event units.

## Longer composite chunks

The first chunk:

```text
04 41 42 01 02 1f 03 23 1f 41 42 1f 43 63 9f
```

and later chunks like:

```text
02 03 23 1f 00 20 1f 43 63 1f 40 60 00 20 9f
03 01 02 03 23 1f 1f 41 42 43 63 1f 1f 00 20 9f
```

look like concatenations of the same shorter motif vocabulary.

## Strongest implication

This comparison suggests:

- short chunks are likely local motif/event units
- longer chunks are likely composite phrase fragments formed from those units
- `1F` most plausibly marks internal boundaries/control transitions inside those larger phrases

## Best current wording

Current safest wording is:

> the `$7AEE` cluster is best read as a compact phrase/event surface built from repeating short motif units, with `0x1F` likely marking internal boundaries and `0x9F` likely marking outer chunk termination.

## Practical next target

The next best question is no longer “is this a stream at all?”

It is:

> does one recurring short chunk such as `02 00 20` or `04 40 60` behave like a stable motif/event atom across the anchor window?
