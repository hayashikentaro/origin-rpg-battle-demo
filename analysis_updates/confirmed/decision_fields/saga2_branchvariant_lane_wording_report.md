# SaGa2 BranchVariant Lane Wording Report

## Question

`branch` を

- default resolution lane
- candidate-aware resolution lane

という actor-local resolution lane pair と読んだあと、
`branchVariant` の side semantics を同じ語彙でどう表すのが safest か。

## Current best reading

現時点では、`branchVariant` は
**PTR-only candidate-family lane refinement bit**
と読むのが safest である。

つまり `branchVariant` は branch pair の外にある別 branch ではなく、
candidate-aware side が active なときに lane をさらに絞る
**lane refinement**
として持つのが最も自然である。

## Side semantics under lane wording

numeric `0/1` の exact binding は引き続き保留するが、
semantic side wording は

- shared/default-leaning lane refinement
- candidate-aware/strict-leaning lane refinement

と置くのが safest である。

これにより `branchVariant` は

- PTR-only
- candidate-family aware
- lane-internal refinement

という 3 点をかなり明確に表せる。

## Why this is better than generic “bit”

`branchVariant` を単に refinement bit とだけ呼ぶと、

- branch pair との関係
- second-line reopening との carry

が弱く見えやすい。

いっぽう lane wording を使うと、
これは **resolution lane pair の内部 refinement**
だとはっきりする。

つまり first-line では

- `branch` = which lane family is active
- `branchVariant` = how the PTR candidate-family case refines that lane

という読みが見やすくなる。

## Relation to `pointerFlavor`

この wording だと second-line の

- `"shared"` = shared/default target-provenance path
- `"candidate"` = candidate-entry target-provenance path

とも自然につながる。

すなわち

- first-line = lane + lane refinement
- second-line = provenance path + downstream result

という role split がかなり綺麗にそろう。

## Current safest wording

現時点の safest wording は次のとおり。

- `branchVariant` = PTR-only candidate-family lane refinement bit
- side semantics:
  - shared/default-leaning lane refinement
  - candidate-aware/strict-leaning lane refinement

## Remaining uncertainty

未確定なのは、

- numeric `0/1` binding
- “strict” を wording にどこまで前面化するか

の 2 点である。

ただし current frontier では、
**lane refinement**
という語彙に揃えるのが最も安全である。
