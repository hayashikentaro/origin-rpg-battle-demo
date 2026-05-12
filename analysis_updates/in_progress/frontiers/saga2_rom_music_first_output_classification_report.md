# SaGa2 ROM Music First Output Classification Report

Date: 2026-05-06

## Summary

For the current music proof case, the strongest reading is that the first meaningful output from the `$7AEE` anchor is **not** a direct pointer and **not** merely a song key.

Current safest classification is:

> **compact command stream fragment**

## Anchor recap

Current first music anchor:

- script opcode `$32` / `$47`
- `HL = $7AEE`
- `A = $0F`
- `CALL $00D2`
- result written to `saved_bg_music`

Current extracted surface:

- ROM window: `0x7AEE-0x7B6D`
- length: `0x80` bytes

Leading bytes:

```text
04 41 42 01 02 1f 03 23 1f 41 42 1f 43 63 9f ...
```

## Why `compact command stream fragment` is strongest

Three local properties push the reading in this direction.

### 1. Repeated short motifs

The surface is full of short low-valued motifs such as:

- `01 02`
- `03 23`
- `41 42`
- `43 63`
- `40 60`
- `00 20`

This looks much more like symbolic/event-ish token structure than like one-off keys or raw pointers.

### 2. Frequent delimiter-like byte

`0x9F` appears repeatedly and naturally segments the anchor into many short chunks.

Even without proving final semantics for `0x9F`, this is already much more compatible with a stream-like surface than with a single direct pointer surface.

### 3. No strong pointer signature in the opening surface

The first window does not strongly resemble a clean pointer table:

- there is no obvious low/high pointer pair cadence
- the values are densely packed into short repeating symbolic groups
- the cluster looks immediately consumable, not merely referential

So the current safest output is:

- not `direct pointer`
- not primarily `song key`
- but `compact command stream fragment`

## Ranking update

For the music-side classification of `$7AEE`, current safest ranking is:

1. **compact command stream fragment**
2. **song key / compact selector table**
3. **direct pointer surface**

## What this does and does not prove

### Strong enough now

- `$7AEE` is a real ROM-backed music resource surface
- its first visible shape is stream-like
- next decode work should treat it as near-inline music/event data before assuming it is only a table of pointers

### Still not proved

- exact event/opcode semantics
- exact role of `0x9F`
- whether all chunks correspond to one song, several song fragments, or mixed audio resources

## Best current wording

Current safest wording is:

> the `$7AEE` anchor currently looks like a compact music command-stream surface, not a pure pointer table and not just a one-byte song-key indirection layer.

## Practical next target

The next strongest target is:

> test whether `0x9F` behaves like a stable event/phrase terminator or only a convenient local segmentation marker.
