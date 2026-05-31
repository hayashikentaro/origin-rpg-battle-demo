# SaGa2 ROM First Intermediate Value Target Report

Date: 2026-05-06

## Summary

The remaining ROM-side question for character-image extraction can now be reduced to a single target:

> what is the **first looked-up intermediate value** downstream of preload entry `0x25`?

This is now a better target than "which final image does `0x25` mean?" because the current strongest selector model is already multi-step.

## Why this is the right target

Current strongest model:

```text
0x25
  -> looked-up intermediate value
  -> normalized source family/path
  -> 363F -> 00AC block copy into $8100-$86FF
```

So the narrowest unresolved bridge is not final graphics identity but the **first observable selector-stage output**.

## What counts as the first intermediate value

For current purposes, the first intermediate value is the earliest value that is:

- downstream of preload-list entry `0x25`
- upstream of the `A=$04 / A=$03` branch family split
- more concrete than the raw list element itself

In other words, it should be the earliest local output that tells us:

- either which source family is being selected
- or which compact key is later reduced into that family

## Why this is stronger than direct-binding language

This avoids overclaiming.

We do **not** yet need to say:

- `0x25` directly means one final payload
- `0x25` directly means one bank
- `0x25` directly means one object gfx id

Instead we only need:

> the first looked-up output downstream of `0x25`

That is the smallest proof that can distinguish:

- table selector
- reduced selector
- direct selector

## Practical interpretation rule

If the first downstream output is:

- a fetched compact key from a banked table, table selector wins strongly
- an immediately range/reduced family value, reduced selector gains weight
- a direct payload address/class with no meaningful intermediate stage, direct selector strengthens

## Best current wording

Current safest wording is:

> the next decisive proof is the first looked-up intermediate value downstream of preload entry `0x25`, because that single value will distinguish whether the selector is table-mediated, reduced, or direct.
