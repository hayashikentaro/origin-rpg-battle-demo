# saga2 41e3-41e5 same local polarity rule

## Current question

inside `41E3-41E5`, the decisive question is no longer whether a code-family split exists.
that part is already strong.

the remaining question is:

**is the carried `0E/0F` split still only transport, or does it already behave like a same-local-polarity pair with raw `0|1`?**

## Safest threshold

the safest threshold for calling it a same-local-polarity pair is:

- the band preserves the `0E/0F` side strongly enough
- the raw `0|1` candidate can be treated as co-carried rather than reopened later
- no extra remap step is needed between this band and the first effective visibility slot

## What this would change

if that threshold becomes supportable, then `41E3-41E5` stops being only:

- strongest binding-candidate band
- strongest code-family split carrier

and starts being:

- first locally plausible numeric-side glue point

## What it does not yet justify

even with this bias, it is still unsafe to jump directly to:

- exact `0 == shared/default-leaning`
- exact `1 == candidate-aware/strict-leaning`

without stronger one-step local evidence.

## Practical reading

current safest reading remains:

- `41E3-41E5` is close enough to be the first plausible glue point
- but not yet strong enough to collapse raw numeric into named side semantics
