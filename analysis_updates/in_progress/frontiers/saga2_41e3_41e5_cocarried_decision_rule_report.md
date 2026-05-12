# saga2 41e3-41e5 cocarried decision rule

## Decision focus

the next ROM-side decision is not "what does branchVariant mean in general?"
it is only:

**can `41E3-41E5` be upgraded from strongest carrier to first plausible cocarried glue point?**

## Pass condition

upgrade the band only if all three remain supportable together:

1. the `0E/0F` side split is strongly preserved inside the band
2. the raw `0|1` candidate is most naturally read as co-carried in the same band, not reopened later
3. no hidden remap is needed before the first effective same-side visibility slot at `41E7-41E9`

## Fail condition

keep the current reading if any of these remains weak:

- raw `0|1` only becomes inferable later from visible side
- the band looks like transport without local numeric-side glue
- a hidden remap still feels necessary between handoff and visibility

## Safe output

if it passes:

- `41E3-41E5` = first plausible cocarried glue point

if it fails:

- `41E3-41E5` = strongest carrier, still not enough for numeric-side collapse

## Working rule

do not collapse raw numeric into named side semantics until the pass condition clearly wins.
