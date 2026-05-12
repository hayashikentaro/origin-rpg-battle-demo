# SaGa2 Debug Field Order Policy Report

## Goal

`branch`, `branchVariant`, `pointerFlavor` の 3 つを debug / trace で並べるとき、
current best reading に最も合う field order を整理する。

## Current safest order

現時点の safest order は次のとおり。

1. `branch`
2. `branchVariant`
3. `pointerFlavor`

つまり

- first-line の lane pair
- first-line の PTR-only refinement
- second-line の provenance reopening

の順で並べるのが最も自然である。

## Why this order works

current best reading では、

- `branch` = actor-local resolution lane pair
- `branchVariant` = PTR-only candidate-family lane refinement bit
- `pointerFlavor` = target-provenance path pair

であり、`postBranchRoute` はその間をつなぐ lane-transfer core である。

そのため debug でも、
first-line から second-line へ下る順序を壊さず

`branch -> branchVariant -> pointerFlavor`

と並べるほうが semantics が追いやすい。

## Why not place `pointerFlavor` earlier

`pointerFlavor` は second-line の strongest field だが、
それを `branchVariant` より前に出すと、

- retained refinement がどこから来たか
- first-line / second-line の境界

が見えにくくなる。

current safest policy は、
**source-side refinement を先に見せ、その landing point を後に見せる**
ことである。

## Recommended debug phrasing

current safest phrasing は、たとえば次の形である。

- `branch=<lane>`
- `branchVariant=<raw>/<side>`
- `pointerFlavor=<value>/<meaning>`

ここで

- raw `0|1` は保持
- side semantics は併記
- `pointerFlavor` は second-line reopening side として最後に出す

のが safest である。

## Current safest summary

現時点の safest debug policy は、
**`branch -> branchVariant -> pointerFlavor` の順に、first-line から second-line への carry を見せる**
ことである。
