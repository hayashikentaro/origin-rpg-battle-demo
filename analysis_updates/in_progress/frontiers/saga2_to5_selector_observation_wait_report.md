# SaGa2 `to5` Selector Observation-Wait Report

Date: 2026-05-06

## Summary

Current `to5` state for ROM-side character-image extraction is no longer theory-building.

It is:

> wait for the first selector-stage observation after preload entry `0x25`

Everything else needed for that observation is already in place.

## What is already fixed

- first proof case:
  - map `0`
  - header `63B1`
  - object stream `63C0`
  - preload entry `07:63BE = 0x25`
- local byte boundary:
  - `25 FF 00 0F 43 06 ...`
- path split:
  - `338D` = preload-present gate
  - `363F -> 00AC` = graphics staging bridge into `$8100-$86FF`
  - `339A+` = post-copy object materialization
- selector ranking:
  - table
  - reduced
  - direct

## What is not yet fixed

Only one decisive gap remains:

> after `0x25`, what is the first selector-stage output?

That output is the narrowest missing bridge between:

- concrete preload-list entry
- pre-copy selector stage
- actual source-side payload choice

## Decision rule

When that first output is observed:

- compact key -> table selector
- reduced family -> reduced selector
- direct source class/address -> direct selector

## Best current stance

Until that observation exists, the safest output stays:

- ranking fixed as `table > reduced > direct`
- no new theory inflation
- no exact payload claim
- no final-image identity claim

## Practical restart line

If ROM analysis resumes, restart from exactly this question:

> after preload entry `0x25`, what is the first selector-stage output?
