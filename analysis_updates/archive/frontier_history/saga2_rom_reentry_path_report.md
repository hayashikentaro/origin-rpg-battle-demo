# saga2 rom reentry path

## Primary ROM targets

1. `41E3-41E5`
2. `41E3-41E9`
3. `41E7-41E9`

## Why this order

- `41E3-41E5`
  - strongest binding-candidate band
  - strongest current carrier of the `0E/0F` code-family split
  - best place to look for the missing one-step local glue between raw `0|1` and named side semantics
- `41E3-41E9`
  - smallest carry candidate cluster
  - best place to test remap-free carry vs hidden remap
- `41E7-41E9`
  - first effective same-side visibility slot
  - best place to confirm side correspondence, not numeric binding itself

## Shortest ROM question

**how far can `41E3-41E5` support a one-step local glue between raw `branchVariant 0|1` and the `0E/0F` side split?**

## Safe reading

- `41E3-41E5` = route-core terminal band / retained refinement handoff edge
- `41E6` = reopening / consume halo entry
- `41E7-41E9` = first effective pair visibility slot

## Practical ROM rule

start from the handoff edge, widen only if the glue is still missing.
