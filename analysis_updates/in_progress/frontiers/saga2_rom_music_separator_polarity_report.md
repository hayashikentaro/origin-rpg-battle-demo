# SaGa2 ROM Music Separator Polarity Report

Date: 2026-05-06

## Summary

Current strongest local evidence supports a polarity split:

- `0x9F` = **outer chunk terminator candidate**
- `0x1F` = **intra-chunk separator/control candidate**

This is now the safest separator reading for the `$7AEE` music anchor.

## Extracted counts

From the current `0x80`-byte `$7AEE` anchor window:

- total segments under current `0x9F` split: `18`
- segments ending with `0x9F`: `17 / 18`
- segments containing `0x1F` inside their core bytes: `9 / 18`

Position evidence:

- `0x9F` positions:
  - `14, 18, 22, 29, 35, 39, 43, 47, 51, 57, 64, 68, 73, 88, 94, 110, 115`
- `0x1F` positions:
  - `5, 8, 11, 24, 63, 70, 77, 80, 83, 92, 93, 100, 101, 106, 107, 112, 119, 122, 125`

## Strongest implication

`0x9F` is highly end-biased.

`0x1F` is not.

That alone makes the split:

- `9F` = outer boundary
- `1F` = inner boundary/control

the strongest current local reading.

## Why this is stronger than neutral segmentation

Earlier, `0x9F` was only a practical segmentation marker.

Current counts make that stronger:

- `0x9F` nearly always closes a segment
- `0x1F` repeatedly appears inside segment bodies
- therefore the two bytes do not play the same structural role

## Best current wording

Current safest wording is:

> `0x9F` behaves like an outer chunk terminator candidate, while `0x1F` behaves like an intra-chunk separator/control candidate inside compact music/event phrase fragments.

## Remaining uncertainty

This still does not prove whether `0x1F` is:

- a pure separator
- a control/event opcode
- a subphrase reset marker

But it strongly narrows where to look next.
