# saga2 41e3-41e5 local glue rule

## Current strongest reading

`41E3-41E5` is already the safest place to treat as:

- strongest binding-candidate band
- route-core terminal band
- retained refinement handoff edge
- strongest current carrier of the `0E/0F` code-family split

## What is still missing

the remaining gap is not broad semantic uncertainty. it is the missing local glue between:

- raw `branchVariant 0|1`
- the named side of the `0E/0F` family split

## Safest lock rule

the numeric binding should be treated as locally lockable at `41E3-41E5` only if one of these becomes supportable:

1. raw `0|1` and the `0E/0F` side are visibly carried as a one-step same-local-polarity pair inside the band
2. the band can be read as preserving a code-led split strongly enough that only one raw polarity assignment remains natural

## What not to overclaim

it is still unsafe to claim that `41E3-41E5` already gives:

- exact `0 == shared/default-leaning` or `0 == candidate-aware/strict-leaning`
- exact `1 == ...` complementary naming
- a fully direct opcode-native anchor

## Practical ROM question

**inside `41E3-41E5`, is the code-family split merely carried, or is it carried with enough local polarity to collapse raw `0|1` into one natural side assignment?**

## Working consequence

until that question becomes answerable, the safest implementation stance remains:

- keep raw `branchVariant?: 0 | 1`
- keep deferred numeric binding
- keep same-side correspondence wording
