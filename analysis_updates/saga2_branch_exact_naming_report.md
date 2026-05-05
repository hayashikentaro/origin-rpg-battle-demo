# SaGa2 Branch Exact Naming Report

## Question

`pointerFlavor` を

- `"shared"` = shared/default target-provenance path
- `"candidate"` = candidate-entry target-provenance path

と exact naming へ寄せたあと、first-line の `branch` を同じ粒度でどう呼ぶのが safest か。

## Current best reading

現時点では、`branch` は単なる generic branch family より、
**local resolution mode pair**
として読むのが safest である。

つまり current best wording を code-ready に少し寄せるなら、

- fast/default side = **shared/default local-resolution mode**
- strict/non-fast-path side = **candidate-aware local-resolution mode**

と置くのが最も自然である。

## Why `local-resolution mode`

`branch` は final target や pointer provenance を直接表すのではなく、
`combatDecision` の直後に

- admitted-path activation
- fallback selection

のどちらとしても読まれる **actor-local resolve の mode pair**
として働いている。

したがって second-line の `pointerFlavor` と対称化するなら、
`branch` は provenance ではなく
**local-resolution mode**
という語彙に寄せるのが safest である。

## Why `candidate-aware`

strict/non-fast-path side は pure generic strict path ではなく、
既報の `0E/0F` special-candidate family と qualifier shadow を含んだ
候補解決寄りの side である。

そのため exact wording では、

- `shared/default local-resolution mode`
- `candidate-aware local-resolution mode`

という pair が current best reading に一番よく合う。

## Implication

この naming によって、

- `branch` = first-line local-resolution mode pair
- `pointerFlavor` = second-line target-provenance path pair

という layer-role の違いがかなり見やすくなる。

## Current safest wording

- `branch(shared side)` = shared/default local-resolution mode
- `branch(candidate-aware side)` = candidate-aware local-resolution mode
