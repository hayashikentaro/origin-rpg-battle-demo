# SaGa2 ROM Music Stable Atom Candidates Report

Date: 2026-05-06

## Summary

Current strongest candidates for stable recurring music/event atoms in the `$7AEE` anchor are:

- `02 00 20`
- `04 40 60`

These now look stronger than merely “short chunks that happen to recur”.

## Exact recurrence

From the current segmented anchor:

### `02 00 20`

Appears as a full chunk twice:

- segment `1`
- segment `5`

And each occurrence starts at offset `0` of the chunk body.

### `04 40 60`

Appears as a full chunk twice:

- segment `2`
- segment `6`

And once as the prefix of a slightly longer chunk:

- segment `14` = `04 40 60 1f 1f`

## Why this matters

This is stronger than general motif repetition because:

- both chunks recur **exactly**
- both recur as **whole units**
- one of them (`04 40 60`) also appears as the stable opening of a longer variant

So the current safest reading is:

- these are not arbitrary byte fragments
- they behave like reusable local atoms/mini-phrases inside the `$7AEE` command surface

## Current best interpretation

Safest current interpretation:

- `02 00 20` = stable short atom candidate
- `04 40 60` = stable short atom candidate with an observable extended form

This makes them better next targets than the long first chunk if the goal is local decode confidence.

## Best current wording

Current safest wording is:

> `02 00 20` and `04 40 60` are the strongest stable atom candidates in the first `$7AEE` music surface, because they recur as exact whole chunks and one also survives as the prefix of a longer variant.

## Practical next target

The next strongest local question is:

> does `04 40 60 1f 1f` behave like `04 40 60` plus a deterministic extension, while `02 00 20` remains a closed atom?
