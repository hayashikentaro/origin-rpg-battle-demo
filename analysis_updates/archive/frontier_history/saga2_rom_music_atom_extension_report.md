# SaGa2 ROM Music Atom Extension Report

Date: 2026-05-08

## Summary

Current strongest local reading is:

- `04 40 60` = stable base atom
- `1F 1F` = deterministic extension/control tail candidate in a larger phrase context

This is the cleanest current local upgrade beyond simple atom recurrence.

## Exact occurrences of `04 40 60`

In the current `$7AEE` anchor segmentation:

- segment `2`: `04 40 60`
- segment `6`: `04 40 60`
- segment `14`: `04 40 60 1f 1f`

All three occurrences begin exactly with the same 3-byte core:

```text
04 40 60
```

Two are closed standalone chunks, and one is an extended variant.

## Exact occurrences of `1F 1F`

`1F 1F` appears only in:

- segment `14`: `04 40 60 1f 1f`
- segment `15`: `03 01 02 03 23 1f 1f 41 42 43 63 1f 1f 00 20`

So current local evidence says:

- `1F 1F` is not a general suffix for every short chunk
- it appears only inside longer/composite phrase contexts

## Strongest implication

This makes the safest current interpretation:

- `04 40 60` is a reusable closed atom
- `04 40 60 1f 1f` is not a different unrelated atom
- it is more naturally read as

```text
base atom (`04 40 60`)
  + deterministic extension/control tail (`1F 1F`)
```

## Why this is stronger than neutral recurrence

If `04 40 60 1f 1f` were just another unrelated chunk, we would not expect:

- exact prefix preservation
- repeated standalone occurrences of the prefix
- `1F 1F` to be restricted to composite contexts

But current evidence gives all three.

## Best current wording

Current safest wording is:

> `04 40 60` behaves like a stable short atom, while `1F 1F` behaves like a composite-context extension/control tail rather than part of the atom’s irreducible core.

## Practical next target

The next strongest local question is:

> does `03 01 02 03 23 1F 1F 41 42 43 63 1F 1F 00 20` decompose into a chain of stable atoms linked by the same `1F 1F` extension/control behavior?
