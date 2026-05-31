# saga2 to5 rom stance

## Current stance

for the remaining ROM-side frontier, the safest stance is:

- `41E3-41E5` = strongest carrier
- not yet a numeric-side collapse point
- raw `0|1` binding remains deferred

## Why this stance holds

- retained refinement handoff is already strong
- `0E/0F` code-family split carry is already strong
- first effective same-side visibility is still downstream at `41E7-41E9`
- the missing piece is still the one-step local glue between raw `0|1` and named side semantics

## What would change the stance

only upgrade the stance if all three become supportable together:

1. `0E/0F` split preserve inside `41E3-41E5`
2. raw `0|1` co-carry inside the same band
3. no hidden remap before `41E7-41E9`

## Until then

the safest output remains:

**strongest carrier, not yet a numeric-side collapse point**

## to5 reading

up to this point, the remaining ROM work is not broad semantic discovery.
it is only a decision about whether `41E3-41E5` stays a carrier or can be promoted to the first plausible glue point.
