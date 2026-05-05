# SaGa2 PostBranchRoute Lane Transfer Report

## Question

`branch` と `branchVariant` を

- resolution lane pair
- lane refinement bit

として読めるようになったあと、
`postBranchRoute` の wording も同じ語彙へ寄せるなら、どう表すのが safest か。

## Current best reading

現時点では、`postBranchRoute` は
**lane-transfer core**
と読むのが safest である。

より丁寧には、

**actor-local resolution lane / lane refinement を second-line provenance reopening へ渡す transfer core**

と書くのが current best wording に最もよく合う。

## Why `lane-transfer` works better now

既報の naming を並べると、

- `branch` = actor-local resolution lane pair
- `branchVariant` = PTR-only candidate-family lane refinement bit
- `pointerFlavor` = target-provenance path pair

となっている。

この 3 つをつなぐ middle field は、
generic “route” より
**lane-transfer core**
と呼ぶほうが role がかなり見えやすい。

つまり `postBranchRoute` は、
lane-level semantics を provenance-level semantics へ橋渡しする field
として読むのが自然である。

## What it transfers

current best reading では、この field は少なくとも

- active lane side
- PTR path の retained lane refinement

を second-line 側へ受け渡す。

特に strongest downstream landing point は `pointerFlavor` にあるので、
`postBranchRoute` は
**lane-to-provenance transfer**
と読むのが安全である。

## Current safest wording

現時点の safest wording は次のとおり。

- `postBranchRoute` = lane-transfer core
- expanded wording:
  - actor-local resolution lane / lane refinement
  - to target-provenance reopening

## Relation to the temporal chain

この wording は current safest temporal chain

- `41E3-41E5` = retained refinement handoff edge
- `41E6` = halo entry
- `41E7-41E9` = first effective `pointerFlavor` pair visibility

ともよく噛み合う。

つまり `41E3-41E5` は
**lane-transfer core の exact micro-boundary**
と読むのが最も自然である。

## Remaining uncertainty

未確定なのは、

- `transfer` をどこまで battle-native に言い換えるか
- `route` という単語を field name として残しつつ docs wording をどう強めるか

の細部である。

ただし current frontier では、
**lane-transfer core**
という wording が最も安全である。
